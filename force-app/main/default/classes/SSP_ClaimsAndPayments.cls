/***************************************************************************************************
*   Type        :   Controller Class
*   Name        :   SSP_ClaimsAndPayments
*   Create By   :   Ajay Saini
*   Create Date :   JUN-30-2020
*   Description :   This class provides methods for claims and payments screen.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini             JUN-30-2020             Initial Version
*
*****************************************************************************************************/
public with sharing class SSP_ClaimsAndPayments {
    @TestVisible
    static List<String> individualIdList = new List<String>();
    static {
        String individualIds = SSP_Utility.getCurrentUserAllIndividualIds();
        if(String.isNotBlank(individualIds)) {
            individualIdList = individualIds.split(';');
        }
    }
    static final String PAID = 'Paid';

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         JUN-30-2020
    * @methodname   getScreenData
    * @description  Method to get all required data for screen.
    * @return       list of records.
    ***************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getScreenData(List<String> individualIds, String cartId, String status) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        Savepoint sp = null;
        try {
            response.bIsSuccess = true;
            response.put('individualIds', individualIdList);
            SSP_Utility.SecurityMatrixWrapper screenPermissions = SSP_Utility.getScreenAccessDetails('SSP_ClaimsAndPayments', null);
            Boolean isNotAccessible = SSP_GlobalConstants.NOT_ACCESSIBLE.equalsIgnoreCase(screenPermissions.screenPermission);
            response.put('isNotAccessible', isNotAccessible);
            if(isNotAccessible) {
                return response;
            }
            Boolean isReadOnly = SSP_GlobalConstants.READ_ONLY.equalsIgnoreCase(screenPermissions.screenPermission);
            Boolean isAllowedToPay = SSP_GlobalConstants.EDITABLE.equalsIgnoreCase(screenPermissions.fieldPermissions.get('CreateCart'));
            response.put('isReadOnly', isReadOnly);
            response.put('isAllowedToPay', isAllowedToPay);
            // SSO Redirect 
            SSP_LightningResponse validateSSORes = SSP_Utility.validateSSORedirect('CLAIMS');
            if(validateSSORes != null && validateSSORes.mapResponse.containsKey('endPoint') && validateSSORes.mapResponse.containskey('encryptedToken')) {
                response.put('endPoint', validateSSORes.mapResponse.get('endPoint'));
                response.put('encryptedToken', validateSSORes.mapResponse.get('encryptedToken'));
                return response;
            }
            String currentSessionId = UserInfo.getSessionId();
            Map<String, Payment_Tracker__c> paymentRecordMap = queryPaymentRecords(individualIds);
            Id currentClaim = null;
            Boolean isDataStale = false;
            for(Payment_Tracker__c record: paymentRecordMap.values()) {
                if(String.isNotBlank(cartId) && cartId == record.CartId__c && String.isBlank((record.Status__c))) {
                    currentClaim = record.Id;
                }
                if(PAID.equalsIgnoreCase(record.Status__c) || currentSessionId != record.SessionId__c) {
                    isDataStale = true;
                }
            }
            List<Payment_Tracker__c> recordsToInsert = new List<Payment_Tracker__c>();
            List<Payment_Tracker__c> recordsToUpdate = new List<Payment_Tracker__c>();
            List<Payment_Tracker__c> recordsToDelete = new List<Payment_Tracker__c>();
            if(isDataStale || paymentRecordMap.isEmpty()) {
                Map<String, Payment_Tracker__c> latestPaymentRecordMap = getClaimRecordsFromRSSPDC();
                for(Payment_Tracker__c record: paymentRecordMap.values()) {
                    if(!latestPaymentRecordMap.containsKey(record.ClaimNumber__c)) {
                        recordsToDelete.add(record);
                        if(record.Id == currentClaim) {
                            currentClaim = null;
                        }
                    }
                }
                for(Payment_Tracker__c newPaymentRecord: latestPaymentRecordMap.values()) {
                    if(paymentRecordMap.containsKey(newPaymentRecord.ClaimNumber__c)) {
                        Payment_Tracker__c record = paymentRecordMap.get(newPaymentRecord.ClaimNumber__c);
                        record.IndividualId__c = newPaymentRecord.IndividualId__c;
                        record.ClaimStatus__c = newPaymentRecord.ClaimStatus__c;
                        record.ProgramCode__c = newPaymentRecord.ProgramCode__c;
                        record.CurrentAmountOwed__c = newPaymentRecord.CurrentAmountOwed__c;
                        record.RepaymentAmount__c = newPaymentRecord.RepaymentAmount__c;
                        record.DueDate__c = newPaymentRecord.DueDate__c;
                        record.SessionId__c = newPaymentRecord.SessionId__c;
                        if(record.Id == currentClaim && String.isEmpty(record.Status__c)) {
                            record.Status__c = status;
                        }
                        recordsToUpdate.add(record);
                    }
                    else {
                        recordsToInsert.add(newPaymentRecord);
                    }
                }
            }
            sp = Database.setSavePoint();
            if(!recordsToDelete.isEmpty()) {
                SSP_SharingByPassFetcher.dmlOnGenericSobjectList(recordsToDelete, 'delete', null);
            }
            if(!recordsToUpdate.isEmpty()) {
                ESAPI.accessController().updateAsUser(new Map<Id, Payment_Tracker__c>(recordsToUpdate), SSP_Utility.getFieldsNamesList(recordsToUpdate));
            }
            else if(String.isNotEmpty(currentClaim)) {
                Map<Id, Payment_Tracker__c> record =  new Map<Id, Payment_Tracker__c>();
                record.put(currentClaim, new Payment_Tracker__c(Id = currentClaim, Status__c = status));
                ESAPI.accessController().updateAsUser(new Map<Id, Payment_Tracker__c>(record), SSP_Utility.getFieldsNamesList(record.values()));
            }
            if(!recordsToInsert.isEmpty()) {
                SSP_GenericDMLHelper.upsertRecords(recordsToInsert, new List<String>{'IndividualId__c', 'ClaimNumber__c', 'ClaimStatus__c', 'ProgramCode__c', 'CurrentAmountOwed__c', 'RepaymentAmount__c', 'DueDate__c', 'SessionId__c'}, 'ClaimNumber__c');
            }
            response.put('isDataStale', isDataStale);
            response.put('currentClaim', currentClaim);
            List<Payment_Tracker__c> records = queryPaymentRecords(individualIds).values();
            for(Payment_Tracker__c record: records) {
                if(record.CartId__c != null && (String.isEmpty(record.Status__c) || record.Status__c == 'success')) {
                    record.ClaimStatus__c = 'PP';
                }
            }
            response.put('records', records);
        }
        catch(Exception e) {
            if(sp != null) {
                Database.rollback(sp);
            }
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ClaimsAndPayments', 'getScreenData', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    @AuraEnabled
    public static SSP_LightningResponse getIndividualsIds() {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            response.bIsSuccess = true;
            response.put('individuals', individualIdList);
            Map<String, Object> dashboardCalloutResponseMap = SSP_DashboardController.triggerDashboardServiceCallOut(null).mapResponse;
            response.put('dashboard', dashboardCalloutResponseMap);
            Boolean isHOH = Boolean.valueOf(dashboardCalloutResponseMap.get('isHeadOfHouseHold'));
            if(isHOH) {
                String caseVsHOHMapString = (String)dashboardCalloutResponseMap.get('caseVsHOH');
                String caseVsIndividualMapString = (String)dashboardCalloutResponseMap.get('caseVsIndividuals');
                Map<String, Object> caseHOHMap = (Map<String, Object>)JSON.deserializeUntyped(caseVsHOHMapString);
                Map<String, Object> caseIndividualsMap = (Map<String, Object>)JSON.deserializeUntyped(caseVsIndividualMapString);
                List<String> cases = new List<String>();
                List<String> individuals = new List<String>();
                for(String caseNumber: caseHOHMap.keySet()) {
                    if(Boolean.valueOf(caseHOHMap.get(caseNumber)) == true &&
                        caseIndividualsMap.get(caseNumber) != null) {
                        List<Object> caseIndividuals = (List<Object>)caseIndividualsMap.get(caseNumber);
                        for(Object individual: caseIndividuals) {
                            individuals.add(String.valueOf(individual));
                        }
                    }
                }
                response.put('individuals', individuals);
            }
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ClaimsAndPayments', 'getIndividualsIds', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    private static Map<String, Payment_Tracker__c> queryPaymentRecords(List<String> individualIds) {
        String individualIdListString = String.join(individualIds == null? individualIdList : individualIds, ',');
        Set<String> fieldList = new Set<String>{'Id', 'IndividualId__c', 'ClaimNumber__c', 'DueDate__c', 'ClaimStatus__c', 'ProgramCode__c', 'CurrentAmountOwed__c', 'RepaymentAmount__c', 'SessionId__c', 'CartId__c', 'Status__c'};
        Map<String, String> conditionsMap = new Map<String, String>{'IndividualId__c' => individualIdListString};
        Map<String, String> detailMap = new Map<String, String>{'objectName' => 'Payment_Tracker__c', 'IN' => 'IndividualId__c'};
        List<Payment_Tracker__c> paymentRecords = (List<Payment_Tracker__c>)SSP_Utility.fetchRecords(detailMap, fieldList, conditionsMap);
        Map<String, Payment_Tracker__c> recordsToReturn = new Map<String, Payment_Tracker__c>();
        if(paymentRecords != null) {
            for(Payment_Tracker__c record: paymentRecords) {
                recordsToReturn.put(record.ClaimNumber__c, record);
            }
        }
        return recordsToReturn;
    }

    private static Map<String, Payment_Tracker__c> getClaimRecordsFromRSSPDC() {
        Map<String, Payment_Tracker__c> paymentRecordsToReturn = new Map<String, Payment_Tracker__c>();
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.CLAIMS_OVERVIEW;
        reqWrapper.primaryApplicationIndividualId = String.join(individualIdList, ';');
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, reqWrapper);
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
        if(objList == null || objList.isEmpty()) {
            throw new AuraHandledException('RSSPDC error');
        }
        RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
        String currentSessionId = UserInfo.getSessionId();
        if(responseWrapper.claimsOverviewPayload != null && responseWrapper.claimsOverviewPayload.ClaimsOverview != null) {
            for(SSP_ClaimsOverviewPayloadWrapper.ClaimsOverviewWrapper claimWrapper: responseWrapper.claimsOverviewPayload.ClaimsOverview) {
                Payment_Tracker__c newPaymentRecord = new Payment_Tracker__c();
                newPaymentRecord.IndividualId__c = claimWrapper.IndividualId;
                newPaymentRecord.ClaimNumber__c = claimWrapper.ClaimNumber;
                newPaymentRecord.ClaimStatus__c = claimWrapper.ClaimStatus;
                newPaymentRecord.ProgramCode__c = claimWrapper.ProgramCode;
                newPaymentRecord.CurrentAmountOwed__c = Decimal.valueOf(claimWrapper.CurrentAmountOwed);
                if(claimWrapper.RepaymentAmount != null) {
                    newPaymentRecord.RepaymentAmount__c = Decimal.valueOf(claimWrapper.RepaymentAmount);
                }
                if(claimWrapper.DueDate != null) {
                    newPaymentRecord.DueDate__c = Date.valueOf(claimWrapper.DueDate);
                }
                newPaymentRecord.SessionId__c = currentSessionId;
                paymentRecordsToReturn.put(newPaymentRecord.ClaimNumber__c, newPaymentRecord);
            }
        }
        return paymentRecordsToReturn;
    }

    @AuraEnabled
    public static SSP_LightningResponse getPaymentURL(String claimNumber, String amount, String redirectUrl) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            SSP_ClaimPaymentURLRequestWrapper requestWrapper = new SSP_ClaimPaymentURLRequestWrapper();
            requestWrapper.PaymentSuccessRedirectURI = redirectUrl + '?status=success';
            requestWrapper.PaymentErrorRedirectURI = redirectUrl + '?status=error';
            requestWrapper.PaymentCancelRedirectURI = redirectUrl + '?status=cancelled';
            requestWrapper.AcceptedPaymentType = 'CreditCard';
            requestWrapper.CartItems = new SSP_ClaimPaymentURLRequestWrapper.cls_CartItems();
            SSP_ClaimPaymentURLRequestWrapper.cls_CartItem cartItem = new SSP_ClaimPaymentURLRequestWrapper.cls_CartItem();
            cartItem.Description = String.format('Description_{0}', new List<String>{ claimNumber });
            cartItem.DisplayOrder = '1';
            cartItem.Quantity = '1';
            cartItem.PAFFree = 'false';
            cartItem.SmartCode = 'BENEFIND';
            cartItem.Subtotal = amount;
            cartItem.Amount = amount;
            cartItem.LocalReferenceId = claimNumber;
            requestWrapper.CartItems.CartItem = new List<SSP_ClaimPaymentURLRequestWrapper.cls_CartItem>{ cartItem };
            Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY => JSON.serialize(requestWrapper)};
            List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPGETURL_METADATANAME, objResponse);
            if(lstData == null || lstData.isEmpty()) {
                throw new AuraHandledException('RSSPDC error');
            }
            Map<String, Object> payloadMap = (Map<String, Object>)JSON.deserializeUntyped(((HttpResponse)lstData.get(0)).getBody());
            Map<String, Object> getPaymentURLResponse = (Map<String, Object>)payloadMap.get('GetPaymentURLResponse');
            response.put('data', getPaymentURLResponse);
            if(getPaymentURLResponse.get('Errorcode') != null) {
                throw new AuraHandledException('Something went wrong!!');
            }
            Set<String> fieldList = new Set<String>{'Id'};
            Map<String, String> conditionsMap = new Map<String, String>{'ClaimNumber__c' => claimNumber};
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'Payment_Tracker__c'};
            List<Payment_Tracker__c> paymentRecords = (List<Payment_Tracker__c>)SSP_Utility.fetchRecords(detailMap, fieldList, conditionsMap);
            if(paymentRecords != null && !paymentRecords.isEmpty()) {
                Payment_Tracker__c paymentRecord = paymentRecords.get(0);
                paymentRecord.CartId__c = (String)getPaymentURLResponse.get('CartId');
                paymentRecord.Status__c = null;
                response.put('recordId', paymentRecord.Id);
                // update paymentRecord;
                ESAPI.accessController().updateAsUser(paymentRecord, SSP_Utility.getFieldsNamesList(new List<SObject>{paymentRecord}));
            }
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ClaimsAndPayments', 'getPaymentURL', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    @AuraEnabled
    public static SSP_LightningResponse getPaymentStatus(String claimNumber, Boolean makeExplicitCall) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            response.bIsSuccess = true;
            Set<String> fieldList = new Set<String>{'Id', 'CartId__c', 'LastModifiedDate', 'Status__c'};
            Map<String, String> conditionsMap = new Map<String, String>{'ClaimNumber__c' => claimNumber};
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'Payment_Tracker__c'};
            List<Payment_Tracker__c> paymentRecords = (List<Payment_Tracker__c>)SSP_Utility.fetchRecords(detailMap, fieldList, conditionsMap);
            if(paymentRecords == null || paymentRecords.isEmpty()) {
                response.bIsSuccess = false;
                return response;
            }
            response.put('recordId', paymentRecords.get(0).Id);
            if(makeExplicitCall != true) {
                String status = paymentRecords.get(0).Status__c;
                if(status == null || status != 'success') {
                    response.put('status', status);
                }
                return response;
            }
            
            Map<String, String> bodyMap = new Map<String, String>{
                'CartId' => paymentRecords.get(0).CartId__c,
                'SourceSystem' => 'SSP'
            };
            Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY => JSON.serialize(bodyMap)};
            List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPGETSTATUS_METADATANAME, objResponse);
            HttpResponse responseRecieved = (HttpResponse)lstData.get(0);
            response.put('httpStatusCode', responseRecieved.getStatusCode());
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseRecieved.getBody());
            Map<String, Object> statusMap = (Map<String, Object>)responseMap.get('NotifyPaymentResponse');
            String status = (String)statusMap.get('RequestStatus');
            Payment_Tracker__c paymentRecord = paymentRecords.get(0);
            paymentRecord.Status__c = status;
            response.put('rawResponse', statusMap);
            response.put('status', status);
            ESAPI.accessController().updateAsUser(paymentRecord, SSP_Utility.getFieldsNamesList(new List<SObject>{paymentRecord}));
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ClaimsAndPayments', 'getPaymentStatus', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
}