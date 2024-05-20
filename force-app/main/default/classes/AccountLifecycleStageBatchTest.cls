@isTest 
public class AccountLifecycleStageBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testLifecycleStages(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont0 = CircleTestDataFactory.insertContactWithStage(act.Id, 'First', 'Last0', 'first.last0@circle.com',null);
        act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
        System.assertEquals(null,act.LifeCycle_Stage__C);
        Contact cont = CircleTestDataFactory.insertContactWithStage(act.Id, 'First', 'Last1', 'first.last@circle.com1','Cold');
        act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
        System.assertEquals('Cold',act.LifeCycle_Stage__C);
        cont.Stage__C = 'Customer';
        update cont;
        act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
        System.assertEquals('Customer',act.LifeCycle_Stage__C);
        act.Lifecycle_Stage__c = null;
        act.Needs_Lifecycle_Recalculation__c = true;
        update act;
        act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
        System.assertEquals(null,act.LifeCycle_Stage__C);

        Test.startTest();
            AccountLifecycleStageBatch b = new AccountLifecycleStageBatch();
            database.executeBatch(b);
        Test.stopTest();

        act = [SELECT LifeCycle_Stage__C ,Needs_Lifecycle_Recalculation__c FROM Account WHERE ID = :act.id];
        System.assertEquals('Customer',act.LifeCycle_Stage__C);
        System.assertEquals(false,act.Needs_Lifecycle_Recalculation__c);
    }
}