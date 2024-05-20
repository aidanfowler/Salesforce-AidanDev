public with sharing class CircleAccountTriggerHandler {

    public static void handleAfterInsert(Map<Id, Circle_Account__C> newCircleAccounts){
        CircleAccounts.rollUpToAccountLevel(newCircleAccounts,null);
        CircleAccounts.rollUpAccountMetrics(newCircleAccounts,null);
        CircleAccounts.rollUpToLeadLevel(newCircleAccounts, null);
    }

    public static void handleAfterUpdate(Map<Id, Circle_Account__c> newCircleAccounts, Map<Id, Circle_Account__c> oldCircleAccounts){
        CircleAccounts.rollUpToAccountLevel(newCircleAccounts, oldCircleAccounts);
        CircleAccounts.rollUpAccountMetrics(newCircleAccounts,oldCircleAccounts);
        CircleAccounts.rollUptoLeadLevel(newCircleAccounts, oldCircleAccounts);
    }

    public static void handleBeforeInsert(List<Circle_Account__c> newAccounts){
        CircleAccounts.setRegionFromCountry(newAccounts);
    }

    public static void handleBeforeUpdate(Map<Id, Circle_Account__c> newCircleAccounts, Map<Id, Circle_Account__c> oldCircleAccounts){
        CircleAccounts.setRegionFromCountry(newCircleAccounts, oldCircleAccounts);
    }
}