public with sharing class SSP_IncomeDetailsQueueRule extends BasicNavFlowRule {
    
    public static final Id INCOMERECORDTYPENAME = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.INCOMERECORDTYPENAME);
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
                    if(income.RecordTypeId == INCOMERECORDTYPENAME && income.isDeleted__c==false && lstIncomeBasedPrograms.contains(income.IncomeTypeCode__c)){
                        result = true;
                        break;
                    }
                }
                /*for(SSP_Asset__c income :
                    SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                     new Set<String>{'Id','isDeleted__c'}, 
                                                     new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> ctxData.MemberId, 'RecordType.DeveloperName'=>'Income'})){
                                                         if(income != null  && income.isDeleted__c==false){
                                                             result = true;
                                                             break;
                                                         }
                                                     } */               
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeDetailsQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}