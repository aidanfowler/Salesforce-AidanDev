public class Contacts {

    public static void blockDuplicateContactsByEmail(List<Contact> newContacts){
        //temp fix for six sense integration user while lead conversion is in need of refactoring 
        if(UserInfo.getUserId() != '0058b00000FQW4oAAH' && UserInfo.getUserId() != '0058b00000GIoMRAA1' && (UserInfo.getUserId() != '0058b00000GJaWiAAL' || Test.isRunningTest())){
            Set<String> emailsToCheck = new Set<String>();
            for(Contact contact : newContacts){
                if(contact.Email != null){
                    emailsToCheck.add(contact.Email);
                }
            }
            if(emailsToCheck.size()>0){
                List<Contact> matchingContacts = ContactDAO.getContactsByEmail(emailsToCheck);
                if(matchingContacts.size()>0){
                    Set<String> matchingEmails = new Set<String>();
                    for(Contact contact : matchingContacts){
                        matchingEmails.add(contact.Email);
                    }
                    for(Contact contact : newContacts){
                        if(matchingEmails.contains(contact.Email)){
                            contact.addError('Running User: '+UserInfo.getUserId()+' There is a duplicate contact in the system with email: '+contact.Email + ' please link existing contact instead of creating / updating this one');
                        }
                    }
                }
            }
        }
    }

    public static void blockDuplicateContactsByEmail(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        List<Contact> contactsToCheck = new List<Contact>();
        for(Id id : newContacts.keySet()){
            if(newContacts.get(id).Email != oldContacts.get(id).Email && newContacts.get(id).Email != null){
                contactsToCheck.add(newContacts.get(id));
            }
        }
        if(contactsToCheck.size()>0){
            blockDuplicateContactsByEmail(contactsToCheck);
        }
    }

    public static void contactDataDeletionRequest(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        Set<String> ignoreFields = new Set<String>{'OwnerId', 'Email','Data_Deleted_Customer_Request__c'};
        Set<String> requiredFieldsToClear = new Set<String>{'FirstName', 'LastName'};
        Map<String, SObjectField> contactFieldMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        Set<Id> contactsToClear = new Set<Id>();
       
        for(Id id : newContacts.keySet()){
            if(newContacts.get(id).Data_Deleted_Customer_Request__c == true && oldContacts.get(id).Data_Deleted_Customer_Request__c == false){
                contactsToClear.add(id);
            }
        }
        if(contactsToClear.size()>0){
            List<AccountContactRelation> deleteIndirectRelationships = AccountDAO.getAccountContactRelationsByContacts(newContacts.keyset());
            if(deleteIndirectRelationships != null && deleteIndirectRelationships.size()>0){
                delete deleteIndirectRelationships;
            }
            for(Id id : contactsToClear){
                Map<String, Object> fields = newContacts.get(id).getPopulatedFieldsAsMap();
                for (String field : fields.keySet()){
                    if (!ignoreFields.contains(field) && !field.contains('__r') && newContacts.get(id).get(field)!=null && contactFieldMap.get(field).getDescribe().isUpdateable()){
                        if(contactFieldMap.get(field).getDescribe().getType() == Schema.DisplayType.Boolean){
                            newContacts.get(id).put(field, false);
                        }
                        else if(requiredFieldsToClear.contains(field)){
                            newContacts.get(id).put(field,'Data Deleted');
                        }
                        else{
                            newContacts.get(id).put(field, null);
                        }
                    }
                    else if(field.contains('Email') && newContacts.get(id).Email != null && !newContacts.get(id).Email.contains('data_deleted_')){
                        newContacts.get(id).Email = 'data_deleted_'+newContacts.get(id).Email;
                    }
                }
            }
        }
    }
}