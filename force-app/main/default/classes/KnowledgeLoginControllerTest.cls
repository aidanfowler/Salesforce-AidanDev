@isTest
public with sharing class KnowledgeLoginControllerTest {
    
    @IsTest
    static void testLogin() {

        Test.startTest();

            PageReference testPage = Page.KnowledgeLogin; 
            Test.setCurrentPage(testPage);
            KnowledgeLoginController controller = new KnowledgeLoginController();
            controller.emailAddress = UserInfo.getUserEmail();

            controller.login();

        Test.stopTest();
    }
}