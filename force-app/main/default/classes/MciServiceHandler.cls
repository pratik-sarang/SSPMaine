/**
* Class        :  MciServiceHandler 
* Description  :  Retrieving details from MCI system.
* @author      :  Deloitte
* @date        :  
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* -----------------------------------------------------------------------------------------------------------   
* 
**/
	public with sharing class MciServiceHandler {
    
    public static kyHbeMciDatacontracts.MciEntitySearchResponse getIndividualBenefindId(string indivKOGId,user usr,string strSourceSystemName){
        kyHbeMciDatacontracts.MciEntitySearchResponse res = new kyHbeMciDatacontracts.MciEntitySearchResponse();
        WebServiceSettings__c mciConfig = WebServiceSettings__c.getValues(SSP_GlobalConstants.MCI_ENTITIY_SEARCH);
        Long startTime= DateTime.now().getTime();
        String requestData;
        String responseData;
        try{
            //WebServiceSettings__c mciConfig = WebServiceSettings__c.getValues('MCI Entity Search');
            kyHbeMciDatacontracts.MciEntitySearchRequest req = new kyHbeMciDatacontracts.MciEntitySearchRequest();
            kyHbeMci.MciHttpsDefaultEndpoint stub = new kyHbeMci.MciHttpsDefaultEndpoint();
            stub.clientCertName_x = mciConfig.Certificate_Name__c;
            stub.endpoint_x = mciConfig.Target_URL__c;
            stub.timeout_x = Integer.valueOf(mciConfig.Time_Out__c);
            req.SourceSystemName = strSourceSystemName;
            req.SourceIndividualId = indivKOGId;
            requestData = JSON.serialize(stub) + JSON.serialize(req);
            res = stub.EntityMciSearch(req);
            responseData = JSON.serialize(stub.EntityMciSearch(req));
        }catch(exception ex){
            //LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'MciServiceHandler','getIndividualBenefindId', ex.getMessage() + ex.getStackTraceString(),true);
            
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.CALLOUT_TO_MCI_SERVICE_IS_FAILED, Source__c =SSP_GlobalConstants.MCI_SERVICE_HANDLER, 
                                              Message__c =  ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.GET_INDIVIDUAL_BENEFIND,
                                              EndPoint__c = mciConfig.Target_URL__c,Timer__c = DateTime.now().getTime()-startTime,
                                              Integration_Payload__c = requestData,InterfaceName__c = 'MCI Service',ResponseData__c = responseData));
            if(publishEvents.size()>0){
                  EventBus.publish(publishEvents);
            }       
        }
        return res;
    }
}
