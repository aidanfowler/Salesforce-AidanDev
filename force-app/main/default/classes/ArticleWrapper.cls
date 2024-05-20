public class ArticleWrapper {
	
    @AuraEnabled
    public String name {get; set;}
    @AuraEnabled
    public String body {get; set;}
    @AuraEnabled
    public String Id {get; set;}
}