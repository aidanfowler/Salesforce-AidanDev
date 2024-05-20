@isTest
public without sharing class CategoryPageControllerTest {

    private static final String GETTING_STARTED = 'Getting_Started';

    @TestSetup
    static void setupData(){

        Knowledge__kav article = TestUtils.createArticle(new Map<SObjectField, Object>{Knowledge__kav.Title => 'My New Test Article for testing',
                                                                                        Knowledge__kav.Body_Content__c => 'Test',
                                                                                        Knowledge__kav.UrlName => 'TestClass'}, true);

        article = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: article.Id];

        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

        Knowledge__DataCategorySelection articleDataCategory = TestUtils.createDataCategorySelection(new Map<SObjectField, Object>{Knowledge__DataCategorySelection.DataCategoryGroupName => 'Help_Center',
                                                                                        Knowledge__DataCategorySelection.DataCategoryName => 'Account_Information'}, article.Id, true);
    }
    
    @isTest
    static void testGetCategoryMapInternal() {

        Test.startTest();

        Map<String, List<SubcategoryWrapper>> categoryMap = CategoryPageController.getCategoryMap(GETTING_STARTED);

        System.assertEquals(1, categoryMap.size(), 'There should be one category map entry');

        Test.stopTest();
    }

    @isTest
    static void testGetCategoryMapGuestUser() {

        SiteUtils.USER_TYPE = 'Guest';

        Test.startTest();

        Map<String, List<SubcategoryWrapper>> categoryMap = CategoryPageController.getCategoryMap(GETTING_STARTED);

        System.assertEquals(1, categoryMap.size(), 'There should be one category map entry');

        Test.stopTest();
    }

    @isTest
    static void testGetCategoryMapCommunityUser() {

        SiteUtils.USER_TYPE = 'Community';

        Test.startTest();

        Map<String, List<SubcategoryWrapper>> categoryMap = CategoryPageController.getCategoryMap(GETTING_STARTED);

        System.assertEquals(1, categoryMap.size(), 'There should be one category map entry');

        Test.stopTest();
    }
}