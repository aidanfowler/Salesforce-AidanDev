@isTest
public with sharing class DataCategoryHelperTest {
    
    @isTest
    static void testGetTopLevelCategoryMap() {

        Test.startTest();

            Map<String, String> categoryMap = DataCategoryHelper.getTopLevelCategoryMap();

            System.assert(categoryMap.size() > 0, 'There should be data in the map.');

        Test.stopTest();
    }

    @isTest
    static void testGetAllSubCategories() {

        Test.startTest();

            List<DataCategory> subCategories = DataCategoryHelper.getAllSubCategories('Help_Center');

            System.assert(subCategories.size() > 0, 'There should be subcategories.');

        Test.stopTest();
    }

    @isTest
    static void testGetSubCategories() {

        Test.startTest();

            List<DataCategory> subCategories = DataCategoryHelper.getSubCategories('Help_Center', 'Getting_Started');

            System.assert(subCategories.size() > 0, 'There should be subcategories.');

        Test.stopTest();
    }

    @isTest
    static void testGetSupportCategoriesNotGated() {

        Test.startTest();

            List<Support_Category__mdt> supportCategories = DataCategoryHelper.getSupportCategories(false, false);

            System.assert(supportCategories.size() > 0, 'There should be support categories.');

            for(Support_Category__mdt supportCategory : supportCategories) {
                System.assertEquals(false, supportCategory.Gated__c, 'The article is not gated.');
            }

        Test.stopTest();
    }

    @isTest
    static void testGetSupportCategoriesNotGatedSuggested() {

        Test.startTest();

            List<Support_Category__mdt> supportCategories = DataCategoryHelper.getSupportCategories(false, true);

            System.assert(supportCategories.size() > 0, 'There should be support categories.');

            for(Support_Category__mdt supportCategory : supportCategories) {
                System.assertEquals(true, supportCategory.Has_Suggested_Articles__c, 'The article is suggested.');
            }

        Test.stopTest();
    }

    @isTest
    static void testGetSupportCategoriesGated() {

        Test.startTest();

            List<Support_Category__mdt> supportCategories = DataCategoryHelper.getSupportCategories(true, false);

            System.assert(supportCategories.size() > 0, 'There should be support categories.');

        Test.stopTest();
    }
}