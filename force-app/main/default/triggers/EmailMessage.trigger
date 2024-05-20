trigger EmailMessage on EmailMessage (before insert, after insert) {
    try{
        if(Trigger.isInsert && Trigger.isBefore){
            EmailMessageTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    }
    catch(Exception e){
        CircleException ce = new CircleException('Email Message Error');
        ce.setMessage(e.getMessage() +'\n'+ e.getStackTraceString());
        EmailService.sendErrorEmail('aidan.fowler@circle.com', 'Email Message Error: ', ce);
        throw ce;
    }
}