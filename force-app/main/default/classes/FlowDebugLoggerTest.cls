@isTest 
public with sharing class FlowDebugLoggerTest {

    @isTest static void testFlowDebugLogger(){
        FlowDebugLogger.trace(new List<String>{'test message for coverage'});
    }
}