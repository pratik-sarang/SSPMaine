/**
 * Class Name    : SSP_SSPDCIntegrationServiceBatch
 * Owner         : DELOITTE
 * Created Date  : 03/31/2020
 * Description   : This batch class will run for every 1 hour to process failed SSPDC Integration service.
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  03/31/2020   Ragunathan       Initial Version
 */
global class SSP_SSPDCIntegrationServiceBatch extends RestIntegrationService implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {
    @TestVisible private static Boolean boolMakeCallout = true ;
    public String PENDING = SSP_InterfaceConstants.PENDING;
    public String SSP_DC = SSP_InterfaceConstants.SSP_DC;
    public String SSP_Status = 'Cancelled';
    Map<String, SObject> mdtMap = new SSP_CustomMetadataAccessor().getAllRecordsMap('SSP_InterfaceDetail__mdt');
    SSP_InterfaceDetail__mdt interfaceDetail = (SSP_InterfaceDetail__mdt)mdtMap.get('SSP_DC');
    Decimal inCounter = interfaceDetail.No_of_Retry__c;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select '+
										' InterfaceName__c, '+
										' MapOfInputParams__c, '+
										' ApplicationId__c, '+
                                        ' Status__c, '+
                                        ' No_of_Retry__c, '+
										' Unique_Id__c '+
                                        ' From SSP_Transaction__c '+
                                        ' Where Status__c =:PENDING AND InterfaceName__c =:SSP_DC'+
                                        ' AND No_of_Retry__c <:inCounter');
    }
    global void execute(Database.BatchableContext bc, List<SSP_Transaction__c> transactionDetails){
        List<SSP_Transaction__c> transactionDetailToUpdate = new List<SSP_Transaction__c>();
        Map<Id,String> mapAppIDBody = new Map<Id,String>();
        Map<Id,Decimal> mapAppIDCounter = new Map<Id,Decimal>();
        List<SSP_Application__c> lstApplication = new List<SSP_Application__c>();
        List<LOG_LogMessage__c> lstLog = new List<LOG_LogMessage__c>();
        for(SSP_Transaction__c td: transactionDetails) {
            if(td.MapOfInputParams__c != null && td.ApplicationId__c != null) {
                mapAppIDBody.put(td.ApplicationId__c,td.MapOfInputParams__c);
                mapAppIDCounter.put(td.ApplicationId__c,td.No_of_Retry__c);
            }
            if(Test.isRunningTest()){
                Map<String, Object> mapInputParams = (Map<String, Object>) JSON.deserializeUntyped(td.MapOfInputParams__c);
                List<Object> lstReturn = invokeCallout(td.InterfaceName__c, mapInputParams);
            }
        }
        if(Schema.sObjectType.SSP_Application__c.fields.SSPDCMessage__c.isAccessible()){ //Force reviewer Checks made 
            lstApplication = [Select id,SSPDCMessage__c from SSP_Application__c where id in : mapAppIDBody.keySet()];
        }
        if (!lstApplication.isEmpty()) {
            for (SSP_Application__c objApp : lstApplication) {
                Map<String, Object> mapInputParams = (Map<String, Object>) JSON.deserializeUntyped(mapAppIDBody.get(objApp.id));
                mapInputParams.put('Counter',mapAppIDCounter.get(objApp.id));
                if((objApp.SSPDCMessage__c != null && (objApp.SSPDCMessage__c.equals('HBE1000') || 
                    objApp.SSPDCMessage__c.equals(SSP_SSPDCIntegrationService.SSPBLANKRES) || 
                    objApp.SSPDCMessage__c.equals(SSP_SSPDCIntegrationService.SSPXMLRES)))) {
                    List<Object> lstReturn = invokeCallout(SSP_DC, mapInputParams);
                    if(lstReturn[0] != null) {
                        transactionDetailToUpdate.add((SSP_Transaction__c)lstReturn[0]);
                    }
                    if(lstReturn[1] != null) {
                        lstLog.add((LOG_LogMessage__c)lstReturn[1]);
                    }
                }else{  
                    //Cancel out txn
                     if(objApp.SSPDCMessage__c!= null && ! objApp.SSPDCMessage__c.equals(SSP_SSPDCIntegrationService.SSPREADTIMEOUT)) {
                        transactionDetailToUpdate.add(clearTransactionDetail(SSP_DC, mapInputParams,SSP_Status));
                    }
                }
            }
        }
        if (!lstLog.isEmpty()) {
            if(Schema.sObjectType.LOG_LogMessage__c.isCreateable()){
                insert lstLog;
            }
        }
        if(!transactionDetailToUpdate.isEmpty()) {
            if(Schema.sObjectType.SSP_Transaction__c.isCreateable() && 
                        Schema.sObjectType.SSP_Transaction__c.isUpdateable()){//Security checks made
                Database.upsert(transactionDetailToUpdate, SSP_Transaction__c.Unique_Id__c.getDescribe().getSObjectField(), true);
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
    
    global void execute(SchedulableContext sc) {
        SSP_SSPDCIntegrationServiceBatch sspdcServiceBatch = new SSP_SSPDCIntegrationServiceBatch();
        database.executebatch(sspdcServiceBatch, 10);
    }
    
    public static List<Object> invokeCallout(String developerName, Map<String, Object> mapInputParams) {
        HttpResponse response = new HttpResponse();
        HttpRequest request= new HttpRequest();
        Long timeTaken;
        Datetime startTime;
        List<Object> lstReturn = new List<Object>();
        LOG_LogMessage__c objLog;
        try {
            startTime = Datetime.now();
            request= generateRequest(developerName, mapInputParams);
            if(boolMakeCallout){
                response = sendRequest(request);
            }
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            lstReturn.add(updateTransactionCounter(developerName, mapInputParams));
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)){
                String stErrorMessage =  'Status : '+response.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
                    objLog = LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    request.getEndpoint(), 
                    'SSP_SSPDCIntegrationService',
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    request.getMethod(),
                    request.getBody(),
                    'Status Code: '+response.getStatusCode(),
                    response.getBody(),
                    timeTaken, 
                    false);
            }
            
        } catch(Exception e){
            if(lstReturn.isEmpty()){
                lstReturn.add(null);
            } 
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+response.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
            objLog = LOG_LogMessageUtility.logMessage (
                                    e,
                                    request.getEndpoint(),
                                    developerName,
                                    'SSP_SSPDCIntegrationService',
                                    'invokeCallout',
                                    stErrorMessage,
                                    request.getMethod(),
                                    request.getBody(),
                                    'Status Code: '+response.getStatusCode(),
                                    response.getBody(),
                                    timeTaken, 
                                    false);
        }
        lstReturn.add(objLog);
        return lstReturn;
    }
    /**
	 * Method Name  : clearTransactionDetail
	 * Created Date : March 31st 2020
	 * Params 		:
	 * Description  :
	 */
    private static SSP_Transaction__c clearTransactionDetail(String interfaceName, Map<String, Object> inputParams, String sStatus) {
        SSP_Transaction__c transactionDetail = new SSP_Transaction__c (
            Status__c 		 	= sStatus,
            Unique_Id__c 	 	= interfaceName+'-'+inputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE)+'-'+inputParams.get(SSP_InterfaceConstants.APPLICATION_ID)
        );
        return transactionDetail;
    }
    /**
	 * Method Name  : updateTransactionCounter
	 * Created Date : March 31st 2020
	 * Params 		:
	 * Description  :
	 */
    private static SSP_Transaction__c updateTransactionCounter(String interfaceName, Map<String, Object> inputParams) {
        
        SSP_Transaction__c transactionDetail = new SSP_Transaction__c ();
        Decimal d = (Decimal)(inputParams.get('Counter'));
        transactionDetail.No_of_Retry__c = ++d;
        transactionDetail.Unique_Id__c = interfaceName+'-'+inputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE)+'-'+inputParams.get(SSP_InterfaceConstants.APPLICATION_ID);
        return transactionDetail;
    }
}