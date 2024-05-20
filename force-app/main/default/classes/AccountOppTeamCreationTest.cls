@isTest
public class AccountOppTeamCreationTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }
    
    @isTest static void testOppTeamCreation(){
        Account acc = CircleTestDataFactory.insertAccount();
        acc.Platform_Owner__c = UserInfo.getUserId();
        acc.Pre_Sales_Solution_Engineer__c = UserInfo.getUserId();
        acc.Treasury_Owner__c = UserInfo.getUserId();
        acc.Post_Sales_Solution_Engineer__c = UserInfo.getUserId();
        update acc;

        Opportunity o = new Opportunity(AccountId = acc.Id, Name = 'TestOpp', CloseDate = date.today(),
                                        StageName = 'Discover', Product_s__c = 'Circle Mint');
        insert o;
        
        acc.Update_Opp_Team_Members__c = true;
        update acc;
    }
}