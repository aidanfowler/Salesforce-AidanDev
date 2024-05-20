public class AccountMaintenanceRequestTriggerHandler {

    public static void handleBeforeUpdate(Map<Id, Account_Maintenance_Request__c> newRequests, Map<Id, Account_Maintenance_Request__c> oldRequests){
        AccountMaintenanceRequests.validateApproval(newRequests, oldRequests);
    }
}