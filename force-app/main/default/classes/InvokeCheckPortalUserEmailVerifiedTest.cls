@isTest 
public class InvokeCheckPortalUserEmailVerifiedTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testInvokePortalUserEmailVerified(){
        List<String> results = InvokeCheckPortalUserEmailVerified.InvokeCheckPortalUserEmailVerified(new List<String>{'123'});
        System.assertEquals('No User Found', results.get(0));
        //cant access object we need to test for authentication from test class - todo 
    }
}