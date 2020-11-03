/*
* Classname 		:  SSP_VLPIntegrationService
* @description 	:  This class is to make callout for VLP
* @author 		:  Rijia Khatun
* @date 		:  11/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/

public with sharing class SSP_VLPIntegrationService extends RestIntegrationService  {
   	 @TestVisible private static Boolean boolNegative = false;
     /**
    * method 		: processResponse
    * @description 	: This method is to process the response
    * @author 		: Rijia Khatun
    * @param lstResponseObject : 
    * @param request : Instance of HttpRequest
    * @param response : Response of the callout that needs to be parsed
    * @return: List<Object>
    * */
    public static List<Object> processResponse(HttpResponse response) {
        SSP_VLPResponseWrapper objVLPRes = new SSP_VLPResponseWrapper();
        if(response.getStatusCode() != 500 && !String.isBlank(response.getBody())) {
            objVLPRes = SSP_VLPResponseWrapper.parseVLPResponse(response.getBody());
        }
        objVLPRes.sStatusCode = response.getStatusCode();
        return new List<Object>{objVLPRes};
    } 
    /**
    * method 		: invokeCallout
    * @description 	: This method is to make callout for VCI interface
    * @author 		: Rijia Khatun
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
        try {
            objReq = generateRequest(developerName,mapInputParams);
            objRes = sendRequest(objReq);
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            if(boolNegative) {
                objRes.setStatusCode(500);
                throw new SSP_VLPIntegrationServiceException();
            }
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
                LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    'SSP_VLPIntegrationService',
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    objReq.getMethod(),
                    objReq.getBody(),
                    'Status Code: '+objRes.getStatusCode(),
                    objRes.getBody(),
                    timeTaken, 
                    true);
            }
        } catch (Exception ex) {
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
            LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        developerName,
                                        'SSP_VLPIntegrationService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        objRes.getBody(),
                                        timeTaken, 
                                        true
                                    );
        }
        response.addAll(processResponse(objRes));
        
        return response;
    }
    public class SSP_VLPIntegrationServiceException extends Exception {
    }
}