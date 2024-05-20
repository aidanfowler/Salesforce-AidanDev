@isTest
public without sharing class ArticlePageControllerTest {

    private static final String ARTICLE_TITLE = 'My New Test Article for testing';
    
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

    @isTest    
    static void testRedirectToMoreRecentArticle() {
        
        Knowledge__kav article = [Select Id from Knowledge__kav where Title = :ARTICLE_TITLE];

        Test.startTest();

            ArticlePageController.RedirectResultWrapper resultWrapper = ArticlePageController.redirectToMoreRecentArticle(article.Id);

            System.assertEquals(false, resultWrapper.redirect, 'Redirect should be false.');

        Test.stopTest();

    }

    @isTest    
    static void testGetArticle() {
        
        Knowledge__kav article = [Select Id from Knowledge__kav where Title = :ARTICLE_TITLE];

        Test.startTest();

            ArticlePageController.ResultWrapper result = ArticlePageController.getArticle(article.Id);

            System.assertEquals(article.Id, result.article.Id, 'The Article Ids should be the same.');
            System.assert(result.breadcrumbs.size() > 0, 'There should be breadcrumbs.');

            List<Recently_Viewed_Article__c> viewedArticles = [Select Id from Recently_Viewed_Article__c where Article__c = :article.Id and User__c = :UserInfo.getUserId()];

            System.assertEquals(1, viewedArticles.size(), 'There should be 1 viewed article');

        Test.stopTest();

    }

    @isTest    
    static void testGetArticleGuest() {

        SiteUtils.USER_TYPE = 'Guest';
        
        Knowledge__kav article = [Select Id from Knowledge__kav where Title = :ARTICLE_TITLE];

        Test.startTest();

            ArticlePageController.ResultWrapper result = ArticlePageController.getArticle(article.Id);

            System.assertEquals(article.Id, result.article.Id, 'The Article Ids should be the same.');
            System.assert(result.breadcrumbs.size() > 0, 'There should be breadcrumbs.');

            List<Recently_Viewed_Article__c> viewedArticles = [Select Id from Recently_Viewed_Article__c where Article__c = :article.Id and User__c = null];

            System.assertEquals(1, viewedArticles.size(), 'There should be 1 viewed article');

        Test.stopTest();

    }
    
    @isTest
    static void testGetArticleGuestNoAccess() {
        
        SiteUtils.USER_TYPE = 'Guest';
        
        Knowledge__kav article = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing no access',
                                                                                        Knowledge__kav.Body_Content__c => 'Test',
                                                                                        Knowledge__kav.UrlName => 'TestArt'}, true);

        article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article.Id];

        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        Knowledge__DataCategorySelection articleDataCategory = TestUtils.createDataCategorySelection(new Map<SObjectField, Object>{Knowledge__DataCategorySelection.DataCategoryGroupName => 'Help_Center',
                                                                                        Knowledge__DataCategorySelection.DataCategoryName => 'Account_Information'}, article.Id, true);
		Test.startTest();
        
        String errorMessage;
        
        try {
            ArticlePageController.ResultWrapper result = ArticlePageController.getArticle(article.Id);
        }
        catch(Exception e) {
            errorMessage = e.getMessage();
        }
        
        System.assertEquals('No Article Found', errorMessage, 'The message should match.');
        
        Test.stopTest();
    }
    
    @isTest    
    static void testGetArticleCommunity() {

        SiteUtils.USER_TYPE = 'Community';
        
        Knowledge__kav article = [Select Id from Knowledge__kav where Title = :ARTICLE_TITLE];

        Test.startTest();

            ArticlePageController.ResultWrapper result = ArticlePageController.getArticle(article.Id);

            System.assertEquals(article.Id, result.article.Id, 'The Article Ids should be the same.');
            System.assert(result.breadcrumbs.size() > 0, 'There should be breadcrumbs.');

        Test.stopTest();

    }
}