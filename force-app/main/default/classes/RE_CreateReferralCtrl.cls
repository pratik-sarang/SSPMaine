/**
* Class Name    : RE_CreateReferralCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Controller class for RE_ReferralDetails
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  Prashant       Initial Version
*  09/08/2019  Pankaj         Added helper methods to have business logic in same class instead 
*							  RE_SharingByPassCtrl as part of security fixes
**/

public with sharing class RE_CreateReferralCtrl {
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         14/06/2019
    * @methodname   fetchloggedInUserInfo()
    * @description  This methods is used to get the logged in user details
    * @param        void
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchloggedInUserInfo(){
        GeneralUtility.isAuthenticatedUser();
	/********** Fixed for Performance Issue: **********/
        //Commented as 2 SOQL were happening and we dont need this check since it is an internal call not exposed to user
        //String conrecordId = GeneralUtility.getLoggedInUserContactId() != null ? String.escapeSingleQuotes(GeneralUtility.getLoggedInUserContactId()) : '';
        String conrecordId = GeneralUtility.getLoggedInUserContactId();
        
        
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                Boolean bSuccess = false;  
        Contact contactobj= new contact();
        try{
            String sFieldsApiNameForContact = RE_DataBaseQueryFields.sFieldsApiNameForContact;
            String sWhereClauseForContact = RE_DataBaseQueryFields.sWhereClauseForContact ;
            String sQuery;
            Map<String,String> mapQueryParameters = new Map<String,String>();
           
            String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForContact);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby); 
            
            Map<Boolean,String> mapResponseContact = RE_DataAccessChecker.getFieldsAccessibility('Contact',sFieldsApiNameForContact,mapQueryParameters);
            if(mapResponseContact.get(true) != null){
                //fix for sit error logs
                if(conrecordId!=null){
                sQuery =  mapResponseContact.get(true);
                contactobj = (sQuery != '' && sQuery != null) ? Database.query(sQuery) : null;
		}
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_createReferral','getloggedinuserid','***FLS Violation***'+mapResponseContact.get(false),true);
            }
            if(contactobj != null){
                contactobj.Phone = (contactobj.Phone != null) ? GeneralUtility.formatphonenumber(contactobj.Phone) : '';
                mapResponse.put('records', JSON.serialize(contactobj));
            }
            bSuccess=true;
        }
        catch(Exception e){errorMap.put('error',e.getMessage());
                           LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateReferral','fetchloggedInUserInfo', e.getMessage(), true);
                           
                          }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         14/06/2019
    * @methodname   fetchLocations()
    * @description  This methods is used to get the locations
    * @param        String accountId
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchLocations(String strAccountId){
        
        String accountId = String.escapeSingleQuotes(strAccountId);
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse objResponse;
        try{
             objResponse= RE_SharingByPassCtrl.fetchLocations(accountId);
        }
        catch(Exception e){
             LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_createreferral', 'fetchLocations', e.getMessage(), true);
        }
        return objResponse;
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         14/06/2019
    * @methodname   fetchLocationResources()
    * @description  This methods is used to get the Resources
    * @param        String locationId
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchLocationResources(String strLocationId){
        
        String locationId = String.escapeSingleQuotes(strLocationId);
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse objResponse;
        try{
             objResponse= RE_SharingByPassCtrl.fetchLocationResources(locationId);
        }
        catch(Exception e){
             LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_createreferral', 'fetchLocationResources', e.getMessage(), true);
        }
        return objResponse;
    }    
	/********************************************************************************************
    * @author       Prashant Singh
    * @date         14/06/2019
    * @methodname   insertReferral()
    * @description  This methods is used to insert the referral
    * @param        RE_RefWrapper objWrapper
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReferral(RE_CreateReferralCtrl.RE_RefWrapper objWrapper){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Id contactId;
        if(objWrapper.isIEESData){
            RE_ClientsHelper.DataTableWrapper clientData=(RE_ClientsHelper.DataTableWrapper)JSON.deserialize(objWrapper.clientData,RE_ClientsHelper.DataTableWrapper.class);
            contactId=RE_CreateCitizenHelper.createContact(Integer.valueof(clientData.IEESId),clientData);
        }
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        try{
            List<Referral__c> referrallst=RE_SharingByPassCtrl.getReferralRecords(objWrapper);
                     //RE_Release 1.2 – Requirment 361795 & 361782 - Payal Dubela(04/23/2020)
                    List<Account> lstAccount =fetchOrganizationDetails(objWrapper.Organization);
            if(referrallst.isEmpty()){
                Referral__c objReferral= new Referral__c();
                        //Status checks
                        if(!lstAccount.isEmpty() && 
                           lstAccount[0].Status__c==RE_GlobalConstants.sAccountStatus && lstAccount[0].IsClaimed__c){
                objReferral.Status__c= RE_GlobalConstants.STATUS_NEW;
                        }else if(!lstAccount.isEmpty() && !lstAccount[0].IsClaimed__c){
                            objReferral.Status__c=RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
                        }else{
                            objReferral.Status__c= RE_GlobalConstants.STATUS_NEW;
                        }
                         //RE_Release 1.2 – Requirment 361795 & 361782 - Payal Dubela(04/23/2020)
                        if(objWrapper.isFrequentlyPaired!=null && objWrapper.isFrequentlyPaired){
                            objReferral.Source__c=RE_GlobalConstants.REFERRAL_SOURCE_FREQUENTLYPAIRED;
                        }else if(objWrapper.isRelatedServices!=null && objWrapper.isRelatedServices){
                            objReferral.Source__c=RE_GlobalConstants.REFERRAL_SOURCE_RELATEDSERVICES;
                        }else{
                objReferral.Source__c= RE_GlobalConstants.SUGGESTED_BY_PARTNER;
                        } 
                 if(objWrapper.isIEESData){
                   objReferral.Contacts__c=contactId;
                 }else{
                objReferral.Contacts__c=objWrapper.Contact;
                 }
                objReferral.Location__c=objWrapper.Location;
                objReferral.Resource__c=objWrapper.Resource;
                objReferral.ReferredAccountID__c=objWrapper.Organization;
                objReferral.ReferringUserPhone__c=objWrapper.Phone;
                objReferral.ReferringUserEmail__c=objWrapper.Email;
                if(objWrapper.Archetype!=null && objWrapper.Archetype!=''){
                    objReferral.Archetype__c=objWrapper.Archetype;}
                
                objReferral.DateOfReferral__c=Date.today();
                Boolean saveRes = RE_SharingByPassCtrl.insertSobject(Referral__c.getSObjectType(), objReferral);
                if(saveRes==true){
                        String sQuery='Select Id,Contacts__r.Name,Contacts__r.FirstName,Contacts__r.LastName,Contacts__r.Email,CreatedById,ReferredAccountID__r.Name,Resource__r.Name,';
                        sQuery+='Contacts__r.PreferredCommunicationMethod__c,ReferredByAccountID__r.Name,Location__r.Address1__c,Location__r.Address2__c,Location__r.City__c,';
                        sQuery+='Location__r.State__c,Location__r.Zip__c,Location__r.PointofContactPhone__c,';
                        sQuery+='Location__r.MondayOpen__c, Location__r.MondayClose__c,Location__r.TuesdayOpen__c,';                        
                        sQuery+='Location__r.TuesdayClose__c,Location__r.WednesdayOpen__c, Location__r.WednesdayClose__c,';
                        sQuery+='Location__r.ThursdayOpen__c, Location__r.ThursdayClose__c,Location__r.FridayOpen__c, ';
                        sQuery+='Location__r.FridayClose__c,Location__r.SaturdayOpen__c, Location__r.SaturdayClose__c,Location__r.SundayOpen__c, ';
                        sQuery+='Location__r.SundayClose__c,Location__r.DaysLocationClosed__c ';
                            sQuery+='FROM Referral__c WHERE id=:recordId';    
                            //RE_Release 1.4 – Iron Dome Changes(07/17) - Payal Dubela                    
                        Referral__c objReferralDetails=RE_SharingByPassCtrl.getReferralRecords(sQuery,objReferral.Id);
                    	sendEmailWhenReferralCreated(new List<Referral__c>{objReferralDetails});// Suresh: bulkified
                }   
                
                Map<String, String> mapInputs = new Map<String, String>();
                mapInputs.put('title','Referral Created');
                mapInputs.put('description',objWrapper.Notes);
                mapInputs.put('recid',objReferral.Id);
                mapInputs.put('isPublic',String.valueOf(false));
                RE_SharingByPassCtrl.createNote(mapInputs);
                mapResponse.put('referralexist',false);
            }else{ 
                mapResponse.put('referralexist',true);
            }
            bSuccess = true;
        }catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl', 'insertReferral', e.getMessage(), true);
            throw e;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Deeksha
    * @date         08/20/2019
    * @methodname   fetchFavResources()
    * @description  This methods is used to get favorite resources
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchFavResources(){
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse objResponse;
        try{
            objResponse = RE_MyFavoritesCtrl.fetchFavResources();
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_CreateReferralCtrl.class.getName(),'fetchFavResources', e.getMessage(), true);
        }
        return objResponse;
    }
    /********************************************************************************************
    * @author       Deeksha
    * @date         11/04/2019
    * @methodname   sendEmailWhenReferralCreated()
    * @description  This methods is used to send email to resident when referral is created ONEVIEW-1469
    * @return       
    **********************************************************************************************/
    public static void sendEmailWhenReferralCreated(List<Referral__c> lstobjReferral){
        List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
        Database.SaveResult[] srCommunicationNubList;
                Set<Id> lstLocationIds = new Set<Id>();
                Set<Id> setResourceIds = new Set<Id>();
        Set<String> strLocationId = new  Set<String>();
        for(Referral__c objReferral : lstobjReferral){
                lstLocationIds.add(objReferral.Location__c);
                setResourceIds.add(objReferral.Resource__c);
               strLocationId.add(objReferral.Location__c);
        }
                List<LocationResource__c> lstLocationResourceContact = RE_MyPlanHelper.getLocationResources(setResourceIds,lstLocationIds);
               List<Location__c> lstReferralLocation = RE_RDResidentViewCtrl.fetchLocationsData(strLocationId);
               Map<Id, Location__c> mapLocation = new Map<Id, Location__c>(lstReferralLocation);
               //RE security Changes -- Payal Dubela
               String sLoggedInUserProfileName = GeneralUtility.getLoggedInUserSelectedRole();
        
        for(Referral__c objReferral : lstobjReferral){
        if( EmailSetting__c.getInstance('Referral created mail').Is_on__c
           && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c){//&& objReferral.Contacts__r.PreferredCommunicationMethod__c == 'Email' - Bug #358843 - Commented by Suresh
               String strEmailTemplateBody ='';
               //link to redirect to Resource
                String objComUrl = Community_URL_Settings__c.getInstance().URL__c;
               
               Blob zipblob  = objReferral.Location__r.Zip__c!=null? Blob.valueOf(String.valueOf(objReferral.Location__r.Zip__c)):Blob.valueOf(RE_GlobalConstants.UNDEFINED);
               /*if(objReferral.Location__r.Zip__c!=null){
                zipblob=Blob.valueOf(String.valueOf(objReferral.Location__r.Zip__c));
               }else{
                zipblob=Blob.valueOf(RE_GlobalConstants.UNDEFINED);
               }*/
               Blob locblob = Blob.valueOf(objReferral.Location__c);
               Blob resblob = Blob.valueOf(objReferral.Resource__c);
               String resourceURL=objComUrl+'/s/'+Label.rdresourceid+EncodingUtil.base64Encode(resblob)+Label.andlocationid+EncodingUtil.base64Encode(locblob)+Label.andzipcode+EncodingUtil.base64Encode(zipblob);
               
               //if(sLoggedInUserProfileName == RE_GlobalConstants.RE_ASSISTER_PROFILE){ //PMD issue fix - Anuj
               // RE security changes -- Payal Dubela
               strEmailTemplateBody = (sLoggedInUserProfileName!=null && sLoggedInUserProfileName.contains(RE_GlobalConstants.RE_ASSISTER_ROLE)) ? String.format(Label.Referral_created_for_resident_Email_Body_Assister, new List<String>{ objReferral.Contacts__r.Name,UserInfo.getName(),objReferral.Resource__r.Name,Label.System_Name }) : String.format(Label.Referral_created_for_resident_Email_Body, new List<String>{ objReferral.Contacts__r.Name,UserInfo.getName(),objReferral.ReferredByAccountID__r.Name,objReferral.Resource__r.Name,Label.System_Name });
               //}
               //else{
               //strEmailTemplateBody = String.format(Label.Referral_created_for_resident_Email_Body, new List<String>{ objReferral.Contacts__r.Name,UserInfo.getName(),objReferral.ReferredByAccountID__r.Name,objReferral.Resource__r.Name,Label.System_Name });
               //}

               strEmailTemplateBody+='<p><b>'+objReferral.Resource__r.Name+'</b><br>'+objReferral.ReferredAccountID__r.Name+'<br>';
               strEmailTemplateBody+= objReferral.Location__r.Address1__c;
               if(objReferral.Location__r.Address2__c !=null){
                   strEmailTemplateBody+='<br>'+objReferral.Location__r.Address2__c;
               }
               strEmailTemplateBody+= '<br>'+objReferral.Location__r.City__c+', '+objReferral.Location__r.State__c+' '+objReferral.Location__r.Zip__c+'<br>';
               
               /* strEmailTemplateBody+= Label.phone+': '+objReferral.Location__r.PointofContactPhone__c+'<br>'; commented by Suresh*/
               /* added by Suresh Starts */
               for(LocationResource__c objLocResource: lstLocationResourceContact){
                   
                   if(objReferral.Resource__c == objLocResource.Resource__c && objReferral.Location__c == objLocResource.Location__c){
                       
                       //if(!String.isBlank(objLocResource.Phone__c)){ //PMD issue fixes - Anuj
                           //strEmailTemplateBody+= (!String.isBlank(objLocResource.Phone__c)) ? Label.phone+': '+GeneralUtility.formatphonenumber(objLocResource.Phone__c)+'<br>' : Label.phone+': '+GeneralUtility.formatphonenumber(objLocResource.TollFree__c)+'<br>';
                            strEmailTemplateBody+= (!String.isBlank(objLocResource.Phone__c)) ? Label.phone+': '+GeneralUtility.formatphonenumber(objLocResource.Phone__c)+'<br>' : (!String.isBlank(objLocResource.TollFree__c)) ? Label.phone+': '+GeneralUtility.formatphonenumber(objLocResource.TollFree__c)+'<br>:':'';
                       //}else if(!String.isBlank(objLocResource.TollFree__c)){ 
                           //strEmailTemplateBody+= Label.phone+': '+GeneralUtility.formatphonenumber(objLocResource.TollFree__c)+'<br>';
                       //}
                   }
               }
               
               /* added by Suresh Ends */
               
               strEmailTemplateBody+= Label.URL+': '+'<a href='+resourceURL+'>'+ resourceURL+'</a>'+'<br>';
               /* added by Suresh Starts */
               for(LocationResource__c objLocResource: lstLocationResourceContact){
                   if(objReferral.Resource__c == objLocResource.Resource__c && objReferral.Location__c == objLocResource.Location__c && mapLocation.get(objReferral.Location__c) != null){
                       
                       strEmailTemplateBody+= '<p>' +Label.next_steps+': '+objLocResource.NextSteps__c+'<br>';
                       strEmailTemplateBody+= Label.what_to_bring+': '+objLocResource.WhatToBring__c+'<br>'+'<p>'+Label.HoursOfOperationHeader+':<br>';
                       
                       RE_RDResidentViewCtrl.LocationTimeFields lclTimeFilds = new RE_RDResidentViewCtrl.LocationTimeFields(mapLocation.get(objReferral.Location__c), objLocResource);
                       
                       strEmailTemplateBody += (lclTimeFilds.isMondayClosed == false && lclTimeFilds.MondayOpen != '' && lclTimeFilds.MondayClose != '')?Label.monday+': '+lclTimeFilds.MondayOpen+' to '+lclTimeFilds.MondayClose+'<br>':(lclTimeFilds.isMondayClosed == true)?Label.monday+': Closed'+'<br>':Label.monday+':<br>';
                       
                       strEmailTemplateBody += (lclTimeFilds.isTuesdayClosed == false && lclTimeFilds.TuesdayOpen != '' && lclTimeFilds.TuesdayClose != '')?Label.tuesday+': '+lclTimeFilds.TuesdayOpen+' to '+lclTimeFilds.TuesdayClose+'<br>':
                       (lclTimeFilds.isTuesdayClosed == true)?Label.tuesday+': Closed'+'<br>':Label.tuesday+':<br>';
                       
                       strEmailTemplateBody += (lclTimeFilds.isWednesdayClosed == false && lclTimeFilds.WednesdayOpen !='' && lclTimeFilds.WednesdayClose != '')?Label.wednesday+': '+lclTimeFilds.WednesdayOpen+' to '+lclTimeFilds.WednesdayClose+'<br>': (lclTimeFilds.isWednesdayClosed == true)?Label.wednesday+': Closed'+'<br>':Label.wednesday+':<br>';
                       
                       strEmailTemplateBody += (lclTimeFilds.isThursdayClosed == false && lclTimeFilds.ThursdayOpen != '' && lclTimeFilds.ThursdayClose != '')?Label.thursday+': '+lclTimeFilds.ThursdayOpen+' to '+lclTimeFilds.ThursdayClose+'<br>':
                       (lclTimeFilds.isThursdayClosed == true)?Label.thursday+': Closed'+'<br>':Label.thursday+':<br>';
                       
                       strEmailTemplateBody += (lclTimeFilds.isFridayClosed == false && lclTimeFilds.FridayOpen !='' && lclTimeFilds.FridayClose != '')?Label.friday+': '+lclTimeFilds.FridayOpen+' to '+lclTimeFilds.FridayClose+'<br>':(lclTimeFilds.isFridayClosed == true)?Label.friday+': Closed'+'<br>':Label.friday+':<br>';
                       
                       strEmailTemplateBody += (lclTimeFilds.isSaturdayClosed == false && lclTimeFilds.SaturdayOpen != '' && lclTimeFilds.SaturdayClose !='')?Label.saturday+': '+lclTimeFilds.SaturdayOpen+' to '+lclTimeFilds.SaturdayClose+'<br>':
                       (lclTimeFilds.isSaturdayClosed == true)?Label.saturday+': Closed'+'<br>':Label.saturday+':<br>';
                       
                       strEmailTemplateBody += (lclTimeFilds.isSundayClosed == false && lclTimeFilds.SundayOpen != '' && lclTimeFilds.SundayClose != '')?Label.sunday+': '+lclTimeFilds.SundayOpen+' to '+lclTimeFilds.SundayClose+'<br>':
                       (lclTimeFilds.isSundayClosed == true)?Label.sunday+': Closed'+'<br>':Label.sunday+':<br>';
                       
                       //Nandita: 352685: Added logic to display notes in referral email R1.1
                    /*   if(lclTimeFilds.displayLocResNotes ==  true){
                                strEmailTemplateBody += '<br>'+'Notes:'+'  '+ objLocResource.Notes__c;
                       }
                       else if(lclTimeFilds.displayLocNotes ==  true){
                                strEmailTemplateBody += '<br>'+'Notes:'+'  '+ mapLocation.get(objReferral.Location__c).Notes__c;
                       }  */
		       //PMD fix - Prashant
                      strEmailTemplateBody +=  (lclTimeFilds.displayLocResNotes ==  true)?'<br>'+'Notes:'+'  '+ objLocResource.Notes__c : (lclTimeFilds.displayLocNotes ==  true)?  '<br>'+'Notes:'+'  '+ mapLocation.get(objReferral.Location__c).Notes__c:'' ; 
                   }
               }

               strEmailTemplateBody+= Label.RE_doNotReplyMessage + ' ' + Label.RE_PIIMessage +'<br>'+ Label.RE_SecurityMessage;
               //replace all the null with empty string in email body
               if(strEmailTemplateBody.contains('null')){
                   strEmailTemplateBody = strEmailTemplateBody.replace('null','');
               }
              
               CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
              
               
               objCommunicationNub.EmailSubject__c = String.format(Label.Referral_created_for_resident_Email_Subject, new List<String>{ Label.System_Name });
               objCommunicationNub.TemplateBody__c = strEmailTemplateBody;
               objCommunicationNub.ToEmail__c = objReferral.Contacts__r.Email;
               objCommunicationNub.FromEmail__c = UserInfo.getUserEmail();
               objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
               //Added By Kojashree
        	   objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
               lstCommunicationNubInsert.add(objCommunicationNub); 
            }
        }
               if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){  
                   srCommunicationNubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
               }
               else{
                   LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_CreateReferralCtrl.class.getName(), 'sendEmailWhenReferralCreated','No Access on CommunicationLog__c Object',true);
               }
           
    }
	
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         04/22/2020
    * @methodname   fetOrganizationDetails
    * @description  This methods Organization Details
    * @return       List<Account>
    * Requirement : 361782  & 361795
    **********************************************************************************************/
    public static List<Account> fetchOrganizationDetails(String orgId){
        orgId = String.escapeSingleQuotes(orgId);
        
        List<Account> lstAccounts = new List<Account>();
        String sFieldsToQueryOnAccount = RE_DataBaseQueryFields.sFieldsToQueryOnAccountCreateReferral;
        String sWhereClauseOnAccount = RE_DataBaseQueryFields.sWhereClauseForAccountCreatReferral;
        Map<String,String> mapAccountQueryParameters = new Map<String,String>();
        mapAccountQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAccount);
        Map<Boolean,String> mapAccountQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Account', sFieldsToQueryOnAccount, mapAccountQueryParameters);
        String switchAccountKey = (mapAccountQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchAccountKey) {
            when 'success' {
                String sQuery = mapAccountQueryResponse.get(true);
                lstAccounts = RE_SharingByPassCtrl.getOrganizationDetails(sQuery,orgId);
            }
            when 'failure'{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_CreateReferral','fetchOrganizationDetails','***FLS Violation***'+mapAccountQueryResponse.get(false),true);
            }
        }
        return lstAccounts;
           
    }
    
    public class RE_RefWrapper{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Contact{get;set;}
        @AuraEnabled
        public String Archetype{get;set;}
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
        public Boolean isIEESData{get;set;}
        @AuraEnabled
        public String clientData{get;set;}
        @AuraEnabled
        public Boolean isFrequentlyPaired{get;set;}
        @AuraEnabled
        public Boolean isRelatedServices{get;set;}
    }
    
}