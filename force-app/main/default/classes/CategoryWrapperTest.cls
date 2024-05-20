@isTest
public class CategoryWrapperTest {

    @IsTest
    static void testCategoryWrapper() {

        Test.startTest();

            CategoryWrapper wrapper = new CategoryWrapper();
            wrapper.categoryId = null;
            wrapper.name = 'Test';
            wrapper.label = 'Test';
            wrapper.order = 1;
            wrapper.icon = '';
            wrapper.groupName = 'test';
            wrapper.numArticles = 5;

            ArticleWrapper aWrapper = new ArticleWrapper();
            aWrapper.name = 'New Article';
            aWrapper.body = 'Test body';
            aWrapper.Id = null;

            wrapper.articles.add(aWrapper);

            SubcategoryWrapper subWrapper = new SubcategoryWrapper();
            subWrapper.name = 'Sub';
            subWrapper.label = 'Sub';
            subWrapper.articles = new List<ArticleWrapper>();
            subWrapper.articles.add(aWrapper);

            System.assertEquals(1, wrapper.articles.size(), 'There should be 1 article.');

        Test.stopTest();
    }
}