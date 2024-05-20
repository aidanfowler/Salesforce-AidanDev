@isTest
public without sharing class SuggestedArticlesControllerTest {

    @TestSetup
    static void setupData(){

        Knowledge__kav article = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing',
                                                                Knowledge__kav.Summary => 'My New Test',
                                                                Knowledge__kav.Body_Content__c => 'Test',
                                                                Knowledge__kav.UrlName => 'TestClass',
                                                                Knowledge__kav.Suggested_Article__c => true,
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, true);

        article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article.Id];

        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        Knowledge__DataCategorySelection articleDataCategory = TestUtils.createDataCategorySelection(new Map<SObjectField, Object>{Knowledge__DataCategorySelection.DataCategoryGroupName => 'Help_Center',
                                                                                        Knowledge__DataCategorySelection.DataCategoryName => 'Account_Information'}, article.Id, true);
    }
    
    @isTest
    static void testGetCategoryMapInternal() {

        Test.startTest();

            List<CategoryWrapper> categoryWrap = SuggestedArticlesController.getCategoryMap();

            System.assertNotEquals(null, categoryWrap, 'Category wrap should not be null.');
            System.assertEquals(1, categoryWrap[0].articles.size(), 'There should be one article.');

        Test.stopTest();
    }

    @isTest
    static void testMaxSuggestedArticles() {

        Knowledge__kav article1 = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing 2',
                                                                Knowledge__kav.Summary => 'My New Test 1',
                                                                Knowledge__kav.Body_Content__c => 'Test',
                                                                Knowledge__kav.UrlName => 'Test2',
                                                                Knowledge__kav.Suggested_Article__c => true,
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, false);
        Knowledge__kav article2 = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing 3',
                                                                Knowledge__kav.Summary => 'My New Test 2',
                                                                Knowledge__kav.Body_Content__c => 'Test',
                                                                Knowledge__kav.UrlName => 'Test3',
                                                                Knowledge__kav.Suggested_Article__c => true,
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, false);
        Knowledge__kav article3 = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing 3',
                                                                Knowledge__kav.Summary => 'My New Test 3',
                                                                Knowledge__kav.Body_Content__c => 'Test',
                                                                Knowledge__kav.UrlName => 'Test4',
                                                                Knowledge__kav.Suggested_Article__c => true,
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, false);

        List<Knowledge__kav> articles = new List<Knowledge__kav>{article1, article2, article3};

        insert articles;

        for(Knowledge__kav newArticle : articles) {

            Knowledge__kav article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];

            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

            Knowledge__DataCategorySelection articleDataCategory = TestUtils.createDataCategorySelection(new Map<SObjectField, Object>{Knowledge__DataCategorySelection.DataCategoryGroupName => 'Help_Center',
                                                                                            Knowledge__DataCategorySelection.DataCategoryName => 'Account_Information'}, article.Id, true);
        }

        Test.startTest();

            List<CategoryWrapper> categoryWrap = SuggestedArticlesController.getCategoryMap();

            // Only 3 articles should be returned even thought there are 4.
            System.assertNotEquals(null, categoryWrap, 'Category wrap should not be null.');
            System.assertEquals(3, categoryWrap[0].articles.size(), 'There should be one article.');

        Test.stopTest();
    }

    @isTest
    static void testGetCategoryMapGuest() {

        SiteUtils.USER_TYPE = 'Guest';

        Test.startTest();

            List<CategoryWrapper> categoryWrap = SuggestedArticlesController.getCategoryMap();

            System.assertNotEquals(null, categoryWrap, 'Category wrap should not be null.');
            System.assertEquals(1, categoryWrap[0].articles.size(), 'There should be one article.');

        Test.stopTest();
    }

    @isTest
    static void testGetCategoryMapCommunity() {

        SiteUtils.USER_TYPE = 'Community';

        Test.startTest();

            List<CategoryWrapper> categoryWrap = SuggestedArticlesController.getCategoryMap();

            System.assertNotEquals(null, categoryWrap, 'Category wrap should not be null.');
            System.assertEquals(1, categoryWrap[0].articles.size(), 'There should be one article.');

        Test.stopTest();
    }

    @isTest
    static void testError() {

        SuggestedArticlesController.hasError = true;

        Test.startTest();

            Boolean errorThrown = false;

            try {

                List<CategoryWrapper> categoryWrap = SuggestedArticlesController.getCategoryMap();
            }
            catch(Exception e) {
                errorThrown = true;
            }

            System.assertEquals(true, errorThrown, 'There should be an error.');

        Test.stopTest();
    }
}