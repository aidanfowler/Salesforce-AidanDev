global class OpportunityAttachmentRecalculationBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID FROM Opportunity WHERE Needs_Attachmnet_Recalculation__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> opps) {
        Set<Id> relevantIds = new Set<Id>();
        for(Opportunity opp : opps){
            relevantIds.add(opp.id);
        }
        Opportunities.recalculateAttachmentCounts(relevantIds);
    }
     
    //abort future scheduled runs of this job
    global void finish(Database.BatchableContext bc) {
        List<CronTrigger> cts = [select id from crontrigger where CronJobDetail.name  = 'Opportunity Attachment Recalculation'];
        if(cts.size()>0){
            system.abortJob(cts.get(0).id);
        }
    }
}