/*
* classname     : SSP_HealthEnrollmentSummaryCtrl
* @description  : This class is use to display the Healthcare Enrollment Summary Details
* @author       : Ashwin Kasture
* @date         : 05/12/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture        05/12/2019      Initial Version
*/
public with sharing class SSP_HealthEnrollmentSummaryCtrl
{
    /*
* method 		: getHealthEnrollmentSummary
* @description  : This method is use to get the Enrollment Summary details by Application Id
* @author 		: Ashwin Kasture
* @param 		: String sApplicationId - It is the Application Id
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse getHealthEnrollmentSummary(String sApplicationId, Boolean bIsEnrolledInInsurance)
    {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            List<SSP_HealthEnrollmentWrapper> lstHealthEnrollmentDetails = new List<SSP_HealthEnrollmentWrapper>();
            sApplicationId = String.escapeSingleQuotes(sApplicationId);
            lstHealthEnrollmentDetails = SSP_HealthEnrollmentSummaryService.getHealthEnrollmentSummary(sApplicationId, bIsEnrolledInInsurance);
            objResponse.bIsSuccess = true;
            objResponse.put('healthEnrollmentSummaryList', lstHealthEnrollmentDetails);
            
            /** 2.5	Security Role Matrix and Program Access. */ 
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_ENROLL_SUMMARY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HEALTHC_ENROLL_SUMMARY_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_ENROLL_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HEALTHC_ENROLL_DETAILS_SCREENID, null));                        
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_ENROLL_INDV_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HEALTHC_ENROLL_INDV_DETAILS_SCREENID, null));                        
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_ACCESS_SUMMARY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HEALTHC_ACCESS_SUMMARY_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_ACCESS_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HEALTHC_ACCESS_DETAILS_SCREENID, null));                        
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_ACCESS_INDV_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HEALTHC_ACCESS_INDV_DETAILS_SCREENID, null));                        
            /** */
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthEnrollmentSummaryCtrl', 'getHealthEnrollmentSummary', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
* method 		: removeInsurancePolicy
* @description  : This method is use to remove Insurance Policy
* @author 		: Ashwin Kasture
* @param 		: String sInsurancePolicyId
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse removeInsurancePolicy(String sInsurancePolicyId,String sAppId) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            sInsurancePolicyId = String.escapeSingleQuotes(sInsurancePolicyId);
            Map<String, Object> mapResponse = SSP_HealthEnrollmentSummaryService.removeInsurancePolicy(sInsurancePolicyId,sAppId);
            objResponse.bIsSuccess = true;
            objResponse.put('removeInsurancePolicy',mapResponse);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthEnrollmentSummaryCtrl', 'removeInsurancePolicy', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
* method 		: removeInsuranceCovInd
* @description  : This method is use to remove Insurance Covered Individual
* @author 		: Ashwin Kasture
* @param 		: String sInsuranceCovIndId
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse removeInsuranceCovInd(String sInsuranceCoverIndId,String sAppId) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            sInsuranceCoverIndId = String.escapeSingleQuotes(sInsuranceCoverIndId);
            Map<String, String> mapResponse = SSP_HealthEnrollmentSummaryService.removeInsuranceCovInd(sInsuranceCoverIndId,sAppId);
            objResponse.bIsSuccess = true;
            objResponse.put('removeInsuranceCoverInd',mapResponse);                        
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthEnrollmentSummaryCtrl', 'removeInsuranceCovInd', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
* method        : updateTrackDeletion
* @description  : This method is use to create SSP_TrackDeletion__c with Insurance Policy & Covered Individual Data
* @author       : Sai Kiran
* @param        : String sTrackDeletionWrapperData
* @return       : SSP_LightningResponse 
* */
    @AuraEnabled
    public static SSP_LightningResponse updateTrackDeletion(String sTrackDeletionWrapperData) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Boolean bIsUpdateSuccess = false;
        try{
            SSP_Utility.isAuthenticatedUser();
            sTrackDeletionWrapperData = String.escapeSingleQuotes(sTrackDeletionWrapperData);
            bIsUpdateSuccess = SSP_HealthEnrollmentSummaryService.updateTrackDeletion(sTrackDeletionWrapperData);
            objResponse.bIsSuccess = bIsUpdateSuccess;
        }catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthEnrollmentSummaryCtrl', 'updateTrackDeletion', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
}