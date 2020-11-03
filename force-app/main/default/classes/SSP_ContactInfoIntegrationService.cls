/*
* Classname         :  SSP_ContactInfoIntegrationService
* @description      :  This class is to make callout for My Contact Information
* @author           :  Rajeev Kumar
* @date             :  03/06/2020
* MODIFICATION LOG  :
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
**/
public with sharing class SSP_ContactInfoIntegrationService extends RestIntegrationService  {

    // private variables
    private static final String INTERFACE_NAME ='UpdateMyInformation';
    private static final String SOURCE = 'SSP_ContactInfoIntegrationService';
    private static final String SOURCE_FUNCTION = 'invokeCallout';

    /**
    * method                                        : invokeCallout
    * @description                                  : This method is to make callout for Update Contact Info Interface
    * @author                                       : Rajeev Kumar
    * @param sInterfaceName                         : MetaData record name
    * @param mapInputParams                         : Request body in a map format
    * @return: List<Object>                         : List of object Records
    * */
    public static List<Object> invokeCallout(String sInterfaceName, Map<String, object> mapInputParams) {
        List<Object> lstResponse = new List<Object>();
        Log_LogMessage__c log;
        logMessageWrapper objLog = new logMessageWrapper();
        objLog.interfaceName = INTERFACE_NAME;
        objLog.source = SOURCE;
        objLog.sourceFunction = SOURCE_FUNCTION;
        try {
            String sIndividualId = (String) mapInputParams.get(SSP_InterfaceConstants.IndividualId);
            SSP_ContactInfoUpdateRequestWrapper requestWrapper = new SSP_ContactInfoUpdateRequestWrapper(sIndividualId);
            mapInputParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(requestWrapper));
            Http objHttp = new Http();
            // Create Request parameters
            HttpRequest objRequest = generateRequest(sInterfaceName,mapInputParams);
            objLog.payload = JSON.serializePretty(JSON.deserializeUntyped(objRequest.getBody()));
            objLog.endpoint = objRequest.getEndPoint();
            objLog.startTime = SSP_IntegrationUtility.getTimeInMilliseconds();
            // Make Callout
            HttpResponse objResponse = objHttp.send(objRequest);
            objLog.timeTaken = SSP_IntegrationUtility.getTimeInMilliseconds() - objLog.startTime;
            objLog.responseData = objResponse.getBody();
            objLog.responseCode = String.valueOf(objResponse.getStatusCode());
            // Verify if Debug is on to create log
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                log = (new SSP_IntegrationUtility()).createLogMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, objLog, true);
            }
            lstResponse =  processResponse(objResponse);
        } catch(Exception e) {
            // validate if its callout exception
            if(objLog != null && objLog.timeTaken == null && objLog.startTime != null) {
                objLog.timeTaken = SSP_IntegrationUtility.getTimeInMilliseconds() - objLog.startTime;
            }
            // Create log Message
            log = (new SSP_IntegrationUtility()).handleException(e, objLog, true);
        }
        return lstResponse;
    }

    /**
    * method                                          : processResponse
    * @description                                    : This method is to process the response
    * @author                                         : Rajeev Kumar
    * @param response                                 : Response of the callout that needs to be parsed
    * @return List<Object>                            : List of Objects
    * */
    public static List<Object> processResponse(HttpResponse objResponse) {
        SSP_ContactInfoUpdateResponseWrapper objContactUpdateRes;
        // throw exception when status is not 200
        if(objResponse.getStatusCode() != 200) {
            throw new CustomException(SSP_InterfaceConstants.UNEXPECTED_RESPONSE_ERROR);
        }
        objContactUpdateRes = SSP_ContactInfoUpdateResponseWrapper.parseContactUpdateResponse(objResponse.getBody());
        return new List<Object>{ objContactUpdateRes };
    }
}