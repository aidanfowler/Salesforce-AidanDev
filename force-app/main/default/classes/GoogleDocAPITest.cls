@IsTest
global class GoogleDocAPITest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
        Trigger_Switches__c setting = [SELECT ID,Generate_Partnership_Construct__c FROM Trigger_Switches__c LIMIT 1];
        setting.Generate_Partnership_Construct__c = true;
        update setting;
    }

    @isTest static void testCreate(){
        GoogleDocMockResponse googleResponse = new GoogleDocMockResponse();
        googleResponse.statusCode = 400;
        Test.setMock(HttpCalloutMock.class, googleResponse);
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.makeOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');
        opp.Objective__c = '1234';
        opp.Hypothesis__c = '1234';
        opp.Risks_Dependencies__c = '1234';
        opp.Method__c = '1234';
        opp.Success_Metrics__c = 'MEWs;USDC on Platform;Transaction Volume;Other';
        opp.Success_Metrics_Details__c = '1234';
        opp.Success_Metrics_Tracking__c = '1234';
        opp.Projected_Mews_Growth__c = 1234;
        opp.Projected_Stablecoin_on_Platform_Growth__c = 1234;
        opp.Projected_Total_Stablecoin_Volume__c = 1234;
    
        
        googleResponse.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, googleResponse);

        Test.startTest();
            insert opp;
        Test.stopTest();

        opp = [SELECT ID, Partnership_Construct_Document_ID__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals('1234567', opp.Partnership_Construct_Document_ID__c);
    }

    @isTest static void testUpdate(){
        Test.setMock(HttpCalloutMock.class, new GoogleDocMockResponse());
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.makeOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');
        opp.Objective__c = '1234';
        opp.Hypothesis__c = '1234';
        opp.Risks_Dependencies__c = '1234';
        opp.Method__c = '1234';
        opp.Success_Metrics__c = 'MEWs;USDC on Platform;Transaction Volume;Other';
        opp.Success_Metrics_Details__c = '1234';
        opp.Success_Metrics_Tracking__c = '1234';
        opp.Projected_Mews_Growth__c = 1234;
        opp.Projected_Stablecoin_on_Platform_Growth__c = 1234;
        opp.Projected_Total_Stablecoin_Volume__c = 1234;
        insert opp;
        
        Test.startTest();
            opp.Partnership_Construct_Document_ID__c = '1234567';
            opp.Partnership_Construct_Last_Updated_Date__c = null;
            opp.Objective__c = '12345';
            update opp;   
        Test.stopTest();

        opp = [SELECT ID, Partnership_Construct_Document_ID__c,Partnership_Construct_Last_Updated_Date__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals('1234567', opp.Partnership_Construct_Document_ID__c);
        System.assertNotEquals(null, opp.Partnership_Construct_Last_Updated_Date__c);
    }

    @isTest
    private static void testCopy(){
        Test.setMock(HttpCalloutMock.class, new GoogleDocMockResponse());
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');
        
        test.startTest();
            HttpResponse res = GoogleDocAPI.copyPartnershipConstructFromTemplate('TEST');
        test.stopTest();

        System.assertEquals('application/json', res.getHeader('Content-Type'));
        System.assertEquals('{"documentId":"1234567", "id":"1234567"}', res.getBody());
        System.assertEquals(200, res.getStatusCode());
    }

    @isTest
    private static void testCopyFailure(){
        GoogleDocMockResponse googleResponse = new GoogleDocMockResponse();
        googleResponse.statusCode = 400;
        Test.setMock(HttpCalloutMock.class, googleResponse);
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');

        test.startTest();
            HttpResponse res = GoogleDocAPI.copyPartnershipConstructFromTemplate('TEST');
        test.stopTest();
        
        System.assertEquals(null, res);
    }

    @isTest
    private static void testShare(){
        GoogleDocMockResponse googleResponse = new GoogleDocMockResponse();
        googleResponse.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, googleResponse);
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');

        test.startTest();
            HttpResponse res = GoogleDocAPI.shareNewDocument('1234567');
        test.stopTest();

        System.assertEquals('application/json', res.getHeader('Content-Type'));
        System.assertEquals('{"documentId":"1234567", "id":"1234567"}', res.getBody());
        System.assertEquals(200, res.getStatusCode());
    }

    @isTest
    private static void testShareFailure(){
        GoogleDocMockResponse googleResponse = new GoogleDocMockResponse();
        googleResponse.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, googleResponse);
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');
        googleResponse.statusCode = 400;
        Test.setMock(HttpCalloutMock.class, googleResponse);
        test.startTest();
            HttpResponse res = GoogleDocAPI.shareNewDocument('1234567');
        test.stopTest();

        System.assertEquals(null, res);
    }


    @isTest
    private static void testBatchUpdate(){
        GoogleDocMockResponse googleResponse = new GoogleDocMockResponse();
        googleResponse.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, googleResponse);
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');

        test.startTest();
            HttpResponse res = GoogleDocAPI.batchUpdate('1234',opp.id,null);
        test.stopTest();

        System.assertEquals('application/json', res.getHeader('Content-Type'));
        System.assertEquals('{"documentId":"1234567", "id":"1234567"}', res.getBody());
        System.assertEquals(200, res.getStatusCode());
        opp = [SELECT ID, Partnership_Construct_Document_ID__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals('1234567', opp.Partnership_Construct_Document_ID__c);
    }

    @isTest
    private static void testBatchUpdateFailure(){
        GoogleDocMockResponse googleResponse = new GoogleDocMockResponse();
        googleResponse.statusCode = 400;
        Test.setMock(HttpCalloutMock.class, googleResponse);

        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.id, 'Name', Date.today(), 'Institutional Trading Partnership');

        test.startTest();
            HttpResponse res = GoogleDocAPI.batchUpdate('1234',opp.id,null);
        test.stopTest();
        
        System.assertEquals(null, res);
        opp = [SELECT ID, Partnership_Construct_Document_ID__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals(null, opp.Partnership_Construct_Document_ID__c);
    }
}