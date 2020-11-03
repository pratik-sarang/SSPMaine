/*********************************************************************************************************************************
* Class Name    : RE_ResidentLogic 
* Owner         : Deloitte
* Created Date  : 11/05/2019 
* Description   : Community SSO handler class for create and update users
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  11/05/2019    Srikanth      Community Resident Logic for SSO
**/
public with sharing class RE_ResidentLogic{
    
    //Custom Exception for Resident
    public class UserAccessException extends Exception{}
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @methodname   createUserinSF()
* @description  Method to create user when Salesforce doesn't find SAML federationIdentifier match in User
* @param        User usr, String federationIdentifier
* @return       User 
************************************************************************************************************************************/
    public static citizenExceptionCapture createUserinSF(user usr, String federationIdentifier ){
        
        citizenExceptionCapture citizenExp = new citizenExceptionCapture();
        citizenExp.isExceptionFound = false;
        Boolean bContact = false;
        Set<Id> setContactIds = new Set<Id>(); 
        Set<Integer> setIeesIds = new Set<Integer>(); 
        Set<Integer> setIeesIdsNotInMappingTable = new Set<Integer>();
        Set<Integer> setIeesIdsInMappingTable = new Set<Integer>();
        Integer latestIeesId;
        Id latestContactId ;
        map<Integer,Id> mapContactIEESIds = new map<Integer,Id>();
        List<Contact_Mapping__c> lstContactMapping = new List<Contact_Mapping__c>();
        List<ContactMappingWrapper> lstContMapWrap = new List<ContactMappingWrapper>();
        
        //SAML request response 
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyUser = (usr.Id == null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
        switch on (switchCaseKeyUser) {
        when SWITCH_SUCCESS {  
            WebServiceSettings__c mciConfig = WebServiceSettings__c.getValues('MCI Entity Search');
            String sourceName = mciConfig.Source_System__c; 
            //retreving the IEES's ids recevied from MCI system for the federation id received from KOG
            MCIResponseWrapper returnResultMCIwrapper =    getIndividualInfo(federationIdentifier,usr,sourceName);
            //to get the single latest IEES Id which is received from MCI system
            
            latestIeesId = getlatestIEEsid(returnResultMCIwrapper.setIeesIds);
            //Create Contact,Account,User if MCI doesnt returns any IEES ID's. 
            if(returnResultMCIwrapper.setIeesIds.isEmpty()){ 
                // Creation of Citizen Contact & User.                
                Contact con = createCitizenContact(usr,returnResultMCIwrapper.DOB,returnResultMCIwrapper.Gender); 
                usr = createCitizenUser(usr, federationIdentifier, con);
            }else{ //if MCI returns any IEES ID's.
                List<Contact_Mapping__c> lstContactMap = (Contact_Mapping__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible()&&  Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible()&&  Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible())?[SELECT Contact__c,IEES_Id__c,Group_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN:returnResultMCIwrapper.setIeesIds ]: new List<Contact_Mapping__c>() ;
                if(!lstContactMap.isEmpty()){
                    //compare if all received IEES id's belongs to the same contact
                    Id contactId = lstContactMap[0].Contact__c;
                    for(Contact_Mapping__c conMap :lstContactMap){
                        mapContactIEESIds.put(integer.valueOf(conMap.IEES_Id__c),conMap.Contact__c);
                        ContactMappingWrapper cmw = new ContactMappingWrapper(conMap.Contact__c,integer.valueOf(conMap.IEES_Id__c),conMap.Group_Id__c);
                        lstContMapWrap.add(cmw);
                        setIeesIdsInMappingTable.add(integer.valueOf(conMap.IEES_Id__c));
                        setContactIds.add(conMap.Contact__c);
                        if(conMap.Contact__c != contactId){
                            bContact = true; //true if not belong to the same contact
                        }
                    }
                    //compare the IEES ids which received from MCI and not in Mapping table
                    for(Integer ieesids : returnResultMCIwrapper.setIeesIds){
                        if(!setIeesIdsInMappingTable.contains(ieesids)){
                            setIeesIdsNotInMappingTable.add(ieesids);
                        }
                    }
                    //if returned IEES id's belong to same contact
                    if(!bContact){
                        List<User> lstexistinguser = new List<User>();
                         if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.ContactId.isAccessible() ){
                            lstexistinguser  = [SELECT ID,ContactId FROM User WHERE ContactId =:contactId];  
                         }
                       
                        if(!lstexistinguser.isEmpty()){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                              ErroLog__c= 'ERROR LOG', Source__c ='RE_ResidentLogic', 
                                                              Message__c ='ERROO3 - Looks like you already have different account, Please login using that Account' ,SourceFunction__c = 'createUserinSF'));
                            if(publishEvents.size()>0){
                                EventBus.publish(publishEvents);
                            }
                            citizenExp.isExceptionFound = true;
                            citizenExp.ExceptionCode = 'ERROO3';

                        }else{
                            //create new user if user doesn't exist in the system with existing contact id
                            //create contact mapping table
                            contact cntact = (Contact.getSObjectType().getDescribe().isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible())?[SELECT Id FROM Contact WHERE Id =:contactId LIMIT 1]: new Contact();
                            usr = createCitizenUser(usr, federationIdentifier, cntact);
                            //create contact mapping table for the remaining received IEES ids 
                            for(Integer IEESId : setIeesIdsNotInMappingTable){
                                Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                                objContactMapping.Contact__c = contactId;
                                objContactMapping.IEES_Id__c = IEESId;
                                //check if IEES id belong to other contact
                                if(!lstContMapWrap.iSEmpty()){
                                    for(ContactMappingWrapper cmw : lstContMapWrap){
                                        if(cmw.ieesId == IEESId ){
                                            objContactMapping.Group_Id__c = cmw.groupId;
                                        }else{
                                            objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                        }
                                    }
                                }else{
                                    objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                }
                                lstContactMapping.add(objContactMapping);
                            }
                            if(!lstContactMapping.isEmpty() && Schema.sObjectType.Contact_Mapping__c.isCreateable()){
                                try{
                                    Insert lstContactMapping;
                                }catch(Exception ex){
                                    List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR009', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'Error while Contact Mapping Record Creation', Source__c ='RE_ResidentLogic', Message__c =  ex.getMessage() ,SourceFunction__c = 'createUserinSF'));
                                    if(publishEvents.size()>0){ EventBus.publish(publishEvents);}
                                    citizenExp.isExceptionFound = true; citizenExp.ExceptionCode = 'ERR009';
                                 }
                                
                            }
                        }
                    }else{ // is IEES ids's doesn't belong to the same contact
                        List<User> lstUser = [SELECT Id,ContactId from User where ContactId IN : setContactIds];
                        if(!lstUser.isEmpty()){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                              ErroLog__c= 'ERROR LOG', Source__c ='RE_ResidentLogic',Log_Code__c = 'ERROO3', 
                                                              Message__c ='ERROO3 - Looks like you already have different account, Please login using that Account' ,SourceFunction__c = 'createUserinSF'));
                            if(publishEvents.size()>0){
                                EventBus.publish(publishEvents);
                            }
                            citizenExp.isExceptionFound = true;
                            citizenExp.ExceptionCode = 'ERR003';
                            //throw new UserAccessException('ERR003');
                        }else{
                            latestIeesId = getlatestIEEsid(setIeesIdsInMappingTable);
                            //Create system Alerts
                            //Get the Contact with latest IEES ID
                            //User newUser = new User();
                            //newUser.ContactId = Get the Contact with latest IEES ID;
                            //Insert newUser
                            //CreateMappingTable;
                            //KOjashree
                            Contact con = new Contact();
                             if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible() ){
                       
                            con = [SELECT Id FROM Contact WHERE Id=:mapContactIEESIds.get(latestIeesId) LIMIT 1];
                                 }
                            usr = createCitizenUser(usr, federationIdentifier, con);
                            List<SystemAlert__c> lstSystemAlerts = new List<SystemAlert__c>();
                            for(Integer IEESId : setIeesIdsNotInMappingTable){
                                Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                                objContactMapping.Contact__c = con.Id;
                                objContactMapping.IEES_Id__c = IEESId;
                                //check if IEES id belong to other contact
                                if(!lstContMapWrap.isEmpty()){
                                    for(ContactMappingWrapper cmw : lstContMapWrap){
                                        if(cmw.ieesId == IEESId ){
                                            objContactMapping.Group_Id__c = cmw.groupId;
                                            SystemAlert__c objSystemAlert = new SystemAlert__c();
                                            objSystemAlert.AlertDetails__c = 'This is a duplicate entry';objSystemAlert.ParentId__c = con.Id;objSystemAlert.IEESId__c = IEESId; objSystemAlert.GroupId__c = cmw.groupId;
                                            lstSystemAlerts.add(objSystemAlert);
                                        }else{
                                            objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                        }
                                    }
                                }else{
                                    objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                }
                                lstContactMapping.add(objContactMapping);
                            }
                            if(!lstContactMapping.isEmpty()&& Schema.sObjectType.Contact_Mapping__c.isCreateable()){

                                try{
                                    Insert lstContactMapping;
                                }catch(Exception ex){
                                    List<ErrorLog__e> publishEvents = new List<ErrorLog__e>(); publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR009', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'Error while Contact Mapping Record Creation', Source__c ='RE_ResidentLogic', Message__c =  ex.getMessage() ,SourceFunction__c = 'createUserinSF'));
                                    if(publishEvents.size()>0){EventBus.publish(publishEvents); }
                                    citizenExp.isExceptionFound = true;citizenExp.ExceptionCode = 'ERR009';
                                    
                                }
                            }
                            if(!lstSystemAlerts.isEmpty() && Schema.sObjectType.SystemAlert__c.isCreateable()){

                                try{
                                    Insert lstSystemAlerts;
                                }catch(Exception ex){
                                    List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR010', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'Error while Contact Mapping Record Creation', Source__c ='RE_ResidentLogic', Message__c =  ex.getMessage() ,SourceFunction__c = 'createUserinSF'));
                                    if(publishEvents.size()>0){EventBus.publish(publishEvents);}
                                    citizenExp.isExceptionFound = true;  citizenExp.ExceptionCode = 'ERR010';                                                                   
                                 }
                            }
                        }
                    }
                }else{
                    //creation of citizen Contact & User. 
                    //Create ContactMapping
                    Contact con = createCitizenContact(usr,returnResultMCIwrapper.DOB,returnResultMCIwrapper.Gender);
                    
                    usr = createCitizenUser(usr, federationIdentifier, con);
                    for(Integer IEESId : returnResultMCIwrapper.setIeesIds){
                        Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                        objContactMapping.Contact__c = con.Id;
                        objContactMapping.IEES_Id__c = IEESId;
                        //check if IEES id belong to other contact
                        if(!lstContMapWrap.iSEmpty()){
                            for(ContactMappingWrapper cmw : lstContMapWrap){
                                if(cmw.ieesId == IEESId ){
                                    objContactMapping.Group_Id__c = cmw.groupId;
                                }else{
                                    objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                }
                            }
                        }else{
                            objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                        }
                        lstContactMapping.add(objContactMapping);
                    }
                    if(!lstContactMapping.isEmpty() && Schema.sObjectType.Contact_Mapping__c.isCreateable()){

                        try{
                            Insert lstContactMapping;
                        }catch(Exception ex){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>(); publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR009', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'Error while Contact Mapping Record Creation', Source__c ='RE_ResidentLogic',Message__c =  ex.getMessage() ,SourceFunction__c = 'createUserinSF')); 
                            if(publishEvents.size()>0){ EventBus.publish(publishEvents); }
                            citizenExp.isExceptionFound = true; citizenExp.ExceptionCode = 'ERR009';
                           
                        }
                    }
                }
            }
        }
     }
        citizenExp.usr = usr;
        return citizenExp;
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @methodname   updateUserinSF()
* @description  Method to update user when Salesforce finds SAML federationIdentifier match to a User
* @param        User usr, String federationIdentifier
* @return       User 
************************************************************************************************************************************/
    
    public static User updateUserinSF(user usrRec, String federationIdentifier){

        User usr = new User();
        if (Schema.sObjectType.User.fields.ContactId.isAccessible() && Schema.sObjectType.User.fields.FederationIdentifier.isAccessible()) {
            usr=[SELECT Id,ContactId FROM User WHERE FederationIdentifier=:usrRec.FederationIdentifier LIMIT 1];
        }
        Boolean bContact = false;
        Set<Id> setContactIds = new Set<Id>();
        Set<Integer> setIeesIds = new Set<Integer>();
        Set<Integer> setIeesIdsNotInMappingTable = new Set<Integer>();
        Set<Integer> setIeesIdsInMappingTable = new Set<Integer>();
        List<Contact_Mapping__c> lstContactMapping = new List<Contact_Mapping__c>();
        List<ContactMappingWrapper> lstContMapWrap = new List<ContactMappingWrapper>();
        MCIResponseWrapper returnResultMCIwrapper= getIndividualInfo(federationIdentifier,usr,'Kog');
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyMCIWrapper = (returnResultMCIwrapper!=null && !returnResultMCIwrapper.setIeesIds.isEmpty())? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
        switch on (switchCaseKeyMCIWrapper) {
        when SWITCH_SUCCESS {  
            List<Contact_Mapping__c> lstContactMap = new List<Contact_Mapping__c>();
            if (Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible()
            && Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible() ) {
            lstContactMap= [SELECT Contact__c,IEES_Id__c,Group_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN:returnResultMCIwrapper.setIeesIds ];
            }
            if(!lstContactMap.isEmpty()){
                ID contactId = lstContactMap[0].Contact__c;
                User objUser = [SELECT ID from User where ContactID =: lstContactMap[0].Contact__c];
                ID userID = objUser.Id;
                integer ieesIdMap = integer.valueOf(lstContactMap[0].IEES_Id__c);
                for(Contact_Mapping__c conMap :lstContactMap){
                    setIeesIdsInMappingTable.add(integer.valueOf(conMap.IEES_Id__c));
                    setContactIds.add(conMap.Contact__c);
                    ContactMappingWrapper cmw = new ContactMappingWrapper(conMap.Contact__c,integer.valueOf(conMap.IEES_Id__c),conMap.Group_Id__c);
                    lstContMapWrap.add(cmw);

                }
                List<User> lstUser = [SELECT ID from User Where ContactId IN :setContactIds];
                for(User u : lstUser){
                    if(u.Id != userId){
                        bContact = true;
                    }
                }
                
                for(Integer IEESID : returnResultMCIwrapper.setIeesIds){
                    if(!setIeesIdsInMappingTable.contains(IEESID)){
                        setIeesIdsNotInMappingTable.add(IEESID);
                    }
                }
                if(!bContact){ //all IEES belong to single contact
                    //usr = [SELECT Id FROM User WHERE ContactId=:contactId LIMIT 1];
                    //Allow User to login using Existing Contact Associated
                    //Create Contact Mapping Table entry
                    for(Integer IEESId : setIeesIdsNotInMappingTable){
                        Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                        objContactMapping.Contact__c = contactId;
                        objContactMapping.IEES_Id__c = IEESId;
                        //check if IEES id belong to other contact
                        if(!lstContMapWrap.isEmpty()){
                            for(ContactMappingWrapper cmw : lstContMapWrap){
                                if(cmw.ieesId == IEESId ){
                                    objContactMapping.Group_Id__c = cmw.groupId;
                                }else{
                                    objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                }
                            }
                        }else{
                            objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                        }
                        
                        lstContactMapping.add(objContactMapping);
                    }
                    if(!lstContactMapping.isEmpty()){

                        insertListSObject(lstContactMapping,'Contact Mapping');
                    }
					//deleting the Contact Mapping with less IEES Ids received from MCI #Start
					map<integer,Contact_Mapping__c> mapContactMapping = new map<integer,Contact_Mapping__c>();
					Set<Id> setContactMapIds = new Set<Id>();
                    List<Contact_Mapping__c> lstCntMapng = (Contact_Mapping__c.getSObjectType().getDescribe().isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible())? [SELECT Id,IEES_Id__c,Contact__c FROM Contact_Mapping__c WHERE Contact__c=:usr.ContactId]: new List<Contact_Mapping__c>();
                    for(Contact_Mapping__c conMap : lstCntMapng){
						mapContactMapping.put(integer.valueOf(conMap.IEES_Id__c),conMap);
					}
					
					Set<integer> setIntegervalue = new Set<Integer>();
					for(integer intIeesIdDelete : returnResultMCIwrapper.setIeesIds){
						setIntegervalue.add(intIeesIdDelete);
					}
					
					for(Integer intIeesIdDelete : mapContactMapping.keyset()){
						if(!setIntegervalue.contains(intIeesIdDelete)){
							setContactMapIds.add(mapContactMapping.get(intIeesIdDelete).Id);
						}
					}
					
					if(!setContactMapIds.isEmpty()){
                        List<Contact_Mapping__c> lstContactMappingDelete = 
                        (Contact_Mapping__c.getSObjectType().getDescribe().isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Id.isAccessible()) ? [SELECT Id FROM Contact_Mapping__c WHERE Id=:setContactMapIds] : new List<Contact_Mapping__c>();
                        try{
                            if(!lstContactMappingDelete.isEmpty() && Schema.sObjectType.Contact_Mapping__c.isAccessible()&& Schema.sObjectType.Contact_Mapping__c.isDeletable()){
                                delete lstContactMappingDelete;
                            }
                            //delete [SELECT Id FROM Contact_Mapping__c WHERE Id=:setContactMapIds ];
                        }
                        catch(exception ex){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                              ErroLog__c= 'ERROR LOG', Source__c ='RE_ResidentLogic', 
                                                              Message__c ='ERRO14 - issue occured while deleting the Contact Mapping Record' ,SourceFunction__c = 'updateUserinSF'));
                            if(publishEvents.size()>0){
                                EventBus.publish(publishEvents);
                            }
                            throw new UserAccessException('ERR014');
                        }
					}
					
					//#END
                    
                }else{
                    //Allow User to login using Existing Contact Associated
                    //Create Contact Mapping Tabel entry
                    //System Alerts
                    for(Integer IEESId : setIeesIdsNotInMappingTable){
                        Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                        // added to debug the issue as it was not replicating in lower env. We will remove it once got the root cause
			
			objContactMapping.Contact__c = usr.ContactId;
                        objContactMapping.IEES_Id__c = IEESId;
                        //check if IEES id belong to other contact
                        if(!lstContMapWrap.isEmpty()){
                            for(ContactMappingWrapper cmw : lstContMapWrap){
                                if(cmw.ieesId == IEESId ){
                                    objContactMapping.Group_Id__c = cmw.groupId;
                                }else{
                                    objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                }
                            }
                        }else{
                            objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                        }
                        
                        lstContactMapping.add(objContactMapping);
                    }
					list<SystemAlert__c> lstSystemAlert = new list<SystemAlert__c>();
                    Contact_Mapping__c conMapGroupId = (Contact_Mapping__c.getSObjectType().getDescribe().isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible())?[SELECT Id,Group_Id__c,Contact__c FROM Contact_Mapping__c WHERE Contact__c=:usr.ContactId Limit 1  ] : new Contact_Mapping__c();
					for(Contact_Mapping__c conMap :lstContactMap){
						for(integer intIeesID :returnResultMCIwrapper.setIeesIds){
							if(intIeesID == conMap.IEES_Id__c && usr.contactId != conMap.Contact__c ){
								SystemAlert__c sysAlert = new SystemAlert__c();
								sysAlert.AlertDetails__c = 'This is a duplicate entry';
								sysAlert.ParentId__c = usr.contactId;
								sysAlert.IEESId__c = conMap.IEES_Id__c;
								sysAlert.GroupId__c = conMapGroupId.Group_Id__c;
								lstSystemAlert.add(sysAlert);
							}
						}
						conMap.Group_Id__c = conMapGroupId.Group_Id__c;
						lstContactMapping.add(conMap);
					}
					
                    if(!lstSystemAlert.isEmpty() && Schema.sObjectType.SystemAlert__c.isCreateable()){
						try{
                           Insert lstSystemAlert; 
                        }catch(Exception ex){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>(); publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR010', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'ERR010 - Unhandled exception during System Alert record Creation', Source__c ='RE_ResidentLogic',Message__c =  ex.getMessage() ,SourceFunction__c = 'updateUserinSF'));
                            if(publishEvents.size()>0){ EventBus.publish(publishEvents); }
                            throw new UserAccessException('ERR010');
                        }
					}
                    if(!lstContactMapping.isEmpty()){
                        try{
                           upsert lstContactMapping; 
                        }catch(Exception ex){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>(); publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR009', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'ERR009 - Unhandled exception during Contact Mapping record Upsert', Source__c ='RE_ResidentLogic', Message__c =  ex.getMessage() ,SourceFunction__c = 'updateUserinSF'));
                            if(publishEvents.size()>0){ EventBus.publish(publishEvents); }                                
                            throw new UserAccessException('ERR009');
                        }
                    }
                }
                
            }else{
                //Create Mapping Table entry
                //Allow User to Login.
                for(Integer IEESId : returnResultMCIwrapper.setIeesIds){
                    Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                    objContactMapping.Contact__c = usr.ContactId;
                    objContactMapping.IEES_Id__c = IEESId;
                    //check if IEES id belong to other contact
                    if(!lstContMapWrap.isEmpty()){
                        for(ContactMappingWrapper cmw : lstContMapWrap){
                            if(cmw.ieesId == IEESId ){
                                objContactMapping.Group_Id__c = cmw.groupId;
                            }else{
                                objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                            }
                        }
                    }else{
                        objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                    }
                    lstContactMapping.add(objContactMapping);
                }
                if(!lstContactMapping.isEmpty()){
                    
                    insertListSObject(lstContactMapping,'Contact Mapping');
                }
            }
        }
     }
        
        return usr;
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @methodname   getIndividualInfo()
* @description  Method to get all IEES id's returned by MCI system for the federation Id match
* @param        string federationId,user usr,String StrSourceSystemName
* @return       set<Integer> 
************************************************************************************************************************************/
    
    public static MCIResponseWrapper getIndividualInfo(string federationId,user usr,String strSourceSystemName){
        set<Integer> setIeesIds = new set<Integer>();
        boolean boolIsRecordfound = false;
        kyHbeMciDatacontracts.MciEntitySearchResponse res =MciServiceHandler.getIndividualBenefindId(federationId,usr,StrSourceSystemName);
        String requestSentToMCI = 'FederationIdentifier:'+federationId+',User:'+JSON.serialize(usr)+',SourceSystemName:'+StrSourceSystemName;
        res=MciServiceHandler.getIndividualBenefindId(federationId,usr,StrSourceSystemName);
        DateTime Dob;
        String Gender='';
        MCIResponseWrapper returnResultMCIwrapper;
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyResponse = (res != null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
        switch on (switchCaseKeyResponse) {
        when SWITCH_SUCCESS {  
            schemasDatacontractOrg200407KyHbe.ArrayOfEntitySearchResponse result= res.result;
            List<kyHbeMciDatacontracts.SourceSystem> lstofSourceSystems = new List<kyHbeMciDatacontracts.SourceSystem>();        
            boolIsRecordfound = (res.IsRecordFound == null || res.IsRecordFound==false) ? false:true;
            if(boolIsRecordfound){
                List<schemasDatacontractOrg200407KyHbe.EntitySearchResponse> lstofEntitySearchResps = result.EntitySearchResponse;
                if(lstofEntitySearchResps!= null && !lstofEntitySearchResps.isEmpty()){
                    for(schemasDatacontractOrg200407KyHbe.EntitySearchResponse eachRes : lstofEntitySearchResps){
                        DOB=eachRes.Dob;
                        Gender=eachRes.Gender;
                        kyHbeMciDatacontracts.ArrayOfSourceSystem eachSource = eachRes.Source;
                        lstofSourceSystems = eachSource.SourceSystem;
                    }
                }
                for(kyHbeMciDatacontracts.SourceSystem eachRecord :lstofSourceSystems){
                    if(eachRecord.SourceSystemName.equalsIgnoreCase('HBE')){
                        string IndividaulId = eachRecord.SourceIndividualId;
                        setIeesIds.add(Integer.valueof(IndividaulId));
                    }
                }
                returnResultMCIwrapper= new MCIResponseWrapper(setIeesIds,DOB,Gender);                
            }
            else{
                returnResultMCIwrapper= new MCIResponseWrapper(setIeesIds,DOB,Gender);                
            }
        }
        when SWITCH_FAILURE { 
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'ERROR LOG',Log_Code__c = 'ERR004',Integration_Payload__c =requestSentToMCI ,ResponseData__c =JSON.serialize(res), Source__c ='RE_ResidentLogic', Message__c ='ERR004 - Null Response from MCI for federation Id'+federationId ,SourceFunction__c = 'getIndividualInfo'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new UserAccessException('ERR004');
        }
     }
        return returnResultMCIwrapper;
    }
    
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @methodname   createCitizenUser()
* @description  Method to create User in the Salesforce system
* @param        User usr, String federationIdentifier, Contact con
* @return       User 
************************************************************************************************************************************/
    
    public static User createCitizenUser(User usr, String federationIdentifier, Contact con){
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
        List <Profile> prof =new List<Profile>();
        if (Schema.sObjectType.Profile.fields.Id.isAccessible()) {
          prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        }
        if(!prof.isEmpty()){
        usr.ProfileId = prof[0].id;
        }
        Database.SaveResult sr = database.insert(usr,false);
        if (!sr.isSuccess()){
            String msg = '';
            for(Database.Error err : sr.getErrors()) {
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            }
            //Platform Event for storing Error Log
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',Log_Code__c = 'ERR005',ErroLog__c= 'Error while creating citizen user', Source__c ='RE_ResidentLogic', Message__c = msg ,SourceFunction__c = 'createCitizenUser'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new UserAccessException('ERR005');
        }
        return usr; 
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @methodname   createCitizenContact()
* @description  Method to create Contact in the Salesforce system
* @param        user usr,String Zipcode
* @return       Contact 
************************************************************************************************************************************/
    
    public static Contact createCitizenContact(user usr,DateTime DOB, String Gender){
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con = new Contact();
        con.RecordTypeId = objRecordType.Id;
        con.FirstName = usr.FirstName;
        con.Gender__c=Gender;
        if(DOB!=null){
            con.Birthdate=DOB.date();
        }        
        con.LastName = usr.LastName;
        con.Email = usr.Email;
        try{
            RE_SharingByPassCtrl.insertSobject(con.getSobjectType(), con);
        }catch(exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();  publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(),Log_Code__c = 'ERR007', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'Error while creating a contact record in salesforce', Source__c ='RE_ResidentLogic', Message__c =  ex.getMessage() ,SourceFunction__c = 'createCitizenContact')); 
            if(publishEvents.size()>0){EventBus.publish(publishEvents);}
            throw new UserAccessException('ERR007');
        }
        return con;
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @methodname   getlatestIEEsid()
* @description  Method to get the latest IEES ID record received from MCI system
* @param        set<Integer> setieesIds
* @return       Integer 
************************************************************************************************************************************/
    public static Integer getlatestIEEsid(set<Integer> setieesIds){
        Integer latestIeesId=0;
        for(Integer IEESID : setieesIds ){
            if( IEESID > latestIeesId){
                latestIeesId = IEESID;
            }
        }
        return latestIeesId;
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @methodname   insertListSObject()
* @description  Method to insert and capture logs for list of sobject
* @param        
* @return       void 
************************************************************************************************************************************/
    public static void insertListSObject(List<sObject> lstsObject, String strSobject){
        
        try{
            if(!lstsObject.isEmpty()){
                insert lstsObject;
            }
        }catch(exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();  publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'ERROR LOG', Source__c ='RE_ResidentLogic', Message__c =  ex.getMessage() ,SourceFunction__c = 'insertListSObject'));
            if(publishEvents.size()>0){EventBus.publish(publishEvents);}
            if(strSobject == 'Contact Mapping'){throw new UserAccessException('ERR009');}
            if(strSobject == 'System Alerts'){ throw new UserAccessException('ERR010');}
        }
    }
    
