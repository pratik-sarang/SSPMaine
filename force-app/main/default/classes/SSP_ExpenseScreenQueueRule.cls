/*
* classname     :  SSP_ExpenseScreenQueueRule
* @description  :  Class for identifying whether to queue sspChangeExistingExpense & sspRemoveExistingExpense screens for particular individual
* @author       :  Shrikant Raut   
* @date         :  12/10/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_ExpenseScreenQueueRule extends BasicNavFlowRule {
    
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

                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                List<String> lstAppPrograms = new List<String>();
                lstAppPrograms = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c != null ? 
                                 appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>() : new List<String>();
                if(lstAppPrograms.contains(SSP_GlobalConstants.MEDICAID) && appIndividualRecord.MedicaidType__c != null){
                    lstAppPrograms.add(appIndividualRecord.MedicaidType__c);
                }
                List<String> lstExpenseBasedPrograms = SSP_ExpenseController.getApplicableExpensesBasedOnPrograms(lstAppPrograms);
                List<SSP_Asset__c> lstAssetReceived = ctxData.queueObject.mapMemberAsset != null ? ctxData.queueObject.mapMemberAsset.containsKey(ctxData.MemberId) ?
                    									ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId) != null ? ctxData.queueObject.mapMemberAsset.get(ctxData.MemberId):
                    									new List<SSP_Asset__c>() : new List<SSP_Asset__c>(): new List<SSP_Asset__c>();
                for(SSP_Asset__c exp : lstAssetReceived){
                    if(exp != null && exp.RecordTypeId == SSP_ExpenseDetailsQueueRule.EXPENSERECORDTYPENAME && !exp.IsDeleted__c 
                       && exp.IsExistingData__c
                       && lstExpenseBasedPrograms.contains(exp.ExpenseTypeCode__c)){
                        result = true;
                    }
                }
                /*for(SSP_Asset__c expense :
                    SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                     new Set<String>{'Id',  'IsExistingData__c', 'EndDate__c','IsDeleted__c'}, 
                                                     new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> ctxData.MemberId, 'RecordType.DeveloperName'=>'Expense','IsExistingData__c'=>'#true#'})){
                                                         
                                                         if(expense != null && !expense.IsDeleted__c){
                                                             result = true;
                                                             break;
                                                         }
                                                     }*/
                
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpenseScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}