@isTest
public class ArticleWrapperTest {

    @isTest
    static void testArticleWrapper() {

        Test.startTest();

            ArticleWrapper wrapper = new ArticleWrapper();
            wrapper.name = 'New Article';
            wrapper.body = 'Test body';
            wrapper.Id = null;

            System.assertNotEquals(null, wrapper, 'There should be a wrapper.');

        Test.stopTest();
    }
}