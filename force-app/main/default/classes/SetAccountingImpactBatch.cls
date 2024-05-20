public class SetAccountingImpactBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT ID, Product_s__c,Accounting_Impact__c FROM Opportunity WHERE Product_S__C != null and Accounting_Impact__C = null AND CloseDate = THIS_YEAR]);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> theOpps) {
        Opportunities.setAccountingImpact(theOpps);
        update theOpps;
    }
     
    public void finish(Database.BatchableContext bc) {
    }
}