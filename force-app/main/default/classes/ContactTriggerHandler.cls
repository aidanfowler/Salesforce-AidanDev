public class ContactTriggerHandler {

    public static void handleBeforeInsert(List<Contact> newContacts){
        Contacts.blockDuplicateContactsByEmail(newContacts);
    }

    public static void handleAfterInsert(Map<Id, Contact> newContacts){
        Accounts.setProductInterestFromContacts(newContacts, null);
        Accounts.recalculateLifeCycleStage(newContacts, null);
    }

    public static void handleBeforeUpdate(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        Contacts.blockDuplicateContactsByEmail(newContacts, oldContacts);
        Contacts.contactDataDeletionRequest(newContacts, oldContacts);
    }
    
    public static void handleAfterUpdate(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        Accounts.setProductInterestFromContacts(newContacts, oldContacts);
        Accounts.recalculateLifeCycleStage(newContacts, oldContacts);
    }
}