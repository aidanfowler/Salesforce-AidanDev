@isTest
public class KnowledgeArticleURLControllerTest {

    @TestSetup
    static void setupData(){

        Knowledge__kav article = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing',
                                                                                        Knowledge__kav.Body_Content__c => 'Test',
                                                                                        Knowledge__kav.UrlName => 'TestClass',
            																			Knowledge__kav.IsVisibleInPkb => true,
                                                                						Knowledge__kav.IsVisibleInCsp => true}, true);

        article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article.Id];

        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        Knowledge__DataCategorySelection articleDataCategory = TestUtils.createDataCategorySelection(new Map<SObjectField, Object>{Knowledge__DataCategorySelection.DataCategoryGroupName => 'Help_Center',
                                                                                        Knowledge__DataCategorySelection.DataCategoryName => 'Account_Information'}, article.Id, true);
    }

    @IsTest
    static void testGetKnowledgeArticleId() {

        Knowledge__kav article = [Select Id from Knowledge__kav where Title = 'My New Test Article for testing'];

        Test.startTest();

            article = KnowledgeArticleURLController.getKnowledgeArticleId(article.Id);

            System.assertNotEquals(null, article.KnowledgeArticleId, 'There should be a value.');

        Test.stopTest();
    }

    @IsTest
    static void testGetSupportSettings() {

        Test.startTest();

            Support_Settings__c supportSettings = KnowledgeArticleURLController.getSupportSettings();

            System.assertNotEquals(null, supportSettings, 'There are support settings.');

    }
}