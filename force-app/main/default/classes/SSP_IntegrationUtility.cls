/**
* Class Name    : SSP_IntegrationUtility
* Owner         : DELOITTE
* Created Date  : 01/04/2020
* Description   : Integration Utility Methods
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          Description                                                         
*  ----------  --------------     -------------------------------------------------------------------
*  11/12/2019  Rajeev Kumar       Initial Version
*  
**/

public class SSP_IntegrationUtility {

    /**
     * method                                       : createLogMessage
     * @description                                 : Create Log Message Record
     * @author                                      : Rajeev Kumar
     * @param ex                                    : Exception object
     * @param objLog                                   : log Message Wrapper
     * @param boolExecuteDML                        : Boolean to perfrom DML or not
     * @return Log_LogMessage__c                    : LogMessage Object Record
     */
    public LOG_LogMessage__c handleException(Exception ex, logMessageWrapper objLog, boolean boolExecuteDML) {
        Log_LogMessage__c objLogRecord =  LOG_LogMessageUtility.logMessage(ex, objLog.endpoint, objLog.interfaceName,objLog.source, objLog.sourceFunction,
                                                objLog.Message, objLog.type, objLog.payload, objLog.responseCode,
                                                objLog.responseData, objLog.timeTaken, boolExecuteDML);
        if(objLogRecord.Id != null){
            return [SELECT Id, Name, responseData__c from Log_LogMessage__c WHERE Id=: objLogRecord.Id];
        }
        return objLogRecord;
         
    }
 
    /**
     * method                                       : createLogMessage
     * @description                                 : Create Log Message Record
     * @author                                      : Rajeev Kumar
     * @param logLevel                              : Log Level, info, error etc.
     * @param objLog                                : log Message Wrapper
     * @param boolExecuteDML                        : Boolean to perfrom DML or not
     * @return Log_LogMessage__c                    : LogMessage Object Record
     */
    public LOG_LogMessage__c createLogMessage(LOG_LogMessageUtility.LOG_LogLevel logLevel, logMessageWrapper objLog, Boolean boolExecuteDML) {
        Log_LogMessage__c objLogRecord = LOG_LogMessageUtility.logMessage(logLevel, objLog.endpoint, objLog.source, objLog.interfaceName, objLog.sourceFunction,
                                                objLog.Message, objLog.type, objLog.payload, objLog.responseCode,
                                                objLog.responseData, objLog.timeTaken, boolExecuteDML);
        if(objLogRecord.Id != null){
            return [SELECT Id, Name, responseData__c from Log_LogMessage__c WHERE Id=: objLogRecord.Id];
        }
        return objLogRecord;
    }

    /**
     * method                                       : getTimeInMilliseconds
     * @description                                 : To Get time in milliseconds
     * @author                                      : Rajeev Kumar
     * @return Integer                              : LogMessage Object Record
     */
    public static Integer getTimeInMilliseconds() {
        DateTime dt = DateTime.Now();
        return ((dt.hour() * 3600000) + 
                (dt.minute() * 60000) + 
                (dt.second() * 1000) + 
                dt.millisecond());
    }
}
