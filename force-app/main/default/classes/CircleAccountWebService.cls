@RestResource(urlMapping='/CircleAccount/*')
global class CircleAccountWebService {

    @HttpPost
    global static void upsertCircleAccount(CircleAccountWrapper properties) {
        RestResponse res = RestContext.response;
        Map<String, String> mapResponse = new Map<String, String>();
        try{
            Circle_Account__c circleAccount = new Circle_Account__c();
            if(properties.circleEntityId != null){
                List<Circle_Account__c> circleAccounts = CircleAccountDAO.getCircleAccountByID(properties.circleEntityId);
                if(circleAccounts.size() > 0){
                    circleAccount = circleAccounts.get(0);
                }
            }
            circleAccount.Legal_Entity_Name__c = properties.legalEntityName != null ? properties.legalEntityName : circleAccount.Legal_Entity_Name__c;
            circleAccount.Name = properties.name != null ? properties.name : circleAccount.Name;
            if(circleAccount.Name != null && circleAccount.Name.length()>79){
                circleAccount.Name = circleAccount.Name.left(79);
            }
            circleAccount.Withdrawal_Limit__c = properties.withdrawalLimit != null ? properties.withdrawalLimit : circleAccount.Withdrawal_Limit__c;
            circleAccount.Account_Lookup__c = properties.accountId != null ? properties.accountId : circleAccount.Account_Lookup__c;
            circleAccount.Contact__c = properties.contactId != null ? properties.contactId : circleAccount.Contact__c;
            circleAccount.Lead__c = properties.leadId != null ? properties.leadId : circleAccount.Lead__c;
            circleAccount.Case__c = properties.caseId != null ? properties.caseId : circleAccount.Case__c;
            circleAccount.Diameter_URL__c = properties.diameterURL != null ? properties.diameterURL : circleAccount.Diameter_URL__c;
            circleAccount.Business_Website__c = properties.businessWebsite != null ? properties.businessWebsite : circleAccount.Business_Website__c;
            circleAccount.State_of_Incorporation__c = properties.stateOfIncorporation != null ? properties.stateOfIncorporation : circleAccount.State_of_Incorporation__c;
            circleAccount.Product_Application_Interest__c = properties.productApplicationInterest != null ? properties.productApplicationInterest : circleAccount.Product_Application_Interest__c;
            circleAccount.Country_of_Incorporation__c = properties.countryOfIncorporation != null ? properties.countryOfIncorporation : circleAccount.Country_of_Incorporation__c;
            circleAccount.Entity_Type_PQ__c = properties.entityTypePQ != null ? properties.entityTypePQ : circleAccount.Entity_Type_PQ__c;
            circleAccount.Circle_Account_Application_Status__c = properties.circleAccountApplicationStatus != null ? properties.circleAccountApplicationStatus : circleAccount.Circle_Account_Application_Status__c;
            circleAccount.Nature_of_Business__c = properties.natureOfBusiness != null ? properties.natureOfBusiness : circleAccount.Nature_of_Business__c;
            circleAccount.CeFi_Yield_Application_Status__c = properties.ceFiYieldApplicationStatus != null ? properties.ceFiYieldApplicationStatus : circleAccount.CeFi_Yield_Application_Status__c;
            circleAccount.Circle_Customer_Id__c = properties.circleCustomerId != null ? properties.circleCustomerId : circleAccount.Circle_Customer_Id__c;
            circleAccount.Account_Type__c = properties.accountType != null ? properties.accountType : circleAccount.Account_Type__c;
            circleAccount.Accounts_API__c = properties.accountsApi != null ? properties.accountsApi : circleAccount.Accounts_API__c;
            circleAccount.Application_Submitted_Date__c = properties.applicationSubmittedDate != null ? properties.applicationSubmittedDate : circleAccount.Application_Submitted_Date__c;
            circleAccount.Business_Segment__c = properties.businessSegment != null ? properties.businessSegment : circleAccount.Business_Segment__c;
            circleAccount.Core_API__c = properties.coreApi != null ? properties.coreApi : circleAccount.Core_API__c;
            circleAccount.Doing_Business_As_DBA__c = properties.doingBusinessAsDBA != null ? properties.doingBusinessAsDBA : circleAccount.Doing_Business_As_DBA__c;
            circleAccount.Cybavo__c = properties.cybavo != null ? properties.cybavo : circleAccount.Cybavo__c;
            circleAccount.Deposit_Limit__c = properties.depositLimit != null ? properties.depositLimit : circleAccount.Deposit_Limit__c;
            circleAccount.Entity_Type_PQ_0__c = properties.entityTypePQ != null ? properties.entityTypePQ : circleAccount.Entity_Type_PQ_0__c;
            circleAccount.First_Transaction__c = properties.firstTransaction != null ? properties.firstTransaction : circleAccount.First_Transaction__c;
            circleAccount.First_Transaction_Date__c = properties.firstTransactionDate != null ? properties.firstTransactionDate : circleAccount.First_Transaction_Date__c;
            circleAccount.Hubspot_Circle_Id__c = properties.hubspotCircleId != null ? properties.hubspotCircleId : circleAccount.Hubspot_Circle_Id__c;
            circleAccount.Hubspot_Created_Date__c = properties.hubspotCreatedDate != null ? properties.hubspotCreatedDate : circleAccount.Hubspot_Created_Date__c;
            circleAccount.Last_Transaction__c = properties.lastTransaction != null ? properties.lastTransaction : circleAccount.Last_Transaction__c;
            circleAccount.Monthly_Payments_Volume__c = properties.monthlyPaymentsVolume != null ? properties.monthlyPaymentsVolume : circleAccount.Monthly_Payments_Volume__c;
            circleAccount.Payments_API__c = properties.paymentsApi != null ? properties.paymentsApi : circleAccount.Payments_API__c;
            circleAccount.Payouts_API__c = properties.payoutsApi != null ? properties.payoutsApi : circleAccount.Payouts_API__c;
            circleAccount.Read_Only_API__c = properties.readOnlyApi != null ? properties.readOnlyApi : circleAccount.Read_Only_API__c;
            circleAccount.SEN__c = properties.sen != null ? properties.sen : circleAccount.SEN__c;
            circleAccount.Signet__c = properties.signet != null ? properties.signet : circleAccount.Signet__c;
            circleAccount.USDC_Express__c = properties.usdcExpress != null ? properties.usdcExpress : circleAccount.USDC_Express__c;
            circleAccount.USDC_Express_Tokenization__c = properties.usdcExpressTokenization != null ? properties.usdcExpressTokenization : circleAccount.USDC_Express_Tokenization__c;
            circleAccount.Expected_Minting_Volume_Monthly__c = properties.expectedMintingVolumeMonthly != null ? properties.expectedMintingVolumeMonthly : circleAccount.Expected_Minting_Volume_Monthly__c;
            circleAccount.Active_Users_On_Platform__c = properties.activeUsersOnPlatform != null ? properties.activeUsersOnPlatform : circleAccount.Active_Users_On_Platform__c;
            circleAccount.Use_Case__c = properties.useCase != null ? properties.useCase : circleAccount.Use_Case__c;
            circleAccount.Weekly_Payments_Volume__c = properties.weeklyPaymentsVolume != null ? properties.weeklyPaymentsVolume : circleAccount.Weekly_Payments_Volume__c;
            circleAccount.Yield_Application_Approved_Date__c = properties.yieldApplicationApprovedDate != null ? properties.yieldApplicationApprovedDate : circleAccount.Yield_Application_Approved_Date__c;
            circleAccount.USDC_Rewards_Application_Status__c = properties.usdcRewardsApplicationStatus != null ? properties.usdcRewardsApplicationStatus : circleAccount.USDC_Rewards_Application_Status__c;
            circleAccount.Email_Verified__c = properties.emailVerified != null ? properties.emailVerified : circleAccount.Email_Verified__c;
            circleAccount.Circle_Account_Qualification_Status__C = properties.circleAccountQualificationStatus != null ? properties.circleAccountQualificationStatus : circleAccount.Circle_Account_Qualification_Status__C;
            if(circleAccount.id != null){
                update circleAccount;
                mapResponse.put('message', circleAccount.Id + ' Updated Successfully');
            }     
            else{ 
                circleAccount.Circle_Entity_Id__c = properties.circleEntityId;
                insert circleAccount;
                mapResponse.put('message', circleAccount.Id + ' Inserted Successfully');
            }
            res.responseBody = Blob.valueOf(JSON.serialize(mapResponse));
            res.statusCode = 200;
        }
        catch(Exception e){
            mapResponse.put('message', e.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(mapResponse));
            res.statusCode = 500;
        }
    }
}