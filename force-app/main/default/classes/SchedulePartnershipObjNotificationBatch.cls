global class SchedulePartnershipObjNotificationBatch implements Schedulable {
    global void execute(SchedulableContext SC) {
        PartnershipObjectiveNotificationsBatch b = new PartnershipObjectiveNotificationsBatch();
        Database.executeBatch(b,1); 
    }
 }