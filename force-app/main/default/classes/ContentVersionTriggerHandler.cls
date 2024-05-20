public class ContentVersionTriggerHandler {

    public static void handleAfterInsert(Map<Id, ContentVersion> newContentVersions){
        ContentDocumentLinks.moveMostRecentNoteToPartnershipObjective(newContentVersions, null);
    }

    public static void handleAfterUpdate(Map<Id, ContentVersion> newContentVersions, Map<Id, ContentVersion> oldContentVersions){
        ContentDocumentLinks.moveMostRecentNoteToPartnershipObjective(newContentVersions, oldContentVersions);
    }
}