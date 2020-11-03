/**
 * Class Name    : SSP_RIDP_CheckResumeIntegrationService
 * Owner         : DELOITTE
 * Created Date  : 05/26/2020
 * Description   : Integration service class to get results for Check Resume under RIDP Integration.
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  05/26/2020  Ragunathan		   Initial Version
 */
public with sharing class SSP_RIDP_CheckResumeIntegrationService extends SOAPIntegrationService { 
    
    // private variables
    public static final String INTERFACE_NAME ='SSP_RIDP';
    public static final String SOURCE = 'SSP_RIDP_CheckResumeIntegrationService';
    public static final String SOURCE_FUNCTION = 'invokeCallout';
    
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
        objLog.interfaceName = INTERFACE_NAME;
        objLog.source = SOURCE;
        objLog.sourceFunction = SOURCE_FUNCTION;
        DateTime startTime = Datetime.now();
        DateTime endTime;
        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse objResponse = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse();
        SSP_RIDP_RequestWrapper objRequestBody = new SSP_RIDP_RequestWrapper();
        SSP_RIDP_tempuriOrg.WSHttpBinding_IRIDPStandAlone objRequest = new SSP_RIDP_tempuriOrg.WSHttpBinding_IRIDPStandAlone();            
        try {
            // Set Certificate
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(sInterfaceName);
            // Set End Point
            objRequest.endpoint_x = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            if(objInterfaceDetail.Timeout_Miliseconds__c != null ){
                objRequest.timeout_x = (Integer) objInterfaceDetail.Timeout_Miliseconds__c;
            }
            objRequestBody = (SSP_RIDP_RequestWrapper) JSON.deserialize((String)mapParams.get(SSP_InterfaceConstants.JSON_BODY), SSP_RIDP_RequestWrapper.class);
            objLog.payload = JSON.serialize(objRequestBody);
            objLog.endpoint = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            objLog.startTime = SSP_IntegrationUtility.getTimeInMilliseconds();
            // Calling the service
            objResponse = objRequest.CheckResume(objRequestBody.RIDPUserResume, objRequestBody.userKOGID);
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