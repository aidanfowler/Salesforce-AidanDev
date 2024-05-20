@isTest 
public class LeadsTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testConvertLeadInsertMatchEmail(){
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circle.com';
        act.Name = 'not provided';
        insert act;

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest@circle.com');
    
        Lead testLead = CircleTestDataFactory.makeLead();
        testLead.Email = 'aidantest@circle.com';
        testLead.Email_Domain__c = 'circle.com';
        testLead.Is_this_a_work_email__c = 'Yes';
        testLead.Legal_Entity_Name__C = 'Legal Name To Account';
        testLead.Auto_Convert__c = true;

        Test.startTest();
            insert testLead;
        Test.stopTest();

        testLead = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLead.id];
        System.assertEquals(act.id, testLead.ConvertedAccountId);
        System.assertEquals(cont.id, testLead.ConvertedContactId);
        act = [SELECT Name FROM Account WHERE ID = :act.id];
        System.assertEquals('Legal Name To Account',act.name);
    }

    @isTest static void testConvertLeadInsert200Leads(){
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circlex.com';
        act.Name = 'The Company';
        insert act;

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest@circle.com');
    
        List<Lead> testLeads = CircleTestDataFactory.make200Leads('The Company');

        Test.startTest();
            insert testLeads;
        Test.stopTest();

        Lead testLead = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLeads.get(0).id];
        Lead testLead2 = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLeads.get(199).id];
        System.assertEquals(act.id, testLead.ConvertedAccountId);
        System.assertEquals(act.id, testLead2.ConvertedAccountId);
        System.assertNotEquals(cont.id, testLead.ConvertedContactId);
    }

    @isTest static void testConvertLeadUpdateMatchCompany(){
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circlex.com';
        act.Name = 'Test Circle X';
        insert act;

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest@circle.com');
    
        Lead testLead = CircleTestDataFactory.makeLead();
        testLead.Email = 'aidantest@circle.com';
        testLead.Email_Domain__c = 'notcircle.com';
        testLead.Company = 'Test Circle X';
        testLead.Is_this_a_work_email__c = 'Yes';
        insert testLead;

        Test.startTest();
            testLead.Auto_Convert__c = true;
            update testLead;
        Test.stopTest();

        testLead = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLead.id];
        System.assertEquals(act.id, testLead.ConvertedAccountId);
        System.assertEquals(cont.id, testLead.ConvertedContactId);
    }

    @isTest static void testConvertLeadUpdateMatchLegalEntity(){
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circlex.com';
        act.Legal_Entity_Name__c = 'Match Legal Name';
        act.Name = 'Not Test Circle X';
        insert act;

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest@circle.com');
    
        Lead testLead = CircleTestDataFactory.makeLead();
        testLead.Email = 'aidantest@circle.com';
        testLead.Email_Domain__c = 'notcircle.com';
        testLead.Company = 'Test Circle X';
        testLead.Is_this_a_work_email__c = 'Yes';
        testLead.Legal_Entity_Name__c = 'Match Legal Name';
        insert testLead;

        Test.startTest();
            testLead.Auto_Convert__c = true;
            update testLead;
        Test.stopTest();

        testLead = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLead.id];
        System.assertEquals(act.id, testLead.ConvertedAccountId);
        System.assertEquals(cont.id, testLead.ConvertedContactId);
    }

    
    @isTest static void testConvertLeadErrorCoverage(){
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circlex.com';
        act.Legal_Entity_Name__c = 'Match Legal Name';
        act.Name = 'Not Test Circle X';
        insert act;

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest@circle.com');
    
        Lead testLead = CircleTestDataFactory.makeLead();
        testLead.Email = 'aidantest@circle.com';
        testLead.Email_Domain__c = 'notcircle.com';
        testLead.Company = 'Test Circle X';
        testLead.Is_this_a_work_email__c = 'Yes';
        testLead.Legal_Entity_Name__c = 'Match Legal Name';
        testLead.Nature_Of_Business__c = 'FAIL';
        testLead.Auto_Convert__c = true;
        
        Test.startTest();
            insert testLead;
        Test.stopTest();
        //test doesn't have asserts because no error is thrown - sent via email
    }

    @isTest static void testConvertLeadNoMatch(){
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circlex.com';
        act.Legal_Entity_Name__c = 'Match Legal Name';
        act.Name = 'Not Test Circle X';
        insert act;

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest2@circle.com');
    
        Lead testLead = CircleTestDataFactory.makeLead();
        testLead.Email = 'aidantest@circle.com';
        testLead.Email_Domain__c = 'notcirclexx.com';
        testLead.Company = 'Test Circle Xxx';
        testLead.Is_this_a_work_email__c = 'Yes';
        testLead.Legal_Entity_Name__c = 'Match Legal Namexx';
        testLead.Auto_Convert__c = true;
        
        Test.startTest();
            insert testLead;
        Test.stopTest();
        testLead = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLead.id];
        System.assertNotEquals(act.id, testLead.ConvertedAccountId);
        System.assertNotEquals(cont.id, testLead.ConvertedContactId);
    }

    @isTest static void testConvertLeadMatchJustContact(){
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circlex.com';
        act.Legal_Entity_Name__c = 'Match Legal Name';
        act.Name = 'Not Test Circle X';
        insert act;

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest@circle.com');
    
        Lead testLead = CircleTestDataFactory.makeLead();
        testLead.Email = 'aidantest@circle.com';
        testLead.Email_Domain__c = 'notcirclexx.com';
        testLead.Company = 'Test Circle Xxx';
        testLead.Is_this_a_work_email__c = 'Yes';
        testLead.Legal_Entity_Name__c = 'Match Legal Namexx';
        testLead.Auto_Convert__c = true;
        
        Test.startTest();
            insert testLead;
        Test.stopTest();
        testLead = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLead.id];
        System.assertEquals(act.id, testLead.ConvertedAccountId);
        System.assertEquals(cont.id, testLead.ConvertedContactId);
    }

    @isTest static void testConvertLeadNoMatchOwnerSDR(){
        User u = CircleTestDataFactory.insertUser();
        Account act = CircleTestDataFactory.makeAccount();
        act.Email_Domain__c = 'circlex.com';
        act.Legal_Entity_Name__c = 'Match Legal Name';
        act.Name = 'Not Test Circle X';
        insert act;
        

        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Test','Test','aidantest2@circle.com');
    
        Lead testLead = CircleTestDataFactory.makeLead();
        testLead.Email = 'aidantest@circle.com';
        testLead.Email_Domain__c = 'notcirclexx.com';
        testLead.Company = 'Test Circle Xxx';
        testLead.Is_this_a_work_email__c = 'Yes';
        testLead.Legal_Entity_Name__c = 'Match Legal Namexx';
        testLead.Auto_Convert__c = true;
        testLead.SDR_Owner__c = u.id;
        
        Test.startTest();
            insert testLead;
        Test.stopTest();
        testLead = [SELECT ID, ConvertedAccountId, ConvertedContactID FROM Lead WHERE ID = :testLead.id];
        System.assertNotEquals(act.id, testLead.ConvertedAccountId);
        System.assertNotEquals(cont.id, testLead.ConvertedContactId);
        List<Account> newAccounts = [SELECT id, name, legal_entity_name__c, OwnerID FROM Account];
        System.assertEquals(2, newAccounts.size());

    }

    @isTest static void testDataDeletedLead(){
        Lead lead = new Lead(Email = 'abc@gmail.com',FirstName = 'Aidan', LastName = 'test', Company = 'Aidan Test', Status='New');
        insert lead;

        Test.startTest();
            lead.Data_Deleted_Customer_Request__c = true;
            update lead;
        Test.stopTest();

        lead = [SELECT ID, FirstName, Email FROM Lead WHERE ID = :lead.id];
        System.assertEquals('data_deleted_abc@gmail.com', lead.Email);
        System.assertEquals('Data Deleted', lead.FirstName);
    }
}