/**
* Class Name    : RE_MyFavoritesCtrl
* Owner         : DELOITTE
* Created Date  : 08/19/2019
* Description   : Controller class for handling favorites resource data 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  08/19/2019  Suyash       Initial Version
**/
public without sharing class RE_MyFavoritesCtrl {
    /********************************************************************************************
    * @author       Suyash
    * @date         08/19/2019
    * @methodname   fetchFavResources()
    * @description  This methods is used to get favorite resources
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchFavResources(){
		GeneralUtility.isAuthenticatedUser();
        String sContactId = GeneralUtility.getLoggedInUserContactId();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<Boolean, String> mapLocResResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        Map<String, String> mapLocResQueryParameters = new Map<String, String>(); 
        String sQuery;
        List<Favorite__c> lstFav = new List<Favorite__c>();
        List<LocationResource__c> sLocResourceList = new List<LocationResource__c>();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();

        
        String sFieldsApiName = RE_DataBaseQueryFields.FIELDS_GET_FAVORITES;
        String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_GET_FAVORITES;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Favorite__c', sFieldsApiName, mapQueryParameters);
        Id sFavRecordTypeId = Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Resource Favorite').getRecordTypeId();
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sQuery =  mapResponseData.get(true);
                lstFav = Database.query(sQuery);
                bSuccess = true; 
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl','deleteFavorite','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }

        Set<Id> setLocationIds = new Set<Id>();
        set<Id> setLocResourceIds = new set<Id>();
        List<FavoritesWrapper> lstWrapper = new List<FavoritesWrapper>();

        if (!lstFav.isEmpty()) {
            
            for (Favorite__c objFav : lstFav) {
                setLocationIds.add(objFav.LocationResource__r.Location__c);
                setLocResourceIds.add(objFav.LocationResource__c);
            }
        }

        //Nandita: Added query block to get Location Resource hours of operation
        
        String sLocResFieldsApiName = RE_DataBaseQueryFields.sFieldsforLocResourceOperationHours;
        String sLocResWhereClause = RE_DataBaseQueryFields.sWhereClauseLocResourceOperationHours;
        mapLocResQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sLocResWhereClause);
        mapLocResResponseData = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c', sLocResFieldsApiName, mapLocResQueryParameters);

        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseLocResKey = (mapLocResResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseLocResKey) {
            when SWITCH_SUCCESS {
                sQuery =  mapLocResResponseData.get(true);
                sLocResourceList = Database.query(sQuery);
                bSuccess = true; 
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl','fetchFavResources','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        Map<Id,  Map<String, List<String>>> mapOperatingHours = new Map<Id,  Map<String, List<String>>>();
        if (!setLocationIds.isEmpty() || !sLocResourceList.isEmpty()) {
           mapOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,sLocResourceList);
        }
            for (Favorite__c objFav : lstFav) {

                FavoritesWrapper objwrapper = new FavoritesWrapper();
                objwrapper.sResourceName = objFav.LocationResource__r.Resource__r.Name;
                objwrapper.sResourceId = objFav.LocationResource__r.Resource__c;
                objwrapper.sSDOHCategory = objFav.LocationResource__r.Resource__r.SdohDomain__c;
                //objwrapper.sResourceDescription = objFav.LocationResource__r.Resource__r.Description__c;
                objwrapper.sResourceDescription = objFav.LocationResource__r.ResourceDescription__c;
                Map<String, List<String>> mapLDayOperatingHours = mapOperatingHours.get(objFav.LocationResource__c);
                objWrapper.sOperatingHoursData = JSON.serialize(mapLDayOperatingHours);
                
                objwrapper.sLocationName = objFav.LocationResource__r.Location__r.Name;
                objwrapper.sLocationId = objFav.LocationResource__r.Location__c;
                objwrapper.sLocAddress1 = objFav.LocationResource__r.Location__r.Address1__c;
                objwrapper.sGeoLocation = objFav.LocationResource__r.Location__r.Geolocation__latitude__s+'##'+objFav.LocationResource__r.Location__r.Geolocation__longitude__s;
                
                //Added by Prashant to show the Closed instead of NA
              
                List<String> daysClosed = new List<String>();
                        if(objFav.LocationResource__r.Location__r.DaysLocationClosed__c !=null){                                               
                               for(String locClosed : objFav.LocationResource__r.Location__r.DaysLocationClosed__c.split(';')){
                                   daysClosed.add(locClosed);
                               }
                           }
                        objwrapper.lstClosedDays = daysClosed;
                
                
              
                
                
                if(objFav.LocationResource__r.Location__r.Address2__c !=null && String.isNotBlank(objFav.LocationResource__r.Location__r.Address2__c))
                {
                    String address='';
                    if(objFav.LocationResource__r.Location__r.Address1__c!= null && String.isNotBlank(objFav.LocationResource__r.Location__r.Address1__c)){
                        address+=objFav.LocationResource__r.Location__r.Address1__c;
                    }
                    if(objFav.LocationResource__r.Location__r.Address2__c!= null && String.isNotBlank(objFav.LocationResource__r.Location__r.Address2__c)){
                        address+=', '+objFav.LocationResource__r.Location__r.Address2__c;
                    }
                    if(objFav.LocationResource__r.Location__r.City__c!= null && String.isNotBlank(objFav.LocationResource__r.Location__r.City__c)){
                        address+=', '+objFav.LocationResource__r.Location__r.City__c;
                    }
                    if(objFav.LocationResource__r.Location__r.State__c!= null && String.isNotBlank(objFav.LocationResource__r.Location__r.State__c)){
                        address+=', '+objFav.LocationResource__r.Location__r.State__c;
                    }
                    if(objFav.LocationResource__r.Location__r.Zip__c!= null){
                        address+=' '+objFav.LocationResource__r.Location__r.Zip__c;
                    }
                    //
                    objwrapper.sLocAddress=address;
                    /*objwrapper.sLocAddress = objFav.LocationResource__r.Location__r.Address1__c + ','+ 
                                             objFav.LocationResource__r.Location__r.Address2__c + ','+
                                             objFav.LocationResource__r.Location__r.City__c + ','+
                                             objFav.LocationResource__r.Location__r.State__c + ','+
                                             objFav.LocationResource__r.Location__r.Zip__c;  */
                }
                else{
                    String address='';
                    if(objFav.LocationResource__r.Location__r.Address1__c!= null && String.isNotBlank(objFav.LocationResource__r.Location__r.Address1__c)){
                        address+=objFav.LocationResource__r.Location__r.Address1__c;
                    }
                    if(objFav.LocationResource__r.Location__r.City__c!= null && String.isNotBlank(objFav.LocationResource__r.Location__r.City__c)){
                        address+=', '+objFav.LocationResource__r.Location__r.City__c;
                    }
                    if(objFav.LocationResource__r.Location__r.State__c!= null && String.isNotBlank(objFav.LocationResource__r.Location__r.State__c)){
                        address+=', '+objFav.LocationResource__r.Location__r.State__c;
                    }
                    if(objFav.LocationResource__r.Location__r.Zip__c!= null){
                        address+=' '+objFav.LocationResource__r.Location__r.Zip__c;
                    }
                    objwrapper.sLocAddress=address;
                    /*objwrapper.sLocAddress = objFav.LocationResource__r.Location__r.Address1__c + ','+ 
                                             objFav.LocationResource__r.Location__r.City__c + ','+
                                             objFav.LocationResource__r.Location__r.State__c + ','+
                                             objFav.LocationResource__r.Location__r.Zip__c;*/
                    
                }
                objwrapper.sLocWebsite = objFav.LocationResource__r.Location__r.LocationWebsite__c;
                objwrapper.sLocationResourceId = objFav.LocationResource__c;
                objwrapper.sContactId = objFav.Contact__c;
                objwrapper.sContactZipCode = String.valueOf(objFav.Contact__r.ZipCode__c);

                objwrapper.bOrgIsClaimed = objFav.LocationResource__r.Resource__r.Organization__r.IsClaimed__c;
                objwrapper.sOrgName = objFav.LocationResource__r.Resource__r.Organization__r.Name;
                //objwrapper.sOrgWebsite = objFav.LocationResource__r.Location__r.Website__c != null ? objFav.LocationResource__r.Location__r.Website__c : objFav.LocationResource__r.Resource__r.Organization__r.Website;;
                objwrapper.sOrgWebsite = objFav.LocationResource__r.Location__r.LocationWebsite__c != null ? objFav.LocationResource__r.Location__r.LocationWebsite__c : objFav.LocationResource__r.Resource__r.Organization__r.Website;
                 if(objFav.LocationResource__r.Phone__c != null && objFav.LocationResource__r.Phone__c != ''){
                        objwrapper.sOrgPhone = GeneralUtility.formatphonenumber(objFav.LocationResource__r.Phone__c);
                    }
                 else if(objFav.LocationResource__r.TollFree__c != null && objFav.LocationResource__r.TollFree__c != ''){
                        objwrapper.sOrgPhone = GeneralUtility.formatphonenumber(objFav.LocationResource__r.TollFree__c);
                    }//Nandita: Updated code to fix issue# 3535051
                objwrapper.sOrgEmail = objFav.LocationResource__r.Location__r.Email__c != null ? objFav.LocationResource__r.Location__r.Email__c : objFav.LocationResource__r.Resource__r.Organization__r.Email__c;
                objwrapper.sOrgId = objFav.LocationResource__r.Resource__r.Organization__c;
                objwrapper.sOrgStatus =  objFav.LocationResource__r.Resource__r.Organization__r.Status__c;
                objwrapper.sNotes =  objFav.LocationResource__r.Notes__c;
                if(objwrapper.sOrgStatus == RE_GlobalConstants.sAccountStatus && objwrapper.bOrgIsClaimed){
                	objwrapper.sOrgCheck = RE_GlobalConstants.STATUS_NEW;
                }else if(!objwrapper.bOrgIsClaimed){
                    objwrapper.sOrgCheck = RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
                } 

                lstWrapper.add(objwrapper);
               
                
				
            }
        //}
        mapResponse.put('favorites',lstWrapper);
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }

    public class FavoritesWrapper{
        
        @AuraEnabled public string sResourceName;
        @AuraEnabled public string sResourceId;
        @AuraEnabled public string sSDOHCategory;
        @AuraEnabled public string sResourceDescription;

        @AuraEnabled public string sLocationName;
        @AuraEnabled public string sLocationId;
        @AuraEnabled public string sLocAddress1;
        @AuraEnabled public string sLocationResourceId;
        @AuraEnabled public string sContactId;
        @AuraEnabled public string sContactZipCode;
        @AuraEnabled public string sLocAddress;
        @AuraEnabled public String sOperatingHoursData;
        @AuraEnabled public string sLocWebsite;
        @AuraEnabled public string sGeoLocation;
        @AuraEnabled public string sNotes;
        
        // added by Prashant [13/12/2019]
        @AuraEnabled public List<String> lstClosedDays{get;set;} 

        @AuraEnabled public Boolean bOrgIsClaimed;
        @AuraEnabled public string sOrgName;
        @AuraEnabled public string sOrgWebsite;
        @AuraEnabled public string sOrgPhone;
        @AuraEnabled public string sOrgEmail;
        @AuraEnabled public string sOrgId;
        @AuraEnabled public string sOrgStatus;
        @AuraEnabled public string sOrgCheck;
        
        @AuraEnabled public Boolean bisSelected = false;

    }

}