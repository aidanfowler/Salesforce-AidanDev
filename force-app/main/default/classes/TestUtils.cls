@isTest
public without sharing class TestUtils {

    public static Knowledge__kav createArticle(Map<SObjectField, Object> fieldMapping, Boolean ins) {
        Knowledge__kav article = new Knowledge__kav();

        if(fieldMapping != null) {
            for(SObjectField field : fieldMapping.keySet()) {
                article.put(field, fieldMapping.get(field));
            }
        }
        
        if(ins) {
            insert article;
        }

        return article;
    }

    public static Knowledge__DataCategorySelection createDataCategorySelection(Map<SObjectField, Object> fieldMapping, Id articleId, Boolean ins) {
        Knowledge__DataCategorySelection dataCatSelection = new Knowledge__DataCategorySelection();
        dataCatSelection.ParentId = articleId;

        if(fieldMapping != null) {
            for(SObjectField field : fieldMapping.keySet()) {
                dataCatSelection.put(field, fieldMapping.get(field));
            }
        }
        
        if(ins) {
            insert dataCatSelection;
        }

        return dataCatSelection;
    }

    public static Recently_Viewed_Article__c createRecentlyViewedArticle(Map<SObjectField, Object> fieldMapping, Id articleId, Id userId, Boolean ins) {
        Recently_Viewed_Article__c rva = new Recently_Viewed_Article__c();
        rva.Article__c = articleId;
        rva.User__c = userId;

        if(fieldMapping != null) {
            for(SObjectField field : fieldMapping.keySet()) {
                rva.put(field, fieldMapping.get(field));
            }
        }
        
        if(ins) {
            insert rva;
        }

        return rva;
    }

    public static Account createAccount(Map<SObjectField, Object> fieldMapping, String name, Boolean ins) {
        Account acc = new Account();
        acc.Name = name;

        if(fieldMapping != null) {
            for(SObjectField field : fieldMapping.keySet()) {
                acc.put(field, fieldMapping.get(field));
            }
        }
        
        if(ins) {
            insert acc;
        }

        return acc;
    }

    public static Contact createContact(Map<SObjectField, Object> fieldMapping, Id accountId, Boolean ins) {
        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.AccountId = accountId;

        if(fieldMapping != null) {
            for(SObjectField field : fieldMapping.keySet()) {
                con.put(field, fieldMapping.get(field));
            }
        }
        
        if(ins) {
            insert con;
        }

        return con;
    }

    public static User createSiteUser( String email, Id contactId, Id profileId, Boolean isActive, Boolean insertData) {
        User u = new User();
        u.LastName = 'TestLastName';
        u.Username = email;
        u.Email = email;
        u.Alias = 'talias';
        u.TimeZoneSidKey = 'America/New_York';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = profileId;
        u.LanguageLocaleKey = 'en_US';
        u.ContactId = contactId;
        u.isActive = isActive;
        
        if (insertData) insert u;
        return u;
    }
}