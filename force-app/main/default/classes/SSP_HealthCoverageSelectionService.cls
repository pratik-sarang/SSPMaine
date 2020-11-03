/*
* classname 	: SSP_HealthCoverageSelectionService
* @description 	: This class is use for Health Coverage information screen
* @author 		: Ashwin Kasture
* @date 		: 22/11/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		22/11/2019		Initial Version
*/
public with sharing class SSP_HealthCoverageSelectionService {
    /*
	* method 		: getHealthSelectionData
	* @description  : This method is use to get the Application data by Application Id
	* @author 		: Ashwin Kasture
	* @param 		: String sApplicationId - It is the Application Id
	* @return 		: List<SSP_HealthInformationWrapper>
	* */
    public static List<SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper> getHealthCoverageSelectionData(String sApplicationId) {
        List<SSP_ApplicationIndividual__c> lstAppIndRecords = new List<SSP_ApplicationIndividual__c>();
        List<SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper> lstHealthInfoWrapper = new List<SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper>();
        lstAppIndRecords = getAppIndData(sApplicationId);
        
        if(!lstAppIndRecords.isEmpty()) {
            for(SSP_ApplicationIndividual__c objAppInd: lstAppIndRecords) {
                lstHealthInfoWrapper.add(assignHealthWrapperData(objAppInd));
            }
        }
        return lstHealthInfoWrapper;
    }
    
    /*
	* method 		: getAppIndData
	* @description  : This method is use to get the SSP Application Individual data by Application Id and Member Id
	* @author 		: Ashwin Kasture
	* @param 		: String sApplicationId - It is the Application Id
					  String sMemberId - It is the Member Id
	* @return 		: List<SSP_ApplicationIndividual__c>
	* */
    public static List<SSP_ApplicationIndividual__c> getAppIndData(String sApplicationId) {
        SSP_Utility.isAuthenticatedUser();
        List<SSP_ApplicationIndividual__c> lstAppIndRecords = new List<SSP_ApplicationIndividual__c>();
        Map<String, String> conditionMap = new Map<String, String>();
        List<String> lstSSPAppFields = new List<String> {'ProgramsApplied__c','EnrolledInHealthCareCoverageToggle__c','NotEnrolledInHealthCareCoverageToggle__c'};
		List<String> lstAppIndFields = new List<String> {'Id','ProgramsApplied__c','SSP_Application__c','SSP_Member__c','MedicaidType__c'};
        Boolean canViewSSPAppFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), lstSSPAppFields);
        Boolean canViewSSPAppIndFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), lstAppIndFields);
        if(canViewSSPAppFields && canViewSSPAppIndFields) {
            Set<String> allApplIndFieldSet = new Set<String> {
                'Id', 'ProgramsApplied__c', 'MedicaidType__c', 'SSP_Application__c', 'SSP_Member__c', 'SSP_Application__r.ProgramsApplied__c', 
                'SSP_Application__r.EnrolledInHealthCareCoverageToggle__c', 'SSP_Application__r.NotEnrolledInHealthCareCoverageToggle__c'
            };
			conditionMap.put('SSP_Application__c', sApplicationId);            
            lstAppIndRecords = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'},
                allApplIndFieldSet,
                conditionMap
            );
        }
        return lstAppIndRecords;
    }
    
    /*
	* method 		: storeHealthCoverageData
	* @description  : This method is use to update the Application data
	* @author 		: Ashwin Kasture
	* @param 		: String sMemberHealthCoverageData - Contains the Applicaton data
	* @return 		: SSP_Application__c
	* */
    public static SSP_Application__c storeHealthCoverageData(String sMemberHealthCoverageData) {
        SSP_Utility.isAuthenticatedUser();
        SSP_Application__c objApp = new SSP_Application__c();
        SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper objEnrollmentWrapper =  
            (SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper) JSON.deserialize (
                sMemberHealthCoverageData, 
                SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper.class
            );
        objApp.Id = objEnrollmentWrapper.sApplId;
        if(objEnrollmentWrapper.sEnrolledInHealthCareCoverage != null) {
        	objApp.EnrolledInHealthCareCoverageToggle__c = objEnrollmentWrapper.sEnrolledInHealthCareCoverage;
        }
        if(objEnrollmentWrapper.sNotEnrolledInHealthCareCoverage != null) {
        	objApp.NotEnrolledInHealthCareCoverageToggle__c  = objEnrollmentWrapper.sNotEnrolledInHealthCareCoverage;
        }
        if(objApp != null) {
            ESAPI.accessController().updateAsUser(objApp, SSP_Utility.getFieldsNamesObject(objApp));
        }
        return objApp;
    }

    /*
	* method 		: assignHealthWrapperData
	* @description  : This method is use set the health selection wrapper data
	* @author 		: Ashwin Kasture
	* @param 		: SSP_Application__c objApp - Contains single application data
	* @return 		: SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper
	* */
    public static SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper assignHealthWrapperData(SSP_ApplicationIndividual__c objAppInd) {
        SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper objWrapperData = new SSP_HealthCoverageSelectionCtrl.SSPHealthCoverageWrapper();
        objWrapperData.sApplId = objAppInd.SSP_Application__c;
        objWrapperData.sMemberId = objAppInd.SSP_Member__c;
        objWrapperData.sProgramsApplied = objAppInd.SSP_Application__r.ProgramsApplied__c;
        objWrapperData.sMedicaidType = objAppInd.MedicaidType__c;
        objWrapperData.sEnrolledInHealthCareCoverage = objAppInd.SSP_Application__r.EnrolledInHealthCareCoverageToggle__c;
        objWrapperData.sNotEnrolledInHealthCareCoverage = objAppInd.SSP_Application__r.NotEnrolledInHealthCareCoverageToggle__c;
        return objWrapperData;
    }
}
