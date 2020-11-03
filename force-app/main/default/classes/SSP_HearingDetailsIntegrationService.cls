/**
 * Class Name    : SSP_HearingDetailsIntegrationService
 * Owner         : DELOITTE
 * Created Date  : 05/20/2020
 * Description   : Integration service class for Hearing Service Details
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  07/16/2020  Rajeev Kumar    Initial Version
 */
public with sharing class SSP_HearingDetailsIntegrationService extends SOAPIntegrationService { 
    
    // private variables
    public static final String INTERFACE_NAME ='HearingDetails';
    public static final String SOURCE = 'SSP_HearingDetailsIntegrationService';
    public static final String SOURCE_FUNCTION = 'invokeCallout';
    
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
        SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse objResponse = new SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse();
        String objRequestBody;
        SSP_Hearing_TempPuri.BasicHttpsBinding_IAdhocDCRequestService objRequest = new SSP_Hearing_TempPuri.BasicHttpsBinding_IAdhocDCRequestService();            
        try {
            // Set Certificate
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(sInterfaceName);
            // Set End Point
            objRequest.endpoint_x = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            // Set Timeout
            if(objInterfaceDetail.Timeout_Miliseconds__c != null) {
                objRequest.timeout_x = Integer.valueOf(objInterfaceDetail.Timeout_Miliseconds__c);
            }
            // Prepare Request Parameters
            objRequestBody = (String) mapParams.get(SSP_InterfaceConstants.JSON_BODY);
            objLog.payload = JSON.serialize(objRequestBody);
            objLog.endpoint = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            objLog.startTime = SSP_IntegrationUtility.getTimeInMilliseconds();
            // Calling the service
            objResponse = objRequest.CitizenHearingViewDetails(objRequestBody);
            objLog.timeTaken = SSP_IntegrationUtility.getTimeInMilliseconds() - objLog.startTime;
            objLog.responseData = JSON.serialize(objResponse);
            // validate if debug is on to create log record
            if(mapParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                log = (new SSP_IntegrationUtility()).createLogMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, objLog, true);
            }
        } catch(Exception e) {
            // validate if its callout excepiton
            if(objLog.timeTaken == null && objLog.startTime != null) {
                objLog.timeTaken = SSP_IntegrationUtility.getTimeInMilliseconds() - objLog.startTime;
            }
            // create log for the exception
            log = (new SSP_IntegrationUtility()).handleException(e, objLog, true);
        }
        System.debug('ResponseData'+objResponse);
        return new List<Object>{ objResponse };

    }
}