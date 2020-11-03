/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_HomePageController
*   Created By   :   Samridh Manucha
*   Created Date :   03/05/2020
*   Description  :   Controller for Home Page 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Samridh               03/05/2020      Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_HomePageController {
    
    /********************************************************************************************
* @author       Samridh Manucha
* @date         12/19/2019
* @methodname   fetchCommunityURL
* @description  This method fetches the community url
* @param        None
* @return       SSP_LightningResponse
********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchCommunityURL(){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{   
            AppConfig__c configData = AppConfig__c.getInstance(SSP_GlobalConstants.BACKYARD_URL);
            if(configData != null )
            {
                String Url = configData.Value__c; 
                toSend.bIsSuccess = true;
                toSend.put('communityURL', Url);           
            }
            else {
                throw new CSException('Custom setting record not found');

            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HomePageController', 'fetchCommunityURL', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
	    /*for defect fix 380499 by Gunjyot Walia*/
        @AuraEnabled
    public static string backYardNavigate(){
        string commURL;
        commURL = AppConfig__c.getInstance('navigateToBackYard').Value__c;
        return commURL;
    }
	
    public class CSException extends Exception{}
}