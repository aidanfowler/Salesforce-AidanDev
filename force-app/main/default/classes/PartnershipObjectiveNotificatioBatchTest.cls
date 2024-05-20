@isTest 
public class PartnershipObjectiveNotificatioBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testNotificationCreation(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Name', Date.today(), 'Circle Mint');
        Partnership_Objective__c obj = new Partnership_Objective__c(Account__c = act.id, Opportunity__c = opp.id, Objective_Description__c = 'test',Customer_Segment__c='Banks',Deal_Construct__c = 'Blockchain',Liquidity__c=true,Objective_End_Date__c=Date.today()+100,Objective_start_date__C = Date.today()-30,Pillar__c='Liquidity',Stablecoin__c = 'USDC',Objective_Status__c='Onboarding', Type__c = 'Partner Metrics Tracking',Performance_Objective_Health__c='On Track');
        insert obj;
        
        Test.startTest();
            PartnershipObjectiveNotificationsBatch b = new PartnershipObjectiveNotificationsBatch();
            Database.executeBatch(b, 1);
        Test.stopTest();

        List<Task> taskss = [SELECT ID FROM Task WHERE WhatID = :obj.id];
        System.assertEquals(1, taskss.size());
    }

    @isTest static void testSchuedlePartnershipNotificationBatch(){
        String year = String.valueOf(Date.today().addYears(1).year());
        String CRON_EXP = '0 0 0 3 9 ? '+year;
        // Schedule the test job
        String jobId = System.schedule('SchedulePartnershipObjNotificationBatch', CRON_EXP, new SchedulePartnershipObjNotificationBatch());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals(year+'-09-03 00:00:00', String.valueOf(ct.NextFireTime));         
    }
}