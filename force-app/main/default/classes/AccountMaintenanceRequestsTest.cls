@isTest 
public class AccountMaintenanceRequestsTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest 
    static void testValidation(){
        Account act = CircleTestDataFactory.insertAccount();
        Account_Maintenance_Request__c amr = new Account_Maintenance_Request__C(Account__c = act.id, Request_type__c = 'Ownership Update');
        insert amr;

        String error = '';
        Test.startTest();
            amr.Request_Status__c = 'Approved';
            try{
                update amr;
            }
            catch(Exception e){
                error = e.getMessage();
            }
        Test.stopTest();

        System.assert(error.contains('Error: You must select a new owner before approving an account maintenance request if the request includes an ownership update'));
    }
}