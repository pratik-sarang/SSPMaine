/*
* Classname 	:  SSP_KIHIPPPaymentIntegrationService
* @description 	:  This class is to make callout to push KIHIPP Preferred Payment method
* @author 		:  Rijia Khatun
* @date 		:  08/16/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
                about the Change
**/
public class SSP_KIHIPPPaymentIntegrationService  extends SOAPIntegrationService {
    /**
     * method 		: invokeCallout
     * @description 	: This method is to call the callout method of KIHIPP stub class 
     * @author 		: Rijia Khatun
     * @param developerName : MetaData record name
     * @param mapInputParams : Request body in a map format
     * @return: List<Object>
     * */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        LOG_LogMessage__c logMessage;
        DateTime startTime = Datetime.now();
        Long timeTaken;
        DateTime endTime;
        List<Object> response = new List<Object>();
        SSP_DataContractOrg.PreferredPaymentIssuanceRequest objRequest = new SSP_DataContractOrg.PreferredPaymentIssuanceRequest();
        SSP_DataContractOrg.AdhocSFServiceResponse objResponse = new SSP_DataContractOrg.AdhocSFServiceResponse();
       try{
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(developerName);
            String strData = (String)mapInputParams.get(SSP_InterfaceConstants.JSON_BODY);
            objRequest = (SSP_DataContractOrg.PreferredPaymentIssuanceRequest)System.JSON.deserialize(strData, SSP_DataContractOrg.PreferredPaymentIssuanceRequest.class);
            SSP_TempuriOrg.BasicHttpsBinding_IAdhocDCRequestService objCallout = new SSP_TempuriOrg.BasicHttpsBinding_IAdhocDCRequestService();
            objCallout.endpoint_x = 'callout:'+objInterfaceDetail.SSP_NamedCredential__c; 
            if (objInterfaceDetail.Timeout_Miliseconds__c !=  null) {
                objCallout.timeout_x = (Integer)objInterfaceDetail.Timeout_Miliseconds__c;
            }
            objResponse = objCallout.SavePreferredPaymentDetails(objRequest);
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+null+'\n'+
                    SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
                logMessage = LOG_LogMessageUtility.logMessage (
                                LOG_LogMessageUtility.LOG_LogLevel.Info,
                                null, 
                                'SSP_KIHIPPPaymentIntegrationService',
                                developerName,
                                'invokeCallout',
                                stErrorMessage,
                                null,
                                JSON.serialize(objRequest),
                                'Status Code: '+null,
                                JSON.serialize(objResponse),
                                timeTaken, 
                                true);
            }
         }catch(Exception e){
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
             String stErrorMessage =  'Status : '+null+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
            logMessage = LOG_LogMessageUtility.logMessage (
                                        e,
                                        null,
                                        developerName,
                                        'SSP_KIHIPPPaymentIntegrationService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        null,
                                        JSON.serialize(objRequest),
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