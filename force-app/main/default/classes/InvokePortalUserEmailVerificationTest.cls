@isTest
public class InvokePortalUserEmailVerificationTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testPortalEmailSend(){
        User u = CircleTestDataFactory.insertUser();
        InvokePortalUserEmailVerification.sendVerificationEmail(new List<String>{u.id});
    }
}