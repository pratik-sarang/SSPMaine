/*
* Classname 	:  SSP_WithdrawHearingIntegrationSevice
* @description 	:  This class is to make callout to withdraw Hearing
* @author 		:  Rijia Khatun
* @date 		:  08/16/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
                about the Change
**/
public class SSP_WithdrawHearingIntegrationSevice  extends SOAPIntegrationService {
    /**
     * method 		: invokeCallout 
     * @description 	: This method is to call the callout method of withdraw Hearing stub class 
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
        SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest objRequest = new SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest();
        SSP_HearingDataContractOrg.CitizenHearingResponse objResponse = new SSP_HearingDataContractOrg.CitizenHearingResponse();
       try{
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(developerName);
            String strData = (String)mapInputParams.get(SSP_InterfaceConstants.JSON_BODY);
            objRequest = (SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest )System.JSON.deserialize(strData, SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest .class);
            SSP_Hearing_TempPuri.BasicHttpsBinding_IAdhocDCRequestService objCallout = new SSP_Hearing_TempPuri.BasicHttpsBinding_IAdhocDCRequestService();
            objCallout.endpoint_x = 'callout:'+objInterfaceDetail.SSP_NamedCredential__c; 
            if (objInterfaceDetail.Timeout_Miliseconds__c !=  null) {
                objCallout.timeout_x = (Integer)objInterfaceDetail.Timeout_Miliseconds__c;
            }
            objResponse = objCallout.CitizenWithdrawHearingRequest(objRequest);
            endTime = Datetime.now();
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
                                'SSP_WithdrawHearingIntegrationSevice',
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
                                        'SSP_WithdrawHearingIntegrationSevice',
                                        'invokeCallout',
                                        stErrorMessage,
                                        null,
                                        JSON.serialize(objRequest),
                                        'Status Code: '+null,
                                        JSON.serialize(objResponse),
                                        timeTaken, 
                                        true
                                    );
            objResponse.Status = false;
            objResponse.Error = new SSP_HearingDataContractOrg.SFHearingCommonError();
            objResponse.Error.CHFSExceptionId = [Select Name from LOG_LogMessage__c where id =: logMessage.Id].Name;
        }
        response.add(objResponse);
        return response;
    }    
}