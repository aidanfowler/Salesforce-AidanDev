public class ContentDocumentLinkDAO {

    public static List<ContentDocumentLink> getContentDocumentsById(Set<Id> ids){
        return [SELECT ID, LinkedEntityId, ContentDocumentId, ContentDocument.createdById FROM ContentDocumentLink WHERE ID IN :ids];
    }

    public static List<ContentDocumentLink> getContentDocumentsByRecord(Set<Id> ids){
        return [SELECT ID, LinkedEntityId, ContentDocumentId, ContentDocument.createdById,ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityID IN :ids];
    }

    public static List<ContentDocumentLink> getContentDocumentLinksByDocumentID(Id id){
        return [SELECT ID, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :id];
    }

    public static List<ContentDocumentLink> getContentDocumentLinksByDocumentIds(Set<Id> documentIds){
        return [SELECT ID, LinkedEntityID, ContentDocument.FileType FROM contentdocumentlink where contentdocumentid IN :documentIds];
    }

    public static ContentVersion getContentVersionFromId(Id contentVersionId){
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionId];
    }
}