/**
* Class Name    : SSP_MCIMergedServiceUtility
* Owner         : DELOITTE
* Created Date  : 11/12/2019
* Description   : Class that holds utility methods for SSP MCI Merged Service
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/

public with sharing class SSP_MCIMergedServiceUtility  extends RestIntegrationService {
    
    public static SSP_MCIMergedServiceResponeWrapper respWrapper;
    public static List<LOG_LogMessage__c> lstofLogs;
    public static Long timeTaken;
    /**
* method        : invokeCallout
* @description  : This method is to make callout for MCI Merged Service
* @author       : Kommana Lova Durga Prasad
* @param developerName : It is a metadata record Name. Here we can store the endpoint details.
* @param mapInputParams : Request body in a map format
* @return: List<Object>
* */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        respWrapper = new SSP_MCIMergedServiceResponeWrapper();
        lstofLogs = new List<LOG_LogMessage__c>();
        HttpRequest objReq = generateRequest(developerName,mapInputParams);
        http h = new http();
        httpResponse objRes = new httpResponse();
        Long startTime;
        try{
            startTime = Datetime.now().getTime();
            objRes  = h.send(objReq);
            Long endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
        }
        catch(Exception e){
            Long endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
            LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_MCIMergedServiceUtility','SSP_MCIMergedServiceUtility','invokeCallout',
                                                                              String.valueof(SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() +SSP_InterfaceConstants.SSPINT_ERRORMSG+e.getMessage()+SSP_InterfaceConstants.SSPINT_ERRORTRACE+e.getStackTraceString()+SSP_InterfaceConstants.SSPINT_ERRORLINENO+e.getLineNumber()),
                                                                              null,objReq.getBody(),'Status Code:-'+objRes.getStatusCode(),objRes.getBody(),timeTaken, false);
            
            lstofLogs.add(lstLogMessag);respWrapper.ErrorCode = 'SFCalloutException';respWrapper.ErrorMessage = 'SF Callout Exception';respWrapper.lstofLogMessages = lstofLogs;
            return new List<object>{respWrapper};
                }
        return processResponse(null,objReq,objRes,mapInputParams);
    }
    
    
    /**
* method        : processResponse
* @description  : This method is to process the response for MCI Merged Service
* @author       :  Kommana Lova Durga Prasad
* @param lstResponseObject : 
* @param request : Instance of HttpRequest
* @param response : Response of the callout that needs to be parsed
* @return: List<Object> type
* */
    public static List<Object> processResponse(List<Object> lstResponseObject, HttpRequest request, HttpResponse response,Map<String, object> mapInputParams) {
        string sSFRequestBody = request.getBody();
        if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)){
            string MessageDebug = SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE+response.getStatusCode() + SSP_InterfaceConstants.SSPINT_ERRORRESPBODY + response.getBody() + SSP_InterfaceConstants.SSPINT_ERRORRESPCODE +response.getStatus();
            LOG_LogMessage__c lstLogMessageDebug = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,null,'SSP_MCIMergedServiceUtility',
                                                                                    'SSP_MCIMergedServiceUtility','processResponse',
                                                                                    MessageDebug,null,sSFRequestBody,'Status Code:-'+response.getStatusCode(),
                                                                                    response.getBody(),timeTaken, false);
            lstofLogs.add(lstLogMessageDebug);
        }
        try{
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            respWrapper.Mode =  string.valueof(responseMap.get(SSP_InterfaceConstants.SMODE));
            resPwrapper.CaseNumber = string.valueof(responseMap.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER));
            resPwrapper.Applicationnumber =  string.valueof(responseMap.get(SSP_InterfaceConstants.SSPMCI_APPNUMBER));
            resPwrapper.IndividualId = string.valueof(responseMap.get(SSP_InterfaceConstants.SSPMCI_INDID));
            resPwrapper.ViewName = string.valueof(responseMap.get(SSP_InterfaceConstants.SSPMCI_VIEWNAME));
            respWrapper.isApplicationBlocked = false;
            respWrapper.MatchStatus = (string) responseMap.get(SSP_InterfaceConstants.SSPMCI_MATCHSTATUS);
            respWrapper.isMemberFileCleared = (boolean) responseMap.get(SSP_InterfaceConstants.SSPMCI_FILECLR);
            if(responseMap.get(SSP_InterfaceConstants.SSPMCI_APPBLOCK) != null && boolean.valueOf(responseMap.get(SSP_InterfaceConstants.SSPMCI_APPBLOCK))){
                respWrapper.isApplicationBlocked = (boolean) responseMap.get(SSP_InterfaceConstants.SSPMCI_APPBLOCK);
                respWrapper.BlockedCaseNumber = string.valueOf(responseMap.get(SSP_InterfaceConstants.SSPMCI_BLOCKCNUMBER));
            }
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(responseMap.get(SSP_InterfaceConstants.SSPMCI_ERRORDATA)));
            if(response.getStatusCode() == 200 ){
                if(errorMap != null &&(string.isNotBlank(string.valueof(errorMap.get(SSP_InterfaceConstants.SSPMCI_ERRORCODE))) || string.isNotBlank(string.valueof(errorMap.get(SSP_InterfaceConstants.SSPMCI_ERRORDES)))) ){
                    respWrapper.ErrorCode  = string.valueof(errorMap.get(SSP_InterfaceConstants.SSPMCI_ERRORCODE));
                    respWrapper.ErrorMessage = string.valueof(errorMap.get(SSP_InterfaceConstants.SSPMCI_ERRORDES));
                }
                if( responseMap.get(SSP_InterfaceConstants.MCI_SSP_Payload) != NULL ){
                    Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(responseMap.get(SSP_InterfaceConstants.MCI_SSP_Payload)));
                    if(responseMap.get(SSP_InterfaceConstants.SSPMCI_MATCHSTATUS) != null || respWrapper.isMemberFileCleared){ 
                        if(payloadMap.get(SSP_InterfaceConstants.MEMBER_API) != null) {
                            List<SSP_Member__c> ListofSSP_Member = (List<SSP_Member__c>) JSON.deserialize(JSON.serialize(payloadMap.get(SSP_InterfaceConstants.MEMBER_API)), List<SSP_Member__c>.class);
                            respWrapper.lstOfSSPMembers = ListofSSP_Member;
                            
                        }
                        if(payloadMap.get(SSP_InterfaceConstants.SSPMCI_APPINDOBJECT) != null) {
                            List<SSP_ApplicationIndividual__c> ListofApplcationIndividuals = (List<SSP_ApplicationIndividual__c>) JSON.deserialize(JSON.serialize(payloadMap.get(SSP_InterfaceConstants.SSPMCI_APPINDOBJECT)), List<SSP_ApplicationIndividual__c>.class);
                            respWrapper.lstOfApplicationIndividuals = ListofApplcationIndividuals;
                        }
                        if(payloadMap.get(SSP_InterfaceConstants.SSPMCI_APPOBJECT) != null) {
                            List<SSP_Application__c> ListofApplcations = (List<SSP_Application__c>) JSON.deserialize(JSON.serialize(payloadMap.get(SSP_InterfaceConstants.SSPMCI_APPOBJECT)), List<SSP_Application__c>.class);
                            respWrapper.lstofApplications = ListofApplcations;
                        }  
                    }
                } 
            }
            else{
                respWrapper.ErrorCode  = String.valueof(response.getStatusCode());
                respWrapper.ErrorMessage =response.getStatus();
                string Message = SSP_InterfaceConstants.SSPINT_ERRORRESPCODE+response.getStatusCode() +SSP_InterfaceConstants.SSPINT_ERRORRESPBODY+response.getBody() +SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE+response.getStatus();
                LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_MCIMergedServiceUtility','SSP_MCIMergedServiceUtility','processResponse',
                                                                                  Message,null,sSFRequestBody,'Status Code:-'+response.getStatusCode(),response.getBody(),timeTaken, false);
                
                lstofLogs.add(lstLogMessag);
            }
        }
        catch(Exception e){
            String ErrorMessage = SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() +SSP_InterfaceConstants.SSPINT_ERRORMSG+e.getMessage()+SSP_InterfaceConstants.SSPINT_ERRORTRACE+e.getStackTraceString()+SSP_InterfaceConstants.SSPINT_ERRORLINENO+e.getLineNumber();
            LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_MCIMergedServiceUtility','SSP_MCIMergedServiceUtility','processResponse',
                                                                              ErrorMessage,null,sSFRequestBody,'Status Code:-'+response.getStatusCode(),response.getBody(),timeTaken, false);
            lstofLogs.add(lstLogMessag); 
            respWrapper.ErrorCode = 'SFCalloutException';
            respWrapper.ErrorMessage = 'SF Callout Exception';
        }
        respWrapper.lstofLogMessages = lstofLogs;
        return new List<object>{respWrapper}; 
            }
}