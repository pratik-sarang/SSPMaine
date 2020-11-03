/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_RelatedResourcesCtrlTest
*   Created By   :   Deloitte
*   Created Date :   07/25/2019
*   Description :   This class acts as a test class for RE_RelatedResourcesCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                    07/25/2019        Initial Version
*****************************************************************************************************************************/

@isTest
public with sharing class RE_RelatedResourcesCtrlTest {

    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         07/25/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setupTestData(){        
        TestDataFactory.testDataSetup();
        List<Location__c> locationList = [SELECT id FROM Location__c ];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c ];
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        List<Profile> lstProfile = [SELECT Id,Name FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST OR Name =: RE_GlobalConstants.strCitizenProfileName];
        Profile objProfile;
        Profile citizenProfile;
        for(Profile objPro : lstProfile){
            if(objPro.name == RE_GlobalConstants.STANDARD_USER_PROFILE_TEST){
                objProfile = objPro;
            }
            else if(objPro.name == RE_GlobalConstants.strCitizenProfileName){
                citizenProfile = objPro;
            }
            
        }
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(idAccount);
        Id sContactId = [SELECT Id FROM Contact WHERE Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        User objReUser = TestDataFactory.createSpecificCommunityUser('reusr', null, 'REUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);  
        Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(lstCitizenAccounts[0].Id);
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='35321';
        if(RE_DataAccessChecker.isAllowedToCreate(Contact.getSObjectType())){
            insert citizenContact;
        }
       // Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
    	Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> resourceLst = TestDataFactory.createResources(2, true, resourceRecordTypeId, lstAccountIds);
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationLst = TestDataFactory.createLocations(2, true, locationRecordTypeId, lstAccountIds);
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(2, true, null, locationLst, resourceLst);
        REIntegrationEndpoints__c endpointsetting= new REIntegrationEndpoints__c();
        endpointsetting.Name='RelatedResources';
        endpointsetting.Content_Type__c='application/JSON';
        endpointsetting.Http_Method_Type__c='POST';
        endpointsetting.Endpoint_URI__c='http://www.testendpointIEES.com';
        endpointsetting.Is_Mock_Response_Enabled__c=true;
        endpointsetting.Is_Cert_Required__c=false;
        endpointsetting.Certificate_Name__c='test';
        endpointsetting.TimeOut__c='20000';
        insert endpointsetting;
    }
	/********************************************************************************************
    * @author       Suyash Singhal
    * @date         07/25/2019
    * @methodname   fetchRelatedResourcesTest
    * @description  This method is used to test the functionality of method - fetchRelatedResources.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void fetchRelatedResourcesTest(){
        List<RE_Taxonomy__c> lstTaxonomies = TestDataFactory.createTaxonomyRecords(4,true);
        List<Resource__c> resourceList = [SELECT id,Organization__c FROM Resource__c];
        List<Double> lstGeoLocation = new List<Double>{38.5784495 ,-89.9242936};
        List<RE_Resource_Taxonomy__c> lstResTaxonmies = TestDataFactory.createResourceTaxonomyRecords(resourceList.size(),true,resourceList,lstTaxonomies);
        //List<User> usrLst= [SELECT Id,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST or Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        List<RE_Taxonomy__c> lstEmptyTaxonomy = new List<RE_Taxonomy__c>();
        List<RE_Config__c> lstTaxGrp = TestDataFactory.createRelResourcesConfigRecords(1,true,lstEmptyTaxonomy,'TaxonomyGroup');
        List<RE_Config__c> lstResourceMappings = TestDataFactory.createRelResourcesConfigRecords(1,true,lstTaxonomies,'SuggestedResourceMapping');
        List<RE_Config__c> lstResMappings = TestDataFactory.createRelResourcesConfigRecords(4,true,lstTaxonomies,'TaxonomyGroupMember');
        List<String> locResourceIDs=new List<String>();
        for(LocationResource__c locRes:[Select Id,Location__r.Status__c,Status__c,Resource__r.Organization__r.Status__c from LocationResource__c]){
            
            locResourceIDs.add(locRes.Id);
        }
        List<String> status=new List<String>();
        status.add('200');
        RE_RelatedResourceMock resmock=new RE_RelatedResourceMock(JSON.serialize(locResourceIDs),JSON.serialize(status),JSON.serialize(new List<String>()));
        Test.setMock(HttpCalloutMock.class, resmock);
        Test.startTest();
            for(User u : [SELECT Id,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST or Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST]){
                if(u.Email == RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST){
                    System.runAs(u){
                        RE_CreateLightningServerResponse response= RE_RelatedResourcesCtrl.fetchRelatedResources(resourceList[0].Id,lstGeoLocation);
                        System.assertEquals(response.isSuccessful, true,'Success');
                    }
                }
            }
        Test.StopTest();
    }
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         02/27/2020
    * @methodname   fetchRelatedResourcesErrorTest
    * @description  This method is used to test the functionality of method - fetchRelatedResources.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void fetchRelatedResourcesErrorTest(){
        List<RE_Taxonomy__c> lstTaxonomies = TestDataFactory.createTaxonomyRecords(4,true);
         List<Double> lstGeoLocation = new List<Double>{38.5784495 ,-89.9242936};
         List<Resource__c> resourceList = [SELECT id,Organization__c FROM Resource__c];
        List<RE_Resource_Taxonomy__c> lstResTaxonmies = TestDataFactory.createResourceTaxonomyRecords(resourceList.size(),true,resourceList,lstTaxonomies);
         List<String> status=new List<String>();
         status.add('400');
        List<String> emsglst=new List<String>();
        emsglst.add('test erro msg');
         RE_RelatedResourceMock resmock=new RE_RelatedResourceMock(JSON.serialize(new List<String>()),JSON.serialize(status),JSON.serialize(emsglst));
         Test.setMock(HttpCalloutMock.class, resmock);
        Test.startTest();
        for(User u : [SELECT Id,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST or Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST]){
            if(u.Email == RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response= RE_RelatedResourcesCtrl.fetchRelatedResources(resourceList[0].Id,lstGeoLocation);
                    System.assertEquals(response.isSuccessful, true,'Success');
                }
            }
        }
        Test.StopTest();
        
    }
	
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         08/09/2019
    * @methodname   testInsertReferralForResident
    * @description  This method is used to test the functionality of method - insertReferralForResident.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testInsertReferralForResident() {  
   		RE_CreateLightningServerResponse response;
		Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account WHERE recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        List<Resource__c> lstResource = [SELECT id FROM Resource__c WHERE Organization__c in : lstCitizenAccounts];
        List<Location__c> lstLocation = [SELECT id FROM Location__c WHERE Account__c in : lstCitizenAccounts];
        String inputJson = '{ "sResourceName" : "test ResName", "sResourceId" : "'+lstResource[0].Id+'", "sResourceAccountName" : "test Acc Name", "sResourceAccountId" : "'+lstCitizenAccounts[0].Id+'", "sFactoidData" : "test data", "dMiles" : "752.5070469744187", "sSDOHDomain" : "", "sLocationId" : "'+lstLocation[0].Id+'", "bisOrgClaimed" : true, "bdisableConnect" : true }';
        User citizenUser = [SELECT Id, ContactId,Contact.AccountId FROM User WHERE Profile.Name=: RE_GlobalConstants.strCitizenProfileName AND isActive=true LIMIT 1];
        Test.startTest();
        System.runAs(citizenUser){
            response =  RE_RelatedResourcesCtrl.insertReferralForResident(inputJson, false,RE_GlobalConstants.SIMILAR_RESOURCE);
        	System.assertEquals(response.isSuccessful, true,'Success');
            inputJson = '{ "sResourceName" : "test ResName", "sResourceId" : "'+lstResource[0].Id+'", "sResourceAccountName" : "test Acc Name", "sResourceAccountId" : "'+lstCitizenAccounts[0].Id+'", "sFactoidData" : "test data", "dMiles" : "752.5070469744187", "sSDOHDomain" : "", "sLocationId" : "'+lstLocation[0].Id+'", "bisOrgClaimed" : false, "bdisableConnect" : true }';
            response =  RE_RelatedResourcesCtrl.insertReferralForResident(inputJson, true,RE_GlobalConstants.COMPLEMENTARY_RESOURCE);
        	System.assertEquals(response.isSuccessful, true,'Success');
        }
        Test.stopTest();
    }
}