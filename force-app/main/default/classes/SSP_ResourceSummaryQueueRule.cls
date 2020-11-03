/*
* classname     :  SSP_ResourcesSelectionScreenQueueRule
* @description  :  Class for identifying whether to queue sspResourceSummary screen for particular individual
* @author       :  Karthik Gulla  
* @date         :  04/10/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
**/
public with sharing class SSP_ResourceSummaryQueueRule extends BasicNavFlowRule {
    
    /**
    * Invoked on workflow "next" action. If true is returned then the page will be marked as "required" in the
    * current flow and so it will be queued to be loaded on its turn. If false is returned then the page
    * will be marked as "not required" and hence will not be loaded in the flow.
    *
    * @param ctx Context object
    * @param ctxData ContextData object
    *
    * @return boolean
    */
    public override boolean isRequired(Context ctx, ContextData ctxData){
        
        Boolean result = false;
        Boolean resourcesResult = false;
        Boolean otherResourcesResult = false;

        Set<String> setApplicationFields = new Set<String>();
        Set<String> setMemberFields = new Set<String>();
        Set<String> setApplicablePrograms = new Set<String>();
        try{
            Map<String,SSP_ResourceMappings__mdt> mapResourceFieldMappings = SSP_ResourcesService.getResourcesDetailsMappings(SSP_GlobalConstants.SOBJECTFIELD);
            if(ctxData!=null
                && ctxData.ApplicationId != '' 
                && ctxData.MemberId != null && ctxData.queueObject != null){ 
                for(SSP_ResourceMappings__mdt resMapping : mapResourceFieldMappings.values()){
                    if(resMapping.DetailsRequired__c){
                        setMemberFields.add(resMapping.SObjectField__c);
                    } else {
                        setApplicationFields.add(resMapping.SObjectField__c);
                    }
                    setApplicablePrograms.addAll(resMapping.ApplicablePrograms__c.split(','));
                }
    
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                List<String> lstAppPrograms = new List<String>();
                lstAppPrograms = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c != null ? 
                    			 appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>() : new List<String>();
                if(lstAppPrograms.contains(SSP_GlobalConstants.MEDICAID) && SSP_ResourcesService.isNONMagiApplication(ctxData.ApplicationId)){
                    lstAppPrograms.add(SSP_GlobalConstants.NONMAGI);
                }
	
                for(String sField : setMemberFields){                    
                    if(appIndividualRecord !=null && appIndividualRecord.SSP_Member__r != null 
                       && appIndividualRecord.SSP_Member__r.get(sField) != null &&
                       appIndividualRecord.SSP_Member__r.get(sField) == SSP_GlobalConstants.YES){
                        resourcesResult = true;
                        break;
                    }
                }

                for(String sField : setApplicationFields){                    
                    if(appIndividualRecord != null && appIndividualRecord.SSP_Application__r != null &&
                       appIndividualRecord.SSP_Application__r.get(sField) != null && 
                       appIndividualRecord.SSP_Application__r.get(sField) == SSP_GlobalConstants.YES 
                       && appIndividualRecord.IsHeadOfHousehold__c){
                        otherResourcesResult = true;
                        break;
                    }
                }

                List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
                List<String> lstResourceBasedPrograms = SSP_ResourcesService.getApplicableResourcesBasedOnPrograms(lstAppPrograms);
                List<SSP_Asset__c> assetList = !(ctxData.queueObject.mapMemberAsset.isEmpty()) ? ctxData.queueObject.mapMemberAsset.containsKey(ctxData.MemberId) ?
                ctxdata.queueObject.mapMemberAsset.get(ctxData.MemberId) : new List<SSP_Asset__c>() : new List<SSP_Asset__c>();
               
                for(SSP_Asset__c assetObj : assetList){
                    if(assetObj.RecordTypeId == SSP_ResourcesService.RESOURCERECORDTYPE 
                        && !assetObj.IsDeleted__c
                        && (!lstResourceBasedPrograms.isEmpty() && lstResourceBasedPrograms.contains(assetObj.ResourceTypeCode__c))){
                        lstAssets.add(assetObj);
                    }
                }
                lstAssets.addAll(SSP_ResourcesController.getResourcesByOwnership(ctxData.MemberId, lstResourceBasedPrograms));

                if((resourcesResult || otherResourcesResult || !lstAssets.isEmpty()) && SSP_ResourcesService.hasProgramApplicable(lstAppPrograms, new List<String>(setApplicablePrograms))){
                    result = true;
                }
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_ResourceSummaryQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}