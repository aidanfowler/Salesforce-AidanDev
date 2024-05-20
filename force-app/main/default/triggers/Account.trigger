trigger Account on Account (before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        AccountTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}