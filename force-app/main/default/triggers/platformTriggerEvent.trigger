/*********************************************************************************************************************************
* Trigger Name    : platformTriggerEvent
* Owner         : Deloitte
* Created Date  : 11/11/2019 
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  11/11/2019    SRIKANTH      
**/

trigger platformTriggerEvent on ErrorLog__e (after insert) {

    List<LOG_LogMessage__c> lstLogMessage = new List<LOG_LogMessage__c>();
    
    for(ErrorLog__e objErrorLog :trigger.new){
        lstLogMessage.add(new LOG_LogMessage__c(LOG_Stack_Trace__c = objErrorLog.StackTrace__c,
        LOG_Message__c =objErrorLog.Message__c, LOG_Debug_Level__c = objErrorLog.DebugLevel__c,
        EndPoint__c = objErrorLog.EndPoint__c, LOG_Timer__c = objErrorLog.Timer__c,
        LOG_Integration_Payload__c = objErrorLog.Integration_Payload__c, InterfaceName__c = objErrorLog.InterfaceName__c,
        LOG_Log_Code__c = objErrorLog.Log_Code__c, ResponseData__c = objErrorLog.ResponseData__c,
        LOG_Source__c =objErrorLog.Source__c , LOG_Source_Function__c = objErrorLog.SourceFunction__c));
    }
    
    if(lstLogMessage.size() >0 && !lstLogMessage.isEmpty()){
        if(Schema.sObjectType.LOG_LogMessage__c.isCreateable())
        {
        	insert lstLogMessage ;
        }
    }
}
