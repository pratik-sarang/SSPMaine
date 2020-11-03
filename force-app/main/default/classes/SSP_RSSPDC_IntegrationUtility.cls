/**
 * Class Name    : SSP_RSSPDC_IntegrationUtility 
 * Owner         : DELOITTE
 * Created Date  : 28/11/2019
 * Description   : Class that holds utility services of Reverse SSP-DC
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  11/12/2019  Rajeev Kumar    Initial Version
 */
public without sharing class SSP_RSSPDC_IntegrationUtility {
    // private attributes
    private String sApplicationId;
    private List<RSSP_DC_JSON_Object_Mapping__mdt> lstSequentialMapping;
    
    /**
     * method                                       : Constructor
     * @description                                 : Non parameterized constructor 
     * @author                                      : Rajeev Kumar
     */
    public SSP_RSSPDC_IntegrationUtility() {
        // Default Constructor
    }

    /**
     * method                                       : Constructor
     * @description                                 : parameterized constructor
     * @author                                      : Rajeev Kumar
     * @param sApplicationId                        : application Id of the Application
     * @param lstSequentialMapping                  : List of JSON object mapping records
     */
    public SSP_RSSPDC_IntegrationUtility(String sApplicationId, List<RSSP_DC_JSON_Object_Mapping__mdt> lstSequentialMapping) {
        this.sApplicationId = sApplicationId;
        this.lstSequentialMapping = lstSequentialMapping;
    }
    
    /**
     * method                                       : updateTransactionStatus
     * @description                                 : Create/Update transaction record 
     * @author                                      : Rajeev Kumar
     * @param objWrapper                            : RSSPDC Object Wrapper
     * @param sStatus                               : Status of the transaction record
     */
    public void updateTransactionStatus(SSP_RSSPDCWrapper objWrapper, String sStatus) {
        List<SSP_Transaction__c> lstTransaction = new List<SSP_Transaction__c>();
        Map<String, String> mapviewStatus = new Map<String, String>();
        if(SSP_InterfaceConstants.PENDING == sStatus) {
            updatePendingTranactions(objWrapper.objRequest, objWrapper.objUser, objWrapper.lstAllViews, objWrapper.sFlowType);
        } else if(SSP_InterfaceConstants.FAILED == sStatus) {
            mapviewStatus = processFailedTransactions(objWrapper.lstAllViews, objWrapper.sFlowType);
        } else if(SSP_InterfaceConstants.SUCCESS == sStatus) {
            mapviewStatus.put(objWrapper.lstAllViews[0], sStatus);
        } else if(SSP_InterfaceConstants.RETRY == sStatus) {
            mapviewStatus.put(objWrapper.lstAllViews[0], SSP_InterfaceConstants.PENDING);
        }
        if(!mapviewStatus.isEmpty()) {
            String sContactorUserId;
            String sUniqueId;
            // logic to prepare Unique Id for Notification Information
            if(mapviewStatus.containsKey(SSP_InterfaceConstants.NOTIFICATION_INFORMATION)) {
                List<Contact_Mapping__c> lstConMapping;
                if(String.isNotBlank(objWrapper.objRequest.primaryApplicationIndividualId) &&
                    objWrapper.objUser != null && objWrapper.objUser.ContactId != null && 
                    objWrapper.objRequest.Role == SSP_InterfaceConstants.CITIZEN_ROLE) {
                        sUniqueId = objWrapper.objUser.ContactId + SSP_InterfaceConstants.SEMICOLON + objWrapper.objRequest.Role + SSP_InterfaceConstants.SEMICOLON;
                } else if(String.isNotBlank(objWrapper.objRequest.primaryApplicationIndividualId)) {
                    lstConMapping = [SELECT Id, contact__c from Contact_Mapping__c WHERE IEES_Id__c =:Integer.valueOf(objWrapper.objRequest.primaryApplicationIndividualId)];
                } else if(objWrapper.objUser != null) {
                    sUniqueId = ((objWrapper.objUser.ContactId != null) ? objWrapper.objUser.ContactId : objWrapper.objUser.Id) + SSP_InterfaceConstants.SEMICOLON + objWrapper.objRequest.Role + SSP_InterfaceConstants.SEMICOLON;
                }
                if(lstConMapping != null && !lstConMapping.isEmpty()) {
                    sUniqueId = lstConMapping.get(0).contact__c + SSP_InterfaceConstants.SEMICOLON + SSP_InterfaceConstants.CITIZEN_ROLE + SSP_InterfaceConstants.SEMICOLON;
                }
            }
            if(objWrapper.objUser != null && objWrapper.objUser.ContactId != null) {
                sContactorUserId = objWrapper.objUser.ContactId;
            } else if(objWrapper.objUser != null) {
                sContactorUserId = objWrapper.objUser.Id;
            }
            for(String sview : mapviewStatus.keyset()) {
                SSP_Transaction__c objTransaction = new SSP_Transaction__c();
                objTransaction.IndividualId__c = objWrapper.objRequest.primaryApplicationIndividualId;
                if(sView == SSP_InterfaceConstants.NOTIFICATION_INFORMATION && sUniqueId != null) {
                    objTransaction.Unique_Id__c = sUniqueId + sview;
                } else {
                    objTransaction.Unique_Id__c = ((!String.isBlank(objWrapper.objRequest.primaryApplicationIndividualId)) ? 
                                                    objWrapper.objRequest.primaryApplicationIndividualId : sContactorUserId) +
                                                    SSP_InterfaceConstants.SEMICOLON + sview;
                }
                objTransaction.Log_Message__c = null;
                objTransaction.ApplicationId__c = objWrapper.objRequest.applicationID;
                objTransaction.CaseNumber__c = String.valueof(objWrapper.objRequest.caseNumber);

                objTransaction.Mode__c = objWrapper.objRequest.mode;
                objTransaction.View_Name__c = sView;
                objTransaction.status__c = mapviewStatus.get(sView);
                if(objTransaction.status__c != SSP_InterfaceConstants.CANCELLED) {
                    objTransaction.Log_Message__c = objWrapper.log.logNumber;
                }
                lstTransaction.add(objTransaction);
            }
        }
        // Update Transaction Record
        if(!lstTransaction.isEmpty() && Schema.sObjectType.SSP_Transaction__c.isCreateable() && Schema.sObjectType.SSP_Transaction__c.isUpdateable()) {
            // Use ESAPI
            Database.upsert(lstTransaction, SSP_Transaction__c.Unique_Id__c.getDescribe().getSObjectField(), true);
        }
    }

    /**
     * method                                       : updatePendingTranactions
     * @description                                 : update Pending transactions
     * @author                                      : Rajeev Kumar
     * @param objRequest                            : RSSPDC Request Wrapper
     * @param mapAllViews                           : Map of all v/s qualified views
     */
    public void updatePendingTranactions(SSP_RSSPDC_RequestWrapper objRequest, User objUser, List<String> lstAllViews, String sFlowType) {
        
        String sAllViews = String.join(lstAllViews, SSP_InterfaceConstants.SEMICOLON);

        String strRequestURL = SSP_InterfaceConstants.HELPER_URL + SSP_InterfaceConstants.APPID + SSP_InterfaceConstants.EQUAL + objRequest.applicationID +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.CASE_NUMBER + SSP_InterfaceConstants.EQUAL + objRequest.caseNumber +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.MODE + SSP_InterfaceConstants.EQUAL + objRequest.mode +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.STATUS + SSP_InterfaceConstants.EQUAL + SSP_InterfaceConstants.PENDING +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.PRIMARY_APPID + SSP_InterfaceConstants.EQUAL + objRequest.primaryApplicationIndividualId +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.VIEWS + SSP_InterfaceConstants.EQUAL + sAllViews +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.VIEW_NAME + SSP_InterfaceConstants.EQUAL + objRequest.viewName +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.FLOW_TYPE + SSP_InterfaceConstants.EQUAL + sFlowType +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.USER_ID + SSP_InterfaceConstants.EQUAL + objUser.Id +
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.CONTACT_ID + SSP_InterfaceConstants.EQUAL + objUser.ContactId + 
                                SSP_InterfaceConstants.AMPERSAND + SSP_InterfaceConstants.ROLE_NAME + SSP_InterfaceConstants.EQUAL + objRequest.role;
        if(Test.isRunningTest() == false ) {
            new PageReference(strRequestURL).getContent();
        }
    }

    /**
     * method                                       : processFailedTransactions
     * @description                                 : update Pending transactions
     * @author                                      : Rajeev Kumar
     * @param lstAllViews                           : List of all views
     * @return Map<String, String>                  : Map of views and corresponding status to update
     */
    public Map<String, String> processFailedTransactions(List<String> lstAllViews, String sFlowType) {
        Map<String, String> mapviewStatus = new Map<String, String>();
        for(integer i=0; i< lstAllViews.size(); i++) {
            if(i == 0) {
                mapviewStatus.put(lstAllViews[i], SSP_InterfaceConstants.FAILED);
                // has to change from break to continue to update cancelled transactions
                break;
                //continue;
            }
            mapviewStatus.put(lstAllViews[i], SSP_InterfaceConstants.CANCELLED);
        }
        return mapviewStatus;
    }

    /**
     * method                                           : getFormattedJsonDataMap
     * @description                                     : Method to format the resuts in uppercase
     * @author                                          : Rajeev Kumar
     * @param mapResults                                : Map of object names to list of records
     * @return Map<String, Object>                      : List of Object Mapping Custom metadata records
     */
    public Map<String, Object> getFormattedJsonDataMap(Map<String, Object> mapResults){
        Map<String, Object> mapFormattedResult = new Map<String, Object>();
        if(mapResults != null) {
            for(String sJsonObjectName: mapResults.keySet()) {
                Object objJsonData = mapResults.get(sJsonObjectName);
                mapFormattedResult.put(sJsonObjectName.toUpperCase(), objJsonData);
            }
        }
        return mapFormattedResult;
    }

    /**
     * method                                           : processResponseData
     * @description                                     : Process the response to get map with object name and List of records
     * @author                                          : Rajeev Kumar
     * @param lstJsonData                               : List of JSON record of each object
     * @param objMap                                    : JSon Object Record
     * @param mapobjectList                             : Map of object to List of Records
     * @return Map<String, List<sObject>>               : Map of object to List of SObject
     */
    public Map<String, List<sObject>> processResponseData(List<Object> lstJsonData, RSSP_DC_JSON_Object_Mapping__mdt objMap, Map<String, List<sObject>> mapobjectList) {
        String sObjName = objMap.SF_Object_Name__c;
        String objListType = 'List' + SSP_InterfaceConstants.ANGULAR_OPEN + sObjName + SSP_InterfaceConstants.ANGULAR_CLOSE;
        if(lstJsonData[0] != null) {
            Type t = Type.forName(objListType);
            List<SObject> lstSobject = (List<SObject>)JSON.deserialize(JSON.serialize(lstJsonData), t);
            if(mapobjectList.containsKey(sObjName)) {
                    mapobjectList.get(sObjName).addAll(lstSobject);
                } else {
                    mapobjectList.put(sObjName,lstSobject);
                }
        }
        return mapobjectList;
    }

    /**
     * method                                           : getSequentailObjectList
     * @description                                     : Method to retrive Object & order sequence
     * @author                                          : Rajeev Kumar
     * @param setObjects                                : Set of Objects
     * @return List<RSSP_DC_JSON_Object_Mapping__mdt>   : List of Object Mapping Custom metadata records
     */
    public List<RSSP_DC_JSON_Object_Mapping__mdt> getSequentailObjectList(set<String> setObjects) {
        if(!setObjects.isEmpty() && Schema.sObjectType.RSSP_DC_JSON_Object_Mapping__mdt.fields.Id.isAccessible()) {
            return new List<RSSP_DC_JSON_Object_Mapping__mdt>([SELECT JSON_Object_Name__c,Object_Insertion_Sequence__c,
                                                                SF_Object_Name__c, External_Id__c
                                                                FROM RSSP_DC_JSON_Object_Mapping__mdt
                                                                WHERE SF_Object_Name__c IN :setObjects
                                                                ORDER BY Object_Insertion_Sequence__c]);
        }
        return null;
    }

    /**
     * method                                           : getViewMappingQuery
     * @description                                     : Prepare the query string for the views to execute
     * @author                                          : Rajeev Kumar
     * @param objRequest                                : SSP_RSSPDC_RequestWrapper Wrapper Object
     * @return List<ReverseSSPViewMapping__mdt>         : List of requested view mapping Metadata Records
     */
    public List<ReverseSSPViewMapping__mdt> getRequestedMappingRecords(SSP_RSSPDC_RequestWrapper objRequest) {
        final String OBJECT_QUERY = 'SELECT id, View__c, Screens__c, Is_Intake__c, Is_RAC__c, Intake_Order__c, '+
                                    'RAC_Order__c FROM ReverseSSPViewMapping__mdt WHERE '; 
        final String WHERE_CONDITION_INTAKE = 'Is_Intake__c = true Order by Intake_Order__c ASC';
        final String WHERE_CONDITION_RAC = 'Is_RAC__c = true Order by RAC_Order__c ASC';
        final String WHERE_CONDITION_AHOHC = 'View__c IN :setViews AND ';
        final String VIEW = 'View__c';
        String sQuery = OBJECT_QUERY;
        Set<String> setValidStatus;
        Set<String> setViews = new Set<String>();
        if(objRequest.viewName == SSP_InterfaceConstants.ADHOC_VIEWS) {
            setValidStatus = new Set<String>{SSP_InterfaceConstants.NOT_STARTED};
        } else if(objRequest.viewName == SSP_InterfaceConstants.PENDING_VIEWS) {
            setValidStatus = new Set<String>{SSP_InterfaceConstants.FAILED,SSP_InterfaceConstants.CANCELLED};
        }
        if(setValidStatus != null && Schema.sObjectType.SSP_Transaction__c.fields.Id.isAccessible()) {
            for(SSP_Transaction__c objTran : [SELECT Id, view_Name__c FROM SSP_Transaction__c 
                                                WHERE IndividualId__c= :String.valueOf(objRequest.primaryApplicationIndividualId)
                                                AND Status__c IN :setValidStatus
                                                AND Mode__c= :objRequest.mode]) {
                setViews.add(objTran.view_Name__c);
            }        
        }
        Set<String> setCombinedViews = new Set<String>{SSP_InterfaceConstants.ALL_VIEWS, SSP_InterfaceConstants.PENDING_VIEWS, SSP_InterfaceConstants.ADHOC_VIEWS};
        if(setCombinedViews.contains(objRequest.viewName) && objRequest.viewName != SSP_InterfaceConstants.ALL_VIEWS) {
            sQuery += WHERE_CONDITION_AHOHC;
        }
        if(!setCombinedViews.contains(objRequest.viewName)) {
            sQuery += VIEW + SSP_InterfaceConstants.EQUAL + SSP_InterfaceConstants.SINGLE_QUOTE + objRequest.viewName + 
                        SSP_InterfaceConstants.SINGLE_QUOTE;
        } else if(objRequest.mode == SSP_InterfaceConstants.MODE_INTAKE ) {
            sQuery += WHERE_CONDITION_INTAKE;
        } else {
            sQuery += WHERE_CONDITION_RAC;
        }

        if(Schema.sObjectType.ReverseSSPViewMapping__mdt.fields.Id.isAccessible()) {
            return Database.query(sQuery);
        }
        return null;
    }

    /**
     * method                                           : getRequestedListOfViews
     * @description                                     : Method to get list of Requested view for RSSPDC
     * @author                                          : Rajeev Kumar
     * @param lstViewMapping                            : List of Requested view Mapping custom metadata
     * @param sScreenNames                              : Comma Seperated View Names
     * @param setPendingViews                           : Set of Pending Views to execute
     * @return List<String>                             : List of Requested View
     */
    public List<String> getRequestedListOfViews(List<ReverseSSPViewMapping__mdt> lstViewMapping, String sScreenNames) {
        List<String> setMembers = new List<String>();
        Set<String> setAvailableScreens = new set<String>();
        Set<String> setRequestedScreens;
        List<String> lstAllViews = new List<String>();

        // Converting screen Names to list
        if(!String.isBlank(sScreenNames)) {
            setRequestedScreens = new Set<String>(sScreenNames.split(SSP_InterfaceConstants.SEMICOLON));
        }

        for(ReverseSSPViewMapping__mdt objView : lstViewMapping) {
            if(setRequestedScreens == null) {
                lstAllviews.add(objView.View__c);
                continue;
            }
            setAvailableScreens = new set<String>(objView.Screens__c.split(SSP_InterfaceConstants.NEW_LINE));
            for(String sScreenName : setRequestedScreens) {
                // Comparing if screen passed is available in the set of available screens for the view
                if(setAvailableScreens.contains(sScreenName)) {
                    lstAllviews.add(objView.View__c);
                    break;
                }
            }
        }
        return lstAllviews;
    }

    /**
     * method                                           : getQualifiedMembers
     * @description                                     : Method to get the IndiviudalIds for QualifiedIndiviudal Call
     * @author                                          : Rajeev Kumar
     * @param sviewName                                 : executed view Name
     * @param objMembers                                : Member records from Response
     * @return Map<String, SSP_Member__c>               : Map of IndividualId to Member Record
     */
    public static String setQaulaifiedIndividuals(String sviewName, object objAllObjects) {
        String sIndividualIds='';
        if(sviewName != SSP_InterfaceConstants.QUALIFIED_INDIVIDUAL) {
            return sIndividualIds;
        }

        Map<String,List<sObject>> mapObjects = (Map<String,List<sObject>>) objAllObjects;
        if(mapObjects.containsKey(SSP_InterfaceConstants.SSP_MEMBER)) {
            for(SSP_Member__c objMember : (List<SSP_Member__c>)mapObjects.get(SSP_InterfaceConstants.SSP_MEMBER)) {
                if(String.isBlank(sIndividualIds)) {
                    sIndividualIds = objMember.IndividualId__c;
                }else {
                    sIndividualIds += SSP_InterfaceConstants.SEMICOLON+objMember.IndividualId__c;

                }
            }
        }
        return sIndividualIds;
    }

    /**
     * method                                          : getWrapperResponse
     * @description                                    : Method to deserialize payload to the Wrapper
     * @author                                         : Rajeev Kumar
     * @param objResWrapper                            : RSSPDC Object Wrapper
     * @param mapPayload                               : List of Object in Response payload
     * @return RSSP_DC_Wrapper                         : List of Object
     */
    public RSSP_DC_Wrapper getWrapperResponse(RSSP_DC_Wrapper objResWrapper,  Map<String, Object> mapPayload, String sViewName) {
        if(sViewName == SSP_InterfaceConstants.ELIGIBILITY_SUMMARY) {
            objResWrapper.EligibilitySummaryPayload = (SSP_EligibilitySummaryPayloadWrapper) System.JSON.deserialize(
                                                    JSON.serialize(mapPayload).replaceAll('__c',''),
                                                    SSP_EligibilitySummaryPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.KHIPP_PAYMENT_SUMMARY) {
            objResWrapper.KHIPPPaymentSummaryPayload = (SSP_KHIPPPaymentSummaryWrapper) System.JSON.deserialize(
                                                    JSON.serialize(mapPayload).replaceAll('__c',''),
                                                    SSP_KHIPPPaymentSummaryWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.BENEFIT_INFORMATION) {
            objResWrapper.benefitInformations = (SSP_BenefitInformationPayloadWrapper) System.JSON.deserialize(
                                            JSON.serialize(mapPayload), 
                                            SSP_BenefitInformationPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.MEDICAID_MCO_INFORMATION) {
            objResWrapper.medicaidMCOInformation = (SSP_MedicaidMCOInformationWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_MedicaidMCOInformationWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.DASHBOARD_CASE_INFORMATION) {
            objResWrapper.dashboardCaseInfo = (SSP_DashboardCaseInformation) System.JSON.deserialize(
                                            JSON.serialize(mapPayload), 
                                            SSP_DashboardCaseInformation.class);
        } else if(sViewName == SSP_InterfaceConstants.RAC_SELECTION_DETAILS) {
            objResWrapper.racSelectionWrapper = (SSP_RACSelectionDetailsWrapper) System.JSON.deserialize(
                                            JSON.serialize(mapPayload), 
                                            SSP_RACSelectionDetailsWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.RFI_DETAILS) {
            objResWrapper.RFIInformationPayload = (SSP_RFIInformationPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_RFIInformationPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.DISQUALIFICATION_DETAILS) {
            objResWrapper.DisqualificationPayload = (SSP_DisqualificationPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_DisqualificationPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.PAST_APPLICATIONS) {
            objResWrapper.PastApplicationsPayload = (SSP_PastApplicationsPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_PastApplicationsPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.NON_CITIZEN_CLIENT_INFORMATION) {
            objResWrapper.nonCitizenClientInfoPayload = (SSP_NonCitizenClientInfoPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_NonCitizenClientInfoPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.WAIVER_DETAILS) {
            objResWrapper.waiverDetailsPayload = (SSP_WaiverDetailsPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_WaiverDetailsPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.NON_CITIZEN_SEARCH_CASE) {
            objResWrapper.nonCitizenSearchCasePayload = (NonCitizenSearchCasePayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                NonCitizenSearchCasePayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.CLAIMS_OVERVIEW) {
            objResWrapper.claimsOverviewPayload = (SSP_claimsOverviewPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_claimsOverviewPayloadWrapper.class);
        } else if(sViewName == SSP_InterfaceConstants.ASSISTER_AUTHREP_CLIENT_DETAILS) {
            objResWrapper.assisterAuthRepDetailsPayload = (SSP_AssisterAuthRepDetailsPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_AssisterAuthRepDetailsPayloadWrapper.class); 
        } else if(sViewName == SSP_InterfaceConstants.TAX_FORMS_1095A_INFORMATION) {
            objResWrapper.taxForms1095AInfoPayload = (SSP_TaxForms1095AInfoPayloadWrapper ) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_TaxForms1095AInfoPayloadWrapper.class); 
        } else if(sViewName == SSP_InterfaceConstants.HEARINGS_SUMMARY_INFORMATION) {
            objResWrapper.hearingsSummaryInfoPayload = (SSP_HearingsSummaryInfoPayloadWrapper ) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_HearingsSummaryInfoPayloadWrapper.class); 
        } else if(sViewName == SSP_InterfaceConstants.KIHIPP_PREFERRED_PAYMENT) {
            objResWrapper.KIHIPPPreferredPaymentPayload = (SSP_KIHIPPPreferredPaymentPayloadWrapper ) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_KIHIPPPreferredPaymentPayloadWrapper.class); 
        } else if(sViewName == SSP_InterfaceConstants.NON_CITIZEN_SEARCH_EXPORT) {
            objResWrapper.nonCitizenSearchExportPayload= (SSP_NonCitizenSearchExportPayloadWrapper) System.JSON.deserialize(
                                                JSON.serialize(mapPayload), 
                                                SSP_NonCitizenSearchExportPayloadWrapper.class); 
        } else {
            return objResWrapper;
        }
        objResWrapper.payload = null;
        return objResWrapper;
    }

    /**
     * method                                          : getIndividualIds
     * @description                                    : Method to Individual Ids
     * @author                                         : Rajeev Kumar
     * @param sApplicationId                           : Application Id of the request
     * @param sMemberId                                : Member Id of the request
     * @return String                                  : Comma seprated Individual Ids
     */
    public String getIndividualIds(String sApplicationId) {
        String sIndividualIds='';
        if(Schema.sObjectType.SSP_Application__c.fields.Id.isAccessible()) {
            for(SSP_ApplicationIndividual__c objIndv : [SELECT Id, SSP_Member__r.IndividualId__c from SSP_ApplicationIndividual__c 
                                                        WHERE SSP_Application__c = :sApplicationId]) {
                if(objIndv.SSP_Member__r.IndividualId__c != null) {
                    if(String.isBlank(sIndividualIds)) {
                        sIndividualIds += objIndv.SSP_Member__r.IndividualId__c;
                    } else {
                        sIndividualIds += SSP_InterfaceConstants.SEMICOLON + objIndv.SSP_Member__r.IndividualId__c;
                    }
                }
            }
        }
        return sIndividualIds;
    }

    /**
     * method                                          : getHOHContact
     * @description                                    : Method to get Contact Record of Primary Applicant
     * @author                                         : Rajeev Kumar
     * @param sHOHIndividualId                         : HOH Id of the Primary Applicant
     * @return Contact                                 : Contact Record of Applicant
     */
    public Contact getHOHContact(String sHOHIndividualId) {
        Contact objHOHContact;
        List<Contact> lstContact;
        if(Schema.sObjectType.Contact.fields.Id.isAccessible()) {
            lstContact = [SELECT id, Email, IndividualId__c, Last_RSSPDC_DateTime__c
                                    FROM Contact 
                                    WHERE IndividualId__c=:sHOHIndividualId];
        }
        if(lstContact != null && !lstContact.isEmpty()) {
            objHOHContact = lstContact.get(0);
        }
        return objHOHContact;
    }

    /**
     * method                                       : updateRSSPDCTimeStamp
     * @description                                 : Update timestamp to current time
     * @author                                      : Rajeev Kumar
     * @param objPrimaryContact                     : Primary Contact Record
     * @param sMode                                 : Mode of the Reverse SSPDC
     */
    public void updateRSSPDCTimeStamp(String sHOHId, String sMode) {
        List<Contact> lstContacts = new List<Contact>();
        List<Contact_Mapping__c>  lstConMapping;
        if(Schema.sObjectType.Contact_Mapping__c.fields.Id.isAccessible()) {
            lstConMapping = [SELECT Contact__c from Contact_Mapping__c 
                            WHERE IEES_Id__c=:Integer.ValueOf(sHOHId)];
        }       
        if(lstConMapping != null && !lstConMapping.isEmpty() && Schema.sObjectType.Contact.fields.Id.isAccessible()) {
            lstContacts = [SELECT Id, Last_RSSPDC_DateTime__c, Is_Eligible_For_RSSPDC__c, IsDashboardRefreshNeeded__c 
                                        FROM Contact 
                                        WHERE Id =:lstConMapping[0].Contact__c];
        }
        Contact objPrimaryContact;
        if(!lstContacts.isEmpty()) {
            objPrimaryContact = lstContacts.get(0);
        } else {
            return;
        }
        String sRSSPDCDateTime = objPrimaryContact.Last_RSSPDC_DateTime__c;
        //Set time stamp for Intake(Current Time) & RAC & Renewal (Null)
        if(sMode != SSP_InterfaceConstants.MODE_INTAKE && objPrimaryContact.Last_RSSPDC_DateTime__c != null) {
            objPrimaryContact.Last_RSSPDC_DateTime__c = null;
        } else {
            DateTime dtcurrentDate = DateTime.Now();
            objPrimaryContact.Last_RSSPDC_DateTime__c = string.valueOf(DateTime.newInstance(dtcurrentDate.dateGmt(), dtcurrentDate.timeGmt()));
        }
        // Update Contact 
        objPrimaryContact.IsDashboardRefreshNeeded__c = true;
        if(Schema.sObjectType.Contact.isUpdateable()) {
            (new SSP_RSSPDC_IntegrationDMLUtility()).performDML(new List<Contact> {objPrimaryContact}, 'Update', null);

        }
    }

    /**
     * method                                       : getUserDetails
     * @description                                 : Get current user Details
     * @author                                      : Rajeev Kumar
     * @return User                                 : Logged in user object
     */
    public User getUserDetails() {
        if(Schema.sObjectType.User.isAccessible()) {
            return [SELECT Id, ContactId, SelectedRole__c, profile.Name from User WHERE Id=:UserInfo.getUserId()];
        }
        return null;
    }

    /**
     * method                                       : setUserRole
     * @description                                 : Set User Role in Request parameter
     * @author                                      : Rajeev Kumar
     * @param objRequest                            : Request Wapper object
     * @param objUser                               : Logged in user object
     * @return SSP_RSSPDC_RequestWrapper            : Request Wrapper
     */
    public SSP_RSSPDC_RequestWrapper setUserRole(SSP_RSSPDC_RequestWrapper objRequest, User objUser) {
        Map<String,String> setRolesWithContactIds = new Map<String, String>{SSP_InterfaceConstants.ASSISTER_ROLE => SSP_InterfaceConstants.ASSISTER_ROLE,
                                                                            SSP_InterfaceConstants.INDIVIDUAL_AUTH_REP_ROLE => SSP_InterfaceConstants.INDIVIDUAL_AUTH_REP_ROLE,
                                                                            SSP_InterfaceConstants.ORGANIZATION_AUTH_REP_ROLE => SSP_InterfaceConstants.ORGANIZATION_AUTH_REP_ROLE,
                                                                            SSP_InterfaceConstants.INSURANCE_AGENT_ROLE => SSP_InterfaceConstants.INSURANCE_AGENT_ROLE,
                                                                            SSP_InterfaceConstants.AGENCY_ADMIN => SSP_InterfaceConstants.ASSISTER_ROLE};
        Set<String> setUserIds = new Set<String>();
        Set<String> setOrganizationIds = new Set<String>();
        
        // Set Citizen Role
        objRequest.role = SSP_InterfaceConstants.CITIZEN_ROLE;
        // Set Non Citizen Role 
        if(objUser != null && objUser.profile.Name != SSP_InterfaceConstants.CITIZEN_PROFILE_NAME && objUser.SelectedRole__c != null) {
            objRequest.role = objUser.SelectedRole__c;
        }
        // Set DC Contact Id
        if(objUser != null && objRequest.role != null && setRolesWithContactIds.containsKey(objRequest.role)) {
            for(AccountContactRelation objRel : [SELECT Id, Account.DCDataId__c, DCContactId__c from AccountContactRelation 
                                                    WHERE Account.RecordType.Name = :SSP_InterfaceConstants.ACCOUNT_ORGANIZATION_RECORD_TYPE
                                                    AND ContactId =:objUser.ContactId AND Roles =: setRolesWithContactIds.get(objRequest.role)]) {
                if(objRel.DCContactId__c != null) {
                    setUserIds.add(String.valueOf(objRel.DCContactId__c));
                }
                if(objRel.Account.DCDataId__c != null) {
                    setOrganizationIds.add(String.valueOf(objRel.Account.DCDataId__c));
                }
            }
        }
        // Set User Ids
        if(!setUserIds.isEmpty()) {
            if(objRequest.keyValueParameters == null){
                objRequest.keyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
            }
            objRequest.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('DCUserId',string.join(new List<String>(setUserIds),';')));
        }
        // Set Organization Ids
        if(!setOrganizationIds.isEmpty()) {
            if(objRequest.keyValueParameters == null) {
                objRequest.keyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
            }
            objRequest.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('DCOrganizationId',string.join(new List<String>(setOrganizationIds),';')));
        }
        return objRequest;
    }
}