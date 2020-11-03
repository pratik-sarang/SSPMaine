/********************************************************************************************************
* @author       Deloitte
* @description  This is the test class of the LOG_DeleteMessagesScheduler and LOG_DeleteLogMessagesBatch classes
* @date         2015-06-29
* @group        Message Logs - Test Classes
*********************************************************************************************************/
@isTest 
public class LOG_DeleteLogMessagesSchedulerTest
{
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This test method is testing the execution of the batch apex via the delete log messages scheduler class
    * @return       void
    *********************************************************************************************************/
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest
    public static  void logDeleteLogMessagesSchedulerTest()
    {
        // Initialize the LOG_MessageSettings
        LOG_TestDataUtility.generateErrorMgtCustomSetting(true,true,true,true,-1);      

        // Create a LOG_LogMessage__c
        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,'Source','Source Function','Message',True);
        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,'Source','Source Function','Message',True);
   
        Test.StartTest();
        
        // Schedule a batch
        LOG_DeleteLogMessagesScheduler logScheduler = new LOG_DeleteLogMessagesScheduler();         
        logScheduler.execute(null);
        
        Test.stopTest();
        
        //Confirm that the Logs have been deleted
        List<LOG_LogMessage__c> remainingLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 10];
        System.assertEquals(1, remainingLogs.size(),'Success'); //Actual result must be of size 1 since a new log is generated after the batch execution  
    }
}