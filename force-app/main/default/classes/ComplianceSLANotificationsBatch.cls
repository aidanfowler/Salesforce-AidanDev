public class ComplianceSLANotificationsBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime now = Datetime.now();
        DateTime hoursAgo72 = now.addHours(-72);
        return Database.getQueryLocator([SELECT ID, Compliance_Analyst__c, Compliance_Analyst__r.ManagerId FROM Opportunity WHERE StageName = 'Approvals' AND Violates_Compliance_SLA__c=true AND Compliance_State__c = 'Pending AML Review']);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> theOpportunities) {
        for(Opportunity opp : theOpportunities){
            opp.send_Compliance_SLA_Notification__c = true;
       }
       update theOpportunities;
    }
     
    public void finish(Database.BatchableContext bc) {
        
    }
}