@isTest
public without sharing class VideoCarouselControllerTest {
    
    @isTest
    static void testGetVideos() {
        Test.startTest();

            List<VideoCarouselController.VideoWrapper> videos = VideoCarouselController.getVideos();

            System.assertNotEquals(0, videos.size(), 'There should be video wrappers.');

        Test.stopTest();
    }
}