public with sharing class SSP_ExpenseDetailsQueueRule extends BasicNavFlowRule {
    public static final Id EXPENSERECORDTYPENAME = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.EXPENSERECORDTYPENAME);
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            /*if(ctxData.modeValue == 'RAC'){
                result = true;
            }
            else*/            
            if(ctxData!=null && String.isNotBlank(ctxData.MemberId)){ //Iron Dome Fix
                result = false;

                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                List<String> lstAppPrograms = new List<String>();
                lstAppPrograms = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c != null ? 
                                 appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>() : new List<String>();
                if(lstAppPrograms.contains(SSP_GlobalConstants.MEDICAID) && appIndividualRecord.MedicaidType__c != null){
                    lstAppPrograms.add(appIndividualRecord.MedicaidType__c);
                }

                List<SSP_Asset__c> lstAssetReceived = ctxData.queueObject.mapMemberAsset != null ? ctxData.queueObject.mapMemberAsset.containsKey(ctxData.MemberId) ?
                    									ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId) != null ? ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId):
                    									new List<SSP_Asset__c>() : new List<SSP_Asset__c>(): new List<SSP_Asset__c>();
                List<String> lstExpenseBasedPrograms = SSP_ExpenseController.getApplicableExpensesBasedOnPrograms(lstAppPrograms);
                for(SSP_Asset__c exp : lstAssetReceived){
                    if(exp != null && exp.RecordTypeId == EXPENSERECORDTYPENAME && !exp.IsDeleted__c && lstExpenseBasedPrograms.contains(exp.ExpenseTypeCode__c) ){
                        result = true;
                        break;
                    }
                }
                /*for(SSP_Asset__c expense :
                    SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                     new Set<String>{'Id', 'IsDeleted__c'}, 
                                                     new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> ctxData.MemberId, 'RecordType.DeveloperName'=>'Expense'})){
                                                         if(expense != null && !expense.IsDeleted__c){
                                                             result = true;
                                                             break;
                                                         }
                                                     }*/                
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpenseDetailsQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}