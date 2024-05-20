public class CaseDAO {

    public static List<Case> getCasesWithBlockedContactEmails(Set<Id> caseIds){
        return [SELECT ID  FROM Case WHERE ID IN :caseIds AND Contact.Data_Deleted_Customer_Request__c = True];
    }
}