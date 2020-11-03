/*
* classname     :  SSP_LogMessageSelector
* @description  :  Selector class for Log Message
* @author       :  Kireeti Gora  
* @date         :  07/07/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_LogMessageSelector {
    /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         07/07/2020
    * @methodname   queryLogMessageData
    * @description  This methods is to query records related to Log Message object
    * @return       List<LOG_LogMessage__c>
    *****************************************************************************************************/ 
   public static List<LOG_LogMessage__c> queryLogMessageData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        
        List<LOG_LogMessage__c> lstLogMessage = new List<LOG_LogMessage__c>();
        lstLogMessage = (List<LOG_LogMessage__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstLogMessage;
    }
}