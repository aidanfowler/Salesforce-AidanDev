trigger ContentDocument on ContentDocument (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        ContentDocumentLinkTriggerHandler.handleBeforeDelete(Trigger.oldMap);
    }
}