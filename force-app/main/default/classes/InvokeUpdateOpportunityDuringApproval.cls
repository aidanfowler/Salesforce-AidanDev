public class InvokeUpdateOpportunityDuringApproval {
    @InvocableMethod(label='UpdateOppDuringApproval' description='Update Record As System Admin To Avoid Approval Lockdown')
    public static List<String>  InvokeUpdateOpportunityDuringApproval(List<Opportunity> opps) {
        Set<ID> relevantOpps = new Set<ID>();
        for(Opportunity opp : opps){
            if(opp.StageName == 'Closed Lost'){
                relevantOpps.add(opp.id);
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
        update opps;
        return new List<String>{'Success'};
    }
}