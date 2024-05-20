@isTest
public class PartnershipObjectivesTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testInsertPartnershipObjectiveRollupHealthLaunchStatus(){
        Account act = CircleTestDataFactory.insertAccount();
        Account act2 = act.clone(false,true);
        insert act2;
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Test', Date.today(), 'Circle Mint');
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today(),Objective_start_date__C = Date.today(),Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Onboarding', Type__c = 'Partner Metrics Tracking',Performance_Objective_Health__c='Not Started');
        insert obj;
        Test.setCreatedDate(obj.id,Date.today().addDays(-1));
        Test.startTest();
            act = [SELECT ID, Performance_Objective_Health__c,Launch_Status__c FROM Account WHERE ID = :act.id];
            System.assertEquals('Not Started', act.Performance_Objective_Health__c);
            System.assertEquals('Onboarding', act.Launch_Status__c);
            Partnership_Objective__c obj2 = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today(),Objective_start_date__C = Date.today(),Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Launched', Type__c = 'Partner Metrics Tracking',Performance_Objective_Health__c='On Track');
            insert obj2;
            act = [SELECT ID, Performance_Objective_Health__c,Launch_Status__c FROM Account WHERE ID = :act.id];
            System.assertEquals('On Track', act.Performance_Objective_Health__c);
            System.assertEquals('Launched', act.Launch_Status__c);
            obj2.Objective_Status__c = 'Onboarding';
            update obj2;
            act = [SELECT ID, Performance_Objective_Health__c,Launch_Status__c FROM Account WHERE ID = :act.id];
            System.assertEquals('On Track', act.Performance_Objective_Health__c);
            System.assertEquals('Onboarding', act.Launch_Status__c);
        Test.stopTest();
    }

    @isTest static void testMostRecentNoteHistory(){
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

        obj = [SELECT Most_Recent_Note__c, Most_recent_Note_History__c FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals('Note Content', obj.Most_Recent_Note__c);
        System.assertEquals('('+String.valueOf(Date.today())+') : Note Content', obj.Most_recent_Note_HIstory__C);
        obj.Most_recent_note__C = 'TEST 123';
        update obj;
        obj = [SELECT Most_Recent_Note__c, Most_recent_Note_History__c FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals('('+String.valueOf(Date.today())+') : TEST 123<br><br>('+String.valueOf(Date.today())+') : Note Content', obj.Most_recent_Note_History__c);
    }

    @isTest static void testAccountRollUpPOCalculationFields(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Test', Date.today(), 'Circle Mint');
        opp.Success_Metrics__c = 'MEWs;USDC On Platform;Transaction Volume;Other';
        update opp;
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today(),Objective_start_date__C = Date.today(),Pillar__c='Liquidity',Objective_Status__c='Onboarding', Type__c = 'Partner Metrics Tracking',Performance_Objective_Health__c='Not Started');
        
        obj.Current_MEWs__c = 2;
        obj.Current_Stablecoin_Liquidity__c = 2;
        obj.Current_Stablecoin_Volume__c = 2;
        obj.Projected_MEWs_Growth__c = 2;
        obj.Projected_Stablecoin_on_Platform_Growth__c = 2;
        obj.Projected_Total_Stablecoin_Volume__c = 2;
        
        insert obj;
        Test.setCreatedDate(obj.id,Date.today().addDays(-1));
        Test.startTest();
            obj = [SELECT ID, Projected_Metrics__C,Current_Metrics__c,Attainment__c FROM Partnership_Objective__c WHERE ID = :obj.id];
            System.assertEquals('MEWs: 2<br>USDC On Platform: $2<br>Transaction Volume: $2',obj.Projected_Metrics__C);
            System.assertEquals('MEWs: 2<br>USDC On Platform: $2<br>Transaction Volume: $2',obj.Current_Metrics__c);
            System.assertEquals('MEWs: 100%<br>USDC On Platform: 100%<br>Transaction Volume: 100%',obj.Attainment__c);
            obj.Current_MEWs__c = 1;
            obj.Current_Stablecoin_Liquidity__c = 1;
            obj.Current_Stablecoin_Volume__c = 1;
            obj.Custom_Metric__c = 1234;
            update obj;
            obj = [SELECT ID, Projected_Metrics__C,Current_Metrics__c,Attainment__c FROM Partnership_Objective__c WHERE ID = :obj.id];
            System.assertEquals('MEWs: 2<br>USDC On Platform: $2<br>Transaction Volume: $2',obj.Projected_Metrics__C);
            System.assertEquals('MEWs: 1<br>USDC On Platform: $1<br>Transaction Volume: $1',obj.Current_Metrics__c);
            System.assertEquals('MEWs: 50%<br>USDC On Platform: 50%<br>Transaction Volume: 50%',obj.Attainment__c);
            obj.Custom_Metric__c = 12345;
            opp.Success_Metrics__c = 'Other';
            update opp;
            update obj;
            obj = [SELECT ID, Projected_Metrics__C,Current_Metrics__c,Attainment__c FROM Partnership_Objective__c WHERE ID = :obj.id];
            System.assertEquals('Click into Partnership Objective for Detail',obj.Projected_Metrics__C);
            System.assertEquals('Click into Partnership Objective for Detail',obj.Current_Metrics__c);
            System.assertEquals('Click into Partnership Objective for Detail',obj.Attainment__c);
        Test.stopTest();
    }
}