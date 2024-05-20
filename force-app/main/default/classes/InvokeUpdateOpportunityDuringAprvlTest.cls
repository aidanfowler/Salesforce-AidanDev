@isTest
public class InvokeUpdateOpportunityDuringAprvlTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }


    @isTest static void testInvokeUpdateOppDuringApprovalTest(){
        ACcount act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Accounts API');
        opp.CloseDate = Date.today()+1;

        Approval.ProcessSubmitRequest testapproval = new Approval.ProcessSubmitRequest();
        testapproval.setComments('Submitting request for approval');
        testapproval.setObjectId(opp.Id);
        Approval.ProcessResult result1 = Approval.process(testapproval);
        
        List<ProcessInstanceWorkitem> piwis = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :opp.id];
        System.assertEquals(1, piwis.size());

        Test.startTest();
            opp.StageName = 'Closed Lost';
            InvokeUpdateOpportunityDuringApproval.InvokeUpdateOpportunityDuringApproval(new List<Opportunity> {opp});
        Test.stopTest();
        opp = [SELECT ID, CloseDate FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals(Date.today()+1, opp.CloseDate);
        piwis = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :opp.id];
        System.assertEquals(0, piwis.size());
    }
}