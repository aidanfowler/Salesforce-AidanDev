public class InvokeCreateChildCaseLinkEmail {
    
    @InvocableMethod(label='Create Child Case Attach Email' description='Used in update case status - AS to create child case and clone email that triggered the case to be created')
    public static void createChildCaseLinkEmail(List<InputVariables> inputVariables) {
        Id queueId = inputVariables.get(0).caseQueueId;
        EmailMessage emailToClone = inputVariables.get(0).triggeringEmail;
        EmailMessage clonedEmail = emailToClone.clone(false, true);
        Case parentCase = inputVariables.get(0).parentCase;
        Case childCase = parentCase.clone(false,true);
        childCase.ownerId = queueId;
        childCase.parentId = parentCase.id;
        childCase.status = 'New';
        childCase.First_Response_Date__c = null;
        childCase.Send_Survey__c = false;
        childCase.Survey_Send_Completion_Date_Time__c = null;
        childCase.Survey_Send_Attempt_Date_Time__c = null;
        Savepoint sp = Database.setSavepoint();
        try{
            insert childCase;
            clonedEmail.parentId = childCase.id;
            clonedEmail.clonedToChildCase__c = true;
            insert clonedEmail;
        }
        catch(Exception e){
            Database.rollback(sp);
            CircleException ce = new CircleException('Child Case Creation Error');
            ce.setMessage(e.getMessage() + '\n' + 'Input Variables To Invokable Action: '+String.valueOf(inputVariables));
            EmailService.sendErrorEmail('aidan.fowler@circle.com', 'Invoke create child case email failure:', ce);
        }
    }

    public class InputVariables{
        @InvocableVariable
        public Id caseQueueId;

        @InvocableVariable
        public EmailMessage triggeringEmail;

        @InvocableVariable
        public Case parentCase;
    }
}