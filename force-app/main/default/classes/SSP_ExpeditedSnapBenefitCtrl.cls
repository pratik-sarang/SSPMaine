/*
* classname 		: SSP_ExpeditedSnapBenefitCtrl
* @description 		: This is the Controller class for Expedited SNAP Benefits.
* @author 			: Sai Kiran
* @date 			: 01/24/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_ExpeditedSnapBenefitCtrl {
    
    
    /*
* method 		: fetchApplicationData
* @description  : This method is used to fetch Application Obj with Expedited Snap Benefits.
* @author 		: Sai Kiran Velpula
* @param 		: sApplicationID - String
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse fetchApplicationData(String sApplicationID){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_ExpeditedSnapBenefitWrapper objAppWrap;
        SSP_Application__c objApplication;      
        try{
            SSP_Utility.isAuthenticatedUser();
            if(sApplicationID != NULL && String.isNotBlank(sApplicationID)){
                sApplicationID = String.escapeSingleQuotes(sApplicationID);
                objApplication = SSP_ExpeditedSnapBenefitService.fetchApplicationData(sApplicationID);
            }
            if(objApplication != NULL){
                objAppWrap = new SSP_ExpeditedSnapBenefitWrapper();
                objAppWrap.sGrossIncAmount = objApplication.HouseholdTotalMonthlyGrossIncAmount__c;
                objAppWrap.sCashSavingAmount = objApplication.HouseholdTotalMonthlyCashSavingAmount__c;
                objAppWrap.bDestituteFarmOrMigrantHouseholdToggle = objApplication.IsDestituteFarmOrMigrantHouseholdToggle__c;
                objAppWrap.bShelterExpExceedIncomeResourcesToggle = objApplication.HasShelterExpExceedIncomeResourcesToggle__c;
            }
            objResponse.put('objApplicationWrap',objAppWrap);
            objResponse.bIsSuccess = true;
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpeditedSnapBenefitService', 'fetchApplicationData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
        }
        
        return objResponse;
    }
    /*
* method 		: updateApplication
* @description  : This method is used to update Application Obj with Expedited Snap Benefits.
* @author 		: Sai Kiran Velpula
* @param 		: sApplicationWrapper
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse updateApplication(String sApplicationWrapper){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_Application__c objApplication;
        List<String> lstApplicationFields = new List<String>{'HouseholdTotalMonthlyGrossIncAmount__c','HouseholdTotalMonthlyCashSavingAmount__c','HasShelterExpExceedIncomeResourcesToggle__c','IsDestituteFarmOrMigrantHouseholdToggle__c'};
            try{
                objApplication = SSP_ExpeditedSnapBenefitService.updateApplication(sApplicationWrapper);
                if(objApplication != NULL ){
                    ESAPI.accessController().updateAsUser(objApplication, lstApplicationFields);
                }
                objResponse.bIsSuccess = true;
            }catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpeditedSnapBenefitService', 'updateApplication', ex.getMessage() , true);
                objResponse.bIsSuccess = false;
            }
        
        return objResponse;
    }
    
    
}