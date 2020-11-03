/**
* @author: Karthik Gulla
* @Class Name: SSP_ResourcesSelectionController
* @desc This class is used as a controller to call ResourcesService for resourcesSelection functionalities
* @Date 01-18-2020
MODIFICATION LOG :
* */ 
public with sharing class SSP_ResourcesSelectionController {
    public static Map<String,SSP_ResourceMappings__mdt> mapResourceFieldMappings;
    public static Map<String,SSP_ResourceMappings__mdt> mapResourceTypeMappings;
   
   /**
    * @author: Karthik Gulla
    * @method: updateResourcesSelectionDetails
    * @desc This method is used to update Resources Selection details
    * @param {String sUpdatedValues}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse updateResourcesSelectionDetails(String sUpdatedValues, String sApplicationId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        try{
            Set<String> setAccessFields = new Set<String>();
            List<SSP_ResourcesWrapper.ResourceSelectionWrapper> lstUpdatedValues = (List<SSP_ResourcesWrapper.ResourceSelectionWrapper>)JSON.deserialize(sUpdatedValues,  List<SSP_ResourcesWrapper.ResourceSelectionWrapper>.class);
            Map<Id,SSP_Member__c> mapMembersRecords = new Map<Id,SSP_Member__c>();
            Map<Id,SSP_Application__c> mapApplicationRecords = new Map<Id,SSP_Application__c>();
            Map<String,List<sObject>> mapTobeUpdatedRecords = new Map<String, List<sObject>>();
            Map<String,Set<String>> mapQuestionToMembers = new Map<String,Set<String>>();
            for(SSP_ResourcesWrapper.ResourceSelectionWrapper sspResSelectionWrapper : lstUpdatedValues){
                if(sspResSelectionWrapper.strObject == SSP_GlobalConstants.SSPAPPLICATIONOBJECT){
                    mapApplicationRecords = SSP_ResourcesSelectionController.buildToBeUpdatedWrapperForApplication(mapApplicationRecords, sspResSelectionWrapper);
                } else if(sspResSelectionWrapper.strObject == SSP_GlobalConstants.SSPMEMBEROBJECT){
                    mapMembersRecords = SSP_ResourcesSelectionController.buildToBeUpdatedWrapperForMember(mapMembersRecords, sspResSelectionWrapper);
                    if(sspResSelectionWrapper.strQuestionValue == SSP_GlobalConstants.YES){
                        mapQuestionToMembers.put(sspResSelectionWrapper.strField, new Set<String>(sspResSelectionWrapper.strObjectRecords.split(SSP_GlobalConstants.COMMA)));
                    }
                }
            }

            SSP_LightningResponse housholdMembersResponse = SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers(String.escapeSingleQuotes(sApplicationId), SSP_GlobalConstants.EMPTY, SSP_GlobalConstants.ALL);
            List<SSP_ResourcesWrapper.HouseholdMemberWrapper> lstHouseholdMembers = (List<SSP_ResourcesWrapper.HouseholdMemberWrapper>)JSON.deserialize(String.valueOf(housholdMembersResponse.mapResponse.get(SSP_GlobalConstants.HOUSEHOLDMEMBERS)), List<SSP_ResourcesWrapper.HouseholdMemberWrapper>.class);
            Set<String> setCurrentApplicationMemberIds = new Set<String>();
            for(SSP_ResourcesWrapper.HouseholdMemberWrapper sspHouseholdMemberWrapper : lstHouseholdMembers){
                setCurrentApplicationMemberIds.add(sspHouseholdMemberWrapper.strMemberId);
            }

            Map<String,Set<String>> mapNewQuestionToMembers = new Map<String,Set<String>>();
            for(String strMemberField : mapQuestionToMembers.keySet()){
                for(String strCurrentMember:setCurrentApplicationMemberIds) {
                    if(!mapQuestionToMembers.get(strMemberField).contains(strCurrentMember) && mapNewQuestionToMembers.get(strMemberField) != null){
                        mapNewQuestionToMembers.get(strMemberField).add(strCurrentMember);
                    } else if(!mapQuestionToMembers.get(strMemberField).contains(strCurrentMember) && mapNewQuestionToMembers.get(strMemberField) == null){
                        Set<String> setNoMembers = new Set<String>();
                        setNoMembers.add(strCurrentMember);
                        mapNewQuestionToMembers.put(strMemberField, setNoMembers);
                    }
                }
            }

            for(String strNewMemberField : mapNewQuestionToMembers.keySet()){
                for(String strRecordId : mapNewQuestionToMembers.get(strNewMemberField)){
                    if(mapMembersRecords.get(strRecordId) != null){
                        mapMembersRecords.get(strRecordId).put(strNewMemberField, SSP_GlobalConstants.NO);
                    } else {
                        SSP_Member__c sspMember = new SSP_Member__c();
                        sspMember.Id = Id.valueOf(strRecordId);
                        sspMember.put(strNewMemberField, SSP_GlobalConstants.NO);
                        mapMembersRecords.put(strRecordId, sspMember);
                    }
                }
            }
                
            if(!mapApplicationRecords.values().isEmpty()){
                for(SSP_Application__c sspAppRecord : mapApplicationRecords.values()){
                    setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspAppRecord));
                }
                //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Application__c>(mapApplicationRecords.values()), new List<String>(setAccessFields));
            	SSP_GenericDMLHelper.updateRecords(mapApplicationRecords.values(),  new List<String>(setAccessFields));//Perf: Replacing ESAPI update call
            }

            if(!mapMembersRecords.values().isEmpty()){
                setAccessFields.clear();
                for(SSP_Member__c sspMemberRecord : mapMembersRecords.values()){ 
                    setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspMemberRecord));
                }
                //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Member__c>(mapMembersRecords.values()), new List<String>(setAccessFields));
                SSP_GenericDMLHelper.updateRecords(mapMembersRecords.values(),  new List<String>(setAccessFields));//Perf: Replacing ESAPI update call
            }

            clsLightningResponse.bIsSuccess = true;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'updateResourcesSelectionDetails', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: buildToBeUpdatedWrapperForMember
    * @desc This method is used to get member details for Resources Selection screen
    * @param {Map<Id,SSP_Member__c> mapMemberRecords, SSP_ResourcesWrapper.ResourceSelectionWrapper sspResSelectionWrapper}
    * @return SSP_LightningResponse
    * */
    public static Map<Id,SSP_Member__c> buildToBeUpdatedWrapperForMember(Map<Id,SSP_Member__c> mapMemberRecords, SSP_ResourcesWrapper.ResourceSelectionWrapper sspResSelectionWrapper){
        try{
            List<String> lstSelectedRecords = new List<String>();
            lstSelectedRecords = sspResSelectionWrapper.strObjectRecords.split(SSP_GlobalConstants.COMMA);
  
            for(String recordId : lstSelectedRecords){
                if(mapMemberRecords.get(recordId) != null){
                    mapMemberRecords.get(recordId).put(sspResSelectionWrapper.strField, sspResSelectionWrapper.strQuestionValue);
                } else {
                    SSP_Member__c sspMember = new SSP_Member__c();
                    sspMember.Id = Id.valueOf(recordId);
                    sspMember.put(sspResSelectionWrapper.strField, sspResSelectionWrapper.strQuestionValue);
                    mapMemberRecords.put(recordId, sspMember);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'buildToBeUpdatedWrapperForMember', e.getMessage(), true);
        }
        return mapMemberRecords;
    }

    /**
    * @author: Karthik Gulla
    * @method: buildToBeUpdatedWrapperForApplication
    * @desc This method is used to get application details for Resources Selection screen
    * @param {Map<Id,SSP_Application__c> mapAppRecords, SSP_ResourcesWrapper.ResourceSelectionWrapper sspResSelectionWrapper}
    * @return SSP_LightningResponse
    * */
    public static Map<Id,SSP_Application__c> buildToBeUpdatedWrapperForApplication(Map<Id,SSP_Application__c> mapAppRecords, SSP_ResourcesWrapper.ResourceSelectionWrapper sspResSelectionWrapper){
        try{
            List<String> lstSelectedRecords = new List<String>();
            lstSelectedRecords = sspResSelectionWrapper.strObjectRecords.split(SSP_GlobalConstants.COMMA);
            for(Id recordId : lstSelectedRecords){
                if(mapAppRecords.get(recordId) != null){
                    mapAppRecords.get(recordId).put(sspResSelectionWrapper.strField, sspResSelectionWrapper.strQuestionValue);
                } else {
                    SSP_Application__c sspApplication = new SSP_Application__c();
                    sspApplication.Id = Id.valueOf(recordId);
                    sspApplication.put(sspResSelectionWrapper.strField, sspResSelectionWrapper.strQuestionValue);
                    mapAppRecords.put(recordId, sspApplication);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'buildToBeUpdatedWrapperForApplication', e.getMessage(), true);
        }
        return mapAppRecords;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesSelectionDetails
    * @desc This method is used to get Resources Selection details
    * @parama {Map<String,String> mapInputs}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse getResourcesSelectionDetails(Map<String,String> mapInputs, String sMode){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Map<String,List<String>> mapQuestionMappings = new Map<String,List<String>>();
        try{
            String strApplicationId = mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.APPLICATIONID)) : SSP_GlobalConstants.EMPTY;            
            Set<Id> setMemberIds = new Set<Id>();            
            Set<Id> setAppIds = new Set<Id>();
            setAppIds.add(strApplicationId);
            
            Map<Id,SSP_Member__c> mapMembers = new Map<Id, SSP_Member__c>();
            Map<Id,String> mapMemberPrograms = new Map<Id,String>();
            Map<Id,Boolean> mapTmembers = new Map<Id,Boolean>();
            Map<String,Map<String,Integer>> mapMemberResourceTypeCount = new Map<String,Map<String,Integer>>();
            Map<String, SSP_ResourcesWrapper.ResourceSelectionWrapper> mapResourceSelectionDetails = new Map<String,SSP_ResourcesWrapper.ResourceSelectionWrapper>();
            mapResourceFieldMappings = getStaticResourceDetailsFieldMappings();
            mapResourceTypeMappings = getStaticResourceDetailsTypeMappings();
            SSP_LightningResponse housholdMembersResponse = SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers(strApplicationId, null, SSP_GlobalConstants.ALL);
            List<SSP_ResourcesWrapper.HouseholdMemberWrapper> lstHouseholdMembers = (List<SSP_ResourcesWrapper.HouseholdMemberWrapper>)JSON.deserialize(String.valueOf(housholdMembersResponse.mapResponse.get(SSP_GlobalConstants.HOUSEHOLDMEMBERS)), List<SSP_ResourcesWrapper.HouseholdMemberWrapper>.class);
            for(SSP_ResourcesWrapper.HouseholdMemberWrapper sspHouseholdMemberWrapper : lstHouseholdMembers){
                if(sMode != null && sMode == SSP_GlobalConstants.RAC_AddMember && sspHouseholdMemberWrapper.strMemberStatus == SSP_GlobalConstants.MEMBER_STATUS_New) {
                    setMemberIds.add(sspHouseholdMemberWrapper.strMemberId);
                } else if(sMode != SSP_GlobalConstants.RAC_AddMember){
                    setMemberIds.add(sspHouseholdMemberWrapper.strMemberId);
                }
                mapMemberPrograms.put(sspHouseholdMemberWrapper.strMemberId, sspHouseholdMemberWrapper.strAppliedPrograms);
                mapTmembers.put(sspHouseholdMemberWrapper.strMemberId, sspHouseholdMemberWrapper.bTMember);
            }
            
            Map<String,Integer> mapResourceTypeCount = new Map<String,Integer>();
            for(SSP_Asset__c sspAsset : SSP_ResourcesService.getResourcesForMember(setMemberIds, true, new List<String>())){
                if(mapMemberResourceTypeCount.get(sspAsset.SSP_Member__c) != null){
                    Map<String,Integer> mapResourceCount = mapMemberResourceTypeCount.get(sspAsset.SSP_Member__c);
                    if(mapResourceCount.get(mapResourceTypeMappings.get(sspAsset.ResourceTypeCode__c).SObjectField__c) != null){
                        Integer iResCount = mapMemberResourceTypeCount.get(sspAsset.SSP_Member__c).get(mapResourceTypeMappings.get(sspAsset.ResourceTypeCode__c).SObjectField__c);
                        mapMemberResourceTypeCount.get(sspAsset.SSP_Member__c).put(mapResourceTypeMappings.get(sspAsset.ResourceTypeCode__c).SObjectField__c, iResCount + 1);
                    } else {
                        mapMemberResourceTypeCount.get(sspAsset.SSP_Member__c).put(mapResourceTypeMappings.get(sspAsset.ResourceTypeCode__c).SObjectField__c,1);
                    }
                } else { 
                    mapResourceTypeCount.put(mapResourceTypeMappings.get(sspAsset.ResourceTypeCode__c).SObjectField__c, 1);
                    Map<String,Integer> mapTempResourceCount = mapResourceTypeCount.clone();
                    mapMemberResourceTypeCount.put(sspAsset.SSP_Member__c, mapTempResourceCount);
                }
                mapResourceTypeCount.clear();
            }

            for(String sKey : mapResourceFieldMappings.keyset()){
                List<String> lstPrograms = mapResourceFieldMappings.get(sKey).ApplicablePrograms__c.split(',');
                mapQuestionMappings.put(sKey, lstPrograms);
            }

            for(SSP_Member__c sspMember : SSP_ResourcesService.getMemberDetailsForResource(setMemberIds)){ 
                for(String sKey : mapResourceFieldMappings.keyset()){
                    if(mapMemberPrograms.get(sspMember.Id) != null
                    && !mapTmembers.get(sspMember.Id)
                    && SSP_ResourcesService.hasProgramApplicable(mapMemberPrograms.get(sspMember.Id).split(SSP_GlobalConstants.COLON), mapQuestionMappings.get(sKey))){
                        mapResourceSelectionDetails = SSP_ResourcesSelectionController.buildResourceSelectionWrapper(sKey, sspMember, mapResourceSelectionDetails);
                    }
                }
            }

            for(SSP_Application__c sspApplication : SSP_ResourcesService.getApplicationDetailsForResource(setAppIds)){
                SSP_ResourcesWrapper.ResourceSelectionWrapper sspResSelectionWrapper = new SSP_ResourcesWrapper.ResourceSelectionWrapper();
                sspResSelectionWrapper.strObject = SSP_GlobalConstants.SSPAPPLICATIONOBJECT;
                sspResSelectionWrapper.strField = SSP_GlobalConstants.ISASSETSINEXCESSTOGGLE;
                sspResSelectionWrapper.strQuestionValue = sspApplication.IsAssetsInExcess1MToggle__c;
                sspResSelectionWrapper.strObjectRecords = (sspApplication.IsAssetsInExcess1MToggle__c == SSP_GlobalConstants.YES) ? String.valueOf(sspApplication.Id) : '';
                sspResSelectionWrapper.strAppliedPrograms = sspApplication.ProgramsApplied__c;
                mapResourceSelectionDetails.put(SSP_GlobalConstants.ISASSETSINEXCESSTOGGLE, sspResSelectionWrapper);
            }
            
            clsLightningResponse = SSP_ResourcesService.buildResponse(SSP_GlobalConstants.RESOURCESELECTIONDETAILS, JSON.serializePretty(mapResourceSelectionDetails));
            clsLightningResponse.put(SSP_GlobalConstants.MAPMEMBERSRESOURCECOUNT, JSON.serializePretty(mapMemberResourceTypeCount));
            clsLightningResponse.bIsSuccess = true;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'getResourcesSelectionDetails', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: buildResourceSelectionWrapper
    * @desc This method is used to build wrapper for resource selection page
    * @param {String strKey, SSP_Member__c sspMember, Map<String, SSP_ResourcesWrapper.ResourceSelectionWrapper> mapResSelectionDetails}
    * @return Map<String, SSP_ResourcesWrapper.ResourceSelectionWrapper>
    * */
    public static Map<String, SSP_ResourcesWrapper.ResourceSelectionWrapper> buildResourceSelectionWrapper(String strKey, SSP_Member__c sspMember, Map<String, SSP_ResourcesWrapper.ResourceSelectionWrapper> mapResSelectionDetails){   
        try{
            if(mapResSelectionDetails.get(strKey) == null){
                SSP_ResourcesWrapper.ResourceSelectionWrapper sspResSelectionWrapper = new SSP_ResourcesWrapper.ResourceSelectionWrapper();
                sspResSelectionWrapper.strObject = SSP_GlobalConstants.SSPMEMBEROBJECT;
                sspResSelectionWrapper.strField = strKey;
                sspResSelectionWrapper.strQuestionValue = String.valueOf(sspMember.get(strKey));
                sspResSelectionWrapper.strObjectRecords = (sspMember.get(strKey) == SSP_GlobalConstants.YES) ? String.valueOf(sspMember.Id) : '';
                mapResSelectionDetails.put(strKey,sspResSelectionWrapper);
            } else {
                mapResSelectionDetails.get(strKey).strQuestionValue = SSP_ResourcesSelectionController.getQuestionValue(mapResSelectionDetails.get(strKey).strQuestionValue , String.valueOf(sspMember.get(strKey)));
                mapResSelectionDetails.get(strKey).strObjectRecords = (sspMember.get(strKey) == SSP_GlobalConstants.YES) ? (!String.isBlank(mapResSelectionDetails.get(strKey).strObjectRecords) ? (mapResSelectionDetails.get(strKey).strObjectRecords + SSP_GlobalConstants.COMMA + sspMember.Id) : sspMember.Id) : mapResSelectionDetails.get(strKey).strObjectRecords;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'buildResourceSelectionWrapper', e.getMessage(), true);
        }
        return mapResSelectionDetails;
    }

    /**
    * @author: Karthik Gulla
    * @method: getQuestionValue
    * @desc This method is used to get question value based on old and new values
    * @param {String strOldValue, String strNewValue}
    * @return String
    * */
    public static String getQuestionValue(String strOldValue, String strNewValue){
        String strReturnValue;
        try{
            if(strOldValue == SSP_GlobalConstants.YES) {
                strReturnValue = SSP_GlobalConstants.YES;
            } else if(strOldValue == SSP_GlobalConstants.NO || strOldValue == SSP_GlobalConstants.EMPTY || strOldValue == null){
                strReturnValue = (strNewValue == SSP_GlobalConstants.YES) ? SSP_GlobalConstants.YES : strOldValue;
            } else {
                strReturnValue = SSP_GlobalConstants.EMPTY;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'getQuestionValue', e.getMessage(), true);
        }
        return strReturnValue;
    }

    /**
    * @author: Karthik Gulla
    * @method: getOtherResourceSelectionDetails
    * @desc This method is used to get other resource selection details
    * @param {String sApplicationId}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse getOtherResourceSelectionDetails(String sApplicationId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Set<String> setPrograms = new Set<String>();
        try{
            clsLightningResponse.put(SSP_GlobalConstants.MEDICAIDNONMAGI, SSP_ResourcesService.isNONMagiApplication(sApplicationId) ? true : false);
            clsLightningResponse.put(SSP_GlobalConstants.RESOURCEFIELDMAPPINGS, SSP_ResourcesService.getResourcesDetailsMappings(SSP_GlobalConstants.SOBJECTFIELD, false));
	    clsLightningResponse.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.OTHER_RESOURCE_SELECTION_SCREENID, null).screenPermission);//CD2 2.5 Security Role Matrix and Program Access.
            clsLightningResponse.bIsSuccess = true;
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'getOtherResourceSelectionDetails', e.getMessage(), true);
        }
        return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: getStaticResourceDetailsFieldMappings
    * @desc This method is used to get the resource details mappings
    * @return Map<String,SSP_ResourceMappings__mdt>
    * */
    public static Map<String,SSP_ResourceMappings__mdt> getStaticResourceDetailsFieldMappings() {
        try {
            if(mapResourceFieldMappings == null) {
                mapResourceFieldMappings = SSP_ResourcesService.getResourcesDetailsMappings(SSP_GlobalConstants.SOBJECTFIELD, TRUE);
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'getStaticResourceDetailsFieldMappings', e.getMessage(), true);
        }        
        return mapResourceFieldMappings;
    }

    /**
    * @author: Karthik Gulla
    * @method: getStaticResourceDetailsTypeMappings
    * @desc This method is used to get the resource details mappings
    * @return Map<String,SSP_ResourceMappings__mdt>
    * */
    public static Map<String,SSP_ResourceMappings__mdt> getStaticResourceDetailsTypeMappings() {
        try {
            if(mapResourceTypeMappings == null) {
                mapResourceTypeMappings = SSP_ResourcesService.getResourcesDetailsMappings(SSP_GlobalConstants.RESOURCETYPEAPI, TRUE);
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesSelectionController', 'getStaticResourceDetailsTypeMappings', e.getMessage(), true);
        }        
        return mapResourceTypeMappings;
    }
}