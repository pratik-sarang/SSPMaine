public with sharing class SSP_AssisterRequestAccessCtrl {
	@AuraEnabled
    public static SSP_LightningResponse searchClientMCIService(String sClientDetails) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            sClientDetails = String.escapeSingleQuotes(sClientDetails);
            String sRoleType = SSP_Utility.getSelectedRole();
            Map<String, Object> objMCIResp = null;            
            objMCIResp = SSP_AuthRepAccessRequestService.searchClientMCIService(sClientDetails); 
            List<Object> lstLogs = (List<Object> )objMCIResp.get('logMessageResponse'); // Added as part of LOG_Message purpose
            objMCIResp.remove('logMessageResponse'); // Added as part of LOG_Message purpose
            objResponse.put('searchClientResponse', objMCIResp);
            
            String sApplicationNumber = objMCIResp != null && objMCIResp.get('applicationNumber') != null ? String.valueOf(objMCIResp.get('applicationNumber')) : '';
            String sCaseNumber = objMCIResp != null && objMCIResp.get('caseNumber') != null ? String.valueOf(objMCIResp.get('caseNumber')) : '';
            
            SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper objMCIDetails = objMCIResp != null && objMCIResp.get('mciDetails') != null ? (SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper)objMCIResp.get('mciDetails') : null;
            String sSourceIndividualId = objMCIDetails != null ? objMCIDetails.sSourceIndividualId : '';
            Boolean bIsFullMatch = objMCIDetails != null ? objMCIDetails.bIsFullMatch : false;
			
            objResponse.put('isPartialMatch', objMCIDetails != null ? objMCIDetails.bIsPartialMatch : false);
            objResponse.put('isNoMatch', objMCIDetails != null ? objMCIDetails.bIsNoMatch : false);
            
            if(bIsFullMatch && String.isNotBlank(sSourceIndividualId) && String.isBlank(sApplicationNumber)) {
                Map<String, Object> objRevSSPDCResp = SSP_AuthRepAccessRequestService.reverseSSPDCService(sSourceIndividualId, null, sRoleType); 
                Object objServiceResponse = objRevSSPDCResp.get('reverseSSPDCDetails');
                                
                Map<String,Object> objAssisterAssociation = SSP_AssisterRequestAccessService.checkCaseForAssociation(JSON.serialize(objServiceResponse), objMCIDetails, sCaseNumber);
                objResponse.put('associationResponse', objAssisterAssociation);                
            } 
            else if (bIsFullMatch && String.isNotBlank(sApplicationNumber)) {
                Map<String,Object> objAssisterAssociation = SSP_AssisterRequestAccessService.checkApplicationAssociation(sSourceIndividualId, sApplicationNumber);
                objResponse.put('associationResponse', objAssisterAssociation);
            }
            
            //Start - Added as a part of LOG_Message Response
            if(lstLogs != null && !lstLogs.isEmpty() && lstLogs.size() == 2) {
                LOG_LogMessage__c objLog = (LOG_LogMessage__c) lstLogs[1];
                //insert objLog;
                ESAPI.accessController().insertAsUser(new List<LOG_LogMessage__c> {objLog}, SSP_Utility.getFieldsNamesList (new List<LOG_LogMessage__c> {objLog})).getInsertedObjects();
                
            }
            //End - Added as a part of LOG_Message Response
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'searchClientMCIService', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse createACRNotification(String sSourceIndividualId, List<Integer> setCaseIds, Map<String, SSP_AssisterAccessRequestCtrl.CaseInfoWrapper> mapCaseInfo, 
                                                              String applicationNumber, Map<String, SSP_AssisterAccessRequestCtrl.CaseInfoWrapper> mapAppInfo) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
		try{
            List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
            
            if(applicationNumber!='' && applicationNumber!=null){
                lstACR = SSP_AssisterRequestAccessService.createAssisterUnverifiedAppACR(sSourceIndividualId,applicationNumber); 
            }
            else{
                lstACR = SSP_AssisterRequestAccessService.createAssisterUnverifiedACR(setCaseIds,mapCaseInfo); 
            }
             
            objResponse.put('lstACR',lstACR);
            List<String> setACRIds = new List<String>();
            for(AccountContactRelation acr : lstACR){
                setACRIds.add(acr.Id);
            }
            
            //Added to get program label         
            String sProgramCode;		                                                               
            if(applicationNumber!='' && applicationNumber!=null){
                sProgramCode = mapAppInfo.get(applicationNumber).ProgramCode;
            }
            else{
                sProgramCode = mapCaseInfo.get(String.valueOf(setCaseIds[0])).ProgramCode;                                                          
            }
                 
             List<String> lstProgram = sProgramCode.split(';');
             Map<String,String> mapProgramPicklistValues = SSP_Utility.getPickListValues('SSP_Application__c', 'ProgramsApplied__c', null);
             String sProgramLabel;
             for(String prgmDet :lstProgram){
                 if(prgmDet=='MA' || prgmDet=='KP'){
                     if(sProgramLabel != null && sProgramLabel != ''){
                         sProgramLabel= sProgramLabel + ',' + mapProgramPicklistValues.get(prgmDet);
                     }
                     else{
                         sProgramLabel= mapProgramPicklistValues.get(prgmDet);
                     }
                 }
             }
    
            //create notification logic
            String identifier ='SF_TOD_003';       
            map<string,object> inputData = new map<string,object>();
            inputData.put('recipientId', sSourceIndividualId);
            inputData.put('recipientType', 'Citizen_Individual');
            inputData.put('acrId', String.join(setACRIds, ';'));
            if(applicationNumber!='' && applicationNumber!=null){
                inputData.put('preferredCommunication', mapAppInfo.get(applicationNumber).PreferredNotificationMethodCode);
                if(mapAppInfo.get(applicationNumber).PrimaryPhoneTypeCode == 'CE')
                    inputData.put('phone', mapAppInfo.get(applicationNumber).PrimaryPhoneNumber);
                else if(mapAppInfo.get(applicationNumber).SecondaryPhoneTypeCode == 'CE')
                    inputData.put('phone', mapAppInfo.get(applicationNumber).SecondaryPhoneNumber);
                inputData.put('email', mapAppInfo.get(applicationNumber).Email);
                inputData.put('citizenFirstName',  mapAppInfo.get(applicationNumber).FirstName);
                inputData.put('nameCitizen',    mapAppInfo.get(applicationNumber).LastName);
                inputData.put('preferredWrittenLanguageCode', mapAppInfo.get(applicationNumber).PreferredWrittenLanguageCode);
            }
            else{
                inputData.put('preferredCommunication', mapCaseInfo.get(String.valueOf(setCaseIds[0])).PreferredNotificationMethodCode);
                if(mapCaseInfo.get(String.valueOf(setCaseIds[0])).PrimaryPhoneTypeCode == 'CE')
                    inputData.put('phone', mapCaseInfo.get(String.valueOf(setCaseIds[0])).PrimaryPhoneNumber);
                else if(mapCaseInfo.get(String.valueOf(setCaseIds[0])).SecondaryPhoneTypeCode == 'CE')
                    inputData.put('phone', mapCaseInfo.get(String.valueOf(setCaseIds[0])).SecondaryPhoneNumber);
                inputData.put('email', mapCaseInfo.get(String.valueOf(setCaseIds[0])).Email);
                inputData.put('citizenFirstName',  mapCaseInfo.get(String.valueOf(setCaseIds[0])).FirstName);
                inputData.put('nameCitizen',    mapCaseInfo.get(String.valueOf(setCaseIds[0])).LastName);
                inputData.put('preferredWrittenLanguageCode', mapCaseInfo.get(String.valueOf(setCaseIds[0])).PreferredWrittenLanguageCode);
            }
            List<User> objNonCitizenUser = SSP_UserSelector.queryUserData (
                                                            new Map<String, String>{'objectName'=>'User','operator'=>'AND'},
                                                            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName'},
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}
        	);
            inputData.put('nameNonCitizen',  objNonCitizenUser[0].Contact.FirstName+' '+objNonCitizenUser[0].Contact.LastName);
            inputData.put('programs',  sProgramLabel);   
            
            Map<String, Object> returnValue= SSP_MessageCenterService.processNotificationMessage(identifier, inputData);
            Object snotificationId = returnValue.get('notificationId'); 
            objResponse.put('notificationId',String.valueOf(snotificationId));
            
            //to find the contact info matches assister directory
            if(inputData.get('email')!=null && inputData.get('email')!=''){
                Boolean result = SSP_AssisterRequestAccessService.searchAssister(String.valueOf(inputData.get('email')));
                objResponse.put('assisterMatchFound',String.valueOf(snotificationId));
            }
            objResponse.bIsSuccess = true;
        }
		catch(Exception ex){
        	List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'createACRNotification', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id); 
		}
        return objResponse;
    }
    
     /*
    * method        : pollingNotificationData
    * @description  : This method is use for polling to get the notification status from citizen.
    * @author       : Rahul Kumar
    * @return       : string 
    * */
    @AuraEnabled
    public static string pollingNotificationData(string notificationId) {
        String sPollResponse;
        try{
            if(notificationId!=null && notificationId!=''){
            String sPermissionFlag;
            List<SSP_Notifications__c> getNotification = new  List<SSP_Notifications__c>();
            if(notificationId != Null){              
                getNotification = SSP_SharingBypassFetcher.fetchRecords(
                                new Map<String, String>{'objectName'=>'SSP_Notifications__c'}, 
                                new Set<String>{'notificationCode__c', 'Linked_Record_Id__c', 'recipientType__c','Id','recipientId__c','Status__c'}, 
                                new Map<String, string>{'Id'=>notificationId}
                );
            }            
            List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation>();
            if(getNotification.size()>0){
                lstAccountContact = SSP_AccountContactRelationSelector.queryACRData(
                    new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                    new Set<String>{'Id','AccountId' ,'RequestAccessPermission__c','PermissionLevel_Medicaid__c','PermissionLevel_SNAP__c','PermissionLevel_StateSupp__c','PermissionLevel_KIHIPP__c', 'PermissionLevel_KTAP__c','PermissionLevel_CCAP__c','ProgramsApplied__c'},
                    new Map<String, String>{'limit'=>'1','Id'=>getNotification[0].Linked_Record_Id__c});
            }
            
            if(lstAccountContact.size()>0) {                
                sPermissionFlag =lstAccountContact[0].RequestAccessPermission__c;
            }
            
            if(getNotification.size()>0){
                if(getNotification[0].Status__c =='Active' && sPermissionFlag != Null){
                    sPollResponse='No Action';
                }else if(getNotification[0].Status__c =='Expired' && (lstAccountContact!=null && lstAccountContact.size()>0) && sPermissionFlag == Null){
                    sPollResponse='Client Accepted';
                }else if(getNotification[0].Status__c =='Expired' && sPermissionFlag == Null){
                    sPollResponse='Client Rejected';
                }
            }
            }
            else{
                sPollResponse='No Action';
            }
        }
        catch(Exception ex){
        	LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'pollingNotificationData', ex.getMessage() , true);            
		}
        return sPollResponse;
    }
    
      /*
        * method        : getAssisterTimeConfig
        * @description  : This method is use to get the Assister timer config details from custom metadata.
        * @author       : Rahul Kumar
        * @return       : timerVal
        * */
    @AuraEnabled
    public static Integer getAssisterTimeConfig() {
        try{
            Integer intTimerVal;
            AppConfig__c getTimerVal = AppConfig__c.getValues('AssisterTimerConfig');
            intTimerVal =integer.valueof(getTimerVal.Value__c);
            return intTimerVal;
        }
        catch(Exception ex){
        	LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'getAssisterTimeConfig', ex.getMessage() , true);   
            return null;
		}
    }

    @AuraEnabled 
    public static string getCurrentLoggedInUserLang(){
        String sUserLang;
        try{
         sUserLang= UserInfo.getLanguage();
         }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'getCurrentLoggedInUserLang', ex.getMessage() , true); 
        }
        return sUserLang;
    }
    @AuraEnabled
    public static SSP_LightningResponse requestConsentApplication(String individualId, String applicationId) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try{
            List<SSP_Application__c> lstApplication = SSP_SharingBypassFetcher.fetchRecords(
                                                                    new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                    new Set<String>{'Id','Account__c','DCCaseNumber__c','Name'}, 
                                                                    new Map<String, String>{'Id'=> applicationId}
                													);    
            objResponse.put('applicationNumber', lstApplication[0].Name);
            if(individualId == null || individualId == ''){
                 List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(applicationId,new set<string>{});
                if(applicationIndividuals != null && (!applicationIndividuals.isEmpty()) && applicationIndividuals[0].SSP_Member__r.IndividualId__c != null){
                    individualId = applicationIndividuals[0].SSP_Member__r.IndividualId__c;
                }
            }
        	Map<String,Object> objAssisterAssociation = SSP_AssisterRequestAccessService.checkApplicationAssociation(individualId, lstApplication[0].Name);
        	objResponse.put('associationResponse', objAssisterAssociation);            
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'requestConsentApplication', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    @AuraEnabled
    public static SSP_LightningResponse updateApplicationBlocked(String applicationId) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try{
            List<SSP_Application__c> lstApplication = SSP_SharingBypassFetcher.fetchRecords(
                                                                    new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                    new Set<String>{'Id','Account__c','DCCaseNumber__c','Name','Status__c'}, 
                                                                    new Map<String, String>{'Id'=> applicationId}
                													);    
            lstApplication[0].Status__c = 'Blocked';
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstApplication, 'upsert', 'SSP_Application__c');   
            objResponse.bIsSuccess = true;
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'requestConsentApplication', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    @AuraEnabled
    public static SSP_LightningResponse revertRequestAccess(String applicationId) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_Application__c> lstApplication =  new  List<SSP_Application__c>();
        List<AccountContactRelation> lstACR =  new  List<AccountContactRelation>();
        try{
            
            if(applicationId != null && applicationId != ''){
                lstApplication = SSP_SharingBypassFetcher.fetchRecords(
                    new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                    new Set<String>{'Id','Account__c','DCCaseNumber__c','Name','Status__c'}, 
                    new Map<String, String>{'Id'=> applicationId}
                );    
            }
            if(!lstApplication.isEmpty()){
                User loggedInUser = [Select Id, ContactId from User where Id = :UserInfo.getUserId()];
                lstACR =    SSP_SharingBypassFetcher.fetchAssisterCurrentACRList(lstApplication[0].Account__c, loggedInUser.ContactId);  
            }
            if(!lstACR.isEmpty()){
                lstACR[0].RequestAccessPermission__c = null;
                lstACR[0].Roles = null;
                List<SSP_Notifications__c> lstNotifications = new List<SSP_Notifications__c>();
                Set<String> notificationIdSet = new Set<String>();
                lstNotifications = SSP_SharingBypassFetcher.fetchRecords(
                    new Map<String, String>{'objectName'=>'SSP_Notifications__c','operator'=>'AND'}, 
                    new Set<String>{'notificationCode__c', 'Linked_Record_Id__c', 'recipientType__c','Id','recipientId__c','Status__c'}, 
                    new Map<String, string>{'Linked_Record_Id__c'=>lstACR[0].Id,'notificationCode__c'=>'SF-TOD-003','Status__c'=>'Active'}
                );
                for(SSP_Notifications__c objNotification: lstNotifications){
                    objNotification.status__c = 'Expired';
                    notificationIdSet.add(objNotification.Id);
                }
                if(!lstNotifications.isEmpty()){
                    SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstNotifications, 'upsert', 'SSP_Notifications__c');   
                    
                    //Expire Survey 
                    List<SurveyInvitation> lstSurveys = SSP_SharingBypassFetcher.fetchRecords(
                        new Map<String, String>{'objectName'=>'SurveyInvitation','operator'=>'AND','IN'=>'SSP_Notifications__c'}, 
                        new Set<String>{'Id','SSP_Notifications__c'}, 
                        new Map<String, string>{'limit'=>'100','SSP_Notifications__c'=>String.join(new List<String>(notificationIdSet),',')}
                    );

                    if(!lstSurveys.isEmpty()){
                        for(SurveyInvitation objSurvey: lstSurveys){
                            objSurvey.InviteExpiryDateTime= SSP_Utility.now();
                        }
                        SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstSurveys, 'upsert', 'SurveyInvitation'); 
                     }
                }
                
                
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstACR, 'upsert', 'AccountContactRelation'); 
            }
            
            objResponse.bIsSuccess = true;
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'requestConsentApplication', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
}