/*
* classname 	: SSP_EnrollmentDetailsCtrl
* @description 	: This class is used for Enrollment Details screen.
* @author 		: Ashwin Kasture
* @date 		: 14/12/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture		14/12/2019		Initial Version
*/
public with sharing class SSP_EnrollmentDetailsCtrl {
    /*
    * method        : getEnrollmentDetails
    * @description  : This method is use to get the Enrollment Details by Application Id
    * @author       : Ashwin Kasture
    * @param        : String sApplicationId - It is the Application Id
    * 				: Boolean bIsEnrolledInInsurance - If True then load Enrollment Details, If False then load Access Details
    * @return       : List<SSP_HealthEnrollmentWrapper>
    * */
    @AuraEnabled
	public static SSP_LightningResponse getEnrollmentDetails(String sApplicationId, String sInsurancePolicyId, Boolean bIsEnrolledInInsurance) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {            
            SSP_Utility.isAuthenticatedUser();
            Boolean isSpanish = UserInfo.getLanguage() == System.Label.SSP_SpanishLanguageCode;
            SSP_EnrollmentDetailsWrapper objEnrollmentDetailsWrapper = new SSP_EnrollmentDetailsWrapper();
            sApplicationId = String.escapeSingleQuotes(sApplicationId);
            sInsurancePolicyId = String.escapeSingleQuotes(sInsurancePolicyId);
            objEnrollmentDetailsWrapper = SSP_HealthEnrollmentSummaryService.getEnrollmentDetails(sApplicationId, sInsurancePolicyId, bIsEnrolledInInsurance);
            objResponse.bIsSuccess = true;
            objResponse.put('enrollmentDetailsData', objEnrollmentDetailsWrapper);
            objResponse.put('isSpanishFlag', isSpanish);
        } catch(Exception ex) {
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, LOG_LogMessageUtility.logMessage(ex, 'SSP_EnrollmentDetailsCtrl', 'getEnrollmentDetails', ex.getMessage() , true)[0].Id);
        }
        return objResponse;
    }
    /*
	* method 		: storeEnrollmentDetailsData
	* @description  : This method is use to store the Enrollment details
	* @author 		: Ashwin Kasture
	* @param 		: String sEnrollmentDetailResponse - Response from component to store data.
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse storeEnrollmentDetailsData(String sEnrollmentDetailResponse) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            sEnrollmentDetailResponse = String.escapeSingleQuotes(sEnrollmentDetailResponse);
            Map<String, Object> mapEnrollmentResponse = SSP_HealthEnrollmentSummaryService.storeEnrollmentDetailsData(sEnrollmentDetailResponse);
            objResponse.bIsSuccess = true;
            objResponse.put('objResponse', mapEnrollmentResponse);
        } catch(Exception ex) {
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, LOG_LogMessageUtility.logMessage(ex, 'SSP_EnrollmentDetailsCtrl', 'storeEnrollmentDetailsData', ex.getMessage() , true)[0].Id);
        }
        return objResponse;
    }
}