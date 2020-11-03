/*********************************************************************************************************************************
* Class Name    : SSP_AssisterLoginHandler 
* Owner         : Deloitte
* Created Date  : 11/05/2019 
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  
**/
public class SSP_AssisterLoginHandler {
    /**
* method        : updateAssisterSSO
* @description  : This method is will update the user record based on the federation Id to Assister Profile
* @author       : Kommana Lova Durga Prasad
* */ 
    public static user updateAssisterSSO(user usr, String federationIdentifier){
        User usrRec =new User();
        if (Schema.sObjectType.User.isAccessible()){
            usrRec = [SELECT ID,LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey, ProfileId FROM User Where FederationIdentifier =: federationIdentifier LIMIT 1];
        } 
        List <Profile> prof = [Select ID from Profile where Name =: SSP_GlobalConstants.RE_ASSISTER_PROFILE];
        if(usrRec != null && usrRec.profileId != prof[0].Id && Schema.sObjectType.User.isUpdateable()){
            usrRec.ProfileId = prof[0].Id;
            update usrRec;
        }
        return usrRec;
    }
}