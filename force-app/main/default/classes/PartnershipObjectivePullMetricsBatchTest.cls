@isTest 
public class PartnershipObjectivePullMetricsBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testNotificationCreation(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today()+100,Objective_start_date__C = Date.today()-30,Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Onboarding', Type__c = 'Partner Metrics Tracking',Performance_Objective_Health__c='On Track');
        obj.Success_Metrics_Details__c = 'abc';
        obj.Success_Metrics_Tracking__C = 'tracking';
        insert obj;
        opp.MeW_Timeframe_in_months__c = 1;
        opp.Projected_Mews_Growth__c = 2;
        opp.Stablecoin_Volume_Timeframe_in_months__c = 3;
        opp.Projected_Total_Stablecoin_Volume__c = 4;
        opp.Stablecoin_On_Pltfrm_Timeframe_months__c = 5;
        opp.Projected_Stablecoin_on_Platform_Growth__c = 6;
        opp.Monthly_active_users__C = 7;
        opp.Success_Metrics_Details__c = '8';
        opp.Success_Metrics_Tracking__C = '9';
        update opp;

        Test.startTest();
            PartnershipObjectivePullOppMetricsBatch b = new PartnershipObjectivePullOppMetricsBatch();
            Database.executeBatch(b, 1);
        Test.stopTest();

        obj = [SELECT ID,MeW_Timeframe_in_months__c,Projected_Mews_Growth__c,Stablecoin_Volume_Timeframe_in_months__c,Projected_Total_Stablecoin_Volume__c,Stablecoin_On_Pltfrm_Timeframe_months__c,Projected_Stablecoin_on_Platform_Growth__c,Monthly_active_users__C,Success_Metrics_Details__c,Success_Metrics_Tracking__C FROM Partnership_Objective__c WHERE ID = :obj.id];
        System.assertEquals(1, obj.MeW_Timeframe_in_months__c);
        System.assertEquals(2, obj.Projected_Mews_Growth__c);
        System.assertEquals(3, obj.Stablecoin_Volume_Timeframe_in_months__c);
        System.assertEquals(4, obj.Projected_Total_Stablecoin_Volume__c);
        System.assertEquals(5, obj.Stablecoin_On_Pltfrm_Timeframe_months__c);
        System.assertEquals(6, obj.Projected_Stablecoin_on_Platform_Growth__c);
        System.assertEquals(7, obj.Monthly_active_users__C);
        System.assertEquals('abc', obj.Success_Metrics_Details__c);
        System.assertEquals('tracking', obj.Success_Metrics_Tracking__C);
    }

    @isTest static void testSchuedlePartnershipObjectivePullMetricsBatchTest(){
        String year = String.valueOf(Date.today().addYears(1).year());
        String CRON_EXP = '0 0 0 3 9 ? '+year;
        // Schedule the test job
        String jobId = System.schedule('SchedulePartnershipObjNotificationBatch', CRON_EXP, new SchedulePartnershipObjectiveMetricRollUp());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals(year+'-09-03 00:00:00', String.valueOf(ct.NextFireTime));
    }
}