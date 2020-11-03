/*********************************************************************************************************************************
* Class Name    : RE_CitizenNonCitizenJITHandler 
* Owner         : Deloitte
* Created Date  : 10/04/2020 
* Description   : class is used to handle the single sign on for the Resident and Community Partner users
*
*  Exception generated from this class follows below error code description
* 
*  ERR001: User does not have Citizen or Community Partner Admin or Community Partner Staff or Agency role from KOG SAML on User Creation
*  ERR002: No contact associated with user object during user update, when user has already logged in to system
*  ERR003: Looks like you already have different account, Please login using that Account
*  ERR004: No response from MCI, returns null
*  ERR005: CreateUser: Error inserting user in Database
*  ERR006: UpdateUser: Error updating User to Database
*  ERR007: Unhandled exception during citizen creation
*  ERR008: Unhandled exception during citizen update
*  ERR009: Unhandled exception during Contact Mapping record Creation
*  ERR010: Unhandled exception during System Alert record Creation
*  ERR011: Error while Assigning Permission Set
*  ERR012: Error in response from MCI.
*  ERR013: JIT handler Exception
*  ERR014: Error in aligning the profile, user needs to relogin
*  ERR015: Assister role is not supported during sign up
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/
global with sharing class RE_CitizenNonCitizenJITHandler implements Auth.SamlJitHandler{
    
    //Custom Exception for Citizen
    public class JITException extends Exception{}
    //Method to create user in Salesforce when Salesforce doesn't find SAML federationIdentifier match in User Datatable
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        SSP_ResidentLogic.citizenExceptionCapture residentException = new SSP_ResidentLogic.citizenExceptionCapture();
        RECommunityPartnerLogin.cpUserExceptionCapture communityPartnerExp = new RECommunityPartnerLogin.cpUserExceptionCapture();
        User usr;
        Boolean UpdateCon=false, CreateCon=false;
        
        usr = JitHelper.parseSamlAttribute(attributes);
        String userinfo=JSON.serialize(usr);
        System.debug(usr+'attributes>>>'+attributes);
        List<Id> userid = new List<Id>();
        if(attributes.containskey(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c)){
            String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new JITException('MFARequiredCP');
            }
        }
        
        Set<String> setStr = new Set<String>();
        Set<String> setRERoles = new Set<String>();
        for(PublicGroupAssignments__c role : PublicGroupAssignments__c.getall().values()){
            setRERoles.add(role.Name);
        }
       
        string strCSRole = String.valueOf(attributes.get(KOG_SAML_Attributes__c.getValues('csrole').SAML_Attribute__c));
        List<String> lstCsRoles = new List<String>();
        if(strCSRole!=null){
            lstCsRoles = strCSRole.split(',');
        }
         List<String> lstStrRERoles = new List<String>();
        //iron dome changes 07/08
        if (Schema.sObjectType.KOGRoleMapping__mdt.isAccessible() && Schema.sObjectType.KOGRoleMapping__mdt.fields.Role_Name__c.isAccessible()) {
            for(KOGRoleMapping__mdt kogrm : [Select Id,Role_Name__c,Related_Permission_Sets__c,MasterLabel FROM KOGRoleMapping__mdt Where Role_Name__c IN: setRERoles LIMIT 1000]){
                setStr.add(kogrm.Role_Name__c);//All RE Roles
                if(lstCsRoles.contains(kogrm.Role_Name__c)){
                    lstStrRERoles.add(kogrm.Role_Name__c);
                }
            }
        }
        
       System.debug(lstStrRERoles+'::::setStr::'+setStr);
        //if the csrole contains only citizen role, then KOGrole field would only be Citizen assigned.
        if(!lstStrRERoles.isEmpty() && lstStrRERoles.size() == 1  && lstStrRERoles.contains(RE_GlobalConstants.CITIZEN) ){
            usr.KOG_Role__c = RE_GlobalConstants.CITIZEN;
        }else if(!lstStrRERoles.isEmpty() && lstStrRERoles.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN)){
            usr.KOG_Role__c = SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        }else if(!lstStrRERoles.isEmpty() && lstStrRERoles.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF)){
            usr.KOG_Role__c = SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF;
        }
        else if(!lstStrRERoles.isEmpty() && lstStrRERoles.contains(RE_GlobalConstants.CASE_WORKER_SUPERVISOR)){
            usr.KOG_Role__c = RE_GlobalConstants.CASE_WORKER_SUPERVISOR;
        }
        else if(!lstStrRERoles.isEmpty() && lstStrRERoles.contains(RE_GlobalConstants.CASE_WORKER)){
            usr.KOG_Role__c = RE_GlobalConstants.CASE_WORKER;
        }
        else if(!lstStrRERoles.isEmpty() && lstStrRERoles.contains(RE_GlobalConstants.ASSISTER)  ){
            usr.KOG_Role__c = RE_GlobalConstants.ASSISTER;
        }
        
        if(usr.KOG_Role__c == null || (usr.KOG_Role__c != null && usr.KOG_Role__c == RE_GlobalConstants.ASSISTER)){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ROLE_DOESNOT_EXIST, Source__c ='RE_CitizenNonCitizenJITHandler',SourceFunction__c = 'createUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }   
            throw new JITException('ERR0015');
        }
        
        if(usr.KOG_Role__c == null || (usr.KOG_Role__c != null && !setStr.contains(usr.KOG_Role__c))){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ROLE_DOESNOT_EXIST, Source__c ='RE_CitizenNonCitizenJITHandler',SourceFunction__c = 'createUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }   
            throw new JITException('ERR001');//role doesn't match
        }
        
        if( usr.KOG_Role__c != null  && setStr.contains(usr.KOG_Role__c)){
            if(usr.KOG_Role__c != null && usr.KOG_Role__c.contains(RE_GlobalConstants.CITIZEN)){
                residentException = SSP_ResidentLogic.createUserinSF(usr,FederationIdentifier,RE_CitizenNonCitizenJITHandlerHelper.rolesToBeAssigned(lstCsRoles));
                if(residentException.isExceptionFound){
                    throw new JITException(residentException.ExceptionCode);
                }
            }
           else if(usr.KOG_Role__c != null && (usr.KOG_Role__c.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN) || usr.KOG_Role__c.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF))){
                communityPartnerExp = RECommunityPartnerLogin.communityPartnerLogin(usr, FederationIdentifier, RE_CitizenNonCitizenJITHandlerHelper.rolesToBeAssigned(lstCsRoles));// added roles as one more parameter
                if(communityPartnerExp.isExceptionFound){
                    throw new JITException(communityPartnerExp.ExceptionCode);
                }
                //Create ACR for Agency
                REAgencyLogin.createUserinSF(communityPartnerExp.usr,federationIdentifier,usr.KOG_Role__c,lstCsRoles);
                if(lstStrRERoles.contains(RE_GlobalConstants.CITIZEN))
                SSP_ResidentLogic.updateUserinSF(communityPartnerExp.usr, federationIdentifier);
            }
           else{
                REAgencyLogin.createUserinSF(usr,federationIdentifier,usr.KOG_Role__c,lstCsRoles);
                if(lstStrRERoles.contains(RE_GlobalConstants.CITIZEN))
                SSP_ResidentLogic.updateUserinSF(usr, federationIdentifier);
            }
            
            SSP_ResidentLogic.assignPermissionsetClone(federationIdentifier,lstCsRoles);     
        }
        return usr;
    }
    
    //Method to update user when Salesforce finds SAML federationIdentifier match to a User Datatable
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User usr= JitHelper.parseSamlAttribute(attributes);
        
        string strCSRole = String.valueOf(attributes.get(KOG_SAML_Attributes__c.getValues('csrole').SAML_Attribute__c));
        List<String> lstRoles = new List<String>();
        Boolean isDiffUser=false;
        //Getting roles of user trying to login
        if(strCSRole!=null){
            lstRoles = strCSRole.split(',');                
        }
        boolean isRoleChanged = false;
        Set<String> setRERoles = new Set<String>();
        for(PublicGroupAssignments__c role : PublicGroupAssignments__c.getall().values()){
            setRERoles.add(role.Name);
        }
        List<String> lstStrRERoles = new List<String>();
         List<String> lstStrRESSPRoles = new List<String>();
         
        //iron dome changes 07/08
        if (Schema.sObjectType.KOGRoleMapping__mdt.isAccessible() && Schema.sObjectType.KOGRoleMapping__mdt.fields.Role_Name__c.isAccessible()) {
            for(KOGRoleMapping__mdt kogrm : [Select Id,Role_Name__c,Related_Permission_Sets__c,MasterLabel FROM KOGRoleMapping__mdt WHERE Role_Name__c IN: lstRoles  LIMIT 1000]){
                if(lstRoles.contains(kogrm.Role_Name__c)){//&& setRERoles.contains(kogrm.Role_Name__c)
                    lstStrRERoles.add(kogrm.Role_Name__c);
                }
                lstStrRESSPRoles.add(kogrm.Role_Name__c);
            }
        }
        
        
        //If NeedKOGVisit true, redirect user to MFA page
        if(attributes.containskey(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c)){
            String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new JITException('MFARequiredCP');
            }
        }
        
        if(lstStrRERoles.isEmpty()){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ROLE_DOESNOT_EXIST, Source__c ='RE_CitizenNonCitizenJITHandler',SourceFunction__c = 'createUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }   
            throw new JITException('ERR001');//role doesn't match
        }
        User userdata = new User();
        Contact con = new Contact();
        if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.KOG_Role__c.isAccessible()) {
            userdata = [SELECT Id,FederationIdentifier,Alias, RE_Selected_Role__c, CommunityNickname,IsActive,LastName,contactId,Firstname,LanguageLocaleKey,KOG_Role__c,ApplicableRoles__c FROM User WHERE FederationIdentifier =:federationIdentifier ];
        }
        if (Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible()) {
            con = [SELECT Id,RecordTypeId,RecordType.Name,AgentId__c FROM Contact WHERE Id=:userdata.contactId];
        }

        if(!lstStrRESSPRoles.isEmpty() && lstStrRESSPRoles.size() == 1 && lstStrRESSPRoles.contains('Citizen') && userdata.ApplicableRoles__c != 'Citizen_Individual' && userdata.Id!=null && con.Id!=null ){
            isDiffUser=true;
        } 
        if(lstStrRERoles.size() == 1 && lstStrRERoles.contains('Citizen') && !isDiffUser){//usr.RE_Selected_Role__c!=null && usr.RE_Selected_Role__c.EqualsIgnoreCase('Citizen_Individual') && 
            
            SSP_ResidentLogic.updateUserinSF(usr,federationIdentifier);//Create Contact Mapping & Upadet Contact
        }
        if(attributes.containsKey(KOG_SAML_Attributes__c.getValues('csrole').SAML_Attribute__c)){
            //Get AgentId from the response
            string AgentId;
            if(lstRoles.contains('Agent')){
                string AgentMap = String.valueOf(attributes.get(KOG_SAML_Attributes__c.getValues('AgentId').SAML_Attribute__c));
                Dom.Document doc = new Dom.Document();  
                doc.load( AgentMap );  
                Dom.XMLNode childElement = doc.getRootElement(); 
                for ( Dom.XMLNode detailElement : childElement.getChildElements() ) 
                    if(detailElement.getName()=='Value'){
                        AgentId=detailElement.getText();
                    }
            } 
           
            if(strCSRole!=null){
                List<String> lstCsRoles = strCSRole.split(',');
                //if the role has changed from citizen to Non Citien , update the RecordType of contact to Non Citizen and roles on user object
                if(!lstStrRERoles.isEmpty() && (lstStrRERoles.size() > 1 || (lstStrRERoles.size() == 1 && lstStrRERoles[0] != 'Citizen'))) {
                    //current role is citizen , secondary role will be non citizen
                    
                    //update the profile to non citizen and the liscence
                    profile prof = [SELECT Id FROM Profile WHERE Name='SSP Non Citizen Profile' LIMIT 1];
                    userdata.ProfileId = prof.Id;
                    // recordtype on contact to be updated to non citizen if existing value is citizen
                    RE_CitizenNonCitizenJITHandlerHelper.UpdateConDetails(con.id,'Non_Citizen',AgentId);
                    
                    
                }else{
                    RE_CitizenNonCitizenJITHandlerHelper.UpdateConDetails(con.id,null,AgentId);
                }
                //if the role has chagned from non citizen to citizen, update the RecordType of contact to Citizen, deactive the existing user (profile downgrade is not supported by sf) and roles on user object
                if(!lstStrRESSPRoles.isEmpty() && lstStrRESSPRoles.size() == 1 && lstStrRESSPRoles.contains('Citizen') && userdata.ApplicableRoles__c!=null && userdata.ApplicableRoles__c != 'Citizen_Individual' && userdata.Id!=null && con.Id!=null ){
                    
                    SSP_ResidentLogic.createDifferentUser(userdata, federationIdentifier,con,RE_CitizenNonCitizenJITHandlerHelper.rolesToBeAssigned(lstCsRoles));
                    isRoleChanged = true;
                    
                }
                if(!lstStrRERoles.contains(userdata.RE_Selected_Role__c)){//userdata.ApplicableRoles__c.contains(userdata.RE_Selected_Role__c) && 
                    userdata.RE_Selected_Role__c ='';
                }
                // Create ACR 
                Set<String> setStrRoles = new Set<String>(lstcsRoles);
                 if(setStrRoles.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN) && String.isBlank(userdata.RE_Selected_Role__c)){
                     userdata.RE_Selected_Role__c = SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
                }
                else if(setStrRoles.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF) && String.isBlank(userdata.RE_Selected_Role__c)){
                         userdata.RE_Selected_Role__c = SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF;
                 }
                else if(setStrRoles.contains(RE_GlobalConstants.CASE_WORKER_SUPERVISOR) && String.isBlank(userdata.RE_Selected_Role__c)){
                    userdata.RE_Selected_Role__c = RE_GlobalConstants.CASE_WORKER_SUPERVISOR;
                    REAgencyLogin.createACRforAgency(userdata.ContactId, RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
                }
                else if(setStrRoles.contains(RE_GlobalConstants.CASE_WORKER) && String.isBlank(userdata.RE_Selected_Role__c)){
                     userdata.RE_Selected_Role__c = RE_GlobalConstants.CASE_WORKER;
                    REAgencyLogin.createACRforAgency(userdata.ContactId, RE_GlobalConstants.CASE_WORKER);
                }
                else if(setStrRoles.contains(RE_GlobalConstants.ASSISTER) && String.isBlank(userdata.RE_Selected_Role__c)){
                     userdata.RE_Selected_Role__c = RE_GlobalConstants.ASSISTER;
                }
                else if(setStrRoles.contains(RE_GlobalConstants.CITIZEN)&& String.isBlank(userdata.RE_Selected_Role__c)){
                     userdata.RE_Selected_Role__c = RE_GlobalConstants.CITIZEN_INDIVIDUAL;
                }
                // roles needs to be updated to the applicable reoles field on user object
                userdata.ApplicableRoles__c = RE_CitizenNonCitizenJITHandlerHelper.rolesToBeAssigned(lstCsRoles);
                userdata.UPNId__c=usr.UPNId__c;
                if(!isRoleChanged){
                    update userdata;
                }
                // permission sets needs to be updated
                SSP_ResidentLogic.assignPermissionsetClone(federationIdentifier,lstCsRoles);
                if(lstStrRERoles.contains(RE_GlobalConstants.CITIZEN) && lstStrRERoles.size()>1 && userdata.RE_Selected_Role__c!= 'Citizen_Individual' ){
                    SSP_ResidentLogic.updateUserinSF(userdata, federationIdentifier);
                }
            }
        }
    }
 
}