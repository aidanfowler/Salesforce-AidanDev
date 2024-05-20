global class SchedulePartnershipObjectiveMetricRollUp implements Schedulable {
    global void execute(SchedulableContext SC) {
        PartnershipObjectivePullOppMetricsBatch b = new PartnershipObjectivePullOppMetricsBatch();
        Database.executeBatch(b); 
    }
 }