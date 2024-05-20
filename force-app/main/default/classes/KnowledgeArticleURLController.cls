public without sharing class KnowledgeArticleURLController {

    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getKnowledgeArticleId(Id recordId) {

        return [Select Id, KnowledgeArticleId from Knowledge__kav where Id = :recordId];
    }

    @AuraEnabled(cacheable=true)
    public static Support_Settings__c getSupportSettings() {
        return Support_Settings__c.getOrgDefaults();
    }
}