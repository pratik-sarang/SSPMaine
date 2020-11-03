/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_HearingSummaryController
*   Created By   :   Sanchita Tibrewala and Chandra Shekhar
*   Created Date :   06/30/2020
*   Description  :   Controller for Hearings Section
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 06/30/2020     Initial Version
*     Narapa                   09/18/2020     DEFECT 389943
*     Narapa                   09/19/2020     Fetching Uploaded Document Mapping Id , to facilitate
                                              Document Processing Message to End User
*****************************************************************************************************************************/
public without sharing class SSP_HearingSummaryController {
    /********************************************************************************************
* @author       Sanchita Tibrewala
* @date         06/30/2020
* @methodname   getHearingSummary
* @description  This method is used to get Hearing Summary details from Interface
* @param        String
* @return       SSP_LightningResponse
********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getHearingSummary(String individualId){
        SSP_LightningResponse toSend = new SSP_LightningResponse(); 
        try{
            List<HearingSummaryWrapper> hearingSummaryList = new List<HearingSummaryWrapper>();
            Map<String,String> hearingProgramMap = new Map<String,String>();
            Map<String,String> hearingReasonMap = new Map<String,String>();
            Map<String,String> hearingAccommodationMap = new Map<String,String>();
            individualId = (individualId == null) ? SSP_Utility.getIndividualId() : individualId;         
            //Issue 1 - Defect 389993
            hearingProgramMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramsOne);
            hearingProgramMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramsTwo) );
            hearingProgramMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramsThree) );  
            hearingReasonMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingReasons);          
            //individualId ='919218728';
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.HEARINGS_SUMMARY_INFORMATION;
            reqWrapper.primaryApplicationIndividualId = individualId; //'919218728';
            reqWrapper.KeyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('PreferredIndividualId',individualId));
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
            
            if(responseWrapper.ACKRESPONSE!= null && responseWrapper.ACKRESPONSE.AckResponseCode!= null){
                toSend.bIsSuccess = true;
                toSend.put('status',false);             
                toSend.put('responseCode',responseWrapper.ACKRESPONSE.AckResponseCode);
                toSend.put('responseDescription',responseWrapper.ACKRESPONSE.AckResponseDescription);
            }else{
	        if(responseWrapper.hearingsSummaryInfoPayload!=null){
                    if(responseWrapper.hearingsSummaryInfoPayload.HearingSummary!=null){
                        for(SSP_HearingsSummaryInfoPayloadWrapper.HearingSummaryWrapper interfaceHearing : responseWrapper.hearingsSummaryInfoPayload.HearingSummary){
                            if(hearingProgramMap.containskey(interfaceHearing.HearingProgram)){
                                interfaceHearing.HearingProgram = hearingProgramMap.get(interfaceHearing.HearingProgram); 
                            }
                            if(hearingReasonMap.containskey(interfaceHearing.HearingReason)){
                                interfaceHearing.HearingReason = hearingReasonMap.get(interfaceHearing.HearingReason); 
                            }
                        }
                        
                          //Fix for Bug: 389993 : Start
                        Map<String,String> hearingTypeMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingType);
                        //Issue 2 - Defect 389993
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeTwo) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeThree) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeFour) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeFive) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeSix) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeSeven) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeEight) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeNine) );
                        hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeTen) );
                        for( SSP_HearingsSummaryInfoPayloadWrapper.HearingSummaryWrapper hsw : responseWrapper.hearingsSummaryInfoPayload.HearingSummary ){
                            hsw.hearingType= (hearingTypeMap.containsKey(hsw.HearingType)? hearingTypeMap.get(hsw.HearingType):hsw.HearingType);
                        }
                        //Fix for Bug: 389993 : End

                        toSend.put('hearingSummaryList', JSON.serialize(responseWrapper.hearingsSummaryInfoPayload.HearingSummary));
                    }else{
                        toSend.put('hearingSummaryList', responseWrapper.hearingsSummaryInfoPayload.HearingSummary);
                    }
                
                //for defect 386192-- start
                if(responseWrapper.hearingsSummaryInfoPayload.PreferredDetails!=null){
                    for(SSP_HearingsSummaryInfoPayloadWrapper.PreferredDetailsWrapper preferredDetails : responseWrapper.hearingsSummaryInfoPayload.PreferredDetails){
                        if(preferredDetails.PrimaryPhoneExtension == ''){
                            preferredDetails.PrimaryPhoneExtension = null;
                        }
                    }
                    toSend.put('individualAddress', JSON.serialize(responseWrapper.hearingsSummaryInfoPayload.PreferredDetails)); 
                }
                } else{
                    toSend.put('hearingSummaryList', responseWrapper.hearingsSummaryInfoPayload);
                }   
                //for defect 386192-- end       
                toSend.bIsSuccess = true;
                toSend.put('status',true);           
                //toSend.put('individualAddress', JSON.serialize(responseWrapper.hearingsSummaryInfoPayload.PreferredDetails)); 
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingController', 'getHearingSummary', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        } 
        return toSend;
    }
    
    /********************************************************************************************
* @author       Sanchita Tibrewala
* @date         06/30/2020
* @methodname   getRequestHearingPicklist
* @description  This method is used to get Hearing Request Picklist Maps
* @param        String
* @return       SSP_LightningResponse
********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getRequestHearingPicklist(String individualId){
        SSP_LightningResponse toSend = new SSP_LightningResponse(); 
        try{
            Map<String,String> hearingProgramMap = new Map<String,String>();
            Map<String,String> hearingReasonMap = new Map<String,String>();
            Map<String,String> hearingAccommodationMap = new Map<String,String>();
            Map<String,String> individualCaseMap = new Map<String,String>();
            Map<String,Map<String,String>> programToHearingReasonMap = new Map<String,Map<String,String>>();
            
            Map<String,List<AuthRepDetailsWrapper>> caseAuthRepMap = new Map<String,List<AuthRepDetailsWrapper>>();
            Set<String> caseList = new Set<String>();
            List<AccountContactRelation> authRepList = new List<AccountContactRelation>();
            List<AuthRepDetailsWrapper> authRepWrapList = new List<AuthRepDetailsWrapper>();
            
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            String caseVsStatus = sessionPart.get('caseVsStatus') != null ? String.valueOf(sessionPart.get('caseVsStatus')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'))) ?
                String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus')) : '';
            if(String.isNotBlank(caseVsStatus)){
                Map<String, String> caseToStatusMap = (Map<String, String>) JSON.deserialize(caseVsStatus, Map<String, String>.class); 
                caseList = caseToStatusMap.keySet();
                
                authRepList = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND','IN'=>'account.CaseNumber__c,Roles'}, 
                                                                              new Set<String>{'Id','account.CaseNumber__c','DCContactId__c','contact.FirstName','contact.LastName','Roles',
                                                                                  'contact.OrganizationName__c','contact.Email','contact.Phone',
                                                                                  'contact.Street__c','contact.AddressLine2__c','contact.City__c','contact.AssociatedCountyCode__c','contact.SSP_State__c','contact.Zipcode4__c','contact.Zipcode5__c',
                                                                                  'Street__c','AddressLine2__c','City__c','CountyCode__c','SSP_State__c','Zipcode4__c','Zipcode5__c'}, 
                                                                              new Map<String, String>{'limit'=>'1000','account.CaseNumber__c'=>String.join(new List<String>(caseList),','),'Roles'=>String.join(SSP_GlobalConstants.HEARING_REP_ROLES,',')});                
                authRepWrapList = getAuthRepWrap(authRepList);
                for(String individualCase : caseList){
                    individualCaseMap.put(individualCase, individualCase);
                }
                for(AuthRepDetailsWrapper authRep : authRepWrapList){
                    if(caseAuthRepMap.containsKey(authRep.CaseNumber)){
                        List<AuthRepDetailsWrapper> existingauthRepsList = caseAuthRepMap.get(authRep.CaseNumber);
                        existingauthRepsList.add(authRep);
                        caseAuthRepMap.put(authRep.CaseNumber, existingauthRepsList);
                    }
                    else{
                        List<AuthRepDetailsWrapper> newauthRepsList = new List<AuthRepDetailsWrapper>{authRep};
                            caseAuthRepMap.put(authRep.CaseNumber, newauthRepsList);
                    }
                }
            }
            
            hearingProgramMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingPrograms);
            hearingReasonMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingReasons);
            hearingAccommodationMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingAccommodations);            
            //KC:Kinship Care;KTAP:K-TAP;MEDCD:Medicaid;SNAP:SNAP;CCA:Child Care Assistance
            //MEDCD:MA;KTAP:KT;SNAP:SN;CCA:CC;            
            programToHearingReasonMap.put('KC', SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramKinshipCare));
            programToHearingReasonMap.put('KTAP', SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramKTAP));
            programToHearingReasonMap.put('MEDCD', SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramMEDCD));
            programToHearingReasonMap.put('SNAP', SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramSNAP));
            programToHearingReasonMap.put('CCA', SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramChildCare));
            
            toSend.put('hearingProgramMap', hearingProgramMap);
            toSend.put('hearingReasonMap', hearingReasonMap);
            toSend.put('hearingAccommodationMap', hearingAccommodationMap);
            toSend.put('programToHearingReasonMap',programToHearingReasonMap);
            if(!individualCaseMap.isEmpty()){
                toSend.put('individualCaseMap', individualCaseMap);
            }
            toSend.put('caseAuthRepMap', caseAuthRepMap);
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingController', 'getRequestHearingPicklist', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        } 
        return toSend;
    }
    
    /********************************************************************************************
* @author       Sanchita Tibrewala
* @date         07/02/2020
* @methodname   sendHearingRequest
* @description  This method is used to send new Hearing request data via service
* @param        String
* @return       SSP_LightningResponse
********************************************************************************************/
    @AuraEnabled    
    public static SSP_LightningResponse sendHearingRequest(String newHearingData, String representativeData, String addressData){
        SSP_LightningResponse toSend = new SSP_LightningResponse(); 
        try{            
            String individualId = SSP_Utility.getIndividualId();
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = new List<SSP_ApplicationIndividual__c> ();
            SSP_HearingDataContractOrg.CitizenHearingRequest hearingRequest = new SSP_HearingDataContractOrg.CitizenHearingRequest();
            Map<String,String> repDetailsMap = new Map<String,String>();
            SSP_HearingDataContractOrg.RepresentativeDetails repDetails = new SSP_HearingDataContractOrg.RepresentativeDetails();
            SSP_HearingDataContractOrg.IndividualAddress indAddress = new SSP_HearingDataContractOrg.IndividualAddress();
            hearingRequest = (SSP_HearingDataContractOrg.CitizenHearingRequest) JSON.deserialize(newHearingData, SSP_HearingDataContractOrg.CitizenHearingRequest.class);
            
            SSP_HearingDataContractOrg.CitizenHearingRequest newhearingRequest = new SSP_HearingDataContractOrg.CitizenHearingRequest();
            newhearingRequest.DCContactId=hearingRequest.DCContactId;
            newhearingRequest.RequireAccommodation=hearingRequest.RequireAccommodation;
            newhearingRequest.Comments=hearingRequest.Comments;
            newhearingRequest.ContinueBenefits=hearingRequest.ContinueBenefits;
            newhearingRequest.HealthInDanger=hearingRequest.HealthInDanger;
            newhearingRequest.HearingReason=hearingRequest.HearingReason;
            newhearingRequest.HearingProgram=hearingRequest.HearingProgram;
            newhearingRequest.DCCaseNumber=hearingRequest.DCCaseNumber;
            newhearingRequest.DMSDocumentId=hearingRequest.DMSDocumentId;
            newhearingRequest.AccommodationList=hearingRequest.AccommodationList;
            
            Boolean repDet = representativeData != null;            
            if(representativeData!=null){                
                repDetailsMap = (Map<String,String>) JSON.deserialize(representativeData, Map<String,String>.class);
                if(repDetailsMap!=null){
                    for(String repKey : SSP_GlobalConstants.REP_ADDRESS_MAP.keySet()){
                        if(repDetailsMap.containsKey(repKey)){
                            String repValue = repDetailsMap.get(repKey);
                            repDetailsMap.put(SSP_GlobalConstants.REP_ADDRESS_MAP.get(repKey), repValue);
                            repDetailsMap.remove(repKey);
                        }
                    }
                    String repMapString = JSON.serialize(repDetailsMap);    
                    repDetails = (SSP_HearingDataContractOrg.RepresentativeDetails) JSON.deserialize(repMapString, SSP_HearingDataContractOrg.RepresentativeDetails.class);
                    SSP_HearingDataContractOrg.RepresentativeDetails newRepDetails= new SSP_HearingDataContractOrg.RepresentativeDetails();
                    newRepDetails.RepresentativeAddressLine1=repDetails.RepresentativeAddressLine1;
                    newRepDetails.RepresentativeAddressLine2=repDetails.RepresentativeAddressLine2;
                    newRepDetails.RepresentativeCity=repDetails.RepresentativeCity;
                    newRepDetails.RepresentativeCountry=repDetails.RepresentativeCountry;
                    newRepDetails.RepresentativeCounty=repDetails.RepresentativeCounty;
                    newRepDetails.RepresentativeEmail=repDetails.RepresentativeEmail;
                    newRepDetails.RepresentativeFirstName=repDetails.RepresentativeFirstName;
                    newRepDetails.RepresentativeLastName=repDetails.RepresentativeLastName;
                    newRepDetails.RepresentativeOrganisationName=repDetails.RepresentativeOrganisationName;
                    newRepDetails.RepresentativePhoneNo=repDetails.RepresentativePhoneNo;
                    newRepDetails.RepresentativeState=repDetails.RepresentativeState;
                    newRepDetails.RepresentativeZip4=repDetails.RepresentativeZip4;
                    newRepDetails.RepresentativeZip5=repDetails.RepresentativeZip5;
                    newhearingRequest.RepresentativeDetail=newRepDetails;
                }
            }
            else{
                repDetails = null;
                SSP_HearingDataContractOrg.RepresentativeDetails newRepDetails= new SSP_HearingDataContractOrg.RepresentativeDetails();
                
            }
            
            addressData=addressData.remove('[');
            addressData=addressData.remove(']');
            if(String.isNotBlank(addressData)){
                indAddress = (SSP_HearingDataContractOrg.IndividualAddress) JSON.deserialize(addressData, SSP_HearingDataContractOrg.IndividualAddress.class);
            }
            SSP_HearingDataContractOrg.IndividualAddress newIndiAddress = new SSP_HearingDataContractOrg.IndividualAddress();
            newIndiAddress.AddressLine1=indAddress.AddressLine1;
            newIndiAddress.AddressLine2=indAddress.AddressLine2;
            newIndiAddress.City=indAddress.City;
            newIndiAddress.CountyCode=indAddress.CountyCode;
            newIndiAddress.Email=indAddress.Email;
            newIndiAddress.FirstName=indAddress.FirstName;
            newIndiAddress.GenderCode=indAddress.GenderCode;
            newIndiAddress.LastName=indAddress.LastName;
            newIndiAddress.MiddleInitial=indAddress.MiddleInitial;
            newIndiAddress.PrimaryPhoneExtension=indAddress.PrimaryPhoneExtension;
            newIndiAddress.PrimaryPhoneNumber=indAddress.PrimaryPhoneNumber;
            newIndiAddress.PrimaryPhoneTypeCode=indAddress.PrimaryPhoneTypeCode;
            newIndiAddress.StateCode=indAddress.StateCode;
            newIndiAddress.ZipCode4=indAddress.ZipCode4;
            newIndiAddress.ZipCode5=indAddress.ZipCode5;
            newhearingRequest.IndividualAddress = newIndiAddress; 
            
            newhearingRequest.IndividualId = Integer.Valueof(individualId);
            //Query Document details
            List<SSP_Notifications__c> negativeDocumentsList= new list<SSP_Notifications__c>();
           if(String.isNotBlank(newhearingRequest.DMSDocumentId)){
            negativeDocumentsList = 
                [SELECT Id, Name, MessageSubject__c, DmsDocumentId__c, NotificationCode__c, MessageCreateDate__c FROM SSP_Notifications__c where DmsDocumentId__c=:newhearingRequest.DMSDocumentId];
             } 
            if(!negativeDocumentsList.isEmpty()){
                newhearingRequest.Extension = SSP_GlobalConstants.NOTIFICATION_EXTENSION_DEFAULT_VALUE;
                newhearingRequest.DocumentName = negativeDocumentsList[0].MessageSubject__c;
                newhearingRequest.DocumentTypeDescription = negativeDocumentsList[0].MessageSubject__c;
                newhearingRequest.DocumentType = negativeDocumentsList[0].NotificationCode__c;
                newhearingRequest.UploadDate = negativeDocumentsList[0].MessageCreateDate__c;
            }
            
            //Add case name and Party Type
            sspApplicationIndividualList = 
                SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                 new Set<String>{'Id', 'IsHeadOfHousehold__c', 'SSP_Application__r.DCCaseNumber__c','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c'}, 
                                                                                 new Map<String, String>{'limit'=>'100','SSP_Application__r.DCCaseNumber__c'=> String.ValueOf(newhearingRequest.DCCaseNumber),'IsHeadOfHousehold__c'=> '#true#'});
            
            if(!sspApplicationIndividualList.isEmpty() && sspApplicationIndividualList!=null){
                newhearingRequest.CaseName = sspApplicationIndividualList[0].SSP_Member__r.FirstName__c + ' ' + sspApplicationIndividualList[0].SSP_Member__r.LastName__c;
            }
            
            newhearingRequest.PartyType = SSP_GlobalConstants.HEARING_PARTY_TYPE_DEFAULT_VALUE;            
            
            Map<String, Object> objReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(newhearingRequest)};
            //objReq.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');//put the app id for which you are invoking this service, this is for logging purpose
            objReq.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,newhearingRequest.DCCaseNumber);
            List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CREATEHEARING_METADATANAME, objReq);
            SSP_HearingDataContractOrg.CitizenHearingResponse objResponse = (SSP_HearingDataContractOrg.CitizenHearingResponse)lstData[0];

            toSend.put('isSuccess', true);
            toSend.put('hearingId', objResponse.HearingId);
            toSend.put('hearingRequestId', objResponse.RequestId);
            toSend.put('hearingRequestFinal', newhearingRequest);
            toSend.put('repDetails', repDetails);
            toSend.put('indAddress', indAddress);
            toSend.put('status', objResponse.Status);
            if(!objResponse.Status || (objResponse.Error!=null && objResponse.Error.CHFSExceptionId!=null)){
                toSend.put('Error', objResponse.Error.CHFSExceptionId);
            }     
            
            toSend.bIsSuccess = true;
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingController', 'sendHearingRequest', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        } 
        return toSend;
    }
    
    /********************************************************************************************
* @author       Sanchita Tibrewala
* @date         07/16/2019
* @methodname   getAuthRepWrap
* @description  This method returns AuthRepDetailsWrapper 
* @param        List<AccountContactRelation>
* @return       List<AuthRepDetailsWrapper>
********************************************************************************************/
    public static List<AuthRepDetailsWrapper> getAuthRepWrap (List<AccountContactRelation> authRepList){
        List<AuthRepDetailsWrapper> authRepWrapList = new List<AuthRepDetailsWrapper> ();
        try{
            for(AccountContactRelation authRep : authRepList){
                AuthRepDetailsWrapper authRepWrap = new AuthRepDetailsWrapper ();
                authRepWrap.RepId = authRep.Id;
                authRepWrap.CaseNumber = authRep.account.CaseNumber__c;
                authRepWrap.Role = authRep.Roles;
                authRepWrap.RepresentativeFirstName = authRep.contact.FirstName;
                authRepWrap.RepresentativeLastName = authRep.contact.LastName;
                authRepWrap.RepresentativeOrganisationName = authRep.contact.OrganizationName__c;
                authRepWrap.RepresentativePhoneNo = authRep.contact.Phone;
                authRepWrap.RepresentativeEmail = authRep.contact.Email;
                if(authRepWrap.Role == SSP_GlobalConstants.REP_ROLE_ASSISTER_VALUE){
                    authRepWrap.Street = authRep.contact.Street__c;
                    authRepWrap.AddressLine2 = authRep.contact.AddressLine2__c;
                    authRepWrap.City = authRep.contact.City__c;
                    authRepWrap.CountyCode = authRep.contact.AssociatedCountyCode__c;
                    authRepWrap.StateCode = authRep.contact.SSP_State__c;
                    authRepWrap.ZipCode4 = authRep.contact.Zipcode4__c;
                    authRepWrap.ZipCode5 = authRep.contact.Zipcode5__c;
                }
                else{
                    authRepWrap.Street = authRep.Street__c;
                    authRepWrap.AddressLine2 = authRep.AddressLine2__c;
                    authRepWrap.City = authRep.City__c;
                    authRepWrap.CountyCode = authRep.CountyCode__c;
                    authRepWrap.StateCode = authRep.SSP_State__c;
                    authRepWrap.ZipCode4 = authRep.Zipcode4__c;
                    authRepWrap.ZipCode5 = authRep.Zipcode5__c; 
                }
                authRepWrapList.add(authRepWrap);
            } 
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingController', 'getAuthRepWrap', ex.getMessage() , true);
        }
        return authRepWrapList;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         07/03/2020
* @methodname   createJSONforHearingSummary
* @description  This method takes Hearing Id and sends us the hearing summary view details
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse showHearingSummaryDetail(String hearingId){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        
        try{
            //hearingId='1003850';
            Map<String, Object> mapParams = new Map<String, Object>();
            boolean hearingWithdrawn=false;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY, hearingId);
            list<Object> serviceResponses1 = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.CITIZEN_HEARING_VIEW_DETAILS, mapParams); 
            SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse serviceResponses  =  (SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse) serviceResponses1[0];            
            
            if(String.isBlank(serviceResponses.ErrorLogCode) || serviceResponses.ErrorLogCode==null){                
                
                SSP_HearingDataContractOrg.ArrayOfDocumentsUpload DocumentsUpload1=serviceResponses.DocumentsUpload;
                SSP_HearingDataContractOrg.HearingAppointment HearingAppointment=serviceResponses.HearingAppointment;
                SSP_HearingDataContractOrg.ArrayOfHearingHistory HearingHistoryList1=serviceResponses.HearingHistoryList;
                SSP_HearingDataContractOrg.HearingSummary HearingSummary=serviceResponses.HearingSummary;
                SSP_HearingDataContractOrg.ArrayOfNegativeActionDocuments NegativeActionDocuments1=serviceResponses.NegativeActionDocuments;
                SSP_HearingDataContractOrg.ArrayOfPartiesInvolved PartiesInvolved1=serviceResponses.PartiesInvolved;
                SSP_HearingDataContractOrg.PrehearingAppointment PrehearingAppointment1=serviceResponses.PrehearingAppointment;  
                Map<String,String> hearingProgramMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramsOne);
                /*Adding all hearing Programs to Map  */
                hearingProgramMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramsTwo));
                hearingProgramMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingProgramsThree));
                Map<String,String> hearingReasonMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingReasons);
                Map<String,String> hearingTypeMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingType);
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeTwo) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeThree) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeFour) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeFive) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeSix) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeSeven) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeEight) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeNine) );
                                    hearingTypeMap.putAll( SSP_Utility.getPicklistFromLabel(System.Label.sspHearingTypeTen) );
                Map<String,String> hearingPartiesInvolvedRolesMap = SSP_Utility.getPicklistFromLabel(System.Label.sspHearingRoles); // changed from sspHearingPartiesInvolvedRoles to sspHearingRoles as per bug 392216
                
                HearingSummaryViewDetailWrapper hsw= new HearingSummaryViewDetailWrapper();
                hsw.hearingStatus=HearingSummary.HearingStatus;           
                hsw.hearingId=HearingSummary.HearingId;
                hsw.hearingProgram=hearingProgramMap.get(HearingSummary.HearingProgram);
                hsw.hearingReason=hearingReasonMap.get(HearingSummary.HearingReason);
                hsw.hearingType= (hearingTypeMap.containsKey(HearingSummary.HearingType)? hearingTypeMap.get(HearingSummary.HearingType):HearingSummary.HearingType);//HearingSummary.HearingType;
                hsw.hearingDate=HearingSummary.HearingDate; 
                hsw.caseNumber=HearingSummary.CaseNumber;
                hsw.caseName=HearingSummary.CaseName;
                hsw.requester=HearingSummary.Requester;
                hsw.hearingOfficer=HearingSummary.HearingOfficer;
                hsw.hearingDelayReason=HearingSummary.HearingDelayReason;
                hsw.individualId=HearingSummary.IndividualId;
                if(PrehearingAppointment1!=null){
                    PrehearingAppointment prehearingAppointment= new PrehearingAppointment();  
                    prehearingAppointment.Id='1';                    
                    prehearingAppointment.meetingType=PrehearingAppointment1.MeetingType;
                    prehearingAppointment.prehearingDate=PrehearingAppointment1.PrehearingDate;
                    prehearingAppointment.conferenceLine=PrehearingAppointment1.ConferenceLine;
                    prehearingAppointment.prehearingtime=PrehearingAppointment1.Prehearingtime;
                    prehearingAppointment.prehearingParticipantCode=PrehearingAppointment1.PrehearingParticipantCode;
                    prehearingAppointment.location=PrehearingAppointment1.Location;
                    if((String.isNotBlank(prehearingAppointment.meetingType) || String.isNotBlank(prehearingAppointment.prehearingDate) || String.isNotBlank(prehearingAppointment.conferenceLine) || String.isNotBlank(prehearingAppointment.prehearingtime) || String.isNotBlank(prehearingAppointment.prehearingParticipantCode) || String.isNotBlank(prehearingAppointment.location))){
                        hsw.prehearingAppointmentList.add(prehearingAppointment);
                    }
                    
                }
                if(HearingAppointment!=null){
                    HearingAppointment hearingAppointment1= new HearingAppointment();
                    hearingAppointment1.Id='1';
                    hearingAppointment1.location=HearingAppointment.Location;
                    hearingAppointment1.hearingDate=HearingAppointment.HearingDate;
                    hearingAppointment1.meetingType= HearingAppointment.MeetingType;
                    hearingAppointment1.timeOfHearing=HearingAppointment.TimeOfHearing;
                    hearingAppointment1.conferenceLine=HearingAppointment.ConferenceLine;        
                    hearingAppointment1.hearingParticipantCode=HearingAppointment.HearingParticipantCode;
                    if(String.isNotBlank(hearingAppointment1.location) || String.isNotBlank(hearingAppointment1.hearingDate) || String.isNotBlank(hearingAppointment1.meetingType) || String.isNotBlank(hearingAppointment1.timeOfHearing) || String.isNotBlank(hearingAppointment1.conferenceLine) || String.isNotBlank(hearingAppointment1.hearingParticipantCode)){
                        hsw.hearingAppointmentList.add(hearingAppointment1);
                    }                
                }
                
                
                Integer loopCounter=0;          
                if(HearingHistoryList1!=null && HearingHistoryList1.HearingHistory!=null && HearingHistoryList1.HearingHistory.size()>0){                
                    for(SSP_HearingDataContractOrg.HearingHistory HearingHistoryList: HearingHistoryList1.HearingHistory){
                        HearingHistory hearingHist= new HearingHistory();
                        hearingHist.Id=String.valueOf(loopCounter);
                        hearingHist.hearingHistoryDate=HearingHistoryList.HearingHistoryDate; 
                        hearingHist.hearingHistoryAction=HearingHistoryList.HearingHistoryAction;
                        if(HearingHistoryList.HearingHistoryAction.equals('Hearing withdraw requested')){
                            hearingWithdrawn=true;
                        }
                        hearingHist.hearingHistoryActionBy=HearingHistoryList.HearingHistoryActionBy;
                        if(hearingHist.hearingHistoryDate!=null || String.isNotBlank(hearingHist.hearingHistoryAction) || String.isNotBlank(hearingHist.hearingHistoryActionBy)){
                            loopCounter++;
                            hsw.hearingHistoryList.add(hearingHist);
                        }                    
                    }                 
                }      
                
                loopCounter=0;
                if(NegativeActionDocuments1!=null && NegativeActionDocuments1.NegativeActionDocuments!=null && NegativeActionDocuments1.NegativeActionDocuments.size()>0){                
                    for(SSP_HearingDataContractOrg.NegativeActionDocuments  NegativeActionDocuments: NegativeActionDocuments1.NegativeActionDocuments){
                        NegativeActionDocuments NegativeActionDocument= new NegativeActionDocuments();               
                        NegativeActionDocument.Id=String.valueOf(loopCounter);
                        NegativeActionDocument.negativeDocumentName=NegativeActionDocuments.NegativeDocumentName;
                        NegativeActionDocument.negativeDmsDocumentId=NegativeActionDocuments.NegativeDmsDocumentId;
                        NegativeActionDocument.negativeDocumentType=NegativeActionDocuments.NegativeDocumentType;
                        NegativeActionDocument.negativeSentDate=NegativeActionDocuments.NegativeSentDate;
                            NegativeActionDocument.extension=SSP_GlobalConstants.NOTIFICATION_EXTENSION_DEFAULT_VALUE;
                        if(String.isNotBlank(NegativeActionDocument.negativeDocumentName)||String.isNotBlank(NegativeActionDocument.negativeDmsDocumentId)||String.isNotBlank(NegativeActionDocument.negativeDocumentType)||NegativeActionDocument.negativeSentDate!=null){
                            loopCounter++;
                            hsw.NegativeActionDocumentsList.add(NegativeActionDocument);
                        }
                    }                 
                }
                
                loopCounter=0;       
                if(PartiesInvolved1!=null && PartiesInvolved1.PartiesInvolved!=null && PartiesInvolved1.PartiesInvolved.size()>0){                
                    for(SSP_HearingDataContractOrg.PartiesInvolved PartiesInvolved: PartiesInvolved1.PartiesInvolved){
                        PartiesInvolved partiesInvolve  = new PartiesInvolved();                        
                        partiesInvolve.Id=String.valueOf(loopCounter);
                        partiesInvolve.contactName=PartiesInvolved.ContactName;
                        partiesInvolve.phoneNumber=PartiesInvolved.PhoneNumber;
                        partiesInvolve.companyName=PartiesInvolved.CompanyName;
                        partiesInvolve.email=PartiesInvolved.Email;
                        //partiesInvolve.role=PartiesInvolved.Role;
                        partiesInvolve.role = (hearingPartiesInvolvedRolesMap.containsKey(PartiesInvolved.Role)? hearingPartiesInvolvedRolesMap.get(PartiesInvolved.Role):PartiesInvolved.Role);
                        if(String.isNotBlank(partiesInvolve.contactName)||String.isNotBlank(partiesInvolve.phoneNumber)||String.isNotBlank(partiesInvolve.companyName)||String.isNotBlank(partiesInvolve.email)||String.isNotBlank(partiesInvolve.role )){
                            loopCounter++;
                            hsw.partiesInvolvedList.add(partiesInvolve);
                        }                    
                    }                 
                }            
                Map<String,String> hearingTypePicklist=SSP_Utility.getPickListValues('DocumentDetail__c','Hearing_Document_Type__c','');
                loopCounter=0;
                if(DocumentsUpload1!=null && DocumentsUpload1.DocumentsUpload!=null && DocumentsUpload1.DocumentsUpload.size()>0){                
                    for(SSP_HearingDataContractOrg.DocumentsUpload DocumentUpload: DocumentsUpload1.DocumentsUpload){ 
                        DocumentsUpload documentsUpload= new DocumentsUpload();                                         
                        documentsUpload.Id=String.valueOf(loopCounter);
                        documentsUpload.documentType=hearingTypePicklist.get(DocumentUpload.DocumentType);
                        documentsUpload.dmsDocumentId=DocumentUpload.DmsDocumentId;
                        documentsUpload.documentName= DocumentUpload.DocumentName;
                        documentsUpload.uploadedBy=DocumentUpload.UploadedBy;
                        documentsUpload.dateOfUpload=DocumentUpload.DateOfUplaod;
                        if(documentsUpload.documentName.Contains('.'))                            
                            documentsUpload.extension=documentsUpload.documentName.substringAfter('.');

                        if(String.isNotBlank(documentsUpload.documentType)|| String.isNotBlank(documentsUpload.dmsDocumentId)|| String.isNotBlank(documentsUpload.documentName)|| String.isNotBlank(documentsUpload.uploadedBy)|| documentsUpload.dateOfUpload!=null){
                            loopCounter++;
                            hsw.documentsUploadList.add(documentsUpload);
                        }
                    }                 
                }
                //Edited query to fetch Mapping Id for uploaded Document
                List<DocumentDetail__c> docDetailList= [SELECT Id,Document_Type_Description__c,Hearing_Id__c,Name,UserId__c,CreatedDate,ContentDocumentId__c,MappingId__c FROM DocumentDetail__c WHERE (Hearing_Id__c=:hearingId OR Hearing_Request_Number__c=:hearingId) AND StatusCode__c!='Success'];
                if(docDetailList!=null && docDetailList.size()>0){
                    for(DocumentDetail__c docDetail:docDetailList){
                        DocumentsUpload documentsUpload= new DocumentsUpload();
                        documentsUpload.Id=documentsUpload.Id;
                        documentsUpload.documentType=docDetail.Document_Type_Description__c;
                        documentsUpload.contentDocumentId=docDetail.ContentDocumentId__c;
                        documentsUpload.documentName=docDetail.Name;
                        documentsUpload.uploadedBy=docDetail.UserId__c;
                        documentsUpload.dateOfUpload=docDetail.CreatedDate;
                        documentsUpload.mappingId = docDetail.MappingId__c;
                        if(documentsUpload.documentName.Contains('.'))                            
                            documentsUpload.extension=documentsUpload.documentName.substringAfter('.');
                        hsw.documentsUploadList.add(documentsUpload);
                    }                 
                }       
                toSend.put('hearingSummaryViewDetailWrapper',hsw);
                toSend.bIsSuccess = true; 
                toSend.put('status',true); 
                toSend.put('hearingWithdrawn',hearingWithdrawn);
                toSend.put('bIsSuccess',true);
            }else{
                toSend.put('status',false); 
                toSend.put('error',serviceResponses.ErrorLogCode); 
            }  
        }
        catch(Exception ex){
            toSend.bIsSuccess = false;            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingSummaryController', 'showHearingSummaryDetail', ex.getMessage() , true);
            toSend.put('Error', lstLogMessages[0].Name);
        }        
        return toSend;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         07/07/2020
