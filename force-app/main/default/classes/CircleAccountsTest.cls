@isTest
public class CircleAccountsTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testAccountRollupInsert(){
        Account act = CircleTestDataFactory.insertAccount();
        Test.startTest();
            Circle_Account__c ca = CircleTestDataFactory.insertCircleAccount(act.id, null, 'Third-Party',true,true,true,false,true,'Cybavo Cashflow Manager', 'Cards;Wires', 'USDC;Wires',100,200);   
        Test.stopTest();

        act = [SELECT ID, Accounts_API__c, Core_API_Number__C,Read_Only_API_Number__c,Sen_Number__c, Signet_Number__c,USDC_Express_Number__c, Cybavo__c, Payments_Api__c, Payouts_Api__c FROM Account WHERE ID = :act.id];
        System.assertEquals('Third-Party', act.Accounts_API__c);
        System.assertEquals(1, act.Core_API_Number__C);
        System.assertEquals(1, act.Read_Only_API_Number__c);
        System.assertEquals(1, act.Sen_Number__c);
        System.assertEquals(0, act.Signet_Number__c);
        System.assertEquals(1, act.USDC_Express_Number__c);
        System.assertEquals('Cybavo Cashflow Manager', act.Cybavo__c);
        System.assertEquals('Cards;Wires', act.Payments_Api__c);
        System.assertEquals('Wires;USDC', act.Payouts_Api__c);
    }

    @isTest static void testAccountRollupMultipleCA(){
        Account act = CircleTestDataFactory.insertAccount();
        Test.startTest();
            Circle_Account__c ca = CircleTestDataFactory.makeCircleAccount(act.id, null,'Third-Party',true,true,true,true,true,'Cybavo Wallet SDK', 'Cards;Wires', 'Wires;USDC',100,200);
            Circle_Account__c ca2 = CircleTestDataFactory.makeCircleAccount(act.id, null, 'None',true,true,true,false,true,'Cybavo Cashflow Manager', 'USDC;ACH','ACH',300,400);
            insert new List<Circle_Account__c>{ca,ca2}; 
        Test.stopTest();

        act = [SELECT ID, Accounts_API__c,Core_API_Number__C,Read_Only_API_Number__c,Sen_Number__c, Signet_Number__c,USDC_Express_Number__c,Cybavo__c,Payments_Api__c, Payouts_Api__c FROM Account WHERE ID = :act.id];
        System.assertEquals('None;Third-Party', act.Accounts_API__c);
        System.assertEquals(2, act.Core_API_Number__C);
        System.assertEquals(2, act.Read_Only_API_Number__c);
        System.assertEquals(2, act.Sen_Number__c);
        System.assertEquals(1, act.Signet_Number__c);
        System.assertEquals(2, act.USDC_Express_Number__c);
        System.assertEquals('Cybavo Cashflow Manager;Cybavo Wallet SDK', act.Cybavo__c);
        System.assertEquals('Cards;Wires;ACH;USDC', act.Payments_Api__c);
        System.assertEquals('Wires;ACH;USDC', act.Payouts_Api__c);
    }

    @isTest static void testAccountRollupUpdate(){
        Account act = CircleTestDataFactory.insertAccount();
        Circle_Account__c ca = CircleTestDataFactory.insertCircleAccount(act.id, null, 'Third-Party',true,true,true,true,true, 'Cybavo Cashflow Manager','USDC;ACH','USDC',100,200);
        Test.startTest();
            ca.Accounts_API__c = 'None';
            update ca;
            act = [SELECT ID, Accounts_API__c FROM Account WHERE ID = :act.id];
            System.assertEquals('None', act.Accounts_API__c);
            ca.Account_lookup__C = null;
            update ca;
            act = [SELECT ID, Accounts_API__c,Core_API_Number__C,Read_Only_API_Number__c,Sen_Number__c, Signet_Number__c, USDC_Express_Number__c,Cybavo__c,Payments_Api__c, Payouts_Api__c FROM Account WHERE ID = :act.id];
            System.assertEquals(null, act.Accounts_API__c);
            System.assertEquals(0, act.Core_API_Number__C);
            System.assertEquals(0, act.Read_Only_API_Number__c);
            System.assertEquals(0, act.Sen_Number__c);
            System.assertEquals(0, act.Signet_Number__c);
            System.assertEquals(0, act.USDC_Express_Number__c);
            System.assertEquals(null, act.Cybavo__c);
            System.assertEquals(null, act.Payments_Api__c);
            System.assertEquals(null, act.Payouts_Api__c);
            ca.Account_lookup__C = act.id;
            update ca;
        Test.stopTest();
    }
    

    @isTest static void testLeadCircleAccountRollupInsert(){
        Lead testLead = CircleTestDataFactory.insertLead();
        Test.startTest();
            Circle_Account__c ca = CircleTestDataFactory.makeCircleAccount(null, testLead.id, null,true,true,true,true,true,null,null,null,null,null);
            Circle_Account__c ca2 = CircleTestDataFactory.makeCircleAccount(null, testLead.id, null,true,true,true,true,true,null,null,null,null,null);
            insert new List<Circle_Account__c>{ca,ca2};
        Test.stopTest();

        testLead = [SELECT ID, Number_of_Circle_Accounts__c FROM Lead WHERE ID = :testLead.id];
        System.assertEquals(2, testLead.Number_of_Circle_Accounts__c);
    }

    @isTest static void testLeadCircleAccountRollupUpdate(){
        Lead testLead = CircleTestDataFactory.insertLead();
        Test.startTest();
            Circle_Account__c ca = CircleTestDataFactory.makeCircleAccount(null, testLead.id, null,true,true,true,true,true,null,null,null,null,null);
            Circle_Account__c ca2 = CircleTestDataFactory.makeCircleAccount(null, testLead.id, null,true,true,true,true,true,null,null,null,null,null);
            insert new List<Circle_Account__c>{ca,ca2};
            ca2.Lead__c = null;
            update ca2;
            testLead = [SELECT ID, Number_of_Circle_Accounts__c FROM Lead WHERE ID = :testLead.id];
            System.assertEquals(1, testLead.Number_of_Circle_Accounts__c);
        Test.stopTest();

        ca2.Lead__c = testLead.id;
        update ca2;
        testLead = [SELECT ID, Number_of_Circle_Accounts__c FROM Lead WHERE ID = :testLead.id];
        System.assertEquals(2, testLead.Number_of_Circle_Accounts__c);
    }    

    @isTest static void testCountryMapping(){
        Account act = CircleTestDataFactory.insertAccount();
        Test.startTest();
            Circle_Account__c ca = CircleTestDataFactory.insertCircleAccount(act.id, null, 'Third-Party',true,true,true,false,true,'Cybavo Cashflow Manager', 'Cards;Wires', 'USDC;Wires',100,200);
            ca = [SELECT ID, Region__c FROM Circle_Account__c WHERE ID = :ca.id];
            System.assertEquals('Americas', ca.Region__c);
            ca.Country_Of_Incorporation__c = 'BR';
            update ca;
        Test.stopTest();
        ca = [SELECT ID, Region__c FROM Circle_Account__c WHERE ID = :ca.id];
        System.assertEquals('LATAM', ca.Region__c);
    }
}