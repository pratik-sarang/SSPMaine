/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_MoreHelpInfoController
*   Created By   :   Samridh Manucha
*   Created Date :   02/05/2020
*   Description  :   Controller to generate pdf for 'More help and Information' page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Samridh               02/05/2020        Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_MoreHelpInfoController{ 
public FAQ__kav helpMoreArticle {get;set;}

  public SSP_MoreHelpInfoController(){
   fetcharticle();
   Apexpages.currentPage().getHeaders().put(SSP_GlobalConstants.CONTENT_DISPOSITION, SSP_GlobalConstants.ATTACHMENT_MORE_HELP_AND_INFORMATION );
  }

/********************************************************************************************
* @author       Samridh Manucha
* @date         03/04/2020
* @methodname   fetcharticle
* @description  This method fetches the knowledge article with detail for this screen
* @param        none
* @return       void method
********************************************************************************************/
public void fetcharticle(){
try{
    String language ;
    String userLanguage = UserInfo.getLanguage();
    string screenName = SSP_GlobalConstants.SCREEN_MORE_HELP_AND_INFORMATION  ;
    for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
        if(value.getValue() == userLanguage) {
            language = value.getValue() ;
            break;
        }
    }
    language = String.isNotBlank(language) ? language : SSP_GlobalConstants.LANGUAGE_CODE_US_ENGLISH ;
    List<FAQ__kav> lstArticles = SSP_SharingBypassFetcher.queryKnowledgeArticles(screenName, language) ; 
    if(lstArticles.size() > 0) helpMoreArticle = lstArticles[0];
   }
    catch(Exception ex){            
        List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MoreHelpInfoController', 'fetcharticle', ex.getMessage() , true);
    }        
}

}