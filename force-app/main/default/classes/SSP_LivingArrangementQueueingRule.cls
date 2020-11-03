/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_LivingArrangementQueueingRule
*   Create By   :   Samridh Manucha
*   Create Date :   JAN-29-2020
*   Description :   This class checks living arrangement Screen needs to be queued.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                    Description
*   --------------------------------------------------------------------------------------
*    Samridh Manucha           JAN-29-2020             Initial Version
*
*****************************************************************************************************************************/
public with sharing class SSP_LivingArrangementQueueingRule extends BasicNavFlowRule {
    
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
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                List<String> selectedProgramList = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>();
                Set<String> evaluatingSet = SSP_GlobalConstants.IN_HOME_ASSISTANCE_PROGRAMS;
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                result = programCheck;                         
            }            
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_LivingArrangementQueueingRule', 'isRequired', e.getMessage() , true);
        }
        return result;
    }
    
     /**
     * isProgramApplied - This is used to check the programs so that living arrangement screen can be queued up
     *
     * @param string memberId
     * @param string applicationId
     *
     * @return boolean
     */
     
    public static boolean isProgramApplied(string memberId , string applicationId) {
       Boolean isProgram = false;
       if(String.isNotBlank(memberId) && String.isNotBlank(applicationId)){
        List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                        SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                         new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c', 'ProgramsApplied__c', 'MedicaidType__c'}, 
                                                                                         new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId),'SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
         Set<string> livingArrangementPrograms = SSP_GlobalConstants.IN_HOME_ASSISTANCE_PROGRAMS;          
         if(sspApplicationIndividualList.size() > 0)
            {
                SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                String programs = sspAppInd.ProgramsApplied__c;
                List<String> programValues = programs.split(';');
                for(String ind : programValues){
                     if (livingArrangementPrograms.contains(ind) )
                     {  
                        isProgram = true;                    
                        break;
                     }                
                }                       
            }
        }
        return isProgram ;
     }                                                                                 

}