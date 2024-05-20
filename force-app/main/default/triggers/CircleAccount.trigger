trigger CircleAccount on Circle_Account__c (after insert, after update, before insert, before update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CircleAccountTriggerHandler.handleAfterInsert(Trigger.newMap);
        }
        else if(Trigger.isUpdate){
            CircleAccountTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    else if(Trigger.isBefore){
        if(Trigger.isInsert){
            CircleAccountTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate){
            CircleAccountTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}