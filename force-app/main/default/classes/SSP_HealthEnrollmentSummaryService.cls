/*
* classname     : SSP_HealthEnrollmentSummaryService
* @description  : This class is use to fetch the details of Healthcare Enrollment Summary
* @author       : Ashwin Kasture
* @date         : 05/12/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture        05/12/2019      Initial Version
*/
public with sharing class SSP_HealthEnrollmentSummaryService {
    /*
    * method        : getHealthEnrollmentSummary
    * @description  : This method is use to get the Enrollment Summary details by Application Id
    * @author       : Ashwin Kasture
    * @param        : String sApplicationId - It is the Application Id
    * @return       : List<SSP_HealthEnrollmentWrapper>
    * */
    public static List<SSP_HealthEnrollmentWrapper> getHealthEnrollmentSummary(String sApplicationId, Boolean bIsEnrolledInInsurance)
    {
        SSP_Utility.isAuthenticatedUser();
        String strMemberIds = '';
        String strCoveredIndId = '';
        List<String> lstOfCoverIndId = new List<String>(); 
        List<SSP_HealthEnrollmentWrapper> lstHealthEnrollmentDetails = new List<SSP_HealthEnrollmentWrapper>();
        Map<String, List<SSP_InsuranceCoveredIndiv__c>> mapPolicyIdVsInsuranceCovInd = new Map<String, List<SSP_InsuranceCoveredIndiv__c>>();
        Map<String, List<SSP_HealthInsuranceFacilityType__c>> mapCoveredIndVsFacilityType = new Map<String, List<SSP_HealthInsuranceFacilityType__c>>();        
        List<SSP_HealthInsuranceFacilityType__c> lstHealthInsuranceFacility = new List<SSP_HealthInsuranceFacilityType__c>();        
        
        List<String> lstApplnIndFields = new List<String>{'Id','SSP_Member__c','SSP_Application__c'};            
            Boolean canViewApplIndFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), lstApplnIndFields);
        
        List<String> lstInsurancePolicyFields = new List<String>{'InsurancePolicyNumber__c','PlanName__c','TypeOfCoverageCode__c'};        
            Boolean canViewInsurancePolicyFields = ESAPI.accessController().isAuthorizedToView(SSP_InsurancePolicy__c.getSObjectType(), lstInsurancePolicyFields);        
        
        List<String> lstInsuranceCovIndFields = new List<String>{'Id','SSP_InsurancePolicy__c','SSP_Member__c','IsInsuranceCovered__c','FirstName__c','LastName__c','IsPolicyHolder__c','IsDefault__c'};        
            Boolean canViewInsuranceCovIndFields = ESAPI.accessController().isAuthorizedToView(SSP_InsuranceCoveredIndiv__c.getSObjectType(), lstInsuranceCovIndFields);
        
        List<String> lstHealthInsuranceFacilityFields = new List<String> {'Id', 'SSP_InsuranceCoveredIndiv__c', 'FacilityType__c'};
            Boolean canViewtHealthInsuranceFacilityFields = ESAPI.accessController().isAuthorizedToView(SSP_HealthInsuranceFacilityType__c.getSObjectType(), lstHealthInsuranceFacilityFields);
        
        if(canViewApplIndFields && canViewInsurancePolicyFields && canViewInsuranceCovIndFields && canViewtHealthInsuranceFacilityFields) {
            // Get SSP_ApplicationIndividual object data
            Set<String> setApplnIndFields = new Set<String>(lstApplnIndFields);
            Map<String, String> mapAppIndCondition = new Map<String, String>{'SSP_Application__c' => sApplicationId};
                List<SSP_ApplicationIndividual__c> lstAppInd = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                    new Map<String, String> {'objectName'=>'SSP_ApplicationIndividual__c'},
                    setApplnIndFields,
                    mapAppIndCondition
                );
            
            // Get SSP_InsuranceCoveredIndiv object data
            List<String> lstMemId = new List<String>();
            for(SSP_ApplicationIndividual__c objAppInd: lstAppInd) {
                lstMemId.add(objAppInd.SSP_Member__c);
            }            
            strMemberIds = String.join(lstMemId, ',');
            Set<String> setInsuranceCovIndFields = new Set<String> {
                'Id','SSP_InsurancePolicy__c','SSP_Member__c','IsInsuranceCovered__c','SSP_InsurancePolicy__r.InsurancePolicyNumber__c','DCId__c','SSP_InsurancePolicy__r.DCId__c',
                    'SSP_InsurancePolicy__r.PlanName__c','SSP_InsurancePolicy__r.TypeOfCoverageCode__c','FirstName__c','LastName__c','IsPolicyHolder__c',
                    'SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','ExtPolicyHolderFirstName__c','ExtPolicyHolderLastName__c','IsDefault__c',
                    'DCInsuranceCoveredIndivId__c','IsTobbacoConsumerToggle__c','SSP_InsurancePolicy__r.IsHealthCareCoverageApproved__c'
                    };
                    //'IsEnrolled__c'=> String.valueOf(bIsEnrolledInInsurance) -> Removed this condition to identify external policy holder
                        Map<String, String> mapInsuranceCovIndCondition = new Map<String, String> {
                            'SSP_Member__c' => strMemberIds,
                                'SSP_InsurancePolicy__r.IsEnrolledInInsurance__c' => String.valueOf(bIsEnrolledInInsurance),                                
                                'SSP_InsurancePolicy__r.IsDeleted__c'=> String.valueOf(false),
                                'IsDeleted__c'=> String.valueOf(false)
                                };
                                    /*List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData (
                                        new Map<String, String> {
                                            'objectName'=>'SSP_InsuranceCoveredIndiv__c',
                                                'IN'=>'SSP_Member__c',
                                                'operator'=>'AND'
                                                },
                                        setInsuranceCovIndFields,
                                        mapInsuranceCovIndCondition
                                    );*/
                                    //Start - CD1 security fixes
                                    List<SSP_InsuranceCoveredIndiv__c> lstCovIndWithMember = SSP_SharingBypassFetcher.fetchRecords (
                                        new Map<String, String> {
                                            'objectName'=>'SSP_InsuranceCoveredIndiv__c',
                                                'IN'=>'SSP_Member__c',
                                                'operator'=>'AND'
                                                },
                                        setInsuranceCovIndFields,
                                        mapInsuranceCovIndCondition
                                    );
            						//End - CD1 security fixes
            List<String> lstPolicyId = new List<String>();
            String strPolicyId = '';
            // Get Insurance Policy Id
            for(SSP_InsuranceCoveredIndiv__c objCoverId: lstCovIndWithMember) {                
                lstPolicyId.add(objCoverId.SSP_InsurancePolicy__c);
            }            
            strPolicyId = String.join(lstPolicyId, ',');
            Map<String, String> mapCovIndCondition = new Map<String, String> {
                            'SSP_InsurancePolicy__c' => strPolicyId,
                                'SSP_InsurancePolicy__r.IsEnrolledInInsurance__c' => String.valueOf(bIsEnrolledInInsurance),                                
                                'SSP_InsurancePolicy__r.IsDeleted__c'=> String.valueOf(false),
                                'IsDeleted__c'=> String.valueOf(false)
                                };
            						//Start - CD1 security fixes
                                    List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_SharingBypassFetcher.fetchRecords (
                                        new Map<String, String> {
                                            'objectName'=>'SSP_InsuranceCoveredIndiv__c',
                                                'IN'=>'SSP_InsurancePolicy__c',
												'operator'=>'AND'                                                
                                                },
                                        setInsuranceCovIndFields,
                                        mapCovIndCondition
                                    );
            						//End - CD1 security fixes
			//Defect 373265
			Map<String,Set<String>> mapAppInd = new Map<String,Set<String>>();
			List<SSP_ApplicationIndividual__c> lstAppInds = new List<SSP_ApplicationIndividual__c>();
            List<SSP_InsuranceCoveredIndiv__c> lstToUpdateInternalCovInd = new List<SSP_InsuranceCoveredIndiv__c>();
			List<SSP_InsuranceCoveredIndiv__c> lstInternalCovInd = new List<SSP_InsuranceCoveredIndiv__c>();
            Set<String> setMemberIds = new Set<String>();
            ID sRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_InsuranceCoveredIndiv__c','InsuranceExternalCoveredIndividual');
            for(SSP_InsuranceCoveredIndiv__c objInsCovInd : lstInsuranceCovInd){
                if(objInsCovInd.IsPolicyHolder__c == False && objInsCovInd.SSP_Member__c != NULL){
                    lstInternalCovInd.add(objInsCovInd);
                    setMemberIds.add(objInsCovInd.SSP_Member__c);
                }
            }
            if(!setMemberIds.isEmpty()){
                lstAppInds = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                    new Map<String, String> {'objectName'=>'SSP_ApplicationIndividual__c','IN'=>'SSP_Member__c'},
                    setApplnIndFields,
                    new Map<String, String>{'SSP_Member__c' => String.join(new List<String>(setMemberIds), ',')}
                );
            }
            if(!lstAppInds.isEmpty()){
                for(SSP_ApplicationIndividual__c objAppInd : lstAppInds){
                    Set<String> setObjApInd = new Set<String>();
                    String sKey = objAppInd.SSP_Member__c;
                    if(mapAppInd.get(sKey) != NULL){
                       mapAppInd.get(sKey).add(String.valueOf(objAppInd.SSP_Application__c)); 
                    }else{
                        setObjApInd.add(String.valueOf(objAppInd.SSP_Application__c));
                        mapAppInd.put(sKey,setObjApInd);
                    }
                }
            }
            if(!lstInternalCovInd.isEmpty()){
                for(SSP_InsuranceCoveredIndiv__c objInsCovInd : lstInternalCovInd){
                    String sKeyToFind = objInsCovInd.SSP_Member__c;
                    if(mapAppInd != NULL && mapAppInd.keySet() != NULL && mapAppInd.get(sKeyToFind) == NULL){
                        objInsCovInd.RecordTypeId = sRecordTypeId;
                        lstToUpdateInternalCovInd.add(objInsCovInd);
                    }else if(mapAppInd != NULL && mapAppInd.keySet() != NULL && mapAppInd.get(sKeyToFind) != NULL && !(mapAppInd.get(sKeyToFind).contains(String.valueOf(sApplicationId)))){
                        objInsCovInd.RecordTypeId = sRecordTypeId;
                        lstToUpdateInternalCovInd.add(objInsCovInd);
                    }
                }
            }
            if(!lstToUpdateInternalCovInd.isEmpty()){
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstToUpdateInternalCovInd, 'update', 'SSP_InsuranceCoveredIndiv__c');
            }
			//End
			//List will get the updated Records
            lstInsuranceCovInd = SSP_SharingBypassFetcher.fetchRecords (
                                        new Map<String, String> {
                                            'objectName'=>'SSP_InsuranceCoveredIndiv__c',
                                                'IN'=>'SSP_InsurancePolicy__c',
												'operator'=>'AND'                                                
                                                },
                                        setInsuranceCovIndFields,
                                        mapCovIndCondition);
            
            
            // Get SSP_HealthInsuranceFacilityType Object data
            for(SSP_InsuranceCoveredIndiv__c objCoverId: lstInsuranceCovInd) {
                lstOfCoverIndId.add(objCoverId.Id);
            }
            strCoveredIndId = String.join(lstOfCoverIndId, ',');            
            Set<String> setHealthInsuranceFacilityFields = new Set<String> {'Id', 'SSP_InsuranceCoveredIndiv__c', 'toLabel(FacilityType__c)'};
                Map<String, String> mapHealthInsuranceFacilityCondition = new Map<String, String> {
                    'SSP_InsuranceCoveredIndiv__c' => strCoveredIndId
                        };
                            /*lstHealthInsuranceFacility = SSP_HealthInsuranceFacilityTypeSelector.queryHealthInsuranceFacilityTypeData (
                                new Map<String, String> {
                                    'hasToLabel'=>'true',
                                        'objectName'=>'SSP_HealthInsuranceFacilityType__c',
                                        'IN'=>'SSP_InsuranceCoveredIndiv__c'
                                        },
                                setHealthInsuranceFacilityFields,
                                mapHealthInsuranceFacilityCondition
                            );*/
                            //Start - CD1 security fixes
                            lstHealthInsuranceFacility = SSP_SharingBypassFetcher.fetchRecords (
                                new Map<String, String> {
                                    'hasToLabel'=>'true',
                                        'objectName'=>'SSP_HealthInsuranceFacilityType__c',
                                        'IN'=>'SSP_InsuranceCoveredIndiv__c'
                                        },
                                setHealthInsuranceFacilityFields,
                                mapHealthInsuranceFacilityCondition
                            );
            				//End - CD1 security fixes
            mapPolicyIdVsInsuranceCovInd = getPolicyVsInsuranceCovId(lstInsuranceCovInd);
            mapCoveredIndVsFacilityType = getCoveredIndVsFacilityType(lstHealthInsuranceFacility);
            lstHealthEnrollmentDetails = setHealthEnrollWrapperData(mapPolicyIdVsInsuranceCovInd, mapCoveredIndVsFacilityType, lstHealthEnrollmentDetails,bIsEnrolledInInsurance);
        }
        return lstHealthEnrollmentDetails;
    }
    
    /*
* method        : getPolicyVsInsuranceCovId
* @description  : This method is use to set Map of Plocity Id with List of Insurance Covered Individual
* @author       : Ashwin Kasture
* @param        : List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd
* @return       : Map<String, List<SSP_InsuranceCoveredIndiv__c>>
* */
    public static Map<String, List<SSP_InsuranceCoveredIndiv__c>> getPolicyVsInsuranceCovId(List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd) {
        Map<String, List<SSP_InsuranceCoveredIndiv__c>> mapPolicyIdVsInsuranceCovInd = new Map<String, List<SSP_InsuranceCoveredIndiv__c>>();
        for(SSP_InsuranceCoveredIndiv__c objIndCov: lstInsuranceCovInd) {
            if(mapPolicyIdVsInsuranceCovInd.containsKey(objIndCov.SSP_InsurancePolicy__c)) {
                List<SSP_InsuranceCoveredIndiv__c> lstCovInd = mapPolicyIdVsInsuranceCovInd.get(objIndCov.SSP_InsurancePolicy__c);
                lstCovInd.add(objIndCov);
                mapPolicyIdVsInsuranceCovInd.put(objIndCov.SSP_InsurancePolicy__c,lstCovInd);
            } else {
                mapPolicyIdVsInsuranceCovInd.put(objIndCov.SSP_InsurancePolicy__c, new List<SSP_InsuranceCoveredIndiv__c>{objIndCov});
            }
        }
        return mapPolicyIdVsInsuranceCovInd;
    }
    
    /*
    * method        : getCoveredIndVsFacilityType
    * @description  : This method is use to set Map of Covered Individual Id with List of Health Insurance Facility type
    * @author       : Ashwin Kasture
    * @param        : List<SSP_HealthInsuranceFacilityType__c> lstHealthInsuranceFacility
    * @return       : Map<String, List<SSP_HealthInsuranceFacilityType__c>>
    * */
    public static Map<String, List<SSP_HealthInsuranceFacilityType__c>> getCoveredIndVsFacilityType(List<SSP_HealthInsuranceFacilityType__c> lstHealthInsuranceFacility) {
        Map<String, List<SSP_HealthInsuranceFacilityType__c>> mapCoveredIndVsFacilityType = new Map<String, List<SSP_HealthInsuranceFacilityType__c>>();
        for(SSP_HealthInsuranceFacilityType__c objIndCov: lstHealthInsuranceFacility) {
            if(mapCoveredIndVsFacilityType.containsKey(objIndCov.SSP_InsuranceCoveredIndiv__c)) {
                List<SSP_HealthInsuranceFacilityType__c> lstCovInd = mapCoveredIndVsFacilityType.get(objIndCov.SSP_InsuranceCoveredIndiv__c);
                lstCovInd.add(objIndCov);
                mapCoveredIndVsFacilityType.put(objIndCov.SSP_InsuranceCoveredIndiv__c, lstCovInd);
            } else {
                mapCoveredIndVsFacilityType.put(objIndCov.SSP_InsuranceCoveredIndiv__c, new List<SSP_HealthInsuranceFacilityType__c>{objIndCov});
            }
        }
        return mapCoveredIndVsFacilityType;
    }
    
    /*
    * method        : setHealthEnrollWrapperData
    * @description  : This method is use to set Enrollment Summary Wrapper Data
    * @author       : Ashwin Kasture
    * @param        : Map<String, List<SSP_InsuranceCoveredIndiv__c>> mapPolicyIdVsInsuranceCovInd, List<SSP_HealthEnrollmentWrapper> lstHealthEnrollmentDetails
    * @return       : List<SSP_HealthEnrollmentWrapper>
    * */
    public static List<SSP_HealthEnrollmentWrapper> setHealthEnrollWrapperData(Map<String, List<SSP_InsuranceCoveredIndiv__c>> mapPolicyIdVsInsuranceCovInd, Map<String, List<SSP_HealthInsuranceFacilityType__c>> mapCoveredIndVsFacilityType, List<SSP_HealthEnrollmentWrapper> lstHealthEnrollmentDetails,Boolean bIsEnrolledInInsurance) {
        Map<String,String> mapTypeCoverageCode =  SSP_Utility.getPickListValues('SSP_InsurancePolicy__c', 'TypeOfCoverageCode__c', null);       
        Map<String,String> mapSourceCoveragePrograms = new Map<String,String>();
        Boolean bIsCoverageCodeMatching = false;
        Boolean bIsCovIndHOH = false;
        Boolean bIsExtPH = false;
        
        List<SSP_SourcesOfCoverage__mdt> lstAllSourceOfCoverage = [SELECT DeveloperName, SourceOfCoverageValue__c, Programs_Applied__c 
                                                                       FROM SSP_SourcesOfCoverage__mdt Limit 1000];            
        for(SSP_SourcesOfCoverage__mdt objSource : lstAllSourceOfCoverage){
            mapSourceCoveragePrograms.put(objSource.DeveloperName,objSource.Programs_Applied__c);
        }  
        for(String strPolicyId: mapPolicyIdVsInsuranceCovInd.keyset()) {
            SSP_HealthEnrollmentWrapper objHealthEnrollmentSum = new SSP_HealthEnrollmentWrapper();
            List<SSP_HealthEnrollmentWrapper.SSP_CoveredIndCls> lstCovIndWrapper = new List<SSP_HealthEnrollmentWrapper.SSP_CoveredIndCls>();
            List<SSP_InsuranceCoveredIndiv__c> lstCovInd = mapPolicyIdVsInsuranceCovInd.get(strPolicyId);
            for(SSP_InsuranceCoveredIndiv__c objMemCov: lstCovInd) {
                SSP_HealthEnrollmentWrapper.SSP_CoveredIndCls objCovInd;
                SSP_HealthEnrollmentWrapper.SSP_CoveredIndCls objExtCovInd;
                objHealthEnrollmentSum.sInsurancePolicyId = objMemCov.SSP_InsurancePolicy__c;
                objHealthEnrollmentSum.sPolicyNumber = objMemCov.SSP_InsurancePolicy__r.InsurancePolicyNumber__c;
                objHealthEnrollmentSum.sPlanName = objMemCov.SSP_InsurancePolicy__r.PlanName__c;
                objHealthEnrollmentSum.sTypeOfCoverageCode = mapTypeCoverageCode.get(objMemCov.SSP_InsurancePolicy__r.TypeOfCoverageCode__c);
                objHealthEnrollmentSum.sTypeOfCoverageCodeName = objMemCov.SSP_InsurancePolicy__r.TypeOfCoverageCode__c;
                objHealthEnrollmentSum.sPolicyDCId = ((objMemCov.SSP_InsurancePolicy__r.DCId__c != NULL) ? (objMemCov.SSP_InsurancePolicy__r.DCId__c).intValue() : NULL);
                if(objHealthEnrollmentSum.sPolicyDCId != NULL && bIsEnrolledInInsurance){
                    objHealthEnrollmentSum.bIsWPRecord = true;
                } else {
                    objHealthEnrollmentSum.bIsWPRecord = false;
                }
                if(mapSourceCoveragePrograms.get(objMemCov.SSP_InsurancePolicy__r.TypeOfCoverageCode__c) != NULL && mapSourceCoveragePrograms.get(objMemCov.SSP_InsurancePolicy__r.TypeOfCoverageCode__c).contains('KP')){
                    bIsCoverageCodeMatching = true;
                }
                //Set the Policy Holder data
                if(objMemCov.IsPolicyHolder__c && objMemCov.SSP_Member__c != null) {
                    objHealthEnrollmentSum.sPolicyHolderId = objMemCov.Id;
                    objHealthEnrollmentSum.sPolicyHolderFirstName = objMemCov.SSP_Member__r.FirstName__c;
                    objHealthEnrollmentSum.sPolicyHolderLastName = objMemCov.SSP_Member__r.LastName__c;
                    objHealthEnrollmentSum.bPolicyHolderIsHealthFacilityExist = (objMemCov.IsTobbacoConsumerToggle__c != NULL || (objMemCov.DCInsuranceCoveredIndivId__c != NULL) || (mapCoveredIndVsFacilityType != null && mapCoveredIndVsFacilityType.get(objMemCov.Id) != null && !mapCoveredIndVsFacilityType.get(objMemCov.Id).isEmpty()))? true: false;
                } else if(objMemCov.IsPolicyHolder__c && objMemCov.SSP_Member__c == null) {
                    objHealthEnrollmentSum.sPolicyHolderId = objMemCov.Id;
                    objHealthEnrollmentSum.sPolicyHolderFirstName = objMemCov.ExtPolicyHolderFirstName__c;
                    objHealthEnrollmentSum.sPolicyHolderLastName = objMemCov.ExtPolicyHolderLastName__c;
                    objHealthEnrollmentSum.bPolicyHolderIsHealthFacilityExist = (objMemCov.IsTobbacoConsumerToggle__c != NULL || (objMemCov.DCInsuranceCoveredIndivId__c != NULL) || ( mapCoveredIndVsFacilityType != null && mapCoveredIndVsFacilityType.get(objMemCov.Id) != null && !mapCoveredIndVsFacilityType.get(objMemCov.Id).isEmpty()))? true: false;
                    if(objMemCov.DCInsuranceCoveredIndivId__c != NULL){
                        bIsExtPH = true;
                    }
                }
                //Set the Covered Individual data
                if(!objMemCov.IsPolicyHolder__c && objMemCov.SSP_Member__c != null) {
                    objCovInd = new SSP_HealthEnrollmentWrapper.SSP_CoveredIndCls();
                    objCovInd.sCoveredIndId = objMemCov.Id;
                    objCovInd.sCoveredIndFirstName = objMemCov.SSP_Member__r.FirstName__c;
                    objCovInd.sCoveredIndLastName = objMemCov.SSP_Member__r.LastName__c;
                    objCovInd.sCoveredIndDCId = ((objMemCov.DCInsuranceCoveredIndivId__c != NULL) ? String.valueOf(objMemCov.DCInsuranceCoveredIndivId__c) : NULL);
                    objCovInd.bIsWPIndividualRecord = (bIsEnrolledInInsurance && objCovInd.sCoveredIndDCId != NULL) ? true: false;                    
                    objCovInd.bIsCoveredHealthFacilityExist = (objMemCov.IsTobbacoConsumerToggle__c != NULL || (objMemCov.DCInsuranceCoveredIndivId__c != NULL) ||(mapCoveredIndVsFacilityType != null && mapCoveredIndVsFacilityType.get(objMemCov.Id) != null && !mapCoveredIndVsFacilityType.get(objMemCov.Id).isEmpty()))? true: false; 
                    objCovInd.lstHealthInsuranceFacilityType = (mapCoveredIndVsFacilityType != null && mapCoveredIndVsFacilityType.get(objMemCov.Id) != null && !mapCoveredIndVsFacilityType.get(objMemCov.Id).isEmpty()) ? mapCoveredIndVsFacilityType.get(objMemCov.Id) : null;
                    lstCovIndWrapper.add(objCovInd);                   
                    if(objMemCov.DCInsuranceCoveredIndivId__c != NULL){
                        bIsCovIndHOH = true;
                    }
                }
                else if(!objMemCov.IsPolicyHolder__c && objMemCov.SSP_Member__c == null) {
                    objExtCovInd = new SSP_HealthEnrollmentWrapper.SSP_CoveredIndCls();
                    objExtCovInd.sCoveredIndId = objMemCov.Id;
                    objExtCovInd.sCoveredIndDCId = ((objMemCov.DCInsuranceCoveredIndivId__c != NULL) ? String.valueOf(objMemCov.DCInsuranceCoveredIndivId__c) : NULL);
                    objExtCovInd.sCoveredIndFirstName = objMemCov.FirstName__c;
                    objExtCovInd.sCoveredIndLastName = objMemCov.LastName__c;
                    objExtCovInd.bIsDefault = objMemCov.IsDefault__c;
                    if(objExtCovInd.sCoveredIndDCId != NULL && bIsEnrolledInInsurance) {
                        objExtCovInd.bIsWPIndividualRecord = true;
                    } else {
                        objExtCovInd.bIsWPIndividualRecord = false;
                    }
                    objExtCovInd.bIsCoveredHealthFacilityExist = (objMemCov.IsTobbacoConsumerToggle__c != NULL || (objMemCov.DCInsuranceCoveredIndivId__c != NULL) ||(mapCoveredIndVsFacilityType != null && mapCoveredIndVsFacilityType.get(objMemCov.Id) != null && !mapCoveredIndVsFacilityType.get(objMemCov.Id).isEmpty()))? true: false; 
                    objExtCovInd.lstHealthInsuranceFacilityType = (mapCoveredIndVsFacilityType != null && mapCoveredIndVsFacilityType.get(objMemCov.Id) != null && !mapCoveredIndVsFacilityType.get(objMemCov.Id).isEmpty()) ? mapCoveredIndVsFacilityType.get(objMemCov.Id) : null;
                    lstCovIndWrapper.add(objExtCovInd);
                }
                //Set the Covered Individual data
                if(bIsCovIndHOH && bIsExtPH && bIsCoverageCodeMatching){
                    objHealthEnrollmentSum.bHideRemoveIcon = true;
                }
            }
            if(!lstCovIndWrapper.isEmpty()) {
                objHealthEnrollmentSum.lstCoverInd = lstCovIndWrapper;
            }            
            lstHealthEnrollmentDetails.add(objHealthEnrollmentSum);
        }
        return lstHealthEnrollmentDetails;
    }
    
    /*
    * method        : removeInsurancePolicy
    * @description  : This method is use to remove Insurance Policy and its Policy Holder and Coved Individual
    * @author       : Ashwin Kasture
    * @param        : String sInsuranceCovIndId
    * @return       : Boolean
    * */
    public static Map<String, Object> removeInsurancePolicy(String sInsurancePolicyId, String sAppId) {
        SSP_Utility.isAuthenticatedUser();
        Map<String, Object> mapResponse = new Map<String, Object>();        
        SSP_InsurancePolicy__c objInsurancePolicy;
        SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper objTrackDelWrap;
        Map<String, String> mapInsurancePolicyCondition = new Map<String, String>{'Id' => sInsurancePolicyId};
            //List<SSP_InsurancePolicy__c> lstInsurancePolicy = SSP_InsurancePolicySelector.queryInsurancePolicyData(new Map<String, String>{'objectName'=>'SSP_InsurancePolicy__c'},new Set<String>{'Id'},mapInsurancePolicyCondition);
		List<SSP_InsurancePolicy__c> lstInsurancePolicy = SSP_SharingBypassFetcher.fetchRecords (new Map<String, String>{'objectName'=>'SSP_InsurancePolicy__c'}, new Set<String>{'Id','DCId__c'}, mapInsurancePolicyCondition); // CD1 Security Fixes
        
        Map<String, String> mapInsuranceCovIndCondition = new Map<String, String>{'SSP_InsurancePolicy__c' => sInsurancePolicyId};
            //List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData(new Map<String, String>{'objectName'=>'SSP_InsuranceCoveredIndiv__c'},new Set<String>{'Id'},mapInsuranceCovIndCondition);
		List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_SharingBypassFetcher.fetchRecords (new Map<String, String>{'objectName'=>'SSP_InsuranceCoveredIndiv__c'}, new Set<String>{'Id','DCId__c'}, mapInsuranceCovIndCondition); // CD1 Security Fixes
        
        if(!lstInsurancePolicy.isEmpty()){
            objInsurancePolicy = lstInsurancePolicy[0];
        }
        if(!lstInsurancePolicy.isEmpty() && lstInsurancePolicy[0].DCId__c == NULL) {
            objInsurancePolicy = lstInsurancePolicy[0];
            mapResponse.put('insurancePolicyId',lstInsurancePolicy[0].Id);
            if(!lstInsuranceCovInd.isEmpty()) {
                mapResponse.put('coveredIndividual',lstInsuranceCovInd);
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstInsuranceCovInd, 'delete', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
            }
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstInsurancePolicy, 'delete', 'SSP_InsurancePolicy__c'); // CD1 Security Fixes
        }
        if(objInsurancePolicy != NULL && objInsurancePolicy.DCId__c != NULL){
            objTrackDelWrap = new SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper();
            objTrackDelWrap.bIsCoveredIndDeletion = false;
            objTrackDelWrap.sDCId = String.valueOf(objInsurancePolicy.DCId__c);
            objTrackDelWrap.sSalesforceId = objInsurancePolicy.Id;
            objTrackDelWrap.sApplicationId = (sAppId != NULL && String.isNotBlank(sAppId)) ? sAppId : '';
        }
        if(objTrackDelWrap != NULL){
            updateTrackDeletion(JSON.serialize(objTrackDelWrap));
            mapResponse.put('insurancePolicyId',lstInsurancePolicy[0].Id);
            mapResponse.put('coveredIndividual',lstInsuranceCovInd);
        }
        updateEnrollmentAccessPolicyFlags(sAppId);
        return mapResponse;
    }
    
    /*
    * method        : removeInsuranceCovInd
    * @description  : This method is use to remove Insurance Covered Individual
    * @author       : Ashwin Kasture
    * @param        : String sInsuranceCovIndId
    * @return       : String 
    * */
    public static Map<String, String> removeInsuranceCovInd(String sInsuranceCovIndId, String sAppId) {
        SSP_Utility.isAuthenticatedUser();
        Map<String, String> mapResponse = new Map<String, String>();
        String strInsuranceCovId = '';
		SSP_InsuranceCoveredIndiv__c objInsCovInd;
        SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper objTrackDelWrap;        
        Map<String, String> mapInsuranceCovIndCondition = new Map<String, String>{'Id' => sInsuranceCovIndId, 'Limit' => '1'};
            //List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData(new Map<String, String>{'objectName'=>'SSP_InsuranceCoveredIndiv__c'},new Set<String>{'Id','SSP_InsurancePolicy__c'},mapInsuranceCovIndCondition);
		List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_SharingBypassFetcher.fetchRecords (new Map<String, String>{'objectName'=>'SSP_InsuranceCoveredIndiv__c'}, new Set<String>{'Id','SSP_InsurancePolicy__c','DCInsuranceCoveredIndivId__c'}, mapInsuranceCovIndCondition);
        if(!lstInsuranceCovInd.isEmpty()){
            objInsCovInd = lstInsuranceCovInd[0];
        }
        if(!lstInsuranceCovInd.isEmpty() && lstInsuranceCovInd[0].DCInsuranceCoveredIndivId__c == NULL) {
            objInsCovInd = lstInsuranceCovInd[0];
            mapResponse.put('insurancePolicyId', String.valueOf(lstInsuranceCovInd[0].SSP_InsurancePolicy__c));
            mapResponse.put('coveredIndividual', String.valueOf(lstInsuranceCovInd[0].Id));
            //ESAPI.accessController().deleteAsUser(lstInsuranceCovInd);
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstInsuranceCovInd, 'delete', 'SSP_InsuranceCoveredIndiv__c'); // CD2 Security Fixes
        }
        if(objInsCovInd != NULL && objInsCovInd.DCInsuranceCoveredIndivId__c != NULL){
            objTrackDelWrap = new SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper();
            objTrackDelWrap.bIsCoveredIndDeletion = true;
            objTrackDelWrap.sDCId = (objInsCovInd.DCInsuranceCoveredIndivId__c).replaceAll(',','');
            objTrackDelWrap.sSalesforceId = objInsCovInd.Id;
            objTrackDelWrap.sApplicationId = (sAppId != NULL && String.isNotBlank(sAppId)) ? sAppId : '';
        }
        if(objTrackDelWrap != NULL){
            updateTrackDeletion(JSON.serialize(objTrackDelWrap));
            mapResponse.put('insurancePolicyId', String.valueOf(lstInsuranceCovInd[0].SSP_InsurancePolicy__c));
            mapResponse.put('coveredIndividual', String.valueOf(lstInsuranceCovInd[0].Id));
        }
        return mapResponse;
    }
    
    /*
    * method        : getEnrollmentDetails
    * @description  : This method is use to get the Enrollment Summary details by Application Id
    * @author       : Ashwin Kasture
    * @param        : String sApplicationId - It is the Application Id
    * @return       : List<SSP_HealthEnrollmentWrapper>
    * */
    public static SSP_EnrollmentDetailsWrapper getEnrollmentDetails(String sApplicationId, String sInsurancePolicyId, Boolean bIsEnrolledInInsurance)
    {
        SSP_Utility.isAuthenticatedUser();        
        SSP_EnrollmentDetailsWrapper objEnrollmentWrapper = new SSP_EnrollmentDetailsWrapper();
        List<SSP_ApplicationIndividual__c> lstAppIndRecords = new List<SSP_ApplicationIndividual__c>();
        List<SSP_InsurancePolicy__c> lstInsurancePolicy = new List<SSP_InsurancePolicy__c>();
        List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = new List<SSP_InsuranceCoveredIndiv__c>();        
        List<SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls> lstInternalCoveredInd = new List<SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls>();
        List<SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls> lstExternalCoveredInd = new List<SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls>();
        List<SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls> lstHOHMembers = new List<SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls>();
        
        String insurancePolicyDetailRecTypeId = Schema.SObjectType.SSP_InsurancePolicy__c.getRecordTypeInfosByDeveloperName().get('InsurancePolicyDetail').getRecordTypeId();        
        String insuranceCovedIndRecTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getRecordTypeInfosByDeveloperName().get('InsuranceCoveredIndividual').getRecordTypeId();
        String insuranceExtPolicyHolderRecTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getRecordTypeInfosByDeveloperName().get('InsuranceExternalPolicyHolder').getRecordTypeId();
        String insuranceExtCoveredIndRecTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getRecordTypeInfosByDeveloperName().get('InsuranceExternalCoveredIndividual').getRecordTypeId();
        
        //Get the SSP_ApplicationIndividual__c object data        
        Map<String, String> appIndDetailMap = new Map<String, String> {'objectName' => 'SSP_ApplicationIndividual__c'};
            Set<String> allAppIndFieldSet = new Set<String> {'Id','SSP_Application__r.ProgramsApplied__c','SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c', 'SSP_Member__c'};
                List<String> lstAppField = new List<String> {'Id','ProgramsApplied__c'};
                    List<String> lstMemberField = new List<String> {'FirstName__c','LastName__c'};
                        Boolean canViewMemberFields = ESAPI.accessController().isAuthorizedToView(SSP_Member__c.getSObjectType(), new List<String>(lstMemberField));
        Boolean canViewAppFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), new List<String>(lstAppField));
        List<String> lstAppIndField = new List<String> {'Id'};
            Boolean canViewAppIndFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), new List<String>(lstAppIndField));
        Map<String, String> appIndConditionMap = new Map<String, String> {'SSP_Application__c' => sApplicationId};
        appIndConditionMap.put('IsTMember__c', String.valueOf(false));    
            if(canViewMemberFields && canViewAppFields && canViewAppIndFields) {
                lstAppIndRecords = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                    appIndDetailMap,
                    allAppIndFieldSet,
                    appIndConditionMap
                );
            }
        
        //Get the Source Of Coverage from Meta Data         
        if(!lstAppIndRecords.isEmpty()) {
            List<String> lstProgramApplied = bIsEnrolledInInsurance ? lstAppIndRecords[0].SSP_Application__r.ProgramsApplied__c.split(';'): new List<String>{SSP_GlobalConstants.KP};
                List<SSP_SourcesOfCoverage__mdt> lstSourceOfCoverage = new List<SSP_SourcesOfCoverage__mdt>();
            List<SSP_SourcesOfCoverage__mdt> lstAllSourceOfCoverage = [SELECT DeveloperName, SourceOfCoverageValue__c, Programs_Applied__c, SourceOfCoverageSpanish__c
                                                                       FROM SSP_SourcesOfCoverage__mdt
                                                                       LIMIT 5000];            
            for(SSP_SourcesOfCoverage__mdt objCoverage: lstAllSourceOfCoverage) {
                List<String> lstPrgm = objCoverage.Programs_Applied__c.split(',');
                for(String strPrm: lstPrgm) {
                    if(lstProgramApplied.contains(strPrm)) {
                        lstSourceOfCoverage.add(objCoverage);
                        break;
                    }
                }
            }
            objEnrollmentWrapper.lstSourceOfCoverage = lstSourceOfCoverage;
        }
        
        //Get the SSP_InsuranceCoveredIndiv__c object data
        Map<String, String> insurancePolicyDetailMap = new Map<String, String> {'objectName' => 'SSP_InsurancePolicy__c'};
            insurancePolicyDetailMap.put('operator', 'AND');
        Set<String> setInsurancePolicyFields = new Set<String> {
            'Id', 'TypeOfCoverageCode__c', 'PlanName__c', 'InsurancePolicyNumber__c','InsuranceGroupNumber__c',  'EnrollmentTierLevel__c',
                'InsuranceCompanyName__c', 'PhysicalAddressLine1__c', 'PhysicalCity__c','PhysicalCountryCode__c','PhysicalCountyCode__c', 'PhysicalStateCode__c',
                'PhysicalZipCode4__c', 'PhysicalZipCode5__c','PhysicalAddressLine2__c' ,'IsEnrolledInInsurance__c','DoNotHaveAllInformation__c','IsHealthCareCovPolicyHolderOutSideCase__c',
                'IsHealthCareCoverageApproved__c'
                };
                    List<String> lstInsurancePolicyFields = new List<String> {
                        'Id', 'TypeOfCoverageCode__c', 'PlanName__c', 'InsurancePolicyNumber__c','InsuranceGroupNumber__c', 'EnrollmentTierLevel__c',
                            'InsuranceCompanyName__c', 'PhysicalAddressLine1__c', 'PhysicalCity__c','PhysicalCountryCode__c','PhysicalCountyCode__c', 'PhysicalStateCode__c',
                            'PhysicalZipCode4__c', 'PhysicalZipCode5__c','PhysicalAddressLine2__c' ,'IsEnrolledInInsurance__c','DoNotHaveAllInformation__c','IsHealthCareCovPolicyHolderOutSideCase__c',
                            'IsHealthCareCoverageApproved__c'
                            };
                                Boolean canViewInsuranceFields = ESAPI.accessController().isAuthorizedToView(SSP_InsurancePolicy__c.getSObjectType(), new List<String>(lstInsurancePolicyFields));
        Map<String, String> insurancePolicyConditionMap = new Map<String, String> {'Id' => sInsurancePolicyId, 'RecordTypeId' => insurancePolicyDetailRecTypeId, 'Limit' => '1'};
            if(canViewInsuranceFields) {
                /*lstInsurancePolicy = SSP_InsurancePolicySelector.queryInsurancePolicyData (
                    insurancePolicyDetailMap,
                    setInsurancePolicyFields, 
                    insurancePolicyConditionMap
                );*/
                // Start - CD1 Security Fixes
                lstInsurancePolicy = SSP_SharingBypassFetcher.fetchRecords (
                    insurancePolicyDetailMap,
                    setInsurancePolicyFields, 
                    insurancePolicyConditionMap
                );
                // End - CD1 Security Fixes
            }        
        
        //Get the SSP_InsuranceCoveredIndiv__c object data
        Map<String, String> insuranceCovIndDetailMap = new Map<String, String> {'objectName' => 'SSP_InsuranceCoveredIndiv__c'};        
            Set<String> setInsuranceCovIndFields = new Set<String>{
                'Id', 'RecordTypeId','SSP_Member__c', 'FirstName__c', 'LastName__c', 'IsPolicyHolder__c', 'SSP_Member__r.FirstName__c', 'IsEnrolled__c',
                    'SSP_Member__r.LastName__c', 'SuffixCode__c','DCInsuranceCoveredIndivId__c', 'ExtPolicyHolderFirstName__c', 'ExtPolicyHolderMiddleInitial__c', 'ExtPolicyHolderLastName__c','IsDefault__c'
                    };
                        List<String> lstInsuranceCovIndFields = new List<String> {
                            'Id', 'RecordTypeId', 'SSP_Member__c', 'FirstName__c', 'LastName__c', 'IsPolicyHolder__c','IsEnrolled__c',
                                'SuffixCode__c', 'ExtPolicyHolderFirstName__c', 'DCInsuranceCoveredIndivId__c','ExtPolicyHolderMiddleInitial__c', 'ExtPolicyHolderLastName__c','IsDefault__c'
                                };
                                    Boolean canViewInsuranceCovIndFields = ESAPI.accessController().isAuthorizedToView(SSP_InsuranceCoveredIndiv__c.getSObjectType(), new List<String>(lstInsuranceCovIndFields));
        Map<String, String> insuranceCovIndConditionMap = new Map<String, String> {'SSP_InsurancePolicy__c' => sInsurancePolicyId};
            if(canViewInsuranceCovIndFields) {
                /*lstInsuranceCovInd = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData (
                    insuranceCovIndDetailMap,
                    setInsuranceCovIndFields,
                    insuranceCovIndConditionMap
                );*/
                // Start - CD1 Security Fixes
                lstInsuranceCovInd = SSP_SharingBypassFetcher.fetchRecords (
                    insuranceCovIndDetailMap,
                    setInsuranceCovIndFields,
                    insuranceCovIndConditionMap
                );
                // End - CD1 Security Fixes
            }        
        objEnrollmentWrapper.mapEnrollmentTierLevel = SSP_Utility.getPickListValues('SSP_InsurancePolicy__c','EnrollmentTierLevel__c',null);
        objEnrollmentWrapper.mapSuffixCode = SSP_Utility.getPickListValues('SSP_InsuranceCoveredIndiv__c','SuffixCode__c',null);
        objEnrollmentWrapper.sTimeTravelDate = String.valueOf(SSP_Utility.now());
        if(!lstInsurancePolicy.isEmpty()) {
            //Set InsuranceCompany Data            
            objEnrollmentWrapper.sInsuranceCompanyName = lstInsurancePolicy[0].InsuranceCompanyName__c;
            objEnrollmentWrapper.sAddressLine1 = lstInsurancePolicy[0].PhysicalAddressLine1__c;
            objEnrollmentWrapper.sAddressLine2 = lstInsurancePolicy[0].PhysicalAddressLine2__c;
            objEnrollmentWrapper.sCity = lstInsurancePolicy[0].PhysicalCity__c;
            objEnrollmentWrapper.sCountryCode = lstInsurancePolicy[0].PhysicalCountryCode__c;
            objEnrollmentWrapper.sCountyCode = lstInsurancePolicy[0].PhysicalCountyCode__c;
            objEnrollmentWrapper.sStateCode = lstInsurancePolicy[0].PhysicalStateCode__c;
            objEnrollmentWrapper.sZipCode4 = lstInsurancePolicy[0].PhysicalZipCode4__c;
            objEnrollmentWrapper.sZipCode5 = lstInsurancePolicy[0].PhysicalZipCode5__c;
			objEnrollmentWrapper.bisHealthCarePolicyHolderOutsideCase = lstInsurancePolicy[0].IsHealthCareCovPolicyHolderOutSideCase__c;
            objEnrollmentWrapper.bisHealthCareCoverageApproved = lstInsurancePolicy[0].IsHealthCareCoverageApproved__c;
            
            //Set InsurancePolicyDetail Data
            objEnrollmentWrapper.sInsurancePolicyId = lstInsurancePolicy[0].Id;
            objEnrollmentWrapper.sSourceHealthCareCoverage = lstInsurancePolicy[0].TypeOfCoverageCode__c;
            objEnrollmentWrapper.sInsurancePlanName = lstInsurancePolicy[0].PlanName__c;
            objEnrollmentWrapper.sPlanPolicyId = lstInsurancePolicy[0].InsurancePolicyNumber__c;
            objEnrollmentWrapper.sPlanGroupId = lstInsurancePolicy[0].InsuranceGroupNumber__c;
            objEnrollmentWrapper.sHouseholdEnrolledPlan = lstInsurancePolicy[0].EnrollmentTierLevel__c;
            objEnrollmentWrapper.bIsEnrolledInInsurance = lstInsurancePolicy[0].IsEnrolledInInsurance__c;
        }
        
        //Set HOHMembers data
        if(!lstAppIndRecords.isEmpty()) {
            for(SSP_ApplicationIndividual__c objInd: lstAppIndRecords) {
                SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls objCovIndWrapper = new SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls();                    
                objCovIndWrapper.sMemberId = objInd.SSP_Member__c;
                objCovIndWrapper.sCoveredIndFirstName = objInd.SSP_Member__r.FirstName__c;
                objCovIndWrapper.sCoveredIndLastName = objInd.SSP_Member__r.LastName__c;                
                lstHOHMembers.add(objCovIndWrapper);
            }
            objEnrollmentWrapper.lstHOHMembers = lstHOHMembers;
        }
        //Set Covered Individual data
        if(!lstInsuranceCovInd.isEmpty()) {
            for(SSP_InsuranceCoveredIndiv__c objCovInd: lstInsuranceCovInd) {
                SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls objCovIndWrapper = new SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls();
                // Internal Policy Holder
                if(objCovInd.IsPolicyHolder__c && objCovInd.RecordTypeId == insuranceCovedIndRecTypeId) {
                    objCovIndWrapper.sMemberId = objCovInd.SSP_Member__c;
                    objCovIndWrapper.sCoveredIndId = objCovInd.Id;
                    objCovIndWrapper.sCoveredIndFirstName = objCovInd.SSP_Member__r.FirstName__c;
                    objCovIndWrapper.sCoveredIndLastName = objCovInd.SSP_Member__r.LastName__c;
                    objCovIndWrapper.bIsEnrolled = objCovInd.IsEnrolled__c;
                    objEnrollmentWrapper.objPolicyHolder = objCovIndWrapper;
                }
                // External Policy Holder
                else if(objCovInd.IsPolicyHolder__c && objCovInd.RecordTypeId == insuranceExtPolicyHolderRecTypeId) { 
                    objCovIndWrapper.sMemberId = objCovInd.SSP_Member__c;
                    objCovIndWrapper.sCoveredIndId = objCovInd.Id;
                    objCovIndWrapper.sCoveredIndSuffix = objCovInd.SuffixCode__c;
                    objCovIndWrapper.sCoveredIndFirstName = objCovInd.ExtPolicyHolderFirstName__c;
                    objCovIndWrapper.sCoveredIndMiddleInitial = objCovInd.ExtPolicyHolderMiddleInitial__c;
                    objCovIndWrapper.sCoveredIndLastName = objCovInd.ExtPolicyHolderLastName__c;
                    objCovIndWrapper.bIsEnrolled = objCovInd.IsEnrolled__c;
                    objEnrollmentWrapper.objOutsidePolicyHolder = objCovIndWrapper;
                }
                // Internal Covered Individual
                else if(!objCovInd.IsPolicyHolder__c && objCovInd.RecordTypeId == insuranceCovedIndRecTypeId) {
                    objCovIndWrapper.sMemberId = objCovInd.SSP_Member__c;
                    objCovIndWrapper.sCoveredIndId = objCovInd.Id;
                    objCovIndWrapper.sCoveredIndFirstName = objCovInd.SSP_Member__r.FirstName__c;
                    objCovIndWrapper.sCoveredIndLastName = objCovInd.SSP_Member__r.LastName__c;
                    objCovIndWrapper.bIsEnrolled = objCovInd.IsEnrolled__c;
                    objCovIndWrapper.bIsExistingRecord = (objCovInd.DCInsuranceCoveredIndivId__c != NULL) ? true : false;
                    lstInternalCoveredInd.add(objCovIndWrapper);                        
                }
                // External Covered Individual
                else if(!objCovInd.IsPolicyHolder__c && objCovInd.RecordTypeId == insuranceExtCoveredIndRecTypeId) {
                    objCovIndWrapper.sMemberId = objCovInd.SSP_Member__c;
                    objCovIndWrapper.sCoveredIndId = objCovInd.Id;
                    objCovIndWrapper.sCoveredIndFirstName = (objCovInd.SSP_Member__c != NULL && objCovInd.SSP_Member__r.FirstName__c != NULL) ? objCovInd.SSP_Member__r.FirstName__c : objCovInd.FirstName__c;
                    objCovIndWrapper.sCoveredIndLastName = (objCovInd.SSP_Member__c != NULL && objCovInd.SSP_Member__r.LastName__c != NULL) ? objCovInd.SSP_Member__r.LastName__c : objCovInd.LastName__c;
                    objCovIndWrapper.bIsEnrolled = objCovInd.IsEnrolled__c;
                    objCovIndWrapper.bIsDefault = objCovInd.IsDefault__c? objCovInd.IsDefault__c: null;
                    lstExternalCoveredInd.add(objCovIndWrapper);
                }
            }
            objEnrollmentWrapper.lstCoveredInd = lstInternalCoveredInd;
            objEnrollmentWrapper.lstOutsideCoveredInd = lstExternalCoveredInd;
        }
        return objEnrollmentWrapper;
    }
    
    /*
    * method        : storeEnrollmentDetailsData
    * @description  : This method is use to store the Enrollment details
    * @author       : Ashwin Kasture
    * @param        : String sEnrollmentDetailResponse - Contains Insurance Policy Data with its Policy Holder and Covered Individuals.
    * @return       : Boolean
    * */
    public static Map<String, Object> storeEnrollmentDetailsData(String sEnrollmentDetailResponse)
    {
        SSP_Utility.isAuthenticatedUser();
        Map<String, Object> mapResponseData = new Map<String, Object>();
        sEnrollmentDetailResponse = sEnrollmentDetailResponse = sEnrollmentDetailResponse.unescapeEcmaScript();
        SSP_EnrollmentDetailsWrapper objEnrollmentWrapper = (SSP_EnrollmentDetailsWrapper)JSON.deserialize (
            sEnrollmentDetailResponse,
            SSP_EnrollmentDetailsWrapper.class
        );        
        String insurancePolicyDetailRecTypeId = Schema.SObjectType.SSP_InsurancePolicy__c.getRecordTypeInfosByDeveloperName().get('InsurancePolicyDetail').getRecordTypeId();        
        String insuranceCovedIndRecTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getRecordTypeInfosByDeveloperName().get('InsuranceCoveredIndividual').getRecordTypeId();
        String insuranceExtPolicyHolderRecTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getRecordTypeInfosByDeveloperName().get('InsuranceExternalPolicyHolder').getRecordTypeId();
        String insuranceExtCoveredIndRecTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getRecordTypeInfosByDeveloperName().get('InsuranceExternalCoveredIndividual').getRecordTypeId();
        
        //Start - Upsert Insurance Company
        SSP_InsurancePolicy__c objInsurancePolicyDetail = new SSP_InsurancePolicy__c();
        objInsurancePolicyDetail.InsuranceCompanyName__c = objEnrollmentWrapper.sInsuranceCompanyName;
        objInsurancePolicyDetail.PhysicalAddressLine1__c = objEnrollmentWrapper.sAddressLine1;
        objInsurancePolicyDetail.PhysicalAddressLine2__c = objEnrollmentWrapper.sAddressLine2;
        objInsurancePolicyDetail.PhysicalCity__c = objEnrollmentWrapper.sCity;
        objInsurancePolicyDetail.PhysicalCountryCode__c = objEnrollmentWrapper.sCountryCode;
        objInsurancePolicyDetail.PhysicalCountyCode__c = objEnrollmentWrapper.sCountyCode;
        objInsurancePolicyDetail.PhysicalStateCode__c = objEnrollmentWrapper.sStateCode;
        objInsurancePolicyDetail.PhysicalZipCode4__c = objEnrollmentWrapper.sZipCode4;
        objInsurancePolicyDetail.PhysicalZipCode5__c = objEnrollmentWrapper.sZipCode5;
        //End - Upsert Insurance Company
        
        //Start - Upsert Insurance Policy Detail
        objInsurancePolicyDetail.Id = objEnrollmentWrapper.sInsurancePolicyId != null? objEnrollmentWrapper.sInsurancePolicyId :null;
        objInsurancePolicyDetail.RecordTypeId = insurancePolicyDetailRecTypeId;
        objInsurancePolicyDetail.TypeOfCoverageCode__c = objEnrollmentWrapper.sSourceHealthCareCoverage;
        objInsurancePolicyDetail.PlanName__c = objEnrollmentWrapper.sInsurancePlanName;
        objInsurancePolicyDetail.InsurancePolicyNumber__c = objEnrollmentWrapper.sPlanPolicyId;
        objInsurancePolicyDetail.InsuranceGroupNumber__c = objEnrollmentWrapper.sPlanGroupId;
        objInsurancePolicyDetail.EnrollmentTierLevel__c = objEnrollmentWrapper.sHouseholdEnrolledPlan;
        objInsurancePolicyDetail.IsEnrolledInInsurance__c = objEnrollmentWrapper.bIsEnrolledInInsurance;
        objInsurancePolicyDetail.IsKIHIPPSourceOfCoverage__c = objEnrollmentWrapper.isKIHIPPSourceOfCoverage != null? objEnrollmentWrapper.isKIHIPPSourceOfCoverage: false;
        if(objInsurancePolicyDetail != null) {
        	//ESAPI.accessController().upsertAsUser(objInsurancePolicyDetail, SSP_Utility.getFieldsNamesObject(objInsurancePolicyDetail));
        	SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objInsurancePolicyDetail}, 'upsert', 'SSP_InsurancePolicy__c'); // CD1 Security Fixes
        mapResponseData.put('insurancePolicyDetails', objInsurancePolicyDetail);
        }
        //End - Upsert Insurance Policy Detail
        
        //Delete the Previous Policy Holder
        Boolean canViewDeletePolicyHolderFields = ESAPI.accessController().isAuthorizedToView(SSP_InsuranceCoveredIndiv__c.getSObjectType(), new List<String>{'Id','SSP_Member__c'});
        
        if(String.isNotBlank(objEnrollmentWrapper.sPolicyHolderMemberIdDelete)) {
            List<SSP_InsuranceCoveredIndiv__c> lstToDeletePolicyHolder = new List<SSP_InsuranceCoveredIndiv__c>();
            Map<String, String> insuranceCovIndDetailMap = new Map<String, String> {'objectName' => 'SSP_InsuranceCoveredIndiv__c','operator'=>'AND'};        
                Set<String> setInsuranceCovIndFields = new Set<String> {'Id', 'SSP_Member__c'};
                    if(canViewDeletePolicyHolderFields) {
                        //Get the SSP_InsuranceCoveredIndiv__c object data to delete                
                        Map<String, String> insuranceCovIndConditionMap = new Map<String, String> {
                            'Id' => objEnrollmentWrapper.sPolicyHolderMemberIdDelete,
                                'IsPolicyHolder__c' => String.valueOf(true)
                                };                
                                    /*lstToDeletePolicyHolder = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData (
                                        insuranceCovIndDetailMap,
                                        setInsuranceCovIndFields,
                                        insuranceCovIndConditionMap
                                    );*/
                                    // Start - CD1 Security Fixes
                                    lstToDeletePolicyHolder = SSP_SharingBypassFetcher.fetchRecords (
                                        insuranceCovIndDetailMap,
                                        setInsuranceCovIndFields,
                                        insuranceCovIndConditionMap
                                    );
                        			// End - CD1 Security Fixes
                    }
            if(!lstToDeletePolicyHolder.isEmpty()) {
                //ESAPI.accessController().deleteAsUser(lstToDeletePolicyHolder);
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstToDeletePolicyHolder, 'delete', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
                mapResponseData.put('sPolicyHolderMemberIdDelete', lstToDeletePolicyHolder);
            }
        }
        //Start - Upsert Insurance Policy Holder
        SSP_InsuranceCoveredIndiv__c objPolicyHolderCovIndRecord;
        if(objEnrollmentWrapper.objPolicyHolder != null && objEnrollmentWrapper.objPolicyHolder.sMemberId != null) {
            objPolicyHolderCovIndRecord = new SSP_InsuranceCoveredIndiv__c();
            objPolicyHolderCovIndRecord.RecordTypeId = insuranceCovedIndRecTypeId;
            objPolicyHolderCovIndRecord.Id = objEnrollmentWrapper.objPolicyHolder.sCoveredIndId != null && objEnrollmentWrapper.objPolicyHolder.sCoveredIndId != ''? objEnrollmentWrapper.objPolicyHolder.sCoveredIndId:null;
            objPolicyHolderCovIndRecord.SSP_InsurancePolicy__c = objInsurancePolicyDetail.Id;
            objPolicyHolderCovIndRecord.SSP_Member__c = objEnrollmentWrapper.objPolicyHolder.sMemberId;
            objPolicyHolderCovIndRecord.IsPolicyHolder__c = true;
            objPolicyHolderCovIndRecord.IsEnrolled__c = objEnrollmentWrapper.bIsEnrolledInInsurance == true? true: false;
            mapResponseData.put('objPolicyHolder', objPolicyHolderCovIndRecord);
        }
        else if(objEnrollmentWrapper.objOutsidePolicyHolder != null && objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndFirstName != null) {
            objPolicyHolderCovIndRecord = new SSP_InsuranceCoveredIndiv__c();            
            objPolicyHolderCovIndRecord.RecordTypeId = insuranceExtPolicyHolderRecTypeId;
            objPolicyHolderCovIndRecord.Id = objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndId != null && objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndId != ''? objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndId:null;
            objPolicyHolderCovIndRecord.SSP_InsurancePolicy__c = objInsurancePolicyDetail.Id;
            objPolicyHolderCovIndRecord.SuffixCode__c = objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndSuffix;
            objPolicyHolderCovIndRecord.ExtPolicyHolderFirstName__c = objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndFirstName;
            objPolicyHolderCovIndRecord.ExtPolicyHolderMiddleInitial__c = objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndMiddleInitial;
            objPolicyHolderCovIndRecord.ExtPolicyHolderLastName__c = objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndLastName;
            objPolicyHolderCovIndRecord.IsPolicyHolder__c = true;
            objPolicyHolderCovIndRecord.IsEnrolled__c = objEnrollmentWrapper.bIsEnrolledInInsurance == true? true: false;
            mapResponseData.put('objOutsidePolicyHolder', objPolicyHolderCovIndRecord);
        }
        else if(objEnrollmentWrapper.objPolicyHolder == null && (objEnrollmentWrapper.objOutsidePolicyHolder == null 
                                                                 || objEnrollmentWrapper.objOutsidePolicyHolder.sCoveredIndFirstName == null)
                && (objEnrollmentWrapper.lstCoveredInd == null || objEnrollmentWrapper.lstCoveredInd.isEmpty()) 
                && (objEnrollmentWrapper.lstOutsideCoveredInd == null || objEnrollmentWrapper.lstOutsideCoveredInd.isEmpty())) {
                    objPolicyHolderCovIndRecord = new SSP_InsuranceCoveredIndiv__c();
                    objPolicyHolderCovIndRecord.RecordTypeId = insuranceExtCoveredIndRecTypeId;
                    objPolicyHolderCovIndRecord.SSP_InsurancePolicy__c = objInsurancePolicyDetail.Id;
                    objPolicyHolderCovIndRecord.IsPolicyHolder__c = false;
                    objPolicyHolderCovIndRecord.IsDefault__c = true;
                    objPolicyHolderCovIndRecord.IsEnrolled__c = objEnrollmentWrapper.bIsEnrolledInInsurance == true? true: false;
                    mapResponseData.put('objDefaultCoveredIndividual', objPolicyHolderCovIndRecord);
                }
        if(objPolicyHolderCovIndRecord != null) {
            //ESAPI.accessController().upsertAsUser(objPolicyHolderCovIndRecord, SSP_Utility.getFieldsNamesObject(objPolicyHolderCovIndRecord));
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objPolicyHolderCovIndRecord}, 'upsert', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
        }
        //End - Upsert Insurance Policy Holder
        
        // Delete Internal Covered Individuals
        if(objEnrollmentWrapper.lstCoveredIndDelete != null && !objEnrollmentWrapper.lstCoveredIndDelete.isEmpty() && canViewDeletePolicyHolderFields) {
            List<SSP_InsuranceCoveredIndiv__c> lstToDeleteInternalCoveredInd = new List<SSP_InsuranceCoveredIndiv__c>();
            Map<String, String> insuranceCovIndDetailMap = new Map<String, String> {'objectName' => 'SSP_InsuranceCoveredIndiv__c','operator'=>'AND','IN'=>'SSP_Member__c'};
                Set<String> setInsuranceCovIndFields = new Set<String> {'Id', 'SSP_Member__c'};
                    String strMemberId = String.join(new List<String>(objEnrollmentWrapper.lstCoveredIndDelete), ',');
            Map<String, String> internalCovIndConditionMap = new Map<String, String> { 
                'SSP_Member__c' => strMemberId, 
                    'SSP_InsurancePolicy__c' => objEnrollmentWrapper.sInsurancePolicyId, 
                    'IsPolicyHolder__c' => String.valueOf(false)
                    };
                        /*lstToDeleteInternalCoveredInd = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData (
                            insuranceCovIndDetailMap,
                            setInsuranceCovIndFields,
                            internalCovIndConditionMap
                        );*/
                        // Start - CD1 Security Fixes
                        lstToDeleteInternalCoveredInd = SSP_SharingBypassFetcher.fetchRecords (
                            insuranceCovIndDetailMap,
                            setInsuranceCovIndFields,
                            internalCovIndConditionMap
                        );
            			// End - CD1 Security Fixes
            if(!lstToDeleteInternalCoveredInd.isEmpty()) {
                //ESAPI.accessController().deleteAsUser(lstToDeleteInternalCoveredInd);
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstToDeleteInternalCoveredInd, 'delete', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
            }
            mapResponseData.put('lstCoveredIndDelete', lstToDeleteInternalCoveredInd);
        }
        // Delete External Covered Individuals
        if(objEnrollmentWrapper.lstOutsideCoveredIndDelete != null && !objEnrollmentWrapper.lstOutsideCoveredIndDelete.isEmpty() && canViewDeletePolicyHolderFields) {
            List<SSP_InsuranceCoveredIndiv__c> lstToDeleteOutsideCoveredInd = new List<SSP_InsuranceCoveredIndiv__c>();
            Map<String, String> insuranceCovIndDetailMap = new Map<String, String> {'objectName' => 'SSP_InsuranceCoveredIndiv__c','operator'=>'AND','IN'=>'Id'};
                Set<String> setInsuranceCovIndFields = new Set<String> {'Id', 'SSP_Member__c'};
                    String strCoveredIndId = String.join(new List<String>(objEnrollmentWrapper.lstOutsideCoveredIndDelete), ',');
            Map<String, String> internalCovIndConditionMap = new Map<String, String> {'Id' => strCoveredIndId, 'SSP_InsurancePolicy__c' => objEnrollmentWrapper.sInsurancePolicyId};
                /*lstToDeleteOutsideCoveredInd = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData (
                    insuranceCovIndDetailMap,
                    setInsuranceCovIndFields,
                    internalCovIndConditionMap
                );*/
                // Start - CD1 Security Fixes
                lstToDeleteOutsideCoveredInd = SSP_SharingBypassFetcher.fetchRecords (
                    insuranceCovIndDetailMap,
                    setInsuranceCovIndFields,
                    internalCovIndConditionMap
                );            
            	// End - CD1 Security Fixes
            if(!lstToDeleteOutsideCoveredInd.isEmpty()) {
                //ESAPI.accessController().deleteAsUser(lstToDeleteOutsideCoveredInd);
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstToDeleteOutsideCoveredInd, 'delete', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
            }
            mapResponseData.put('lstOutsideCoveredIndDelete', lstToDeleteOutsideCoveredInd);
        }
        
        //Start - Upsert Insurance Covered Individual
        List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd;
        List<SSP_InsuranceCoveredIndiv__c> lstOutsideCovInd;
        if(objEnrollmentWrapper.lstCoveredInd != null && !objEnrollmentWrapper.lstCoveredInd.isEmpty()) {
            lstInsuranceCovInd = new List<SSP_InsuranceCoveredIndiv__c>();
            for(SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls objCovIndWrapper :objEnrollmentWrapper.lstCoveredInd) {
                SSP_InsuranceCoveredIndiv__c objCovIndRecord = new SSP_InsuranceCoveredIndiv__c();
                objCovIndRecord.Id = objCovIndWrapper.sCoveredIndId != null && objCovIndWrapper.sCoveredIndId != ''? objCovIndWrapper.sCoveredIndId:null;
                objCovIndRecord.RecordTypeId = insuranceCovedIndRecTypeId;
                objCovIndRecord.SSP_Member__c = objCovIndWrapper.sMemberId;
                objCovIndRecord.SSP_InsurancePolicy__c = objInsurancePolicyDetail.Id;             
                objCovIndRecord.IsPolicyHolder__c = false;
                objCovIndRecord.IsEnrolled__c = objEnrollmentWrapper.bIsEnrolledInInsurance == true? true: false;
                lstInsuranceCovInd.add(objCovIndRecord);
            }
            if(!lstInsuranceCovInd.isEmpty()) {
                //ESAPI.accessController().upsertAsUser(lstInsuranceCovInd, SSP_Utility.getFieldsNamesList(lstInsuranceCovInd));
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstInsuranceCovInd, 'upsert', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
            }
            mapResponseData.put('lstCoveredInd', lstInsuranceCovInd);
        }
        if(objEnrollmentWrapper.lstOutsideCoveredInd != null && !objEnrollmentWrapper.lstOutsideCoveredInd.isEmpty()) {
            lstOutsideCovInd = new List<SSP_InsuranceCoveredIndiv__c>();
            for(SSP_EnrollmentDetailsWrapper.SSP_CoveredIndCls objCovIndWrapper :objEnrollmentWrapper.lstOutsideCoveredInd) {
                SSP_InsuranceCoveredIndiv__c objCovIndRecord = new SSP_InsuranceCoveredIndiv__c();
                objCovIndRecord.Id = objCovIndWrapper.sCoveredIndId != null && objCovIndWrapper.sCoveredIndId != ''? objCovIndWrapper.sCoveredIndId:null;
                objCovIndRecord.RecordTypeId = insuranceExtCoveredIndRecTypeId;                
                objCovIndRecord.SSP_InsurancePolicy__c = objInsurancePolicyDetail.Id;
                objCovIndRecord.FirstName__c = objCovIndWrapper.sCoveredIndFirstName;
                objCovIndRecord.LastName__c = objCovIndWrapper.sCoveredIndLastName;
                objCovIndRecord.IsPolicyHolder__c = false;
                objCovIndRecord.IsEnrolled__c = objEnrollmentWrapper.bIsEnrolledInInsurance == true? true: false;
                lstOutsideCovInd.add(objCovIndRecord);
            }
            if(!lstOutsideCovInd.isEmpty()) {
                //ESAPI.accessController().upsertAsUser(lstOutsideCovInd, SSP_Utility.getFieldsNamesList(lstOutsideCovInd));
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstOutsideCovInd, 'upsert', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
            }
            mapResponseData.put('lstOutsideCoveredInd', lstOutsideCovInd);
        }
        //End - Upsert Covered Individual
        return mapResponseData;
    }
    
    /*
    * method        : updateTrackDeletion
    * @description  : This method is use to create SSP_TrackDeletion__c with Insurance Policy & Covered Individual Data
    * @author       : Sai Kiran
    * @param        : String sTrackDeletionWrapperData
    * @return       : Boolean 
    * */
    public static Boolean updateTrackDeletion(String sTrackDeletionWrapperData) {
        Map<String,String> mapConditions = new Map<String,String>();
        Boolean bIsUpdateSuccess = false;
        SSP_InsuranceCoveredIndiv__c objCovIndividual;
        SSP_InsurancePolicy__c objPolicy;
        SSP_TrackDeletion__c objTrackDeletion = new SSP_TrackDeletion__c();
        List<SSP_InsuranceCoveredIndiv__c> updateCovIndList = new List<SSP_InsuranceCoveredIndiv__c>();
        List<String> lstTrackDeletionFields = new List<String>{'SSP_Application__c','DCId__c','EndDate__c','SFObject__c','EndReason__c','SSP_Member__c','OtherReason__c','ParentDCId__c','SalesforceId__c','Source__c'};
            List<String> lstCovIndFields = new List<String>{'IsDeleted__c'};
                Set<String> setInsuranceCovIndFields = new Set<String>{'IsDeleted__c'};
                    List<String> lstInsPolicyFields = new List<String>{'IsDeleted__c'};
                        SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper trackDeletionWrapper = new SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper();
        SSP_InsuranceCoveredIndiv__c objCovInds;
        ID covIndRecordTypeId;
        try{
            covIndRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_InsuranceCoveredIndiv__c','InsuranceCoveredIndividual');
            Boolean bViewTrackDeletionFields = ESAPI.accessController().isAuthorizedToView(SSP_TrackDeletion__c.getSObjectType(), lstTrackDeletionFields);
            Boolean bViewCovIndFields = ESAPI.accessController().isAuthorizedToView(SSP_InsuranceCoveredIndiv__c.getSObjectType(), lstCovIndFields);
            Boolean bViewInsPolicyFields = ESAPI.accessController().isAuthorizedToView(SSP_InsurancePolicy__c.getSObjectType(), lstInsPolicyFields);    
            SSP_Utility.isAuthenticatedUser();
            if(sTrackDeletionWrapperData != NULL && !String.isBlank(sTrackDeletionWrapperData)){
                trackDeletionWrapper = (SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper) JSON.deserialize(sTrackDeletionWrapperData, SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper.class);
            }
            if(trackDeletionWrapper != NULL){
                if(bViewTrackDeletionFields){
                    //objCovInds = new SSP_InsuranceCoveredIndiv__c(Id = trackDeletionWrapper.sSalesforceId);
                    objTrackDeletion.SSP_Application__c = trackDeletionWrapper.sApplicationId;
                    objTrackDeletion.SalesforceId__c = trackDeletionWrapper.sSalesforceId;
                    objTrackDeletion.OtherReason__c = trackDeletionWrapper.sOtherReason;
                    objTrackDeletion.EndReason__c = trackDeletionWrapper.sEndReason;
                    objTrackDeletion.SSP_Member__c = trackDeletionWrapper.sMemberId;
                    objTrackDeletion.EndDate__c = trackDeletionWrapper.dEndDate;                
                    objTrackDeletion.ParentDCId__c = trackDeletionWrapper.sParentDCId;
                    objTrackDeletion.DCId__c = Decimal.valueOf(trackDeletionWrapper.sDCId);
                }
                if(trackDeletionWrapper.bIsCoveredIndDeletion){
                    objTrackDeletion.SFObject__c = 'SSP_InsuranceCoveredIndiv__c';
                    //objCovInds = new SSP_InsuranceCoveredIndiv__c(Id = trackDeletionWrapper.sSalesforceId);
                    objCovInds = (SSP_InsuranceCoveredIndiv__c)SSP_SharingBypassFetcher.fetchRecords (new Map<String, String>{'objectName'=>'SSP_InsuranceCoveredIndiv__c'}, new Set<String>{'Id','SSP_InsurancePolicy__c','RecordTypeId'}, new Map<String, String>{'Id' => trackDeletionWrapper.sSalesforceId, 'Limit' => '1'})[0];
                    if(objCovInds != NULL && objCovInds.RecordTypeId == covIndRecordTypeId){
                        objTrackDeletion.Source__c = 'CoveredIndividual';
                    }else{
                        objTrackDeletion.Source__c = 'ExternalCoveredIndividual';
                    }
                }else{
                    objTrackDeletion.SFObject__c = 'SSP_InsurancePolicy__c';
                    objTrackDeletion.Source__c = 'HealthCoverageInformation';
                }
                objTrackDeletion = (SSP_TrackDeletion__c)ESAPI.accessController().insertAsUser(objTrackDeletion, lstTrackDeletionFields);
                if(trackDeletionWrapper.bIsCoveredIndDeletion){
                    objCovIndividual = new SSP_InsuranceCoveredIndiv__c(Id = trackDeletionWrapper.sSalesforceId);
                    objCovIndividual.IsDeleted__c = true;
                }else{
                    objPolicy = new SSP_InsurancePolicy__c(Id = trackDeletionWrapper.sSalesforceId);
                    objPolicy.IsDeleted__c = true;
                    mapConditions.put('SSP_InsurancePolicy__c', objPolicy.Id);
                /*List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData (
                        new Map<String, String> {
                            'objectName'=>'SSP_InsuranceCoveredIndiv__c'
                                },
                        setInsuranceCovIndFields,
                        mapConditions
                );*/
                // Start - CD1 Security Fixes
                List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_SharingBypassFetcher.fetchRecords (
                    new Map<String, String> {
                        'objectName'=>'SSP_InsuranceCoveredIndiv__c'
                            },
                    setInsuranceCovIndFields,
                    mapConditions
                    );
                // End - CD1 Security Fixes
                    for(SSP_InsuranceCoveredIndiv__c objCovInd : lstInsuranceCovInd){
                        objCovInd.IsDeleted__c = true;
                        updateCovIndList.add(objCovInd);
                    }
                }
            }
            if(objCovIndividual != NULL && bViewCovIndFields){
                objCovIndividual = (SSP_InsuranceCoveredIndiv__c)ESAPI.accessController().updateAsUser(objCovIndividual, lstCovIndFields);
            }
            if(objPolicy != NULL && bViewInsPolicyFields){
                //objPolicy = (SSP_InsurancePolicy__c)ESAPI.accessController().updateAsUser(objPolicy, lstInsPolicyFields);
                objPolicy = (SSP_InsurancePolicy__c)SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objPolicy}, 'update', 'SSP_InsurancePolicy__c')[0]; // CD1 Security Fixes
                if(updateCovIndList != NULL){
                    //ESAPI.accessController().updateAsUser(new Map<ID,SSP_InsuranceCoveredIndiv__c>(updateCovIndList), lstCovIndFields);
                    SSP_SharingBypassFetcher.dmlOnGenericSobjectList(updateCovIndList, 'upsert', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
                }
            }
            if((objTrackDeletion != NULL && objCovIndividual != NULL && objPolicy != NULL) || (objCovIndividual != NULL) || (objPolicy != NULL)){
                bIsUpdateSuccess = true;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HealthEnrollmentSummaryService', 'updateTrackDeletion', e.getMessage(), true);
        }
        return bIsUpdateSuccess;
    }
    /**
    * @author: Varun Kochar
    * @method: getCoveredIndividual
    * @desc This method is used to get details for a particular covered Individual
    * @return List<SSP_InsuranceCoveredIndiv__c>
    * */
    public static List<SSP_InsuranceCoveredIndiv__c> getCoveredIndividual(Set<String> insuranceCoveredIndividualId){
        try{
             Map<String, String> insuranceCovIndConditionMap = new Map<String, String> {'Id' => String.join(new List<String>(insuranceCoveredIndividualId), ',')};
            Map<String, String> insuranceCovIndDetailMap = new Map<String, String> {'objectName' => 'SSP_InsuranceCoveredIndiv__c', 'IN'=>'Id'};        
                Set<String> setInsuranceCovIndFields = new Set<String>{'Id','RecordTypeId','Name','SSP_InsurancePolicy__c','SSP_Member__c','SSP_Member__r.FirstName__c', 'SSP_Member__r.MiddleInitial__c','SSP_Member__r.SuffixCode__c','SSP_Member__r.LastName__c','SSP_Member__r.GenderCode__c','SSP_Member__r.BirthDate__c','SSP_Member__r.SSN__c',
                    'SSP_Asset__c','DCId__c','DCInsuranceCoveredIndivId__c','IsPolicyHolder__c','FirstName__c','LastName__c','MiddleInitial__c','SuffixCode__c','Gender__c','DateofBirth__c','IsTobbacoConsumerToggle__c','RelationshipCode__c','Recordtype.Name','Recordtype.DeveloperName','SSN__c',
                    'IsCoveredIndividualUpdated__c','ExtAddressLine1__c','ExtAddressLine2__c','ExtPolicyHolderSsn__c','ExtPolicyHolderFirstName__c','ExtPolicyHolderLastName__c','ExtPolicyHolderMiddleInitial__c','MedicaidId__c','SSP_InsurancePolicy__r.EmployerName__c',
                    'SSP_InsurancePolicy__r.IsKIHIPPSourceOfCoverage__c','SSP_InsurancePolicy__r.IsHealthCareCoverageApproved__c','SSP_InsurancePolicy__r.IsHealthCareCovPolicyHolderOutSideCase__c' ,'HasMedicaidToggle__c','ExtCity__c','ExtStateCode__c','ExtZipCode4__c','ExtZipCode5__c'};
                        //return SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData ( insuranceCovIndDetailMap, setInsuranceCovIndFields, insuranceCovIndConditionMap);
                        return SSP_SharingBypassFetcher.fetchRecords ( insuranceCovIndDetailMap, setInsuranceCovIndFields, insuranceCovIndConditionMap); // CD1 Security Fixes
                                
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HealthEnrollmentSummaryService', 'getCoveredIndividual', e.getMessage(), true);
        }
        return null;
    }
    
    /**
    * @author: Varun Kochar
    * @method: getHealthInsuranceFacilityType
    * @desc This method is used to get details for a particular covered Individual
    * @return List<SSP_InsuranceCoveredIndiv__c>
    * */
    public static List<SSP_HealthInsuranceFacilityType__c> getHealthInsuranceFacilityType(Set<String> insuranceCoveredIndividualId){
        try{
             Map<String, String> healthInsuranceFacilityTypeMap = new Map<String, String> {'objectName' => 'SSP_HealthInsuranceFacilityType__c','operator'=>'AND', 'IN'=>'SSP_InsuranceCoveredIndiv__c'};        
                Set<String> setHealthInsuranceFacilityTypeFields = new Set<String>{'Id','Name','RecordTypeId','SSP_InsuranceCoveredIndiv__c','DCId__c','CoverageStartDate__c','CoverageEndDate__c','EndReason__c','OtherReason__c','FacilityType__c'};
                    Map<String, String> healthInsuranceFacilityTypeConditionMap = new Map<String, String> {'SSP_InsuranceCoveredIndiv__c' => String.join(new List<String>(insuranceCoveredIndividualId), ','), 'IsDeleted__c' => 'false'};
                        
                      //return SSP_HealthInsuranceFacilityTypeSelector.queryHealthInsuranceFacilityTypeData(healthInsuranceFacilityTypeMap, setHealthInsuranceFacilityTypeFields, healthInsuranceFacilityTypeConditionMap);
                      return SSP_SharingBypassFetcher.fetchRecords (healthInsuranceFacilityTypeMap, setHealthInsuranceFacilityTypeFields, healthInsuranceFacilityTypeConditionMap); // CD1 Security Fixes
                                            
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HealthEnrollmentSummaryService', 'getHealthInsuranceFacilityType', e.getMessage(), true);
        }
        return null;
    }
    /**
    * @author: Varun Kochar
    * @method: getFacilityTypesMap
    * @desc This method is used to get getFacilityTypesList
    * @return Map<String, String>
    * */
    public static Map<String, String> getFacilityTypesMap(){
        try{
            Map<String, String> facilityTypesMap = new Map<String, String>();
             for(Schema.PicklistEntry pickList : SSP_HealthInsuranceFacilityType__c.FacilityType__c.getDescribe().getPicklistValues()){
                facilityTypesMap.put(pickList.getValue(),pickList.getLabel());
            }
              return facilityTypesMap;                          
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HealthEnrollmentSummaryService', 'getFacilityTypesMap', e.getMessage(), true);
        }
        return null;
    }
    
    /**
    * @author: Varun Kochar
    * @method: getAssets
    * @desc This method is used to get list of Assets for a Member
    * @return List<SSP_Asset__c>
    * */
    public static List<SSP_Asset__c> getAssets(Set<String> memberId){
        try{
              Map<String, String> sspAssetMap = new Map<String, String> {'objectName' => 'SSP_Asset__c','operator'=>'AND', 'IN'=>'SSP_Member__c'};        
                    Set<String> setSSPAssetFields = new Set<String>{'Id','Name','RecordTypeId','SSP_Member__c','EmployerName__c'};
                        Map<String, String> sspAssetConditionMap = new Map<String, String>{'SSP_Member__c' =>   String.join(new List<String>(memberId), ','), 'Recordtype.Name' =>'Income', 'IncomeTypeCode__c' => 'EA'};
                        
                      return  SSP_AssetSelector.queryAssetData ( sspAssetMap, setSSPAssetFields, sspAssetConditionMap);
                                            
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HealthEnrollmentSummaryService', 'getAssets', e.getMessage(), true);
        }
        return null;
    }
    /**
    * @author: Varun Kochar
    * @method: getCoveredIndividualPolicyHolder
    * @desc This method is used to get details for a particular covered Individual
    * @return List<SSP_InsuranceCoveredIndiv__c>
    * */
    public static List<SSP_InsuranceCoveredIndiv__c> getCoveredIndividualPolicyHolder(Set<String> insurancePolicyId){
        try{
            Map<String, String> insuranceCovIndHolderDetailMap = new Map<String, String> {'objectName' => 'SSP_InsuranceCoveredIndiv__c' ,'operator'=>'AND', 'IN'=>'SSP_InsurancePolicy__c'};        
                Set<String> setInsuranceCovIndHolderFields = new Set<String>{'Id','Name','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','FirstName__c','LastName__c','ExtPolicyHolderFirstName__c','ExtPolicyHolderLastName__c','Recordtype.DeveloperName'};
                    Map<String, String> insuranceCovIndHolderConditionMap = new Map<String, String> {'SSP_InsurancePolicy__c' =>  String.join(new List<String>(insurancePolicyId), ','),'IsPolicyHolder__c' =>'true' };
                        //return SSP_InsuranceCoveredIndivSelector.queryInsuranceCoveredIndivData ( insuranceCovIndHolderDetailMap, setInsuranceCovIndHolderFields, insuranceCovIndHolderConditionMap);
                        return SSP_SharingBypassFetcher.fetchRecords ( insuranceCovIndHolderDetailMap, setInsuranceCovIndHolderFields, insuranceCovIndHolderConditionMap); // CD1 Security Fixes
            
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HealthEnrollmentSummaryService', 'getCoveredIndividualPolicyHolder', e.getMessage(), true);
        }
        return null;
    }

    /**
    * @author: Karthik Gulla
    * @method: updateEnrollmentAccessPolicyFlags
    * @desc This method is used to update health coverage selection questions after the policies are removed
    * @return void
    * */
    public static void updateEnrollmentAccessPolicyFlags(String sApplicationId) {
        Set<String> memberIds = new Set<String>();
        Map<String, Integer> mapPolicyCount = new Map<String,Integer>();
        List<SSP_InsuranceCoveredIndiv__c> lstPolicyMembers = new List<SSP_InsuranceCoveredIndiv__c>();
        try{
            List<SSP_ApplicationIndividual__c> lstAppIndRecords = SSP_HealthCoverageSelectionService.getAppIndData(sApplicationId);
            for(SSP_ApplicationIndividual__c app : lstAppIndRecords){
                memberIds.add(app.SSP_Member__c);
            }
            if(Schema.sObjectType.SSP_InsuranceCoveredIndiv__c.isAccessible()) {
                lstPolicyMembers = [Select Id, SSP_InsurancePolicy__r.IsEnrolledInInsurance__c, SSP_InsurancePolicy__r.DCId__c
                                                        from SSP_InsuranceCoveredIndiv__c
                                                        where SSP_Member__c IN :memberIds
                                                        AND IsDeleted__c = false];
            }
            for(SSP_InsuranceCoveredIndiv__c policy : lstPolicyMembers){
                //Enrollment Summary Related
                if(policy.SSP_InsurancePolicy__r.IsEnrolledInInsurance__c && policy.SSP_InsurancePolicy__r.DCId__c != NULL){
                    if(mapPolicyCount.get('Enrollment') != null) {
                        mapPolicyCount.put('Enrollment',mapPolicyCount.get('Enrollment') + 1);
                    } else {
                        mapPolicyCount.put('Enrollment', 1);
                    }
                }
                //Access Summary Related
                if(!policy.SSP_InsurancePolicy__r.IsEnrolledInInsurance__c && policy.SSP_InsurancePolicy__r.DCId__c != NULL){
                    if(mapPolicyCount.get('Access') != null) {
                        mapPolicyCount.put('Access',mapPolicyCount.get('Access') + 1);
                    } else {
                        mapPolicyCount.put('Access', 1);
                    }
                }
            }

            if(mapPolicyCount.get('Enrollment') == null) {
                SSP_Application__c sspAppRecord = new SSP_Application__c();
                sspAppRecord.Id = sApplicationId;
                sspAppRecord.EnrolledInHealthCareCoverageToggle__c = SSP_GlobalConstants.NO;
                ESAPI.accessController().updateAsUser(sspAppRecord, SSP_Utility.getFieldsNamesObject(sspAppRecord));
            }
            
            if(mapPolicyCount.get('Access') == null) {
                SSP_Application__c sspAppRecord = new SSP_Application__c();
                sspAppRecord.Id = sApplicationId;
                sspAppRecord.NotEnrolledInHealthCareCoverageToggle__c = SSP_GlobalConstants.NO;
                ESAPI.accessController().updateAsUser(sspAppRecord, SSP_Utility.getFieldsNamesObject(sspAppRecord));
            }
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_HealthEnrollmentSummaryService', 'updateEnrollmentAccessPolicyFlags', e.getMessage(), true);
        }
    }
}