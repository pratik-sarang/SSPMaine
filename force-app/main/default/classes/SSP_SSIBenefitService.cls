/*
* classname 		: SSP_SSIBenefitService
* @description 		: This is the service class for SSI Benefits.
* @author 			: Sai Kiran
* @date 			: 01/10/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_SSIBenefitService {
    public static Map<String,String> mapConditions = new Map<String,String>(); 
    Public static ID sObjectRecordType = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.OBJ_SSIBENEFIT, SSP_GlobalConstants.SSIBENEFIT_RECORDTYPE);
    /*
* method 		: fetchSSIBenefits
* @description  : This method is used to fetch the SSI Benefits. 
* @author 		: Sai Kiran
* @param 		: sMemberId - Member ID in string format
* @return 		: List<SSP_Benefits__c>
* */
    @AuraEnabled
    public static List<SSP_Benefits__c> fetchSSIBenefits(String sMemberId){
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        List<String> lstBenefitsFields = new List<String>{'BenefitApplicationDate__c','StatusofApplication__c','BenefitDenialReason__c','BenefitDenialDate__c'};
            try{
                SSP_Utility.isAuthenticatedUser();
                Boolean bViewBenefitsFields = ESAPI.accessController().isAuthorizedToView(SSP_Benefits__c.getSObjectType(), lstBenefitsFields);
                if(bViewBenefitsFields){ 
                    sMemberId = String.escapeSingleQuotes(sMemberId);
                    mapConditions.clear();
                    mapConditions.put('SSP_Member__c',sMemberId);
                    mapConditions.put('RecordTypeId',sObjectRecordType);
                    mapConditions.put('limit','1');
                    lstBenefits = SSP_BenefitsSelector.queryBenefitsData(new Map<String, String>{'hasToLabel'=>'false','objectName'=>'SSP_Benefits__c','operator'=>'AND'}, 
                                                                         new Set<String>{'ID','BenefitApplicationDate__c','StatusofApplication__c','BenefitDenialReason__c','BenefitDenialDate__c'}, 
                                                                         mapConditions);
                    
                }
            }catch(Exception e){
                LOG_LogMessageUtility.logMessage(e, 'SSP_SSIBenefitService', 'fetchSSIBenefits', e.getMessage(), true);
            }
        return lstBenefits;
    }
    
    
    /*
* method 		: updateSSIBenefits
* @description  : This method is used to update the SSI Benefits. 
* @author 		: Sai Kiran
* @param 		: jsonObjBenefit - SSP_SSIBenefitWrapper in string format
* @return 		: List<SSP_Benefits__c>
* */
    @AuraEnabled
    public static SSP_Benefits__c updateSSIBenefits(String jsonObjBenefit){
        SSP_Benefits__c objSSIBenefit;
        List<String> lstBenefitsFields = new List<String>{'BenefitApplicationDate__c','StatusofApplication__c','BenefitDenialReason__c','BenefitDenialDate__c'};
            SSP_SSIBenefitWrapper ssiBenefitWrapper = (SSP_SSIBenefitWrapper) JSON.deserialize(jsonObjBenefit, SSP_SSIBenefitWrapper.class);
        try{
            SSP_Utility.isAuthenticatedUser();
            Boolean bViewBenefitsFields = ESAPI.accessController().isAuthorizedToView(SSP_Benefits__c.getSObjectType(), lstBenefitsFields);
            if(bViewBenefitsFields){ 
                if(ssiBenefitWrapper.sBenefitId != NULL){
                    objSSIBenefit = new SSP_Benefits__c(ID = ssiBenefitWrapper.sBenefitId);
                }else{
                    objSSIBenefit = new SSP_Benefits__c();
                    objSSIBenefit.SSP_Member__c = ssiBenefitWrapper.sMemberId;
                }
                objSSIBenefit.BenefitApplicationDate__c = ssiBenefitWrapper.dBenefitApplicationDate;
                objSSIBenefit.StatusofApplication__c = ssiBenefitWrapper.sApplicationStatus;
                objSSIBenefit.BenefitDenialReason__c = ssiBenefitWrapper.sBenefitDenialReason;
                objSSIBenefit.BenefitDenialDate__c = ssiBenefitWrapper.dBenefitDenialDate;
                objSSIBenefit.RecordTypeId = sObjectRecordType;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_SSIBenefitService', 'updateSSIBenefits', e.getMessage(), true);
        }
        return objSSIBenefit;
    }
    
}