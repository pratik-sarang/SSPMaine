	/**
* Class Name    : RE_MyPlanCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Controller class for My Plan
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/07/2019  PANKAJ       Initial Version
*  11/04/2019  PANKAJ		Changed logic for displaying only public Notes on Resident MyPlan Page
*  12/04/2019  Megha M      Changed logic to set the firstname, lastname and email while sending email plan to resident - Bug(341987)
*  01/07/2020  Megha M      Added Pagination Changes
**/
public with sharing class RE_MyPlanCtrl {

    public List<RE_MyPlanWrapper> resultInProgressResources { get; set; }
    public List<RE_MyPlanWrapper> resultCompletedResources { get; set; }
    public String partnerName { get; set; }
    public string clientId { get; set;}

    /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/07/2019
    * @methodname   getMyPlans()
    * @description  This methods is used to get the list of MyPlans
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getMyPlans(String strContactId, String sPageType,String iPageSize, String pageNumber){ 
        String sContactId = String.escapeSingleQuotes(strContactId);
        String strPageType =String.isNotBlank(sPageType)?String.escapeSingleQuotes(sPageType):'';
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('Cart_SuggestedForMe');
        try{
            List<RE_MyPlanWrapper> lstInProgressWrapper = new List<RE_MyPlanWrapper>();
            List<RE_MyPlanWrapper> lstCompletedWrapper = new List<RE_MyPlanWrapper>();
            List<RE_MyPlanWrapper> lstDraftWrapper = new List<RE_MyPlanWrapper>();
            Map<Id, Double> mapReferralDistance = new Map<Id, Double>();
            Map<Id, String> mapLatLong = new Map<Id, String>();
            Set<Id> lstLocationIds = new Set<Id>();
            Set<Id> setReferralIds = new Set<Id>();
            Set<Id> setResourceIds = new Set<Id>();
            Id contactId;
           //  String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
            
            // Added By Kojashree --- SSP Merge
            String sRole = GeneralUtility.getLoggedInUserSelectedRole();
            // if(sProfileName == RE_GlobalConstants.strCitizenProfileName){
            if(sRole == RE_GlobalConstants.strCitizenAppRole){
                // if profile is citizen dont allow to pass any other contact id
                contactId = GeneralUtility.getLoggedInUserContactId();
            }else{
                contactId = (String.isBlank(sContactId)) ? GeneralUtility.getLoggedInUserContactId() : sContactId;
            }
            Contact objContact = new Contact();
            //Fix for Sit error logs
            if(contactId!=null){
                //Updated By Kojashree SSP Merge
                // objContact= RE_SharingByPassCtrl.getCitizenContactDetails(contactId, sProfileName);
                objContact= RE_SharingByPassCtrl.getCitizenContactDetails(contactId, sRole);
            }
            //RE_Release 1.1 – Security Fixes - Payal Dubela(04/02/2020) -- Added Check to avoid null pointer if contact is not queried
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (objContact.Id!=null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    
                    // if((sProfileName == 'RE Citizen Profile') || (sProfileName == RE_GlobalConstants.strAgencyProfileName) || !(GeneralUtility.checkConsentForClient(objContact.Id).isEmpty()))
                    // Added By Kojashree - SSP Merge 
                    RE_GlobalConstants.SWITCH_CONSTANTS isAccessible = ((sRole == RE_GlobalConstants.strCitizenAppRole) || (sRole == RE_GlobalConstants.CASE_WORKER) || (sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR) || !(GeneralUtility.checkConsentForClient(sContactId).isEmpty()))? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                    switch on (isAccessible){
                        when SWITCH_SUCCESS {
                        Location objLocationdata = objContact.ContactGeoLocation__c;                        
                        //RE_Release 1.2 – SIT Error Log- Payal Dubela– Fixing error log(After cut to production)
                        List<Referral__c>   lstReferral= RE_SharingByPassCtrl.getReferralDetails(contactId,strPageType,(!String.isEmpty(iPageSize))?Integer.valueof(iPageSize):Integer.valueof(Label.RE_Clients_Search_Limit),Integer.valueof(pageNumber));
            for(Referral__c objReferral : lstReferral){
                Double dMiles = RE_MyPlanHelper.getDistance(objLocationdata, objReferral.Location__r.Geolocation__c, 'mi');
                mapReferralDistance.put(objReferral.Id, dMiles); 
                String sLatLong = objReferral.Location__r.Geolocation__latitude__s+'##'+objReferral.Location__r.Geolocation__longitude__s;
                mapLatLong.put(objReferral.Id, sLatLong);
                setReferralIds.add(objReferral.Id);
                lstLocationIds.add(objReferral.Location__c);
                setResourceIds.add(objReferral.Resource__c);
            }
            // check if location and referral is present for the user
            String sSwitchKey = (lstLocationIds != null && !lstLocationIds.isEmpty() && setReferralIds != null && !setReferralIds.isEmpty()) ? 'success' : 'failure';
            switch on (sSwitchKey) {
                when 'success' {
                    List<LocationResource__c> lstLocationResourceContact = RE_MyPlanHelper.getLocationResources(setResourceIds,lstLocationIds);
                    //RE_Release 1.1 – Defect 359141- Payal Dubela– Removing Favorite Functionality from My Plan
                    // Map<String, Favorite__c> mapFavorites = RE_SharingByPassCtrl.getMyFavorite(setResourceIds,lstLocationIds);
                    
                    Map<Id,  Map<String, List<String>>> mapOperatingHours = GeneralUtility.getLocationOperationHoursList(lstLocationIds,lstLocationResourceContact);
                    List<Feedback__c> lstReferralFeedback = RE_SharingByPassCtrl.getReferralFeedback(setReferralIds);
                    Map<Id, Feedback__c> mapReferralFeedback = new  Map<Id, Feedback__c>();
                    for(Feedback__c objFeedback : lstReferralFeedback){
                        mapReferralFeedback.put(objFeedback.Referral__c, objFeedback);
                    }
                    Map<String, List<RE_NotesCtrl.NotesWrapper>> mapReferralContentNotes = RE_MyPlanHelper.getReferralNotes(setReferralIds);
                                //Moved in the conditon for performance fix
                                //Map<String,Boolean> mapCRefNoteAccess = getContentNotesAccessFromWrapper(mapReferralContentNotes);
                                Map<String,Boolean> mapCRefNoteAccess= new Map<String,Boolean>();
                                if(strPageType=='Suggested'){
                                    mapCRefNoteAccess = getContentNotesAccessFromWrapper(mapReferralContentNotes);
                                }
                    for(Referral__c objReferral : lstReferral){
                        RE_MyPlanWrapper objWrapper = new RE_MyPlanWrapper();
                        RE_MyPlanWrapper.Resource objResource = new RE_MyPlanWrapper.Resource();
                        RE_MyPlanWrapper.Location objLocation = new RE_MyPlanWrapper.Location();
                        for(LocationResource__c objLocResource: lstLocationResourceContact){
                            if(objReferral.Resource__c == objLocResource.Resource__c && objReferral.Location__c == objLocResource.Location__c){
                                objWrapper.sLocResourceId = objLocResource.Id;
                                            String locResNotes = objLocResource.Notes__c;
                                            String locNotes = objLocResource.Location__r.Notes__c;
                                            //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue
                                            objWrapper.sLocationResourceNotes=objLocResource.Notes__c;
                                //RE_Release 1.1 – Defect 359141- Payal Dubela– Removing Favorite Functionality from My Plan
                                //objWrapper.bIsFav = (mapFavorites.containsKey(objLocResource.Id)) ? true :false;
                                objResource.sResourceDescription=objLocResource.ResourceDescription__c;
                                if(!String.isBlank(objLocResource.Phone__c)){
                                    objLocation.sPOCPhone = GeneralUtility.formatphonenumber(objLocResource.Phone__c); 
                                }else if(!String.isBlank(objLocResource.TollFree__c)){
                                    objLocation.sPOCPhone = GeneralUtility.formatphonenumber(objLocResource.TollFree__c); 
                                }
                                Map<String, List<String>> mapLDayOperatingHours = mapOperatingHours.get(objLocResource.Id);
                               
                                objWrapper.sOperatingHoursData = JSON.serialize(mapLDayOperatingHours);
				            
                                	    DateTime dt = DateTime.now();
                                            String weekdayValue = dt.format('EEEE');
                                            List<String> lstOperationHours = mapLDayOperatingHours.get(weekdayValue); 
                                            if(lstOperationHours[0] != '' && lstOperationHours[3] == 'true'){ // When time is present and it is from LR
                                                objWrapper.sOperatingHoursToday =Label.today + ' ' +lstOperationHours[0]+' '+Label.to+' '+lstOperationHours[1];
                                            }
                                            else if(lstOperationHours[0] == '' && lstOperationHours[2] == 'true' && lstOperationHours[3] == 'true'){//When Time is blank and LR and 'Closed'
                                                objWrapper.sOperatingHoursToday =weekdayValue + ' Closed';
                                            }
                                            else if(locResNotes != '' && locResNotes != null && lstOperationHours[3] == 'false'){//When time is blank and not Closed and 'Notes' are present
                                                 objWrapper.sOperatingHoursToday = locResNotes;
                                                
                                            }
                                            else if(lstOperationHours[0] != '' && lstOperationHours[3] == 'false'){// When time is present and it is from L
                                                objWrapper.sOperatingHoursToday =Label.today + ' ' +lstOperationHours[0]+' '+Label.to+' '+lstOperationHours[1];
                                                
                                            }
                                            else if(lstOperationHours[0] == '' && lstOperationHours[2] == 'true' && lstOperationHours[3] == 'false'){//When Time is blank and L and 'Closed'
                                                objWrapper.sOperatingHoursToday = weekdayValue + ' Closed';
                                            }
                                            else{ //When time is blank and L and not Closed and 'Notes' are present
                                                 objWrapper.sOperatingHoursToday = locNotes;
                                                
                                            }
                                            
                                            objResource.sWhatToBring = objLocResource.WhatToBring__c;
                                            objResource.sResourceElegibility = objLocResource.EligibilityDescription__c;
                                            objResource.sNextStep = objLocResource.NextSteps__c;
                                            objResource.intFees = objLocResource.Fees__c;
                                        }
                                        
                                    }
                                    
                                    
                                    /* Referrals */
                                    RE_MyPlanWrapper.Referral objRef = new RE_MyPlanWrapper.Referral();
                                    objRef.referralId = objReferral.Id;
                                    objRef.sReferralStatus = objReferral.Status__c;
                                    objRef.sReferralOrgId = objReferral.ReferredAccountID__c;
                                    objRef.sReferralLatLong = mapLatLong.get(objReferral.Id);
                                    objRef.sReferralCreatedByName = objReferral.CreatedBy.Name;
                                    objRef.sReferralCreatedByAccountName = objReferral.CreatedBy.Account.Name;
                                    objRef.dCreatedDate = objReferral.CreatedDate;
                                    objRef.sDayOpened = String.valueOf(objReferral.DaysSinceOpened__c);
                                    objRef.bIsRated = (mapReferralFeedback.get(objReferral.Id) != null)? true : false;
                                    objWrapper.referral = objRef;
                                    
                                    /*Resources*/
                                    
                                    //objResource.intFees = objReferral.Resource__r.Fees__c;
                                    objResource.resourceId = objReferral.Resource__c;
                                    objResource.resourceOrgName = objReferral.Resource__r.Organization__r.Name;
                                    //objResource.sNextStep = objReferral.Resource__r.NextSteps__c;
                                    //objResource.sResourceDescription = objReferral.Resource__r.Description__c;
                                    objResource.sResourceName = objReferral.Resource__r.Name;
                                    objResource.sSDOHCategory = objReferral.Resource__r.SdohDomain__c;
                                    // objResource.sWhatToBring = objReferral.Resource__r.WhatToBring__c;
                                    //objResource.sResourceElegibility = objReferral.Resource__r.EligibilityDescription__c;
                                    objWrapper.resource = objResource;
                                    /* Accoount */
                                    RE_MyPlanWrapper.Account objAccount = new RE_MyPlanWrapper.Account();
                                    objAccount.bOrgIsClaimed = objReferral.ReferredAccountID__r.IsClaimed__c;
                                    objAccount.sReferralOrgUrl = objReferral.ReferredAccountID__r.Website;
                                    objAccount.sReferralOrgName = objReferral.ReferredAccountID__r.Name;
                                    objAccount.sReferralOrgAddress1 = objReferral.ReferredAccountID__r.ShippingStreet;
                                    objAccount.sReferralOrgCity = objReferral.ReferredAccountID__r.ShippingCity;
                                    objAccount.sReferralOrgZip = objReferral.ReferredAccountID__r.ShippingPostalCode;
                                    objAccount.sReferralOrgUrl = objReferral.ReferredAccountID__r.Website;
                                    objWrapper.acc = objAccount;
                                    objWrapper.dMiles = mapReferralDistance.get(objReferral.Id);
                                    // Referral Notes
                                    //objWrapper.lstNotes = mapReferralContentNotes.get(objReferral.Id);
                                    List<RE_NotesCtrl.NotesWrapper> lstPublicNotes = (List<RE_NotesCtrl.NotesWrapper>) mapReferralContentNotes.get(objReferral.Id);
                                    List<RE_NotesCtrl.NotesWrapper> lstFinalPublicNotes = new List<RE_NotesCtrl.NotesWrapper>();
                                    // lstPublicNotes = (List<RE_NotesCtrl.NotesWrapper>) mapReferralContentNotes.get(objReferral.Id);
                                    for(integer i =0; lstPublicNotes != null && i<lstPublicNotes.size(); i++){
                                        if(lstPublicNotes[i].isPublic == true) {lstFinalPublicNotes.add(lstPublicNotes[i]);}
                                    }
                                    objWrapper.lstNotes =lstFinalPublicNotes;
                                    if(objWrapper.lstNotes != null && !objWrapper.lstNotes.isEmpty() && (mapCRefNoteAccess.containsKey(objReferral.Id) && mapCRefNoteAccess.get(objReferral.Id) != null && mapCRefNoteAccess.get(objReferral.Id))){
				    objWrapper.firstContentNote = objWrapper.lstNotes[0]; }                        
                                    /* Location */
                                    
                                    objLocation.sLocationAddress1 = objReferral.Location__r.Address1__c;
                                    objLocation.sLocationAddress2  = objReferral.Location__r.Address2__c;
                                    objLocation.sLocationCity = objReferral.Location__r.City__c;
                                    objLocation.sLocationState = objReferral.Location__r.State__c;
                                    objLocation.sLocationCountry = objReferral.Location__r.County__c;
                                    objLocation.sLocationZip = (objReferral.Location__r.Zip__c != null) ? String.valueOf(objReferral.Location__r.Zip__c) : '';
                                    objLocation.sLocationZipExt = (objReferral.Location__r.ZipExtensionCode__c != null) ? String.valueOf(objReferral.Location__r.ZipExtensionCode__c) : '';
                                    objLocation.sPOCEmail = String.isBlank(objReferral.Location__r.Email__c)?objReferral.Location__r.Account__r.Email__c:objReferral.Location__r.Email__c;
                                    objLocation.sWebsite = (objReferral.Location__r.LocationWebsite__c != null) ? objReferral.Location__r.LocationWebsite__c : objReferral.Location__r.Account__r.Website;
                                    objLocation.sLocationWebsite = objReferral.Location__r.LocationWebsite__c;
                                    objLocation.sLocation = objReferral.Location__r.Name;
                                    objLocation.sLocationId = objReferral.Location__c;
                                    objLocation.sSpcialLocationInstructions = objReferral.Location__r.SpecialLocationInstructions__c;
                                    /*if(!String.isBlank(objReferral.Location__r.Phone__c)){
objLocation.sPOCPhone = GeneralUtility.formatphonenumber(objReferral.Location__r.Phone__c); 
}else if(!String.isBlank(objReferral.Location__r.Account__r.Phone)){
objLocation.sPOCPhone = GeneralUtility.formatphonenumber(objReferral.Location__r.Account__r.Phone); 
}*/
                                    //Map<String, String> mapLDayOperatingHours = mapOperatingHours.get( objReferral.Location__c);
                                    //objWrapper.sOperatingHoursData = JSON.serialize(mapLDayOperatingHours);
                                    // added by Pankaj for closed location days [12/02/2019]
                                    List<String> daysClosed = new List<String>();
                                    if(objReferral.Location__r.DaysLocationClosed__c !=null){                                               
                                        for(String locClosed : objReferral.Location__r.DaysLocationClosed__c.split(';')){
                                            daysClosed.add(locClosed);
                                        }
                                    }
                                    objLocation.lstClosedDays = daysClosed;
                                    objWrapper.location = objLocation;
                                    /* Contact */
                                    RE_MyPlanWrapper.Contact objCon = new RE_MyPlanWrapper.Contact();
                                    objCon.sResidentId = contactId;
                                    objCon.sContactZipCode = objContact.mailingpostalcode;
                                    objWrapper.con = objCon;
                                    // Location Operating hours
                                    if(objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_DRAFT){
                                        lstDraftWrapper.add(objWrapper);
                                    }else if( (objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_CLOSED || objReferral.UserComplete__c == true) && objReferral.Outcome__c != RE_GlobalConstants.REFERRAL_OUTCOME_STATUS){
                                        lstCompletedWrapper.add(objWrapper);
                                    }else if(objReferral.Status__c != RE_GlobalConstants.STATUS_CLOSING_REFERRAL && objReferral.Outcome__c != RE_GlobalConstants.REFERRAL_OUTCOME_STATUS){
                                        lstInProgressWrapper.add(objWrapper);
                                        
                                    }
                                }
                            }
                        }
                        String sLocationOperatingHrs = (objLocationdata != null) ? objLocationdata.getLatitude() + '##' + objLocationdata.getLongitude() : '';
                        mapResponse.put('mylocation', sLocationOperatingHrs);            
                        if(strPageType=='MyResources'){
                            mapResponse.put('myresource', lstInProgressWrapper);
                            
                        } else if(strPageType=='Completed'){
                            mapResponse.put('completed', lstCompletedWrapper);            
                        } else if(strPageType=='Suggested'){
                            mapResponse.put('suggested',SuggestedByMeResources(contactId));
                        }   
                        // Commented By Kojashree -- SSP Merge
                       // mapResponse.put('profile', sProfileName); 
                        mapResponse.put('profile', sRole); 
                        Integer sGlbResLen = 0;
                        sGlbResLen = (lstReferral!=null)?lstReferral.size():sGlbResLen;
                        mapResponse.put('sGlbResLen',sGlbResLen);               
                        mapResponse.put('mylocationdata', JSON.serialize(objContact));
                        mapResponse.put('isMyCartServiceAvailable',oIntEndpoints.isServiceAvailable__c );
                        bSuccess = true;
                    }when SWITCH_FAILURE { 
                        bSuccess=false;
                    }
                }
                }
                when SWITCH_FAILURE {
                    bSuccess=false;
                }
            }
        }catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl', 'getMyPlans', e.getMessage()+' '+e.getStackTraceString(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
/********************************************************************************************
* @author       Srikanth
* @date         04/23/2020
* @methodname   SuggestedByMeResources()
* @description  This method queries the data for the below descriotion sobjects from Referral Recommendations object 
* @return       List<RE_MyPlanWrapper> -  Returns all the Account,Resources,Location,contact to
                 the UI in order to specifiy the Suggested my cart details
**********************************************************************************************/    
    
    public static List<RE_MyPlanWrapper> SuggestedByMeResources(string strContactId){
        
        
        
        String contactId;  
        // String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
        // Added By Kojashree --- SSP Merge
        String sRole = GeneralUtility.getLoggedInUserSelectedRole();
        Map<String, Object> errorMap    = new Map<String, Object>();
        List<RE_MyPlanWrapper> lstobjWrapper = new List<RE_MyPlanWrapper>();
        Set<Id> setLocationResourcesIds = new Set<Id>();
        Set<Id> setResourceIdsData = new Set<Id>();
        Set<Id> setLocationIdsData = new Set<Id>();
        Contact objContact = new Contact();
        Map<String,String> mapRecommdQueryParameters = new Map<String,String>();
        
        try{
            
            system.debug('@@ sRole suggested resource '+sRole);
            //  if(sProfileName == RE_GlobalConstants.strCitizenProfileName){
            if(sRole == RE_GlobalConstants.strCitizenAppRole){
                // if profile is citizen dont allow to pass any other contact id
                contactId = GeneralUtility.getLoggedInUserContactId();
            }else{
                contactId = (String.isBlank(strContactId)) ? GeneralUtility.getLoggedInUserContactId() : strContactId;
            }
            List<User> lstUser = new List<User>();
            if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible()) {
                lstUser = [SELECT Id FROM User WHERE ContactId =:contactId AND ContactId != null];
            }
            system.debug('@@ lstUser '+lstUser);
            
            
            Id loggedinUserId = !lstUser.isEmpty() ? lstUser[0].Id : UserInfo.getUserId();
            system.debug('@@ loggedinUserId '+loggedinUserId);
           
            List<ReferralRecommendation__c> objRecommd =  new List<ReferralRecommendation__c>();
             if (Schema.sObjectType.Contact.fields.ContactGeoLocation__c.isAccessible()){
                objContact = [Select Id,mailingpostalcode,ContactGeoLocation__c FROM Contact WHERE Id=:contactId AND Id != null Limit 1];
            }
            system.debug('@@ objContact '+objContact);
            objRecommd = RE_SharingByPassCtrl.RequestRecommendations(loggedinUserId);
            system.debug('@@objRecommd '+objRecommd);
            Map<Id,ReferralRecommendation__c> mapData = new Map<Id,ReferralRecommendation__c>();
            for(ReferralRecommendation__c refRecommd : objRecommd  ){
                setLocationResourcesIds.add(refRecommd.LocationResource__c);
                mapData.put(refRecommd.LocationResource__c,refRecommd);
            } 
            for(LocationResource__c locResourceRec : RE_SharingByPassCtrl.getResourcesRecommendations(setLocationResourcesIds)){
                setResourceIdsData.add(locResourceRec.Resource__c); 
                setLocationIdsData.add(locResourceRec.Location__c);
            }
            system.debug('@@setResourceIdsData '+setResourceIdsData);
            system.debug('@@setLocationIdsData '+setLocationIdsData);
            List<LocationResource__c> lstLocationResourceContact = RE_MyPlanHelper.getLocationResources(setResourceIdsData,setLocationIdsData);
            system.debug('@@lstLocationResourceContact '+lstLocationResourceContact);
            
            Map<Id,  Map<String, List<String>>> mapOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIdsData,lstLocationResourceContact);
            for(LocationResource__c resLoc : RE_SharingByPassCtrl.lstLocationResource(setLocationResourcesIds)){
                
                RE_MyPlanWrapper objWrapper = new RE_MyPlanWrapper();
                RE_MyPlanWrapper.Referral objRef = new RE_MyPlanWrapper.Referral();
                RE_MyPlanWrapper.Resource objResource = new RE_MyPlanWrapper.Resource();
                RE_MyPlanWrapper.Account objAccount = new RE_MyPlanWrapper.Account();
                RE_MyPlanWrapper.Location objLocation = new RE_MyPlanWrapper.Location();
                RE_MyPlanWrapper.Contact objCon = new RE_MyPlanWrapper.Contact();
                
                objWrapper.sLocResourceId = resLoc.Id;
                objWrapper.sLocationResourceNotes=resLoc.Notes__c; 
                String locResNotes = resLoc.Notes__c;
                String locNotes = resLoc.Location__r.Notes__c;
                Map<String, List<String>> mapLDayOperatingHours = mapOperatingHours.get(resLoc.Id);
                objWrapper.sOperatingHoursData = JSON.serialize(mapLDayOperatingHours);
                
                DateTime dt = System.now();
                String weekdayValue = dt.format('EEEE');
                List<String> lstOperationHours = mapLDayOperatingHours.get(weekdayValue); 
                system.debug('@@ lstOperationHours'+lstOperationHours);
                if(lstOperationHours[0] != '' && lstOperationHours[3] == 'true'){ // When time is present and it is from LR
                    objWrapper.sOperatingHoursToday =Label.today + ' ' +lstOperationHours[0]+' '+Label.to+' '+lstOperationHours[1];
                }
                else if(lstOperationHours[0] == '' && lstOperationHours[2] == 'true' && lstOperationHours[3] == 'true'){//When Time is blank and LR and 'Closed'
                    objWrapper.sOperatingHoursToday =weekdayValue + ' Closed';
                }
                else if(locResNotes != '' && locResNotes != null && lstOperationHours[3] == 'false'){//When time is blank and not Closed and 'Notes' are present
                    objWrapper.sOperatingHoursToday = locResNotes;
                }
                else if(lstOperationHours[0] != '' && lstOperationHours[3] == 'false'){// When time is present and it is from L
                    objWrapper.sOperatingHoursToday =Label.today + ' ' +lstOperationHours[0]+' '+Label.to+' '+lstOperationHours[1];
                }
                else if(lstOperationHours[0] == '' && lstOperationHours[2] == 'true' && lstOperationHours[3] == 'false'){//When Time is blank and L and 'Closed'
                    objWrapper.sOperatingHoursToday = weekdayValue + ' Closed';
                }
                else{ //When time is blank and L and not Closed and 'Notes' are present
                    objWrapper.sOperatingHoursToday = locNotes;
                }
                
                
                if(mapData.get(resLoc.Id).User__c == loggedinUserId ){
                    objRef.sDayOpened = String.valueOf(mapData.get(resLoc.Id).DaysSinceOpened__c);
                }
                
                objRef.sReferralLatLong = resLoc.Location__r.Geolocation__latitude__s+'##'+resLoc.Location__r.Geolocation__longitude__s;
                objWrapper.referral = objRef;
                
                system.debug('@@ objRef '+objRef);
                objResource.sResourceDescription=resLoc.ResourceDescription__c;
                objResource.sWhatToBring = resLoc.WhatToBring__c;
                objResource.sResourceElegibility = resLoc.EligibilityDescription__c;
                objResource.sNextStep = resLoc.NextSteps__c;
                objResource.intFees = resLoc.Fees__c;
                objResource.resourceId = resLoc.Resource__c;
                objResource.resourceOrgName = resLoc.Resource__r.Organization__r.Name;
                objResource.sResourceName = resLoc.Resource__r.Name;
                objResource.sSDOHCategory = resLoc.Resource__r.SdohDomain__c;
                objWrapper.resource = objResource;
                
                objAccount.bOrgIsClaimed = resLoc.Resource__r.Organization__r.IsClaimed__c;
                objAccount.sReferralOrgUrl = resLoc.Resource__r.Organization__r.Website;
                objAccount.sReferralOrgName = resLoc.Resource__r.Organization__r.Name;
                objAccount.sReferralOrgAddress1 = resLoc.Resource__r.Organization__r.ShippingStreet;
                objAccount.sReferralOrgCity = resLoc.Resource__r.Organization__r.ShippingCity;
                objAccount.sReferralOrgZip = resLoc.Resource__r.Organization__r.ShippingPostalCode;
                objWrapper.acc = objAccount;
                Location objLocationdata = objContact.ContactGeoLocation__c;
                
                Double dMiles = RE_MyPlanHelper.getDistance(objLocationdata, resLoc.Location__r.Geolocation__c, 'mi');
                objWrapper.dMiles = dMiles;                                 
                objWrapper.lstNotes =null;
                
                objLocation.sLocationAddress1 = resLoc.Location__r.Address1__c;
                objLocation.sLocationAddress2  = resLoc.Location__r.Address2__c;
                objLocation.sLocationCity = resLoc.Location__r.City__c;
                objLocation.sLocationState = resLoc.Location__r.State__c;
                objLocation.sLocationCountry = resLoc.Location__r.County__c;
                objLocation.sLocationZip = (resLoc.Location__r.Zip__c != null) ? String.valueOf(resLoc.Location__r.Zip__c) : '';
                objLocation.sLocationZipExt = (resLoc.Location__r.ZipExtensionCode__c != null) ? String.valueOf(resLoc.Location__r.ZipExtensionCode__c) : '';
                objLocation.sPOCEmail = String.isBlank(resLoc.Location__r.Email__c)?resLoc.Location__r.Account__r.Email__c:resLoc.Location__r.Email__c;
                objLocation.sWebsite = (resLoc.Location__r.LocationWebsite__c != null) ? resLoc.Location__r.LocationWebsite__c : resLoc.Location__r.Account__r.Website;
                objLocation.sLocationWebsite = resLoc.Location__r.LocationWebsite__c;
                objLocation.sLocation = resLoc.Location__r.Name;
                objLocation.sLocationId = resLoc.Location__c;
                objLocation.sSpcialLocationInstructions = resLoc.Location__r.SpecialLocationInstructions__c;
                if(!String.isBlank(resLoc.Phone__c)){
                    objLocation.sPOCPhone = GeneralUtility.formatphonenumber(resLoc.Phone__c); 
                }else if(!String.isBlank(resLoc.TollFree__c)){
                    objLocation.sPOCPhone = GeneralUtility.formatphonenumber(resLoc.TollFree__c); 
                }
                objWrapper.location = objLocation;
                
                objCon.sResidentId = objContact.Id;
                objCon.sContactZipCode = objContact.mailingpostalcode;
                objWrapper.con = objCon;
                
                lstobjWrapper.add(objWrapper);
                system.debug('@@ objWrapper '+objWrapper);
                system.debug('@@lstobjWrapper '+lstobjWrapper);
            }
        }catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl', 'SuggestedByMeResources', e.getMessage()+' '+e.getStackTraceString(), true);}
        
        return lstobjWrapper;
    }
    
    /********************************************************************************************
* @author       Srikanth
* @date         04/23/2020
* @methodname   showMeMore()
* @description  This method calls the MY Cart API
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse showMeMore(){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        set<Id> ResLocIds = SuggestForMeServiceCall();
        if(!ResLocIds.isEmpty()){
            mapResponse.put('draftReferralCount', RE_SharingByPassCtrl.getCountValue(null));
            bSuccess = true;            
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
   
    /********************************************************************************************
* @author       Srikanth
* @date         04/23/2020
* @methodname   showMeMore()
* @description  This method calls the MY Cart API service
* @return       set<Id> -  Retunrs LR's Ids from the external system
**********************************************************************************************/
    public static set<Id> SuggestForMeServiceCall(){
        
        
        
        RE_CartResponseWrapper wrapResponseData = new RE_CartResponseWrapper();
        set<Id> ResourceLocationIds = new Set<Id>();
        Id loggedinUserId = UserInfo.getUserId();
        set<string> setStrLocResRequest = new set<string>();
        CartSuggetsedRequestWrapper requestWrap;
        Map<String,Object> mapInputData = new Map<String,Object>();
        Set<Id> setLocationRecIds = new Set<Id>();
        List<ReferralRecommendation__c> lstRefRcm = new List<ReferralRecommendation__c>();
        List<LocationResource__c> lstLocRes = new List<LocationResource__c>();
        Id contactId = GeneralUtility.getLoggedInUserContactId();
        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('Cart_SuggestedForMe');
        
        setStrLocResRequest = RE_SharingByPassCtrl.getLocationResourceRecmds(contactId);
        requestWrap = new CartSuggetsedRequestWrapper(loggedinUserId,setStrLocResRequest);
        mapInputData.put('request',requestWrap); 
        Map<String, Object> suggestedCartResponse=RE_ServiceHandler.handleExecutionResults('GetCartService',mapInputData);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyResourceData = (suggestedCartResponse.containskey('response')) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                                
        switch on (switchCaseKeyResourceData) {
                  when SWITCH_SUCCESS { 
                    wrapResponseData = (RE_CartResponseWrapper)suggestedCartResponse.get('response');
                    
                      RE_GlobalConstants.SWITCH_CONSTANTS switchErrorData = (wrapResponseData.status!=null && (!wrapResponseData.status.isEmpty()) && wrapResponseData.status[0]== '200') ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE  ;
                    switch on (switchErrorData) {
                        when SWITCH_SUCCESS {
                            for(string str : wrapResponseData.resourceLocationID.resource_location_id){
                                ResourceLocationIds.add(Id.ValueOf(str));
                            }
                            lstLocRes = RE_SharingByPassCtrl.getResourcesRecommendations(ResourceLocationIds);
                             if(ReferralRecommendation__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.ReferralRecommendation__c.fields.Name.isAccessible() && Schema.sObjectType.ReferralRecommendation__c.fields.LocationResource__c.isAccessible() && Schema.sObjectType.ReferralRecommendation__c.fields.User__c.isAccessible()){
                                for(ReferralRecommendation__c refRecmdRec : [SELECT Id,Name,LocationResource__c,User__c FROM ReferralRecommendation__c WHERE User__c =:loggedinUserId AND User__c != null]){
                                    setLocationRecIds.add(refRecmdRec.LocationResource__c);
                                } 
                             } 
                            for(LocationResource__c locResRec : lstLocRes){
                                if(!setLocationRecIds.contains(locResRec.Id)){
                                    ReferralRecommendation__c refcmd = new ReferralRecommendation__c();
                                    refcmd.User__c = loggedinUserId;
                                    refcmd.LocationResource__c = locResRec.Id;
                                    lstRefRcm.add(refcmd);
                                }
                            }
                            if(!lstRefRcm.isEmpty()){
                                RE_SharingByPassCtrl.insertSobjects(ReferralRecommendation__c.getSObjectType(), lstRefRcm);
                            }
                        }
                        when SWITCH_FAILURE{
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,oIntEndpoints.Endpoint_URI__c,'RE_MyPlanCtrl',
                            'SuggestForMeServiceCall','Callout to Suggested CART is failed',
                            'POST',JSON.serialize(mapInputData.get('request')),
                            (wrapResponseData!=null && wrapResponseData.status!=null && !wrapResponseData.status.isEmpty())?
                            wrapResponseData.status[0]:(suggestedCartResponse.containsKey('httpstatus')?String.valueof(suggestedCartResponse.get('httpstatus')):''),
                            suggestedCartResponse.containsKey('jsonresponse')?String.valueof(suggestedCartResponse.get('jsonresponse')):'',0,true);
                        }
                    }
                  }
                  when SWITCH_FAILURE{
                  		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,oIntEndpoints.Endpoint_URI__c,'RE_MyPlanCtrl','SuggestForMeServiceCall','Callout to Suggested CART is failed','POST',JSON.serialize(mapInputData.get('request')),String.valueOf(suggestedCartResponse.get('status')),String.valueOf(suggestedCartResponse.get('error')),0,true);
                  }
        }
         
        
        return ResourceLocationIds;
    }
    
    
     /********************************************************************************************
* @author       Srikanth
* @date         04/24/2020
* @methodname   suggestedToConnect()
* @description  This methods is used to get data from UI and create referral and delete the associated CART Recommendations
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse suggestedToConnect(string strJson, string strValueHandler,  Boolean bAchConsentAgreed){
        
        
        
        GeneralUtility.isAuthenticatedUser();
        //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
        String sValueHandler = String.isNotBlank(strValueHandler)?String.escapeSingleQuotes(strValueHandler):strValueHandler;
        Boolean bSuccess = false; 
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        RE_MyPlanWrapper wrapper;
        List<ReferralRecommendation__c> lstRefRecmds = new List<ReferralRecommendation__c>();
        
        try{   
             if(bAchConsentAgreed){
                Account objAccount = new Account();
                objAccount.Id = GeneralUtility.getLoggedInUserAccountId();
                objAccount.HasOptedOutOfAccount__c = false;
                RE_SharingByPassCtrl.updateSobject(objAccount.getSobjectType(),objAccount);
            } 
            Id loggedinUserId = UserInfo.getUserId();
            Map<String, Object> mapRsrce =  (Map<String, Object>)JSON.deserializeUntyped(strJson);
            //wrapper = (RE_MyPlanWrapper)JSON.deserializeStrict(strJson, RE_MyPlanWrapper.class);//(RE_MyPlanWrapper) JSON.deserialize(strJson, RE_MyPlanWrapper.class);
            LocationResource__c locres = RE_SharingByPassCtrl.createReferralForSuggestedThanks(mapRsrce,sValueHandler);
            Id locId = locres.Id;
            
            try{
                String sFieldsToQueryOnRecmd = RE_DataBaseQueryFields.sFieldsToQueryOnRecmd; // 'LocationResource__c,User__c';
                String sWhereClauseOnRecmd = RE_DataBaseQueryFields.sWhereClauseOnRecmd;  //'LocationResource__c=:locId AND User__c=:loggedinUserId';
                Map<String,String> mapRecommdQueryParameters = new Map<String,String>();
                mapRecommdQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnRecmd);
                Map<Boolean,String> mapRecommdQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('ReferralRecommendation__c', sFieldsToQueryOnRecmd, mapRecommdQueryParameters);
                String switchRecommdKey = (mapRecommdQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
                switch on (switchRecommdKey) {
                    when 'success' { 
                        String sRecommdQuery =  mapRecommdQueryResponse.get(true);
                        lstRefRecmds = Database.query(sRecommdQuery); 
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl','suggestedToConnect', RE_GlobalConstants.FLS_ERROR + '' + mapRecommdQueryResponse.get(false), true);
                    }
                }
            } catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl', 'suggestedToConnect', e.getMessage(), true);}
            
            //lstRefRecmds = [Select Id,LocationResource__c,User__c FROM ReferralRecommendation__c WHERE LocationResource__c=:locres.Id AND User__c=:loggedinUserId];
            if(!lstRefRecmds.isEmpty()){
               RE_SharingByPassCtrl.deleteRecommendations(lstRefRecmds);
            }  
            mapResponse.put('draftReferralCount', RE_SharingByPassCtrl.getCountValue(null));
            bSuccess = true;
        }catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl','suggestedToConnect', e.getMessage(), true);
            throw e;
        }
        
       
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/07/2019
    * @methodname   removeFromMyPlans()
    * @description  This methods is used to remove my plan from the list
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse removeFromMyPlans(String strReferralId){
        
        String sReferralId = String.escapeSingleQuotes(strReferralId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try{
            Referral__c objReferral =  new Referral__c();
            String sFieldsToQueryOnReferral = RE_DataBaseQueryFields.sFieldsToQueryOnReferral;
            String sWhereClauseOnReferral = RE_DataBaseQueryFields.sWhereClauseIdInRecordId;
            Map<String,String> mapReferralQueryParameters = new Map<String,String>();
            mapReferralQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReferral);
            Map<Boolean,String> mapReferralQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Referral__c', sFieldsToQueryOnReferral, mapReferralQueryParameters);
            String switchReferralKey = (mapReferralQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (switchReferralKey) {
                when 'success' {
                    String sReferralQuery =  mapReferralQueryResponse.get(true);
                    objreferral = RE_SharingByPassCtrl.getReferralRecords(sReferralQuery, sReferralId); 
                    objReferral.Status__c = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
                    objReferral.Outcome__c = RE_GlobalConstants.REFERRAL_OUTCOME_STATUS;
                    objReferral.OutcomeReason__c = RE_GlobalConstants.REFERRAL_CANCELLED_BY_CLIENT;
                    objReferral.UserComplete__c =  true;
                    objReferral.DateClosed__c=date.today(); 
                    RE_SharingByPassCtrl.updateReferralRecords(objReferral);
                    mapResponse.put('success', objReferral);
                    mapResponse.put('draftReferralCount', getDraftReferralCount());
                    bSuccess = true;
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl','getMyPlan', RE_GlobalConstants.FLS_ERROR + '' + mapReferralQueryResponse.get(false), true);
                }
            }
        } catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl', 'getMyPlans', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/13/2019
    * @methodname   shareMyPlanDetails()
    * @description  This methods is used to share the Completed and Inprogress resource details to resident 
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse shareMyPlanDetails(String ContactDetails){
        GeneralUtility.isAuthenticatedUser();        
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        String sTemplateBody = RE_GlobalConstants.sEmptyString;
        String sInProgResourceDetails =  RE_GlobalConstants.sEmptyString;
        String sCompletedResourceDetails =  RE_GlobalConstants.sEmptyString;
        try{
            RE_MyPlanCtrl.processRecordsforEmail(ContactDetails); // Future method to send out emails after pagination in My plan
            bSuccess = true;            
        } catch (Exception e) { errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_MyPlanCtrl.class.getName(), 'shareMyPlanDetails', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
     /********************************************************************************************
    * @author       Pankaj
    * @date         07/30/2019
    * @methodname   connectDraftReferrals()
    * @description  This methods is used to connect a draft referral to Organization
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse connectDraftReferrals(String strReferralId, Boolean bConsentAgreed){
        GeneralUtility.isAuthenticatedUser();
        String sReferralId = String.escapeSingleQuotes(strReferralId);
        
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Boolean bFlag = false;
        try{
            RE_CreateLightningServerResponse reLtngResponse = RE_ReferralDetailsCtrl.getReferralDetails(sReferralId);
            Referral__c objReferral = (Referral__c)JSON.deserialize(String.valueOf(reLtngResponse.objectData.get('objReferral')), Referral__c.Class);            
            Boolean bAccountIsClaimed = objReferral.ReferredAccountID__r.IsClaimed__c;
            String sAccountStatus = objReferral.ReferredAccountID__r.Status__c;
            Referral__c updateReferral = new Referral__c();
            updateReferral.Id = objReferral.Id;

            if(bAccountIsClaimed && sAccountStatus == RE_GlobalConstants.sAccountStatus){
                updateReferral.Status__c = RE_GlobalConstants.STATUS_NEW;
                bFlag = true;
            }else if(!bAccountIsClaimed){
                updateReferral.Status__c = RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
                bFlag = true;
            }
            if(bFlag){ 
                RE_DataAccessChecker.updateObject(Referral__c.sObjectType, updateReferral);
                mapResponse.put('resReferralStatus', updateReferral.Status__c);
            }
            
            if(bConsentAgreed){
                Account objAccount = new Account();
                objAccount.Id = GeneralUtility.getLoggedInUserAccountId();
                objAccount.HasOptedOutOfAccount__c = false;
                RE_SharingByPassCtrl.updateSobject(objAccount.getSobjectType(),objAccount);
            }

            mapResponse.put('draftReferralCount', getDraftReferralCount());
            mapResponse.put('success', objReferral);
            bSuccess = true;
            
        } catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl', 'connectDraftReferrals', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }

    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         07/30/2019
    * @methodname   getOptOutInfoSharingDetails()
    * @description  This methods is used to get OptOutInfoSharing Information from Account
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getOptOutInfoSharingDetails(){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try{
            mapResponse.put('OptOutInfoSharing', GeneralUtility.getOptOutInfoSharingDetails());
            bSuccess = true;
        }catch(Exception e) {bSuccess = false;errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl','getOptOutInfoSharingDetails', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }

    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         09/04/2019
    * @methodname   getContentNotesAccessFromWrapper()
    * @description  This methods is used to get Notes Access From Wrapper
    * @return       Map<String,Boolean>
    **********************************************************************************************/
    public static Map<String,Boolean> getContentNotesAccessFromWrapper(Map<String, List<RE_NotesCtrl.NotesWrapper>> mapRefContentNotes){
        List<ContentNote> lstContentNotes = new List<ContentNote>();
        Map<String, String> mapRefVsContentNotes = new Map<String,String>(); 
        List<ContentNote> lstFirstContentNotes = new List<ContentNote>();
        Set<Id> setContentIds = new Set<Id>();
        Map<String,Boolean> mapReferralVsNotesAccess = new Map<String,Boolean>();

        try{
            for(String sRefCNote : mapRefContentNotes.keySet()){
                List<RE_NotesCtrl.NotesWrapper> lstNotesWrapper = mapRefContentNotes.get(sRefCNote);
                RE_NotesCtrl.NotesWrapper rFirstNoteWrapper = lstNotesWrapper[0];
                setContentIds.add(rFirstNoteWrapper.NoteId); 
                mapRefVsContentNotes.put(sRefCNote, rFirstNoteWrapper.NoteId);
            }

            String sFieldsApiName = RE_DataBaseQueryFields.sContentNotesFieldsApiName;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnCVForNotesMyPlan;
            Map<String, String> mapQueryParametersForContentNote = new Map<String, String>();
            mapQueryParametersForContentNote.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentNote', sFieldsApiName, mapQueryParametersForContentNote);
            lstFirstContentNotes = Database.query(sQuery);
            
            Map<String,Boolean> mapCNoteAccess = RE_NotesHelper.getNotesPublicOrPrivateFromContentVersion(lstFirstContentNotes);
            for(String sRefCNte : mapRefContentNotes.keySet()){
                mapReferralVsNotesAccess.put(sRefCNte, mapCNoteAccess.get(mapRefVsContentNotes.get(sRefCNte)));
            }
        }catch(Exception e) {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl','getContentNotesAccessFromWrapper', e.getMessage(), true);}
        return mapReferralVsNotesAccess;
    }

    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         09/04/2019
    * @methodname   getDraftReferralCount()
    * @description  This methods is used to get draft referral count
    * @return       Integer
    **********************************************************************************************/
    public static Integer getDraftReferralCount(){
        Integer iDraftCount = 0;
        if(UserInfo.getUserType() != 'Guest'){
            try{
                Id contactId = GeneralUtility.getLoggedInUserContactId();
                List<Referral__c> lstReferrals = RE_SharingByPassCtrl.getReferralDetails(contactId);
                for(Referral__c referral:lstReferrals){
                    //if(referral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_DRAFT){
                        //iDraftCount++;
                    //}
                    iDraftCount = (referral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_DRAFT)?iDraftCount++:iDraftCount;
                    }
            } catch (Exception e) {LOG_LogMessageUtility.logMessage(e, 'RE_MyPlanCtrl', 'getDraftReferralCount', e.getMessage() , true);} }
        return iDraftCount;
    }

    
    /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         09/04/2019
    * @methodname   createFavorite()
    * @param		(String sLocationResId)
    * @description  This methods is used to create favorite object
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse createFavorite(String strLocationResId){
        GeneralUtility.isAuthenticatedUser();
        String sLocationResId = String.escapeSingleQuotes(strLocationResId);
        return RE_SharingByPassCtrl.createFavorite(sLocationResId);
     
    }
    /********************************************************************************************
    * @author       Megha Mittal
    * @date         01/07/2020
    * @methodname   getMyPlansCount()
    * @description  This methods is used to get the count of Myplan records
    * @return       RE_CreateLightningServerResponse
    ********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getMyPlansCount(String strContactId){        
        GeneralUtility.isAuthenticatedUser();
        String sContactId = String.escapeSingleQuotes(strContactId);        
        Boolean bSuccess = false;        
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Integer draftWrapperCount=0;
        Integer completedWrapperCount=0;
        Integer inProgressedWrapperCount=0;
        try{
            //RE_Release 1.1 – Security Fixes - Payal Dubela
            Id contactId;
           // String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
            // Added By Kojashree --- SSP Merge
            String sRole = GeneralUtility.getLoggedInUserSelectedRole();
            //   if(sProfileName == 'RE Citizen Profile'){
            if(sRole == RE_GlobalConstants.strCitizenAppRole){
                contactId = GeneralUtility.getLoggedInUserContactId();
            }else{
                contactId = (String.isBlank(sContactId)) ? GeneralUtility.getLoggedInUserContactId() : sContactId;
            }
            //  List<Referral__c> lstReferral = RE_SharingByPassCtrl.getReferralDetails(contactId); changed as per the performance fix for removing extra vaiables
            List<Referral__c> lstReferral = RE_SharingByPassCtrl.getReferralcountforPlan(contactId); 
            for(Referral__c objReferral : lstReferral){
                if(objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_DRAFT){
                    draftWrapperCount+=1;
                }else if( (objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_CLOSED || objReferral.UserComplete__c == true) && objReferral.Outcome__c != RE_GlobalConstants.REFERRAL_OUTCOME_STATUS){
                    completedWrapperCount+=1;
                }else if(objReferral.Status__c != RE_GlobalConstants.STATUS_CLOSING_REFERRAL && objReferral.Outcome__c != RE_GlobalConstants.REFERRAL_OUTCOME_STATUS){
                    inProgressedWrapperCount+=1;
                }
            }                        
            mapResponse.put('draftWrapperCount', RE_SharingByPassCtrl.getCountValue(sContactId));
            mapResponse.put('completedWrapperCount', completedWrapperCount);
            mapResponse.put('inProgressedWrapperCount', inProgressedWrapperCount);            
            bSuccess = true;
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl', 'getMyPlans', e.getMessage()+' '+e.getStackTraceString(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Megha Mittal
    * @date         01/07/2020
    * @methodname   processRecordsforEmail()
    * @description  This methods is used to send the emails(Future Method)
    * @return       void
    ********************************************************************************************/
    @future
    public static void processRecordsforEmail(String ContactDetails)
    {
        //RE_Release 1.1 – Security Fixes - Payal Dubela  
        String sContactId = String.escapeSingleQuotes(ContactDetails);  
        Id contactId;
        String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
        // Added By Kojashree -- SSP Merge
        String sRole = GeneralUtility.getLoggedInUserSelectedRole();
       if(sRole == RE_GlobalConstants.strCitizenAppRole){
            contactId = GeneralUtility.getLoggedInUserContactId();
        }else{
            contactId = (String.isBlank(sContactId)) ? GeneralUtility.getLoggedInUserContactId() : sContactId;
        }
        Contact conobj = new Contact();
        //Fix for Sit error logs
        if(contactId!=null){
            // Updated By Kojashree -- SSP Merge
             conobj= RE_SharingByPassCtrl.getCitizenContactDetails(contactId, sRole);
            
        }
                       
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        String sTemplateBody = RE_GlobalConstants.sEmptyString;
        String sInProgResourceDetails =  RE_GlobalConstants.sEmptyString;
        String sCompletedResourceDetails =  RE_GlobalConstants.sEmptyString;
        List<RE_MyPlanWrapper.EmailWrapper> lstCompletedResources =new list<RE_MyPlanWrapper.EmailWrapper>();
        List<RE_MyPlanWrapper.EmailWrapper> lstInProgressResources = new List<RE_MyPlanWrapper.EmailWrapper>();
        try{
            Map<String,List<RE_MyPlanWrapper.EmailWrapper>> responserec = RE_MyPlanCtrl.getMyPlansforemail(conobj.Id);            
            lstInProgressResources = responserec.get('myresource');
            lstCompletedResources = responserec.get('completed');
            if(EmailSetting__c.getInstance('Share My Plan').Is_on__c && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c){
                sTemplateBody = Label.RE_Hello+',<p>'+String.format(Label.RE_ShareMyPlan_Email_Body_Line1,new List<String>{conobj.FirstName,conobj.LastName,System.today().format()});
                sTemplateBody += '<p><b><u>'+Label.RE_In_Progress_Resource+'</u></b>';
                
                if(lstInProgressResources.size()==0){
                    sInProgResourceDetails = RE_GlobalConstants.sBRTag+String.format(Label.RE_NoResourcesAvailable,new List<String>{RE_GlobalConstants.STATUS_INPROGRESS});   
                    sTemplateBody += sInProgResourceDetails;
                }
                else{
                    String sInProgResources = RE_MyPlanHelper.getShareMyPlanEmailTemplateBody(lstInProgressResources);
                    sTemplateBody += sInProgResources;
                }
                sTemplateBody+='<p><b><u>'+Label.RE_Completed_Resource+'</u></b>';
                if(lstCompletedResources.size()==0){
                    sCompletedResourceDetails = RE_GlobalConstants.sBRTag+String.format(Label.RE_NoResourcesAvailable,new List<String>{RE_GlobalConstants.STATUS_COMPLETED}); 
                    sTemplateBody += sCompletedResourceDetails;
                }
                else{
                    String sCompletedResources = RE_MyPlanHelper.getShareMyPlanEmailTemplateBody(lstCompletedResources);
                    sTemplateBody+=sCompletedResources;
                }
                sTemplateBody += Label.RE_doNotReplyMessage;
                sTemplateBody += '<br>'+Label.RE_SecurityMessage; 
                if(sTemplateBody.contains('null')){
                    sTemplateBody = sTemplateBody.replace('null','');
                }
                RE_MyPlanCtrl.createCommunicationHubRecord(conobj, sTemplateBody);//PMD Issues - Anuj - 05/06/2020
                bSuccess = true;
            }
        } catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_MyPlanCtrl.class.getName(), 'shareMyPlanDetails', e.getMessage(), true);}        
    }
    
    /********************************************************************************************
    * @author       Anuj Vashistha
    * @date         05/06/2020
    * @methodname   createCommunicationHubRecord()
    * @description  This methods is used to create communication nub record for email
    * @return       void
    ********************************************************************************************/
    public static void createCommunicationHubRecord(Contact conobj, String sTemplateBody){
        List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
                CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
                objCommunicationNub.EmailSubject__c = String.format(Label.RE_ShareMyPlan_Email_Subject, new List<String>{ conobj.FirstName +' '+ conobj.LastName});
                objCommunicationNub.TemplateBody__c = sTemplateBody;
                objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                objCommunicationNub.TemplateName__c= Label.RE_EmailTemplateNameShareMyPlan;
                objCommunicationNub.ToEmail__c= conobj.Email;
                //Added By Kojashree
        	   objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                lstCommunicationNubInsert.add(objCommunicationNub);
        if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){
            //if(RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){                
                        RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                    }
                    else{
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_MyPlanCtrl.class.getName(), 'shareMyPlanDetails','No Access on CommunicationLog__c Object',true);
                    }
        //}
    }
    
    /********************************************************************************************
* @author       Pankaj Mohanta
* @date         06/07/2019
* @methodname   getMyPlans()
* @description  This methods is used to get the list of MyPlans
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static Map<String,List<RE_MyPlanWrapper.EmailWrapper>> getMyPlansforemail(String strContactId){        
        String sContactId = String.escapeSingleQuotes(strContactId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String,List<RE_MyPlanWrapper.EmailWrapper>> mapResponse= new Map<String,List<RE_MyPlanWrapper.EmailWrapper>>();
        try{
            List<RE_MyPlanWrapper.EmailWrapper> lstInProgressWrapper = new List<RE_MyPlanWrapper.EmailWrapper>();
            List<RE_MyPlanWrapper.EmailWrapper> lstCompletedWrapper = new List<RE_MyPlanWrapper.EmailWrapper>();
            List<RE_MyPlanWrapper.EmailWrapper> lstDraftWrapper = new List<RE_MyPlanWrapper.EmailWrapper>();
            Map<Id, Double> mapReferralDistance = new Map<Id, Double>();
            Map<Id, String> mapLatLong = new Map<Id, String>();
            Set<Id> lstLocationIds = new Set<Id>();
            Set<Id> setReferralIds = new Set<Id>();
            Set<Id> setResourceIds = new Set<Id>();
           // Chnaged By Kojashree -- SSP Merge
            String sRole = GeneralUtility.getLoggedInUserSelectedRole();
            Id contactId = (String.isBlank(sContactId)) ? GeneralUtility.getLoggedInUserContactId() : sContactId;
            Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(contactId, sRole);
            Location objLocationdata = objContact.ContactGeoLocation__c;                        
            List<Referral__c> lstReferral = RE_SharingByPassCtrl.getReferralDetails(contactId);
            for(Referral__c objReferral : lstReferral){
                Double dMiles = RE_MyPlanHelper.getDistance(objLocationdata, objReferral.Location__r.Geolocation__c, 'mi');
                mapReferralDistance.put(objReferral.Id, dMiles); 
                String sLatLong = objReferral.Location__r.Geolocation__latitude__s+'##'+objReferral.Location__r.Geolocation__longitude__s;
                mapLatLong.put(objReferral.Id, sLatLong);
                setReferralIds.add(objReferral.Id);
                lstLocationIds.add(objReferral.Location__c);
                setResourceIds.add(objReferral.Resource__c);
            }
            // check if location and referral is present for the user
            String sSwitchKey = (lstLocationIds != null && !lstLocationIds.isEmpty() && setReferralIds != null && !setReferralIds.isEmpty()) ? 'success' : 'failure';
            switch on (sSwitchKey) {
                when 'success' {
                    List<LocationResource__c> lstLocationResourceContact = RE_MyPlanHelper.getLocationResources(setResourceIds,lstLocationIds);
                    //RE_Release 1.1 – Defect 359141- Payal Dubela– Removing Favorite Functionality from My Plan
                    //Map<String, Favorite__c> mapFavorites = RE_SharingByPassCtrl.getMyFavorite(setResourceIds,lstLocationIds);
                    Map<Id,  Map<String, List<String>>> mapLocationOperationOperatingHours = GeneralUtility.getLocationOperationHoursList(lstLocationIds,lstLocationResourceContact);
                    Map<Id,  Map<String, String>> mapOperatingHours = RE_MyPlanHelper.getLocationOperatingHours(lstLocationIds);
                    for(Referral__c objReferral : lstReferral){
                        boolean boolResourceLocationHoursOperation = false;
                        RE_MyPlanWrapper.EmailWrapper objWrapper = new RE_MyPlanWrapper.EmailWrapper();
                        objWrapper.sResourceName = objReferral.Resource__r.Name;
                        objWrapper.resourceId =  objReferral.Resource__c;
                        objWrapper.sReferralOrgName =  objReferral.ReferredAccountID__r.Name;
                        //objWrapper.sReferralOrgUrl =  objReferral.ReferredAccountID__r.Website;
                        objWrapper.sLocationAddress1 = objReferral.Location__r.Address1__c;
                        objWrapper.sLocationAddress2  = objReferral.Location__r.Address2__c;
                        objWrapper.sLocationCity = objReferral.Location__r.City__c;
                        objWrapper.sLocationState = objReferral.Location__r.State__c;
                        objWrapper.sLocationCountry = objReferral.Location__r.County__c;
                        objWrapper.sLocationZip = (objReferral.Location__r.Zip__c != null) ? String.valueOf(objReferral.Location__r.Zip__c) : '';
                        objWrapper.sLocationZipExt = (objReferral.Location__r.ZipExtensionCode__c != null) ? String.valueOf(objReferral.Location__r.ZipExtensionCode__c) : '';
                        objWrapper.sPOCEmail = String.isBlank(objReferral.Location__r.Email__c)?objReferral.Location__r.Account__r.Email__c:objReferral.Location__r.Email__c; 
                        
                        
                    /* ::::::::::::added by Suresh Starts::::::::::::::*/
                    if(String.isNotBlank(objReferral.Location__r.LocationWebsite__c)){
                        objWrapper.sReferralOrgUrl = objReferral.Location__r.LocationWebsite__c;
                    }
                    else if(String.isNotBlank(objReferral.ReferredAccountID__r.Website)){
                        objWrapper.sReferralOrgUrl = objReferral.ReferredAccountID__r.Website;
                    }
                    for(LocationResource__c objLocResource: lstLocationResourceContact){
                        if(objReferral.Resource__c == objLocResource.Resource__c && objReferral.Location__c == objLocResource.Location__c){
                            String locResNotes = objLocResource.Notes__c;
                            String locNotes = objLocResource.Location__r.Notes__c;
                            if(!String.isBlank(objLocResource.Phone__c)){
                                objWrapper.sPOCPhone = GeneralUtility.formatphonenumber(objLocResource.Phone__c); 
                            }else if(!String.isBlank(objLocResource.TollFree__c)){
                                objWrapper.sPOCPhone = GeneralUtility.formatphonenumber(objLocResource.TollFree__c); 
                            }
                            Map<String, List<String>> mapLDayOperatingHours = mapLocationOperationOperatingHours.get(objLocResource.Id);
                            objWrapper.sOperatingHoursData = JSON.serialize(mapLDayOperatingHours); 
                            //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue - Start
                            DateTime dt = DateTime.now();
                            String weekdayValue = dt.format('EEEE');
                            List<String> lstOperationHours = mapLDayOperatingHours.get(weekdayValue); 
                            if(lstOperationHours[0] != '' && lstOperationHours[3] == 'true'){ // When time is present and it is from LR
                                objWrapper.sOperatingHoursToday =Label.today + ' ' +lstOperationHours[0]+' '+Label.to+' '+lstOperationHours[1];
                            }
                            else if(lstOperationHours[0] == '' && lstOperationHours[2] == 'true' && lstOperationHours[3] == 'true'){//When Time is blank and LR and 'Closed'
                                objWrapper.sOperatingHoursToday =weekdayValue + ' Closed';
                            }
                            else if(locResNotes != '' && locResNotes != null && lstOperationHours[3] == 'false'){//When time is blank and not Closed and 'Notes' are present
                                    objWrapper.sOperatingHoursToday = locResNotes;
                            }
                            else if(lstOperationHours[0] != '' && lstOperationHours[3] == 'false'){// When time is present and it is from L
                                objWrapper.sOperatingHoursToday =Label.today + ' ' +lstOperationHours[0]+' '+Label.to+' '+lstOperationHours[1];
                            }
                            else if(lstOperationHours[0] == '' && lstOperationHours[2] == 'true' && lstOperationHours[3] == 'false'){//When Time is blank and L and 'Closed'
                                objWrapper.sOperatingHoursToday = weekdayValue + ' Closed';
                            }
                            else{ //When time is blank and L and not Closed and 'Notes' are present
                                    objWrapper.sOperatingHoursToday = locNotes;
                            }
                            //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue - END
                        }
                        
                    }
                    /*::::::::::::::::::::ends::::::::::::::::::::::::::*/
                  
                    if(objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_DRAFT){
                        lstDraftWrapper.add(objWrapper);
                    }else if( (objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_CLOSED || objReferral.UserComplete__c == true) && objReferral.Outcome__c != RE_GlobalConstants.REFERRAL_OUTCOME_STATUS){
                        lstCompletedWrapper.add(objWrapper);
                    }else if(objReferral.Status__c != RE_GlobalConstants.STATUS_CLOSING_REFERRAL && objReferral.Outcome__c != RE_GlobalConstants.REFERRAL_OUTCOME_STATUS){
                        lstInProgressWrapper.add(objWrapper);
                    }
                }
            }
        }            
        mapResponse.put('myresource', lstInProgressWrapper);
        mapResponse.put('completed', lstCompletedWrapper);
        bSuccess = true;
    }catch(Exception e){ errorMap.put('error', e.getMessage()); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanCtrl', 'getMyPlans', e.getMessage()+' '+e.getStackTraceString(), true);}
    return mapResponse;
}
    
    
    public PageReference printPlans() {
         // Added By Kojashree -- SSP Merge
        String sRole = GeneralUtility.getLoggedInUserSelectedRole();
      
        if(sRole == RE_GlobalConstants.strCitizenAppRole){
            clientId = GeneralUtility.getLoggedInUserContactId();
        }else{
            clientId = System.currentPageReference().getParameters().get('clientId');
        }
        String conId = (clientId != null && clientId != '') ? clientId : GeneralUtility.getLoggedInUserContactId();
        this.partnerName = (clientId != null && clientId != '') ? GeneralUtility.getContactNameFromId(clientId) : GeneralUtility.getLoggedInUserContactName();
        // Updated By Kojashree -- SSP Merge
         if(sRole == RE_GlobalConstants.strCitizenAppRole){
            Map<String,Object> mapMyPlansInProg = getMyPlans(conId,'MyResources','2000','0').objectData;
            for (String key : mapMyPlansInProg.keySet()) {
                this.resultInProgressResources = (List<RE_MyPlanWrapper>)mapMyPlansInProg.get('myresource');
            }
            
            Map<String,Object> mapMyPlansCompleted = getMyPlans(conId,'Completed','2000','0').objectData;
            for (String key : mapMyPlansCompleted.keySet()) {
                this.resultCompletedResources = (List<RE_MyPlanWrapper>)mapMyPlansCompleted.get('completed');
            }
        }else{
            //SSP Merge Fixes -- Kojashree Kakariya
            if(GeneralUtility.checkConsentForClient(conId).isEmpty() && sRole != RE_GlobalConstants.CASE_WORKER && sRole != RE_GlobalConstants.CASE_WORKER_SUPERVISOR){
                PageReference retURL = Page.Unauthorized;
                retURL.setRedirect(true);
                return retURL;
                
            }else{
                Map<String,Object> mapMyPlansInProg = getMyPlans(conId,'MyResources','2000','0').objectData;
                for (String key : mapMyPlansInProg.keySet()) {
                    this.resultInProgressResources = (List<RE_MyPlanWrapper>)mapMyPlansInProg.get('myresource');
                }
                
                Map<String,Object> mapMyPlansCompleted = getMyPlans(conId,'Completed','2000','0').objectData;
                for (String key : mapMyPlansCompleted.keySet()) {
                    this.resultCompletedResources = (List<RE_MyPlanWrapper>)mapMyPlansCompleted.get('completed');
                }
            }
            
        }
        
        return null;        
    }

     /*********************************************************************************************************
* @author       Srikanth
* @date         04/23/2020
* @wrapperclass CartSuggetsedRequestWrapper()
* @description  Thiclass is used for Suggest for My Cart API Call
/***********************************************************************************************************/
    
    public class CartSuggetsedRequestWrapper{
        
        public String user_id;
        public Set<string> prev_resourceLocationIDs;
        
        public CartSuggetsedRequestWrapper(String user_id,Set<String> prev_resourceLocationIDs){
          this.user_id=user_id;
          this.prev_resourceLocationIDs=prev_resourceLocationIDs;
        } 
    }
}