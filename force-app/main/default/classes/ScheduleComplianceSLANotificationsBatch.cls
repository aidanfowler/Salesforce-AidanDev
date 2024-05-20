global class ScheduleComplianceSLANotificationsBatch implements Schedulable {
    global void execute(SchedulableContext SC) {
        ComplianceSLANotificationsBatch b = new ComplianceSLANotificationsBatch();
        Database.executeBatch(b,1); 
    }
 }