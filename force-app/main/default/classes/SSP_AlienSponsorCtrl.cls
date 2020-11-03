/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_AlienSponsorCtrl
*   Created By   :   Suyash Singhal
*   Created Date :   01/16/2020
*   Description  : 	 This class is use to fetch the Alien Sponsor data.
*   Modification Log
*   Developer                 Date		          Description
*   Suyash                    01/16/2020	      Initial Version
*****************************************************************************************************************************/

public with sharing class SSP_AlienSponsorCtrl {
	/*
	* method 		: fetchAlienSponsorData
	* @description  : This method is use to fetch the Alien Sponsor data.
	* @author 		: Ashwin Kasture
	* @param 		: String applicationId - Contains Application Id
	* @param 		: String memberId - Contains Member Id
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse fetchAlienSponsorData(String applicationId, String memberId) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            applicationId = String.escapeSingleQuotes(applicationId);
            memberId = String.escapeSingleQuotes(memberId);
            List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = SSP_AlienSponsorService.fetchAlienSponsorData(applicationId, memberId);
            objResponse.bIsSuccess = true;
            objResponse.put('alienSponsorData', lstApplicationIndividuals);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AlienSponsorCtrl', 'fetchAlienSponsorData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }

    /*
	* method 		: storeAlienSponsorData
	* @description  : This method is use to store the Alien Sponsor data.
	* @author 		: Ashwin Kasture
	* @param 		: String sAlienSponsorData - Contains the Alien Sponsor data
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse storeAlienSponsorData(String sAlienSponsorData) {
    	SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            sAlienSponsorData = String.escapeSingleQuotes(sAlienSponsorData);
            Map<String, Object> mapResponse = SSP_AlienSponsorService.storeAlienSponsorData(sAlienSponsorData);          
            objResponse.bIsSuccess = true;
            objResponse.put('sAlienSponsorData', mapResponse);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AlienSponsorCtrl', 'storeAlienSponsorData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
}