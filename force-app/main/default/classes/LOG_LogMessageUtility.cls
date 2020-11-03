/********************************************************************************************************
* @author         Deloitte
* @description    An utility class providing a set of static methods allowing to log messages into the LOG table
* @date			  2015-07-10
* @group 		  Message Logs
*********************************************************************************************************/
public with sharing class LOG_LogMessageUtility 
{
    
  //***************************************** PUBLIC ENUMS***************************************** 
    
  //------------------------------------------------------------ 
  //Description:   Enumeration of supported log levels 
  //------------------------------------------------------------
  public enum LOG_LogLevel {Debug, Info, Error, Warning}
  
  //***************************************** PRIVATE VARIABLE***************************************** 
  @TestVisible
  private static List<LOG_LogMessage__c> pendingLogsForUpsert = new  List<LOG_LogMessage__c>();
  
  //***************************************** PUBLIC VARIABLE***************************************** 
  public static Boolean queueDMLRequests = false;
    
    
   //***************************************** PUBLIC METHODS***************************************** 
   
    public static void commitQueuedLogsToDatabase()
    {
        if (!pendingLogsForUpsert.isEmpty()){
            try{
                RE_DataAccessChecker.insertObjects(LOG_LogMessage__c.getSObjectType(), pendingLogsForUpsert);
            }
            catch(Exception e){
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                for(LOG_LogMessage__c log :pendingLogsForUpsert){
                    publishEvents.add(new ErrorLog__e(StackTrace__c = log.LOG_Stack_Trace__c,Message__c = log.LOG_Message__c,DebugLevel__c = log.LOG_Debug_Level__c,
                                                      Source__c=log.LOG_Source__c,SourceFunction__c = log.LOG_Source_Function__c));
                }
                EventBus.publish(publishEvents);
            }
        }
        
        pendingLogsForUpsert.clear();
    }
    
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This method retrieves the log settings including the different log parameters (log level
   * 				for which a message must be logged and age till the log must be kept)
   * @return		LOG_LogMessageSettings__c: the log setting to be retreived. If not existing a new log setting is created
   *********************************************************************************************************/
   public static LOG_LogMessageSettings__c getLogSettings() 
   {         
       List<LOG_LogMessageSettings__c> setgs = LOG_LogMessageSettings__c.getall().values();
       if((setgs == null) || (setgs.size() == 0)){
           return insertLogSettings();
       }
       else{
          return setgs[0];  
       }              
   }
    
    
    //***************************************** BASIC METHODS DEFINITION***************************************** 
   
    /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This method logs a list of messages passed as input of the method. This is the main method 
    * 				invoked by all the other method overload.
    * @param		appLogs (List<LOG_LogMessage__c>): the list of messages to log	
    * @return		void
    *********************************************************************************************************/
    public static void logMessage(List<LOG_LogMessage__c> appLogs)
    {
        List<LOG_LogMessage__c> appLogsToInsert = new List<LOG_LogMessage__c>();
        LOG_LogMessageSettings__c setgs = getLogSettings();
        
        for(LOG_LogMessage__c appLog : appLogs)
        {       
            //Check if the message must be inserted depending on the log level
        	if ((appLog.LOG_Debug_Level__c == LOG_LogLevel.Debug.name() && setgs.LOG_Debug__c) || (appLog.LOG_Debug_Level__c == LOG_LogLevel.Error.name() && setgs.LOG_Error__c) ||
            	(appLog.LOG_Debug_Level__c == LOG_LogLevel.Info.name() && setgs.LOG_Info__c)   || (appLog.LOG_Debug_Level__c == LOG_LogLevel.Warning.name() && setgs.LOG_Warning__c))
        	{
                //Truncate payload if too long
                if(appLog.LOG_Integration_Payload__c!=null){
                appLog.LOG_Integration_Payload__c = appLog.LOG_Integration_Payload__c.abbreviate(131072);
                }
                appLogsToInsert.add(appLog);
              
        	}
            appLog.LOG_Reference_Id__c = getIndividualId();   
        }
        
        if (!appLogsToInsert.isEmpty())
        {
            //Force Reviewer Fixes : Kojashree Kakariya
            String switchCaseKey = (!queueDMLRequests)?'TRUE':'FALSE';
            switch on (switchCaseKey) {
                when 'TRUE'{
                    try{
                        //RE_DataAccessChecker.insertObjects(LOG_LogMessage__c.getSObjectType(), appLogsToInsert);
                        insert appLogsToInsert;//Perf fix - Keshav/Sajan
                    }
                    catch(Exception e){
                        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                        for(LOG_LogMessage__c log :appLogsToInsert){
                            publishEvents.add(new ErrorLog__e(StackTrace__c = log.LOG_Stack_Trace__c,Message__c = log.LOG_Message__c,DebugLevel__c = log.LOG_Debug_Level__c,
                                                              Source__c=log.LOG_Source__c,SourceFunction__c = log.LOG_Source_Function__c));
                        }
                        EventBus.publish(publishEvents);
                    } 
                }
                when 'FALSE'{
                    pendingLogsForUpsert.addAll(appLogsToInsert); 
                }
            }
            
        }        
    }
   
    /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This methods logs a message by providing as input an instance of the LOG_LogMessage__c sObject
    * @param		appLog (LOG_LogMessage__c): the message to log	
    * @return		void
    *********************************************************************************************************/
    public static void logMessage(LOG_LogMessage__c appLog)
    {
        List<LOG_LogMessage__c> appLogs = new List<LOG_LogMessage__c>();        
        appLogs.add( appLog );        
        logMessage( appLogs );
    }

    //*****************************************METHODS WITH DIFFERENT LOG PARAMETERS***************************************** 
    
    /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This methods logs a message by providing as input the list of all the possible parameters
    * 				This methods provides the most extensive options
    * @param		logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		message (String): the message to log	
    * @param		payLoad (String): The detailed integrated message (xml, JSON)
    * @param		strackTrace (String): The stack trace of the exception	
    * @param		timeTaken (Long): the execution time of the interface or other processes (in milisecond)
    * @param		referenceId (String): the SFDC Id of the record related to the message to log or the Id of the Job being executed
    * @param		referenceInfo (String): additional information regarding the related record or job 
    * @param		logCode (String): the exception log code	
    * @param		executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
    * @return		LOG_LogMessage__c: the log message that has been created
    *********************************************************************************************************/
    public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String payLoad, String strackTrace, long timeTaken, String referenceId, String referenceInfo, String logCode, Boolean executeDML) 
    {
       LOG_LogMessage__c log = new LOG_LogMessage__c();
            
       log.LOG_Source__c = source;
       log.LOG_Source_Function__c = sourceFunction;
       log.LOG_Reference_Id__c = referenceId;
       log.LOG_Reference_Info__c = referenceInfo;       
       log.LOG_Integration_Payload__c = payload;
       log.LOG_Stack_Trace__c = strackTrace;
       log.LOG_Message__c = message; 
       log.LOG_Debug_Level__c = logLevel.name();
       log.LOG_Log_Code__c = logCode;
       log.LOG_Timer__c = timeTaken;
       //Force Reviewer Fixes : Kojashree Kakariya
       String switchCaseKey = executeDML?'TRUE':'FALSE';
        switch on (switchCaseKey) {
            when 'TRUE'{
              logMessage(log);  
            }
            when 'FALSE'{
                if(null == pendingLogsForUpsert){
                    pendingLogsForUpsert = new List<LOG_LogMessage__c>();
                }
                pendingLogsForUpsert.add(log);
            }
        }
        
       return  log;     
    }
    
    public static void storeLogs(){
        try{
            if(null != pendingLogsForUpsert && !pendingLogsForUpsert.isEmpty()){
                queueDMLRequests = false;
                logMessage(pendingLogsForUpsert);
                pendingLogsForUpsert.clear();
            }
        }catch(Exception e) {
            logMessage(e, 'LOG_LogMessageUtility', 'storeLogs', null, null, null, true);
        }
    }
   
   
   public static void storeLogsFuture() {
   	  if(null != pendingLogsForUpsert && !pendingLogsForUpsert.isEmpty()){
   	  	String logString = JSON.serialize(pendingLogsForUpsert);
   	  	logMessageFuture(logString);
   	  	pendingLogsForUpsert.clear();
   	  }
   }
   
   @future
   public static void logMessageFuture(String logList) {
      try{
          list<LOG_LogMessage__c> pendingLos =(List<LOG_LogMessage__c>)JSON.deserialize(logList,List<LOG_LogMessage__c>.class);
          if(null != pendingLos && !pendingLos.isEmpty()){
              queueDMLRequests = false;
              logMessage(pendingLos);
          }
      }catch(Exception e) {
        logMessage(e, 'LOG_LogMessageUtility', 'storeLogs', null, null, null, true);
      }  
   }
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This methods logs a message by providing as input a subset of the possible parameters
   * @param			logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
   * @param			source (String): the source of the message (Interface name, Functionality name, ...)
   * @param			sourceFunction (String): the calling method (ClassName.MethodName)	
   * @param			message (String): the message to log	
   * @param			payLoad (String): The detailed integrated message (xml, JSON)	
   * @param			logCode (String): the exception log code	
   * @param			executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
   * @return		LOG_LogMessage__c: the log message that has been created
   *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message,  String payLoad, String logCode, Boolean executeDML) 
   {
       return logMessage(logLevel, source, sourceFunction, message, payLoad, '', null, '', '', logCode, executeDML);   
   }
 
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This methods logs a message by providing as input a subset of the possible parameters
   * @param			logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
   * @param			source (String): the source of the message (Interface name, Functionality name, ...)
   * @param			sourceFunction (String): the calling method (ClassName.MethodName)	
   * @param			message (String): the message to log	
   * @param			logCode (String): the exception log code	
   * @param			executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
   * @return		LOG_LogMessage__c: the log message that has been created
   *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String logCode, Boolean executeDML) 
   {
       return logMessage(logLevel, source, sourceFunction, message, '', '', null, '', '', logCode, executeDML);     
   }
   /********************************************************************************************************
   * @author		Kommana Lova Durga Prasad
   * @date			2019-11-19
   * @description	This methods logs a message by providing as input a subset of the possible parameters
   * @param			logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
   * @param			source (String): the source of the message (Interface name, Functionality name, ...)
   * @param			sourceFunction (String): the calling method (ClassName.MethodName)	
   * @param			message (String): the message to log	
   * @param			logCode (String): the exception log code	
   * @param			executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
   * @return		LOG_LogMessage__c: the log message that has been created will created through ErrorLog__e event.
   *********************************************************************************************************/
   public static ErrorLog__e logMessageasPlatformEvent(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String logCode, Boolean executeDML) 
   {
    	ErrorLog__e errorLog = new ErrorLog__e(DebugLevel__c = string.valueof(logLevel),
                                                              ErroLog__c= logCode, Source__c =source, 
                                                              Message__c =message ,SourceFunction__c = sourceFunction);
       if(executeDML){
           EventBus.publish(errorLog);
       }
       return errorLog;
   }
    
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This methods logs a message by providing as input a subset of the possible parameters
   * @param			logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
   * @param			source (String): the source of the message (Interface name, Functionality name, ...)
   * @param			sourceFunction (String): the calling method (ClassName.MethodName)	
   * @param			message (String): the message to log	
   * @param			executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
   * @return		LOG_LogMessage__c: the log message that has been created
   *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, Boolean executeDML) 
   {
       return logMessage(logLevel, source, sourceFunction, message, '', '', null, '', '', '', executeDML);    
   }
    
    
   //*****************************************METHODS TO LOG EXCEPTIONS*****************************************  
   
   /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This methods logs a message related to the specified Exception
    * 				Depending of the exception type several logs might be created (e.g. DML Exception)
    * @param		exc (Exception): the Exception to log
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		additionalMessage (String): (optional) an additional message to log	besides the exception message
    * @param		payLoad (String): The detailed integrated message (xml, JSON)
    * @param		timeTaken (Long): the execution time of the interface or other processes (in milisecond)
    * @param		executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
    * @return		List<LOG_LogMessage__c>: the log messages that have been created
    *********************************************************************************************************/
   public static List<LOG_LogMessage__c> logMessage(Exception exc, String source, String sourceFunction, String additionalMessage, String payLoad, long timeTaken, Boolean executeDML)
   {   
        String message = RE_GlobalConstants.sEmptyString;
        List<LOG_LogMessage__c> msgsToInsertDml = new List<LOG_LogMessage__c>();
         
        if (additionalMessage != null && additionalMessage != ''){
            message = RE_GlobalConstants.LOGS_MESSAGE + additionalMessage + '\n';
        }
        message += 'Exception Type: ' + exc.getTypeName() + '\nException Line Nr: ' + exc.getLineNumber(); 

        if (exc instanceof DmlException){
            DmlException dmlExc = (DmlException) exc;
            msgsToInsertDml = logDMLExceptions(dmlExc, message, exc, source, sourceFunction, payLoad, timeTaken);
                   
            //insert list of logs
            if(executeDML){
                logMessage(msgsToInsertDml);
            } 
        }else{
             //OTHER TYPE OF ERRORS
            message += '\nException Message: ' + exc.getMessage();
            LOG_LogMessage__c logMessageObj = logMessage(LOG_LogLevel.Error, source, sourceFunction, message, payLoad, exc.getStackTraceString(), timeTaken, '', '', exc.getTypeName(), executeDML);                  
            msgsToInsertDml.add(logMessageObj);
        }
        return msgsToInsertDml;
  }
    
   /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This methods logs a message related to the specified Exception
    * 				Depending of the exception type several logs might be created (e.g. DML Exception)
    * 				This is a simplified method overloaded regarding the log of exceptions 
    * @param		exc (Exception): the Exception to log
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		additionalMessage (String): (optional) an additional message to log	besides the exception message
    * @param		executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
    * @return		List<LOG_LogMessage__c>: the log messages that have been created
    *********************************************************************************************************/
   public static List<LOG_LogMessage__c> logMessage(Exception exc, String source, String sourceFunction, String additionalMessage, Boolean executeDML)
   {
   		return logMessage(exc, source, sourceFunction, additionalMessage, '', null, executeDML);
   }
    
   //*****************************************METHODS TO LOG SOBJECTS INFO*****************************************  
   
   /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This methods logs a message related to the specified sObject record
    * @param		logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		message (String): the message to log 
    * @param		logCode (String): (optional) the error log code
    * @param		sObjectInError (sObject): the instance of the sObject for which the message must be logged
    * @param		executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
    * @return		LOG_LogMessage__c: the log message that have been created
    *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String logCode, SObject sObjectInError, Boolean executeDML)
   {   
       List<SObject> listsObjectInError = new List<SObject>();
       listsObjectInError.add(sObjectInError);
       List<LOG_LogMessage__c> logs = logMessage(logLevel, source, sourceFunction, message, logCode, listsObjectInError, executeDML);
       return logs[0];
   }
   
   /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This methods logs a list of messages related to the specified sObject list of records
    * @param		logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		message (String): the message to log 
    * @param		logCode (String): (optional) the error log code
    * @param		listsObjectInError (List<sObject>): the list of sObject records for which the messages must be logged
    * @param		executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done	
    * @return		List<LOG_LogMessage__c>: the log messages that have been created
    *********************************************************************************************************/
   public static List<LOG_LogMessage__c> logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String logCode, List<SObject> listsObjectInError, Boolean executeDML)
   {            
       List<LOG_LogMessage__c> logs = new List<LOG_LogMessage__c>();
              
       for(SObject objInErr : listsObjectInError)
       {
           String objType = objInErr.getSObjectType().getDescribe().getName();
           LOG_LogMessage__c log = logMessage(logLevel, source, sourceFunction, message, '', JSON.serializePretty(objInErr), null, objInErr.id, objType, logCode, false);
           logs.add(log);   
       } 
       
       if (executeDML)
       {
           logMessage(logs);
       }
       
       return logs; 
   }
    /********************************************************************************************************
    * @author		Varun Singh
    * @date			2018-04-17
    * @description	This methord takes saveRecord as input and insert a log for the errors if any
    * @return		none
    *********************************************************************************************************/
    public static void logMessage(list<Database.SaveResult> results ,LOG_LogLevel logLevel, String source, String sourceFunction, String message){
        
        String errMsg = RE_GlobalConstants.sEmptyString;
        try{
        for(Database.SaveResult sr: results){
            if(!sr.isSuccess()){
                    errMsg += sr.getId();
                    for(Database.Error err : sr.getErrors()){
                        errMsg += '\n Error Field:'+err.getFields() +'; Error Code:' + err.getStatusCode() + '; Error Message:' +err.getMessage();
                    }
            }
        }
            
            message += ' - ' + errMsg;
            
            if(String.isNotEmpty(errMsg)){
                        
            LOG_LogMessageUtility.logMessage(logLevel, source, sourceFunction, message, true);
            }
        
        }catch(Exception ex){
            LOG_LogMessageUtility.logMessage(logLevel, source, sourceFunction, 'Error logging message:'+errMsg+'; Exception '+ex.getStackTraceString(), true); 
        }
    }
   
    /********************************************************************************************************
    * @author		Arun Kumar RV
    * @date			2018-06-15
    * @description	This methord takes DeleteResult as input and insert a log for the errors if any
    * @return		none
    *********************************************************************************************************/
    public static void logMessage(list<Database.DeleteResult> results ,LOG_LogLevel logLevel, String source, String sourceFunction, String message){
        
        String errMsg = RE_GlobalConstants.sEmptyString;
        try{
        for(Database.DeleteResult dr: results){
            if(!dr.isSuccess()){
                    errMsg += dr.getId();
                    for(Database.Error err : dr.getErrors()){
                        errMsg += 'Error Field:'+err.getFields() +'; Error Code:' + err.getStatusCode() + '; Error Message:' +err.getMessage();
                    }
            }
        }
            
            message += ' - ' + errMsg;
              
            if(String.isNotEmpty(errMsg)){
                	
            LOG_LogMessageUtility.logMessage(logLevel, source, sourceFunction, message, true);
            }
        }catch(Exception ex){
            LOG_LogMessageUtility.logMessage(logLevel, source, sourceFunction, 'Error logging message:'+errMsg+'; Exception '+ex.getStackTraceString(), true);
        }
    }
    /********************************************************************************************************
    * @author		Pankaj Mohanta
    * @date			2019-04-24
    * @description	This methord is used to insert a integration Request Log record
    * @param		logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		message (String): the message to log 
    * @param		type (String): type of callout e.g. GET/POST/PUT
    * @param		playload (String): request playload data
    * @param		responseCode (String): status code
    * @param		responseData (String): response playload data
    * @param		timeTaken (Long): Time taken
    * @param		executeDML (Boolean):
    * @return		none
    *********************************************************************************************************/
    public static void logMessage(LOG_LogLevel logLevel, String endpoint, String source, String sourceFunction, String message, String type, String payload, String responseCode, String responseData , Long timeTaken, Boolean executeDML){
       LOG_LogMessage__c log = logMessage(logLevel, source, sourceFunction, message, payload, '', timeTaken, '', '', responseCode, false); 
       log.ResponseData__c = trimTheResponse(responseData);
       log.CalloutType__c = type;
       log.EndPoint__c = endpoint;
       logMessage(log);
    }
    

    /********************************************************************************************************
    * @author		Pankaj Mohanta
    * @date			2019-04-24
    * @description	This methord is used log an integration exception
    * @param		ex (Exception): Exception object
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		message (String): the message to log 
    * @param		type (String): type of callout e.g. GET/POST/PUT
    * @param		playloadData (String): request playload data
    * @param		responseCode (String): status code
    * @param		responseData (String): response playload data
    * @param		timeTaken (Long): Time taken
    * @param		executeDML (Boolean):
    * @return		none
    * @return		none
    *********************************************************************************************************/
    public static void logMessage(Exception ex, String endpoint, String source, String sourceFunction, String message, String type, String playloadData, String responseCode, String responseData , Long timeTaken, Boolean executeDML){
        List<LOG_LogMessage__c> lstLog = logMessage(ex, source, sourceFunction, message, playloadData, timeTaken, false);
        if(lstLog != null && lstLog.size() > 0){
            LOG_LogMessage__c log = lstLog[0];
            log.ResponseData__c = trimTheResponse(responseData);
            log.CalloutType__c = type;
            log.LOG_Log_Code__c = responseCode;
            log.EndPoint__c = endpoint;
            logMessage(log);
        }
    }

   //***************************************** PRIVATE METHODS***************************************** 
   
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This method inserts a new log setting with default value: all the log level tracked and age kep 365 days
   * @return		LOG_LogMessageSettings__c: the log setting that has been inserted
   *********************************************************************************************************/
   @TestVisible
   private static LOG_LogMessageSettings__c insertLogSettings() 
   {         
       LOG_LogMessageSettings__c setg = new LOG_LogMessageSettings__c(Name = RE_GlobalConstants.LOGS_DEFAULT_AUTOGENERATED, LOG_Debug__c = true, LOG_Error__c= true, LOG_Info__c = true, LOG_Warning__c = true, LOG_Log_Purge__c = 365);
       RE_DataAccessChecker.insertObject(LOG_LogMessageSettings__c.getSObjectType(), setg);
       //insert setg;  
       return setg;
   }   
    
   /********************************************************************************************************
   * @author		Parjanya Roy
   * @date			2019-02-06
   * @description	Method to record Exceptions arising as a result of CustomValidation to be recorded as Info :: Bug#285339
   * @return		void
   *********************************************************************************************************/
   
    private static void overrideLogLevel(LOG_LogMessage__c logMessage, String exceptionTypeName){
        Set<String> setLogAsInfoExceptionTypes = new Set<String>();
        setLogAsInfoExceptionTypes.add('FIELD_CUSTOM_VALIDATION_EXCEPTION');
        if(logMessage!=null && setLogAsInfoExceptionTypes.contains(exceptionTypeName.trim())){
               logMessage.LOG_Debug_Level__c = RE_GlobalConstants.LOGS_MESSAGE_INFO;
           }
    }

    /********************************************************************************************************
   * @author        Karthik Gulla
   * @date          2019-07-30
   * @description   Method to log DML Exceptions
   * @return        List<LOG_LogMessage__c>
   *********************************************************************************************************/
    private static List<LOG_LogMessage__c> logDMLExceptions(DmlException dmlExc, String sMessage, Exception exc, String source, String sourceFunction, String payLoad, long timeTaken){
        String message = sMessage;
        List<LOG_LogMessage__c> msgsToInsertDml = new List<LOG_LogMessage__c>();
        for (integer i= 0; i<dmlExc.getNumDml(); i++){
            String dmlMessage = message + '\nException Message: ' + dmlExc.getDmlMessage(i);
            String dmlRecordInErrorInfo = RE_GlobalConstants.LOGS_BATCHROW + dmlExc.getDmlIndex(i);
            String fieldsInError = RE_GlobalConstants.sEmptyString;
            for (String fieldName : dmlExc.getDmlFieldNames(i)){
                fieldsInError = String.isBlank(fieldsInError) ? fieldName : fieldsInError + ', ' + fieldName;
            }
            dmlRecordInErrorInfo = RE_GlobalConstants.LOGS_FIELDSINERROR + fieldsInError;               
            LOG_LogMessage__c msg = logMessage(LOG_LogLevel.Error, source, sourceFunction, dmlMessage, payLoad, exc.getStackTraceString(), timeTaken, dmlExc.getDmlId(i), dmlRecordInErrorInfo, dmlExc.getDmlType(i).name(), false);
            if(null!=dmlExc.getDmlType(i)){ // To Override Exception Logging Level for Specific Exceptions
                overrideLogLevel(msg,dmlExc.getDmlType(i).name());
            }
            msgsToInsertDml.add(msg);
        }
        return msgsToInsertDml;
    }
     /********************************************************************************************************
    * @author		Rajeev Kumar
    * @date			2020-03-27
    * @description	This methord is used log an integration exception
    * @param		ex (Exception): Exception object
    * @param		interfaceName (String): Name of the interface)
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		message (String): the message to log 
    * @param		type (String): type of callout e.g. GET/POST/PUT
    * @param		playloadData (String): request playload data
    * @param		responseCode (String): status code
    * @param		responseData (String): response playload data
    * @param		timeTaken (Long): Time taken
    * @param		executeDML (Boolean):
    * @return		LOG_LogMessage__c (Object) Return log Message object
    *********************************************************************************************************/
    
    public static LOG_LogMessage__c logMessage(Exception ex, String endpoint, String interfaceName, String source, String sourceFunction, String message, String type, String playloadData, String responseCode, String responseData , Long timeTaken, Boolean executeDML){
        List<LOG_LogMessage__c> lstLog = logMessage(ex, source, sourceFunction, message, playloadData, timeTaken, false);
        if(lstLog != null && lstLog.size() > 0) {
            LOG_LogMessage__c log = lstLog[0];
            log.ResponseData__c = trimTheResponse(responseData);
            log.CalloutType__c = type;
            log.InterfaceName__c = interfaceName;
            log.LOG_Log_Code__c = responseCode;
            log.EndPoint__c = endpoint;
            if(executeDML){
                logMessage(log);
            }
            return log;
        }
        return null;
    }
     /********************************************************************************************************
    * @author		Kommana Lova Durga Prasasd 
    * @date			2020-03-26
    * @description	This methord is used to insert a integration Request Log record
    * @param		logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param		source (String): the source of the message (Interface name, Functionality name, ...)
    * @param		sourceFunction (String): the calling method (ClassName.MethodName)	
    * @param		message (String): the message to log 
    * @param		type (String): type of callout e.g. GET/POST/PUT
    * @param		playload (String): request playload data
    * @param		responseCode (String): status code
    * @param		responseData (String): response playload data
    * @param		timeTaken (Long): Time taken
    * @param		executeDML (Boolean):
    * @return		LOG_LogMessage__c(Object) : Log Message that have been created
    *********************************************************************************************************/
    
    public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String endpoint, String source,String interfaceName, String sourceFunction, String message, String type, String payload, String responseCode, String responseData , Long timeTaken, Boolean executeDML){
        LOG_LogMessage__c log = logMessage(logLevel, source, sourceFunction, message, payload, '', timeTaken, '', '', responseCode, false); 
        log.ResponseData__c = trimTheResponse(responseData);
        log.CalloutType__c = type;
        log.EndPoint__c = endpoint;
        log.InterfaceName__c = interfaceName;
        if(executeDML){
            logMessage(log);
        } 
        return log;
    }

    private static String trimTheResponse(String response) {
       return (string.isNotBlank(response) && response.length() > 32000) ? response.substring(0,32000) :response;
    }

    public static String getIndividualId(){
        String strIndividualId = '';
        String strCitizenProfileName = 'RE Citizen Profile';
        String strNonCitizenProfileName = 'SSP Non Citizen Profile';
        try{
            Id citizenProfileId = [SELECT Id, Name FROM Profile WHERE Name = :strCitizenProfileName].Id;
            Id nonCitizenProfileId = [SELECT Id, Name FROM Profile WHERE Name = :strNonCitizenProfileName].Id;
            User userDetails = [SELECT Id, Contact.IndividualId__c, ImpersonatedIndividualId__c, SelectedRole__c 
                                FROM User 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
            if(UserInfo.getSessionId() != null 
              && UserInfo.getProfileId() != null
              && UserInfo.getProfileId() == nonCitizenProfileId
              && userDetails != null){
                strIndividualId = userDetails.ImpersonatedIndividualId__c;
            } 

            if(UserInfo.getSessionId() != null 
              && userDetails != null 
              && userDetails.Contact != null
              && UserInfo.getProfileId() != null
              && UserInfo.getProfileId() == citizenProfileId
              ){
                strIndividualId = userDetails.Contact.IndividualId__c;
            }
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'LOG_LogMessageUtility', 'getIndividualId', e.getMessage(), true);
        }
        return strIndividualId;
    }
}