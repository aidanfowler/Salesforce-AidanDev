@isTest 
public with sharing class RollUpPartnershipObjectivesBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testBatchJob(){
        Account act = CircleTestDataFactory.insertAccount();
        Account act2 = act.clone(false,true);
        insert act2;
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Test', Date.today(), 'Circle Mint');
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today(),Objective_start_date__C = Date.today(),Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Onboarding', Type__c = 'Partner Metrics Tracking',Performance_Objective_Health__c='Not Started');
        
        obj.Current_MEWs__c = 2;
        obj.Starting_Mews__c = 0;
        obj.Current_Stablecoin_Liquidity__c = 2;
        obj.Starting_stablecoin_Liquidity__C = 0;
        obj.Current_Stablecoin_Volume__c = 2;
        obj.Starting_Stablecoin_volume__C = 0;
        obj.Projected_MEWs_Growth__c = 2;
        obj.Projected_Stablecoin_on_Platform_Growth__c = 2;
        obj.Projected_Total_Stablecoin_Volume__c = 2;
        
        insert obj;
        obj = [SELECT ID, Projected_Metrics__C,Current_Metrics__c,Attainment__c FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals('MEWs: 2<br>USDC On Platform: $2<br>Transaction Volume: $2',obj.Projected_Metrics__C);
        System.assertEquals('MEWs: 2<br>USDC On Platform: $2<br>Transaction Volume: $2',obj.Current_Metrics__c);
        System.assertEquals('MEWs: 100%<br>USDC On Platform: 100%<br>Transaction Volume: 100%',obj.Attainment__c);
        obj.Projected_Metrics__c = null;
        obj.Current_Metrics__c = null;
        obj.Attainment__c = null;
        update obj;
        obj = [SELECT ID, Projected_Metrics__C,Current_Metrics__c,Attainment__c FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals(null,obj.Projected_Metrics__C);
        System.assertEquals(null,obj.Current_Metrics__c);
        System.assertEquals(null,obj.Attainment__c);
        Test.startTest();
            RollUpPartnershipObjectivesBatch b = new RollUpPartnershipObjectivesBatch();
            Database.executeBatch(b);
        Test.stopTest();

        obj = [SELECT ID, Projected_Metrics__C,Current_Metrics__c,Attainment__c FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals('MEWs: 2<br>USDC On Platform: $2<br>Transaction Volume: $2',obj.Projected_Metrics__C);
        System.assertEquals('MEWs: 2<br>USDC On Platform: $2<br>Transaction Volume: $2',obj.Current_Metrics__c);
        System.assertEquals('MEWs: 100%<br>USDC On Platform: 100%<br>Transaction Volume: 100%',obj.Attainment__c);
    }
}