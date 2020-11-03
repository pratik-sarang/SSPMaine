/*
* classname     :  SSP_CareTakerServicesQueueRule
* @description  :  Class for identifying whether to queue sspCareTakerServices screen for particular individual
* @author       :  Shrikant Raut   
* @date         :  04/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_CareTakerServicesQueueRule extends BasicNavFlowRule{
    
    
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
            if(ctxData!=null && String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId)){ //Iron Dome fix
                List<String> appLevelPrgList = new List<String>();
                Set<String> indvLevelPrgSet = new Set<String>();
                //Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
                
                if(ctxData.queueObject.applicationIndividualList != null){
                    for(SSP_ApplicationIndividual__c appIndv :ctxData.queueObject.applicationIndividualList){  
                         if(ctxData.MemberId==appIndv.SSP_Member__c) {  //381345                    
                            if(appLevelPrgList.isEmpty()){
                                appLevelPrgList =  appIndv.SSP_Application__r.ProgramsApplied__c != null ? String.valueOf(appIndv.SSP_Application__r.ProgramsApplied__c).split(';') : appLevelPrgList;
                                if(appLevelPrgList != null && checkPrograms(new Set<String>(appLevelPrgList), new Set<String>{SSP_GlobalConstants.STATE} ) ){
                                    result = true;                                    
                                }
                            }  
                            result = result && appIndv.SSP_Member__r.IsReceivingCaretakerServicesToggle__c != null && appIndv.SSP_Member__r.IsReceivingCaretakerServicesToggle__c == SSP_GlobalConstants.YES ;                            
                            //result = result && ((sessionPart != null && sessionPart.contains(SSP_GlobalConstants.STATE)) ? Boolean.valueOf(sessionPart.get(SSP_GlobalConstants.STATE)) : false); 
                            result = result && (SSP_Utility.getAvailableProgramsByRole().contains(SSP_GlobalConstants.STATE));
                         }
                    }
                }                
            }            
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_CareTakerServicesQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         04/14/2020
* @methodname   checkPrograms
* @description  This methods is used to compare programs
* @return       Boolean
*****************************************************************************************************/    
    public static Boolean checkPrograms(Set<String> appliedSet, Set<String> availablePrgList){
        Boolean result = false;        
        for(String prg : availablePrgList){
            if(appliedSet.contains(prg)){
                result = true;
                break;
            }
        }
        return result;
    }
}