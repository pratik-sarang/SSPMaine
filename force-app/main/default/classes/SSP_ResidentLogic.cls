/*********************************************************************************************************************************
* Class Name    : SSP_ResidentLogic 
* Owner         : Deloitte
* Created Date  : 10/04/2020 
* Description   : Community SSO handler class for create and update users
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  11/05/2019    Kommana Lova Durga Prasad      Community Resident Logic for SSO
**/
public class SSP_ResidentLogic{
    
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
    public static citizenExceptionCapture createUserinSF(user usr, String federationIdentifier, string strApplicableRoles ){
        
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
        List<Contact_Mapping__c> lstContactMap = new List<Contact_Mapping__c>();

        
        //SAML request response 
        if(usr.Id == null){
            WebServiceSettings__c mciConfig = WebServiceSettings__c.getValues(SSP_GlobalConstants.MCI_ENTITIY_SEARCH);
            String sourceName = mciConfig.Source_System__c; 
            //retreving the IEES's ids recevied from MCI system for the federation id received from KOG
            MCIResponseWrapper returnResultMCIwrapper =    getIndividualInfo(federationIdentifier,usr,sourceName);
            //to get the single latest IEES Id which is received from MCI system
            latestIeesId = getlatestIEEsid(returnResultMCIwrapper.setIeesIds);
            //Create Contact,Account,User if MCI doesnt returns any IEES ID's. 
            if(returnResultMCIwrapper.setIeesIds.isEmpty()){ 
                // Creation of Citizen Contact & User. 
                usr = userMappingsWithMCI(usr,returnResultMCIwrapper);               
                Contact con = createCitizenContact(usr,latestIeesId,returnResultMCIwrapper); // SSP Related Changes
                usr = createCitizenUser(usr, federationIdentifier, con,strApplicableRoles);
            }else{ //if MCI returns any IEES ID's.
                if (Schema.sObjectType.Contact_Mapping__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() 
                    && Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible()) {
                    lstContactMap = [SELECT Contact__c,IEES_Id__c,Group_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN:returnResultMCIwrapper.setIeesIds ];
                }
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
                        if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.ContactId.isAccessible()) {
                            lstexistinguser  = [SELECT ID,ContactId FROM User WHERE ContactId =:contactId];
                        }
                        if(!lstexistinguser.isEmpty()){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                              ErroLog__c= 'ERROR LOG', Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, 
                                                              Message__c ='ERROO3 - Looks like you already have different account, Please login using that Account' ,SourceFunction__c = 'createUserinSF'));
                            if(publishEvents.size()>0){
                                EventBus.publish(publishEvents);
                            }
                            citizenExp.isExceptionFound = true;
                            citizenExp.ExceptionCode = 'ERROO3';
                            
                        }else{
                            // SSP Update contact based on the changes
                            if(contactId != null && returnResultMCIwrapper!=null && (returnResultMCIwrapper.Gender != null || returnResultMCIwrapper.SSN != null ) ){
                                Map<String,String> valueMap = new Map<String,String>();
                                valueMap.put('Gender',returnResultMCIwrapper.Gender);
                                valueMap.put('SSN',returnResultMCIwrapper.SSN);
                                updateContact(contactId,valueMap);
                            } 
                            // SSP Update contact ended
                            //create new user if user doesn't exist in the system with existing contact id
                            //create contact mapping table
                            usr = userMappingsWithMCI(usr,returnResultMCIwrapper); 
                            usr = createCitizenUser(usr, federationIdentifier, [SELECT Id FROM Contact WHERE Id =:contactId LIMIT 1],strApplicableRoles);
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
                    }else{ // is IEES ids's doesn't belong to the same contact
                        List<User> lstUser = new List<User>();
                        if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.ContactId.isAccessible()) {
                            lstUser = [SELECT Id,ContactId from User where ContactId IN : setContactIds];
                        }
                        if(!lstUser.isEmpty()){
                            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                              ErroLog__c= 'ERROR LOG', Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, 
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
                            Contact con = new Contact();
                            if (Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible()) {
                                con = [SELECT Id FROM Contact WHERE Id=:mapContactIEESIds.get(latestIeesId) LIMIT 1];
                            }
                            // SSP Update contact based on the changes
                            if(mapContactIEESIds.get(latestIeesId) != null &&  
                               (returnResultMCIwrapper.Gender != null || returnResultMCIwrapper.SSN != null ) ){
                                   Map<String,String> valueMap = new Map<String,String>();
                                   valueMap.put('Gender',returnResultMCIwrapper.Gender);
                                   valueMap.put('SSN',returnResultMCIwrapper.SSN);
                                   updateContact(mapContactIEESIds.get(latestIeesId),valueMap);
                               } 
                            // SSP Update contact ended
                            usr = userMappingsWithMCI(usr,returnResultMCIwrapper); 
                            usr = createCitizenUser(usr, federationIdentifier, con,strApplicableRoles);
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
                                            objSystemAlert.AlertDetails__c = SSP_GlobalConstants.THIS_IS_DUPLICATE_CONTACT;
                                            objSystemAlert.ParentId__c = con.Id;
                                            objSystemAlert.IEESId__c = IEESId;
                                            objSystemAlert.GroupId__c = cmw.groupId;
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
                            if(!lstSystemAlerts.isEmpty()){
                                
                                try{
                                    if (Schema.sObjectType.SystemAlert__c.isCreateable()) {
                                        Insert lstSystemAlerts;
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
                                    citizenExp.ExceptionCode = 'ERR010';
                                }
                            }
                        }
                    }
                }else{
                    //creation of citizen Contact & User. 
                    //Create ContactMapping
                    usr = userMappingsWithMCI(usr,returnResultMCIwrapper);
                    Contact con = createCitizenContact(usr,latestIeesId,returnResultMCIwrapper); // SSP Related Changes
                    usr = createCitizenUser(usr, federationIdentifier, con,strApplicableRoles);
                    String grpId ='Grp'+string.valueOf(latestIeesId)+String.valueOf(DateTime.now().getTime()).right(3);
                    for(Integer IEESId : returnResultMCIwrapper.setIeesIds){
                        Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                        objContactMapping.Contact__c = con.Id;
                        objContactMapping.IEES_Id__c = IEESId;
                        //check if IEES id belong to other contact
                        /*[Suresh] not reachable 
                        if(!lstContMapWrap.iSEmpty()){
                            for(ContactMappingWrapper cmw : lstContMapWrap){
                                if(cmw.ieesId == IEESId ){
                                    objContactMapping.Group_Id__c = cmw.groupId;
                                }else{
                                    objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                }
                            }
                        }else{*/
                        objContactMapping.Group_Id__c = grpId;//[Suresh] latest IESS Group Id
                        //}
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
        }
        handleDuplicateMembers(usr.contactId, lstContactMap);
        citizenExp.usr = usr;
        return citizenExp;
    }

    /*********************************************************************************************************************************
    * @author       Rajeev Kumar
    * @date         10/15/2019
    * @methodname   handleDuplicateMembers()
    * @description  Create Con Mapping and change member from existing member
    * @param        String conRec, List<Contact_Mapping__c> lstContactMap
    * @return       void 
    ************************************************************************************************************************************/

    public static void handleDuplicateMembers(String conRec, List<Contact_Mapping__c> lstContactMap) {
        List<SSP_Member__c> lstMemberToUpdate = new List<SSP_Member__c>();
        Map<Integer, List<Contact_Mapping__c>> mapIndvToConMappingToUpdate = new Map<Integer, List<Contact_Mapping__c>>();
        Set<String> setConIds = new Set<String>();
        List<SSP_Member__c> lstMembersToDelete = new List<SSP_Member__c>();
        List<Contact_Mapping__c> lstConMappingToUpdate = new List<Contact_Mapping__c>();
        Map<Id, SSP_Member__c> mapContactToMember = new Map<Id, SSP_Member__c>();
        List<Contact_Mapping__c> lstConMappingToInsert = new List<Contact_Mapping__c>();
        Map<String, String> mapConToIEESId = new Map<String, String>();

        if(!lstContactMap.isEmpty() && conRec!= null) {
            for(Contact_Mapping__c objConMap : lstContactMap) {
                if(objConMap.Contact__c == conRec) {
                    mapConToIEESId.put(conRec+objConMap.IEES_Id__c, objConMap.Group_Id__c);
                }
                if(conRec != objConMap.Contact__c) {
                    if(mapIndvToConMappingToUpdate.ContainsKey(Integer.valueOf(objConMap.IEES_Id__c))) {
                        mapIndvToConMappingToUpdate.get(Integer.valueOf(objConMap.IEES_Id__c)).add(objConMap);
                    }else {
                        mapIndvToConMappingToUpdate.put(Integer.valueOf(objConMap.IEES_Id__c), new List<Contact_Mapping__c> {objConMap});
                    }
                }
            }
            // Get the Member Id from Existing Contact
            for(Integer intIEES : mapIndvToConMappingToUpdate.keySet()) {
                for(Contact_Mapping__c objMapping : mapIndvToConMappingToUpdate.get(intIEES)) {
                	setConIds.add(objMapping.Contact__c);
                }
            }
            if(setConIds!= null && !setConIds.isEmpty()) {
                for(SSP_Member__c objMember : [SELECT Id, Contact__c from SSP_Member__c WHERE Contact__c IN: setConIds ORDER BY lastModifiedDate]) {
                    if(mapContactToMember.containsKey(objMember.Contact__c)) {
                        lstMembersToDelete.add(objMember);
                    }else {
                        mapContactToMember.put(objMember.Contact__c, objMember);
                    }
                }
            }

            if(!mapIndvToConMappingToUpdate.isEmpty()) {
                Boolean isMemberAdded;
                String sMemberId;
                Set<String> setIds = new Set<String>();
                String sGroupId;
                for(Integer intIEES : mapIndvToConMappingToUpdate.keySet()) {
                    // Create New Con Mapping for Records which was already present with Contact
                    if(mapConToIEESId.containsKey(conRec+intIEES)) {
                        setIds.add(conRec+intIEES);
                        sGroupId = mapConToIEESId.get(conRec+intIEES);
                    }
                    if(!setIds.contains(conRec+intIEES)){
                        Contact_Mapping__c objConMapping = new Contact_Mapping__c();
                        objConMapping.IEES_Id__c = intIEES;
                        objConMapping.Contact__c = conRec;
                        objConMapping.Group_Id__c = 'Grp'+string.valueOf(intIEES)+String.valueOf(DateTime.now().getTime()).right(3);
                        lstConMappingToInsert.add(objConMapping);
                        setIds.add(conRec+objConMapping.IEES_Id__c);
                        sGroupId = objConMapping.Group_Id__c;
                    }
                    isMemberAdded= false;
                    for(Contact_Mapping__c objMapping : mapIndvToConMappingToUpdate.get(intIEES)) {
                        // Update Con Mapping Records with new Group Id on Existing Duplicate Con Mapping with Contact Id
                        objMapping.Group_Id__c = sGroupId;
                        //objMapping.IEES_Id__c = null;
                        if(mapContactToMember.containsKey(objMapping.Contact__c) && !isMemberAdded) {
                            SSP_Member__c objMember = mapContactToMember.get(objMapping.Contact__c);
                            objMember.Contact__c = conRec;
                            lstMemberToUpdate.add(objMember);
                            isMemberAdded = true;
                            sMemberId = objMember.Id;
                        } else if(objMapping.Contact__c != conRec && mapContactToMember.containsKey(objMapping.Contact__c) && sMemberId != mapContactToMember.get(objMapping.Contact__c).Id) {
                            lstMembersToDelete.add(mapContactToMember.get(objMapping.Contact__c));
                        }
                        lstConMappingToUpdate.add(objMapping);
                    }
                }
            }
            if(!lstMemberToUpdate.isEmpty()) {
                List<SSP_Member__c> lstMember = [SELECT Id FROM SSP_Member__c WHERE Contact__c = :conRec];
                if(!lstMember.isEmpty()) {
                    lstMembersToDelete.addAll(lstMember);
                }
            }
            if(!lstMembersToDelete.isEmpty()) {
                delete lstMembersToDelete;
            }
            if(!lstConMappingToInsert.isEmpty()) {
                insert lstConMappingToInsert;
            }
            if(!lstConMappingToUpdate.isEmpty()) {
                update lstConMappingToUpdate;
            }
            if(!lstMemberToUpdate.isEmpty()) {
                update lstMemberToUpdate;
            }
        }
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
        if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.ContactId.isAccessible() 
            && Schema.sObjectType.User.fields.Id.isAccessible()) {
            usr = [SELECT Id,ContactId, Contact.KOGSourceId__c FROM User WHERE FederationIdentifier=:usrRec.FederationIdentifier LIMIT 1];
        }
        
        Boolean bContact = false;
        Set<Id> setContactIds = new Set<Id>();
        Set<Integer> setIeesIds = new Set<Integer>();
        Set<Integer> setIeesIdsNotInMappingTable = new Set<Integer>();
        Set<Integer> setIeesIdsInMappingTable = new Set<Integer>();
        List<Contact_Mapping__c> lstContactMapping = new List<Contact_Mapping__c>();
        List<ContactMappingWrapper> lstContMapWrap = new List<ContactMappingWrapper>();
        List<Contact_Mapping__c> lstContactMap = new List<Contact_Mapping__c>();
        MCIResponseWrapper returnResultMCIwrapper= getIndividualInfo(federationIdentifier,usr,'Kog');
        if(returnResultMCIwrapper!=null && !returnResultMCIwrapper.setIeesIds.isEmpty()){
            if (Schema.sObjectType.Contact_Mapping__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() 
                && Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible()) {
                lstContactMap = [SELECT Contact__c,IEES_Id__c,Group_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN:returnResultMCIwrapper.setIeesIds ];
            }
            if(!lstContactMap.isEmpty()){
                ID contactId; 
                for(Contact_Mapping__c conMap : lstContactMap) {
                    if(usr != null && conMap.Contact__c == usr.contactId) {
                        contactId = conMap.Contact__c;
                    }
                }
                List<user> objUser = new List<user>();
                if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible()) {
                    objUser = [SELECT ID from User where ContactID =: contactId];
                }
                integer ieesIdMap = integer.valueOf(lstContactMap[0].IEES_Id__c);
                for(Contact_Mapping__c conMap :lstContactMap){
                    setIeesIdsInMappingTable.add(integer.valueOf(conMap.IEES_Id__c));
                    setContactIds.add(conMap.Contact__c);
                    ContactMappingWrapper cmw = new ContactMappingWrapper(conMap.Contact__c,integer.valueOf(conMap.IEES_Id__c),conMap.Group_Id__c);
                    lstContMapWrap.add(cmw);
                    
                }
                List<User> lstUser = new List<User>();
                if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible()) {
                    lstUser = [SELECT ID from User Where ContactId IN :setContactIds];
                }
                if(objUser == null) {
                    bContact = true;
                } else {
                    if(objUser.IsEmpty() || lstUser.isEmpty()) {
                        bContact = true;
                    } 
                    if(!bContact) {
                        for(User u : lstUser){
                            if(u.Id != objUser[0].Id){
                                bContact = true;
                            }
                        }
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
                        
                        insertListSObject(lstContactMapping,SSP_GlobalConstants.CONTACT_MAPPING);
                    }
                    
                }else{
                    //Allow User to login using Existing Contact Associated
                    //Create Contact Mapping Tabel entry
                    //System Alerts
                    Set<Integer> combinedIEESIds = new Set<Integer>();
                    combinedIEESIds.addAll(setIeesIdsInMappingTable);
                    combinedIEESIds.addAll(setIeesIdsNotInMappingTable);
                    for(Integer IEESId : combinedIEESIds){
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
                    if(!lstContactMapping.isEmpty()){
                        
                        insertListSObject(lstContactMapping,SSP_GlobalConstants.CONTACT_MAPPING);
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
                    
                    insertListSObject(lstContactMapping,SSP_GlobalConstants.CONTACT_MAPPING);
                }
            }
        }
        // Method to handle Duplicate members if any.
        handleDuplicateMembers(usr.contactId, lstContactMap);

        // SSP Update contact based on the changes
        if(usr.contactId != null){
            Map<String,String> valueMap = new Map<String,String>();
            if(String.isEmpty(usr.Contact.KOGSourceId__c)) {
                valueMap.put('KOGSourceId__c',federationIdentifier);
            }
            if(returnResultMCIwrapper!=null && (returnResultMCIwrapper.Gender != null || returnResultMCIwrapper.SSN != null )) {
                valueMap.put('Gender',returnResultMCIwrapper.Gender);
                valueMap.put('SSN',returnResultMCIwrapper.SSN);
            }
            if(valueMap != null && valueMap.size() > 0) {
                updateContact(usr.contactId,valueMap);
            }
        } 
        // SSP Update contact ended
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
        kyHbeMciDatacontracts.MciEntitySearchResponse res = new kyHbeMciDatacontracts.MciEntitySearchResponse();
        res=MciServiceHandler.getIndividualBenefindId(federationId,usr,StrSourceSystemName);
        DateTime Dob;
        String Gender='';
        String SSN = null;
        String Email = null;
        String FirstName = null;
        String LastName = null;
        String MiddleName = null;
        MCIResponseWrapper returnResultMCIwrapper;
        if(res != null){
            schemasDatacontractOrg200407KyHbe.ArrayOfEntitySearchResponse result= res.result;
            List<kyHbeMciDatacontracts.SourceSystem> lstofSourceSystems = new List<kyHbeMciDatacontracts.SourceSystem>();        
            boolIsRecordfound = (res.IsRecordFound == null || res.IsRecordFound==false) ? false:true;
            if(boolIsRecordfound){
                List<schemasDatacontractOrg200407KyHbe.EntitySearchResponse> lstofEntitySearchResps = result.EntitySearchResponse;
                if(lstofEntitySearchResps!= null && !lstofEntitySearchResps.isEmpty()){
                    for(schemasDatacontractOrg200407KyHbe.EntitySearchResponse eachRes : lstofEntitySearchResps){
                        DOB=eachRes.Dob;
                        Gender=eachRes.Gender;
                        SSN = eachRes.Ssn;
                        Email = eachRes.Email;
                        FirstName = eachRes.FirstName;
                        LastName = eachRes.LastName;
                        MiddleName= eachRes.MiddleName;
                        kyHbeMciDatacontracts.ArrayOfSourceSystem eachSource = eachRes.Source;
                        lstofSourceSystems = eachSource.SourceSystem;
                    }
                }
                for(kyHbeMciDatacontracts.SourceSystem eachRecord :lstofSourceSystems){
                    if(eachRecord.SourceSystemName.equalsIgnoreCase('HBE')){
                        string IndividaulId= eachRecord.SourceIndividualId;
                        setIeesIds.add(Integer.valueof(IndividaulId));
                    }
                }
                returnResultMCIwrapper= new MCIResponseWrapper(setIeesIds,DOB,Gender,SSN,Email,FirstName,LastName,MiddleName);                
            }
            else{
                returnResultMCIwrapper= new MCIResponseWrapper(setIeesIds,DOB,Gender,SSN,Email,FirstName,LastName,MiddleName);                
            }
        }
        else{
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'ERROR LOG', Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, Message__c ='ERR004 - Null Response from MCI for federation Id'+federationId ,SourceFunction__c = SSP_GlobalConstants.GET_INDIVIDUAL_INFO));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new UserAccessException('ERR004');
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
    
    public static User createCitizenUser(User usr, String federationIdentifier, Contact con, string strApplicableRoles){
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
        usr.RE_Selected_Role__c = 'Citizen_Individual';// [Suresh] added for RE
        
        usr.ApplicableRoles__c = strApplicableRoles;
        usr = JitHelper.sanitiseUser(usr);
        List <Profile> prof = new List<Profile>();
        if (Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.Id.isAccessible()) {
            prof = [Select Id from Profile where Name =: SSP_GlobalConstants.RE_CITIZEN_PROFILE];
        }
        usr.ProfileId = prof[0].id;
        List<User> lstUserToError = [Select id FROM User WHERE FederationIdentifier=:usr.FederationIdentifier LIMIT 1];
        if(lstUserToError.size()>0){
            throw new UserAccessException('ERR014');
        }
        try{
            if (Schema.sObjectType.User.isCreateable()) {
                insert usr;
            }
        }catch(exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_CITIZEN_USER, Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, Message__c = ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.CREATE_CITIZEN_USER));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new UserAccessException('ERR005');
        }
        return usr; 
    }   

     
