/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_RelationshipInformationRule
*   Created By   :   Sanchita Tibrewala
*   Created Date :   02/03/2020
*   Description  :   To decide whether the Relationship page is queued in the flow or not
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 02/03/2020     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_RelationshipInformationRule extends BasicNavFlowRule {
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/03/2020
    * @methodname   isRequired
    * @description  To decide whether the Relationship page is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = new List<SSP_ApplicationIndividual__c> ();
            List<String> programValues = new List<String>();
            Boolean selectedProgram = false;
            Map<String,String> conditionMap = new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId)};
            /*if(String.isNotBlank(ctxData.ApplicationId)){
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c'}, 
                                                                                     conditionMap);
            }*/
            if(ctxData.queueObject != null && ctxData.queueObject.applicationIndividualList != null){
            	 sspApplicationIndividualList = ctxData.queueObject.applicationIndividualList;
            }
            if (!sspApplicationIndividualList.isEmpty() && String.isNotBlank(ctxData.MemberId)){
                Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap = new Map<Id, SSP_ApplicationIndividual__c> ();
                for(SSP_ApplicationIndividual__c ind : sspApplicationIndividualList){
                        sspApplicationIndividualMap.put(ind.SSP_Member__c, ind);
                } 
                String programs = sspApplicationIndividualMap.get(ctxData.MemberId).ProgramsApplied__c;
                if(String.isNotBlank(programs)){
                    programValues = programs.split(';');
                }
                for(String program : programValues){
                    if(SSP_GlobalConstants.IN_HOME_ASSISTANCE_PROGRAMS.contains(program) && sspApplicationIndividualList.size() > 1){
                        selectedProgram = true;
                        break;                     
                    }
                }
            }
            if(selectedProgram){
                result = true;
            }
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RelationshipInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}