global class PartnershipObjectiveSetNoteBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID FROM Partnership_Objective__c WHERE Needs_Note_Update__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Partnership_Objective__c> objectives) {
        for(Partnership_objective__c objective : objectives){
            List<ContentDocumentLink> linkedDocuments = [SELECT ID, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :objective.id];
            Set<Id> contentDocumentIds = new Set<id>();
            for(ContentDocumentLink link : linkedDocuments){
                contentDocumentIds.add(link.contentDocumentId);
            }
            List<ContentVersion> cv = [SELECT ID, TextPreview FROM ContentVersion WHERE ContentDocumentId in:contentDocumentIds ORDER BY LastModifiedDate Desc LIMIT 1];
            if(cv != null && cv.size()>0){
                objective.Most_Recent_Note__c = cv.get(0).TextPreview;
                objective.Most_Recent_Note_Date__c = Date.today();
                objective.Needs_Note_Update__c = false;
            }
        }
        update objectives;
    }
     
    //abort future scheduled runs of this job
    global void finish(Database.BatchableContext bc) {
        List<CronTrigger> cts = [select id from crontrigger where CronJobDetail.name  = 'Set Partnership Objective Note'];
        if(cts.size()>0){
            system.abortJob(cts.get(0).id);
        }
    }
}