/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_AmericanIndianInformationRule
*   Created By   :   Sanchita Tibrewala
*   Created Date :   01/09/2020
*   Description  :   To decide whether the American Indian page is queued in the flow or not
*  
*   Modification Log
*   ----------------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * --------------------------------------------------------------------------------------------               
*     Sanchita                 01/09/2020     Initial Version
*****************************************************************************************************************************/
public class SSP_AmericanIndianInformationRule extends BasicNavFlowRule {
	
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         01/09/2020
    * @methodname   isRequired
    * @description  To decide whether the American Indian page is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
             List<SSP_Member__c> sspMemberList = new List<SSP_Member__c> ();
             List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = new List<SSP_ApplicationIndividual__c> ();
             List<String> raceValues = new List<String>();
             List<String> programValues = new List<String>();
             /*if(String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId)){
                 sspMemberList = 
                    SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                       new Set<String>{'Id', 'RaceCode__c'}, 
                                                       new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(ctxData.MemberId)});
                 sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c', 'MedicaidType__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});
             }*/
             if (ctxData.queueObject != null && ctxData.ApplicationId != null && ctxData.MemberId != null){
                 //SSP_Member__c sspMember = sspMemberList.get(0);
                 SSP_ApplicationIndividual__c sspAppInd = ctxData.queueObject.memberAppIndividualMap != null ?
                     ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ? ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) :
                     new SSP_ApplicationIndividual__c () : new SSP_ApplicationIndividual__c();
                 if(sspAppInd.ProgramsApplied__c != NULL && sspAppInd.SSP_Member__c != NULL){
                     String raceCode = sspAppInd.SSP_Member__r.RaceCode__c;
                     if(String.isNotBlank(raceCode)){
                         raceValues = raceCode.split(';');
                     }
                     String programs = sspAppInd.ProgramsApplied__c;
                     if(String.isNotBlank(programs)){
                         programValues = programs.split(';');
                     }
                     if(raceValues.contains(SSP_GlobalConstants.AMERICAN_INDIAN_RACE_CODE) && programValues.contains(SSP_GlobalConstants.MEDICAID) && sspAppInd.MedicaidType__c == SSP_GlobalConstants.MAGI){
                         result = true;
                     }
                 }
             }
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AmericanIndianInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}