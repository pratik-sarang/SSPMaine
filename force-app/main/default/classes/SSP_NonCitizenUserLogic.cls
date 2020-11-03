/*********************************************************************************************************************************
* Class Name    : SSP_NonCitizenUserLogic 
* Owner         : Deloitte
* Created Date  : 10/04/2020 
* Description   : Community SSO handler class for create and update users
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  
**/
public class SSP_NonCitizenUserLogic{
    public class UserAccessException extends Exception{}
    
    /*********************************************************************************************************************************
    * @author       Srikanth
    * @date         11/11/2019
    * @methodname   createUserinSF()
    * @description  Method to create user when Salesforce doesn't find SAML federationIdentifier match in User
    * @param        User usr, String federationIdentifier
    * @return       User 
    ************************************************************************************************************************************/
    public static User createNonCitizenUserinSF(user usr, String federationIdentifier , String RoleName, List<String> lstcsRoles, string AgentId){
        List<User> lstUsers = new List<User>();
        Contact conRec = new Contact();
        Set<Integer> setIeesIdsNotInMappingTable = new Set<Integer>();
        Set<Integer> setIeesIdsInMappingTable = new Set<Integer>();
        Integer latestIeesId;
        SSP_ResidentLogic.citizenExceptionCapture citizenExp = new SSP_ResidentLogic.citizenExceptionCapture();
        citizenExp.isExceptionFound = false;

        List<Contact_Mapping__c> lstContactMapping = new List<Contact_Mapping__c>();
        List<SSP_ResidentLogic.ContactMappingWrapper> lstContMapWrap = new List<SSP_ResidentLogic.ContactMappingWrapper>();
        Set<String> setContactIds = new Set<String>(); 
        List<Contact_Mapping__c> lstContactMap = new List<Contact_Mapping__c>();
        Map<Integer,Id> mapContactIEESIds = new Map<Integer,Id>();
        List<Contact> lstExistingContacts = [SELECT Id,KOGSourceId__c,AgentId__c,Gender__c,SSN__c,Birthdate,GenderCode__c FROM Contact WHERE KOGSourceId__c =:federationIdentifier OR (AgentId__c!=null AND AgentId__c=:AgentId)];
        WebServiceSettings__c mciConfig = WebServiceSettings__c.getValues(SSP_GlobalConstants.MCI_ENTITIY_SEARCH);
        String sourceName = mciConfig.Source_System__c;
        SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper = SSP_ResidentLogic.getIndividualInfo(federationIdentifier,usr,sourceName);
        latestIeesId = SSP_ResidentLogic.getlatestIEEsid(returnResultMCIwrapper.setIeesIds);
        if(lstExistingContacts.isEmpty()) {
            conRec = createNonCitizenContact(usr,AgentId, returnResultMCIwrapper);
	    lstUsers.add( createNonCitizenUser(usr, federationIdentifier, conRec,RoleName,lstcsRoles) ); 
        } else {
            conRec = lstExistingContacts[0];
            conRec = updateNonCitizenContact(conRec, returnResultMCIwrapper);
            if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.ContactId.isAccessible() 
                && Schema.sObjectType.User.fields.Id.isAccessible()) {
		lstUsers = [SELECT Id,ContactId FROM User WHERE FederationIdentifier=:usr.FederationIdentifier LIMIT 1];
            }
            if(lstUsers.isEmpty()) {
                lstUsers.add( createNonCitizenUser(usr, federationIdentifier, conRec,RoleName,lstcsRoles) );  
            }
        }
        if(!returnResultMCIwrapper.setIeesIds.isEmpty()) {
            //if MCI returns any IEES ID's.
            if (Schema.sObjectType.Contact_Mapping__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() 
            && Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible()) {
            lstContactMap = [SELECT Contact__c, IEES_Id__c,Group_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN:returnResultMCIwrapper.setIeesIds ];
            }
        }
        if(conRec != null && !lstContactMap.isEmpty()) {
            SSP_ResidentLogic.handleDuplicateMembers(conRec.Id,lstContactMap);
        }
        if(!returnResultMCIwrapper.setIeesIds.isEmpty()) { 
            //if MCI returns any IEES ID's.
            if (Schema.sObjectType.Contact_Mapping__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() 
            && Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible()) {
            lstContactMap = [SELECT Contact__c, IEES_Id__c,Group_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN:returnResultMCIwrapper.setIeesIds ];
			}
		}
        if(!lstContactMap.isEmpty()) {
			//compare if all received IEES id's belongs to the same contact
			Id contactId = lstContactMap[0].Contact__c;
			for(Contact_Mapping__c conMap :lstContactMap){
				mapContactIEESIds.put(integer.valueOf(conMap.IEES_Id__c),conMap.Contact__c);
				SSP_ResidentLogic.ContactMappingWrapper cmw = new SSP_ResidentLogic.ContactMappingWrapper(conMap.Contact__c,integer.valueOf(conMap.IEES_Id__c),conMap.Group_Id__c);
				lstContMapWrap.add(cmw);
				setIeesIdsInMappingTable.add(integer.valueOf(conMap.IEES_Id__c));
				setContactIds.add(conMap.Contact__c);
			}
		}
		If(!returnResultMCIwrapper.setIeesIds.isEmpty()) {
			//compare the IEES ids which received from MCI and not in Mapping table
			for(Integer ieesids : returnResultMCIwrapper.setIeesIds){
				if(!setIeesIdsInMappingTable.contains(ieesids)){
					setIeesIdsNotInMappingTable.add(ieesids);
				}
			}
			if(!setIeesIdsNotInMappingTable.isEmpty()) {
				//create contact mapping table for the remaining received IEES ids 
				for(Integer IEESId : setIeesIdsNotInMappingTable) {
            Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
            objContactMapping.Contact__c = conRec.Id;
					objContactMapping.IEES_Id__c = IEESId;
					//check if IEES id belong to other contact
					if(!lstContMapWrap.iSEmpty()){
						for(SSP_ResidentLogic.ContactMappingWrapper cmw : lstContMapWrap){
							if(cmw.ieesId == IEESId ){
								objContactMapping.Group_Id__c = cmw.groupId;
							} else {
								objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
							}
						}
					} else {
						objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
					}
            lstContactMapping.add(objContactMapping);
				}
            if(!lstContactMapping.isEmpty()){
                try{
                    if (Schema.sObjectType.Contact_Mapping__c.isCreateable()) {
                        Insert lstContactMapping;
                    }
                }catch(Exception ex){
                    List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                    publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                        ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_CONTACT_MAPPING, Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, 
                                                        Message__c =  ex.getMessage() ,SourceFunction__c = 'createUserinSF'));
                    if(publishEvents.size()>0){
                        EventBus.publish(publishEvents);
                    }
						citizenExp.isExceptionFound = true;
						citizenExp.ExceptionCode = 'ERR009';
					}
							
				}
			}
		}
        return lstUsers[0];
    }

    @future
    public static void updateConMappingRecords(String sConMappingRecords) {
        List<Contact_Mapping__c> lstConMapping;
        if(String.isNotBlank(sConMappingRecords)) {
            lstConMapping = (List<Contact_Mapping__c>)JSON.deserialize(sConMappingRecords, List<Contact_Mapping__c>.class);

        }
        if(lstConMapping != null && !lstConMapping.isEmpty()) {
            insert lstConMapping;
        }
    
    }

    
    /*********************************************************************************************************************************
    * @author       Srikanth
    * @date         11/11/2019
    * @methodname   createNonCitizenContact()
    * @description  Method to create Contact in the Salesforce system for the SSP system Roles
    * @param        user usr,String Zipcode
    * @return       Contact 
    ************************************************************************************************************************************/
    public static Contact createNonCitizenContact(user usr,string AgentId, SSP_ResidentLogic.MCIResponseWrapper MCIResp) {
    	
    	RecordType objAccountRecordType = GeneralUtility.fetchRecordType('Citizen', 'Account');
        //RecordType objAccountRecordType = GeneralUtility.fetchRecordType('Non_Citizen_Account', 'Account');
        Account acc = new Account();
        acc.Name = usr.FirstName+' '+usr.LastName;
        acc.RecordTypeId = objAccountRecordType.Id;
    
        if (Schema.sObjectType.Account.isCreateable()) {
            insert acc;
        }
        
        RecordType objRecordType = GeneralUtility.fetchRecordType('Non_Citizen', 'Contact');
        Contact con = new Contact();
        con.RecordTypeId = objRecordType.Id;
        con.FirstName = usr.FirstName;  
        con.LastName = usr.LastName;
        con.Email = usr.Email;
        con.MiddleName = usr.MiddleName;
        con.PermissionsLevel__c = 'Admin';
        con.Status__c = 'Active';
        con.TrainingLevel__c = 'Complete';
        con.KOGSourceId__c = usr.FederationIdentifier; 
        con.AccountId  = acc.Id;
    	con.AgentId__c=AgentId;
        if(MCIResp != null && !string.isNotBlank(MCIResp.Gender)) {
            con.Gender__c = MCIResp.Gender;
            con.GenderCode__c = MCIResp.Gender == 'Male' ? 'M' : (MCIResp.Gender == 'Female' ? 'F' : 'U');
        }
        if(MCIResp != null && MCIResp.DOB != null) {
            con.Birthdate=MCIResp.DOB.date();
        }
        if(MCIResp != null && string.isNotBlank(MCIResp.SSN)) {
            con.SSN__c = MCIResp.SSN;
        } 
        try{
            if (Schema.sObjectType.Contact.isCreateable()) {
                insert con;
            }
        }catch(exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_CONTACT_RECORD, Source__c =SSP_GlobalConstants.SSP_NON_CITIZEN_USER_LOGIN, 
                                              Message__c =  ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.CREATE_CITIZEN_CONTACT));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new UserAccessException('ERR007');
        }
        return con;
    }

    /*********************************************************************************************************************************
    * @author                   : Rajeev
    * @date                     : 10/05/2020
    * @methodname               : updateNonCitizenContact()
    * @description              : Method to Update Non Citizen Contact in Salesforce
    * @param objCon             : User Associated Contact Record 
    * @param MCIResp            : Response Wrapper for MCI 
    * @return                   : Associated Contact Record 
    ************************************************************************************************************************************/
    public static Contact updateNonCitizenContact(Contact objCon, SSP_ResidentLogic.MCIResponseWrapper MCIResp) {
        Boolean isUpdate = false;
        if(MCIResp != null && MCIResp.DOB != null && MCIResp.DOB.date() != objCon.Birthdate) {
            objCon.Birthdate = MCIResp.DOB.date();
            isUpdate = true;
        }
        if(MCIResp != null && !String.isBlank(MCIResp.SSN) && MCIResp.SSN != objCon.SSN__c) {
            objCon.SSN__c = MCIResp.SSN;
            isUpdate = true;
        }
        if(MCIResp != null && !String.isBlank(MCIResp.Gender) && MCIResp.Gender != objCon.Gender__c) {
            objCon.Gender__c = MCIResp.Gender;
            objCon.GenderCode__c = MCIResp.Gender == 'Male' ? 'M' : (MCIResp.Gender == 'Female' ? 'F' : 'U'); //SSP Related Changes
            isUpdate = true;
        }

        if(isUpdate) {
            update objCon;
        }
        return objCon;
    }

    /*********************************************************************************************************************************
    * @author       Srikanth
    * @date         11/11/2019
    * @methodname   createNonCitizenUser()
    * @description  Method to create User in the Salesforce system
    * @param        User usr, String federationIdentifier, Contact con
    * @return       User 
    ************************************************************************************************************************************/
    public static User createNonCitizenUser(User usr, String federationIdentifier, Contact con, String RoleName, List<String> lstcsRoles){
        
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
        usr.ContactId = con.id;
        usr.FederationIdentifier = federationIdentifier;
        
        String values  = SSPCitizenJITHandler.rolesToBeAssigned(lstcsRoles);
        if(usr.KOG_Role__c != 'Citizen'){
            usr.KOG_Role__c = 'Non Citizen';
        }
        usr.ApplicableRoles__c = values!=null ? values : '';
        usr = JitHelper.sanitiseUser(usr);
		
		//iron dome changes 07/08
		List <Profile> prof = new List <Profile>();
		if (Schema.sObjectType.profile.isAccessible() && Schema.sObjectType.profile.fields.Id.isAccessible()) {
			prof = [Select Id from Profile where Name =: SSP_GlobalConstants.SSP_Non_Citizen_Profile];
		}
        usr.ProfileId = prof[0].id;

        if (Schema.sObjectType.User.isCreateable()) {
            try{
                insert usr;
            }catch(exception ex){
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_CITIZEN_USER, Source__c =SSP_GlobalConstants.SSP_NON_CITIZEN_USER_LOGIN, Message__c = ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.CREATE_CITIZEN_USER));
                if(publishEvents.size()>0){
                    EventBus.publish(publishEvents);
                }
                throw new UserAccessException('ERR005');
            }
        }
        return usr; 
    }

    

    /*********************************************************************************************************************************
    * @author       Rajeev
    * @date         11/11/2019
    * @methodname   updateNonCitizenUser()
    * @description  Method to create User in the Salesforce system
    * @param        User usr, String federationIdentifier, Contact con
    * @return       User 
    ************************************************************************************************************************************/
    /*
    public static User updateNonCitizenUser(User usr, String federationIdentifier) {
        // Mehtod is used in SSPCitizenJITHandler
        // Write the logic for the same
        return usr; 
    }
    */
    /*********************************************************************************************************************************
    * @author       Rajeev
    * @date         11/11/2019
    * @methodname   updateNonCitizenUser()
    * @description  Method to create User in the Salesforce system
    * @param        User usr, String federationIdentifier, Contact con
    * @return       User 
    ************************************************************************************************************************************/
    public static User updateNonCitizenUserinSF(User usr, String agentId, String federationIdentifier) {
        // Mehtod is used in SSPCitizenJITHandler
        // Write the logic for the same
        return usr; 
    }    
}