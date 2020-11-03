/**
* Class Name    : RE_SendSMSClass
* Owner         : DELOITTE
* Created Date  : 06/05/2019
* Description   : Class for sending SMS through Twilio
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/05/2019  Lagan Kankane       Initial Version
**/

public with sharing class RE_SendSMSClass implements RE_SendSMSInterface {
    
    
      public String executeSMSProcess(Map<String,String> parameterMap)
    {
       // 
        executeSMS(parameterMap);
        return 'true';
    }
    
    /**
* Method Name    : executeSMS
* Owner         : Lagan Kankane
* Created Date  : 06/05/2019
* Description   : Method for executing SMS callout functionlity
*/
    @future(callout=true)
    public static void executeSMS(Map<String,String> parameterMap){
        Map<String,Object> mapInputData = (Map<String,Object>)parameterMap;
        Map<String,Object> resp = RE_ServiceHandler.handleExecutionResults('SendSMSTwilio', mapInputData);//fetch from custom metadata
        // Map<String,Object> resp = RE_ServiceHandler.handleExecutionResults('SendSMSTwilio', mapInputData);//fetch from custom setting
       // 
        
    }
    
}