trigger AccountMaintenanceRequest on Account_Maintenance_Request__c (before update) {
    if(Trigger.isUpdate && Trigger.isBefore){
        AccountMaintenanceRequestTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}