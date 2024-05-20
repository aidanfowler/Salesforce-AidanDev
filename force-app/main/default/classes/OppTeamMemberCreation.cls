public class OppTeamMemberCreation {
	@InvocableMethod
    public static void createOppTeamMembers(List<Account> a_accountList){
        //Account acc = a_accountList[0];
        Map<Id, Account> accMap = new Map<Id, Account>(a_accountList);
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppsToUpdateList = new List<Opportunity>();
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        oppList = [select id, AccountId, OwnerId, RecordTypeId, RecordType.Name from Opportunity where AccountId in :accMap.keySet() and IsClosed = false];
        //Map<Id, RecordType> oppRecordTypeMap = new Map<Id, RecordType>([select Id,Name from RecordType where sObjectType='Opportunity']);
        
        for(Opportunity opp : oppList){
            Account ac = new Account();
            ac = accMap.get(opp.AccountId);
            
            String currentOwnerId = ac.Platform_Owner__c;
            if(String.isNotBlank(currentOwnerId)){
                if(opp.RecordType.Name == 'Platform'){
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id, OwnerId = currentOwnerId);
                    oppsToUpdateList.add(oppToUpdate);
                }
                else{
                    otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Platform Rep'));
                }
            }
            
            currentOwnerId = ac.Treasury_Owner__c;
            if(String.isNotBlank(currentOwnerId)){
                if(opp.RecordType.Name == 'Treasury'){
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id, OwnerId = currentOwnerId);
                    oppsToUpdateList.add(oppToUpdate);
                }
                else{
                	otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Treasury Services Rep'));
                }
            }
            
            currentOwnerId = ac.Business_Development_Owner__c;
            if(String.isNotBlank(currentOwnerId)){
                if(opp.RecordType.Name == 'Business Development'){
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id, OwnerId = currentOwnerId);
                    oppsToUpdateList.add(oppToUpdate);
                }
                else{
                	otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Business Development Rep'));
                }
            }
            
            currentOwnerId = ac.Pre_Sales_Solution_Engineer__c;
            if(String.isNotBlank(currentOwnerId)){
                otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Pre-Sales Solution Engineer'));
            }
            currentOwnerId = ac.Post_Sales_Solution_Engineer__c;
            if(String.isNotBlank(currentOwnerId)){
                otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Post-Sales Solution Engineer'));
            }
            
            currentOwnerId = ac.Customer_Success_Manager__c;
            if(String.isNotBlank(currentOwnerId)){
                if(opp.RecordType.Name == 'Renewal'){
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id, OwnerId = currentOwnerId);
                    oppsToUpdateList.add(oppToUpdate);
                }
                else{
                	otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Customer Success Manager'));
                }
            }
            currentOwnerId = ac.Onboarding_Specialist__c;
            if(String.isNotBlank(currentOwnerId)){
                otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Onboarding Specialist'));
            }
            
            currentOwnerId = ac.Circle_Ventures_Owner__c;
            if(String.isNotBlank(currentOwnerId)){
                if(opp.RecordType.Name == 'Circle Ventures'){
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id, OwnerId = currentOwnerId);
                    oppsToUpdateList.add(oppToUpdate);
                }
                else{
                	otmList.add(returnTeamMember(currentOwnerId, opp.Id, 'Circle Ventures Rep'));
                }
            }
        }
        
        if(otmList.size() > 0){
            insert otmList;
        }
        if(oppsToUpdateList.size() > 0){
            update oppsToUpdateList;
        }
    }
    
    public static OpportunityTeamMember returnTeamMember(String a_userId, String a_opportunityId, String a_roleName){
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.UserId = a_userId;
        otm.TeamMemberRole = a_roleName;
        otm.OpportunityId = a_opportunityId;
        otm.OpportunityAccessLevel = 'Edit';
        return otm;
    }
}