/*
* classname     :  SSP_OtherResSelectionScreenQueueRule
* @description  :  Class for identifying whether to queue sspOtherResourcesSelection screen for particular individual
* @author       :  Karthik Gulla  
* @date         :  02/29/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
**/
public with sharing class SSP_OtherResSelectionScreenQueueRule extends BasicNavFlowRule {
    
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
        List<String> lstResourcePrograms = new List<String>();
        lstResourcePrograms.add(SSP_GlobalConstants.STATE);
        lstResourcePrograms.add(SSP_GlobalConstants.NONMAGI);
        try{
            if(ctxData!=null
                && ctxData.ApplicationId != '' && ctxData.ApplicationId != null
                 && ctxData.modeValue != 'RAC'){ 
                Set<Id> setApplicationIds = new Set<Id>();  
                setApplicationIds.add(ctxData.ApplicationId);

		List<SSP_ApplicationIndividual__c> lstAppIndividuals = ctxData.queueObject.applicationIndividualList != null ? ctxData.queueObject.applicationIndividualList : new List<SSP_ApplicationIndividual__c>();
                List<String> lstAppPrograms = new List<String>();
                List<String> lstEmptyAppPrograms = new List<String>();
                for(SSP_ApplicationIndividual__c sspAppIndividual : lstAppIndividuals){
                    lstAppPrograms.clear(); 
                    lstAppPrograms = sspAppIndividual.ProgramsApplied__c != null ? sspAppIndividual.ProgramsApplied__c.split(';') : lstEmptyAppPrograms;

                    if(lstAppPrograms.contains(SSP_GlobalConstants.MEDICAID)
                        && sspAppIndividual.MedicaidType__c == SSP_GlobalConstants.NONMAGI) {
                        lstAppPrograms.add(SSP_GlobalConstants.NONMAGI);
                    }
                        
                    if(SSP_ResourcesService.hasProgramApplicable(lstAppPrograms, lstResourcePrograms)){
                        result = true;
                        break;
                    }
                } 
            }
        }
        catch(Exception ex){            
            LOG_LogMessageUtility.logMessage(ex, 'SSP_OtherResSelectionScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}