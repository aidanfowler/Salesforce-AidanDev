public class LeadTriggerHandler {

    public static void handleBeforeUpdate(Map<Id, Lead> newLeads, Map<Id, Lead> oldLeads){
        Leads.dataDeletedRequest(newLeads, oldLeads);
    }

    public static void handleAfterInsert(Map<Id, Lead> newLeads){
        Leads.checkForAndConvertLeads(newLeads);
    }

    public static void handleAfterUpdate(Map<Id, Lead> newLeads, Map<Id, Lead> oldLeads){
        Leads.checkForAndConvertLeads(newLeads);
    }
}