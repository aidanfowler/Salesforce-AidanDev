public without sharing class SubmitATicketController {
    private static String POST_METHOD = 'POST';

    public static Boolean hasError = false;

        
    @AuraEnabled
    public static String insertRecord(SObject record, String recaptchaResponse){

        String resultString;

        try {

            if(hasError) {
                throw new AuraHandledException('Test error');
            }

            Support_Settings__c supportSettings = getSupportSettings();

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(supportSettings.reCaptcha_Endpoint__c);
            request.setMethod(POST_METHOD);
            request.setBody('secret=' + supportSettings.reCaptcha_Secret_Key__c + '&response=' + recaptchaResponse);
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                if (result.containsKey('success') && result.get('success') == true) {
                    if (result.containsKey('score')) {
                        //score logic is only needed/returned for v3 (0.0 - 1.0)
                        //https://developers.google.com/recaptcha/docs/v3
                        //TODO: verify action name for the request
                        String action = (String)result.get('action');
                        //TODO: get threshold configuration for each action
                        Decimal threshold = .4;
                        Decimal score = (Decimal)result.get('score');
                        if (score > threshold) {
                            
                            resultString = 'Success - v3';
                        }
                    } else {
                        
                        resultString = 'Success - v2';
                    }
                } else {
                    resultString = 'Invalid Verification';
                }
            }
            //consider letting this through
            resultString = 'Invalid Verification Request';
        }
        catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());

            throw exc;
        }

        return resultString;
    }

    @AuraEnabled(cacheable=true)
    public static String getEmailAddress() {

        String emailAddress;

        try {

            if(hasError) {
                throw new AuraHandledException('Test error');
            }

            if(UserInfo.getUserType() != 'Guest') {
                emailAddress = UserInfo.getUserEmail();
            }
        }
        catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());

            throw exc;
        }

        return emailAddress;
    }

    @AuraEnabled(cacheable=true)
    public static String getContactId(Id userId) {

        Id contactId;

        try {

            if(hasError) {
                throw new AuraHandledException('Test error');
            }

            if(userId != null) {
                contactId = [Select ContactId from User where Id = :userId]?.ContactId;
            }
        }
        catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());

            throw exc;
        }

        return contactId;
    }

    @AuraEnabled
    public static String getArticleTitle(Id articleId) {

        String title;

        try {

            if(hasError) {
                throw new AuraHandledException('Test error');
            }
            
            title = [Select Title from Knowledge__kav where Id = :articleId or KnowledgeArticleId = :articleId]?.Title;
        }
        catch(Exception e) {
            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());

            throw exc;
        }

        return title;
    }

    @AuraEnabled
    public static String getArticleMainCategory(Id articleId) {
        String mainCategory = '';

        try {
            // Get the SubCategories
            List<DataCategory> subcategories = DataCategoryHelper.getAllSubCategories(DataCategoryHelper.DATA_CATEGORY_GROUP);

            Knowledge__kav article = [Select Id, Title, LastPublishedDate, Summary, (SELECT Id, DataCategoryName, DataCategoryGroupName FROM DataCategorySelections) from Knowledge__kav where Id = :articleId];

            // Loop through the Article categories.
            for(Knowledge__DatacategorySelection categorySelection : article.DataCategorySelections) {
                mainCategory = categorySelection.DataCategoryName +';'+categorySelection.DataCategoryGroupName;
                Boolean found = false;
                for(DataCategory category : subcategories) {
                    // Set the main Category name
                    if(category.getName() == categorySelection.DataCategoryName) {
                        mainCategory =  category.getName();
                        found = true;
                        break;
                    }
                    // Get Child Categories of the Sub Categories.
                    List<DataCategory> subCats = category.getChildCategories();
                    for(DataCategory subCat : subCats) {
                        
                        // If the Sub Category matches the DataCategory
                        if(subCat.getName() == categorySelection.DataCategoryName) {
                            mainCategory=category.getName();
                            found = true;
                            break;
                        }
                    }
                    if(found) {
                        break;
                    }
                }
                if(found) {
                    break;
                }
            }
            
        } catch (Exception e) {

            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());

            AuraHandledException auraExc = new AuraHandledException(e.getMessage());
            auraExc.setMessage(e.getMessage());
            throw auraExc;
        }


        return mainCategory;
    }

    @AuraEnabled(cacheable=true)
    public static Support_Settings__c getSupportSettings() {

        return Support_Settings__c.getInstance();
    }
}