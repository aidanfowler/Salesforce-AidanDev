trigger ContentVersion on ContentVersion (after insert, after update) {

    if(Trigger.isAfter){
        if(trigger.isInsert){
            ContentVersionTriggerHandler.handleAfterInsert(Trigger.newMap);
        }
        else if (trigger.isUpdate){
            ContentVersionTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}