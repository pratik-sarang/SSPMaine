/*
* classname 	: SSP_HealthSelectionCtrl
* @description 	: This class is use to select the Health selection information
* @author 		: Ashwin Kasture
* @date 		: 13/11/2019
* MODIFICATION LOG
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		13/11/2019		Initial Version
*/
public with sharing class SSP_HealthSelectionCtrl
{
    /*
	* method 		: getHealthSelectionData
	* @description  : This method is use to retrive the Health Selection data from SSP_Member Object using SSP_ApplicationIndividual Object
	* @author 		: Ashwin Kasture
	* @param 		: String sApplicationId - Contains Application Id
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse getHealthSelectionData(String sApplicationId, String sMode)
    {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            List<SSP_HealthInformationWrapper> lstHealthInfoWrapper = new List<SSP_HealthInformationWrapper>();
            Map<String, Boolean> questionMap = new Map<String, Boolean>{
                        'showMedicalQuestions' => false,
                        'showCommunityQuestions' => false
                    }; // #385049
            sApplicationId = String.escapeSingleQuotes(sApplicationId);
            sMode = String.escapeSingleQuotes(sMode);
            lstHealthInfoWrapper = SSP_HealthInformationService.getHealthSelectionData(sApplicationId, sMode); 
            objResponse.bIsSuccess = true;
            objResponse.put('healthInformationData', lstHealthInfoWrapper);
            if(sMode == 'RAC'){
                
                /** #385049 */
                if(lstHealthInfoWrapper != null && !lstHealthInfoWrapper.isEmpty() && String.isNotBlank(lstHealthInfoWrapper[0].sRACSelectedOptions)){                                        
                    for(String questionKey : lstHealthInfoWrapper[0].sRACSelectedOptions.split(',')){
                        
                        if(questionKey.equalsIgnoreCase(SSP_GlobalConstants.EMERGENCY_MEDICAL_QUESTIONS)){
                            questionMap.put('showMedicalQuestions', true);
                        }
                        else if(questionKey.equalsIgnoreCase(SSP_GlobalConstants.CIS_CARETAKER_QUESTIONS)){
                            questionMap.put('showCommunityQuestions',true);
                        }
                    }
                    

                }
                /** */
             	SSP_HealthInformationService.createNavFlowStatuses(lstHealthInfoWrapper,sApplicationId,questionMap);   
            }  
            objResponse.put('questionsMap', questionMap); // #385049        
            objResponse.put('screenPermission', SSP_Utility.getScreenAccessDetails('SSP_APP_Select_Health', null).screenPermission);//CD2 2.5 Security Role Matrix and Program Access.


        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthSelectionCtrl', 'getHealthSelectionData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
	* method 		: storeHealthSelectionData
	* @description  : This method is use to update the SSP_Member data
	* @author 		: Ashwin Kasture
	* @param 		: String sMemberHealhSelectionData - contains the answed question data.
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse storeHealthSelectionData(String sApplicationId, String sMemberHealthSelectionData, String sApplicationData) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            sApplicationId = String.escapeSingleQuotes(sApplicationId);
            sMemberHealthSelectionData = String.escapeSingleQuotes(sMemberHealthSelectionData);
            sApplicationData = String.escapeSingleQuotes(sApplicationData);
            List<SSP_Member__c> lstUpdatedMembers = SSP_HealthInformationService.storeHealthSelectionData(sApplicationId, sMemberHealthSelectionData, sApplicationData);
            SSP_HealthInformationService.handleTrackDeletion(sApplicationId);
            objResponse.bIsSuccess = true;
            objResponse.put('lstUpdatedMembers',lstUpdatedMembers);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthSelectionCtrl', 'storeHealthSelectionData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
}