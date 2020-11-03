/*
* Classname     :  SSP_SendComToMC_GenerateTokenService
* @description  :  This class is to make callout to get token for Sending Communication Log to MC.
* @author       :  Ragunathan
* @date         :  10/01/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  10/01/2020			Initial creation
**/
public with sharing class SSP_SendComToMC_GenerateTokenService extends RestIntegrationService  {

    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for get the token for Sending Communication Log to MC.
    * @author       : Ragunathan
    * @param developerName : MetaData record name
    * @param mapInputParams : Request body in a map format
    * @return: List<Object>
    * */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        HttpResponse objRes = new HttpResponse();
        HttpRequest objReq = new HttpRequest();
        List<Object> response = new List<Object>();
        Long startTime;
        Long timeTaken;
        Long endTime;
        LOG_LogMessage__c logMessage;
        String responseToLog;
        SSP_SendComToMC_ResponseWrapper responseWrapper;
        try {
            objReq = generateRequest(developerName, mapInputParams);
            startTime = Datetime.now().getTime();
            objRes = sendRequest(objReq);
            endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
			responseToLog = objRes.getBody();
            responseWrapper = (SSP_SendComToMC_ResponseWrapper) JSON.deserialize(
                                                                    objRes.getBody(), 
                                                                    SSP_SendComToMC_ResponseWrapper.class);
            response.add(responseWrapper);
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+objRes.getStatus();
                logMessage = LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    'SSP_SendComToMC_GenerateTokenService',
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    objReq.getMethod(),
                    objReq.getBody(),
                    'Status Code: '+objRes.getStatusCode(),
                    responseToLog,
                    timeTaken, 
                    false);
                    response.add(logMessage);
            }
            
        } catch (Exception ex) {
            endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
            String stErrorMessage =  'Status : '+objRes.getStatus();
            logMessage = LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        developerName,
                                        'SSP_SendComToMC_GenerateTokenService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        responseToLog,
                                        timeTaken, 
                                        true
                                    );
            responseWrapper = new SSP_SendComToMC_ResponseWrapper();
            responseWrapper.logName = logMessage.Name;
            response.add(responseWrapper);
        }
		
        return response;
    }
}