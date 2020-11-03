/*********************************************************************************************************************************
* Class Name    : REAgencyLogin 
* Owner         : CHFS Team
* Created Date  : 03/26/2020 
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  03/26/2020  Ram Konduri     Initial Version
**/
public with sharing class REAgencyLogin {
    
    //Custom Exception for Resident
    public class UserAccessException extends Exception{}

/*********************************************************************************************************************************
* Method Name   : agencyLogin 
* Owner         : Ram Konduri
* Created Date  : 03/26/2020 
* Description   : Method is used to Create an User based on ID retured by KOG
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/    
public static agencyUserExceptionCapture agencyLogin(User usr, String federationIdentifier){
    agencyUserExceptionCapture agencyUsrExp = new agencyUserExceptionCapture();
     agencyUsrExp.isExceptionFound = false;
     String permissionSetName;
     List<Contact> listContact= new List <Contact>();
     RecordType objRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.CONTACT_AGENCY_RECORDTYPE,RE_GlobalConstants.strSobjectName);
     if(usr.KOG_Role__c == 'Case Worker Supervisor'){
         permissionSetName = 'RE_Agency_Admin';          
     }else if(usr.KOG_Role__c == 'Case Worker'){
         permissionSetName = 'RE_Agency_Staff';
     } 
     if(Schema.sObjectType.Contact.fields.Id.isAccessible()){

         listContact = [SELECT Id FROM Contact WHERE Email =: usr.Email and Email!=null and RecordTypeId=: objRecordType.Id LIMIT 1];
         if(!listContact.isEmpty() && listContact.size()>0){
            usr.ContactId = listContact[0].id;
         }else{
             Contact con = createAgencyContact(usr, '');
             usr.ContactId = con.id;
         }          
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
     if(Schema.sObjectType.Profile.fields.Id.isAccessible()){ 
         List <Profile> prof = [Select Id FROM Profile WHERE Name = 'RE Agency User Profile']; 
         usr.ProfileId = prof[0].id;
     }
     //Changes By Priyamvada
     usr = JitHelper.sanitiseUser(usr);
     Database.SaveResult sr = database.insert(usr,false);
     if (!sr.isSuccess()){
         String msg = '';
         for(Database.Error err : sr.getErrors()) {
             msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
         }
         List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
         publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= 'Error while creating user', Source__c ='REAgencyLogin', Message__c = msg ,SourceFunction__c = 'communityPartnerLogin'));
         if(publishEvents.size()>0){
             EventBus.publish(publishEvents);
         }
         agencyUsrExp.isExceptionFound = true;
         agencyUsrExp.usr = usr;
         agencyUsrExp.exceptionCode = 'ERR005';
         
     } 
    //Update Kog SourceId- RE Security Changes- Payal Dubela
    RECommunityPartnerLogin.updateKogSourceId(usr.ContactId,federationIdentifier);

      //RE_Release 1.3 – Bug 372485 - Payal Dubela
     if(Schema.sObjectType.PermissionSet.fields.Id.isAccessible()){ 
         PermissionSet objPermissionSet = [SELECT ID,Name FROM PermissionSet WHERE Name =: permissionSetName and Name!=null LIMIT 1]; 
         insertPermissionSet(objPermissionSet.Id,usr.Id);
     }
     return agencyUsrExp;
 }
 
/*********************************************************************************************************************************
* @author       Ram Konduri
* @date         03/26/2020
* @wrapperClass agencyUserExceptionCapture
* @description  Wrapper class
************************************************************************************************************************************/
 
 public class agencyUserExceptionCapture{
     public boolean isExceptionFound;
     public user usr;
     public string exceptionCode;
 }




public static user updateAgencySSO(user usr, String federationIdentifier){
        User usrRec;
        if(Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.LanguageLocaleKey.isAccessible() 
            && Schema.sObjectType.User.fields.TimeZoneSidKey.isAccessible() && Schema.sObjectType.User.fields.ProfileId.isAccessible()
            && Schema.sObjectType.Profile.fields.Id.isAccessible()){
            
            usrRec = [SELECT ID,LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey, ProfileId FROM User Where FederationIdentifier =: federationIdentifier LIMIT 1];
            List <Profile> prof = [Select ID from Profile where Name = 'RE Agency User Profile' and Name!=null];
            if(usrRec != null && usrRec.profileId != prof[0].Id && Schema.sObjectType.User.isUpdateable()){
                usrRec.ProfileId = prof[0].Id;
                update usrRec;
            }
            
        }
        return usrRec;
    }
    
/*********************************************************************************************************************************
* @author       Payal Dubela
* @date         06/10/2020
* @methodname   createAgencyContact()
* @description  Method to create Contact in the Salesforce system
* @param        user usr,String Zipcode
* @return       Contact 
************************************************************************************************************************************/
    
public static Contact createAgencyContact(user usr, String strAgencyRole){
    //RecordType objRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.CONTACT_AGENCY_RECORDTYPE,RE_GlobalConstants.strSobjectName);
    RecordType objRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.strNonCitizenContactDevName, RE_GlobalConstants.strSobjectName);
    List<Account> accList;
    String accountName=System.Label.RE_AgencyUserAccountName;
    if (Schema.sObjectType.Account.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible()) {
        accList= [SELECT Id,Name FROM Account WHERE Name=:accountName AND Name!=null LIMIT 1];
    }
    if(accList.isEmpty()){
        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();  publishEvents.add(new ErrorLog__e(StackTrace__c ='Agency Account doesnot Exist',Log_Code__c = 'ERR007', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'Error while creating a contact record in salesforce', Source__c ='REAgencyLogin', Message__c = 'Agency Account doesnot exist',SourceFunction__c = 'createAgencyContact')); 
        if(publishEvents.size()>0){EventBus.publish(publishEvents);}
        throw new UserAccessException('ERR007');
    }
    //Create dummy account 
    //String strRERoles = RE_UserTriggerHandler.getRERoles(usr.ApplicableRoles__c);
    //List<String> lstRoles = strRERoles.split(';');
    //Set<String> strRoles = new Set<String>(lstRoles);
    Account acc = GeneralUtility.createDummyAccount(usr.FirstName, usr.LastName, strAgencyRole);
    Contact con = new Contact();
    con.RecordTypeId = objRecordType.Id;
    con.FirstName = usr.FirstName;
    con.AccountId = acc.Id;
    con.LastName = usr.LastName;
    con.Email = usr.Email;
    con.Status__c=RE_GlobalConstants.ACTIVE;
    con.TrainingLevel__c=RE_GlobalConstants.CONTACT_TRAINING_LEVEL_TRAINED;
    con.KOGSourceId__c=usr.federationIdentifier;
    if(strAgencyRole.EqualsIgnoreCase('Case Worker Supervisor')){
        con.PermissionsLevel__c = RE_GlobalConstants.ADMIN_ROLE;          
    }else if(strAgencyRole.EqualsIgnoreCase('Case Worker')){
        con.PermissionsLevel__c = RE_GlobalConstants.STAFF_ROLE; 
    } 
    try{
        RE_SharingByPassCtrl.insertSobject(con.getSobjectType(), con);
        
        // Insert ACR
        if(String.isNotBlank(strAgencyRole))
            GeneralUtility.createACR(accList[0].Id, con.Id, strAgencyRole);
        
    }catch(exception ex){
        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();  publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR007', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'Error while creating a contact record in salesforce', Source__c ='REAgencyLogin', Message__c =  ex.getMessage() ,SourceFunction__c = 'createAgencyContact')); 
        if(publishEvents.size()>0){EventBus.publish(publishEvents);}
        throw new UserAccessException('ERR007');
    }
    return con;
 }
   //RE_Release 1.3 – Bug 372485 - Payal Dubela
   @future
    public static void insertPermissionSet(String permissionSetId,String userId){
      PermissionSetAssignment objPermissionSetAssignment=new PermissionSetAssignment(PermissionSetId = permissionSetId,AssigneeId = userId);
      Database.SaveResult srPSA = database.insert(objPermissionSetAssignment,false);
      if (!srPSA.isSuccess()){
         String msg = '';
         for(Database.Error err : srPSA.getErrors()) {
             msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
         }
       List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
         publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= 'Error while creating Permission set', Source__c ='REAgencyLogin', Message__c = msg ,SourceFunction__c = 'insertPermissionSet'));
         if(publishEvents.size()>0){
             EventBus.publish(publishEvents);
         }
      }
    }
   
    /*********************************************************************************************************************************
    * @author       Suresh
    * @date         01/07/2020
    * @methodname   createACRforAgency()
    * @description  Method to create user Contact & ACR when Salesforce doesn't find SAML federationIdentifier match in User
    * @param        User usr, String federationIdentifier
    * @return       User 
    ************************************************************************************************************************************/
    public static void createACRforAgency(String ContactId, String role){
    List<Account> accList;
    String accountName=System.Label.RE_AgencyUserAccountName;
    if (Schema.sObjectType.Account.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible()) {
        accList= [SELECT Id,Name FROM Account WHERE Name=:accountName AND Name!=null LIMIT 1];
    }
    if(accList.isEmpty()){
        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();  publishEvents.add(new ErrorLog__e(StackTrace__c ='Agency Account doesnot Exist',Log_Code__c = 'ERR007', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'Error while creating a contact record in salesforce', Source__c ='REAgencyLogin', Message__c = 'Agency Account doesnot exist',SourceFunction__c = 'createAgencyContact')); 
        if(publishEvents.size()>0){EventBus.publish(publishEvents);}
        throw new UserAccessException('ERR007');
    }
   try{
       //check if ACR Exist
        List<AccountContactRelation> lstACR = RE_DataAccessChecker.isAllowedToAccess(AccountContactRelation.sObjectType) && RE_DataAccessChecker.isSafeField('Roles', 'AccountContactRelation') && RE_DataAccessChecker.isSafeField('ContactId', 'AccountContactRelation') ?[SELECT Roles ,ContactId FROM AccountContactRelation WHERE  ContactId =: ContactId AND AccountId =:accList[0].Id AND roles includes(:RE_GlobalConstants.CASE_WORKER_SUPERVISOR, :RE_GlobalConstants.CASE_WORKER)]: new List<AccountContactRelation>();
       if(lstACR.isEmpty()){
            GeneralUtility.createACR(accList[0].Id, ContactId, role);
       }
    }catch(exception ex){
        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();  publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR015', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'Error while creating a ACR record in salesforce', Source__c ='REAgencyLogin', Message__c =  ex.getMessage() ,SourceFunction__c = 'createACRforAgency')); 
        if(publishEvents.size()>0){EventBus.publish(publishEvents);}
        throw new UserAccessException('ERR015');
    }
        
    }
    
    /*********************************************************************************************************************************
    * @author       Suresh
    * @date         01/07/2020
    * @methodname   createUserinSF()
    * @description  Method to create user Contact & ACR when Salesforce doesn't find SAML federationIdentifier match in User
    * @param        User usr, String federationIdentifier
    * @return       User 
    ************************************************************************************************************************************/
    public static User createUserinSF(user usr, String federationIdentifier , String RoleName, List<String> lstcsRoles){
        User UserRec = new User();
        Contact conRec = new Contact();
        Set<String> setStrRoles = new Set<String>(lstcsRoles);
        String strRERole ='';
        if(setStrRoles.contains(RE_GlobalConstants.CASE_WORKER_SUPERVISOR)){
            strRERole = RE_GlobalConstants.CASE_WORKER_SUPERVISOR;
        }
        else if(setStrRoles.contains(RE_GlobalConstants.CASE_WORKER)){
             strRERole = RE_GlobalConstants.CASE_WORKER;
        }
        //Create ACR when roles are Partner community & Case worker
        if(usr.Id != null){
            if(String.isNotBlank(strRERole)){
                REAgencyLogin.createACRforAgency(usr.ContactId, strRERole);
            }
        }
       
       //Create ACR, Contact & User when role is Case Worker Supervisor/Case worker or both
        if(usr.Id == null){
            List<Contact> lstExistingContacts = [SELECT Id,KOGSourceId__c,AgentId__c FROM Contact WHERE (Account.Applicable_Roles__c like :'%'+usr.KOG_Role__c+'%' AND EMail =: usr.EMail) OR KOGSourceId__c =:federationIdentifier];
            if(lstExistingContacts.isEmpty()){
                if(setStrRoles.contains(RE_GlobalConstants.CASE_WORKER_SUPERVISOR) || setStrRoles.contains(RE_GlobalConstants.CASE_WORKER)){
                    conRec = createAgencyContact(usr, strRERole);
                }
            }else{
                conRec = lstExistingContacts[0];
                usr.ContactId = lstExistingContacts[0].Id;
                if(String.isNotBlank(strRERole)){
                    createACRforAgency(usr.ContactId, strRERole);
                }
            }
            
            usr.RE_Selected_Role__c = strRERole; //Assign RE role
            UserRec = SSP_NonCitizenUserLogic.createNonCitizenUser(usr, federationIdentifier, conRec,RoleName,lstcsRoles);
        }
        return UserRec;
    }
    
}