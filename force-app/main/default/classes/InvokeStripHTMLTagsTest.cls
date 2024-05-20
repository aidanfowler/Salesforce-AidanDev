@isTest
public class InvokeStripHTMLTagsTest {

    @TestSetup
    static void setup(){
        CircleTestDataFactory.insertCustomSettings();
    }

    @IsTest
    static void testStripHTML(){
        String testString = '123<br/><p>abc</p>';
        List<String> testList = new List<String>{testString};
        List<String> results = new List<String>();
        Test.startTest();
            results = InvokeStripHtmlTags.InvokeStripHtmlTags(testList);
        Test.stopTest();

        System.assertEquals('123<br/> abc', results.get(0));
    }
}