/**
* This Class used for make callout for Address Verification Service
* Date : 2nd Dec 2019
* @author: Kommana Lova Durga Prasad
* @TestClass: 
*/

public class SSP_AddressVerification_IntUtility extends SOAPIntegrationService {
    
    /**
* method        : invokeCallout
* @description  : This method is to make callout for Address Verification
* @author       : Kommana Lova Durga Prasad
* @param developerName : It is a metadata record Name. Here we can store the endpoint details.
* @param mapInputParams : Request body in a map format
* @return: List<Object>
* */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        SSP_AddressResponseWrapper respWrapper = new SSP_AddressResponseWrapper();
        SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1 response = null;
        respWrapper.Issucess = true;
        List<LOG_LogMessage__c> lstofLogs = new List<LOG_LogMessage__c>();
        DateTime startTime = Datetime.now();
        Long timeTaken;
        try{
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(developerName);
            SSP_AddressVerificationWSDLService.COT_USAC_County_svcPort objRequest = new SSP_AddressVerificationWSDLService.COT_USAC_County_svcPort();
            objRequest.endpoint_x = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            if(objInterfaceDetail.Timeout_Miliseconds__c != null) {
                objRequest.timeout_x = Integer.valueOf(objInterfaceDetail.Timeout_Miliseconds__c);
            }
            String strData = (String)mapInputParams.get(SSP_InterfaceConstants.SSPINT_BODY);
            SSP_AddressVerificationWSDLService.COT_USAC_County_op1 objRequestBody = 
                (SSP_AddressVerificationWSDLService.COT_USAC_County_op1)System.JSON.deserialize(strData, SSP_AddressVerificationWSDLService.COT_USAC_County_op1.class);
            /* Here we are making callout*/
            response = objRequest.COT_USAC_County_op1('',
                                                      String.isNotBlank(objRequestBody.line1) ? objRequestBody.line1 : '',
                                                      String.isNotBlank(objRequestBody.line2) ? objRequestBody.line2 : '',
                                                      String.isNotBlank(objRequestBody.city) ? objRequestBody.city : '',
                                                      String.isNotBlank(objRequestBody.state) ? objRequestBody.state : '',
                                                      String.isNotBlank(objRequestBody.zip) ? objRequestBody.zip : '');
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
        }
        catch(Exception e){
            respWrapper.Issucess = false;
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_AddressVerification_IntUtility','SSP_AddressVerification_IntUtility','invokeCallout',
                                                                              SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() +SSP_InterfaceConstants.SSPINT_ERRORMSG+e.getMessage()+SSP_InterfaceConstants.SSPINT_ERRORTRACE+e.getStackTraceString()+SSP_InterfaceConstants.SSPINT_ERRORLINENO+e.getLineNumber(),
                                                                              null,(String)mapInputParams.get(SSP_InterfaceConstants.SSPINT_BODY),'Status Code:-ERROR -'+ Limits.getDMLStatements(),JSON.serialize(response),timeTaken, false);
            lstofLogs.add(lstLogMessag);
        }
        if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
            LOG_LogMessage__c lstLogMessageDebug = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,null,'SSP_AddressVerification_IntUtility','SSP_AddressVerification_IntUtility','invokeCallout',
                                                                                    JSON.serialize(response),null,(String)mapInputParams.get(SSP_InterfaceConstants.SSPINT_BODY),'Status Code:-Info',JSON.serialize(response),timeTaken, false);
            lstofLogs.add(lstLogMessageDebug);
        }
        respWrapper.lstofLogMessages = lstofLogs;
        respWrapper.ResponseDetail = response;
        return new List<Object>{respWrapper};
    }
    
}