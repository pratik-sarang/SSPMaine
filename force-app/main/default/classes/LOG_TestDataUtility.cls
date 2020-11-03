/********************************************************************************************************
* @author       Deloitte
* @description  This test class is the framework used to generate test data to be used by the other test classes
* @date         2015-06-29
* @group        Message Logs - Test Classes
*********************************************************************************************************/
@isTest
public class LOG_TestDataUtility {
   
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method generates a Log Message Custom setting with the parameters provided as input
    * @param        error (Boolean): indicates if the error logs must be logged
    * @param        warning (Boolean): indicates if the warning logs must be logged
    * @param        info (Boolean): indicates if the info logs must be logged
    * @param        debug (Boolean): indicates if the debug logs must be logged
    * @param        logPurge (Boolean): the number of day before the log messages must be deleted
    * @return       void
    *********************************************************************************************************/
    public static LOG_LogMessageSettings__c generateErrorMgtCustomSetting(Boolean error, Boolean warning , Boolean info, Boolean debug, Integer logPurge)    
    {
       //insert custom setting
       LOG_LogMessageSettings__c setg = new LOG_LogMessageSettings__c();
       setg.Name = 'Default';
       setg.LOG_Debug__c = debug;
       setg.LOG_Error__c = error;
       setg.LOG_Info__c = info;
       setg.LOG_Warning__c = warning;
       setg.LOG_Log_Purge__c = logPurge;
       insert setg;
        
       return setg;
    }
 
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method generates a list of test accounts
    * @param        nrOfAccounts (integer): the number of accounts to be created
    * @param        nameRoot (String): the rootname of the accounts being generated
    * @param        executeInsert (Boolean): True of the DML insert must be executed or not, False otherwise
    * @return       List<Account>: the list of generated accounts
    *********************************************************************************************************/
    public static List<Account> generateAccounts(integer nrOfAccounts, String nameRoot, Boolean executeInsert)
    {
        List<Account> accList = new List<Account>();
        for (integer i=1; i<= nrOfAccounts; i++)
        {
            Account acc = new Account();
            acc.Name = nameRoot + ' - ' + String.valueOf(i);
            
            accList.add(acc);
        }
        if (executeInsert)
            insert accList;
        
        return accList;
    }

    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method generates a list of test contacts
    * @param        nrOfContacts (integer): the number of contacts to be created
    * @param        nameRoot (String): the rootname of the contacts being generated
    * @param        linkToAccount (Account): the account to which the contact must be linked to
    * @param        executeInsert (Boolean): True of the DML insert must be executed or not, False otherwise
    * @return       List<Contact>: the list of generated contacts
    *********************************************************************************************************/
    public static List<Contact> generateContacts(integer nrOfContacts, String nameRoot, Account linkToAccount, Boolean executeInsert)
    {
        List<Contact> ctcList = new List<Contact>();
        for (integer i=1; i <= nrOfContacts; i++)
        {
            Contact ctc = new Contact();
            ctc.AccountId = linkToAccount.Id;
            ctc.LastName = nameRoot + ' - ' + String.valueOf(i);
            
            ctcList.add(ctc);
        }
        
        if (executeInsert)
            insert ctcList;
        
        return ctcList;
    }

    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method retireves the logMessage specified by the provided SFDC Id
    * @param        logId (Id): the SFDC Id of the Log message to be retrieved
    * @return       LOG_LogMessage__c: the Queried Log Message
    *********************************************************************************************************/ 
    public static LOG_LogMessage__c getInsertedLog(Id logId){
       LOG_LogMessage__c insertedMsg = [SELECT LOG_Age__c, LOG_Debug_Level__c, Id, LOG_Log_Code__c, LOG_Message__c, Name, LOG_Reference_Id__c, LOG_Reference_Info__c, LOG_Source__c, LOG_Source_Function__c, LOG_Stack_Trace__c, LOG_Timer__c, CreatedDate, LOG_Integration_Payload__c 
                                        FROM LOG_LogMessage__c
                                        WHERE Id = :logId
                                       LIMIT 1];
        return insertedMsg;
    }
     
}