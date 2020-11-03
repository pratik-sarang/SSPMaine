/**
* Class Name    : SSP_CorrespondenceUtilityService
* Owner         : DELOITTE
* Created Date  : 01/06/2020
* Description   : Class that holds utility methods for SSP Correspondence Service
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
* 01/06/2020  Kommana Lova Durga Prasad   Initial Version
*/

public class SSP_CorrespondenceUtilityService extends RestIntegrationService {
    
    public static SSP_CorrespondenceResponseWrapper objCorrespondceResp;
    public static Long timeTaken;
    
    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for Correspondence service
    * @author       : Kommana Lova Durga Prasad
    * @param developerName : It is a metadata record Name. Here we can store the endpoint details.
    * @param mapInputParams : Request body in a map format
    * @return: List<Object>
    * */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        //Query the endpoint based on developerName set the endpoint of HpptRequest  
        objCorrespondceResp = new SSP_CorrespondenceResponseWrapper();
        HttpRequest objReq = generateRequest(developerName,mapInputParams);
        http h = new http();
        HttpResponse objRes;
        Long startTime;
        LOG_LogMessage__c lstLogMessag;
        List<Object> lstResponse = new List<Object>();
        try{
            startTime = Datetime.now().getTime();
            objRes = h.send(objReq);
            Long endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
        }
        catch(Exception e) {
            Long endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
            lstLogMessag = 
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,
                                                 null,
                                                 'CorrespondenceUtilityService',
                                                 'CorrespondenceUtilityService',
                                                 'invokeCallout',
                                                 SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() + 
                                                 SSP_InterfaceConstants.SSPINT_ERRORMSG + e.getMessage() + 
                                                 SSP_InterfaceConstants.SSPINT_ERRORTRACE + 
                                                 e.getStackTraceString() + 
                                                 SSP_InterfaceConstants.SSPINT_ERRORLINENO + 
                                                 e.getLineNumber()
                                                 ,null,
                                                 objReq.getBody(),
                                                 'Status Code:-'+objRes.getStatusCode(),
                                                 objRes.getBody(),
                                                 timeTaken, true);
            objCorrespondceResp.LogId = lstLogMessag.id; objCorrespondceResp.isSuccess = false;
            return new List<object>{objCorrespondceResp};   
        }
        if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
            string MessageDebug = SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE + objRes.getStatusCode() + 
                                    SSP_InterfaceConstants.SSPINT_ERRORRESPBODY + objRes.getBody() + 
                                    SSP_InterfaceConstants.SSPINT_ERRORRESPCODE +objRes.getStatus();

            if(!mapInputParams.containsKey(SSP_InterfaceConstants.IS_LOG_INSERTED) || 
               (mapInputParams.containsKey(SSP_InterfaceConstants.IS_LOG_INSERTED) && 
                (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_LOG_INSERTED))) {
                    lstLogMessag = 
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,
                                                         null,
                                                         'CorrespondenceUtilityService',
                                                         'CorrespondenceUtilityService',
                                                         'invokeCallout',
                                                         MessageDebug,
                                                         null,
                                                         objReq.getBody(),
                                                         'Status Code:-'+objRes.getStatusCode(),
                                                         objRes.getBody(),
                                                         timeTaken,
                                                         true);
                } else {
                    lstLogMessag = 
                    LOG_LogMessageUtility.logMessage (
                        LOG_LogMessageUtility.LOG_LogLevel.Info,
                        objReq.getEndpoint(), 
                        'CorrespondenceUtilityService',
                        'CorrespondenceUtilityService',
                        'invokeCallout',
                        MessageDebug,
                        objReq.getMethod(),
                        objReq.getBody(),
                        'Status Code: '+objRes.getStatusCode(),
                        objRes.getBody(),
                        timeTaken, 
                        false);
                        lstResponse.add(lstLogMessag);
                }
        }
        if(objRes.getStatusCode() == 200) {
            lstResponse =  processResponse(objRes,false,objReq);
        }
        else {
            lstResponse =  processResponse(objRes,true,objReq);
        }
        if(lstLogMessag != null) {
            lstResponse.add(lstLogMessag);
        }
        return lstResponse;
    }
    
    /**
    * method        : processResponse
    * @description  : This method is to process the response for Correspondence 
    * @author       :  Kommana Lova Durga Prasad
    * @param lstResponseObject : 
    * @param request : Instance of HttpRequest
    * @param response : Response of the callout that needs to be parsed
    * @return: List<Object> type
    * */
    
    public static List<Object> processResponse(HttpResponse response,boolean isException,httpRequest request) {        
        if(!isException){
            objCorrespondceResp = SSP_CorrespondenceResponseWrapper.parse(response.getBody());
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if(responseMap.get('AckResponse') != NULL) {
                string Message =  SSP_InterfaceConstants.SSPINT_ERRORRESPCODE+response.getStatusCode() +SSP_InterfaceConstants.SSPINT_ERRORRESPBODY+response.getBody() +SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE+response.getStatus();
                LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'CorrespondenceUtilityService','CorrespondenceUtilityService','processResponse',
                                                                                  Message,null,request.getBody(),'Status Code:-'+response.getStatusCode(),response.getBody(),timeTaken, true);
                
                objCorrespondceResp.LogId = lstLogMessag.id;
                objCorrespondceResp.isSuccess = false;
            } else {
                objCorrespondceResp.isSuccess = true;                
            }
        } else {
            string Message = SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE+response.getStatusCode() + SSP_InterfaceConstants.SSPINT_ERRORRESPBODY + response.getBody() + SSP_InterfaceConstants.SSPINT_ERRORRESPCODE +response.getStatus();
            LOG_LogMessage__c lstLogMessag = 
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,
                                                 null,
                                                 'CorrespondenceUtilityService',
                                                 'CorrespondenceUtilityService',
                                                 'processResponse',
                                                 Message,
                                                 null,
                                                 request.getBody(),
                                                 'Status Code:-'+response.getStatusCode(),
                                                 response.getBody(),
                                                 timeTaken,
                                                 true); 
            objCorrespondceResp.LogId = lstLogMessag.id;
            objCorrespondceResp.isSuccess = false;
        }
        objCorrespondceResp.StatusCode = response.getStatusCode();
        return new List<Object>{objCorrespondceResp};
            }
}