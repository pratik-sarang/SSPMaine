/*
* classname 	: SSP_AuthRepAccessRequestCtrl
* @description 	: This class is use to Search and Request Access for Authorize representative.
* @author 		: Ashwin Kasture
* @date 		: 4th June 2020
* MODIFICATION LOG
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		4th June 2020	Initial Version
*/
public with sharing class SSP_AuthRepAccessRequestCtrl {
	/*
	* method 		: loadAuthRepDetails
	* @description  : This method is use to load the Auth Resp Details.
	* @author 		: Ashwin Kasture
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse loadAuthRepDetails() {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            Map<String, Object> objResp = SSP_AuthRepAccessRequestService.loadAuthRepDetails();
            objResponse.put('authRepDetails', objResp);
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AuthRepAccessRequestCtrl', 'loadAuthRepDetails', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }

	/*
	* method 		: searchClientMCIService
	* @description  : This method is use to search client by MCI service.
	* @author 		: Ashwin Kasture
	* @param 		: String strClientDetails
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse searchClientMCIService(String sClientDetails) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            sClientDetails = String.escapeSingleQuotes(sClientDetails);
            Map<String, Object> objMCIResp = null;
            String sRoleType = SSP_Utility.getSelectedRole();
            objMCIResp = SSP_AuthRepAccessRequestService.searchClientMCIService(sClientDetails);
            List<Object> lstLogs = (List<Object> )objMCIResp.get('logMessageResponse'); // Added as part of LOG_Message purpose
            objMCIResp.remove('logMessageResponse'); // Added as part of LOG_Message purpose
            objResponse.put('searchClientResponse', objMCIResp);
            
            String sApplicationNumber = objMCIResp != null && objMCIResp.get('applicationNumber') != null ? String.valueOf(objMCIResp.get('applicationNumber')) : '';
            String sCaseNumber = objMCIResp != null && objMCIResp.get('caseNumber') != null ? String.valueOf(objMCIResp.get('caseNumber')) : '';
            
            List<Object> objLoginUserDetail = (objMCIResp !=null && objMCIResp.get('loginUserDetails') != null) ? (List<Object>)objMCIResp.get('loginUserDetails'):null;
            
            SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper objMCIDetails = objMCIResp != null && objMCIResp.get('mciDetails') != null ? (SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper)objMCIResp.get('mciDetails') : null;
            String sSourceIndividualId = objMCIDetails != null ? objMCIDetails.sSourceIndividualId : '';
            Boolean bIsFullMatch = objMCIDetails != null ? objMCIDetails.bIsFullMatch : false;
            
            if(bIsFullMatch && String.isNotBlank(sSourceIndividualId) && String.isBlank(sApplicationNumber)) {
                Map<String, Object> objRevSSPDCResp = SSP_AuthRepAccessRequestService.reverseSSPDCService(sSourceIndividualId, null, sRoleType);
                objResponse.put('reverseSSPDCResponse', objRevSSPDCResp);
            } else if (bIsFullMatch && String.isNotBlank(sSourceIndividualId) && String.isNotBlank(sApplicationNumber)) {
                List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation> ();
                List<SSP_ApplicationIndividual__c> lstAppInd = SSP_AuthRepAccessRequestService.getApplicationBasedOnIndividualId(sSourceIndividualId, sApplicationNumber);
                List<User> lstLoginUserDetail = (objMCIResp !=null && objMCIResp.get('loginUserDetails') != null) ? (List<User>)objMCIResp.get('loginUserDetails'):null;
                
                
                if(lstAppInd != null & !lstAppInd.isEmpty()) {
                	List<String> lstAccountIds = new List<String>{lstAppInd[0].SSP_Application__r.Account__c};
                	                	
                	lstAccountContact = SSP_AuthRepAccessRequestService.getExistingACR(lstAccountIds, lstLoginUserDetail[0].ContactId);
                    objResponse.put('existingACRResponse', lstAccountContact);
                }
                objResponse.put('applicationResponse', lstAppInd);
                objResponse.put('existingACRResponse', lstAccountContact);
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
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AuthRepAccessRequestCtrl', 'searchClientMCIService', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
	* method 		: requestAccess
	* @description  : This method is use to Request Access for a Citzen. And update the Address, Address Line2, Relationship details.
	* @author 		: Ashwin Kasture
	* @param 		: String strRequestAccessDetails
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse requestAccess(String sRequestAccessDetails) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            sRequestAccessDetails = String.escapeSingleQuotes(sRequestAccessDetails);
            Map<String, Object> mapReqAccessDetails = (Map<String, Object>)JSON.deserializeUntyped(sRequestAccessDetails);
            String sApplNumberParam = mapReqAccessDetails.get('applicationNumber').toString();
            if(String.isBlank(sApplNumberParam)) {
            	Map<String, Object> objResp = SSP_AuthRepAccessRequestService.requestAccess(sRequestAccessDetails);
                objResponse.put('requestAccessData', objResp);
            } else if(String.isNotBlank(sApplNumberParam)) {
                Map<String, Object> objResp = SSP_AuthRepAccessRequestService.requestApplicationAccess(sRequestAccessDetails);
                objResponse.put('requestAccessData', objResp);
            }
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AuthRepAccessRequestCtrl', 'requestAccess', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }        
        return objResponse;
    }
    
    /*
	* method 		: showClientProgramPermission
	* @description  : This method is use to View the Program Permission Details.
	* @author 		: Ashwin Kasture
	* @return 		: SSP_LightningResponse
	* */
    @AuraEnabled
    public static SSP_LightningResponse showClientProgramPermission(String sNotificationDetails) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            sNotificationDetails = String.escapeSingleQuotes(sNotificationDetails);
            Map<String, Object> objResp = SSP_AuthRepAccessRequestService.showClientProgramPermission(sNotificationDetails);
            objResponse.put('showProgramPermission', objResp);
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AuthRepAccessRequestCtrl', 'showClientProgramPermission', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }        
        return objResponse;
    }

    /*
    * classname 	: MCIResponseWrapper
    * @description 	: This class is use set the MCI reponse data into wrapper variables to bind it in UI.
    * @author 		: Ashwin Kasture
    * @date 		: 9th June 2020
    */
    public with sharing class MCIResponseWrapper {
        @AuraEnabled public Boolean bIsFullMatch {get;set;}
        @AuraEnabled public Boolean bIsPartialMatch {get;set;}
        @AuraEnabled public Boolean bIsNoMatch {get;set;}

        @AuraEnabled public String sSourceIndividualId {get;set;}
    }
    
    /*
    * classname 	: SSPDCResponseWrapper
    * @description 	: This class is use set the SSPDC response data into wrapper variables to send it to UI.
    * @author 		: Ashwin Kasture
    * @date 		: 16th June 2020
    */
    public with sharing class ReverseSSPDCResponseWrapper {
        @AuraEnabled public List<AuthRepAndAssiterClientInfoWrapper> AuthrepandAssiterClientInfo {get;set;}
    	@AuraEnabled public List<CaseInfoWrapper> CaseInfo {get;set;}
    }
	
    /*
    * classname 	: AuthRepAndAssiterClientInfoWrapper
    * @description 	: This class is use set the Auth Rep/ Assister SSPDC response data into wrapper variables to send it to UI.
    * @author 		: Ashwin Kasture
    * @date 		: 16th June 2020
    */
    public with sharing class AuthRepAndAssiterClientInfoWrapper {
        @AuraEnabled public String UserId  {get;set;}
        @AuraEnabled public String RepresentativeRelationshipCode  {get;set;}
        @AuraEnabled public String ProgramsApplied  {get;set;}
        @AuraEnabled public String CaseNumber  {get;set;}
        @AuraEnabled public String PermissionLevelMedicaid  {get;set;}
        @AuraEnabled public String PermissionLevelSNAP  {get;set;}
        @AuraEnabled public String PermissionLevelStateSupp  {get;set;}
        @AuraEnabled public String PermissionLevelKIHIPP  {get;set;}
        @AuraEnabled public String PermissionLevelCCAP {get;set;}
        @AuraEnabled public String PermissionLevelKTAP {get;set;}
        @AuraEnabled public String Street {get;set;}
        @AuraEnabled public String AddressLine2 {get;set;}
        @AuraEnabled public String CountyCode {get;set;}
        @AuraEnabled public String SSP_State {get;set;}
        @AuraEnabled public String Zipcode5 {get;set;}
        
        @AuraEnabled public String Suffix {get;set;}
        @AuraEnabled public String FirstName {get;set;}
        @AuraEnabled public String MiddleName {get;set;}
        @AuraEnabled public String LastName {get;set;}
        @AuraEnabled public String Gender {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String Birthdate {get;set;}
        @AuraEnabled public String SSN {get;set;}
        @AuraEnabled public String RoleType {get;set;}
        @AuraEnabled public String DCRepresentativeId {get;set;}
        @AuraEnabled public String isAuthRepVerified {get;set;}
        @AuraEnabled public String Phone {get;set;}
        @AuraEnabled public String PrimaryPhoneExtension {get;set;}
        @AuraEnabled public String PreferredLanguageCode {get;set;}
        @AuraEnabled public String OrgranizationIdentificationNumber {get;set;}
        @AuraEnabled public String OrganizationName {get;set;}
        @AuraEnabled public String OrganizationId {get;set;}
    }
	
    /*
    * classname 	: CaseInfoWrapper
    * @description 	: This class is use set the Case Info SSPDC response data wrapper variables to send it to UI.
    * @author 		: Ashwin Kasture
    * @date 		: 16th June 2020
    */
    public with sharing class CaseInfoWrapper {
        @AuraEnabled public String CaseNumber {get;set;}
        @AuraEnabled public String ProgramCode {get;set;}
        @AuraEnabled public String LastUpdatedDate {get;set;}
        
        @AuraEnabled public String FirstName {get;set;}
        @AuraEnabled public String LastName {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String PrimaryPhoneTypeCode {get;set;}
        @AuraEnabled public String PrimaryPhoneNumber {get;set;}
        @AuraEnabled public String PrimaryPhoneExetnsion {get;set;}
        @AuraEnabled public String SecondaryPhoneTypeCode {get;set;}
        @AuraEnabled public String SecondaryPhoneNumber {get;set;}
        @AuraEnabled public String SecondaryPhoneExtension {get;set;}
        @AuraEnabled public String PreferredWrittenLanguageCode {get;set;}
        @AuraEnabled public String PreferredSpokenLanguageCode {get;set;}
        @AuraEnabled public String PreferredNotificationMethodCode {get;set;}
    }
    
    /*
    * classname 	: ApplicationInfoWrapper
    * @description 	: This class is use set the Application Info SSPDC response data wrapper variables to send it to UI.
    * @author 		: Ashwin Kasture
    * @date 		: 22th June 2020
    */
    public with sharing class ApplicationInfoWrapper {
        @AuraEnabled public String ApplicationNumber {get;set;}
        @AuraEnabled public String ProgramCode {get;set;}
        @AuraEnabled public String LastUpdatedDate {get;set;}
        @AuraEnabled public String UserId {get;set;}
        
        @AuraEnabled public String FirstName {get;set;}
        @AuraEnabled public String LastName {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String PrimaryPhoneTypeCode {get;set;}
        @AuraEnabled public String PrimaryPhoneNumber {get;set;}
        @AuraEnabled public String PrimaryPhoneExetnsion {get;set;}
        @AuraEnabled public String SecondaryPhoneTypeCode {get;set;}
        @AuraEnabled public String SecondaryPhoneNumber {get;set;}
        @AuraEnabled public String SecondaryPhoneExtension {get;set;}
        @AuraEnabled public String PreferredWrittenLanguageCode {get;set;}
        @AuraEnabled public String PreferredSpokenLanguageCode {get;set;}
        @AuraEnabled public String PreferredNotificationMethodCode {get;set;}
    }
}