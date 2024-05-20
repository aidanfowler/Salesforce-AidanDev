public with sharing class CircleAccounts {
    
    public static void rollUpToAccountLevel(Map<Id, Circle_Account__c> newCircleAccounts, Map<Id, Circle_Account__c> oldCircleAccounts){
        Set<Id> allAccountsToUpdateSet = new Set<Id>();
        
        for(Id id : newCircleAccounts.keyset()){
            if(oldCircleAccounts != null){
                if(newCircleAccounts.get(id).Accounts_API__c != oldCircleAccounts.get(id).Accounts_API__c || newCircleAccounts.get(id).Core_API_Number__c != oldCircleAccounts.get(id).Core_API_Number__c
                || newCircleAccounts.get(id).Read_Only_API_Number__c != oldCircleAccounts.get(id).Read_Only_API_Number__c || newCircleAccounts.get(id).Sen_Number__c != oldCircleAccounts.get(id).Sen_Number__c
                || newCircleAccounts.get(id).Signet_Number__c != oldCircleAccounts.get(id).Signet_Number__c || newCircleAccounts.get(id).USDC_Express_Number__c != oldCircleAccounts.get(id).USDC_Express_Number__c
                || newCircleAccounts.get(id).Cybavo__c != oldCircleAccounts.get(id).Cybavo__c || newCircleAccounts.get(id).Payments_API__c != oldCircleAccounts.get(id).Payments_API__c 
                || newCircleAccounts.get(id).Payouts_API__c != oldCircleAccounts.get(id).Payouts_API__c || newCircleAccounts.get(id).Account_lookup__c != oldCircleAccounts.get(id).Account_lookup__c ){
                    if(newCircleAccounts.get(id).Account_lookup__C != null){
                        allAccountsToUpdateSet.add(newCircleAccounts.get(id).Account_lookup__C);
                    }
                    if(oldCircleAccounts.get(id).Account_lookup__C != null){
                        allAccountsToUpdateSet.add(oldCircleAccounts.get(id).Account_lookup__C);
                    }
                }
            }
            else{
                if((newCircleAccounts.get(id).Accounts_API__c != null || newCircleAccounts.get(id).Core_API__c != null || newCircleAccounts.get(id).Read_Only_API__c != false || newCircleAccounts.get(id).Sen__c != false 
                || newCircleAccounts.get(id).Signet__c != false || newCircleAccounts.get(id).USDC_Express__c != false || newCircleAccounts.get(id).Cybavo__c != null  || newCircleAccounts.get(id).Payments_API__c != null
                || newCircleAccounts.get(id).Payouts_API__c != null) && newCircleAccounts.get(id).Account_lookup__C != null){
                    allAccountsToUpdateSet.add(newCircleAccounts.get(id).Account_lookup__C);
                }
            }
        }

        if(allAccountsToUpdateSet.size()>0){
            List<Account> allAccountsToUpdate = AccountDAO.getAccountsWithCircleAccountsByIds(allAccountsToUpdateSet);
            rollUpToAccount(allAccountsToUpdate);
            update allAccountsToUpdate;
        }
    }

    public static void rollUpToAccount(List<Account> accountAPIAccountsToUpdate){
        for(Account act : accountAPIAccountsToUpdate){
            Set<String> accountAPIValuesSet = new Set<String>();
            Set<String> cybavoValueSet = new Set<String>();
            Set<String> paymentsApiValueSet = new Set<String>();
            Set<String> payoutsApiValueSet = new Set<String>();
            String accountAPIValues = ''; 
            String cybavoValues = '';
            String paymentApiValues = '';
            String payoutsApiValues = '';
            Decimal coreApiSum = 0;
            Decimal readOnlyApiSum = 0;
            Decimal senSum = 0;
            Decimal sigNetSum = 0;
            Decimal usdcExpressSum = 0;
            
            for(Circle_Account__C circleAct : act.Circle_Accounts__r){
                if(circleAct.Accounts_API__c != null){
                    accountAPIValuesSet.add(circleAct.Accounts_API__c);
                }
                if(circleAct.Cybavo__c != null){
                    for(String val : circleAct.Cybavo__c.split(';')){
                        cybavoValueSet.add(val);
                    }
                }
                if(circleAct.Payments_API__c != null){
                    for(String val : circleAct.Payments_API__c.split(';')){
                        paymentsApiValueSet.add(val);
                    }
                }
                if(circleAct.Payouts_API__c != null){
                    for(String val : circleAct.Payouts_API__c.split(';')){
                        payoutsApiValueSet.add(val);
                    }
                }
                coreApiSum += circleAct.Core_API_Number__c;
                readOnlyApiSum += circleAct.Read_Only_API_Number__c;
                senSum += circleAct.Sen_Number__c;
                sigNetSum += circleAct.Signet_Number__c;
                usdcExpressSum += circleAct.USDC_Express_Number__c;   
            }

            for(String apiVal : accountAPIValuesSet){
                accountAPIValues += apiVal + ';';
            }
            accountAPIValues = accountAPIValues.removeEnd(';');
            act.Accounts_API__c = accountAPIValues;

            for(String cybavoVal : cybavoValueSet){
                cybavoValues += cybavoVal + ';';
            }
            cybavoValues = cybavoValues.removeEnd(';');
            act.Cybavo__c = cybavoValues;

            for(String paymentApiVal : paymentsApiValueSet){
                paymentApiValues += paymentApiVal + ';';
            }
            paymentApiValues = paymentApiValues.removeEnd(';');
            act.Payments_API__c = paymentApiValues;

            for(String payoutApiVal : payoutsApiValueSet){
                payoutsApiValues += payoutApiVal + ';';
            }
            payoutsApiValues = payoutsApiValues.removeEnd(';');
            act.Payouts_API__c = payoutsApiValues;
            act.Core_API_Number__c = coreApiSum;
            act.Read_Only_API_Number__c = readOnlyApiSum;
            act.Sen_Number__c = senSum;
            act.Signet_Number__C = sigNetSum;
            act.USDC_Express_Number__C = usdcExpressSum;
        }
    }

    public static void rollUptoLeadLevel(Map<Id, Circle_Account__C> newCircleAccounts, Map<Id, Circle_Account__c> oldCircleAccounts){
        Set<Id> leadsToUpdateSet = new Set<Id>();

        for(Id id : newCircleAccounts.keyset()){
            if(oldCircleAccounts == null){
                if(newCircleAccounts.get(id).Lead__c != null){
                    leadsToUpdateSet.add(newCircleAccounts.get(id).Lead__C);
                }
            }
            else{
                if(newCircleAccounts.get(id).Lead__C != oldCircleAccounts.get(id).Lead__C){
                    if(newCircleAccounts.get(id).Lead__C != null){
                        leadsToUpdateSet.add(newCircleAccounts.get(id).Lead__c);
                    }
                    if(oldCircleAccounts.get(id).Lead__c != null){
                        leadsToUpdateSet.add(oldCircleAccounts.get(id).Lead__c);
                    }
                }
            }
        }

        if(leadsToUpdateSet.size()>0){
            List<Lead> leadsToUpdate = LeadDAO.getLeadsAndCircleAccountsById(leadsToUpdateSet);
            for(Lead theLead : leadsToUpdate){
                Integer count = 0;
                for(Circle_Account__c ca : theLead.Circle_Accounts__r){
                    count++;
                }
                theLead.Number_Of_Circle_Accounts__c = count;
            }
            update leadsToUpdate;
        }
    }

    public static void setRegionFromCountry(List<Circle_Account__c> newCircleAccounts){
        List<Circle_Account__c> accountsNeedCountry = new List<Circle_Account__c>();
        for(Circle_Account__c ca : newCircleAccounts){
            if(ca.Country_Of_Incorporation__c != null){
                accountsNeedCountry.add(ca);
            }
        }
        if(accountsNeedCountry.size()>0){
            attachRegionFromCountry(accountsNeedCountry);
        }
    }

    public static void setRegionFromCountry(Map<Id, Circle_Account__c> newCircleAccounts, Map<Id, Circle_Account__c> oldCircleAccounts){
        List<Circle_Account__c> accountsNeedCountry = new List<Circle_Account__c>();
        for(Id id : newCircleAccounts.keyset()){
            if(newCircleAccounts.get(id).Country_of_Incorporation__c != oldCircleAccounts.get(id).Country_of_Incorporation__c){
                if(newCircleAccounts.get(id).Country_of_Incorporation__c == null){
                    newCircleAccounts.get(id).Region__c = null;
                }
                else{
                    accountsNeedCountry.add(newCircleAccounts.get(id));
                }
            }
        }
        if(accountsNeedCountry.size()>0){
            attachRegionFromCountry(accountsNeedCountry);
        }
    }

    public static void attachRegionFromCountry(List<Circle_Account__c> circleAccounts){
        List<Schema.PicklistEntry> picklistValues = Circle_Account__c.Country_Of_Incorporation__c.getDescribe().getPicklistValues();
        Map<String,String> countryAPIToLabelMap = new Map<String,String>();
        for(Schema.PicklistEntry sp : picklistValues){
            countryAPIToLabelMap.put(sp.getValue(), sp.getLabel());
        }
        Set<String> caCountryLabels = new Set<String>();
        for(Circle_Account__c ca : circleAccounts){
            caCountryLabels.add(countryAPIToLabelMap.get(ca.Country_Of_Incorporation__c));
        }
        List<Country_Region_Mapping__mdt> crms = [SELECT Country__c, Region__c FROM Country_Region_Mapping__mdt WHERE Country__c IN :caCountryLabels];
        Map<String, String> crmMap = new Map<String, String>();
        for(Country_Region_Mapping__mdt crm : crms){
            crmMap.put(crm.Country__C, crm.Region__c);
        }
        for(Circle_Account__c ca : circleAccounts){
            if(crmMap.get(countryAPIToLabelMap.get(ca.Country_Of_Incorporation__c)) != null){
                ca.Region__c = crmMap.get(countryAPIToLabelMap.get(ca.Country_Of_Incorporation__c));
            }
        }
    }

    public static void rollUpAccountMetrics(Map<Id, Circle_Account__c> newCircleAccounts, Map<Id, Circle_Account__c> oldCircleAccounts){
        Set<Id> allAccountsToUpdateSet = new Set<Id>();
        
        for(Id id : newCircleAccounts.keyset()){
            if(oldCircleAccounts != null){
                if((newCircleAccounts.get(id).Current_Gross_Burn__c != oldCircleAccounts.get(id).Current_Gross_Burn__c || newCircleAccounts.get(id).Current_Gross_Mint__c != oldCircleAccounts.get(id).Current_Gross_Mint__c
                || newCircleAccounts.get(id).Burn_Volume_Last_30_Days__c != oldCircleAccounts.get(id).Burn_Volume_Last_30_Days__c ||newCircleAccounts.get(id).Mint_Volume_Last_30_Days__c != oldCircleAccounts.get(id).Mint_Volume_Last_30_Days__c 
                || newCircleAccounts.get(id).Monthly_Avg_Gross_Burn__c != oldCircleAccounts.get(id).Monthly_Avg_Gross_Burn__c ||newCircleAccounts.get(id).Monthly_Avg_Gross_Mint__c != oldCircleAccounts.get(id).Monthly_Avg_Gross_Mint__c
                || newCircleAccounts.get(id).Starting_Gross_Burn__c != oldCircleAccounts.get(id).Starting_Gross_Burn__c ||newCircleAccounts.get(id).Starting_Gross_Mint__c != oldCircleAccounts.get(id).Starting_Gross_Mint__c
                || newCircleAccounts.get(id).Account_lookup__C != oldCircleAccounts.get(id).Account_lookup__C) 
                && (newCircleAccounts.get(id).Account_lookup__C != null || oldCircleAccounts.get(id).Account_lookup__C != null)){
                    if(newCircleAccounts.get(id).Account_lookup__C != null){
                        allAccountsToUpdateSet.add(newCircleAccounts.get(id).Account_lookup__C);
                    }
                    if(oldCircleAccounts.get(id).Account_lookup__C != null){
                        allAccountsToUpdateSet.add(oldCircleAccounts.get(id).Account_lookup__C);
                    }
                }
            }
            else{
                if((newCircleAccounts.get(id).Current_Gross_Burn__c != null || newCircleAccounts.get(id).Current_Gross_Mint__c != null || newCircleAccounts.get(id).Burn_Volume_Last_30_Days__c != null || newCircleAccounts.get(id).Mint_Volume_Last_30_Days__c != null
                || newCircleAccounts.get(id).Monthly_Avg_Gross_Burn__c != null || newCircleAccounts.get(id).Monthly_Avg_Gross_Mint__c != null || newCircleAccounts.get(id).Starting_Gross_Burn__c != null || newCircleAccounts.get(id).Starting_Gross_Mint__c != null) 
                && newCircleAccounts.get(id).Account_lookup__C != null){
                    allAccountsToUpdateSet.add(newCircleAccounts.get(id).Account_lookup__C);
                }
            }
        }

        if(allAccountsToUpdateSet.size()>0){
            Accounts.rollUpAccountMetrics(allAccountsToUpdateSet);
        }
    }
}