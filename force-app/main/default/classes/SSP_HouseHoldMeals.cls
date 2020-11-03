/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_HouseHoldMeals
*   Created By   :   Suyash Singhal
*   Created Date :   11/13/2019
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                    11/13/2019        Initial Version
*****************************************************************************************************************************/


public with sharing class SSP_HouseHoldMeals {

     /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @description  This method gets all the Household details as an init method
    * @param        lstApplicationIds - asked to make code bulkified -_-
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchHouseHoldData(String sApplicationId , String mode){
         SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String,Object> MapResponse = new Map<String,Object>();
        List<String> lstApplicationIds = new List<String>{sApplicationId};
       

        try{
         
            MapResponse =  SSP_HouseHoldMealsService.fetchHouseHoldData(lstApplicationIds , mode);
        }catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldMeals', 'fetchHouseHoldData', ex.getMessage() , true);        }
         
        objResponse.bIsSuccess = Boolean.valueOf(MapResponse.get('bIsSuccess'));
        objResponse.mapResponse = MapResponse;

        return objResponse;
        
    }

     /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @description  This method save the member data from component
    * @param        String sMemberIds,String sAppId
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse saveData(String sMemberIds,String sAppId , String mode){
         SSP_Utility.isAuthenticatedUser();        
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        map<String,Object> MapResponse = new map<String,Object>();

        try{
          
           MapResponse =  SSP_HouseHoldMealsService.saveData(sMemberIds,sAppId , mode);
          
        }catch(Exception ex) {List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldMeals', 'saveData', ex.getMessage() , true);        }

        objResponse.bIsSuccess = Boolean.valueOf(MapResponse.get('bIsSuccess'));
        objResponse.mapResponse = MapResponse;
        return objResponse;

    }

    public class WrapperHHMeals {

        @AuraEnabled public String sMemberName;
        @AuraEnabled public String sMemberId;
        @AuraEnabled public Boolean bCanBuyCookWithHOH;
        @AuraEnabled public Boolean bHOH;
    	@AuraEnabled public String sMemberStatus;
        
    }
}