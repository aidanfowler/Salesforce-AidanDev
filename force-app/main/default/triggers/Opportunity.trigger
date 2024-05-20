trigger Opportunity on Opportunity (before update, before insert, after update, after insert) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            OpportunityTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isInsert){
            OpportunityTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    }
    else if (Trigger.isAfter){
        if(Trigger.isUpdate){
            OpportunityTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isInsert){
            OpportunityTriggerHandler.handleAfterInsert(Trigger.newMap);
        }
    }

}