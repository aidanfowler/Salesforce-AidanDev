@isTest 
public class AccountsTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testProductInterestContactInsert(){
        Account act = CircleTestDataFactory.insertAccount();
        Test.startTest();
            Contact contact = CircleTestDataFactory.insertContact(act.id, 'FirstName', 'LastName', 'Circle Mint');
        Test.stopTest();

        act = [SELECT Product_Interest__c FROM Account WHERE ID = :act.id];
        System.assertEquals('Circle Mint', act.Product_Interest__c);
    }
    
    @isTest static void testProductInterestContactUpdate(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact contact = CircleTestDataFactory.insertContact(act.id, 'FirstName', 'LastName', 'Circle Mint');
        Contact contact2 = CircleTestDataFactory.insertContact(act.id, 'FirstName', 'LastName', null);
        Test.startTest();
            contact2.Product_Interest__c = 'Payments API';
            update contact2;
        Test.stopTest();

        act = [SELECT Product_Interest__c FROM Account WHERE ID = :act.id];
        System.assertEquals('Circle Mint;Payments API', act.Product_Interest__c);
    }

    @isTest static void testProductInterestMultiAccountRelation(){
        Account act1 = CircleTestDataFactory.insertAccount();
        Account act2 = CircleTestDataFactory.insertAccount();
        Contact cont1 = CircleTestDataFactory.insertContact(act1.id, 'FirstName', 'LastName', null);
        
        Test.startTest();
            AccountContactRelation acr = new AccountContactRelation(AccountId = act2.id, ContactId = cont1.id);
            insert acr;
            cont1.Product_Interest__c = 'Circle Mint';
            update cont1;
        Test.stopTest();

        List<Account> acts = [SELECT ID, Product_Interest__C FROM Account WHERE ID = :act1.id OR ID = :act2.id];
        System.assertEquals(2, acts.size());
        for(Account act : acts){
            System.assertEquals('Circle Mint', act.Product_Interest__c);
        }
    }

    @isTest static void testAccountLifeCycles(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont0 = CircleTestDataFactory.insertContactWithStage(act.Id, 'First', 'Last0', 'first.last0@circle.com',null);
        act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
        System.assertEquals(null,act.LifeCycle_Stage__C);
        Contact cont = CircleTestDataFactory.insertContactWithStage(act.Id, 'First', 'Last1', 'first.last@circle.com1','Cold');
        act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
        System.assertEquals('Cold',act.LifeCycle_Stage__C);

        Test.startTest();
            cont.Stage__C = 'Customer';
            update cont;
            act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
            System.assertEquals('Customer',act.LifeCycle_Stage__C);
            Contact cont2 = CircleTestDataFactory.insertContactWithStage(act.Id, 'First', 'Last2', 'first.last2@circle.com','Subscriber');
            act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
            System.assertEquals('Customer',act.LifeCycle_Stage__C);
            cont.accountid = null;
            update cont;
            act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
            System.assertEquals('Subscriber',act.LifeCycle_Stage__C);
            cont2.accountId = null;
            update cont2;
            act = [SELECT LifeCycle_Stage__C FROM Account WHERE ID = :act.id];
            System.assertEquals(null,act.LifeCycle_Stage__C);
        Test.stopTest();
    }

    @isTest static void testMostRecentNotesHistory(){
        Account act = CircleTestDataFactory.insertAccount();
        act = [SELECT Most_recent_Notes__c, Most_recent_notes_history__C FROM Account WHERE ID = :act.id];
        System.assertEquals(null, act.Most_recent_notes_history__c);

        Test.startTest();
            act.Most_recent_notes__C = 'abc';
            update act;
            act = [SELECT Most_recent_Notes__c, Most_recent_notes_history__C FROM Account WHERE ID = :act.id];
            System.assertEquals('('+String.valueOf(Date.today())+') : abc', act.Most_recent_Notes_HIstory__C);
            act.Most_recent_Notes__C = 'test 123';
            update act;

        Test.stopTest();
        act = [SELECT Most_recent_Notes__c, Most_recent_notes_history__C FROM Account WHERE ID = :act.id];
        System.assertEquals('('+String.valueOf(Date.today())+') : test 123<br><br>('+String.valueOf(Date.today())+') : abc', act.Most_recent_Notes_HIstory__C);
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


    @isTest static void testAccountRollUpPOCalculationFields(){
        Account act = CircleTestDataFactory.insertAccount();
        Account act2 = act.clone(false,true);
        insert act2;
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Test', Date.today(), 'Circle Mint');
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today(),Objective_start_date__C = Date.today(),Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Onboarding', Type__c = 'Partner Metrics Tracking',Performance_Objective_Health__c='Not Started');
        insert obj;
        Test.setCreatedDate(obj.id,Date.today().addDays(-1));
        Test.startTest();
            Circle_Account__c ca = CircleTestDataFactory.makeCircleAccount(act.id, null,'Third-Party',true,true,true,true,true,'Cybavo Wallet SDK', 'Cards;Wires', 'Wires;USDC',200,100);
            insert ca;
            act = [SELECT ID, Starting_Metrics__c,Current_Metrics__c,Monthly_Avg_Metrics__c,Last_30_Day_Metrics__c,Last_30_Day_Metrics_Trend__c,Total_Burn_Volume_Last_30_Days__c,Total_Mint_Volume_Last_30_Days__c,Total_Current_Gross_Burn__c,Total_Current_Gross_Mint__c,Total_Monthly_Avg_Gross_Burn__c,Total_Monthly_Avg_Gross_Mint__c FROM Account WHERE ID = :act.id];        
            System.assertEquals(200,act.Total_Current_Gross_Mint__c);
            System.assertEquals(100,act.Total_Current_Gross_Burn__c);
            System.assertEquals(200,act.Total_Mint_Volume_Last_30_Days__c);
            System.assertEquals(100,act.Total_Burn_Volume_Last_30_Days__c);
            Circle_Account__c ca2 = CircleTestDataFactory.makeCircleAccount(act.id, null, 'None',true,true,true,false,true,'Cybavo Cashflow Manager', 'USDC;ACH','ACH',300,400);
            ca2.Monthly_Avg_Gross_Mint__c = 150;
            ca2.Monthly_Avg_Gross_Burn__c = 200;
            insert ca2;
            act = [SELECT ID, Starting_Metrics__c,Current_Metrics__c,Monthly_Avg_Metrics__c,Last_30_Day_Metrics__c,Last_30_Day_Metrics_Trend__c,Total_Burn_Volume_Last_30_Days__c,Total_Mint_Volume_Last_30_Days__c,Total_Current_Gross_Burn__c,Total_Current_Gross_Mint__c,Total_Monthly_Avg_Gross_Burn__c,Total_Monthly_Avg_Gross_Mint__c FROM Account WHERE ID = :act.id];
            System.assertEquals(500,act.Total_Current_Gross_Mint__c);
            System.assertEquals(500,act.Total_Current_Gross_Burn__c);
            System.assertEquals(350,act.Total_Monthly_Avg_Gross_Mint__c);
            System.assertEquals(300,act.Total_Monthly_Avg_Gross_Burn__c);
            System.assertEquals(500,act.Total_Mint_Volume_Last_30_Days__c);
            System.assertEquals(500,act.Total_Burn_Volume_Last_30_Days__c);
            ca2.Monthly_Avg_Gross_Mint__c = 450;
            ca2.Monthly_Avg_Gross_Burn__c = 500;
            update ca2;
            act = [SELECT ID, Starting_Metrics__c,Current_Metrics__c,Monthly_Avg_Metrics__c,Last_30_Day_Metrics__c,Last_30_Day_Metrics_Trend__c,Total_Burn_Volume_Last_30_Days__c,Total_Mint_Volume_Last_30_Days__c,Total_Current_Gross_Burn__c,Total_Current_Gross_Mint__c,Total_Monthly_Avg_Gross_Burn__c,Total_Monthly_Avg_Gross_Mint__c FROM Account WHERE ID = :act.id];
            System.assertEquals(650,act.Total_Monthly_Avg_Gross_Mint__c);
            System.assertEquals(600,act.Total_Monthly_Avg_Gross_Burn__c);
            System.assertEquals(500,act.Total_Mint_Volume_Last_30_Days__c);
            System.assertEquals(500,act.Total_Burn_Volume_Last_30_Days__c);
        Test.stopTest();
    }

    @isTest static void testOppLiquidityCoverageRollUp(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Test', Date.today(), 'Institutional Trading Partnership');
        Circle_Account__c ca = CircleTestDataFactory.insertCircleAccount(act.id, null, 'Third-Party',true,true,true,false,true,'Cybavo Cashflow Manager', 'Cards;Wires', 'USDC;Wires',100,200);  
        OpportunityTeamMember pm = new OpportunityTeamMember(OpportunityId = opp.id, userId = UserInfo.getUserId(),TeamMemberRole = 'Partner Manager'); 
        insert pm;
        
        opp.Liquidity_Coverage_Supported_Markets__c = 'Brazil';
        opp.Liquidity_Coverage_Partner_Status__c = 'Discovery';
        opp.Liquidity_Coverage_Priority__c = 'P0';
        opp.Liquidity_Coverage_Instant_Rails__c = 'Yes';
        opp.Liquidity_Coverage_Partner_Category__c = 'OTC';
        opp.Liquidity_Coverage_USDC_Source__c = 'Circle Mint';
        opp.Circle_Account__c = ca.id;
        opp.Liquidity_Coverage_Banking_Partner__c = 'UBS';
        opp.Liquidity_Coverage_Tied_To_Incentive__c = 'Yes';
        opp.Supported_Currencies_for_Minting__c = 'United Arab Emirates Dirham AED';
        opp.Supported_Currencies_for_Redeeming__c = 'Albania Lek ALL';
        opp.Minimum_Volume_Supported__c = 123;
        opp.Liquidity_Coverage_Supported_Audience__c = 'B2B';
        opp.StageName = 'Closed Won';

        Test.startTest();
            update opp;
        Test.stopTest();
        
        act = [SELECT ID, Liquidity_Coverage_deal__c from Account WHERE ID = :act.id];
        System.assertEquals(opp.id, act.Liquidity_Coverage_Deal__C);
    }
}