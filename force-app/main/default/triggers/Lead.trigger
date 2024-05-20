trigger Lead on Lead (after insert, after update, before update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            LeadTriggerHandler.handleAfterInsert(Trigger.newMap);
        }
        else if(Trigger.isUpdate){
            LeadTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    if(Trigger.isBefore & Trigger.isUpdate){
        LeadTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}