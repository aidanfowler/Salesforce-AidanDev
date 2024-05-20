public class CaseAssignmentQueueable implements Queueable {
    private Id m_caseId;
    public CaseAssignmentQueueable(Id a_caseId){
        m_caseId = a_caseId;
    }
    public void execute(QueueableContext context) {
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;          
        Case caseRecord=[select id from Case where case.id = :m_caseId];
        caseRecord.setOptions(dmo);
        update caseRecord;
    }
}