/*
* classname     :  SSP_ResourcesScreenQueueRule
* @description  :  Class for identifying whether to queue sspRemoveExistingResource/sspChangeExistingResource screen for particular individual
* @author       :  Karthik Gulla  
* @date         :  12/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
**/
public with sharing class SSP_ResourcesScreenQueueRule extends BasicNavFlowRule {
    
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
        List<String> lstResourcePrograms = new List<String>();
        lstResourcePrograms.add(SSP_GlobalConstants.SNAP);
        lstResourcePrograms.add(SSP_GlobalConstants.KTAP);
        lstResourcePrograms.add(SSP_GlobalConstants.STATE);
        lstResourcePrograms.add(SSP_GlobalConstants.NONMAGI);
        try{
            List<String> lstMemberPrograms = new List<String>();
            if(ctxData!=null 
                && ctxData.MemberId != '' && ctxData.MemberId != null
                && ctxData.ApplicationId != '' && ctxData.ApplicationId != null && ctxData.queueObject != null){
                Set<Id> setMemberIds = new Set<Id>();
                setMemberIds.add(ctxData.MemberId);
                List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
                List<SSP_Asset__c> lstAssetReceived = ctxData.queueObject.mapMemberAsset != null ? ctxData.queueObject.mapMemberAsset.containsKey(ctxData.MemberId) ?
                    									ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId) != null ? ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId):
                    									new List<SSP_Asset__c>() : new List<SSP_Asset__c>(): new List<SSP_Asset__c>();
                
            	SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);

                if(appIndividualRecord != NULL && appIndividualRecord.ProgramsApplied__c != NULL){
                    lstMemberPrograms = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>();              
                    if(appIndividualRecord != null
                        && lstMemberPrograms.contains(SSP_GlobalConstants.MEDICAID)
                        && appIndividualRecord.MedicaidType__c == SSP_GlobalConstants.NONMAGI){
                        lstMemberPrograms.add(SSP_GlobalConstants.NONMAGI);
                    }
                }

                List<String> lstResourceBasedPrograms = SSP_ResourcesService.getApplicableResourcesBasedOnPrograms(lstMemberPrograms);
                for(SSP_Asset__c assetObj : lstAssetReceived){
                    if(assetObj.RecordTypeId == SSP_ResourcesService.RESOURCERECORDTYPE &&
                       assetObj.IsExistingData__c == true && assetObj.IsDeleted__c == false
                       && (!lstResourceBasedPrograms.isEmpty() && lstResourceBasedPrograms.contains(assetObj.ResourceTypeCode__c))){
                        lstAssets.add(assetObj);
                    }
                }   
                
                if(SSP_ResourcesService.hasProgramApplicable(lstMemberPrograms, lstResourcePrograms) && !lstAssets.isEmpty()){
                    result = true;
                }
            }
        }
        catch(Exception ex){            
            LOG_LogMessageUtility.logMessage(ex, 'SSP_ResourcesScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}