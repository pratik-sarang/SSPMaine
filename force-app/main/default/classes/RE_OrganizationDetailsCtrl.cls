/**
* Class Name    : RE_OrganizationDetailsCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Fetching the logged in community user associated accounts
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  SRIKANTH       Initial Version
*  05/29/2019  SRIKANTH       Security Fixes
*  07/23/2019  Anuj			  US 588 - Update Location data on Save
*  Modified updateOrganizationDetail, fetchOrganizationDetails
**/

public with sharing class RE_OrganizationDetailsCtrl{

/*********************************************************************************************************************************
* @author       SRIKANTH
* @date         05/02/2019
* @methodname   fetchOrganizationDetails()
* @description  This methods is used to get the logged in user associated Account record field's
* @param        NA
* @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
@AuraEnabled
public static RE_CreateLightningServerResponse fetchOrganizationDetails(){
GeneralUtility.isAuthenticatedUser();        
Boolean bSuccess = false;        
Map<String, Object> mapResponse = new Map<String, Object>();
Map<String, Object> errorMap = new Map<String, Object>(); 
try {
	//fetch the logged in userid 
	Id loggedinUserId = UserInfo.getUserId();
	//String sUserWhereClause = 'Id=:loggedinUserId';
	String sUserWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedUser;
	Map<String, String> mapUserQueryParameters = new Map<String, String>();
	mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
	mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
	String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User','ContactId', mapUserQueryParameters);            
	List<User> loggedInUser = Database.query(userQuery);            
            // SIT ErrorLog message fix - By Sures - Starts
            Id userContactId;
            if(!loggedInUser.isEmpty()){
                userContactId = loggedInUser[0].ContactId;  
            }
            // SIT ErrorLog message fix - By Sures - Ends       
	//fetch the current logged in user contact's AccountId 
	//String sContactWhereClause = 'Id=:userContactId';
	String sContactWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedContact;
	String sContactSafeQuery;
	Map<String, String> mapContactQueryParameters = new Map<String, String>();            
	mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sContactWhereClause);
	mapContactQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
	Map<Boolean, String> mapResponseContact = RE_DataAccessChecker.getFieldsAccessibility('Contact', 'AccountId', mapContactQueryParameters);
		
	if (mapResponseContact.get(true) != null) {
		sContactSafeQuery = mapResponseContact.get(true);
	} else {
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_OrganizationDetailsCtrl','fetchOrganizationDetails','Some Fields do not have the required access on contact object ' + mapResponseContact.get(false),true);
	}
	List<Contact> userContactRec = new List<Contact>();
	if (sContactSafeQuery != null) {
		userContactRec = Database.query(sContactSafeQuery);                
	} 
	//Added By Kojashree -- SSP Merge
	String contactAccountId = GeneralUtility.getLoggedInAccountId();
            // SIT ErrorLog message fix - By Sures - Starts
           
            // SIT ErrorLog message fix - By Sures - Ends
	//fetch the fields based on the Contact's Account id retrevied 
	//String sAccountFields = 'Name,Twitter__c,Facebook__c,Status__c,CommonlyUsedName__c,POC_Phone__c,POC_Name__c,POC_Email__c,CountyServed__c,Website,Phone,OrganizationUniqueId__c';
	String sAccountFields = RE_DataBaseQueryFields.sFieldsToQueryOnAccount;
	//String sAccountWhereClause = 'Id=:contactAccountId';
	String sAccountWhereClause = RE_DataBaseQueryFields.sWhereClauseGetAccountId;
	String sAccountSafeQuery;
	Map<String, String> mapAccountQueryParameters = new Map<String, String>();
	mapAccountQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sAccountWhereClause);
	mapAccountQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
	Map<Boolean, String> mapResponseAccount = RE_DataAccessChecker.getFieldsAccessibility('Account', sAccountFields, mapAccountQueryParameters);
	if (mapResponseAccount.get(true) != null) {
		sAccountSafeQuery = mapResponseAccount.get(true);
	} else {
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_OrganizationDetailsCtrl','fetchOrganizationDetails','Some Fields do not have the required access on Account Object ' + mapResponseAccount.get(false),true);
	}
		
	List<Account> contactAccountRec = new List<Account>();
	if (sAccountSafeQuery != null) {
		contactAccountRec = Database.query(sAccountSafeQuery);                
	} 
		
	if (!contactAccountRec.isEmpty()) {
                if (contactAccountRec[0].Phone != null){
                    contactAccountRec[0].Phone = GeneralUtility.formatphonenumber(contactAccountRec[0].Phone);
                }
				if (contactAccountRec[0].POC_Phone__c != null){
                    contactAccountRec[0].POC_Phone__c = GeneralUtility.formatphonenumber(contactAccountRec[0].POC_Phone__c);
                }
		mapResponse.put('Account', contactAccountRec[0]);
	}
		
            List<Schema.PicklistEntry> lstStatusPicklistOptions = Account.Status__c.getDescribe().getPicklistValues();
            List<PicklistWrapper> lstStatusOptions = new List<PicklistWrapper>();
            for(Schema.PicklistEntry itrStatus : lstStatusPicklistOptions){
               lstStatusOptions.add(new PicklistWrapper(itrStatus.getLabel(),itrStatus.getValue(),false));
            } 
			if (!lstStatusOptions.isEmpty()) {
                mapResponse.put('AccountStatus', lstStatusOptions);
            } 

            /*//the below General Utlity class is used to fetch the Account status field values
            List<String> pickval = GeneralUtility.getPicklistValues('Account', 'Status__c');
            if (!pickval.isEmpty()) {
                mapResponse.put('AccountStatus', pickval);
            } */
            
            //the below General Utlity class is used to fetch the State field values
            List<String> stateValues = GeneralUtility.getPicklistValues('Location__c', 'State__c');
            if (!stateValues.isEmpty()) {
                mapResponse.put('stateValues', stateValues);            
            } 
            /* [Suresh] SIT Erorr log fix | added empty check - starts  */
            List<Location__c> lstLocations = new List<Location__c>();
            Location__c locationHeadQuarter = new Location__c();
            if(!contactAccountRec.isEmpty()){
                lstLocations = fetchLocations(contactAccountRec[0].Id);
                locationHeadQuarter = fetchLocationHeadQuarter(contactAccountRec[0].Id);
            }
           /* [Suresh] SIT Erorr log fix -Ends */
            RE_LocationCtrl.locationWrapper objLocationWrapper; 
			if(locationHeadQuarter != null){
				objLocationWrapper = new RE_LocationCtrl.locationWrapper(locationHeadQuarter,true);
			}
				
			if (!lstLocations.isEmpty()) {
				mapResponse.put('Locations', lstLocations);
			}
				
			if (objLocationWrapper != null) {
				mapResponse.put('LocationHeadQuarter',objLocationWrapper);
			}
	Boolean bHasPermission = userPermissionAccess();
	mapResponse.put('isAdminUser', bHasPermission);
	Boolean bAgencyHasPermission = agencyUserPermissionAccess();
    mapResponse.put('isAgencyUser', bAgencyHasPermission);
	bSuccess = true; 
} catch (Exception e) {
	//error message is to store the error recorded in failure
	errorMap.put('error', e.getMessage());
	LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationDetailsCtrl','fetchOrganizationDetails', e.getMessage(), true); 
}
return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);        
}


