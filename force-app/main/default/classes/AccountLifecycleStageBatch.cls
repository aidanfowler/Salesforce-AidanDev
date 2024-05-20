public class AccountLifecycleStageBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT ID, Lifecycle_Stage__c, (SELECT ID, Stage__c FROM Contacts) FROM Account WHERE Needs_Lifecycle_Recalculation__c = TRUE AND Lifecycle_Stage__C != 'Terminated Customer' AND LifeCycle_Stage__C != 'Former Customer']);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> theAccounts) {
        for(Account act : theAccounts){
            act.Needs_Lifecycle_Recalculation__c = false;
        }
        Accounts.recalculateAccountLifeCycleStages(theAccounts);
    }
     
    public void finish(Database.BatchableContext bc) {
        
    }
}