public with sharing class LeadDAO {

    public static List<Lead> getLeadsAndCircleAccountsById(Set<Id> leadIds){
        return [SELECT ID, Number_Of_Circle_Accounts__C, (SELECT ID FROM Circle_Accounts__r) FROM Lead WHERE ID IN :leadIds];
    }
}