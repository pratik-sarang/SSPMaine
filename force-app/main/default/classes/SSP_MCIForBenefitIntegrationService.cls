/**
* Class Name    : SSP_MCIIntegrationService
* Owner         : DELOITTE
* Created Date  : 06/03/2020
* Description   : Class that holds utility methods for SSP MCI Service
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  06/03/2020  Ragunathan                   Initial Version
*/
public with sharing class SSP_MCIForBenefitIntegrationService extends SOAPIntegrationService {

    public static final String SOURCE = 'SSP_MCIForBenefitIntegrationService';
    public static final String SOURCE_FUNCTION = 'invokeCallout';

    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for MCI Service
    * @author       : Ragunathan
    * @param developerName : It is a metadata record Name. Here we can store the endpoint details.
    * @param mapInputParams : Request body in a map format
    * @return: List<Object>
    * */
    public static List<Object> invokeCallout(String sInterfaceName, Map<String, object> mapInputParams) {
        logMessageWrapper objLog = new logMessageWrapper();
        Log_LogMessage__c log;
        objLog.interfaceName = sInterfaceName;
        objLog.source = SOURCE;
        objLog.sourceFunction = SOURCE_FUNCTION;
        Datetime startTime = Datetime.now();
        Datetime endTime;
        List<Object> serviceResponse = new List<Object>();
        try {        
            
            SSP_MCIForBenefitRequestWrapper request = (SSP_MCIForBenefitRequestWrapper)JSON.deserialize((String)mapInputParams.get(SSP_InterfaceConstants.JSON_BODY), SSP_MCIForBenefitRequestWrapper.class);
            Contact con = request.con;
            
            kyHbeMciDatacontracts.MciEntitySearchResponse res = new kyHbeMciDatacontracts.MciEntitySearchResponse();
            SSP_InterfaceDetail__mdt objInterfaceDetail = getCertificateName(sInterfaceName);
            kyHbeMciDatacontracts.MciEntitySearchRequest req = new kyHbeMciDatacontracts.MciEntitySearchRequest();
            kyHbeMci.MciHttpsDefaultEndpoint stub = new kyHbeMci.MciHttpsDefaultEndpoint();
            stub.endpoint_x         = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            if(objInterfaceDetail.Timeout_Miliseconds__c != null) {
                stub.timeout_x          = Integer.valueof(objInterfaceDetail.Timeout_Miliseconds__c);
            }            
            req.SourceSystemName    = 'HBE';
            req.FirstName           = con.firstName;
            req.LastName            = con.LastName;
            req.Dob                 = con.birthdate;
            if(con.ssn__c!=null){
                req.Ssn=con.ssn__c;  
            }
            req.Gender              = con.Gender__c;
            objLog.payload = JSON.serialize(req);
            objLog.endpoint = SSP_InterfaceConstants.SSP_CallOut+objInterfaceDetail.SSP_NamedCredential__c;
            objLog.startTime = SSP_IntegrationUtility.getTimeInMilliseconds();
            res = stub.EntityMciSearch(req);
            endTime = Datetime.now();
            objLog.timeTaken = endTime.getTime() - startTime.getTime();
            objLog.responseData = JSON.serialize(res);
            serviceResponse.add(res);

            if(objInterfaceDetail.Is_Debug__c) {
                log = (new SSP_IntegrationUtility()).createLogMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, objLog, false);
                serviceResponse.add(log);
            }
    } catch(Exception e) {
        endTime = Datetime.now();
        objLog.timeTaken = endTime.getTime() - startTime.getTime();
        // create log for the exception
        log = (new SSP_IntegrationUtility()).handleException(e, objLog, true);
    }
        return serviceResponse;
    }
}