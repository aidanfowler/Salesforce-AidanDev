public without sharing class KnowledgeLoginController {

    public static String USER_LICENSE = 'Customer Community Login';
    public String emailAddress {get; set;}
    public String startUrl {get; set;}

    public KnowledgeLoginController() {

        Support_Settings__c settings = Support_Settings__c.getInstance();
        
        if(Test.isRunningTest()) {
            USER_LICENSE = 'Salesforce';
        }

        startUrl = settings.Start_Url__c;
    }

    public PageReference login() {

        PageReference ref;

        try {

            // Find the User by the Email Address
            User u = [Select Id, Username, isActive from User where Email = :emailAddress and Profile.UserLicense.Name = :USER_LICENSE];

            if(u.IsActive == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'User is no longer active, please reach out to your account representative if this is an error'));
            }
            else{
                // Verify by the Email Address
                List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
                methods.add(Auth.VerificationMethod.EMAIL);

                if(!Test.isRunningTest()) {
                    // Login using a verification code.
                    ref = Site.passwordlessLogin(u.Id, methods, startUrl);
                }
            }
        }
        catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Username not found. Please try again or reach out to your account representative'));
            return null;
        }

        return ref;
    }
}