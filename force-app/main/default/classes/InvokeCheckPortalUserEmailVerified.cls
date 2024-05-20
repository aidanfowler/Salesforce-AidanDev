public without sharing class InvokeCheckPortalUserEmailVerified {

    @InvocableMethod(label='CheckIfPortalEmailVerified' description='Check if portal user has verified email')
    public static List<String>  InvokeCheckPortalUserEmailVerified(List<String> portalUserId) {
        List<TwoFactorMethodsInfo> emailinfo = [SELECT Id, UserId, HasUserVerifiedEmailAddress FROM TwoFactorMethodsInfo WHERE  UserID = :portalUserId.get(0) LIMIT 1];
        if(emailinfo.size()>0 && emailinfo.get(0).HasUserVerifiedEmailAddress == false){
            return new List<String>{'False'};
        }
        else if(emailinfo.size()>0 && emailinfo.get(0).HasUserVerifiedEmailAddress == true){
            return new List<String>{'True'};
        }
        else{
            return new List<String>{'No User Found'};
        }
    }
}