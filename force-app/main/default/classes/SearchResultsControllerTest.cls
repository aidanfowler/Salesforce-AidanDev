@isTest
public without sharing class SearchResultsControllerTest {
    
    @TestSetup
    static void setupData(){

        Knowledge__kav article1 = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing',
                                                                Knowledge__kav.Summary => 'My New Test',
                                                                Knowledge__kav.Body_Content__c => 'Test',
                                                                Knowledge__kav.UrlName => 'Test1534',
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, false);
        Knowledge__kav article2 = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing',
                                                                Knowledge__kav.Summary => 'My New Test',
                                                                Knowledge__kav.Body_Content__c => 'Test2',
                                                                Knowledge__kav.UrlName => 'Test234534',
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, false);
        Knowledge__kav article3 = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing',
                                                                Knowledge__kav.Summary => 'My New Test',
                                                                Knowledge__kav.Body_Content__c => 'Test3',
                                                                Knowledge__kav.UrlName => 'Test34534',
                                                                Knowledge__kav.IsVisibleInPkb => true,
                                                                Knowledge__kav.IsVisibleInCsp => true}, false);

        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        articles.add(article1);
        articles.add(article2);
        articles.add(article3);

        insert articles;

        for(Knowledge__kav article : articles) {

            article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article.Id];

            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

            Knowledge__DataCategorySelection articleDataCategory = TestUtils.createDataCategorySelection(new Map<SObjectField, Object>{Knowledge__DataCategorySelection.DataCategoryGroupName => 'Help_Center',
                                                                                            Knowledge__DataCategorySelection.DataCategoryName => 'Account_Information'}, article.Id, true);
        }
    }

    @isTest
    static void testGetSearchResultsGuestAllCategories(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Guest';
        
        Test.startTest();

        Id [] fixedSearchResults= new Id[1];
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);

            SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 10, 'All Categories');

            System.assertEquals(3, result.searchResults.size(), 'There should be three results.');

        Test.stopTest();
    }

    @isTest
    static void testGetSearchResultsGuestAllCategoriesSmallPageSize(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Guest';
        
        Test.startTest();

        Id [] fixedSearchResults= new Id[1];
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);

            SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 2, 'All Categories');

            System.assertEquals(2, result.searchResults.size(), 'There should be three results.');

        Test.stopTest();
    }

    @isTest
    static void testGetSearchResultsGuestGettingStarted(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Guest';
        
        Test.startTest();

        Id [] fixedSearchResults= new Id[1];
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);

            SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 10, 'Getting_Started');

            System.assertEquals(3, result.searchResults.size(), 'There should be three results.');

        Test.stopTest();
    }

    @isTest
    static void testGetSearchResultsCommunityAllCategories(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Community';
        
        Test.startTest();

        Id [] fixedSearchResults= new Id[1];
        
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }

        Test.setFixedSearchResults(fixedSearchResults);

            SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 10, 'All Categories');

            System.assertEquals(3, result.searchResults.size(), 'There should be three results.');

        Test.stopTest();
    }

    @isTest
    static void testGetSearchResultsCommunityGettingStarted(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Community';
        
        Test.startTest();

        Id [] fixedSearchResults= new Id[1];
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);

            SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 10, 'Getting_Started');

            System.assertEquals(3, result.searchResults.size(), 'There should be three results.');

        Test.stopTest();
    }

    @isTest
    static void testGetSearchResultsCommunityGettingStartedSmallPageSize(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Community';
        
        Test.startTest();

        Id [] fixedSearchResults= new Id[1];
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);

            SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 2, 'Getting_Started');

            System.assertEquals(2, result.searchResults.size(), 'There should be two results.');

        Test.stopTest();
    }

    @isTest
    static void testGetResultsCommunityAllSmallPageSize(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Community';
        
        Test.startTest();

        List<Id> fixedSearchResults = new List<Id>();
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }

        SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 2, 'All Categories');

        Test.setFixedSearchResults(fixedSearchResults);

            result = SearchResultsController.getResults(2, 2, result.articleIds, fixedSearchResults, new List<String>(), 'All Categories');

            System.assertEquals(1, result.searchResults.size(), 'There should be one result.');

        Test.stopTest();
    }

    @isTest
    static void testGetResultsCommunityGettingStartedSmallPageSize(){

        List<Knowledge__kav> articles = [Select Id from knowledge__kav where Summary = 'My New Test'];

        SiteUtils.USER_TYPE = 'Community';
        
        Test.startTest();

        List<Id> fixedSearchResults = new List<Id>();
        for(Knowledge__kav article : articles) {
            fixedSearchResults.add(article.Id);
        }

        SearchResultsController.ResultWrapper result = SearchResultsController.getSearchResults('Article', 2, 'Getting_Started');

        Test.setFixedSearchResults(fixedSearchResults);

            result = SearchResultsController.getResults(2, 2, result.articleIds, fixedSearchResults, new List<String>(), 'Getting_Started');

            System.assertEquals(1, result.searchResults.size(), 'There should be one result.');

        Test.stopTest();
    }
}