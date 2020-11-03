/**
* Class Name    : ReferralTriggerHandler
* Owner         : DELOITTE
* Created Date  : 04/17/2020
* Description   : Helper class for ReferralTrigger
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  04/17/2020  Anuj       Initial Version
******************************************************************
* 	
**/

public with sharing class ReferralTriggerHandler extends TriggerHandler  {
    
    //used as a reference to compare b/w count of old and new referrals
    Public Static Map<Id,Integer> refCountMap = new Map<Id,Integer>();
    
    /********************************************************************************************
* @author       Anuj
* @date         04/17/2020
* @methodname   getOrgRefCount
* @description  This methods is used to return map of organization id and the count(int) of referrrals made to it
* @param        setOrgId : Set<Id>
* @return       orgIdCountMap: Map<Id,Integer>
********************************************************************************************/
    Public Static Map<Id,Integer> getOrgRefCount (Set<Id> setOrgId){
        Map<Id,Integer> orgIdCountMap = new Map<Id,Integer>();
        // Referral__c is a private Object, Users can't access Id, Name and other fields to find Count of Referrals, hence this query :
        try{
            List<AggregateResult> results = RE_SharingByPassCtrl.getReferralCountUnclaimedOrg(setOrgId);
            for(AggregateResult result : results){
                Id orgId = (Id)result.get('rid');
                Integer orgCount = (Integer)result.get('cnt');
                orgIdCountMap.put(orgId, orgCount);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','getOrgRefCount',e.getStackTraceString(), true);
        }
        return orgIdCountMap;
    }
    
    
    /********************************************************************************************
* @author       Anuj
* @date         04/20/2020
* @methodname   getLocationResources
* @description  This methods is used to return list of location resources
* @params       setResourceIds: Set<Id>, setLocationIds: Set<Id>
* @return       List<LocationResource__c>
********************************************************************************************/
    Public Static List<LocationResource__c> getLocationResources (Set<Id> setResourceIds, Set<Id> setLocationIds){
        
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        
        List<LocationResource__c> lstLocationResources = new List<LocationResource__c>();
        String sFieldsQueriedOnReferralLR = RE_DataBaseQueryFields.sFieldsQueriedOnReferralLR;
        String sWhereClauseOnLocationResource = RE_DataBaseQueryFields.sWhereClauseOnLocationResource;
        
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocationResource);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c', sFieldsQueriedOnReferralLR, mapQueryParameters);
        try{
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    lstLocationResources = RE_SharingByPassCtrl.getLocationResources(sQuery,setResourceIds,setLocationIds); 
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler', 'getLocationResources', RE_GlobalConstants.FLS_ERROR + '' + mapResponseData.get(false), true);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','getLocationResources',e.getStackTraceString(), true);
        }
        return lstLocationResources;
    }
    
    /********************************************************************************************
* @author       Anuj
* @date         04/20/2020
* @methodname   getOrgData
* @description  This methods is used to get the organization's data to send email to respective POCs
* @param        orgIds: Set<Id>
* @return       List<Account>
********************************************************************************************/
    Public static List<Account> getOrgData (Set<Id> orgIds){
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, String> mapQueryParameters = new Map<String, String>(); 
        List<Account> listOrg = new List<Account>();
        String sFieldsApiName;
        String sWhereClause;
        String sQuery;
        String switchCaseKey;
        try{
            sFieldsApiName = RE_DataBaseQueryFields.sAccountFieldsOffboardEMail;
            sWhereClause = RE_DataBaseQueryFields.sAccountWhereClauseOffboardEMail;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Account', sFieldsApiName, mapQueryParameters);
            switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (switchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    listOrg = RE_SharingByPassCtrl.getAccountList(sQuery,orgIds); 
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','getOrgData','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
        }catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','getOrgData', e.getMessage(), true);
        }
        return listOrg;
        
    }
    
    /********************************************************************************************
* @author       Anuj
* @date         04/20/2020
* @methodname   getOrgData
* @description  This methods is used to get the location record
* @param        locIds: Set<Id>
* @return       List<Location__c>
********************************************************************************************/
    Public static List<Location__c> getLocations (Set<Id> orgIds){
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, String> mapQueryParameters = new Map<String, String>(); 
        List<Location__c> listLoc = new List<Location__c>();
        String sFieldsApiName;
        String sWhereClause;
        String sQuery;
        String switchCaseKey;
        try{
            sFieldsApiName = RE_DataBaseQueryFields.sLocationFieldsOffboardEMail;
            sWhereClause = RE_DataBaseQueryFields.sLocationWhereClauseOffboardEMail;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Location__c', sFieldsApiName, mapQueryParameters);
            switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (switchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    listLoc = RE_SharingByPassCtrl.getLocationList(sQuery,orgIds);
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','getLocations','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
        }catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','getLocations', e.getMessage(), true);
        }
        return listLoc;
        
    }
    
    
    /********************************************************************************************
* @author       Anuj
* @date         04/17/2020
* @methodname   checkBeforeReferralCreated
* @description  This methods is used to update the 'refCountMap' with count of old referrals 
to the organization in context
* @param        lstReferrals: List<Referral__c>
* @return       Void
********************************************************************************************/
    Public void checkBeforeReferralCreated(List<Referral__c> lstReferrals){
        Set<Id> orgSet = new Set<Id>();
        try{
            if(lstReferrals!=null && !lstReferrals.isEmpty()){
                for(Referral__c ref : lstReferrals)
                {
                    if(ref.ReferredAccountID__c != null && ref.ReferredAccountID__r.IsClaimed__c == false)
                    {
                        orgSet.add(ref.ReferredAccountID__c);
                    }
                }
                ReferralTriggerHandler.refCountMap = ReferralTriggerHandler.getOrgRefCount(orgSet);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','checkBeforeReferralCreated', e.getMessage(), true);
            
        }
    }
    
    
    
    /********************************************************************************************
* @author       Anuj
* @date         04/17/2020
* @methodname   checkAfterReferralCreated
* @description  This methods is used to calculate logic to send emails
* @param        lstReferrals : List<Referral__c>
* @return       Void
********************************************************************************************/
    Public void checkAfterReferralCreated (List<Referral__c> lstReferrals){
        
        Set<Id> orgSet = new Set<Id>();
        Set<Id> finalOrgSet = new Set<Id>();
        Set<Id> locationSet = new Set<Id>();
        Set<Id> resourceSet = new Set<Id>();
        Boolean isFirstEmail = true;  //boolean to conditionally send first email and second email
        List<Referral__c> lstToUpdateReferrals = new List<Referral__c>();
        Map<Id, AccountContactRelation> acrMap = new Map<Id, AccountContactRelation>();
        String sRole;
        try{
            Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
		    // SCA Fix : Kojashree           
            List<AccountContactRelation> acrList = new List<AccountContactRelation>();
            if(Schema.sObjectType.AccountContactRelation.fields.Id.isAccessible() && Schema.sObjectType.AccountContactRelation.fields.ContactId.isAccessible() && Schema.sObjectType.AccountContactRelation.fields.AccountId.isAccessible() && Schema.sObjectType.AccountContactRelation.fields.Roles.isAccessible()){
               acrList = [SELECT Id, ContactId, AccountId, Roles 
                                                    FROM AccountContactRelation 
                                                    WHERE Account.RecordTypeId = :accountRecordTypeId AND Roles INCLUDES (:RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN, :RE_GlobalConstants.COMMUNITY_PARTNER_STAFF, :RE_GlobalConstants.CASE_WORKER_SUPERVISOR, :RE_GlobalConstants.CASE_WORKER, :RE_GlobalConstants.RE_ASSISTER_ROLE)];
         
            }
            List<Referral__c> lstRefToGetRelatedFields = new List<Referral__c>();
            if(Schema.sObjectType.Referral__c.fields.Id.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredByAccountID__c.isAccessible()  ){
                lstRefToGetRelatedFields = [SELECT Id, CreatedBy.RE_Selected_Role__c, CreatedBy.ContactId, ReferredAccountID__c, ReferredByAccountID__c 
                                                			FROM Referral__c 
                                                			WHERE Id IN :lstReferrals];
 
            }
           
            
            for(AccountContactRelation acr : acrList)
            {
                acrMap.put(acr.ContactId, acr);
            }
            for(Referral__c ref : lstRefToGetRelatedFields)
            {
                sRole = ref.CreatedBy.RE_Selected_Role__c;
                if(acrMap.containsKey(ref.CreatedBy.ContactId) && (sRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || sRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF || sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || sRole == RE_GlobalConstants.CASE_WORKER || sRole == RE_GlobalConstants.RE_ASSISTER_ROLE))
                {
                    ref.ReferredByAccountID__c = acrMap.get(ref.CreatedBy.ContactId).AccountId;
                    lstToUpdateReferrals.add(ref);
                }
            }
            if(lstToUpdateReferrals.size() > 0)
            {
                Update lstToUpdateReferrals;
            }
            for(Referral__c ref : lstReferrals)
            {
                if(ref.ReferredAccountID__c != null && ref.ReferredAccountID__r.IsClaimed__c == false)
                {
                    orgSet.add(ref.ReferredAccountID__c);
                }
            }
            
            Map<Id,Integer> newRefCountMap = ReferralTriggerHandler.getOrgRefCount(orgSet);
            if(ReferralTriggerHandler.refCountMap!=null && !ReferralTriggerHandler.refCountMap.isEmpty() && newRefCountMap!=null && !newRefCountMap.isEmpty()){
                for (Id i : ReferralTriggerHandler.refCountMap.keySet()) {
                    Integer oldValue = ReferralTriggerHandler.refCountMap.get(i);
                    Integer newValue = newRefCountMap.containsKey(i) ? newRefCountMap.get(i) : 0;
                    if(oldValue >= 1 && oldValue < 10 && newValue >= 10){
                        isFirstEmail = false;
                        finalOrgSet.add(i);
                    }
                }
                ReferralTriggerHandler.initiateEmailConditionally(finalOrgSet, isFirstEmail);
                //RE_Release 1.4 – Iron Dome Changes(07/20) - Payal Dubela
                }else if((ReferralTriggerHandler.refCountMap == null || ReferralTriggerHandler.refCountMap.isEmpty()) && (newRefCountMap != null && !newRefCountMap.isEmpty())){
                finalOrgSet.clear();
                Boolean isOneEmail = false;
                Boolean isBothEmail = false;
                for (Id orgId : newRefCountMap.keySet()) {
                    Integer newValue = newRefCountMap.get(orgId);
                    finalOrgSet.add(orgId);
                    if(newValue >= 1 && newValue < 10){
                        isOneEmail = true;
                    }else if(newValue >= 10){
                        isBothEmail = true;
                    }
                }
                if(isOneEmail){
                    ReferralTriggerHandler.initiateEmailConditionally(finalOrgSet, isOneEmail);
                }
                if(isBothEmail){
                    ReferralTriggerHandler.initiateEmailConditionally(finalOrgSet, true);
                    ReferralTriggerHandler.initiateEmailConditionally(finalOrgSet, false);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','checkAfterReferralCreated', e.getMessage(), true);
            
        }
    }
    
    /********************************************************************************************
* @author       Anuj
* @date         04/23/2020
* @methodname   initiateEmailConditionally
* @description  This methods is used to calculate logic to send first and second emails, or both emails.. conditionally!
* @param        isFirstEmail : Boolean, finalOrgSet : Set<Id>
* @return       Void
********************************************************************************************/
    Public static void initiateEmailConditionally(Set<Id> finalOrgSet, Boolean isFirstEmail){
        try{
            List<Account> listAcc = ReferralTriggerHandler.getOrgData(finalOrgSet);
            List<Location__c> listLoc = ReferralTriggerHandler.getLocations(finalOrgSet);
            List<Resource__c> listResources = RE_SharingByPassCtrl.getResourceListUnclaimedOrg(finalOrgSet);
            
            
            Set<Id> resourceSet = (new Map<Id,Resource__c>(listResources)).keySet();
            Set<Id> locationSet = (new Map<Id,Location__c>(listLoc)).keySet();
            
            List<LocationResource__c> listLr = ReferralTriggerHandler.getLocationResources(resourceSet,locationSet);
            
            String resourceURL = Community_URL_Settings__c.getOrgDefaults().URL__c+'/s/searchorganization?isOpenClaimRequest='+true+'&orgId=';
            
            ReferralTriggerHandler.sendEmail(listAcc,isFirstEmail,resourceURL);
            ReferralTriggerHandler.sendEmail(listLoc,isFirstEmail,resourceURL);
            ReferralTriggerHandler.sendEmail(listLr,isFirstEmail,resourceURL);
            
        }catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','initiateEmailConditionally', e.getMessage(), true);
        }
    }
    
    
    
    /********************************************************************************************
* @author       Anuj
* @date         04/17/2020
* @methodname   sendEmail
* @description  This methods is used to send params to createCommunicationRecord method conditionally
* @param        objList: List<sObject>, isFirstEmail: Boolean
* @return       null
********************************************************************************************/
    Public static void sendEmail(List<sObject> objList, Boolean isFirstEmail, String resourceURL){
        try{ 
            if (objList != null 
                && EmailSetting__c.getInstance('Referral email to offboarded partner').Is_on__c
                && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c) {
                    ReferralTriggerHandler.createCommunicationRecord(objList,isFirstEmail,resourceURL);   
                }
        }catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','sendEmail', e.getMessage(), true);
        }
    }
    
    /********************************************************************************************
* @author       Anuj
* @date         04/22/2020
* @methodname   createCommunicationRecord
* @description  This methods is used to send email to the POCs about the first and tenth referral created for 
the resources of the Organization claimed.
* @param        isFirstEmail: Boolean; firstParam,secondParam,thirdParam,toEmail : String
* @return       null
********************************************************************************************/
    Public static void createCommunicationRecord(List<sObject> objList, Boolean isFirstEmail, String resourceURL){
        String sTemplateBody = RE_GlobalConstants.sEmptyString;
        try{
            // set template body    
            //set template body ends
            List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
            //--------------------------
            String sobjectType = objList.size() > 0 ? objList[0].Id.getSObjectType().getDescribe().getName() : '';
            for(sObject obj: objList){
                //set param for LR,Location & Account
                String firstParam;
                String secondParam;
                String thirdParam;
                String toEmail; 
                switch on sobjectType {
                    when 'LocationResource__c' {
                        secondParam = (String)obj.get('AccountName__c');
                        String orgId = (String)obj.get('OrgId__c');
                        thirdParam = obj.get('OrgId__c') != null ? resourceURL+EncodingUtil.base64Encode(Blob.valueOf(orgId)) : '';
                        if(obj.get('FirstPointofContactEmail__c') != null){
                            firstParam = (obj.get('FirstPointOfContactName__c') != null) ? ' '+(String)obj.get('FirstPointOfContactName__c')+',' : ',';
                            sTemplateBody =  isFirstEmail == true ? String.format(Label.RE_OffboardReferralFirstEmail,new List<String>{firstParam,secondParam,thirdParam}) : String.format(Label.RE_OffboardReferralSecondEmail,new List<String>{firstParam,secondParam,thirdParam});                        
                            sTemplateBody += Label.RE_OffboardReferralFooter;
                            CommunicationLog__c objCommunicationNubFirstPOC = new CommunicationLog__c();
                            objCommunicationNubFirstPOC.EmailSubject__c = Label.RE_OffboardReferralEmailSubject;
                            objCommunicationNubFirstPOC.TemplateBody__c = sTemplateBody;
                            objCommunicationNubFirstPOC.Status__c= RE_GlobalConstants.STATUS_INPROGRESS;
                            objCommunicationNubFirstPOC.ToEmail__c= (String)obj.get('FirstPointofContactEmail__c');
                             //Added By Kojashree
       					    objCommunicationNubFirstPOC.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                         
                            objCommunicationNubFirstPOC.SendMail__c= (objCommunicationNubFirstPOC.ToEmail__c != null && objCommunicationNubFirstPOC.ToEmail__c != '') ? True : False;
                            lstCommunicationNubInsert.add(objCommunicationNubFirstPOC);
                        }
                        if(obj.get('SecondPointofContactEmail__c') != null){
                            firstParam = (obj.get('SecondPointOfContactName__c') != null) ? ' '+(String)obj.get('SecondPointOfContactName__c')+',' : ',';
                            sTemplateBody =  isFirstEmail == true ? String.format(Label.RE_OffboardReferralFirstEmail,new List<String>{firstParam,secondParam,thirdParam}) : String.format(Label.RE_OffboardReferralSecondEmail,new List<String>{firstParam,secondParam,thirdParam});
                            sTemplateBody += Label.RE_OffboardReferralFooter;
                            CommunicationLog__c objCommunicationNubSecondPOC = new CommunicationLog__c();
                            objCommunicationNubSecondPOC.EmailSubject__c = Label.RE_OffboardReferralEmailSubject;
                            objCommunicationNubSecondPOC.TemplateBody__c = sTemplateBody;
                            objCommunicationNubSecondPOC.Status__c= RE_GlobalConstants.STATUS_INPROGRESS;
                            objCommunicationNubSecondPOC.ToEmail__c= (String)obj.get('SecondPointofContactEmail__c');
                             //Added By Kojashree
       					    objCommunicationNubSecondPOC.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                           
                            objCommunicationNubSecondPOC.SendMail__c= (objCommunicationNubSecondPOC.ToEmail__c != null && objCommunicationNubSecondPOC.ToEmail__c != '') ? True : False;
                            lstCommunicationNubInsert.add(objCommunicationNubSecondPOC);
                        }
                        
                    }	
                    when 'Location__c' {
                        firstParam = (obj.get('PointOfContactName__c') != null) ? ' '+(String)obj.get('PointOfContactName__c')+',' : ',';
                        secondParam = (String)obj.get('AccountName__c');
                        String orgId = (String)obj.get('Account__c');
                        thirdParam = resourceURL+EncodingUtil.base64Encode(Blob.valueOf(orgId));
                        toEmail = (String)obj.get('PointofContactEmail__c');
                        sTemplateBody =  isFirstEmail == true ? String.format(Label.RE_OffboardReferralFirstEmail,new List<String>{firstParam,secondParam,thirdParam}) : String.format(Label.RE_OffboardReferralSecondEmail,new List<String>{firstParam,secondParam,thirdParam});
                        sTemplateBody += Label.RE_OffboardReferralFooter;
                        if(obj.get('PointofContactEmail__c') != null){
                            CommunicationLog__c objCommunicationNubFirstPOC = new CommunicationLog__c();
                            objCommunicationNubFirstPOC.EmailSubject__c = Label.RE_OffboardReferralEmailSubject;
                            objCommunicationNubFirstPOC.TemplateBody__c = sTemplateBody;
                            objCommunicationNubFirstPOC.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                            objCommunicationNubFirstPOC.ToEmail__c= (String)obj.get('PointofContactEmail__c');
                             //Added By Kojashree
       					    objCommunicationNubFirstPOC.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                           
                            objCommunicationNubFirstPOC.SendMail__c= (objCommunicationNubFirstPOC.ToEmail__c != null && objCommunicationNubFirstPOC.ToEmail__c != '') ? True : False;
                            lstCommunicationNubInsert.add(objCommunicationNubFirstPOC);
                        }
                    }
                    when 'Account' {
                        firstParam = (obj.get('POC_Name__c') != null) ? ' '+(String)obj.get('POC_Name__c')+',' : ',';
                        secondParam = (String)obj.get('Name');
                        String orgId = (String)obj.get('Id');
                        thirdParam = resourceURL+EncodingUtil.base64Encode(Blob.valueOf(orgId));
                        toEmail = (String)obj.get('POC_Email__c');
                        sTemplateBody =  isFirstEmail == true ? String.format(Label.RE_OffboardReferralFirstEmail,new List<String>{firstParam,secondParam,thirdParam}) : String.format(Label.RE_OffboardReferralSecondEmail,new List<String>{firstParam,secondParam,thirdParam});                         	
                        sTemplateBody += Label.RE_OffboardReferralFooter;
                        if(obj.get('POC_Email__c') != null){
                            CommunicationLog__c objCommunicationNubFirstPOC = new CommunicationLog__c();
                            objCommunicationNubFirstPOC.EmailSubject__c = Label.RE_OffboardReferralEmailSubject;
                            objCommunicationNubFirstPOC.TemplateBody__c = sTemplateBody;
                            objCommunicationNubFirstPOC.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                            objCommunicationNubFirstPOC.ToEmail__c= (String)obj.get('POC_Email__c');
                             //Added By Kojashree
       					    objCommunicationNubFirstPOC.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                          
                            objCommunicationNubFirstPOC.SendMail__c= (objCommunicationNubFirstPOC.ToEmail__c != null && objCommunicationNubFirstPOC.ToEmail__c != '') ? True : False;
                            lstCommunicationNubInsert.add(objCommunicationNubFirstPOC);
                        }
                    }
                    when else{
                        // do nothing
                    }
                }
                //set param for LR,Location & Account ends
            }
            if(lstCommunicationNubInsert!=null && lstCommunicationNubInsert.size() > 0){
                if(RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){   
                    RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                }
                else{
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,ReferralTriggerHandler.class.getName(), 'createCommunicationRecord','No Access on CommunicationLog__c Object',true);
                }
                
            }
        }catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'ReferralTriggerHandler','createCommunicationRecord', e.getMessage(), true);
        }
    }
    
}