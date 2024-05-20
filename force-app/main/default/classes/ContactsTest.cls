@isTest
public class ContactsTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @isTest static void testCreateDuplicateEmailError(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Aidan', 'Fowler', 'test@test.com');
        String errorMessage = '';
        Test.startTest();
            try{
                Contact contact2 = CircleTestDataFactory.insertContactWithEmail(act.id, 'Aidan2', 'Fowler2', 'test@test.com');
            } 
            catch(Exception e){
                errorMessage = e.getMessage();
            }
        Test.stopTest();
        System.assert(errorMessage.contains('There is a duplicate contact in the system with email')); 
    }

    @isTest static void testUpdateDuplicateEmailError(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Aidan', 'Fowler', 'test@test.com');
        Contact cont2 = CircleTestDataFactory.insertContactWithEmail(act.id, 'Aidan', 'Fowler', 'test2@test.com');
        String errorMessage = '';
        Test.startTest();
            try{
                cont2.email = 'test@test.com';
                update cont2;
            } 
            catch(Exception e){
                errorMessage = e.getMessage();
            }
        Test.stopTest();
        System.assert(errorMessage.contains('There is a duplicate contact in the system with email')); 
    }

    @isTest static void testDataDeletedContact(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContactWithEmail(act.id, 'Aidan', 'Fowler', 'test@test.com');

        Test.startTest();
            cont.Data_Deleted_Customer_Request__c = true;
            update cont;
        Test.stopTest();

        cont = [SELECT ID, FirstName, AccountId FROM Contact WHERE ID = :cont.id];
        System.assertEquals(null, cont.accountid);
        System.assertEquals('Data Deleted', cont.FirstName);
    }
}