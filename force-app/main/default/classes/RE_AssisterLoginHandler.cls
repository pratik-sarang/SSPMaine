/*********************************************************************************************************************************
* Class Name    : RE_AssisterLoginHandler 
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
public with sharing class RE_AssisterLoginHandler {
    public static user updateAssisterSSO(user usr, String federationIdentifier){
		User usrRec;
        /*
		if(Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.LanguageLocaleKey.isAccessible() 
			&& Schema.sObjectType.User.fields.TimeZoneSidKey.isAccessible() && Schema.sObjectType.User.fields.ProfileId.isAccessible()
            && Schema.sObjectType.Profile.fields.Id.isAccessible()){
			//RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
			if(federationIdentifier!=null && !String.isBlank(federationIdentifier)){
				usrRec = [SELECT ID,LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey, ProfileId FROM User Where FederationIdentifier =: federationIdentifier AND FederationIdentifier != null LIMIT 1];
			}
			List <Profile> prof = [Select ID from Profile where Name = 'RE Assister Profile' and Name!=null];
			if(usrRec != null && usrRec.profileId != prof[0].Id && Schema.sObjectType.User.isUpdateable()){
                usrRec.ProfileId = prof[0].Id;
                update usrRec;
        	}
		}
		*/
        return usrRec;
    }
}