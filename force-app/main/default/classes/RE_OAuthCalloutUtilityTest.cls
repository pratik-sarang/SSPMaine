/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_OAuthCalloutUtilityTest
*   Created By   :   Deloitte
*   Created Date :   09/27/2019
*   Description :   This class acts as a test class for RE_OAuthCalloutUtility
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Payal                    09/27/2019        Initial Version
*****************************************************************************************************************************/
@isTest
public class RE_OAuthCalloutUtilityTest {
    
    @isTest static  void getFreshTokenTest() {
        REIntegrationEndpoints__c endpointsetting= new REIntegrationEndpoints__c();
        endpointsetting.Name='BitlyOauth';
        endpointsetting.Client_Id__c='cgsdjhgdjgvcjasdghsd56';
        endpointsetting.Client_Secret__c='bsdjfgsdfjgfjgsdfjgjdfgjhag';
        endpointsetting.Endpoint_URI__c='http://www.testendpointIEES.com';
        endpointsetting.Content_Type__c='application/JSON';
        endpointsetting.Http_Method_Type__c='GET';
        insert endpointsetting;
        RE_OAuthCalloutUtility oToken = RE_OAuthCalloutUtility.parse('{"expiresIn":"4","dtExpirationTime":"2023-10-10T07:00:00.000Z","accessToken":"BitlyOauth"}');
        RE_OAuthCalloutUtility.sAccessTokenType='BitlyOauth';
        RE_OAuthCalloutUtility refreshedToken=RE_OAuthCalloutUtility.getFreshToken();
         system.assert(refreshedToken == null, 'Success');
        
    }
    @isTest static  void getFreshTokenTest1() {
        REIntegrationEndpoints__c endpointsetting= new REIntegrationEndpoints__c();
        endpointsetting.Name='Azure';
        endpointsetting.Client_Id__c='cgsdjhgdjgvcjasdghsd56';
        endpointsetting.Client_Secret__c='bsdjfgsdfjgfjgsdfjgjdfgjhag';
        endpointsetting.Endpoint_URI__c='http://www.testendpointIEES.com';
        endpointsetting.Content_Type__c='application/JSON';
        endpointsetting.Http_Method_Type__c='GET';
        insert endpointsetting;
        RE_OAuthCalloutUtility oToken = RE_OAuthCalloutUtility.parse('{"expiresIn":"4","dtExpirationTime":"2023-10-10T07:00:00.000Z","accessToken":"Azure"}');
        RE_OAuthCalloutUtility.sAccessTokenType='Azure';
        RE_OAuthCalloutUtility refreshedToken=RE_OAuthCalloutUtility.getFreshToken();
        system.assert(refreshedToken == null, 'Success');
        
    }
    @isTest static  void getFreshTokenTest2() {
        REIntegrationEndpoints__c endpointsetting= new REIntegrationEndpoints__c();
        endpointsetting.Name='oDataToken';
        endpointsetting.Client_Id__c='cgsdjhgdjgvcjasdghsd56';
        endpointsetting.Client_Secret__c='bsdjfgsdfjgfjgsdfjgjdfgjhag';
        endpointsetting.Endpoint_URI__c='http://www.testendpointIEES.com';
        endpointsetting.Content_Type__c='application/JSON';
        endpointsetting.Http_Method_Type__c='GET';
        insert endpointsetting;
        RE_OAuthCalloutUtility oToken = RE_OAuthCalloutUtility.parse('{"expiresIn":"4","dtExpirationTime":"2023-10-10T07:00:00.000Z","accessToken":"oDataToken"}');
        RE_OAuthCalloutUtility.sAccessTokenType='oDataToken';
        RE_OAuthCalloutUtility refreshedToken=RE_OAuthCalloutUtility.getFreshToken();

         system.assert(refreshedToken == null, 'Success');
        
    }
    @isTest static  void getFreshTokenTest3() {
        REIntegrationEndpoints__c endpointsetting= new REIntegrationEndpoints__c();
        endpointsetting.Name='PowerBIAuth';
        endpointsetting.Client_Id__c='cgsdjhgdjgvcjasdghsd56';
        endpointsetting.Client_Secret__c='bsdjfgsdfjgfjgsdfjgjdfgjhag';
        endpointsetting.Endpoint_URI__c='http://www.testendpointIEES.com';
        endpointsetting.Content_Type__c='application/JSON';
        endpointsetting.Http_Method_Type__c='GET';
        insert endpointsetting;
        RE_OAuthCalloutUtility oToken = RE_OAuthCalloutUtility.parse('{"expiresIn":"4","dtExpirationTime":"2023-10-10T07:00:00.000Z","accessToken":"PowerBIAuth"}');
        RE_OAuthCalloutUtility.sAccessTokenType='PowerBIAuth';
        RE_OAuthCalloutUtility refreshedToken=RE_OAuthCalloutUtility.getFreshToken();

             system.assert(refreshedToken == null, 'Success');
    }

}