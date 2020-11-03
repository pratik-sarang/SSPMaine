/*********************************************************************************************************************************
* Class Name    : SSP_CommunityPartnerLogin 
* Owner         : Deloitte
* Created Date  : 11/05/2019 
* Description   : class is used to make a Inquiry Service Call out
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  11/05/2019   Sai Kiran      Initial Version
**/
global with sharing class SSP_CommunityPartnerLogin {
    
    public class CcAccessException extends Exception{}
    
/*********************************************************************************************************************************
* Method Name   : sendEmailtoCommunityPartner 
* Owner         : Sai Kiran
* Created Date  : 11/05/2019 
* Description   : Method is used to Send an Email to User
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/
    global void sendEmailtoCommunityPartner(List<Contact> lstContact){
    
        tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService  gatewayKOGService=new tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService();
        KOGWebservice__c objKogCP;
        KOGWebservice__c objKogIS;
        objKogIS = KOGWebservice__c.getValues(SSP_GlobalConstants.KOG_INQUIRY_SERVICE);
        String pageURL;
        String appName;
        String role;
        String SERVICE_URL_EP;
        Integer roleProvision;
        String contextID;
        String regLink = objKogIS.KOG_Login_URL__c;
        String strEmail;
        String encodedUrl;
        GeneralUtility.AddUserWrapper usrWrapper = new GeneralUtility.AddUserWrapper();
        List<GeneralUtility.AddUserWrapper> lstUser = new List<GeneralUtility.AddUserWrapper> ();
        List<GeneralUtility.AddUserWrapper> lstDeniedUser = new List<GeneralUtility.AddUserWrapper> ();
        
        tempuriOrg.BasicHttpsBinding_IInquiryService inquiryService = new tempuriOrg.BasicHttpsBinding_IInquiryService();
        inquiryService.clientCertName_x = objKogIS.Certificate__c;
        inquiryService.endpoint_x = objKogIS.EndURL__c;
        inquiryService.timeout_x = 90000;
        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
        for(Contact objContact : lstContact){
            if(objContact.PermissionsLevel__c == 'Admin'){
             	objKogCP = KOGWebservice__c.getValues('KOG CP Admin');
            }else if(objContact.PermissionsLevel__c == 'Staff'){
				objKogCP = KOGWebservice__c.getValues('KOG CP Staff');
            }
            gatewayKOGService.clientCertName_x=objKogCP.Certificate__c;
            pageURL = objKogCP.PageURL__c;
            appName = objKogCP.ApplicationName__c;
            role = objKogCP.Role__c    ;
            SERVICE_URL_EP=objKogCP.EndURL__c;
            strEmail = objContact.Email;
            gatewayKOGService.endpoint_x=SERVICE_URL_EP;
            try{
                roleProvision = inquiryService.UserEnrollCheck(strEmail, appName, role);
            }catch(Exception ex){
                
                
                publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                  ErroLog__c= SSP_GlobalConstants.ERROR_IN_RECEIVING_ROLEPROVISION, Source__c =SSP_GlobalConstants.RECOMMUNITYPARTNERLOGIN, 
                                                  Message__c =  ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.SEND_EMAIL_TO_COMMUNITY_PARTNER));
                if(publishEvents.size()>0){
                    EventBus.publish(publishEvents);
                }
            }
           //role provision 1 : if user doesn't exist in KOG 
           //role provision 2 : if user exist in KOG and valid role that match SF and KOG
           
            if(roleProvision == 1 || roleProvision == 2){ 
                try{
                    contextID = gatewayKOGService.SaveAddRoleParametersEx(pageURL,appName,role,false);
                }catch(Exception ex){
                    
                    
                    publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                      ErroLog__c= SSP_GlobalConstants.ERROR_IN_RECEIVING_CONTEXTID, Source__c =SSP_GlobalConstants.RECOMMUNITYPARTNERLOGIN, 
                                                      Message__c =  ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.SEND_EMAIL_TO_COMMUNITY_PARTNER));
                    if(publishEvents.size()>0){
                        EventBus.publish(publishEvents);
                    }
                }
                //sends email to the user with the KOG registration link 
                regLink = regLink+contextID;
                encodedUrl = EncodingUtil.urlEncode(regLink, 'UTF-8');
                //Sends an email to user with Link to Create an Account.
                usrWrapper.contactId = objContact.Id;
                usrWrapper.systemName = appName;
                usrWrapper.accountName = objContact.Account.Name;
                usrWrapper.regLink = objKogIS.KOG_Registration_URL__c+encodedUrl;
                usrWrapper.logLink = objKogCP.PageURL__c;
                usrWrapper.contactNumber = System.Label.StateHelpdesk;  
                usrWrapper.toEmail = objContact.Email;
                usrWrapper.contactName = objContact.Name;
                usrWrapper.FirstName = objContact.FirstName;
                usrWrapper.LastName = objContact.LastName;                
                usrWrapper.IsClaim=objContact.IsClaim__c;
                usrWrapper.emailChange = false;
                lstUser.add(usrWrapper);
            }else if(roleProvision == 3){ //role provision 3 : if user exist in KOG, and role doesn't match with SF to KOG
                //Sends an Email to User to use another email Address
                usrWrapper.contactId = objContact.Id;
                usrWrapper.systemName = appName;
                usrWrapper.accountName = objContact.Account.Name;
                usrWrapper.contactName = objContact.Name;
                usrWrapper.FirstName = objContact.FirstName;
                usrWrapper.LastName = objContact.LastName;
                usrWrapper.contactNumber = System.Label.StateHelpdesk;
                usrWrapper.toEmail = objContact.Email;
                usrWrapper.emailChange = true;
                lstDeniedUser.add(usrWrapper);
            }
        }
        if(lstUser.size() > 0){
            GeneralUtility.addNewUserToOrg(lstUser);
        }
        if(lstDeniedUser.size() > 0){
            GeneralUtility.addNewUserToOrg(lstUser);
        }
    }
    
/*********************************************************************************************************************************
* Method Name   : communityPartnerLogin 
* Owner         : Sai Kiran
* Created Date  : 11/05/2019 
* Description   : Method is used to Create an User based on ID retured by KOG
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/    
    public static cpUserExceptionCapture communityPartnerLogin(User usr, String federationIdentifier){
       cpUserExceptionCapture cpUsrExp = new cpUserExceptionCapture();
        cpUsrExp.isExceptionFound = false;
        String permissionSetName;
        if(usr.KOG_Role__c == SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN){
            permissionSetName = SSP_GlobalConstants.RE_COMMUNITY_PARTNER_ADMIN;          
        }else if(usr.KOG_Role__c == SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF){
            permissionSetName = SSP_GlobalConstants.RE_COMMUNITY_PARTNER_STAFF;
        }
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.ID.isAccessible()){
            Contact objContact = [SELECT ID from Contact where Email =: usr.Email LIMIT 1];
            usr.ContactId = objContact.id; 
        } 
        usr.Alias = usr.FirstName.substring(0,2)+String.valueOf(DateTime.now().getTime()).right(6);
        usr.FederationIdentifier = federationIdentifier;
        if(usr.LanguageLocaleKey == 'es-US' || usr.LanguageLocaleKey == 'es-MX') {
            usr.LanguageLocaleKey='es_US';
            usr.LocaleSidKey = 'es_US';  
        } else {
            usr.LanguageLocaleKey='en_US';
            usr.LocaleSidKey = 'en_US';  
        }
        usr.TimeZoneSidKey = 'America/New_York';
        usr.EmailEncodingKey = 'UTF-8';
        
        if(Schema.sObjectType.Profile.isAccessible()){
            List <Profile> prof = [Select ID from Profile where Name =: SSP_GlobalConstants.RE_COMMUNITY_PARTNER_USER_PROFILE];
            usr.ProfileId = prof[0].id;
        }
        Database.SaveResult sr;
        if (Schema.sObjectType.User.isCreateable()) {
            sr = database.insert(usr,false);
        }
        if (!sr.isSuccess()){
            String msg = '';
            for(Database.Error err : sr.getErrors()) {
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            }
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_USER, Source__c =SSP_GlobalConstants.RECOMMUNITYPARTNERLOGIN, Message__c = msg ,SourceFunction__c = SSP_GlobalConstants.COMMUNITYPARTNERLOGIN));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            cpUsrExp.isExceptionFound = true;
            cpUsrExp.usr = usr;
            cpUsrExp.ExceptionCode = 'ERR005';
            
        }
        PermissionSet objPermissionSet = new PermissionSet();
        if (Schema.sObjectType.PermissionSet.isAccessible()){
            objPermissionSet = [SELECT ID, Name FROM PermissionSet WHERE Name =: permissionSetName LIMIT 1];
        }
        PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment(
        PermissionSetId = objPermissionSet.Id,
        AssigneeId = usr.Id);
        Database.SaveResult srPSA;
        if (Schema.sObjectType.PermissionSetAssignment.isCreateable()) {
            srPSA = database.insert(objPermissionSetAssignment,false);
        }
        if (!srPSA.isSuccess()){
            String msg = '';
            for(Database.Error err : srPSA.getErrors()) {
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            }
          List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_PERMISSION_SET, Source__c =SSP_GlobalConstants.RECOMMUNITYPARTNERLOGIN, Message__c = msg ,SourceFunction__c = SSP_GlobalConstants.COMMUNITYPARTNERLOGIN));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            
            cpUsrExp.isExceptionFound = true;
            cpUsrExp.usr = usr;
            cpUsrExp.ExceptionCode = 'ERR011';
        }
        return cpUsrExp;
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         12/02/2019
* @wrapperClass staffExceptionCapture
* @description  Wrapper class
************************************************************************************************************************************/
    
    public class cpUserExceptionCapture{
        public boolean isExceptionFound;
        public user usr;
        public string ExceptionCode;
    }
}