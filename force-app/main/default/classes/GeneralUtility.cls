/**
* General Utility class to contain methods used commonly accross modules.
* 
a* @author Srikanth
* @date 04/26/2019 
*/

/**
Comment LOG
Author                      Date              Mofication made
Megha Mittal               12/3/2019          Added the changes for helpdesk contact number - 339715
Megha Mittal               12/10/2019         Added the changes to fetch logged in User Account Details for emails- Bug(339713)
-------------------------------------------------------------------
*/

  
Public inherited sharing Class GeneralUtility {
    
    Public Static Profile loggedInUserProfile;
    Public Static String SelectedRole;

    public static final String sFieldsToQueryOnRecordType = 'DeveloperName,Id,IsActive,Name,SobjectType';
    public static final String sWhereClauseOnRecordTypeRecord = 'DeveloperName=: strRecordTypeDeveloperName and SobjectType=: strSobjectName';

    /*
*  @method: GeneralUtility.getLoggedInUserProfile()
*  @description: method returns Profile Of logged In user. 
*  Consumes one SOQL per transaction even if called multiple times
*  
*/
    Public Static Profile getLoggedInUserProfile(){
        If (loggedInUserProfile == null){
            loggedInUserProfile = [Select Id, Name from Profile where Id =: userinfo.getProfileid()];
        }
        
        Return loggedInUserProfile;
    }
    
    /*
*Method Name: fetchRecordType
*Description: Method to fetch the record type based on provided record type developer name And sobject name.
Returns record type instance.
*
*/
    Public Static RecordType fetchRecordType(String strRecordTypeDeveloperName, String strSobjectName){

        RecordType result = null;
        String sFieldsToQueryOnRecordType = sFieldsToQueryOnRecordType;
        String sWhereClauseOnRecordType = sWhereClauseOnRecordTypeRecord;
        Map<String,String> mapRecordTypeQueryParameters = new Map<String,String>();
        mapRecordTypeQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnRecordType);
        Map<Boolean,String> mapRecordTypeQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('RecordType', sFieldsToQueryOnRecordType, mapRecordTypeQueryParameters);
        String switchRecordTypeKey = (mapRecordTypeQueryResponse.get(true) != null) ? 'success' : 'failure';  
        switch on (switchRecordTypeKey) {
            when 'success' {
                List<RecordType> lstRecordTypeRecords = (List<RecordType>) Database.query(mapRecordTypeQueryResponse.get(true));
                if(lstRecordTypeRecords != null && !lstRecordTypeRecords.isEmpty()) {
                    result =  lstRecordTypeRecords[0];
                }
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','fetchRecordType','Some Fields doesn\'t have the required access :: '+mapRecordTypeQueryResponse.get(false), true);
            }
        }
        return result;         
    }
    
    public static String getLoggedInUserContactId(){
        GeneralUtility.isAuthenticatedUser();
        return [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
    }
    public static String getLoggedInUserContactEmail(){
        GeneralUtility.isAuthenticatedUser();
        return [SELECT Id, Contact.Email FROM User WHERE Id =:UserInfo.getuserId()].Contact.Email;
    }
    public static String getLoggedInUserContactName(){
        GeneralUtility.isAuthenticatedUser();
        return [SELECT Id, Contact.Name FROM User WHERE Id =:UserInfo.getuserId()].Contact.Name;
    }
    public static String getContactNameFromId(String conId){
        GeneralUtility.isAuthenticatedUser();
        Id contactId = Id.valueOf(conId);
        String contactName;
        if (Schema.sObjectType.Contact.fields.Name.isAccessible()) {
            Contact[] objCon = [SELECT Id, Name FROM Contact WHERE Id =:contactId];
            contactName = objCon.size() > 0 ? objCon[0].Name : '';
        }
        return contactName;
    }

    /*
*Method Name: getLoggedInUserAccountId()
*Description: gets the logged in user contact account.
*
*/
    /*public static String getLoggedInUserAccountId(){
        List<Contact> lstContacts = new List<Contact>();
        User u;
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType)){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserForLoggedIn;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserForLoggedIn;
            String loggedinUserId = UserInfo.getuserId();
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    u = (User) Database.query(mapUserQueryResponse.get(true));
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInUserAccountId','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
        String returnId = '';
        try{
            if(RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType)){ // PMD Report Check.
                String sFieldsToQueryOnContact = RE_DataBaseQueryFields.sFieldsToQueryOnContactForLoggedIn;
                String sWhereClauseOnContact = RE_DataBaseQueryFields.sWhereClauseOnContactForLoggedIn;
                String contactId = u.ContactId;
                Map<String,String> mapContactQueryParameters = new Map<String,String>();
                mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnContact);
                Map<Boolean,String> mapContactQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsToQueryOnContact, mapContactQueryParameters);
                String switchUserKey = (mapContactQueryResponse.get(true) != null) ? 'success' : 'failure';    
                switch on (switchUserKey) {
                    when 'success' {
                        lstContacts = (List<Contact>) Database.query(mapContactQueryResponse.get(true));
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInUserAccountId','Some Fields doesn\'t have the required access :: '+mapContactQueryResponse.get(false), true);
                    }
                }
            }
            if(lstContacts.size() > 0){
                returnId = lstContacts[0].AccountId;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getLoggedInUserAccountId', '****No Account Found for Logged in User****' , true);
        }
        return returnId;
    }
    /* 
*Method Name: getLoggedInUserAccount()
*Description: gets the logged in user contact account.
*
*/
  /* public static Account getLoggedInUserAccount(){
        List<Contact> lstContacts = new List<Contact>();
        User u;
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType)){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserForLoggedIn;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserForLoggedIn;
            String loggedinUserId = UserInfo.getuserId();
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    u = (User) Database.query(mapUserQueryResponse.get(true));
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInUserAccountId','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
        Account returnAccount = new Account();
        try{
            if(RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType)){ // PMD Report Check.
                String sFieldsToQueryOnContact = RE_DataBaseQueryFields.sFieldsToQueryOnContactForLoggedIn;
                String sWhereClauseOnContact = RE_DataBaseQueryFields.sWhereClauseOnContactForLoggedIn;
                String contactId = u.ContactId;
                Map<String,String> mapContactQueryParameters = new Map<String,String>();
                mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnContact);
                Map<Boolean,String> mapContactQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsToQueryOnContact, mapContactQueryParameters);
                String switchUserKey = (mapContactQueryResponse.get(true) != null) ? 'success' : 'failure';    
                switch on (switchUserKey) {
                    when 'success' {
                        lstContacts = (List<Contact>) Database.query(mapContactQueryResponse.get(true));
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInUserAccountId','Some Fields doesn\'t have the required access :: '+mapContactQueryResponse.get(false), true);
                    }
                }
            }
            if(lstContacts.size() > 0){
                returnAccount = lstContacts[0].Account;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getLoggedInUserAccountId', '****No Account Found for Logged in User****' , true);
        }
        return returnAccount;
    }
    
    /*
*Method Name: getLoggedInUserProfileName
*Description: Returns the Profile Name for the logged in User.
*
*/
    public static String getLoggedInUserProfileName(){
        Id profileId = UserInfo.getProfileId();
        String sName =  [SELECT Name FROM Profile WHERE Id =:profileId LIMIT 1].Name;
        return sName;
    }
    
    /*
* Name : getPicklistValues
* @desc: Created to get Picklist values Dynamically.
*/     
    public static List<String> getPicklistValues(String objectName, String fieldName){
        List<String> lstPLValues = new List<String>();
        if(objectName!='' && objectName !=null && fieldName !='' && fieldName !=null){
            String[] arrTypes = new String[]{objectName};
                Schema.DescribeSObjectResult[] arrSobjectDescribe = Schema.describeSObjects(arrTypes); //describe the sobject
            Map<String, Schema.SObjectField> mapOfFields = arrSobjectDescribe[0].fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> lstPickistLValues = mapOfFields.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : lstPickistLValues) { //for all values in the picklist list
                lstPLValues.add(a.getValue()); //add the value and label to our final list
            }
        }
        return lstPLValues; //return the List
    }
    
    /*

    
    /*
*Method Name: fetchFieldsPicklistValueAPIName
*Description:  Returns the map of Field Name to map of picklist value and api name
*
*/
    public static Map<String,Map<String,String>> fetchFieldsPicklistValueAPIName(String objectName, String lstFields){
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Map<String,Map<String,String>>  mapFieldPicklistValues  = new Map<String,Map<String,String>>();
        
        String[] split = lstFields.split(',');
        try{
            for(String fieldName : split){
                
                Map<String,String> mapPicklistValueAPI = new Map<String,String>();
                for(Schema.PicklistEntry a: fieldMap.get(fieldName).getDescribe().getPickListValues()){
                    
                    mapPicklistValueAPI.put(a.getLabel(),a.getValue());
                }
                mapFieldPicklistValues.put(fieldName,mapPicklistValueAPI);
                
            }
        }
        catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'fetchFieldsPicklistValueAPIName', 'Exception Handled' , true);
            throw e;
        }
        return mapFieldPicklistValues;
    }
    
    /**
* @method: isAuthenticatedUser
* @desc Checks if the user is authentiacted to access the system
* @param objType -- SObjectType 
* @return throws exception for non authenticated users.
* */
    public static void isAuthenticatedUser() {
        if (UserInfo.getUserType() == 'Guest') {
            throw new AuthenticationException('*** You are not authenticated to access the system ***');
        }        
    }
    
 
    Public Class AuthenticationException extends Exception{}
    
    
    /**
* @Method : GeneralUtility.getRecrodTypeIdBySobjectAndDevName()
* @Description : Added this method To query the record type id Using schema Not by query - Defect #297514
* */
    Public Static Id getRecrodTypeIdBySobjectAndDevName(String sobjectName, String strRecordTypeDeveloperName ){
        Return Schema.describeSObjects(New String[]{sobjectName}).get(0).getRecordTypeInfosByDeveloperName().get(strRecordTypeDeveloperName).getRecordTypeId();
    }
    
    /**
    * method name: getCommunityUsersSetting
    * @Description : get the community user setting metadata
    * */
    /*public static List<RECommunityUsersConfiguration__mdt> getCommunityUsersSetting(String sRole){
        List<RECommunityUsersConfiguration__mdt> lstUserConfig =  new List<RECommunityUsersConfiguration__mdt>();
        
        String sFieldsToQueryOncommunityConfig = 'Label, AllowIntegrationforUserCreation__c, PermissionSets__c, ProfileName__c, Role__c';
        String sWhereClauseOncommunityConfig = (sRole != null ) ? 'Role__c =: sRole' : null;
        
        
        Map<String,String> mapcommunityConfig = new Map<String,String>();
        if(sWhereClauseOncommunityConfig != null){
            mapcommunityConfig.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOncommunityConfig);
        }
        mapcommunityConfig.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        
        String sCommunityConfigQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('RECommunityUsersConfiguration__mdt', 
                                                                                          sFieldsToQueryOncommunityConfig, 
                                                                                          mapcommunityConfig);
        lstUserConfig = Database.query(sCommunityConfigQuery);
        return lstUserConfig;
    }
    /**
    * method name: getLoggedInUserContactRole
    * @Description : get Logged In User ContactRole
    * */
    public static String getLoggedInUserContactRole(){
        Id userId = UserInfo.getuserId();
        String sFieldsToQueryOnUser = 'Id, ContactId, contact.PermissionsLevel__c';
        String sWhereClauseOnUser = 'Id =: userId';
        
        Map<String,String> mapUserQueryParameters = new Map<String,String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        String sUserQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User', sFieldsToQueryOnUser, mapUserQueryParameters);
        User objUser = Database.query(sUserQuery);
        return objUser.contact.PermissionsLevel__c;
    }

    /***************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         05/27/2019
    * @methodname   getAccountOwnerId()
    * @description  This methods is used to get the logged in User's Acccount owner Id
    * @param        Id    (ID)   : accounId of the contact
    * @return       Id    (ID)   : logged in User Accout Id
    *****************************************************************************************************/
    public static Id getAccountOwnerId(Id accountId){
        Id accOwnerId = null;
        String sFieldsToQueryOnAccount = 'Id, ownerId';
        String sWhereClauseOnAccount = 'Id =: accountId';
        String sAccountQuery;
        Map<String,String> mapAccountQueryParameters = new Map<String,String>();
        mapAccountQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAccount);
        mapAccountQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        try{
            Map<Boolean, String> mapAccountQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Account', sFieldsToQueryOnAccount, mapAccountQueryParameters);
            if(mapAccountQueryResponse.get(true) != null){
                sAccountQuery =  mapAccountQueryResponse.get(true);
                Account objAccount = Database.query(sAccountQuery); // try catch log
                if(objAccount != null){
                    accOwnerId = objAccount.ownerId;
                }
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility', 'getAccountOwnerId', '***FLS Violation***', true);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility', 'getAccountOwnerId', e.getMessage(), true);
        }
        return accOwnerId;
    }
    /***************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   getRecordOwner()
    * @description  This methods is used to get the owner Id
    * @return       String                  :  record owner Id
    *****************************************************************************************************/
   /* public static String getRecordOwner(String sObjectName, String sRecordId){
        String sRecordOwnerId;
        String sFieldsToQueryOnReferral = RE_DataBaseQueryFields.sFieldsToQueryOnReferral;
        String sWhereClauseOnReferral = RE_DataBaseQueryFields.sWhereClauseOnReferralRecord;
        Map<String,String> mapReferralQueryParameters = new Map<String,String>();
        mapReferralQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReferral);
        mapReferralQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        Map<Boolean,String> mapReferralQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Referral__c', sFieldsToQueryOnReferral, mapReferralQueryParameters);
        String switchReferralKey = (mapReferralQueryResponse.get(true) != null) ? 'success' : 'failure';    
        switch on (switchReferralKey) {
            when 'success' {
                Referral__c lstRecords = (Referral__c) Database.query(mapReferralQueryResponse.get(true));
                Id contactId = lstRecords.Contacts__c;
                sRecordOwnerId = getUserIdBasedOnContactId(contactId);
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getRecordOwner','Some Fields doesn\'t have the required access :: '+mapReferralQueryResponse.get(false), true);
            }
        }
        return sRecordOwnerId;
    }
     /***************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         07/02/2019
    * @methodname   getUserIdBasedOnContactId()
    * @description  This methods is used to get the user id based on given contact Id
    * @return       Id                  :  User Id
    *****************************************************************************************************/
    /*public static Id getUserIdBasedOnContactId(Id sContactId){
        String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sIdNameField;
        String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnIdContactId;
        Map<String,String> mapUserQueryParameters = new Map<String,String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User', sFieldsToQueryOnUser, mapUserQueryParameters);
        User objUser = (User) Database.query(sQuery); 
        return objUser.Id;
    }
       /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   getFormatedDate()
    * @description  This methods is used to get the Location Operating hours in specified format AM/PM
    * @return       Map<String, String>> 
    ******************************************************************************************/
    public static String getFormatedDate(String sDate){
        Datetime dt = DateTime.valueOf(sDate);
        return dt.format('EEE')+ ', '+dt.format('h:mm a');
    }
   /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   getOperatingHours()
    * @description  This methods is used to get the Location Operating hours in specified format AM/PM
    * @return       Map<String, String>> 
    ******************************************************************************************/
    public static String getOperatingHours(Time sTime){
        Datetime myDateTime = Datetime.newInstance(Date.today(), sTime);
        return myDateTime.format('h:mm a');
    }
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   getAllOptions
    * @description  This methods is used to get all the Values for mentioned field present in the system
    * @return       List<String> of Values
    **********************************************************************************************/    
    
    @AuraEnabled
    /*Commented by LK
    public static List<String> getAllOptions(String sObjectName, String sFieldAPIName){
    return GeneralUtility.getPicklistValues(sObjectName,sFieldAPIName);
    */
    //Added by LK
   /* public static RE_CreateLightningServerResponse getAllOptions(String sObjectName, String sFieldAPIName){ 
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        try {
            List<String> lstPicklistVals = GeneralUtility.getPicklistValues(sObjectName,sFieldAPIName);
            bSuccess = true;
            mapResponse.put('PicklistVals', lstPicklistVals);
        }catch (Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getAllOptions', e.getMessage(),true);
        } 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }//
    
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   formatphonenumber()
    * @description  This methods is used to get the formated phone numberfrom string
    * @return       String 
    ******************************************************************************************/
    public static String formatphonenumber(String sPhone) {

        String sFormatedPhone = sPhone.replaceAll('\\D','');
        if (sFormatedPhone.length() == 10) {
            sFormatedPhone = formatphonenum(sFormatedPhone);
            return sFormatedPhone;
        }else {
            return sPhone;
        }
    }
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   formatphonenum()
    * @description  This methods is used to get the formated phone numberfrom string
    * @return       String 
    ******************************************************************************************/
    private static String formatphonenum (String sPhone) {
        sPhone = '(' + sPhone.substring(0, 3) + ') ' + sPhone.substring(3, 6) + '-' + sPhone.substring(6);
        return sPhone;
    }
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         07/04/2019
    * @methodname   getLatLong()
    * @description  This methods is used to get the lat long information based on zip code
    * @return       String 
    ******************************************************************************************/
    public static String getLatLong(String sZip){
        String sLatLong;
        if(String.isNotBlank(sZip)){
            sZip=sZip.replaceAll('\\s+','+');
            sZip=sZip.replaceAll(',','');
            Http http = new Http(); 
            HttpRequest request = new HttpRequest();
            string strKey =Google_Map_API__c.getOrgDefaults().Key_Value__c;
            request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+String.escapeSingleQuotes(sZip)+',&key='+strKey);
            request.setMethod('GET');
            HttpResponse response;
            if(!Test.isRunningTest()){
                response = http.send(request);
            }else{
                response=RE_GoogleMapAPIMockResponse.respond(request);
            }

            RE_GoogleMapGeoLocationResponseWrapper wrapper = (RE_GoogleMapGeoLocationResponseWrapper) JSON.deserialize(response.getBody(), RE_GoogleMapGeoLocationResponseWrapper.class);        
            RE_GoogleMapGeoLocationResponseWrapper.Northeast loc;
            if(wrapper.status == 'OK' && wrapper.status != 'ZERO_RESULTS'){
                for(RE_GoogleMapGeoLocationResponseWrapper.Results r: wrapper.results){
                    loc = new RE_GoogleMapGeoLocationResponseWrapper.Northeast();
                    loc.lat = r.geometry.location.lat;
                    loc.lng = r.geometry.location.lng;
                }
                sLatLong = loc.lat+'##'+loc.lng;
            }
        }
        return sLatLong;
    }
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         07/04/2019
    * @methodname   getUserPermissionSet()
    * @description  This methods is used to get logged in user Permission set name
    * @return       String 
    ******************************************************************************************/
    /*public static List<PermissionSetAssignment> geLoggedInUserPermissionSets(){
        List<PermissionSetAssignment> lstPermissionSet =  new List<PermissionSetAssignment>();
        try{
            ID userid=UserInfo.getUserId();
            String sFieldsToQueryOnperm = RE_DataBaseQueryFields.sFieldsToQueryOnperm;
            String sWhereClauseOnperm = RE_DataBaseQueryFields.sWhereClauseOnperm;
            
            Map<String,String> mappermQueryParameters = new Map<String,String>();
            mappermQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnperm);
            mappermQueryParameters.put(RE_GlobalConstants.sLimitKey,Label.maxsoqlquerylimit);
            String sPermissionSetQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sPermissionSetObj, sFieldsToQueryOnperm, mappermQueryParameters); 
            lstPermissionSet = Database.query(sPermissionSetQuery);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getPermissionSetName','Unable to fetch Permission sets for the current user', true);
        }
        return lstPermissionSet;
    }

    /**************************************************************************************
    * @author       Payal Dubela
    * @date         07/09/2019
    * @methodname   getFieldsFromFieldSet()
    * @description  This methods is used to get fields from Fieldset
    * @return       String 
    ******************************************************************************************/
     public static String getFieldsFromFieldSet(String objectName,String fieldSetName){
         String fieldsToQuery='';
         Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
         Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(ObjectName);
         Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
         Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            for(Schema.FieldSetMember f : fieldSetObj.getFields()) {
                fieldsToQuery += f.getFieldPath() + ', ';
            }
        fieldsToQuery=fieldsToQuery.removeEnd(', ');

      return fieldsToQuery;
     }
    
    /**************************************************************************************
    * @author       Nupoor Nimbalkar
    * @date         07/10/2019
    * @methodname   getUserLocale()
    * @description  This methods is used to get logged in user locale
    * @return       String 
    ******************************************************************************************/
    public static String getUserLocale(){
        return UserInfo.getLocale();
    }
    
    
    public String fetchRecordTypeOfRecord(Id objId){
        return null;
    }
    
    /*public static RE_CreateLightningServerResponse getLoggedInUserRole(){
        Boolean bSuccess = false;
        Boolean bIsCPUserProfile = false;
        Boolean bIsResident = false;
        Boolean bIsResidentorGuest = false;
        Boolean bIsGuestUser = false;
        
        
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try{
                    String sRole = GeneralUtility.getLoggedInUserContactRole();
                    Profile sProfile = GeneralUtility.getLoggedInUserProfile();
                    if(sProfile.Name == RE_GlobalConstants.strCommunityProfileName ){
                        bIsCPUserProfile = true;
                    }
                    ID userid=UserInfo.getUserId();
                    
                    String sFieldsToQueryOnperm = RE_DataBaseQueryFields.sFieldsToQueryOnperm;
                    String sWhereClauseOnperm = RE_DataBaseQueryFields.sWhereClauseOnperm;
                    String sPermissionSetQuery;
                    
                    Map<String,String> mappermQueryParameters = new Map<String,String>();
                    mappermQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnperm);
                    mappermQueryParameters.put(RE_GlobalConstants.sLimitKey,Label.maxsoqlquerylimit);
                    sPermissionSetQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sPermissionSetObj, sFieldsToQueryOnperm, mappermQueryParameters); 
                    
                    List<PermissionSetAssignment> lstPermissionSet = Database.query(sPermissionSetQuery);
                    for(PermissionSetAssignment pmset : lstPermissionSet){
                        
                        if(pmset.PermissionSet.Name==RE_GlobalConstants.RESIDENT_PERMISSIONSET_NAME){
                            bIsResidentorGuest=true;
                        }
                        if(sProfile.Name == RE_GlobalConstants.strGuestProfileName){
                            bIsGuestUser=true;
                        }
                        
                    }
                    mapResponse.put('bIsGuestUser', bIsGuestUser);
                    mapResponse.put('bIsResidentorGuest', bIsResidentorGuest);
                    bSuccess =  true;
                }catch(Exception e){
                    errorMap.put('error',e.getMessage());
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RDResidentViewCtrl', 'getLoggedInUserRole', e.getMessage(), true);
                }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    public static String fetchPicklistLabel(String objectName, String fieldName, String picklistValue){
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();        
        String label = '';
        try{
            for(Schema.PicklistEntry a: fieldMap.get(fieldName).getDescribe().getPickListValues()){                                    
                if(a.getValue() == picklistValue)
                    label = String.valueOf(a.getLabel());
            } 
            
        }
        catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'fetchFieldsPicklistValueAPIName', 'Exception Handled' , true);                                  
        }   
        return label;
    }
    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         07/30/2019
    * @methodname   getOptOutInfoSharingDetails()
    * @description  This methods is used to get OptOutInfoSharing Information from Account
    * @return       Boolean
    **********************************************************************************************/
    /*@AuraEnabled
    public static Boolean getOptOutInfoSharingDetails(){
        Boolean bSuccess = false;
        Boolean bReturnVal = true;
        String sSwitchCaseKey;
        String sQuery;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String recordId = getLoggedInUserAccountId();
        String sFieldsToQueryOnAccount = RE_DataBaseQueryFields.sFieldsToQueryOnAccountForOptOut;
        String sWhereClauseOnAccount  = RE_DataBaseQueryFields.sWhereClauseIdInRecordId;
        try{
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAccount);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Account', sFieldsToQueryOnAccount, mapQueryParameters);
        
            sSwitchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (sSwitchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    List<Account> lstAccounts = Database.query(sQuery);
                    if(lstAccounts.size() > 0)
                        bReturnVal =  lstAccounts[0].HasOptedOutOfAccount__c;
                    else
                        bReturnVal = true; 
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getOptOutInfoSharingDetails','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }      
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getOptOutInfoSharingDetails', e.getMessage() , true);
            bReturnVal = true;                                
        }
        return bReturnVal;
    }
   /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/22/2019
    * @methodname   getFavorites()
    * @description  This methods is used to get favorites for the CP User
    * @return        Map<String, Favorite__c>
    **********************************************************************************************/
    /*public static Map<String, Favorite__c> getFavorites(Set<Id> setResourceIds, Set<Id> setLocationIds){
        String sQuery;
        List<Favorite__c> lstFavorites = new List<Favorite__c>();
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        String loggedinUser = getLoggedInUserContactId();
        String sFieldsToQueryOnFavorite = RE_DataBaseQueryFields.sFieldsToQueryOnFavorite;
        String sWhereClauseOnFavorite = RE_DataBaseQueryFields.sWhereClauseOnOnFavorite;
        Map<String, Favorite__c> mapResourceLocationFavorite = new Map<String, Favorite__c>();
        try{
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnFavorite);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Favorite__c', sFieldsToQueryOnFavorite, mapQueryParameters);
            Id sFavRecordTypeId = Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Resource Favorite').getRecordTypeId();
            String sSwitchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (sSwitchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    lstFavorites = Database.query(sQuery);
                    for(Favorite__c fav:lstFavorites){
                            mapResourceLocationFavorite.put(fav.LocationResource__c, fav);
                    }
                }
            }
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getFavorites', e.getMessage() , true);
        } 
        
        return mapResourceLocationFavorite;
    }*/
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         09/05/2019
    * @methodname   getQueue()
    * @description  This method is used to get Queue with the specified name 
    * @return       Group
    **********************************************************************************************/
    public static Group getQueue(String sQueuename)
    {   
        Group Queue = new Group();
        if(Schema.sObjectType.Group.fields.Id.isAccessible() && Schema.sObjectType.Group.fields.Name.isAccessible()
          && Schema.sObjectType.Group.fields.Type.isAccessible() && Schema.sObjectType.Group.fields.DeveloperNAME.isAccessible()){
              Queue = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND DeveloperNAME =: sQueuename];
          }
            return Queue;
        
    }
    /********************************************************************************************
    * @author       Megha Mittal
    * @date         11/04/2019
    * @methodname   addNewUserToOrg()
    * @params       Id,String,String,String,String,String
    * @description  This methods is used to send email notification when user is created in the system
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/    
    /*public static RE_CreateLightningServerResponse addNewUserToOrg(List<AddUserWrapper> adduserWrapperList){        
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Id, Contact> mapContact;
        List<Id> contactIds=new List<Id>();            
        try{
                        
            List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
            Database.SaveResult[] srCommunicationNubList;                    
            RE_CreateLightningServerResponse cplocresponse=RE_CreateReferralCtrl.fetchloggedInUserInfo();
            String switchUserKey1 = (cplocresponse.isSuccessful==true) ? 'success' : 'failure';                              
            switch on (switchUserKey1) {
                when 'success' {                  
                    String switchUserKey = (EmailSetting__c.getInstance('New User to Organization').Is_on__c && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c) ? 'success' : 'failure';                
                    switch on (switchUserKey) {
                        when 'success' {            
                            
                            for(AddUserWrapper addwrapper:adduserWrapperList){
                                CommunicationLog__c objCommunicationNub = new CommunicationLog__c();  
                                if(addwrapper.emailChange==true){
                                    objCommunicationNub.EmailSubject__c = Label.RE_Add_New_User_Subject_Email_Change; 
                                    String sTemplateBody = Label.RE_Add_New_User_Body_Email_Change;
                                    sTemplateBody += Label.RE_doNotReplyMessage;
                                    sTemplateBody += '<br>'+Label.RE_SecurityMessage;
                                    objCommunicationNub.TemplateBody__c = sTemplateBody;
                                }
                                else{
                                    objCommunicationNub.EmailSubject__c = Label.RE_Add_New_User_Subject;
                                    String sTemplateBody = String.format(Label.RE_Add_New_User_Body, new List<String>{addwrapper.FirstName,addwrapper.LastName,UserInfo.getFirstName(),UserInfo.getLastName(),addwrapper.accountName,Label.System_Name,addwrapper.regLink,addwrapper.logLink,Label.StateHelpdesk});  
                                    sTemplateBody += Label.RE_doNotReplyMessage;
                                    sTemplateBody += '<br>'+Label.RE_SecurityMessage;
                                    objCommunicationNub.TemplateBody__c = sTemplateBody;
                                  }
                                objCommunicationNub.ToEmail__c = addwrapper.toEmail;
                                objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                                 //Added By Kojashree
                                 objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                          
                                lstCommunicationNubInsert.add(objCommunicationNub);             
                            }
                        }  
                    }
                }            
                when 'failure' {  
                    if(EmailSetting__c.getInstance('Claim Site Approval mail').Is_on__c ){
                        for(AddUserWrapper addwrapper:adduserWrapperList){
                            if(addwrapper.IsClaim==true){
                                CommunicationLog__c objCommunicationNub = new CommunicationLog__c();                                                                                    
                                objCommunicationNub.EmailSubject__c = String.format(Label.RE_ClaimApprovedSub, new List<String>{ Label.System_Name });
                                String strEmailTemplateBody = String.format(Label.RE_ClaimApprovedBody, new List<String>{ addwrapper.FirstName,addwrapper.LastName,addwrapper.accountName,Label.System_Name,Label.StateHelpdesk,addwrapper.regLink,addwrapper.logLink });
                                strEmailTemplateBody += Label.RE_doNotReplyMessage;
                                strEmailTemplateBody += '<br>'+Label.RE_SecurityMessage;
                                objCommunicationNub.TemplateBody__c = strEmailTemplateBody;
                                objCommunicationNub.ToEmail__c = addwrapper.toEmail;
                                objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;  
                                 //Added By Kojashree
                                objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                            
                                lstCommunicationNubInsert.add(objCommunicationNub);             
                            }                        
                        }
                    }                
                }       
            }    
            if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){  
                srCommunicationNubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                bSuccess = true;
            }
            else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,GeneralUtility.class.getName(), 'addNewUserToOrg','No Access on CommunicationLog__c Object',true);
            }       
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, GeneralUtility.class.getName(), 'addNewUserToOrg', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
   /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         1/06/2020
    * @methodname   checkDuplicateUser()
    * @params       String
    * @description  This methods is used to check duplicate contact/user in the system
    * @return       Map<String, Integer>
    **********************************************************************************************/   
  /*public static Map<String, Integer> checkDuplicateUser(List<String> lstEmails){
        Map<String, Integer> mapContactDuplicateEmail = new Map<String, Integer>();
        Map<String,String> mapInputs= new Map<String,String>();
        // RE Security Changes -- Payal Dubela --- Start
        ID nonCitizenRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RE_GlobalConstants.strNonCitizenContactDevName).getRecordTypeId();
        String cpAdminRole=RE_GlobalConstants.sStartStringPercent+RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN+RE_GlobalConstants.sEndStringPercent;
        String cpStaffRole=RE_GlobalConstants.sStartStringPercent+RE_GlobalConstants.COMMUNITY_PARTNER_STAFF+RE_GlobalConstants.sEndStringPercent;
        if(Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()){
         String squery=RE_DataBaseQueryFields.sQueryDuplicateUser+cpAdminRole +RE_DataBaseQueryFields.sQueryDuplicateUser1+ cpStaffRole+RE_DataBaseQueryFields.sQueryDuplicateUser2;
         mapInputs.put('nonCitizenRectypeId',nonCitizenRectypeId);
         mapInputs.put('cpAdminRole',cpAdminRole);
         mapInputs.put('cpStaffRole',cpStaffRole);
            for(AggregateResult  objCon :RE_SharingByPassCtrl.getDuplicateUser(squery,mapInputs,lstEmails)){
                    mapContactDuplicateEmail.put(String.valueOf(objCon.get('Email')), Integer.valueOf(objCon.get('numcount'))); // found duplicate
                }
            }
        // RE Security Changes -- Payal Dubela --- END
        return mapContactDuplicateEmail;
    }
    /********************************************************************************************
    * @author       Megha Mittal
    * @date         11/06/2019        
    * @description  This is a wrapper class for email around adding new users    
    **********************************************************************************************/
    //Wrapper for Email
    public class AddUserWrapper {        
        public Id contactId;
        public String contactName;
        public String FirstName;
        public String LastName;
        public String systemName;
        public String accountName;
        public String regLink;
        public String logLink; //Siri: added to get KOG login url
        public String contactNumber;
        public Boolean IsClaim;
        public String toEmail;   
        public Boolean emailChange;
    }

    /********************************************************************************************
    * @author       Nandita Bapaye
    * @date         29/01/2020      
    * @description   Function to return operation timings for single location Resource
    **********************************************************************************************/
   
    /*public static Map<String, List<String>> getLocationOperationHours(Location__c sObjLoc,LocationResource__c sObjLocRes)
    {
        Map<String, List<String>> mapdata = new Map<String, List<String>>();
        try{
           List<String> sDaysClosedLocRes = new List<String>();
            List<String> sDaysClosedLoc = new List<String>();
            Map<String, String> ObjLocResMapdata = new Map<String, String>();
            Map<String, String> ObjLocMapdata = new Map<String, String>();
           
            List<String> sDaysofWeek = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'};
            for(String sDay: sDaysofWeek){
                String OpenTime;
                String CloseTime;
                String sOperationTimeLocRes;
                String sOperationTimeLoc;
                   if(sDay == 'Monday'){
                    OpenTime = sObjLocRes.MondayOpen__c != null?GeneralUtility.getOperatingHours(sObjLocRes.MondayOpen__c):'';
                    CloseTime = sObjLocRes.MondayClose__c != null?GeneralUtility.getOperatingHours(sObjLocRes.MondayClose__c):'';
                       sOperationTimeLocRes = OpenTime+','+CloseTime;
                    
                    OpenTime = sObjLoc.MondayOpen__c != null?GeneralUtility.getOperatingHours(sObjLoc.MondayOpen__c):'';
                    CloseTime = sObjLoc.MondayClose__c != null?GeneralUtility.getOperatingHours(sObjLoc.MondayClose__c):'';
                   sOperationTimeLoc=OpenTime+','+CloseTime;
                     
                }
                if(sDay == 'Tuesday'){
                     OpenTime = sObjLocRes.TuesdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLocRes.TuesdayOpen__c):'';
                    CloseTime = sObjLocRes.TuesdayClose__c != null?GeneralUtility.getOperatingHours(sObjLocRes.TuesdayClose__c):'';
                       sOperationTimeLocRes = OpenTime+','+CloseTime;
                    
                    OpenTime = sObjLoc.TuesdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLoc.TuesdayOpen__c):'';
                    CloseTime = sObjLoc.TuesdayClose__c != null?GeneralUtility.getOperatingHours(sObjLoc.TuesdayClose__c):'';
                   sOperationTimeLoc=OpenTime+','+CloseTime;
                }
                if(sDay == 'Wednesday'){
                     OpenTime = sObjLocRes.WednesdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLocRes.WednesdayOpen__c):'';
                    CloseTime = sObjLocRes.WednesdayClose__c != null?GeneralUtility.getOperatingHours(sObjLocRes.WednesdayClose__c):'';
                       sOperationTimeLocRes = OpenTime+','+CloseTime;
                    
                    OpenTime = sObjLoc.WednesdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLoc.WednesdayOpen__c):'';
                    CloseTime = sObjLoc.WednesdayClose__c != null?GeneralUtility.getOperatingHours(sObjLoc.WednesdayClose__c):'';
                   sOperationTimeLoc=OpenTime+','+CloseTime;
                }
                if(sDay == 'Thursday'){
                     OpenTime = sObjLocRes.ThursdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLocRes.ThursdayOpen__c):'';
                    CloseTime = sObjLocRes.ThursdayClose__c != null?GeneralUtility.getOperatingHours(sObjLocRes.ThursdayClose__c):'';
                       sOperationTimeLocRes = OpenTime+','+CloseTime;
                    
                    OpenTime = sObjLoc.ThursdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLoc.ThursdayOpen__c):'';
                    CloseTime = sObjLoc.ThursdayClose__c != null?GeneralUtility.getOperatingHours(sObjLoc.ThursdayClose__c):'';
                   sOperationTimeLoc=OpenTime+','+CloseTime;
                }
                if(sDay == 'Friday'){
                     OpenTime = sObjLocRes.FridayOpen__c != null?GeneralUtility.getOperatingHours(sObjLocRes.FridayOpen__c):'';
                    CloseTime = sObjLocRes.FridayClose__c != null?GeneralUtility.getOperatingHours(sObjLocRes.FridayClose__c):'';
                       sOperationTimeLocRes = OpenTime+','+CloseTime;
                    
                    OpenTime = sObjLoc.FridayOpen__c != null?GeneralUtility.getOperatingHours(sObjLoc.FridayOpen__c):'';
                    CloseTime = sObjLoc.FridayClose__c != null?GeneralUtility.getOperatingHours(sObjLoc.FridayClose__c):'';
                   sOperationTimeLoc=OpenTime+','+CloseTime;
                }
                 if(sDay == 'Saturday'){
                     OpenTime = sObjLocRes.SaturdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLocRes.SaturdayOpen__c):'';
                    CloseTime = sObjLocRes.SaturdayClose__c != null?GeneralUtility.getOperatingHours(sObjLocRes.SaturdayClose__c):'';
                       sOperationTimeLocRes = OpenTime+','+CloseTime;
                    
                    OpenTime = sObjLoc.SaturdayOpen__c != null?GeneralUtility.getOperatingHours(sObjLoc.SaturdayOpen__c):'';
                    CloseTime = sObjLoc.SaturdayClose__c != null?GeneralUtility.getOperatingHours(sObjLoc.SaturdayClose__c):'';
                   sOperationTimeLoc=OpenTime+','+CloseTime;
                }
                 if(sDay == 'Sunday'){
                     OpenTime = sObjLocRes.SundayOpen__c != null?GeneralUtility.getOperatingHours(sObjLocRes.SundayOpen__c):'';
                    CloseTime = sObjLocRes.SundayClose__c != null?GeneralUtility.getOperatingHours(sObjLocRes.SundayClose__c):'';
                       sOperationTimeLocRes = OpenTime+','+CloseTime;
                    
                    OpenTime = sObjLoc.SundayOpen__c != null?GeneralUtility.getOperatingHours(sObjLoc.SundayOpen__c):'';
                    CloseTime = sObjLoc.SundayClose__c != null?GeneralUtility.getOperatingHours(sObjLoc.SundayClose__c):'';
                   sOperationTimeLoc=OpenTime+','+CloseTime;
                }
                ObjLocResMapdata.put(sDay,sOperationTimeLocRes);  
                ObjLocMapdata.put(sDay,sOperationTimeLoc); 
            }
           if(sObjLocRes.DaysClosed__c != null){
                sDaysClosedLocRes = sObjLocRes.DaysClosed__c.split(';');
           }
           if(sObjLoc.DaysLocationClosed__c != null){
                 sDaysClosedLoc = sObjLoc.DaysLocationClosed__c.split(';');
           }

            if(ObjLocResMapdata != null || ObjLocMapdata != null || !sDaysClosedLocRes.isEmpty() || !sDaysClosedLoc.isEmpty()){
                    for(String sDay: sDaysofWeek){
                        mapdata.put(sDay, new List<String>());
                        List<String> OpenCloseTime = new List<String>();
                        List<String> OpenCloseTimeLoc = new List<String>();
                        String Closetime = '';
                        String Opentime = '';
                        String ClosedFlag = 'false';
                        String Notes = '';
                        String isLocationResource = 'false';
                        if(!sDaysClosedLocRes.isEmpty() && sDaysClosedLocRes.contains(sDay)){
                            ClosedFlag = 'true';
                            isLocationResource = 'true';
                        }
                        else{
                        //RE_Release 1.4 – Iron Dome Changes(07/21) - Payal Dubela
                        if(ObjLocResMapdata !=null && ObjLocResMapdata.get(sDay) !=null)
                            OpenCloseTime = ObjLocResMapdata.get(sDay).split(',');
                        if(!OpenCloseTime.isEmpty() && ((OpenCloseTime.size()>0 && OpenCloseTime[0] != null) || (OpenCloseTime.size()>1 && OpenCloseTime[1] != null)) ){
                                Opentime = OpenCloseTime.size()>0?OpenCloseTime[0]:'';
                                CloseTime = OpenCloseTime.size()>1?OpenCloseTime[1]:'';
                                isLocationResource = 'true';
                            }
                            else{
                                if(!sDaysClosedLoc.isEmpty() && sDaysClosedLoc.contains(sDay)){
                                    ClosedFlag = 'true';
                                }
                                else{
                                if(ObjLocMapdata!=null && ObjLocMapdata.get(sDay) !=null)
                                        OpenCloseTimeLoc = ObjLocMapdata.get(sDay).Split(',');
                                if(!OpenCloseTimeLoc.isEmpty() && ((OpenCloseTimeLoc.size()>0 && OpenCloseTimeLoc[0] != null) || (OpenCloseTimeLoc.size()>1 && OpenCloseTimeLoc[1] != null))){
                                        Opentime = OpenCloseTimeLoc.size()>0?OpenCloseTimeLoc[0]:'';
                                        CloseTime = OpenCloseTimeLoc.size()>1?OpenCloseTimeLoc[1]:'';
                                    }
                                }
                            }
                        }
                    mapdata.get(sDay).add(Opentime);
                    mapdata.get(sDay).add(CloseTime);
                    mapdata.get(sDay).add(ClosedFlag);
                    mapdata.get(sDay).add(isLocationResource);
                }
        }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLocationOperationHours',e.getStackTraceString(), true);
        }
        return mapdata;
    }
     /********************************************************************************************
    * @author       Nandita Bapaye
    * @date         31/01/2020      
    * @description  Function to return operation timings for List of LocationResource
    **********************************************************************************************/
   /*public static Map<Id,map<String, List<String>>> getLocationOperationHoursList(Set<Id> sLocationIds,List<LocationResource__c> sLocationResourceList){
        map <Id,map<String,List<String>>> finalResponseMap = new map <Id,map<String,List<String>>>();
       
        try{
            List<Location__c> sLocationList = RE_SharingByPassCtrl.getLocationOperatingHours(sLocationIds);
           
            map<Id, LocationResource__c> sLocResDataMap = new map<Id, LocationResource__c>();
            map<Id,Location__c> sLocDataMap = new map<Id, Location__c>();

            for (LocationResource__c sObjLocRes : sLocationResourceList){
                sLocResDataMap.put(sObjLocRes.Id,sObjLocRes);
            }
            for (Location__c sObjLoc : sLocationList){
                sLocDataMap.put(sObjLoc.Id,sObjLoc);
            }
            for(Id locResId : sLocResDataMap.keySet()){
                LocationResource__c sObjLocRes = new LocationResource__c();
                sObjLocRes = sLocResDataMap.get(locResId);
                Location__c sObjLoc = new Location__c();
                map<String,list<string>> sLocResHoursMap;
                if(sLocDataMap.containsKey(sObjLocRes.Location__c)){
                    sObjLoc = sLocDataMap.get(sObjLocRes.Location__c);
                }
                sLocResHoursMap = getLocationOperationHours(sObjLoc,sObjLocRes);
                finalResponseMap.put(sObjLocRes.Id,sLocResHoursMap);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLocationOperationHoursList',e.getStackTraceString(), true);
        }
        return finalResponseMap;
    } 
    /********************************************************************************************
    * @author       Nandita Bapaye
    * @date         03/26/2020
    * @methodname   getFavoriteClientIds()
    * @description  This methods is used to get favorites for the CP User
    * @return        Set<Id>
    **********************************************************************************************/
    /*public static Set<Id> getFavoriteClientIds(){
        String sQuery;
        List<Favorite__c> lstFavorites = new List<Favorite__c>();
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String loggedinUser = getLoggedInUserContactId();
        String sFieldsToQueryOnFavoriteClient = RE_DataBaseQueryFields.sFieldsToQueryOnFavoriteClient;
        String sWhereClauseOnFavoriteClient = RE_DataBaseQueryFields.sWhereClauseOnFavoriteClient;
        Set<Id> sFavclientIdSet = new Set<Id>();
        try{
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnFavoriteClient);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Favorite__c', sFieldsToQueryOnFavoriteClient, mapQueryParameters);
            Id sFavRecordTypeId = Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Client Favorite').getRecordTypeId();
            String sSwitchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (sSwitchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    lstFavorites = RE_SharingByPassCtrl.getFavoriteResources(sQuery,null,loggedinUser,sFavRecordTypeId);
                    for(Favorite__c fav:lstFavorites){
                            sFavclientIdSet.add(fav.Client__c);
                    }
                }
            }
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getFavoriteClientIds', e.getMessage() , true);
        } 
        
        return sFavclientIdSet;
    }

    /********************************************************************************************
    * @author       Payal Dubela
    * @date         04/02/2020
    * @methodname   checkConsentForClient()
    * @description  This method is used to check Partner has consent to see Client Data
    * @return        List<Consent>
    **********************************************************************************************/
    /*public static List<Consent__c> checkConsentForClient(String clientId){
        List<Consent__c> consentList=new List<Consent__c>();
		// Added By Kojashree -- SSP Merge
        //  String loggedInUserAccountId=GeneralUtility.getLoggedInUserAccountId();
        String loggedInUserAccountId=GeneralUtility.getLoggedInAccountId();
        String loggedInUserContactId=GeneralUtility.getLoggedInUserContactId();
        String sQuery;
        String sWhereClause;
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String consentStatus=RE_GlobalConstants.CONSENT_STATUS_ACTIVE;
        String sOrganization=RE_GlobalConstants.ORGANIZATION;
        String sAssister=RE_GlobalConstants.ASSISTER;
        try {
           // Profile sProfile = GeneralUtility.getLoggedInUserProfile();
            // Added By Kojashree -- SSP Merge
            String sRole = GeneralUtility.getLoggedInUserSelectedRole();
            //if(sProfile.Name == RE_GlobalConstants.RE_ASSISTER_PROFILE)
            if(sRole == RE_GlobalConstants.ASSISTER){
                sWhereClause=RE_DataBaseQueryFields.sWhereClauseOnClientConsentForAssister; 
            }else{
                sWhereClause=RE_DataBaseQueryFields.sWhereClauseOnClientConsent;
            }
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldConsentFieldsStatus;
            String sOrderBy = RE_DataBaseQueryFields.sCreatedDateDESC;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderBy);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.consentobjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    consentList = Database.query(sQuery);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','CheckConsentForClient','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
        }catch (Exception e) {
                             LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility', 'CheckConsentForClient', e.getMessage()+' ' +e.getLineNumber(), true);}
        return consentList;
    }
    /*****************************************************************************************************
* @author        Venkat Korra
* @date          04/30/2020
* @methodname    EncryptionProcess()
* @description   This method is used for encryption using key, IV and text that needs to be encrypted.
* @return        String
*******************************************************************************************************/
    public static String EncryptionProcess(String key, String initVector, String plainText)
    {
        String encryptedDataString;
        try {
            if(String.isNotBlank(key) && String.isNotBlank(initVector) && String.isNotBlank(plainText))
            {
                Blob cryptoKey = Blob.valueOf(key);
                Blob data = Blob.valueOf(plainText);
                Blob IV = Blob.valueOf(initVector);
                Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, IV, data);
                encryptedDataString = EncodingUtil.base64Encode(encryptedData);
                
            }
        }catch (Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility', 'EncryptionProcess', e.getMessage()+' ' +e.getLineNumber(), true);
        }
        return encryptedDataString;
    }
    
    /*****************************************************************************************************
* @author        Venkat Korra
* @date          04/30/2020
* @methodname    DecryptionProcess()
* @description   This method is used for decryption using key, IV and text that needs to be decrypted.
* @return        String
*******************************************************************************************************/
    public static String DecryptionProcess(String key, String initVector, String cipherText)
    {
        String decryptedDataString;
        try {
            if(String.isNotBlank(key) && String.isNotBlank(initVector) && String.isNotBlank(cipherText))
            {
                String decodeText = EncodingUtil.urlDecode(cipherText, 'ASCII');
                Blob data = EncodingUtil.base64Decode(decodeText);
                Blob cryptoKey = Blob.valueOf(key);
                Blob IV = Blob.valueOf(initVector);
                Blob decryptedData = Crypto.decrypt('AES256', cryptoKey, IV, data);
                decryptedDataString = decryptedData.toString();
            }
        }catch (Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility', 'DecryptionProcess', e.getMessage()+' ' +e.getLineNumber(), true);
        }
        return decryptedDataString;
    }
    /*****************************************************************************************************
    * @author        Payal Dubela
    * @date          07/27/2020
    * @methodname    createDummyAccount()
    * @description   This method is used for creating dummy accounts for partners
    * @return        Account
    *******************************************************************************************************/
    public static Account createDummyAccount(String firstName,String lastName,String applicableRole){
        //RecordType objAccountRecordType = GeneralUtility.fetchRecordType('Citizen', 'Account');
        Id accountRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen');

        List<User> userList = RE_SharingByPassCtrl.getUserList(RE_GlobalConstants.strSystemAutoProcessProfile);
        Account acc = new Account();
        acc.Name = firstName+' '+lastName;
        acc.RecordTypeId = accountRecordTypeId;
        acc.Applicable_Roles__c=applicableRole;
        if(userList!=null && !userList.isEmpty()){
           acc.ownerId=userList[0].Id;
        }
        if (Schema.sObjectType.Account.isCreateable()) {
            insert acc;
        }
        return acc;
    }
    /*****************************************************************************************************
    * @author        Payal Dubela
    * @date          07/27/2020
    * @methodname    createDummyAccount()
    * @description   This method is used for creating dummy accounts for partners
    * @return        Account
    *******************************************************************************************************/
    public static AccountContactRelation createACR(String accountId,String contactId,String role){
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = accountId;
        acr.Contactid = contactId;
        acr.Roles=role;
        if(Schema.sObjectType.AccountContactRelation.isCreateable()){
            RE_SharingByPassCtrl.insertSobject(AccountContactRelation.getSobjectType(), acr);
        }
        return acr;
    }

     /*****************************************************************************************************
    * @author        Payal Dubela
    * @date          07/27/2020
    * @methodname    getLoggedInAccountId()
    * @description   This method is used for creating dummy accounts for partners
    * @return        Account
    *******************************************************************************************************/
    /*public static String getLoggedInAccountId(){
        User u;
        String sAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Resource_Engine').getRecordTypeId();
        List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType)){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserNew;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserForLoggedIn;
            String loggedinUserId = UserInfo.getuserId();
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    u = (User) Database.query(mapUserQueryResponse.get(true));
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInAccountId','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
        String selectedRole=u.RE_Selected_Role__c;
        String returnId=''; 
        try{
            if(RE_DataAccessChecker.isAllowedToAccess(AccountContactRelation.sObjectType)){ // PMD Report Check.
                String sFieldsToQueryOnACR = RE_DataBaseQueryFields.sFieldsToQueryOnACR;
                String sWhereClauseOnACR = RE_DataBaseQueryFields.sWhereClauseForACRGetOrg;
                String contactId = u.ContactId;
                Map<String,String> mapACRQueryParameters = new Map<String,String>();
                mapACRQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnACR);
                Map<Boolean,String> mapACRQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('AccountContactRelation', sFieldsToQueryOnACR, mapACRQueryParameters);
                String switchUserKey = (mapACRQueryResponse.get(true) != null) ? 'success' : 'failure';    
                switch on (switchUserKey) {
                    when 'success' {
                        lstACR = (List<AccountContactRelation>) Database.query(mapACRQueryResponse.get(true));
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInAccountId','Some Fields doesn\'t have the required access :: '+mapACRQueryResponse.get(false), true);
                    }
                }
            }
            if(lstACR.size() > 0){
                returnId = lstACR[0].AccountId;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getLoggedInAccountId', '****No Account Found for Logged in User****' , true);
        }
        return returnId;
    }

     /*****************************************************************************************************
    * @author        Payal Dubela
    * @date          07/29/2020
    * @methodname    getLoggedInUserSelectedRole()
    * @description   This method is used for fetching selected  role for logged in user
    * @return        Account
    *******************************************************************************************************/
   /* public static String getLoggedInUserSelectedRole(){
        User u;
        String returnRole=''; 
        //Error Log Fixes - Payal Dubela - 08/29
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType) && UserInfo.getUserType()!='Guest'){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserNew;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserForLoggedIn;
            String loggedinUserId = UserInfo.getuserId();
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    u = (User) Database.query(mapUserQueryResponse.get(true));
                    returnRole=u.RE_Selected_Role__c;
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInUserSelectedRole','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
       return returnRole; 

    }
      /*****************************************************************************************************
    * @author        Payal Dubela
    * @date          07/29/2020
    * @methodname    getLoggedInUserAvailableRole()
    * @description   This method is used for fetching available role for logged in user
    * @return        Account
    *******************************************************************************************************/
    /*public static String getLoggedInUserAvailableRole(){
        User u;
        String availableRole=''; 
        //Error Log Fixes - Payal Dubela - 08/29
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType) && UserInfo.getUserType()!='Guest'){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserNew;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserForLoggedIn;
            String loggedinUserId = UserInfo.getuserId();
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    u = (User) Database.query(mapUserQueryResponse.get(true));
                    availableRole=u.ApplicableRoles__c;
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInUserAvailableRole','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
       return availableRole; 

    }
    /*****************************************************************************************************
    * @author        Venkat Korra
    * @date          08/07/2020
    * @methodname    getUserRecord()
    * @description   This method is used for fetching user record
    * @return        User
    * @param         userId
    *******************************************************************************************************/    
    /*public static User getUserRecord(Id userId){
        User u;
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType)){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserNew;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserNew;
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    u = (User) Database.query(mapUserQueryResponse.get(true));
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getUserRecord','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
        return u;
    }
    /*****************************************************************************************************
    * @author        Siri Putta
    * @date          08/10/2020
    * @methodname    getUserRolesforHeaderCmp()
    * @description   This method is used for fetching roles to display on header section
    * @return        List<String>
    * 
    *******************************************************************************************************/ 
    /*public static List<String> getUserRolesforHeaderCmp(){
        List<PublicGroupAssignments__c> publicGrpAssignment = PublicGroupAssignments__c.getAll().values();
        Set<String> rolesToCheck = new Set<String>();
        List<String> headerApplicableRoles=new List<String>();
        try{
            for(PublicGroupAssignments__c pga:publicGrpAssignment){
                rolesToCheck.add(pga.ProfileName__c);
            }
            String availableRoles = getLoggedInUserAvailableRole();
            List<String> lstApplicableRoles=String.isNotBlank(availableRoles)?availableRoles.split(';'):new List<String>();
            for(String appRole:lstApplicableRoles){
                String appRoleLabel=fetchPicklistLabel('user','ApplicableRoles__c',appRole);
                if(rolesToCheck.contains(appRole)){
                    headerApplicableRoles.add(appRoleLabel);
                } 
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getUserRolesforHeaderCmp', 'Failed to fetch roles to display on header section' , true);
        }
        return headerApplicableRoles;
    }
    
    /*****************************************************************************************************
    * @author        Siri Putta
    * @date          08/13/2020
    * @methodname    getPermssionNamesForRole()
    * @description   This method is used for fetch permissionset based on roles
    * @return        Map<String,String>
    * @param         List<String>
    *******************************************************************************************************/ 
    /*public static Map<String,String> getPermssionNamesForRole(List<String> assignedRole){
        Map<String,String> roleToPS=new Map<String,String>();
        List<String> roles= new List<String>();
        try{
            for(String role: assignedRole){
                if(role.equalsIgnoreCase('Citizen_Individual')){
                    roles.add('Citizen');
                }
                else if(role.equalsIgnoreCase('kynector')){
                     roles.add('Assister');
                }
                else{
                    roles.add(role);
                }
            }
            List<KOGRoleMapping__mdt> rolMdt=new List<KOGRoleMapping__mdt>([Select id,Role_Name__c,Related_Permission_Sets__c FROM KOGRoleMapping__mdt Where Role_Name__c in:roles ]);
            for(KOGRoleMapping__mdt kogRole:rolMdt){
                roleToPS.put(kogRole.Role_Name__c,kogRole.Related_Permission_Sets__c);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getPermssionNamesForRole', 'Failed to fetch permission sets fro the respective roles' , true);
        }
        return roleToPS;
    }
    /*****************************************************************************************************
    * @author        Siri Putta
    * @date          08/14/2020
    * @methodname    callFlowForPS()
    * @description   This method is used for invoke the flow to activate and deactivate PS
    * @param         List<String>,List<String>
    *******************************************************************************************************/ 
    public static void callFlowForPS(List<String> activatePs,List<String> deactivatePS){
        if(!Test.isRunningTest()){
            Map<String,Object> params=new Map<String,Object>();
            params.put('listActivatePermissions', activatePs);
            params.put('listDeactivatePermissions', deactivatePS);
            Flow.Interview.Permission_Set_Activation_Flow flow1=new Flow.Interview.Permission_Set_Activation_Flow(params);
            flow1.start();
        }
    }
    //This method is to get the list of PS to be activated and deactivated.
    /*public static void assignPS(List<String> availableRoles){
        List<String> activatePs=new List<String>();
        List<String> deactivatePS=new List<String>();
        Map<String,String> perm= getPermssionNamesForRole(availableRoles);
        for(String role: perm.keySet()){
            if(GeneralUtility.SelectedRole.contains(role))
                activatePs.add(perm.get(role));
            else
                deactivatePS.add(perm.get(role));        
        }
        callFlowForPS(activatePs,deactivatePS);
    }*/
     /*****************************************************************************************************
    * @author        Payal Dubela
    * @date          07/27/2020
    * @methodname    getLoggedInAccountId()
    * @description   This method is used for retriving logged in account
    * @return        Account
    *******************************************************************************************************/
    /*public static Account getLoggedInAccount(){
        User u;
        String sAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Resource_Engine').getRecordTypeId();
        List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType)){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserNew;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserForLoggedIn;
            String loggedinUserId = UserInfo.getuserId();
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    u = (User) Database.query(mapUserQueryResponse.get(true));
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInAccountId','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
        String selectedRole=u.RE_Selected_Role__c;
       Account acc= new Account();
        try{
            if(RE_DataAccessChecker.isAllowedToAccess(AccountContactRelation.sObjectType)){ // PMD Report Check.
                String sFieldsToQueryOnACR = RE_DataBaseQueryFields.sFieldsToQueryOnACR1;
                String sWhereClauseOnACR = RE_DataBaseQueryFields.sWhereClauseForACRGetOrg;
                String contactId = u.ContactId;
                Map<String,String> mapACRQueryParameters = new Map<String,String>();
                mapACRQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnACR);
                Map<Boolean,String> mapACRQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('AccountContactRelation', sFieldsToQueryOnACR, mapACRQueryParameters);
                String switchUserKey = (mapACRQueryResponse.get(true) != null) ? 'success' : 'failure';    
                switch on (switchUserKey) {
                    when 'success' {
                        lstACR = (List<AccountContactRelation>) Database.query(mapACRQueryResponse.get(true));
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInAccountId','Some Fields doesn\'t have the required access :: '+mapACRQueryResponse.get(false), true);
                    }
                }
            }
            if(lstACR.size() > 0){
                acc = lstACR[0].Account;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getLoggedInAccountId', '****No Account Found for Logged in User****' , true);
        }
        return acc;
    }
    /*****************************************************************************************************
    * @author        Venkat Korra
    * @date          08/19/2020
    * @methodname    getUserApplicableRoles()
    * @description   This method is used for fetching user record
    * @return        String
    * @param         String conId
    *******************************************************************************************************/    
   /* public static String getUserApplicableRoles(String sContactId){
        List<User> uList;
        String sApplicableRoles;
        if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType)){ // PMD Report Check.
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserNew;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUser;
            Map<String,String> mapUserQueryParameters = new Map<String,String>();
            mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            Map<Boolean,String> mapUserQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('User', sFieldsToQueryOnUser, mapUserQueryParameters);
            String switchUserKey = (mapUserQueryResponse.get(true) != null) ? 'success' : 'failure';    
            switch on (switchUserKey) {
                when 'success' {
                    uList = (List<User>) Database.query(mapUserQueryResponse.get(true));
                    sApplicableRoles = uList[0].ApplicableRoles__c;
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getUserApplicableRoles','Some Fields doesn\'t have the required access :: '+mapUserQueryResponse.get(false), true);
                }
            } 
        }
        return sApplicableRoles;
    }*/
}