public without sharing class RecentlyViewedArticlesController {

    public static Boolean testError = false;    

    @AuraEnabled(cacheable=true)
    public static List<ArticleWrapper> getRecentlyViewedArticles(Id articleId){

        Boolean isGuest = SiteUtils.isGuestUser();

        List<ArticleWrapper> articles = new List<ArticleWrapper>();

        try {

            Knowledge__kav knowledgeArticle;
            // Get the Article for the article that is currently being viewed.
            if(articleId != null) {
                knowledgeArticle = [Select Id, KnowledgeArticleId from Knowledge__kav where (Id = :articleId OR KnowledgeArticleId = :articleId) AND PublishStatus = 'Online'];
            }

            List<Recently_Viewed_Article__c> viewedArticles;
            Map<Id, Knowledge__kav> articleMap = new Map<Id, Knowledge__kav>();

            // Get the Recently Viewed Articles.
            if(isGuest && knowledgeArticle != null) {
                viewedArticles = [Select Article__c, User__c, Article__r.KnowledgeArticleId from 
                                    Recently_Viewed_Article__c 
                                    where User__c = null and Article__r.KnowledgeArticleId != :knowledgeArticle.KnowledgeArticleId order by CreatedDate desc limit 5];
            }
            else if(knowledgeArticle != null) {
                viewedArticles = [Select Article__c, User__c, Article__r.KnowledgeArticleId 
                                    from Recently_Viewed_Article__c 
                                    where User__c = :userInfo.getUserId() and Article__r.KnowledgeArticleId != :knowledgeArticle.KnowledgeArticleId order by CreatedDate desc limit 5];
            }
            else if(isGuest && knowledgeArticle == null) {
                viewedArticles = [Select Article__c, User__c, Article__r.KnowledgeArticleId from 
                                    Recently_Viewed_Article__c 
                                    where User__c = null order by CreatedDate desc limit 5];
            }
            else if(knowledgeArticle == null) {
                viewedArticles = [Select Article__c, User__c, Article__r.KnowledgeArticleId 
                                    from Recently_Viewed_Article__c 
                                    where User__c = :userInfo.getUserId() order by CreatedDate desc limit 5];
            }

            Set<Id> articleIds = new Set<Id>();

            for(Recently_Viewed_Article__c viewedArticle : viewedArticles) {

                articleIds.add(viewedArticle.Article__r.KnowledgeArticleId);
            }

            // Check if the recently viewed article is published.
            for(Knowledge__kav currentArticle : [Select Id, KnowledgeArticleId, Title from Knowledge__kav 
                    where KnowledgeArticleId in :articleIds and PublishStatus = 'Online']) {

                articleMap.put(currentArticle.KnowledgeArticleId, currentArticle);
            }

            // Add the matching published article to the list.
            for(Recently_Viewed_Article__c viewedArticle : viewedArticles) {

                Knowledge__kav article = articleMap.get(viewedArticle.Article__r.KnowledgeArticleId);

                if(article != null) {
                    ArticleWrapper aw = new ArticleWrapper();
                    aw.name = article.Title;
                    aw.Id = article.Id;
                    articles.add(aw);
                }
            }

            // For Unit Testing
            if(testError) {
                throw new AuraHandledException('Testing error.');
            }
            
        } catch (Exception e) {

            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());

            AuraHandledException auraExc = new AuraHandledException(e.getMessage());
            auraExc.setMessage(e.getMessage());
            throw auraExc;
        }

        return articles;
    }
}