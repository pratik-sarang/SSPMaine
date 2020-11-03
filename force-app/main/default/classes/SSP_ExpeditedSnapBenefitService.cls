/*
* classname 		: SSP_ExpeditedSnapBenefitService
* @description 		: This is the Service class for Expedite SNAP Benefits.
* @author 			: Sai Kiran
* @date 			: 01/24/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_ExpeditedSnapBenefitService {
    
    /*
* method 		: fetchApplicationData
* @description  : This method is used to fetch Application Obj to display Expedited Snap Benefits.
* @author 		: Sai Kiran Velpula
* @param 		: sApplicationID - String
* @return 		: SSP_Application__c Object
* */
    @AuraEnabled
    public static SSP_Application__c fetchApplicationData(String sApplicationID){
        Map<String,String> mapConditions = new Map<String,String>();
        SSP_Application__c objApplication;
        List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
        List<String> lstApplicationFields = new List<String>{'ProgramsApplied__c','HouseholdTotalMonthlyGrossIncAmount__c','HouseholdTotalMonthlyCashSavingAmount__c','HasShelterExpExceedIncomeResourcesToggle__c','IsDestituteFarmOrMigrantHouseholdToggle__c'};
            try{
                SSP_Utility.isAuthenticatedUser();
                Boolean bViewApplicationFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), lstApplicationFields);
                if(bViewApplicationFields){ 
                    mapConditions.put('ID',sApplicationID);
                    mapConditions.put('limit','1');
                    lstApplications = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                   new Set<String>{'ID','ProgramsApplied__c','HouseholdTotalMonthlyGrossIncAmount__c','HouseholdTotalMonthlyCashSavingAmount__c','HasShelterExpExceedIncomeResourcesToggle__c','IsDestituteFarmOrMigrantHouseholdToggle__c'}, 
                                                                                   mapConditions);
                }
                if(lstApplications.size()>0){
                    objApplication = lstApplications[0];
                }
            }catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpeditedSnapBenefitService', 'fetchApplicationData', ex.getMessage() , true);
            }
        return objApplication;
    }
    
    /*
* method 		: updateApplication
* @description  : This method is used to update Application Obj with Expedited Snap Benefits.
* @author 		: Sai Kiran Velpula
* @param 		: sApplicationWrapper
* @return 		: SSP_Application__c Object
* */
    @AuraEnabled
    public static SSP_Application__c updateApplication(String sApplicationWrapper){
        SSP_ExpeditedSnapBenefitWrapper objApplicationWrap;
        SSP_Application__c objApplication;
        try{
            if(sApplicationWrapper != NULL && !String.isBlank(sApplicationWrapper)){
                objApplicationWrap = (SSP_ExpeditedSnapBenefitWrapper)JSON.deserialize(sApplicationWrapper, SSP_ExpeditedSnapBenefitWrapper.class);
                objApplication = new SSP_Application__c(ID = objApplicationWrap.sApplicationId);
                objApplication.HouseholdTotalMonthlyGrossIncAmount__c = objApplicationWrap.sGrossIncAmount;
                objApplication.HouseholdTotalMonthlyCashSavingAmount__c = objApplicationWrap.sCashSavingAmount;
                objApplication.HasShelterExpExceedIncomeResourcesToggle__c = objApplicationWrap.bShelterExpExceedIncomeResourcesToggle;
                objApplication.IsDestituteFarmOrMigrantHouseholdToggle__c = objApplicationWrap.bDestituteFarmOrMigrantHouseholdToggle;
            }
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpeditedSnapBenefitService', 'updateApplication', ex.getMessage() , true);
        }
        return objApplication;
    }
    
}