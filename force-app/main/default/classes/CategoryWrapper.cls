public class CategoryWrapper {
    
    public CategoryWrapper() {
        subcategories = new List<SubcategoryWrapper>();
        articles = new List<ArticleWrapper>();
    }

    @AuraEnabled
    public String categoryId {get; set;}
    @AuraEnabled
    public String name {get; set;}
    @AuraEnabled
    public String label {get; set;}
    @AuraEnabled
    public Integer order {get; set;}
    @AuraEnabled
    public String icon {get; set;}
    @AuraEnabled
    public String groupName {get; set;}
    @AuraEnabled
    public Integer numArticles {get; set;}
    @AuraEnabled
    public List<SubcategoryWrapper> subcategories {get; set;}
    @AuraEnabled
    public List<ArticleWrapper> articles {get; set;}
}