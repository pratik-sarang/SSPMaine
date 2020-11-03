/**
* @author: Karthik Gulla
* @Class Name: SSP_ExistResourcesController
* @desc This class is used as a controller to call ResourcesService for existing resources functionalities
* @Date 11-15-2019
MODIFICATION LOG :
* */ 
public with sharing class SSP_ExistResourcesController {
    public static Map<String,SSP_ResourceMappings__mdt> mapResourceTypeMappings;
    /**
    * @author: Karthik Gulla
    * @method: getExistingResourcesForChangeOrRemoval
    * @desc This method is used to get existing resource details for removal
    * @params {Map<String,String> mapInputs}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse getExistingResourcesForChangeOrRemoval(Map<String,String> mapInputs, List<String> lstAppPrograms){
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Set<Id> setMemberIds = new Set<Id>();
        try{
            String strMemberId = mapInputs.get(SSP_GlobalConstants.MEMBERID) != null ? mapInputs.get(SSP_GlobalConstants.MEMBERID) : ''; 
            setMemberIds.add(strMemberId);
            List<SSP_ResourcesWrapper> lstExistResources = new List<SSP_ResourcesWrapper>();
            List<SSP_Asset__c> lstExistResourceRecords = SSP_ResourcesService.getResourcesForMember(setMemberIds, true, SSP_ResourcesService.getApplicableResourcesBasedOnPrograms(lstAppPrograms));
            if(!lstExistResourceRecords.isEmpty()){
                for(SSP_Asset__c sspAssetResource : lstExistResourceRecords){
                    lstExistResources.add(SSP_ResourcesService.buildResourcesWrapper(sspAssetResource));
                }
            }
            clsLightningResponse = SSP_ResourcesService.buildResponse(SSP_GlobalConstants.EXISTINGRESOURCES, JSON.serializePretty(lstExistResources));
            clsLightningResponse.put('timeTravelDate', SSP_Utility.today());
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ExistResourcesController', 'getExistingResourcesForChangeOrRemoval', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }

     /**
    * @author: Karthik Gulla
    * @method: updateExistingResources
    * @desc This method is used to get update existing resource details
    * @params {String sUpdatedValues}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse updateExistingResources(String sUpdatedValues, String sMemberId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Set<Id> setResourceIds = new Set<Id>();
        try{
            Set<String> setAccessFields = new Set<String>();
            List<SSP_Asset__c> lstToBeUpdatedAssets = (List<SSP_Asset__c>) JSON.deserialize(sUpdatedValues, List<SSP_Asset__c>.class);
            if(!lstToBeUpdatedAssets.isEmpty()){
                for(SSP_Asset__c sspAssetRecord : lstToBeUpdatedAssets){
                    setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspAssetRecord));
                    setResourceIds.add(sspAssetRecord.Id);
                }
                //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Asset__c>(lstToBeUpdatedAssets), new List<String>(setAccessFields));
                //Perf Fix:08/29 : SV
                SSP_GenericDMLHelper.updateRecords(lstToBeUpdatedAssets,  new List<String>(setAccessFields));

            }
            if(!setResourceIds.isEmpty() && sMemberId != null && sMemberId != ''){
                SSP_ExistResourcesController.updateGatepostQuestions(setResourceIds, sMemberId);
            }
            clsLightningResponse.bIsSuccess = true;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ExistResourcesController', 'updateExistingResources', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }

     /**
    * @author: Karthik Gulla
    * @method: updateGatepostQuestions
    * @desc This method is used to get gatepost questions to No if it is the last resource type which is deleted
    * @params {String sUpdatedValues}
    * @return SSP_LightningResponse
    * */
    public static SSP_LightningResponse updateGatepostQuestions(Set<Id> setResourceIds, String sMemberId){
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        Set<Id> setMemberIds = new Set<Id>();
        Map<String,Integer> mapResourceTypeCount = new Map<String,Integer>();
        Set<String> setAccessFields = new Set<String>();
        Set<String> setExistResources = new Set<String>();
        Map<Boolean,List<SSP_Asset__c>> mapDataExistToListAssets = new Map<Boolean,List<SSP_Asset__c>>();
        try{
            setMemberIds.add(sMemberId);
            mapResourceTypeMappings = SSP_ResourcesService.getStaticResourceDetailsTypeMappings();
            mapDataExistToListAssets = SSP_ResourcesService.getResourcesForMember(setMemberIds, new List<String>());
            if(mapDataExistToListAssets != null && mapDataExistToListAssets.size()>0 && mapDataExistToListAssets.containsKey(true)){
                lstAssets = mapDataExistToListAssets.get(true);
            } else if(mapDataExistToListAssets != null && mapDataExistToListAssets.size()>0 && mapDataExistToListAssets.containsKey(false)) {
                lstAssets.addAll(mapDataExistToListAssets.get(false));
            }

            for(SSP_Asset__c sspAssetResource : lstAssets){
                setExistResources.add(sspAssetResource.ResourceTypeCode__c);
            }

            SSP_Member__c sspMemberRecord = new SSP_Member__c();
            sspMemberRecord.Id = sMemberId;            
            for(SSP_Asset__c sspAsset : SSP_ResourcesService.getResourceDetails(setResourceIds)){
                if(!setExistResources.contains(sspAsset.ResourceTypeCode__c)){
                    sspMemberRecord.put(mapResourceTypeMappings.get(sspAsset.ResourceTypeCode__c).SobjectField__c, SSP_GlobalConstants.NO);
                }
            }
            setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspMemberRecord));
            if(!new List<String>(setAccessFields).isEmpty()){
                ESAPI.accessController().updateAsUser(sspMemberRecord, new List<String>(setAccessFields));
            }              
            clsLightningResponse.bIsSuccess = true;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ExistResourcesController', 'updateGatepostQuestions', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }
}