public with sharing class OpportunityTriggerHandler {

    public static void handleBeforeUpdate(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        Opportunities.validateCSMBeforeClosedWon(newOpps, oldOpps);
        Opportunities.validateProductSelection(newOpps, oldOpps);
        Opportunities.validateAccountingApplicabilityDuringPricingApproval(newOpps, oldOpps);
        Opportunities.revertStageToDiscoverIfProductsChanged(newOpps, oldOpps);
        Opportunities.copyNextStepIntoNextSteps(newOpps, oldOpps);
        Opportunities.setAccountingImpact(newOpps, oldOpps);
        Opportunities.setDateStageEnteredFields(newOpps, oldOpps);
        Opportunities.recallOpenApprovalRequestsUponClosedLost(newOpps, oldOpps);
    }

    public static void handleBeforeInsert(List<Opportunity> newOpps){
        Opportunities.setAccountingImpact(newOpps);
        Opportunities.setGeneratePartnershipConstruct(newOpps);
    }

    public static void handleAfterUpdate(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        Opportunities.generatePartnershipConstructDoc(newOpps, oldOpps);
        Opportunities.checkIfPOShouldBeDeleted(newOpps,oldOpps);
        Accounts.rollUpLiquidityCoverageUpdates(newOpps, oldOpps);
    }

    public static void handleAfterInsert(Map<Id, Opportunity> newOpps){
        Opportunities.generatePartnershipConstructDoc(newOpps, null);
    }
}