/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_AlienSponsorInformationRule
*   Created By   :   Sanchita Tibrewala
*   Created Date :   03/26/2020
*   Description  :   To decide whether the Alien Sponsor screen is queued in the flow or not
*  
*   Modification Log
*   ----------------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * --------------------------------------------------------------------------------------------               
*     Sanchita                 03/26/2020     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_AlienSponsorInformationRule extends BasicNavFlowRule {

    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         03/26/2020
    * @methodname   isRequired
    * @description  To decide whether the Alien Sponsor page is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            if(ctxData.ApplicationId != null && ctxData.MemberId != null && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ? 
                    	ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ? 
                    ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                List<String> selectedProgramList = appIndividualRecord.ProgramsApplied__c != null ? appIndividualRecord.ProgramsApplied__c.split(';') : new list<String>();
                Set<String> evaluatingSet = SSP_GlobalConstants.ALIEN_SPONSOR_PROGRAMS;
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                result = appIndividualRecord.SSP_Member__c != null && (appIndividualRecord.SSP_Member__r.HasAlienSponsorToggle__c == SSP_GlobalConstants.YES) && programCheck;                         
            }           
            /*List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId)){
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__r.HasAlienSponsorToggle__c', 'ProgramsApplied__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});
            }
            if (!sspApplicationIndividualList.isEmpty()){
                 SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                 Boolean selectedProgram = false;
                 String programs = sspAppInd.ProgramsApplied__c;
                 List<String> programValues = programs.split(';');
                 for(String program : programValues){
                     if(SSP_GlobalConstants.ALIEN_SPONSOR_PROGRAMS.contains(program)){
                         selectedProgram = true;
                         break;                     
                     }
                 }
                 if(sspAppInd.SSP_Member__r.HasAlienSponsorToggle__c == SSP_GlobalConstants.YES && selectedProgram){
                     result = true;
                 }
             }*/
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberDisabilityInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}