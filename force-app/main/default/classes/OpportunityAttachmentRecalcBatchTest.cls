@isTest 
public class OpportunityAttachmentRecalcBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testAddFile(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');

        ContentVersion contentVersion = new ContentVersion(Title = 'a picture',PathOnClient   = 'Pic.jpg', VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = opp.id; 
        objCntDocLink.ContentDocumentId = documents[0].Id; 
        objCntDocLink.shareType = 'V';        
        
        Test.startTest();
            insert objCntDocLink;
        Test.stopTest();

        opp = [SELECT Number_Of_Attachments__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals(1, opp.Number_Of_Attachments__c);
    }

    @isTest static void testDeleteFile(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');

        ContentVersion contentVersion = new ContentVersion(Title = 'a picture',PathOnClient   = 'Pic.jpg', VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = opp.id; 
        objCntDocLink.ContentDocumentId = documents[0].Id; 
        objCntDocLink.shareType = 'V';        
        
        Test.startTest();
            insert objCntDocLink;
            opp = [SELECT Number_Of_Attachments__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals(1, opp.Number_Of_Attachments__c);
            delete documents;
            opp = [SELECT Number_Of_Attachments__c FROM Opportunity WHERE ID = :opp.id];
            System.assertEquals(1, opp.Number_Of_Attachments__c);
            OpportunityAttachmentRecalculationBatch b = new OpportunityAttachmentRecalculationBatch();
            Database.executeBatch(b); 
        Test.stopTest();

        opp = [SELECT Number_Of_Attachments__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals(0, opp.Number_Of_Attachments__c);    
    }

    @isTest static void testSchuedleAttachmentRecalculation(){
        String year = String.valueOf(Date.today().addYears(1).year());
        String CRON_EXP = '0 0 0 3 9 ? '+year;
        // Schedule the test job
        String jobId = System.schedule('ScheduleAttachmentRecalculation', CRON_EXP, new ScheduleAttachmentRecalculation());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals(year+'-09-03 00:00:00', String.valueOf(ct.NextFireTime));         
    }
}