* @methodname   getNegativeNoticeForHearing
* @description  This method takes a case Id and sends us negative notice data
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getNegativeNoticeForHearing(String caseId){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        List<User> userLst;
        String userRole;        
        List<String> programAccessForNotices;
        List<String> correspondenceCode=new list<String>{'EDB-104','HIP-020','EDB-057','EDB-059','EDB-060','EDB-058','EDB-034','EDB-040','EDB-043','DCC-105','DCC-941','EDB-052','EDB-053','EDB-054','EDB-055','EDB-002','EDB-003','EDB-004','EDB-005','EDB-064','EDB-065','EDB-063','EDB-049','EDB-050'};
            try{
                userLst = SSP_Utility.getCurrentUserDetails();
                userRole = (SSP_Utility.getUserDetails(userLst[0].Id)).get(SSP_GlobalConstants.USER_ROLE); 
                String individualId = SSP_Utility.getIndividualId();            
                programAccessForNotices = new List<String>();
                /*For citizen - notices with all programs*/
                if(userRole==SSP_GlobalConstants.CITIZEN_ROLE){
                    programAccessForNotices.addAll(SSP_GlobalConstants.ALL_PROGRAMS);
                      //DEFECT 389943: Added new programs
                      programAccessForNotices.add('SA');
                      programAccessForNotices.add('KC');   
                }
                /*Auth rep access maps based fetch accessible programs (per case-prgram map basis filtering happens further)*/
                else if(userRole==SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING || userRole==SSP_GlobalConstants.ORGANISATION_AUTH_REP){
                    map<String,Set<String>> authRepAccessForNotices;
                    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                    String authRepAccessForNoticesString = sessionPart.get('authRepAccessForNotices') != null ? String.valueOf(sessionPart.get('authRepAccessForNotices')) : 
                    String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices'))) ?
                        String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices')) : '';
                    if(authRepAccessForNoticesString != null && authRepAccessForNoticesString != ''){
                        authRepAccessForNotices = (map<String,Set<String>>)JSON.deserialize(authRepAccessForNoticesString, map<String,Set<String>>.class);
                        for(String caseNo : authRepAccessForNotices.keySet()){
                            programAccessForNotices.addAll(authRepAccessForNotices.get(caseNo));
                        }
                    }
                }
                /* for all other roles - role programs access for notices*/
                else{
                    programAccessForNotices.addAll(SSP_Utility.getAvailableProgramsByRole());
                }
                List<String> lstIndId = (ssp_utility.getCurrentUserAllIndividualIds()).split(';');
                String primaryIndId = ssp_utility.getIndividualId();
                if( userRole==SSP_GlobalConstants.CITIZEN_ROLE || (primaryIndId!=null && primaryIndId!='')){
                    userRole=SSP_GlobalConstants.NOTIFICATION_CITIZEN;
                }    
                //DEFECT 389943: Changed the query for Program_Code__c            
                List<SSP_Notifications__c> negativeDocumentsList = [SELECT Id,Name,messageSubject__c,messageSubjectES__c,Program_Code__c,dmsDocumentId__c,notificationCode__c,MessageCreateDate__c,Case_Number__c,CreatedDate FROM SSP_Notifications__c where Case_Number__c=:caseId AND dmsDocumentId__c!=null AND notificationCode__c in: correspondenceCode and (Program_Code__c IN :programAccessForNotices OR Program_Code__c = NULL ) and Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND  recipientId__c IN :lstIndId AND recipientType__c = :userRole ];
                //recipeint ID= case-inidvidual Id imperosnated
                toSend.bIsSuccess = true;
                toSend.put('negativeDocumentsList', negativeDocumentsList);      
                toSend.put('bIsSuccess',true);    
            }
        catch(Exception ex){
            toSend.bIsSuccess = false;            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingSummaryController', 'getNegativeNoticeForHearing', ex.getMessage() , true);
            toSend.put('Error', lstLogMessages[0].Name);
        }        
        return toSend;       
    } 
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         07/16/2020
* @methodname   withdrawHearingRequest
* @description  This method takes a hearing Id and sends us withdrawHearingRequest Status
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse withdrawHearingRequest(String hearingId){
        SSP_LightningResponse toSend = new SSP_LightningResponse();        
        try{            
            SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest req = new SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest();            
            req.HearingId= hearingId;            
            Map<String, Object> objReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
                objReq.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');//put the app id for which you are invoking this service, this is for logging purpose
            objReq.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,'CaseNumber');//put the CaseNumber for which you are invoking this service, this is for logging purpose
            List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WITHDRAWHEARING_METADATANAME, objReq);
            SSP_HearingDataContractOrg.CitizenHearingResponse objResponse = (SSP_HearingDataContractOrg.CitizenHearingResponse)lstData[0];
            toSend.bIsSuccess = true;
            toSend.put('status', true); 
            toSend.put('withdrawHearingStatus',objResponse.Status);
            if(!objResponse.Status || (objResponse.Error!=null && objResponse.Error.CHFSExceptionId!=null)){
                toSend.put('Error', objResponse.Error.CHFSExceptionId);
            }     
            toSend.put('bIsSuccess',true);    
        }
        catch(Exception ex){
            toSend.bIsSuccess = false;            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingSummaryController', 'getNegativeNoticeForHearing', ex.getMessage() , true);
            toSend.put('Error', lstLogMessages[0].Name);
        }        
        return toSend;       
    }  
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         07/10/2020
* @methodname   getScreenPermisson
* @description  This method takes a case Id and sends us negative notice data
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getScreenPermission(String screenId, String userId){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        toSend.put('readOnlyUser', false);  
        list<String> readOnlyProfiles=System.label.SSP_ReadOnlyProfiles.split(';');  
        try{ 
            String selectedRole=SSP_Utility.getUserDetails(userId).get('userRole');
            toSend.bIsSuccess = true;
            toSend.put('screenAccessDetails', SSP_Utility.getScreenAccessDetails(screenId,selectedRole)); 
            if(readOnlyProfiles.contains(selectedRole)){
               toSend.put('readOnlyUser', true);  
            }               
            toSend.put('bIsSuccess',true);
        }
        catch(Exception ex){
            toSend.bIsSuccess = false;            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingSummaryController', 'getScreenPermisson', ex.getMessage() , true);
            toSend.put('Error', lstLogMessages[0].Name);
        }        
        return toSend;       
    } 
    @AuraEnabled
    public static SSP_LightningResponse changeNotificationStatus(String hearingId,string hearingRequestNumber){
        SSP_Utility.isAuthenticatedUser();
        
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        String hearingCompare=String.escapeSingleQuotes(hearingId+'-'+hearingRequestNumber);
        try{
            //add docObj.Hearing_Id__c+'-'+docObj.Hearing_Request_Number__c
            List<SSP_Notifications__c> sspNotifications= [SELECT Id,Linked_Record_Id__c,Status__c  FROM SSP_Notifications__c WHERE  Status__c!='Expired' AND Linked_Record_Id__c=:hearingCompare];
            if(sspNotifications!=null && sspNotifications.size()>0)
            {
                for(SSP_Notifications__c sspnotify: sspNotifications)
                {
                    if(sspnotify.Status__c!=null)
                        sspnotify.Status__c='Expired';
                }
                if (Schema.sObjectType.SSP_Notifications__c.fields.Status__c.isUpdateable()){
                    update sspNotifications;
                    objResponse.bIsSuccess=true;
                }   
            }
            else {
                objResponse.bIsSuccess=true;
            }
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingSummaryController', 'changeNotificationStatus', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    
    public class HearingSummaryViewDetailWrapper{
        @AuraEnabled public String hearingStatus;
        @AuraEnabled public String hearingId;
        @AuraEnabled public String hearingProgram;
        @AuraEnabled public String hearingReason;
        @AuraEnabled public String hearingType;
        @AuraEnabled public String hearingDate; 
        @AuraEnabled public Integer caseNumber;
        @AuraEnabled public String caseName;
        @AuraEnabled public String requester;
        @AuraEnabled public String hearingOfficer;
        @AuraEnabled public String hearingDelayReason;
        @AuraEnabled public Integer individualId;
        @AuraEnabled public list<PrehearingAppointment> prehearingAppointmentList= new list<PrehearingAppointment>();        	
        @AuraEnabled public list<HearingHistory> hearingHistoryList= new list<HearingHistory>();
        @AuraEnabled public list<HearingAppointment> hearingAppointmentList= new list<HearingAppointment>();
        @AuraEnabled public list<PartiesInvolved> partiesInvolvedList = new list<PartiesInvolved>();        	
        @AuraEnabled public list<DocumentsUpload> documentsUploadList= new list<DocumentsUpload>();
        @AuraEnabled public list<NegativeActionDocuments> NegativeActionDocumentsList= new list<NegativeActionDocuments>();
        
    } 
    public class PrehearingAppointment{
        @AuraEnabled public String Id;
        @AuraEnabled public String meetingType;
        @AuraEnabled public String prehearingDate;
        @AuraEnabled public String conferenceLine;
        @AuraEnabled public String prehearingtime;
        @AuraEnabled public String prehearingParticipantCode;  
        @AuraEnabled public String location; 
    }
    public class HearingHistory{ 
        @AuraEnabled public String Id;       	
        @AuraEnabled public DateTime hearingHistoryDate; 
        @AuraEnabled public String hearingHistoryAction; 
        @AuraEnabled public String hearingHistoryActionBy;        	
    }
    public class HearingAppointment{
        @AuraEnabled public String Id;
        @AuraEnabled public String location;
        @AuraEnabled public String hearingDate;
        @AuraEnabled public String meetingType;
        @AuraEnabled public String timeOfHearing;
        @AuraEnabled public String conferenceLine;       
        @AuraEnabled public String hearingParticipantCode;
    }
    public class PartiesInvolved{
        @AuraEnabled public String Id;
        @AuraEnabled public String contactName; 
        @AuraEnabled public String phoneNumber; 
        @AuraEnabled public String companyName; 
        @AuraEnabled public String email;
        @AuraEnabled public String role;
    }
    public class DocumentsUpload{
        @AuraEnabled public String Id;
        @AuraEnabled public String documentType;
        @AuraEnabled public String dmsDocumentId;
        @AuraEnabled public String documentName;
        @AuraEnabled public String uploadedBy;
        @AuraEnabled public DateTime dateOfUpload;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String extension;
        @AuraEnabled public String MappingId;
        
    }
    public class NegativeActionDocuments{
        @AuraEnabled public String Id;
        @AuraEnabled public String negativeDocumentName;
        @AuraEnabled public String negativeDmsDocumentId;
        @AuraEnabled public String negativeDocumentType;
        @AuraEnabled public DateTime negativeSentDate;
        @AuraEnabled public String extension;
    }   
    
    public class HearingSummaryWrapper{
        @AuraEnabled public String hearingStatus;
        @AuraEnabled public String hearingId;
        @AuraEnabled public String hearingProgram;
        @AuraEnabled public String hearingReason;
        @AuraEnabled public String hearingType;
        @AuraEnabled public String hearingDate;     
    }   
    
    
    public class AuthRepDetailsWrapper{
        @AuraEnabled public String RepId; 
        @AuraEnabled public String CaseNumber; 
        @AuraEnabled public String Role; 
        @AuraEnabled public String RepresentativeFirstName; 
        @AuraEnabled public String RepresentativeLastName; 
        @AuraEnabled public String RepresentativeOrganisationName; 
        @AuraEnabled public String RepresentativePhoneNo; 
        @AuraEnabled public String RepresentativeEmail; 
        @AuraEnabled public String Street; 
        @AuraEnabled public String AddressLine2; 
        @AuraEnabled public String City; 
        @AuraEnabled public String CountyCode; 
        @AuraEnabled public String StateCode; 
        @AuraEnabled public String ZipCode4; 
        @AuraEnabled public String ZipCode5; 
    }    
}