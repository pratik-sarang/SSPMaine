/********************************************************************************************************
* @author         Deloitte
* @description    This class is the implementation of the Schedulable interface and allows to schedule a job in 
*                 order to delete old messages
* @date           2015-06-26
* @group          Message Logs
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* --------------------------------------------------------------------------------
* Ravi Shankar                   02-22-2019                 Bug: 292687 - IronDome issues
*********************************************************************************************************/
global with sharing class LOG_DeleteLogMessagesScheduler implements Schedulable 
{
    
    // Fetch the Log Message Custom Settings in order to retrieve the Log_Purge__c
    private LOG_LogMessageSettings__c lms = LOG_LogMessageUtility.getLogSettings();
    
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method is the implementation of the Schedule interface and invokes a Batch apex in order
    *               to delete old messages
    * @param        sc (SchedulableContext): the context of the scheduled job
    * @return       void
    *********************************************************************************************************/
    global void execute(SchedulableContext sc)
    {
        
        Decimal dPurgeDays = lms.LOG_Log_Purge__c; 
        String sFieldsToQuery = RE_DataBaseQueryFields.sFieldsToQueryOnLogMsg;
        String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnLogMsg;
        String sQuery;
        //String queryString = 'SELECT  id, LOG_Age__c from LOG_LogMessage__c WHERE LOG_Age__c > :dPurgeDays';
        Map<String,String> mapQueryParameters = new Map<String,String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility('LOG_LogMessage__c',sFieldsToQuery,mapQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                           
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sQuery =  mapResponse.get(true);  
                Database.executeBatch(new LOG_DeleteLogMessagesBatch(sQuery,dPurgeDays), 200);
            }   
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, LOG_DeleteLogMessagesScheduler.class.getName(),'execute','Some Fields doesn\'t have the required access :: '+mapResponse.get(false), true);
            }
        }  
        
    }
}