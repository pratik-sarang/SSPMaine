/*
* Classname     :  SSP_PreferredMCOSelectionIntegService
* @description  :  This class is to make callout for Preferred MCO Selection
* @author       :  Ragunathan
* @date         :  08/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  08/05/2020			Initial creation
**/

public with sharing class SSP_PreferredMCOSelectionIntegService extends SOAPIntegrationService {

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
        objLog.interfaceName = SSP_InterfaceConstants.SSP_PREFERRED_MCO_SELECTION;
        objLog.source = SSP_InterfaceConstants.SSP_PREFERRED_MCO_SERVICE;
        objLog.sourceFunction = SSP_InterfaceConstants.SOURCE_FUNCTION;
        DateTime startTime;
        DateTime endTime;
        SSP_DataContractOrg.PreferredMcoResponse objResponse = new SSP_DataContractOrg.PreferredMcoResponse();
        SSP_DataContractOrg.PreferredMcoRequest objRequestBody = new SSP_DataContractOrg.PreferredMcoRequest();
        SSP_tempuriOrg.BasicHttpsBinding_IAdhocDCRequestService objRequest = new SSP_tempuriOrg.BasicHttpsBinding_IAdhocDCRequestService();
        try {
            // Set Certificate
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(sInterfaceName);
            // Set End Point
            objRequest.endpoint_x = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            if(objInterfaceDetail.Timeout_Miliseconds__c != null) {
                objRequest.timeout_x  = Integer.valueof(objInterfaceDetail.Timeout_Miliseconds__c);
            }
            objRequestBody = (SSP_DataContractOrg.PreferredMcoRequest)mapParams.get(SSP_InterfaceConstants.JSON_BODY);
            objLog.payload = JSON.serialize(objRequestBody);
            objLog.endpoint = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            startTime = Datetime.now();
            // Calling the service
            objResponse = objRequest.GetPreferredMCOPlanList(objRequestBody);
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
            SSP_DataContractOrg.SspdcsfCommonError commonError = new SSP_DataContractOrg.SspdcsfCommonError();
            commonError.CHFSExceptionId = log.Name;
            objResponse.Status = false;
        }
        return new List<Object>{ objResponse };

    }
}