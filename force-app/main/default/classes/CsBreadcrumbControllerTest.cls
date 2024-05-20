@IsTest
private class CsBreadcrumbControllerTest {
    private static final String FAQ_ARTICLE_URL = 'very-interesting-faq-page';

    @IsTest
    private static void faq_positiveTest() {
        // When
        Test.startTest();
        CsBreadcrumbController.UrlWrapper uw = CsBreadcrumbController.doGetSetting(FAQ_ARTICLE_URL);
        Test.stopTest();

        // Then
        System.assertEquals(CsBreadcrumbController.mapLabels.get('FAQ'), uw.name);
        System.assertEquals(CsBreadcrumbController.mapURLs.get('FAQ'), uw.url);
    }

    @IsTest
    private static void blankUrl_negativeTest() {
        // When
        Test.startTest();
        CsBreadcrumbController.UrlWrapper uw = CsBreadcrumbController.doGetSetting('');
        Test.stopTest();

        // Then
        System.assertEquals('', uw.name);
        System.assertEquals('', uw.url);
    }

    @IsTest
    private static void nullUrl_negativeTest() {
        // When
        Test.startTest();
        CsBreadcrumbController.UrlWrapper uw = CsBreadcrumbController.doGetSetting(null);
        Test.stopTest();

        // Then
        System.assertEquals('', uw.name);
        System.assertEquals('', uw.url);
    }
}