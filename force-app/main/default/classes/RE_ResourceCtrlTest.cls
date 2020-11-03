/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_ResourceCtrlTest
*   Created By   :   Deloitte
*   Created Date :   05/24/2019
*   Description :   This class acts as a test class for RE_ResourceController
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
* 
*****************************************************************************************************************************/
@isTest
private class RE_ResourceCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
    /*
*Method Name: setupTestData
*Description: method to create test records for all test methods.
*Returns: none
*
*/
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        
    }
    
    
    
    /*
*Method Name: testGetResourceSummary
*Description: Method to cover functionality of method - getResourceSummary.
*Returns: none
*
*/
    @isTest static void testGetResourceSummary() {
        List<Resource__c> resourceLst = [SELECT Id FROM Resource__c LIMIT 2];
        String resourceRecId = resourceLst[0].Id;
        User cpUser = [SELECT Id, ContactId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        RE_CreateLightningServerResponse responseNResult;
        List<RE_Taxonomy__c> lstTaxonomy = TestDataFactory.createTaxonomyRecords(2, true);
        TestDataFactory.createResourceTaxonomyRecords(2, true, resourceLst, lstTaxonomy);
        Test.startTest();
        System.runAs(cpUser){
            responseResult = RE_ResourceCtrl.getResourceSummary(resourceRecId);
            responseNResult = RE_ResourceCtrl.getResourceSummary(null);
            
        }
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful,true,'Success');
    }
    
    /*
*Method Name: testGetPickListValues
*Description: Method to cover functionality of method - getPickListValues.
*Returns: none
*
*/
    @isTest static void testGetPickListValues() {
        Test.startTest();
        RE_CreateLightningServerResponse responseResult = RE_ResourceCtrl.getPickListValues('Resource__c','ResourceType__c');
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful,true,'Success');
    }
    
    /*
*Method Name: testGetPickListValuesExcptn
*Description: Method to cover catch block of method - getPickListValues.
*Returns: none
*
*/
    @isTest static void testGetPickListValuesExcptn() {
        Test.startTest();
        RE_CreateLightningServerResponse responseResult = RE_ResourceCtrl.getPickListValues('Resourc__c','ResourceTyp__c');
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful,false,'Error');
    }
    
    /*
*Method Name: testUpdateResourceDetails
*Description: Method to cover functionality of method - updateResourceDetails.
*Returns: none
*
*/
    @isTest static void testUpdateResourceDetails() {
        List<RE_Taxonomy__c> lstTaxonomy = TestDataFactory.createTaxonomyRecords(2, true);
        String sFieldsApiName = RE_DataBaseQueryFields.RE_ResourceCtrlQuery;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        Map<Boolean, String> mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Resource__c', sFieldsApiName,mapQueryParameters);
        Resource__c objResource;
        String sResourceQuery;
        if(mapResponseData.get(true) != null){
            sResourceQuery =  mapResponseData.get(true);
            objResource = Database.query(sResourceQuery);
        }
        
        
        List<Location__c> locationList = [SELECT Id,Name FROM Location__c LIMIT 5];
        List<LocationResource__c> beforeUpdateList = [SELECT Id, Location__c, Location__r.Name FROM LocationResource__c];
        RE_ResourceWrapper objResourceWrapper = new RE_ResourceWrapper(objResource,locationList, beforeUpdateList,true, null, null);
        objResourceWrapper.TaxonomyId = lstTaxonomy[0].Id;
        String jsonString = JSON.Serialize(objResourceWrapper);
        User cpUser = [SELECT Id, ContactId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        Test.startTest();
        System.runAs(cpUser){
            RE_CreateLightningServerResponse responseResult = RE_ResourceCtrl.updateResourceDetails(jsonString,locationList,locationList);
            System.assert(responseResult.isSuccessful == true,'Success');
        }
        Test.stopTest();
        
    }
    
    /*
*Method Name: testUpdateResourceDetails
*Description: Method to cover functionality of method - updateResourceDetails.
*Returns: none
*
*/
    @isTest static void testUpdateResourceDetailsForAddResource() {
        List<RE_Taxonomy__c> lstTaxonomy = TestDataFactory.createTaxonomyRecords(2, true);
        List<Location__c> locationList = [SELECT Id,Name FROM Location__c];
        List<LocationResource__c> beforeUpdateList = [SELECT Id, Location__c, Location__r.Name FROM LocationResource__c];
        String locId = locationList[0].Id;
        User cpUser = [SELECT Id, ContactId, AccountId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        Test.startTest();
        System.runAs(cpUser){
            Resource__c resource = new Resource__c();
            resource.Name = 'TestResource0714';
            RE_ResourceWrapper.Location reWrap = new RE_ResourceWrapper.Location(locId,locationList[0].Name);
            RE_ResourceWrapper objResourceWrapper = new RE_ResourceWrapper(resource,locationList, null,true, null, null);
            objResourceWrapper.TaxonomyId = lstTaxonomy[0].Id;
            objResourceWrapper.AccountId = cpUser.AccountId;
            String jsonString = JSON.Serialize(objResourceWrapper);
            RE_CreateLightningServerResponse responseResult = RE_ResourceCtrl.updateResourceDetails(jsonString,locationList,locationList);
        }
        Test.stopTest();
        List<LocationResource__c> afterUpdateList = [SELECT Id FROM LocationResource__c];
       // System.assert(beforeUpdateList.size() < afterUpdateList.size(),'Success');
       System.assert(afterUpdateList.size() > 0,'Success');
    }
    
    @isTest static void testResourceDetailsWrapper(){
        List<Location__c> locationList = [SELECT Id,Name FROM Location__c];
        User cpUser = [SELECT Id, ContactId, AccountId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        Test.startTest();
        System.runAs(cpUser){
            
            RE_ResourceWrapperSearch resourceWrapSearch = new RE_ResourceWrapperSearch();
            resourceWrapSearch.resoucrePOCPhone = '270-236-2517';
            resourceWrapSearch.resourcePOCEmail = 'communityusr@deloitte.com';
            
            RE_ResourceWrapperSearch.Location loc = new RE_ResourceWrapperSearch.Location();
            loc.locationLatLong = '41.4986961';
            loc.locationIsClosedDay = 'Sunday';
            
            List<String> lstLocClosedDays = new List<String>();
            lstLocClosedDays.add('Monday');
            lstLocClosedDays.add('Tuesday');
            loc.lstClosedDays = lstLocClosedDays;
            
            RE_ResourceDetailWrapper resourceDetailWrap = new RE_ResourceDetailWrapper();
            
            resourceDetailWrap.resourcePOCEmail = 'communityusr@deloitte.com';
            resourceDetailWrap.specialInstructions = 'Test Special Instructions';
            resourceDetailWrap.resoucrePOCPhone = '270-236-2517';
            
            RE_ResourceDetailWrapper.Location loc2 = new RE_ResourceDetailWrapper.Location();
            loc2.locationLatLong = '41.4986961';
            loc2.locationIsClosedDay = 'Sunday';
            loc2.lstClosedDays = lstLocClosedDays;
            
            String jsonString = JSON.Serialize(resourceDetailWrap);
            System.assert((jsonString.length() > 0 )== true,'Success');
       
        }
        Test.stopTest();
        
    }
    
}