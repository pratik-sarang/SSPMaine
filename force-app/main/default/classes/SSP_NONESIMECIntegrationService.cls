/*
* Classname 		:  SSP_NONESIMECIntegrationService
* @description 	:  This class is the service class for Non-ESI MEC Integration Service
* @author 		:  Kommana Lova Durga Prasad
* @date 		:  18/12/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Descriptio about the Change
**/
public class SSP_NONESIMECIntegrationService extends RestIntegrationService{
    public static SSP_NONESIMECResponseWrapper objNONESIMECResp;
    public static List<SSP_Transaction__c> lstofSSPTransactions;
    public static List<LOG_LogMessage__c> lstofLogMessages;
    public static Long timeTaken;
    
    /**
* method        : invokeCallout
* @description  : This method is to make callout for SSP_NONESIMECIntegrationService
* @author       : Kommana Lova Durga Prasad
* @param developerName : It is a metadata record Name. Here we can store the endpoint details.
* @param mapInputParams : Request body in a map format
* @return: List<Object>
* */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        objNONESIMECResp = new SSP_NONESIMECResponseWrapper();
        lstofSSPTransactions = new List<SSP_Transaction__c>();
        lstofLogMessages =  new List<LOG_LogMessage__c>();
        objNONESIMECResp.IsSuccess = false;
        HttpRequest objReq = generateRequest(developerName,mapInputParams);
        string strAppId = '';
        string strCaseId = '';
        Long startTime;
        SSP_NONESIMECRequestWrapper request = SSP_NONESIMECRequestWrapper.parseNONESIMECResponse((String)mapInputParams.get(SSP_InterfaceConstants.JSON_BODY));
        if(String.isNotBlank(string.valueof(request.ApplicationNumber))){
            strAppId = string.valueof(request.ApplicationNumber);
        }
        if(String.isNotBlank(string.valueof(request.CaseNumber))){
            strCaseId = string.valueof(request.CaseNumber);
        }
        http h = new http();
        HttpResponse objRes;
        try{
            startTime = Datetime.now().getTime();
            objRes = h.send(objReq);
            Long endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
        }
        catch(Exception e){
            Long endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
            String ErrorMessage = SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() +SSP_InterfaceConstants.SSPINT_ERRORMSG+e.getMessage()+SSP_InterfaceConstants.SSPINT_ERRORTRACE+e.getStackTraceString()+SSP_InterfaceConstants.SSPINT_ERRORLINENO+e.getLineNumber();
            LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_NONESIMECIntegrationService','SSP_NONESIMECIntegrationService','invokeCallout',
                                                                              ErrorMessage,null,objReq.getBody(),'Status Code:-'+objRes.getStatusCode(),objRes.getBody(),timeTaken, false);
            lstofLogMessages.add(lstLogMessag);objNONESIMECResp.lstofLogMessages = lstofLogMessages;objNONESIMECResp.IsSuccess = false; return new List<object>{objNONESIMECResp};
                }
        if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)){
            string MessageDebug = SSP_InterfaceConstants.SSPINT_ERRORRESPCODE+objRes.getStatusCode() +SSP_InterfaceConstants.SSPINT_ERRORRESPBODY+objRes.getBody() +SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE+objRes.getStatus();
            LOG_LogMessage__c lstLogMessageDebug = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,null,'SSP_NONESIMECIntegrationService','SSP_NONESIMECIntegrationService','invokeCallout',
                                                                                    MessageDebug,null,objReq.getBody(),'Status Code:-'+objRes.getStatusCode(),objRes.getBody(),timeTaken, false);
            lstofLogMessages.add(lstLogMessageDebug);  
        }
        if(objRes.getStatusCode() == 200){
            return processResponse(objRes,false,strAppId,strCaseId,objReq);
        }
        return processResponse(objRes,true,strAppId,strCaseId,objReq);
        
    }
    
    /**
* method        : processResponse
* @description  : This method is to process the response for SSP_NONESIMECIntegrationService
* @author       :  Kommana Lova Durga Prasad
* @param lstResponseObject : 
* @param request : Instance of HttpRequest
* @param response : Response of the callout that needs to be parsed
* @return: List<Object> type
* */    
    public static List<Object> processResponse(HttpResponse response,boolean isException,string appId, string caseId,HttpRequest request) {
        
        try{
            if(!isException && string.isNotBlank(response.getBody())){
                objNONESIMECResp = SSP_NONESIMECResponseWrapper.parseNONESIMECResponse(response.getBody());
                // List<SSP_Transaction__c> lstOfAllEachLevelTranscations = new List<SSP_Transaction__c>();
                String strInterfaceName = SSP_InterfaceConstants.SSPNONESIMEC_METADATANAME;
                if(objNONESIMECResp != null && objNONESIMECResp.AckResponse != null && objNONESIMECResp.AckResponse.AckResponseCode != null){
                    string Message = SSP_InterfaceConstants.SSPINT_ERRORRESPCODE+response.getStatusCode() +SSP_InterfaceConstants.SSPINT_ERRORRESPBODY+response.getBody() +SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE+response.getStatus();
                    LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_NONESIMECIntegrationService','SSP_NONESIMECIntegrationService','invokeCallout',
                                                                                      Message,null,request.getBody(),'Status Code:-'+response.getStatusCode(),response.getBody(),timeTaken, false);
                    lstofLogMessages.add(lstLogMessag);
                    objNONESIMECResp.IsSuccess = false; 
                }
                else if(objNONESIMECResp != null && objNONESIMECResp.VerifyNonESIMECResp != null && objNONESIMECResp.VerifyNonESIMECResp.NonESIMECIndividualResp != null && 
                        !objNONESIMECResp.VerifyNonESIMECResp.NonESIMECIndividualResp.isEmpty()){
                            for(SSP_NONESIMECResponseWrapper.NonESIMECIndividualRespWrapper eachResp : (List<SSP_NONESIMECResponseWrapper.NonESIMECIndividualRespWrapper>)objNONESIMECResp.VerifyNonESIMECResp.NonESIMECIndividualResp){
                                String strSSN = '';
                                String strOrgCode = '';
                                String strMECVerificationCode = '';
                                if(eachResp.Applicant != null && eachResp.Applicant.PersonSSNIdentification != null){
                                    strSSN =  eachResp.Applicant.PersonSSNIdentification;
                                    if(eachResp.OtherCoverage != null && !eachResp.OtherCoverage.isEmpty()){
                                        for(SSP_NONESIMECResponseWrapper.OtherCoverageWrapper OtherCoverage:  eachResp.OtherCoverage){
                                            if(OtherCoverage.OrganizationCode != null){
                                                strOrgCode = OtherCoverage.OrganizationCode;
                                            }
                                            if(OtherCoverage.MECCoverage != null && OtherCoverage.MECCoverage.Insurance != null && !OtherCoverage.MECCoverage.Insurance.isEmpty()){
                                                for(SSP_NONESIMECResponseWrapper.InsuranceWrapper eachInsurance : OtherCoverage.MECCoverage.Insurance){
                                                    SSP_Transaction__c eachInsuranceLevelTranscation = new SSP_Transaction__c();
                                                    eachInsuranceLevelTranscation.InterfaceName__c = strInterfaceName;
                                                    eachInsuranceLevelTranscation.ApplicationId__c = appId;
                                                    eachInsuranceLevelTranscation.CaseNumber__c = caseId;
                                                    eachInsuranceLevelTranscation.SSN__c = strSSN;
                                                    eachInsuranceLevelTranscation.OrganizationName__c = strOrgCode;
                                                    if(eachInsurance.InsuranceEffectiveDate != null){
                                                        eachInsuranceLevelTranscation.StartDate__c = Date.valueof(eachInsurance.InsuranceEffectiveDate);
                                                    }
                                                    if(eachInsurance.InsuranceEndDate != null){
                                                        eachInsuranceLevelTranscation.EndDate__c = Date.valueof(eachInsurance.InsuranceEndDate);
                                                    }
                                                    if(eachInsurance.InsuranceEndDateSpecified1 != null){
                                                        eachInsuranceLevelTranscation.InsuranceEndDateSpecified__c = Boolean.valueof(eachInsurance.InsuranceEndDateSpecified1);
                                                    }
                                                    lstofSSPTransactions.add(eachInsuranceLevelTranscation);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if(!lstofSSPTransactions.isEmpty()){
                                
                                objNONESIMECResp.lstofTransactionsToInsert = lstofSSPTransactions;
                                List<SSP_Transaction__c> lstofDeleteTranscations = deleteAndInsertRecords(appId,caseId);
                                if(lstofDeleteTranscations != null && !lstofDeleteTranscations.isEmpty()){
                                    objNONESIMECResp.lstofTransactionsToDelete =  lstofDeleteTranscations;
                                }
                                objNONESIMECResp.IsSuccess = true; 
                            }
                        }
            }
            else{
                string Message = SSP_InterfaceConstants.SSPINT_ERRORRESPCODE+response.getStatusCode() +SSP_InterfaceConstants.SSPINT_ERRORRESPBODY+response.getBody() +SSP_InterfaceConstants.SSPINT_ERRORRESPSTCDE+response.getStatus();
                LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_NONESIMECIntegrationService','SSP_NONESIMECIntegrationService','invokeCallout',
                                                                                  Message,null,request.getBody(),'Status Code:-'+response.getStatusCode(),response.getBody(),timeTaken, false);
                lstofLogMessages.add(lstLogMessag);
            }
        }
        catch(Exception e){
            String ErrorMessage = SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() +SSP_InterfaceConstants.SSPINT_ERRORMSG+e.getMessage()+SSP_InterfaceConstants.SSPINT_ERRORTRACE+e.getStackTraceString()+SSP_InterfaceConstants.SSPINT_ERRORLINENO+e.getLineNumber();
            LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_NONESIMECIntegrationService','SSP_NONESIMECIntegrationService','invokeCallout',
                                                                              ErrorMessage,null,request.getBody(),'Status Code:-'+response.getStatusCode(),response.getBody(),timeTaken, false);
            lstofLogMessages.add(lstLogMessag);
            objNONESIMECResp.IsSuccess = false;
        }
        objNONESIMECResp.lstofLogMessages = lstofLogMessages;
        return new List<Object>{objNONESIMECResp};
            } 
    
    public static List<SSP_Transaction__c> deleteAndInsertRecords(string appId, string caseId){
        List<SSP_Transaction__c> lstToDelete = new List<SSP_Transaction__c>();
        string InterfaceName = SSP_InterfaceConstants.SSPNONESIMEC_METADATANAME;
        string sQuery = 'Select Id from SSP_Transaction__c where InterfaceName__c=:InterfaceName';
        if(string.isNotBlank(appId) && string.isNotBlank(caseId)){
            sQuery = sQuery+ ' AND (ApplicationId__c=:appId OR CaseNumber__c=:caseId)';
        }
        else if(string.isNotBlank(appId)){
            sQuery = sQuery+ ' AND ApplicationId__c=:appId';
        }
        else if(string.isNotBlank(caseId)){
            sQuery = sQuery+ ' AND CaseNumber__c=:caseId';
        }
        lstToDelete = Database.query(sQuery);
        return lstToDelete;
    }
    
}
