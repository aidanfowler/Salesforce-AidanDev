public without sharing class ArticlePageController {

    private static final String MAIN_CATEGORY = 'Circle_Support';
    private static final String MAIN_CATEGORY_NAME = 'Circle Support';
    private static final String NO_ARTICLE_FOUND = 'No Article Found';

    @AuraEnabled
    public static RedirectResultWrapper redirectToMoreRecentArticle(String articleId) {

        RedirectResultWrapper redirectWrapper;

        try {
        
        List<Knowledge__kav> articles = [Select Id, PublishStatus, KnowledgeArticleId from Knowledge__kav where Id = :articleId];

        if(!articles.isEmpty()) {

            Knowledge__kav article = articles[0];

            if(article.PublishStatus == 'Online') {
                redirectWrapper = new RedirectResultWrapper();
                redirectWrapper.redirect = false;
            }
            else {
                article = [Select Id from Knowledge__kav where KnowledgeArticleId = :article.KnowledgeArticleId and PublishStatus = 'online'];

                redirectWrapper = new RedirectResultWrapper();
                redirectWrapper.redirect = true;
                redirectWrapper.currentArticleId = article.Id;
            }
        }
        else {
            redirectWrapper = new RedirectResultWrapper();
            redirectWrapper.redirect = false;
        }
        }
        catch(Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());

            AuraHandledException auraExc = new AuraHandledException(e.getMessage());
            auraExc.setMessage(e.getMessage());
            throw auraExc;
        }

        return redirectWrapper;
    }

    @AuraEnabled
    public static ResultWrapper getArticle(Id articleId){

        ResultWrapper result = new ResultWrapper();

        Knowledge__kav article;

        try {

            if(SiteUtils.isGuestUser()) {
                // Get the article
                List<Knowledge__kav> articles = [SELECT Id,PublishStatus,Title, Body_Content__c FROM Knowledge__kav WHERE (Id = :articleId and  IsVisibleInPkb = true) or (KnowledgeArticleId = :articleId and PublishStatus='online' AND Language = 'en_US' and IsVisibleInPkb = true and IsLatestVersion = true)];

                if(articles.size() > 0) {
                    article = articles[0];
                }
                else {                    
                    AuraHandledException auraExc = new AuraHandledException(NO_ARTICLE_FOUND);
                    auraExc.setMessage(NO_ARTICLE_FOUND);
                    throw auraExc;
                }
            }
            else if(SiteUtils.isStandardUser()) {
                // Get the article
                List<Knowledge__kav> articles = [SELECT Id,PublishStatus,Title, Body_Content__c FROM Knowledge__kav WHERE (Id = :articleId and IsVisibleInApp = true) or (KnowledgeArticleId = :articleId and PublishStatus='online' AND Language = 'en_US' and IsVisibleInApp = true and IsLatestVersion = true)];
            
                if(articles.size() > 0) {
                    article = articles[0];
                }
                else {
                    AuraHandledException auraExc = new AuraHandledException(NO_ARTICLE_FOUND);
                    auraExc.setMessage(NO_ARTICLE_FOUND);
                    throw auraExc;
                }
            }
            else {
                List<Knowledge__kav> articles = [SELECT Id,PublishStatus,Title, Body_Content__c FROM Knowledge__kav WHERE (Id = :articleId and IsVisibleInCsp = true) or (KnowledgeArticleId = :articleId and PublishStatus='online' AND Language = 'en_US' and IsVisibleInCsp = true and IsLatestVersion = true)];
            
                if(articles.size() > 0) {
                    article = articles[0];
                }
                else {
                    AuraHandledException auraExc = new AuraHandledException(NO_ARTICLE_FOUND);
                    auraExc.setMessage(NO_ARTICLE_FOUND);
                    throw auraExc;
                }
            }

            saveViewedArticle(article.Id);

            result.article = article;
            // Get the Category Breadcrumbs
            result.breadcrumbs = getCategoryHierarchy(article.Id);
            
        } catch (Exception e) {

            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());

            AuraHandledException auraExc = new AuraHandledException(e.getMessage());
            auraExc.setMessage(e.getMessage());
            throw auraExc;
        }

        return result;
    }

    private static List<Breadcrumb> getCategoryHierarchy(Id articleId){

        List<Breadcrumb> breadcrumbs = new List<Breadcrumb>();

        // Add the Main Breadcrumb
        Breadcrumb breadcrumb = new Breadcrumb();
        breadcrumb.label = MAIN_CATEGORY_NAME;
        breadcrumb.name = MAIN_CATEGORY;

        breadcrumbs.add(breadcrumb);

        try {
            // Get the SubCategories
            List<DataCategory> subcategories = DataCategoryHelper.getAllSubCategories(DataCategoryHelper.DATA_CATEGORY_GROUP);

            Knowledge__kav article = [Select Id, Title, LastPublishedDate, Summary, (
                SELECT Id, DataCategoryName, DataCategoryGroupName
                FROM DataCategorySelections
              ) from Knowledge__kav where Id = :articleId];

            // Loop through the Article categories.
            for(Knowledge__DatacategorySelection categorySelection : article.DataCategorySelections) {

                Boolean found = false;

                for(DataCategory category : subcategories) {

                    // Set the main Category name
                    if(category.getName() == categorySelection.DataCategoryName) {
                        breadcrumb = new Breadcrumb();
                        breadcrumb.label = category.getLabel();
                        breadcrumb.name = category.getName();

                        breadcrumbs.add(breadcrumb);
                        found = true;

                        break;
                    }

                    // Get Child Categories of the Sub Categories.
                    List<DataCategory> subCats = category.getChildCategories();

                    for(DataCategory subCat : subCats) {
                        
                        // If the Sub Category matches the DataCategory
                        if(subCat.getName() == categorySelection.DataCategoryName) {

                            // Set the Main SubCategory Name
                            breadcrumb = new Breadcrumb();
                            breadcrumb.label = category.getLabel();
                            breadcrumb.name = category.getName();

                            breadcrumbs.add(breadcrumb);

                            // Set the Lowest Level SubCategory
                            breadcrumb = new Breadcrumb();
                            breadcrumb.label = subCat.getLabel();
                            breadcrumb.name = subCat.getName();

                            breadcrumbs.add(breadcrumb);

                            found = true;
                            break;
                        }
                    }

                    if(found) {
                        break;
                    }
                }

                if(found) {
                    break;
                }
            }
            
        } catch (Exception e) {

            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());

            AuraHandledException auraExc = new AuraHandledException(e.getMessage());
            auraExc.setMessage(e.getMessage());
            throw auraExc;
        }

        return breadcrumbs;
    }

    private static void saveViewedArticle(Id articleId) {       

        try {
        
            Boolean isGuest = SiteUtils.isGuestUser();
            Id userId = UserInfo.getUserId();

            List<Recently_Viewed_Article__c> recentlyViewedArticles;
            List<Recently_Viewed_Article__c> recentlyViewedArticlesToDelete = new List<Recently_Viewed_Article__c>();

            // Get the Article
            List<Knowledge__kav> articles = [Select Id, KnowledgeArticleId from Knowledge__kav where Id = :articleId];

            if(articles.size() > 0) {

                // Get the Recently Viewed articles for the User or Guest.
                if(isGuest) {
                    recentlyViewedArticles = [Select Id, Article__r.KnowledgeArticleId from Recently_Viewed_Article__c where User__c = null];
                }
                else {
                    recentlyViewedArticles = [Select Id, Article__r.KnowledgeArticleId from Recently_Viewed_Article__c where User__c = :userId];
                }

                // Delete any Articles with the same KnowledgeArticleId
                for(Recently_Viewed_Article__c recentArticle : recentlyViewedArticles) {
                    if(recentArticle.Article__r.KnowledgeArticleId == articles[0].KnowledgeArticleId) {
                        recentlyViewedArticlesToDelete.add(recentArticle);
                    }
                }

                // Insert the Viewed article.
                Recently_Viewed_Article__c viewedArticle = new Recently_Viewed_Article__c();
                viewedArticle.Article__c = articleId;

                if(!isGuest) {
                    viewedArticle.User__c = UserInfo.getUserId();
                }

                insert viewedArticle;

                // Get any articles that need to be deleted.
                List<Recently_Viewed_Article__c> additionalArticlesToDelete;

                if(isGuest) {
                    additionalArticlesToDelete = [Select Id from Recently_Viewed_Article__c where User__c = null order by CreatedDate desc offset 10];
                }
                else {
                    additionalArticlesToDelete = [Select Id from Recently_Viewed_Article__c where User__c = :UserInfo.getUserId() order by createddate desc offset 10];
                }

                recentlyViewedArticlesToDelete.addAll(additionalArticlesToDelete);

                // Delete the Articles.
                if(recentlyViewedArticlesToDelete.size() > 0) {
                    delete recentlyViewedArticlesToDelete;
                }
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    public class Breadcrumb {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String label {get; set;}
    }

    public class ResultWrapper {
        @AuraEnabled
        public Knowledge__kav article { get; set;}
        @AuraEnabled
        public List<Breadcrumb> breadcrumbs {get; set;}

        public ResultWrapper() {
            breadcrumbs = new List<Breadcrumb>();
        }
    }

    public class RedirectResultWrapper {
        @AuraEnabled
        public Boolean redirect {get; set;}
        @AuraEnabled
        public String currentArticleId {get; set;}
    }
}