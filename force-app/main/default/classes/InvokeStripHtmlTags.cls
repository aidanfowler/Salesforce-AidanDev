public with sharing class InvokeStripHtmlTags {
    @InvocableMethod(label='Clean HTML' description='Removes HTML Tags')
    public static List<String> InvokeStripHtmlTags(List<String> tags) {
        List<String> strippedHTMLList = new List<String>();
        for(String tag : tags){
            String strippedHTML = tag.replace('<br/>','zzxxzz');
            strippedHTML = strippedHTML.stripHTMLTags().trim();
            strippedHTMLList.add(strippedHTML.replace('zzxxzz','<br/>'));

        }
        return strippedHTMLList; 
    }
}