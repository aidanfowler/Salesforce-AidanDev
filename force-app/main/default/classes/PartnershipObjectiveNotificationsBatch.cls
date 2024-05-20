global class PartnershipObjectiveNotificationsBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Date> dateList = new Set<Date>();
        Date today = Date.today();
        dateList.addAll(new List<Date>{today.addDays(-30),today.addDays(-60),today.addDays(-90),today.addDays(-180),today.addDays(-270),today.addDays(-360),today.addDays(-450),today.addDays(-540),today.addDays(-630),today.addDays(-720),today.addDays(-810),today.addDays(-900),today.addDays(-990),today.addDays(-1080),today.addDays(-1170),today.addDays(-1260),today.addDays(-1350),today.addDays(-1440)});
        String query = 'SELECT ID, Name,OwnerId, Account__r.Name,Opportunity__r.Name, Owner.Name,Successes__c,Challenges__c,Opportunities__c,Learnings__c FROM Partnership_Objective__c WHERE Objective_Start_Date__c IN :dateList AND (Contract_End_Date__c >= :today OR Contract_End_Date__c = null) AND Type__c = \'Partner Metrics Tracking\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Partnership_Objective__c> objectives) {
        List<Task> tasksToInsert = new List<Task>();
        for(Partnership_objective__c objective : objectives){
            Task t = new Task();
            t.WhatId = objective.id;
            t.Status = 'Open';
            t.ActivityDate = Date.today()+7;
            t.Description = 'Please review the Insights section of this Partnership Objective. Once you\'ve completed this task, insights will be shared with leadership.';
            t.Ownerid = objective.OwnerId;
            t.Priority = 'Normal';
            t.Subject = 'Update Partnership Objective Insights Reminder';
            t.TaskSubtype = 'Task';
            tasksToInsert.add(t);
        }
        if(tasksToInsert.size()>0){
            insert tasksToInsert;
        }
    }
     
    global void finish(Database.BatchableContext bc) {
    }
}