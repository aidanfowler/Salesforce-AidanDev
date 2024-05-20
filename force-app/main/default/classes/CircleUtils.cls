public class CircleUtils {
    
    public static Map<String, LifeCycleStage> lifeCycleStageModel = new Map<String, LifeCycleStage>();
    public static Set<String> validProducts = new Set<String>{'Accounts API','Activation Incentives','Blockchain Partnerships','CCTP','Channel Sales','Circle Mint','Core API','Crypto Deposits','Crypto Payouts','Cybavo Cashflow Manager','Cybavo VAULT','Indirect Liquidity Partners','Institutional Trading Partnership','Performance Incentives','Product Integrations','Programmable Wallets','PSP Crypto Settlement','Read Only API','Referrals','Smart Contract Platform','Verite','Bridged USDC Standard','Alt Mempool','Gas Station', 'Loans'};
    public static Set<String> accountsPayableProducts = new Set<String>{'Activation Incentives','Performance Incentives'};
    public static Set<String> accountsReceivableProducts = new Set<String>{'Core API','Programmable Wallets','Accounts API','Crypto Deposits','Crypto Payouts','Cybavo VAULT','Cybavo Cashflow Manager','PSP Crypto Settlement','Smart Contract Platform', 'Gas Station'};
    public static Set<String> pricingTeamProducts = new Set<String>{'Institutional Trading Partnership','Channel Sales','Referrals','Blockchain Partnerships','Indirect Liquidity Partners','Product Integrations', 'Loans'};
    public static Set<String> noImpactProducts = new Set<String>{'Circle Mint','CCTP','Read Only API','Verite','Bridged USDC Standard','Alt Mempool'};
    public static Map<String,Integer> stageOrderMap = new Map<String, Integer>{'Discover'=>1,'Solution'=>2,'Approvals'=>3,'Negotiate'=>4,'Contract'=>5,'Closed Won'=>6, 'Closed Lost'=>7};

    static{
        lifeCycleStageModel.put('Cold', new LifeCycleStage(1,'Cold'));
        lifeCycleStageModel.put('Subscriber', new LifeCycleStage(2,'Subscriber'));
        lifeCycleStageModel.put('New', new LifeCycleStage(3,'Lead'));
        lifeCycleStageModel.put('Recycled - Not Ready', new LifeCycleStage(4,'Recycled'));
        lifeCycleStageModel.put('Researching', new LifeCycleStage(5,'In Progress'));
        lifeCycleStageModel.put('In Progress', new LifeCycleStage(6,'In Progress'));
        lifeCycleStageModel.put('Marketing Qualified', new LifeCycleStage(7,'MQL'));
        lifeCycleStageModel.put('Engaged', new LifeCycleStage(8,'SAL'));
        lifeCycleStageModel.put('Advanced', new LifeCycleStage(9,'SQL'));
        lifeCycleStageModel.put('Qualified', new LifeCycleStage(10,'OTY'));
        lifeCycleStageModel.put('Disqualified - Bad Fit', new LifeCycleStage(11,'Disqualified'));
        lifeCycleStageModel.put('Closed-lost', new LifeCycleStage(12,'Closed-lost'));
        lifeCycleStageModel.put('Customer', new LifeCycleStage(13,'Customer'));
        lifeCycleStageModel.put('Former Customer', new LifeCycleStage(14,'Former Customer'));
        lifeCycleStageModel.put('Terminated Customer', new LifeCycleStage(15,'Terminated Customer'));
    }
   
    public class LifeCycleStage{
        public String accountStage {get;set;}
        public Integer stageNumber {get;set;}

        public LifeCycleStage(Integer num, String stage){
            accountStage = stage;
            stageNumber = num;
        }
    }
}