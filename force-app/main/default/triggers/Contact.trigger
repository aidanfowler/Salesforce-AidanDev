trigger Contact on Contact (before insert, after insert, before update, after update) {
    
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            ContactTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        else if(Trigger.isAfter){
            ContactTriggerHandler.handleAfterInsert(Trigger.newMap);
        }
    }
    else if(Trigger.isUpdate){
        if(Trigger.isBefore){
            ContactTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isAfter){
            ContactTriggerHandler.handleAfterUpdate(Trigger.newMap,Trigger.oldMap);
        }
    }
}