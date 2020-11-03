/**
* Class Name    : RE_UserCreationHelperTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_UserCreationHelper
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  26/06/2019  Arun       Modified version
**/
@isTest
public class RE_GoogleMapGeoLocationResponseWrapTest {
	@isTest static  void getWrapperMethodTest(){
        RE_GoogleMapGeoLocationResponseWrapper mapWrapperresponse=RE_GoogleMapGeoLocationResponseWrapper.parse(RE_GlobalConstants.sMapMockJsonResponse);
        System.assertNotEquals(null, mapWrapperresponse);
    }
}