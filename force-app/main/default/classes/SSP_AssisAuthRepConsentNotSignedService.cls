/*
* classname 	: SSP_AssisAuthRepConsentNotSignedService
* @description 	: This class is used for assister & auth rep access consent not signed from client
* @author 		: Rahul Kumar
* @date 		: 13th June 2020
* MODIFICATION LOG
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Rahul Kumar 		13th June 2020	   Initial Version
*/
public without sharing class SSP_AssisAuthRepConsentNotSignedService {
    
    /*
	* method 		: updateAccountContactRelation
	* @description  : This method is used for updating the request permission for Assister and Auth rep 
					  in case of no consent received.
	* @author 		: Rahul Kumar
	* @return 		: string 
	*/
    @AuraEnabled
    public static String updateAccountContactRelation(string snotificationId, boolean citizenConsent)
    {
        Id idUser = UserInfo.getUserId();
       	String result = '';
        try{
            List<User> userList = SSP_UserSelector.queryUserData (
                new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.IndividualId__c','Contact.Phone'}, 
                new Map<String, String>{'limit'=>'1','Id'=>UserInfo.getuserId()}
            );
            
            List<SSP_Notifications__c> lstNotifications = new List<SSP_Notifications__c>();
            if(String.isNotBlank(snotificationId)) {            
                lstNotifications = SSP_MessageCenterWithoutSharingService.fetchNotifications(snotificationId);
            }
            set<String> setLinkedId = new set<String>();
            if(lstNotifications!=null && lstNotifications.size()>0){
                List<String> lstLinkdedRec = lstNotifications[0].Linked_Record_Id__c.split(';');
                for(String recId:lstLinkdedRec){
                    setLinkedId.add(recId);
                }
            }
            List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation>();        
            if(lstNotifications.size()>0) {            
                lstAccountContact=  [SELECT Id, StartDate, AccountId, ContactId, Roles, ProgramsApplied__c, PermissionLevel_Medicaid__c, PermissionLevel_SNAP__c, PermissionLevel_StateSupp__c, PermissionLevel_KIHIPP__c, PermissionLevel_KTAP__c, PermissionLevel_CCAP__c, RequestAccessPermission__c, RepresentativeRelationshipCode__c 
                                     ,CountyCode__c,Zipcode5__c,Zipcode4__c,AddressLine2__c,Street__c,City__c,SSP_State__c,dcAgencyId__c,dcContactId__c,DCRepresentativeId__c,IsRepresentativeVerified__c FROM AccountContactRelation where Id IN:setLinkedId];
            }  
           	String nonCitizenRole = '';
            Set<String> setAccId = new Set<String>();
            Set<String> setConId = new Set<String>();
            for(AccountContactRelation acrRecord:lstAccountContact){
                setAccId.add(acrRecord.AccountId);
                setConId.add(acrRecord.ContactId);
				nonCitizenRole = acrRecord.Roles;                
            }
            if(nonCitizenRole == SSP_GlobalConstants.AGENCY_ADMIN_ROLE){
                nonCitizenRole = SSP_GlobalConstants.ASSISTER_ROLE;
            }
            // SSP Application Query
            List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
            List<Contact> lstContacts = new List<Contact>();
            Map<String, SSP_Application__c> mapApplications = new Map<String, SSP_Application__c>();
            Map<String, Contact> mapContacts = new Map<String, Contact>();
            Map<String,String> mapAssisterOrgId = new Map<String,String>();
            Map<String,String> mapAssisterContactId = new Map<String,String>();
            Map<String,String> mapAuthRepOrgId = new Map<String,String>();
            Map<String,String> mapAuthRepContactId = new Map<String,String>();
            if(lstAccountContact.size()>0){
                lstApplications = [Select Id, Account__c, DCCaseNumber__c, ProgramsApplied__c,name,CreatedByID
                                   FROM  SSP_Application__c where Account__c IN:setAccId];
                for(SSP_Application__c app : lstApplications){
                    mapApplications.put(app.Account__c, app);
                }
                //Contact Query            
                lstContacts = [SELECT Id, Name, DCDataId__c,IndividualId__c from contact where Id IN:setConId];
                for(Contact con : lstContacts){
                    mapContacts.put(con.Id, con);
                }
                                
                List<AccountContactRelation> lstOrgACR = [Select AccountId,ContactId, DCContactId__c, Account.DCDataId__c, Account.RecordType.DeveloperName, Roles
                                                          from AccountContactRelation
                                                          where ContactId IN :setConId and Account.RecordType.DeveloperName = 'Resource_Engine'];
                
                for(AccountContactRelation acr : lstOrgACR){
                    List<String> lstRoles = new List<String>();

                    if(acr.roles != null && acr.Roles.contains(';')){
                        lstRoles = acr.Roles.split(';');
                    }
                    else{
                        lstRoles.add(acr.roles);
                    }
                    if(!lstRoles.isEmpty() && lstRoles.contains(nonCitizenRole)){
                        if((acr.DCContactId__c!=null && !mapAssisterContactId.containsKey(acr.ContactId)) && 
                           (acr.Account.DCDataId__c!=null && !mapAssisterOrgId.containsKey(acr.ContactId))){
                               mapAssisterOrgId.put(acr.ContactId, String.valueOf(acr.Account.DCDataId__c));                            
                               mapAssisterContactId.put(acr.ContactId, String.valueOf(acr.DCContactId__c));
                               
                           }
                    }  
                    if(!lstRoles.isEmpty() && lstRoles.contains(nonCitizenRole)){
                        if(acr.DCContactId__c!=null && (!mapAuthRepContactId.containsKey(acr.ContactId))) {
                              mapAuthRepContactId.put(acr.ContactId, String.valueOf(acr.DCContactId__c));   
                           }
                           if((acr.Account.DCDataId__c!=null && (!mapAuthRepOrgId.containsKey(acr.ContactId))) &&
                              acr.DCContactId__c!=null){
                               mapAuthRepOrgId.put(acr.ContactId, String.valueOf(acr.Account.DCDataId__c));                            
                             
                               
                           }
                    }  
                } 
                
            }
            
            Boolean bUpdateAuthAccept;        
            Boolean bUpdateAuthrepRej;
            String sUserRole;
            List<LOG_LogMessage__c> lstLogMessages = new List<LOG_LogMessage__c>();
            
            if(lstAccountContact.size()>0) {
                for(AccountContactRelation acrRecord : lstAccountContact){
                    if(citizenConsent== true){
                        //Citizen provided consent for Auth Rep
                        if(acrRecord.Roles == SSP_GlobalConstants.INDIVIDUAL_AUTH_REP || 
                           acrRecord.Roles == SSP_GlobalConstants.ORGANIZATION_AUTH_REP)
                        {
                            sUserRole = acrRecord.Roles;
                            //Start - Added for Tracker Defect-56
                            String sGetReqAuthPermission = '';
                            if(acrRecord.RequestAccessPermission__c != null && lstNotifications[0].RequestAccessPermission__c != null) {
                                sGetReqAuthPermission = lstNotifications[0].RequestAccessPermission__c;
                            } else if(acrRecord.RequestAccessPermission__c != null && (lstNotifications[0].RequestAccessPermission__c == null || lstNotifications[0].RequestAccessPermission__c == '')) {
                                SSP_Notifications__c objUpdNotif = new SSP_Notifications__c();
                                objUpdNotif = setNotificationRequestAccessPrgmPerJSON(acrRecord, lstNotifications[0]);
                                sGetReqAuthPermission = objUpdNotif.RequestAccessPermission__c;
                            }
                            //End - Added for Tracker Defect-56
                            String programCodes;
                            if(String.isNotBlank(sGetReqAuthPermission)) { // Added as part of Tracker Defect-56
                            JSONParser parser = JSON.createParser(sGetReqAuthPermission);
                            while (parser.nextToken() != null) {
                                if(parser.getText() == 'PermissionLevel_CCAP__c'){
                                    parser.nextToken();                                        
                                    acrRecord.PermissionLevel_CCAP__c=string.valueOf(parser.getText()); 
                                    // fix 390617
                                    if(programCodes!=null && programCodes!='' && (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.CHILD_CARE_CODE)))){
                                        programCodes = programCodes + ';' + SSP_GlobalConstants.CHILD_CARE_CODE;
                                    }
                                    else{
                                        // fix 390617
                                        programCodes = (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.CHILD_CARE_CODE))) ? SSP_GlobalConstants.CHILD_CARE_CODE : '';
                                    }
                                }
                                if(parser.getText() == 'PermissionLevel_KTAP__c'){
                                    parser.nextToken();                                        
                                    acrRecord.PermissionLevel_KTAP__c=string.valueOf(parser.getText());
                                    // fix 390617
                                    if(programCodes!=null && programCodes!='' && (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KTAP)))){
                                        system.debug('programCodes1:'+programCodes);
                                        programCodes = programCodes + ';' + SSP_GlobalConstants.KTAP;
                                    }
                                    else{
                                        // fix 390617
                                        programCodes = (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KTAP))) ? SSP_GlobalConstants.KTAP : '';
                                    }
                                } 
                                if(parser.getText() == 'PermissionLevel_SNAP__c'){
                                    parser.nextToken();
                                    acrRecord.PermissionLevel_SNAP__c=string.valueOf(parser.getText());
                                    // fix 390617
                                    if(programCodes!=null && programCodes!='' && (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP)))){
                                        programCodes = programCodes + ';' + SSP_GlobalConstants.SNAP;
                                    }
                                    else{
                                        // fix 390617
                                        programCodes = (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP))) ? SSP_GlobalConstants.SNAP : '';
                                    }
                                }
                                if(parser.getText() == 'PermissionLevel_KIHIPP__c'){
                                    parser.nextToken();
                                    acrRecord.PermissionLevel_KIHIPP__c=string.valueOf(parser.getText());
                                    // fix 390617
                                    if(programCodes!=null && programCodes!='' && (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP)))){
                                        programCodes = programCodes + ';' + SSP_GlobalConstants.KHIPP;
                                    }
                                    else{
                                        // fix 390617
                                        programCodes = (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP))) ? SSP_GlobalConstants.KHIPP : '';
                                    }
                                }
                                if(parser.getText() == 'PermissionLevel_Medicaid__c'){
                                    parser.nextToken();
                                    acrRecord.PermissionLevel_Medicaid__c=string.valueOf(parser.getText());
                                    // fix 390617
                                    if(programCodes!=null && programCodes!='' && (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID)))){
                                        programCodes = programCodes + ';' + SSP_GlobalConstants.MEDICAID;
                                    }
                                    else{
                                        // fix 390617
                                        programCodes = (String.IsBlank(acrRecord.ProgramsApplied__c) || (acrRecord.ProgramsApplied__c != null && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID))) ? SSP_GlobalConstants.MEDICAID : '';
                                    }
                                }                                
                            }
                            } // Added as part of Tracker Defect-56
                            if(mapAuthRepOrgId.get(acrRecord.contactId) != null){                               
                                acrRecord.DCAgencyId__c = Decimal.valueOf(mapAuthRepOrgId.get(acrRecord.contactId));
                            }
                            if(mapAuthRepContactId.get(acrRecord.contactId) != null){
                               acrRecord.DCContactId__c =Decimal.valueOf(mapAuthRepContactId.get(acrRecord.contactId));  
                            }
                            
                            if(acrRecord.ProgramsApplied__c!=null && String.isNotBlank(programCodes)){
                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c + ';' + programCodes;
                            }
                            else if(!String.isNotBlank(acrRecord.ProgramsApplied__c) && String.isNotBlank(programCodes)){
                                acrRecord.ProgramsApplied__c = programCodes;
                            }
                            //Start - Tracker Defect-111
                            //MA
                            if(String.isNotBlank(acrRecord.PermissionLevel_Medicaid__c) && String.isNotBlank(acrRecord.ProgramsApplied__c) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID)){
                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.MEDICAID;
                            }
                            else if(String.isNotBlank(acrRecord.PermissionLevel_Medicaid__c) && String.isBlank(acrRecord.ProgramsApplied__c)){
                                acrRecord.ProgramsApplied__c = SSP_GlobalConstants.MEDICAID;
                            }
                            //SNAP
                            if(String.isNotBlank(acrRecord.PermissionLevel_SNAP__c) && String.isNotBlank(acrRecord.ProgramsApplied__c) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP)){
                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.SNAP;
                            }
                            else if(String.isNotBlank(acrRecord.PermissionLevel_SNAP__c) && String.isBlank(acrRecord.ProgramsApplied__c)){
                                acrRecord.ProgramsApplied__c = SSP_GlobalConstants.SNAP;
                            }
                            //KP
                            if(String.isNotBlank(acrRecord.PermissionLevel_KIHIPP__c) && String.isNotBlank(acrRecord.ProgramsApplied__c) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP)){
                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.KHIPP;
                            }
                            else if(String.isNotBlank(acrRecord.PermissionLevel_KIHIPP__c) && String.isBlank(acrRecord.ProgramsApplied__c)){
                                acrRecord.ProgramsApplied__c = SSP_GlobalConstants.KHIPP;
                            }
                            //KTAP
                            if(String.isNotBlank(acrRecord.PermissionLevel_KTAP__c) && String.isNotBlank(acrRecord.ProgramsApplied__c) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KTAP)){
                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.KTAP;
                            }
                            else if(String.isNotBlank(acrRecord.PermissionLevel_KTAP__c) && String.isBlank(acrRecord.ProgramsApplied__c)){
                                acrRecord.ProgramsApplied__c = SSP_GlobalConstants.KTAP;
                            }
                            //CC
                            if(String.isNotBlank(acrRecord.PermissionLevel_CCAP__c) && String.isNotBlank(acrRecord.ProgramsApplied__c) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.CHILD_CARE_CODE)){
                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.CHILD_CARE_CODE;
                            }
                            else if(String.isNotBlank(acrRecord.PermissionLevel_CCAP__c) && String.isBlank(acrRecord.ProgramsApplied__c)){
                                acrRecord.ProgramsApplied__c = SSP_GlobalConstants.CHILD_CARE_CODE;
                            }
                            //End - Tracker Defect-111
                            acrRecord.IsRepresentativeVerified__c = 'Y';
                            //call update DC representative service
                            SSP_UpdateDCRepResponseWrapper response = new SSP_UpdateDCRepResponseWrapper();
                            if(mapApplications.get(acrRecord.AccountId) != null && mapApplications.get(acrRecord.AccountId).DCCaseNumber__c != null){
                                Map<String, Object> mapParams = new Map<String, Object>();
                                RSSP_DC_Wrapper responseWrapper =  new RSSP_DC_Wrapper();
                                SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                                SSP_AssisterAuthRepDetailsPayloadWrapper objAuthRepPayLoad=new SSP_AssisterAuthRepDetailsPayloadWrapper();
                                reqWrapper.viewName = SSP_InterfaceConstants.ASSISTER_AUTHREP_CLIENT_DETAILS;           	
                                reqWrapper.caseNumber = Integer.valueOf(mapApplications.get(acrRecord.AccountId).DCCaseNumber__c);                              
                                reqWrapper.role =acrRecord.Roles != null ?acrRecord.Roles :SSP_GlobalConstants.RoleType_AuthRep;
                                mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                                mapParams.put(SSP_InterfaceConstants.SKIP_LOG,true);
                                mapParams.put(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD,true);
                                List<Object> objListRsspdc = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                                if(objListRsspdc != null && (!objListRsspdc.isEmpty())){
                                    responseWrapper = (RSSP_DC_Wrapper) objListRsspdc.get(0);
                                }
                                if(objListRsspdc.size() >1 && objListRsspdc[1] != null){                   
                                    LOG_LogMessage__c objLog = (LOG_LogMessage__c) objListRsspdc[1];
                                    lstLogMessages.add(objLog);                                
                                }   
                                
                                if(responseWrapper != null && responseWrapper.assisterAuthRepDetailsPayload != null){
                                    objAuthRepPayLoad = responseWrapper.assisterAuthRepDetailsPayload;
                                }else{            	
                                    result = 'assisterAuthRepDetailsPayload key is Null';
                                    break;
                                }
                                if(objAuthRepPayLoad != null && objAuthRepPayLoad.AuthrepandAssiterClientInfo != null && !objAuthRepPayLoad.AuthrepandAssiterClientInfo.isEmpty()) {
                                    for(SSP_AssisterAuthRepDetailsPayloadWrapper.AuthrepandAssiterClientInfoWrapper objAuthRepInfo: objAuthRepPayLoad.AuthrepandAssiterClientInfo) {   
                                        if(objAuthRepInfo != null && objAuthRepInfo.userId != null && mapAuthRepContactId.get(acrRecord.contactId) != null && objAuthRepInfo.userId == mapAuthRepContactId.get(acrRecord.contactId) ){                            
                                            acrRecord.DCRepresentativeId__c =    objAuthRepInfo.DCRepresentativeId != null ? Integer.valueOf(objAuthRepInfo.DCRepresentativeId): 0;
                                            if(objAuthRepInfo.Street != null){
                                               acrRecord.Street__c =  objAuthRepInfo.Street; 
                                            }
                                            if(objAuthRepInfo.AddressLine2 != null){
                                               acrRecord.AddressLine2__c =  objAuthRepInfo.AddressLine2; 
                                            }
                                            if(objAuthRepInfo.SSP_State != null){
                                               acrRecord.SSP_State__c =  objAuthRepInfo.SSP_State; 
                                            }
                                            if(objAuthRepInfo.CountyCode != null){
                                               acrRecord.CountyCode__c =  objAuthRepInfo.CountyCode; 
                                            }
                                            if(objAuthRepInfo.Zipcode5 != null){
                                               acrRecord.Zipcode5__c =  objAuthRepInfo.Zipcode5; 
                                            }
                                            
                                            //Defect 389834                                            
											acrRecord.PermissionLevel_CCAP__c = acrRecord.PermissionLevel_CCAP__c == null ? objAuthRepInfo.PermissionLevelCCAP : acrRecord.PermissionLevel_CCAP__c; 
                                            acrRecord.PermissionLevel_KTAP__c = acrRecord.PermissionLevel_KTAP__c == null ? objAuthRepInfo.PermissionLevelKTAP : acrRecord.PermissionLevel_KTAP__c; 
                                            acrRecord.PermissionLevel_SNAP__c = acrRecord.PermissionLevel_SNAP__c == null ? objAuthRepInfo.PermissionLevelSNAP : acrRecord.PermissionLevel_SNAP__c; 
                                            acrRecord.PermissionLevel_KIHIPP__c = acrRecord.PermissionLevel_KIHIPP__c == null ? objAuthRepInfo.PermissionLevelKIHIPP : acrRecord.PermissionLevel_KIHIPP__c; 
                                            acrRecord.PermissionLevel_Medicaid__c = acrRecord.PermissionLevel_Medicaid__c == null ? objAuthRepInfo.PermissionLevelMedicaid : acrRecord.PermissionLevel_Medicaid__c; 
                                            if(String.isNotBlank(objAuthRepInfo.PermissionLevelStateSupp) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.STATE)) {                                                
                                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c!=null ? (acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.STATE) : SSP_GlobalConstants.STATE; //Defect 390054
                                            }
                                            if(String.isNotBlank(objAuthRepInfo.PermissionLevelSNAP) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP)) {                                                
                                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c!=null ? (acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.SNAP) : SSP_GlobalConstants.SNAP;
                                            }
                                            if(String.isNotBlank(objAuthRepInfo.PermissionLevelMedicaid) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID)) {                                                
                                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c!=null ? (acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.MEDICAID) : SSP_GlobalConstants.MEDICAID;
                                            }
                                            if(String.isNotBlank(objAuthRepInfo.PermissionLevelKTAP) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KTAP)) {                                                
                                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c!=null ? (acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.KTAP) : SSP_GlobalConstants.KTAP;
                                            }
                                            if(String.isNotBlank(objAuthRepInfo.PermissionLevelKIHIPP) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP)) {                                                
                                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c!=null ? (acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.KHIPP) : SSP_GlobalConstants.KHIPP;
                                            }
                                            if(String.isNotBlank(objAuthRepInfo.PermissionLevelCCAP) && !acrRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.CHILD_CARE_CODE)) {                                                
                                                acrRecord.ProgramsApplied__c = acrRecord.ProgramsApplied__c!=null ? (acrRecord.ProgramsApplied__c + ';' + SSP_GlobalConstants.CHILD_CARE_CODE) : SSP_GlobalConstants.CHILD_CARE_CODE;
                                            }
                                        }
                                    }
                                }
                                //Defect 389834 - End
                                Map<String, Object> mapInputParams = new Map<String, Object> ();
                                mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_APP_ID, mapApplications.get(acrRecord.AccountId).Id);
                                mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_ACR, acrRecord);
                                mapInputParams.put(SSP_InterfaceConstants.SSP_IS_FROM_REQUEST_ACCESS, true);                         
                                mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_CONTACT_ID, mapContacts.get(acrRecord.contactId).Id);
                                
                                List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_UPDATE_DC_REPRESENTATIVE, mapInputParams);
                                if(objList!= null && !objList.isEmpty()){
                                    response = (SSP_UpdateDCRepResponseWrapper) objList[0];
                                    
                                    LOG_LogMessage__c objLog = (LOG_LogMessage__c)objList[1];
                                    lstLogMessages.add(objLog);
                                }
                            }
                            //callout end
                            if((response != null && response.AckResponse != null &&  response.AckResponse.success) || mapApplications.get(acrRecord.AccountId).DCCaseNumber__c == null){                                
                                bUpdateAuthAccept = true;
                                result = 'true';                                                                
                            }
                            else if(response != null && response.AckResponse != null && response.AckResponse.Error != null &&  response.AckResponse.Error.CHFSExceptionId != null){                 
                                result = response.AckResponse.Error.CHFSExceptionId; 
                                break;
                            }else if(response != null && response.AckResponse != null && response.AckResponse.Error != null &&  response.AckResponse.Error.ErrorCode != null){                
                                result = response.AckResponse.Error.ErrorCode; 
                                break;
                            }       

                            /** #388714 */
                            acrRecord = modifyACRRequestAccessPermissionJSON(acrRecord, lstNotifications[0]);//Added for Tracker Defect-56
                            bUpdateAuthAccept = true;  
                            /** */                                                                                  
                        }                
                        else if(acrRecord.Roles == SSP_GlobalConstants.ASSISTER_ROLE || acrRecord.Roles == SSP_GlobalConstants.AGENCY_ADMIN_ROLE){
                            sUserRole = acrRecord.Roles;                        
                            
                            //set update agent assister service values 
                            SSP_UpdateAgentAssisterResWrapper objResult = new SSP_UpdateAgentAssisterResWrapper();
                            List<Object> lstData = new List<Object>();
                            if(mapApplications.get(acrRecord.AccountId).DCCaseNumber__c != null) {
                                SSP_UpdateAgentAssisterRequestWrapper objRequest = new  SSP_UpdateAgentAssisterRequestWrapper();
                                objRequest.Operation = 'update';                     
                                SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel objChild = new SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel();
                                List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel> lstChild = new List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel>();                                                                        
                                objChild.AgencyId = mapAssisterOrgId.get(acrRecord.ContactId);
                                objChild.CaseNumber = mapApplications.get(acrRecord.AccountId).DCCaseNumber__c != null ? String.valueOf(mapApplications.get(acrRecord.AccountId).DCCaseNumber__c) : null;
                                objChild.IndividualId = lstNotifications[0].recipientId__c != null ? lstNotifications[0].recipientId__c : null;
                                objChild.AgencyEmployeeId = mapAssisterContactId.get(acrRecord.ContactId) != null ? String.valueOf(mapAssisterContactId.get(acrRecord.ContactId)) : null;
                                objChild.IndividualContactPhone = userList[0].Contact.Phone != null ?  userList[0].Contact.Phone:null;
                                objChild.DoiAgentId = null;
                                objChild.DoiAgencyId = null;
                                objchild.IsAssisterUpdate = acrRecord.Roles == SSP_GlobalConstants.ASSISTER_ROLE ? 'true' : 'false'; 
                                objchild.IsAgentUpdate = acrRecord.Roles == SSP_GlobalConstants.AGENCY_ADMIN_ROLE ? 'true' : 'false'; 
                                lstChild.add(objchild);
                                objRequest.DCAgencyIndividualCaseAssociationModel =lstChild ;
                                Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objRequest) };                        
                                    objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID, mapApplications.get(acrRecord.AccountId).DCCaseNumber__c == null ? mapApplications.get(acrRecord.AccountId).Id : null);//put the app id for which you are invoking this service
                                objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER, mapApplications.get(acrRecord.AccountId).DCCaseNumber__c != null ? mapApplications.get(acrRecord.AccountId).DCCaseNumber__c : null);//put the CaseNumber for which you are invoking this service
                                lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPUpdateAgentAssister_METADATANAME , objResponse);
                                if(lstData != null && (!lstData.isEmpty())){
                                    objResult = (SSP_UpdateAgentAssisterResWrapper)lstData[0];
                                                                 
                                }
                            }
                            if(mapApplications.get(acrRecord.AccountId).DCCaseNumber__c == null ||
                               (((objResult.isSFFailure != null && (!objResult.isSFFailure)) || (objResult.isSFFailure == null)) && objResult.AckResponse != null && objResult.AckResponse.success))
                            {
                                result = 'true';                            
                                String sGetReqAssisPermission = acrRecord.RequestAccessPermission__c;                             
                                acrRecord.RequestAccessPermission__c= null;                                                                             
                                bUpdateAuthAccept = true;  
                            }
                            else if (((objResult.isSFFailure != null && (objResult.isSFFailure)) || (objResult.isSFFailure == null)) || (objResult.AckResponse != null  && objResult.AckResponse != null && objResult.AckResponse.Error != null)){
                                if(objResult.AckResponse.Error.CHFSExceptionId != null){                                
                                    result = objResult.AckResponse.Error.CHFSExceptionId;
                                    break;
                                }else if(objResult.AckResponse.Error.ErrorCode != null){                                
                                    result = objResult.AckResponse.Error.ErrorCode;
                                    break;
                                }                                
                            }
                            if(lstData.size() >1 && lstData[1] != null){                   
                                LOG_LogMessage__c objLog = (LOG_LogMessage__c) lstData[1];
                                lstLogMessages.add(objLog);                                
                            }   
                            
                            // Defect 385641 Defect Fix Start -  Kireeti
                            SSP_ApplicationIndividual__c objAppIndividual = new SSP_ApplicationIndividual__c();                            
                            SSP_Application__c application = new SSP_Application__c();
                            String sspMemberId;      
                            String individualId;
                            if((!lstNotifications.isEmpty()) && lstNotifications[0].recipientId__c != null){
                                individualId =   lstNotifications[0].recipientId__c;
                            }
                            if(mapApplications.get(acrRecord.AccountId) != null && mapApplications.get(acrRecord.AccountId).Id != null){
                                application =mapApplications.get(acrRecord.AccountId);
                            }
                            if(((result == 'true' && application != null && application.DCCaseNumber__c != null) || ( application != null && application.Id != null && application.DCCaseNumber__c == null)) && individualId != null) {
                                List<contact> contactList = new List<contact>();
                                if( application != null && application.Id != null ){
                                    List<SSP_ApplicationIndividual__c> applicationIndividuals = new List<SSP_ApplicationIndividual__c>();
                                    applicationIndividuals = [SELECT Id, IsHeadOfHousehold__c, MedicaidType__c,ProgramsApplied__c,SSP_Member__r.Name,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__c,SSP_Member__r.IndividualId__c,SSP_Member__r.PrimaryPhoneNumber__c,SSP_Member__r.Email__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.PhysicalCountyCode__c 
                                                              FROM SSP_ApplicationIndividual__c WHERE IsHeadOfHousehold__c = true AND  SSP_Application__c =:application.Id];
                                    if(applicationIndividuals != null && (!applicationIndividuals.isEmpty()) && applicationIndividuals[0].SSP_Member__c != null && applicationIndividuals[0].SSP_Member__r.FirstName__c  != null){ 
                                        objAppIndividual = applicationIndividuals[0];
                                    }else if(individualId != null){
                                        
                                        contactList = [SELECT Id,FirstName,LastName,Email,Phone,Suffix FROM Contact WHERE IndividualId__c=:individualId];
                                    }
                                }
                                
                                
                                if(application != null && application.Id != null && (objAppIndividual != null || (!contactList.isEmpty()))){  
                                    Map<String, String> miscellaneousParameterMapping= new Map<String, String>{
                                        'IndividualFirstName'=> (objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.FirstName__c != null)? objAppIndividual.SSP_Member__r.FirstName__c :objAppIndividual == null && (!contactList.isEmpty()) && contactList[0].FirstName !=null ?contactList[0].FirstName:'',//'Logged in UserFirstName'
                                            'IndividualMI'=>  (objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.MiddleInitial__c != null)? objAppIndividual.SSP_Member__r.MiddleInitial__c :'',
                                                'IndividualLastName'=>  (objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.LastName__c != null)? objAppIndividual.SSP_Member__r.LastName__c :objAppIndividual == null && (!contactList.isEmpty()) && contactList[0].FirstName !=null ?contactList[0].FirstName:'',
                                                    'IndividualSuffix'=>(objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.SuffixCode__c != null)? objAppIndividual.SSP_Member__r.SuffixCode__c :objAppIndividual == null && (!contactList.isEmpty()) && contactList[0].LastName !=null ?contactList[0].LastName:'',
                                                        'Email'=>(objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.Email__c != null)? objAppIndividual.SSP_Member__r.Email__c : objAppIndividual == null && (!contactList.isEmpty()) && contactList[0].Email != null ? contactList[0].Email :'',//'Logged in UserEmail'
                                                            'PrimaryPhoneNumber'=>(objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.PrimaryPhoneNumber__c != null)? objAppIndividual.SSP_Member__r.PrimaryPhoneNumber__c.replace('-','') :objAppIndividual == null && (!contactList.isEmpty()) &&  contactList[0].Phone !=null ?contactList[0].Phone.replace('-',''):'',//Logged in UserPrimaryPhoneNumber'                                     
                                                                'AssocAgencyId'=>'',
                                                                'AssocAgencyEmployeeId'=>'',
                                                                'AssocDoiAgentId'=>'',
                                                                'AssocDoiAgencyId'=>''
                                                                };
                                                                    String param = '';
                                    for(String key : miscellaneousParameterMapping.keySet()){
                                        String value = miscellaneousParameterMapping.get(key);//get value corresponding to key being iterated
                                        param += key + ':' + value + '|';
                                    }
                                    param.removeEnd('|');
                                    SSP_CorrespondenceRequestWrapper hr = new SSP_CorrespondenceRequestWrapper('HBE-016');
                                    
                                    if(mapAssisterContactId.get(acrRecord.ContactId)!=null){
                                        hr.AgencyEmployeeId = Integer.valueOf(mapAssisterContactId.get(acrRecord.ContactId));
                                    }
                                    else{
                                        hr.AgencyEmployeeId = 0;
                                    }
                                    if(mapAssisterOrgId.get(acrRecord.ContactId) != null){
                                        hr.AgencyId = Integer.valueOf(mapAssisterOrgId.get(acrRecord.ContactId));
                                    }else {
                                        hr.AgencyId = 0;  
                                    }
                                    
                                    if(application.DCCaseNumber__c != null){               
                                        hr.CaseNumber = Integer.valueOf(application.DCCaseNumber__c);
                                    }else{              
                                        hr.ApplicationNumber = Integer.valueOf(application.Name);     
                                    }
                                    hr.CorrespondenceCode = 'HBE-016';
                                    hr.CreatedDate= SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                                    hr.CreatedUserId =individualId;            
                                    hr.DoiAgencyId = 0;
                                    hr.DoiAgentId =  0;
                                    hr.MiscellaneousParameters = param;
                                    hr.PrintMode = 'BP';
                                    hr.ProgramCode = application.ProgramsApplied__c;
                                    hr.RequestTriggerStatusCode = 'NEW';
                                    hr.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
                                    hr.UpdatedDate = SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                                    hr.UpdatedUserId =individualId;  
                                    hr.Reqtype = 'InsertCorrespondenceTrigger';
                                    Map<String,object> obj = new Map<string,object>();
                                    obj.put('jsonbody', JSON.serialize(hr));
                                    obj.put(SSP_InterfaceConstants.IS_LOG_INSERTED,false);
                                    List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
                                    
                                    if(slist != null && slist.size() > 0 && slist[0] != null){
                                        SSP_CorrespondenceResponseWrapper resp = (SSP_CorrespondenceResponseWrapper)slist[0];
                                        if(resp.isSuccess){
                                            result = 'true';
                                            
                                        }else{
                                            result = resp.LogId;
                                        }
                                    }
                                    
                                    if(slist.size() >1 && slist[1] != null){                 
                                        LOG_LogMessage__c objLog = (LOG_LogMessage__c) slist[1];
                                        
                                        lstLogMessages.add(objLog);
                                        
                                    }
                                }
                            } 
                            // Defect 385641 Defect Fix End - Kireeti
                        }
                        
                    }
                    else if(citizenConsent== false){
                        if(acrRecord.Roles == SSP_GlobalConstants.INDIVIDUAL_AUTH_REP || acrRecord.Roles == SSP_GlobalConstants.ORGANIZATION_AUTH_REP){
                            sUserRole = acrRecord.Roles;
                            if(acrRecord.PermissionLevel_CCAP__c !=Null || acrRecord.PermissionLevel_KTAP__c !=Null || acrRecord.PermissionLevel_SNAP__c !=Null || acrRecord.PermissionLevel_KIHIPP__c !=Null || acrRecord.PermissionLevel_Medicaid__c !=Null) //Removed acrRecord.RequestAccessPermission__c != null condition for Tracker Defect-56
                            {
                                //Start - Added for Tracker Defect-56
                                if(acrRecord.RequestAccessPermission__c != null) {
                                    acrRecord = modifyACRRequestAccessPermissionJSON(acrRecord, lstNotifications[0]);
                                }
                                //End - Added for Tracker Defect-56
                                bUpdateAuthrepRej = true;                            
                            }else if(acrRecord.PermissionLevel_CCAP__c ==Null && acrRecord.PermissionLevel_KTAP__c ==Null && acrRecord.PermissionLevel_SNAP__c ==Null && acrRecord.PermissionLevel_KIHIPP__c ==Null && acrRecord.PermissionLevel_Medicaid__c ==Null) //Removed acrRecord.RequestAccessPermission__c != null condition for Tracker Defect-56
                            {                                                        
                                //Start - Added for Tracker Defect-56
                                if(acrRecord.RequestAccessPermission__c != null) {
                                    acrRecord = modifyACRRequestAccessPermissionJSON(acrRecord, lstNotifications[0]);
                                }
                                bUpdateAuthrepRej = acrRecord.RequestAccessPermission__c != null ? true : false;
                                //End - Added for Tracker Defect-56
                            }
                            bUpdateAuthAccept = false;  
                        }
                        else if(acrRecord.Roles == SSP_GlobalConstants.ASSISTER_ROLE || acrRecord.Roles == SSP_GlobalConstants.AGENCY_ADMIN_ROLE){
                            sUserRole = acrRecord.Roles;
                            bUpdateAuthAccept = false;                                                                                              
                        }
                    }                
                }
            }
            
            //Notification logic       
            String sidentifier;
            map<string,object> inputData = new map<string,object>(); 
            inputData.put('recipientType', nonCitizenRole);
            inputData.put('notificationId', snotificationId);
            
            //Get the member name from notification recipient id
            // fix for 385337 - start
            if(lstNotifications != null && !lstNotifications.isEmpty() && lstNotifications[0].recipientId__c != null)
            {
                /*List<SSP_Member__c> lstMembers = SSP_MemberSelector.queryMemberData (
                    new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                    new Set<String>{'Id','FirstName__c','LastName__c','IndividualId__c'}, 
                    new Map<String, String>{'limit'=>'1','IndividualId__c'=>lstNotifications[0].recipientId__c}
                );*/
                List<SSP_Member__c> lstMembers = [select Id ,FirstName__c,LastName__c,IndividualId__c from SSP_Member__c where IndividualId__c=:lstNotifications[0].recipientId__c Limit 1];
                if(lstMembers!=null && lstMembers.size()>0){
                	inputData.put('citizenFirstName', lstMembers[0].FirstName__c + ' ' + lstMembers[0].LastName__c); 
                }
            }                       
            // fix for 385337 - end

            // fix 378781 : fetch recipient id of non citizen
            String nonCitizenContact;
            String nonCitizenDCContact;
            if(lstAccountContact != null && lstAccountContact.size() > 0){
                nonCitizenContact = lstAccountContact[0].ContactId;
            }
            if(nonCitizenContact != null && nonCitizenContact != '')
            {
                list<Integer> listNonCitizenIdentifier = new list<Integer>();
                //386774
                if(nonCitizenRole == SSP_GlobalConstants.ORGANISATION_AUTH_REP || nonCitizenRole == SSP_GlobalConstants.AGENCY_ADMIN_ROLE)
                {
                    
                    for(AccountContactRelation objAcr :[Select id , Account.DCDataId__c from AccountContactRelation 
                                                        where Account.DCDataId__c !=null and Account.RecordType.Name=: SSP_GlobalConstants.ORGANIZATION 
                                                        and ContactId =: nonCitizenContact and Roles includes (:nonCitizenRole )])
                        
                        
                    {
                        if(objAcr.Account.DCDataId__c !=null){
                            Integer intVal =(objAcr.Account.DCDataId__c).intValue();
                            nonCitizenDCContact = String.valueOf(intVal);
                        }
                                                            
                    }
                }
                else {
                for(AccountContactRelation objACR : [select id, DCContactId__c from AccountContactRelation where 
                                DCContactId__c != null AND  Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION 
                                AND ContactId = :nonCitizenContact AND Roles = :nonCitizenRole])
                {
                    
                    Integer intVal = (objACR.DCContactId__c).intValue();
                    nonCitizenDCContact = String.valueOf(Integer.valueOf(intVal));
                    }
                }
            }
            
            // fix 378781 : perform operations if recipient id is found 
            if(nonCitizenDCContact!=null && nonCitizenDCContact != ''){
                inputData.put('recipientId', nonCitizenDCContact); 
                    
                // DML operation for Auth Rep        
                if(bUpdateAuthAccept == true && (sUserRole == SSP_GlobalConstants.INDIVIDUAL_AUTH_REP || sUserRole == SSP_GlobalConstants.ORGANIZATION_AUTH_REP) && result == 'true'){
                    //Savepoint sp;            
                    update lstAccountContact;            
                    sidentifier=SSP_GlobalConstants.SF_NOT_002;  
                    inputData.put('sourceTodoCode', SSP_GlobalConstants.SF_TOD_002);
                }
                else if(bUpdateAuthAccept == false && (sUserRole == SSP_GlobalConstants.INDIVIDUAL_AUTH_REP || sUserRole == SSP_GlobalConstants.ORGANIZATION_AUTH_REP)){            
                     //update the application to blocked 
                     List<SSP_Application__c> lstAppToBeUpdated = new List<SSP_Application__c>();
                     Set<Id> setAccountID = new Set<Id>();
                     for (AccountContactRelation objACR : lstAccountContact) {
                        SSP_Application__c objApp = mapApplications.get(objACR.AccountID);
                        if(!setAccountID.contains(objACR.AccountID) && !objApp.CreatedByID.equals(idUser)) {
                                SSP_Application__c objUpdate = new SSP_Application__c(
                                    id=objApp.id,
                                    Status__c =SSP_GlobalConstants.APPLICATION_STATUS_BLOCKED
                                );
                                lstAppToBeUpdated.add(objUpdate);
                        }
                        if(!lstAppToBeUpdated.isEmpty()) {
                            update lstAppToBeUpdated;
                        }
                     }
                    if(bUpdateAuthrepRej == true){                
                        update lstAccountContact;                
                        sidentifier=SSP_GlobalConstants.SF_NOT_003;  
                        inputData.put('sourceTodoCode', SSP_GlobalConstants.SF_TOD_002);
                    }else if(bUpdateAuthrepRej == false){
                        delete lstAccountContact;                
                        sidentifier=SSP_GlobalConstants.SF_NOT_003;  
                        inputData.put('sourceTodoCode', SSP_GlobalConstants.SF_TOD_002);                
                    } 
                }
                
                //DML operation for Assister
                if(bUpdateAuthAccept == true && (sUserRole ==SSP_GlobalConstants.ASSISTER_ROLE || sUserRole ==SSP_GlobalConstants.AGENCY_ADMIN_ROLE) && result == 'true')
                {
                    //Savepoint sp;                                         
                    update lstAccountContact;            
                    sidentifier=SSP_GlobalConstants.SF_NOT_002;  
                    inputData.put('sourceTodoCode', SSP_GlobalConstants.SF_TOD_003);
                }        
                else if(bUpdateAuthAccept == false && (sUserRole ==SSP_GlobalConstants.ASSISTER_ROLE || sUserRole ==SSP_GlobalConstants.AGENCY_ADMIN_ROLE)){             
                    delete lstAccountContact;            
                    sidentifier=SSP_GlobalConstants.SF_NOT_003;  
                    inputData.put('sourceTodoCode', SSP_GlobalConstants.SF_TOD_003);
                }
                
                Map<String, Object> returnValue= SSP_MessageCenterService.processNotificationMessage(sidentifier, inputData);
            }
            if(citizenConsent == true){
                    String currentUserIndividualId  = ssp_Utility.getIndividualId();
                    if(String.isNotBlank(currentUserIndividualId)){
                        List<contact> lstContact = new List<contact>();
                        lstContact = [SELECT Id,isDashboardRefreshNeeded__c FROM Contact Where IndividualId__c  = :currentUserIndividualId];
                        if(!lstContact.isEmpty()){
                            lstContact[0].isDashboardRefreshNeeded__c = true;
                            UPDATE lstContact;
                        }
                    }
                }
            //Insert service log messages
            if(lstLogMessages!= null && lstLogMessages.size()>0){
                insert lstLogMessages;
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisAuthRepConsentNotSignedService', 'updateAccountContactRelation', ex.getMessage() , true); 
            return 'false';
        }
        return result;
    }
    
    @AuraEnabled
    public static String expireNotification(String notificationId){
        try{
            List<SSP_Notifications__c> lstNotifications = new List<SSP_Notifications__c>();
            if(String.isNotBlank(notificationId)) {            
                lstNotifications = SSP_MessageCenterWithoutSharingService.fetchNotifications(notificationId);
            }
            for(SSP_Notifications__c notification : lstNotifications){
                notification.Status__c = 'Expired';
            }
            update lstNotifications;
            return 'true';
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisAuthRepConsentNotSignedService', 'expireNotification', ex.getMessage() , true); 
            return 'false';
        }
    }
    //Start - Tracker Defect-56
    public static Boolean isToAvoid=false;
    public static AccountContactRelation modifyACRRequestAccessPermissionJSON(AccountContactRelation acrRecord,SSP_Notifications__c objNotif) {
        if(acrRecord.RequestAccessPermission__c != null && objNotif.RequestAccessPermission__c != null && objNotif.RequestAccessPermission__c !='') {
            Map<String, Object> mapACRReqPer = (Map<String, Object>)JSON.deserializeUntyped(acrRecord.RequestAccessPermission__c);
            Map<String, Object> mapNotifReqPer = (Map<String, Object>)JSON.deserializeUntyped(objNotif.RequestAccessPermission__c);
            Boolean isToUpdate = false;
            if(!mapACRReqPer.isEmpty() && !mapNotifReqPer.isEmpty()) {
                for(String sPrg: mapNotifReqPer.keySet()) {
                    if(mapACRReqPer.get(sPrg)!=null) {
                        mapACRReqPer.remove(sPrg);
                        isToUpdate = true;
                    }
                }
                String sUpdatePerssmission='';
                if(isToUpdate && mapACRReqPer!=null && !mapACRReqPer.isEmpty()) {
                    sUpdatePerssmission = JSON.serialize(mapACRReqPer);
                }
                if(isToUpdate) {
                    acrRecord.RequestAccessPermission__c=sUpdatePerssmission;
                }
            }
        } else if(!isToAvoid && acrRecord.RequestAccessPermission__c != null && (objNotif.RequestAccessPermission__c == null ||  objNotif.RequestAccessPermission__c=='')) {
            objNotif = setNotificationRequestAccessPrgmPerJSON(acrRecord, objNotif);
            acrRecord = modifyACRRequestAccessPermissionJSON(acrRecord, objNotif);
            isToAvoid=true;
        }
        return acrRecord;
    }

    public static SSP_Notifications__c setNotificationRequestAccessPrgmPerJSON(AccountContactRelation acrRecord,SSP_Notifications__c objNotif) {
        if((objNotif.RequestAccessPermission__c == null ||  objNotif.RequestAccessPermission__c=='') && objNotif.Notification_Body__c != null) {
            system.debug('Before-'+objNotif.RequestAccessPermission__c);
            Map<String, Object> mapNotifReqAccPer = new Map<String,Object>();
            String sNotifBody = objNotif.Notification_Body__c;
            
            if(sNotifBody.contains(SSP_GlobalConstants.MA_Label)) {
                mapNotifReqAccPer.put('PermissionLevel_Medicaid__c',setNotificationPermission(acrRecord,objNotif,'PermissionLevel_Medicaid__c'));
            }
            if(sNotifBody.contains(SSP_GlobalConstants.SN_Label)) {
                mapNotifReqAccPer.put('PermissionLevel_SNAP__c',setNotificationPermission(acrRecord,objNotif,'PermissionLevel_SNAP__c'));
            }
            if(sNotifBody.contains(SSP_GlobalConstants.SS_Label)) {
                mapNotifReqAccPer.put('PermissionLevel_StateSupp__c',setNotificationPermission(acrRecord,objNotif,'PermissionLevel_StateSupp__c'));
            }
            if(sNotifBody.contains(SSP_GlobalConstants.KP_Label)) {
                mapNotifReqAccPer.put('PermissionLevel_KIHIPP__c',setNotificationPermission(acrRecord,objNotif,'PermissionLevel_KIHIPP__c'));
            }
            if(sNotifBody.contains(SSP_GlobalConstants.KT_Label)) {
                mapNotifReqAccPer.put('PermissionLevel_KTAP__c',setNotificationPermission(acrRecord,objNotif,'PermissionLevel_KTAP__c'));
            }
            if(sNotifBody.contains(SSP_GlobalConstants.CC_Label)) {
                mapNotifReqAccPer.put('PermissionLevel_CCAP__c',setNotificationPermission(acrRecord,objNotif,'PermissionLevel_CCAP__c'));
            }
            objNotif.RequestAccessPermission__c = mapNotifReqAccPer!=null && !mapNotifReqAccPer.isEmpty() ? JSON.serialize(mapNotifReqAccPer):null;
        }
        return objNotif;
    }

    public static String setNotificationPermission(AccountContactRelation acrRecord,SSP_Notifications__c objNotif,String sPrgmPer) {
        Map<String, Object> mapACRReqPer = new Map<String, Object> ();
        if(acrRecord.Id == objNotif.Linked_Record_Id__c && acrRecord.RequestAccessPermission__c!=null) {
            mapACRReqPer = (Map<String, Object>)JSON.deserializeUntyped(acrRecord.RequestAccessPermission__c);
        }
        String sPer = mapACRReqPer!=null && !mapACRReqPer.isEmpty() && mapACRReqPer.get(sPrgmPer)!=null ? (String)mapACRReqPer.get(sPrgmPer) :'';
        return sPer;
    }
    //END - Tracker Defect-56
}