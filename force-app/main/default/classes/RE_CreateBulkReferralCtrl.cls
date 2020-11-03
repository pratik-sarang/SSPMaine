/**
* Class Name    : RE_CreateBulkReferralCtrl
* Owner         : DELOITTE
* Created Date  : 08/28/2019
* Description   : Used to create Bulk referrals from Favorites screen
*                            M O D I F I C A T I O N   L O G                                          
*
* Date        Developer       Description                                                         
* ----------  -----------     --------------------------------------------------------------------
*  04/06/2019  Suyash       Initial Version
*  
**/
public with sharing class RE_CreateBulkReferralCtrl {

	 /*********************************************************************************************************
    * @author       Suyash Singhal
    * @date         08/28/2019
    * @methodname   createReferrals()
    * @description  This methods is used to create Bulk referrals
    * @return       RE_CreateLightningServerResponse
    /***********************************************************************************************************/

    @AuraEnabled
    public static RE_CreateLightningServerResponse createReferrals(String strJsonData,String strScreenVariablesJson){
        
        //escapesinglequotes cannot be made as it is malforming json(JSON has serialized data)-Payal
        String sJsonData = strJsonData;
        
        String sScreenVariablesJson = String.escapeSingleQuotes(strScreenVariablesJson);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        RE_CreateLightningServerResponse objCreateReferrals;
        
        try{ 
            ScreenInputs screenWrapper = (ScreenInputs)JSON.deserialize(sScreenVariablesJson,ScreenInputs.class);
            if(String.isNotBlank(sJsonData)){
                List<RE_MyFavoritesCtrl.FavoritesWrapper> lstWrapper = (List<RE_MyFavoritesCtrl.FavoritesWrapper>)JSON.deserialize(sJsonData,List<RE_MyFavoritesCtrl.FavoritesWrapper>.class);
                objCreateReferrals = insertBulkReferral(lstWrapper,screenWrapper);
                bSuccess = true; 
            }
        }catch(Exception e){
            bSuccess = false;
        }
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,objCreateReferrals.objectData);  
    }
  	/*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         09/11/2019
    * @methodname   insertBulkReferral()
    * @description  This methods is introduced as part of security fixes.
    * @return       RE_CreateLightningServerResponse
    /***********************************************************************************************************/
    public static RE_CreateLightningServerResponse insertBulkReferral(List<RE_MyFavoritesCtrl.FavoritesWrapper> lstWrapper,RE_CreateBulkReferralCtrl.ScreenInputs screenWrapper){
        String sContactId = screenWrapper.sClientId;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        User referraluser; 
        List<Referral__c> lstReferralsInsert= new List<Referral__c>();
        map<String,String> mapExistingRefResourcesName = new map<String,String>();
        Set<String> setSuccessfulReferalsResource = new Set<String>();
        Set<String> setUnSuccessfulReferalsResource = new Set<String>();
        try{
            String sClosed=RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
            Set<String> setResourceIds = new Set<String>();
            map<String,String> mapResourceIDvsLocationId = new map<String,String>();
            map<String,String> mapResourceIDvsNotesData = new map<String,String>();
            for(RE_MyFavoritesCtrl.FavoritesWrapper objWrapper : lstWrapper){
               setResourceIds.add(String.escapeSingleQuotes(objWrapper.sResourceId));
                mapResourceIDvsLocationId.put(objWrapper.sResourceId,objWrapper.sLocationId);
            }
            String sFieldsApiNameReferral = RE_DataBaseQueryFields.sFieldsApiNameForReferralTest; 
            Map<String,String> mapQueryParametersForReferral = new Map<String,String>();
            mapQueryParametersForReferral.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWherClauseForBulkReferralDuplicates);
            mapQueryParametersForReferral.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParametersForReferral.put(RE_GlobalConstants.sOrderByKey,RE_DataBaseQueryFields.sCreatedDateASC);
            String sQuery;
            
            Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility('Referral__c',sFieldsApiNameReferral,mapQueryParametersForReferral);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseReferral.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseReferral.get(true);
                    Map<String, String> mapInputs = new Map<String, String>();
                    mapInputs.put('sQuery',sQuery);
                    mapInputs.put('sContactId',sContactId);
                    mapInputs.put('sClosed',sClosed);
                    
                    lstReferralsInsert = RE_SharingByPassCtrl.getBulkReferralRecords(mapInputs, setResourceIds);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateBulkReferralCtrl','createReferrals','Some Fields doesn\'t have the required access :: '+mapResponseReferral.get(false), true);
                }
            }
            
            if(!lstReferralsInsert.isEmpty()){
                for(Referral__c objReferral : lstReferralsInsert){
                    mapExistingRefResourcesName.put(objReferral.Resource__c+''+objReferral.Location__c,objReferral.Resource__r.name);// Anuj - Defect#346650
                }
            }
            
            //Client User Query
            String referringcontactid= screenWrapper.sClientId;
           /* String sFieldsApiName = RE_DataBaseQueryFields.sIdNameFieldUsers; 
            String sWhereClause=RE_DataBaseQueryFields.sReferringContactWhereClause;
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            Map<String,String> mapQueryParametersForUser = new Map<String,String>();
            mapQueryParametersForUser.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParametersForUser.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParametersForUser.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            
            Map<Boolean,String> mapResponseReferralUsers = RE_DataAccessChecker.getFieldsAccessibility('User',sFieldsApiName,mapQueryParametersForUser);
            if(mapResponseReferralUsers.get(true) != null){
                String sQueryForUser =  mapResponseReferralUsers.get(true);
                referraluser = Database.query(sQueryForUser);  
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','insertReferral','***FLS Violation***'+mapResponseReferralUsers.get(false),true);
            }*/


            //Start Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
              /*referraluser = getRecordOwner(screenWrapper);*/
            //End Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
            List<Referral__c> lstRefsToInsert = new List<Referral__c>();
            
            for(RE_MyFavoritesCtrl.FavoritesWrapper objWrapper : lstWrapper){
                
                if(!mapExistingRefResourcesName.containsKey(objWrapper.sResourceId+''+objWrapper.sLocationId)){ // Anuj - Defect#346650
                    Referral__c objReferral= new Referral__c();
                    objReferral.Status__c= objWrapper.sOrgCheck;
                    objReferral.Source__c= RE_GlobalConstants.SUGGESTED_BY_PARTNER;
                    objReferral.Contacts__c=referringcontactid;
                    objReferral.Location__c=objWrapper.sLocationId;
                    objReferral.Resource__c=objWrapper.sResourceId;
                    objReferral.ReferredAccountID__c=objWrapper.sOrgId;
                    objReferral.ReferringUserPhone__c= GeneralUtility.formatphonenumber(screenWrapper.sPhone);//Screen Phone
                    objReferral.ReferringUserEmail__c=screenWrapper.sEmail;//Screen Email
                    objReferral.DateOfReferral__c=Date.today();
                    //Start Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
                    /*objReferral.OwnerId=referraluser.Id;*/
                    //End Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
                    lstRefsToInsert.add(objReferral);
                }else{
                    setUnSuccessfulReferalsResource.add(objWrapper.sResourceName);
                }
            }
            
            if(!lstRefsToInsert.isEmpty()){
                RE_SharingByPassCtrl.insertSobjects(Referral__c.getSObjectType(), lstRefsToInsert);
                //Suresh: Bug #357427 - Send Referrl Email Starts
                Map<Id, Referral__c> mapReferrals = new Map<Id, Referral__c>(lstRefsToInsert);
                Set<Id> setResourceId = new Set<Id>(mapReferrals.keySet());
                List<Referral__c> objReferralDetails= RE_SharingByPassCtrl.getReferralRecords(RE_DataBaseQueryFields.sRferralQuery,setResourceId, sContactId);
                RE_CreateReferralCtrl.sendEmailWhenReferralCreated(objReferralDetails);
                //Suresh: Bug #357427 - Send Referrl Email ENds
                for(Referral__c objReferral : lstRefsToInsert){
                 // creating the notes
                    RE_NotesCtrl.createNote('Referral Created',screenWrapper.sNotes,objReferral.Id,false);
                }
            }
            mapResponse.put('referralexist',setUnSuccessfulReferalsResource);
            mapResponse.put('NumberRefsCreated',lstRefsToInsert.size());
             //Start Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
            //mapResponse.put('ClientName',referraluser.Name);
             //Start Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
            bSuccess = true;
            
        }catch(Exception e){
            errorMap.put('error',e.getMessage());
            throw e;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    // added by Pankaj as part of security fixes
     //Start Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
    /*public static User getRecordOwner(ScreenInputs screenWrapper){
        //Client User Query
        User referraluser;
        String referringcontactid= screenWrapper.sClientId;
        String sFieldsApiName = RE_DataBaseQueryFields.sIdNameFieldUsers; 
        String sWhereClause=RE_DataBaseQueryFields.sReferringContactWhereClause;
        String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
        Map<String,String> mapQueryParametersForUser = new Map<String,String>();
        mapQueryParametersForUser.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapQueryParametersForUser.put(RE_GlobalConstants.sLimitKey, '1');
        mapQueryParametersForUser.put(RE_GlobalConstants.sOrderByKey,sOrderby);
        
        Map<Boolean,String> mapResponseReferralUsers = RE_DataAccessChecker.getFieldsAccessibility('User',sFieldsApiName,mapQueryParametersForUser);
        if(mapResponseReferralUsers.get(true) != null){
            String sQueryForUser =  mapResponseReferralUsers.get(true);
            referraluser = Database.query(sQueryForUser);  
        }else{
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','insertReferral','***FLS Violation***'+mapResponseReferralUsers.get(false),true);
        }
        return referraluser;
    }*/
    //End Commented as per ONEVIEW-1361-Payal(Create Referral not working for user's which do not have user enabled)
    
    /*********************************************************************************************************
    * @author       Suyash Singhal
    * @date         08/28/2019
    * @methodname   getTableData()
    * @description  This methods is used to parse Table Data and sent it Component
    * @return       RE_CreateLightningServerResponse
    /***********************************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getTableData(String strJsonData){
        
        
        //escapesinglequotes cannot be made as it is malforming json(JSON has serialized data)-Payal
        String sJsonData = strJsonData;
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = true;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        
        List<RE_MyFavoritesCtrl.FavoritesWrapper> lstWrapper = (List<RE_MyFavoritesCtrl.FavoritesWrapper>)JSON.deserialize(sJsonData,List<RE_MyFavoritesCtrl.FavoritesWrapper>.class);
        List<BulkReferralTableWrapper> lstTableWrapper = new List<BulkReferralTableWrapper>();
        for(RE_MyFavoritesCtrl.FavoritesWrapper objWrapper : lstWrapper){
            BulkReferralTableWrapper tableWrapper = new BulkReferralTableWrapper(objWrapper.sOrgName,objWrapper.sLocationName,objWrapper.sResourceName);
            lstTableWrapper.add(tableWrapper);
        }
        
        RE_CreateLightningServerResponse loggedinUserInfo = RE_CreateReferralCtrl.fetchloggedInUserInfo();
        if(loggedinUserInfo.isSuccessful){
        	map<String, Object> objectData = loggedinUserInfo.objectData;
            mapResponse.put('loggedinuserdata',objectData.get('records'));
        }
		mapResponse.put('tabledata', JSON.serialize(lstTableWrapper));
		return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);        
    }
   
    public class RE_RefWrapper{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Contact{get;set;}
        @AuraEnabled
        public String Location{get;set;}
        @AuraEnabled
        public String Resource{get;set;}
        @AuraEnabled
        public String Organization{get;set;}
        @AuraEnabled
        public String Notes{get;set;}
        @AuraEnabled
        public String Phone{get;set;} 
        @AuraEnabled
        public String Email{get;set;}
        @AuraEnabled
        public String sStatus{get;set;}
    }
    
    public class BulkReferralTableWrapper {
        public String Organization;
        public String Location;
        public String Resource;
        
        public BulkReferralTableWrapper(String Organization,String Location,String Resource){
            this.Organization = Organization;
            this.Location = Location;
            this.Resource = Resource;
        }
    }
    
    public class ScreenInputs{
       @AuraEnabled public String sEmail;
       @AuraEnabled public String sPhone;
       @AuraEnabled public String sClientId;
       @AuraEnabled public String sNotes;

    }
}