@isTest
public without sharing class CategoryMenuControllerTest {
    
    @isTest    
    static void testGetSupportCategories() {
        
        Test.startTest();

            List<CategoryWrapper> wrappers = CategoryMenuController.getSupportCategories(false);

            System.assert(wrappers.size() > 0, 'There should be categories.');

        Test.stopTest();
    }

    @isTest    
    static void testError() {

        CategoryMenuController.testError = true;
        Boolean errorFound = false;
        
        Test.startTest();

            try {

                List<CategoryWrapper> wrappers = CategoryMenuController.getSupportCategories(false);

            }
            catch(Exception e) {
                errorFound = true;
            }   

            System.assertEquals(true, errorFound, 'There should have been an error thrown.');

        Test.stopTest();
    }
}