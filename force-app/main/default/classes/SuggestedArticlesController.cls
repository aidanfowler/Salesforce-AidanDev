public without sharing class SuggestedArticlesController {

    public static Boolean hasError = false;
    public static final String DATA_GROUP_NAME = 'Help_Center';
    public static Integer MAX_SUGGESTED_ARTICLES = 3;

    @AuraEnabled(cacheable=true)
    public static List<CategoryWrapper> getCategoryMap() {

        List<CategoryWrapper> wrappers = new List<CategoryWrapper>();

        try {

            Map<String, CategoryWrapper> categoryNameToWrapper = new Map<String, CategoryWrapper>();
            Map<String, String> subCategoryToCategory = new Map<String, String>();

            // Get the Categories that have Suggested Articles.
            List<Support_Category__mdt> supportCategories = DataCategoryHelper.getSupportCategories(SiteUtils.isGated(), true);
            // Create the Category Wrappers for each subcategory
            wrappers = prepareCategoryWrappers(supportCategories, 
                                                                categoryNameToWrapper, 
                                                                subCategoryToCategory);

            // Get the Suggested Articles
            List<Knowledge__kav> articles;

            if(SiteUtils.isGuestUser()) {
                articles = [Select Id, Title, (
                    SELECT Id, DataCategoryName, DataCategoryGroupName
                    FROM DataCategorySelections
                    ) from Knowledge__kav Where PublishStatus='online' AND Language = 'en_US' and IsVisibleInPkb = true 
                    and IsLatestVersion = true and Suggested_Article__c = true order by Title ];
            }
            else if(SiteUtils.isStandardUser()) {
                articles = [Select Id, Title, (
                    SELECT Id, DataCategoryName, DataCategoryGroupName
                    FROM DataCategorySelections
                    ) from Knowledge__kav Where PublishStatus='online' AND Language = 'en_US' and IsVisibleInApp = true 
                    and IsLatestVersion = true and Suggested_Article__c = true order by Title ];
            }
            else {
                articles = [Select Id, Title, (
                    SELECT Id, DataCategoryName, DataCategoryGroupName
                    FROM DataCategorySelections
                    ) from Knowledge__kav Where PublishStatus='online' AND Language = 'en_US' and IsVisibleInCsp = true 
                    and IsLatestVersion = true and Suggested_Article__c = true order by Title ];
            }

            // Loop through the Articles
            for(Knowledge__kav article : articles) {

                // Loop through the Categories
                for(Knowledge__DatacategorySelection category : article.DataCategorySelections) {

                    // Check if in the main category
                    CategoryWrapper cWrapper = categoryNameToWrapper.get(category.DataCategoryName);

                    // Check if in a subcategory
                    if(cWrapper == null) {
                        String categoryName = subCategoryToCategory.get(category.DataCategoryName);

                        cWrapper = categoryNameToWrapper.get(categoryName);
                    }

                    // Create the Wrapper if a match was found.
                    if(cWrapper != null) {

                        // Create the ArticleWrapper
                        ArticleWrapper aWrapper = new ArticleWrapper();
                        aWrapper.name = article.Title;
                        aWrapper.Id = article.Id;
                        cWrapper.articles.add(aWrapper);
                    }
                }
            }

            // Make sure the article size is at max
            checkArticleSize(wrappers);

            // For Unit testing
            if(hasError) {
                AuraHandledException exc = new AuraHandledException('Throwing error.');
                exc.setMessage('Throwing error.');
                throw exc;
            }
        }
        catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());
            throw exc;
        }

        return wrappers;
        
    }

    private static List<CategoryWrapper> prepareCategoryWrappers(List<Support_Category__mdt> supportCategories, 
                                                                Map<String, CategoryWrapper> categoryNameToWrapper, 
                                                                Map<String, String> subCategoryToCategory) {

        List<CategoryWrapper> wrappers = new List<CategoryWrapper>();

        try {

            for(Support_Category__mdt supportCategory : supportCategories) {

                // Create a Wrapper.
                CategoryWrapper cWrapper = new CategoryWrapper();
                cWrapper.name = supportCategory.API_Name__c;
                cWrapper.label = supportCategory.Label;
                cWrapper.order = Integer.valueOf(supportCategory.Order__c);
                cWrapper.icon = supportCategory.Icon__c;

                // Set the Name with the wrapper
                categoryNameToWrapper.put(supportCategory.API_Name__c, cWrapper);

                // Create a map of subcategory to category to find the Main Category for the subcategory.
                List<DataCategory> subcategories = DataCategoryHelper.getSubCategories(DATA_GROUP_NAME, supportCategory.API_Name__c);

                for(DataCategory subcategory : subcategories) {
                    subCategoryToCategory.put(subcategory.getName(), supportCategory.API_Name__c);
                }

                wrappers.add(cWrapper);
            }
        }
        catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());
            throw exc;
        }

        return wrappers;
    }

    private static void checkArticleSize(List<CategoryWrapper> wrappers) {

        try {
            for(CategoryWrapper wrapper : wrappers) {
                if(wrapper.articles.size() > MAX_SUGGESTED_ARTICLES) {
                    while(wrapper.articles.size() > MAX_SUGGESTED_ARTICLES) {
                        // Get random index to remove if the size is greater than the max size.
                        Integer index = (Math.random() * (wrapper.articles.size() - 1)).intValue();
                        // Remove the Article
                        wrapper.articles.remove(index);
                    }
                }
            }
        }
        catch(Exception e) {
        }
    }
}