/***************************************************************************************************************************
*   Type         :   Queueing Logic
*   Name         :   SSP_NonPrimaryContactInformationRule
*   Created By   :   Sanchita Tibrewala
*   Created Date :   11/21/2019
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 11/21/2019     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_NonPrimaryContactInformationRule extends BasicNavFlowRule {
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/21/2019
    * @methodname   isRequired
    * @description  To decide whether the Contact Information page is queued in the flow or not
    * @param        Context, ContextData
    * @return       Boolean
    ********************************************************************************************/
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            List<SSP_Member__c> sspMemberList;
            SSP_ApplicationIndividual__c appIndividualRecord = new SSP_ApplicationIndividual__c();            
            if(ctxData.queueObject != null){
                Map<String,SSP_ApplicationIndividual__c> appIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
                appIndividualMap = ctxData.queueObject.memberAppIndividualMap != null ? ctxData.queueObject.memberAppIndividualMap : new Map<String,SSP_ApplicationIndividual__c>();                
                appIndividualRecord = appIndividualMap != null ? appIndividualMap.containskey(ctxData.MemberId) ? appIndividualMap.get(ctxData.MemberId)
                    					: new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();                
                Boolean selectedProgram = false;
                if(appIndividualRecord != null ){
                    //SSP_ApplicationIndividual__c appIndividualRecord = sspApplicationIndividualList[0];
                	Integer age = (Integer)appIndividualRecord.SSP_Member__r.Age__c;
                    String programs = appIndividualRecord.ProgramsApplied__c;
                    List<String> programValues = programs.split(';');                    
                    for(String program : programValues){
                        if(SSP_GlobalConstants.CONTACT_INFORMATION_PROGRAMS.contains(program)){
                            selectedProgram = true;
                            break;                     
                        }
                	}                    
                    if(((age >= 16 && !appIndividualRecord.IsHeadOfHousehold__c) || appIndividualRecord.IsHeadOfHousehold__c) && selectedProgram){
                    	result = true;
                	}  
            }
            }
            /*if(String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId)){
                sspMemberList = 
                    SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                       new Set<String>{'Id','Age__c'}, 
                                                       new Map<String, String>{'limit'=>'10','Id'=>  String.escapeSingleQuotes(ctxData.MemberId)});
                
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c', 'IsHeadOfHousehold__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});
            }*/
            /*if (!sspMemberList.isEmpty() && !sspApplicationIndividualList.isEmpty()){
                SSP_Member__c record = sspMemberList.get(0);
                SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                Boolean selectedProgram = false;
                Integer age = (Integer)record.Age__c;
                String programs = sspAppInd.ProgramsApplied__c;
                List<String> programValues = programs.split(';');
                for(String program : programValues){
                    if(SSP_GlobalConstants.CONTACT_INFORMATION_PROGRAMS.contains(program)){
                        selectedProgram = true;
                        break;                     
                    }
                }
                if(((age >= 16 && !sspAppInd.IsHeadOfHousehold__c) || sspAppInd.IsHeadOfHousehold__c) && selectedProgram){
                    result = true;
                }
            } */ 
        }
		catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonPrimaryContactInformationRule', 'isRequired', ex.getMessage() , true);
        }
		return result;
    }
    
}