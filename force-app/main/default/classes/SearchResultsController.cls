public without sharing class SearchResultsController {

    public static final String VISIBLE_PUBLIC = 'IsVisibleInPkb';
    public static final String VISIBLE_CUSTOMER = 'IsVisibleInCsp';
    public static final String VISIBLE_INTERNAL = 'IsVisibleInApp';
    public static final String GUEST_USER_TYPE = 'Guest';
    public static final String STANDARD_USER_TYPE = 'Standard';
    public static final String WILD_CARD = '*';
    public static final String ALL_CATS = 'All Categories';
    public static String SEARCH_TERM = '';

    public static final Set<String> tokensToIgnore = new Set<String>{'a', 'the', 'and'};
    
    @AuraEnabled(cacheable=true)
    public static ResultWrapper getSearchResults(String searchTerm, Integer pageSize, String categoryName){

        ResultWrapper wrapper;
        List<CategoryWrapper> cWrappers = new List<CategoryWrapper>();

        try {

            List<Knowledge__kav> alphaArticles;
            List<Knowledge__kav> betaArticles;

            SEARCH_TERM = searchTerm;
            String wildSearchTerm = '%' + searchTerm + '%';

            // Search for the Articles. (search term in Title)
            if(SiteUtils.isGuestUser()) {

                alphaArticles = [Select Id from Knowledge__kav where Title like :wildSearchTerm 
                                and PublishStatus='online' AND Language = 'en_US' and IsVisibleInPkb = true and IsLatestVersion = true];
            }
            else if(SiteUtils.isStandardUser()) {
                alphaArticles = [Select Id from Knowledge__kav where Title like :wildSearchTerm
                                and PublishStatus='online' AND Language = 'en_US' and IsVisibleInApp = true and IsLatestVersion = true];
            }
            else {
                alphaArticles = [Select Id from Knowledge__kav where Title like :wildSearchTerm
                                and PublishStatus='online' AND Language = 'en_US' and IsVisibleInCsp = true and IsLatestVersion = true];
            }

            List<String> alphaArticleIds = new List<String>();
            
            // Compile the Article Ids.
            for(Knowledge__kav article : alphaArticles) {
                alphaArticleIds.add(article.Id);
            }

            // Search for the Beta Articles (search term in Summary).
            if(SiteUtils.isGuestUser()) {

                betaArticles = [Select Id from Knowledge__kav where Summary like :wildSearchTerm and Id not in :alphaArticleIds
                                and PublishStatus='online' AND Language = 'en_US' and IsVisibleInPkb = true and IsLatestVersion = true];
            }
            else if(SiteUtils.isStandardUser()) {
                betaArticles = [Select Id from Knowledge__kav where Summary like :wildSearchTerm and Id not in :alphaArticleIds
                                and PublishStatus='online' AND Language = 'en_US' and IsVisibleInApp = true and IsLatestVersion = true];
            }
            else {
                betaArticles = [Select Id from Knowledge__kav where Summary like :wildSearchTerm and Id not in :alphaArticleIds
                                and PublishStatus='online' AND Language = 'en_US' and IsVisibleInCsp = true and IsLatestVersion = true];
            }

            List<String> betaArticleIds = new List<String>();
            
            // Compile the Article Ids.
            for(Knowledge__kav article : betaArticles) {
                betaArticleIds.add(article.Id);
            }

            // Get the Search Terms.
            String searchVarsString = getSearchString(searchTerm);
            List<List<SObject>> articles;

            // Search for the Other Articles.
            if(SiteUtils.isGuestUser()) {
                articles = [FIND :searchVarsString In NAME FIELDS RETURNING Knowledge__kav
                                                     (Id WHERE PublishStatus='online' AND Language = 'en_US' and 
                                                     IsVisibleInPkb = true and IsLatestVersion = true and 
                                                     Id not in :alphaArticleIds and Id not in :betaArticleIds limit 2000)];
            }
            else if(SiteUtils.isStandardUser()) {
                articles = [FIND :searchVarsString In NAME FIELDS RETURNING Knowledge__kav
                                                     (Id WHERE PublishStatus='online' AND Language = 'en_US' and 
                                                     IsVisibleInApp = true and IsLatestVersion = true and 
                                                     Id not in :alphaArticleIds and Id not in :betaArticleIds limit 2000)];
            }
            else {
                articles = [FIND :searchVarsString In NAME FIELDS RETURNING Knowledge__kav
                                                     (Id WHERE PublishStatus='online' AND Language = 'en_US' and 
                                                     IsVisibleInCsp = true and IsLatestVersion = true and 
                                                     Id not in :alphaArticleIds and Id not in :betaArticleIds limit 2000)];
            }

            List<String> articleIds = new List<String>();
            
            // Compile the Article Ids.
            for(SObject article : articles[0]) {
                articleIds.add(article.Id);
            }

            // Get the Support Categories
            List<Support_Category__mdt> supportCategories = DataCategoryHelper.getSupportCategories(SiteUtils.isGated(), false);
            
            Map<String, CategoryWrapper> categoryWrapperMap = new Map<String, CategoryWrapper>();

            // Get the Number of Articles per category
            for(Support_Category__mdt category : supportCategories) {

                String query = 'Select count() from KnowledgeArticleVersion Where (Id in :articleIds or Id in :alphaArticleIds or Id in :betaArticleIds) and '
                                + 'PublishStatus=\'online\' WITH DATA CATEGORY Help_Center__c below ' + category.API_Name__c + '__c';

                Integer numArticles = Database.countQuery(query);
            
                if(numArticles > 0) {
                    CategoryWrapper cWrapper = new CategoryWrapper();
                    cWrapper.name = category.API_Name__c;
                    cWrapper.label = category.Label;
                    cWrapper.numArticles = numArticles;
                    cWrappers.add(cWrapper);
                }
            }

            // Get the first page results.
            wrapper = getResults(0, pageSize, articleIds, alphaArticleIds, betaArticleIds, categoryName);
            wrapper.categoryWrappers = cWrappers;
            wrapper.articleIds = articleIds;
            wrapper.alphaArticleIds = alphaArticleIds;
            wrapper.betaArticleIds = betaArticleIds;
            
        } catch (Exception e) {

            AuraHandledException exc = new AuraHandledException(e.getStackTraceString() + e.getMessage());
            exc.setMessage(e.getStackTraceString() + e.getMessage());

            throw exc;
        }

        return wrapper;
    }

    @AuraEnabled
    public static ResultWrapper getNextSearchResults(Integer offset, Integer pageSize, List<String> articleIds, List<String> alphaArticleIds, List<String> betaArticleIds, String categoryName) {

        return getResults(offset, pageSize, articleIds, alphaArticleIds, betaArticleIds, categoryName);
    }

    @TestVisible
    private static ResultWrapper getResults(Integer offset, Integer pageSize, List<String> articleIds,List<String> alphaArticleIds, List<String> betaArticleIds, String categoryName) {

        Set<String> supportCategories = new Set<String>();

        ResultWrapper wrapper = new ResultWrapper();

        Set<Id> addedArticleIds = new Set<Id>();

        try {

            if(categoryName == ALL_CATS) {

                List<KnowledgeArticleVersion> allArticles = new List<KnowledgeArticleVersion>();

                // Get the Alpha (Title)
                List<KnowledgeArticleVersion> articles = [Select Id, Title, LastPublishedDate, Summary 
                                                        from KnowledgeArticleVersion where Id in :alphaArticleIds and PublishStatus = 'online' 
                                                        and IsLatestVersion = true
                                                        order by title];

                allArticles.addAll(articles);

                // Get the Beta (Summary)
                articles = [Select Id, Title, LastPublishedDate, Summary 
                                                        from KnowledgeArticleVersion where Id in :betaArticleIds and Id not in :alphaArticleIds and PublishStatus = 'online' 
                                                        and IsLatestVersion = true
                                                        order by title];

                allArticles.addAll(articles);

                // Get the rest
                articles = [Select Id, Title, LastPublishedDate, Summary 
                                                        from KnowledgeArticleVersion where Id in :articleIds and Id not in :alphaArticleIds and Id not in :betaArticleIds and PublishStatus = 'online' 
                                                        and IsLatestVersion = true
                                                        order by title];

                articles = bubbleSortArticlesByMatchSize(articles);

                allArticles.addAll(articles);

                // Get the offset and the limit
                Integer articleLimit = offset + pageSize;

                if(allArticles.size() < articleLimit) {
                    articleLimit = allArticles.size();
                }

                // Loop through the articles and add to the results.
                for(Integer index = offset; index < articleLimit; index++) {

                    KnowledgeArticleVersion article = allArticles[index];

                    updateSearchResults(wrapper, article);
                }

                // Set the Number of Results.
                wrapper.numResults = allArticles.size();
            }
            else {

                List<KnowledgeArticleVersion> allArticles = new List<KnowledgeArticleVersion>();

                String countQuery = 'Select count() from KnowledgeArticleVersion Where (Id in :articleIds or Id in :alphaArticleIds or Id in :betaArticleIds) and '
                                    + 'PublishStatus=\'online\' WITH DATA CATEGORY Help_Center__c below ' + categoryName + '__c';

                // Get the count
                wrapper.numResults = Database.countQuery(countQuery);

                // Get the Alpha
                String articleQuery = 'Select Id, Title, LastPublishedDate, Summary from KnowledgeArticleVersion where Id in :alphaArticleIds and '
                                    + 'PublishStatus=\'online\' WITH DATA CATEGORY Help_Center__c below ' + categoryName + '__c '
                                    + 'order by title';

                List<KnowledgeArticleVersion> articles = Database.query(articleQuery);

                allArticles.addAll(articles);

                // Get the Beta
                articleQuery = 'Select Id, Title, LastPublishedDate, Summary from KnowledgeArticleVersion where Id in :betaArticleIds and Id not in :alphaArticleIds and '
                                    + 'PublishStatus=\'online\' WITH DATA CATEGORY Help_Center__c below ' + categoryName + '__c '
                                    + 'order by title';

                articles = Database.query(articleQuery);

                allArticles.addAll(articles);

                // Get the other results.
                articleQuery = 'Select Id, Title, LastPublishedDate, Summary from KnowledgeArticleVersion where Id in :articleIds and Id not in :alphaArticleIds and Id not in :betaArticleIds and '
                                    + 'PublishStatus=\'online\' WITH DATA CATEGORY Help_Center__c below ' + categoryName + '__c '
                                    + 'order by title';

                articles = Database.query(articleQuery);

                articles = bubbleSortArticlesByMatchSize(articles);

                allArticles.addAll(articles);

                // Get the offset and limit
                Integer articleLimit = offset + pageSize;

                if(allArticles.size() < articleLimit) {
                    articleLimit = allArticles.size();
                }

                // Add the current search results.
                for(Integer index = offset; index < articleLimit; index++) {

                    KnowledgeArticleVersion article = allArticles[index];

                    updateSearchResults(wrapper, article);
                }
            }
        }
        catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getStackTraceString() + e.getMessage());
            exc.setMessage(e.getStackTraceString() + e.getMessage());

            throw exc;
        }

        return wrapper;
    }

    private static void updateSearchResults(ResultWrapper wrapper, KnowledgeArticleVersion article) {
        SearchResult result = new SearchResult();
        result.articleId = article.Id;
        result.title = article.Title;
        result.description = article.Summary;
        result.publishedDate = article.LastPublishedDate;

        wrapper.searchResults.add(result);
    }

    private static String getSearchString(String searchTerm) {
        // Get the Search Terms.
        if(searchTerm == null) {
            searchTerm = '';
        }
        else {
            searchTerm = EncodingUtil.urlDecode(searchTerm, 'UTF-8');
        }

        // Either split or start with the search term.
        Set<String> searchVars;

        try {
            searchVars = new Set<String>(searchTerm.split('+'));
        }
        catch(Exception e) {
            searchVars = new Set<String>{searchTerm};
        }

        List<String> tempSearchTerms = new List<String>();
        List<List<SObject>> articles;

        // split all terms on space.
        for(String var : searchVars) {
            List<String> vals = var.split(' ');
            tempSearchTerms.addAll(vals);
        }

        searchVars.addAll(tempSearchTerms);

        // Combine all search terms with Wild cards
        List<String> searchVarsNew = new List<String>();

        List<String> searchVarsList = new List<String>(searchVars);

        for(Integer i = 0; i < searchVarsList.size(); i++) {
            if(!tokensToIgnore.contains(searchVarsList[i])) {
                searchVarsNew.add(WILD_CARD + searchVarsList[i].trim() + WILD_CARD);
            }
        }

        // Join terms with OR.
        return String.join(searchVarsNew, ' or ');
    }

    private static List<KnowledgeArticleVersion> bubbleSortArticlesByMatchSize(List<KnowledgeArticleVersion> articles){
        Map<Id, KnowledgeArticleVersion> knowledgeArticleMap = new Map<Id, KnowledgeArticleVersion>(articles);
        //Order articles without exact matches by Title relevance
        Set<String> searchStrings = new Set<String>();
        for(String searchItem : SEARCH_TERM.split(' ')){
            searchStrings.add(searchItem.toLowerCase());
        }
        List<articleRelevanceWrapper> articleRelevanceList = new List<articleRelevanceWrapper>();
        // Compile the Article Ids.
        for(KnowledgeArticleVersion article : articles) {
            Integer counter = 0;
            for(String searchItem : searchStrings){
                if(article.Title.toLowerCase().contains(searchItem)){
                    counter++;
                }
            }
            ArticleRelevanceWrapper arw = new ArticleRelevanceWrapper();
            arw.articleId = article.id;
            arw.matches = counter;
            articleRelevanceList.add(arw);
        }
        if(articleRelevanceList.size() > 0){
            Integer n = articleRelevanceList.size();
            for(Integer i=0; i<n-1; i++){
                Boolean swapped = false;
                for(Integer j =0; j<n-1-i; j++){
                    if(articleRelevanceList.get(j).matches < articleRelevanceList.get(j+1).matches){
                        ArticleRelevanceWrapper temp = articleRelevanceList.get(j);
                        articleRelevanceList.set(j,articleRelevanceList.get(j+1)); 
                        articleRelevanceList.set(j+1,temp);
                        swapped = true;
                    }
                }
                //if no further sorting is needed
                if(!swapped){
                    break;
                }
            }
            articles.clear();
            for(ArticleRelevanceWrapper arw : articleRelevanceList){
                articles.add(knowledgeArticleMap.get(arw.articleId));
            }
        }
        return articles;
    }

    public class articleRelevanceWrapper{
        public Integer matches {get;set;}
        public String articleId {get;set;}
    }

    public class ResultWrapper {
        @AuraEnabled
        public List<SearchResult> searchResults {get; set;}
        @AuraEnabled
        public List<CategoryWrapper> categoryWrappers {get; set;}
        @AuraEnabled
        public Integer numResults {get; set;}
        @AuraEnabled
        public List<String> articleIds {get; set;}
        @AuraEnabled
        public List<String> alphaArticleIds {get; set;}
        @AuraEnabled
        public List<String> betaArticleIds {get; set;}

        public ResultWrapper() {
            searchResults = new List<SearchResult>();
            categoryWrappers = new List<CategoryWrapper>();
        }
    }

    public class SearchResult {
        @AuraEnabled        
        public String articleId {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public DateTime publishedDate {get; set;}
        @AuraEnabled
        public String categoryName {get; set;}

        public SearchResult() {
            
        }
    }
}