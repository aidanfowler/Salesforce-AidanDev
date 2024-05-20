global class BatchLeadConvert implements Database.Batchable<sObject> {
    private Set<Id> m_leadIdSet = new Set<Id>();
    
    global BatchLeadConvert(Set<Id> a_leadIdSet){
        m_leadIdSet = a_leadIdSet;
    }
    global Database.QueryLocator start(Database.BatchableContext a_bc) {
        //String query = 'SELECT Id, Name FROM Lead';
        //return Database.getQueryLocator(query);
        return Database.getQueryLocator([SELECT id,firstname,lastname,email,OwnerId,
                                         Legal_Entity_Name__c,Email_Domain__c,
                                         IsConverted, Auto_Convert__c, Company, Is_this_a_work_email__c,
                                         sdr_owner__c
                                         from Lead where id in:m_leadIdSet
                                         and IsConverted = false]);
    }
    
    global void execute(Database.BatchableContext a_bc, List<Lead> a_leadList) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        for(Lead ld : a_leadList){
            leadMap.put(ld.Id, ld);
        }
        //try {
        AutoConvertLead.checkForLeadsToConvert(leadMap);
        //} catch(Exception e) {
            //System.debug(e);
        //}
    }
     
    global void finish(Database.BatchableContext a_bc) {
        
    }
}