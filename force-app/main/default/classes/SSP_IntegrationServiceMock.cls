/*
* Classname         :  SSP_IntegrationServiceMock
* @description  :  This class is to mock the response for Adhoc SSP DC MyInformation
* @author       :  Rajeev Kumar
* @date         :  06/03/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest
public class SSP_IntegrationServiceMock implements HttpCalloutMock {
    Boolean  boolIsMockResponseSuccessful;
    String sInterfaceName;
    public Boolean boolIsCalloutException = false;
    // set by constructor, used to vary the mockresponse
    public SSP_IntegrationServiceMock(Boolean boolIsMockResponseSuccessful, String sInterfaceName) {
      this.boolIsMockResponseSuccessful  = boolIsMockResponseSuccessful;
      this.sInterfaceName = sInterfaceName;
    }

    public SSP_IntegrationServiceMock(Boolean boolIsCalloutException) {
        this.boolIsCalloutException = boolIsCalloutException;
    }
  
    public HttpResponse respond(HttpRequest rqst) {
        Map<String,String> mapInterfaceNames = new Map<String, String>{'providerSearch'=>sProviderSearch,
                                                                        'contactInfoUpdate'=>sUpdateContactInfo,
                                                                        SSP_InterfaceConstants.TAX_FORMS_CORRESPONDENCE => sTaxFormsCorrespnodence
                                                                    };
        HttpResponse hResp = new HttpResponse();
        if(boolIsCalloutException) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        } else if (this.boolIsMockResponseSuccessful) {
            hResp.setStatusCode(200);
            if(mapInterfaceNames.containsKey(sInterfaceName)) {
                hResp.setBody(mapInterfaceNames.get(sInterfaceName));
            }     
        } else {
            hResp.setStatusCode(400);
            hResp.setStatus('Bad request');
        }
        return hResp;
    }

    public String sProviderSearch  =    '   {  '  + 
                                        '     "Results": {  '  + 
                                        '       "ProviderSearchResult": [  '  + 
                                        '         {  '  + 
                                        '           "OrganizationId": "4701",  '  + 
                                        '           "OrganizationName": "THE WILLOWS AT HAMBURG    ",  '  + 
                                        '           "OrganizationAddress": "2531 OLD ROSEBUD RD, LEXINGTON,KY,40509"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "OrganizationId": "3937",  '  + 
                                        '           "OrganizationName": "WILLOWBROOK HEALTHCARE CEN",  '  + 
                                        '           "OrganizationAddress": "WILLOWBROOK HEALTHCARE CTR,586 EASTERN BOULEVARD, CLARKSVILLE,IN,471290000"  '  + 
                                        '         }  '  + 
                                        '       ]  '  + 
                                        '     }  '  + 
                                        '  }  ' ;
    public String sUpdateContactInfo = '{"status":true}';
    public String sTaxFormsCorrespnodence =     '   {  '  + 
                                                '      "SaveResultResponse": {  '  + 
                                                '         "IsSuccess": "true",  '  + 
                                                '         "Messages": [  '  + 
                                                '            {  '  + 
                                                '               "Message": "Message_1"  '  + 
                                                '            },  '  + 
                                                '            {  '  + 
                                                '               "Message": "Message_2"  '  + 
                                                '            },  '  + 
                                                '            {  '  + 
                                                '               "Message": "Message_3"  '  + 
                                                '            }  '  + 
                                                '         ]  '  + 
                                                '      },  '  + 
                                                '      "AckResponse": null  '  + 
                                                '  }  ' ; 
}