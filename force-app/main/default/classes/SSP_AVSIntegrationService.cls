/*
* Classname 	:  SSP_AVSIntegrationService
* @description 	:  This class is to make callout for AVS
* @author 		:  Rijia Khatun
* @date 		:  11/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
                about the Change
**/
public class SSP_AVSIntegrationService extends SOAPIntegrationService {
    public static final String ORGANIZATIONID = 'DCBSFamilySupport';
    /**
     * method 		: invokeCallout
     * @description 	: This method is to call the callout method of AVS stub class 
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
        SSP_AVSSchemasPostAvstr.identity_element objRequest = new SSP_AVSSchemasPostAvstr.identity_element();
        SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element objResponse = new SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element();
       try{
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(developerName);
            String strData = (String)mapInputParams.get(SSP_InterfaceConstants.JSON_BODY);
            objRequest = (SSP_AVSSchemasPostAvstr.identity_element)System.JSON.deserialize(strData, SSP_AVSSchemasPostAvstr.identity_element.class);
            SSP_AVSTempuriOrg.BasicHttpBinding_ITwoWayAsync objCallout = new SSP_AVSTempuriOrg.BasicHttpBinding_ITwoWayAsync();
            objCallout.endpoint_x = 'callout:'+objInterfaceDetail.SSP_NamedCredential__c; 
             if (objInterfaceDetail.Timeout_Miliseconds__c !=  null) {
                objCallout.timeout_x = (Integer)objInterfaceDetail.Timeout_Miliseconds__c;
            }
            objResponse = objCallout.PostTransaction(new List<String>{'MEDICAID'},objRequest,ORGANIZATIONID,'SSP','SSP','0',null,null);
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
                                'SSP_AVSIntegrationService',
                                developerName,
                                'invokeCallout',
                                stErrorMessage,
                                null,
                                JSON.serialize(objRequest),
                                'Status Code: '+null,
                                JSON.serialize(objResponse),
                                timeTaken, 
                                false);
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
                                        'SSP_AVSIntegrationService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        null,
                                        JSON.serialize(objRequest),
                                        'Status Code: '+null,
                                        JSON.serialize(objResponse),
                                        timeTaken, 
                                        false
                                    );
        }
        response.add(objResponse);
        if(logMessage != null) {
            response.add(logMessage);
        }
        return response;
    }    

    public class SSP_AVSIntegrationServiceException extends Exception {
        
    }
}