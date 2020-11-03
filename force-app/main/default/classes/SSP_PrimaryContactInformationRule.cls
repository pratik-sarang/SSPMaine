/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_PrimaryContactInformationRule
*   Created By   :   Sanchita Tibrewala
*   Created Date :   01/31/2020
*   Description  :   To decide whether the Contact Information page is queued in the flow or not
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 01/31/2020     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_PrimaryContactInformationRule extends BasicNavFlowRule {
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         01/31/2020
    * @methodname   isRequired
    * @description  To decide whether the Contact Information page is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(String.isNotBlank(ctxData.ApplicationId)){
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});
            }
            if (!sspApplicationIndividualList.isEmpty()){
                SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                Boolean selectedProgram = false;
                String programs = sspAppInd.ProgramsApplied__c;
                List<String> programValues = programs.split(';');
                for(String program : programValues){
                    if(SSP_GlobalConstants.CONTACT_INFORMATION_PROGRAMS.contains(program)){
                        selectedProgram = true;
                        break;                     
                    }
                }
                if(selectedProgram){
                    result = true;
                }
            }  
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_PrimaryContactInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}