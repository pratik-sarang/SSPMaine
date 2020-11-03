/*
* classname     :  SSP_ExpensesSelectionQueueRule
* @description  :  Class for identifying whether to queue sspExpenseSelection screens for particular applciation
* @author       :  Shrikant Raut   
* @date         :  3/13/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_ExpensesSelectionQueueRule extends BasicNavFlowRule {
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
        Boolean bProgramCheck = false;
        Boolean bAgeCheck = false;
        try{
            if(ctxData!=null && String.isNotBlank(ctxData.ApplicationId) && ctxData.modeValue != 'RAC' && ctxData.queueObject != null ){ //Iron Dome fix
                List<SSP_ApplicationIndividual__c> appIndividualList = ctxData.queueObject.applicationIndividualList != null ? ctxData.queueObject.applicationIndividualList :
                														new List<SSP_ApplicationIndividual__c>();
                 if(!appIndividualList.isEmpty()){
                     String appPrograms= appIndividualList[0].ProgramsApplied__c;
                     List<String> programList = appPrograms.split(';');
                     Set<String> applicableProgList = SSP_GlobalConstants.SSP_EXPENSESEL_PROGRAMS;
                     bProgramCheck = SSP_Utility.checkApplicablePrograms(programList,applicableProgList);
                 }
                for(SSP_ApplicationIndividual__c appIndividual : appIndividualList){
                    if(SSP_Utility.monthsBetweenDates(appIndividual.SSP_Member__r.birthDate__c) > 0){
                        bAgeCheck = true;
                        break;
                    }
                }
                if(bProgramCheck && bAgeCheck){
                    result = true;
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpenseScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}
