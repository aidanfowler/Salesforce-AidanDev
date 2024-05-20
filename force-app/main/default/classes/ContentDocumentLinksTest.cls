@isTest 
public class ContentDocumentLinksTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    //nothing to assert as the outcome of this is a slack notificaiton being sent via the slack flow
    @isTest static void testContentDocumentLink(){
        User u = CircleTestDataFactory.insertLegalUser();
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');
        opp.OwnerId = u.id;
        update opp;
        
        ContentVersion contentVersion = new ContentVersion(Title = 'a picture',PathOnClient = 'Pic.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = documents.get(0).id, LinkedEntityId = opp.id);
        
        Test.startTest();
            insert cdl;
        Test.stopTest();
    }

    @isTest static void testPartnershipObjectiveNote(){
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
        
        Test.startTest();
            insert objCntDocLink;
        Test.stopTest();

        obj = [SELECT ID, Needs_Note_Update__C FROM Partnership_Objective__C WHERE ID = :obj.id];
        System.assertEquals(true, obj.Needs_Note_Update__C);
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

    @isTest static void testAddFileOpportunityCount(){
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

    @isTest static void testDeleteFileOpportunityCount(){
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

}