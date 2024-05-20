public without sharing class DataCategoryHelper {

   public static final String DATA_CATEGORY_GROUP = 'Help_Center';

   // Returns a Map of Category Name to Label
    public static Map<String, String> getTopLevelCategoryMap(){

      Map<String, String> categoryMap = new Map<String, String>();

      List<DescribeDataCategoryGroupResult> describeCategoryResult;
      List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
      try {
         //Making the call to the describeDataCategoryGroups to
         //get the list of category groups associated
         List<String> objType = new List<String>();
         objType.add('KnowledgeArticleVersion');
         describeCategoryResult = Schema.describeDataCategoryGroups(objType);
         
         //Creating a list of pair objects to use as a parameter
         //for the describe call
         List<DataCategoryGroupSobjectTypePair> pairs = 
            new List<DataCategoryGroupSobjectTypePair>();
         
         //Looping throught the first describe result to create
         //the list of pairs for the second describe call
         for(DescribeDataCategoryGroupResult singleResult : 
         describeCategoryResult){
            DataCategoryGroupSobjectTypePair p =
               new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());

            pairs.add(p);
         }
         
         //describeDataCategoryGroupStructures()
         describeCategoryStructureResult = 
            Schema.describeDataCategoryGroupStructures(pairs, false);

         //Getting data from the result
         for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult) {

            List<DataCategory> dataCategories = singleResult.getTopCategories();

            for(DataCategory dataCategory : dataCategories) {
               categoryMap.put(dataCategory.getName(), dataCategory.getLabel());
            }

            //Recursively get all the categories
            List<DataCategory> allCategories = getAllCategories(dataCategories);

            for(DataCategory category : allCategories) {
               
               categoryMap.put(category.getName(), category.getLabel());
            }
            
         }
      } 
      catch (Exception e){
      }
      return categoryMap;
    }

   // Gets All SubCategoires for a Group
   public static List<DataCategory> getAllSubCategories(String groupName) {
      List<DataCategory> dataCategories = new List<DataCategory>();
      DataCategoryGroupSObjectTypePair p = new DataCategoryGroupSObjectTypePair();

         List<DescribeDataCategoryGroupResult> describeCategoryResult;
         List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;

         p.setSObject('KnowledgeArticleVersion');
         p.setDataCategoryGroupName(groupName);

         describeCategoryStructureResult = 
            Schema.describeDataCategoryGroupStructures(new List<DataCategoryGroupSObjectTypePair>{p}, false);

         DataCategory dataCat;

         for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult) {
            DataCategory dataCategory = singleResult.getTopCategories()[0];
            
            List<DataCategory> childCategories = dataCategory.getChildCategories();            

            for(DataCategory dc : childCategories) {
               
               dataCategories.add(dc);
            }
         }
         
      return dataCategories;
   }

   // Get Subcategories for a Category
   public static List<DataCategory> getSubCategories(String groupName, String dataCategoryName) {

      List<DataCategory> dataCategories = new List<DataCategory>();

      if(dataCategoryName != null) {

         DataCategoryGroupSObjectTypePair p = new DataCategoryGroupSObjectTypePair();

         List<DescribeDataCategoryGroupResult> describeCategoryResult;
         List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;

         p.setSObject('KnowledgeArticleVersion');
         p.setDataCategoryGroupName(groupName);

         describeCategoryStructureResult = 
            Schema.describeDataCategoryGroupStructures(new List<DataCategoryGroupSObjectTypePair>{p}, false);

         DataCategory dataCat;

         List<DataCategory> topDataCategories = describeCategoryStructureResult[0].getTopCategories();

         for(DataCategory topCategory : topDataCategories[0].getChildCategories()) {

            if(topCategory.getName() == dataCategoryName) {
         
               dataCat = topCategory;
               break;
            }
         }         

         dataCategories = dataCat.getChildCategories();

      }

      return dataCategories;
   }
   
   private static DataCategory[] getAllCategories(DataCategory [] categories){
      if(categories.isEmpty()){
         return new DataCategory[]{};
      } else {
         DataCategory [] categoriesClone = categories.clone();
         DataCategory category = categoriesClone[0];
         DataCategory[] allCategories = new DataCategory[]{category};
         categoriesClone.remove(0);
         categoriesClone.addAll(category.getChildCategories());
         allCategories.addAll(getAllCategories(categoriesClone));
         return allCategories;
      }
   }

   // Get the Support Categories from the Category Name (Support_Category__mdt)
   public static List<Support_Category__mdt> getSupportCategories(Boolean loggedIn, Boolean checkingSuggestedArticles) {

      String query = 'Select Id, Label, API_Name__c, Order__c, Icon__c, Has_Suggested_Articles__c, Gated__c from Support_Category__mdt';

      if(loggedIn && checkingSuggestedArticles) {
         query += ' where (Gated__c = true or Gated__c = false) and Has_Suggested_Articles__c = true ';
      }
      else if(loggedIn) {
         query += ' where (Gated__c = true or Gated__c = false) ';
      }
      else if(checkingSuggestedArticles) {
         query += ' where Has_Suggested_Articles__c = true and Gated__c = false ';
      }
      else {
         query += ' where Gated__c = false ';
      }

      query += ' order by Order__c asc';

      return Database.query(query);
   }

}