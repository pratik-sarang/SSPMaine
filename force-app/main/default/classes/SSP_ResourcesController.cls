/**
* @author: Karthik Gulla
* @Class Name: SSP_ResourcesController
* @desc This class is used as a controller to call ResourcesService
* @Date 11-15-2019
MODIFICATION LOG :
* */ 
public with sharing class SSP_ResourcesController {
    public static Map<String,SSP_ResourceMappings__mdt> mapResourceFieldMappings;

    /**
    * @author: Karthik Gulla
    * @method: getDetailsForResourcesSummary 
    * @desc This method is used to get details for resources summary
    * @param {Map<String,String> mapInputs}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse getDetailsForResourcesSummary(Map<String,String> mapInputs){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Set<Id> setMemberIds = new Set<Id>();
        List<SSP_ResourcesWrapper> lstRequiredResources = new List<SSP_ResourcesWrapper>();
        List<SSP_ResourcesWrapper> lstNotRequiredResources = new List<SSP_ResourcesWrapper>();
        List<SSP_ResourcesWrapper> lstExistResources = new List<SSP_ResourcesWrapper>();
        List<SSP_Asset__c> lstExistAssets = new List<SSP_Asset__c>();
        List<SSP_Asset__c> lstRequiredAssets = new List<SSP_Asset__c>();
        Map<String,Object> mapAdditionalDetails = new Map<String,Object>();
        Map<String,Integer> mapResExistCount = new Map<String,Integer>();
        Map<Boolean,List<SSP_Asset__c>> mapDataExistToListAssets = new Map<Boolean,List<SSP_Asset__c>>();//Added for Perf fix - Keshav
        Boolean bMedicaidNonMagi = false;
        String strProgramsApplied = '';
        List<String> lstAppPrograms = new List<String>();
        try{          
            String strApplicationId = mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null ? mapInputs.get(SSP_GlobalConstants.APPLICATIONID) : SSP_GlobalConstants.EMPTY;
            String strMemberId = mapInputs.get(SSP_GlobalConstants.MEMBERID) != null ? mapInputs.get(SSP_GlobalConstants.MEMBERID) : SSP_GlobalConstants.EMPTY; 
            setMemberIds.add(strMemberId);
            
            List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(Id.valueOf(strMemberId), Id.valueOf(strApplicationId), null);
            if(!lstAppIndividuals.isEmpty() && lstAppIndividuals[0].ProgramsApplied__c != null){
                bMedicaidNonMagi = (lstAppIndividuals[0].ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.MEDICAID) && lstAppIndividuals[0].MedicaidType__c == SSP_GlobalConstants.NONMAGI) ? true : false;
                strProgramsApplied = (lstAppIndividuals[0].ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.MEDICAID)) ? (lstAppIndividuals[0].ProgramsApplied__c + SSP_GlobalConstants.COLON + lstAppIndividuals[0].MedicaidType__c) : lstAppIndividuals[0].ProgramsApplied__c;
                lstAppPrograms = strProgramsApplied != null ? strProgramsApplied.split(';') : new List<String>();
            }
            List<String> lstResourceBasedPrograms = SSP_ResourcesService.getApplicableResourcesBasedOnPrograms(lstAppPrograms);
            mapDataExistToListAssets = SSP_ResourcesService.getResourcesForMember(setMemberIds, lstResourceBasedPrograms);
            if(mapDataExistToListAssets != null && mapDataExistToListAssets.size()>0 && mapDataExistToListAssets.containsKey(true)){//Added for Perf Fix - Keshav
                //Identify Existing Resources for a Member
                //lstExistAssets = SSP_ResourcesService.getResourcesForMember(setMemberIds, true);
                lstExistAssets = mapDataExistToListAssets.get(true);
                for(SSP_Asset__c sspAssetResource : lstExistAssets){
                    lstExistResources.add(SSP_ResourcesService.buildResourcesWrapper(sspAssetResource));
                }
            }
            
            //Identify Co owner resources for a Member
            for(SSP_Asset__c sspAssetResource : SSP_ResourcesController.getResourcesByOwnership(strMemberId, lstResourceBasedPrograms)){
                SSP_ResourcesWrapper sspResCoOwnerWrapper = SSP_ResourcesService.buildResourcesWrapper(sspAssetResource);
                sspResCoOwnerWrapper.bIsCoownerResource = true;
                lstExistResources.add(sspResCoOwnerWrapper);
            }
            
            //Identify Editable Required Resources
            List<SSP_Asset__c>lstAssets = new List<SSP_Asset__c>();
            if(mapDataExistToListAssets != null && mapDataExistToListAssets.size()>0){//Added for Perf Fix - Keshav
                if( mapDataExistToListAssets.containsKey(false)){
                    lstAssets.addAll(mapDataExistToListAssets.get(false));//Added for Perf Fix - Keshav SSP_ResourcesService.getResourcesForMember(setMemberIds, false);
                }
                if( mapDataExistToListAssets.containsKey(true)){
                    lstAssets.addAll(mapDataExistToListAssets.get(true));//Added for Perf Fix - Keshav lstAssets.addAll(SSP_ResourcesService.getResourcesForMember(setMemberIds, true));
                }
            }
            if(lstAssets != null && lstAssets.size()>0){
                for(SSP_Asset__c sspAssetResource : lstAssets){
                    Integer iResCount = 1;
                    if(!sspAssetResource.IsExistingData__c){ 
                        lstRequiredResources.add(SSP_ResourcesService.buildResourcesWrapper(sspAssetResource));
                    }
                    if(mapResExistCount.containsKey(sspAssetResource.ResourceTypeCode__c)){
                        mapResExistCount.put(sspAssetResource.ResourceTypeCode__c, mapResExistCount.get(sspAssetResource.ResourceTypeCode__c) + 1);
                    } else{
                        mapResExistCount.put(sspAssetResource.ResourceTypeCode__c, iResCount);
                    }
                }
            }
            
            Map<String, List<SSP_ResourcesWrapper>> mapResourcesByMappings = SSP_ResourcesController.getResourcesForSummaryBasedOnResourceMappings(mapResExistCount, mapInputs, lstResourceBasedPrograms);
            lstRequiredResources.addAll(mapResourcesByMappings.get(SSP_GlobalConstants.REQUIREDRESOURCES));
            lstNotRequiredResources.addAll(mapResourcesByMappings.get(SSP_GlobalConstants.NOTREQUIREDRESOURCES));

            clsLightningResponse = SSP_ResourcesService.buildResponse(SSP_GlobalConstants.EXISTINGRESOURCES, JSON.serializePretty(lstExistResources));
            
            if(!lstAppIndividuals.isEmpty()){
                mapAdditionalDetails.put(SSP_GlobalConstants.MEDICAIDNONMAGI, bMedicaidNonMagi);
                clsLightningResponse.put(SSP_GlobalConstants.PROGRAMSAPPLIED, strProgramsApplied);
            } else{
                clsLightningResponse.put(SSP_GlobalConstants.PROGRAMSAPPLIED, SSP_GlobalConstants.EMPTY);
            }
           
            clsLightningResponse.put(SSP_GlobalConstants.RESREQUIRINGDETAILS, JSON.serializePretty(lstRequiredResources));
            clsLightningResponse.put(SSP_GlobalConstants.RESNOTREQUIRINGDETAILS, JSON.serializePretty(lstNotRequiredResources));
            clsLightningResponse.put(SSP_GlobalConstants.ADDITIONALDETAILS, JSON.serializePretty(mapAdditionalDetails));
            clsLightningResponse.put('timeTravelDate', SSP_Utility.today());
            /** 2.5	Security Role Matrix and Program Access. */
            clsLightningResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_SUMMARY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HH_RESOURCE_SUMMARY_SCREENID, null));
            clsLightningResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HH_RESOURCE_DETAILS_SCREENID, null));
            /** */
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'getDetailsForResourcesSummary', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourceTileFieldValue
    * @desc This method is used to get values on Resource Tiles
    * @param {String strLineData, String strLine, SSP_Asset__c assetRecord}
    * @return String
    * */
    public static String getResourceTileFieldValue(String strLineData, String strLine, SSP_Asset__c assetRecord){
        String strResTileValue = SSP_GlobalConstants.EMPTY;
        String strLineFields = SSP_GlobalConstants.EMPTY;
        try{
            if(strLineData != null){
                Map<String,Object> mapLineData = (Map<String,Object>)JSON.deserializeUntyped(strLineData);
            
                if(mapLineData.get(strLine) != null){
                    strLineFields = String.valueOf(mapLineData.get(strLine));
                }
                
                for(String strFieldKey : strLineFields.split(SSP_GlobalConstants.COMMA)){
                    if(assetRecord.get(strFieldKey) != null){
                        strResTileValue = strResTileValue + assetRecord.get(strFieldKey) + ' ';
                    }
                }
            }   
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'getResourceTileFieldValue', e.getMessage(), true);
        }
        return strResTileValue;
    }

    /**
    * @author: Karthik Gulla
    * @method: removeResources
    * @desc This method is used to remove Resources
    * @param {Map<String,String> mapInputs}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse removeResources(Map<String,String> mapInputs){
        SSP_Utility.isAuthenticatedUser();
        Set<Id> setResourceIds = new Set<Id>();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        try{
            if(mapInputs.get(SSP_GlobalConstants.STRRESOURCEID) != null
                && SSP_ResourcesController.isValidSalesforceID( mapInputs.get(SSP_GlobalConstants.STRRESOURCEID), SSP_Asset__c.class)
                && Id.valueOf(mapInputs.get(SSP_GlobalConstants.STRRESOURCEID)).getSObjectType().getDescribe().getName() == SSP_GlobalConstants.ASSETOBJECTNAME){
                setResourceIds.add(mapInputs.get(SSP_GlobalConstants.STRRESOURCEID));
                SSP_ResourcesService.deleteResources(setResourceIds);
            }
            SSP_ResourcesService.updateGatepostQuestions(mapInputs, SSP_GlobalConstants.NO, SSP_GlobalConstants.REMOVE);            
            clsLightningResponse = SSP_ResourcesService.buildResponse('Success', 'true');
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'removeResources', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }

    

    /**
    * @author: Karthik Gulla
    * @method: getMemberDetails
    * @desc This method is used to get Member details
    * @param {Map<String,String> mapInputs}
    * @return Map<String,SSP_Member__c>
    * */
    public static Map<String,SSP_Member__c> getMemberDetails(Map<String,String> mapInputs){
        String strMemberId = SSP_GlobalConstants.EMPTY;
        Map<String, SSP_Member__c> mapMemberDetails = new Map<String, SSP_Member__c>();
        Set<Id> setMemberIds = new Set<Id>();
        try{
            if(mapInputs.get(SSP_GlobalConstants.MEMBERID) != null){
                strMemberId = mapInputs.get(SSP_GlobalConstants.MEMBERID);
            }
            setMemberIds.add(strMemberId);
            for(SSP_Member__c sspMember : SSP_ResourcesService.getMemberDetailsForResource(setMemberIds)){
                mapMemberDetails.put(sspMember.Id, sspMember);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'getMemberDetails', e.getMessage(), true);
        }
        return mapMemberDetails;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicationDetails
    * @desc This method is used to get Application details
    * @param {Map<String,String> mapInputs}
    * @return Map<String,SSP_Application__c>
    * */
    public static Map<String,SSP_Application__c> getApplicationDetails(Map<String,String> mapInputs){
        String strApplicationId = SSP_GlobalConstants.EMPTY;
        Map<String, SSP_Application__c> mapApplicationDetails = new Map<String, SSP_Application__c>();
        Set<Id> setApplicationIds = new Set<Id>();
        try{
            if(mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null){
                strApplicationId = mapInputs.get(SSP_GlobalConstants.APPLICATIONID);
            }
            setApplicationIds.add(strApplicationId);

            for(SSP_Application__c sspApplication : SSP_ResourcesService.getApplicationDetailsForResource(setApplicationIds)){
                mapApplicationDetails.put(sspApplication.Id, sspApplication);
            }         
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'getApplicationDetails', e.getMessage(), true);
        }
        return mapApplicationDetails;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesByOwnership
    * @desc This method is used to get Resources based on Ownership
    * @param {String strMemberId, Boolean bExistingData}
    * @return List<SSP_Asset__c>
    * */
    public static List<SSP_Asset__c> getResourcesByOwnership(String strMemberId, List<String> lstResourcePrograms){
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        try{
            List<SSP_ResourceOwnership__c> lstResourceOwnerships = new List<SSP_ResourceOwnership__c>();            
            Set<Id> setResourceIds = new Set<Id>();
            for(SSP_ResourceOwnership__c sspResOwnership: SSP_ResourcesService.getResourcesByOwnership(strMemberId, lstResourcePrograms)){
                setResourceIds.add(sspResOwnership.SSP_Asset__c);
            }
            if(!setResourceIds.isEmpty()){
                lstAssets = SSP_ResourcesService.getResourceDetails(setResourceIds);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'getResourcesByOwnership', e.getMessage(), true);
        }
        return lstAssets;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesForSummaryBasedOnResourceMappings
    * @desc This method is used to get resource summary details
    * @param {Map<String,Integer> mapResourceExistCount, Map<String,String> mapInputs}
    * @return Map<String,List<SSP_ResourcesWrapper>>
    * */
    public static Map<String,List<SSP_ResourcesWrapper>> getResourcesForSummaryBasedOnResourceMappings(Map<String,Integer> mapResourceExistCount, Map<String,String> mapInputs, List<String> lstResourcePrograms){
        Map<String,List<SSP_ResourcesWrapper>> mapResources = new Map<String, List<SSP_ResourcesWrapper>>();
        List<SSP_ResourcesWrapper> lstReqResources = new List<SSP_ResourcesWrapper>();
        List<SSP_ResourcesWrapper> lstNotReqResources = new List<SSP_ResourcesWrapper>();
        Set<Id> setMemberIds = new Set<Id>();
        Set<Id> setAppIds = new Set<Id>();
        try{
            mapResourceFieldMappings = getStaticResourceDetailsFieldMappings();
            String strApplicationId = mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.APPLICATIONID)) : SSP_GlobalConstants.EMPTY;
            String strMemberId = mapInputs.get(SSP_GlobalConstants.MEMBERID) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.MEMBERID)) : SSP_GlobalConstants.EMPTY;  
            setMemberIds.add(strMemberId);
            setAppIds.add(strApplicationId);

            Map<String, SSP_Member__c> mapMemberDetails = SSP_ResourcesController.getMemberDetails(mapInputs);
            Map<String, SSP_Application__c> mapApplicationDetails = SSP_ResourcesController.getApplicationDetails(mapInputs);
            for(String sKey : mapResourceFieldMappings.keyset()){
                if(!mapResourceExistCount.containsKey(mapResourceFieldMappings.get(sKey).ResourceType__c)){
                    mapResourceExistCount.put(mapResourceFieldMappings.get(sKey).ResourceType__c, 0);
                }
            }
            for(String sKey : mapResourceFieldMappings.keyset()){     
                SSP_ResourcesWrapper sspResourcesWrapper = new SSP_ResourcesWrapper();
                sspResourcesWrapper.strResourceType = mapResourceFieldMappings.get(sKey).ResourceType__c;
                sspResourcesWrapper.strResourceTypeLabel = String.valueOf(mapResourceFieldMappings.get(sKey).get(SSP_GlobalConstants.RTYPE));
                sspResourcesWrapper.bDetailsRequired = mapResourceFieldMappings.get(sKey).DetailsRequired__c;
                sspResourcesWrapper.strTempResId = String.valueof(Math.abs(Crypto.getRandomLong())).substring(0, SSP_GlobalConstants.IRANDOMVALUELENGTH);
                sspResourcesWrapper.strResTileLineOneValue = sspResourcesWrapper.strResourceTypeLabel;
                sspResourcesWrapper.strResTileLineTwoValue  = SSP_GlobalConstants.EMPTY;
                sspResourcesWrapper.strResourceSubType = SSP_GlobalConstants.EMPTY;
                sspResourcesWrapper.strFuneralFundedOption = SSP_GlobalConstants.EMPTY;
                sspResourcesWrapper.strOtherOwners = SSP_GlobalConstants.EMPTY;
                sspResourcesWrapper.strAdditionalOwners = '[{"value":""}]';
                sspResourcesWrapper.isResourceEditable = false;
                sspResourcesWrapper.strAccessToVehicle = 'Y';
                if((mapResourceFieldMappings.get(sKey) != null
                    && mapResourceFieldMappings.get(sKey).DetailsRequired__c)
                    && lstResourcePrograms.contains(mapResourceFieldMappings.get(sKey).ResourceType__c) 
                    && (mapMemberDetails.get(strMemberId) != null
                    && mapMemberDetails.get(strMemberId).get(sKey) != null
                    && mapMemberDetails.get(strMemberId).get(sKey) == SSP_GlobalConstants.YES                   
                    && mapResourceExistCount.get(mapResourceFieldMappings.get(sKey).ResourceType__c) == 0)){
                    lstReqResources.add(sspResourcesWrapper);
                }else if((mapResourceFieldMappings.get(sKey) != null
                    && !mapResourceFieldMappings.get(sKey).DetailsRequired__c) 
                    && lstResourcePrograms.contains(mapResourceFieldMappings.get(sKey).ResourceType__c) 
                    && (mapApplicationDetails.get(strApplicationId) != null
                    && mapApplicationDetails.get(strApplicationId).get(sKey) != null
                    && mapApplicationDetails.get(strApplicationId).get(sKey) == SSP_GlobalConstants.YES)){
                    lstNotReqResources.add(sspResourcesWrapper);
                }
            }
            mapResources.put(SSP_GlobalConstants.REQUIREDRESOURCES, lstReqResources);
            mapResources.put(SSP_GlobalConstants.NOTREQUIREDRESOURCES, lstNotReqResources);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'getResourcesForSummaryBasedOnResourceMappings', e.getMessage(), true);
        }
        return mapResources;
    }

    /**
    * @author: Karthik Gulla
    * @method: isValidSalesforceId
    * @desc This method is used to validate salesforce Id
    * @param {String sfdcId, System.Type t}
    * @return Boolean
    * */
    public static Boolean isValidSalesforceId( String sfdcId, System.Type t ){
        Boolean isValid = false;
        try { 
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( sfdcId ).matches() ){
                // Try to assign it to an Id before checking the type
                Id id = sfdcId;
 
                // Use the Type to construct an instance of this sObject
                sObject sObj = (sObject) t.newInstance();
      
                // Set the ID of the new object to the value to test
                sObj.Id = id;
 
                // If the tests passed, it's valid
                isValid = true;
            }
        } catch ( Exception e ){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'isValidSalesforceId', e.getMessage(), true);
            isValid = false;
        }
 
        // ID is not valid
        return isValid;
    }

    /**
    * @author: Karthik Gulla
    * @method: getStaticResourceDetailsFieldMappings
    * @desc This method is used to get the resource details mappings based on field
    * @return Map<String,SSP_ResourceMappings__mdt>
    * */
    public static Map<String,SSP_ResourceMappings__mdt> getStaticResourceDetailsFieldMappings() {
        try {
            if(mapResourceFieldMappings == null) {
                mapResourceFieldMappings = SSP_ResourcesService.getResourcesDetailsMappings(SSP_GlobalConstants.SOBJECTFIELD);
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesController', 'getStaticResourceDetailsFieldMappings', e.getMessage(), true);
        }        
        return mapResourceFieldMappings;
    }
}