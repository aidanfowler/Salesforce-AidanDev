@isTest 
public class CircleTestDataFactory {

    public static void insertCustomSettings(){
        Trigger_Switches__c setting = new Trigger_Switches__c();
        setting.Pause_Slack_Notifications__c = true;
        setting.Generate_Partnership_Construct__c = false;
        insert setting;

        RecordTypeIds__c recordTypes = new RecordTypeIds__c();
        recordTypes.OnboardingCase__c = [SELECT ID FROM RecordType WHERE sObjectType = 'Case' AND Name = 'Onboarding' LIMIT 1].ID;
        recordTypes.BusinessDevelopmentOpp__c = [SELECT ID FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Business Development' LIMIT 1].ID;
        recordTypes.RenewalOpp__c = [SELECT ID FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Renewal' LIMIT 1].ID;
        insert recordTypes;

        Profiles__c profiles = new Profiles__c();
        List<Profile> adminProfiles = [SELECT ID FROM Profile WHERE Name = 'System Administrator' OR Name = 'Sys Admin Integration User'];
        profiles.System_Admin__c = adminProfiles.get(0).id;
        profiles.System_Admin_Integration__C = adminProfiles.get(1).id;
        insert profiles;
    }

    public static Case insertCustomerCareCase(){
        RecordType customerSupportCase = [SELECT ID, Name FROM RecordType WHERE sObjectType = 'Case' AND Name = 'Customer Care' LIMIT 1];
        Case c = new Case(RecordTypeId = customerSupportCase.id, Subject = 'Test Case', Description = 'Test Description', Status= 'In Progress');
        insert c;
        return c;
    }

    public static EmailMessage makeInboundEmail(Id caseId){
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = caseId;
        return email;
    }

    public static Account insertAccount(){
        Account act = makeAccount();
        insert act;
        return act;
    }

    public static Account makeAccount(){
        Account act = new Account(Name = 'Test Account');
        return act;
    }

    public static Contact insertContact(id actId, String first, String last, String productInterest){
        Contact contact = new Contact(FirstName = first, LastName = last);
        if(actId != null){
            contact.AccountId = actId;
        }
        if(productInterest != null){
            contact.Product_Interest__c = productInterest;
        }
        insert contact;
        return contact;
    }

    public static Opportunity insertOpportunity(String actId, String nameIn, Date closeDateIn, String productsIn){
        Opportunity opp = new Opportunity();
        opp.AccountId = actId;
        opp.Name = nameIn;
        opp.CloseDate = closeDateIn;
        opp.StageName = 'Discover';
        opp.Product_s__c = productsIn;
        opp.Type = 'New Business';
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        insert opp;
        return opp;
    }

    public static Opportunity makeOpportunity(String actId, String nameIn, Date closeDateIn, String productsIn){
        Opportunity opp = new Opportunity();
        opp.AccountId = actId;
        opp.Name = nameIn;
        opp.CloseDate = closeDateIn;
        opp.StageName = 'Discover';
        opp.Product_s__c = productsIn;
        opp.Type = 'New Business';
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        return opp;
    }

    public static Contact insertContactWithEmail(id actId, String first, String last, String email){
        Contact contact = new Contact(FirstName = first, LastName = last);
        if(actId != null){
            contact.AccountId = actId;
        }
        if(email != null){
            contact.Email = email;
        }
        contact.Stage__C = 'Cold';
        insert contact;
        return contact;
    }

    public static Contact insertContactWithStage(id actId, String first, String last, String email, String stage){
        Contact contact = new Contact(FirstName = first, LastName = last);
        if(actId != null){
            contact.AccountId = actId;
        }
        if(email != null){
            contact.Email = email;
        }
        contact.Stage__C = stage;
        insert contact;
        return contact;
    }

    public static Circle_Account__c insertCircleAccount(id actId, id leadId, String accountApiVal, Boolean coreApi, Boolean readOnlyApi, Boolean sen, Boolean signet, Boolean usdcExpress, String cybavo, String paymentApi, String payoutsApi, Decimal mint30, Decimal burn30){
        Circle_Account__c ca = makeCircleAccount(actId, leadId, accountApiVal, coreApi,readOnlyApi,sen, signet, usdcExpress, cybavo, paymentApi, payoutsApi, mint30, burn30);
        insert ca;
        return ca;
    }

    public static Circle_Account__c makeCircleAccount(id actId, id leadId, String accountApiVal, Boolean coreApi, Boolean readOnlyApi, Boolean sen, Boolean signet,Boolean usdcExpress, String cybavo,String paymentApi, String payoutsApi,Decimal mint30, Decimal burn30){
        Circle_Account__c ca = new Circle_Account__C();
        ca.Account_lookup__c = actId;
        ca.Lead__c = leadId;
        ca.Accounts_API__c = accountApiVal;
        ca.Core_API__c = coreApi;
        ca.Read_Only_API__c = readOnlyApi;
        ca.Cybavo__c = cybavo;
        ca.Payments_API__c = paymentApi;
        ca.Payouts_Api__c = payoutsApi;
        ca.Sen__c = sen;
        ca.Signet__c = signet;
        ca.USDC_Express__c = usdcExpress;
        ca.Country_Of_Incorporation__c = 'US';
        ca.Mint_Volume_Last_30_Days__c = mint30;
        ca.Burn_Volume_Last_30_Days__c = burn30;
        ca.Current_Gross_Burn__c = burn30;
        ca.Current_Gross_Mint__c = mint30;
        ca.Monthly_Avg_Gross_Burn__c = burn30;
        ca.Monthly_Avg_Gross_Mint__c = mint30;
        ca.Starting_Gross_Burn__c = burn30;
        ca.Starting_Gross_Mint__c = mint30;
        return ca;
    }

    public static Lead insertLead(){
        Lead theLead = makeLead();
        insert theLead;
        return theLead;
    }

    public static Lead makeLead(){
        Lead theLead = new Lead(FirstName = 'Test', LastName = 'Test');
        theLead.company = 'test company';
        return theLead;
    }

    public static List<Lead> make200Leads(String company){
        List<Lead> leadsToInsert = new List<Lead>();
        for(Integer i = 0;i<200;i++){
            Lead ld = new Lead(FirstName = 'Test', LastName = 'Test'+String.valueOf(i));
            ld.company = company;
            ld.email = 'testEmail'+String.valueOf(i)+'@circle.com';
            ld.isConverted = false;
            ld.Email_Domain__c = 'circle.com';
            ld.Is_this_a_work_email__c = 'Yes';
            ld.Auto_Convert__c = true;
            leadsToInsert.add(ld);
        }
        return leadsToInsert;
    }

    public static User insertUser(){
        User u = new User();
        u.Username = 'userName@circle.com';
        u.Email = 'userEmail@circle.com';
        u.FirstName = 'firstName';
        u.LastName = 'lastName';
        u.CommunityNickname = 'communityNickname';
		u.ProfileId = [SELECT ID FROM Profile WHERE NAME = 'Sales Exec'].id;
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.EmailEncodingKey='UTF-8';
        u.alias = 'testu';
        insert u;
        return u;
    }

    public static User insertPricingUser(){
        User u = new User();
        u.Username = 'userName@circle.com';
        u.Email = 'userEmail@circle.com';
        u.FirstName = 'firstName';
        u.LastName = 'lastName';
        u.CommunityNickname = 'communityNickname';
		u.ProfileId = [SELECT ID FROM Profile WHERE NAME = 'Pricing'].id;
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.EmailEncodingKey='UTF-8';
        u.alias = 'testu';
        insert u;
        return u;
    }

    public static User insertLegalUser(){
        User u = new User();
        u.Username = 'userNameLegal@circle.com';
        u.Email = 'userEmailLegal@circle.com';
        u.FirstName = 'firstName';
        u.LastName = 'lastName';
        u.CommunityNickname = 'communityNickname';
		u.ProfileId = [SELECT ID FROM Profile WHERE NAME = 'Legal'].id;
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.EmailEncodingKey='UTF-8';
        u.alias = 'testu';
        insert u;
        return u;
    }
    
}