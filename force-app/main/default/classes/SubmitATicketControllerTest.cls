@isTest
public without sharing class SubmitATicketControllerTest {

    @TestSetup
    static void makeData(){
        Support_Settings__c supportSettings = Support_Settings__c.getInstance();
        supportSettings.reCaptcha_Secret_Key__c = '2423432342';
        supportSettings.reCaptcha_Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify';
        insert supportSettings;
    }
    
    @IsTest
    static void testVerifyCaptcha() {

        Test.setMock(HttpCalloutMock.class, new RecaptchaMock());

        Test.startTest();

            String value = SubmitATicketController.insertRecord(null, '');

            //System.assert(value.contains('Success'), 'There should be a success.');

        Test.stopTest();
    }

    @IsTest
    static void testVerifyCaptchaWithError() {

        SubmitATicketController.hasError = true;

        Test.setMock(HttpCalloutMock.class, new RecaptchaMock());

        Boolean errorFound = false;

        Test.startTest();

            try {
                String value = SubmitATicketController.insertRecord(null, '');
            }
            catch(Exception e) {
                errorFound = true;
            }

        Test.stopTest();

        System.assertEquals(true, errorFound, 'There should be an error.');
    }

    @IsTest
    static void testGetEmailAddress() {

        Test.startTest();

            String email = SubmitATicketController.getEmailAddress();

            System.assertEquals(UserInfo.getUserEmail(), email, 'The email addresses should match.');

        Test.stopTest();
    }

    @IsTest
    static void testGetEmailAddressHasError() {

        SubmitATicketController.hasError = true;

        Test.startTest();

            Boolean errorFound = false;

            try {
                String email = SubmitATicketController.getEmailAddress();
            }
            catch(Exception e) {
                errorFound = true;
            }

            System.assertEquals(true, errorFound, 'There should be an error.');

        Test.stopTest();
    }

    @IsTest
    static void testGetContactId() {

        Profile prof = [Select Id from Profile where Name = 'Circle Support Community Login User' limit 1];

        Account testAccount = TestUtils.createAccount(null, 'Test Account', true);
        Contact testContact = TestUtils.createContact(null, testAccount.Id, true);
        User testUser = TestUtils.createSiteUser('circletestuser@circlehelporg.com', testContact.Id, prof.Id, true, true);

        System.runAs(testUser) {

            String contactId;

            Test.startTest();

                contactId = SubmitATicketController.getContactId(testUser.Id);

            Test.stopTest();

            System.assertEquals(testContact.Id, contactId, 'The Contact Id should be the same.');
        }
    }

    @IsTest
    static void testGetContactIdHasError() {

        Profile prof = [Select Id from Profile where Name = 'Circle Support Community Login User' limit 1];

        Account testAccount = TestUtils.createAccount(null, 'Test Account', true);
        Contact testContact = TestUtils.createContact(null, testAccount.Id, true);
        User testUser = TestUtils.createSiteUser('circletestuser@circlehelporg.com', testContact.Id, prof.Id, true, true);

        System.runAs(testUser) {

            Boolean errorFound = false;
            SubmitATicketController.hasError = true;

            Test.startTest();

                try {
                    String contactId = SubmitATicketController.getContactId(testUser.Id);
                }
                catch(Exception e) {
                    errorFound = true;
                }

            Test.stopTest();

            System.assertEquals(true, errorFound, 'There should be an error.');
        }
    }

    @IsTest
    static void testGetArticleTitle() {

        String articleTitle = 'My New Test Article for testing';

        Knowledge__kav article = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => articleTitle,
                                                                Knowledge__kav.Summary => 'My New Test',
                                                                Knowledge__kav.Body_Content__c => 'Test',
                                                                Knowledge__kav.UrlName => 'TestA',
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, true);

        article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article.Id];

        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        String title;

        Test.startTest();

            title = SubmitATicketController.getArticleTitle(article.Id);

        Test.stopTest();

        System.assertEquals(articleTitle, title, 'The Title should match the Article title.');
    }

    @IsTest
    static void testGetArticleCategory() {

        String articleTitle = 'My New Test Article for testing 2';

        Knowledge__kav article = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => articleTitle,
                                                                Knowledge__kav.Summary => 'My New Test 2',
                                                                Knowledge__kav.Body_Content__c => 'Test 2',
                                                                Knowledge__kav.UrlName => 'TestB',
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, true);

        article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article.Id];

        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.ParentId = article.ID;
        dataCategory.DataCategoryGroupName = 'Help_Center';
        dataCategory.DataCategoryName = 'Programmable_wallets';
        insert dataCategory;

        
        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        String category;

        Test.startTest();

            category = SubmitATicketController.getArticleMainCategory(article.Id);

        Test.stopTest();

        System.assertEquals('Wallets',category);
    }

    @isTest
    static void testGetSupportSettings() {

        Test.startTest();

            SubmitATicketController.getSupportSettings();

        Test.stopTest();
    }
}