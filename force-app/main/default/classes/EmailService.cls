public class EmailService {

    public static void sendErrorEmail(String toAddress, String subject, Exception e){
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = 'noreply@circle.com'];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {toAddress};
        message.subject = subject;
        if ( owea.size() > 0 ) {
            message.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        if(e != null){
            if(e.getMessage().contains('ConvertLead failed. First exception on row 0; first error: INACTIVE_OWNER_OR_USER, Record owner cannot be an inactive user.: []')){
                String messagetext = 'ConvertLead Failed Due To Inactive User: ';
                Integer ownerIndex = e.getMessage().indexOf('OwnerId=');
                if(ownerIndex != -1){
                    String ownerId = e.getMessage().substring(ownerIndex+8,ownerIndex+26);
                    User inactiveUser = [SELECT FirstName, LastName, Profile.name FROM User WHERE ID = :ownerId];
                    messagetext = messagetext + inactiveUser.FirstName + ' ' + inactiveUser.lastName + ' ID: '+ownerId +' Profile: '+inactiveUser.Profile.Name;
                }
                message.plaintextbody = messagetext;
            }
            else{
                message.plaintextbody = e.getMessage() + '\n' + e.getStackTraceString();
            }
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }

    public static void blockOutboundEmailsForDataRemovalContacts(List<EmailMessage> newEmails){
        List<EmailMessage> relevantEmails = new List<EmailMessage>();
        Set<String> toAddresses = new Set<String>();
        Set<Id> caseIds = new Set<Id>();
        Set<String> blockedEmails = new Set<String>();
        for(EmailMessage email : newEmails){
            if(email.Incoming == false){
                relevantEmails.add(email);
                //emails from the case feed
                if(email.parentId != null){
                    if(String.valueOf(email.parentId).left(3)=='500'){
                        caseIds.add(email.parentId);
                    }
                }
                //emails based on address for other situations
                if(email.toAddress != null){
                    toAddresses.add(email.toAddress);
                }
            }
        }
        if(caseIds.size()>0){
            List<Case> caseWithContact = CaseDAO.getCasesWithBlockedContactEmails(caseIds);
            caseIds.clear();
            for(Case theCase : caseWithContact){
                caseIds.add(theCase.id);
            }
        }
        if(toAddresses.size()>0){
            List<Contact> blockedContacts = ContactDAO.getBlockedContactsByEmail(toAddresses);
            for(Contact contact : blockedContacts){
                blockedEmails.add(contact.email);
            }
        }
        for(EmailMessage email : relevantEmails){
            if(caseIds.contains(email.parentId) || blockedEmails.contains(email.ToAddress)){
                email.addError('You can not send an outbound email to a contact who has requested their data be deleted');
            }
        }
    }
}