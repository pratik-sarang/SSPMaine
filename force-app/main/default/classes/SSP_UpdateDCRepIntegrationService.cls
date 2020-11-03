/**
 * Class Name    : SSP_UpdateDCRepIntegrationService
 * Owner         : DELOITTE
 * Created Date  : 21/04/2020
 * Description   : Class to invoke SSP Update DCRepresentative Service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  21/04/2020  Ragunathan          Initial Version
 */
public with sharing class SSP_UpdateDCRepIntegrationService extends RestIntegrationService {

    /**
     * method                                   : invokeCallout
     * @description                             : Method to Invoke the callout
     * @author                                  : Ragunathan
     * @param sInterfaceName                    : Unique Interface Name
     * @param mapParams                         : Map of input request parameters
     * @return void                             : void
     */
    public List<Object> invokeCallout(String sInterfaceName, Map<String, Object> mapInputParams) {
        HttpResponse objRes = new HttpResponse();
        HttpRequest objReq = new HttpRequest();
        Log_LogMessage__c log;
        List<Object> response = new List<Object>();
        Long startTime = Datetime.now().getTime();
        Long timeTaken;
        Long endTime;
        try {
            Map<String, Object> requestParam = SSP_UpdateDCRepIntegrationUtility.prepareRequestParam( mapInputParams );
            objReq = generateRequest(sInterfaceName, requestParam);
            objRes = sendRequest(objReq);
            endTime = Datetime.now().getTime();
            timeTaken = endTime - startTime;
            SSP_UpdateDCRepResponseWrapper wrapperResponse = (SSP_UpdateDCRepResponseWrapper) JSON.deserialize(objRes.getBody(), SSP_UpdateDCRepResponseWrapper.class);
			response.add(wrapperResponse);
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                //Sonar Code review comment fix
                String stErrorMessage =  SSP_InterfaceConstants.SSP_UPDATE_DC_SERVICE_STATUS+objRes.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
                    Boolean disableDML = false;
                    if(mapInputParams.containsKey(SSP_InterfaceConstants.SSP_IS_FROM_REQUEST_ACCESS)){
                        disableDML = (Boolean) mapInputParams.get(SSP_InterfaceConstants.SSP_IS_FROM_REQUEST_ACCESS);
                    }

                log = LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    SSP_InterfaceConstants.SSP_UPDATE_DC_SERVICE,
                    sInterfaceName,
                    'invokeCallout',
                    stErrorMessage,
                    objReq.getMethod(),
                    objReq.getBody(),
                    'Status Code: '+objRes.getStatusCode(),
                    objRes.getBody(),
                    timeTaken, 
                    !disableDML);
                //Send Log back as service response only when the service invoked from the Request Access Screen    
                if(disableDML) {
                    response.add(log);
                }
                
            }
        } catch (Exception ex) {
            endTime = Datetime.now().getTime();
            Long exceTimeTaken = endTime - startTime;//Sonar Code review comment fix
            String stErrorMessage =  SSP_InterfaceConstants.SSP_UPDATE_DC_SERVICE_STATUS+objRes.getStatus()+'\n'+//Sonar Code review comment fix
                					 SSP_InterfaceConstants.SSP_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSP_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSP_CASENUMBER);
            log = LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        sInterfaceName,
                                        SSP_InterfaceConstants.SSP_UPDATE_DC_SERVICE,
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        objRes.getBody(),
                                        exceTimeTaken, 
                                        true
                                    );
        }
        
        return response;
    }
}