@isTest(SeeAllData=true)
public class AutoLeadConvertTest {
    public static testmethod void convertLeadTest(){
        Trigger_Switches__c setting = [SELECT ID, New_Lead_Conversion__c FROM Trigger_Switches__C];
        setting.New_Lead_Conversion__c = False;
        update setting;
        Lead ld = [select id, auto_convert__c, email_domain__c, 
                   Legal_Entity_Name__c, Company from Lead 
                   where email_domain__c != null and nature_of_business__c = null limit 1];
        List<Lead> leadList = [select id, auto_convert__c, email_domain__c, Is_this_a_work_email__c,
                               Legal_Entity_Name__c, Company from Lead 
                   			   where email_domain__c != null and isconverted = false
                               limit 20];
        
        
        
        for(Lead l : leadList){
            l.Auto_Convert__c = true;
            L.Is_this_a_work_email__c = 'Yes';
            System.debug(l.Id);
        }
        ld.Auto_Convert__c = true;
        
        List<Lead> littleLeadList = [select id, auto_convert__c, email_domain__c, Legal_Entity_Name__c, Company from Lead 
                   			   where email_domain__c != null and isconverted = false
                               //and 
                               //(id = '00Q8L000001ghn3UAA')// or id = '00Q8L000001WjGLUA0' or 
                                //id = '00Q8L000001WjGKUA0' or id = '00Q8L000001WjGJUA0' or 
                                //id = '00Q8L000001WjGIUA0')
                               limit 5];
        for(Lead l : littleLeadList){
            l.Auto_Convert__c = true;
            System.debug(l.Id);
        }
        
        Lead insertLead = new Lead(LastName = 'test', Company = 'TestCompanyTesting123', email_domain__c = 'thisisatest12389.com', Auto_Convert__c = true);
        Lead insertLead1 = new Lead(LastName = 'test', Company = 'TestNameTest789', Legal_Entity_Name__c = 'TestNameTesting123', Auto_Convert__c = true,
                                    email_domain__c = 'thisisatest123489.com');
        Account acc = new Account(Name = 'TestCompanyTesting123');
        Account acc1 = new Account(Name = 'TestingHereAgain789', Legal_Entity_Name__c = 'TestNameTesting123');
        insert acc;
        insert acc1;
        Test.startTest();
        
        insert insertLead;
        insert insertLead1;
        update littleLeadList;
        update leadList;
        Test.stopTest();
        System.debug(insertLead.Company);
        System.debug(insertLead1.Legal_Entity_Name__c);
    }
}