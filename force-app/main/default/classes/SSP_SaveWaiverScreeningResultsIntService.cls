/**
 * Class Name    : SSP_SaveWaiverScreeningResultsIntService
 * Owner         : DELOITTE
 * Created Date  : 05/20/2020
 * Description   : Integration service class to get results for save waiver screening
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  05/20/2020  Ragunathan		   Initial Version
 */
public with sharing class SSP_SaveWaiverScreeningResultsIntService extends SOAPIntegrationService {
    
    /**
    * method                : invokeCallout
    * @description          : Method to handle invoke callout
    * @author               : Ragunathan
    * @param sInterfaceName : Unique Interface Name
    * @param mapParams      : Parameters to build request
    * @return               : List<Object>
    * */
    public List<Object> invokeCallout(String sInterfaceName, Map<String, Object> mapParams) {
        logMessageWrapper objLog = new logMessageWrapper();
        Log_LogMessage__c log;
        objLog.interfaceName = SSP_InterfaceConstants.SSP_SAVE_WAIVER_SCREENING_RESULTS;
        objLog.source = SSP_InterfaceConstants.SOURCE_SAVE_SCR;
        objLog.sourceFunction = SSP_InterfaceConstants.SOURCE_FUNCTION;
        DateTime startTime = Datetime.now();
        DateTime endTime;
        SSP_DatacontractOrg.WaiverResponse objResponse = new SSP_DatacontractOrg.WaiverResponse();
        SSP_DatacontractOrg.ArrayOfWaiverScreeningRequestModel objRequestBody = new SSP_DatacontractOrg.ArrayOfWaiverScreeningRequestModel();
        SSP_tempuriOrg.BasicHttpsBinding_IAdhocDCRequestService objRequest = new SSP_tempuriOrg.BasicHttpsBinding_IAdhocDCRequestService();            
        try {
            // Set Certificate
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(sInterfaceName);
            // Set End Point
            objRequest.endpoint_x = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            if(objInterfaceDetail.Timeout_Miliseconds__c != null) {
                objRequest.timeout_x  = Integer.valueof(objInterfaceDetail.Timeout_Miliseconds__c);
            }
            objRequestBody = (SSP_DatacontractOrg.ArrayOfWaiverScreeningRequestModel)mapParams.get(SSP_InterfaceConstants.JSON_BODY);
            objLog.payload = JSON.serialize(objRequestBody);
            objLog.endpoint = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            objLog.startTime = SSP_IntegrationUtility.getTimeInMilliseconds();
            
            // Calling the service
            objResponse = objRequest.InsertWaiverScreening(objRequestBody);
            endTime = Datetime.now();
            objLog.timeTaken = endTime.getTime() - startTime.getTime();
            objLog.responseData = JSON.serialize(objResponse);
            // validate if debug is on to create log record
            if(mapParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                log = (new SSP_IntegrationUtility()).createLogMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, objLog, true);
            }
        } catch(Exception e) {
            endTime = Datetime.now();
            objLog.timeTaken = endTime.getTime() - startTime.getTime();
            // create log for the exception
            log = (new SSP_IntegrationUtility()).handleException(e, objLog, true);
        }
        return new List<Object>{ objResponse };

    }
}