/*********************************************************************************************************************************
* @author       SRIKANTH
* @date         05/02/2019
* @methodname   updateOrganizationDetail()
* @description  This method is used to update the Organization Detail.
* @param        organizationRec    (sObject)  : To retrieve the data from the UI.
* @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
@AuraEnabled
public static RE_CreateLightningServerResponse updateOrganizationDetail(Account organizationRec, RE_LocationCtrl.locationWrapper locationRec){ 
Boolean bSuccess = false;
GeneralUtility.isAuthenticatedUser();
Map<String, Object> mapResponse = new Map<String, Object>();
Map<String, Object> errorMap = new Map<String, Object>();
try {
	if (organizationRec.Id != null) {
		Database.SaveResult[] sr = RE_DataAccessChecker.updateObject(Account.sObjectType, organizationRec);
		mapResponse.put('isSuccessful', true);
		bSuccess = true;
	}
} catch (Exception e) {
	errorMap.put('error', e.getMessage());
	LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationDetailsCtrl','updateOrganizationDetail', e.getMessage(), true);
}
return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
}

/*********************************************************************************************************************************
* @author       SRIKANTH
* @date         05/02/2019
* @methodname   fetchLocations()
* @description  This method is used to fetch the locations associated to the logged in user's Account Record
* @param        AccountId    (sObject)  : logged in user Account Record Id
* @return       List<Location__c> : List of locations records
************************************************************************************************************************************/
public static List<Location__c> fetchLocations(Id accountId) {
List<Location__c> locationResults = new List<Location__c>();
try {            
		
	String sLocationFields = RE_DataBaseQueryFields.sLocationFieldsOrgSearch;
		
	String sLocationWhereClause = RE_DataBaseQueryFields.sLocationWhereClauseOrgSearch;
	String sLocationSafeQuery;
	Map<String, String> mapLocationQueryParameters = new Map<String, String>();
	mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sLocationWhereClause);
	Map<Boolean, String> mapResponseLocation = RE_DataAccessChecker.getFieldsAccessibility('Location__c',sLocationFields,mapLocationQueryParameters);
		
	if (mapResponseLocation.get(true) != null) {
		sLocationSafeQuery = mapResponseLocation.get(true);
	} else {
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationDetailsCtrl','fetchLocations', 'some requried fields are missing', true);
	}
		
	if (sLocationSafeQuery != null) {
		locationResults = Database.query(sLocationSafeQuery);                
	}            
} catch (Exception e) {
	//error message is to store the error recorded in failure
	LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationDetailsCtrl','fetchLocations', e.getMessage(), true);
}        
return locationResults;        
}

