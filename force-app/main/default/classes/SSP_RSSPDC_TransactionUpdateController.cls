/**
 * Class Name                                       : SSP_RSSPDC_TransactionUpdateController
 * Owner                                            : DELOITTE
 * Created Date                                     : 29/01/2020
 * Description                                      : This class create transaction record by retrieving data from page URL
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  29/01/2020  Rajeev Kumar    Initial Version
 */
public without sharing class SSP_RSSPDC_TransactionUpdateController {

    /**
     * method                                       : insertTransactionRecord
     * @description                                 : extracts the GET parameters with the request values and creates the transaction record
     * @author                                      : Rajeev Kumar
     */
    public void insertTransactionRecord() {
        // Read URL Parameters
        String sAppID = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.APPID).escapeHtml4();
        String sCaseNumber = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.CASE_NUMBER).escapeHtml4();
        String status = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.STATUS).escapeHtml4();
        String sMode = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.MODE).escapeHtml4();
        String sPrimaryAppIndId = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.PRIMARY_APPID).escapeHtml4();
        String sViews = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.VIEWS).escapeHtml4();
        String sViewName = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.VIEW_NAME).escapeHtml4();
        String sFlowType = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.FLOW_TYPE).escapeHtml4();
        String sRole = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.ROLE_NAME).escapeHtml4();
        String sUserId = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.USER_ID).escapeHtml4();
        String sContactId = ApexPages.currentPage().getParameters().get(SSP_InterfaceConstants.CONTACT_ID).escapeHtml4();

        
        Set<String> setRequestedViews = new Set<String>(sViews.split(SSP_InterfaceConstants.SEMICOLON));
        Set<String> setAllViews = new Set<String>();
        List<SSP_Transaction__c> lstTransaction = new List<SSP_Transaction__c>();
        String sUniqueId;
        // Set the unique Id
        if(sViewName == SSP_InterfaceConstants.NOTIFICATION_INFORMATION) {
            List<Contact_Mapping__c> lstConMapping;
            if(String.isNotBlank(sPrimaryAppIndId) && String.isNotBlank(sContactId) && sRole == SSP_InterfaceConstants.CITIZEN_ROLE) {
                sUniqueId = sContactId + SSP_InterfaceConstants.SEMICOLON + SSP_InterfaceConstants.CITIZEN_ROLE + SSP_InterfaceConstants.SEMICOLON;
            } else if(String.isNotBlank(sPrimaryAppIndId)) {
                lstConMapping = [SELECT Id, contact__c from Contact_Mapping__c WHERE IEES_Id__c =:Integer.valueOf(sPrimaryAppIndId)];
            } else {
                sUniqueId = (sContactId != null ? sContactId : sUserId) + SSP_InterfaceConstants.SEMICOLON + sRole + SSP_InterfaceConstants.SEMICOLON;
            }
            if(lstConMapping != null && !lstConMapping.isEmpty()) {
                sUniqueId = lstConMapping.get(0).contact__c + SSP_InterfaceConstants.SEMICOLON + SSP_InterfaceConstants.CITIZEN_ROLE + SSP_InterfaceConstants.SEMICOLON;
            }
        } else {
            sUniqueId = sPrimaryAppIndId + SSP_InterfaceConstants.SEMICOLON;
        }
        if(sViewName == SSP_InterfaceConstants.ALL_VIEWS && sMode == SSP_InterfaceConstants.MODE_RAC) {
            if(Schema.sObjectType.ReverseSSPViewMapping__mdt.fields.Id.isAccessible()) {
                for(ReverseSSPViewMapping__mdt objMapping : [SELECT Id, View__c from ReverseSSPViewMapping__mdt WHERE is_RAC__c = true]) {
                    setAllViews.add(objMapping.view__c);
                }
            }
        } else {
            setAllViews.addAll(setRequestedViews);
        }

        for(String sView : setAllViews) {
            if(setRequestedViews.contains(sView)) {
                lstTransaction.add(new SSP_Transaction__c(ApplicationId__c= sAppID, 
                                                            CaseNumber__c = sCaseNumber,
                                                            Mode__c= sMode,
                                                            View_Name__c = sView,
                                                            IndividualId__c = sPrimaryAppIndId,
                                                            Log_Message__c = null,
                                                            Status__c = status,
                                                            Unique_Id__c = sUniqueId+sView
                                                            ));
                continue;
            }
                lstTransaction.add(new SSP_Transaction__c(ApplicationId__c= sAppID, 
                                                            CaseNumber__c = sCaseNumber,
                                                            Mode__c= sMode,
                                                            View_Name__c = sView,
                                                            IndividualId__c = sPrimaryAppIndId,
                                                            Log_Message__c = null,
                                                            Status__c = SSP_InterfaceConstants.NOT_STARTED,
                                                            Unique_Id__c = sUniqueId+sView
                                                            ));
        }

        // Update Transaction Records
        if(lstTransaction != null && !lstTransaction.IsEmpty() && Schema.sObjectType.SSP_Transaction__c.isUpdateable()) {
            (new SSP_RSSPDC_IntegrationDMLUtility()).performDML(lstTransaction, 'Upsert', SSP_Transaction__c.Unique_Id__c.getDescribe().getSObjectField());
        }
    }
}