/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/11/2019
* @wrapperClass ContactMappingWrapper
* @description  Wrapper class
************************************************************************************************************************************/
    
    //wrapper class for contact mapping table
    public class ContactMappingWrapper{
        public Id contactId;
        public Integer ieesId;
        public string groupId;
        public ContactMappingWrapper(Id contactId,integer ieesId,string groupId){
            this.contactId = contactId;
            this.ieesId = ieesId;
            this.groupId = groupId;
        }
    }

/*********************************************************************************************************************************
* @author       Srikanth
* @date         11/28/2019
* @wrapperClass citizenExceptionCapture
* @description  Wrapper class
************************************************************************************************************************************/
    
    public class citizenExceptionCapture{
        public boolean isExceptionFound;
        public user usr;
        public string ExceptionCode;
    }

/*********************************************************************************************************************************
* @author       Payal Dubela
* @date         12/18/2019
* @wrapperClass MCIResponse
* @description  Wrapper class
************************************************************************************************************************************/
    
    //wrapper class for contact mapping table
    public class MCIResponseWrapper{
        public Set<Integer> setIeesIds;
        public DateTime DOB;
        public String Gender;
        public MCIResponseWrapper(Set<Integer> ieesIds,DateTime dateOfBirth,String gender){
            this.setIeesIds = ieesIds;
            this.DOB = dateOfBirth;
            this.Gender = (gender=='M'?'Male':(gender=='F'?'Female':'Other'));
        }
    }
}
