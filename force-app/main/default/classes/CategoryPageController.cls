public without sharing class CategoryPageController {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<SubcategoryWrapper>> getCategoryMap(String categoryName) {

        Map<String, List<ArticleWrapper>> subCategoryToArticleWrapperMap = new Map<String, List<ArticleWrapper>>();
        
        Map<String, List<SubcategoryWrapper>> categoryMap = new Map<String, List<SubcategoryWrapper>>();

        try {

            // Get the Subcategories for the selected category
            List<DataCategory> subCategories = DataCategoryHelper.getSubCategories(DataCategoryHelper.DATA_CATEGORY_GROUP, categoryName);

            categoryMap.put(categoryName, new List<SubcategoryWrapper>());

            // Add the Subcategory Names for the query.
            List<String> subCategoryNames = new List<String>();
            subCategoryNames.add(categoryName + '__c');

            for(DataCategory subCategory : subCategories) {
                subCategoryNames.add(subCategory.getName() + '__c');
            }

            // Create the Subcategory for the Main Category for any articles that are part
            // of the main Category.
            SubcategoryWrapper mainCategoryWrapper = new SubcategoryWrapper();
            mainCategoryWrapper.name = '';
            mainCategoryWrapper.label = '';
            mainCategoryWrapper.articles = new List<ArticleWrapper>();
            List<SubcategoryWrapper> wrappers = categoryMap.get(categoryName);
            wrappers.add(mainCategoryWrapper);

            if(subCategoryNames.size() > 0) {

                // Get the Article Versions based on the User type
                String query;

                // Get all Articles in the Category Subcategories
                if(SiteUtils.isGuestUser()) {
                    query = 'SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus=\'online\' and IsLatestVersion = true and IsVisibleInPkb = true and Language = \'en_US\' WITH DATA CATEGORY Help_Center__c AT (' + String.join(subCategoryNames, ',') + ')';
                }
                else if(SiteUtils.isStandardUser()) {
                    query = 'SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus=\'online\' and IsLatestVersion = true and IsVisibleInApp = true and Language = \'en_US\' WITH DATA CATEGORY Help_Center__c AT (' + String.join(subCategoryNames, ',') + ')';
                }
                else {
                    query = 'SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus=\'online\' and IsLatestVersion = true and IsVisibleInCsp = true and Language = \'en_US\' WITH DATA CATEGORY Help_Center__c AT (' + String.join(subCategoryNames, ',') + ')';
                }

                Map<Id, KnowledgeArticleVersion> articleVersionMap = new Map<Id, KnowledgeArticleVersion>((List<KnowledgeArticleVersion>)Database.query(query));

                // Loop through the articles and create the ArticleWrappers.
                for(Knowledge__kav article : [Select Id, Title, LastPublishedDate, Summary, (
                    SELECT Id, DataCategoryName, DataCategoryGroupName
                    FROM DataCategorySelections) from Knowledge__kav where Id in :articleVersionMap.keySet() order by Title]) {

                    // Loop through the Data Categories
                    for(Knowledge__DatacategorySelection category : article.DataCategorySelections) {

                        if(category.DataCategoryName == categoryName) {
                            // Add an Article for the Main Category
                            ArticleWrapper aWrapper = new ArticleWrapper();
                            aWrapper.name = article.Title;
                            aWrapper.Id = article.Id;
                            
                            SubcategoryWrapper sWrapper = categoryMap.get(categoryName)[0];
                            sWrapper.articles.add(aWrapper);
                        }
                        else {

                            // Find the Subcategory list of articles.
                            List<ArticleWrapper> aWrappers = subCategoryToArticleWrapperMap.get(category.DataCategoryName);

                            if(aWrappers == null) {
                                // Add the Category to the List.
                                subCategoryToArticleWrapperMap.put(category.DataCategoryName, aWrappers = new List<ArticleWrapper>());
                            }

                            // Create the ArticleWrapper
                            ArticleWrapper aWrapper = new ArticleWrapper();
                            aWrapper.name = article.Title;
                            aWrapper.Id = article.Id;
                            aWrappers.add(aWrapper);
                        }
                    }
                }

                // Add all Subcategories to the SubcategoryWrappers list.
                for(DataCategory subCategory : subCategories) {
                    
                    SubcategoryWrapper sWrapper = new SubcategoryWrapper();
                    sWrapper.name = subCategory.getName();
                    sWrapper.label = subCategory.getLabel();
                    sWrapper.articles = subCategoryToArticleWrapperMap.get(subCategory.getName());

                    List<SubcategoryWrapper> subCategoryWrappers = categoryMap.get(categoryName);
                    subCategoryWrappers.add(sWrapper);
                }

                List<SubcategoryWrapper> subCatList = categoryMap.get(categoryName);

                // Remove the main Category articles if there are none.
                if(subCatList[0].articles.size() == 0) {
                    subCatList.remove(0);
                }
            }
        }
        catch(Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            AuraHandledException auraExc = new AuraHandledException(e.getMessage());
            auraExc.setMessage(e.getMessage());
            throw auraExc;
        }
        
        return categoryMap;
    }
}