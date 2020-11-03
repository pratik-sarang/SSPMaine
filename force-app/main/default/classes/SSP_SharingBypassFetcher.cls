/*
* @classname    :  SSP_SharingBypassFetcher 
* @description  :  Class to hold all utility methods which need to run system mode
* @author       :  Ajay Saini
* @date         :  JAN-06-2020
* ---------------------------------------------------------------------------------------------*/
public without sharing class SSP_SharingBypassFetcher {
    public static final string SSPVCI_METADATANAME = 'SSP_VCI';
    public static final string SSPNONESI_METADATANAME = 'SSP_NONESIMECService';
    public static List<SSP_Transaction__c> fetchTransactionRecords(String individualId, Set<String> views){
        return [SELECT Id, View_Name__c, Status__c, Log_Message__c FROM SSP_Transaction__c WHERE IndividualId__c = :individualId AND View_Name__c IN :views LIMIT 5000];
    }
     public static List<SSP_Transaction__c> fetchTransactionRecords(String uniqueId){
        return [SELECT Id, Status__c, Log_Message__c FROM SSP_Transaction__c WHERE Unique_Id__c = :uniqueId];
    }
    public static List<Contact_Mapping__c> fetchContactMapping(Integer individualId){
        return [Select Contact__c from Contact_Mapping__c WHERE IEES_Id__c = :individualId];
    }	
    public static List<Contact_Mapping__c> fetchContactMappingRecordList(List<Integer> lstIndividualIds) {
        return [SELECT Id, Contact__c, Group_Id__c, IEES_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN: lstIndividualIds];
    }
    public static List<SSP_CountyZipCodeAssociation__c> fetchCountyZipCode(String zipCode) {
        return [SELECT id, CountyCode__c FROM SSP_CountyZipCodeAssociation__c WHERE ZipCode5__c = :zipCode];
    }
    
    public static List<AccountContactRelation> fetchAssisterPresentACRList(String accountId, String contactId) {
       return [Select AccountId, ContactId from AccountContactRelation 
               where AccountId = :accountId and ContactId != :contactId
			   AND (Roles = 'Assister' OR Roles = 'Agency_Admin')];
    }
    public static List<AccountContactRelation> fetchAssisterCurrentACRList(String accountId, String contactId) {
        return [Select AccountId, ContactId,RequestAccessPermission__c from AccountContactRelation 
                where AccountId = :accountId and ContactId = :contactId
                AND (Roles = 'Assister' OR Roles = 'Agency_Admin')];
    }
    
    public static List<AccountContactRelation> fetchAssisterList(String acrRole) {
       return [SELECT Id,contactId from AccountContactRelation WHERE account.recordtype.developerName = 'Resource_Engine' AND Roles INCLUDES (:acrRole) AND contact.recordtype.developername = 'Non_Citizen'];
    }
     public static List<AccountContactRelation> fetchAuthRepDCId(String contactId) {
       return [SELECT Id,DCContactId__c from AccountContactRelation WHERE account.recordtype.developerName = 'Resource_Engine' AND (Roles INCLUDES ('Individual_Auth_Rep') OR Roles INCLUDES ('Organization_Auth_Rep')) AND contactId=:contactId];
    }
        public static List<SSP_Application__c> fetchExistingCase(String caseNumber, String contactId){
        Map<String, String> accountIdMapping = new Map<String, String>();
        List<SSP_Application__c> caseList = new List<SSP_Application__c>();
        for(SSP_Application__c sspCase : [SELECT Id, Account__c FROM SSP_Application__c WHERE DCCaseNumber__c = :Decimal.ValueOf(caseNumber) AND RecordTypeId = :SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case') LIMIT 100]){
            accountIdMapping.put(sspCase.Account__c, '');
            caseList.add(sspCase);
        }
        
        if(!accountIdMapping.isEmpty()){
            for(AccountContactRelation acr : [SELECT Id, AccountId FROM AccountContactRelation WHERE AccountId IN :accountIdMapping.keySet() AND ContactId = :contactId LIMIT 100]){
                accountIdMapping.remove(acr.AccountId);
            }
            
            if(!accountIdMapping.isEmpty()){
                List<AccountContactRelation> acrList = new List<AccountContactRelation>();
                for(String accountId : accountIdMapping.keySet()){
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.AccountId = accountId;
                    acr.ContactId = contactId;
                    acrList.add(acr);
                }
                
                if(!acrList.isEmpty()){
                    insert acrList;
                }
            }
        }	
        return caseList;	
    }

    /*
    * Name : sendHTTPRequest 
    * Description: This method will be used to provide the methods to make Http GET callouts
    * Date: JAN-06-2020
    */
    public static String sendHTTPRequest(String url) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(String.escapeSingleQuotes(url));
            req.setMethod('GET');
            Http http = new Http();
            return http.send(req).getBody();
        }
        catch(System.Exception e) {
            return JSON.serialize(e);
        }
    }
   
        /**************************************************************************************
* @author       Sai Kiran
* @date         07/01/2020
* @methodname   getUsersList for Profile
* @description  This methods is used to get Users for a profile
* @param        String strProfileName
* @return       List<User> 
******************************************************************************************/
    public static List<User> getUserList(String sProfileName){
        List<User> userList = [SELECT Id,Name FROM User WHERE Profile.Name=:sProfileName AND IsActive=true ORDER BY CreatedDate asc LIMIT 1];        
        return userList;
    }
    
    public static List<SObject> fetchRecords(Map<String, String> detailMap, Set<String> fieldSet, Map<String, String> conditionsMap) {
        return SSP_Utility.fetchRecords(detailMap, fieldSet, conditionsMap);
    }

    public static List<FAQ__kav> queryKnowledgeArticles(String screenName, String lang){
        List<FAQ__kav> FAQList = new List<FAQ__kav>();
        FAQList = [SELECT Id, Title, HelpModal__c, ScreenName__c, Language, Order__c 
                   FROM FAQ__kav WHERE (PublishStatus = 'Draft' 
                   AND RecordType.DeveloperName = 'Helpmore' AND ScreenName__c = :screenName
                   AND language = :lang)];
        
        return FAQList;
    }

    public static String fetchExistingAccount(String caseNumber, String contactId){
        String accountId;
        List<Account> caseAccountList = [SELECT Id FROM Account WHERE CaseNumber__c = :caseNumber LIMIT 1];
        if(caseAccountList != null && !caseAccountList.isEmpty()){
            accountId = caseAccountList[0].Id;
            Map<String, AccountContactRelation> acrList = new Map<String, AccountContactRelation>{accountId => new AccountContactRelation(AccountId = accountId, ContactId = contactId)};

            for(AccountContactRelation acr : [SELECT Id, AccountId FROM AccountContactRelation WHERE AccountId = :accountId AND ContactId = :contactId LIMIT 100]){
                acrList.remove(acr.AccountId);
            }

            if(acrList != null && !acrList.isEmpty() && acrList.values().size() > 0){
                insert acrList.values();
            }
        }
        return accountId;
    }

    /**
     * method                                       : getContacts
     * @description                                 : Retrieve Contacts by bypassing sharing
     * @author                                      : Rajeev Kumar
     * @param setContactIds                         : Set of Contact Ids
     * @return List<Contact>                        : List of Contact Records
     */
    public static List<Contact> getContacts(Set<String> setContactIds) {
        return [SELECT Id, IndividualId__c from Contact WHERE IndividualId__c IN: setContactIds];
    }
    /**
     * method                                       : getContactsByDCACRIds
     * @description                                 : Retrieve Contacts by bypassing sharing
     * @author                                      : Rajeev Kumar
     * @param setDCACRIds                           : Set of DCACRIds on Contact
     * @return List<Contact>                        : List of Contact Records
     */
    public static List<contact> getContactsByDCACRIds(Set<String> setDCACRIds) {
        return [SELECT Id, RecordType.Name, DCACRId__c from Contact WHERE DCACRId__c IN: setDCACRIds];
    }

    /**
     * method                                       : getAccountsByCaseNumbers
     * @description                                 : Retrieve Accounts by bypassing sharing
     * @author                                      : Rajeev Kumar
     * @param setCaseNumbers                        : Set of caseNumbers on Account
     * @return List<Account>                        : List of Account Records
     */
    public static List<Account> getAccountsByCaseNumbers(Set<String> setCaseNumbers) {
        return [SELECT Id, CaseNumber__c from Account WHERE CaseNumber__c IN :setCaseNumbers];
    }
    /*
    * method        								: dmlOnGenericSobjectList
    * @description  								: This method is use to perform DML oprations on List of Sobject.
    * @author       								: Ashwin Kasture
    * @param lstRecords								: Contains List of sObject records.
    * @param sOperationType 						: Contains DML operation to perform.
    * @param sObjectName							: Contains name of Object.
    * @return       								: void
    * */
    public static List<sObject> dmlOnGenericSobjectList(List<sObject> lstRecords, String sOperationType, String sObjectName) {
        if(sOperationType == 'insert') {
            insert lstRecords;
        } else if(sOperationType == 'update') {
            update lstRecords;
        } else if(sOperationType == 'upsert' && String.isNotBlank(sObjectName)) {
            List<sObject> lstUpsert = dynamicSObject(lstRecords, sObjectName);
            upsert lstUpsert;
        } else if(sOperationType == 'delete') {
            delete lstRecords;
        }
        return lstRecords;
    }
    /*
    * method        								: dynamicSObject
    * @description  								: This method is use to form Object type based on ObjectName.
    * @author       								: Ashwin Kasture
    * @param lstRecords								: Contains List of sObject records.
    * @param sObjectName 							: Contains name of Object.
    * @return List<SObject> 						: List of sObject
    * */
    public static List<SObject> dynamicSObject(List<sObject> lstRecords, String sObjectName) {
        String slistType = 'List<' + sObjectName + '>';
        List<sObject> lstSObject = (List<sObject>)Type.forName(slistType).newInstance();
        lstSObject.addAll(lstRecords);
        return lstSObject;
	}
    
    public static void deleteRecords(String appId){
        List<NavFlowStatus__c> flowStatList = new List<NavFlowStatus__c>();
        if(String.isNotBlank(appId)){
            flowStatList = SSP_NavFlowStatusSelector.queryFlowStatusByApplicationId(appId, new Set<String>{'Name'});
        }         
        if(!flowStatList.isEmpty() ){
            delete flowStatList;
        }            
    }

     /*
    * method        								: getSSPDCRecords
    * @description  								: This query ACR and Contact for SSPDC
    * @author       								: Rijia Khatun
    * @return List<SObject> 						: List of sObject
    * */
    public static List<sObject>  getSSPDCRecords(String sQuery, String sApplicationId,
        Set<Id> setContactId, Set<Id> setMemberIds, Set<ID> setAlienSponsorId) {
        return Database.query(sQuery);
    }

      /*
    * method        								: deleteExistingData
    * @description  								: This to delete transaction record for VCI
    * @author       								: Rijia Khatun
    * @return 						                : 
    * */
    public static void deleteExistingData(String sAppID, Set<String> setOfSSNs) {
        if(Schema.sObjectType.SSP_Transaction__c.fields.Id.isAccessible()){
            List<SSP_Transaction__c> lstToBeDeleted = [Select Id from SSP_Transaction__c
                                                            where ApplicationId__c=:sAppID 
                                                            AND InterfaceName__c=:SSP_InterfaceConstants.SSPVCI_METADATANAME
                                                            AND SSN__c in:setOfSSNs];
            if(!lstToBeDeleted.isEmpty() && Schema.sObjectType.SSP_Transaction__c.isDeletable() ) {
                Database.delete(lstToBeDeleted);
            }
        }
    }

    public static Set<Integer> getContactsToInsert(Set<Integer> setIndividuals) {
        //Perf fix - Keshav/Sajan
        List<Contact_Mapping__c> listConMap = [SELECT Id, Group_Id__c, IEES_Id__c, Contact__c from Contact_Mapping__c WHERE IEES_Id__c IN :setIndividuals];
        for(Contact_Mapping__c objConMapping : listConMap) {
            setIndividuals.remove(Integer.valueOf(objConMapping.IEES_Id__c));
        }
        return setIndividuals;
    }

    public static void insertConMappingRecords(Set<Integer> setIndividualIds) {
        List<Contact_Mapping__c> lstContactMapping = new List<Contact_Mapping__c>();
        if(setIndividualIds != null && !setIndividualIds.isEmpty()) {
            for(Integer sIndv: setIndividualIds) {
                Contact objCon = new Contact(IndividualId__c=String.valueOf(sIndv));
                lstContactMapping.add(new Contact_Mapping__c(Contact__r=objCon, IEES_Id__c=sIndv, Group_Id__c='Grp'+string.valueOf(sIndv)+String.valueOf(DateTime.now().getTime()).right(3)));
            }
        }
        if(!lstContactMapping.isEmpty()) {
            Database.insert(lstContactMapping, true);
        }
    }


    
    /**
     * method                                       : getContactsForUpdateDCRep
     * @description                                 : This is called in SSP_UpdateDCRepIntegrationUtility class to
                                                        Retrieve Contacts by bypassing Contact Id
     * @author                                      : Ragunathan
     * @param contactId                             : Id of a Contact
     * @return List<Contact>                        : List of Contact Records
     */
    public static List<Contact> getContactsForUpdateDCRep(String contactId) {
        return [Select 
                    Id,
                    FirstName,
                    MiddleName,
                    LastName,
                    SuffixCode__c,
                    OrganizationName__c,
                    OrgranizationIdentificationNumber__c,
                    Phone,
                    PrimaryPhoneExtension__c,
                    Email,
                    PreferredLanguageCode__c,
                    GenderCode__c,
                    BirthDate,
                    SSN__c,
                    AgencyOrOrganization__r.DCDataId__c,
                    IsManualAuthRep__c,
                    DCDataId__c
                From Contact WHERE Id =: contactId];
    }

    /**
     * method                                       : getSSPApplicationForUpdateDCRep
     * @description                                 : This is called in SSP_UpdateDCRepIntegrationUtility class to
                                                       Retrieve SSP Applications by bypassing Application Id
     * @author                                      : Ragunathan
     * @param applicationId                         : Id of a SSP_Application__c
     * @return List<SSP_Application__c              : List of SSP_Application__cRecords
     */
    public static List<SSP_Application__c> getSSPApplicationForUpdateDCRep(String applicationId) {
        return [Select  DCCaseNumber__c from SSP_Application__c WHERE Id =: applicationId];
    }
}
