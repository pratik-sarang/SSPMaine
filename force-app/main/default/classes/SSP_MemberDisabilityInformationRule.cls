/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_MemberDisabilityInformationRule
*   Created By   :   Sanchita Tibrewala
*   Created Date :   12/20/2019
*   Description  :   To decide whether the Member Disability screen is queued in the flow or not
*  
*   Modification Log
*   ----------------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * --------------------------------------------------------------------------------------------               
*     Sanchita                 12/20/2019     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_MemberDisabilityInformationRule extends BasicNavFlowRule {

    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         12/20/2019
    * @methodname   isRequired
    * @description  To decide whether the Member Disability page is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            List<SSP_Member__c> sspMemberList;
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(ctxData.MemberId != null && ctxData.MemberId != '' && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ?
                    						ctxData.queueObject.memberAppIndividualMap.containsKey(ctxData.MemberId) ? 
                							ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                List<String> selectedProgramList = appIndividualRecord.ProgramsApplied__c != null ? appIndividualRecord.ProgramsApplied__c.split(';') : new List<string>() ;
                Set<String> evaluatingSet = SSP_GlobalConstants.IN_HOME_ASSISTANCE_PROGRAMS;
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                result = appIndividualRecord != null && (appIndividualRecord.SSP_Member__r.IsDisabledToggle__c == SSP_GlobalConstants.YES) 
                          && programCheck;                         
               /* String memberId = String.escapeSingleQuotes(ctxData.MemberId);
                sspMemberList = 
                    SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                       new Set<String>{'Id', 'IsDisabledToggle__c'}, 
                                                       new Map<String, String>{'limit'=>'10','Id'=> memberId});
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});
            }
            if (!sspMemberList.isEmpty() && !sspApplicationIndividualList.isEmpty()){
                 SSP_Member__c sspMember = sspMemberList.get(0);
                 SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                 Boolean selectedProgram = false;
                 String programs = sspAppInd.ProgramsApplied__c;
                 List<String> programValues = programs.split(';');
                 for(String program : programValues){
                     if(SSP_GlobalConstants.IN_HOME_ASSISTANCE_PROGRAMS.contains(program)){
                         selectedProgram = true;
                         break;                     
                     }
                 }
                 if(!sspMemberList.isEmpty() && sspMember.IsDisabledToggle__c == SSP_GlobalConstants.YES && selectedProgram){
                     result = true;
                 }*/
             }
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberDisabilityInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}