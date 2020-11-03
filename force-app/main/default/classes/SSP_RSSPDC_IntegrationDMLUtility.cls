/**
 * Class Name                                               : SSP_RSSPDC_IntegrationDMLUtility 
 * Owner                                                    : DELOITTE
 * Created Date                                             : 28/11/2019
 * Description                                              : Class that holds DML utility services of Reverse SSP-DC
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  11/12/2019  Rajeev Kumar    Initial Version
 */
public without sharing class SSP_RSSPDC_IntegrationDMLUtility {
    private static final String CITIZEN_CONTACT_RECORD_TYPE = 'Citizen';
    private static final String CITIZEN_ACCOUNT_RECORD_TYPE = 'Citizen';
    private static final String AUTHREP_RECORD_TYPE = 'AuthRep';
    private static final String INSURANCE_RECORD_TYPE = 'InsurancePolicyDetail';
    private static final String OOS_BENEFIT_RECORD_TYPE = 'OutOfStateBenefit';
    private static final string NON_CITIZEN_ACCOUNT_RECORD_TYPE = 'Non_Citizen_Account';
    private static final string NON_CITIZEN_CONTACT_RECORD_TYPE = 'Non_Citizen';
    private static final string APPLICATIONRECORDTYPE = 'SSP_Application';
    private static final string ORGANIZATION_RECORD_TYPE = 'Resource_Engine';

    /**
     * method                                               : updateMembers
     * @description                                         : Upsert Members with their contact reference
     * @author                                              : Rajeev Kumar
     * @param lstAssets                                     : List of Members Record
     * @param sExternalIdField                              : external Id field for upsert
     * @return List<SSP_Member__c>                          : List of inserted Member Records
     */
    public List<SSP_Member__c> updateMembers(List<SSP_Member__c> lstMembers, Schema.SObjectField sExternalIdField, Contact objPrimaryContact, String sViewName) {
        List<SSP_Member__c> lstMemberToUpdate = new List<SSP_Member__c>();
        List<Integer> lstIndividualIds = new List<Integer>();
        Set<String> setIndividualIds = new Set<String>();
        Map<String, String> mapIndvidualEmail;
        for(SSP_Member__c objMember: lstMembers) {
            lstIndividualIds.add(Integer.valueOf(objMember.IndividualId__c));
        }
        Map<Decimal,String> mapExistingMembers  = SSP_Utility.getMemberIds(lstIndividualIds);
        for(SSP_Member__c objMember: lstMembers) {
            // Verify if IndiviudalId from HOH Member where email is blank
            if(sViewName == SSP_InterfaceConstants.MEMBER_INFORMATION && objPrimaryContact != null &&
                objMember.IndividualId__c == objPrimaryContact.IndividualId__c &&
                String.IsBlank(objMember.email__c) && !String.IsBlank(objPrimaryContact.email)) {
                    objMember.email__c = objPrimaryContact.email;
            }
            if(mapExistingMembers != null && mapExistingMembers.containsKey(Decimal.ValueOf(objMember.IndividualId__c))) {
                objMember.Id = mapExistingMembers.get(Decimal.ValueOf(objMember.IndividualId__c));
            } else {
                List<Contact_Mapping__c> lstConmapping = [SELECT Id, Contact__r.Id FROM Contact_Mapping__c WHERE IEES_ID__c = :Integer.valueOf(objMember.IndividualId__c) LIMIT 1];
                if(!lstConmapping.isEmpty()) {
                    objMember.Contact__c = lstConmapping.get(0).Contact__r.Id;
                }
            }
            /* Bug - 384646*/
            if(String.isNotBlank(objMember.SSN__c) && objMember.SSN__c.startsWithIgnoreCase(SSP_GlobalConstants.INVALID_SSN_START_DIGIT)) {
                objMember.PseudoSSN__c = objMember.SSN__c;
                objMember.SSN__c= null;   
            }
            lstMemberToUpdate.add(objMember);
        }
        if(Schema.sObjectType.SSP_Member__c.isCreateable() && Schema.sObjectType.SSP_Member__c.isUpdateable()) {
            performDML(lstMemberToUpdate, 'Upsert', null);
        }
        return lstMemberToUpdate;
    }

    /**
     * method                                               : insertACRForNewMember
     * @description                                         : Insert AccountContactRelation Records
     * @author                                              : Rajeev Kumar
     * @param lstMembers                                    : List of member Records
     * @param sApplicationId                                : Applicaton Id of the flow
     */
    public void insertACRForNewMember(List<SSP_Member__c> lstMembers, String sApplicationId) {
        Set<String> setAllContactIds = new Set<String>();
        Map<String, Set<String>> mapAccountContacts = new Map<String, Set<String>>();
        Map<String, Set<String>> mapExistingACR = new Map<String, Set<String>>();
        List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
        Set<String> setACRIds = new Set<String>();
        set<String> setAccountIds = new Set<String>();
        set<String> setContactIds = new Set<String>();
        Set<String> setExistingACR = new Set<String>();
        // Get the logged in User details whether its citizen or Agent
        if (Schema.sObjectType.User.fields.Id.isAccessible()) {
            List<User> lstUser = [SELECT Id, ContactId from User WHERE ContactId != null AND Id=:userInfo.getUserId()];
            if(!lstUser.isEmpty()) {
                setContactIds.add(lstUser.get(0).ContactId);
            }
        }
        // get Application Account Id
        if (String.isNotBlank(sApplicationId) && Schema.sObjectType.SSP_Application__c.fields.Id.isAccessible()) {
            setAccountIds.add([SELECT Id, Account__r.Id from SSP_Application__c WHERE Id = :sApplicationId].account__r.Id);
        }
        
        // Prepare set of all account Ids and contact Ids.
        if (Schema.sObjectType.SSP_Member__c.fields.Id.isAccessible()) {
            for(SSP_Member__c objMember : [SELECT Id, Contact__r.Id, Contact__r.AccountId FROM SSP_Member__c WHERE Id IN: lstMembers]) {
                setContactIds.add(objMember.Contact__r.Id);
                setAccountIds.add(objMember.Contact__r.AccountId);
            }
        }
        
        // Prepare set of All ACR Records
        for(String sAccountId : setAccountIds) {
            for(String sContactId : setContactIds){
                setACRIds.add(sAccountId+SSP_InterfaceConstants.SEMICOLON+sContactId);
            }
        }
        // Verify if ACR already exists
        if (Schema.sObjectType.AccountContactRelation.fields.accountId.isAccessible()) {
            for(AccountContactRelation objAcr : [SELECT id, accountId, ContactId FROM AccountContactRelation 
                                                WHERE accountId IN: setAccountIds
                                                AND contactId IN: setContactIds]) {
                if(setACRIds.contains(objAcr.accountId+SSP_InterfaceConstants.SEMICOLON+objAcr.ContactId)) {
                    setACRIds.remove(objAcr.accountId+SSP_InterfaceConstants.SEMICOLON+objAcr.ContactId);
                }
            }
        }
        // Create List of new ACR Records to insert
        for(String sKey : setACRIds) {
            AccountContactRelation objACR = new AccountContactRelation();
            objACR.accountId= sKey.split(SSP_InterfaceConstants.SEMICOLON)[0];
            objACR.contactId = sKey.split(SSP_InterfaceConstants.SEMICOLON)[1];
            lstACR.add(objACR);
        }
        // Insert new ACR Records
        if(!lstACR.isEmpty() && Schema.sObjectType.AccountContactRelation.isCreateable()) {
            Database.insert(lstACR, true);
            //ESAPI.accessController().insertAsUser(lstACR, SSP_Utility.getFieldsNamesObject (lstACR[0]));
        }
    }

    /**
     * method                                               : upsertAssets
     * @description                                         : Upsert Asset and its parent asset
     * @author                                              : Rajeev Kumar
     * @param lstAssets                                     : List of Asset record
     * @param sExternalIdField                              : external Id field for upsert
     * @return List<SSP_Asset__c>                           : List of inserted Asset Records   
     */
    public List<SSP_Asset__c> upsertAssets(List<SSP_Asset__c> lstAssets, Schema.SObjectField sExternalIdField, String sApplicationId) {
        List<SSP_Asset__c> lstparentAssets = new List<SSP_Asset__c>();
        List<SSP_Asset__c> lstChildAssets = new List<SSP_Asset__c>();
        for(SSP_Asset__c objAsset : lstAssets) {
            objAsset.SSP_Application__c = sApplicationId;
            if(objAsset.InsurancePolicyAsset__r == null) {
                lstparentAssets.add(objAsset);
            } else {
                lstChildAssets.add(objAsset);
            }
        }
        if(lstparentAssets.size()>0 && Schema.sObjectType.SSP_Asset__c.isCreateable() && Schema.sObjectType.SSP_Asset__c.isUpdateable()) {
            // Use ESAPI
            Database.upsert(lstparentAssets, sExternalIdField, true);
        }
        if(lstparentAssets.size()>0 && Schema.sObjectType.SSP_Asset__c.isCreateable() && Schema.sObjectType.SSP_Asset__c.isUpdateable()) {
            // Use ESAPI
            Database.upsert(lstChildAssets, sExternalIdField, true);
        } 
        lstparentAssets.addAll(lstChildAssets);
        return lstparentAssets;
    }

    /**
     * method                                               : insertAppIndividualRecords
     * @description                                         : Insert Application Individual Records
     * @author                                              : Rajeev Kumar
     * @param lstAppIndividuals                             : List of Application Individuals
     * @param sApplicationId                                : Application Id from the Request
     * @return List<SSP_ApplicationIndividual__c>           : List of Application Individual Records
     */
    public List<SSP_ApplicationIndividual__c> insertAppIndividualRecords(List<SSP_ApplicationIndividual__c> lstAppIndividuals, String sApplicationId) {
        List<SSP_ApplicationIndividual__c> lstAppIndvToInsert = new List<SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> lstAppIndvToUpdate = new List<SSP_ApplicationIndividual__c>();
        Map<String, String> mapExistingIndv = new Map<String, String>();
        Set<String> setMemberIds = new Set<String>();

        for(SSP_ApplicationIndividual__c objAppIndv: lstAppIndividuals) {
            setMemberIds.add(objAppIndv.SSP_Member__r.IndividualId__c);
        }
        if (Schema.sObjectType.SSP_ApplicationIndividual__c.fields.Id.isAccessible()) {
            for(SSP_ApplicationIndividual__c objIndv : [SELECT Id, SSP_Member__r.IndividualId__c FROM SSP_ApplicationIndividual__c 
                                                        WHERE SSP_Application__c=:sApplicationId AND SSP_Member__r.IndividualId__c IN :setMemberIds]){
                mapExistingIndv.put(objIndv.SSP_Member__r.IndividualId__c, objIndv.Id);
            }
        }
        for(SSP_ApplicationIndividual__c objAppIndv: lstAppIndividuals) {
            objAppIndv.SSP_Application__c = sApplicationId;
            if(mapExistingIndv.containsKey(objAppIndv.SSP_Member__r.IndividualId__c)) {
                objAppIndv.Id = mapExistingIndv.get(objAppIndv.SSP_Member__r.IndividualId__c);
                lstAppIndvToUpdate.add(objAppIndv);
                continue;
            }
            lstAppIndvToInsert.add(objAppIndv);
        }
        if(!lstAppIndvToInsert.isEmpty() && Schema.sObjectType.SSP_ApplicationIndividual__c.isCreateable()) {
            //ESAPI.accessController().insertAsUser(lstAppIndvToInsert, SSP_Utility.getFieldsNamesObject (lstAppIndvToInsert[0])); 
            Database.Insert(lstAppIndvToInsert, true);
        }
        if(!lstAppIndvToUpdate.isEmpty() && Schema.sObjectType.SSP_ApplicationIndividual__c.isUpdateable()){
            //ESAPI.accessController().updateAsUser(lstAppIndvToUpdate, SSP_Utility.getFieldsNamesObject (lstAppIndvToUpdate[0])); 
            Database.Update(lstAppIndvToUpdate, true);
        }
        lstAppIndvToInsert.addAll(lstAppIndvToUpdate);
        return lstAppIndvToInsert;
    }

    /**
     * method                                               : upsertContacts
     * @description                                         : Upsert Members with their contact reference
     * @author                                              : Rajeev Kumar
     * @param lstContacts                                   : List of Contact Records
     * @param sExternalIdField                              : external Id field for upsert
     * @return List<Contact>                                : List of inserted contact records
     */
    public List<Contact> upsertContacts(List<Contact> lstContacts, Schema.SObjectField sExternalIdField) {

        Set<String> setAllContacts = new Set<String>();
        Map<String,String> mapContactsToUpdate = new Map<String, String>();
        List<Account> lstAccountsToInsert = new List<Account>();
        List<Contact> lstContactsToInsert = new List<Contact>();
        List<Contact> lstContactsToUpdate = new List<Contact>();
        String sAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(NON_CITIZEN_ACCOUNT_RECORD_TYPE).getRecordTypeId();
        //String sConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(NON_CITIZEN_CONTACT_RECORD_TYPE).getRecordTypeId();
        // Get all the contacts with the DCACRID
        for(Contact objCon : lstContacts) {
            if(objCon.DCACRId__c != null) {
                setAllContacts.add(objCon.DCACRId__c.toUpperCase());
            }
        }
        // Validate if the contact exists in Salesforce
        if (Schema.sObjectType.Contact.fields.Id.isAccessible()) {
            for(Contact objCon: [SELECT Id, DCACRId__c, FirstName, LastName  FROM Contact WHERE DCACRId__c IN :setAllContacts]) {
                if(objCon.DCACRId__c != null) {
                    mapContactsToUpdate.put(objCon.DCACRId__c.toUpperCase(), objCon.Id);
                }
            }
        }
        // Create instance of account for new Contacts
        for(Contact objCon : lstContacts) {
            if(objCon.DCACRId__c != null && !mapContactsToUpdate.containsKey(objCon.DCACRId__c.toUpperCase())) {
                Account objAccount = new Account(Name=objCon.firstName.trim() + ' ' + objCon.lastName.trim(),
                                                    RecordTypeId = sAccRecTypeId);
                lstAccountsToInsert.add(objAccount);
                lstContactsToInsert.add(objCon);
                continue;
            }
            if(objCon.DCACRId__c != null) {
                objCon.Id = mapContactsToUpdate.get(objCon.DCACRId__c.toUpperCase());
            }
            lstContactsToUpdate.add(objCon);
        }
        // Insert New Contacts & Accounts with Account Creation Service
        if(!lstAccountsToInsert.isEmpty()) {
            Map<String,Object> result = SSP_ProgramSelectionService.invokeAccountCreationService(lstAccountsToInsert,lstContactsToInsert,null);
        }
        // Update existing Contacts
        if(!lstContactsToUpdate.isEmpty()) {
            Database.update(lstContactsToUpdate, true);
        }
        return lstContactsToUpdate;
    }
    
    /**
     * method                                               : updateApplication
     * @description                                         : Update Application Records
     * @author                                              : Rajeev Kumar
     * @param lstApplication                                : List of Application Record
     * @param sApplicationId                                : Application Id from the request
     * @return List<SSP_Application__c>                     : List of inserted application records
     */
    public List<SSP_Application__c> updateApplication(List<SSP_Application__c> lstApplication, String sApplicationId) {
        List<SSP_Application__c> lstApplicationToUpdate = new List<SSP_Application__c>();
        for(SSP_Application__c objApplication: lstApplication) {
            objApplication.Id = sApplicationId;
            lstApplicationToUpdate.add(objApplication);
        }

        if(!lstApplicationToUpdate.isEmpty() && Schema.sObjectType.SSP_Application__c.isUpdateable()) {
            performDML(lstApplicationToUpdate, 'Update', null);
        } 
        return lstApplicationToUpdate;
    }

    /**
     * method                                               : upsertACRRecords
     * @description                                         : Insert ACR with Application and Members
     * @author                                              : Rajeev Kumar
     * @param lstACR                                        : List of AccountContactRelation Records
     * @return List<AccountContactRelation>                 : List of inserted Account contact relationship records
     */
    public List<AccountContactRelation> upsertACRRecords(List<AccountContactRelation> lstACR, String applicationID) {
        List<SSP_Application__c> lstApp = new  List<SSP_Application__c>();
        if(Schema.sObjectType.SSP_Application__c.fields.Account__c.isAccessible()) {
            lstApp = [Select Account__c,RecordType.DeveloperName from SSP_Application__c where id=:applicationID];
        }
        if(!lstApp.isEmpty() && lstApp[0].RecordType.DeveloperName.equals(APPLICATIONRECORDTYPE)) {
            List<AccountContactRelation> lstACRsToReturn = upsertACRRecordsForIntake(lstACR,lstApp[0]); 
            return lstACRsToReturn;
        } else {
            Set<String> setManualAuthRepACRIds = new Set<String>();
            Set<String> setACRIds = new Set<String>();        
            Set<String> setCaseNumbers = new Set<String>();
            Set<String> setContactsToRetain = new Set<String>();
            Set<String> setUniqueRecords = new Set<String>();
            Set<String> setRoles = new Set<String>{'Assister', 'Insurance_Agent', 'Organization_Auth_Rep', 'Individual_Auth_Rep'};
            List<AccountContactRelation> lstACRToProcess = new LIst<AccountContactRelation>();
            List<AccountContactRelation> lstACRToInsert = new List<AccountContactRelation>();
            List<AccountContactRelation> lstACRToUpdate = new List<AccountContactRelation>();
            List<AccountContactRelation> lstACRToDelete = new List<AccountContactRelation>();
            List<Contact> lstContactToDelete = new List<Contact>();
            Map<String, Id> mapExistingACR = new Map<String, Id>();
            Map<String, String> mapACRIdToContact = new Map<String, String>();
            Map<String, String> mapAccountIds = new Map<String, String>();
            // Get case numbers and ACR records from List of ACR
            for(AccountContactRelation objACR : lstACR) {

                setCaseNumbers.add(objACR.Account.CaseNumber__c);
                if(objACR.DCACRId__c != null && objACR.DCACRId__c.toUpperCase().contains('MANUAL AUTHORIZED REPRESENTATIVE')) {
                    setManualAuthRepACRIds.add(objACR.DCACRId__c.toUpperCase());
                }
                if(objACR.DCACRId__c != null) {
                    setACRIds.add(objACR.DCACRId__c.toUpperCase());
                }
            }
            // Get Corresponding Contact for Manual Auth Rep
            if(!setManualAuthRepACRIds.isEmpty() && Schema.sObjectType.Contact.fields.Id.isAccessible()) {
                for(Contact objCon : [SELECT Id, DCACRId__c, IsManualAuthRep__c FROM Contact WHERE DCACRId__c IN: setManualAuthRepACRIds]) {
                    mapACRIdToContact.put(objCon.DCACRId__c.toUpperCase(), objCon.Id);
                    if(objCon.IsManualAuthRep__c) {
                        setContactsToRetain.add(objCon.Id);
                    }
                }
            }
            // Get Corresponding Contact for Agent, Assister & Auth Rep
            if(!setACRIds.isEmpty() && Schema.sObjectType.AccountContactRelation.fields.Id.isAccessible()) {
                for(AccountContactRelation objACR : [SELECT Id, DCACRId__c, contactId, Contact.AccountId, Contact.IsManualAuthRep__c 
                                                    FROM AccountContactRelation WHERE DCACRId__c IN: setACRIds]) {
                    mapACRIdToContact.put(objACR.DCACRId__c.toUpperCase(), objACR.ContactId);
                }
            }

            for(AccountContactRelation objACR : lstACR) {
                if(objACR.DCACRId__c != null && mapACRIdToContact.containsKey(objACR.DCACRId__c.toUpperCase())) {
                    objACR.ContactId = mapACRIdToContact.get(objACR.DCACRId__c.toUpperCase());
                    lstACRToProcess.add(objACR);
                }
            }
            // Query Existing ACR to DELETE
            if(Schema.sObjectType.AccountContactRelation.fields.Id.isAccessible()) {
                for(AccountContactRelation objACR : [SELECT Id, Account.CaseNumber__c, ContactId, contact.AccountId, Contact.IsManualAuthRep__c, Roles, RequestAccessPermission__c 
                                                    FROM AccountContactRelation 
                                                    WHERE Account.CaseNumber__c IN: setCaseNumbers
                                                    AND Roles IN: setRoles AND RequestAccessPermission__c = null]) {
                    if(!setContactsToRetain.contains(objACR.contactId) && objACR.Contact.IsManualAuthRep__c) {
                        lstContactToDelete.add(new Contact(Id=objACR.ContactId));
                    }
                    lstACRToDelete.add(objACR);
                }
            }
            // Delete ACR
            if(!lstACRToDelete.isEmpty() && Schema.sObjectType.AccountContactRelation.isDeletable()) {
                Database.Delete(lstACRToDelete, true);
            }
            // Delete Contact
            if(!lstContactToDelete.isEmpty() && Schema.sObjectType.Contact.isDeletable()) {
                Database.Delete(lstContactToDelete, true);
            }
            // Find if Any ACR exist for Update
            if(Schema.sObjectType.AccountContactRelation.fields.Id.isAccessible()) {
                for(AccountContactRelation objExistingACR : [SELECT Id, ContactId, Account.CaseNumber__c 
                                                            FROM AccountContactRelation 
                                                            WHERE Account.CaseNumber__c IN: setCaseNumbers 
                                                            AND ContactId IN: mapACRIdToContact.values()]) {
                    mapExistingACR.put(objExistingACR.Account.CaseNumber__c+objExistingACR.ContactId, objExistingACR.Id);
                }
            }
            // Prepare list of ACR to update or Insert
            for(AccountContactRelation objACR: lstACRToProcess) {
                objACR.DCACRId__c = null;
                objACR.RequestAccessPermission__c = null;
                if(mapExistingACR.containsKey(objACR.Account.CaseNumber__c+objACR.ContactId)) {
                    objACR.Id = mapExistingACR.get(objACR.Account.CaseNumber__c+objACR.ContactId);
                    lstACRToUpdate.add(objACR); 
                    continue;
                }
                lstACRToInsert.add(objACR);
            }
            // Insert ACR's
            if(!lstACRToInsert.isEmpty() && Schema.sObjectType.AccountContactRelation.isCreateable()) {
                //ESAPI.accessController().insertAsUser(lstACRToInsert, SSP_Utility.getFieldsNamesObject (lstACRToInsert[0])); 
                Database.Insert(lstACRToInsert, true);
            }
            // Update ACR's
            if(!lstACRToUpdate.isEmpty() && Schema.sObjectType.AccountContactRelation.isCreateable()) {
                //ESAPI.accessController().updateAsUser(lstACRtoUpdate, SSP_Utility.getFieldsNamesObject (lstACRtoUpdate[0])); 
                Database.update(lstACRtoUpdate, true);
            }
            return lstACRToInsert;
        }
    }
      /**
     * method                                               : upsertACRRecordsForIntake
     * @description                                         : Insert ACR with Application 
     * @author                                              : Rijia Khatun
     * @param lstACR                                        : List of AccountContactRelation Records, Application Id
     * @return List<AccountContactRelation>                 : List of inserted Account contact relationship records
     */
    public List<AccountContactRelation> upsertACRRecordsForIntake(List<AccountContactRelation> lstACR, SSP_Application__c objApp) {
        Set<String> setManualAuthRepACRIds= new Set<String>();
        Set<String> setACRIds = new Set<String>();
        List<AccountContactRelation> lstUpdateACRs = new List<AccountContactRelation>();
        List<AccountContactRelation> lstInsertACRs = new List<AccountContactRelation>();
        Map<String,ID> mapACRIdToContact = new Map<String,ID>();
        Map<String, ID> mapExistingACR = new Map<String, Id>();
        for(AccountContactRelation objACR : lstACR) {
            if(objApp.RecordType.DeveloperName.equals(APPLICATIONRECORDTYPE)) {
                objACR.Account = null;
                objACR.AccountID = objApp.Account__c;
                if(objACR.DCACRId__c != null && objACR.DCACRId__c.contains('MANUAL AUTHORIZED REPRESENTATIVE')) {
                    setManualAuthRepACRIds.add(objACR.DCACRId__c);
                } else {
                    setACRIds.add(objACR.DCACRId__c);
                }
            }
        }
        // Get Corresponding Contact for Manual Auth Rep
        if(!setManualAuthRepACRIds.isEmpty() && Schema.sObjectType.Contact.fields.Id.isAccessible()) {
            for(Contact objCon : [SELECT Id, DCACRId__c FROM Contact WHERE DCACRId__c IN: setManualAuthRepACRIds]) {
                mapACRIdToContact.put(objCon.DCACRId__c, objCon.Id);
            }
        }
        // Get Corresponding Contact for Agent, Assister & Auth Rep
        if(!setACRIds.isEmpty() && Schema.sObjectType.AccountContactRelation.fields.Id.isAccessible()) {
            for(AccountContactRelation objACR : [SELECT Id, DCACRId__c, contactId
                                                FROM AccountContactRelation WHERE DCACRId__c IN: setACRIds]) {
				if(!String.isBlank(objACR.DCACRId__c)) {
                	mapACRIdToContact.put(objACR.DCACRId__c.toUpperCase(), objACR.ContactId);
                }
            }
        }
        for(AccountContactRelation objACR : lstACR) {
            if(!String.isBlank(objACR.DCACRId__c) && mapACRIdToContact.containsKey(objACR.DCACRId__c.toUpperCase())) {
                objACR.ContactId = mapACRIdToContact.get(objACR.DCACRId__c);
            }
        }
        if(Schema.sObjectType.AccountContactRelation.fields.Id.isAccessible()) {
            for(AccountContactRelation objExistingACR : [SELECT Id, ContactId, AccountID 
                                                        FROM AccountContactRelation 
                                                        WHERE  ContactId IN: mapACRIdToContact.values()
                                                        AND AccountId=: objApp.Account__c]) {
                mapExistingACR.put((String)objExistingACR.AccountID+(String)objExistingACR.ContactId, objExistingACR.Id);
            }
        }
        for(AccountContactRelation objACR : lstACR) {
			objACR.DCACRID__c = null;
            if(mapExistingACR.containsKey((String)objACR.AccountId+(String)objACR.ContactId)) {
                objACR.Id = mapExistingACR.get((String)objACR.AccountId+(String)objACR.ContactId);
                lstUpdateACRs.add(objACR);
                continue;
            }
            lstInsertACRs.add(objACR);
        }
        if(!lstInsertACRs.isEmpty() && Schema.sObjectType.AccountContactRelation.isCreateable()) {
            Database.insert(lstInsertACRs, true);
        }
        if(!lstUpdateACRs.isEmpty() && Schema.sObjectType.AccountContactRelation.isCreateable()) { 
            Database.update(lstUpdateACRs, true);
        }
        return lstInsertACRs;
    }

    /**
     * method                                               : individualAuthRepACRRecords
     * @description                                         : Insert ACR Records for Individual Auth Rep
     * @author                                              : Rajeev Kumar
     * @param lstInsCoveredIndv                             : List of AccountContactRelation Records
     * @return List<AccountContactRelation>                 : List of inserted ACR Records
     */
    public List<AccountContactRelation> individualAuthRepACRRecords(List<AccountContactRelation> lstACRRecords) {
        Account objAccount;
        List<Account> lstAccount;
        String sOrganizationRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ORGANIZATION_RECORD_TYPE).getRecordTypeId();
        List<AccountContactRelation> lstACRToInsert = new List<AccountContactRelation>();
        Map<String,Object> mapResult;
        User objUser = [SELECT Id, contactId, Contact.firstName, Contact.lastName FROM User WHERE Id= :userInfo.getUserId()];
        if(objUser.ContactId != null && objUser.contact.firstName != null && objUser.contact.lastName != null ) { 
            Account objAccRecord = new Account(Name=objUser.Contact.firstName.trim() + ' ' + objUser.Contact.lastName.trim(),
                                            RecordTypeId = sOrganizationRecTypeId);
            mapResult = SSP_ProgramSelectionService.invokeAccountCreationService(new List<Account>{ objAccRecord },null,null);
        }
        if(mapResult != null && !mapResult.isEmpty() && mapResult.containsKey('lstAccounts')){                        
            lstAccount = ((List<Account>)mapResult.get('lstAccounts'));
            objAccount = lstAccount != null && !lstAccount.isEMpty() ? lstAccount[0] : null;
        }
        if(objAccount != null) {
            for(AccountContactRelation objACR : lstACRRecords) {
                objACR.AccountId = objAccount.Id;
                objAcr.ContactId = objUser.ContactId;
                lstACRToInsert.add(objAcr);
            }
        }
        if(!lstACRToInsert.isEmpty()) {
            performDML(lstACRToInsert, 'Insert', null);
        }
        return lstACRToInsert;
    }
    /**
     * method                                               : upsertInsuranceCoveredIndv
     * @description                                         : Insert Insurance covered Individual Records
     * @author                                              : Rajeev Kumar
     * @param lstInsCoveredIndv                             : List of AccountContactRelation Records
     * @param sExternalIdField                              : Unique External Id field
     * @return List<SSP_InsuranceCoveredIndiv__c>           : List of inserted Insurnace covered Indv records
     */
    public List<SSP_InsuranceCoveredIndiv__c> upsertInsuranceCoveredIndv(List<SSP_InsuranceCoveredIndiv__c> lstInsCoveredIndv, Schema.SObjectField sExternalIdField) {
        for(SSP_InsuranceCoveredIndiv__c objIndv : lstInsCoveredIndv) {
            if(objIndv.RecordType.Name == 'Insurance External Policy Holder' || 
                (objIndv.RecordType.Name == 'Insurance Covered Individual' && 
                objIndv.InsuranceInternalPolicyHolder__c != null && 
                objIndv.SSP_Member__r.IndividualId__c != null &&
                objIndv.SSP_Member__r.IndividualId__c == objIndv.InsuranceInternalPolicyHolder__c)) {
                    objIndv.IsPolicyHolder__c = true;
            }
        }
        if(Schema.sObjectType.SSP_InsuranceCoveredIndiv__c.isCreateable() && Schema.sObjectType.SSP_InsuranceCoveredIndiv__c.isUpdateable()) {
            performDML(lstInsCoveredIndv, 'Upsert', sExternalIdField);
        }
        return lstInsCoveredIndv;
    }

    /**
     * method                                               : upsertNonCustodialParent
     * @description                                         : Upsert Non-Custodial Parent
     * @author                                              : Rajeev Kumar
     * @param lstNonCustodialParent                         : List of lstNonCustodialParent Records
     * @param sExternalIdField                              : Unique External Id field
     * @return List<SSP_NonCustodialParent__c>              : List of inserted non custodial parent record
     */
    public List<SSP_NonCustodialParent__c> upsertNonCustodialParent(List<SSP_NonCustodialParent__c> lstNonCustodialParent, Schema.SObjectField sExternalIdField) {
        Set<Decimal> setNCPIds = new Set<Decimal>();
        List<SSP_NonCustodialParent__c> lstNCPToDelete = new List<SSP_NonCustodialParent__c>();
        for(SSP_NonCustodialParent__c objNCP : lstNonCustodialParent) {
            setNCPIds.add(objNCP.DCNonCustodialParentId__c);
        }
        // Delete existing Non Custodial parent record if any
        if (Schema.sObjectType.SSP_NonCustodialParent__c.fields.Id.isAccessible()) {
            lstNCPToDelete = [SELECT Id from SSP_NonCustodialParent__c WHERE DCNonCustodialParentId__c IN: setNCPIds];
        }
        if(!lstNCPToDelete.isEmpty() && Schema.sObjectType.SSP_NonCustodialParent__c.isDeletable()) {
            database.delete(lstNCPToDelete, true);
        }
        // Insert or upate Non Custodial Parent Record
        if(Schema.sObjectType.SSP_NonCustodialParent__c.isCreateable() && Schema.sObjectType.SSP_NonCustodialParent__c.isUpdateable()) {
            performDML(lstNonCustodialParent, 'Upsert', sExternalIdField);
        }
        return lstNonCustodialParent;
    }

    /**
     * method                                               : upsertInsurancePolicy
     * @description                                         : Upsert lstInsurancePolicy Records
     * @author                                              : Rajeev Kumar
     * @param lstInsurancePolicy                            : List of lstInsurancePolicy Records
     * @param sExternalIdField                              : Unique External Id field
     * @return List<SSP_InsurancePolicy__c>                 : List of inserted insurance policy records
     */
    public List<SSP_InsurancePolicy__c> upsertInsurancePolicy(List<SSP_InsurancePolicy__c> lstInsurancePolicy, Schema.SObjectField sExternalIdField) {
        Set<Decimal> setInsuranceIds = new Set<Decimal>();
        List<SSP_InsurancePolicy__c> lstInsuranceToDelete = new List<SSP_InsurancePolicy__c>();
        for(SSP_InsurancePolicy__c objInsurance : lstInsurancePolicy) {
            objInsurance.RecordTypeId = Schema.SObjectType.SSP_InsurancePolicy__c.getRecordTypeInfosByDeveloperName().get(INSURANCE_RECORD_TYPE).getRecordTypeId();
            setInsuranceIds.add(objInsurance.DCId__c);
        }
        // Delete Existing Insurance or any policy record
        if (Schema.sObjectType.SSP_InsurancePolicy__c.fields.Id.isAccessible()) {
            lstInsuranceToDelete = [SELECT Id FROM SSP_InsurancePolicy__c WHERE DCId__c IN: setInsuranceIds];
        }
        if(!lstInsuranceToDelete.isEmpty()) {
            Database.delete(lstInsuranceToDelete, true);
        }
        // Insert new Insurance Policy Records
        if(Schema.sObjectType.SSP_InsurancePolicy__c.isCreateable() && Schema.sObjectType.SSP_InsurancePolicy__c.isUpdateable()) {
            performDML(lstInsurancePolicy, 'Upsert', sExternalIdField);
        }
        return lstInsurancePolicy;
    }

    /**
     * method                                               : upsertRelationship
     * @description                                         : upsert Relationship Records
     * @author                                              : Rajeev Kumar
     * @param lstRelationship                               : List of Relationship Records
     * @param sExternalIdField                              : Unique External Id field
     * @return List<SSP_Relationship__c>                    : List of inserted Relationship records
     */
    public List<SSP_Relationship__c> upsertRelationship(List<SSP_Relationship__c> lstRelationship, Schema.SObjectField sExternalIdField) {
        if(Schema.sObjectType.SSP_Relationship__c.isCreateable() && Schema.sObjectType.SSP_Relationship__c.isUpdateable()) {
            performDML(lstRelationship, 'Upsert', sExternalIdField);
        }
        return lstRelationship;
    }

    /**
     * method                                               : upsertAttendance
     * @description                                         : Upsert Attendance records
     * @author                                              : Rajeev Kumar
     * @param lstAttendance                                 : List of Attendance Records
     * @param sExternalIdField                              : Unique External Id field
     * @param List<SSP_Attendance__c>                       : List of Attendance Records
     */
    public List<SSP_Attendance__c> upsertAttendance(List<SSP_Attendance__c> lstAttendance, Schema.SObjectField sExternalIdField, String sApplicationId) {
        for(SSP_Attendance__c objAttendance : lstAttendance) {
            objAttendance.SSP_Application__c = sApplicationId;
        }
        if(Schema.sObjectType.SSP_Attendance__c.isCreateable() && Schema.sObjectType.SSP_Attendance__c.isUpdateable()) {
            performDML(lstAttendance, 'Upsert', sExternalIdField);
        }
        return lstAttendance;
    }

    /**
     * method                                               : upsertIndividualMedicalCoverage
     * @description                                         : Upsert IndividualMedicalCoverage Records
     * @author                                              : Rajeev Kumar
     * @param lstMedCoverage                                : List of IndividualMedicalCoverage Records
     * @param sExternalIdField                              : Unique External Id field
     * @return List<SSP_IndividualMedicalCoverage__c>       : List of inserted Individual Medical Coverage
     */
    public List<SSP_IndividualMedicalCoverage__c> upsertIndividualMedicalCoverage(List<SSP_IndividualMedicalCoverage__c> lstMedCoverage, Schema.SObjectField sExternalIdField) {
        if(Schema.sObjectType.SSP_IndividualMedicalCoverage__c.isCreateable() && Schema.sObjectType.SSP_IndividualMedicalCoverage__c.isUpdateable()) {
            performDML(lstMedCoverage, 'Upsert', sExternalIdField);
        }
        return lstMedCoverage;
    }

    /**
     * method                                               : upsertInsurancePlanTier
     * @description                                         : Upsert Attendance records
     * @author                                              : Rajeev Kumar
     * @param lstPanTier                                    : List of Attendance Records
     * @param sExternalIdField                              : Unique External Id field
     * @return List<SSP_HealthInsurancePlanTierDetail__c>   : List of inserted Health Insurance plan tier records
     */
    public List<SSP_HealthInsurancePlanTierDetail__c> upsertInsurancePlanTier(List<SSP_HealthInsurancePlanTierDetail__c> lstPanTier, Schema.SObjectField sExternalIdField) {
        if(Schema.sObjectType.SSP_HealthInsurancePlanTierDetail__c.isCreateable() && Schema.sObjectType.SSP_HealthInsurancePlanTierDetail__c.isUpdateable()) {
            performDML(lstPanTier, 'Upsert', sExternalIdField);
        }
        return lstPanTier;
    }

    /**
     * method                                               : upsertAlienSponsor
     * @description                                         : Upsert Alien Sponsor records
     * @author                                              : Rajeev Kumar
     * @param lstAlienSponsor                               : List of Alien Sponsor Records
     * @param sExternalIdField                              : Unique External Id field
     * @return List<SSP_AlienSponsor__c>                    : List of inserted alien sponsor records
     */
    public List<SSP_AlienSponsor__c> upsertAlienSponsor(List<SSP_AlienSponsor__c> lstAlienSponsor, Schema.SObjectField sExternalIdField) { 
        if(Schema.sObjectType.SSP_AlienSponsor__c.isCreateable() && Schema.sObjectType.SSP_AlienSponsor__c.isUpdateable()) {
            performDML(lstAlienSponsor, 'Upsert', sExternalIdField);
        }
        return lstAlienSponsor;
    }

    /**
     * method                                               : upsertBenefits
     * @description                                         : upsert Benefits recors
     * @author                                              : Rajeev Kumar
     * @param lstBenefits                                   : List of Benefits records
     * @return List<SSP_Benefits__c>                        : List of inserted Benefit records
     */
    public List<SSP_Benefits__c> upsertBenefits(List<SSP_Benefits__c> lstBenefits, Schema.SObjectField sExternalIdField) {
        for(SSP_Benefits__c objBenefit: lstBenefits) {
            if(objBenefit.recordType.Name == OOS_BENEFIT_RECORD_TYPE) {
                objBenefit.BenefitStateCountyKey__c = SSP_AnotherStateBenefitsService.generateUniqueID();
            }
        }
        if(Schema.sObjectType.SSP_Benefits__c.isCreateable() && Schema.sObjectType.SSP_Benefits__c.isUpdateable()) {
            //Database.upsert(lstBenefits, sExternalIdField, true);
            performDML(lstBenefits, 'Upsert', sExternalIdField);
        }
        return lstBenefits;
    }

    /**
     * method                                               : insertNonCustodialRelationship
     * @description                                         : insert Benefits recors
     * @author                                              : Rajeev Kumar
     * @param lstNonCustRel                                 : List of Non Custodial Relationship records
     * @return List<SSP_NoncustodialRelationship__c>         : List of inserted Non Custodial Relationship records
     */
    public List<SSP_NoncustodialRelationship__c> insertNonCustodialRelationship(List<SSP_NoncustodialRelationship__c> lstNonCustRel) {
        if(Schema.sObjectType.SSP_NoncustodialRelationship__c.isCreateable()) {
            performDML(lstNonCustRel, 'Insert', null);
        } 
        return lstNonCustRel;
    }

    /**
     * method                                               : insertFacilityType
     * @description                                         : insert Health Insurance Facility Type Records
     * @author                                              : Rajeev Kumar
     * @param lstFacilityType                               : List of Health Insurance Facility Type Records
     * @return List<SSP_HealthInsuranceFacilityType__c>     : List of inserted Health Insurance Facility type records
     */
    public List<SSP_HealthInsuranceFacilityType__c> insertFacilityType(List<SSP_HealthInsuranceFacilityType__c> lstFacilityType) {
        if(Schema.sObjectType.SSP_HealthInsuranceFacilityType__c.isCreateable()) {
            //ESAPI.accessController().insertAsUser(lstFacilityType, SSP_Utility.getFieldsNamesObject (lstFacilityType[0])); 
            performDML(lstFacilityType, 'Insert', null);

        }
        return lstFacilityType;
    }

    /**
     * method                                               : insertResourceOwnership
     * @description                                         : insert Resource Ownership Records
     * @author                                              : Rajeev Kumar
     * @param lstResourceOwnership                          : List of Resource Ownership Records
     * @return List<SSP_ResourceOwnership__c>               : List of inserted Resource Ownership Records
     */
    public List<SSP_ResourceOwnership__c> insertResourceOwnership(List<SSP_ResourceOwnership__c> lstResourceOwnership) {
        if(Schema.sObjectType.SSP_ResourceOwnership__c.isCreateable()) {
            //ESAPI.accessController().insertAsUser(lstResourceOwnership, SSP_Utility.getFieldsNamesObject (lstResourceOwnership[0])); 
            performDML(lstResourceOwnership, 'Insert', null);
        }
        return lstResourceOwnership;
    }

    /**
     * method                                               : insertNotifications
     * @description                                         : insert Notification Records
     * @author                                              : Rajeev Kumar
     * @param lstNotifications                              : List of Notiifications Record
     * @return List<SSP_Notifications__c>                   : List of inserted Notification Records
     */
    public List<SSP_Notifications__c> insertNotifications(List<SSP_Notifications__c> lstNotifications, Schema.SObjectField sExternalIdField) {
        if(Schema.sObjectType.SSP_Notifications__c.isCreateable() && Schema.sObjectType.SSP_Notifications__c.isUpdateable()) {
            performDML(lstNotifications, 'Upsert', sExternalIdField);
        }
        return lstNotifications;
    }

    /**
     * method                                               : insertNewMembersAccountAndContact
     * @description                                         : Insert New Members Account & Contact
     * @author                                              : Rajeev Kumar
     * @param lstMembers                                    : lstMembers List of members to be processed
     */
    public Map<String, Object> insertNewMembersAccountAndContact(List<SSP_Member__c> lstMembers) {
        List<Account> lstAccountsToInsert = new List<Account>();
        List<Contact> lstContactsToInsert = new List<Contact>();
        Map<String,Object> mapResult = new Map<String, Object>(); 
        Map<Integer, SSP_Member__c> mapProcessedIndividual = new Map<Integer, SSP_Member__c>();
        Map<Integer, SSP_Member__c> mapAllIndividuals = new Map<Integer, SSP_Member__c>();
        String sAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CITIZEN_ACCOUNT_RECORD_TYPE).getRecordTypeId();
        String sContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CITIZEN_CONTACT_RECORD_TYPE).getRecordTypeId();
        
        for(SSP_Member__c objMember : lstMembers) {
            mapAllIndividuals.put(Integer.valueOf(objMember.IndividualId__c), objMember);

        }

        // Get all the Individual Id's where Contact already exists
        Set<Integer> setNewContacts = SSP_SharingBypassFetcher.getContactsToInsert(mapAllIndividuals.keyset());
        // Prepare a list of Account and Contact to Insert
        for(SSP_Member__c  objMember: mapAllIndividuals.values()) {
            if(setNewContacts.contains(Integer.valueOf(objMember.IndividualId__c))) {
                // Create Account & Contact List who doesn't exist
                Account objAccount = new Account(Name=objMember.Firstname__c.trim() + ' ' + objMember.lastname__c.trim(),
                                                RecordTypeId = sAccountRecTypeId);
                Contact objContact = new Contact(FirstName = objMember.Firstname__c.trim(),
                                                Lastname = objMember.lastname__c.trim(),
                                                RecordTypeId = sContactRecTypeId,
                                                IndividualId__c = String.valueOf(objMember.IndividualId__c),
                                                birthdate = objMember.BirthDate__c,
                                                GenderCode__c = objMember.GenderCode__c
                                                );
                lstAccountsToInsert.add(objAccount);
                lstContactsToInsert.add(objContact);
                mapProcessedIndividual.put(Integer.valueOf(objMember.IndividualId__c), objMember);
            }
        }
        // Create Account and Contact via Rest Service for Community User
        if(!lstAccountsToInsert.isEmpty()) {
            mapResult = SSP_ProgramSelectionService.invokeAccountCreationService(lstAccountsToInsert,lstContactsToInsert,null);
        }
        return mapResult;
    }

    /**
     * method                                               : upsertAccounts
     * @description                                         : Insert Account for Agent Assister Auth Rep Service
     * @author                                              : Rajeev Kumar
     * @param lstAccount                                    : lstAccount List of Accounts to be processed
     */
    public List<Account> upsertAccounts(List<Account> lstAccount) {
        String sIndivdiualId = SSP_Utility.getIndividualId();
        Contact objCon = new Contact();
        if(!String.isBlank(sIndivdiualId)) {
            List<Contact> lstContact = [SELECT Id from Contact WHERE IndividualId__c =: sIndivdiualId];
            if(!lstContact.isEmpty()) {
                objCon.Id = lstContact.get(0).Id;
            }
        }
        Map<String,Object> result = SSP_ProgramSelectionService.invokeAccountCreationService(lstAccount, null, objCon.Id);
        return null;
    }

   /**
     * Method                                               : resetMembers
     * @description                                         : Reset member and Application
     * @author                                              : Rajeev Kumar
     * @param sAppId                                        : Application Id
     * @param setMeberIDs                                   : set of memeber Ids to process
     * @param sMode                                         : Mode of the transaction
     */
    public List<SSP_Member__c> resetMembers(List<SSP_Member__c> lstMembers, String sAppId, String sMode) {
        //final attributes
        final String OBJECT_QUERY = 'Select Field_Name__c,Object_Name__c FROM RSSP_DC_ResetFilter__mdt WHERE ';
        final String WHERE_CONDITION_RAC = 'Is_RAC__c = true'; 
        final String WHERE_CONDITION_INTAKE = 'Is_Intake__c = true';
        List<Integer> lstMemberIndvId = new List<Integer>();
        for(SSP_Member__c objMember : lstMembers) {
            lstMemberIndvId.add(Integer.valueOf(objMember.IndividualId__c));
        }
        Map<Decimal,String> mapMmeberIds = SSP_Utility.getMemberIds(lstMemberIndvId);

        Set<Id> setMemberIds = new  Set<Id>();
        Map<String,Set<String>> mapFilterField = new Map<String,Set<String>>();
        List<SSP_Member__c> lstMemberToBeUpdated = new List<SSP_Member__c>();
        SSP_Application__c objAppToBeUpdated;
        String sQuery = OBJECT_QUERY;

        if(sMode == SSP_InterfaceConstants.MODE_RAC) {
            sQuery += WHERE_CONDITION_RAC;
        } else {
            sQuery += WHERE_CONDITION_INTAKE;
        }
        if(Schema.sObjectType.RSSP_DC_ResetFilter__mdt.fields.Id.isAccessible()) {
            for(RSSP_DC_ResetFilter__mdt objIterate : DataBase.query(sQuery)) {
                if(mapFilterField.containsKey(objIterate.Object_Name__c)) {
                    mapFilterField.get(objIterate.Object_Name__c).add(objIterate.Field_Name__c.toLowerCase());    
                } else{
                    mapFilterField.put(objIterate.Object_Name__c,new Set<String>{objIterate.Field_Name__c.toLowerCase()});       
                }      
            }
        }
        SSP_Member__c objMemberIns = (SSP_Member__c)SSP_Member__c.sObjectType.newSObject(null, true);
        Map<String, Schema.SobjectField> mapMemberFields = Schema.SObjectType.SSP_Member__c.fields.getMap();
        Set<String> setOfFields = mapFilterField.get(SSP_InterfaceConstants.SSP_Member);
        if(Schema.sObjectType.SSP_Member__c.fields.Id.isAccessible()) {
            for(SSP_Member__c objMember : [SELECT Id
                                            FROM SSP_Member__c
                                            WHERE Id in : mapMmeberIds.values()]) {
                setMemberIds.add(objMember.Id);                                                 
                for(String key : mapMemberFields.keySet()) {
                    /*
                    if(mapMemberFields.get(key).getDescribe().isUpdateable() && Schema.DisplayType.Boolean == mapMemberFields.get(key).getDescribe().getType()) {
                        objMember.put(key,false);   
                    } else if(mapMemberFields.get(key).getDescribe().isUpdateable()) {
                        objMember.put(key,null); 
                    }
                    */
                    if((setOfFields!= null && !setOfFields.contains(key))) {
                        if(mapMemberFields.get(key).getDescribe().isUpdateable()) {
                            if(Schema.DisplayType.Boolean == mapMemberFields.get(key).getDescribe().getType()) {
                                objMember.put(key,false);   
                            } else {
                                objMember.put(key,null); 
                            }
                        }
                    } else if(setOfFields == null && mapMemberFields.get(key).getDescribe().isUpdateable()) {
                        if(Schema.DisplayType.Boolean == mapMemberFields.get(key).getDescribe().getType()) {
                            objMember.put(key,false);   
                        } else {
                            objMember.put(key,null); 
                        }
                    }
                }
                lstMemberToBeUpdated.add(objMember);
            }
        }
        if(sAppId != null) {
            objAppToBeUpdated = new SSP_Application__c();
            SSP_Application__c objAppIns = (SSP_Application__c)SSP_Application__c.sObjectType.newSObject(null, true);
            Map<String, Schema.SobjectField> mapAppFields = Schema.SObjectType.SSP_Application__c.fields.getMap();
            setOfFields = mapFilterField.get(SSP_InterfaceConstants.SSP_APPLICATION);
            for(String key : mapAppFields.keySet()) {
                /*
                if(mapAppFields.get(key).getDescribe().isUpdateable() && Schema.DisplayType.Boolean == mapAppFields.get(key).getDescribe().getType()) {
                    objAppToBeUpdated.put(key,false);   
                } else if(mapAppFields.get(key).getDescribe().isUpdateable()) {
                    objAppToBeUpdated.put(key,null); 
                }
                */
                if((setOfFields!= null && !setOfFields.contains(key)) && mapAppFields.get(key).getDescribe().isUpdateable()) {
                    if(Schema.DisplayType.Boolean == mapAppFields.get(key).getDescribe().getType()) {
                        objAppToBeUpdated.put(key,false);
                    } else{
                        objAppToBeUpdated.put(key,null);
                    }
                } else if(setOfFields == null && mapAppFields.get(key).getDescribe().isUpdateable()) {
                    if(Schema.DisplayType.Boolean == mapAppFields.get(key).getDescribe().getType()) {
                        objAppToBeUpdated.put(key,false);
                    } else{
                        objAppToBeUpdated.put(key,null);
                    }
                }
            }
        }
        mapFilterField.clear();
        if(objAppToBeUpdated != null) {
            objAppToBeUpdated.Id = sAppId;
            performDML(new List<SSP_Application__c> { objAppToBeUpdated }, 'Update', null);
        }
        if(! lstMemberToBeUpdated.isEmpty()) {
            performDML(lstMemberToBeUpdated, 'Update', null);
        }
        return lstMemberToBeUpdated;
    }

    /**
     * method                                               : deleteChildRecs
     * @description                                         : Delete all child records of provided members
     * @author                                              : Rajeev Kumar
     * @param setMemberIds                                  : setMemberIds - set of memberIDs to be processed
     * @param sAppId                                        : Application Id of the record
     */
    public void deleteChildRecs(List<SSP_Member__c> lstMembers, String sAppId) {
        final String SELECT_QUERY = 'Select Id from ';
        final String WHERE_CLAUSE = ' Where ';
        List<sObject> lstChildRecsToBeDeleted = new List<sObject>();
        if(lstMembers == null || (lstMembers!= null && lstMembers.isEmpty())) {
            return;
        }
        Map<String,String> mapObjectToCondition = new Map<String,String>{
            'SSP_IndividualMedicalCoverage__c'=>SSP_InterfaceConstants.SSP_Member,
            'SSP_Relationship__c'=>SSP_InterfaceConstants.SSP_Member,
            'SSP_Benefits__c'=>SSP_InterfaceConstants.SSP_Member,
            'SSP_Attendance__c'=>SSP_InterfaceConstants.SSP_Member,
            'SSP_NoncustodialRelationship__c'=>SSP_InterfaceConstants.SSP_Member,
            'SSP_Asset__c'=>SSP_InterfaceConstants.SSP_Member,
            'SSP_InsuranceCoveredIndiv__c'=>SSP_InterfaceConstants.SSP_Member,
            'SSP_ApplicationIndividual__c'=>SSP_InterfaceConstants.SSP_APPLICATION,
            'SSP_TrackDeletion__c' =>SSP_InterfaceConstants.SSP_APPLICATION
        };

        for(String sIterate : mapObjectToCondition.keySet()) {
            String sWhereCondition;
            if(sIterate!=null && (sIterate.equals('SSP_ApplicationIndividual__c') || sIterate.equals('SSP_TrackDeletion__c'))) { //SSP_Interface_Security Fixes -- Added null check to the string
                sWhereCondition = mapObjectToCondition.get(sIterate)+'=:sAppId';
            } else {
                sWhereCondition = mapObjectToCondition.get(sIterate)+' in: lstMembers';
            }
            String sQuery = SELECT_QUERY + sIterate + WHERE_CLAUSE + sWhereCondition;
            List<sObject> lstTemData =  DataBase.query(sQuery);
            if(lstTemData != null) {
                lstChildRecsToBeDeleted.addAll(lstTemData);  
            }
        }
        if(!lstChildRecsToBeDeleted.isEmpty()) {
            Database.delete(lstChildRecsToBeDeleted);
        }
    }

    /**
     * method                                               : performDML
     * @description                                         : Performs DML on each object
     * @author                                              : Rajeev Kumar
     * @param lstRecords                                    : List of Records
     * @param sActionType				    : Action Type
     * @param sExternalIdField                              : External Id field
     */
    public void performDML(List<sObject> lstRecords, String sActionType, Schema.SObjectField sExternalIdField) {
        Schema.SObjectType sObjectType = lstRecords.getSObjectType();
        List<sObject> lstCastRecords = new List<sObject>();
        if (sObjectType != null) {
            String slistType = 'List<' + sObjectType + '>';
            lstCastRecords = (List<sObject>)Type.forName(slistType).newInstance();
            lstCastRecords.addAll(lstRecords);
        }
        try {
            if(sActionType == 'Upsert' && sExternalIdField == null) {
                Database.upsert(lstCastRecords, true);
            } else if(sActionType == 'Upsert') {
                Database.upsert(lstCastRecords, sExternalIdField, true);
            } else if(sActionType == 'Insert') {
                Database.Insert(lstCastRecords, true);
            } else if(sActionType == 'Update') {
                Database.Update(lstCastRecords, true);
            }
        } catch (DMLException ex) {

            if(StatusCode.UNABLE_TO_LOCK_ROW == ex.getDmlType(0) || StatusCode.DUPLICATE_VALUE == ex.getDmlType(0)) {
                boolean boolIsRepeat = true; 
                integer intCount = 0; 
                while (boolIsRepeat && intCount < 10) {
                    try {  
                        boolIsRepeat = false;
                        if(sActionType == 'Upsert' && sExternalIdField == null) {
                            Database.upsert(lstCastRecords, true);
                        } else if(sActionType == 'Upsert') {
                            Database.upsert(lstCastRecords, sExternalIdField, true);
                        } else if(sActionType == 'Insert') {
                            Database.Insert(lstCastRecords, true);
                        } else if(sActionType == 'Update') {
                            Database.Update(lstCastRecords, true);
                        }                    
                    } catch (System.DmlException excp) {
                        if(StatusCode.UNABLE_TO_LOCK_ROW == excp.getDmlType(0) || StatusCode.DUPLICATE_VALUE == excp.getDmlType(0)) {
                            boolIsRepeat = true; 
                            intCount++;
                        } else {
                            throw excp;
                        }
                    }
                }
                if(intCount > 10) { 
                    throw ex;
                }
            } else {
                throw ex;
            }
        }
    }
}