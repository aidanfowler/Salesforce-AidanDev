@isTest
public class InvokeCreateFlowErrorTest {

    @isTest static void testInvokeCreateFlowError(){
        InvokeCreateFlowError cfe = new InvokeCreateFlowError();
        String errorMessage = '';
        Test.startTest();
            try{
                InvokeCreateFlowError.addError(new List<String>{'test error'});
            }
            catch(Exception e){
                errorMessage = e.getMessage();
            }
        Test.stopTest();
        System.assertEquals(errorMessage, 'test error ');
    }
}