public class ContentDocumentLinkTriggerHandler {

    public static void handleAfterInsert(Map<Id, ContentDocumentLink> newContentDocumentLinks){
        ContentDocumentLinks.sendSlackNotificationForLegalContractUpload(newContentDocumentLinks);
        ContentDocumentLinks.rollUpCountToOpportunity(newContentDocumentLinks);
    }

    public static void handleBeforeDelete(Map<Id, ContentDocument> oldContentDocuments){
        ContentDocumentLinks.scheduleRollUpCountToOpportunity(oldContentDocuments);
    }
}