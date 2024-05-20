@isTest
public without sharing class RecentlyViewedArticlesControllerTest {
    
    @TestSetup
    static void setupData(){

        List<Knowledge__kav> articles = new List<Knowledge__kav>();

        articles.add(TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'Test article',
                                                                                        Knowledge__kav.Body_Content__c => 'Test',
                                                                                        Knowledge__kav.UrlName => 'TestClass'}, false));

        articles.add(TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'Test article2',
                                                                                        Knowledge__kav.Body_Content__c => 'Tests',
                                                                                        Knowledge__kav.UrlName => 'TestsClass'}, false));

        insert articles;

        List<Recently_Viewed_Article__c> recentlyViewedArticles = new List<Recently_Viewed_Article__c>();

        for(Knowledge__kav article : [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id in :articles]) {
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

            recentlyViewedArticles.add(TestUtils.createRecentlyViewedArticle(null, article.Id, UserInfo.getUserId(), false));

            recentlyViewedArticles.add(TestUtils.createRecentlyViewedArticle(null, article.Id, null, false));
        }

        insert recentlyViewedArticles;
    }

    @isTest    
    static void testGetRecentlyViewedArticlesForUser() {

        Knowledge__kav article = [Select Id from Knowledge__kav limit 1];
        
        Test.startTest();

            List<ArticleWrapper> articles = RecentlyViewedArticlesController.getRecentlyViewedArticles(article.Id);

            System.assertEquals(1, articles.size(), 'There should be one recently viewed articles for the User.');

        Test.stopTest();
    }

    @isTest    
    static void testGetRecentlyViewedArticlesForGuest() {

        Knowledge__kav article = [Select Id from Knowledge__kav limit 1];

        // For testing.
        SiteUtils.USER_TYPE = 'Guest';
        
        Test.startTest();

            List<ArticleWrapper> articles = RecentlyViewedArticlesController.getRecentlyViewedArticles(article.Id);

            System.assertEquals(1, articles.size(), 'There should be one recently viewed articles for the Guest User.');

        Test.stopTest();
    }

    @isTest    
    static void testThrowingError() {

        Knowledge__kav article = [Select Id from Knowledge__kav limit 1];

        // For testing.
        RecentlyViewedArticlesController.testError = true;

        Boolean errorFound = false;
        
        Test.startTest();

            try {
                List<ArticleWrapper> articles = RecentlyViewedArticlesController.getRecentlyViewedArticles(article.Id);
            }
            catch(Exception e) {
                errorFound = true;
            }

            System.assertEquals(true, errorFound, 'There should have been an error thrown.');

        Test.stopTest();
    }
}