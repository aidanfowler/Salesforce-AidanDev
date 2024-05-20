public with sharing class PartnershipObjectives {

    public static void recalculateAccountRollUpFields(Map<Id, Partnership_Objective__c> newObjectives, Map<Id, Partnership_Objective__c> oldObjectives){
        Set<Id> accountIdsToRollUp = new Set<Id>();
        for(Id id : newObjectives.keyset()){
            if(oldObjectives != null){
                if((newObjectives.get(id).Performance_Objective_Health__c != oldObjectives.get(id).Performance_Objective_Health__c || newObjectives.get(id).Account__c != oldObjectives.get(id).Account__c 
                    || newObjectives.get(id).Objective_Status__c != oldObjectives.get(id).Objective_Status__c) && newObjectives.get(id).Type__c == 'Partner Metrics Tracking'){
                        accountIdsToRollUp.add(newObjectives.get(id).Account__c);
                    }
            }
            else{
                if((newObjectives.get(id).Performance_Objective_Health__c != null || newObjectives.get(id).Objective_Status__c != null ) && newObjectives.get(id).Type__c == 'Partner Metrics Tracking' && newObjectives.get(id).Account__c != null){
                    accountIdsToRollUp.add(newObjectives.get(id).Account__c);
                }
            }
        }
        if(accountIdsToRollUp.size()>0){
            Accounts.rollUpAccountMetrics(accountIdsToRollUp);
        }
    }

    public static void recalculatePORollUpFields(Map<Id, Partnership_Objective__c> newObjectives, Map<Id, Partnership_Objective__c> oldObjectives){
        Set<Partnership_Objective__c> partnershipMetricsNeedRollUp = new Set<Partnership_Objective__c>();
        for(Id id : newObjectives.keyset()){
            if((newObjectives.get(id).Current_Stablecoin_Liquidity__c != oldObjectives.get(id).Current_Stablecoin_Liquidity__c || newObjectives.get(id).Current_MEWs__c != oldObjectives.get(id).Current_MEWs__c 
                || newObjectives.get(id).Current_Stablecoin_Volume__c != oldObjectives.get(id).Current_Stablecoin_Volume__c || newObjectives.get(id).Projected_MeWs_Growth__c != oldObjectives.get(id).Projected_MeWs_Growth__c
                || newObjectives.get(id).Projected_Total_Stablecoin_Volume__c != oldObjectives.get(id).Projected_Total_Stablecoin_Volume__c || newObjectives.get(id).Projected_Stablecoin_on_Platform_Growth__c != oldObjectives.get(id).Projected_Stablecoin_on_Platform_Growth__c
                || newObjectives.get(id).Custom_Metric__c != oldObjectives.get(id).Custom_Metric__c || newObjectives.get(id).Starting_Mews__C !=oldObjectives.get(id).Starting_mews__c || newObjectives.get(id).Starting_Stablecoin_Volume__c !=oldObjectives.get(id).Starting_Stablecoin_Volume__c 
                || newObjectives.get(id).Starting_stablecoin_Liquidity__C !=oldObjectives.get(id).Starting_stablecoin_Liquidity__C)
                && newObjectives.get(id).Type__c == 'Partner Metrics Tracking'){
                    partnershipMetricsNeedRollUp.add(newObjectives.get(id));
            }
        }

        if(partnershipMetricsNeedRollUp.size()>0){
            rollUpPOMetrics(partnershipMetricsNeedRollUp);
        }
    }

    public static void recalculatePORollUpFields(List<Partnership_Objective__c> newObjectives){
        Set<Partnership_Objective__c> partnershipMetricsNeedRollUp = new Set<Partnership_Objective__c>();
        for(Partnership_Objective__c po : newObjectives){
            if((po.Current_Stablecoin_Liquidity__c != null ||  po.Current_MEWs__c != null || po.Current_Stablecoin_Volume__c != null ||  po.Projected_Stablecoin_on_Platform_Growth__c != null
                ||  po.Projected_MeWs_Growth__c != null || po.Projected_Total_Stablecoin_Volume__c != null || po.Custom_Metric__c != null || po.Starting_Mews__c != null 
                || po.Starting_stablecoin_Liquidity__C != null || po.Starting_Stablecoin_Volume__c != null) && po.Type__c == 'Partner Metrics Tracking'){
                partnershipMetricsNeedRollUp.add(po);
            }
        }
        if(partnershipMetricsNeedRollUp.size()>0){
            rollUpPOMetrics(partnershipMetricsNeedRollUp);
        }
    }

    public static void rollUpPOMetrics(Set<Partnership_Objective__c> objectives){
        List<String> currencyFormatting = new String[]{'0','number','⌗⌗⌗,⌗⌗⌗,⌗⌗⌗,⌗⌗⌗'};
        for(Partnership_Objective__c po: objectives){
            String currentMetrics = '';
            String projectedMetrics = '';
            String attainment = '';
            String growthMetrics = '';

            String stablecoin = po.Stablecoin__c;
            if(stablecoin == null || stablecoin == ''){
                stablecoin = 'USDC';
            }
        
            currentMetrics += po.Current_MEWs__c != null ? 'MEWs: ' +String.format(po.Current_MEWs__c.format(), currencyFormatting) +'<br/>': ''; 
            currentMetrics += po.Current_Stablecoin_Liquidity__c != null ? stablecoin+ ' On Platform: $' +String.format(po.Current_Stablecoin_Liquidity__c.format(), currencyFormatting) +'<br/>': '';
            currentMetrics += po.Current_Stablecoin_Volume__c != null ? 'Transaction Volume: $' +String.format(po.Current_Stablecoin_Volume__c.format(), currencyFormatting) +'<br/>': '';  
            
            projectedMetrics += po.Projected_MeWs_Growth__c != null ? 'MEWs: ' +String.format(po.Projected_MeWs_Growth__c.format(), currencyFormatting) +'<br/>': '';
            projectedMetrics += po.Projected_Stablecoin_on_Platform_Growth__c != null ? ''+stablecoin+ ' On Platform: $' +String.format(po.Projected_Stablecoin_on_Platform_Growth__c.format(), currencyFormatting) +'<br/>': '';                
            projectedMetrics += po.Projected_Total_Stablecoin_Volume__c != null ? 'Transaction Volume: $' +String.format(po.Projected_Total_Stablecoin_Volume__c.format(), currencyFormatting) +'<br/>': '';
            
            growthMetrics += po.Starting_Mews__c != null && po.Current_MEWs__c != null ?'MeWs: '+ String.format((po.Current_MEWs__c-po.Starting_Mews__c).format(), currencyFormatting) + '<br/>' : '';
            growthMetrics += po.Starting_stablecoin_liquidity__C != null && po.Current_Stablecoin_Liquidity__c != null ?'Stablecoin On Platform: $'+ String.format((po.Current_Stablecoin_Liquidity__c-po.Starting_stablecoin_liquidity__C).format(), currencyFormatting) + '<br/>' : '';
            growthMetrics += po.Starting_Stablecoin_Volume__c != null && po.Current_Stablecoin_Volume__c != null ? 'Transaction Volume: $'+String.format((po.Current_Stablecoin_Volume__c-po.Starting_Stablecoin_Volume__c).format(), currencyFormatting) + '<br/>' : '';


            if(po.Projected_MeWs_Growth__c != null && po.Projected_MeWs_Growth__c != 0 && po.MeWs_Growth__c != null){
                Decimal projectedMewAttainment = po.MeWs_Growth__c / po.Projected_MeWs_Growth__c;
                attainment += 'MEWs: '+(projectedMewAttainment*100.0).setScale(0)+'%<br/>';
            }
            if(po.Projected_Stablecoin_on_Platform_Growth__c != null &&po.Projected_Stablecoin_on_Platform_Growth__c != 0  && po.Stablecoin_On_Platform_Growth__c != null){
                Decimal stableCoinOnPlatformAttainment = po.Stablecoin_On_Platform_Growth__c / po.Projected_Stablecoin_on_Platform_Growth__c;
                attainment += stablecoin+' On Platform: '+(stableCoinOnPlatformAttainment*100.0).setScale(0)+'%<br/>';
            }
            if(po.Projected_Total_Stablecoin_Volume__c != null && po.Projected_Total_Stablecoin_Volume__c != 0 &&  po.Stablecoin_Volume_Growth__c !=null){
                Decimal projectedtransactionAttainment = po.Stablecoin_Volume_Growth__c / po.Projected_Total_Stablecoin_Volume__c;
                attainment += 'Transaction Volume: '+(projectedtransactionAttainment*100.0).setScale(0)+'%<br/>';
            }
            if(po.Success_Metrics__c != null && po.Success_Metrics__c =='Other'){
                projectedMetrics = 'Click into Partnership Objective for Detail';
                currentMetrics = 'Click into Partnership Objective for Detail'; 
                attainment = 'Click into Partnership Objective for Detail';
            }
            
            po.Current_Metrics__c = currentMetrics.removeEnd('<br/>');
            po.Projected_Metrics__c = projectedMetrics.removeEnd('<br/>');
            po.Attainment__c = attainment.removeEnd('<br/>');
            po.Growth__c = growthMetrics.removeEnd('<br/>');
        }
    }

    public static void setMostRecentNoteHistory(Map<Id, Partnership_Objective__c> newObjectives, Map<Id, Partnership_Objective__c> oldObjectives){
        for(Id id : newObjectives.keyset()){
            if(newObjectives.get(id).Most_recent_Note__c != oldObjectives.get(id).Most_recent_Note__c && newObjectives.get(id).Most_recent_Note__c != null){
                if(newObjectives.get(id).Most_recent_Note_History__c != null){
                    newObjectives.get(id).Most_recent_Note_History__c = '('+String.valueOf(Date.today()) +') : '+newObjectives.get(id).Most_recent_Note__c+ '<br/><br/>' +newObjectives.get(id).Most_recent_Note_History__c;
                }
                else{
                    newObjectives.get(id).Most_recent_Note_History__c = '('+String.valueOf(Date.today()) +') : '+newObjectives.get(id).Most_recent_Note__c;
                }
                newObjectives.get(id).Most_Recent_Note_Date__c = Date.today();
            }
        }
    }
}