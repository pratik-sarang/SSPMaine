/**
* Class Name    : RE_RelatedResourcesCtrl
* Owner         : DELOITTE
* Created Date  : 17/07/2019
* Description   : 
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     --------------------------------------------------------------------
*  04/06/2019  Suyash       Initial Version
*  
**/
public with sharing class RE_RelatedResourcesCtrl {
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   fetchRelatedResources
    * @description  This methods is used to fetch related resources based on resourceid and geo co-ordinates
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/ 
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchRelatedResources(String strResourceId,  List<Double> geoLocation){
        //RE_Release 1.2 – Requirment 361795 & 361782 - Payal Dubela(04/23/2020) -- Related Services (Similar Resources) & Frequently Paired Together -- Start
        String sResourceId = String.escapeSingleQuotes(strResourceId);
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        List<RE_Resource_Taxonomy__c> objLstJunctionRecs = new List<RE_Resource_Taxonomy__c>();
        Map<String,Object> mapInputData = new Map<String,Object>();
        RelatedResourceRequestWrapper requestwrap;
        Set<String> locationResourceIds= new Set<String>();
        List<LocationResource__c> locationResourcelst=new List<LocationResource__c>();
        Map<Id,LocationResource__c> mapLocationResources= new Map<Id,LocationResource__c>();
        Map<Id,Double> mapResourceIdVsMinDis = new Map<Id,Double>();
        Set<String> resourceIds=new Set<String>();
        Map<String,Boolean> mapResourceIdVsDisableConnect = new Map<String,Boolean>(); 
        Map<String,Resource__c> mapResources = new Map<String,Resource__c>();
        List<RelatedResourcesWrapper> complementryReswrapList= new List<RelatedResourcesWrapper>();
        List<RelatedResourcesWrapper> similarReswrapList= new List<RelatedResourcesWrapper>();
        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('RelatedResources');
        String sEndpoint = oIntEndpoints.Endpoint_URI__c;
        String sHttpMethod = oIntEndpoints.Http_Method_Type__c;

        try{

            //Fetch Taxonomy from Resource Taxonomy
            objLstJunctionRecs = RE_SharingByPassCtrl.fetchResourceTaxnomies(sResourceId);
            
            System.Location zipLocation;
            if(geoLocation!=null && geoLocation.size()>0){
                zipLocation = System.Location.newInstance(geoLocation[0], geoLocation[1]);
            }
            //Force Reviewer Changes - Payal Dubela - 08/28
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyJuncRes = (!objLstJunctionRecs.isEmpty() && objLstJunctionRecs.size()>0 && zipLocation!=null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyJuncRes) {
            when SWITCH_SUCCESS {  
                //USe Logged in user id for all other users and for guest use '999999999999999999'
                String userId=UserInfo.getUserType() != 'Guest'?UserInfo.getUserId():Label.Guest_UserId;
                //Request Wrapper
                requestwrap= new RelatedResourceRequestWrapper(userId,String.valueof(zipLocation.getLatitude())
                                                               ,String.valueof(zipLocation.getLongitude()),
                                                               String.valueof(objLstJunctionRecs[0].Taxonomy__c),
                                                               sResourceId);
                mapInputData.put('request',requestwrap);
                //API call
                Map<String, Object> suggestedResourcesResponse=RE_ServiceHandler.handleExecutionResults('GetRelatedResources',mapInputData);
                //Check response was succesful or not
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyResourceData = (suggestedResourcesResponse.containskey('response')) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                                
                switch on (switchCaseKeyResourceData) {
                  when SWITCH_SUCCESS {   
                    //Check the staus retured from response is 200 or not
                    RE_ResourceResponseWrapper wrapResponseData = (RE_ResourceResponseWrapper)suggestedResourcesResponse.get('response');
                    RE_GlobalConstants.SWITCH_CONSTANTS switchErrorData = (wrapResponseData.status!=null && (!wrapResponseData.status.isEmpty()) && wrapResponseData.status[0]=='200') ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE  ;
                    switch on (switchErrorData) {
                        when SWITCH_SUCCESS { 
                            //Retrive resourceids from response wrapper 
                            Set<String>  complementaryResources=  wrapResponseData.complementary_resource.resource_location_id;
                            Set<String>  similarResources=  wrapResponseData.similar_resource.resource_location_id;
                            locationResourceIds.addAll(complementaryResources);
                            locationResourceIds.addAll(similarResources);
                            //Query location resources
                            locationResourcelst=fetchLocationResources(locationResourceIds);
                            
                            for(LocationResource__c locRes:locationResourcelst){
                                //Mile calculation
                                Location locgeoLocation = locRes.Location__r.Geolocation__c;
                                if(locgeoLocation!=null){
                                    Double dMiles = RE_MyPlanHelper.getDistance(zipLocation, locgeoLocation, 'mi');
                                    dMiles = dMiles!=null?Double.valueOf(Decimal.valueOf(dMiles).setScale(2,RoundingMode.CEILING)): null;
                                    mapResourceIdVsMinDis.put(locRes.Id,dMiles);
                                }
                                resourceIds.add(locRes.Resource__c);
                                mapLocationResources.put(locRes.Id,locRes);
                            }
                            //Fetch Resource data to pass to referral screen
                            List<Resource__c>  lstResources = RE_ResourceCtrl.fetchResourceData(resourceIds); 
                            for(Resource__c objResource : lstResources){
                                if(objResource.Referrals__r != null && !objResource.Referrals__r.isEmpty()){
                                    mapResourceIdVsDisableConnect.put(objResource.id,true);
                                }else{
                                        mapResourceIdVsDisableConnect.put(objResource.id,false);
                                }
                                mapResources.put(objResource.id, objResource);
                            }
                            //Populate Wrapper for Frequently Paired Resources
                            for(String comResourceId:complementaryResources){
                                if(mapLocationResources.containsKey(comResourceId)){
                                    LocationResource__c locResource=mapLocationResources.get(comResourceId);
                                    Double dmiles;
                                    if(mapResourceIdVsMinDis.containsKey(comResourceId)){
                                        dmiles=mapResourceIdVsMinDis.get(comResourceId);
                                    }
                                    RelatedResourcesWrapper objWrapper = new RelatedResourcesWrapper(locResource.Resource__r.Name,
                                                                                         String.ValueOf(locResource.Resource__c),
                                                                                         locResource.Resource__r.Organization__r.Name,
                                                                                         String.ValueOf(locResource.Resource__r.Organization__c),
                                                                                         dmiles,
                                                                                         locResource.Location__c,
                                                                                         locResource.Resource__r.Organization__r.IsClaimed__c,
                                                                                         mapResourceIdVsDisableConnect.get(locResource.Resource__c),
                                                                                         mapResources.get(locResource.Resource__c));
                                    complementryReswrapList.add(objWrapper);
                               }   
                            }

                            //Populate Wrapper for Similar Resources
                            for(String simResourceId:similarResources){
                                if(mapLocationResources.containsKey(simResourceId)){
                                    LocationResource__c locResource=mapLocationResources.get(simResourceId);
                                    Double dmiles;
                                    if(mapResourceIdVsMinDis.containsKey(simResourceId)){
                                        dmiles=mapResourceIdVsMinDis.get(simResourceId);
                                    }
                                    RelatedResourcesWrapper objWrapper = new RelatedResourcesWrapper(locResource.Resource__r.Name,
                                                                                            String.ValueOf(locResource.Resource__c),
                                                                                            locResource.Resource__r.Organization__r.Name,
                                                                                            String.ValueOf(locResource.Resource__r.Organization__c),
                                                                                            dmiles,
                                                                                            locResource.Location__c,
                                                                                            locResource.Resource__r.Organization__r.IsClaimed__c,
                                                                                            mapResourceIdVsDisableConnect.get(locResource.Resource__c),
                                                                                            mapResources.get(locResource.Resource__c));
                                    similarReswrapList.add(objWrapper);
                                }   
                            }
                            if(!complementryReswrapList.isEmpty()){
                                mapResponse.put('relatedresources',JSON.serialize(complementryReswrapList));
                            }
                            if(!similarReswrapList.isEmpty()){
                               mapResponse.put('similarresources',JSON.serialize(similarReswrapList));  
                            }       
                        }
                        when SWITCH_FAILURE{
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,sEndpoint,'RE_RelatedResourcesCtrl',
                            'execute','Callout to Related Resource failed',
                            sHttpMethod,JSON.serialize(mapInputData.get('request')),
                            (wrapResponseData!=null && wrapResponseData.status!=null && !wrapResponseData.status.isEmpty())?
                            wrapResponseData.status[0]:(suggestedResourcesResponse.containsKey('httpstatus')?String.valueof(suggestedResourcesResponse.get('httpstatus')):''),
                            suggestedResourcesResponse.containsKey('jsonresponse')?String.valueof(suggestedResourcesResponse.get('jsonresponse')):'',0,true);
                          }
                      }

                    }   
                  when SWITCH_FAILURE{
                       LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,sEndpoint,'RE_RelatedResourcesCtrl','execute','Callout to Related Resource failed',sHttpMethod,JSON.serialize(mapInputData.get('request')),String.valueOf(suggestedResourcesResponse.get('status')),String.valueOf(suggestedResourcesResponse.get('error')),0,true);
                    }
                }
            }
          }
            bSuccess = true;
        }
       //RE_Release 1.2 – Requirment 361795 & 361782 - Payal Dubela(04/23/2020) -- Related Services (Similar Resources) & Frequently Paired Together -- END
        catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RelatedResourcesCtrl', 'fetchRelatedResources', e.getMessage() +' ' +e.getLineNumber(),true);
        }
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }

    /********************************************************************************************
    * @author       Payal Dubela
    * @date         04/22/2020
    * @methodname   fetchLocationResources
    * @description  This methods is used to fetch location resources on the basis of id
    * @return       List<LocationResource__c>
    * Requirement : 361782  & 361795
    **********************************************************************************************/
    public static List<LocationResource__c> fetchLocationResources(Set<String> locationResourceIds){
        List<LocationResource__c> lstLocResources = new List<LocationResource__c>();
        String sActiveStatus=RE_GlobalConstants.LOCATION_STATUS_ACTIVE;
        String sOrganizationStatus=RE_GlobalConstants.sAccountStatus;
        String sFieldsToQueryOnLocationResource = RE_DataBaseQueryFields.SFieldsToqueryonLocationResourceRR;
        String sWhereClauseOnLocationResource = RE_DataBaseQueryFields.sWhereClauseForLocationResourceRR;
        Map<String,String> mapResourceLocationQueryParameters = new Map<String,String>();
        mapResourceLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocationResource);
        Map<Boolean,String> mapResourceLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c', sFieldsToQueryOnLocationResource, mapResourceLocationQueryParameters);
        String switchLocResourceKey = (mapResourceLocationQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchLocResourceKey) {
            when 'success' {
                String sQuery = mapResourceLocationQueryResponse.get(true);
                lstLocResources = RE_SharingByPassCtrl.getLocationResourceRecords(locationResourceIds, sQuery,sActiveStatus,sOrganizationStatus);
            }
            when 'failure'{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RelatedResourceCtrl','fetchLocationResources','***FLS Violation***'+mapResourceLocationQueryResponse.get(false),true);
            }
        }
        return lstLocResources;
           
    }

    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   insertReferralForResident
    * @description  This methods is used to insert referral record for Resident
    *               
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReferralForResident(String strwrapperObj, Boolean bConsentAgreed,String referralSource){
        GeneralUtility.isAuthenticatedUser();
        //String wrapperObj = String.escapeSingleQuotes(strwrapperObj);
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Boolean> mapResponse = new Map<String, Boolean>{};
        List<Referral__c> referrallst = new List<Referral__c>();  
        try{
            RelatedResourcesWrapper wrapObj =  (RelatedResourcesWrapper)JSON.deserialize(strwrapperObj, RelatedResourcesWrapper.class);
            Referral__c objReferral= new Referral__c();
            if( wrapObj.bisOrgClaimed){
                objReferral.Status__c= RE_GlobalConstants.STATUS_NEW;
            }else{
                objReferral.Status__c= RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
            } 
            Id contactId = GeneralUtility.getLoggedInUserContactId();
            objReferral.Contacts__c = contactId;
            objReferral.Location__c = id.valueOf(wrapObj.sLocationId);
            objReferral.Resource__c = wrapObj.sResourceId;
            objReferral.ReferredAccountID__c = wrapObj.sResourceAccountId;            
            ID loggedinuserID = UserInfo.getUserId();
            objReferral.OwnerId=loggedinuserID;
            objReferral.DateOfReferral__c=Date.today();
            //Added source
            if(referralSource==RE_GlobalConstants.SIMILAR_RESOURCE){
                objReferral.Source__c=RE_GlobalConstants.REFERRAL_SOURCE_RELATEDSERVICES;
            }else if(referralSource==RE_GlobalConstants.COMPLEMENTARY_RESOURCE){
                objReferral.Source__c= RE_GlobalConstants.REFERRAL_SOURCE_FREQUENTLYPAIRED;
            }else{
                objReferral.Source__c=RE_GlobalConstants.ADDED_BY_RESIDENT;
            }
            
            RE_SharingByPassCtrl.insertReferral(objReferral);
            bSuccess = true;
            if(bConsentAgreed){
                Account objAccount = new Account();
                objAccount.Id = GeneralUtility.getLoggedInUserAccountId();
                objAccount.HasOptedOutOfAccount__c = false;
                RE_SharingByPassCtrl.updateSobject(objAccount.getSobjectType(), objAccount);
            }
        }catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RelatedResourcesCtrl', 'insertReferralForResident', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         08/19/2019
    * @methodname   getOptOutInfoSharingDetails()
    * @description  This methods is used to get OptOutInfoSharing Information from Account
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getOptOutInfoSharingDetails(){
        return RE_MyPlanCtrl.getOptOutInfoSharingDetails();
    }
    
    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         08/19/2019
    * @methodname   connectDraftReferralsFromRelatedResources()
    * @description  This methods is used to connect Draft Referrals
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse connectDraftReferralsFromRelatedResources(String strRRReferralId, Boolean bRRConsentAgreed){
        
        String sRRReferralId = String.escapeSingleQuotes(strRRReferralId);
        
        return RE_MyPlanCtrl.connectDraftReferrals(String.escapeSingleQuotes(sRRReferralId), bRRConsentAgreed);
    }

    public class RelatedResourcesWrapper{
        
        @AuraEnabled public String sResourceName;
        @AuraEnabled public String sResourceId;
        @AuraEnabled public String sResourceAccountName;
        @AuraEnabled public String sResourceAccountId;
        @AuraEnabled public Double dMiles;
        @AuraEnabled public String sLocationId;
        @AuraEnabled public Boolean bisOrgClaimed;
        @AuraEnabled public Boolean bdisableConnect;
        @AuraEnabled public Resource__c objResource; 

        public RelatedResourcesWrapper(){
            bdisableConnect = false;
        }

        public RelatedResourcesWrapper(String sResourceName,String sResourceId,String sResourceAccountName,
                                        String sResourceAccountId,Double dMiles,
                                        String sLocationId,Boolean bisOrgClaimed, Boolean bdisableConnect, Resource__c obResource){
            this.sResourceName = sResourceName;
            this.sResourceId = sResourceId;
            this.sResourceAccountName = sResourceAccountName;
            this.sResourceAccountId = sResourceAccountId;
            this.dMiles = dMiles;
            this.sLocationId = sLocationId;
            this.bisOrgClaimed =bisOrgClaimed;
            this.bdisableConnect = bdisableConnect;
            this.objResource = obResource;
        }
    }

    public class RelatedResourceRequestWrapper{
        
        public String user_id;
        public String LATITUDE;
        public String LONGITUDE;
        public String taxonomy_id;
        public String resource_id;

        public RelatedResourceRequestWrapper(String user_id,String LATITUDE,String LONGITUDE,
                                             String taxonomy_id,String resource_id){
          this.user_id=user_id;
          this.LATITUDE=LATITUDE;
          this.LONGITUDE=LONGITUDE;
          this.taxonomy_id=taxonomy_id;
          this.resource_id=resource_id;
        }
    }
}