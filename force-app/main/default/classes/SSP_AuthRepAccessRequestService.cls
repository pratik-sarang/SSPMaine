/*
* classname 	: SSP_AuthRepAccessRequestService
* @description 	: This class is use to 
* @author 		: Ashwin Kasture
* @date 		: 4th June 2020
* MODIFICATION LOG
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		4th June 2020	Initial Version
*/
public with sharing class SSP_AuthRepAccessRequestService {
    /*
	* method 		: loadAuthRepDetails
	* @description  : This method is use to load the Auth Resp Details.
	* @author 		: Ashwin Kasture
	* @return 		: Map<String, Object>
	* */
    public static Map<String, Object> loadAuthRepDetails() {
        Map<String, Object> objResponse = new Map<String, Object>();
        Map<String,String> mapRelationshipPicklistValues = SSP_Utility.getPickListValues('AccountContactRelation', 'RepresentativeRelationshipCode__c', null);
        Map<String,String> mapPemissionPicklistValues = SSP_Utility.getPickListValues('AccountContactRelation', 'PermissionLevel_Medicaid__c', null);
        Map<String,String> mapProgramPicklistValues = SSP_Utility.getPickListValues('AccountContactRelation', 'ProgramsApplied__c', null);
        Set<String> setPrograms = SSP_Utility.getAvailableProgramsByRole();

        Map<String, String> mapUserDetails = SSP_Utility.getUserDetails(UserInfo.getUserId()); // Need to remove this before checkins

        List<SSP_ProgramPermissionMapping__mdt> lstProgramPermissions = [SELECT ApplyReportChangeRecertify__c,ApplyReportChangeRecertifyCopyNotice__c,ApplyReportChangeRecertifyEBTCard__c,ApplyReportChangeRecertifyReceiveChecks__c,ApplyReportChangeRecertifyChecksToClient__c,StatutoryBenefitPayee__c,UseEBTCard__c,Program__c,Role__c,Order__c 
                                                                         FROM SSP_ProgramPermissionMapping__mdt 
                                                                         Where Role__c =: SSP_GlobalConstants.Auth_Rep AND Program__c IN: setPrograms Order by Order__c Asc];
		
        objResponse.put('programPermissionMapping', lstProgramPermissions);
        objResponse.put('relationshipPicklistValues', mapRelationshipPicklistValues);
        objResponse.put('permissionPicklistValues', mapPemissionPicklistValues);
        objResponse.put('programPicklistValues', mapProgramPicklistValues);
        objResponse.put('availableProgramsSet',setPrograms);
        objResponse.put('userDetails',SSP_Utility.getUserDetails(UserInfo.getUserId()));// Need to remove before checkins
        objResponse.put('selectedRole',SSP_Utility.getSelectedRole());// Need to remove this before checkins
        return objResponse;
    }

    /*
	* method 		: searchClientMCIService
	* @description  : This method is use to search client by MCI service.
	* @author 		: Ashwin Kasture
	* @param 		: String sClientDetails
	* @return 		: Map<String, Object>
	* */
    @AuraEnabled
    public static Map<String, Object> searchClientMCIService (String sClientDetails) {
        String sMatchStatus = '';
        String sApplicationNumber = '';
        String sCaseNumber = '';
        Map<String, Object> objResponse = new Map<String, Object>();
        //List<SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper> lstMCIDetails = new List<SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper>();
        SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper objMCIDetails = new SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper();
        Map<String, Object> mapClientParam = (Map<String, Object>)JSON.deserializeUntyped(sClientDetails);
        List<String> lstSourceIndividualId = new List<String>();
        
        //MCI Integration Service
        sApplicationNumber = mapClientParam.get('applicationNumber') != null ? String.valueOf(mapClientParam.get('applicationNumber')) : '';
        sCaseNumber = mapClientParam.get('caseNumber') != null ? String.valueOf(mapClientParam.get('caseNumber')) : '';
        
        objResponse.put('applicationNumber', sApplicationNumber);
        objResponse.put('caseNumber', sCaseNumber);
        
        List<User> userList = SSP_UserSelector.queryUserData (
                                                            new Map<String, String>{'objectName'=>'User','operator'=>'AND'},
                                                            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.DCDataId__c'},
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
        if(!userList.isEmpty()){
            List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
            lstACR = SSP_SharingBypassFetcher.fetchAuthRepDCId(userList[0].ContactId);
            if((!lstACR.isEmpty()) && lstACR[0] != null && lstACR[0].DCContactId__c != null){
                objResponse.put('dcDataId', lstACR[0].DCContactId__c);
            }
        }
        objResponse.put('loginUserDetails', userList);
        
        //MCI Call
        String sSourceIndividualIds = '';
        String sFullMatchLabel = SSP_GlobalConstants.FullMatch_Label;
        String sPartialMatchLabel = SSP_GlobalConstants.PartialMatch_Label;
        String sHBESystemLabel = SSP_GlobalConstants.HBE_System_Label;
        
        Contact objContact = new Contact();
        
        objContact.SuffixCode__c = mapClientParam.get('suffix') != null && mapClientParam.get('suffix') != '' ? String.valueOf(mapClientParam.get('suffix')) : null;
        objContact.FirstName = mapClientParam.get('firstName') != null && mapClientParam.get('firstName') != '' ? String.valueOf(mapClientParam.get('firstName')) : null;
        objContact.MiddleName = mapClientParam.get('middleName') != null && mapClientParam.get('middleName') != '' ? String.valueOf(mapClientParam.get('middleName')) : null;
        objContact.LastName = mapClientParam.get('lastName') != null && mapClientParam.get('lastName') != '' ? String.valueOf(mapClientParam.get('lastName')) : null;
        objContact.Birthdate = mapClientParam.get('birthDate') != null && mapClientParam.get('birthDate') != '' ? Date.valueOf(String.valueOf(mapClientParam.get('birthDate'))) : null;
        objContact.Gender__c = mapClientParam.get('gender') != null && mapClientParam.get('gender') != '' ? String.valueOf(mapClientParam.get('gender')) : null;
        objContact.ssn__c = mapClientParam.get('ssn') != null && mapClientParam.get('ssn') != '' ? String.valueOf(mapClientParam.get('ssn')) : null;
        
        //MCI Request
        SSP_MCIForBenefitRequestWrapper mciRequest = new SSP_MCIForBenefitRequestWrapper();
        mciRequest.con = objContact;
        Map<String, Object> mapInputParams = new Map<String, Object>();
        mapInputParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(mciRequest));
        List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_MCI_SERVICE_FOR_BENEFIT, mapInputParams);
        objResponse.put('logMessageResponse',slist); // Added as part of LOG_Message purpose
        //MCI Response
        if(slist != null && !slist.isEmpty()) {
            objMCIDetails.bIsFullMatch = false;
            objMCIDetails.bIsPartialMatch = false;
            objMCIDetails.bIsNoMatch = false;
            
            kyHbeMciDatacontracts.MciEntitySearchResponse entitySearchResponse = (kyHbeMciDatacontracts.MciEntitySearchResponse) slist[0];
            schemasDatacontractOrg200407KyHbe.ArrayOfEntitySearchResponse result = entitySearchResponse.Result;
            if(result != null) {
                List<schemasDatacontractOrg200407KyHbe.EntitySearchResponse> searchResponses = result.EntitySearchResponse;
                if(entitySearchResponse.IsRecordFound && searchResponses != null && !searchResponses.isEmpty()) {
                    objMCIDetails.bIsFullMatch = (searchResponses.size() == 1 && searchResponses[0].MatchStatus == sFullMatchLabel) ? true : false;
                    objMCIDetails.bIsPartialMatch = (searchResponses.size() > 1 || searchResponses[0].MatchStatus == sPartialMatchLabel) ? true : false;
                    
                    if(objMCIDetails.bIsFullMatch) {
                        //To get SourceIndividualId from SourceSystem
                        schemasDatacontractOrg200407KyHbe.EntitySearchResponse resp = searchResponses[0];
                        kyHbeMciDatacontracts.ArrayOfSourceSystem source = resp.Source;
                        List<kyHbeMciDatacontracts.SourceSystem> sourceSystems = source.SourceSystem;
                        for (kyHbeMciDatacontracts.SourceSystem objSourceSystem : sourceSystems) {
                            if(String.isNotBlank(objSourceSystem.SourceIndividualId) && String.isNotBlank(objSourceSystem.SourceSystemName) && objSourceSystem.SourceSystemName == sHBESystemLabel) {
                                lstSourceIndividualId.add(objSourceSystem.SourceIndividualId);
                            }
                        }
                        //Start - Defect: 385708, When Source System is not HBE 
                        if(!lstSourceIndividualId.isEmpty()) {
                            objMCIDetails.sSourceIndividualId = String.join(lstSourceIndividualId,';');
                        } else {
                            objMCIDetails.bIsFullMatch =false;
                            objMCIDetails.bIsNoMatch = true;
                        }
                        //End - Defect: 385708, When Source System is not HBE 
                    }
                } else if (!entitySearchResponse.IsRecordFound) {
                    objMCIDetails.bIsNoMatch = true;
                }
            } else if (!entitySearchResponse.IsRecordFound) {//385789
                    objMCIDetails.bIsNoMatch = true;
            }else { 
                objResponse.put('ERROR', 'Result key is Null'); 
            }
            objResponse.put('mciDetails', objMCIDetails);
            objResponse.put('sourceIndividualId', lstSourceIndividualId);
        } else {
            objResponse.put('ERROR', 'Empty Response'); 
        }
        
        return objResponse;
    }
    
    /*
	* method 		: reverseSSPDCService
	* @description  : This method is use to make a Reverse SSP DC Call to get the Client Case Details.
	* @author 		: Ashwin Kasture
    * @param 		: String sApplicationNumber - Contains Application Number.
    * @param        : String sCaseNumber - Contains Case Number.
    * @param        : String sSourceIndividualId - Contains Source Individual Id Number.
	* @return 		: Map<String, Object>
	* */
    public static Map<String, Object> reverseSSPDCService(String sSourceIndividualId, String sCaseNumber, String sRoleType) {
        Map<String, Object> objResponse = new Map<String, Object>();
        // Start - Reverse SSP DC Call
        if(String.isNotBlank(sSourceIndividualId) || String.isNotBlank(sCaseNumber)) {
            SSP_AuthRepAccessRequestCtrl.ReverseSSPDCResponseWrapper objRevSSPDCResp = new SSP_AuthRepAccessRequestCtrl.ReverseSSPDCResponseWrapper();
            List<SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper> lstCaseInfo = new List<SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper>();
            List<SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper> lstAuthRespAssissterInfo = new List<SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper>(); 
            //RSSP_DC Request
            //if(sRoleType == 'Assister' || sRoleType == 'Organization_Auth_Rep') { // Need to remove this before checkins //
                Map<String, Object> mapParams = new Map<String, Object>();
                SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName = SSP_InterfaceConstants.ASSISTER_AUTHREP_CLIENT_DETAILS;
                if(String.isNotBlank(sSourceIndividualId)) {
                    reqWrapper.primaryApplicationIndividualId = sSourceIndividualId;
                }
            	if(String.isNotBlank(sCaseNumber)) {
                    reqWrapper.caseNumber = Integer.valueOf(sCaseNumber);
                }
                reqWrapper.role = sRoleType == SSP_GlobalConstants.RoleType_Assister ? SSP_GlobalConstants.RoleType_Assister: SSP_GlobalConstants.RoleType_AuthRep;
                mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
                
                SSP_AssisterAuthRepDetailsPayloadWrapper objAuthRepPayLoad = responseWrapper.assisterAuthRepDetailsPayload;
                //Iterate on CaseInfo List	            
                if(objAuthRepPayLoad != null && objAuthRepPayLoad.CaseInfo != null && !objAuthRepPayLoad.CaseInfo.isEmpty()) {
                    for(SSP_AssisterAuthRepDetailsPayloadWrapper.CaseInfoWrapper objCase: objAuthRepPayLoad.CaseInfo) {
                        SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper objCaseInfo = new SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper();
                        objCaseInfo.CaseNumber = objCase.CaseNumber;
                        objCaseInfo.ProgramCode = objCase.ProgramCode;
                        objCaseInfo.LastUpdatedDate = objCase.LastUpdatedDate;

                        objCaseInfo.FirstName = objCase.FirstName;
                        objCaseInfo.LastName = objCase.LastName;
                        objCaseInfo.Email = objCase.Email;
                        objCaseInfo.PrimaryPhoneTypeCode = objCase.PrimaryPhoneTypeCode;
                        objCaseInfo.PrimaryPhoneNumber = objCase.PrimaryPhoneNumber;
                        objCaseInfo.PrimaryPhoneExetnsion = objCase.PrimaryPhoneExetnsion;
                        objCaseInfo.SecondaryPhoneTypeCode = objCase.SecondaryPhoneTypeCode;
                        objCaseInfo.SecondaryPhoneNumber = objCase.SecondaryPhoneNumber;
                        objCaseInfo.SecondaryPhoneExtension = objCase.SecondaryPhoneExtension;
                        objCaseInfo.PreferredWrittenLanguageCode = objCase.PreferredWrittenLanguageCode;
                        objCaseInfo.PreferredSpokenLanguageCode = objCase.PreferredSpokenLanguageCode;
                        objCaseInfo.PreferredNotificationMethodCode = objCase.PreferredNotificationMethodCode;
                        
                        lstCaseInfo.add(objCaseInfo);
                        
                    }
                    objRevSSPDCResp.CaseInfo = lstCaseInfo;
                }
                
                //Iterate on AuthrepandAssiterClientInfo List
                if(objAuthRepPayLoad != null && objAuthRepPayLoad.AuthrepandAssiterClientInfo != null && !objAuthRepPayLoad.AuthrepandAssiterClientInfo.isEmpty()) {
                    for(SSP_AssisterAuthRepDetailsPayloadWrapper.AuthrepandAssiterClientInfoWrapper objAuthRepInfo: objAuthRepPayLoad.AuthrepandAssiterClientInfo) {
                        SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper objAuthRespAssissterInfo = new SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper();
                        objAuthRespAssissterInfo.UserId = objAuthRepInfo.UserId;
                        objAuthRespAssissterInfo.CaseNumber = objAuthRepInfo.CaseNumber;
                        objAuthRespAssissterInfo.PermissionLevelCCAP = objAuthRepInfo.PermissionLevelCCAP;
                        objAuthRespAssissterInfo.PermissionLevelKIHIPP = objAuthRepInfo.PermissionLevelKIHIPP;
                        objAuthRespAssissterInfo.PermissionLevelKTAP= objAuthRepInfo.PermissionLevelKTAP;
                        objAuthRespAssissterInfo.PermissionLevelMedicaid= objAuthRepInfo.PermissionLevelMedicaid;
                        objAuthRespAssissterInfo.PermissionLevelSNAP = objAuthRepInfo.PermissionLevelSNAP;
                        objAuthRespAssissterInfo.PermissionLevelStateSupp = objAuthRepInfo.PermissionLevelStateSupp;
                        
                        objAuthRespAssissterInfo.Street = objAuthRepInfo.Street;
                        objAuthRespAssissterInfo.AddressLine2 = objAuthRepInfo.AddressLine2;
                        objAuthRespAssissterInfo.CountyCode = objAuthRepInfo.CountyCode;
                        objAuthRespAssissterInfo.SSP_State = objAuthRepInfo.SSP_State;
                        objAuthRespAssissterInfo.Zipcode5 = objAuthRepInfo.Zipcode5;
                        
                        objAuthRespAssissterInfo.Suffix = objAuthRepInfo.Suffix;
                        objAuthRespAssissterInfo.FirstName = objAuthRepInfo.FirstName;
                        objAuthRespAssissterInfo.MiddleName = objAuthRepInfo.MiddleName;
                        objAuthRespAssissterInfo.LastName = objAuthRepInfo.LastName;
                        objAuthRespAssissterInfo.Gender = objAuthRepInfo.Gender;
                        objAuthRespAssissterInfo.Email = objAuthRepInfo.Email;
                        objAuthRespAssissterInfo.Birthdate = objAuthRepInfo.Birthdate;
                        objAuthRespAssissterInfo.SSN = objAuthRepInfo.SSN;
                        objAuthRespAssissterInfo.RoleType = objAuthRepInfo.RoleType;
                        objAuthRespAssissterInfo.DCRepresentativeId = objAuthRepInfo.DCRepresentativeId;
                        objAuthRespAssissterInfo.isAuthRepVerified = objAuthRepInfo.isAuthRepVerified;
                        objAuthRespAssissterInfo.Phone = objAuthRepInfo.Phone;
                        objAuthRespAssissterInfo.PrimaryPhoneExtension = objAuthRepInfo.PrimaryPhoneExtension;
                        objAuthRespAssissterInfo.PreferredLanguageCode = objAuthRepInfo.PreferredLanguageCode;
                        objAuthRespAssissterInfo.OrgranizationIdentificationNumber = objAuthRepInfo.OrgranizationIdentificationNumber;
                        objAuthRespAssissterInfo.OrganizationName = objAuthRepInfo.OrganizationName;
                        objAuthRespAssissterInfo.OrganizationId = objAuthRepInfo.OrganizationId;
                        
                        lstAuthRespAssissterInfo.add(objAuthRespAssissterInfo);
                        
                    }
                    objRevSSPDCResp.AuthrepandAssiterClientInfo = lstAuthRespAssissterInfo;
                }
            objResponse.put('reverseSSPDCDetails', objRevSSPDCResp);
        }
        // End - Reverse SSP DC Call
        return objResponse;
    }

    /*
	* method 		: getApplnBasedOnIndividualId
	* @description  : This method is use to get Application records based on Individual Ids.
	* @author 		: Ashwin Kasture
    * @param        : String sSourceIndividualId - Contains Source Individual Id Number.
	* @return 		: Map<String, Object>
	* */
    public static List<SSP_ApplicationIndividual__c> getApplicationBasedOnIndividualId(String sSourceIndividualId, String sApplicationNumber) {
        Map<String, Object> objResponse = new Map<String, Object>();
        List<Integer> lstIndividualIds = new List<Integer>();
        List<String> lstContactIds = new List<String>();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        List<String> lstIndIds = sSourceIndividualId.split(';');
        for(String sIndInds: lstIndIds) {
            lstIndividualIds.add(Integer.valueOf(sIndInds));
        }
        
        List<Contact_Mapping__c> lstContactMapping = SSP_SharingBypassFetcher.fetchContactMappingRecordList(lstIndividualIds);
        /*List<Contact_Mapping__c> lstContactMapping = [SELECT Id, Contact__c, Group_Id__c, IEES_Id__c 
                                                      FROM Contact_Mapping__c
                                                      WHERE IEES_Id__c IN: lstIndividualIds];*/
        /* Commented this bcoz its not working for selector query
         * String sIndividualId = String.join(lstIndividualIds, ',');
        List<Contact_Mapping__c> lstContactMapping = SSP_SharingBypassFetcher.fetchRecords (
                                                                                               new Map<String, String>{'objectName'=>'Contact_Mapping__c','IN'=>'IEES_Id__c'}, 
                                                                                               new Set<String>{'Id','Contact__c','Group_Id__c','IEES_Id__c'},
                                                                                               new Map<String, String>{'IEES_Id__c'=> sIndividualId});*/
        
        
        
        for(Contact_Mapping__c objConMap: lstContactMapping) {
            lstContactIds.add(objConMap.Contact__c);
        }
        
        /*lstAppInd = [SELECT Id, SSP_Application__r.Name, SSP_Application__r.LastModifiedDate, SSP_Member__r.Contact__r.DCDataId__c, SSP_Application__r.ProgramsApplied__c,
                     SSP_Member__r.Contact__r.FirstName,SSP_Member__r.Contact__r.LastName, SSP_Member__r.Email__c,SSP_Member__r.PreferredNotificationMethodCode__c,
                     SSP_Member__r.PreferredWrittenLanguageCode__c,SSP_Member__r.PrimaryPhoneNumber__c,IsHeadOfHousehold__c,SSP_Application__r.Account__c
                     FROM SSP_ApplicationIndividual__c 
                     WHERE SSP_Member__r.Contact__c IN: lstContactIds AND SSP_Application__r.Name =: sApplicationNumber];*/
        
        String sContactIds = String.join(lstContactIds, ',');
        Set<String> allApplIndFieldSet = new Set<String>{'Id', 'SSP_Application__r.Name', 'SSP_Application__r.LastModifiedDate', 'SSP_Member__r.Contact__r.DCDataId__c', 
            											'SSP_Application__r.ProgramsApplied__c','SSP_Member__r.Contact__r.FirstName','SSP_Member__r.Contact__r.LastName', 
            											'SSP_Member__r.Email__c','SSP_Member__r.PreferredNotificationMethodCode__c','SSP_Member__r.PreferredWrittenLanguageCode__c',
            											'SSP_Member__r.PrimaryPhoneNumber__c','IsHeadOfHousehold__c','SSP_Application__r.Account__c'};

        Map<String, String> detailMap = new Map<String,String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','IN'=>'SSP_Member__r.Contact__c'};
        Map<String, String> conditionMap = new Map<String, String>{'SSP_Member__r.Contact__c'=>sContactIds,'SSP_Application__r.Name'=>sApplicationNumber};
        lstAppInd = SSP_SharingBypassFetcher.fetchRecords (detailMap,allApplIndFieldSet,conditionMap);
        
        return lstAppInd;
    }
    
    /*
	* method 		: requestAccess
	* @description  : This method is use to Request Case Access for a Citzen. And update the Address, Address Line2, Relationship details.
	* @author 		: Ashwin Kasture
	* @param 		: String sRequestAccessDetails
	* @return 		: static Map<String, Object>
	* */
    public static Map<String, Object> requestAccess (String sRequestAccessDetails) {
        
        Map<String, Object> objResponse = new Map<String, Object>();
        Map<String, Object> mapReqAccessDetails = (Map<String, Object>)JSON.deserializeUntyped(sRequestAccessDetails);
        Map<String, Object> objAccConRel = (Map<String, Object>)mapReqAccessDetails.get('accountContactRelation');
        String sCaseNumberParam = mapReqAccessDetails.get('caseNumber').toString();
        List<Object> lstUser = (List<Object>)mapReqAccessDetails.get('loginUserDetails');
        
        
        String sSourceIndifidualId = mapReqAccessDetails.get('sourceIndividualId')!= null ? mapReqAccessDetails.get('sourceIndividualId').toString():'';
        SSP_AuthRepAccessRequestCtrl.ReverseSSPDCResponseWrapper objReverseSSPDCResponse = (SSP_AuthRepAccessRequestCtrl.ReverseSSPDCResponseWrapper)
			JSON.deserialize(JSON.serialize(mapReqAccessDetails.get('reverseSSPDCResponse')), SSP_AuthRepAccessRequestCtrl.ReverseSSPDCResponseWrapper.class);
        
        //User objUser = [SELECT Id, ContactId FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
        List<User> userList = SSP_UserSelector.queryUserData (
                                                            new Map<String, String>{'objectName'=>'User','operator'=>'AND'},
                                                            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.DCDataId__c'},
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}
        );
		
		String loggedInRole = SSP_Utility.getSelectedRole();        
        List<AccountContactRelation> lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','Roles'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'Account.RecordType.DeveloperName'=>'Resource_Engine'}
                                                          );

        AccountContactRelation objCurrentUserACR = new AccountContactRelation();
        List<String> lstRoles = new List<String>();
        for(AccountContactRelation acr : lstCurrentUserACR){            
            if(acr.roles != null && acr.Roles.contains(';')){
                lstRoles = acr.Roles.split(';');
            }
            else{
                lstRoles.add(acr.roles);
            }
            if(!lstRoles.isEmpty() && lstRoles.contains(loggedInRole)){
                objCurrentUserACR = acr;
                break;
            }            
        }

        
        String sReqPrgm = '';
        String sCaseNumber = '';
        Boolean isPrgmExists = false;
        Boolean hasCasePrgmBoth = false;
        Boolean hasCase = false;
        Date dtLastUpdatedDate = null;
        List<String> setReqPrgm = new List<String>();
        
        SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper objLastUpdatedCase = null;
        SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper objCaseIndentified = null;
        SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper objCaseProgramIndentified = null;
        Map<String, SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper> mapCaseNumberVsCaseInfo = new Map<String, SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper>();
        Map<String, SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper> mapUserIdCaseNoVsAuthInfo = new Map<String, SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper>();
        Map<String, List<String>> mapCaseNumVsPrgms = new Map<String, List<String>>();
        
        if(objAccConRel.get('programPermission') != null) {
            Map<String, Object> mapProgramPermission = (Map<String, Object>)objAccConRel.get('programPermission');
            
            sReqPrgm = mapProgramPermission.get('PermissionLevel_Medicaid__c') != null ? SSP_GlobalConstants.MEDICAID+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_SNAP__c') != null ? SSP_GlobalConstants.SNAP+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_StateSupp__c') != null ? SSP_GlobalConstants.STATE+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_KIHIPP__c') != null ? SSP_GlobalConstants.KHIPP+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_KTAP__c') != null ? SSP_GlobalConstants.KTAP+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_CCAP__c') != null ? SSP_GlobalConstants.CHILDCARE+';' : '';            
        }
        
        if(String.isNotBlank(sReqPrgm)) {
            if(sReqPrgm.contains(';')) {
                setReqPrgm = sReqPrgm.split(';');
            } else {
                setReqPrgm.add(sReqPrgm);
            }
        }
        
		Set<String> setIndetifiedPrgm = new Set<String>();
        //Iterate on CaseInfo List
        if(objReverseSSPDCResponse != null && objReverseSSPDCResponse.CaseInfo != null && !objReverseSSPDCResponse.CaseInfo.isEmpty()) {
            for(SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper objCaseInfo: objReverseSSPDCResponse.CaseInfo) {
                List<String> setCasePrgm = new List<String>();
                //Split the RSSP_DC Programs
                if(objCaseInfo.ProgramCode != null && objCaseInfo.ProgramCode.contains(';')) {
                    setCasePrgm = objCaseInfo.ProgramCode.split(';');
                } else if(objCaseInfo.ProgramCode != null) {
                    setCasePrgm.add(objCaseInfo.ProgramCode);
                }
                
                //Find Requested program exists in RSSP_DC Programs
                if(!setCasePrgm.isEmpty()) {
					for(String sPrgm : setCasePrgm) {
                        //Condition to pick Case based on CaseNumber & Requested Programs
                        if(String.isNotBlank(sCaseNumberParam) && sCaseNumberParam.equals(objCaseInfo.CaseNumber) && setReqPrgm.contains(sPrgm)) {
                            objCaseProgramIndentified = new SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper();
                            objCaseProgramIndentified.CaseNumber = objCaseInfo.CaseNumber;
                            objCaseProgramIndentified.ProgramCode = objCaseInfo.ProgramCode;
                            objCaseProgramIndentified.LastUpdatedDate = objCaseInfo.LastUpdatedDate;
                            
                            objCaseProgramIndentified.FirstName = objCaseInfo.FirstName;
                            objCaseProgramIndentified.LastName = objCaseInfo.LastName;
                            objCaseProgramIndentified.Email = objCaseInfo.Email;
                            objCaseProgramIndentified.PreferredNotificationMethodCode = objCaseInfo.PreferredNotificationMethodCode;
                            objCaseProgramIndentified.PreferredWrittenLanguageCode = objCaseInfo.PreferredWrittenLanguageCode;
                            objCaseProgramIndentified.PrimaryPhoneNumber = objCaseInfo.PrimaryPhoneNumber;
                            mapCaseNumberVsCaseInfo.put(objCaseProgramIndentified.CaseNumber, objCaseProgramIndentified);
                            hasCasePrgmBoth = true;
                            setIndetifiedPrgm.add(sPrgm);
                            
                            if(mapCaseNumVsPrgms.containsKey(objCaseInfo.CaseNumber)) {
                                List<String> lstPrgms = mapCaseNumVsPrgms.get(objCaseInfo.CaseNumber);
                                lstPrgms.add(sPrgm);
                                mapCaseNumVsPrgms.put(objCaseInfo.CaseNumber, lstPrgms);
                            } else {
                                mapCaseNumVsPrgms.put(objCaseInfo.CaseNumber, new List<String> { sPrgm });
                            }
                        } 
                        //Condition to pick Case based on Requested Programs
                        else if(setReqPrgm.contains(sPrgm)) {
                            mapCaseNumberVsCaseInfo.put(objCaseInfo.CaseNumber, objCaseInfo);
                            setIndetifiedPrgm.add(sPrgm);
                            isPrgmExists = true;
                            
                            if(mapCaseNumVsPrgms.containsKey(objCaseInfo.CaseNumber)) {
                                List<String> lstPrgms = mapCaseNumVsPrgms.get(objCaseInfo.CaseNumber);
                                lstPrgms.add(sPrgm);
                                mapCaseNumVsPrgms.put(objCaseInfo.CaseNumber, lstPrgms);
                            } else {
                                mapCaseNumVsPrgms.put(objCaseInfo.CaseNumber, new List<String> { sPrgm });
                            }
                        }
                        //Condition to pick Case based on CaseNumber
                        /*else if(String.isNotBlank(sCaseNumberParam) && sCaseNumberParam.equals(objCaseInfo.CaseNumber)) {
                            objCaseIndentified = new SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper();
                            objCaseIndentified.CaseNumber = objCaseInfo.CaseNumber;
                            objCaseIndentified.ProgramCode = objCaseInfo.ProgramCode;
                            objCaseIndentified.LastUpdatedDate = objCaseInfo.LastUpdatedDate;
                        }*/
                    }   
                }
                
                //Condition to find Case number
                if(String.isNotBlank(sCaseNumberParam) && sCaseNumberParam.equals(objCaseInfo.CaseNumber)) {
                    objCaseIndentified = new SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper();
                    objCaseIndentified.CaseNumber = objCaseInfo.CaseNumber;
                    objCaseIndentified.ProgramCode = objCaseInfo.ProgramCode;
                    objCaseIndentified.LastUpdatedDate = objCaseInfo.LastUpdatedDate;
                    
                    objCaseIndentified.FirstName = objCaseInfo.FirstName;
                    objCaseIndentified.LastName = objCaseInfo.LastName;
                    objCaseIndentified.Email = objCaseInfo.Email;
                    objCaseIndentified.PreferredNotificationMethodCode = objCaseInfo.PreferredNotificationMethodCode;
                    objCaseIndentified.PreferredWrittenLanguageCode = objCaseInfo.PreferredWrittenLanguageCode;
                    objCaseIndentified.PrimaryPhoneNumber = objCaseInfo.PrimaryPhoneNumber;
                    hasCase = true;
                }
                
                //Condition to pick the Last Updated Case.
                if(dtLastUpdatedDate == null) {
                    objLastUpdatedCase = new SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper();
                    dtLastUpdatedDate = Date.valueOf(objCaseInfo.LastUpdatedDate);
                    objLastUpdatedCase.CaseNumber = objCaseInfo.CaseNumber;
                    objLastUpdatedCase.ProgramCode = objCaseInfo.ProgramCode;
                    objLastUpdatedCase.LastUpdatedDate = objCaseInfo.LastUpdatedDate;
                    objLastUpdatedCase.FirstName = objCaseInfo.FirstName;
                    objLastUpdatedCase.LastName = objCaseInfo.LastName;
                    objLastUpdatedCase.Email = objCaseInfo.Email;
                    objLastUpdatedCase.PreferredNotificationMethodCode = objCaseInfo.PreferredNotificationMethodCode;
                    objLastUpdatedCase.PreferredWrittenLanguageCode = objCaseInfo.PreferredWrittenLanguageCode;
                    objLastUpdatedCase.PrimaryPhoneNumber = objCaseInfo.PrimaryPhoneNumber;
                } else if(dtLastUpdatedDate != null && dtLastUpdatedDate < Date.valueOf(objCaseInfo.LastUpdatedDate)) {
                    dtLastUpdatedDate = Date.valueOf(objCaseInfo.LastUpdatedDate);
                    objLastUpdatedCase.CaseNumber = objCaseInfo.CaseNumber;
                    objLastUpdatedCase.ProgramCode = objCaseInfo.ProgramCode;
                    objLastUpdatedCase.LastUpdatedDate = objCaseInfo.LastUpdatedDate;
                    objLastUpdatedCase.FirstName = objCaseInfo.FirstName;
                    objLastUpdatedCase.LastName = objCaseInfo.LastName;
                    objLastUpdatedCase.Email = objCaseInfo.Email;
                    objLastUpdatedCase.PreferredNotificationMethodCode = objCaseInfo.PreferredNotificationMethodCode;
                    objLastUpdatedCase.PreferredWrittenLanguageCode = objCaseInfo.PreferredWrittenLanguageCode;
                    objLastUpdatedCase.PrimaryPhoneNumber = objCaseInfo.PrimaryPhoneNumber;
                }
            }
            
            //Put the Case Number which is entered
            if(!isPrgmExists && !hasCasePrgmBoth && objCaseIndentified != null) {
                mapCaseNumberVsCaseInfo.put(objCaseIndentified.CaseNumber, objCaseIndentified);
            }
            
            for(String sPrgm: setReqPrgm) {
                // Consider Case when hasCasePrgmBoth=true
                if(hasCasePrgmBoth && !setIndetifiedPrgm.contains(sPrgm)) {
                    mapCaseNumberVsCaseInfo.put(objCaseProgramIndentified.CaseNumber, objCaseProgramIndentified);
                    if(mapCaseNumVsPrgms.containsKey(objCaseProgramIndentified.CaseNumber)) {
                        List<String> lstPrgms = mapCaseNumVsPrgms.get(objCaseProgramIndentified.CaseNumber);
                        lstPrgms.add(sPrgm);
                        mapCaseNumVsPrgms.put(objCaseProgramIndentified.CaseNumber, lstPrgms);
                    } else {
                        mapCaseNumVsPrgms.put(objCaseProgramIndentified.CaseNumber, new List<String> { sPrgm });
                    }
                }
                // Consider Case when hasCasePrgmBoth=false & isPrgmExists=true
                else if(!setIndetifiedPrgm.contains(sPrgm)) {
                    //Link if Case number Found
                    if(hasCase) {
                        mapCaseNumberVsCaseInfo.put(objCaseIndentified.CaseNumber, objCaseIndentified);
                        if(mapCaseNumVsPrgms.containsKey(objCaseIndentified.CaseNumber)) {
                            List<String> lstPrgms = mapCaseNumVsPrgms.get(objCaseIndentified.CaseNumber);
                            lstPrgms.add(sPrgm);
                            mapCaseNumVsPrgms.put(objCaseIndentified.CaseNumber, lstPrgms);
                        } else {
                            mapCaseNumVsPrgms.put(objCaseIndentified.CaseNumber, new List<String> { sPrgm });
                        }
                    } 
                    //Link if Case number not found
                    else {
                    	mapCaseNumberVsCaseInfo.put(objLastUpdatedCase.CaseNumber, objLastUpdatedCase);
                        if(mapCaseNumVsPrgms.containsKey(objLastUpdatedCase.CaseNumber)) {
                            List<String> lstPrgms = mapCaseNumVsPrgms.get(objLastUpdatedCase.CaseNumber);
                            lstPrgms.add(sPrgm);
                            mapCaseNumVsPrgms.put(objLastUpdatedCase.CaseNumber, lstPrgms);
                        } else {
                            mapCaseNumVsPrgms.put(objLastUpdatedCase.CaseNumber, new List<String> { sPrgm });
                        }    
                    }                    
                }
            }
			
            
            
            
            
            
            
            
        }
            
        //Iterate on AuthrepandAssiterClientInfo List
        if(objReverseSSPDCResponse != null && objReverseSSPDCResponse.AuthrepandAssiterClientInfo != null && !objReverseSSPDCResponse.AuthrepandAssiterClientInfo.isEmpty()) {
            for(SSP_AuthRepAccessRequestCtrl.AuthrepandAssiterClientInfoWrapper objAuthRepInfo: objReverseSSPDCResponse.AuthrepandAssiterClientInfo) {
                if(objAuthRepInfo.UserId == String.valueOf(objCurrentUserACR.DCContactId__c) && mapCaseNumberVsCaseInfo.get(objAuthRepInfo.CaseNumber) != null) {
                    mapUserIdCaseNoVsAuthInfo.put(objAuthRepInfo.UserId+','+objAuthRepInfo.CaseNumber, objAuthRepInfo);
                }
            }
        }
        
        
        //Start - Insert/Update AccountContactRelation
        List<SSP_Application__c> lstNewCase = new List<SSP_Application__c>();
        List<SSP_Application__c> lstExistingCase = new List<SSP_Application__c>();
        
        List<AccountContactRelation> lstUpdateACR = new List<AccountContactRelation>();
        List<AccountContactRelation> lstExistingACR = new List<AccountContactRelation>();
        
        Map<String, SSP_Application__c> mapDCCaseNumberVsCase = new Map<String, SSP_Application__c>();
		List<Account> lstNewAccount = new List<Account>();
        List<String> lstExistingAccountIds = new List<String>();
        Map<String, String> mapAccConVSUserIdCase = new Map<String, String>();
        String sLoginContactIds = userList[0].ContactId;
        
        if(((String.isNotBlank(sCaseNumberParam) && hasCase) || (String.isBlank(sCaseNumberParam) && !hasCase)) && !mapCaseNumberVsCaseInfo.keySet().isEmpty()) {
            //List<Decimal> lstRevSspDcCaseNumber = new List<Decimal>(); //Need to remove before checkins
            //for (String strCaseNo: mapCaseNumberVsCaseInfo.keySet()) { //Need to remove before checkins
            //    lstRevSspDcCaseNumber.add(Decimal.valueOf(strCaseNo)); //Need to remove before checkins
            //} //Need to remove before checkins

            /*lstExistingCase = [Select Id, Account__c, DCCaseNumber__c, Account__r.CaseNumber__c
                               FROM  SSP_Application__c 
                               WHERE DCCaseNumber__c IN:lstRevSspDcCaseNumber AND RecordTypeId =: SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case')];*/ // Need to remove this before checkins
            
			List<Integer> lstRevSspDcCaseNumber = new List<Integer>();
            for (String strCaseNo: mapCaseNumberVsCaseInfo.keySet()) {
				lstRevSspDcCaseNumber.add(Integer.valueOf(strCaseNo));
            }
            lstExistingCase = SSP_SharingBypassFetcher.fetchRecords(
                                                                    new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND','IN'=>'DCCaseNumber__c'}, 
                                                                    new Set<String>{'Id','Account__c','DCCaseNumber__c','Account__r.CaseNumber__c'}, 
                                                                    new Map<String, String>{'DCCaseNumber__c'=> String.join(lstRevSspDcCaseNumber, ','), 'RecordTypeId'=>SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case')}
            );
            
            //Create Map of Case Number Vs Case
            if(!lstExistingCase.isEmpty()) {
            	for(SSP_Application__c objCase: lstExistingCase) {
                	mapDCCaseNumberVsCase.put(String.valueOf(objCase.DCCaseNumber__c), objCase);
                }
                
            }
            
            // Create Account List
            for(String sCaseNum: mapCaseNumberVsCaseInfo.keySet()) {
                if(mapDCCaseNumberVsCase.isEmpty() || (!mapDCCaseNumberVsCase.isEmpty() && mapDCCaseNumberVsCase.get(sCaseNum) == null)) {
                    
                    //Construct Application account
                    Account objAccount = new Account();
                    objAccount.Name = 'Application Account for ' + userList[0].Contact.FirstName + ' ' + userList[0].Contact.LastName;
                    objAccount.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
                    objAccount.CaseNumber__c = sCaseNum;
                    lstNewAccount.add(objAccount);
                } else if(!mapDCCaseNumberVsCase.isEmpty() && mapDCCaseNumberVsCase.get(sCaseNum) != null) {
                    
                    SSP_Application__c objApp = mapDCCaseNumberVsCase.get(sCaseNum);
                    lstExistingAccountIds.add(objApp.Account__c);
                    mapAccConVSUserIdCase.put(objApp.Account__c+','+userList[0].ContactId, objCurrentUserACR.DCContactId__c+','+objApp.Account__r.CaseNumber__c);
                }
            }
            
            //Start - Below code runs for new Case
            
            
            if(!lstNewAccount.isEmpty()) {
                //Creates Account and ACR to link that account and current user's contact
                List<String> lstAccountIds = new List<String>();
            	Map<String,object> mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(lstNewAccount, null, userList[0].ContactId);
                
                if(mapRestResult != null && mapRestResult.get('lstAccounts') != null) {
                    
                    List<Account> lstCreatedNewAccount = ((List<Account>)mapRestResult.get('lstAccounts'));
                    
                    for(Account objAccount: lstCreatedNewAccount) {
                        SSP_Application__c objCase = new SSP_Application__c();
                        objCase.Account__c =  objAccount.Id;
                        objCase.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
                        objCase.DCCaseNumber__c = Decimal.valueOf(objAccount.CaseNumber__c);
                        //objCase.ProgramsApplied__c = mapCaseNumberVsCaseInfo.get(objAccount.CaseNumber__c).ProgramCode;
                        lstNewCase.add(objCase);
                        lstAccountIds.add(objAccount.Id);
                        mapAccConVSUserIdCase.put(objAccount.Id+','+userList[0].ContactId, objCurrentUserACR.DCContactId__c+','+objAccount.CaseNumber__c);
                    }
                }
                
                if(!lstNewCase.isEmpty()) {
                	// Insert Case
                	SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstNewCase, 'insert', 'SSP_Application__c');
                    //lstNewCase = ESAPI.accessController().insertAsUser(lstNewCase, SSP_Utility.getFieldsNamesList (lstNewCase)).getInsertedObjects();
                	
                    
                    // Updated new ACR
                    Map<String, Object> mapNewACR = indentifyAndUpdateACRData(lstAccountIds, sLoginContactIds, mapAccConVSUserIdCase, objAccConRel, mapCaseNumVsPrgms, mapUserIdCaseNoVsAuthInfo, objCurrentUserACR);
                    lstUpdateACR = (List<AccountContactRelation>)mapNewACR.get('updatedACR');
                    if(!lstUpdateACR.isEmpty()) {
                        SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstUpdateACR, 'update', 'AccountContactRelation'); //Added DML bcoz it is failing to update.
                        //ESAPI.accessController().updateAsUser(lstUpdateACR, SSP_Utility.getFieldsNamesList (lstUpdateACR));
                        
                        
                        //Start - Send Notification Logic                	
                    	Map<String, Object> mapNotificationResp = sendNotificationMessage(sSourceIndifidualId, lstUpdateACR, mapCaseNumberVsCaseInfo, userList[0],null,null,objAccConRel); //Added extra objAccConRel for Tracker Defect-56
                    	objResponse.put('notificationId', mapNotificationResp.get('notificationId'));
                        objResponse.put('sProgramsPermission', mapNotificationResp.get('sProgramsPermission')); //Tracker Defect-56
                        objResponse.put('hasPendingRequest', mapNotificationResp.get('hasPendingRequest')); //Tracker Defect-56
                		//End - Send Notification Logic
                		
                    }                    
                    objResponse.put('newACR', lstUpdateACR);
                }
            }
			//End - Below code runs for new Case
			
            //Start - Below code runs for Existing Case
            if(!lstExistingAccountIds.isEmpty()) {
                // Updated Exsiting ACR
                Map<String, Object> mapUpdatedACR = indentifyAndUpdateACRData(lstExistingAccountIds, sLoginContactIds, mapAccConVSUserIdCase, objAccConRel, mapCaseNumVsPrgms, mapUserIdCaseNoVsAuthInfo, objCurrentUserACR);
                lstExistingACR = (List<AccountContactRelation>)mapUpdatedACR.get('updatedACR');
                List<AccountContactRelation> lstOldACR = (List<AccountContactRelation>)mapUpdatedACR.get('oldACR');
                if(!lstExistingACR.isEmpty()) {
                    SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstExistingACR, 'upsert', 'AccountContactRelation');
                    //ESAPI.accessController().updateAsUser(lstExistingACR, SSP_Utility.getFieldsNamesList (lstExistingACR));
                    
                    
                    //Start - Send Notification Logic //381488   
                        Map<String, Object> mapNotificationResp = sendNotificationMessage(sSourceIndifidualId, lstExistingACR, mapCaseNumberVsCaseInfo, userList[0],null,null,objAccConRel); //Added extra objAccConRel for Tracker Defect-56
                    	objResponse.put('notificationId', mapNotificationResp.get('notificationId'));
                        objResponse.put('sProgramsPermission', mapNotificationResp.get('sProgramsPermission')); //Tracker Defect-56
                        objResponse.put('hasPendingRequest', mapNotificationResp.get('hasPendingRequest')); //Tracker Defect-56
                	//End - Send Notification Logic
                }
                objResponse.put('updatedARC', lstExistingACR);
                objResponse.put('oldARC', lstOldACR);
                
                
            }
            //End - Below code runs for Existing Case
        }
        return objResponse;
    }
    
    /*
	* method 		: requestApplicationAccess
	* @description  : This method is use to Request Application Access for a Citzen. And update the Address, Address Line2, Relationship details.
	* @author 		: Ashwin Kasture
	* @return 		: Map<String, Object>
	* */
    public static Map<String, Object> requestApplicationAccess (String sRequestAccessDetails) {
        Map<String, Object> objResponse = new Map<String, Object>();
        Map<String, Object> mapReqAccessDetails = (Map<String, Object>)JSON.deserializeUntyped(sRequestAccessDetails);
        Map<String, Object> objAccConRel = (Map<String, Object>)mapReqAccessDetails.get('accountContactRelation');
        String sAppNumberParam = mapReqAccessDetails.get('applicationNumber').toString();
        List<Object> lstUser = (List<Object>)mapReqAccessDetails.get('loginUserDetails');
        
        
        String sSourceIndifidualId = mapReqAccessDetails.get('sourceIndividualId')!= null ? mapReqAccessDetails.get('sourceIndividualId').toString():'';
        List<SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper> lstApplicationResponse = (List<SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper>)JSON.deserialize(JSON.serialize(mapReqAccessDetails.get('applicationResponse')), List<SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper>.class);
        
        //User objUser = [SELECT Id, ContactId FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
        List<User> userList = SSP_UserSelector.queryUserData (
                                                            new Map<String, String>{'objectName'=>'User','operator'=>'AND'},
                                                            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.DCDataId__c'},
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}
        );
        String loggedInRole = SSP_Utility.getSelectedRole();        
        List<AccountContactRelation> lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','Roles'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'Account.RecordType.DeveloperName'=>'Resource_Engine'}
                                                          );  
        AccountContactRelation objCurrentUserACR = new AccountContactRelation();
        List<String> lstRoles = new List<String>();
        for(AccountContactRelation acr : lstCurrentUserACR){            
            if(acr.roles != null && acr.Roles.contains(';')){
                lstRoles = acr.Roles.split(';');
            }
            else{
                lstRoles.add(acr.roles);
            }
            if(!lstRoles.isEmpty() && lstRoles.contains(loggedInRole)){
                objCurrentUserACR = acr;
                break;
            }            
        }
		
        
        String sReqPrgm = '';
        String sCaseNumber = '';
        Boolean isPrgmExists = false;
        Boolean hasAppPrgmBoth = false;
        Boolean hasApp = false;
        Date dtLastUpdatedDate = null;
        List<String> setReqPrgm = new List<String>();
        
        
        SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper objLastUpdatedApp = null;
        SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper objAppIndentified = null;
        SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper objAppProgramIndentified = null;
        Map<String, SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper> mapAppNumberVsAppInfo = new Map<String, SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper>();
        Map<String, SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper> mapUserIdAppNoVsAuthInfo = new Map<String, SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper>();
        Map<String, List<String>> mapAppNumVsPrgms = new Map<String, List<String>>();
        
        if(objAccConRel.get('programPermission') != null) {
            Map<String, Object> mapProgramPermission = (Map<String, Object>)objAccConRel.get('programPermission');
            
            sReqPrgm = mapProgramPermission.get('PermissionLevel_Medicaid__c') != null ? SSP_GlobalConstants.MEDICAID+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_SNAP__c') != null ? SSP_GlobalConstants.SNAP+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_StateSupp__c') != null ? SSP_GlobalConstants.STATE+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_KIHIPP__c') != null ? SSP_GlobalConstants.KHIPP+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_KTAP__c') != null ? SSP_GlobalConstants.KTAP+';' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_CCAP__c') != null ? SSP_GlobalConstants.CHILDCARE+';' : '';            
        }
        if(String.isNotBlank(sReqPrgm)) {
            if(sReqPrgm.contains(';')) {
                setReqPrgm = sReqPrgm.split(';');
            } else {
                setReqPrgm.add(sReqPrgm);
            }
        }
        
        Set<String> setIndetifiedPrgm = new Set<String>();
        if(!lstApplicationResponse.isEmpty()) {
        	for(SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper objAppInfo: lstApplicationResponse) {
            	List<String> setAppPrgm = new List<String>();
                //Split the RSSP_DC Programs
                if(objAppInfo.ProgramCode.contains(';')) {
                    setAppPrgm = objAppInfo.ProgramCode.split(';');
                } else {
                    setAppPrgm.add(objAppInfo.ProgramCode);
                }
                
                //Find Requested program exists in RSSP_DC Programs
                if(!setAppPrgm.isEmpty()) {
                    for(String sPrgm : setAppPrgm) {
                        //Condition to pick Application based on ApplicationNumber & Requested Programs
                        if(String.isNotBlank(sAppNumberParam) && sAppNumberParam.equals(objAppInfo.ApplicationNumber) && setReqPrgm.contains(sPrgm)) {
                            objAppProgramIndentified = new SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper();
                            objAppProgramIndentified.ApplicationNumber = objAppInfo.ApplicationNumber;
                            objAppProgramIndentified.ProgramCode = objAppInfo.ProgramCode;
                            objAppProgramIndentified.LastUpdatedDate = objAppInfo.LastUpdatedDate;
                            
                            objAppProgramIndentified.FirstName = objAppInfo.FirstName;
                            objAppProgramIndentified.LastName = objAppInfo.LastName;
                            objAppProgramIndentified.Email = objAppInfo.Email;
                            objAppProgramIndentified.PreferredNotificationMethodCode = objAppInfo.PreferredNotificationMethodCode;
                            objAppProgramIndentified.PreferredWrittenLanguageCode = objAppInfo.PreferredWrittenLanguageCode;
                            objAppProgramIndentified.PrimaryPhoneNumber = objAppInfo.PrimaryPhoneNumber;
                            mapAppNumberVsAppInfo.put(objAppProgramIndentified.ApplicationNumber, objAppProgramIndentified);
                            hasAppPrgmBoth = true;
                            setIndetifiedPrgm.add(sPrgm);
                            
                            if(mapAppNumVsPrgms.containsKey(objAppInfo.ApplicationNumber)) {
                                List<String> lstPrgms = mapAppNumVsPrgms.get(objAppInfo.ApplicationNumber);
                                lstPrgms.add(sPrgm);
                                mapAppNumVsPrgms.put(objAppInfo.ApplicationNumber, lstPrgms);
                            } else {
                                mapAppNumVsPrgms.put(objAppInfo.ApplicationNumber, new List<String> { sPrgm });
                            }
                        } 
                        //Condition to pick Application based on Requested Programs
                        else if(setReqPrgm.contains(sPrgm)) {
                            mapAppNumberVsAppInfo.put(objAppInfo.ApplicationNumber, objAppInfo);
                            setIndetifiedPrgm.add(sPrgm);
                            isPrgmExists = true;
                            
                            if(mapAppNumVsPrgms.containsKey(objAppInfo.ApplicationNumber)) {
                                List<String> lstPrgms = mapAppNumVsPrgms.get(objAppInfo.ApplicationNumber);
                                lstPrgms.add(sPrgm);
                                mapAppNumVsPrgms.put(objAppInfo.ApplicationNumber, lstPrgms);
                            } else {
                                mapAppNumVsPrgms.put(objAppInfo.ApplicationNumber, new List<String> { sPrgm });
                            }
                        }
                        //Condition to pick Application based on ApplicationNumber
                        /*else if(String.isNotBlank(sAppNumberParam) && sAppNumberParam.equals(objAppInfo.ApplicationNumber)) {
                            objAppIndentified = new SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper();
                            objAppIndentified.ApplicationNumber = objAppInfo.ApplicationNumber;
                            objAppIndentified.ProgramCode = objAppInfo.ProgramCode;
                            objAppIndentified.LastUpdatedDate = objAppInfo.LastUpdatedDate;
                        }*/
                    }
            	}
                //Condition to find Application number
                if(String.isNotBlank(sAppNumberParam) && sAppNumberParam.equals(objAppInfo.ApplicationNumber)) {
                    hasApp = true;
                    objAppIndentified = new SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper();
                    objAppIndentified.ApplicationNumber = objAppInfo.ApplicationNumber;
                    objAppIndentified.ProgramCode = objAppInfo.ProgramCode;
                    objAppIndentified.LastUpdatedDate = objAppInfo.LastUpdatedDate;
                    
                    objAppIndentified.FirstName = objAppInfo.FirstName;
                    objAppIndentified.LastName = objAppInfo.LastName;
                    objAppIndentified.Email = objAppInfo.Email;
                    objAppIndentified.PreferredNotificationMethodCode = objAppInfo.PreferredNotificationMethodCode;
                    objAppIndentified.PreferredWrittenLanguageCode = objAppInfo.PreferredWrittenLanguageCode;
                    objAppIndentified.PrimaryPhoneNumber = objAppInfo.PrimaryPhoneNumber;
                }
                
                //Condition to pick the Last Updated Case.
                if(dtLastUpdatedDate == null) {
                    objLastUpdatedApp = new SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper();
                    dtLastUpdatedDate = Date.valueOf(objAppInfo.LastUpdatedDate);
                    objLastUpdatedApp.ApplicationNumber = objAppInfo.ApplicationNumber;
                    objLastUpdatedApp.ProgramCode = objAppInfo.ProgramCode;
                    objLastUpdatedApp.LastUpdatedDate = String.valueOf(Date.valueOf(objAppInfo.LastUpdatedDate));
                    
                    objLastUpdatedApp.FirstName = objAppInfo.FirstName;
                    objLastUpdatedApp.LastName = objAppInfo.LastName;
                    objLastUpdatedApp.Email = objAppInfo.Email;
                    objLastUpdatedApp.PreferredNotificationMethodCode = objAppInfo.PreferredNotificationMethodCode;
                    objLastUpdatedApp.PreferredWrittenLanguageCode = objAppInfo.PreferredWrittenLanguageCode;
                    objLastUpdatedApp.PrimaryPhoneNumber = objAppInfo.PrimaryPhoneNumber;
                } else if(dtLastUpdatedDate != null && dtLastUpdatedDate < Date.valueOf(objAppInfo.LastUpdatedDate)) {
                    dtLastUpdatedDate = Date.valueOf(objAppInfo.LastUpdatedDate);
                    objLastUpdatedApp.ApplicationNumber = objAppInfo.ApplicationNumber;
                    objLastUpdatedApp.ProgramCode = objAppInfo.ProgramCode;
                    objLastUpdatedApp.LastUpdatedDate = String.valueOf(Date.valueOf(objAppInfo.LastUpdatedDate));
                    
                    objLastUpdatedApp.FirstName = objAppInfo.FirstName;
                    objLastUpdatedApp.LastName = objAppInfo.LastName;
                    objLastUpdatedApp.Email = objAppInfo.Email;
                    objLastUpdatedApp.PreferredNotificationMethodCode = objAppInfo.PreferredNotificationMethodCode;
                    objLastUpdatedApp.PreferredWrittenLanguageCode = objAppInfo.PreferredWrittenLanguageCode;
                    objLastUpdatedApp.PrimaryPhoneNumber = objAppInfo.PrimaryPhoneNumber;
                }
                
                //Iterate on AuthrepandAssiterClientInfo List
                if(objAppInfo.UserId == String.valueOf(objCurrentUserACR.DCContactId__c)) {
                    mapUserIdAppNoVsAuthInfo.put(objAppInfo.UserId+','+objAppInfo.ApplicationNumber, objAppInfo);
                }
        	}
            //Put the Application Number which is entered
            if(!isPrgmExists && !hasAppPrgmBoth && objAppIndentified != null) {
                mapAppNumberVsAppInfo.put(objAppIndentified.ApplicationNumber, objAppIndentified);
            }
            
            for(String sPrgm: setReqPrgm) {
                // Consider App when hasCasePrgmBoth=true
                if(hasAppPrgmBoth && !setIndetifiedPrgm.contains(sPrgm)) {
                    mapAppNumberVsAppInfo.put(objAppProgramIndentified.ApplicationNumber, objAppProgramIndentified);
                    if(mapAppNumVsPrgms.containsKey(objAppProgramIndentified.ApplicationNumber)) {
                        List<String> lstPrgms = mapAppNumVsPrgms.get(objAppProgramIndentified.ApplicationNumber);
                        lstPrgms.add(sPrgm);
                        mapAppNumVsPrgms.put(objAppProgramIndentified.ApplicationNumber, lstPrgms);
                    } else {
                        mapAppNumVsPrgms.put(objAppProgramIndentified.ApplicationNumber, new List<String> { sPrgm });
                    }
                }
                // Consider Application when hasAppPrgmBoth=false & isPrgmExists=true
                else if(!setIndetifiedPrgm.contains(sPrgm)) {
                    //Link if Application number Found
                    if(hasApp) {
                        mapAppNumberVsAppInfo.put(objAppIndentified.ApplicationNumber, objAppIndentified);
                        if(mapAppNumVsPrgms.containsKey(objAppIndentified.ApplicationNumber)) {
                            List<String> lstPrgms = mapAppNumVsPrgms.get(objAppIndentified.ApplicationNumber);
                            lstPrgms.add(sPrgm);
                            mapAppNumVsPrgms.put(objAppIndentified.ApplicationNumber, lstPrgms);
                        } else {
                            mapAppNumVsPrgms.put(objAppIndentified.ApplicationNumber, new List<String> { sPrgm });
                        }
                    } 
                    //Link if Application number not found
                    else {
                        mapAppNumberVsAppInfo.put(objLastUpdatedApp.ApplicationNumber, objLastUpdatedApp);
                        if(mapAppNumVsPrgms.containsKey(objLastUpdatedApp.ApplicationNumber)) {
                            List<String> lstPrgms = mapAppNumVsPrgms.get(objLastUpdatedApp.ApplicationNumber);
                            lstPrgms.add(sPrgm);
                            mapAppNumVsPrgms.put(objLastUpdatedApp.ApplicationNumber, lstPrgms);
                        } else {
                            mapAppNumVsPrgms.put(objLastUpdatedApp.ApplicationNumber, new List<String> { sPrgm });
                        }    
                    }                    
                }
            }
            
            
            
            
            
            
            
            
            
        }
        
        List<SSP_Application__c> lstExistingApp = new List<SSP_Application__c>();
        Map<String, SSP_Application__c> mapDCAppNumberVsApp = new Map<String, SSP_Application__c>();
        List<String> lstExistingAccountIds = new List<String>();
        Map<String, String> mapAccConVSUserIdApp = new Map<String, String>();
        List<AccountContactRelation> lstExistingACR = new List<AccountContactRelation>();
        String sLoginContactIds = userList[0].ContactId;
        
        if(((String.isNotBlank(sAppNumberParam) && hasApp) || (String.isBlank(sAppNumberParam) && !hasApp)) && !mapAppNumberVsAppInfo.keySet().isEmpty()) {
            /*lstExistingApp = [Select Id, Name, Account__c, DCCaseNumber__c, Account__r.CaseNumber__c
                               FROM  SSP_Application__c 
                               WHERE Name IN: mapAppNumberVsAppInfo.keySet() AND RecordTypeId =: SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Application')];*/ // Need to remove this before checkins
            
			List<Integer> lstRevSspDcAppNumber = new List<Integer>();
            for (String strAppNo: mapAppNumberVsAppInfo.keySet()) {
				lstRevSspDcAppNumber.add(Integer.valueOf(strAppNo));
            }
            lstExistingApp = SSP_SharingBypassFetcher.fetchRecords(
                                                                    new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND','IN'=>'Name'}, 
                                                                    new Set<String>{'Id','Name','Account__c','DCCaseNumber__c','Account__r.CaseNumber__c'}, 
                                                                    new Map<String, String>{'Name'=> String.join(lstRevSspDcAppNumber, ','), 'RecordTypeId'=>SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','SSP_Application')});

            
            //Create Map of App Number Vs App
            if(!lstExistingApp.isEmpty()) {
            	for(SSP_Application__c objApp: lstExistingApp) {
                	mapDCAppNumberVsApp.put(String.valueOf(objApp.Name), objApp);
                }
                
            }
            
            // Create Account List
            for(String sAppNum: mapAppNumberVsAppInfo.keySet()) {
                if(!mapDCAppNumberVsApp.isEmpty() && mapDCAppNumberVsApp.get(sAppNum) != null) {
                    
                    SSP_Application__c objApp = mapDCAppNumberVsApp.get(sAppNum);
                    lstExistingAccountIds.add(objApp.Account__c);
                    mapAccConVSUserIdApp.put(objApp.Account__c+','+userList[0].ContactId, objCurrentUserACR.DCContactId__c+','+objApp.Name);
                }
            }
            
            
            //Start - Below code runs for Existing Case
            if(!lstExistingAccountIds.isEmpty()) {
                // Updated Exsiting ACR
                Map<String, Object> mapExistingACR = indentifyAndUpdateACRData(lstExistingAccountIds, sLoginContactIds, mapAccConVSUserIdApp, objAccConRel, mapAppNumVsPrgms, null, objCurrentUserACR);
                lstExistingACR = (List<AccountContactRelation>)mapExistingACR.get('updatedACR');
                if(!lstExistingACR.isEmpty()) {
                    SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstExistingACR, 'upsert', 'AccountContactRelation');
                    //ESAPI.accessController().upsertAsUser(lstExistingACR, SSP_Utility.getFieldsNamesList (lstExistingACR));
                    
                    
                    //Start - Send Notification Logic                	
                    Map<String, Object> mapNotificationResp = sendNotificationMessage(sSourceIndifidualId, lstExistingACR, null, userList[0], mapAppNumberVsAppInfo, mapAccConVSUserIdApp,objAccConRel); //Added extra objAccConRel for Tracker Defect-56
                    objResponse.put('notificationId', mapNotificationResp.get('notificationId'));
                    objResponse.put('sProgramsPermission', mapNotificationResp.get('sProgramsPermission')); //Tracker Defect-56
                    objResponse.put('hasPendingRequest', mapNotificationResp.get('hasPendingRequest')); //Tracker Defect-56
                	//End - Send Notification Logic
                }
                objResponse.put('updatedARC', lstExistingACR);
            }
            //End - Below code runs for Existing Case
        }
        return objResponse;
    }
    
    /*
	* method 		: indentifyAndUpdateACRData
	* @description  : This method is use to Indentify and Update the ACR Data.
	* @author 		: Ashwin Kasture
	* @return 		: List<AccountContactRelation>
	* */
    public static Map<String, Object> indentifyAndUpdateACRData(List<String> lstAccountIds,
                                                                         String sLoginContactIds, 
                                                                         Map<String, String> mapAccConVSUserIdCase,
                                                                         Map<String, Object> objAccConRel,
                                                                         Map<String, List<String>> mapCaseNumVsPrgms,
                                                                Map<String, SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper> mapUserIdCaseNoVsAuthInfo,
                                                               AccountContactRelation objCurrentUserACR) {
		Map<String, Object> mapResponse = new Map<String, Object>();
        List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation>();
        List<AccountContactRelation> lstOldACR = new List<AccountContactRelation>();
		List<AccountContactRelation> lstUpdateACR = new List<AccountContactRelation>();
		Map<String, Object> mapAddressDetails = (Map<String, Object>)objAccConRel.get('addressDetails');
                                                                             
        /*lstAccountContact = [SELECT Id, AccountId, Account.CaseNumber__c, PermissionLevel_Medicaid__c, PermissionLevel_SNAP__c, PermissionLevel_StateSupp__c,PermissionLevel_KTAP__c,PermissionLevel_KIHIPP__c,PermissionLevel_CCAP__c,ProgramsApplied__c,RequestAccessPermission__c
                            FROM AccountContactRelation 
                            WHERE AccountId IN: lstAccountIds AND ContactId =: sLoginContactIds];*/
		
        String sAccountIds = String.join(lstAccountIds, ',');
        lstAccountContact = SSP_SharingBypassFetcher.fetchRecords(
                                                                    new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND','IN'=>'AccountId'}, 
                                                                    new Set<String>{'Id','AccountId','Account.CaseNumber__c' ,'PermissionLevel_Medicaid__c','PermissionLevel_SNAP__c','PermissionLevel_StateSupp__c','PermissionLevel_KIHIPP__c', 'PermissionLevel_KTAP__c','PermissionLevel_CCAP__c','ProgramsApplied__c','RequestAccessPermission__c'},
                                                                    new Map<String, String>{'AccountId'=>sAccountIds, 'ContactId'=>sLoginContactIds});
        lstOldACR = lstAccountContact.deepClone();
		mapResponse.put('oldACR', lstOldACR);
		
		
		//Start - To Create New ACR
		if(lstAccountContact.isEmpty()){
            for(String sAccId :lstAccountIds) {
                if(mapAccConVSUserIdCase.get(sAccId+','+sLoginContactIds) == null || mapAccConVSUserIdCase.get(sAccId+','+sLoginContactIds) != '') {
                    AccountContactRelation objACR = new AccountContactRelation();
                    objACR.AccountId = sAccId;
                    objACR.ContactId = sLoginContactIds;
                    
                    objACR.Roles = SSP_Utility.getSelectedRole();
                    objACR.DCContactId__c = objCurrentUserACR.DCContactId__c;
                	objACR.DCAgencyId__c = objCurrentUserACR.Account.DCDataId__c;
                    lstAccountContact.add(objACR);
                }
            }
            
        }
		//End - To Create New ACR
        //Update Existing ACR
        for(AccountContactRelation objAccCon :lstAccountContact) {
            
            
            String sUserIdWithCase = mapAccConVSUserIdCase.get(objAccCon.AccountId+','+sLoginContactIds);
            List<String> lstUserIdWithCase = String.isNotBlank(sUserIdWithCase) ? sUserIdWithCase.split(',') : new List<String>();
            String sUserId = !lstUserIdWithCase.isEmpty() ? lstUserIdWithCase[0] : '';
            String sCaseNo = !lstUserIdWithCase.isEmpty() ? lstUserIdWithCase[1] : '';
            
            
            if(objAccConRel.get('RepresentativeRelationshipCode__c') != null && objAccConRel.get('RepresentativeRelationshipCode__c') != '') {
            	objAccCon.RepresentativeRelationshipCode__c = String.valueOf(objAccConRel.get('RepresentativeRelationshipCode__c'));
            }
            //Start - When Login Auth Rep found in RSSPDC reponse then update its permission
            if(mapAccConVSUserIdCase.get(objAccCon.AccountId+','+sLoginContactIds) != null && mapAccConVSUserIdCase.get(objAccCon.AccountId+','+sLoginContactIds) != '') {
                String sUserIdCase = mapAccConVSUserIdCase.get(objAccCon.AccountId+','+sLoginContactIds);
                SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper objAuthRepInfo = mapUserIdCaseNoVsAuthInfo!= null ? mapUserIdCaseNoVsAuthInfo.get(sUserIdCase):null;
                
                //Update the Roles

                objAccCon.Roles = SSP_Utility.getSelectedRole();
                objAccCon.DCContactId__c = objCurrentUserACR.DCContactId__c;
                objAccCon.DCAgencyId__c = objCurrentUserACR.Account.DCDataId__c;
                //Start - Update Permission On ACR
                if(objAuthRepInfo != null && String.isNotBlank(objAuthRepInfo.PermissionLevelStateSupp)) {
                    objAccCon.PermissionLevel_StateSupp__c = objAuthRepInfo.PermissionLevelStateSupp;
                    objAccCon.ProgramsApplied__c = objAccCon.ProgramsApplied__c!=null && !objAccCon.ProgramsApplied__c.contains(SSP_GlobalConstants.STATE) ? (objAccCon.ProgramsApplied__c + ';' + SSP_GlobalConstants.STATE) : SSP_GlobalConstants.STATE;
                }
                if(objAuthRepInfo != null && String.isNotBlank(objAuthRepInfo.PermissionLevelSNAP)) {
                    objAccCon.PermissionLevel_SNAP__c = objAuthRepInfo.PermissionLevelSNAP;
                    objAccCon.ProgramsApplied__c = objAccCon.ProgramsApplied__c!=null && !objAccCon.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP) ? (objAccCon.ProgramsApplied__c + ';' + SSP_GlobalConstants.SNAP) : SSP_GlobalConstants.SNAP;
                }
                if(objAuthRepInfo != null && String.isNotBlank(objAuthRepInfo.PermissionLevelMedicaid)) {
                    objAccCon.PermissionLevel_Medicaid__c = objAuthRepInfo.PermissionLevelMedicaid;
                    objAccCon.ProgramsApplied__c = objAccCon.ProgramsApplied__c!=null && !objAccCon.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID) ? (objAccCon.ProgramsApplied__c + ';' + SSP_GlobalConstants.MEDICAID) : SSP_GlobalConstants.MEDICAID;
                }
                if(objAuthRepInfo != null && String.isNotBlank(objAuthRepInfo.PermissionLevelKTAP)) {
                    objAccCon.PermissionLevel_KTAP__c = objAuthRepInfo.PermissionLevelKTAP;
                    objAccCon.ProgramsApplied__c = objAccCon.ProgramsApplied__c!=null && !objAccCon.ProgramsApplied__c.contains(SSP_GlobalConstants.KTAP) ? (objAccCon.ProgramsApplied__c + ';' + SSP_GlobalConstants.KTAP) : SSP_GlobalConstants.KTAP;
                }
                if(objAuthRepInfo != null && String.isNotBlank(objAuthRepInfo.PermissionLevelKIHIPP)) {
                    objAccCon.PermissionLevel_KIHIPP__c = objAuthRepInfo.PermissionLevelKIHIPP;
                    objAccCon.ProgramsApplied__c = objAccCon.ProgramsApplied__c!=null && !objAccCon.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP) ? (objAccCon.ProgramsApplied__c + ';' + SSP_GlobalConstants.KHIPP) : SSP_GlobalConstants.KHIPP;
                }
                if(objAuthRepInfo != null && String.isNotBlank(objAuthRepInfo.PermissionLevelCCAP)) {
                    objAccCon.PermissionLevel_CCAP__c = objAuthRepInfo.PermissionLevelCCAP;
                    objAccCon.ProgramsApplied__c = objAccCon.ProgramsApplied__c!=null && !objAccCon.ProgramsApplied__c.contains(SSP_GlobalConstants.CHILD_CARE_CODE) ? (objAccCon.ProgramsApplied__c + ';' + SSP_GlobalConstants.CHILD_CARE_CODE) : SSP_GlobalConstants.CHILD_CARE_CODE;
                }
                //End - Update Permission On ACR
                
                //Start - Update Address On ACR
                Contact objContact;                
                if(mapAddressDetails.get('Street__c') != null && mapAddressDetails.get('Street__c') != '') {
                    objAccCon.Street__c = String.valueOf(mapAddressDetails.get('Street__c'));
                }
                if(mapAddressDetails.get('AddressLine2__c') != null && mapAddressDetails.get('AddressLine2__c') !='') {
                    objAccCon.AddressLine2__c = String.valueOf(mapAddressDetails.get('AddressLine2__c'));
                }
                if(mapAddressDetails.get('City__c') != null && mapAddressDetails.get('City__c') != '') {
                    objAccCon.City__c = String.valueOf(mapAddressDetails.get('City__c'));
                }
                if(mapAddressDetails.get('CountyCode__c') != null && mapAddressDetails.get('CountyCode__c') != '') {
                    objAccCon.CountyCode__c = String.valueOf(mapAddressDetails.get('CountyCode__c'));
                }
                if(mapAddressDetails.get('SSP_State__c') != null && mapAddressDetails.get('SSP_State__c') != '') {
                    objAccCon.SSP_State__c = String.valueOf(mapAddressDetails.get('SSP_State__c'));
                }
                if(mapAddressDetails.get('Zipcode4__c') != null && mapAddressDetails.get('Zipcode4__c') != '') {
                    objAccCon.ZipCode4__c = String.valueOf(mapAddressDetails.get('Zipcode4__c'));
                }
                if(mapAddressDetails.get('Zipcode5__c') != null && mapAddressDetails.get('Zipcode5__c') != '') {
                    objAccCon.ZipCode5__c = String.valueOf(mapAddressDetails.get('Zipcode4__c'));
                }
                //End - Update Address On ACR
            }
            //End - When Login Auth Rep found in RSSPDC reponse then update its permission
            
            // Start - Set Requested permission according to Programs And remove Existing permission
            
                        
            
            //Start - Tracker Defect-56
            String sOldReqPer = objAccCon.RequestAccessPermission__c;
            Map<String, Object> mapOldReqPer = new Map<String, Object>();
            if(String.isNotBlank(sOldReqPer)) {
                mapOldReqPer = (Map<String, Object>)JSON.deserializeUntyped(sOldReqPer);
            }
            //End - Tracker Defect-56
            if(objAccConRel.get('programPermission') != null && mapCaseNumVsPrgms.get(sCaseNo) != null && !mapCaseNumVsPrgms.get(sCaseNo).isEmpty()) {
                Map<String, Object> mapPrgVsPermission = (Map<String, Object>)objAccConRel.get('programPermission');
                List<String> lstPrgm = mapCaseNumVsPrgms.get(sCaseNo);
                String sPrograms = String.join(lstPrgm, ',');
                
                JSONGenerator generator = JSON.createGenerator(true);
                generator.writeStartObject();
                if(mapPrgVsPermission.get('PermissionLevel_Medicaid__c') != null && objAccCon.PermissionLevel_Medicaid__c != mapPrgVsPermission.get('PermissionLevel_Medicaid__c').toString() && sPrograms.contains('MA')) {
                    generator.writeStringField('PermissionLevel_Medicaid__c', mapPrgVsPermission.get('PermissionLevel_Medicaid__c').toString());
                }
                //Start - Tracker Defect-56
                else if(mapOldReqPer != null && mapOldReqPer.get('PermissionLevel_Medicaid__c') != null && objAccCon.PermissionLevel_Medicaid__c != mapOldReqPer.get('PermissionLevel_Medicaid__c').toString()) {
                    generator.writeStringField('PermissionLevel_Medicaid__c', mapOldReqPer.get('PermissionLevel_Medicaid__c').toString());
                }
                //End - Tracker Defect-56
                if(mapPrgVsPermission.get('PermissionLevel_SNAP__c') != null && objAccCon.PermissionLevel_SNAP__c != mapPrgVsPermission.get('PermissionLevel_SNAP__c').toString() && sPrograms.contains('SN')) {
                    generator.writeStringField('PermissionLevel_SNAP__c', mapPrgVsPermission.get('PermissionLevel_SNAP__c').toString());
                }
                //Start - Tracker Defect-56
                else if(mapOldReqPer != null && mapOldReqPer.get('PermissionLevel_SNAP__c') != null && objAccCon.PermissionLevel_SNAP__c != mapOldReqPer.get('PermissionLevel_SNAP__c').toString()) {
                    generator.writeStringField('PermissionLevel_SNAP__c', mapOldReqPer.get('PermissionLevel_SNAP__c').toString());
                }
                //End - Tracker Defect-56
                if(mapPrgVsPermission.get('PermissionLevel_StateSupp__c') != null && objAccCon.PermissionLevel_StateSupp__c != mapPrgVsPermission.get('PermissionLevel_StateSupp__c').toString() && sPrograms.contains('SS')) {
                    generator.writeStringField('PermissionLevel_StateSupp__c', mapPrgVsPermission.get('PermissionLevel_StateSupp__c').toString());
                }
                //Start - Tracker Defect-56
                else if(mapOldReqPer != null && mapOldReqPer.get('PermissionLevel_StateSupp__c') != null && objAccCon.PermissionLevel_StateSupp__c != mapOldReqPer.get('PermissionLevel_StateSupp__c').toString()) {
                    generator.writeStringField('PermissionLevel_StateSupp__c', mapOldReqPer.get('PermissionLevel_StateSupp__c').toString());
                }
                //End - Tracker Defect-56
                if(mapPrgVsPermission.get('PermissionLevel_KIHIPP__c') != null && objAccCon.PermissionLevel_KIHIPP__c != mapPrgVsPermission.get('PermissionLevel_KIHIPP__c') && sPrograms.contains('KP')) {
                    generator.writeStringField('PermissionLevel_KIHIPP__c', mapPrgVsPermission.get('PermissionLevel_KIHIPP__c').toString());
                }
                //Start - Tracker Defect-56
                else if(mapOldReqPer != null && mapOldReqPer.get('PermissionLevel_KIHIPP__c') != null && objAccCon.PermissionLevel_KIHIPP__c != mapOldReqPer.get('PermissionLevel_KIHIPP__c').toString()) {
                    generator.writeStringField('PermissionLevel_KIHIPP__c', mapOldReqPer.get('PermissionLevel_KIHIPP__c').toString());
                }
                //End - Tracker Defect-56
                if(mapPrgVsPermission.get('PermissionLevel_KTAP__c') != null && objAccCon.PermissionLevel_KTAP__c != mapPrgVsPermission.get('PermissionLevel_KTAP__c').toString() && sPrograms.contains('KT')) {
                    generator.writeStringField('PermissionLevel_KTAP__c', mapPrgVsPermission.get('PermissionLevel_KTAP__c').toString());
                }
                //Start - Tracker Defect-56
                else if(mapOldReqPer != null && mapOldReqPer.get('PermissionLevel_KTAP__c') != null && objAccCon.PermissionLevel_KTAP__c != mapOldReqPer.get('PermissionLevel_KTAP__c').toString()) {
                    generator.writeStringField('PermissionLevel_KTAP__c', mapOldReqPer.get('PermissionLevel_KTAP__c').toString());
                }
                //End - Tracker Defect-56
                if(mapPrgVsPermission.get('PermissionLevel_CCAP__c') != null && objAccCon.PermissionLevel_CCAP__c != mapPrgVsPermission.get('PermissionLevel_CCAP__c').toString() && sPrograms.contains('CC')) {
                    generator.writeStringField('PermissionLevel_CCAP__c', mapPrgVsPermission.get('PermissionLevel_CCAP__c').toString());
                }
                //Start - Tracker Defect-56
                else if(mapOldReqPer != null && mapOldReqPer.get('PermissionLevel_CCAP__c') != null && objAccCon.PermissionLevel_CCAP__c != mapOldReqPer.get('PermissionLevel_CCAP__c').toString()) {
                    generator.writeStringField('PermissionLevel_CCAP__c', mapOldReqPer.get('PermissionLevel_CCAP__c').toString());
                }
                //End - Tracker Defect-56
                generator.writeEndObject();
                String jsonPermissionString = generator.getAsString();
                //Start- Tracker Defect-111
                if(String.isNotBlank(jsonPermissionString)){
                    Map<String, Object> mapReqPer = (Map<String, Object>)JSON.deserializeUntyped(jsonPermissionString);
                    objAccCon.RequestAccessPermission__c = (mapReqPer!=null && !mapReqPer.isEmpty()) ? jsonPermissionString : null;
                }
                //End - Tracker Defect-111
                objAccCon.IsRepresentativeVerified__c = 'N';
            }
            // End - Set Requested permission according to Programs And remove Existing permission
            lstUpdateACR.add(objAccCon);
        }
        mapResponse.put('updatedACR', lstUpdateACR); //Added outside loop for Tracker Defect-111
        return mapResponse;
    }
    
    /*
	* method 		: sendNotificationMessage
	* @description  : This method is use to Send Notification messages.
	* @author 		: Ashwin Kasture
	* @return 		: Map<String, Object>
	* */
    public static Map<String, Object> sendNotificationMessage(String sSourceIndifidualId, 
                                                              List<AccountContactRelation> lstExistingACR, 
                                                              Map<String, SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper> mapCaseNumberVsCaseInfo,
                                                              User objNonCitizenUser,
                                                              Map<String, SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper> mapAppNumberVsAppInfo,
                                                              Map<String, String> mapAccConVSUserIdApp,
                                                              Map<String, Object> objAccConRel) {
        Map<String, Object> objResponse = new Map<String, Object>();
		
		
		
		
		
		
        List<String> lstACRIds = new List<String>();
		String sProgramsPermission = '';
        for(AccountContactRelation objACR :lstExistingACR) {
            lstACRIds.add(objACR.Id);
            sProgramsPermission = removeExistingPermission(objACR, objAccConRel); //Tracker Defect-56
        }
        if(String.isNotBlank(sProgramsPermission)) { //Added this condition for Tracker Defect-111
		String sACRIds = String.join(lstACRIds,';');
		
		// Start - Split program and permission Logic
		String sReqPrgm = '';
		String sProgramVsPermision = '';
		Map<String, Object> mapProgramPermission = (Map<String, Object>)JSON.deserializeUntyped(sProgramsPermission);
		
		
			//Program MA,SN,SS
            sReqPrgm = mapProgramPermission.get('PermissionLevel_Medicaid__c') != null ?  SSP_GlobalConstants.MA_Label+',' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_SNAP__c') != null ? SSP_GlobalConstants.SN_Label+',' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_StateSupp__c') != null ? SSP_GlobalConstants.SS_Label+',' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_KIHIPP__c') != null ? SSP_GlobalConstants.KP_Label+',' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_KTAP__c') != null ? SSP_GlobalConstants.KT_Label+',' : '';
            sReqPrgm += mapProgramPermission.get('PermissionLevel_CCAP__c') != null ? SSP_GlobalConstants.CC_Label+',' : '';
			sReqPrgm = sReqPrgm.removeEnd(',');
            //Permision MA-SE,SN-SS
            // fix 380489
            map<string,string> permissionAPIToLabelMap = new map<string,string>{'ST'=>'Apply, Report Changes, Recertify','NT'=>'Apply, Report Changes, Recertify and receive copy of Notices','SE'=>'Apply, Report Changes, Recertify and use EBT Card','CC'=>'Apply, Report Change, Recertify and receive checks made out to client','CA'=>'Apply, Report Change, Recertify and receive checks','ET'=>'Use EBT Card','PY'=>'Statutory Benefit Payee'};
			sProgramVsPermision = mapProgramPermission.get('PermissionLevel_Medicaid__c') != null ? SSP_GlobalConstants.MA_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_Medicaid__c'))+'<br/>' : '';
            sProgramVsPermision += mapProgramPermission.get('PermissionLevel_SNAP__c') != null ? SSP_GlobalConstants.SN_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_SNAP__c'))+'<br/>' : '';
            sProgramVsPermision += mapProgramPermission.get('PermissionLevel_StateSupp__c') != null ? SSP_GlobalConstants.SS_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_StateSupp__c'))+'<br/>' : '';
            sProgramVsPermision += mapProgramPermission.get('PermissionLevel_KIHIPP__c') != null ? SSP_GlobalConstants.KP_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_KIHIPP__c'))+'<br/>' : '';
            sProgramVsPermision += mapProgramPermission.get('PermissionLevel_KTAP__c') != null ? SSP_GlobalConstants.KT_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_KTAP__c'))+'<br/>' : '';
            sProgramVsPermision += mapProgramPermission.get('PermissionLevel_CCAP__c') != null ? SSP_GlobalConstants.CC_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_CCAP__c'))+'<br/>' : '';
		// End - Split program and permission Logic
        
        //create notification logic
        String identifier = SSP_GlobalConstants.SF_TOD_002;
        map<string,object> mapInputData = new map<string,object>();
        mapInputData.put('recipientId', sSourceIndifidualId);
        mapInputData.put('recipientType', 'Citizen_Individual');
        mapInputData.put('acrId', sACRIds);
		
		//Condition for Case
		if(mapCaseNumberVsCaseInfo != null) {
            SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper objCaseInfo = mapCaseNumberVsCaseInfo.get(lstExistingACR[0].Account.CaseNumber__c);
            if(objCaseInfo != null) {
            	
                mapInputData.put('preferredCommunication', objCaseInfo.PreferredNotificationMethodCode);
                mapInputData.put('preferredWrittenLanguageCode', objCaseInfo.PreferredWrittenLanguageCode);
                mapInputData.put('phone', objCaseInfo.PrimaryPhoneNumber);
                mapInputData.put('email', objCaseInfo.Email);
                mapInputData.put('citizenFirstName', objCaseInfo.FirstName);
                mapInputData.put('nameCitizen', objCaseInfo.LastName);                                                    
            }		
        }
		
		//Condition for Application
        if(mapAppNumberVsAppInfo != null) {
        	String sUserIdWithCase = mapAccConVSUserIdApp != null ? mapAccConVSUserIdApp.get(lstExistingACR[0].AccountId+','+objNonCitizenUser.ContactId):'';
        	List<String> lstUserIdWithCase = String.isNotBlank(sUserIdWithCase) ? sUserIdWithCase.split(',') : new List<String>();
        	String sUserId = !lstUserIdWithCase.isEmpty() ? lstUserIdWithCase[0] : '';
        	String sAppNo = !lstUserIdWithCase.isEmpty() ? lstUserIdWithCase[1] : '';
        	
        	
            
            SSP_AuthRepAccessRequestCtrl.ApplicationInfoWrapper objAppInfo = mapAppNumberVsAppInfo.get(sAppNo);
			
            if(objAppInfo != null) {
            	mapInputData.put('preferredCommunication', objAppInfo.PreferredNotificationMethodCode);
            	mapInputData.put('preferredWrittenLanguageCode', objAppInfo.PreferredWrittenLanguageCode);
            	mapInputData.put('phone', objAppInfo.PrimaryPhoneNumber);
            	mapInputData.put('email', objAppInfo.Email);
            	mapInputData.put('citizenFirstName', objAppInfo.FirstName);
            	mapInputData.put('nameCitizen', objAppInfo.LastName);    
            }
    	}

        mapInputData.put('nameNonCitizen',  objNonCitizenUser.Contact.FirstName+' '+objNonCitizenUser.Contact.LastName);
        mapInputData.put('programs', sReqPrgm);
        mapInputData.put('permissions',sProgramVsPermision);
        //Start - Added program API for Tracker Defect-56
        mapInputData.put('requestPermission', sProgramsPermission);
        objResponse.put('sProgramsPermission', sProgramsPermission);
        Boolean hasPendingRequest=false;
        String sToDoRecTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Notifications__c','To_Do');
        Map<String, Object> mapNewReqPer = new Map<String, Object>(mapProgramPermission);
        Map<String, Object> mapRemoveNewReqPerMatch = new Map<String, Object>(mapNewReqPer);
        List<SSP_Notifications__c> lstUpdateNotification = new List<SSP_Notifications__c>();
        
        SSP_Message_Center_Configuration__mdt objMsgConfig = [SELECT Id, Code__c,Body__c,Body_Spanish__c FROM SSP_Message_Center_Configuration__mdt WHERE DeveloperName =:SSP_GlobalConstants.SF_TOD_002 LIMIT 1];
        List<SSP_Notifications__c> lstNotification = [SELECT Id,Status__c,Linked_Record_Id__c,Notification_Body__c,Notification_Body_Es__c,notificationCode__c,RequestAccessPermission__c FROM SSP_Notifications__c WHERE Linked_Record_Id__c IN: lstACRIds AND recipientId__c =: sSourceIndifidualId AND Status__c =: SSP_GlobalConstants.NOTIFICATION_ACTIVE AND notificationCode__c =: objMsgConfig.Code__c AND RecordTypeId =: sToDoRecTypeId AND RequestAccessPermission__c!=null];
        if(mapNewReqPer != null && !mapNewReqPer.isEmpty() && !lstNotification.isEmpty()) {
            for (SSP_Notifications__c objNotif : lstNotification) {
                Boolean isPrgExistsToRemove = false;
                Map<String, Object> mapOldReqPer = (Map<String, Object>)JSON.deserializeUntyped(objNotif.RequestAccessPermission__c);
                for(String sPrg: mapNewReqPer.keySet()) {
                    //Search for same prgm & same permission and remove it to check already has access
                    if(!mapNewReqPer.isEmpty() && mapOldReqPer!=null && !mapOldReqPer.isEmpty() && mapOldReqPer.get(sPrg)!=null && mapNewReqPer.get(sPrg).toString() == mapOldReqPer.get(sPrg).toString()) {
                        mapRemoveNewReqPerMatch.remove(sPrg);
                    }
                    //Search for same prgm but any permission and remove it (old MA-NT will stay and new MA-NT will created bcoz not all same prgm & per exists)
                    if(!mapNewReqPer.isEmpty() && mapOldReqPer!=null && !mapOldReqPer.isEmpty() && mapOldReqPer.get(sPrg)!=null) {
                        mapOldReqPer.remove(sPrg);
                        isPrgExistsToRemove=true;
                    }
                    //Expire notification when no more prgm & permission exists
                    if(mapOldReqPer.isEmpty()) {
                        objNotif.Status__c = SSP_GlobalConstants.NOTIFICATION_EXPIRED;
                        lstUpdateNotification.add(objNotif);
                        break;
                    }
                }
                //To update notification
                if(isPrgExistsToRemove && !mapOldReqPer.isEmpty()) {
                    objNotif.Notification_Body__c = String.format(objMsgConfig.Body__c, new List<String>{(String)mapInputData.get('nameNonCitizen'), getRequestProgramLabels(mapOldReqPer)});
                    objNotif.Notification_Body_Es__c = String.format(objMsgConfig.Body_Spanish__c, new List<String>{(String)mapInputData.get('nameNonCitizen'),getRequestProgramLabels(mapOldReqPer)});
                    objNotif.RequestAccessPermission__c=JSON.serialize(mapOldReqPer);
                    lstUpdateNotification.add(objNotif);
                }
            }
        }

        if(mapRemoveNewReqPerMatch!=null && mapRemoveNewReqPerMatch.isEmpty()) {
            objResponse.put('hasPendingRequest',true);
            hasPendingRequest=true;
        } else if(mapRemoveNewReqPerMatch!=null && !mapRemoveNewReqPerMatch.isEmpty() && !lstUpdateNotification.isEmpty()) {
            update lstUpdateNotification;
        }
        
        if(!hasPendingRequest) { //Added this condition for Tracker Defect-56
            Map<String, Object> returnValue = SSP_MessageCenterService.processNotificationMessage(identifier, mapInputData);
            Object sNotificationId = returnValue.get('notificationId');
            objResponse.put('notificationId',sNotificationId);
        } //Added this condition for Tracgker Defect-56
        //End - Added program API for Tracker Defect-56
        } //Added this condition for Tracker Defect-111
        return objResponse;
    }
    
    /*
	* method 		: showClientProgramPermission
	* @description  : This method is use to View the Program Permission Details.
	* @author 		: Ashwin Kasture
	* @return 		: Map<String, Object>
	* */
    public static Map<String, Object> showClientProgramPermission (String sNotificationDetails) {
        Map<String, Object> mapNotificationDetails = (Map<String, Object>)JSON.deserializeUntyped(sNotificationDetails);
        List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation>();
        //Fix for 382061-MY_INFORMATION
        List<SSP_Member__c> lstApplInd = new List<SSP_Member__c>();
        Map<String, Object> objResponse = new Map<String, Object>();
        List<String> lstACRId = new List<String>();
        
        Map<String,String> mapPemissionPicklistValues = SSP_Utility.getPickListValues('AccountContactRelation', 'PermissionLevel_Medicaid__c', null);
        Map<String,String> mapSuffixLabelValues = SSP_Utility.getPickListValues('SSP_Application__c', 'ApplicationEsignSuffixCode__c', null);
        String sNotificationId = mapNotificationDetails.get('notificationId').toString();
        List<SSP_Notifications__c> lstNotification = SSP_SharingBypassFetcher.fetchRecords (
                                                                                               new Map<String, String>{'objectName'=>'SSP_Notifications__c','IN'=>'Id'}, 
                                                                                               new Set<String>{'Id','recipientId__c','Linked_Record_Id__c','Case_Number__c','Notification_Body__c','Notification_Body_Es__c','RequestAccessPermission__c'},
                                                                                               new Map<String, String>{'Id'=> sNotificationId}); //Tracker Defect-56 Added 'Notification_Body__c','Notification_Body_Es__c','RequestAccessPermission__c' fields
        if(!lstNotification.isEmpty()) {
            for(SSP_Notifications__c objNotif : lstNotification) {
                if(objNotif.Linked_Record_Id__c.contains(',')) {
                    lstACRId  = objNotif.Linked_Record_Id__c.split(',');
                } else {
                    lstACRId.add(objNotif.Linked_Record_Id__c);
                }
            }
        }
		// To get the ACR
        if(!lstACRId.isEmpty()) {
        	String sACRIds = String.join(lstACRId, ',');
        	lstAccountContact = SSP_SharingBypassFetcher.fetchRecords(
                                                                        new Map<String, String>{'objectName'=>'AccountContactRelation','IN'=>'Id'}, 
                                                                        new Set<String>{'Id','AccountId','RequestAccessPermission__c','Contact.FirstName', 'Contact.LastName'},
                														new Map<String, String>{'Id'=> sACRIds});
            
        }
        
        //Fix for 382061-MY_INFORMATION
        String primaryIndId = ssp_utility.getIndividualId();
        lstApplInd = SSP_SharingBypassFetcher.fetchRecords(
                                                        new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                        new Set<String>{'Id','FirstName__c', 'LastName__c','MiddleInitial__c','SuffixCode__c','IsHeadOfHousehold__c'},
                                                        new Map<String, String>{'IndividualId__c'=> primaryIndId});
        
        objResponse.put('notificationDetails', lstNotification); //Tracker Defect-56
        objResponse.put('loginUserLanguage', UserInfo.getLanguage()); //Tracker Defect-56
        objResponse.put('accountContactList', lstAccountContact);
        objResponse.put('permissionPicklistValues', mapPemissionPicklistValues);
        objResponse.put('applicationIndividuals', lstApplInd);
        objResponse.put('timeTravelDate', SSP_Utility.today());
        objResponse.put('suffixLabelValue', mapSuffixLabelValues);
        return objResponse;
    }
    
    /*
	* method 		: getExistingACR
	* @description  : This method is use to get the Existing ACR data.
	* @author 		: Ashwin Kasture
	* @return 		: List<AccountContactRelation>
	* */
    public static List<AccountContactRelation> getExistingACR(List<String> lstAccountIds, String sContactId) {
        List<AccountContactRelation> lstAccountContact  = new List<AccountContactRelation> ();
        /*lstAccountContact = [SELECT Id, AccountId, ContactId, Contact.DCDataId__c, PermissionLevel_Medicaid__c, PermissionLevel_SNAP__c, PermissionLevel_StateSupp__c,
                             PermissionLevel_KTAP__c, PermissionLevel_KIHIPP__c, PermissionLevel_CCAP__c, ProgramsApplied__c, RequestAccessPermission__c,
                             RepresentativeRelationshipCode__c, Street__c, AddressLine2__c, City__c, CountyCode__c, SSP_State__c, Zipcode5__c
                             FROM AccountContactRelation 
                             WHERE AccountId IN: lstAccountIds AND ContactId =: sContactId];*/
        String sAccountIds = String.join(lstAccountIds, ',');
        Set<String> setACRFields = new Set<String>{'Id','AccountId','ContactId','Contact.DCDataId__c','PermissionLevel_Medicaid__c','PermissionLevel_SNAP__c','PermissionLevel_StateSupp__c',
                                    'PermissionLevel_KIHIPP__c', 'PermissionLevel_KTAP__c','PermissionLevel_CCAP__c','ProgramsApplied__c','RequestAccessPermission__c','RepresentativeRelationshipCode__c',
                                    'Street__c','AddressLine2__c','City__c','CountyCode__c','SSP_State__c','Zipcode5__c'}; 
        lstAccountContact = SSP_SharingBypassFetcher.fetchRecords(
                                new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND','IN'=>'AccountId'}, 
                                setACRFields,
                                new Map<String, String>{'AccountId'=> sAccountIds, 'ContactId'=> sContactId});
        
        return lstAccountContact;
    }
    
    	/*
	* method 		: getRequestAccessPermission
	* @description  : This method is used to get the Request Access Permission
	* @author 		: Priyamvada Chundawat
	* @return 		: String
	* */
    @AuraEnabled
	public static SSP_LightningResponse getRequestAccessPermission(String appId) {
        String requestAccessPermission = '';
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<AccountContactRelation> lstCurrentUserACR =  new List<AccountContactRelation>();
         List<SSP_Application__c> lstApplication = new  List<SSP_Application__c>();
        List<SSP_Member__c> lstMember = new List<SSP_Member__c>();
        List<SSP_ApplicationIndividual__c> lstAppl = SSP_SharingBypassFetcher.fetchRecords(
                                                           new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                           new Set<String>{'Id','SSP_Application__r.Account__c','SSP_Member__c'},
                							               new Map<String, String>{'SSP_Application__c'=> appId,'IsHeadOfHousehold__c'=>'true'});
        if((!lstAppl.isEmpty()) && lstAppl[0].SSP_Member__c != null){
        lstMember = SSP_SharingBypassFetcher.fetchRecords(
                                                           new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                           new Set<String>{'Id','PreferredNotificationMethodCode__c'},
                							               new Map<String, String>{'Id'=> lstAppl[0].SSP_Member__c});
        }
    	List<User> userList = SSP_UserSelector.queryUserData (
                                                            new Map<String, String>{'objectName'=>'User','operator'=>'AND'},
                                                            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.DCDataId__c','selectedRole__c'},
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
        if(lstAppl.isEmpty()){
            lstApplication = SSP_SharingBypassFetcher.fetchRecords(
                                                           new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                           new Set<String>{'Id','Account__c'},
                							               new Map<String, String>{'Id'=> appId});
            
        }
        
        if(!lstAppl.isEmpty()){
       lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','RequestAccessPermission__c','ProgramsApplied__c'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'AccountId'=>lstAppl[0].SSP_Application__r.Account__c});
        }else if(!lstApplication.isEmpty()){
             lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','RequestAccessPermission__c','ProgramsApplied__c'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'AccountId'=>lstApplication[0].Account__c});
        }
        if(lstCurrentUserACR != null && lstCurrentUserACR.size() > 0  && lstCurrentUserACR[0].RequestAccessPermission__c != null ) {                                                
			objResponse.put('requestPermission', lstCurrentUserACR[0].RequestAccessPermission__c);
           
        }
      
        if((!userList.isEmpty()) && userList[0].selectedRole__c != null && SSP_GlobalConstants.AUTH_REP_ROLES.contains( userList[0].selectedRole__c)) {                                                
			objResponse.put('isAuthRep', true);
           
        }
         if((lstCurrentUserACR != null && lstCurrentUserACR.size() > 0)) {                                                
			objResponse.put('hasAccess', true);
           
        }
          if((!lstMember.isEmpty()) && lstMember[0] != null  && lstMember[0].PreferredNotificationMethodCode__c != null
            && (lstMember[0].PreferredNotificationMethodCode__c == 'EE' || lstMember[0].PreferredNotificationMethodCode__c == 'ES')){
           objResponse.put('electronicConsent', true);
          }
        return objResponse;
  
    }
    
    //Start - Added as part of Tracker Defect-56
    /*
	* method 		: getRequestProgramLabels
	* @description  : This method is use to set the programs labels for notification body.
	* @author 		: Ashwin Kasture
	* @return 		: String
	* */
    public static String getRequestProgramLabels(Map<String, Object> mapProgramPermission) {
        String sReqPrgm='';
        sReqPrgm = mapProgramPermission.get('PermissionLevel_Medicaid__c') != null ?  SSP_GlobalConstants.MA_Label+',' : '';
        sReqPrgm += mapProgramPermission.get('PermissionLevel_SNAP__c') != null ? SSP_GlobalConstants.SN_Label+',' : '';
        sReqPrgm += mapProgramPermission.get('PermissionLevel_StateSupp__c') != null ? SSP_GlobalConstants.SS_Label+',' : '';
        sReqPrgm += mapProgramPermission.get('PermissionLevel_KIHIPP__c') != null ? SSP_GlobalConstants.KP_Label+',' : '';
        sReqPrgm += mapProgramPermission.get('PermissionLevel_KTAP__c') != null ? SSP_GlobalConstants.KT_Label+',' : '';
        sReqPrgm += mapProgramPermission.get('PermissionLevel_CCAP__c') != null ? SSP_GlobalConstants.CC_Label+',' : '';
        sReqPrgm = sReqPrgm.removeEnd(',');
        return sReqPrgm;
    }
    //End - Added as part of Tracker Defect-56

    //Start - Added as part of Tracker Defect-56
    /*
	* method 		: removeExistingPermission
	* @description  : This method is use to remove existing permission.
	* @author 		: Ashwin Kasture
	* @return 		: String
	* */
    public static String removeExistingPermission(AccountContactRelation objAccCon, Map<String, Object> objAccConRel) {
        String sProgramsPermission = '';
        if(objAccConRel!=null && objAccConRel.get('programPermission') != null) {
            Map<String, Object> mapPrgVsPermission = (Map<String, Object>)objAccConRel.get('programPermission');
            system.debug('mapPrgVsPermission-'+mapPrgVsPermission);
            if(mapPrgVsPermission.get('PermissionLevel_Medicaid__c') != null && objAccCon.PermissionLevel_Medicaid__c!=null && objAccCon.PermissionLevel_Medicaid__c == mapPrgVsPermission.get('PermissionLevel_Medicaid__c').toString()) {
                mapPrgVsPermission.remove('PermissionLevel_Medicaid__c');
            }

            if(mapPrgVsPermission.get('PermissionLevel_SNAP__c') != null && objAccCon.PermissionLevel_SNAP__c!=null && objAccCon.PermissionLevel_SNAP__c == mapPrgVsPermission.get('PermissionLevel_SNAP__c').toString()) {
                mapPrgVsPermission.remove('PermissionLevel_SNAP__c');
            }

            if(mapPrgVsPermission.get('PermissionLevel_StateSupp__c') != null && objAccCon.PermissionLevel_StateSupp__c!=null && objAccCon.PermissionLevel_StateSupp__c == mapPrgVsPermission.get('PermissionLevel_StateSupp__c').toString()) {
                mapPrgVsPermission.remove('PermissionLevel_StateSupp__c');
            }

            if(mapPrgVsPermission.get('PermissionLevel_KIHIPP__c') != null && objAccCon.PermissionLevel_KIHIPP__c!=null && objAccCon.PermissionLevel_KIHIPP__c == mapPrgVsPermission.get('PermissionLevel_KIHIPP__c').toString()) {
                mapPrgVsPermission.remove('PermissionLevel_KIHIPP__c');
            }

            if(mapPrgVsPermission.get('PermissionLevel_KTAP__c') != null && objAccCon.PermissionLevel_KTAP__c!=null && objAccCon.PermissionLevel_KTAP__c == mapPrgVsPermission.get('PermissionLevel_KTAP__c').toString()) {
                mapPrgVsPermission.remove('PermissionLevel_KTAP__c');
            }

            if(mapPrgVsPermission.get('PermissionLevel_CCAP__c') != null && objAccCon.PermissionLevel_CCAP__c!=null && objAccCon.PermissionLevel_CCAP__c == mapPrgVsPermission.get('PermissionLevel_CCAP__c').toString()) {
               mapPrgVsPermission.remove('PermissionLevel_CCAP__c');
            }
            sProgramsPermission = mapPrgVsPermission != null && !mapPrgVsPermission.isEmpty() ? JSON.serialize(mapPrgVsPermission):'';
        }
        return sProgramsPermission;
    }
    //End - Added as part of Tracker Defect-56
}