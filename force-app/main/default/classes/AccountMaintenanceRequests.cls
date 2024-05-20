public class AccountMaintenanceRequests {

    public static void validateApproval(Map<Id, Account_Maintenance_Request__C> newRequests, Map<Id, Account_Maintenance_Request__c> oldRequests){
        for(Id id : newRequests.keyset()){
            if(newRequests.get(id).Request_Status__c == 'Approved' && newRequests.get(id).Request_Status__c != oldRequests.get(id).Request_Status__c && newRequests.get(id).Request_Types_Selected__c.contains('Ownership Update') && newRequests.get(id).New_Owner__c == null){
                newRequests.get(id).addError('Error: You must select a new owner before approving an account maintenance request if the request includes an ownership update');
            }
        }
    }
}