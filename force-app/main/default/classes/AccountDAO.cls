public with sharing class AccountDAO {

    public static List<Account> getAccountsWithCircleAccountsByIds(Set<Id> accountIds){
        return [SELECT ID, Accounts_API__c,Core_API_Number__c,Read_Only_API_Number__c,Sen_Number__c, Signet_Number__c, USDC_Express_Number__c, Cybavo__c,Payments_API__c,Payouts_API__c, (SELECT ID, Accounts_API__c,Core_API_Number__c,Read_Only_API_Number__c,Sen_Number__c, Signet_Number__c, USDC_Express_Number__c, Cybavo__c,Payments_API__c,Payouts_API__c FROM Circle_Accounts__r) FROM Account WHERE ID IN :accountIds];
    }

    public static List<Account> getAccountsWithCircleAccountsAndPOsByIds(Set<Id> accountIds){
        return [SELECT ID, Performance_Objective_Health__c, (SELECT ID,Current_Gross_Burn__c,Current_Gross_Mint__c,Burn_Volume_Last_30_Days__c,Mint_Volume_Last_30_Days__c,Monthly_Avg_Gross_Burn__c,Monthly_Avg_Gross_Mint__c,Starting_Gross_Burn__c,Starting_Gross_Mint__c FROM Circle_Accounts__r),(SELECT ID, Success_Metrics__c, Custom_metric__C, Objective_Status__c,Performance_Objective_Health__c,Stablecoin__c,Current_MEWs__c,Current_Stablecoin_Liquidity__c,Current_Stablecoin_Volume__c,Projected_MeWs_Growth__c,Projected_Total_Stablecoin_Volume__c,Projected_Stablecoin_on_Platform_Growth__c FROM Partnership_Objectives__r WHERE Type__c = 'Partner Metrics Tracking' ORDER BY CreatedDate DESC) FROM Account WHERE ID IN :accountIds];
    }

    public static List<Account> getMatchingAccountsForLeadConversion(Set<String> domainNames, Set<String> companyNames, Set<String> legalEntityNames){
        List<Account_Exclusion_List__mdt> excludeAccounts = [SELECT Id, Account_Id__c, Account_Name__c FROM Account_Exclusion_List__mdt];
        Set<String> excludeAccountIds = new Set<String>();
        for(Account_Exclusion_List__mdt exclusion : excludeAccounts){
            excludeAccountIds.add(exclusion.Account_ID__c);
        }
        if(domainNames.size()>0 || companyNames.size()>0 || legalEntityNames.size()>0){
            return [SELECT Id, Name, Email_Domain__c,Legal_Entity_Name__C, OwnerId FROM Account WHERE (Email_Domain__c in :domainNames OR Name IN :companyNames OR Legal_Entity_Name__C IN :legalEntityNames) AND (NOT ID IN :excludeAccountIds)];
        }
        else{ 
            return null;
        }
    }

    public static List<Account> getAccountsWithContactsAndLifeCycleStages(Set<Id> accountIds){
        return [SELECT ID, Lifecycle_Stage__c, (SELECT ID, Stage__c FROM Contacts) FROM Account WHERE ID IN :accountIds AND Lifecycle_Stage__c != 'Terminated Customer' AND Lifecycle_Stage__c != 'Former Customer'];
    }

    public static List<AccountContactRelation> getAccountContactRelations(Set<Id> relevantContacts, Set<Id> relevantAccounts) {
        return [SELECT ID, AccountId, Account.Product_Interest__C, Contact.Product_Interest__C FROM AccountContactRelation WHERE (ContactID IN :relevantContacts OR AccountID IN : relevantAccounts)];
    }

    public static List<AccountContactRelation> getAccountContactRelationsByContacts(Set<Id> relevantContacts){
        return [SELECT ID FROM AccountContactRelation WHERE ContactID IN :relevantContacts AND IsDirect = False];

    }
}