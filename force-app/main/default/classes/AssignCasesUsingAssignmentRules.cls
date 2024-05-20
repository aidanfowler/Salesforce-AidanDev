public class AssignCasesUsingAssignmentRules
{
    @InvocableMethod
    public static void CaseAssign(List<Id> CaseIds)
    {
        System.enqueueJob(new CaseAssignmentQueueable(CaseIds[0]));
    }
}