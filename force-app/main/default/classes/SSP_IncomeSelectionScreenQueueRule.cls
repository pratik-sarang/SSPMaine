/*
* classname     :  SSP_IncomeSelectionScreenQueueRule
* @description  :  Class for identifying whether to queue sspChangeExistingIncome screen for particular individual
* @author       :  Shrikant Raut   
* @date         :  03/09/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_IncomeSelectionScreenQueueRule extends BasicNavFlowRule{
 
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
            if(ctxData!=null && String.isNotBlank(ctxData.ApplicationId) && ctxData.queueObject != null && ctxData.modeValue != 'RAC'){ //Iron Dome fix
                 List<SSP_ApplicationIndividual__c> appIndividualList = ctxData.queueObject.applicationIndividualList != null ?
                     													ctxData.queueObject.applicationIndividualList : new List<SSP_ApplicationIndividual__c>();
                 if(!appIndividualList.isEmpty()){
                     String appPrograms= appIndividualList[0].ProgramsApplied__c;
                     List<String> programList = appPrograms.split(';');
                     Set<String> applicableProgList = SSP_GlobalConstants.SSP_INCOMESEL_MEMBERLEVEL_PROGRAMS;
                     result = SSP_Utility.checkApplicablePrograms(programList, applicableProgList);
                 }
                /*List<String> appLevelPrgList = new List<String>();
                Set<String> indvLevelPrgSet = new Set<String>();
                for(SSP_ApplicationIndividual__c appIndv : 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(
                        new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME=>'SSP_ApplicationIndividual__c',SSP_GlobalConstants.SSP_OPERATOR=>'AND'}, 
                        new Set<String>{'Id',SSP_GlobalConstants.SSP_PROGRAMS_FIELD,'SSP_Application__r.'+SSP_GlobalConstants.SSP_PROGRAMS_FIELD}, 
                        new Map<String, String>{'SSP_Application__c'=>ctxData.ApplicationId})){
                            
                            if(appLevelPrgList.isEmpty()){
                           		appLevelPrgList = (appIndv.getSObject('SSP_Application__r') != null && appIndv.getSObject('SSP_Application__r').get(SSP_GlobalConstants.SSP_PROGRAMS_FIELD) != null) ? String.valueOf(appIndv.getSObject('SSP_Application__r').get(SSP_GlobalConstants.SSP_PROGRAMS_FIELD)).split(';') : appLevelPrgList;
                                if(appLevelPrgList != null && checkPrograms(new Set<String>(appLevelPrgList), SSP_GlobalConstants.SSP_APPLEVEL) ){
                                    result = true;
                                    break;
                                }
                            }
                            
                            List<String> indvPrgList = (appIndv.get(SSP_GlobalConstants.SSP_PROGRAMS_FIELD) != null ) ? String.valueOf(appIndv.get(SSP_GlobalConstants.SSP_PROGRAMS_FIELD)).split(';') : new List<String>();
                            indvLevelPrgSet.addAll(indvPrgList);
                        }
                if(indvLevelPrgSet != null && checkPrograms(indvLevelPrgSet, SSP_GlobalConstants.SSP_INDVLEVEL)){
                    result = true;
                }*/
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeSelectionScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
    
}