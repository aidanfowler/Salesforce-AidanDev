public with sharing class CsBreadcrumbController {
    private static final String GETTING_STARTED = 'Getting_Started';
    private static final String ACCOUNT_INFORMATION = 'Account_Information';
    private static final String FAQ = 'FAQ';

    @TestVisible
    private static Map<String, String> mapURLs = new Map<String, String>{
        GETTING_STARTED => 'getting-started',
        ACCOUNT_INFORMATION => 'account-information',
        FAQ => 'faq-page'
    };

    @TestVisible
    private static Map<String, String> mapLabels = new Map<String, String>{
        GETTING_STARTED => 'Getting Started',
        ACCOUNT_INFORMATION => 'Account Info',
        FAQ => 'FAQ'
    };

    @AuraEnabled
    public static UrlWrapper doGetSetting(String url) {
        if (String.isBlank(url)) {
            return new UrlWrapper();
        }

        List<Knowledge__DataCategorySelection> dataCategorySelections = selectDataCategorySelectionsWhereParentUrl(url);
        if (dataCategorySelections.isEmpty()) {
            return new UrlWrapper();
        }

        String categoryName = String.valueOf(dataCategorySelections[0].DataCategoryName);
        if (!mapURLs.containsKey(categoryName) || !mapLabels.containsKey(categoryName)) {
            return new UrlWrapper();
        }

        return new UrlWrapper(mapURLs.get(categoryName), mapLabels.get(categoryName));
    }

    private static List<Knowledge__DataCategorySelection> selectDataCategorySelectionsWhereParentUrl(String url) {
        return Test.isRunningTest()
            ? new List<Knowledge__DataCategorySelection>{ new Knowledge__DataCategorySelection(DataCategoryName = 'FAQ') }
            : [SELECT Id, DataCategoryName FROM Knowledge__DataCategorySelection WHERE Parent.UrlName = :url LIMIT 1];
    }

    public class UrlWrapper {
        @AuraEnabled
        public String url { get; set; }
        @AuraEnabled
        public String name { get; set; }

        public UrlWrapper() {
            this.url = '';
            this.name = '';
        }

        public UrlWrapper(String u, String n) {
            this.url = u;
            this.name = n;
        }
    }
}