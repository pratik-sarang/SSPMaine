/**
 * Class Name    : SSP_RSSPDC_IntegrationHandler
 * Owner         : DELOITTE
 * Created Date  : 28/11/2019
 * Description   : Class to hold handler methods for RSSPDC Integration service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  11/12/2019  Rajeev Kumar       Initial Version
 */

public with sharing class SSP_RSSPDC_IntegrationHandler { 
    /**
     * method                                           : prepareRequestParams
     * @description                                     : Handler method to prepare request parameter
     * @author                                          : Rajeev Kumar
     * @param sInterfaceName                            : Unique Interface Name
     * @param mapParams                                 : Map of parameters
     * @return SSP_RSSPDCWrapper                        : RSSPDC Wrapper Object
     */
    public SSP_RSSPDCWrapper prepareRequestParams(String sInterfaceName, Map<String, Object> mapParams) {
        SSP_RSSPDCWrapper objWrapper = new SSP_RSSPDCWrapper();
        Set<String> setViews = new Set<String>{ SSP_InterfaceConstants.ALL_VIEWS, SSP_InterfaceConstants.ADHOC_VIEWS };
        // Deserialize to Request Parameters
        objWrapper.objRequest = (SSP_RSSPDC_RequestWrapper) mapParams.get(SSP_InterfaceConstants.JSON_BODY);
        
        // Get and set the IndividualIds of the application
        if(String.isBlank(objWrapper.objRequest.individualIds) && !String.isBlank(objWrapper.objRequest.ApplicationID)) {
            objWrapper.objRequest.individualIds = (new SSP_RSSPDC_IntegrationUtility()).getIndividualIds(objWrapper.objRequest.ApplicationID);
        }
        // Get User Details
        objWrapper.objUser = (new SSP_RSSPDC_IntegrationUtility()).getUserDetails();
        // Set Role & User Id in the request
        objWrapper.objRequest = (new SSP_RSSPDC_IntegrationUtility()).setUserRole(objWrapper.objRequest, objWrapper.objUser);

        //Get Requested List of views including All, Adhoc & Pending Views
        List<ReverseSSPViewMapping__mdt> lstViewMappingRecords = (new SSP_RSSPDC_IntegrationUtility()).getRequestedMappingRecords(objWrapper.objRequest);
        
        // Get the Screen details in Case of RAC for All Views & Adhoc Views
        if(mapParams.containsKey(SSP_InterfaceConstants.SSP_SCREEN_NAMES) && objWrapper.objRequest.mode == SSP_InterfaceConstants.MODE_RAC && setViews.contains(objWrapper.objRequest.viewName)) {
            objWrapper.sScreenNames = (String) mapParams.get(SSP_InterfaceConstants.SSP_SCREEN_NAMES);
        }

        //Get & Set List of requested views
        objWrapper.lstAllViews = (new SSP_RSSPDC_IntegrationUtility()).getRequestedListOfViews(lstViewMappingRecords, objWrapper.sScreenNames);
        objWrapper.sInterfaceName = sInterfaceName;
        // Set the flow type
        setViews.add(SSP_InterfaceConstants.PENDING_VIEWS);
        if(setViews.contains(objWrapper.objRequest.viewName)) {
            objWrapper.sFlowType = objWrapper.objRequest.viewName;
        }
        //Perf Fix
        if(mapParams.containsKey(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD)){
            objWrapper.skipTransaction = (Boolean) mapParams.get(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD);
        }
        // Skip DML for not handling DML in Integration
        if(mapParams.containsKey(SSP_InterfaceConstants.SKIP_DML_OPERATIONS)) {
            objWrapper.skipDML = (Boolean) mapParams.get(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD);
        }
        if(mapParams.containsKey(SSP_InterfaceConstants.ACCOUNTS)) {
            objWrapper.lstAccounts = (List<Account>) mapParams.get(SSP_InterfaceConstants.ACCOUNTS);
        }
        // Skips log Records
        if(mapParams.containsKey(SSP_InterfaceConstants.SKIP_LOG)) {
            objWrapper.skipLog = (Boolean) mapParams.get(SSP_InterfaceConstants.SKIP_LOG);
        }
        return objWrapper;
    }
    
    /**
     * method                                           : performOperationsOnResposne
     * @description                                     : Method to perform various operations on response
     * @author                                          : Rajeev Kumar
     * @param objWrapper                                : RSSPDC Object Wrapper
     * @param lstResponse                               : List of Object in Response payload
     * @return List<Object>                             : List of Object
     */
    public RSSP_DC_Wrapper performOperationsOnResposne(SSP_RSSPDCWrapper objWrapper, List<Object> lstResponse) {
        final Set<String> setWrapperResponse = new Set<String>{SSP_InterfaceConstants.ELIGIBILITY_SUMMARY,
                                                                SSP_InterfaceConstants.KHIPP_PAYMENT_SUMMARY,
                                                                SSP_InterfaceConstants.BENEFIT_INFORMATION,
                                                                SSP_InterfaceConstants.MEDICAID_MCO_INFORMATION,
                                                                SSP_InterfaceConstants.DASHBOARD_CASE_INFORMATION,
                                                                SSP_InterfaceConstants.RAC_SELECTION_DETAILS,
                                                                SSP_InterfaceConstants.RFI_DETAILS,
                                                                SSP_InterfaceConstants.DISQUALIFICATION_DETAILS,
                                                                SSP_InterfaceConstants.PAST_APPLICATIONS,
                                                                SSP_InterfaceConstants.NON_CITIZEN_CLIENT_INFORMATION,
                                                                SSP_InterfaceConstants.NON_CITIZEN_SEARCH_CASE,
                                                                SSP_InterfaceConstants.WAIVER_DETAILS,
                                                                SSP_InterfaceConstants.CLAIMS_OVERVIEW,
                                                                SSP_InterfaceConstants.ASSISTER_AUTHREP_CLIENT_DETAILS,
                                                                SSP_InterfaceConstants.TAX_FORMS_1095A_INFORMATION,
                                                                SSP_InterfaceConstants.HEARINGS_SUMMARY_INFORMATION,
                                                                SSP_InterfaceConstants.KIHIPP_PREFERRED_PAYMENT,
                                                                SSP_InterfaceConstants.NON_CITIZEN_SEARCH_EXPORT
                                                            };
        Map<String, List<sObject>> mapProcessedData;
        List<SSP_Member__c> lstMembers;
        RSSP_DC_Wrapper objRes = new RSSP_DC_Wrapper();

        // Return empty wrapper if Payload is null
        if(lstResponse == null || (lstResponse != null && (lstResponse.isEmpty() || (!lstResponse.isEmpty() && ((RSSP_DC_Wrapper) lstResponse.get(0)).payload == null)))) {
            return objRes;
        }
        objRes = (RSSP_DC_Wrapper)lstResponse.get(0);
        Map<String, Object> payLoadData = (Map<String, Object>) objRes.payload;
        // Get Wrapper Response
        if(setWrapperResponse.contains(objWrapper.objRequest.viewName)) {
            objRes = (new SSP_RSSPDC_IntegrationUtility()).getWrapperResponse(objRes, payLoadData, objWrapper.objRequest.viewName);
            return objRes;
        }
        // Convert the wrapper to sObject
        List<RSSP_DC_JSON_Object_Mapping__mdt> lstSequentialObjMap = (new SSP_RSSPDC_IntegrationUtility()).getSequentailObjectList(payLoadData.keySet());
        mapProcessedData = processResponseToSobject(lstSequentialObjMap, payLoadData);

        //Get the Qualfied Members from the QualfiedIndividual Callout
        if(objWrapper.objRequest.viewName == SSP_InterfaceConstants.QUALIFIED_INDIVIDUAL) {
            objWrapper.objRequest.individualIds = SSP_RSSPDC_IntegrationUtility.setQaulaifiedIndividuals(objWrapper.objRequest.viewName, mapProcessedData);
            
        }

        // Perform DML on the processed Data
        if(!objWrapper.skipDML) {
            performDMLonProcessedData(objWrapper.objRequest, mapProcessedData, lstSequentialObjMap);
        }
        
        return objRes;
    }

    /**
     * method                                           : processResponseToSobject
     * @description                                     : Method to retrive requested views for execution
     * @author                                          : Rajeev Kumar
     * @param lstSequentialObjMap                       : List of Sequential
     * @param mapResponse                               : Map of object to list of records
     * @return Map<String, List<sObject>>               : Map of object to List of Records
     */
    public Map<String, List<sObject>> processResponseToSobject(List<RSSP_DC_JSON_Object_Mapping__mdt> lstSequentialObjMap, Map<string, Object> mapResponse) {
        List<Object> lstResponse = new List<Object>();
        RSSP_DC_Wrapper objResWrapper;
        RSSP_DC_Wrapper objResults;
        String sObjectName;
        Map<String, List<sObject>> mapobjectList = new Map<String, List<sObject>>();
        if(!mapResponse.keyset().isEmpty()) {
            mapResponse = (new SSP_RSSPDC_IntegrationUtility()).getFormattedJsonDataMap(mapResponse);
        }
        //Loop on Sequential Object List
        List<Object> lstJsonData;
        for (RSSP_DC_JSON_Object_Mapping__mdt objMap : lstSequentialObjMap) {
            lstJsonData = new List<Object>();     
            String sJsonObjName = (objMap.Json_Object_Name__c).toUpperCase();
            if(mapResponse.containsKey(sJsonObjName)) {
                lstJsonData = (List<Object>)mapResponse.get(sJsonObjName);
            }
            if(lstJsonData != null && !lstJsonData.isEmpty()) {                        
                //Get Object wise field map list from custom setting
                String sfObjectName = (objMap.SF_Object_Name__c).toUpperCase();
                //Save data
                mapobjectList = (new SSP_RSSPDC_IntegrationUtility()).processResponseData(lstJsonData, objMap, mapobjectList);
            }
        }
        return mapobjectList;
    }

    /**
     * method                                           : handlePayloadProcessing
     * @description                                     : Process the payload to object wrapper
     * @author                                          : Rajeev Kumar
     * @param mapFormattedResults                       : Map of object Name to Object
     * @param RSSP_DC_Wrapper                           : RSSPDC Wrapper object
     */
    public RSSP_DC_Wrapper handlePayloadProcessing(Map<String, Object> mapFormattedResults) {
        Map<String, Object> mapPayload;
        Map<String, List<Object>> mapformattedPayload = new Map<String, List<Object>>();
        mapPayload = (Map<String, Object>) mapFormattedResults.get(SSP_InterfaceConstants.SSP_PAYLOAD);
        for(String sObjKey : mapPayload.keyset()) {
            if(mapPayload.get(sObjKey) != null && mapPayload.get(sObjKey) instanceof List<Object>) {
                mapformattedPayload.put(sObjKey, (List<Object>) mapPayload.get(sObjKey));
            } else if(mapPayload.get(sObjKey) != null) {
                mapformattedPayload.put(sObjKey, new List<Object>{ mapPayload.get(sObjKey) });
            }
        }
        // Remove payload and deserialize
        mapFormattedResults.remove(SSP_InterfaceConstants.SSP_PAYLOAD);
        RSSP_DC_Wrapper objResults = (RSSP_DC_Wrapper) JSON.deserialize (JSON.serialize(mapFormattedResults), RSSP_DC_Wrapper.class);
        // set the payload back to wrapper
        if(!mapformattedPayload.isEmpty()) {
            objResults.payload = (Map<String, Object>) mapformattedPayload;
        } else {
            objResults.payload = null;
        }
        return objResults;
    }

    /**
     * method                                           : getRetrySTatus
     * @description                                     : Get the retry status of of the transaction
     * @author                                          : Rajeev Kumar
     * @param objWrapper                                : RSSPDC Object Wrapper
     * @return String                                   : Status of the transaction to update
     */
    public String getRetrySTatus(SSP_RSSPDCWrapper objWrapper) {
        String sRetryStatus = SSP_InterfaceConstants.RETRY;
        objWrapper.retry.currentCount++;
        if(objWrapper.retry.currentCount <= objWrapper.retry.totalCount) {
            objWrapper.retry.isRetry = true;
        } else {
            sRetryStatus = SSP_InterfaceConstants.FAILED;
            objWrapper.retry = new SSP_RetryWrapper();
        }
        return sRetryStatus;
    }

    /**
     * method                                           : handleExceptions
     * @description                                     : To handle all exception
     * @author                                          : Rajeev Kumar
     * @param SSP_RSSPDCWrapper                         : RSSPDC Object Wrapper
     * @param isSync                                    : Boolean to validate Sync or Asyc
     */
    public void handleExceptions(Exception e, SSP_RSSPDCWrapper objWrapper, Boolean isSync) {
        Log_LogMessage__c log = new Log_LogMessage__c();
        String sStatus = SSP_InterfaceConstants.FAILED;
        // Verify log time
        if(objWrapper != null && objWrapper.log != null && objWrapper.log.timeTaken == null && objWrapper.log.startTime != null) {
            objWrapper.log.timeTaken = SSP_IntegrationUtility.getTimeInMilliseconds() - objWrapper.log.startTime;
        }

        // Create Log Message
        log =  (new SSP_IntegrationUtility()).handleException(e, objWrapper.log, true);
        objWrapper.log.LogNumber = (log != null && log.Name != null) ? log.Name : null;
        
        // Verify Status
        if(!isSync && (type.forName(e.getTypeName()) == System.CalloutException.class || 
            (type.forName(e.getTypeName()) == CustomException.class && e.getMessage() == SSP_InterfaceConstants.ERROR_HBE_9000))) {
                sStatus = getRetrySTatus(objWrapper);
        }
        
        // Update Transaction Records
        //PERF Fix
        if(!objWrapper.skipTransaction){
            (new SSP_RSSPDC_IntegrationUtility()).updateTransactionStatus(objWrapper, sStatus);
        }
        // Clear views if failed
        if(sStatus == SSP_InterfaceConstants.FAILED) {
            //objWrapper.lstAllViews.clear();
        }
    }

    /**
     * method                                           : handleSuccess
     * @description                                     : handle all success transactions
     * @author                                          : Rajeev Kumar
     * @param objWrapper                                : RSSPDC Object Wrapper
     */
    public Log_LogMessage__c handleSuccess(SSP_RSSPDCWrapper objWrapper) {
        Log_LogMessage__c log;
        // Create Log Message
        objWrapper.retry = new SSP_RetryWrapper();
        if(objWrapper.boolIsDebug) {
            log = (new SSP_IntegrationUtility()).createLogMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, objWrapper.log, !objWrapper.skipLog);
        }
        // Update Success Transactions
        objWrapper.log.LogNumber = (log != null && log.Name != null) ? log.Name : null;
        //PERF Fix
        if(!objWrapper.skipTransaction){
            (new SSP_RSSPDC_IntegrationUtility()).updateTransactionStatus(objWrapper, SSP_InterfaceConstants.SUCCESS);
        }
        if(objWrapper.skipLog && objWrapper.boolIsDebug) {
            return log;
        }
        return null;
    }

    /**
     * method                                       : performDMLonProcessedData
     * @description                                 : Perform DML on Processed object Record
     * @author                                      : Rajeev Kumar
     * @param objWrapper                            : Object Wrapper
     * @param mapsObjects                           : List of JSON object mapping records
     * @param lstSequentialObjMap                   : List of custom metadata objects
     */
    public void performDMLonProcessedData(SSP_RSSPDC_RequestWrapper objRequest, Map<String, List<sObject>> mapsObjects, 
                                            List<RSSP_DC_JSON_Object_Mapping__mdt> lstSequentialObjMap) {
        List<sObject> lstInsertedObject = new List<sObject>();
        String sObjName;
        List<String> lstKey;
        Schema.SObjectField sExternalIdField;
        List<sObject> lstSObject = new List<sObject>();
        for(RSSP_DC_JSON_Object_Mapping__mdt obj : lstSequentialObjMap) {
            lstInsertedObject = new List<sObject>();
            if(!String.isBlank(obj.External_Id__c)) {
                sExternalIdField = Schema.getGlobalDescribe().get(obj.SF_Object_Name__c).getDescribe().fields.getMap().get(obj.External_Id__c);
            }
            sObjName = obj.SF_Object_Name__c;
            if(!mapsObjects.containsKey(sObjName)) {
                continue;
            }
            lstSobject = mapsObjects.get(sObjName);
            switch on sObjName.toUpperCase() {
                when 'SSP_MEMBER__C' {
                    // Insert Account and Contact of new Members
                    Map<String, Object> mapInsertedAccAndContacts = (new SSP_RSSPDC_IntegrationDMLUtility()).insertNewMembersAccountAndContact((List<SSP_Member__c>) lstSobject);
                    Contact objHOHContact = (new SSP_RSSPDC_IntegrationUtility()).getHOHContact(String.ValueOf(objRequest.primaryApplicationIndividualId));
                    if(objRequest.viewName == SSP_InterfaceConstants.QUALIFIED_INDIVIDUAL) {
                        (new SSP_RSSPDC_IntegrationUtility()).updateRSSPDCTimeStamp(String.valueOf(objRequest.primaryApplicationIndividualId), objRequest.mode);
                        List<SSP_Member__c> lstMembers = (new SSP_RSSPDC_IntegrationDMLUtility()).resetMembers((List<SSP_Member__c>) lstSobject, objRequest.applicationID, objRequest.mode);
                        (new SSP_RSSPDC_IntegrationDMLUtility()).deleteChildRecs(lstMembers, objRequest.applicationID);
                    }
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).updateMembers((List<SSP_Member__c>) lstSobject, sExternalIdField, ObjHOHContact, objRequest.viewName);
                    (new SSP_RSSPDC_IntegrationDMLUtility()).insertACRForNewMember((List<SSP_Member__c>) lstInsertedObject, objRequest.applicationID);
                } when 'SSP_APPLICATION__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).updateApplication((List<SSP_Application__c>)lstSobject, objRequest.applicationID);
                } when 'SSP_BENEFITS__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertBenefits((List<SSP_Benefits__c>)lstSobject, sExternalIdField);
                } when 'SSP_ASSET__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertAssets((List<SSP_Asset__c>)lstSobject, sExternalIdField, objRequest.applicationID);
                } when 'SSP_NONCUSTODIALPARENT__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertNonCustodialParent((List<SSP_NonCustodialParent__c>)lstSobject, sExternalIdField);
                } when 'SSP_NONCUSTODIALRELATIONSHIP__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).insertNonCustodialRelationship((List<SSP_NoncustodialRelationship__c>)lstSobject);
                } when 'SSP_INSURANCEPOLICY__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertInsurancePolicy((List<SSP_InsurancePolicy__c>)lstSobject, sExternalIdField);
                } when 'SSP_HealthInsurancePlanTierDetail__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertInsurancePlanTier((List<SSP_HealthInsurancePlanTierDetail__c>)lstSobject, sExternalIdField);
                } when 'SSP_INSURANCECOVEREDINDIV__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertInsuranceCoveredIndv((List<SSP_InsuranceCoveredIndiv__c>)lstSobject, sExternalIdField);
                } when 'SSP_HEALTHINSURANCEFACILITYTYPE__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).insertFacilityType((List<SSP_HealthInsuranceFacilityType__c>)lstSobject);
                } when 'SSP_INDIVIDUALMEDICALCOVERAGE__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertIndividualMedicalCoverage((List<SSP_IndividualMedicalCoverage__c>)lstSobject, sExternalIdField);
                } when 'SSP_APPLICATIONINDIVIDUAL__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).insertAppIndividualRecords((List<SSP_ApplicationIndividual__c>) lstSobject, objRequest.applicationID);
                } when 'SSP_RELATIONSHIP__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertRelationship((List<SSP_Relationship__c>)lstSobject, sExternalIdField);
                } when 'SSP_RESOURCEOWNERSHIP__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).insertResourceOwnership((List<SSP_ResourceOwnership__c>)lstSobject);
                } when 'SSP_ATTENDANCE__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertAttendance((List<SSP_Attendance__c>)lstSobject, sExternalIdField, objRequest.applicationID);
                } when 'CONTACT' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertContacts((List<Contact>)lstSobject, sExternalIdField);
                } when 'SSP_ALIENSPONSOR__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertAlienSponsor((List<SSP_AlienSponsor__c>)lstSobject, sExternalIdField);
                } when 'ACCOUNTCONTACTRELATION' {
                    if(objRequest.viewName == SSP_InterfaceConstants.ONBOARD_INDV_AUTHREP) {
                        lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).individualAuthRepACRRecords((List<AccountContactRelation>)lstSobject);
                    } else {
                        lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).upsertACRRecords((List<AccountContactRelation>)lstSobject,objRequest.applicationID);
                    }
                } when 'SSP_NOTIFICATIONS__C' {
                    lstInsertedObject = (new SSP_RSSPDC_IntegrationDMLUtility()).insertNotifications((List<SSP_Notifications__c>)lstSobject, sExternalIdField);
                }
            }
        }
    }
}