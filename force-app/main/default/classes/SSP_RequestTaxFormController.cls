/***************************************************************************************************
*   Type        :   Controller Class
*   Name        :   SSP_RequestTaxFormController
*   Create By   :   Ajay Saini
*   Create Date :   JUN-29-2020
*   Description :   This class provides methods for request tax form screen.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini             JUN-29-2020             Initial Version
* 
*****************************************************************************************************/
public with sharing class SSP_RequestTaxFormController {
    static List<String> individualIdList = new List<String>();
    static {
        String individualIds = SSP_Utility.getCurrentUserAllIndividualIds();
        if(String.isNotBlank(individualIds)) {
            individualIdList = individualIds.split(';');
        }
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         JUL-10-2020
    * @methodname   getScreenData
    * @description  Method make RSSPDC callout to get screen data.
    * @return       list of records.
    ***************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getScreenData(String caseNumber) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            response.bIsSuccess = true;
            SSP_Utility.SecurityMatrixWrapper screenPermissions = SSP_Utility.getScreenAccessDetails('SSP_RequestTaxForms', null);
            Boolean isNotAccessible = SSP_GlobalConstants.NOT_ACCESSIBLE.equalsIgnoreCase(screenPermissions.screenPermission);
            response.put('isNotAccessible', isNotAccessible);
            if(isNotAccessible) {
                return response;
            }
            Boolean is1095AAccessible = SSP_GlobalConstants.EDITABLE.equals(screenPermissions.fieldPermissions.get('Toggle_1095A'));
            Boolean is1095BAccessible = SSP_GlobalConstants.READ_ONLY.equals(screenPermissions.fieldPermissions.get('Toggle_1095B'));
            response.put('is1095AAccessible', is1095AAccessible);
            response.put('is1095BAccessible', is1095BAccessible);
            if(is1095BAccessible) {
                response.put('portal1095BToken', getPortal1095BToken());
                response.put('portal1095BEndpoint', SSPIntegrationEndpoints__c.getInstance('1095B Portal').URL__c);
            }
            if(!is1095AAccessible) {
                return response;
            }
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.TAX_FORMS_1095A_INFORMATION;
            reqWrapper.primaryApplicationIndividualId = String.join(individualIdList, ';');
            mapParams.put(SSP_InterfaceConstants.JSON_BODY, reqWrapper);
            List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            if(objList == null || objList.isEmpty()) {
                throw new AuraHandledException('Something Went Wrong!!');
            }
            RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
            if(responseWrapper.ACKRESPONSE != null && responseWrapper.ACKRESPONSE.AckResponseCode != null) {
                throw new AuraHandledException('Something Went Wrong!!');
            }
            response.put('individuals', individualIdList);
            response.put('validationConfig', GenericValidationController.getMetadataList(new List<String>{'Email__c,SSP_Member__c'}, 'SSP_RequestTaxForms'));
            response.put('response', JSON.deserializeUntyped(JSON.serialize(responseWrapper)));
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_RequestTaxFormController', 'getScreenData', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    @AuraEnabled
    public static SSP_LightningResponse fireMyInfoCallout( String individualId) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            Map<String, Object> mapParams = new Map<String, Object>{SSP_InterfaceConstants.IndividualId => individualId};
            List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.UPDATE_CONTACT_INFO, mapParams);
            if(objList == null || objList.isEmpty()) {
                throw new AuraHandledException('Something Went Wrong!!');
            }
            SSP_ContactInfoUpdateResponseWrapper resp = (SSP_ContactInfoUpdateResponseWrapper)  objList.get(0);
            response.put('myInfoResponse', (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resp)));
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_RequestTaxFormController', 'fireMyInfoCallout', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    @AuraEnabled
    public static SSP_LightningResponse taxFormCorrespondenceService(String enrollmentId, String year) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            response.bIsSuccess = true;
            String currentUserName = UserInfo.getUserName();
            String individualId = SSP_Utility.getIndividualId();
            if(String.isNotBlank(individualId)) {
                List<User> users = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                            new Set<String>{'Id', 'ContactId', 'Contact.IndividualId__c', 'Username'}, 
                                                            new Map<String, String>{'limit' => '1', 'Contact.IndividualId__c' => individualId});
                if(!users.isEmpty()) {
                    currentUserName = users.get(0).UserName;
                }
            }
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_TaxFormsCorrespondenceReqWrapper objRequest = new SSP_TaxFormsCorrespondenceReqWrapper();            
            objRequest.TaxFormsCorrespondenceRequestParameters = new SSP_TaxFormsCorrespondenceReqWrapper.TaxFormsCorrespondenceRequestParametersWrapper();
            objRequest.TaxFormsCorrespondenceRequestParameters.EnrollmentId = enrollmentId;
            objRequest.TaxFormsCorrespondenceRequestParameters.ApplicableYear = year;
            objRequest.TaxFormsCorrespondenceRequestParameters.SourceApplication = 'SSP';
            objRequest.TaxFormsCorrespondenceRequestParameters.UserInfo = currentUserName;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(objRequest));
            List<Object> lstResponse = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.TAX_FORMS_CORRESPONDENCE, mapParams);
            if(lstResponse == null || lstResponse.isEmpty()) {
                throw new AuraHandledException('Something Went Wrong!!');
            }
            SSP_TaxFormsCorrespondenceResWrapper taxResponseWrapper = (SSP_TaxFormsCorrespondenceResWrapper)lstResponse[0];
            if(taxResponseWrapper.AckResponse != null && taxResponseWrapper.AckResponse.AckResponseCode != null) {
                throw new AuraHandledException('Something Went Wrong!!');
            }
            response.put('response', JSON.deserializeUntyped(JSON.serialize((SSP_TaxFormsCorrespondenceResWrapper)lstResponse[0])));
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_RequestTaxFormController', 'taxFormCorrespondenceService', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    public static String getPortal1095BToken() {
        String currentUserName = UserInfo.getUserName();
        String individualId = SSP_Utility.getIndividualId();
        if(String.isNotBlank(individualId)) {
            List<User> users = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName' => 'User', 'operator' => 'AND'}, 
                                                        new Set<String>{'UPNId__c'}, 
                                                        new Map<String, String>{'limit' => '1', 'Contact.IndividualId__c' => individualId});
            if(!users.isEmpty()) {
                currentUserName = users.get(0).UPNId__c;
            }
        }
        Portal_1095B_Request reqDetail = new Portal_1095B_Request(currentUserName);
        Blob dataBlob = Blob.valueOf(JSON.serialize(reqDetail));
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', Blob.valueof(Label.SSP_PORTAL_1095B_KEY), dataBlob); 
        return EncodingUtil.base64Encode(encryptedData); 
    }

    public class Portal_1095B_Request {
        public String SourceSystem;
        public Integer CaseNumber;
        public String RequestUserId;

        public Portal_1095B_Request(String currentUserName) {
            RequestUserId = currentUserName;
            CaseNumber = 0;
            SourceSystem = 'SSP';
        }
    }
}
