/**
 * Class Name    : SSP_RSSPDC_IntegrationService
 * Owner         : DELOITTE
 * Created Date  : 28/11/2019
 * Description   : Class to invoke Reverse SSP DC Integration Service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  11/12/2019  Rajeev Kumar        Initial Version
 */

public with sharing class SSP_RSSPDC_IntegrationService extends RestIntegrationService {    
    
    /**
     * method                                   : invokeCallout
     * @description                             : Method to make RSSPDC call out
     * @author                                  : Rajeev Kumar
     * @param sInterfaceName                    : Interface Name
     * @param mapParams                         : Map of Request Parameters
     */  
    public static List<Object> invokeCallout(String sInterfaceName, Map<String, Object> mapParams) {
        List<Object> lstResponse;
        List<Object> lstRes;
        List<Object> lstResponseObject = new List<Object>();
        SSP_RSSPDCWrapper objWrapper = new SSP_RSSPDCWrapper();
        RSSP_DC_Wrapper objResWRapper  = new RSSP_DC_Wrapper();
        Log_LogMessage__c objLog;
        try {
            // Get Request parameter
            objWrapper = (new SSP_RSSPDC_IntegrationHandler()).prepareRequestParams(sInterfaceName, mapParams);
            if(!objWrapper.lstAllViews.isEmpty()) {
                try {
                    objWrapper.boolIsDebug = mapParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapParams.get(SSP_InterfaceConstants.IS_DEBUG);
                    //PERF Fix
                    if(!objWrapper.skipTransaction){
                    // Update Pending Transactions
                    (new SSP_RSSPDC_IntegrationUtility()).updateTransactionStatus(objWrapper, SSP_InterfaceConstants.PENDING);
                    }
                    // Invoke callout for first view
                    lstResponse = (new SSP_RSSPDC_IntegrationService()).invokeHttpCallout(objWrapper);
                    // Create account for Agent Assister Service     
                    if(objWrapper.lstAccounts != null && !objWrapper.lstAccounts.isEmpty() && objWrapper.objRequest.viewName == SSP_InterfaceConstants.AUTHREPS_ASSISTERS) {
                        (new SSP_RSSPDC_IntegrationDMLUtility()).upsertAccounts(objWrapper.lstAccounts);
                    }
                    if(lstResponse != null && !lstResponse.isEmpty()) { 
                        // Perform DML Operations on Response
                        objResWRapper = (new SSP_RSSPDC_IntegrationHandler()).performOperationsOnResposne(objWrapper, lstResponse);
                    }
                    objLog = (new SSP_RSSPDC_IntegrationHandler()).handleSuccess(objWrapper);
                } catch(Exception e) {
                    (new SSP_RSSPDC_IntegrationHandler()).handleExceptions(e, objWrapper, true);
                    objResWRapper.ACKRESPONSE.AckResponseCode = objWrapper.log.LogNumber;
                }
                // Future jobs for next views
                objWrapper.lstAllViews.remove(0);
                processFutureJobs(objWrapper, mapParams);
            }
        } Catch(Exception e) {
            (new SSP_RSSPDC_IntegrationHandler()).handleExceptions(e, objWrapper, true);
            objResWRapper.ACKRESPONSE.AckResponseCode = objWrapper.log.LogNumber;
        }
        lstResponseObject.add(objResWRapper);
        if(objLog != null) {
            lstResponseObject.add(objLog);
        }
        return lstResponseObject;
    }

    /**
     * method                                   : processFutureJobs
     * @description                             : Method to call RSSPDC for to call Async
     * @author                                  : Rajeev Kumar
     * @param SSP_RSSPDCWrapper                 : Wrapper Object
     * @param mapParams                         : Map of request paramters
     */  
    public static void processFutureJobs(SSP_RSSPDCWrapper objWrapper, Map<String, Object> mapParams) {
        if(!objWrapper.lstAllViews.isEmpty()) {
            List<String> lstViews = new List<String>();
            lstViews.addAll(objWrapper.lstAllViews);
            for(String sView :lstViews) {
                invokeFutureCallout(JSON.Serialize(objWrapper));
                objWrapper.lstAllViews.remove(0);
            }
        }
    }

    /**
     * method                                   : invokeFutureCallout
     * @description                             : RSSPDC Async callout
     * @author                                  : Rajeev Kumar
     * @param sObjWrapper                       : Serialized wrapper
     */  
    @future(Callout = true)
    public static void invokeFutureCallout(String sObjWrapper) {
        List<Object> lstResponse;
        RSSP_DC_Wrapper objResWRapper  = new RSSP_DC_Wrapper();
        SSP_RSSPDCWrapper objWrapper  = new SSP_RSSPDCWrapper();
        try {
            objWrapper = (SSP_RSSPDCWrapper) JSON.deserialize(sObjWrapper, SSP_RSSPDCWrapper.class);
            // Invoke future Callout
            lstResponse = (new SSP_RSSPDC_IntegrationService()).invokeHttpCallout(objWrapper);
            if(lstResponse != null && !lstResponse.isEmpty()) { 
                // Perform DML Operations on Response
                objResWRapper = (new SSP_RSSPDC_IntegrationHandler()).performOperationsOnResposne(objWrapper, lstResponse);
            }
            Log_LogMessage__c objLog = (new SSP_RSSPDC_IntegrationHandler()).handleSuccess(objWrapper);
        } catch(Exception e) {
            (new SSP_RSSPDC_IntegrationHandler()).handleExceptions(e, objWrapper, true);
            objResWRapper.ACKRESPONSE.AckResponseCode = objWrapper.log.LogNumber;
        }
    }
    
    /**
     * method                                   : invokeHttpCallout
     * @description                             : Method to make Rest API Callout
     * @author                                  : Rajeev Kumar
     * @param objWrapper                        : Wrapper Object
     * @return List<Object>                     : List of Object
     */    
    public List<Object> invokeHttpCallout(SSP_RSSPDCWrapper objWrapper) {
        objWrapper.objRequest.viewName =  objWrapper.lstAllViews.get(0);
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(objWrapper.objRequest));
        Http objHttp = new Http();
        HttpRequest objRequest = new HttpRequest();
        httpResponse objResponse; 
        // Prepare the Request parameter
        objRequest = generateRequest(objWrapper.sInterfaceName, mapParams);
        objWrapper.log.interfaceName = SSP_InterfaceConstants.REVERSE_SSP_DC+ '.'+objWrapper.objRequest.viewName;
        objWrapper.log.endPoint = objRequest.getEndPoint();
        objWrapper.log.type = objRequest.getMethod();
        objWrapper.log.payload = JSON.serializePretty(objWrapper.objRequest);
        objWrapper.log.startTime = SSP_IntegrationUtility.getTimeInMilliseconds();
        //added by Apoorva start
        SSP_DC_ReverseMockImpl mockImpl = new SSP_DC_ReverseMockImpl();
        objRequest.setBody((String) mapParams.get(SSP_InterfaceConstants.JSON_BODY));
        objResponse = mockImpl.respond(objRequest);
        //end
        // Invoke service
        //objResponse = objHttp.send(objRequest);
        objWrapper.log.timeTaken = SSP_IntegrationUtility.getTimeInMilliseconds() - objWrapper.log.startTime;
        objWrapper.log.responseCode = (objResponse.getStatusCode() == null)? null :String.valueOf(objResponse.getStatusCode());
        try {
            objWrapper.log.responseData = JSON.serializePretty(JSON.deserializeUntyped(objResponse.getBody()));
        } catch(exception e) {
            objWrapper.log.responseData = objResponse.getBody();
            throw new CustomException(SSP_InterfaceConstants.UNEXPECTED_RESPONSE_ERROR);
        }
        return processResponse(objResponse);
    }

    /**
     * method                                   : processResponse
     * @description                             : Method to process the response to wrapper or sObject
     * @author                                  : Rajeev Kumar
     * @param objResponse                       : Http Response Wrapper
     * @return List<Object>                     : List of Object records
     */
    public List<Object> processResponse(HttpResponse objResponse) {
        Map<String, Object> formattedResults;
        RSSP_DC_Wrapper objResults;
        Map<String, Object> ackResponse;
        if(objResponse.getStatusCode() != null && objResponse.getStatusCode() != 200) {
            throw new CustomException('Unexpected Status Code');
        }
        String sJsonResponseBody = objResponse.getBody().trim();
        Map<String, Object> mapResults = (Map<String, Object>)JSON.deserializeUntyped(sJsonResponseBody);
        formattedResults = (new SSP_RSSPDC_IntegrationUtility()).getFormattedJsonDataMap(mapResults);
        // Throw exception if exception code received
        if(formattedResults.get(SSP_InterfaceConstants.ACKRESPONSE) != null) {
            ackResponse = (Map<String, Object>) formattedResults.get(SSP_InterfaceConstants.ACKRESPONSE);
        }
        if(ackResponse != null && ackResponse.containsKey(SSP_InterfaceConstants.ACKRESPONSE_CODE) && 
            String.valueOf(ackResponse.get(SSP_InterfaceConstants.ACKRESPONSE_CODE)) == SSP_InterfaceConstants.HBE_9000) {
                throw new CustomException(SSP_InterfaceConstants.ERROR_HBE_9000);
        }
        // Validate for Null Payload
        if(formattedResults.get(SSP_InterfaceConstants.SSP_PAYLOAD) == null) {
            throw new CustomException(SSP_InterfaceConstants.UNEXPECTED_RESPONSE_ERROR); 
        }
        objResults = (new SSP_RSSPDC_IntegrationHandler()).handlePayloadProcessing(formattedResults);
        return new List<Object>{ objResults };
    }
}