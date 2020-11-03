public with sharing class RE_URLShortener {
    
    public static string getShortenedURL( String linktoshort,String customsettingName) {    
        try{
            //Get RebrandlyShortURL endpoint details
            REIntegrationEndpoints__c urlIntEndpoints = REIntegrationEndpoints__c.getValues(customsettingName); 
            String sEndpoint = urlIntEndpoints.Endpoint_URI__c	;
            String sContentType = urlIntEndpoints.Content_Type__c;
            String sHttpMethod = urlIntEndpoints.Http_Method_Type__c;
            String sApiKey = urlIntEndpoints.Account_API_Key__c;
            //RE_Release 1.2 – Task 367419- Payal Dubela - Domain Changes
            Map<String,String> domainDetails= new Map<String,String>();
            domainDetails.put('fullName',urlIntEndpoints.Domain_Name__c);
            bodyToSent btosendobj= new bodyToSent();
            btosendobj.destination=linktoshort;
            btosendobj.domain=domainDetails;
            return RE_URLShortener.getHttp(sEndpoint, JSON.serialize(btosendobj),sApiKey,sHttpMethod,sContentType,urlIntEndpoints.Workspace_Id__c);
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_URLShortener','getShortenedURL',e.getMessage()+ e.getStackTraceString()+e.getLineNumber(), true);
        }
        
        return null;
    }
    
    public static string getHttp(string strURL, String body, String sApiKey,String sHttpMethod,String sContentType,String workspace){
        String shorturl;
        Long startTime= DateTime.now().getTime();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod(sHttpMethod);
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        req.setHeader('Content-Type', sContentType);
        req.setHeader('apikey', sApiKey);
        //RE_Release 1.2 – Task 367419- Payal Dubela - Domain Changes
        req.setHeader('workspace',workspace);
        
        
        req.setBody(body); 
        
        res = h.send(req);
        String responseBody = res.getBody();
        
        if(res.getStatusCode()==200 && res.getStatus() == 'OK'){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            shorturl=(String)results.get('shortUrl');
        }else{
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,strURL,'RE_URLShortener','getHttp','Callout to Rebrandly Failed',sHttpMethod,body,String.valueof(res.getStatusCode()),res.getBody(),DateTime.now().getTime()-startTime,true);
        }
        return shorturl;
    }
    
    Public class bodyToSent{
        public String destination;
        public Map<String,Object> domain;
    }
    
    
    
}