@isTest
public class ComplianceSLANotificationsBatchTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testSLA(){
        Account act = CircleTestDataFactory.insertAccount();
        Opportunity opp = CircleTestDataFactory.insertOpportunity(act.Id, 'Test', Date.today(), 'Institutional Trading Partnership');
        opp.StageName = 'Approvals';
        opp.Compliance_Analyst__C = UserInfo.getUserId();
        opp.Compliance_State__C = 'Pending AML Review';
        update opp;
        opp.Last_Compliance_State_Change_Date__c = DateTime.now().addHours(-300);
        update opp;

        Test.startTest();
            ComplianceSLANotificationsBatch b = new ComplianceSLANotificationsBatch();
            Database.executeBatch(b);
        Test.stopTest();

        opp = [SELECT ID, send_Compliance_SLA_Notification__c FROM Opportunity WHERE ID = :opp.id];
        System.assertEquals(opp.send_Compliance_SLA_Notification__c, true);
    }

    @isTest static void testScheduledJob(){
        String year = String.valueOf(Date.today().addYears(1).year());
        String CRON_EXP = '0 0 0 3 9 ? '+year;
        // Schedule the test job
        String jobId = System.schedule('ScheduleComplianceSLANotificationsBatch', CRON_EXP, new ScheduleComplianceSLANotificationsBatch());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals(year+'-09-03 00:00:00', String.valueOf(ct.NextFireTime));         
    }

}