trigger LeadTrigger on Lead (after insert, after update) {
    if(Trigger.IsAfter && Trigger_Switches__c.getInstance().Lead_Trigger_Switch__c && !Trigger_Switches__c.getInstance().New_lead_Conversion__c){
        if(Trigger.IsInsert || Trigger.isUpdate){
            Map<Id, Lead> leadsToConvertMap = new Map<Id, Lead>();
            for(Lead ld : Trigger.New){
                if(ld.Auto_Convert__c && !ld.IsConverted){
                    leadsToConvertMap.put(ld.Id, ld);
                }
            }
            if(leadsToConvertMap.size() > 0){
                if(leadsToConvertMap.size() <= 5){
                	AutoConvertLead.checkForLeadsToConvert(leadsToConvertMap);
                }
                else if(!system.isBatch()){
                    database.executeBatch(new BatchLeadConvert(leadsToConvertMap.keySet()), 25);
                }
            }
        }
        
    }
}