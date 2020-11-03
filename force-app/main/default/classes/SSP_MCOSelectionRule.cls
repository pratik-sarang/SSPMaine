/***************************************************************************************************************************
*   Name         :   SSP_MCOSelectionRule
*   Created By   :   Mounika Darisi
*   Created Date :   08/10/2020
*   Description  :   To decide whether the MCO Selection screen is to be queued in the flow or not
*  
*   Modification Log
*   ----------------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * --------------------------------------------------------------------------------------------               
*     Mounika Darisi              08/10/2020     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_MCOSelectionRule extends BasicNavFlowRule {

    /********************************************************************************************
    * @author       Mounika Darisi
    * @date         08/10/2020
    * @methodname   isRequired
    * @description  To decide whether the MCO Selection screen is to be queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            if(ctxData.MemberId != '' && ctxData.MemberId != null && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ?
                    						ctxData.queueObject.memberAppIndividualMap.containsKey(ctxData.MemberId) ? 
                							ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                List<String> selectedProgramList = (appIndividualRecord != null && appIndividualRecord.MemberProgramsApplied__c != null && String.isNotBlank(appIndividualRecord.MemberProgramsApplied__c)) ? appIndividualRecord.MemberProgramsApplied__c.split(';') : new List<string>() ;
                List<String> appProgramList = (appIndividualRecord != null && appIndividualRecord.ProgramsApplied__c != null)? appIndividualRecord.ProgramsApplied__c.split(';') : new List<string>() ;
                Set<String> evaluatingSet = SSP_GlobalConstants.MCO_SELECTION_PROGRAMS; 
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                Boolean appProgramCheck = SSP_Utility.checkApplicablePrograms(appProgramList, evaluatingSet);
                if(appIndividualRecord != null && appProgramCheck && programCheck && 
                  (appIndividualRecord.MemberStatus__c == SSP_GlobalConstants.MEMBER_STATUS_New || ctxData.modeValue == SSP_GlobalConstants.SSP_INTAKE_FLOW)){
                    result = true;
                }                      
             }
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MCOSelectionRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}