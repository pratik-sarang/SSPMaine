/*
* classname     :  SSP_CISCareTakerController
* @description  :  Controller Method for sspCas=reTakerServices
* @author       :  Shrikant Raut   
* @date         :  04/09/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_CISCareTakerController {
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         04/09/2020
* @methodname   fetchRequiredData
* @description  This methods is used to fetch required Member and Application related data.
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse fetchRequiredData(Id sspApplicationId, String sspMemberId, String callingComponent){       
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix         
        SSP_LightningResponse response = new SSP_LightningResponse();
        String screenId;
        List<SSP_ApplicationIndividual__c> appIndvList = new List<SSP_ApplicationIndividual__c>();  
        Map<String, String> detailMap = new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.OBJ_APPLICATION_INDIVIDUAL,
            SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND};
                //adding common fields to be queried
                Set<String> fieldSet = new Set<String>{'Id','SSP_Application__r.ProgramsApplied__c','ProgramsApplied__c','IsHeadOfHousehold__c'}; 
                    Map<String, String> conditionMap = new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'100'};
                        try {
                            SSP_Utility.setProgramPermissions();
                            if(sspApplicationId != null && sspMemberId != null){
                                conditionMap.put(SSP_GlobalConstants.OBJ_MEMBER, sspMemberId);
                                conditionMap.put(SSP_GlobalConstants.OBJ_APPLICATION, sspApplicationId);
                                
                                //adding fields to query for sspCareTakerServices lwc cmp
                                if(callingComponent != null && callingComponent.equals(SSP_GlobalConstants.CARE_TAKER_SERVICES)){
                                    screenId = SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID;
                                    fieldSet.addAll(new Set<String>{'ServiceStartDate__c','ServiceEndDate__c','IsServiceProvidedSafelyToggle__c','IsPreventedNursingFacilityToggle__c','IsServiceReceivedRegularlyToggle__c','CaretakerRelation__c','IsCaretakerLivingTogetherToggle__c','CaretakerName__c','CaretakerPhone__c'});
                                    response.put(SSP_GlobalConstants.KEY_CARE_TAKER_RELATIONS,SSP_Utility.getPickListValues(SSP_GlobalConstants.OBJ_APPLICATION_INDIVIDUAL, 'CaretakerRelation__c', null));
                                }
                                
                                //place holder for adding CIS related fields
                                if(callingComponent != null && callingComponent.equals(SSP_GlobalConstants.CIS)){
                                    screenId = SSP_GlobalConstants.CIS_SCREENID;
                                    
                                    fieldSet.addAll(new Set<String>{'CISStartDate__c','CISEndDate__c','MentalIllnessImpairsFunctioningToggle__c','MentalIllnessNeedsTreatmentToggle__c','MentalIllnessWithoutAlzheimersToggle__c','IsServiceStoppingInstitutalizationToggle__c','CareCoordinatorRelationship__c','CareCoordinatorName__c','CareCoordinatorAddressLine1__c','CareCoordinatorCity__c','CareCoordinatorStateCode__c','CareCoordinatorZipcode4__c','CareCoordinatorZipcode5__c','CareCoordinatorCountyCode__c','CareCoordinatorAddressLine2__c','CareCoordinatorPhoneNumber__c'});
                                    response.put(SSP_GlobalConstants.KEY_CIS_RELATIONS,SSP_Utility.getPickListValues(SSP_GlobalConstants.OBJ_APPLICATION_INDIVIDUAL, 'CareCoordinatorRelationship__c', null));
                                }
                                
                                if(fieldSet.contains('')){
                                    fieldSet.remove('');
                                }
                                
                                appIndvList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(detailMap, fieldSet, conditionMap);  
                                response.put(SSP_GlobalConstants.KEY_APP_INDVS,appIndvList);
                                response.put(SSP_GlobalConstants.KEY_ACCESS_DETAILS,SSP_Utility.getScreenAccessDetails(screenId, null));//DCBS (View Only)
                                response.put(SSP_GlobalConstants.KEY_ACCESSIBLE_PROGRAMS,SSP_Utility.getAvailableProgramsByRole());
                                
                                response.bIsSuccess = true;
                            }
                        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_CISCareTakerController', 'fetchRequiredData', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);            
        }
        return response;
    }
    
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         04/14/2019
* @methodname   updateRecord
* @description  This methods is used to update SSP_ApplicationIndividual__c records
* @return       SSP_LightningResponse
*****************************************************************************************************/    
    @auraEnabled
    public static SSP_LightningResponse updateApplicationIndividuals(String serializedJSON){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            
            if(serializedJSON != null && Schema.sObjectType.SSP_ApplicationIndividual__c.isUpdateable()){
                List<SSP_ApplicationIndividual__c> appIndividualList = (List<SSP_ApplicationIndividual__c>)JSON.deserialize(serializedJSON, List<SSP_ApplicationIndividual__c>.class);
                response.bIsSuccess = ESAPI.accessController().updateAsUser(new Map<ID, SSP_ApplicationIndividual__c>(appIndividualList), SSP_Utility.getFieldsNamesList (appIndividualList)).wasSuccessful();
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_CISCareTakerController', 'updateRecord', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);            
        }
        return response;
        
    }
}