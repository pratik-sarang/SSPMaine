/********************************************************************************************************
* @author       Deloitte
* @description  This is the test class of the LOG_LogMessageUtility class
* @date         2015-06-29
* @group        Message Logs - Test Classes
*********************************************************************************************************/
@isTest
public class LOG_LogMessageUtilityTest {  
    
  
	/********************************************************************************************************
	* @author        Karolinski Stephane
	* @date          2015-08-17
	* @description   This test method tests the getLogSettings method
	* @return        void
	*********************************************************************************************************/
	@isTest
	public static void getLogSettingsTest() 
	{         
		LOG_TestDataUtility.generateErrorMgtCustomSetting(true, false, false, true, 95);

		LOG_LogMessageSettings__c resultSetg = LOG_LogMessageUtility.getLogSettings();
		System.assert(resultSetg != null,'Success'); 
		System.assertEquals(true, resultSetg.LOG_Debug__c,'Success'); 
		System.assertEquals(true, resultSetg.LOG_Error__c,'Error'); 
		System.assertEquals(false, resultSetg.LOG_Info__c,'Info'); 
		System.assertEquals(false, resultSetg.LOG_Warning__c,'Warning');
		System.assertEquals(95, resultSetg.LOG_Log_Purge__c,'Log Purge'); 
	}
   
	/********************************************************************************************************
	* @author        Karolinski Stephane
	* @date          2015-08-17
	* @description   This test method tests the automatic generation of the custom settings
	* @return        void
	*********************************************************************************************************/
	@isTest
	public static void insertLogSettingsTest() 
	{         
		LOG_LogMessageSettings__c setg = LOG_LogMessageUtility.insertLogSettings();       
		LOG_LogMessageSettings__c resultSetg = LOG_LogMessageUtility.getLogSettings();
		System.assert((setg != null) && (resultSetg != null),'Success'); 
		System.assertEquals(true, resultSetg.LOG_Debug__c,'Success'); 
		System.assertEquals(true, resultSetg.LOG_Error__c,'Error'); 
		System.assertEquals(true, resultSetg.LOG_Info__c,'Info'); 
		System.assertEquals(true, resultSetg.LOG_Warning__c,'Warning');
		System.assertEquals(365, resultSetg.LOG_Log_Purge__c,'Log Purge'); 
	}


