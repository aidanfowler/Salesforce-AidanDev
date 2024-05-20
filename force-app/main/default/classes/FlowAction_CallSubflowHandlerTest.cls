@IsTest
public class FlowAction_CallSubflowHandlerTest {
    
    private static final String flowApiName = 'Dummy_Flow';
    private static final Map<String,Object> inputVariablesMap = new Map<String,Object>{
        'varText' => 'Flows are love!'
    };
    private static final String assertionFailMessagePrefix = 'FlowAction_CallSubflowHandlerTest Class Assertion Failed: ';

    @testSetup
    public static void testSetup(){
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test cg', CollaborationType = 'Public');
        insert cg;
        
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'test@email01.com',
            Username = 'user@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert usr;
        CollaborationGroupMember c = new CollaborationGroupMember();
        c.CollaborationGroupId = cg.id;
        c.MemberId = usr.Id;
        insert c;
    }
    
    @IsTest
    static void callSubflowTest(){

        FlowAction_CallSubflowHandler.FlowInput[] inputs = new FlowAction_CallSubflowHandler.FlowInput[]{};
        FlowAction_CallSubflowHandler.FlowInput input = new FlowAction_CallSubflowHandler.FlowInput();
        input.flowApiName = flowApiName;
        input.inputVariablesJSON = JSON.serialize(inputVariablesMap);
        inputs.add(input);

        Test.startTest();
        FlowAction_CallSubflowHandler.callSubflow(inputs);
        Test.stopTest();
        
        System.assertEquals(
            1, 
            Limits.getQueries(), 
            assertionFailMessagePrefix + 'Number of SOQL queries do not match.'
        );
        
    }

}