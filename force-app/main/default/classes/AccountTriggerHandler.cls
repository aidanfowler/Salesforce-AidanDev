public with sharing class AccountTriggerHandler {

    public static void handleBeforeUpdate(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts){
        Accounts.copyMostRecentNotesIntoHistory(newAccounts, oldAccounts);
    }
}