	/********************************************************************************************************
	* @author        Karolinski Stephane
	* @date          2015-08-17
	* @description   This test method tests the behaviour of the different logMessage methods overload 
	* @return        void
	*********************************************************************************************************/
	@isTest
	public static void logMessageTestSuccess()   
	{  
		// insert custom setting
        REIntegrationEndpoints__c setting = new REIntegrationEndpoints__c();
        setting.Name='RE_GoogleMapAPI';
        setting.Account_API_Key__c='AIzaSyBwQAy5ZMxTXt-Wrc64WsdYtxyYs5N1WYs';
        setting.Endpoint_URI__c='https://maps.googleapis.com/maps/api/geocode/json?';
        insert setting;
		//build test data: Account and Contacts
		Account acc = LOG_TestDataUtility.generateAccounts(1, 'Test Account', true)[0];
		List<Contact> contactsToLog =  LOG_TestDataUtility.generateContacts(2, 'Test Contact', acc, false);      
		contactsToLog[0].FirstName='testName1';
		contactsToLog[1].FirstName='testName2';
		contactsToLog[0].Email='testName1@testcontact.com';
		contactsToLog[1].Email='testName2@testcontact.com';		
		insert contactsToLog;
		Test.startTest();

		//String logMessage = 'exception Message 123';
		LOG_LogMessageUtility.LOG_LogLevel logLevel = LOG_LogMessageUtility.LOG_LogLevel.Debug;
		String sourceComponent = 'sourceComponent 123';
		MyException exc = new MyException('This is an exception');
		LOG_TestDataUtility.generateErrorMgtCustomSetting(true, true, true, true, 95);

		List<LOG_LogMessage__c> msgToInsert = LOG_LogMessageUtility.logMessage(exc, sourceComponent, 'sourceFunction1', 'Log Message test 890', true); 
		System.assert((msgToInsert != null) && (msgToInsert.size() > 0));

		LOG_LogMessage__c insertedMsg = LOG_TestDataUtility.getInsertedLog(msgToInsert[0].Id);
		System.assert(insertedMsg != null);
		System.assertEquals(msgToInsert[0].LOG_Source__c, insertedMsg.LOG_Source__c,'Success');
		System.assertEquals(msgToInsert[0].LOG_Source_Function__c, insertedMsg.LOG_Source_Function__c,'Success');
		System.assertEquals('sourceFunction1', insertedMsg.LOG_Source_Function__c,'Success');
		System.assertEquals(msgToInsert[0].LOG_Message__c, insertedMsg.LOG_Message__c,'Success');
		System.assert(insertedMsg.LOG_Message__c.contains('Message: Log Message test 890'),'Success');
		System.assert(insertedMsg.LOG_Message__c.contains(exc.getMessage()),'Success');
		System.assert(insertedMsg.LOG_Stack_Trace__c != null,'Success');
		System.assertEquals(msgToInsert[0].LOG_Log_Code__c, insertedMsg.LOG_Log_Code__c,'Success');
		// System.assertEquals(0, insertedMsg.LOG_Age__c);
		//System.assertEquals(null, insertedMsg.LOG_Reference_Id__c,'Success');
		System.assertEquals(null, insertedMsg.LOG_Reference_Info__c,'Success');
		System.assertEquals(msgToInsert[0].LOG_Debug_Level__c, insertedMsg.LOG_Debug_Level__c,'Success');
		System.assertEquals('Error', insertedMsg.LOG_Debug_Level__c,'Success');

		List<LOG_LogMessage__c> msgToInsert3 = LOG_LogMessageUtility.logMessage(exc, sourceComponent, 'Function1()', 'test logMessage', '<xml>payLoad</xml>',  9999, true);
		System.assert((msgToInsert3 != null) && (msgToInsert3.size() > 0),'Success');
		LOG_LogMessage__c insertedMsg3 = LOG_TestDataUtility.getInsertedLog(msgToInsert3[0].Id);
		System.assert(insertedMsg3 != null,'Success');     
		System.assertEquals('<xml>payLoad</xml>', insertedMsg3.LOG_Integration_Payload__c,'Success');  
        
        	// Added by Durga Prasad
	        LOG_LogMessage__c msgToinsertInt1 = LOG_LogMessageUtility.logMessage(exc, 'testpoint', 'testint', 'testsource','testsourcefunction', 'testmessage','type','<xml>payLoad</xml>','testrespcode','respdata',null, false);
	        LOG_LogMessage__c msgToinsertInt2 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, 'testpoint', 'testsource', 'testInt','testsourcefunction', 'testmessage','type','<xml>payLoad</xml>','testrespcode','respdata',null, false);
        
