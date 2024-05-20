public without sharing class VideoCarouselController {
    
    @AuraEnabled(cacheable=true) 
    public static List<VideoWrapper> getVideos(){

        List<VideoWrapper> videoWrappers = new List<VideoWrapper>(); 

        List<Video__mdt> videos = Video__mdt.getAll().values();

        for(Video__mdt video : [Select Id, Title__c, Article_Id__c, Video_URL__c, Description__c, UUID__c, Order__c
                                from Video__mdt order by Order__c]) {
            VideoWrapper vw = new VideoWrapper();
            vw.header = video.Title__c;
            vw.articleId = video.Article_Id__c;
            vw.video = video.Video_URL__c;
            vw.description = video.Description__c;
            vw.uuid = video.UUID__c;
            vw.url = '/article-page?articleId=' + video.Article_Id__c;

            videoWrappers.add(vw);
        }

        return videoWrappers;
    }

    public class VideoWrapper {
        @AuraEnabled
        public String header {get; set;}
        @AuraEnabled
        public String video {get; set;}
        @AuraEnabled
        public String uuid {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String articleId {get; set;}
        @AuraEnabled
        public Integer order {get; set;}
        @AuraEnabled
        public String url {get; set;}
    }
}