/**
 * Class Name    : SSP_WDT_IntegrationService
 * Owner         : DELOITTE
 * Created Date  : 10/04/2020
 * Description   : Class to invoke SSP Waiver Data Transfer Integration Service for Generate token
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  10/04/2020  Ragunathan          Initial Version
 */
public with sharing class SSP_WDT_GenerateIntegrationService extends RestIntegrationService {

    /**
     * method                                   : invokeCallout
     * @description                             : Method to invoke the callout
     * @author                                  : Ragunathan
     * @param sInterfaceName                    : Unique Interface Name
     * @param mapParams                         : Map of views and associated Programs
     * @return void                             : void
     */
    public List<Object> invokeCallout(String sInterfaceName, Map<String, Object> mapInputParams) {
        HttpResponse objRes = new HttpResponse();
        HttpResponse consumeRes = new HttpResponse();
        HttpRequest objReq = new HttpRequest();
        HttpRequest consumeReq = new HttpRequest();
        List<Object> response = new List<Object>();
        DateTime startTime = Datetime.now();
        Long timeTaken;
        DateTime endTime;
        try {
            Map<String, Object> processedRequest = SSP_WDT_IntegrationUtility.processRequestDetails(mapInputParams);
            objReq = generateRequest(sInterfaceName, processedRequest);
            objRes = sendRequest(objReq);
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            SSP_WDT_GenerateResponseWrapper generatedToken = (SSP_WDT_GenerateResponseWrapper) JSON.deserialize(objRes.getbody(), SSP_WDT_GenerateResponseWrapper.class);
            response.add(generatedToken);
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
                LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    'SSP_WDT_GenerateIntegrationService',
                    sInterfaceName,
                    'invokeCallout',
                    stErrorMessage,
                    objReq.getMethod(),
                    objReq.getBody(),
                    'Status Code: '+objRes.getStatusCode(),
                    objRes.getBody(),
                    timeTaken, 
                    true);
            }
        } catch (Exception ex) {
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
            LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        sInterfaceName,
                                        'SSP_WDT_GenerateIntegrationService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        objRes.getBody(),
                                        timeTaken, 
                                        true
                                    );
        }
        
        return response;
    }
}