	        ErrorLog__e errorPlatformToinsert1 = LOG_LogMessageUtility.logMessageasPlatformEvent(LOG_LogMessageUtility.LOG_LogLevel.Debug,'testsource','testfunction','testmessage','logcode',true);
	        // Closed by Durga Prasad
	        LOG_LogMessage__c msgToInsert2 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'source function()', 'logMessage', '<payLoad/>', '[stack trace]', 100, 'Ref Id 00001', '00001', 'logCode',true);  
	        LOG_LogMessage__c insertedMsg2 = LOG_TestDataUtility.getInsertedLog(msgToInsert2.Id);              
		System.assert(insertedMsg2 != null);
		System.assert(!String.isBlank(insertedMsg2.LOG_Message__c),'Success');
		System.assertEquals(100, insertedMsg2.LOG_Timer__c,'Success');       
		System.assert(insertedMsg2.LOG_Stack_Trace__c != null,'Success');
		//System.assertEquals(0, insertedMsg2.LOG_Age__c,'Success');
		//System.assertEquals('Ref Id 00001',insertedMsg2.LOG_Reference_Id__c,'Success');
		System.assertEquals('00001', insertedMsg2.LOG_Reference_Info__c,'Success');
		System.assertEquals('Debug', insertedMsg2.LOG_Debug_Level__c,'Success');

		msgToInsert[0].Id = null;
		LOG_LogMessageUtility.logMessage(msgToInsert[0]);

		LOG_LogMessage__c msgToInsert5 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', false); 
		System.assert(msgToInsert5.Id == null,'Success');
		msgToInsert5 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', true); 
		System.assert(msgToInsert5.Id != null);
		LOG_LogMessage__c insertedMsg5 = LOG_TestDataUtility.getInsertedLog(msgToInsert5.Id); 
		System.assert(insertedMsg5 != null);
		System.assertEquals('Debug', insertedMsg5.LOG_Debug_Level__c);


		List<LOG_LogMessage__c> msgToInsert6 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', contactsToLog, true); 
		System.assert(msgToInsert6 != null);
		System.assert(msgToInsert6.size() == 2);
		System.assert(msgToInsert6[0].LOG_Reference_Info__c.contains('Contact'));
		LOG_LogMessage__c insertedMsg6 = LOG_TestDataUtility.getInsertedLog(msgToInsert6[0].Id); 
		System.assert(insertedMsg6 != null);
		LOG_LogMessage__c insertedMsg7 = LOG_TestDataUtility.getInsertedLog(msgToInsert6[1].Id); 
		System.assert(insertedMsg7 != null);
		System.assertEquals('logCode', insertedMsg7.LOG_Log_Code__c);

		LOG_LogMessage__c msgToInsert8 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', acc, true); 
		System.assert((msgToInsert8 != null) && (LOG_TestDataUtility.getInsertedLog(msgToInsert8.Id) != null));       
		System.assert(msgToInsert8.LOG_Reference_Info__c.contains('Account'));

		LOG_LogMessage__c msgToInsert9 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', true); 
		System.assert((msgToInsert9 != null) && (LOG_TestDataUtility.getInsertedLog(msgToInsert9.Id) != null));

		LOG_LogMessage__c msgToInsert10 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', '<xml>payLoad</xml>', true); 
		System.assert((msgToInsert10 != null) && (LOG_TestDataUtility.getInsertedLog(msgToInsert10.Id) != null));

		//test DML exception logging
		try{
			insert new Lead();
		}
		catch(DmlException dmlExc)
		{
			List<LOG_LogMessage__c> msgToInsertDml = LOG_LogMessageUtility.logMessage(dmlExc, sourceComponent, 'Function1()', 'test logMessage', '<xml>payLoad</xml>',  9999, true);
			System.assert((msgToInsertDml != null) && (msgToInsertDml.size() > 0));   

			LOG_LogMessage__c insertedMsgDml = LOG_TestDataUtility.getInsertedLog(msgToInsertDml[0].Id);
			System.assert(insertedMsgDml != null);    
			System.assert(insertedMsgDml.LOG_Message__c.contains('System.DmlException'));
			// System.assert(insertedMsgDml.LOG_Log_Code__c.startsWith('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			System.assertEquals(insertedMsgDml.LOG_Source_Function__c, msgToInsertDml[0].LOG_Source_Function__c);
			System.assert((insertedMsgDml.LOG_Timer__c == msgToInsertDml[0].LOG_Timer__c) && (insertedMsgDml.LOG_Timer__c == 9999));
			System.assert(insertedMsgDml.LOG_Stack_Trace__c != null);
		}

		Test.stopTest();

	}

	/********************************************************************************************************
	* @author        Karolinski Stephane
	* @date          2015-09-25
	* @description   This test method tests the Log Queuing functionality 
	* @return        void
	*********************************************************************************************************/
	@isTest
	public static void queueLogMessageTest() 
	{
		//Queue Log Message
		LOG_LogMessageUtility.queueDMLRequests = true;

		//Log 2 messages
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'Queue Message', 'queueLogMessageTest', 'Test Log 1', true); 
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'Queue Message', 'queueLogMessageTest', 'Test Log 1', true); 

		//Check that no message has been logged at that stage
		List<LOG_LogMessage__c> insertedLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 5];
		System.assertEquals(0, insertedLogs.size());

		LOG_LogMessageUtility.commitQueuedLogsToDatabase();

		//Check that the 2 Logs have been inserted and that the Queue is now empty
		insertedLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 5];
		System.assertEquals(2, insertedLogs.size());
		System.assertEquals(0,LOG_LogMessageUtility.pendingLogsForUpsert.size());

		LOG_LogMessageUtility.queueDMLRequests = false;
	}


	/********************************************************************************************************
	* @author        Deloitte
	* @description   Defines a custom exception class used to simulate the exception logMessage method overload
	* @date          2015-06-29
	* @group         Message Logs - Test Classes
	*********************************************************************************************************/
	private class MyException extends Exception {}

	@isTest
	public static void storeLogTest() 
	{  
		//Log 2 messages
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'Store Logs Test 1', 'queueLogMessageTest', 'Test Log 1', 'Test Payload', 'Test', true); 
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'Store Logs Test 2', 'queueLogMessageTest', 'Test Log 1', 'Test Payload', 'Test', true); 

		//Check that no message has been logged at that stage
		List<LOG_LogMessage__c> insertedLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 5];
		String sourceComponent = 'sourceComponent 123';
		MyException exc = new MyException('This is an exception');
		List<LOG_LogMessage__c> msgToInsert = LOG_LogMessageUtility.logMessage(exc, sourceComponent, 'sourceFunction1', 'Log Message test 890', 'Test Payload', null, false); 
		System.assert(!msgToInsert.isEmpty(),'Success');
        //LOG_LogMessageUtility.pendingLogsForUpsert=insertedLogs;
		LOG_LogMessageUtility.storeLogs();
		LOG_LogMessageUtility.storeLogsFuture();
		//LOG_LogMessageUtility.logMessageFuture(JSON.serializePretty(msgToInsert));
	}

	@isTest
	public static void saveResultsLogTest(){
		List<Account> accList = new List<Account>();
		accList.add(new Account(Status__c='Test Exception'));
        Database.SaveResult[] srList = Database.insert(accList, false);
        LOG_LogMessageUtility.logMessage(srList, LOG_LogMessageUtility.LOG_LogLevel.Debug, 'Log Utility', 'saveResultsLogTest', 'Testing error logging');
		List<LOG_LogMessage__c> lstLogMsg=[SELECT Id,LOG_Source_Function__c FROM LOG_LogMessage__c WHERE LOG_Source__c='Log Utility' LIMIT 1];
    	System.assert(lstLogMsg[0].LOG_Source_Function__c =='saveResultsLogTest','Success');
    }

	/*  @isTest
	public static void deleteResultsLogTest(){
		List<Account> accList = new List<Account>();
		accList.add(new Account(Name='Test Exception'));
		Database.DeleteResult[] srList = Database.Delete(accList, false);
		LOG_LogMessageUtility.logMessage(srList, LOG_LogMessageUtility.LOG_LogLevel.Debug, 'Log Utility', 'saveResultsLogTest', 'Testing error logging');
		}*/
		/*   @isTest
		public static void logMessageTest() 
		{
		list<Database.SaveResult> resultsList = new list<Database.SaveResult>();
		try{
		LOG_LogMessageUtility.logMessage(resultsList,null,'stringTest','stringTest','stringTest');
		}
		catch(DMLException e)
		{

		}
	}*/
	@isTest
	public static void logMessageTestDelete() 
	{
		//Database.DeleteResult dr=new Database.DeleteResult();
		List<Account> accList = new List<Account>();
		accList.add(new Account(Name='Test Exception'));
        insert accList;
        Profile objProfile = [SELECT Id from Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        User objREUser = TestDataFactory.createSpecificCommunityUser('reusr',null, 'REUser',  RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);
        list<Database.DeleteResult> resultsList;
        System.runAs(objREUser){
            resultsList = Database.delete(accList, false);
        }
        System.assert(resultsList[0].getErrors()[0].getMessage().contains('insufficient access rights on object'),'Success');
        LOG_LogMessageUtility.logMessage(resultsList,LOG_LogMessageUtility.LOG_LogLevel.Info,'stringTest','stringTest','stringTest');
	}

	@isTest
	public static void testPendingLogs(){
		LOG_LogMessage__c log = new LOG_LogMessage__c();
        log.LOG_Source__c='testSrc';
        log.LOG_Source_Function__c='testFunc';
		List<LOG_LogMessage__c> lstLogs = new List<LOG_LogMessage__c>();
		lstLogs.add(log);
		LOG_LogMessageUtility.pendingLogsForUpsert = lstLogs;
		LOG_LogMessageUtility.storeLogs();
        System.assert(LOG_LogMessageUtility.queueDMLRequests == false,'Success');
	}

	@isTest
	public static void testPendingLogsFuture(){
		LOG_LogMessage__c log = new LOG_LogMessage__c();
		List<LOG_LogMessage__c> lstLogs = new List<LOG_LogMessage__c>();
		lstLogs.add(log);
		LOG_LogMessageUtility.pendingLogsForUpsert = lstLogs;
		LOG_LogMessageUtility.storeLogsFuture();
        System.assert(LOG_LogMessageUtility.queueDMLRequests == false,'Success');
		}
	@isTest
	public static void testLogsIntegrationRequest(){
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'TestEndPoint','Test','testFunction','TestMsg','GET','Test','400','Test',2147483648L,true);
		List<LOG_LogMessage__c> lstLogMsg=[SELECT Id,LOG_Source_Function__c FROM LOG_LogMessage__c WHERE LOG_Source__c='Test' LIMIT 1];
    	System.assert(lstLogMsg[0].LOG_Source_Function__c =='testFunction','Success');
    }
	@isTest
	public static void testLogsIntegrationExcptn(){
		try{
			insert new Account();
		}catch(Exception e){
            System.assert(e.getMessage().contains('REQUIRED_FIELD_MISSING'),'Success');
			LOG_LogMessageUtility.logMessage(e,'TestEndPoint','Test','testFunction','TestMsg','GET','Test','400','Test',2147483648L,false);
		}
	}

}