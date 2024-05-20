public class AutoConvertLead {
    private static LeadStatus m_leadStatus;
	private static Map<String, Id> m_emailContactIdMap; 
    private static List<Account_Exclusion_List__mdt> m_accountExclusionList;
    public static void checkForLeadsToConvert(Map<Id, Lead> a_leadMap){
        try{
            System.debug('INSIDE checkForLeadsToConvert');
            
            //Group autoConvertQueue = [select id, developerName from Group where developerName = 'Auto_Convert'];
            Map<Id, Lead> leadsToConvertMap = new Map<Id, Lead>();
            for(Lead ld : a_leadMap.values()){
                
                //if(ld.OwnerId == autoConvertQueue.Id && !ld.IsConverted
                if(ld.Auto_Convert__c == true && !ld.IsConverted
                && ld.Email_Domain__c != NULL){
                    leadsToConvertMap.put(ld.Id, ld);
                }
                
            }
            if(leadsToConvertMap.size() > 0){
                convertAutoConvertLeads(leadsToConvertMap);
            }
        }
        catch(Exception e){
            CircleException ce = new CircleException('Lead Conversion Error');
            
            ce.setMessage(e.getMessage() + '\n' + 'Lead Map: '+String.valueOf(a_leadMap));
            EmailService.sendErrorEmail('aidan.fowler@circle.com', 'lead conversion failure: LEADS:', ce);
            //throw e;
        }        
    }
    
    private static void convertAutoConvertLeads(Map<Id, Lead> a_leadMap){
        System.debug('INSIDE convertAutoConvertLeads');
        
        m_leadStatus = [Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        
        Map<Id, Database.LeadConvert> massLeadConvertMap = new Map<Id, Database.LeadConvert>();
        User owner = [select id from User where Name = 'Emily Ball'];
        List<String> emailDomainList = new List<String>();
        List<String> companyNameList = new List<String>();
        List<String> legalEntityNameList = new List<String>();
        List<String> emailList = new List<String>();
        
        for(Lead ld : a_leadMap.values()){
            emailDomainList.add(ld.Email_Domain__c);
            if(ld.Company != null){
            	companyNameList.add(ld.Company);
            }
            if(ld.Email != null){
                emailList.add(ld.Email);
            }
            if(ld.Legal_Entity_Name__c != null){
            	legalEntityNameList.add(ld.Legal_Entity_Name__c);
            }
        }
        if(companyNameList.size() > 0){
            System.debug(companyNameList);
            Integer i = 0;
        }
        if(legalEntityNameList.size() > 0){
            System.debug(legalEntityNameList);
            Integer i = 0;
        }
        
        List<Contact> matchedContactList = [select id, email, AccountId from contact where email != null
                                            and email in :emailList];
        Map<String, Id> emailContactIdMap = new Map<String, Id>();
        for(Contact con : matchedContactList){
            if(!emailContactIdMap.containsKey(con.Email)){
                emailContactIdMap.put(con.Email, con.Id);
            }
        }
        m_emailContactIdMap = new Map<String, Id>();
        m_emailContactIdMap = emailContactIdMap;
        
        for(Lead ld : a_leadMap.values()){
            String leadOwnerId = ld.OwnerId;
            
            Database.LeadConvert lc = createLeadConvert(ld.Id);
            if(emailContactIdMap.containsKey(ld.Email)){
                
                lc.setContactId(emailContactIdMap.get(ld.Email));
            }
            if(leadOwnerId.startsWith('00G')){
                String sdrOwnerId = ld.SDR_Owner__c;
                if(sdrOwnerId != null){
                    lc.setOwnerId(sdrOwnerId);
                }
                else{
                    lc.setOwnerId(owner.Id);
                }
            }
            
            massLeadConvertMap.put(ld.id, lc);
        }
        List<Account> matchedEmailAccounts = new List<Account>();
        matchedEmailAccounts = [select id, email_domain__c, OwnerId from Account where email_domain__c in :emailDomainList
                                and email_domain__c != null and email_domain__c != 'gmail.com' and email_domain__c != 'yahoo.com'
                                and email_domain__c != 'icloud.com'];
        
        List<Id> matchedEmailIdList = new List<Id>();
        for(Account acc : matchedEmailAccounts){
            matchedEmailIdList.add(acc.Id);
        }
        
        List<Account> matchedCompanyAccounts = new List<Account>();
        matchedCompanyAccounts = [select id, Name, OwnerId from Account where 
                                  Name in :companyNameList and Name != '[not provided]'
                                  and Name != '[No Name Provided]'];
        
        List<Account> matchedLegalAccounts = new List<Account>();
        matchedLegalAccounts = [select id, Legal_Entity_Name__c, OwnerId from Account where 
                                Legal_Entity_Name__c in :legalEntityNameList
                                ];
        
        if(matchedCompanyAccounts.size() > 0){
            System.debug(matchedCompanyAccounts);
            Integer i = 0;
        }
        if(matchedLegalAccounts.size() > 0){
            System.debug(matchedLegalAccounts);
            Integer i = 0;
        }
        //List<Account> matchedAccounts = new List<Account>();
        //matchedAccounts.addAll(matchedLegalAccounts);
        //matchedAccounts.addAll(matchedEmailAccounts);
        //Map<Id, Account> matchedAccountMap = new Map<Id, Account>(matchedAccounts);
        System.debug(legalEntityNameList);
        System.debug(companyNameList);
        if(matchedEmailAccounts.size() > 0 || matchedLegalAccounts.size() > 0 || matchedCompanyAccounts.size() > 0){
            m_accountExclusionList = new List<Account_Exclusion_List__mdt>();
            m_accountExclusionList = [select id, Account_Id__c, Account_Name__c from Account_Exclusion_List__mdt];
            Map<String, Account_Exclusion_List__mdt> accountExclusionMap = new Map<String, Account_Exclusion_List__mdt>();
            for(Account_Exclusion_List__mdt acl : m_accountExclusionList){
                if(!accountExclusionMap.containsKey(acl.Account_Id__c)){
                    accountExclusionMap.put(acl.Account_Id__c, acl);
                }
            }
            
            for(Lead ld : a_leadMap.values()){
                Boolean matched = false;
                String ownerId = ld.OwnerId;
                if(ld.Is_this_a_work_email__c != null && ld.Is_this_a_work_email__c == 'Yes'){
                    for(Account acc : matchedEmailAccounts){
                        if(ld.Email_Domain__c == acc.Email_Domain__c){
                            massLeadConvertMap.remove(ld.Id);
                            
                            Database.LeadConvert lc = createLeadConvert(ld.Id);
                            if(emailContactIdMap.containsKey(ld.Email)){
                                lc.setContactId(emailContactIdMap.get(ld.Email));
                            }
                            if(OwnerId.startsWith('00G')){
                                lc.setOwnerId(acc.OwnerId);
                            }
                            lc.setAccountId(acc.Id);
                            massLeadConvertMap.put(ld.id, lc);
                            matched = true;
                            break;
                        }
                    }
                }
                if(!matched){
                    for(Account acc : matchedCompanyAccounts){
                        String companyName = ld.Company;
                        companyName = companyName.toLowerCase();
                        if(ld.Company == acc.Name && !accountExclusionMap.containsKey(acc.Id)
                           && !companyName.contains('not provided')){
                            matched = true;
                            massLeadConvertMap.remove(ld.Id);
                            Database.LeadConvert lc = createLeadConvert(ld.Id);
                            if(emailContactIdMap.containsKey(ld.Email)){
                                lc.setContactId(emailContactIdMap.get(ld.Email));
                            }
                            if(OwnerId.startsWith('00G')){
                                lc.setOwnerId(acc.OwnerId);
                            }
                            lc.setAccountId(acc.Id);
                            massLeadConvertMap.put(ld.id, lc);
                            break;
                        }
                    }
                }
                if(!matched){
                    for(Account acc : matchedLegalAccounts){
                        if(ld.Legal_Entity_Name__c == acc.Legal_Entity_Name__c && !accountExclusionMap.containsKey(acc.Id)){
                            matched = true;
                            massLeadConvertMap.remove(ld.Id);
                            Database.LeadConvert lc = createLeadConvert(ld.Id);
                            if(emailContactIdMap.containsKey(ld.Email)){
                                lc.setContactId(emailContactIdMap.get(ld.Email));
                            }
                            if(OwnerId.startsWith('00G')){
                                lc.setOwnerId(acc.OwnerId);
                            }
                            lc.setAccountId(acc.Id);
                            
                            massLeadConvertMap.put(ld.id, lc);
                            break;
                        }
                    }
                }
                matched = false;
            }
        }
        
        if(massLeadConvertMap.size() > 0){
            for(Id id : massLeadConvertMap.keyset()){
                if(massLeadConvertMap.get(id).getContactId() != null && massLeadConvertMap.get(id).getAccountId() == null){
                    massLeadConvertMap.get(id).setContactId(null);
                }
            }
            List<Database.LeadConvertResult> lcrList = Database.convertLead(massLeadConvertMap.values());
            
            List<Account> nameChangeAccountList = new List<Account>();
            for(Database.LeadConvertResult lcr : lcrList){
                Lead convertedLead = a_leadMap.get(lcr.getLeadId());
                String leadCompanyName = convertedLead.Company;
                leadCompanyName = leadCompanyName.toLowerCase();
                String leadLegalEntityName = convertedLead.Legal_Entity_Name__c;
                if(leadCompanyName.contains('not provided') && !(String.isBlank(leadLegalEntityName))){
                    nameChangeAccountList.add(new Account(Id = lcr.getAccountId(), Name = leadLegalEntityName));
                }
            }
            if(nameChangeAccountList.size() > 0){
                update nameChangeAccountList;
            }
            
        	
        }
    }
    private static Database.LeadConvert createLeadConvert(Id a_leadId){
        System.debug('INSIDE createLeadConvert method');
        
        Database.LeadConvert singleLeadconvert = new Database.LeadConvert();
        singleLeadconvert.setLeadId(a_leadId);
        singleLeadconvert.setConvertedStatus(m_leadStatus.MasterLabel);
        singleLeadconvert.setDoNotCreateOpportunity(TRUE);
        
        return singleLeadConvert;
    }
}