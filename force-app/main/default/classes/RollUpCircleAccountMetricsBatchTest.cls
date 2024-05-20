@isTest 
public with sharing class RollUpCircleAccountMetricsBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testBatchJob(){
        Account act = CircleTestDataFactory.insertAccount();
        Account act2 = act.clone(false,true);
        insert act2;
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Test', Date.today(), 'Circle Mint');
        
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
}