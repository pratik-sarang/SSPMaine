/*
* classname 	: SSP_HealthCoverageSelectionCtrl
* @description 	: This class is use for Health coverage information screen
* @author 		: Ashwin Kasture
* @date 		: 22/11/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		22/11/2019		Initial Version
*/
public with sharing class SSP_HealthCoverageSelectionCtrl {
    /*
	* method 		: getHealthCoverageData
	* @description  : This method is use to retrive the Health Coverage Selection data from Application object.
	* @author 		: Ashwin Kasture
	* @param 		: String sApplicationId - Contains Application Id
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse getHealthCoverageData(String sApplicationId) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String,String> mapConditions = new Map<String,String>();
        Boolean bIsPolicyExist = false;
        Boolean bIsAccess = false;
        try{
            SSP_Utility.isAuthenticatedUser();
            List<SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper> lstHealthInfoWrapper = new List<SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper>();
            sApplicationId = String.escapeSingleQuotes(sApplicationId);
            List<SSP_ApplicationIndividual__c> lstAppIndRecords = SSP_HealthCoverageSelectionService.getAppIndData(sApplicationId);
            Set<String> memberIds = new Set<String>();
            for(SSP_ApplicationIndividual__c app : lstAppIndRecords){
                memberIds.add(app.SSP_Member__c);
            }
            List<SSP_InsuranceCoveredIndiv__c> lstPolicyMembers = [Select Id, SSP_InsurancePolicy__r.IsEnrolledInInsurance__c, SSP_InsurancePolicy__r.DCId__c
                                                      from SSP_InsuranceCoveredIndiv__c
                                                      where SSP_Member__c IN :memberIds
                                                      AND IsDeleted__c = false];
            for(SSP_InsuranceCoveredIndiv__c policy : lstPolicyMembers)
            {
                //Enrollment Summary Related
                if(policy.SSP_InsurancePolicy__r.IsEnrolledInInsurance__c && policy.SSP_InsurancePolicy__r.DCId__c != NULL){
                    objResponse.put('enrollmentApproved', true);
                    bIsPolicyExist = true;
                }
                //Access Summary Related
                if(!policy.SSP_InsurancePolicy__r.IsEnrolledInInsurance__c && policy.SSP_InsurancePolicy__r.DCId__c != NULL){
                    objResponse.put('accessApproved', true);
                    bIsAccess = true;
                }
            }
            
            mapConditions.put('ID',sApplicationId);
            mapConditions.put('limit','1');
            List<SSP_Application__c> lstApps = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                           new Set<String>{'ID','ProgramsApplied__c','EnrolledInHealthCareCoverageToggle__c','NotEnrolledInHealthCareCoverageToggle__c'}, 
                                                                           mapConditions);
            if(lstApps != NULL && !lstApps.isEmpty()){
                if(bIsPolicyExist){
                    lstApps[0].EnrolledInHealthCareCoverageToggle__c = 'Y';
                }
                if(bIsAccess){
                    lstApps[0].NotEnrolledInHealthCareCoverageToggle__c = 'Y';
                }
                //ESAPI.accessController().updateAsUser(lstApps[0], new List<String>{'EnrolledInHealthCareCoverageToggle__c','NotEnrolledInHealthCareCoverageToggle__c'});
            	SSP_GenericDMLHelper.updateRecords(lstApps,  new List<String>{'EnrolledInHealthCareCoverageToggle__c','NotEnrolledInHealthCareCoverageToggle__c'}); //Perf Fix: Removed ESAPI Call

            }
                        
            lstHealthInfoWrapper = SSP_HealthCoverageSelectionService.getHealthCoverageSelectionData(sApplicationId);
            objResponse.bIsSuccess = true;
            objResponse.put('healthCoverageData', lstHealthInfoWrapper);
        }catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthCoverageSelectionCtrl', 'getHealthCoverageData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    /*
	* method 		: storeHealthCoverageData
	* @description  : This method is use to update the SSP_Application data
	* @author 		: Ashwin Kasture
	* @param 		: String sMemberHealthCoverageData
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse storeHealthCoverageData(String sMemberHealthCoverageData) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try{
            SSP_Utility.isAuthenticatedUser();
            sMemberHealthCoverageData = String.escapeSingleQuotes(sMemberHealthCoverageData);
            SSP_Application__c objApp = SSP_HealthCoverageSelectionService.storeHealthCoverageData(sMemberHealthCoverageData);
            objResponse.bIsSuccess = true;
            objResponse.put('objUpdatedApplication',objApp);
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthCoverageSelectionCtrl', 'storeHealthCoverageData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
	* class 		: SSPHealthCoverageWrapper
	* @description  : This method is use to assign the Health Coverage Selection data of Application object.
	* @author 		: Ashwin Kasture
	* */
    public with sharing class SSPHealthCoverageWrapper {
        @AuraEnabled public String sEnrolledInHealthCareCoverage {get;set;}
        @AuraEnabled public String sNotEnrolledInHealthCareCoverage {get;set;}
        @AuraEnabled public String sProgramsApplied {get;set;}
        @AUraEnabled public String sMedicaidType {get;set;}
        @AuraEnabled public String sApplId {get;set;}
        @AuraEnabled public String sMemberId {get;set;}
    }
}