@isTest
public class CaseAssignmentTest {

    @TestSetup
    static void setup(){
       CircleTestDataFactory.insertCustomSettings(); 
    }
    
    static testmethod void  testCaseAssignment(){
        Account a = new Account(Name = 'TestName');
        insert a;
        Case c = new Case(Subject = 'Test', AccountId = a.Id);
        insert c;
        List<Id> caseIds = new List<Id>();
        caseIds.add(c.Id);
        AssignCasesUsingAssignmentRules.CaseAssign(caseIds);
    }
}