public class InvokePortalUserEmailVerification {
    @InvocableMethod(label='InvokePortalUserEmailVerification' description='Send portal user verification email')
    public static void sendVerificationEmail(List<String> portalUserId) {
        Support_Settings__c ss = Support_Settings__c.getInstance();
        System.UserManagement.sendAsyncEmailConfirmation(portaluserId.get(0),null,ss.NetworkId__c,'/EmailVerified');
    }
}