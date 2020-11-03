/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_FormerFosterCareInformationRule
*   Created By   :   Sanchita Tibrewala
*   Created Date :   02/11/2020
*   Description  :   To decide whether the Former Foster Care screen is queued in the flow or not
*  
*   Modification Log
*   ----------------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * --------------------------------------------------------------------------------------------               
*     Sanchita                 02/11/2020     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_FormerFosterCareInformationRule extends BasicNavFlowRule {
	
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/11/2020
    * @methodname   isRequired
    * @description  To decide whether the Former Foster Care screen is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            if(ctxData.ApplicationId != null && ctxData.MemberId != null && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                List<String> selectedProgramList = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c.split(';') : new list<String>();
                Set<String> evaluatingSet = new Set<String> {SSP_GlobalConstants.MEDICAID};
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                result = appIndividualRecord != null && (appIndividualRecord.SSP_Member__r.IsFosterCareToggle__c == SSP_GlobalConstants.YES) && programCheck;                         
            }
             /*List<SSP_Member__c> sspMemberList;
             List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
             if(String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId)){
                 sspMemberList = 
                    SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                       new Set<String>{'Id', 'IsFosterCareToggle__c'}, 
                                                       new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(ctxData.MemberId)});
                 sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});
             }
             if (!sspMemberList.isEmpty() && !sspApplicationIndividualList.isEmpty()){
                 SSP_Member__c sspMember = sspMemberList.get(0);
                 SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                 String programs = sspAppInd.ProgramsApplied__c;
                 List<String> programValues = programs.split(';');
                 if(sspMember.IsFosterCareToggle__c == SSP_GlobalConstants.YES && !programValues.isEmpty() && programValues.contains(SSP_GlobalConstants.MEDICAID)){
                     result = true;
                 }
             }*/
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_FormerFosterCareInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}