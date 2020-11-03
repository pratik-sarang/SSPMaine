/*********************************************************************************************************************************
* Class Name    : SSPCitizenJITHandler 
* Owner         : Deloitte
* Created Date  : 10/04/2020 
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
*  ERR007: Unhandled exception during citizen creation
*  ERR008: Unhandled exception during citizen update
*  ERR009: Unhandled exception during Contact Mapping record Creation
*  ERR010: Unhandled exception during System Alert record Creation
*  ERR011: Error while Assigning Permission Set
*  ERR012: Error in response from MCI.
*  ERR013: JIT handler Exception
*  ERR014: Error in aligning the profile, user needs to relogin
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/
global class SSPCitizenJITHandler implements Auth.SamlJitHandler{
    
    //Custom Exception for Citizen
    public class JITException extends Exception{}
    //Method to create user in Salesforce when Salesforce doesn't find SAML federationIdentifier match in User Datatable
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        SSP_ResidentLogic.citizenExceptionCapture residentException = new SSP_ResidentLogic.citizenExceptionCapture();
        SSP_CommunityPartnerLogin.cpUserExceptionCapture communityPartnerExp = new SSP_CommunityPartnerLogin.cpUserExceptionCapture();
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
        
        string strCSRole = String.valueOf(attributes.get(KOG_SAML_Attributes__c.getValues('csrole').SAML_Attribute__c));
        List<String> lstCsRoles = new List<String>();
        if(strCSRole!=null){
            lstCsRoles = strCSRole.toUppercase().split(',');
        }

        Set<String> setStr = new Set<String>();
        List<String> lstStrSSPRoles = new List<String>();
        //iron dome changes 07/08
        //Getting role mapping from metadata and add to list if at the time of login role is present in metadata
        if (Schema.sObjectType.KOGRoleMapping__mdt.isAccessible() && Schema.sObjectType.KOGRoleMapping__mdt.fields.Role_Name__c.isAccessible()) {
            for(KOGRoleMapping__mdt kogrm : [Select Id,Is_SSP_User__c,Role_Name__c,Related_Permission_Sets__c,MasterLabel FROM KOGRoleMapping__mdt LIMIT 1000]){
                setStr.add(kogrm.Role_Name__c);
                if(lstCsRoles.contains(String.valueOf(kogrm.Role_Name__c).toUppercase()) && kogrm.Is_SSP_User__c == true){
                    lstStrSSPRoles.add(kogrm.Role_Name__c);
                }
            }
        }
        //if the csrole contains only citizen role, then KOGrole field would only be Citizen assigned.
        if(!lstStrSSPRoles.isEmpty() && lstStrSSPRoles.size() == 1  && lstStrSSPRoles.contains('Citizen') ){
            usr.KOG_Role__c = 'Citizen';
        }else if(!lstStrSSPRoles.isEmpty() && lstStrSSPRoles.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN)  ){
            usr.KOG_Role__c = SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        }else if(!lstStrSSPRoles.isEmpty() && lstStrSSPRoles.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF)  ){
            usr.KOG_Role__c = SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF;
        }
        else{
            usr.KOG_Role__c = 'Agent';
        }
        //if the cs role contains noncitizen with multiple roles
        //code needs to be added
        //Add lstStrSSPRoles.isEmpty() becuase if list is empty then it will show ACCESS DENIED error        
        if(usr.KOG_Role__c == null || (usr.KOG_Role__c != null && !setStr.contains(usr.KOG_Role__c)) || lstStrSSPRoles.isEmpty()){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ROLE_DOESNOT_EXIST, Source__c ='CPJITHandler',SourceFunction__c = 'createUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }   
            throw new JITException('ERR001');//role doesn't match
        }
        
        if( usr.KOG_Role__c != null  && setStr.contains(usr.KOG_Role__c)){
            if(usr.KOG_Role__c != null && usr.KOG_Role__c.contains('Citizen')){
                residentException = SSP_ResidentLogic.createUserinSF(usr,FederationIdentifier,rolesToBeAssigned(lstCsRoles));
                if(residentException.isExceptionFound){
                    throw new JITException(residentException.ExceptionCode);
                }
            }
            else if(usr.KOG_Role__c != null && (usr.KOG_Role__c.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN) || usr.KOG_Role__c.contains(SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF))){
                communityPartnerExp = SSP_CommunityPartnerLogin.communityPartnerLogin(usr, FederationIdentifier);
                if(communityPartnerExp.isExceptionFound){
                    throw new JITException(communityPartnerExp.ExceptionCode);
                }
            }
            else{
                //Get AgentId from the response
				string AgentId;
                if(lstCsRoles.contains('AGENT')){
                    string AgentMap = String.valueOf(attributes.get(KOG_SAML_Attributes__c.getValues('AgentId').SAML_Attribute__c));
                    Dom.Document doc = new Dom.Document();  
                    doc.load( AgentMap );  
                    Dom.XMLNode childElement = doc.getRootElement(); 
                    for ( Dom.XMLNode detailElement : childElement.getChildElements() ) 
                        if(detailElement.getName()=='Value'){
                            AgentId=detailElement.getText();
                        }
                }
                SSP_NonCitizenUserLogic.createNonCitizenUserinSF(usr,federationIdentifier,usr.KOG_Role__c,lstCsRoles,AgentId);
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
        //Getting roles of user trying to login
        if(strCSRole!=null){
            lstRoles = strCSRole.toUppercase().split(',');                
        }

        //Getting role mapping from metadata and add to list if at the time of login role is present in metadata
        List<String> lstStrSSPRoles = new List<String>();
        if (Schema.sObjectType.KOGRoleMapping__mdt.isAccessible() && Schema.sObjectType.KOGRoleMapping__mdt.fields.Role_Name__c.isAccessible() && Schema.sObjectType.KOGRoleMapping__mdt.fields.Is_SSP_User__c.isAccessible()) {
            for(KOGRoleMapping__mdt kogrm : [Select Id,Is_SSP_User__c,Role_Name__c,Related_Permission_Sets__c,MasterLabel FROM KOGRoleMapping__mdt LIMIT 1000]){
                if(lstRoles.contains(String.valueOf(kogrm.Role_Name__c).toUppercase()) && kogrm.Is_SSP_User__c == true){
                    lstStrSSPRoles.add(kogrm.Role_Name__c);
                }
            }
        }

        //If NeedKOGVisit true, redirect user to MFA page
        if(attributes.containskey(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c)){
            String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new JITException('MFARequiredCP');
            }
        }
        
        //Add lstStrSSPRoles.isEmpty() becuase if list is empty then it will show ACCESS DENIED error
        if(lstStrSSPRoles.isEmpty()){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ROLE_DOESNOT_EXIST, Source__c ='CPJITHandler',SourceFunction__c = 'UpdateUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }   
            throw new JITException('ERR001');

        }
        User userdata = new User();
        Contact con = new Contact();
        if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.KOG_Role__c.isAccessible()) {
            userdata = [SELECT Id,FederationIdentifier,Alias,CommunityNickname,IsActive,LastName,contactId,Firstname,LanguageLocaleKey,KOG_Role__c,ApplicableRoles__c FROM User WHERE FederationIdentifier =:federationIdentifier ];
        }
        if (Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible()) {
            con = [SELECT Id,RecordTypeId,RecordType.Name,AgentId__c FROM Contact WHERE Id=:userdata.contactId];
        }
        /*if(usr.KOG_Role__c!=null && usr.KOG_Role__c == 'Citizen') {
            SSP_ResidentLogic.updateUserinSF(usr,federationIdentifier);
        }*/
        List<String> lstCsRoles;
        if(strCSRole!=null) {
            lstCsRoles = strCSRole.split(',');
        }
		//This will only fire when Kog returns only one role (citizen)
        if(lstCsRoles != null && lstCsRoles.size() == 1 && userdata != null && userdata.KOG_Role__c!=null && userdata.KOG_Role__c == 'Citizen') {
            SSP_ResidentLogic.updateUserinSF(usr,federationIdentifier);
	    }
	
        //if the role has chagned from non citizen to citizen, update the RecordType of contact to Citizen, deactive the existing user (profile downgrade is not supported by sf) and roles on user object
        if(!lstStrSSPRoles.isEmpty() && lstStrSSPRoles.size() == 1 && lstStrSSPRoles[0] == 'Citizen' && userdata.KOG_Role__c!= 'Citizen' && userdata.Id!=null && con.Id!=null ){
            SSP_ResidentLogic.createDifferentUser(userdata, federationIdentifier,con,rolesToBeAssigned(lstStrSSPRoles));
        }
	
        if(attributes.containsKey(KOG_SAML_Attributes__c.getValues('csrole').SAML_Attribute__c)){
			//Get AgentId from the response
			string AgentId;
			if(lstRoles.contains('AGENT')){
				string AgentMap = String.valueOf(attributes.get(KOG_SAML_Attributes__c.getValues('AgentId').SAML_Attribute__c));
				Dom.Document doc = new Dom.Document();  
				doc.load( AgentMap );  
				Dom.XMLNode childElement = doc.getRootElement(); 
				for ( Dom.XMLNode detailElement : childElement.getChildElements() ) 
					if(detailElement.getName()=='Value'){
						AgentId=detailElement.getText();
					}
			} 
            if(lstCsRoles != null) {
                //if the role has changed from citizen to Non Citien , update the RecordType of contact to Non Citizen and roles on user object
                if(!lstCsRoles.isEmpty() && (lstCsRoles.size() > 1 || (lstCsRoles.size() == 1 && lstCsRoles[0] != 'Citizen'))) {
                    //current role is citizen , secondary role will be non citizen
                    
                    //update the profile to non citizen and the liscence
                    profile prof = [SELECT Id FROM Profile WHERE Name='SSP Non Citizen Profile' LIMIT 1];
                    userdata.ProfileId = prof.Id;
                    
                    // recordtype on contact to be updated to non citizen if existing value is citizen
                    SSP_NonCitizenUserLogic.createNonCitizenUserinSF(usr,federationIdentifier,usr.KOG_Role__c,lstCsRoles,AgentId);
                    UpdateConDetails(con.id, 'Non_Citizen', AgentId, federationIdentifier);
                    
                }else{
                    UpdateConDetails(con.id, null, AgentId, federationIdentifier);
                }
                
                // roles needs to be updated to the applicable reoles field on user object
                userdata.ApplicableRoles__c = rolesToBeAssigned(lstCsRoles);
                userdata.UPNId__c=usr.UPNId__c;
                if(!lstStrSSPRoles.isEmpty() && !lstStrSSPRoles.contains('Citizen') && !(String.isBlank(userdata.KOG_Role__c)) && !userdata.KOG_Role__c.equalsIgnoreCase('Citizen') && !userdata.KOG_Role__c.equalsIgnoreCase('Agent')){
                    userdata.KOG_Role__c = 'Non Citizen';
                }
                update userdata;
                // permission sets needs to be updated
                SSP_ResidentLogic.assignPermissionsetClone(federationIdentifier,lstCsRoles);
            }
        }
    }
    
    public static string rolesToBeAssigned(List<String> lstRolesFromKog){
       String strApplicableRolesToUpdate;
        /*[Suresh] RE related change Starts */
        Set<String> setRERoles = new Set<String>();
        for(PublicGroupAssignments__c role : PublicGroupAssignments__c.getall().values()){
            setRERoles.add(role.Name);
        }
        /*[Suresh] RE related change Ends */
        for(KOGRoleMapping__mdt kogrm : [Select Id,DeveloperName,Role_Name__c FROM KOGRoleMapping__mdt WHERE Role_Name__c!=null AND Role_Name__c IN:lstRolesFromKog LIMIT 1000 ]){
            if(String.isNotEmpty(strApplicableRolesToUpdate) && String.isNotBlank(strApplicableRolesToUpdate)){
                if(kogrm.DeveloperName == 'Eligibility_Benefit_Inquiry_User'){
                    strApplicableRolesToUpdate = strApplicableRolesToUpdate+';'+'Eligibility_&_Benefit_Inquiry_User';
                }else if(kogrm.DeveloperName == 'Waiver_Direct_Service_Provider_Superviso'){
                    strApplicableRolesToUpdate = strApplicableRolesToUpdate+';'+'WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR';
                }
                /*[Suresh] RE related change Starts */
                else if(setRERoles.contains(kogrm.Role_Name__c)){
                    if(kogrm.Role_Name__c == 'Citizen'){
                        strApplicableRolesToUpdate = strApplicableRolesToUpdate+';'+'Citizen_Individual';
                    }
                    else{
                        strApplicableRolesToUpdate = strApplicableRolesToUpdate+';'+kogrm.Role_Name__c;
                    }
                }
                /*[Suresh] RE related change End */
                else{
                    strApplicableRolesToUpdate = strApplicableRolesToUpdate+';'+kogrm.DeveloperName;
                }
            }
            else{
                if(kogrm.DeveloperName == 'Eligibility_Benefit_Inquiry_User'){
                    strApplicableRolesToUpdate = 'Eligibility_&_Benefit_Inquiry_User';
                }else if(kogrm.DeveloperName == 'Waiver_Direct_Service_Provider_Superviso'){
                    strApplicableRolesToUpdate = 'WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR';
                }
                /*[Suresh] RE related change Starts */
                else if(setRERoles.contains(kogrm.Role_Name__c)){
                    if(kogrm.Role_Name__c == 'Citizen'){
                        strApplicableRolesToUpdate = 'Citizen_Individual';
                    }
                    else{
                        strApplicableRolesToUpdate = kogrm.Role_Name__c;
                    }
                }
                /*[Suresh] RE related change End */
                else{
                    strApplicableRolesToUpdate = kogrm.DeveloperName;
                }
                
            }
        }
        return strApplicableRolesToUpdate;
    }

    @future 
    public static void UpdateConDetails(id ConId, String RecordTypeNametoUpdate,string AgentId, String federationIdentifier){
        contact con = [SELECT Id,RecordTypeId,RecordType.Name,AgentId__c, KOGSourceId__c FROM Contact WHERE Id=:conid];
        if(String.isNotBlank(RecordTypeNametoUpdate) && String.isNotEmpty(RecordTypeNametoUpdate) && con.RecordType.Name != RecordTypeNametoUpdate ){
            RecordType objContactRecordType = GeneralUtility.fetchRecordType(RecordTypeNametoUpdate, 'Contact');
            con.RecordTypeId = objContactRecordType.Id;
        }
        // Bug no: 393865 Prod Issue 
        if(!String.isBlank(federationIdentifier) && String.isBlank(con.KOGSourceId__c)) {
            con.KOGSourceId__c = federationIdentifier;
        }
        if(String.isNotBlank(AgentId) && String.isNotEmpty(AgentId) && con.AgentId__c!=AgentId){
            con.AgentId__c=AgentId;
        }
        update con;
    }
}