global class RollUpCircleAccountMetricsBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,Account_Lookup__c FROM Circle_Account__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Circle_Account__c> circleAccounts) {
        Set<Id> accountIds = new Set<Id>();
        for(Circle_Account__c ca : circleAccounts){
            accountIds.add(ca.Account_Lookup__c);
        }
        Accounts.rollUpAccountMetrics(accountIds);
    }
     
    global void finish(Database.BatchableContext bc) {
    }
}