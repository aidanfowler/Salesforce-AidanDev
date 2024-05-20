@isTest
public with sharing class SiteUtilsTest {
    
    @isTest
    static void testIsGuestUser() {
        SiteUtils.USER_TYPE = 'Guest';

        System.assertEquals(true, SiteUtils.isGuestUser(), 'This should be a guest user.');
    }

    @isTest
    static void testIsStandardUser() {
        SiteUtils.USER_TYPE = 'Standard';

        System.assertEquals(true, SiteUtils.isStandardUser(), 'This should be a standard user.');
    }

    @isTest
    static void testIsCommunityUser() {
        SiteUtils.USER_TYPE = 'Community';

        System.assertEquals(true, SiteUtils.isCommunityUser(), 'This should be a community user.');
    }

    @isTest
    static void testIsLoggedInUser() {
        SiteUtils.USER_TYPE = 'Standard';

        System.assertEquals(true, SiteUtils.isLoggedIn(), 'This user should be logged in.');
    }
}