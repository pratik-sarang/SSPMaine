/*********************************************************************************************************************************
* Trigger Name    : platformTriggerEventForUser
* Owner         : Deloitte
* Created Date  : 06/04/2019 
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  06/04/2019    SRIKANTH      
**/

trigger platformTriggerEventForUser on UpdateSSOUser__e (after insert) {

    List<User> lstUserRec = new List<User>();
    
    for(UpdateSSOUser__e objErrorLog :trigger.new){
        lstUserRec.add(new User(id = objErrorLog.UserId__c,
        IsActive =objErrorLog.IsActive__c, CommunityNickname = objErrorLog.CommunityNickname__c,
        Alias = objErrorLog.Alias__c,Username = objErrorLog.UserName__c+String.valueOf(DateTime.now().getTime()).right(3) , FederationIdentifier = objErrorLog.FederationIdentifier__c,UPNId__c='',IsPortalEnabled=false));
    }
    
    if(lstUserRec.size() >0 && !lstUserRec.isEmpty() && Schema.sObjectType.User.isUpdateable()){
          update lstUserRec;
    }
}