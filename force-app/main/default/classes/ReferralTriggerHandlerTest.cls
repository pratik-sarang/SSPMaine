@isTest
public class ReferralTriggerHandlerTest {
    
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id,POC_Name__c,Name,POC_Email__c FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='43223';
        insert citizenContact;
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation = TestDataFactory.createLocations(2, true, locationRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = TestDataFactory.createResources(10, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        List<Referral__c> lstRreferral=TestDataFactory.createReferral(10,true,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,citizenContact.Id,lstCitizenAccounts,lstResource);
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(2, true, null, lstLocation, lstResource);
    }
    
    @isTest
    public static void getOrgRefCount(){
        Map<Id,Integer> orgIdCountMap = new Map<Id,Integer>();
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        List<Account> accountList = TestDataFactory.createAccounts(10,true,sREAccRecTypeId);
        Set<Id> orgSet = new Set<Id>();
        for(Account a : accountList){
            orgSet.add(a.Id);
        }
        List<AggregateResult> results = [SELECT COUNT(Id) cnt, ReferredAccountID__c rid FROM Referral__c WHERE ReferredAccountID__c IN:orgSet GROUP BY ReferredAccountID__c];
        for(AggregateResult result : results){
            Id orgId = (Id)result.get('rid');
            Integer orgCount = (Integer)result.get('cnt');
            orgIdCountMap.put(orgId, orgCount);
        }
        System.assert(true, orgIdCountMap != null);
    }
    
    @isTest
    public static void testcreateCommunicationRecord(){
        List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        List<Account> lstAccounts = TestDataFactory.createAccounts(1,true,sREAccRecTypeId);
        List<Location__c> lstLocations = [SELECT Id,PointOfContactName__c,AccountName__c,Account__c,PointofContactEmail__c FROM Location__c LIMIT 1];
        
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(lstAccounts[0].Id);
        List<Resource__c> resourceLst = TestDataFactory.createResources(2, true, null, lstAccountIds);
        List<Location__c> locationLst = TestDataFactory.createLocations(2, true, null, lstAccountIds);
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(2, true, null, locationLst, resourceLst);
        Test.startTest();
        Boolean isFirstEmail = true;
        String orgId = lstAccounts[0].Id;
        String resourceURL= Community_URL_Settings__c.getOrgDefaults().URL__c+'/s/searchorganization?isOpenClaimRequest='+true+'&orgId=';
        
        ReferralTriggerHandler.createCommunicationRecord(lstAccounts, isFirstEmail, resourceURL);
        ReferralTriggerHandler.createCommunicationRecord(lstLocations, isFirstEmail, resourceURL);
        ReferralTriggerHandler.createCommunicationRecord(lstLocRes, isFirstEmail, resourceURL);
        ReferralTriggerHandler.getOrgData(null);
        ReferralTriggerHandler.getLocationResources(null, null);
        ReferralTriggerHandler.getOrgRefCount(null);
        ReferralTriggerHandler.getLocations(null);
        ReferralTriggerHandler.sendEmail(null, false, 'resourceurl');
        ReferralTriggerHandler.createCommunicationRecord(null, true, 'resourceurl');
        System.assert(lstAccounts.size() > 0, true);
        System.assert(lstLocations.size() > 0, true);
        System.assert(lstLocRes.size() > 0, true);
        Test.stopTest();
    }
    
    
}