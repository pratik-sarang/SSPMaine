/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_NotUSCitizenQueueingRule
*   Create By   :   Shivam Tiwari
*   Create Date :   JAN-24-2020
*   Description :   This class checks if Not US Citizen Screen needs to be queued.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                    Description
*   --------------------------------------------------------------------------------------
*    Shivam Tiwari             JAN-24-2020             Initial Version
*
*****************************************************************************************************************************/

public with sharing class SSP_NotUSCitizenQueueingRule extends BasicNavFlowRule {
    
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
    public override boolean isRequired(Context ctx, ContextData ctxData) {
        Boolean result = false;
        try {
            if(ctxData.ApplicationId != null && ctxData.MemberId != null && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ? ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.memberId)?
                    			ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c() ;
                if(appIndividualRecord != NULL && appIndividualRecord.ProgramsApplied__c != NULL){
                    List<String> selectedProgramList = appIndividualRecord.ProgramsApplied__c.split(';');
                    Set<String> evaluatingSet = SSP_GlobalConstants.NOT_US_CITIZEN_PROGRAMS;
                    Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                    result = (appIndividualRecord.SSP_Member__r.IsUSCitizenToggle__c == SSP_GlobalConstants.NO) && programCheck; 
                }        
            }
            /*List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
           if(String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId)){
                String memberId = String.escapeSingleQuotes(ctxData.MemberId);
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c', 'SSP_Member__r.IsUSCitizenToggle__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});
            }
            if (!sspApplicationIndividualList.isEmpty()){
                SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                Boolean selectedProgram = false;
                String programs = sspAppInd.ProgramsApplied__c;
                List<String> programValues = programs.split(';');
                for(String program : programValues){
                    if(SSP_GlobalConstants.NOT_US_CITIZEN_PROGRAMS.contains(program)){
                        selectedProgram = true;
                        break;                     
                    }
                }
                if(sspAppInd.SSP_Member__r.IsUSCitizenToggle__c == SSP_GlobalConstants.NO && selectedProgram){
                    result = true;
                }
            }    */                      
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_NotUSCitizenQueueingRule', 'isRequired', e.getMessage() , true);
        }
        return result;
    }
    
}