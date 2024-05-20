public class CircleAccountDAO {

    public static List<Circle_Account__c> getCircleAccountByID(String entityId){
        return [SELECT ID, Legal_Entity_Name__c, Name, Withdrawal_Limit__c, Lead__c, Account_Lookup__c, Contact__c, Diameter_URL__c, Business_Website__c,
            State_of_Incorporation__c, Product_Application_Interest__c, Country_of_Incorporation__c, CeFi_Yield_Application_Status__c,Entity_Type_PQ__c, Circle_Account_Application_Status__c,
            Nature_of_Business__c, Circle_Customer_Id__c,Account_Type__c, Accounts_API__c, Application_Submitted_Date__c, Business_Segment__c,Case__c, Core_API__c, Doing_Business_As_DBA__c,
            Cybavo__c, Deposit_Limit__c, Entity_Type_PQ_0__c,First_Transaction__c, First_Transaction_Date__c,Hubspot_Circle_Id__c, Hubspot_Created_Date__c,Last_Transaction__c, Monthly_Payments_Volume__c,
            Payments_API__c, Payouts_API__c,Read_Only_API__c, SEN__c, SEN_Number__c, Signet__c,USDC_Express__c, USDC_Express_Number__c, USDC_Express_Tokenization__c, Use_Case__c,Weekly_Payments_Volume__c, 
            Yield_Application_Approved_Date__c,Yield_Application_Submitted_Date__c,USDC_Rewards_Application_Status__c,Email_Verified__c, Expected_Minting_Volume_Monthly__c,Active_Users_On_Platform__c,
            Circle_Account_Qualification_Status__C from Circle_Account__c where Circle_Entity_Id__c = :entityId limit 1];
    }
}