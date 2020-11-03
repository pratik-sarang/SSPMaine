/**
* Class Name    : RE_LandingPageCtrl
* Owner         : DELOITTE
* Created Date  : 07/10/2019
* Description   : Controller for RE_LandingPage
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/10/2019  Nupoor       Initial Version
**/
public class RE_LandingPageCtrl {
	@AuraEnabled
    public static RE_CreateLightningServerResponse fetchUserType() {
        Boolean bSuccess = false;  
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap    = new Map<String, Object>{};
        Boolean isLoggedIn = false;
        String userType = UserInfo.getUserType();
        if (userType != 'Guest'){         
			isLoggedIn = true;                    
        }else{
            isLoggedIn = false;
        }
        bSuccess = true;
        mapResponse.put('isLoggedIn', isLoggedIn);        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
}