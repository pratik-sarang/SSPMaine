/***************************************************************************************************
*   Type        :   Controller Class
*   Name        :   SSPAddressAutocompleteController
*   Create By   :   Ajay Saini
*   Create Date :   NOV-11-2019
*   Description :   This class provides methods for address autocompletion.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini             NOV-11-2019             Initial Version
*
*****************************************************************************************************/
public with sharing class SSPAddressAutocompleteController {
    private static GoogleMapsApiConfig__c config = GoogleMapsApiConfig__c.getInstance();
    private static final String GOOGLE_API_KEY;
    private static final String GOOGLE_API_KEY_DCBS;
    private static final String AUTOCOMPLETE_BASE_URL;
    private static final String PLACE_DETAIL_URL;
    private static final String LOCATION;
    private static final String RADIUS;
    private static final String UTF8 = 'UTF-8';

    static {
        if(config != null) {
            GOOGLE_API_KEY = config.Key__c;
            GOOGLE_API_KEY_DCBS = config.API_Key_DCBS__c;
            PLACE_DETAIL_URL = config.PlaceDetailUrl__c;
            AUTOCOMPLETE_BASE_URL = config.AutoCompleteUrl__c;
            LOCATION = config.Location__c;
            RADIUS = String.valueOf(config.Radius__c);
        }
    }
    
    /*
    * Name : getAddressAutoComplete 
    * Description: This method will be used to get Search Results for auto Address text entered by user using GoogleMaps API
    * @Date 11-NOV-19
    */
    @AuraEnabled
    public static String getAddressAutoComplete(String searchKey) {
        try{
            String autoCompleteUrl = AUTOCOMPLETE_BASE_URL;
            if(String.isNotBlank(searchKey)) {
                autoCompleteUrl += '?input=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(searchKey), UTF8);
            }
            if(LOCATION != null) {
                autoCompleteUrl += '&location=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(LOCATION), UTF8);
            }
            if(RADIUS != null) {
                autoCompleteUrl += '&radius=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(RADIUS), UTF8);
            }
            autoCompleteUrl += '&components=' + EncodingUtil.urlEncode(String.escapeSingleQuotes('country:us'), UTF8);
            if(GOOGLE_API_KEY != null) {
                autoCompleteUrl += '&key=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(GOOGLE_API_KEY), UTF8);
            }
            //Added to filter auto complete results based on place types
            Set<String> setPlaceTypes = new Set<String>();
            String strPlaceTypes = SSP_Utility.getSSPPortalConfigurations('PlaceTypes');
            if(strPlaceTypes != null) {
                setPlaceTypes.addAll(strPlaceTypes.split(','));
            }
            if(setPlaceTypes.isEmpty()){
                return SSP_SharingBypassFetcher.sendHTTPRequest(autoCompleteUrl);
            } else {
                return filterAddressAutoCompleteResults(SSP_SharingBypassFetcher.sendHTTPRequest(autoCompleteUrl), setPlaceTypes);
            }
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e,
                'SSPAddressAutocompleteController', 'getAddressAutoComplete', e.getMessage() , true);
            return JSON.serialize(e);
        }
    }
    
    public class predictionObjectWrapper {
        public List<Object> prediction;
        
        public predictionObjectWrapper(Map<String, Object> response){
            prediction = (List<Object>)response.get('predictions');
        }
    }
    
    public class predictionWrapper{
        public String description;
        public String id;
        public String place_id;
        public String reference;
        public List<String> types;
        
    }
    public class responseWrapper{
        public List<predictionWrapper> predictions;
        public String status;
    }
     public class placeObjectWrapper {
        public Object placeresult;
        
        public placeObjectWrapper(Map<String, Object> response){
            placeresult = (Object)response.get('result');
        }
    }
    public class placeWrapper{
        public object html_attributions;
        public placeResultWrapper result;
        public string status;        
    }
    public class placeResultWrapper{
         @AuraEnabled public string formatted_address;
         @AuraEnabled public geometryWrapper geometry;
         @AuraEnabled public List<address_componentsWrapper> address_components;
        
    }
    public class address_componentsWrapper{
        String long_name;
        String short_name;
        List<String> types;
    }

    public class geometryWrapper{
         @AuraEnabled public locationWrapper location;
    }
    public class locationWrapper{
         @AuraEnabled public string lat;
         @AuraEnabled public string lng;
    }
    
    /*
* Name : getAddressAutoCompleteLWC
* Author: Payal
* Description: This method will be used to get Search Results for auto Address text entered by user using GoogleMaps API
* @Date 10-APR-20
*/
    @AuraEnabled
    public static String getAddressAutoCompleteLWC(String searchKey) {
        //List<predictionWrapper> predictionWrapperList = new List<predictionWrapper>();
        List<placeResultWrapper> placeResultWrapperList = new List<placeResultWrapper>();
        try{
            String autoCompleteUrl = AUTOCOMPLETE_BASE_URL;            
            if(String.isNotBlank(searchKey)) {
                autoCompleteUrl += '?input=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(searchKey), UTF8);
            }            
            if(LOCATION != null) {
                autoCompleteUrl += '&location=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(LOCATION), UTF8);
            }
            if(RADIUS != null) {
                autoCompleteUrl += '&radius=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(RADIUS), UTF8);
            }
            autoCompleteUrl += '&components=' + EncodingUtil.urlEncode(String.escapeSingleQuotes('country:us'), UTF8);
            if(GOOGLE_API_KEY != null) {
                autoCompleteUrl += '&key=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(GOOGLE_API_KEY_DCBS), UTF8);
            }
            
            String response = SSP_SharingBypassFetcher.sendHTTPRequest(autoCompleteUrl);
            
	    //List<Object> returnList = new List<object>();
            if(response!=null){
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response);
                
                //predictionObjectWrapper predict = new predictionObjectWrapper(results);
                responseWrapper responseWrapperObj = (responseWrapper)JSON.deserialize(String.valueof(response),responseWrapper.class);
                for(predictionWrapper prediction: responseWrapperObj.predictions){
                    String placeDetail = getPlaceDetailDCBS(prediction.place_id);
                     Map<String, Object> placeresults = (Map<String, Object>)JSON.deserializeUntyped(placeDetail);
                    placeObjectWrapper placeObjectObjectValue = new placeObjectWrapper(placeresults);
                    placeResultWrapper p = new placeResultWrapper();
                    p = (placeResultWrapper) JSON.deserialize(JSON.serialize(placeObjectObjectValue.placeresult), placeResultWrapper.class);
                    placeResultWrapperList.add(p);
                    
                    //returnList.add(placeDetail);                                        
                }
            }
            
            //return placeResultWrapperList;
            return JSON.serialize(placeResultWrapperList);
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e,
                                             'SSPAddressAutocompleteController', 'getAddressAutoCompleteLWC', e.getMessage() , true);
            return null;
        }
    }
    
        /*
* Name : getPlaceDetailDCBS 
* Description: This method will be used to get address (street,city,country,zipcode,geolocation) 
*               using the Place Id generated during address Selection
* @Date April 14, 2020
*/
    @AuraEnabled(cacheable=true)
    public static String getPlaceDetailDCBS(String placeId) {
        try{
            String placeIdUrl = PLACE_DETAIL_URL;
            if(String.isNotBlank(placeId)) {
                placeIdUrl += '?placeid=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(placeId), UTF8);
            }
            if(RADIUS != null) {
                placeIdUrl += '&radius=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(RADIUS), UTF8);
            }
            if(String.isNotBlank(GOOGLE_API_KEY_DCBS)) {
                placeIdUrl += '&key=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(GOOGLE_API_KEY_DCBS), UTF8);
            }
            return SSP_SharingBypassFetcher.sendHTTPRequest(placeIdUrl);
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e,
                                             'SSPAddressAutocompleteController', 'getPlaceDetail', e.getMessage() , true);
            return JSON.serialize(e);
        }
    }

    /*
    * Name : getPlaceDetail 
    * Description: This method will be used to get address (street,city,country,zipcode,geolocation) 
    *               using the Place Id generated during address Selection
    * @Date 11-NOV-19
    */
    @AuraEnabled(cacheable=true)
    public static String getPlaceDetail(String placeId) {
        try{
            String placeIdUrl = PLACE_DETAIL_URL;
            if(String.isNotBlank(placeId)) {
                placeIdUrl += '?placeid=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(placeId), UTF8);
            }
            if(String.isNotBlank(GOOGLE_API_KEY)) {
                placeIdUrl += '&key=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(GOOGLE_API_KEY), UTF8);
            }
            return SSP_SharingBypassFetcher.sendHTTPRequest(placeIdUrl);
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e,
                'SSPAddressAutocompleteController', 'getPlaceDetail', e.getMessage() , true);
            return JSON.serialize(e);
        }
    }

    /**
    * @author: Karthik Gulla
    * @method: filterAddressAutoCompleteResults
    * @desc This method is used to filter address auto complete results based on place types
    * @param {String strResponse, Set<String> setPlaceTypes}
    * @return String
    * */
    public static String filterAddressAutoCompleteResults(String strResponse, Set<String> setPlaceTypes) {
        String strFilteredResponse = '';
        try{
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
            SSPAddressAutoCompleteController.responseWrapper responseWrapperObj = (SSPAddressAutoCompleteController.responseWrapper)JSON.deserialize(String.valueof(strResponse),SSPAddressAutoCompleteController.responseWrapper.class);

            SSPAddressAutoCompleteController.responseWrapper updatedresponseWrapperObj = (SSPAddressAutoCompleteController.responseWrapper)JSON.deserialize(String.valueof(strResponse),SSPAddressAutoCompleteController.responseWrapper.class);
            List<SSPAddressAutoCompleteController.predictionWrapper> lstFilteredPredictions = new List<SSPAddressAutoCompleteController.predictionWrapper>();

            for(SSPAddressAutoCompleteController.predictionWrapper prediction: responseWrapperObj.predictions){
                List<String> lstPredictionTypes = prediction.types;
                if(hasPlaceTypesApplicable(lstPredictionTypes, new List<String>(setPlaceTypes))) {
                    lstFilteredPredictions.add(prediction);
                }
            }
            updatedresponseWrapperObj.predictions = lstFilteredPredictions;
            strFilteredResponse = JSON.serializePretty(updatedresponseWrapperObj);
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSPAddressAutocompleteController', 'filterAddressAutoCompleteResults', e.getMessage(), true);
            return strFilteredResponse;
        }
        return strFilteredResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: hasPlaceTypesApplicable
    * @desc This method is used to check whether address returened has a valid place types
    * @param {List<String> lstAddressPlaceTypes, List<String> lstConfiguredPlaceTypes}
    * @return Boolean
    * */
    public static Boolean hasPlaceTypesApplicable(List<String> lstAddressPlaceTypes, List<String> lstConfiguredPlaceTypes){
        Boolean bReturnValue = false;
        try{
            for(String strPlaceType:lstAddressPlaceTypes){
                bReturnValue =  lstConfiguredPlaceTypes.contains(strPlaceType) ? true : false;
                if(bReturnValue){
                    break;
                }                            
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSPAddressAutocompleteController', 'hasPlaceTypesApplicable', e.getMessage(), true);
        }        
        return bReturnValue;
    }
}