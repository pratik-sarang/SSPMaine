/***************************************************************************************************************************
*   Type        :   Knowledge article search logic
*   Name        :   SSP_KnowledgeArticleCtrlr
*   Create By   :   Narapa
*   Create Date :   Jul-10-2020
*   Description :   This class manages the search queries when typing in the search bar on the Help & FAQs
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                    Description
*   --------------------------------------------------------------------------------------
*    Tommaso Massari           Jul-24-2020             Initial Version
*
*****************************************************************************************************************************/

public with sharing class SSP_KnowledgeArticleCtrlr {

    /**
     * exec - the only public method, used to access the functionalities of the class, depending on the action received.
     *
     * @param string action
     * @param string searchTerm
     * @param string language
     * @param string category
     *
     * @return SSP_LightningResponse
     */

    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse exec(String action, String searchTerm, String language, String category){
        SSP_LightningResponse KACtrlrResponse = new SSP_LightningResponse();
        if (action == 'getKACategories')
        {
            KACtrlrResponse = getCategories();
        }
        else if (action == 'getKArticles')
        {
            KACtrlrResponse = getArticles(category,language);
        }
        else if (action == 'searchArticles')
        {
            KACtrlrResponse = searchArticle(searchTerm, language);
        }
       return KACtrlrResponse;
    }
    
    /**
     * searchArticle - search a given piece of text into the whole article set and category set
     *
     * @param string searchTerm
     * @param string language
     *
     * @return SSP_LightningResponse
     */
    
    private static SSP_LightningResponse searchArticle(String searchTerm, String language){
        SSP_LightningResponse res = new SSP_LightningResponse();
        List<FAQ__kav> articles = new List<FAQ__kav>();
        String recordType = 'BenefindArticles';
        List<PicklistEntry> categories = new List<PicklistEntry>();
        searchTerm = searchTerm.toLowerCase() + '*';

        try {
            switch on language {
                when 'en_US' {
                    articles = [FIND :searchTerm RETURNING FAQ__kav 
                                (Id, Title, Answer__c, Question__c, Help_Category__c, Order__c 
                                WHERE Language = 'en_US' AND PublishStatus = 'Online' AND RecordType.DeveloperName = :recordType ORDER BY Order__c)][0];
                }
                
                when 'es_US' {
                    articles = [FIND :searchTerm RETURNING FAQ__kav 
                                (Id, Title, Answer__c, Question__c, Help_Category__c, Order__c 
                                WHERE Language = 'es_US' AND PublishStatus = 'Online' AND RecordType.DeveloperName = :recordType ORDER BY Order__c)][0];
                }
                
                when else {
                    throw new InvalidLanguageCodeException('Invalid language code passed to searchArticle method. Language code received is: ' + language);
                }
        	}
        }
        
        catch (Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_KnowledgeArticleCtrlr', 'searchArticle', e.getMessage() , true);
            res.addException(e, lstLogMessages[0].Id);
        }

        searchTerm = searchTerm.removeEnd('*');
        
        for (PicklistEntry category: fetchCategories()){
            if (category.label.toLowerCase().contains(searchTerm)){
                categories.add(category); // <api, label>
            }
        }
                        
        res.put('articles', articles);
        res.put('categories', categories);

        return res;
    }
    
    // FOOTNOTE
    // reason for the use of switch instead of a variable on the Language in the query:
    // "When searching the FAQ__kav object, you must include a filter on Language = [language ISO code] as a top-level AND condition."
    // Can't use variables for PublishStatus:
    // "Invalid PublishStatus filter value. Valid values are 'Draft', 'Online' and 'Archived'.""

    /**
     * getCategories - this is used to get the categories to display in the initial UI menu
     *
     * @return SSP_LightningResponse
     */

    private static SSP_LightningResponse getCategories(){
        SSP_LightningResponse categoriesResponse = new SSP_LightningResponse();
       categoriesResponse.put('kACategories',fetchCategories());
       return categoriesResponse;
        
    }

    /**
     * fetchCategories - it returns the list of all help categories, in the format of PicklistEntry <label, value>
     *
     * @return List<PicklistEntry>
     */
    private static List<PicklistEntry> fetchCategories(){
    List<PicklistEntry> helpCategoriesList = new List<PicklistEntry>();
        Schema.DescribeFieldResult helpCategory = FAQ__kav.Help_Category__c.getDescribe();
        List<Schema.PicklistEntry> helpCatPle = helpCategory.getPicklistValues();
        for( Schema.PicklistEntry helpCatPl : helpCatPle){
            if(helpCatPl.getValue().startsWith('BA_') && helpCatPl.isActive()){
                helpCategoriesList.add(new PicklistEntry(helpCatPl.getValue(),helpCatPl.getLabel()));
            }
       }
       return helpCategoriesList;
    }

    /**
     * getArticles - This is used to get a set of articles of a certain category and language
     *
     * @param string category
     * @param string language
     *
     * @return SSP_LightningResponse
     */

    private static SSP_LightningResponse getArticles(String category, String language){
        SSP_LightningResponse articlesResponse = new SSP_LightningResponse();
        List<FAQ__kav> faqList = new List<FAQ__kav>();
        String recordType = 'BenefindArticles';

        try {
            faqList = [SELECT Id, Title, Question__c,Answer__c, ScreenName__c, Language, toLabel(Help_Category__c), Order__c 
            FROM FAQ__kav WHERE (PublishStatus = 'Online' 
            AND RecordType.DeveloperName = :recordType AND Help_Category__c=:category
            AND language = :language) ORDER BY Order__c];
        }

        catch (QueryException e){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_KnowledgeArticleCtrlr', 'getArticles', e.getMessage() , true);
            articlesResponse.addException(e, lstLogMessages[0].Id);
        }

        //no click on phone number bug fix
        for(FAQ__kav faq: faqList){
            faq.Answer__c = faq.Answer__c.replaceAll('/tel:','tel:');

            // work-around for accessing static resource (PROD issue)
            faq.Answer__c = faq.Answer__c.replaceAll('/resource','../resource');
        }

        articlesResponse.put('kArticles',faqList);
        return articlesResponse;
    }       

    /**
     * PicklistEntry - inner class used to define a daa structure to save API name and Label of help categories
     */
    public class PicklistEntry{

        @AuraEnabled public String value{get;set;}
        @AuraEnabled public String label{get;set;}

        public PicklistEntry(String value, String label){
            this.value = value;
            this.label = label; 
        }
    }

    /**
     * InvalidLanguageCodeException - custom exception to catch issues with the language code
     */
    public class InvalidLanguageCodeException extends Exception {}
}