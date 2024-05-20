trigger AccountTrigger on Account (before update) {
    if(Trigger.isUpdate && Trigger_Switches__c.getInstance().Account_Trigger_Switch__c){
        List<Account> accOppTeamCreateList = new List<Account>();
        
        for(Account acc : Trigger.New){
            if(acc.Update_Opp_Team_Members__c){
                accOppTeamCreateList.add(acc);
                acc.Update_Opp_Team_Members__c = false;
            }
        }
        
        OppTeamMemberCreation.createOppTeamMembers(accOppTeamCreateList);
    }
}