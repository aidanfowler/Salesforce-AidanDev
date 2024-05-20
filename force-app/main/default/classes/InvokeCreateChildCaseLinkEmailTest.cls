@isTest
public class InvokeCreateChildCaseLinkEmailTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }


    @isTest static void testInvokeCreateChildCaseLinkEmail(){
        Group customerSupportGroup = new Group(Name='Customer_Support', Type='Queue');
        insert customerSupportGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject customerSupportQueue = new QueueSObject(QueueID = customerSupportGroup.id, SObjectType = 'Case');
            insert customerSupportQueue;
        }

        Case customerCareCase = CircleTestDataFactory.insertCustomerCareCase();
        customerCareCase.First_Response_date__C = Date.today();
        update customerCareCase;
        EmailMessage inbound = CircleTestDataFactory.makeInboundEmail(customerCareCase.id);
        insert inbound;
        List<Case> cases = [SELECT ID FROM Case];
        System.assertEquals(1, cases.size());
        List<EmailMessage> emails = [SELECT ID,clonedToChildCase__c FROM EmailMessage Order By CreatedDate desc];
        System.assertEquals(1, emails.size());
        Id emailId = emails.get(0).id;
        
        InvokeCreateChildCaseLinkEmail.InputVariables inputVars = new InvokeCreateChildCaseLinkEmail.InputVariables();
        inputVars.caseQueueId = customerSupportGroup.id;
        inputVars.triggeringEmail = inbound;
        inputVars.parentCase = customerCareCase;

        Test.startTest();
            InvokeCreateChildCaseLinkEmail.createChildCaseLinkEmail(new List<InvokeCreateChildCaseLinkEmail.InputVariables> {inputVars});
        Test.stopTest();

        cases = [SELECT ID, ParentID,First_Response_Date__c FROM Case Order By CreatedDate desc];
        System.assertEquals(2, cases.size());
        cases = [SELECT ID, ParentID, First_Response_Date__C FROM Case WHERE ID != :customerCareCase.id];
        System.assertEquals(customerCareCase.id, cases.get(0).ParentID);
        System.assertEquals(null, cases.get(0).First_Response_Date__c);

        emails = [SELECT ID,clonedToChildCase__c FROM EmailMessage Order By CreatedDate desc];
        System.assertEquals(2, emails.size());
        emails = [SELECT clonedToChildCase__c FROM EmailMessage WHERE ID != :emailId];
        System.assertEquals(true, emails.get(0).clonedToChildCase__c);
    }

    @isTest static void testInvokeCreateChildCaseLinkEmailFail(){
        Case customerCareCase = CircleTestDataFactory.insertCustomerCareCase();
        EmailMessage inbound = CircleTestDataFactory.makeInboundEmail(customerCareCase.id);
        insert inbound;
        List<Case> cases = [SELECT ID FROM Case];
        System.assertEquals(1, cases.size());
        
        InvokeCreateChildCaseLinkEmail.InputVariables inputVars = new InvokeCreateChildCaseLinkEmail.InputVariables();
        inputVars.caseQueueId = null;
        inputVars.triggeringEmail = inbound;
        inputVars.parentCase = customerCareCase;

        Boolean failure = false;
        Test.startTest();
            InvokeCreateChildCaseLinkEmail.createChildCaseLinkEmail(new List<InvokeCreateChildCaseLinkEmail.InputVariables> {inputVars});
        Test.stopTest();

        //No assert because failure leads to email
    }
}