public class RE_GoogleMapsController {
    public static string getGoogleMapsAPIKey(){
        string strKey =Google_Map_API__c.getOrgDefaults().Key_Value__c;
        return strKey;
    }
    @AuraEnabled
    public static string getAddressAutoComplete(String input) {
        //SOQL injection Fixes - Payal dubela - 08/26
        input=String.isNotBlank(input)?String.escapeSingleQuotes(input):input;
        try{
            String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
            + EncodingUtil.urlEncode(input, 'UTF-8')
            + '&key=' + RE_GoogleMapsController.getGoogleMapsAPIKey();
            
            return RE_GoogleMapsController.getHttp(url);
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_GoogleMapsController','getAddressAutoComplete', e.getStackTraceString(), true);
           
        }
        
        
        return null;
    }
    
    public static string getHttp(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        String responseBody = res.getBody();
        return responseBody;
    }
    
}