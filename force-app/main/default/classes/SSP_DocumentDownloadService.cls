/**
* Class Name    : SSP_DocumentDownloadService
* Owner         : DELOITTE
* Created Date  : 11/12/2019
* Description   : Class that holds utility methods for SSP Document Download Service
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer                    Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
public class SSP_DocumentDownloadService extends SOAPIntegrationService {
    public static final String SOURCE = 'SSP_DocumentDownloadService';
    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for Document Download Service
    * @author       : Kommana Lova Durga Prasad
    * @param developerName : It is a metadata record Name. Here we can store the endpoint details.
    * @param mapInputParams : Request body in a map format
    * @return: List<Object>
    * */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        Continuation con = new Continuation(60);
        con.continuationMethod = SSP_GlobalConstants.PROCESS_RESPONSE; //SSP_Interface_Security Fixes moved to Global Constants
        string response = null;
        String responseTrimed = '';
        boolean isAsync = false;
        List<LOG_LogMessage__c> lstofLogs = new List<LOG_LogMessage__c>();
        Long startTime;
        Long endTime;
        //Long timeTaken;
        try{
            
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(developerName);
            
            String DocumentId = string.valueof(mapInputParams.get('DocumentId')) != NULL ? string.valueof(mapInputParams.get('DocumentId')) : '';
            String MappingId =  string.valueof(mapInputParams.get('MappingId')) != NULL ? string.valueof(mapInputParams.get('MappingId')) : ''; 
            SSP_DDtempuriOrg.BasicHttpBinding_ITwoWayAsync docDownloadService = new SSP_DDtempuriOrg.BasicHttpBinding_ITwoWayAsync();
            docDownloadService.endpoint_x = SSP_GlobalConstants.CALLOUT_COLON+objInterfaceDetail.SSP_NamedCredential__c; //SSP_Interface_Security Fixes moved to Global Constants
            if(objInterfaceDetail.Timeout_Miliseconds__c != null) {
                docDownloadService.timeout_x = (Integer) objInterfaceDetail.Timeout_Miliseconds__c;
            }                                                                                                                    
            /* Here we are making callout*/
            startTime = Datetime.now().getTime();
            response = docDownloadService.DMSGetDocumentService(DocumentId,MappingId);   
            endTime = Datetime.now().getTime();         
            responseTrimed = (string.isNotBlank(response) && response.length() > 32000) ? response.substring(0,32000) :response;            
        }
        catch(Exception e){
            endTime = Datetime.now().getTime();
            Long timeTaken = endTime - startTime;
            LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,SOURCE,SOURCE,'invokeCallout',
                                                                              SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() +SSP_InterfaceConstants.SSPINT_ERRORMSG+e.getMessage()+SSP_InterfaceConstants.SSPINT_ERRORTRACE+e.getStackTraceString()+SSP_InterfaceConstants.SSPINT_ERRORLINENO+e.getLineNumber(),
                                                                              null,JSON.serialize(mapInputParams),'Status Code:-ERROR -'+ Limits.getDMLStatements(),
                                                                              responseTrimed,
                                                                              //isAsync ? JSON.serialize(con) : JSON.serialize(response),
                                                                              timeTaken, false);
            lstofLogs.add(lstLogMessag);
        }
        
        if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)){
            endTime = Datetime.now().getTime();
            Long timeTaken = endTime - startTime;
            LOG_LogMessage__c lstLogMessageDebug = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,null,SOURCE,SOURCE,'invokeCallout',
                                                                                    JSON.serialize(responseTrimed),null,
                                                                                    JSON.serialize(mapInputParams),
                                                                                    'Status Code:-Info',
                                                                                    responseTrimed,
                                                                                    timeTaken, false);
            lstofLogs.add(lstLogMessageDebug);
        }
        if(!lstofLogs.isEmpty() && Schema.sObjectType.LOG_LogMessage__c.isCreateable() ){
            insert lstofLogs;
        }
        return new List<Object>{response};
        }
}