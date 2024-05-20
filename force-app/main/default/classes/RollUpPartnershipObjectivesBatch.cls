global class RollUpPartnershipObjectivesBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,Account__c,Type__c,Current_Stablecoin_Liquidity__c,Current_MEWs__c,Current_Stablecoin_Volume__c,Projected_MeWs_Growth__c,Mews_Growth__c, Stablecoin_On_Platform_Growth__c, Stablecoin_Volume_Growth__c, Projected_Total_Stablecoin_Volume__c,Projected_Stablecoin_on_Platform_Growth__c,Stablecoin__c, Success_Metrics__c, Starting_Mews__C, Starting_Stablecoin_liquidity__c, Starting_Stablecoin_Volume__c FROM Partnership_Objective__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Partnership_Objective__c> objectives) {
        Set<Id> accountIds = new Set<Id>();
        Set<Partnership_Objective__c> objectivesToRecalculate = new Set<Partnership_Objective__c>();
        for(Partnership_objective__c objective : objectives){
            accountIds.add(objective.Account__c);
            if(objective.Type__c =='Partner Metrics Tracking'){
                objectivesToRecalculate.add(objective);
            }
        }
        Accounts.rollUpAccountMetrics(accountIds);
        if(objectivesToRecalculate.size()>0){
            PartnershipObjectives.rollUpPOMetrics(objectivesToRecalculate);
            List<Partnership_Objective__c> objectivesToUpdate = new List<Partnership_Objective__c>();
            objectivesToUpdate.addAll(objectivesToRecalculate);
            update objectivesToUpdate;
        }
    }
     
    global void finish(Database.BatchableContext bc) {
    }
}