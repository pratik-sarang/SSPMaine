/*********************************************************************************************************************************
* Class Name    : StaffHandler 
* Owner         : Deloitte
* Created Date  : 11/05/2019 
* Description   : class is used to Create UW Staff
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date         Developer       Description                                                         
*  ----------   -----------     ----------------------------------------------------------------------------------------------------
*  11/08/2019   Sai kiran       Initial Version
*  12/02/2019   Srikanth        Error Handling implementation using platform events
*  04/29/2020   Venkat Korra    Task-339189: Added changes related to New Production Support Profile. 
*                               And modified class name from RE_UWStaffHandler to StaffHandler
*/
public with sharing class StaffHandler {
    
    public class CcAccessException extends Exception{}
    public static staffExceptionCapture createUser(user usr, String federationIdentifier ){
        //below code creates the user with the respective to UW Staff profile
        staffExceptionCapture staffExp = new staffExceptionCapture();
        staffExp.isExceptionFound = false;
        usr.Alias = usr.FirstName.substring(0,2)+String.valueOf(DateTime.now().getTime()).right(6);
        if(usr.LanguageLocaleKey == 'es-US' || usr.LanguageLocaleKey == 'es-MX') {
            usr.LanguageLocaleKey='es_US';
            usr.LocaleSidKey = 'es_US';  
        } else {
            usr.LanguageLocaleKey='en_US';
            usr.LocaleSidKey = 'en_US';  
        }
        usr.TimeZoneSidKey = 'America/New_York';
        usr.EmailEncodingKey = 'UTF-8';
        usr.FederationIdentifier = federationIdentifier;
        List <Profile> prof = new List<Profile>();
        if(Schema.sObjectType.Profile.fields.ID.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible() ){
            // Venkat: 04/29/2020: Task-339189: Added changes related to New Production Support Profile.
            if(usr.KOG_Role__c.contains('UW Staff'))
            {
                prof = getSingleProfileRec('RE United Way Staff');
                usr.RE_Selected_Role__c = 'UW Staff';//[Suresh] set RE selected field
            }
            else if(usr.KOG_Role__c.contains('SF Production Support'))
            {
                prof = getSingleProfileRec('Production Support Profile');
            }
        }
        usr.ProfileId = prof[0].id;
        Database.SaveResult sr = database.insert(usr,false);
        if (!sr.isSuccess()){
            String msg = '';
            for(Database.Error err : sr.getErrors()) {
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                
            }
            //platform events to capture the Error Log when there is an exception in user creation
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',Log_Code__c = 'ERR005',ErroLog__c= 'Error while creating user', Source__c ='StaffHandler', Message__c = msg ,SourceFunction__c = 'createUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            //below parameters to pass the Error code and message to the JIT handler
            staffExp.ExceptionCode = 'ERR002';
            staffExp.usr = usr;
            //throw new CcAccessException('ERR005');
        }
        return staffExp; 
    }
    
    public static user updateUser(user usrInfo, String federationIdentifier ){
     
        User usr ;
        if(Schema.sObjectType.User.fields.ID.isAccessible() && Schema.sObjectType.User.fields.LanguageLocaleKey.isAccessible() && 
           Schema.sObjectType.User.fields.TimeZoneSidKey.isAccessible() && Schema.sObjectType.User.fields.EmailEncodingKey.isAccessible()
          && Schema.sObjectType.User.fields.ProfileId.isAccessible() && Schema.sObjectType.User.fields.FederationIdentifier.isAccessible() && federationIdentifier!=null){
        usr = [SELECT ID,LanguageLocaleKey, ApplicableRoles__c, TimeZoneSidKey, EmailEncodingKey, ProfileId, KOG_Role__c FROM User Where FederationIdentifier =: federationIdentifier LIMIT 1];
          }
        if(usr.LanguageLocaleKey == 'es-US' || usr.LanguageLocaleKey == 'es-MX') {
            usr.LanguageLocaleKey='es_US';
            usr.LocaleSidKey = 'es_US';  
        } else {
            usr.LanguageLocaleKey='en_US';
            usr.LocaleSidKey = 'en_US';  
        }
        usr.TimeZoneSidKey = 'America/New_York';
        usr.EmailEncodingKey = 'UTF-8';
        List <Profile> prof = new List<Profile>();
        if(Schema.sObjectType.Profile.fields.ID.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible()){
            // Venkat: 04/29/2020: Task-339189: Added changes related to New Production Support Profile.
            if(usr.KOG_Role__c.contains('UW Staff'))
            {
                 usr.ApplicableRoles__c = 'RE United Way Staff';
                prof = getSingleProfileRec('RE United Way Staff');
                usr.RE_Selected_Role__c = 'UW Staff';//[Suresh] set RE selected field
            }
            else if(usr.KOG_Role__c.contains('SF Production Support'))
            {
                
                prof = getSingleProfileRec('Production Support Profile');
            }
        }
        usr.ProfileId = prof[0].id;
        Database.SaveResult sr = database.update(usr,false);
        if (!sr.isSuccess()){
            String msg = '';
            for(Database.Error err : sr.getErrors()) {
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            }
            //platform events to capture the Error Log when there is an exception in user update
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',Log_Code__c = 'ERR003',ErroLog__c= 'Error while creating user', Source__c ='StaffHandler', Message__c = msg ,SourceFunction__c = 'updateUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new CcAccessException('ERR003');
        }
        return usr; 
         
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         12/02/2019
* @wrapperClass staffExceptionCapture
* @description  Wrapper class
************************************************************************************************************************************/
    
    public class staffExceptionCapture{
        public boolean isExceptionFound;
        public user usr;
        public string ExceptionCode;
    }
    public static List<profile> getSingleProfileRec(String ProfileName){
        return [Select Id FROM Profile WHERE Name=:ProfileName LIMIT 1];
    }
}