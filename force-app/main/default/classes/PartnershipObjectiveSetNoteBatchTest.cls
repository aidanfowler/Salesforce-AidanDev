@isTest 
public class PartnershipObjectiveSetNoteBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testMostRecentNote(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today(),Objective_start_date__C = Date.today(),Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Onboarding', Type__c = 'Objective Tracking',Performance_Objective_Health__c='On Track');
        insert obj;

        ContentNote objCntNote = new ContentNote();
        objCntNote.Title = 'Note Title';
        objCntNote.Content = Blob.valueOf('Note Content');
        insert objCntNote;

        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = obj.id; 
        objCntDocLink.ContentDocumentId = objCntNote.Id; 
        objCntDocLink.shareType = 'V'; 
        insert objCntDocLink;
        
        Test.startTest();
            PartnershipObjectiveSetNoteBatch b = new PartnershipObjectiveSetNoteBatch();
            Database.executeBatch(b, 1);
        Test.stopTest();

        obj = [SELECT Most_Recent_Note__c FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals('Note Content', obj.Most_Recent_Note__c);
    }

    @isTest static void testMostRecentNoteUpdate(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today(),Objective_start_date__C = Date.today(),Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Onboarding', Type__c = 'Objective Tracking',Performance_Objective_Health__c='On Track');
        insert obj;

        ContentNote objCntNote = new ContentNote();
        objCntNote.Title = 'Note Title';
        objCntNote.Content = Blob.valueOf('Note Content');
        insert objCntNote;

        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = obj.id; 
        objCntDocLink.ContentDocumentId = objCntNote.Id; 
        objCntDocLink.shareType = 'V'; 
        insert objCntDocLink;

        objCntNote.Content = Blob.valueOf('Note Content 2');
        update objCntNote;
        
        Test.startTest();
            PartnershipObjectiveSetNoteBatch b = new PartnershipObjectiveSetNoteBatch();
            Database.executeBatch(b, 1);
        Test.stopTest();

        obj = [SELECT Most_Recent_Note__c FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals('Note Content 2', obj.Most_Recent_Note__c);
    }

    @isTest static void testSchuedlePartnershipNoteBatch(){
        String year = String.valueOf(Date.today().addYears(1).year());
        String CRON_EXP = '0 0 0 3 9 ? '+year;
        // Schedule the test job
        String jobId = System.schedule('SchedulePartnershipObjSetNoteBatch', CRON_EXP, new SchedulePartnershipObjSetNoteBatch());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals(year+'-09-03 00:00:00', String.valueOf(ct.NextFireTime));         
    }
}