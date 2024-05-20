global class PartnershipObjectivePullOppMetricsBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,Data_Pulled_From_Opportunity_Datestamp__c,MeW_Timeframe_in_months__c,Projected_Mews_Growth__c,Stablecoin_Volume_Timeframe_in_months__c,Projected_Total_Stablecoin_Volume__c,Stablecoin_On_Pltfrm_Timeframe_months__c,Projected_Stablecoin_on_Platform_Growth__c,Monthly_active_users__C,Success_Metrics_Details__c,Success_Metrics_Tracking__C, Opportunity__r.MeW_Timeframe_in_months__c, Opportunity__r.Monthly_active_users__C, Opportunity__r.Projected_Mews_Growth__c, Opportunity__r.Projected_Total_Stablecoin_Volume__c, Opportunity__r.Projected_Stablecoin_on_Platform_Growth__c, Opportunity__r.Stablecoin_Volume_Timeframe_in_months__c, Opportunity__r.Stablecoin_On_Pltfrm_Timeframe_months__c, Opportunity__r.Success_Metrics_Details__c, opportunity__r.Success_Metrics_Tracking__C FROM Partnership_Objective__c Where Opportunity__r.LastModifiedDate = LAST_N_DAYS:2';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Partnership_Objective__c> objectives) {
        for(Partnership_objective__c objective : objectives){
            Boolean updated = false;
            if(objective.MeW_Timeframe_in_months__c == null && objective.opportunity__r.MeW_Timeframe_in_months__c != null){
                objective.MeW_Timeframe_in_months__c = objective.opportunity__r.MeW_Timeframe_in_months__c;
                updated = true;
            }
            if(objective.Projected_Mews_Growth__c == null && objective.opportunity__r.Projected_Mews_Growth__c != null){
                objective.Projected_Mews_Growth__c = objective.opportunity__r.Projected_Mews_Growth__c;
                updated = true;
            }
            if(objective.Stablecoin_Volume_Timeframe_in_months__c == null && objective.opportunity__r.Stablecoin_Volume_Timeframe_in_months__c != null){
                objective.Stablecoin_Volume_Timeframe_in_months__c = objective.opportunity__r.Stablecoin_Volume_Timeframe_in_months__c;
                updated = true;
            }
            if(objective.Projected_Total_Stablecoin_Volume__c == null && objective.opportunity__r.Projected_Total_Stablecoin_Volume__c != null){
                objective.Projected_Total_Stablecoin_Volume__c = objective.opportunity__r.Projected_Total_Stablecoin_Volume__c;
                updated = true;
            }
            if(objective.Stablecoin_On_Pltfrm_Timeframe_months__c == null && objective.opportunity__r.Stablecoin_On_Pltfrm_Timeframe_months__c != null){
                objective.Stablecoin_On_Pltfrm_Timeframe_months__c = objective.opportunity__r.Stablecoin_On_Pltfrm_Timeframe_months__c;
                updated = true;
            }
            if(objective.Projected_Stablecoin_on_Platform_Growth__c == null && objective.opportunity__r.Projected_Stablecoin_on_Platform_Growth__c != null){
                objective.Projected_Stablecoin_on_Platform_Growth__c = objective.opportunity__r.Projected_Stablecoin_on_Platform_Growth__c;
                updated = true;
            }
            if(objective.Monthly_active_users__C == null && objective.opportunity__r.Monthly_active_users__C != null){
                objective.Monthly_active_users__C = objective.opportunity__r.Monthly_active_users__C;
                updated = true;
            }
            if(objective.Success_Metrics_Details__c == null && objective.opportunity__r.Success_Metrics_Details__c != null){
                objective.Success_Metrics_Details__c = objective.opportunity__r.Success_Metrics_Details__c;
                updated = true;
            }
            if(objective.Success_Metrics_Tracking__C == null && objective.opportunity__r.Success_Metrics_Tracking__C != null){
                objective.Success_Metrics_Tracking__C = objective.opportunity__r.Success_Metrics_Tracking__C;
                updated = true;
            }
            if(updated){
                objective.Data_Pulled_From_Opportunity_Datestamp__c = Datetime.now();
            }
        }
        update objectives;
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}