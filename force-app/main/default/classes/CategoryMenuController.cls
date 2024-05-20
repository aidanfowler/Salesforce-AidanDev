public without sharing class CategoryMenuController {

    public static Boolean testError = false;

    @AuraEnabled(cacheable=true)
    public static List<CategoryWrapper> getSupportCategories(Boolean checkingSuggestedArticles) {

        List<CategoryWrapper> wrappers = new List<CategoryWrapper>();

        try {
            // Get the Support Categories from the MetaData.
            for(Support_Category__mdt supportCategory : DataCategoryHelper.getSupportCategories(SiteUtils.isGated(), checkingSuggestedArticles)) {

                CategoryWrapper cWrapper = new CategoryWrapper();
                cWrapper.name = supportCategory.API_Name__c;
                cWrapper.label = supportCategory.Label;
                cWrapper.order = Integer.valueOf(supportCategory.Order__c);
                cWrapper.icon = supportCategory.Icon__c;

                wrappers.add(cWrapper);
            }

            if(testError) {
                throw new AuraHandledException('Test error');
            }
        }
        catch(Exception e) {

            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());

            AuraHandledException exc = new AuraHandledException(e.getMessage());
            exc.setMessage(e.getMessage());
            throw exc;
        }

        return wrappers;
    }
}