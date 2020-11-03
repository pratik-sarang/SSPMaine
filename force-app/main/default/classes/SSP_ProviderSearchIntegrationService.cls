/**
 * Class Name    : SSP_ProviderSearchIntegrationService
 * Owner         : DELOITTE
 * Created Date  : 02/07/2020
 * Description   : To provide service for provider search Interface
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  02/07/2020  Rajeev Kumar    Initial Version
 */
public with sharing class SSP_ProviderSearchIntegrationService extends RestIntegrationService { 
    
    // private variables
    private static final String INTERFACE_NAME ='ProviderSearch';
    private static final String SOURCE = 'SSP_ProviderSearchIntegrationService';
    private static final String SOURCE_FUNCTION = 'invokeCallout';
    
    /**
    * method                : invokeCallout
    * @description          : Method to handle invoke callout
    * @author               : Rajeev Kumar
    * @param sInterfaceName : Unique Interface Name
    * @param mapParams      : Parameters to build request
    * @return               : List<Object>
    * */
    public List<Object> invokeCallout(String sInterfaceName, Map<String, Object> mapParams) {
        logMessageWrapper objLog = new logMessageWrapper();
        Log_LogMessage__c log;
        objLog.interfaceName = INTERFACE_NAME;
        objLog.source = SOURCE;
        objLog.sourceFunction = SOURCE_FUNCTION;
        Long startTime = DateTime.now().getTime();
        Long endTime;
        try {
            Map<String, String> mapInputParams = new Map<String, String>();
            Http objHttp = new Http();
            mapInputParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(mapParams));
            // Prepare Request parameters
            HttpRequest objRequest = generateRequest(sInterfaceName,mapInputParams);
            objLog.payload = objRequest.getBody();
            objLog.endpoint = objRequest.getEndPoint();
            objLog.startTime = SSP_IntegrationUtility.getTimeInMilliseconds();
            // make callout
            HttpResponse objResponse = objHttp.send(objRequest);
            endTime = DateTime.now().getTime();            
            objLog.timeTaken = endTime - startTime;
            objLog.responseData = objResponse.getBody();
            objLog.responseCode = String.valueOf(objResponse.getStatusCode());
            // validate if debug is on to create log record
            if(mapParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                log = (new SSP_IntegrationUtility()).createLogMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, objLog, true);
            }
            return processResponse(objResponse);
        } catch(Exception e) {
            endTime = DateTime.now().getTime();            
            objLog.timeTaken = endTime - startTime;
            // create log for the exception
            log = (new SSP_IntegrationUtility()).handleException(e, objLog, true);
        }
        return new List<Object>();
    }
    
    /**
    * method             : processResponse
    * @description       : This method is to process the response
    * @author            : Rajeev Kumar
    * @param response    : Response of the callout that needs to be parsed
    * @return            : List<Object>
    * */
    public List<Object> processResponse(HttpResponse objResponse) {
        SSP_ProviderSearchResponseWrapper objProviderSearch = new SSP_ProviderSearchResponseWrapper();
        // verify if status in not 200
        if(objResponse.getStatusCode() != 200) {
            throw new CustomException(SSP_InterfaceConstants.UNEXPECTED_RESPONSE_ERROR);
        }
        objProviderSearch = SSP_ProviderSearchResponseWrapper.parseProviderSearch(objResponse.getBody());
        return new List<Object>{ objProviderSearch };
    }
}