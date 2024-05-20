public class OpportunityDAO {

    public static List<Opportunity> getOpportunitiesById(Set<Id> ids){
        return [SELECT ID, OwnerId, Name FROM Opportunity WHERE ID IN :ids];
    }

    public static List<Opportunity> getOpportunitiesWithAttachmentCount(Set<Id> ids){
        return [SELECT ID, Number_Of_Attachments__c, Needs_Attachmnet_Recalculation__c FROM Opportunity WHERE ID in :ids];
    }

    public static List<OpportunityTeamMember> getCSMOppTeamMembers(Set<Id> ids){
        return [SELECT ID, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN :ids and TeamMemberRole = 'Customer Success Manager'];

    }
}