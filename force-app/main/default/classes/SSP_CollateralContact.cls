/*
* classname     : SSP_CollateralContact
* @description  : This class is used for assister access request screen 
* @author       : Rahul Kumar
* @date         : 6th July 2020
* MODIFICATION LOG
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Rahul Kumar       6th July 2020     Initial Version
*/
public with sharing class SSP_CollateralContact {
	
     /*
* method        : getCurrentLoggedInUserLang
* @description  : This method is use to load the Assister Role Details.
* @author       : Rahul Kumar
* @return       : String
* */
     @AuraEnabled 
    public static string getCurrentLoggedInUserLang(){
        String sUserLang;
        sUserLang= UserInfo.getLanguage();
        return sUserLang;
    }
    @AuraEnabled 
    public static List<SSP_Application__c> fetchCollateralContactData(String sApplicationId){
       
         List<SSP_Application__c>  lstapp = new List<SSP_Application__c>();
        try{
         
           lstapp = SSP_SharingBypassFetcher.fetchRecords(new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                   new Set<String>{'Id','Relationship_To_You__c','Contact_Name__c','Contact_Phone_Number__c'}, 
                                                                   new Map<String, String>{'Id'=>sApplicationId}
                                                                   );
          
         }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_CollateralContact', 'fetchCollateralContactData', ex.getMessage() , true); 
        }
        return lstapp;
    }
}