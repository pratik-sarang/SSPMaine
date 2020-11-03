/*********************************************************************************************************************************
* Class         : RE_MessagingEndUserHandler
* Owner         : Deloitte
* Created Date  : 20/05/2020
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  20/05/2020   Suresh      
**/
public with sharing class RE_MessagingEndUserHandler{
	/*
    public void updateContact(List<MessagingEndUser> lstMsgEdUrs, Map<Id, MessagingEndUser> mapOld){
        Map<String, MessagingEndUser> mapMsgEndUsrs = new Map<String, MessagingEndUser>(); 
        Set<String> setPhone = new Set<String>();
        for(MessagingEndUser msg : lstMsgEdUrs){
            MessagingEndUser msOldUsr = mapOld.get(msg.Id);
            if(msOldUsr.IsOptedOut != msg.IsOptedOut){//
               String strPhone =msg.Name.substringAfter(Label.US_Country_Code);
               strPhone = '('+ strPhone.substring(0, 3) +') ' + strPhone.substring(3, 6) + '-' + strPhone.substring(6);
               setPhone.add(strPhone);
               mapMsgEndUsrs.put(strPhone, msg);
            }
        }
      //if(!setPhone.isEmpty() && RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && RE_DataAccessChecker.isSafeField('ConsentToTexts__c', 'Contact')){
          RE_GlobalConstants.SWITCH_CONSTANTS isAccessible = (!setPhone.isEmpty() && RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && RE_DataAccessChecker.isSafeField('ConsentToTexts__c', 'Contact'))? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
          switch on (isAccessible){
            when SWITCH_SUCCESS {
          List<Contact> lstContacts = [SELECT Id, Name, Phone, ConsentToTexts__c, Is_Platform_Event__c, Phone_Number__c, PreferredCommunicationMethod__c FROM Contact WHERE Phone_Number__c IN:setPhone];
              //if(!lstContacts.isEmpty()){
                RE_GlobalConstants.SWITCH_CONSTANTS isNotEmpty = (!lstContacts.isEmpty())? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                switch on (isNotEmpty){
                    when SWITCH_SUCCESS {
               for(Contact cnt : lstContacts){
                   if(!cnt.Is_Platform_Event__c){
                       cnt.PreferredCommunicationMethod__c = (mapMsgEndUsrs.ContainsKey(cnt.Phone_Number__c) && mapMsgEndUsrs.get(cnt.Phone_Number__c).IsOptedOut == false ) ? RE_GlobalConstants.MobilePhone : RE_GlobalConstants.CLAIM_ConsentProvidedEmail;
                       cnt.ConsentToTexts__c = (mapMsgEndUsrs.ContainsKey(cnt.Phone_Number__c) && mapMsgEndUsrs.get(cnt.Phone_Number__c).IsOptedOut == false ) ? true : false;
                       cnt.Is_Platform_Event__c = false;
                   }
                   else{
                       cnt.Is_Platform_Event__c = false;
                   }
               }
               try{
                    if(Schema.sObjectType.MessagingEndUser.isUpdateable()){
                       update lstContacts;
                   }
               }catch(Exception e){
                 LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'MessagingEndUserHandler', 'updateContact', e.getMessage(), true);
               }
           }
       }
            
          }
       }
    }
	*/
}