global class SchedulePartnershipObjSetNoteBatch implements Schedulable {
    global void execute(SchedulableContext SC) {
        PartnershipObjectiveSetNoteBatch b = new PartnershipObjectiveSetNoteBatch();
        Database.executeBatch(b,1); 
    }
 }