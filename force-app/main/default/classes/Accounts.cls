public class Accounts {

    //Get all of the product interests from any contact account relations when a contact is inserted or updated and update the account level with all of the unique product interests from the related contacts
    public static void setProductInterestFromContacts(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        Set<Id> relevantContacts = new Set<Id>();
        Set<Id> relevantAccounts = new Set<Id>();
        for(Id id : newContacts.keyset()){
            if(newContacts.get(id).AccountId != null && (oldContacts == null && newContacts.get(id).Product_Interest__C != null)
                ||(oldContacts != null && newContacts.get(id).Product_Interest__C != oldContacts.get(id).Product_Interest__c)){
                relevantContacts.add(Id);
                relevantAccounts.add(newContacts.get(id).AccountId);
            }
        }
        if(relevantContacts.size()>0){
            List<AccountContactRelation> accountAndContacts = AccountDAO.getAccountContactRelations(relevantContacts, relevantAccounts);
            if(accountAndContacts.size()>0){
                List<Account> accountsToUpdate = new List<Account>();
                Map<Id, Set<String>> accountContactProductInterestMap = new Map<Id, Set<String>>();
                for(AccountContactRelation accountAndContact : accountAndContacts){
                    if(accountContactProductInterestMap.get(accountAndContact.AccountId) == null){
                        accountContactProductInterestMap.put(accountAndContact.AccountId, new Set<String>());
                    }
                    if(accountAndContact.Contact.Product_Interest__C != null){
                        List<String> productInterests = accountAndContact.Contact.Product_Interest__C.split(';');
                        accountContactProductInterestMap.get(accountAndContact.AccountId).addAll(productInterests);
                    }
                }
                for(Id interestMapId : accountContactProductInterestMap.keySet()){
                    String newProductInterests = '';
                    for(String productInterest : accountContactProductInterestMap.get(interestMapId)){
                        newProductInterests += productInterest+';';
                    }
                    newProductInterests = newProductInterests.removeEnd(';');
                    accountsToUpdate.add(new Account(Id = interestMapId, Product_Interest__c = newProductInterests));
                }
                update accountsToUpdate;
            }
        }
    }

    public static void recalculateLifeCycleStage(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        Set<Id> relevantAccounts = new Set<Id>();
        for(Id id : newContacts.keyset()){
            if(oldContacts == null && newContacts.get(id).Stage__c != null){
                relevantAccounts.add(newContacts.get(id).AccountId);
            }
            else if(oldContacts != null && (newContacts.get(id).Stage__C != oldContacts.get(id).Stage__c || newContacts.get(id).AccountId != oldContacts.get(id).AccountId)){
                relevantAccounts.add(newContacts.get(id).AccountId);
                relevantAccounts.add(oldContacts.get(id).AccountId);
            }
        }
        if(relevantAccounts.size()>0){
            List<Account> accountsToRecalculateStage = AccountDAO.getAccountsWithContactsAndLifeCycleStages(relevantAccounts);
            recalculateAccountLifeCycleStages(accountsToRecalculateStage);
        }
    }

    //Also accessed from AccountLifecycleStageBatch class (why it is in it's own method)
    public static void recalculateAccountLifeCycleStages(List<Account> accountsToRecalculateStage){
        for(Account act : accountsToRecalculateStage){
            Integer highestStageNumber = 0;
            String higestContactStageName = '';
            for(Contact c : act.contacts){
                if(c.Stage__C != null && CircleUtils.lifeCycleStageModel.get(c.Stage__C) != null){
                    Integer contactStage = CircleUtils.lifeCycleStageModel.get(c.Stage__c).stageNumber;
                    if(contactStage > highestStageNumber){
                        highestStageNumber = contactStage;
                        higestContactStageName = c.Stage__c;
                    }
                }
            }
            if(highestStageNumber == 0){
                act.Lifecycle_Stage__c = null;
            }
            else{
                act.LifeCycle_Stage__c = CircleUtils.lifeCycleStageModel.get(higestContactStageName).accountStage;
            }
        }
        update accountsToRecalculateStage;
    }

    public static void copyMostRecentNotesIntoHistory(Map<Id, Account> newActs, Map<Id, Account> oldActs){
        for(Id id : newActs.keyset()){
            if(newActs.get(id).Most_Recent_Notes__c != oldActs.get(id).Most_Recent_Notes__c){
                if(newActs.get(id).Most_Recent_Notes_History__c != null){
                    newActs.get(id).Most_Recent_Notes_History__c = '('+String.valueOf(Date.today()) +') : '+ newActs.get(id).Most_Recent_Notes__c + '<br/><br/>' + newActs.get(id).Most_Recent_Notes_History__c;
                }
                else{
                    newActs.get(id).Most_Recent_Notes_History__c = '('+String.valueOf(Date.today()) +') : '+ newActs.get(id).Most_Recent_Notes__c;
                }
                newActs.get(id).Most_Recent_Note_Updated_Date__C = DateTime.now();
            }
        }
    }

    public static void rollUpAccountMetrics(Set<Id> accountIds){
        List<Account> allAccountsToUpdate = AccountDAO.getAccountsWithCircleAccountsAndPOsByIds(accountIds);
        for(Account act : allAccountsToUpdate){
            List<Circle_Account__c> circleMints = act.Circle_Accounts__r;
            if(circleMints.size() > 0){
                Decimal startingBurn = null;
                Decimal startingMint = null;
                Decimal currentBurn = null;
                Decimal currentMint = null;
                Decimal monthlyAvgBurn = null;
                Decimal monthlyAvgMint = null;
                Decimal burnVol30 = null;
                Decimal mintVol30 = null;    
                Decimal avg30DiffMint = null;
                Decimal avg30DiffBurn = null;             
                for(Circle_Account__c circleMint : circleMints){
                    if(circleMint.Starting_Gross_Burn__c != null){
                        if(startingBurn == null){
                            startingBurn = circleMint.Starting_Gross_Burn__c;
                        }
                        else{
                            startingBurn += circleMint.Starting_Gross_Burn__c;
                        }
                    }
                    if(circleMint.Starting_Gross_Mint__c != null){
                        if(startingMint == null){
                            startingMint = circleMint.Starting_Gross_Mint__c;
                        }
                        else{
                            startingMint += circleMint.Starting_Gross_Mint__c;
                        }
                    }
                    if(circleMint.Current_Gross_Burn__c != null){
                        if(currentBurn == null){
                            currentBurn = circleMint.Current_Gross_Burn__c;
                        }
                        else{
                            currentBurn += circleMint.Current_Gross_Burn__c;
                        }
                    }
                    if(circleMint.Current_Gross_Mint__c != null){
                        if(currentMint == null){
                            currentMint = circleMint.Current_Gross_Mint__c;
                        }
                        else{
                            currentMint += circleMint.Current_Gross_Mint__c;
                        }
                    }
                    if(circleMint.Monthly_Avg_Gross_Burn__c != null){
                        if(monthlyAvgBurn == null){
                            monthlyAvgBurn = circleMint.Monthly_Avg_Gross_Burn__c;
                        }
                        else{
                            monthlyAvgBurn += circleMint.Monthly_Avg_Gross_Burn__c;
                        }
                    }
                    if(circleMint.Monthly_Avg_Gross_Mint__c != null){
                        if(monthlyAvgMint == null){
                            monthlyAvgMint = circleMint.Monthly_Avg_Gross_Mint__c;
                        }
                        else{
                            monthlyAvgMint += circleMint.Monthly_Avg_Gross_Mint__c;
                        }
                    }
                    if(circleMint.Burn_Volume_Last_30_Days__c != null){
                        if(burnVol30 == null){
                            burnVol30 = circleMint.Burn_Volume_Last_30_Days__c;
                        }
                        else{
                            burnVol30 += circleMint.Burn_Volume_Last_30_Days__c;
                        }
                    }
                    if(circleMint.Mint_Volume_Last_30_Days__c != null){
                        if(mintVol30 == null){
                            mintVol30 = circleMint.Mint_Volume_Last_30_Days__c;
                        }
                        else{
                            mintVol30 += circleMint.Mint_Volume_Last_30_Days__c;
                        }
                    }
                }
                act.Total_Burn_Volume_Last_30_Days__c = burnVol30;
                act.Total_Mint_Volume_Last_30_Days__c = mintVol30;
                act.Total_Current_Gross_Burn__c = currentBurn;
                act.Total_Current_Gross_Mint__c = currentMint;
                act.Total_Monthly_Avg_Gross_Burn__c = monthlyAvgBurn;
                act.Total_Monthly_Avg_Gross_Mint__c = monthlyAvgMint;
            }
            
            List<Partnership_Objective__c> pObjectives = act.Partnership_Objectives__r;
            if(pObjectives.size() != 0){
                Partnership_Objective__c po = pObjectives.get(0);               
                act.Performance_Objective_Health__c = po.Performance_Objective_Health__c;
                act.Launch_Status__c = po.Objective_Status__c;
            }
            else{
                act.Performance_Objective_Health__c = null;
                act.Launch_Status__c = null;
            }
        }
        update allAccountsToUpdate;
    }

    public static void rollUpLiquidityCoverageUpdates(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        List<Account> accountsToUpdate = new List<Account>();
        for(Id id : newOpps.keySet()){
            if(newOpps.get(id).Product_s__c.contains('Institutional Trading Partnership') && (newOpps.get(id).Account_Liquidity_Coverage_Deal__c == null || newOpps.get(id).Account_Liquidity_Coverage_Deal__c == Id) && newOpps.get(id).StageName == 'Closed Won'){
                Account actToUpdate = new Account(Id = newOpps.get(id).AccountId);
                Boolean updateAct = false;
                if(newOpps.get(id).Liquidity_Coverage_Supported_Markets__c != oldOpps.get(id).Liquidity_Coverage_Supported_Markets__c){
                    actToUpdate.Liquidity_Coverage_Supported_Markets__c = newOpps.get(id).Liquidity_Coverage_Supported_Markets__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_Partner_Status__c != oldOpps.get(id).Liquidity_Coverage_Partner_Status__c){
                    actToUpdate.Liquidity_Coverage_Partner_Status__c = newOpps.get(id).Liquidity_Coverage_Partner_Status__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_Priority__c != oldOpps.get(id).Liquidity_Coverage_Priority__c){
                    actToUpdate.Liquidity_Coverage_Priority__c = newOpps.get(id).Liquidity_Coverage_Priority__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_Instant_Rails__c != oldOpps.get(id).Liquidity_Coverage_Instant_Rails__c){
                    actToUpdate.Liquidity_Coverage_Instant_Rails__c = newOpps.get(id).Liquidity_Coverage_Instant_Rails__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_Partner_Category__c != oldOpps.get(id).Liquidity_Coverage_Partner_Category__c){
                    actToUpdate.Liquidity_Coverage_Partner_Category__c = newOpps.get(id).Liquidity_Coverage_Partner_Category__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_USDC_Source__c != oldOpps.get(id).Liquidity_Coverage_USDC_Source__c){
                    actToUpdate.Liquidity_Coverage_USDC_Source__c = newOpps.get(id).Liquidity_Coverage_USDC_Source__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_Banking_Partner__c != oldOpps.get(id).Liquidity_Coverage_Banking_Partner__c){
                    actToUpdate.Liquidity_Coverage_Banking_Partner__c = newOpps.get(id).Liquidity_Coverage_Banking_Partner__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_Tied_To_Incentive__c != oldOpps.get(id).Liquidity_Coverage_Tied_To_Incentive__c){
                    actToUpdate.Liquidity_Coverage_Tied_To_Incentive__c = newOpps.get(id).Liquidity_Coverage_Tied_To_Incentive__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Circle_Account__c != oldOpps.get(id).Circle_Account__c){
                    actToUpdate.Circle_Mint__c = newOpps.get(id).Circle_Account__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Supported_Currencies_for_Minting__c != oldOpps.get(id).Supported_Currencies_for_Minting__c){
                    actToUpdate.Supported_Currencies_for_Minting__c = newOpps.get(id).Supported_Currencies_for_Minting__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Supported_Currencies_for_Redeeming__c != oldOpps.get(id).Supported_Currencies_for_Redeeming__c){
                    actToUpdate.Supported_Currencies_for_Redeeming__c = newOpps.get(id).Supported_Currencies_for_Redeeming__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Liquidity_Coverage_Supported_Audience__c != oldOpps.get(id).Liquidity_Coverage_Supported_Audience__c){
                    actToUpdate.Liquidity_Coverage_Supported_Audience__c = newOpps.get(id).Liquidity_Coverage_Supported_Audience__c;
                    updateAct = true;
                }
                if(newOpps.get(id).Minimum_Volume_Supported__c != oldOpps.get(id).Minimum_Volume_Supported__c){
                    actToUpdate.Minimum_Volume_Supported__c = newOpps.get(id).Minimum_Volume_Supported__c;
                    updateAct = true;
                }
                if(updateAct){
                    actToUpdate.Liquidity_Coverage_Deal__c = id;
                    accountsToUpdate.add(actToUpdate);
                }
            }
        }
        if(accountsToUpdate.size()>0){
            update accountsToUpdate;
        }
    }

}