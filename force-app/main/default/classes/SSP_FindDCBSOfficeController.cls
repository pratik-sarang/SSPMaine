/*
* classname         :  SSP_FindDCBSOfficeController
* @description      :  Controller Class for Find DCBS office screen 
* WIHTOUT SHARING   :  The class is running in without sharing mode, since it will fetch office records which are loaded 
                        as a part of day 0 data setup. Also, guest can access this without login to SSP.
* @author           :  Payal Gupta
*/
public without sharing class SSP_FindDCBSOfficeController{
    private static GoogleMapsApiConfig__c config = GoogleMapsApiConfig__c.getInstance();
    private static final String GOOGLE_API_KEY;
    private static final String AUTOCOMPLETE_BASE_URL;
    private static final String PLACE_DETAIL_URL;
    private static final String LOCATION;
    private static final String RADIUS;
    private static final String UTF8 = 'UTF-8';

    public static Map<String, String> countyMap;
    static {
        if(config != null) {
            GOOGLE_API_KEY = config.API_Key_DCBS__c;
            PLACE_DETAIL_URL = config.PlaceDetailUrl__c;
            AUTOCOMPLETE_BASE_URL = config.AutoCompleteUrl__c;
            LOCATION = config.Location__c;
            RADIUS = String.valueOf(config.Radius__c);
        }
        populateCountyMap();
    }

    public class address_componentsListWrapper{
        public List<address_componentsWrapper> address_components;
    }

    public class address_componentsWrapper{
        public String long_name;
        public String short_name;
        public List<String> types;
    }    
    @AuraEnabled
    public static List<SSP_Office__c> getOfficeLocations(decimal lat, decimal lng, String addressCmp){      
        List<SSP_Office__c> sspOfficelist= new List<SSP_Office__c>(); 
        List<address_componentsWrapper> addres_componentList;     
        String postalCode;
        String country;
        String state;
        String county;
        String city;
        Boolean fullAddressPresent= false; //if full address is present then return all offices sorted by distance
        
        if(addressCmp != null){
            addres_componentList = (List<address_componentsWrapper>) JSON.deserialize(addressCmp, List<address_componentsWrapper>.class);
        }
        
        
        if(addres_componentList != null && addres_componentList.size()>0){
            for(address_componentsWrapper component: addres_componentList){
                if(component.types.contains('postal_code')){
                    postalCode = component.long_name;
                    
                }
                if(component.types.contains('country')){
                    country = component.long_name;
                    
                }
                if(component.types.contains('administrative_area_level_1')){
                   state = component.long_name;
                    
                }
                if(component.types.contains('administrative_area_level_2')){
                    String temp;
                    
                    try{
                        temp = component.long_name.trim();
                        if(temp.contains('County')){
                            temp = component.long_name.split('County')[0].trim();
                        }
                        if(countyMap != null && countyMap.containsKey(temp)){
                            county = countyMap.get(temp);
                            if(county.startsWith('0')){
                                county = county.substringAfter('0');
                            }
                            if(county.startsWith('0')){
                                county = county.substringAfter('0');
                            }
                        }
                        

                    }
                    catch(Exception ex){
                        List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_FindDCBSOfficeController', 'getOfficeLocations', ex.getMessage() , true);
                    }
                    
                }
                if(component.types.contains('locality')){
                    city = component.long_name;
                    
                }
                //different types present on address component that constitutes full address
                if(component.types.contains('route') || component.types.contains('street_number') 
                    || component.types.contains('subpremise')|| component.types.contains('premise')
                    || component.types.contains('sublocality')){
                    fullAddressPresent = true;
                    
                }
            }
            
        }
        if(!fullAddressPresent){
            String soql = 'SELECT Id, Name, Calculated_Distance__c, OfficeHoursTo__c,OfficeHoursFrom__c,OfficePhone__c,Geolocation__latitude__s,Geolocation__longitude__s, PhysicalAddressLine1__c, PhysicalAddressLine2__c,PhysicalCity__c,PhysicalCountyCode__c, PhysicalStateCode__c, PhysicalZipCode4__c,PhysicalZipCode5__c, DISTANCE(Geolocation__c, GEOLOCATION(:lat,:lng), \'mi\') dist, OfficeHoursFromText__c, OfficeHoursToText__c FROM SSP_Office__c  ';
            String filter = ' WHERE ';
            if(postalCode != null){
                filter = filter + ' PhysicalZipCode5__c like \'%'+String.escapeSingleQuotes(postalCode)+ '%\' ';
            }
            if(city != null){
                if(filter.length()>7){
                    filter = filter + ' AND ';
                }
                filter = filter + ' PhysicalCity__c like \'%'+String.escapeSingleQuotes(city) + '%\' ';
            }
            if(county != null){
                if(filter.length()>7){
                    filter = filter + ' AND ';
                }
                filter = filter + ' PhysicalCountyCode__c =:county '; //' PhysicalCountyCode__c like \'%'+county + '%\' '
            }
            if(filter.length()>7){
                soql = soql + filter;
            }

            soql = soql + 'ORDER BY DISTANCE(Geolocation__c, GEOLOCATION('+lat+','+lng+'), \'mi\')';
            
            sspOfficelist=Database.query(soql);
            
            
            
        }
        else{
            
            sspOfficelist = [SELECT Id, Name, Calculated_Distance__c, OfficeHoursTo__c,OfficeHoursFrom__c,OfficePhone__c,Geolocation__latitude__s,Geolocation__longitude__s, 
                            PhysicalAddressLine1__c, PhysicalAddressLine2__c,PhysicalCity__c,PhysicalCountyCode__c, PhysicalStateCode__c, PhysicalZipCode4__c,PhysicalZipCode5__c,
                            DISTANCE(Geolocation__c, GEOLOCATION(:lat,:lng), 'mi') dist, OfficeHoursFromText__c, OfficeHoursToText__c
                            FROM SSP_Office__c ORDER BY DISTANCE(Geolocation__c, GEOLOCATION(:lat,:lng), 'mi')];
        }
        
        for ( SSP_Office__c office : sspOfficelist) { 
                                                         
                                       if(office.get('dist') != null){
                                           office.Calculated_Distance__c = String.valueOf(((Decimal)office.get('dist')).SetScale(2)); 
                                           office.OfficeHoursFromText__c = String.valueOf(office.OfficeHoursFrom__c);
                                           office.OfficeHoursToText__c = String.valueOf(office.OfficeHoursTo__c);
                                                       
                                           //sspOfficelist.add(office); 
                                       }                                  
                                   }
        return sspOfficelist;
        
    }

    public class placeResultWrapper{
        public List<resultsWrapper> results;

    }   
    public class resultsWrapper{
        public string formatted_address;
        public List<address_componentsWrapper> address_components;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse getCurrentAddress(decimal lat, decimal lng){   
        SSP_LightningResponse returnResponse = new SSP_LightningResponse(); 
        String result = '';
            try{
                String autoCompleteUrl = 'https://maps.googleapis.com/maps/api/geocode/json'; 
                if(lat != null && lng != null) {
                    autoCompleteUrl += '?latlng=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(String.valueOf(lat)), UTF8)+','
                                                + EncodingUtil.urlEncode(String.escapeSingleQuotes(String.valueOf(lng)), UTF8);
                }
                
                if(GOOGLE_API_KEY != null) {
                    autoCompleteUrl += '&key=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(GOOGLE_API_KEY), UTF8);
                }
                String response = SSP_SharingBypassFetcher.sendHTTPRequest(autoCompleteUrl);
                
                if(response != null){
                    placeResultWrapper responseWrapperObj = (placeResultWrapper)JSON.deserialize(String.valueof(response),placeResultWrapper.class);
                    
                    if(responseWrapperObj != null && responseWrapperObj.results != null 
                        && responseWrapperObj.results.size()>0 && responseWrapperObj.results[0].formatted_address != null){
                        
                        result = responseWrapperObj.results[0].formatted_address;
                        returnResponse.put('formattedAddress', result);
                        //returnResponse.put('dummy', 'dummry');
                        returnResponse.put('addressComponent', JSON.serialize(responseWrapperObj.results[0].address_components));
                        
                    }
                    
                }
            
            
            } catch(Exception e) {
                LOG_LogMessageUtility.logMessage(e,
                                                'SSP_FindDCBSOfficeController', 'getCurrentAddress', e.getMessage() , true);
                
            }
        return returnResponse;
    }

    public static void populateCountyMap(){
        countyMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = SSP_Member__c.PhysicalCountyCode__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry entry : ple)
       {
               countyMap.put(entry.getLabel(), entry.getValue());
               
       }     
       
    }
    
}