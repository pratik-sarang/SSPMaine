/*********************************************************************************************************************************
* Class Name    : RECommunityPartnerLogin 
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
global with sharing class RECommunityPartnerLogin {
    
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
        objKogIS = KOGWebservice__c.getValues('KOG Inquiry Service');
        String pageURL;
        String appName;
        String role;
        String SERVICE_URL_EP;
    String strinquiryResponse;
        Integer roleProvision;
        String regLink = objKogIS.KOG_Login_URL__c;
        String strEmail;
        String encodedUrl;
        Long startTime= DateTime.now().getTime();
        String strInquiryRequestData;
        String strGateWayServiceRequestData;
        String contextID;
        String Roles;
        String acrAccountName;
        GeneralUtility.AddUserWrapper usrWrapper;
        List<GeneralUtility.AddUserWrapper> lstUser = new List<GeneralUtility.AddUserWrapper> ();
        List<GeneralUtility.AddUserWrapper> lstDeniedUser = new List<GeneralUtility.AddUserWrapper> ();
        
        tempuriOrg.BasicHttpsBinding_IInquiryService inquiryService = new tempuriOrg.BasicHttpsBinding_IInquiryService();
        inquiryService.clientCertName_x = objKogIS.Certificate__c;
        inquiryService.endpoint_x = objKogIS.EndURL__c;
        inquiryService.timeout_x = 90000;
        for(Contact objContact : lstContact){
            usrWrapper = new GeneralUtility.AddUserWrapper();
            if(objContact.PermissionsLevel__c == 'Admin'){
                Roles = 'Community Partner Admin';
                objKogCP = KOGWebservice__c.getValues('KOG CP Admin');
            }else if(objContact.PermissionsLevel__c == 'Staff'){
                Roles = 'Community Partner Staff';
            objKogCP = KOGWebservice__c.getValues('KOG CP Staff');
            }
            gatewayKOGService.clientCertName_x=objKogCP.Certificate__c;
            pageURL = objKogCP.PageURL__c;
            appName = objKogCP.ApplicationName__c;
            role = objKogCP.Role__c    ;
            SERVICE_URL_EP=objKogCP.EndURL__c;
            strEmail = objContact.Email;
            gatewayKOGService.endpoint_x=SERVICE_URL_EP;
            strInquiryRequestData = JSON.serialize(inquiryService) + '[Input Parameters : Email='+strEmail+', ApplicationName='+appName+', Role='+role+']';
            try{
                roleProvision = inquiryService.UserEnrollCheck(strEmail, appName, role);
             }catch(Exception ex){
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                  ErroLog__c= 'Callout to Inquiry Service is Failed', Source__c ='RECommunityPartnerLogin', 
                                                  Message__c =  ex.getMessage() ,SourceFunction__c = 'sendEmailtoCommunityPartner',
                                                  EndPoint__c = objKogIS.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                                  Integration_Payload__c = strInquiryRequestData,InterfaceName__c = 'Inquiry Service',ResponseData__c = String.valueOf(roleProvision)));
                if(publishEvents.size()>0){
                    EventBus.publish(publishEvents);
                }     
            }
            if(objContact != null){
                //RE Security Changes -392204-Payal Dubela
                AccountContactRelation acr =RE_SharingByPassCtrl.getACRRecord(objContact.Id, Roles,true);
                if(acr != null){
                    List<Account> acrAccount = [SELECT Name FROM Account WHERE Id =: acr.AccountId];
                    if(acrAccount.size() > 0) {
                        acrAccountName  = acrAccount[0].Name;
                    }
                }
            }
           //role provision 1 : if user doesn't exist in KOG 
           //role provision 2 : if user exist in KOG and valid role that match SF and KOG
            if(roleProvision == 1){ 
                    
                    schemasDatacontractOrg200407KeupsB.UserAttribute usrattrEmail = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                    usrattrEmail.IsReadOnly = True;
                    usrattrEmail.Value = objContact.Email;
                    
                    schemasDatacontractOrg200407KeupsB.UserAttribute usrattrFirstName = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                    usrattrFirstName.Value = objContact.FirstName;
                    
                    schemasDatacontractOrg200407KeupsB.UserAttribute usrattrLastName = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                    usrattrLastName.Value = objContact.LastName;
                    
                    schemasDatacontractOrg200407KeupsB.UserAttribute usrattrMobile = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                    usrattrMobile.Value = objContact.Phone;
                    
                    schemasDatacontractOrg200407KeupsB.UserAttributes usrattrs = new schemasDatacontractOrg200407KeupsB.UserAttributes();
                    usrattrs.EmailAddress = usrattrEmail;
                    usrattrs.FirstName = usrattrFirstName;
                    usrattrs.LastName = usrattrLastName;
                    usrattrs.MobilePhone = usrattrMobile;
                        try{
                        contextID = gatewayKOGService.RoleRequestShortcut(pageURL,appName,role,false,usrattrs);
                    }catch(Exception ex){
                        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                        publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                          ErroLog__c= 'Callout to Gateway Service is Failed', Source__c ='RECommunityPartnerLogin', 
                                                          Message__c =  ex.getMessage() ,SourceFunction__c = 'sendEmailtoCommunityPartner',
                                                          EndPoint__c = objKogCP.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                                          Integration_Payload__c = strGateWayServiceRequestData,InterfaceName__c = 'Gateway Service',ResponseData__c = contextID));
                        if(publishEvents.size()>0){
                            EventBus.publish(publishEvents);
                        }     
                    }           
                    
                    strGateWayServiceRequestData = JSON.serialize(gatewayKOGService) + '[Input Parameters : pageURL='+pageURL+', ApplicationName='+appName+', Role='+role+', UserAttributes='+JSON.serialize(usrattrs)+']';
                    
                    
                   
                if(String.IsNotEmpty(contextID)){
                    regLink = regLink+contextID;
                    encodedUrl = EncodingUtil.urlEncode(regLink, 'UTF-8');
                    //Sends an email to user with Link to Create an Account.
                    usrWrapper.contactId = objContact.Id;
                    usrWrapper.systemName = appName;
                    usrWrapper.accountName = acrAccountName;
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
                }
                else{
                    List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                    publishEvents.add(new ErrorLog__e(StackTrace__c = '', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                      ErroLog__c= 'Null response from Gateway Service', Source__c ='RECommunityPartnerLogin', 
                                                      Message__c =  '' ,SourceFunction__c = 'sendEmailtoCommunityPartner',
                                                      EndPoint__c = objKogCP.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                                      Integration_Payload__c = strGateWayServiceRequestData,InterfaceName__c = 'Gateway Service',ResponseData__c = contextID));
                    if(publishEvents.size()>0){
                        EventBus.publish(publishEvents);
                    } 
                }
                //sends email to the user with the KOG registration link 
            }
            else if(roleProvision == 2){
                schemasDatacontractOrg200407KeupsB.UserAttribute usrattrEmail = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                usrattrEmail.IsReadOnly = True;
                usrattrEmail.Value = objContact.Email;
                
                schemasDatacontractOrg200407KeupsB.UserAttribute usrattrFirstName = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                usrattrFirstName.Value = objContact.FirstName;
                
                schemasDatacontractOrg200407KeupsB.UserAttribute usrattrLastName = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                usrattrLastName.Value = objContact.LastName;
                
                schemasDatacontractOrg200407KeupsB.UserAttribute usrattrMobile = new schemasDatacontractOrg200407KeupsB.UserAttribute();
                usrattrMobile.Value = objContact.Phone;
                
                schemasDatacontractOrg200407KeupsB.UserAttributes usrattrs = new schemasDatacontractOrg200407KeupsB.UserAttributes();
                usrattrs.EmailAddress = usrattrEmail;
                usrattrs.FirstName = usrattrFirstName;
                usrattrs.LastName = usrattrLastName;
                usrattrs.MobilePhone = usrattrMobile;
                try{
                    contextID = gatewayKOGService.RoleRequestShortcut(pageURL,appName,role,false,usrattrs);
                }catch(Exception ex){
                    List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                    publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                      ErroLog__c= 'Callout to Gateway Service is Failed', Source__c ='RECommunityPartnerLogin', 
                                                      Message__c =  ex.getMessage() ,SourceFunction__c = 'sendEmailtoCommunityPartner',
                                                      EndPoint__c = objKogCP.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                                      Integration_Payload__c = strGateWayServiceRequestData,InterfaceName__c = 'Gateway Service',ResponseData__c = contextID));
                    if(publishEvents.size()>0){
                        EventBus.publish(publishEvents);
                    }     
                }
                
                strGateWayServiceRequestData = JSON.serialize(gatewayKOGService) + '[Input Parameters : pageURL='+pageURL+', ApplicationName='+appName+', Role='+role+', UserAttributes='+JSON.serialize(usrattrs)+']';
                
            
                if(String.IsNotEmpty(contextID)){
                    regLink = regLink+contextID;
                    usrWrapper.contactId = objContact.Id;
                    usrWrapper.systemName = appName;
                    usrWrapper.accountName = acrAccountName;
                    usrWrapper.regLink = regLink;
                    usrWrapper.logLink = objKogCP.PageURL__c;
                    usrWrapper.contactNumber = System.Label.StateHelpdesk;  
                    usrWrapper.toEmail = objContact.Email;
                    usrWrapper.contactName = objContact.Name;
                    usrWrapper.FirstName = objContact.FirstName;
                    usrWrapper.LastName = objContact.LastName;                
                    usrWrapper.IsClaim=objContact.IsClaim__c;
                    usrWrapper.emailChange = false;
                    lstUser.add(usrWrapper);
                }
                else{
                    List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                    publishEvents.add(new ErrorLog__e(StackTrace__c = '', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                      ErroLog__c= 'Null response from Gateway Service', Source__c ='RECommunityPartnerLogin', 
                                                      Message__c =  '' ,SourceFunction__c = 'sendEmailtoCommunityPartner',
                                                      EndPoint__c = objKogCP.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                                      Integration_Payload__c = strGateWayServiceRequestData,InterfaceName__c = 'Gateway Service',ResponseData__c = contextID));
                    if(publishEvents.size()>0){
                        EventBus.publish(publishEvents);
                    } 
                }
            }
            else if(roleProvision == 3){ //role provision 3 : if user exist in KOG, and role doesn't match with SF to KOG
                //Sends an Email to User to use another email Address
                usrWrapper.contactId = objContact.Id;
                usrWrapper.systemName = appName;
                usrWrapper.accountName = acrAccountName;
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
    public static cpUserExceptionCapture communityPartnerLogin(User usr, String federationIdentifier, String roles){
       cpUserExceptionCapture cpUsrExp = new cpUserExceptionCapture();
        cpUsrExp.isExceptionFound = false;
        //String cpRole;
        /*if(usr.KOG_Role__c == 'Community Partner Admin'){
            cpRole = 'Community Partner Admin';          
        }else if(usr.KOG_Role__c == 'Community Partner Staff'){
           cpRole = 'Community Partner Staff'; 
        } */
        //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
        if(Schema.sObjectType.Contact.fields.Id.isAccessible() && usr.Email !=null){ 
            Contact objContact = [SELECT Id, Account.Applicable_Roles__c FROM Contact WHERE Email =: usr.Email and Email!=null AND Account.Applicable_Roles__c like :'%'+usr.KOG_Role__c+'%' LIMIT 1];
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
        usr.ApplicableRoles__c = roles;
        usr.RE_Selected_Role__c = usr.KOG_Role__c;
        //usr.KOG_Role__c = roles
        //Changes By Priyamvada
        usr = JitHelper.sanitiseUser(usr);
        if(Schema.sObjectType.Profile.fields.Id.isAccessible()){ // PMD Issue Fix - Srikanth
            List <Profile> prof = [Select Id FROM Profile WHERE Name = 'SSP Non Citizen Profile' AND Name != null]; 
            usr.ProfileId = prof[0].id;
        }
        Database.SaveResult sr = database.insert(usr,false);
        if (!sr.isSuccess()){
            String msg = '';
            for(Database.Error err : sr.getErrors()) {
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            }
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= 'Error while creating user', Source__c ='RECommunityPartnerLogin', Message__c = msg ,SourceFunction__c = 'communityPartnerLogin'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            cpUsrExp.isExceptionFound = true;
            cpUsrExp.ExceptionCode = 'ERR005';
            
        } 
        cpUsrExp.usr = usr;
        //PermissionSetAssignment objPermissionSetAssignment;
        //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
       /* if(Schema.sObjectType.PermissionSet.fields.Id.isAccessible() && permissionSetName!=null && (!String.isBlank(permissionSetName))){ // PMD Issue Fix - Srikanth
            PermissionSet objPermissionSet = [SELECT ID,Name FROM PermissionSet WHERE Name =: permissionSetName and Name!=null LIMIT 1]; 
            objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = objPermissionSet.Id,AssigneeId = usr.Id);
        }*/
        /*Database.SaveResult srPSA = database.insert(objPermissionSetAssignment,false);
        if (!srPSA.isSuccess()){
            String msg = '';
            for(Database.Error err : srPSA.getErrors()) {
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            }
          List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= 'Error while creating Permission set', Source__c ='RECommunityPartnerLogin', Message__c = msg ,SourceFunction__c = 'communityPartnerLogin'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            
            cpUsrExp.isExceptionFound = true;
            cpUsrExp.usr = usr;
            cpUsrExp.ExceptionCode = 'ERR011';
        }*/
        //Update Kog SourceId- RE Security Changes- Payal Dubela
        updateKogSourceId(usr.ContactId,federationIdentifier);
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
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         05/21/2020
* @wrapperClass updateCPSSO
* @description  To update Profile and ContactId of a CP user
************************************************************************************************************************************/
    
    public static user updateCPSSO(user usr, String federationIdentifier){
        RecordType objRecordType = GeneralUtility.fetchRecordType('CPUserContact', 'Contact');
        User usrRec;
        if(Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.LanguageLocaleKey.isAccessible() 
            && Schema.sObjectType.User.fields.TimeZoneSidKey.isAccessible() && Schema.sObjectType.User.fields.ProfileId.isAccessible()
            && Schema.sObjectType.Profile.fields.Id.isAccessible()){
            
            usrRec = [SELECT ID,LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey, ProfileId,ContactId,Email FROM User Where FederationIdentifier =: federationIdentifier AND FederationIdentifier != null LIMIT 1];
            Contact lstconupdate = [Select Id,RecordtypeId,AccountId from contact where id=:usrRec.ContactId AND id != null Limit 1];
            List<Contact> lstconCprec = [SELECT Id,Email,AccountId From Contact WHERE Email=:usrRec.Email AND RecordTypeId =:objRecordType.Id AND Email != null LIMIT 1 ];
            List <Profile> prof = [Select ID from Profile where Name = 'RE Community Partner User Profile' and Name!=null];
            if(usrRec != null && usrRec.profileId != prof[0].Id && Schema.sObjectType.User.isUpdateable()){
                usrRec.ProfileId = prof[0].Id;
                usrRec.KOG_Role__c = usr.KOG_Role__c;
                update usrRec;
            }
            
            updateContactRec(lstconCprec[0].AccountId,objRecordType.Id,lstconupdate.Id,lstconCprec[0].Id );
        }
        return usrRec;
    }
    
    @future
    public static void updateContactRec(Id AccountId,Id RecTypeId,Id ConId, Id conDeleteId){
        
        contact condel = [SELECT Id FROM Contact WHERE Id=:conDeleteId AND Id != null LIMIT 1];
        delete condel;
        
        contact con = [SELECT Id,AccountId,RecordTypeId FROM Contact WHERE Id=:ConId AND Id != null LIMIT 1];
        Account acc= [Select Id FROM Account WHERE Id=:AccountId AND Id != null LIMIT 1];
        con.AccountId = acc.Id;
        con.RecordTypeId  = RecTypeId;
        update con;
        
        
    }
    
    
@future
 public static void updateKogSourceId(String conId,String kogId){
   Contact contactToUpdate = new Contact();
   contactToUpdate.Id=conId;
   contactToUpdate.KOGSourceId__c=kogId;
   if (Schema.sObjectType.Contact.isUpdateable()) {
     update contactToUpdate;
   }
 }
}