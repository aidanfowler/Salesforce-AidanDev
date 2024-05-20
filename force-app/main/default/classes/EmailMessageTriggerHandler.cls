public class EmailMessageTriggerHandler {

    public static void handleBeforeInsert(List<EmailMessage> newEmails){
        EmailService.blockOutboundEmailsForDataRemovalContacts(newEmails);
    }  
}