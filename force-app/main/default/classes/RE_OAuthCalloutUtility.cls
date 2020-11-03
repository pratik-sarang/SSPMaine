/**
 * Class Name    : RE_OAuthCalloutUtility
 * Owner         : Deloitte
 * Created Date  : 05/01/2017
 * Description   : Utility  Class to get the OAuth token
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer       Description                                                         
 *  ----------  -----------     -------------------------------------------------------------------
    05/01/2017  Subhojit        First version created to make a callout
    05/15/2018  Sudipta         Changes made to get access token for oData integration
 **/
public class RE_OAuthCalloutUtility{
    
    public String accessToken; 
    public String expiresIn;
    public DateTime dtExpirationTime;
    public static String sAccessTokenType = RE_GlobalConstants.sAccessTokenType; //should match the name of the Integration Endpoint custom setting name
    
    
            
    /********************************************************************************************
    METHOD NAME    : parse
    DESCRIPTION    : This method will parse JSON
    RETURN TYPE    : RE_OAuthCalloutUtility
    PARAMETER      : String
    Author         : Danish
    *********************************************************************************************/
    public static RE_OAuthCalloutUtility parse(String sJson) {
        
        RE_OAuthCalloutUtility oAuthVal = (RE_OAuthCalloutUtility) System.JSON.deserialize(sJson, RE_OAuthCalloutUtility.class);
        DateTime dtCurrTime = System.now();
        oAuthVal.dtExpirationTime = dtCurrTime.addSeconds(Math.round(.75 * (Integer.ValueOf(oAuthVal.expiresIn))) - 1);        
        return oAuthVal;

    }
    
    /********************************************************************************************
    METHOD NAME    : getFreshToken
    DESCRIPTION    : This method will parse JSON
    RETURN TYPE    : ISD_OAuthCalloutUtility
    PARAMETER      : String
    Author         : Danish
    *********************************************************************************************/
    public static RE_OAuthCalloutUtility getFreshToken() {
        RE_OAuthCalloutUtility oOAuthToken = null;
        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues(sAccessTokenType);
        if (oIntEndpoints != null) {
            /*Form the request body*/
            String sBody;
            switch on sAccessTokenType {
                when 'Azure' {
                    sBody = RE_GlobalConstants.sBody1 + oIntEndpoints.Client_Id__c + 
                    '&client_secret=' +oIntEndpoints.Client_Secret__c + 
                    '=&grant_type=client_credentials';
                }  
                when 'oDataToken' {
                    sBody = RE_GlobalConstants.sBody2 + oIntEndpoints.Client_Id__c + 
                    '&password=' + oIntEndpoints.Client_Secret__c + '&grant_type=password';
                }
                when 'PowerBIAuth'  {
                    sBody = RE_GlobalConstants.sBody3 + oIntEndpoints.Resource_URI__c +
                        '&client_id=' + EncodingUtil.urlEncode(oIntEndpoints.Client_Id__c, 'UTF-8') + 
                        //'&client_secret=' + oIntEndpoints.Client_Secret__c + 
                        '&username=' + oIntEndpoints.Username__c + 
                        '&password=' + oIntEndpoints.Password__c;
                }                
            }

            Map<HttpRequest, HttpResponse> mapResponse = new Map<HttpRequest, HttpResponse>();
            /*Call RE_CalloutUtility.sendRequest to get Access token*/
            mapResponse = RE_CalloutUtility.sendRequest(sBody,
            oIntEndpoints.Endpoint_URI__c, oIntEndpoints.Content_Type__c,
            oIntEndpoints.Http_Method_Type__c, null);        
            /*Code to get response from mapRequestResponse*/
            HttpResponse oResponse = new HttpResponse();
            oResponse = mapResponse.values()[0];
            Integer iStatusCode = oResponse.getStatusCode();
            if (String.valueOf(oResponse.getStatusCode()).startsWith('2')) {
                oOAuthToken = RE_OAuthCalloutUtility.parse(oResponse.getBody());
            }            
        }
        return oOAuthToken;
    }
}