/*********************************************************************************************************************************
* @author       Srikanth
* @date         06/03/2020
* @methodname   assignPermissionsetClone()
* @description  Method is to assign the appropriate Permission set to the user // SSP related changes
* @param        User usr
* @return       Void 
************************************************************************************************************************************/    
    
    @future
    public static void assignPermissionsetClone(String federationIdentifier,List<String> lstKogRoles){
        user usrdata = new user();
        if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.KOG_Role__c.isAccessible() 
            && Schema.sObjectType.User.fields.FederationIdentifier.isAccessible()) {
            usrdata = [SELECT Id,FederationIdentifier,KOG_Role__c FROM User WHERE FederationIdentifier=:federationIdentifier LIMIT 1 ];
        }
        Id userId = usrdata.Id;
        List<PermissionSetAssignment> lstPermissionSetAssignment = new List<PermissionSetAssignment>();
        map<String,KOGRoleMapping__mdt> mapKogRole = new map<String,KOGRoleMapping__mdt>();
        
        Set<Id> setPermissionSetId = new set<Id>();
        Set<String> setRemovePermissionSet = new Set<String>();
        
        List<PermissionSetAssignment> lstRemovePermissionSetAssignment = new List<PermissionSetAssignment>();
        set<Id> setPermissionssetids = new Set<Id>();
        Set<String> setRemovePS = new Set<String>();
        List<String> lstPermissionsetNamesRemove = new List<String>();
        Set<String> setStrData = new Set<String>();
        List<String> lstKOGRolesUpperCase = new List<String>();
         for(String strRole : lstKogRoles)
         {
             if(strRole!=null)
             {
             lstKOGRolesUpperCase.add(strRole.toUpperCase());
             }
         }
        //the following loop is to get the list of permission sets available to the user
        if (Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() 
            && Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible()) {
            for(PermissionSetAssignment psa:[Select Id,PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: userId  ]){
                setPermissionSetId.add(psa.PermissionSetId);
            }
        }
        
        Set<String> setPermissionsetCapture = new Set<String>();
        Map<String,PermissionSet> mapData = new Map<String,PermissionSet>();
        if(Schema.sObjectType.PermissionSetAssignment.isAccessible() ){
            for(PermissionSet objPermissionSet : [SELECT ID,Name FROM PermissionSet WHERE Id IN : setPermissionSetId]){
                //setPermissionsetCapture.add(objPermissionSet.Name);
                mapData.put(objPermissionSet.Name,objPermissionSet);
            }
        }
        
        //the following loop is the capture all the Related permissions sets which are available in the custom metadata
        
        
        List<String> lstPR = new List<String>();
        if(Schema.sObjectType.KOGRoleMapping__mdt.isAccessible() && Schema.sObjectType.KOGRoleMapping__mdt.fields.Role_Name__c.isAccessible() && Schema.sObjectType.KOGRoleMapping__mdt.fields.Related_Permission_Sets__c.isAccessible()) {
            List<string> lstRolesToAdd;
            for(KOGRoleMapping__mdt kogrm : [Select Id,Role_Name__c,Related_Permission_Sets__c FROM KOGRoleMapping__mdt WHERE Role_Name__c!=null  ]){
                lstRolesToAdd = new List<String>();
                if(lstKOGRolesUpperCase.contains(String.valueOf(kogrm.Role_Name__c).toUpperCase())){
                    mapKogRole.put(String.valueOf(kogrm.Role_Name__c).toUpperCase(),kogrm );
                    string strKogRole = kogrm.Related_Permission_Sets__c;
                    
                    lstRolesToAdd = strKogRole.split(',');
                }
                for(String strRoleValue : lstRolesToAdd){
                    if(strRoleValue!=null){
                        lstPermissionsetNamesRemove.add(strRoleValue);
                    }
                }
                
                string strKogRole = kogrm.Related_Permission_Sets__c;
                
                if(strKogRole!=null){
                    lstPR = strKogRole.split(',');
                }
                
                for(String str : lstPR){
                    setStrData.add(str);
                }
                
            }
        }
        
        for(String str : mapData.keyset()){
            if(!lstPermissionsetNamesRemove.contains(str) && setStrData.contains(str)){
                setRemovePS.add(str);
            }
        }
        
        
        
        //following condition is to assign the permissions set to the user
        for(String strRoleFromKog : lstKOGRolesUpperCase){
            
            if(!mapKogRole.isEmpty() && mapKogRole.containsKey(strRoleFromKog)){
                string strKogRole = mapKogRole.get(strRoleFromKog).Related_Permission_Sets__c;
                List<String> lstPermissionsetNames = strKogRole.split(',');
                //iron dome changes 07/08
                if (Schema.sObjectType.PermissionSet.isAccessible() && Schema.sObjectType.PermissionSet.fields.Id.isAccessible() && Schema.sObjectType.PermissionSet.fields.Name.isAccessible()) {
                    for(PermissionSet objPermissionSet : [SELECT ID,Name FROM PermissionSet WHERE Name IN : lstPermissionsetNames]){
                        setRemovePermissionSet.add(objPermissionSet.Name);
                        if(!setPermissionSetId.contains(objPermissionSet.Id)){
                            PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = objPermissionSet.Id,AssigneeId = usrdata.Id);
                            lstPermissionSetAssignment.add(objPermissionSetAssignment);
                        }
                    }
                }
                
            }
        }
        if(!lstPermissionSetAssignment.isEmpty()){
            try{
                if (Schema.sObjectType.PermissionSetAssignment.isCreateable()) {
                    insert lstPermissionSetAssignment;
                }
            }
            catch(Exception ex){
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_PERMISSION_SET, Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, Message__c = ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.ASSIGN_PERMISSIONSET));
                if(publishEvents.size()>0){
                    EventBus.publish(publishEvents);
                }
                throw new UserAccessException('ERR011');
            }
            
        }
        
        //iron dome changes 07/08
        if(!setRemovePS.isEmpty() && Schema.sObjectType.PermissionSet.isAccessible() && Schema.sObjectType.PermissionSet.fields.Id.isAccessible() ){
            for(PermissionSet objPermissionSet : [SELECT Id,Name FROM PermissionSet WHERE Name IN : setRemovePS]){
                setPermissionssetids.add(objPermissionSet.Id);
            }
        }
        
        //following code is to fetch the list of permissions set assignments to user which needs to be deleted.
        if (Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.Id.isAccessible()) {
            if(!setPermissionssetids.isEmpty()){
                for(PermissionSetAssignment psaDelete : [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN : setPermissionssetids ]){
                    lstRemovePermissionSetAssignment.add(psaDelete);
                }
            }
            
        }
        
        if(!lstRemovePermissionSetAssignment.isEmpty()){
            try{
                if (Schema.sObjectType.PermissionSetAssignment.isDeletable()) {
                    delete lstRemovePermissionSetAssignment;
                }
            }
            catch(Exception ex){
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                publishEvents.add(new ErrorLog__e(DebugLevel__c = 'ERROR',ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_DELETING_PERMISSION_SET, Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, Message__c = ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.ASSIGN_PERMISSIONSET));
                if(publishEvents.size()>0){
                    EventBus.publish(publishEvents);
                }
                throw new UserAccessException('ERR011');
            }
            
        }
    }   
   
   
   public static void createDifferentUser(User usr, String federationIdentifier, Contact con, string strApplicableRoles){
       //user userDeactive = [SELECT Id,FederationIdentifier,Alias,CommunityNickname,IsActive,LastName,Username,Email,LocaleSidKey,MiddleName FROM User WHERE FederationIdentifier =: federationIdentifier LIMIT 1];
       user userDeactive = new user(); //iron dome changes 07/08
       if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.FederationIdentifier.isAccessible() 
           && Schema.sObjectType.User.fields.CommunityNickname.isAccessible() && Schema.sObjectType.User.fields.IsActive.isAccessible() 
           && Schema.sObjectType.User.fields.Email.isAccessible()) {
           userDeactive = [SELECT Id,FederationIdentifier,Alias,CommunityNickname,IsActive,LastName,
                                Username,Email,LocaleSidKey,MiddleName FROM User WHERE FederationIdentifier =: usr.FederationIdentifier LIMIT 1];
       }
       
       List<UpdateSSOUser__e> publishEvents = new List<UpdateSSOUser__e>();
            publishEvents.add(new UpdateSSOUser__e(UserId__c = userDeactive.Id ,Alias__c = userDeactive.LastName.substring(0,3)+String.valueOf(DateTime.now().getTime()).right(5),
                                              CommunityNickname__c = userDeactive.LastName.substring(0,3)+String.valueOf(DateTime.now().getTime()).right(5), FederationIdentifier__c = '',IsActive__c = false,UserName__c = userDeactive.Username ));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            } 
       
       usr.id = null;
       usr.Username = userDeactive.Username;
       usr.Email = userDeactive.Email;
       usr.LocaleSidKey = userDeactive.LocaleSidKey;
       usr.MiddleName = userDeactive.MiddleName;
       createUserinSF(usr,federationIdentifier,strApplicableRoles);
       //createCitizenUser(usr,federationIdentifier,con);
   }
   
 
  /*********************************************************************************************************************************
* @author       Kommana Lova Durga Prasad
* @date         05/02/2020
* @methodname   userMappingsWithMCI()
* @description  Method to Map the User with MCI Details
* @param        User usr, MCIResponseWrapper MCIResp
* @return       User 
************************************************************************************************************************************/
    public static User userMappingsWithMCI(User usr, MCIResponseWrapper MCIResp){
        usr.FirstName = string.isNotBlank(MCIResp.FirstName) ? MCIResp.FirstName : usr.FirstName;
        usr.LastName = string.isNotBlank(MCIResp.LastName) ? MCIResp.LastName : usr.LastName;
        usr.MiddleName = string.isNotBlank(MCIResp.MiddleName) ? MCIResp.MiddleName : usr.MiddleName;
        usr.Email = string.isNotBlank(MCIResp.Email) ? MCIResp.Email : usr.Email;
        
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
    
    public static Contact createCitizenContact(user usr,Integer IEESId,MCIResponseWrapper MCIResp){
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        List<Contact> existingContact= new List<Contact>();
        if(Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.KOGSourceId__c.isAccessible()){
            existingContact=[Select Id,KOGSourceId__c 
                             FROM Contact
                             WHERE KOGSourceId__c=:usr.FederationIdentifier LIMIT 1];
        }
        if(existingContact!=null && existingContact.size()>0){
            return existingContact[0];
        }else{
        Contact con = new Contact();
        con.RecordTypeId = objRecordType.Id;
        con.FirstName = usr.FirstName;
        con.Gender__c=MCIResp.Gender;
        con.GenderCode__c = MCIResp.Gender == 'Male' ? 'M' : (MCIResp.Gender == 'Female' ? 'F' : 'U'); //SSP Related Changes
            if(MCIResp.DOB!=null){
                con.Birthdate=MCIResp.DOB.date();
            }        
        con.LastName = usr.LastName;
        con.Email = usr.Email;
        con.MiddleName = usr.MiddleName; // SSP Related Changes
        con.KOGSourceId__c = usr.FederationIdentifier; // SSP Related Changes
        //As part of Bug 386045, Removing the IndividualId mapping on Contact
        //if(IEESId != 0) con.IndividualId__c = String.valueof(IEESId); // SSP Related Changes
        if(string.isNotBlank(MCIResp.SSN)) con.SSN__c = MCIResp.SSN; // SSP Related Changes
        con.Status__c=RE_GlobalConstants.ACTIVE; //RE Security Changes - Payal Dubela
        try{
            if (Schema.sObjectType.Contact.isCreateable()) {
                insert con;
            }
        }catch(exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_CONTACT_RECORD, Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, 
                                              Message__c =  ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.CREATE_CITIZEN_CONTACT));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new UserAccessException('ERR007');
        }
        return con;
    }
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
* @author       Kommana Lova Durga Prasad
* @date         04/28/2020
* @methodname   updateContact()
* @description  Method to Update the contacts
* @param        conId, paramsMap
* @return       contact 
************************************************************************************************************************************/
    public static contact updateContact(Id conId,  Map<String,String> paramsMap){
        boolean isUpdateNeeded = false;
        contact contactToUpdate = null;
        
        if (Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Gender__c.isAccessible() && Schema.sObjectType.Contact.fields.GenderCode__c.isAccessible() && Schema.sObjectType.Contact.fields.SSN__c.isAccessible()) {
            for(contact con : [select id,KOGSourceId__c,Gender__c,GenderCode__c,SSN__c from contact where id=:conId]){
                if((con.Gender__c == null || con.GenderCode__c == null) && paramsMap.get('Gender') != null){
                    con.Gender__c= paramsMap.get('Gender');
                    con.GenderCode__c = paramsMap.get('Gender') == 'Male' ? 'M' : (paramsMap.get('Gender') == 'Female' ? 'F' : 'U');
                        isUpdateNeeded = true;
                }
                if(con.SSN__c == null && paramsMap.get('SSN') != null){
                    
                    con.SSN__c = paramsMap.get('SSN');
                    isUpdateNeeded = true;    
                }
                if(String.isEmpty(con.KOGSourceId__c) && paramsMap.get('KOGSourceId__c') != null) {
                    con.KOGSourceId__c = paramsMap.get('KOGSourceId__c');
                    isUpdateNeeded = true; 
                }
                contactToUpdate = con;
                contactToUpdate.id = con.id;
            }
        }
        
        try{
            if(isUpdateNeeded){
                if (Schema.sObjectType.Contact.isUpdateable()) {
                    update contactToUpdate; 
                }
                
            } 
        }catch(exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= SSP_GlobalConstants.ERROR_WHILE_CREATING_CONTACT, Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, 
                                              Message__c =  ex.getMessage() ,SourceFunction__c = 'updateContact'));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            throw new UserAccessException('ERR007_1');
        }
        return contactToUpdate;
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
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'ERROR LOG', Source__c =SSP_GlobalConstants.SSP_RESIDENT_LOGIC, Message__c =  ex.getMessage() ,SourceFunction__c = SSP_GlobalConstants.INSERT_LIST_SOBJECT));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }
            if(strSobject == SSP_GlobalConstants.CONTACT_MAPPING){
                throw new UserAccessException('ERR009');
            }
            if(strSobject == 'System Alerts'){
                throw new UserAccessException('ERR010');
            }
            
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
        public String SSN;
        public String Email;
        public String FirstName;
        public String LastName;
        public String MiddleName;
        public MCIResponseWrapper(Set<Integer> ieesIds,DateTime dateOfBirth,String gender,string ssnValue,String emailValue,String fname,String lname,String mname){
            this.setIeesIds = ieesIds;
            this.DOB = dateOfBirth;
            this.Gender = (gender=='M'?'Male':(gender=='F'?'Female':'Other'));
            this.SSN = ssnValue;
            this.Email = emailValue;
            this.FirstName = fname;
            this.LastName = lname;
            this.MiddleName = mname;
        }
    }
}