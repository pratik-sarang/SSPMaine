/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_MemberBlindInformationRule
*   Created By   :   Shivam Tiwari
*   Created Date :   12/23/2019
*   Description  :   To decide whether the Member Blindness screen is queued in the flow or not
*  
*   Modification Log
*   ----------------------------------------------------------------------------------------------
*   * Developer                   Date         		 Description
*   * --------------------------------------------------------------------------------------------               
*     Shivam Tiwari              12/23/2019     	Initial Version
*****************************************************************************************************************************/
public class SSP_MemberBlindInformationRule extends BasicNavFlowRule {
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/23/2019
    * @methodname   isRequired
    * @description  To decide whether the Member Blindness page is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){   
        Boolean result = false;
        try{
            List<SSP_Member__c> sspMemberList;
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(ctxData.MemberId != '' && ctxData.MemberId != null && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ? ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ?
                    ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                List<String> selectedProgramList = appIndividualRecord.ProgramsApplied__c != null ? appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>();
                Set<String> evaluatingSet = SSP_GlobalConstants.IN_HOME_ASSISTANCE_PROGRAMS;
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                result = appIndividualRecord != null && (appIndividualRecord.SSP_Member__r.IsBlindToggle__c == SSP_GlobalConstants.YES) 
                          && programCheck;      
                /*String memberId = String.escapeSingleQuotes(ctxData.MemberId);
                sspMemberList = 
                    SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                       new Set<String>{'Id', 'IsBlindToggle__c'}, 
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
                 if(sspMember.IsBlindToggle__c == SSP_GlobalConstants.YES && selectedProgram){
                     result = true;
                 }*/
             }
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberBlindInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }

}