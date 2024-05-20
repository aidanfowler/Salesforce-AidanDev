@isTest
public class CircleAccountWebServiceTest {

    @TestSetup
    static void setup(){
       CircleTestDataFactory.insertCustomSettings(); 
    }
    
    @isTest static  void testWebService(){
        Account act = CircleTestDataFactory.insertAccount();
        Contact cont = CircleTestDataFactory.insertContact(act.Id,'first', 'last', null);
        Circle_Account__c ca = new Circle_Account__C(Account_Lookup__c = act.id, Contact__c = cont.id, Legal_entity_Name__C = 'legal', Nature_Of_Business__C = 'fiAssetMgr');
        ca.Name = 'Test CA';
        ca.Circle_Entity_Id__c = '123456z';
        insert ca;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CircleAccount';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
    
        CircleAccountWrapper accWrapper = new CircleAccountWrapper();
        accWrapper.natureOfBusiness = ca.Nature_of_Business__c;
        accWrapper.legalEntityName = ca.Legal_Entity_Name__c;
        accWrapper.name = ca.Name;
        accWrapper.withdrawalLimit = 123;
        CircleAccountWebService.upsertCircleAccount(accWrapper);
        List<Circle_Account__C> circleAccounts = [SELECT ID FROM Circle_Account__C WHERE Name = :ca.name];
        System.assertEquals(2, circleAccounts.size());
        accWrapper.circleEntityId = ca.Circle_Entity_Id__c;
        CircleAccountWebService.upsertCircleAccount(accWrapper);
        circleAccounts = [SELECT ID FROM Circle_Account__C WHERE Circle_Entity_Id__c = :ca.Circle_Entity_Id__c];
        System.assertEquals(1, circleAccounts.size());

        RestContext.response = null;
        String error;
        try{
            CircleAccountWebService.upsertCircleAccount(accWrapper);
        }
        catch(Exception e){
            error = e.getMessage();
        }
        System.assertNotEquals(null, error);

    }
}