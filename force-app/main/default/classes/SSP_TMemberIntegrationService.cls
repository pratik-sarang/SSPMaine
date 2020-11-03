/*
* Classname 	:  SSP_TMemberIntegrationService
* @description 	:  This class is to make callout for T-Member
* @author 		:  Rijia Khatun
* @date 		:  11/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
about the Change.
**/
public class SSP_TMemberIntegrationService extends SOAPIntegrationService {
    
    /**
* method 		: invokeCallout
* @description 	: This method is to call the callout method of TMember stub class 
* @author 		: Rijia Khatun
* @param developerName : MetaData record name
* @param mapInputParams : Request body in a map format
* @return: List<Object>
* */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        List<Object> response = new List<Object>();
        DateTime startTime = Datetime.now();
        Long timeTaken;
        SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(developerName);
        SSP_TMemberCalloutClass.BasicHttpsBinding_IKyHbeEdbcHHMBRService objRequest = new SSP_TMemberCalloutClass.BasicHttpsBinding_IKyHbeEdbcHHMBRService();
        objRequest.endpoint_x = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c; 
        if (objInterfaceDetail.Timeout_Miliseconds__c !=  null) {
            objRequest.timeout_x = (Integer)objInterfaceDetail.Timeout_Miliseconds__c;
        }
        String strData = (String)mapInputParams.get(SSP_InterfaceConstants.JSON_BODY);
        SSP_TMemberDataContract.SSPCaseResponse objResponse = new SSP_TMemberDataContract.SSPCaseResponse();
        SSP_TMemberDataContract.SSPCaseRequest objRequestBody = new SSP_TMemberDataContract.SSPCaseRequest();
        try{
            objRequestBody = (SSP_TMemberDataContract.SSPCaseRequest)System.JSON.deserialize(strData, SSP_TMemberDataContract.SSPCaseRequest.class);
            objResponse = objRequest.SSPDetermineMember(objRequestBody);
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+null+'\n'+
                    SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
                LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    null, 
                    'SSP_TMemberIntegrationService',
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    null,
                    JSON.serialize(objRequestBody),
                    'Status Code: '+null,
                    JSON.serialize(objResponse),
                    timeTaken, 
                    true);
            }
        } catch(Exception e){
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+null+'\n'+
                SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
            LOG_LogMessageUtility.logMessage (
                e,
                null,
                developerName,
                'SSP_TMemberIntegrationService',
                'invokeCallout',
                stErrorMessage,
                null,
                JSON.serialize(objRequestBody),
                'Status Code: '+null,
                JSON.serialize(objResponse),
                timeTaken, 
                true
            );
        }
        response.add(objResponse);
        return response;
    } 
}