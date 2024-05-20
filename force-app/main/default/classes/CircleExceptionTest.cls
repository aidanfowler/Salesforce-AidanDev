@isTest 
public with sharing class CircleExceptionTest {

    @isTest static void coverCircleException(){
        Boolean except = false;
        try{
            Throw new CircleException('this covers the circle exception class');
        }
        catch(Exception e){
            except = true;
        }
        System.assertEquals(true, except);
    }
}