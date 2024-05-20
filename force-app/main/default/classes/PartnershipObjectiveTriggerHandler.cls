public with sharing class PartnershipObjectiveTriggerHandler {

    public static void handleBeforeInsert(List<Partnership_Objective__c> newObjectives){
        PartnershipObjectives.recalculatePORollUpFields(newObjectives);
    }
    public static void handleAfterInsert(Map<Id, Partnership_Objective__c> newObjectives){
        PartnershipObjectives.recalculateAccountRollUpFields(newObjectives, null);
    }

    public static void handleBeforeUpdate(Map<Id, Partnership_Objective__c> newObjectives, Map<Id, Partnership_Objective__c> oldObjectives){
        PartnershipObjectives.setMostRecentNoteHistory(newObjectives, oldObjectives);
        PartnershipObjectives.recalculatePORollUpFields(newObjectives, oldObjectives);
    }
    public static void handleAfterUpdate(Map<Id, Partnership_Objective__c> newObjectives, Map<Id, Partnership_Objective__c> oldObjectives){
        PartnershipObjectives.recalculateAccountRollUpFields(newObjectives, oldObjectives);
    }  
}