/*
* classname     :  SSP_MedicalEnforcementCtrlQueueRule
* @description  :  Class for identifying whether to queue sspMedicalEnforcement screen for particular individual
* @author       :  Naveena Malapati   
* @date         :  03/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_MedicalEnforcementCtrlQueueRule extends BasicNavFlowRule {
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
        Boolean atleastNonDeceasedMember = false;
        List<SSP_ApplicationIndividual__c> appIndividualList = [SELECT Id, SSP_Member__c, SSP_Application__c, IsHeadOfHousehold__c,
                                                                SSP_Application__r.ProgramsApplied__c,ProgramsApplied__c, SSP_Member__r.Age__c, SSP_Member__r.DeathDate__c
                                                                FROM SSP_ApplicationIndividual__c
                                                                WHERE SSP_Application__c = :ctxData.applicationId];
        // Start - CD2 Security Fixes
		List<SSP_NoncustodialRelationship__c> nonCustodialParentList = SSP_SharingBypassFetcher.fetchRecords (
			new Map<String, String> {'objectName'=>'SSP_NoncustodialRelationship__c'},
            new Set<String> {'Id','SSP_Member__c','SSP_Member__r.Age__c'},
            new Map<String, String> {'SSP_Member__c'=> ctxData.MemberId}
        );
        // End - CD2 Security Fixes
        Map<String, SSP_ApplicationIndividual__c> memberVsAppIndividual = new Map<String,SSP_ApplicationIndividual__c>();
        for(SSP_ApplicationIndividual__c appInd : appIndividualList){
            memberVsAppIndividual.put(appInd.SSP_Member__c, appInd);
        }
        for(SSP_ApplicationIndividual__c appInd : appIndividualList){
            if(appInd.SSP_Member__r.Age__c >= 19 && appInd.SSP_Member__r.DeathDate__c == null){
                atleastNonDeceasedMember = true;
                break;
            }            
        }
        
        String strPrograms = memberVsAppIndividual.get(ctxData.MemberId).ProgramsApplied__c;
        String[] progList = strPrograms.split(';');
        String appPrograms = memberVsAppIndividual.get(ctxData.MemberId).SSP_Application__r.ProgramsApplied__c;
        String[] appProgramsList = appPrograms.split(';');           
        if(nonCustodialParentList.size() > 0 && atleastNonDeceasedMember && !memberVsAppIndividual.get(ctxData.MemberId).IsHeadOfHousehold__c
           && memberVsAppIndividual.get(ctxData.MemberId).SSP_Member__r.Age__c < 19 && progList.contains('MA') && appProgramsList.size() == 1){
               result = true;
           }
       }
       catch(Exception ex){
           List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MedicalEnforcementCtrlQueueRule', 'isRequired', ex.getMessage() , true);
       }
        return result;
    }
}