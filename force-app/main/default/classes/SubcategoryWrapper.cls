public class SubcategoryWrapper {

    @AuraEnabled
    public String name {get; set;}
    @AuraEnabled
    public String label {get; set;}
    @AuraEnabled
    public List<ArticleWrapper> articles {get; set;}
}