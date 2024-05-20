trigger PartnershipObjective on Partnership_Objective__c (before insert, after insert, before update, after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            PartnershipObjectiveTriggerHandler.handleAfterInsert(Trigger.newMap);
        }
        else if(Trigger.isUpdate){
            PartnershipObjectiveTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    else if(Trigger.isBefore){
        if(Trigger.isUpdate){
            PartnershipObjectiveTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isInsert){
            PartnershipObjectiveTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    }
}