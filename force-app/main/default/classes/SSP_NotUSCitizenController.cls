/***************************************************************************************************************************
*   Type        :   Controller Class
*   Name        :   SSP_NotUSCitizenController
*   Create By   :   Shivam Tiwari
*   Create Date :   JAN-24-2020
*   Description :   This class is the controller class for Not US Citizen screen.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                    Description
*   --------------------------------------------------------------------------------------
*    Shivam Tiwari             JAN-24-2020             Initial Version
*
*****************************************************************************************************************************/
public with sharing class SSP_NotUSCitizenController {
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         JAN-24-2020
    * @methodname   prepareRequest
    * @description  This method is used to prepare request wrapper and make callout to VLP Service.
    * @param        String, String
    * @return       void
    ********************************************************************************************/
    @AuraEnabled
    public static void prepareRequest(String jsonMemberData, String applicationId, String sMemberId){
        SSP_Utility.isAuthenticatedUser();
        Map<String,Object> MapResponse = new Map<String,Object>();
        SSP_Member__c objMember;
        List<String> lstMemberFields = new List<String>{'Id', 'IndividualId__c','FirstName__c','LastName__c','MiddleInitial__c','SuffixCode__c','BirthDate__c'};
        try{
            if(!String.isBlank(jsonMemberData) && !String.isBlank(applicationId)){
                Id caseRecordTypeId = Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
                List<String> listFields = new List<String>{'Id', 'RecordtypeId', 'Name'};
                SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, listFields);
                if(sMemberId != NULL && String.isNotBlank(sMemberId)){
                    objMember = SSP_MemberSelector.queryMemberDataById(sMemberId, lstMemberFields);
                }
                if(objMember != NULL && objMember.IndividualId__c != NULL){
                    MapResponse = SSP_NotUSCitizenService.prepareRequest(jsonMemberData, application.Name,objMember);
                }
                SSP_VLPRequestWrapper RequestData = (SSP_VLPRequestWrapper)MapResponse.get('vlpRequestData');
                Map<String, Object> objRequest = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(RequestData)};
                
                if(application.RecordTypeId == caseRecordTypeId){
                    objRequest.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER, application.Name);
                    objRequest.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID, null);
                }
                else{
                    objRequest.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID, application.Name);
                    objRequest.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER, null);
                }
                      
                List<Object> resObj = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPVLP_METADATANAME, objRequest);
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NotUSCitizenController', 'prepareRequest', ex.getMessage() , true);
        }
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         JAN-24-2020
    * @methodname   getProgramsApplied
    * @description  This method is used to get the list of programs applied by individual.
    * @param        String, String
    * @return       //SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getProgramsApplied(string memberId, string applicationId) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            String programsApplied = '';
            if(!String.isBlank(memberId) && !String.isBlank(applicationId)){
                Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap = new Map<Id, SSP_ApplicationIndividual__c> ();
                List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c', 'ProgramsApplied__c', 'MedicaidType__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId),'SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
                
                if(!sspApplicationIndividualList.isEmpty()){
                    for(SSP_ApplicationIndividual__c ind : sspApplicationIndividualList){
                        sspApplicationIndividualMap.put(ind.SSP_Member__c, ind);
                    }
                    programsApplied = sspApplicationIndividualMap.get(memberId).ProgramsApplied__c;
                    toSend.bIsSuccess = true;
                    toSend.put('programsApplied', programsApplied);
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NotUSCitizenController', 'getProgramsApplied', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    /********************************************************************************************
    * @author           Rijia 
    * @date             Sep-17-2020
    * @description      This is to handle alien sposnor deleteion
    ********************************************************************************************/
     @AuraEnabled
    public static void handleAlienSponsor(String applicationId, String memberId){
        try{
            SSP_Member__c objMember = [Select id,HasAlienSponsorToggle__c,IsUSCitizenToggle__c,InternalAlienSponsor__c,
            InternalAlienSponsor__r.IndividualId__c,DCInternalAlienSponsorId__c,DCAlienSponsorRelationship__c,
            ExternalAlienSponsor__c,ExternalAlienSponsor__r.DCAlienSponsorId__c from SSP_Member__c where id =: memberId];
            if(objMember.HasAlienSponsorToggle__c.equals('N') || objMember.IsUSCitizenToggle__c.equals('Y')) {
                if (objMember.InternalAlienSponsor__c != null) {
                    //Create track deletion 
                    if(objMember.DCInternalAlienSponsorId__c != null) {
                        List<SSP_TrackDeletion__c> lstExistingRecordCheck = [Select id from SSP_TrackDeletion__c
                        where DCId__c=:objMember.DCInternalAlienSponsorId__c AND SSP_Application__c=:applicationId 
                        And SFObject__c=:'SSP_Member__c' limit 1];
                        if(lstExistingRecordCheck.isEmpty()) {
                            SSP_TrackDeletion__c objTrack = new SSP_TrackDeletion__c();
                            objTrack.Source__c = 'AlienSponsor';
                            objTrack.DCId__c =objMember.DCInternalAlienSponsorId__c;//DCIndividualAlienSponsorId
                            objTrack.SSP_Application__c = applicationId;
                            objTrack.SFObject__c = 'SSP_Member__c';
                            objTrack.SalesforceId__c  = objMember.id; //SponsoredIndividuals.IndividualId
                            objTrack.OtherReason__c = String.ValueOf(objMember.InternalAlienSponsor__r.IndividualId__c); // SponsorID
                            objTrack.EndReason__c = String.ValueOf(objMember.DCAlienSponsorRelationship__c); // DCIndividualAlienSponsorRelationshipId
                            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objTrack}, 'insert', 'SSP_TrackDeletion__c');
                            objMember.InternalAlienSponsor__c = null;
                            objMember.DCAlienSponsorRelationship__c = null;
                            objMember.DCInternalAlienSponsorId__c = null;
                        } 
                    } else {
                        //Clear out member fields 
                        objMember.InternalAlienSponsor__c = null;
                        objMember.AlienNumber__c = null;
                        objMember.AlienTypeCode__c = null;
                        objMember.DCAlienSponsorRelationship__c = null; // if DCAlienSponsorId__c is null then DCAlienSponsorRelationship__c will be blank too
                        //objMember.SponsoredByOrganization__c = null // this is for extenal sponsor
                    }
    
                }
                if (objMember.ExternalAlienSponsor__c != null) {
                    //Create track deletion 
                    if(objMember.ExternalAlienSponsor__r.DCAlienSponsorId__c != null) {
                        List<SSP_TrackDeletion__c> lstExistingRecordCheck = [Select id from SSP_TrackDeletion__c
                        where DCId__c=:objMember.ExternalAlienSponsor__r.DCAlienSponsorId__c AND SSP_Application__c=:applicationId 
                        And SFObject__c=:'SSP_Member__c' limit 1];
                        if(lstExistingRecordCheck.isEmpty()) {
                            SSP_TrackDeletion__c objTrack = new SSP_TrackDeletion__c();
                            objTrack.Source__c = 'AlienSponsor';
                            objTrack.DCId__c = objMember.ExternalAlienSponsor__r.DCAlienSponsorId__c;//DCIndividualAlienSponsorId
                            objTrack.SSP_Application__c = applicationId;
                            objTrack.SFObject__c = 'SSP_Member__c';
                            objTrack.SalesforceId__c  = objMember.id;//SponsoredIndividuals.IndividualId
                            objTrack.EndReason__c = String.ValueOf(objMember.DCAlienSponsorRelationship__c);// DCIndividualAlienSponsorRelationshipId
                            List<sObject> lstRetData = SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objTrack}, 'insert', 'SSP_TrackDeletion__c');
                            objMember.ExternalAlienSponsor__c = null;
                            objMember.DCAlienSponsorRelationship__c = null;
                            objMember.DCInternalAlienSponsorId__c = null;
                        }
                   } else {
                        //Clear out member fields(if any) and delete alien sposor record
                        objMember.AlienNumber__c = null;
                        objMember.AlienTypeCode__c = null;
                        objMember.DCAlienSponsorRelationship__c = null; // if DCAlienSponsorId__c is null then DCAlienSponsorRelationship__c will be blank too
                        objMember.SponsoredByOrganization__c = null ;
                        List<SSP_AlienSponsor__c> lstAlienSponsor = [Select id from SSP_AlienSponsor__c where id =:objMember.ExternalAlienSponsor__c];
                       if(!lstAlienSponsor.isEmpty()) {
                            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstAlienSponsor, 'delete', 'SSP_AlienSponsor__c');
                        }
                    }
                }
            } 
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objMember}, 'update', 'SSP_Member__c');
        }catch(Exception e) {

        }
    }
    
    /********************************************************************************************
    * @author           Shivam Tiwari
    * @date             JAN-24-2020
    * @SubclassName     memberDataWrapper
    * @description      This is a wrapper subclass for SSP_NotUSCitizenController.
    ********************************************************************************************/
    public class memberDataWrapper {
        @AuraEnabled public String memberFirstName;
        @AuraEnabled public String memberLastName;
        @AuraEnabled public String servedInUSMilitary;
        @AuraEnabled public Date immigrationDateOfBirth;
        @AuraEnabled public String immigrationSuffix;
        @AuraEnabled public String immigrationFirstName;
        @AuraEnabled public String immigrationMiddleName;
        @AuraEnabled public String immigrationLastName;
        @AuraEnabled public String hasLegalImmigrationStatus;
        @AuraEnabled public Boolean immigrationDetailsMatch;
        @AuraEnabled public String passportNumber;
        @AuraEnabled public String naturalizationNumber;
        @AuraEnabled public String i94Number;
        @AuraEnabled public String documentDescription;
        @AuraEnabled public Date documentExpiryDate;
        @AuraEnabled public String issuanceCountryCode;
        @AuraEnabled public String citizenshipNumber;
        @AuraEnabled public String hasLivedInUS;
        @AuraEnabled public String alienTypeCode;
        @AuraEnabled public String immigrationDocumentTypeCode; //Parent field
        @AuraEnabled public String SEVISId;
        @AuraEnabled public String receiptNumber;
        @AuraEnabled public String alienNumber;
        @AuraEnabled public String hasAlienSponsor;
    }

}