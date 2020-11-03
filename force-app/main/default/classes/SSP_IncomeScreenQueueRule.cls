/*
* classname     :  SSP_IncomeScreenQueueRule
* @description  :  Class for identifying whether to queue sspChangeExistingIncome screen for particular individual
* @author       :  Shrikant Raut   
* @date         :  12/03/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_IncomeScreenQueueRule extends BasicNavFlowRule {
    
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
        try{
            if(ctxData!=null && String.isNotBlank(ctxData.MemberId) && ctxData.queueObject != null){ //Iron Dome fix
                //List<SSP_Asset__c> assetList = ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId);

                //Added to filter income records based on programs
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                List<String> lstAppPrograms = new List<String>();
                lstAppPrograms = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c != null ? 
                                 appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>() : new List<String>();
                                 
                List<String> lstIncomeBasedPrograms = SSP_IncomeController.getApplicableIncomesBasedOnPrograms(lstAppPrograms);

                List<SSP_Asset__c> assetList = ctxData.queueObject.mapMemberAsset != null ? ctxData.queueObject.mapMemberAsset.containsKey(ctxData.MemberId) ?
                                                        ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId) != null ? ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId):
                                                        new List<SSP_Asset__c>() : new List<SSP_Asset__c>(): new List<SSP_Asset__c>();


                for(SSP_Asset__c income : assetList){
                    if(income != null && income.RecordTypeId == SSP_IncomeDetailsQueueRule.INCOMERECORDTYPENAME && !income.isDeleted__c && income.IsExistingData__c && income.EmploymentEndReason__c == null && lstIncomeBasedPrograms.contains(income.IncomeTypeCode__c)){
                        
                        result = true;
                        break;
                    }
                }
                
                /*for(SSP_Asset__c income :
                    SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                     new Set<String>{'Id',  'IsExistingData__c', 'EndDate__c','EmploymentEndReason__c', 'IsDeleted__c'}, 
                                                     new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> ctxData.MemberId, 'RecordType.DeveloperName'=>'Income','IsExistingData__c'=>'#true#'})){
                                                         
                                                          if(income != null && income.IsExistingData__c  && income.EmploymentEndReason__c == null && !income.IsDeleted__c){
                                                                result = true;
                                                             break;
                                                         }
                                                     }*/
                
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}