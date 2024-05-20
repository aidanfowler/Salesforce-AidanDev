public class Leads {

    public static void checkForAndConvertLeads(Map<Id, Lead> newLeads){
        try{
            Map<Id, Lead> leadsToConvertMap = new Map<Id, Lead>();
            for(Lead ld : newLeads.values()){
                if(ld.Auto_Convert__C == true && !ld.IsConverted){
                    leadsToConvertMap.put(ld.id, ld);
                }
            }
            if(leadsToConvertMap.size()>0){
                autoConvertLeads(leadsToConvertMap);
            }
        }
        catch(Exception e){
            CircleException ce = new CircleException('Lead Conversion Error');
            ce.setMessage(e.getMessage() +'\n'+ e.getStackTraceString() + '\n' + 'Lead Map: '+String.valueOf(newLeads));
            EmailService.sendErrorEmail('aidan.fowler@circle.com', 'lead conversion failure: LEADS:', ce);
        }
        
    }

    public static void autoConvertLeads(Map<Id, Lead> leadsToConvert){
        String defaultLeadOwner = Static_User_Settings__c.getInstance().Default_Lead_Conversion_Owner__c;
        Set<String> emailDomainList = new Set<String>();
        Set<String> emailList = new Set<String>();
        Set<String> companyNameList = new Set<String>();
        Set<String> legalEntityNameList = new Set<String>();
        Set<String> domainExclusions = new Set<String>{'icloud.com','gmail.com','yahoo.com'};
        Set<String> companyNameExclusions = new Set<String>{'[not provided]','[No Name Provided]','not provided'};
        
        List<Account> accountsToUpdateName = new List<Account>();
        Map<Id, Database.LeadConvert> massLeadConvertMap = new Map<Id, Database.LeadConvert>();
        
        for(Lead ld : leadsToConvert.values()){
            if(ld.Email_Domain__c != null && !domainExclusions.contains(ld.Email_Domain__c)){
                emailDomainList.add(ld.Email_Domain__c);
            }
            if(ld.Email != null){
                emailList.add(ld.Email);
            }
            if(ld.Company != null && !companyNameExclusions.contains(ld.Company)){
            	companyNameList.add(ld.Company);
            }
            if(ld.Legal_Entity_Name__c != null){
            	legalEntityNameList.add(ld.Legal_Entity_Name__c);
            }
        }
        

        List<Contact> matchedContactList =ContactDAO.getContactsByEmail(emailList);
        Map<String, Contact> emailContactIdMap = new Map<String, Contact>();
        for(Contact con : matchedContactList){
            if(!emailContactIdMap.containsKey(con.Email)){
                emailContactIdMap.put(con.Email, con);
            }
        }
        
        List<Account> matchedAccountList = AccountDAO.getMatchingAccountsForLeadConversion(emailDomainList, companyNameList, legalEntityNameList);
        Map<String, List<Account>> accountsByDomainMap = new Map<String, List<Account>>();
        Map<String, List<Account>> accountsByCompanyMap = new Map<String, List<Account>>();
        Map<String, List<Account>> accountsByLegalEntityMap = new Map<String, List<Account>>();
        if(matchedAccountList != null && matchedAccountList.size()>0){
            for(Account act : matchedAccountList){
                if(emailDomainList.contains(act.Email_Domain__c)){
                    if(accountsByDomainMap.get(act.Email_Domain__C) == null){
                        accountsByDomainMap.put(act.Email_Domain__C, new List<Account>());
                    }
                    accountsByDomainMap.get(act.Email_Domain__C).add(act);
                }
                if(companyNameList.contains(act.Name)){
                    if(accountsByCompanyMap.get(act.Name)==null){
                        accountsByCompanyMap.put(act.Name, new List<Account>());
                    }
                    accountsByCompanyMap.get(act.Name).add(act);
                }
                if(legalEntityNameList.contains(act.Legal_Entity_Name__c)){
                    if(accountsByLegalEntityMap.get(act.Legal_Entity_Name__c)==null){
                        accountsByLegalEntityMap.put(act.Legal_Entity_Name__c, new List<Account>());
                    }
                    accountsByLegalEntityMap.get(act.Legal_Entity_Name__c).add(act);
                }
            }
        }
        
        
        for(Lead ld : leadsToConvert.values()){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.id);
            lc.setConvertedStatus('Qualified');
            lc.setDoNotCreateOpportunity(TRUE);
            Account matchedAccount = null;
            if((matchedAccountList != null && matchedAccountList.size()>0) || emailContactIdMap.get(ld.Email) != null){
                String ownerId = ld.OwnerId;
                if(ld.Is_This_A_Work_Email__c == 'Yes' && accountsByDomainMap.get(ld.Email_Domain__c) != null){
                    matchedAccount = accountsByDomainMap.get(ld.Email_Domain__c).get(0);
                }
                else if(ld.Legal_Entity_Name__c != null && accountsByLegalEntityMap.get(ld.Legal_Entity_Name__c) != null){
                    matchedAccount = accountsByLegalEntityMap.get(ld.Legal_Entity_Name__c).get(0);
                }
                else if(ld.Company != null && accountsByCompanyMap.get(ld.Company) != null){
                    matchedAccount = accountsByCompanyMap.get(ld.Company).get(0);
               }
                else if(ld.Email != null && emailContactIdMap.get(ld.Email) != null){
                    matchedAccount = new Account(Id = emailContactIdMap.get(ld.Email).accountId, Name = emailContactIdMap.get(ld.Email).Account.Name, OwnerId = emailContactIdMap.get(ld.Email).Account.OwnerId);
                }

                if(matchedAccount != null){
                    if(emailContactIdMap.containsKey(ld.Email)){
                        lc.setContactId(emailContactIdMap.get(ld.Email).id);
                    }
                    lc.setAccountId(matchedAccount.id);
                    lc.setOwnerId(matchedAccount.OwnerId);

                    String accountName = matchedAccount.Name;
                    if(accountName != null){
                        accountName = accountName.toLowerCase();
                        if(accountName.contains('not provided') && ld.Legal_Entity_Name__c != null){
                            matchedAccount.Name = ld.Legal_Entity_Name__c;
                            accountsToUpdateName.add(matchedAccount);
                        }
                    }
                }
            }
            if(matchedAccount == null){
                if(ld.SDR_Owner__c != null && ld.SDR_Owner_Is_Active__c){
                    lc.setOwnerId(ld.SDR_Owner__c);
                }
                else{
                    lc.setOwnerId(defaultLeadOwner);
                }
            }
            massLeadConvertMap.put(ld.id, lc);
        }
        
        if(massLeadConvertMap.size()>0){
            List<Database.LeadConvertResult> lcrList = Database.convertLead(massLeadConvertMap.values());
            if(accountsToUpdateName.size()>0){
                update accountsToUpdateName;
            }
        }    
    }

    public static void dataDeletedRequest(Map<Id, Lead> newLeads, Map<Id, Lead> oldLeads){
        Set<String> ignoreFields = new Set<String>{'OwnerId', 'Email','Data_Deleted_Customer_Request__c'};
        Set<String> requiredFieldsToClear = new Set<String>{'FirstName', 'LastName','Company','Status'};
        Map<String, SObjectField> leadFieldMap = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
        Set<Id> leadsToClear = new Set<Id>();
        for(Id id : newLeads.keySet()){
            if(newLeads.get(id).Data_Deleted_Customer_Request__c == true && oldLeads.get(id).Data_Deleted_Customer_Request__c == false){
                leadsToClear.add(id);
            }
        }
        if(leadsToClear.size()>0){
            for(Id id : leadsToClear){
                Map<String, Object> fields = newLeads.get(id).getPopulatedFieldsAsMap();
                for (String field : fields.keySet()){
                    if (!ignoreFields.contains(field) && !field.contains('__r') && newLeads.get(id).get(field)!=null && leadFieldMap.get(field).getDescribe().isUpdateable()){
                        if(leadFieldMap.get(field).getDescribe().getType() == Schema.DisplayType.Boolean){
                            newLeads.get(id).put(field, false);
                        }
                        else if(requiredFieldsToClear.contains(field)){
                            newLeads.get(id).put(field,'Data Deleted');
                        }
                        else{
                            newLeads.get(id).put(field, null);
                        }
                    }
                    else if(field.contains('Email')){
                        newLeads.get(id).Email = 'data_deleted_'+newLeads.get(id).Email;
                    }
                }
            }
        }
    }
}