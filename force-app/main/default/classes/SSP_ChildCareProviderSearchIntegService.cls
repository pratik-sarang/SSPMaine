/*
* Classname     :  SSP_ChildCareProviderSearchIntegService
* @description  :  This class is to make callout for VCI
* @author       :  Ragunathan
* @date         :  05/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  05/14/2020			Initial creation
**/

public with sharing class SSP_ChildCareProviderSearchIntegService extends RestIntegrationService  {

    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for VCI interface
    * @author       : Ragunathan
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
        String responseToLog;
        try {
            objReq = generateRequest(developerName,mapInputParams);
            objRes = sendRequest(objReq);
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
			responseToLog = (string.isNotBlank(objRes.getBody()) && objRes.getBody().length() > 32000) ? objRes.getBody().substring(0,32000) :objRes.getBody();
            SSP_ChildCareProviderSearchResponse responseWrapper = (SSP_ChildCareProviderSearchResponse) JSON.deserialize(
                                                                    objRes.getBody(), 
                                                                    SSP_ChildCareProviderSearchResponse.class);
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
                    'SSP_ChildCareProviderSearchIntegService',
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
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
            logMessage = LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        developerName,
                                        'SSP_ChildCareProviderSearchIntegService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        responseToLog,
                                        timeTaken, 
                                        true
                                    );
        }
		
        return response;
    }
}
