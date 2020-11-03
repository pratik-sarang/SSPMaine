/*
* classname 		: SSP_SSIBenefitCtrl
* @description 		: This is the Controller class for SSI Benefits.
* @author 			: Sai Kiran
* @date 			: 01/10/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_SSIBenefitCtrl {
       /*
* method 		: fetchSSIBenefits
* @description  : This method is used to fetch the SSI Benefits.
* @author 		: Sai Kiran Velpula
* @param 		: sMemberId - Id in string format
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse fetchSSIBenefits(String sMemberId){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_Benefits__c objSSIBenefit = new SSP_Benefits__c();
        List<SSP_Benefits__c> lstSSIBenefit = new List<SSP_Benefits__c>();
        SSP_SSIBenefitWrapper ssiBenefitRecords = new SSP_SSIBenefitWrapper();
        try{
            SSP_Utility.isAuthenticatedUser();
            sMemberId = String.escapeSingleQuotes(sMemberId);
            if(sMemberId != NULL){
                lstSSIBenefit = SSP_SSIBenefitService.fetchSSIBenefits(sMemberId);
                if(lstSSIBenefit.size() > 0){
                    objSSIBenefit = lstSSIBenefit[0];
                }
                if(objSSIBenefit != NULL){
                    ssiBenefitRecords.sBenefitId = objSSIBenefit.Id;
                    ssiBenefitRecords.dBenefitApplicationDate = objSSIBenefit.BenefitApplicationDate__c;
                    ssiBenefitRecords.dBenefitDenialDate = objSSIBenefit.BenefitDenialDate__c;
                    ssiBenefitRecords.sApplicationStatus = objSSIBenefit.StatusofApplication__c;
                    ssiBenefitRecords.sBenefitDenialReason = objSSIBenefit.BenefitDenialReason__c;
                }
            }
            objResponse.put('sBenefitRecords',ssiBenefitRecords);
            objResponse.bIsSuccess = true;
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SSIBenefitCtrl', 'fetchSSIBenefits', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
        }
        return objResponse;
    }
    
    /*
* method 		: updateSSIBenefits
* @description  : This method is used to update the SSI Benefits.
* @author 		: Sai Kiran Velpula
* @param 		: jsonObjBenefit - SSP_SSIBenefitWrapper in string format
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse updateSSIBenefits(String jsonObjBenefit){
        SSP_Benefits__c objSSIBenefit = new SSP_Benefits__c();
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<String> lstBenefitsFields = new List<String>{'BenefitApplicationDate__c','StatusofApplication__c','BenefitDenialReason__c','BenefitDenialDate__c'};
            try{
                if(jsonObjBenefit != NULL){
                    objSSIBenefit = SSP_SSIBenefitService.updateSSIBenefits(jsonObjBenefit);
                    if(objSSIBenefit != NULL ){
                        ESAPI.accessController().upsertAsUser(objSSIBenefit,lstBenefitsFields);
                    }
                }
                objResponse.bIsSuccess = true;
            }catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SSIBenefitCtrl', 'updateSSIBenefits', ex.getMessage() , true);
                objResponse.bIsSuccess = false;
            }
        return objResponse;
    }
}