/*********************************************************************************************************************************
* Class Name    : CPJITHandler 
* Owner         : Deloitte
* Created Date  : 11/05/2019 
* Description   : class is used to handle the single sign on for the Resident and Community Partner users
*
*  Exception generated from this class follows below error code description
* 
*  ERR001: User does not have Citizen or Community Partner Admin or Community Partner Staff role from KOG SAML on User Creation
*  ERR002: No contact associated with user object during user update, when user has already logged in to system
*  ERR003: Looks like you already have different account, Please login using that Account
*  ERR004: No response from MCI, returns null
*  ERR005: CreateUser: Error inserting user in Database
*  ERR006: UpdateUser: Error updating User to Database
*  ERR007: Unhandled exception during contact creation
*  ERR008: Unhandled exception during contact update
*  ERR009: Unhandled exception during Contact Mapping record Creation
*  ERR010: Unhandled exception during System Alert record Creation
*  ERR011: Error while Assigning Permission Set
*  ERR012: Error in response from MCI.
*  ERR013: JIT handler Exception
*  ERR014: Unhandled exception during Contact Mapping record Deletion
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/
//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class CPJITHandler implements Auth.SamlJitHandler {
    //Custom Exception for Citizen
    public class JITException extends Exception{}
    
    //Method to create user in Salesforce when Salesforce doesn't find SAML federationIdentifier match in User Datatable
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        /*RE_ResidentLogic.citizenExceptionCapture residentException = new RE_ResidentLogic.citizenExceptionCapture();
        RECommunityPartnerLogin.cpUserExceptionCapture communityPartnerExp = new RECommunityPartnerLogin.cpUserExceptionCapture();
        REAgencyLogin.agencyUserExceptionCapture agencyExp = new REAgencyLogin.agencyUserExceptionCapture();
        User usr;
        Boolean UpdateCon=false, CreateCon=false;
        usr = JitHelper.parseSamlAttribute(attributes);
        String userinfo=JSON.serialize(usr);
        List<Id> userid = new List<Id>();
        if(attributes.containskey(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c)){
            String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new JITException('MFARequiredCP');
            }
        }        
        //RE_Release 1.4 – Iron Dome Changes(07/17) - Payal Dubela
        if( usr!=null && (usr.KOG_Role__c == null || (usr.KOG_Role__c != null && !usr.KOG_Role__c.contains('Citizen') && !usr.KOG_Role__c.contains('Community Partner Admin') && !usr.KOG_Role__c.contains('Community Partner Staff') && !usr.KOG_Role__c.contains('Case Worker Supervisor') && !usr.KOG_Role__c.contains('Case Worker')))){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= 'role doesnot match', Source__c ='CPJITHandler',SourceFunction__c = 'createUser',
                                              Integration_Payload__c=federationIdentifier,Log_Code__c = 'ERR001',ResponseData__c =JSON.serialize(attributes)));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }   
            throw new JITException('ERR001');//role doesn't match
        }
        if(usr.KOG_Role__c != null && usr.KOG_Role__c.contains('Citizen')){
            residentException = RE_ResidentLogic.createUserinSF(usr,FederationIdentifier);
            if(residentException.isExceptionFound){
                throw new JITException(residentException.ExceptionCode);
            }
        }
        if(usr.KOG_Role__c != null && (usr.KOG_Role__c.contains('Community Partner Admin') || usr.KOG_Role__c.contains('Community Partner Staff'))){
            communityPartnerExp = RECommunityPartnerLogin.communityPartnerLogin(usr, FederationIdentifier);
            if(communityPartnerExp.isExceptionFound){
                throw new JITException(communityPartnerExp.ExceptionCode);
            }
        }
        if(usr.KOG_Role__c != null && (usr.KOG_Role__c.contains('Case Worker Supervisor') || usr.KOG_Role__c.contains('Case Worker'))){
            agencyExp = REAgencyLogin.agencyLogin(usr, FederationIdentifier);
            if(agencyExp.isExceptionFound){
                throw new JITException(agencyExp.ExceptionCode);
            }
        }
        return usr;
        */
        return null;
    }
    
    //Method to update user when Salesforce finds SAML federationIdentifier match to a User Datatable
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        /*User usr= JitHelper.parseSamlAttribute(attributes);
        if(attributes.containskey(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c)){
            String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new JITException('MFARequiredCP');
            }
        }
        //iRonDome Fix - R1.4 - Suresh
        if(usr != null && (usr.KOG_Role__c == null || (usr.KOG_Role__c != null && !usr.KOG_Role__c.contains('Citizen') && !usr.KOG_Role__c.contains('Community Partner Admin') 
                                       && !usr.KOG_Role__c.contains('Community Partner Staff') && !usr.KOG_Role__c.contains('Case Worker Supervisor') 
                                       && !usr.KOG_Role__c.contains('Case Worker') && !usr.KOG_Role__c.contains('Assister')) )){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= 'role doesnot match', Source__c ='CPJITHandler',SourceFunction__c = 'createUser',
                                              Integration_Payload__c=federationIdentifier,Log_Code__c = 'ERR001',ResponseData__c =JSON.serialize(attributes)));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }   
            throw new JITException('ERR001');//role doesn't match
        }
        if(usr.KOG_Role__c.contains('Citizen')){
            RE_ResidentLogic.updateUserinSF(usr,federationIdentifier);
        }
        if(usr.KOG_Role__c.contains('Assister')){
           RE_AssisterLoginHandler.updateAssisterSSO(usr,federationIdentifier);
        }
        if(usr.KOG_Role__c.contains('Case Worker Supervisor') || usr.KOG_Role__c.contains('Case Worker')){
            REAgencyLogin.updateAgencySSO(usr,federationIdentifier);
        }
        if(usr.KOG_Role__c.contains('Community Partner Admin') || usr.KOG_Role__c.contains('Community Partner Staff')){
            RECommunityPartnerLogin.updateCPSSO(usr,federationIdentifier);
        }
       */ 
    }
}