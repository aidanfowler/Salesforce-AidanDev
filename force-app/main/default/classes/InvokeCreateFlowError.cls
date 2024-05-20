public class InvokeCreateFlowError {
    @InvocableMethod(label='Throw an error' description='Throws an error so readable message can be sent to user')
    public static void addError(List<String> errorMessages) {
        CircleException e = new CircleException();
        String errorString = '';
        for(String error : errorMessages){
            errorString += error +' ';
        }
        e.setMessage(errorString);
        throw e;   
    }
}