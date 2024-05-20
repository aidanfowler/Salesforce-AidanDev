public with sharing class SiteUtils {
    
    public static final String GUEST_USER_TYPE = 'Guest';
    public static final String STANDARD_USER_TYPE = 'Standard';

    public static String USER_TYPE = UserInfo.getUserType();

    public static Boolean isGuestUser() {
        return USER_TYPE == GUEST_USER_TYPE;
    }

    public static Boolean isStandardUser() {
        return USER_TYPE == STANDARD_USER_TYPE;
    }

    public static Boolean isCommunityUser() {
        return USER_TYPE != GUEST_USER_TYPE && USER_TYPE != STANDARD_USER_TYPE;
    }

    public static Boolean isGated() {
        return USER_TYPE != GUEST_USER_TYPE;
    }

    public static Boolean isLoggedIn() {
        return USER_TYPE != GUEST_USER_TYPE;
    }
}