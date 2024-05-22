public class Opportunities {

    public static void validatePMBeforeClosedWon(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        Set<Id> oppsToCheck = new Set<Id>();
        for(Id id: newOpps.keyset()){
            String products = String.valueOf(newOpps.get(id).product_s__c);
            if(newOpps.get(id).StageName == 'Closed Won' && oldOpps.get(id).StageName != newOpps.get(id).StageName && (newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c || (newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().ProductIntegrationsOpp__c && (products.contains('CCTP') || products.contains('Bridged USDC Standard') || products.contains('USDC Trading Pairs'))))){
                oppsToCheck.add(id);
            }
        }
        if(oppsToCheck.size()>0){
            List<OpportunityTeamMember> oppTeamMembers = OpportunityDAO.getPMOppTeamMembers(oppsToCheck);
            Map<Id, Id> oppTeamMemberMap = new Map<Id, Id>();
            for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
                oppTeamMemberMap.put(oppTeamMember.opportunityid, oppTeamMember.id);
            }
            for(Id id : oppsToCheck){
                if(oppTeamMemberMap.get(id) == null){
                    newOpps.get(id).addError('You must add a PM to the opportunity team beforce closing this opportunity');
                }
            }
        }
    }

    public static void validateProductSelection(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        if(UserInfo.getProfileId() != Profiles__c.getInstance().System_Admin__c && UserInfo.getProfileId() != Profiles__c.getInstance().System_Admin_Integration__c){
            for(Id id : newOpps.keySet()){
                if(newOpps.get(id).StageName != oldOpps.get(id).StageName && newOpps.get(id).Product_s__c != null && newOpps.get(id).StageName != 'Closed Lost' && (newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().RenewalOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().ProductIntegrationsOpp__c)){
                    Boolean invalidProduct = false;
                    for(String product : newOpps.get(id).product_s__c.split(';')){
                        if(!CircleUtils.validProducts.contains(product)){
                            invalidProduct = true;
                        }
                    }
                    if(invalidProduct){
                        newOpps.get(id).addError('Error: You have a product selected which is not in the product book, please correct the selected product(s) to a valid option');
                    }
                }
            }
        }
    }

    public static void revertStageToDiscoverIfProductsChanged(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        for(Id id : newOpps.keyset()){
            if(newOpps.get(id).Products_Selected__C != null && (newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().RenewalOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().ProductIntegrationsOpp__c)){
                Boolean needsReversion = false;
                List<String> newProducts = newOpps.get(id).Products_Selected__C.split(';');
                if(oldOpps.get(id).Products_Selected__C == null){
                    needsReversion = true;
                }
                else{
                    List<String> oldProducts = oldOpps.get(id).Products_Selected__C.split(';');
                    for(String product : newProducts){
                        if(!oldProducts.contains(product)){
                            needsReversion = true;
                        }
                    }
                }
                if(needsReversion){
                    newOpps.get(id).Bypass_Stage_Validation__c = true;
                    newOpps.get(id).StageName = 'Discover';
                    newOpps.get(id).Product_Approval_Status__C = 'Not Started';
                    newOpps.get(id).Kash_Product_Approval_Status__C = 'Not Started';
                    newOpps.get(id).Pricing_Approval_Status__c = 'Not Started';
                    newOpps.get(id).DRG_approval_Status__C = 'Not Started';
                    newOpps.get(id).Compliance_State__c = null;
                    newOpps.get(id).Compliance_Approval_Status__c = 'Not Started';
                    newOpps.get(id).Contract_Request_Status__c = 'Not Started';
                    newOpps.get(id).Compliance_Analyst__c = null;

                }
            }
        }
    }

    public static void validateAccountingApplicabilityDuringPricingApproval(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        if(UserInfo.getProfileId() != Profiles__c.getInstance().System_Admin__c && UserInfo.getProfileId() != Profiles__c.getInstance().System_Admin_Integration__c){
            for(Id id : newOpps.keyset()){
                String error = '';
                if(newOpps.get(id).Pricing_approval_status__c == 'Approved' && oldOpps.get(id).Pricing_approval_status__c != 'Approved' && (newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().RenewalOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().ProductIntegrationsOpp__c)){
                    if(newOpps.get(id).Accounting_Impact__c == null){
                        error += 'The pricing team must populate the Accounting Impact field before approving & ';
                    }
                    if((newOpps.get(id).Pricing_Matrix__c == null || newOpps.get(id).Stablecoin_Custody__C == null || newOpps.get(id).Weighted_Margin_to_Circle__c == null || newOpps.get(id).Bps_on_Volume_Payment__c == null) && (newOpps.get(id).Products_Selected__c.contains('Performance Incentives'))){
                        error += ' The Pricing Matrix, Stablecoin Custody, Weighted Margin % & Bps On Volume must be populated for all Performance Incentives';
                    }
                    error = error.removeEnd('& ');
                    if(error != ''){
                        newOpps.get(id).addError(error);
                    }
                }
            }
        }
    }

    public static void copyNextStepIntoNextSteps(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        for(Id id : newOpps.keyset()){
            if(newOpps.get(id).NextStep != oldOpps.get(id).NextStep){
                newOpps.get(id).Next_Steps__c = '('+String.valueOf(Date.today()) +') : '+ newOpps.get(id).NextStep + '<br/><br/>' + newOpps.get(id).Next_Steps__c;
            }
        }
    }

    public static void setAccountingImpact(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        List<Opportunity> relevantOpps = new List<Opportunity>();
        for(Id id : newOpps.keySet()){
            if(newOpps.get(id).Product_s__c != oldOpps.get(id).Product_s__c){
                relevantOpps.add(newOpps.get(id));
            }
        }
        if(relevantOpps.size()>0){
            setAccountingImpact(relevantOpps);
        }
    }

    public static void setAccountingImpact(List<Opportunity> newOpps){
        for(Opportunity opp : newOpps){
            Boolean pricingTeam = false;
            Boolean accountsPayable = false;
            Boolean accountsReceivable = false;
            Boolean notApplicable = false;
            for(String product : opp.Product_s__c.split(';')){
                if(CircleUtils.pricingTeamProducts.contains(product)){
                    pricingTeam = true;
                }
                else if(CircleUtils.accountsPayableProducts.contains(product)){
                    accountsPayable = true;
                }
                else if(CircleUtils.accountsReceivableProducts.contains(product)){
                    accountsReceivable = true;
                }
                else if(CircleUtils.noImpactProducts.contains(product)){
                    notApplicable = true;
                }
            }
            if(pricingTeam){
                opp.Accounting_Impact__c = null;
            }
            else if(accountsPayable && accountsReceivable){
                opp.Accounting_Impact__c = 'Both';
            }
            else if(accountsPayable){
                opp.Accounting_Impact__c = 'Accounts Payable';
            }
            else if (accountsReceivable){
                opp.Accounting_Impact__c = 'Accounts Receivable';
            }
            else if (notApplicable){
                opp.Accounting_Impact__c = 'Not Applicable';
            }
        }
    }

    public static void setDateStageEnteredFields(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        for(id id : newOpps.keySet()){
            String newStage = newOpps.get(id).StageName;
            String oldStage = oldOpps.get(id).StageName;
            if(newStage != oldStage && (newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().RenewalOpp__c || newOpps.get(id).RecordTypeId == RecordTypeIds__c.getInstance().ProductIntegrationsOpp__c)){
                DateTime now = dateTime.now();
                Integer newStageNumber = CircleUtils.stageOrderMap.get(newStage);
                Integer oldStageNumber = CircleUtils.stageOrderMap.get(oldStage);
                if(newOpps.get(id).StageName == 'Closed Lost'){
                    newOpps.get(id).Date_Closed_Lost_Stage_Entered__c = dateTime.now();
                    newOpps.get(id).Date_Closed_Won_Stage_Entered__c = null;
                }
                else if(newStageNumber > oldStageNumber){
                    if(newStage == 'Solution'){
                        newOpps.get(id).Date_Solution_Stage_Entered__c = now;
                    }
                    else if(newStage == 'Approvals'){
                        newOpps.get(id).Date_Approvals_Stage_Entered__c = now;
                        if(newOpps.get(id).Date_Solution_Stage_Entered__c == null){
                            newOpps.get(id).Date_Solution_Stage_Entered__c = now;
                        }
                    }
                    else if(newStage == 'Negotiate'){
                        newOpps.get(id).Date_Negotiate_Stage_Entered__c = now;
                        if(newOpps.get(id).Date_Approvals_Stage_Entered__c ==null){
                            newOpps.get(id).Date_Approvals_Stage_Entered__c = now;
                        }
                        if(newOpps.get(id).Date_Solution_Stage_Entered__c == null){
                            newOpps.get(id).Date_Solution_Stage_Entered__c = now;
                        }
                    }
                    else if(newStage == 'Contract'){
                        newOpps.get(id).Date_Contract_Stage_Entered__c = now;
                        if(newOpps.get(id).Date_Negotiate_Stage_Entered__c == null){
                            newOpps.get(id).Date_Negotiate_Stage_Entered__c = now;
                        }
                        if(newOpps.get(id).Date_Approvals_Stage_Entered__c ==null){
                            newOpps.get(id).Date_Approvals_Stage_Entered__c = now;
                        }
                        if(newOpps.get(id).Date_Solution_Stage_Entered__c == null){
                            newOpps.get(id).Date_Solution_Stage_Entered__c = now;
                        }
                    }
                    else if(newStage == 'Closed Won'){
                        newOpps.get(id).Date_Closed_Won_Stage_Entered__c = now;
                        if(newOpps.get(id).Date_Contract_Stage_Entered__c == null){
                            newOpps.get(id).Date_Contract_Stage_Entered__c = now;
                        }
                        if(newOpps.get(id).Date_Negotiate_Stage_Entered__c == null){
                            newOpps.get(id).Date_Negotiate_Stage_Entered__c = now;
                        }
                        if(newOpps.get(id).Date_Approvals_Stage_Entered__c ==null){
                            newOpps.get(id).Date_Approvals_Stage_Entered__c = now;
                        }
                        if(newOpps.get(id).Date_Solution_Stage_Entered__c == null){
                            newOpps.get(id).Date_Solution_Stage_Entered__c = now;
                        }
                    }
                }
                else if(newStageNumber < oldStageNumber){
                    if(newStage == 'Discover'){
                        newOpps.get(id).Date_Solution_Stage_Entered__c = null;
                        newOpps.get(id).Date_Approvals_Stage_Entered__c = null;
                        newOpps.get(id).Date_Negotiate_Stage_Entered__c = null;
                        newOpps.get(id).Date_Contract_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Won_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Lost_Stage_Entered__c = null;
                    }
                    else if(newStage == 'Solution'){
                        newOpps.get(id).Date_Approvals_Stage_Entered__c = null;
                        newOpps.get(id).Date_Negotiate_Stage_Entered__c = null;
                        newOpps.get(id).Date_Contract_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Won_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Lost_Stage_Entered__c = null;
                    }
                    else if(newStage == 'Approvals'){
                        newOpps.get(id).Date_Negotiate_Stage_Entered__c = null;
                        newOpps.get(id).Date_Contract_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Won_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Lost_Stage_Entered__c = null;
                    }
                    else if(newStage == 'Negotiate'){
                        newOpps.get(id).Date_Contract_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Won_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Lost_Stage_Entered__c = null;
                    }
                    else if(newStage == 'Contract'){
                        newOpps.get(id).Date_Closed_Won_Stage_Entered__c = null;
                        newOpps.get(id).Date_Closed_Lost_Stage_Entered__c = null;
                    }
                    else if(newStage == 'Closed Won'){
                        newOpps.get(id).Date_Closed_Won_Stage_Entered__c = now;
                        newOpps.get(id).Date_Closed_Lost_Stage_Entered__c = null;
                    }
                }
            }
        }
    }

    public static void recalculateAttachmentCounts(Set<Id> relevantOpportunityIds){
        List<Opportunity> opps = OpportunityDAO.getOpportunitiesWithAttachmentCount(relevantOpportunityIds);
        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkDAO.getContentDocumentsByRecord(relevantOpportunityIds);
        Map<Id, List<ContentDocumentLink>> oppToContentDocumentMap = new Map<Id, List<ContentDocumentLink>>();
        for(ContentDocumentLink cdl : contentDocumentLinks){
            if(cdl.ContentDocument.FileType != 'SNOTE'){
                if(oppToContentDocumentMap.get(cdl.LinkedEntityID)==null){
                    oppToContentDocumentMap.put(cdl.LinkedEntityID,new List<ContentDocumentLink>());
                }
                oppToContentDocumentMap.get(cdl.LinkedEntityID).add(cdl);
            }
        } 
        for(Opportunity opp : opps){
            if(oppToContentDocumentMap.get(opp.id) != null){
                opp.Number_Of_Attachments__c = oppToContentDocumentMap.get(opp.Id).size();
            }
            else{
                opp.Number_Of_Attachments__c = 0;
            }
            opp.Needs_Attachmnet_Recalculation__c = false;
        }
        update opps;
    }

    public static void recallOpenApprovalRequestsUponClosedLost(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        Set<Id> relevantOpps = new Set<Id>();
        for(Id id : newOpps.keySet()){
            if(newOpps.get(id).StageName == 'Closed Lost' && oldOpps.get(id).StageName != 'Closed Lost'){
                relevantOpps.add(id);
            }
        }
        if(relevantOpps.size()>0){
            List<ProcessInstanceWorkitem> piwis = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :relevantOpps];
            for(ProcessInstanceWorkitem piwi : piwis){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Removed');       
                req.setWorkitemId(piwi.Id);
                Approval.process(req,false);
            }
        }
    }

    public static void generatePartnershipConstructDoc(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        if(Trigger_Switches__c.getInstance().Generate_Partnership_Construct__c == true){
            for(Id id : newOpps.keySet()){
                if(oldOpps != null && (newOpps.get(id).Generate_Partnership_Construct__c && (oldOpps.get(id).Generate_Partnership_Construct__c == false || newOpps.get(id).Name != oldOpps.get(id).Name || newOpps.get(id).OwnerId != oldOpps.get(id).OwnerId 
                || newOpps.get(id).CloseDate != oldOpps.get(id).CloseDate || newOpps.get(id).Product_s__c != oldOpps.get(id).Product_s__c || newOpps.get(id).Hypothesis__c != oldOpps.get(id).Hypothesis__c || newOpps.get(id).Objective__c != oldOpps.get(id).Objective__C 
                || newOpps.get(id).Risks_Dependencies__c != oldOpps.get(id).Risks_Dependencies__c || newOpps.get(id).Method__c != oldOpps.get(id).Method__c || newOpps.get(id).Success_Metrics__c != oldOpps.get(id).Success_Metrics__c 
                || newOpps.get(id).Success_Metrics_Details__c != oldOpps.get(id).Success_Metrics_Details__c || newOpps.get(id).Success_Metrics_Tracking__c != oldOpps.get(id).Success_Metrics_Tracking__C || newOpps.get(id).Projected_Mews_Growth__c != oldOpps.get(id).Projected_Mews_Growth__c
                || newOpps.get(id).Projected_Stablecoin_on_Platform_Growth__c != oldOpps.get(id).Projected_Stablecoin_on_Platform_Growth__c || newOpps.get(id).Projected_Total_Stablecoin_Volume__c != oldOpps.get(id).Projected_Total_Stablecoin_Volume__c
                || newOpps.get(id).StageName != oldOpps.get(id).StageName))){
                    if(newOpps.get(id).Partnership_Construct_Document_ID__c == null){
                        System.debug('creating new doc');
                        GoogleDocAPI.createPartnershipContructDoc(id, newOpps.get(id).Name);
                    }
                    else{
                        System.debug('updating existing doc');
                        String projectedMetrics = GoogleDocAPI.createProjectedMetricString(oldOpps.get(id).Projected_Mews_Growth__c, oldOpps.get(id).Projected_Stablecoin_on_Platform_Growth__c, oldOpps.get(id).Projected_Total_Stablecoin_Volume__c, oldOpps.get(id).Success_metrics_details__C);
                        GoogleDocAPI.refreshPartnershipConstructDoc(id, newOpps.get(id).Partnership_Construct_Document_ID__c,oldOpps.get(id).Name, String.valueOf(oldOpps.get(id).CloseDate), oldOpps.get(id).Owner_Name__c, oldOpps.get(id).Product_s__c.replace(';',', '), oldOpps.get(id).Objective__c, oldOpps.get(id).Hypothesis__c, OldOpps.get(id).Risks_Dependencies__C, oldOpps.get(id).Method__c, oldOpps.get(id).Success_Metrics__c != null ? oldOpps.get(id).Success_Metrics__c.replace(';',', ') : null, oldOpps.get(id).Success_Metrics_tracking__c,projectedMetrics, oldOpps.get(id).StageName);
                    }
                }
                else if (oldOpps == null){
                    if(newOpps.get(id).Generate_Partnership_Construct__c == true){
                        System.debug('creating new doc');
                        GoogleDocAPI.createPartnershipContructDoc(id, newOpps.get(id).Name);
                    }
                }
            }
        }
    }

    public static void setGeneratePartnershipConstruct(List<Opportunity> newOpps){
        if(Trigger_Switches__c.getInstance().Generate_Partnership_Construct__c == true){
            for(Opportunity opp : newOpps){
                if(opp.RecordTypeId == RecordTypeIds__c.getInstance().BusinessDevelopmentOpp__c){
                    opp.Generate_Partnership_Construct__c = true;
                }
            }
        }
    }

    public static void checkIfPOShouldBeDeleted(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        for(Id id : newOpps.keyset()){
            if(newOpps.get(id).Generate_Partnership_Construct__c == false && oldOpps.get(id).Generate_Partnership_Construct__c == true && newOpps.get(id).Partnership_Construct_Document_ID__c != null){
                GoogleDocAPI.deletePO(id);
            }
        }
    }
}