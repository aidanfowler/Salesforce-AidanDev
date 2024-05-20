global class ScheduleAttachmentRecalculation implements Schedulable {
    global void execute(SchedulableContext SC) {
        OpportunityAttachmentRecalculationBatch b = new OpportunityAttachmentRecalculationBatch();
        Database.executeBatch(b); 
    }
 }