/**
* Class Name    : RE_URLShortnerService
* Owner         : DELOITTE
* Created Date  : 07/10/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/10/2019  Abhijeet Vaishnab       Initial Version
*  
**/
public with sharing class RE_URLShortnerService {
    
    
    public Static String getShortURL(String slongURL){
       // 
        Map<String, Object> mapInputData = new Map<String,Object>();
        
        String shortURL;
        mapInputData.put('longURL',slongURL);
        RE_URLShortnerResponseWrapper wrapShortURLData = (RE_URLShortnerResponseWrapper)RE_ServiceHandler.handleExecutionResults('getShortURL',mapInputData).get(RE_GlobalConstants.RESP_SHORT_URL_DATA);
        if(wrapShortURLData != null){
            shortURL = wrapShortURLData.url;
        }
        return shortURL;
    }
    
}