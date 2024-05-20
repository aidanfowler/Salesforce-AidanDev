@isTest
public class OpportunitiesTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testRevertStageIfProductsChange(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(AccountId = act.id, name = 'Test',StageName = 'Discover',CloseDate = Date.today(), Type = 'New Business',Product_s__c = 'Circle Mint');
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        insert opp;
        opp.StageName = 'Solution';
        opp.Compliance_Analyst__c = UserInfo.getUserId();
        update opp;
        
        Test.startTest();
            opp.Product_s__c = 'Circle Mint;Programmable Wallets';
            update opp;
            opp = [SELECT ID, StageName, Compliance_Analyst__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals('Discover',opp.StageName);
            System.assertEquals(null, opp.Compliance_Analyst__c);
            opp.StageName = 'Solution';
            update opp;
            opp.Product_s__c = 'Circle Mint';
            update opp;
        Test.stopTest();
        opp = [SELECT ID, StageName FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals('Solution',opp.StageName);
    }

    @isTest static void testOppTeamCSMValidationFailed(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(Accountid = act.id, name = 'test', StageName = 'Discover', CloseDate = Date.today(), Type = 'New Business', Product_s__c = 'Circle Mint');
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        insert opp;
        String error = '';
        Test.startTest();
            opp.StageName = 'Closed Won';
            try{
                update opp;
            }
            catch(Exception e){
                error = e.getMessage();
            }
        Test.stopTest();
        System.assert(error.contains('You must add a CSM to the opportunity team beforce closing this opportunity'));
    }

    @isTest static void testOppTeamCSMValidationSuccess(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(Accountid = act.id, name = 'test', StageName = 'Discover', CloseDate = Date.today(), Type = 'New Business', Product_s__c = 'Circle Mint');
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        insert opp;
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(OpportunityId = opp.id, TeamMemberRole = 'Customer Success Manager', UserId = UserInfo.getUserId());
        insert oppTeamMember;
        String error = '';
        Test.startTest();
            opp.StageName = 'Closed Won';
            try{
                update opp;
            }
            catch(Exception e){
                error = e.getMessage();
            }
        Test.stopTest();
        System.assertEquals('', error);
    }

    @isTest static void testValidateProducts(){
        User sdr = CircleTestDataFactory.insertUser();
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(OwnerId = sdr.id, Accountid = act.id, name = 'test', StageName = 'Discover', CloseDate = Date.today(), Type = 'New Business', Product_s__c = 'Invalid', Challenges__c = 'Challenges',Decision_Makers__C = 'Decision Makers', Projected_Wallet_Count__c = 123, Monthly_Active_Users__C = 123, Projected_Minting_Volume__c = 123);
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        insert opp;

        System.runAs(sdr){
            String error = '';
            Test.startTest();
                opp.StageName = 'Solution';
                try{
                    update opp;
                }
                catch(Exception e){
                    error = e.getMessage();
                }
            Test.stopTest();
            System.assert(error.contains('Error: You have a product selected which is not in the product book, please correct the selected product(s) to a valid option'));
        }
    }

    @isTest static void testAccountApplicability(){
        User u = CircleTestDataFactory.insertPricingUser();
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(OwnerId = u.id, Accountid = act.id, name = 'test', StageName = 'Discover', CloseDate = Date.today(), Type = 'New Business', Product_s__c = 'Performance Incentives', Challenges__c = 'Challenges',Decision_Makers__C = 'Decision Makers', Projected_Wallet_Count__c = 123, Monthly_Active_Users__C = 123, Projected_Minting_Volume__c = 123);
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        insert opp;

        System.runAs(u){
            String error = '';
            Test.startTest();
                opp.Accounting_Impact__c = null;
                opp.Pricing_approval_status__c = 'Approved';
                try{
                    update opp;
                }
                catch(Exception e){
                    error = e.getMessage();
                }
            Test.stopTest();
            System.assert(error.contains('The pricing team must populate the Accounting Impact field before approving'));
            System.assert(error.contains('The Pricing Matrix, Stablecoin Custody, Weighted Margin % & Bps On Volume must be populated for all Performance Incentives'));

        }
    }

    @isTest static void testNextStepToHistory(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(AccountId = act.id, name = 'Test',StageName = 'Discover',CloseDate = Date.today(), Type = 'New Business',Product_s__c = 'Circle Mint', NextStep = 'abc');
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
        insert opp;

        opp = [SELECT ID, Next_steps__C from Opportunity WHERE ID = :opp.id];
        System.assertEquals('('+String.valueOf(Date.today())+') : abc', opp.Next_Steps__c);
        
        opp.NextStep = 'test 123';
        update opp;

        opp = [SELECT ID, Next_steps__C from Opportunity WHERE ID = :opp.id];
        System.assertEquals('('+String.valueOf(Date.today())+') : test 123<br><br>('+String.valueOf(Date.today())+') : abc', opp.Next_Steps__c);

    }

    @isTest static void testAccountingImpact(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = new Opportunity(AccountId = act.id, name = 'Test',StageName = 'Discover',CloseDate = Date.today(), Type = 'New Business',Product_s__c = 'Circle Mint', NextStep = 'abc');
        opp.RecordTypeId = RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c;
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
            opp.Product_s__c = 'Circle Mint;Core API;Activation Incentives;Institutional Trading Partnership';
            update opp;
            opp = [Select Accounting_Impact__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals(null, opp.Accounting_Impact__c);
        Test.stopTest();
    }

    @isTest static void testDateXStageEntered(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'TEST', Date.today(), 'Circle Mint');
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(OpportunityId = opp.id, TeamMemberRole = 'Customer Success Manager', UserId = UserInfo.getUserId());
        insert oppTeamMember;

        Test.startTest();
            opp = [SELECT ID, Date_Discover_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Discover_Stage_Entered__c);
            opp.StageName = 'Solution';
            update opp;
            opp = [SELECT ID, Date_Solution_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Solution_Stage_Entered__c);
            opp.StageName = 'Approvals';
            update opp;
            opp = [SELECT ID, Date_Approvals_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Approvals_Stage_Entered__c);
            opp.StageName = 'Negotiate';
            update opp;
            opp = [SELECT ID, Date_Negotiate_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Negotiate_Stage_Entered__c);
            opp.StageName = 'Contract';
            update opp;
            opp = [SELECT ID, Date_Contract_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Contract_Stage_Entered__c);
            opp.StageName = 'Closed Won';
            opp.Referral_Partner__c = 'Solana';
            opp.Accounting_Impact__c = 'Not Applicable';
            opp.Opportunity_Currency__c = 'USD';
            update opp;
            opp = [SELECT ID, Date_Closed_Won_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Closed_Won_Stage_Entered__c);
            opp.StageName = 'Closed Lost';
            update opp;
            opp = [SELECT ID, Date_Closed_Won_Stage_Entered__c,Date_Closed_Lost_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals(null, opp.Date_Closed_Won_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Closed_Lost_Stage_Entered__c);
            opp.StageName = 'Discover';
            update opp;
            opp = [SELECT ID, Date_Discover_Stage_Entered__c, Date_Solution_Stage_Entered__c,Date_Approvals_Stage_Entered__c,Date_Negotiate_Stage_Entered__c, Date_Contract_Stage_Entered__c,Date_Closed_Lost_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Discover_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Solution_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Approvals_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Negotiate_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Contract_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Closed_Lost_Stage_Entered__c);
            opp.StageName = 'Closed Won';
            update opp;
            opp = [SELECT ID, Date_Discover_Stage_Entered__c, Date_Solution_Stage_Entered__c,Date_Approvals_Stage_Entered__c,Date_Negotiate_Stage_Entered__c, Date_Contract_Stage_Entered__c,Date_Closed_Lost_Stage_Entered__c,Date_Closed_Won_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Discover_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Solution_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Approvals_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Negotiate_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Contract_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Closed_Won_Stage_Entered__c);
            opp.StageName = 'Solution';
            update opp;
            opp = [SELECT ID, Date_Discover_Stage_Entered__c, Date_Solution_Stage_Entered__c,Date_Approvals_Stage_Entered__c,Date_Negotiate_Stage_Entered__c, Date_Contract_Stage_Entered__c,Date_Closed_Lost_Stage_Entered__c,Date_Closed_Won_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Discover_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Solution_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Approvals_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Negotiate_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Contract_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Closed_Won_Stage_Entered__c);
            opp.StageName = 'Closed Won';
            update opp;
            opp.StageName = 'Approvals';
            update opp;
            opp = [SELECT ID, Date_Discover_Stage_Entered__c, Date_Solution_Stage_Entered__c,Date_Approvals_Stage_Entered__c,Date_Negotiate_Stage_Entered__c, Date_Contract_Stage_Entered__c,Date_Closed_Lost_Stage_Entered__c,Date_Closed_Won_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Discover_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Solution_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Approvals_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Negotiate_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Contract_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Closed_Won_Stage_Entered__c);
            opp.StageName = 'Closed Won';
            update opp;
            opp.StageName = 'Negotiate';
            update opp;
            opp = [SELECT ID, Date_Discover_Stage_Entered__c, Date_Solution_Stage_Entered__c,Date_Approvals_Stage_Entered__c,Date_Negotiate_Stage_Entered__c, Date_Contract_Stage_Entered__c,Date_Closed_Lost_Stage_Entered__c,Date_Closed_Won_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Discover_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Solution_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Approvals_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Negotiate_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Contract_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Closed_Won_Stage_Entered__c);
            opp.StageName = 'Closed Won';
            update opp;
            opp.StageName = 'Contract';
            update opp;
            opp = [SELECT ID, Date_Discover_Stage_Entered__c, Date_Solution_Stage_Entered__c,Date_Approvals_Stage_Entered__c,Date_Negotiate_Stage_Entered__c, Date_Contract_Stage_Entered__c,Date_Closed_Lost_Stage_Entered__c,Date_Closed_Won_Stage_Entered__c FROM Opportunity WHERE ID = :opp.id];
            System.assertNotEquals(null, opp.Date_Discover_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Solution_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Approvals_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Negotiate_Stage_Entered__c);
            System.assertNotEquals(null, opp.Date_Contract_Stage_Entered__c);
            System.assertEquals(null, opp.Date_Closed_Won_Stage_Entered__c);
        Test.stopTest();       
    }

    @isTest static void testAddFileOpportunityCount(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');

        ContentVersion contentVersion = new ContentVersion(Title = 'a picture',PathOnClient   = 'Pic.jpg', VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = opp.id; 
        objCntDocLink.ContentDocumentId = documents[0].Id; 
        objCntDocLink.shareType = 'V';        
        
        Test.startTest();
            insert objCntDocLink;
        Test.stopTest();

        opp = [SELECT Number_Of_Attachments__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals(1, opp.Number_Of_Attachments__c);
    }

    @isTest static void testApprovalRecall(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Accounts API');

        Approval.ProcessSubmitRequest testapproval = new Approval.ProcessSubmitRequest();
        testapproval.setComments('Submitting request for approval');
        testapproval.setObjectId(opp.Id);
        Approval.ProcessResult result1 = Approval.process(testapproval);
        
        List<ProcessInstanceWorkitem> piwis = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :opp.id];
        System.assertEquals(1, piwis.size());
        
        Test.startTest();
            opp.StageName = 'Closed Lost';
            update opp;
        Test.stopTest();

        piwis = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :opp.id];
        System.assertEquals(0, piwis.size());
    }

}