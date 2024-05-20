@isTest
public with sharing class EmailServiceTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }
 
    @isTest static void testErrorEmail(){
        CircleException ce = new CircleException();
        ce.setMessage('circle exception to trigger error email');
        EmailService.sendErrorEmail('aidan.fowler@circle.com','subject',ce);
        ce.setMessage('ConvertLead failed. First exception on row 0; first error: INACTIVE_OWNER_OR_USER, Record owner cannot be an inactive user.: []Lead Map: {00Q8b00001zyghaEAA=Lead:{Id=00Q8b00001zyghaEAA, IsDeleted=false, MasterRecordId=null, Salutation=null, FirstName=Jennifer, LastName=Avila, MiddleName=null, Suffix=null, Title=null, Company=Jen cleaners, Street=null, City=null, State=null, PostalCode=null, Country=null, StateCode=null, CountryCode=null, Latitude=null, Longitude=null, GeocodeAccuracy=null, Phone=null, MobilePhone=null, Fax=null, Email=peligrosaha@gmail.com, Website=null, PhotoUrl=null, Description=null, LeadSource=Paid Search, Status=Cold, Industry=null, Rating=null, AnnualRevenue=null, NumberOfEmployees=null, OwnerId=0058b00000GIimVAAT,');
        EmailService.sendErrorEmail('aidan.fowler@circle.com','subject',ce);
    }

    @isTest static void testEmailErrorFromCase(){
        Case c = CircleTestDataFactory.insertCustomerCareCase();
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        cont.Data_Deleted_Customer_Request__c = true;
        update cont;
        c.contactid = cont.id;
        update c;

        EmailMessage testEmail = new EmailMessage(ParentId = c.id, Incoming = false);
        String error = '';
        Test.startTest();
            try{
                insert testEmail;
            }
            catch(Exception e){
                error = e.getMessage();
            }
        Test.stopTest();
        System.assert(error.contains('You can not send an outbound email to a contact who has requested their data be deleted'));
    }

    @isTest static void testEmailErrorDirectToEmail(){
        Case c = CircleTestDataFactory.insertCustomerCareCase();
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.id, 'first', 'last', null);
        cont.Email = 'testblock@circle.com';
        cont.Data_Deleted_Customer_Request__c = true;
        update cont;
        c.contactid = cont.id;
        update c;

        EmailMessage testEmail = new EmailMessage(ToAddress='data_deleted_testblock@circle.com', Incoming = false);
        String error = '';
        Test.startTest();
            try{
                insert testEmail;
            }
            catch(Exception e){
                error = e.getMessage();
            }
        Test.stopTest();
        System.assert(error.contains('You can not send an outbound email to a contact who has requested their data be deleted'));
    }
}