/*********************************************************************************************************************************
* @author       SRIKANTH
* @date         05/02/2019
* @methodname   fetchLocationHeadQuarter()
* @description  This method is used to retrieve the head quarter location to the associated Account
* @param        AccountId    (sObject)  : logged in user Account Record Id
* @return       Location__c : Location record data
************************************************************************************************************************************/    
public static Location__c fetchLocationHeadQuarter(Id accountId) {
List<Location__c> locationResults = new List<Location__c>();
try {            
	//String sLocationFields ='Name,Address1__c,Address2__c,City__c,State__c,Zip__c,ZipExtensionCode__c,IsPrimary__c,Account__c';
	String sLocationFields = RE_DataBaseQueryFields.sLocationFieldsToQuery;
	//String sLocationWhereClause = 'IsPrimary__c=true AND Account__c=:accountId';
	String sLocationWhereClause = RE_DataBaseQueryFields.sWhereClauseOnLocDetails;
	String sLocationSafeQuery;
	Map<String, String> mapLocationQueryParameters = new Map<String, String>();
	mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sLocationWhereClause);
	mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
	Map<Boolean, String> mapResponseLocation = RE_DataAccessChecker.getFieldsAccessibility('Location__c', sLocationFields, mapLocationQueryParameters);            
	if (mapResponseLocation.get(true) != null) {
		sLocationSafeQuery = mapResponseLocation.get(true);
	}            
	if (sLocationSafeQuery!= null) {
		locationResults = Database.query(sLocationSafeQuery);                
	}       
} catch(Exception e) {
	LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationSearchCtrl','fetchLocationHeadQuarter', e.getMessage(), true);
}  
return locationResults.isEmpty() ? null : locationResults[0];
}

/*********************************************************************************************************************************
* @author       SRIKANTH
* @date         05/02/2019
* @methodname   userPermissionAccess()
* @description  This method is used to send bool value 
* @return       boolean
************************************************************************************************************************************/
public static Boolean userPermissionAccess(){        

Boolean bIsStaffUser = false;	        
try {
	Id loggedInUserId = UserInfo.getUserId();
	String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
    if(selectedRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF){
        bIsStaffUser = true;
    }
} catch(Exception e) {
	LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_OrganizationSearchCtrl','userPermissionAccess', e.getMessage(), true);
}  
return bIsStaffUser;
}
    /*********************************************************************************************************************************
    * @author       CHFS
    * @date         04/01/2020
    * @methodname   agencyUserPermissionAccess()
    * @description  This method is used to send bool value 
    * @return       boolean
    ************************************************************************************************************************************/
    public static Boolean agencyUserPermissionAccess(){        
       
        Boolean bIsStaffUser = false;           
        try {
            Id loggedInUserId = UserInfo.getUserId();
			String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
            if(selectedRole == RE_GlobalConstants.CASE_WORKER){
                bIsStaffUser = true;
            }
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_OrganizationSearchCtrl','agencyUserPermissionAccess', e.getMessage(), true);
        }  
        return bIsStaffUser;
    }
    public class PicklistWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String value {get;set;}
        @AuraEnabled
        public Boolean selected{get;set;}
        
        
        public PicklistWrapper(String label, String value, Boolean selected){
            this.label = label;
            this.value = value; 
            this.selected = selected;
        }
    }
}