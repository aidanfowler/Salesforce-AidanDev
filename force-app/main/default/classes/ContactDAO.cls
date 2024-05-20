public class ContactDAO {

    public static List<Contact> getContactsByEmail(Set<String> emails){
        return [SELECT ID, Email, AccountID, Account.Name, Account.OwnerId FROM Contact WHERE Email IN :emails ORDER BY CreatedDate asc];
    }

    public static List<Contact> getBlockedContactsByEmail(Set<String> emails){
        return [SELECT ID, Email FROM Contact WHERE Email IN :emails and Data_Deleted_Customer_Request__c = True];
    }
}