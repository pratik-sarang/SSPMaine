/*
* Classname         :  SSP_UpdateAgentAssisterService
* @description  :  This class is to make callout for Update Agent and Assister
* @author       :  Rijia Khatun
* @date         :  03/07/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
  Rijia Khatun        03/07/2020          Initial Version
**/
public with sharing class SSP_UpdateAgentAssisterService extends RestIntegrationService  {
    /**
    * method        : processResponse
    * @description  : This method is to process the response
    * @author       : Rijia Khatun
    * @param lstResponseObject : 
    * @param request : Instance of HttpRequest
    * @param response : Response of the callout that needs to be parsed
    * @return: List<Object>
    * */
    public static List<Object> processResponse(HttpResponse response) {
        SSP_UpdateAgentAssisterResWrapper objRes = new SSP_UpdateAgentAssisterResWrapper();
        if(response.getStatusCode() != 500 && !String.isBlank(response.getBody()) ) {
            objRes = SSP_UpdateAgentAssisterResWrapper.parse(response.getBody());
        }   
        objRes.sStatusCode = response.getStatusCode();
        return new List<Object>{objRes};
    }
    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for overlap interface
    * @author       : Rijia Khatun
    * @param developerName : MetaData record name
    * @param mapInputParams : Request body in a map format
    * @return: List<Object>
    * */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        HttpResponse objRes = new HttpResponse();
        HttpRequest objReq = new HttpRequest();
        List<Object> response = new List<Object>();
        DateTime startTime = Datetime.now();
        Long timeTaken;
        DateTime endTime;
        LOG_LogMessage__c logMessage;
        try {
            objReq = generateRequest(developerName,mapInputParams);   
            objRes = sendRequest(objReq);
            response.addAll(processResponse(objRes));
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)){
                String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
                logMessage = LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    'SSP_UpdateAgentAssisterService',
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    objReq.getMethod(),
                    objReq.getBody(),
                    'Status Code: '+objRes.getStatusCode(),
                    objRes.getBody(),
                    timeTaken, 
                    false);
            }
        } catch (Exception ex) {
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
            logMessage = LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        developerName,
                                        'SSP_UpdateAgentAssisterService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        objRes.getBody(),
                                        timeTaken, 
                                        false
                                    );
        }
        if(response.isEmpty()) {
            SSP_UpdateAgentAssisterResWrapper objResFailuer = new SSP_UpdateAgentAssisterResWrapper();
            objResFailuer.isSFFailure = true;
            response.add(objResFailuer);
        }
        response.add(logMessage);
        return response;
    }
}