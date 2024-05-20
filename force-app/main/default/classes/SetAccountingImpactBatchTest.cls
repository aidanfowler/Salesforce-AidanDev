@isTest 
public class SetAccountingImpactBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testAccountingImpact(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(AccountId = act.id, name = 'Test',StageName = 'Discover',CloseDate = Date.today(), Type = 'New Business',Product_s__c = 'Circle Mint', NextStep = 'abc');
        insert opp; 

        opp = [Select Accounting_Impact__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals('Not Applicable', opp.Accounting_Impact__c);

        Test.startTest();
            opp.Product_s__c = 'Circle Mint;Institutional Trading Partnership';
            update opp;
            opp = [Select Accounting_Impact__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals(null, opp.Accounting_Impact__c);
            opp.Product_s__c = 'Circle Mint;Core API';
            update opp;
            opp = [Select Accounting_Impact__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals('Accounts Receivable', opp.Accounting_Impact__c);
            opp.Product_s__c = 'Circle Mint;Activation Incentives';
            update opp;
            opp = [Select Accounting_Impact__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals('Accounts Payable', opp.Accounting_Impact__c);
            opp.Product_s__c = 'Circle Mint;Core API;Activation Incentives';
            update opp;
            opp = [Select Accounting_Impact__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals('Both', opp.Accounting_Impact__c);
            opp.Accounting_Impact__C = null;
            SetAccountingImpactBatch b = new SetAccountingImpactBatch();
            Database.executeBatch(b, 1);
        Test.stopTest();
        opp = [Select Accounting_Impact__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals('Both', opp.Accounting_Impact__c);
    }
}