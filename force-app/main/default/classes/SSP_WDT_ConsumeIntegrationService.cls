/**
 * Class Name    : SSP_WDT_ConsumeIntegrationService
 * Owner         : DELOITTE
 * Created Date  : 20/04/2020
 * Description   : Class to invoke SSP Waiver Data Transfer Integration Service for consume
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  20/04/2020  Ragunathan          Initial Version
 */
public with sharing class SSP_WDT_ConsumeIntegrationService extends RestIntegrationService {

    /**
     * method                                   : invokeCallout
     * @description                             : Method to Invoke the callout
     * @author                                  : Ragunathan
     * @param sInterfaceName                    : Unique Interface Name
     * @param mapParams                         : Map of views and associated Programs
     * @return void                             : void
     */
    public List<Object> invokeCallout(String sInterfaceName, Map<String, Object> mapInputParams) {
        HttpResponse objRes = new HttpResponse();
        HttpRequest objReq = new HttpRequest();
        List<Object> response = new List<Object>();
        Datetime startTime = Datetime.now();
        Long timeTaken;
        Datetime endTime;
        try {
            objReq = generateRequest(sInterfaceName, mapInputParams);
            objRes = sendRequest(objReq);
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            response.add( SSP_WDT_IntegrationUtility.processConsumeResponse(objRes.getbody()) );
			
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
                LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    'SSP_WDT_ConsumeIntegrationService',
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
                                        'SSP_WDT_ConsumeIntegrationService',
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