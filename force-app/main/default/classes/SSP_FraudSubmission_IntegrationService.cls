/*
* Classname     :  SSP_ReportFraud_IntegrationService
* @description  :  This class is to make callout for Fraud Submission
* @author       :  Ragunathan
* @date         :  07/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  07/14/2020			Initial creation
**/

public with sharing class SSP_FraudSubmission_IntegrationService extends RestIntegrationService  {

    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for Fraud Submission interface
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
        SSP_FraudSubmission_ResponseWrapper responseWrapper;
        try {
            objReq = generateRequest(developerName,mapInputParams);
            startTime = Datetime.now().getTime();
            objRes = sendRequest(objReq);
            endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
			responseToLog = objRes.getBody();
            responseWrapper = (SSP_FraudSubmission_ResponseWrapper) JSON.deserialize(
                                                                    objRes.getBody(), 
                                                                    SSP_FraudSubmission_ResponseWrapper.class);
            response.add(responseWrapper);
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
                logMessage = LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    'SSP_FraudSubmission_IntegrationService',
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    objReq.getMethod(),
                    objReq.getBody(),
                    'Status Code: '+objRes.getStatusCode(),
                    responseToLog,
                    timeTaken, 
                    true);
            }
            
        } catch (Exception ex) {
            endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
            String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
            logMessage = LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        developerName,
                                        'SSP_FraudSubmission_IntegrationService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        responseToLog,
                                        timeTaken, 
                                        true
                                    );
            responseWrapper = new SSP_FraudSubmission_ResponseWrapper();
            responseWrapper.logName = logMessage.Name;
            response.add(responseWrapper);
        }
		
        return response;
    }
}