/***************************************************************************************************************************
*   Type         :   Rule Class
*   Name         :   SSP_HouseHoldMealRule
*   Created By   :   Suyash Singhal
*   Created Date :   11/12/2019
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                    11/28/2019        Initial Version
*****************************************************************************************************************************/

public with sharing class SSP_HouseHoldMealRule extends BasicNavFlowRule{ 

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
        Boolean result = False;
        try{
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
        	if(String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId) && ctxData.queueObject != null){
                sspApplicationIndividualList = ctxData.queueObject.applicationIndividualList != null ? ctxData.queueObject.applicationIndividualList : new List<SSP_ApplicationIndividual__c>();
                    /*SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'IsHeadOfHousehold__c', 'SSP_Application__c', 'SSP_Application__r.ProgramsApplied__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10', 'SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId)});*/
            }
            if(!sspApplicationIndividualList.isEmpty()){
                Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap = new Map<Id, SSP_ApplicationIndividual__c> ();
                for(SSP_ApplicationIndividual__c ind : sspApplicationIndividualList){
                        sspApplicationIndividualMap.put(ind.SSP_Member__c, ind);
                } 
                List<String> programValues = sspApplicationIndividualMap.get(ctxData.MemberId).ProgramsApplied__c.split(';');
                if(sspApplicationIndividualMap.get(ctxData.MemberId).IsHeadOfHousehold__c == true && programValues.contains(SSP_GlobalConstants.SNAP) && sspApplicationIndividualList.size() > 1){
                    result = true;
                }
            }
        }
        catch(Exception ex){  
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldMealRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
}