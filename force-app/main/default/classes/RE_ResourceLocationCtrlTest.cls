@isTest
public class RE_ResourceLocationCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
    
    
    /********************************************************************************************
* @author      Kojashree Kakariya
* @date         02/07/2019
* @methodname   setupTestData
* @description  This method is used to create test records for all test methods
* @param        none
* @return       none
********************************************************************************************/
    @testSetup static void setupTestData(){        
        TestDataFactory.testDataSetup();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(idAccount);
        Id sContactId = [SELECT Id FROM Contact WHERE Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        User objReUser = TestDataFactory.createSpecificCommunityUser('reusr', null, 'REUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);                
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        
    }
    
    /********************************************************************************************
* @author       Kojashree Kakariya
* @date          02/07/2019
* @methodname   testGetLocationResourceDetails
* @description  This method is used to test the functionality of method - getResourceLocationDetails.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testGetLocationResourceDetails() {        
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<LocationResource__c> locationResList = [SELECT Id FROM LocationResource__c LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(communityUser) {
            if(!locationResList.isEmpty())
                result = RE_ResourceLocationCtrl.getResourceLocationDetails(String.valueOf(locationResList[0].Id));
        }
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
    }
    
    /********************************************************************************************
* @author      Kojashree Kakariya
* @date          02/07/2019
* @methodname   testGetLocationResourceDetailsExcptn
* @description  This method is used to test the functionality of catch block of method - getResourceLocationDetails.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testGetLocationResourceDetailsExcptn() {
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<LocationResource__c> locationResList = [SELECT Id FROM LocationResource__c LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(communityUser) {
            result = RE_ResourceLocationCtrl.getResourceLocationDetails('null');
        }
        Test.stopTest();
        System.assert(result.isSuccessful == false,'Success');
    }
    
    /********************************************************************************************
* @author       Kojashree Kakariya
* @date          02/07/2019
*Method Name:   testGetPickListValues
*Description:   Method to cover functionality of method - getPickListValues.
*Returns:       none
*********************************************************************************************/
    @isTest static void testGetPickListValues() {
        Test.startTest();
        RE_CreateLightningServerResponse responseResult = RE_ResourceLocationCtrl.getPickListValues('LocationResource__c','Status__c');
        RE_CreateLightningServerResponse rest2 = RE_ResourceLocationCtrl.updateResourceLocation('{}', '');
        System.assert(rest2.isSuccessful == false,'Success');
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful,true,'Success');
    }
    
    /********************************************************************************************
* @author       Kojashree Kakariya
* @date          02/07/2019
*Method Name:   updateResourceLocation
*Description:   Method to cover functionality of method - updateResourceLocationDetails.
*Returns:       none
*********************************************************************************************/
    
    @isTest static void updateResourceLocation(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        LocationResource__c locRes = [SELECT Id,Name,AgesServed__c,Location__c,Status__c,Phone__c,TollFree__c,Fax__c,ResourceDescription__c,
                                      Geography_Served__c,EligibilityCCAP__c,EligibilityDescription__c,EligibilityMedicaid__c,EligibilitySNAP__c,EligibilityTANF__c,
                                      FirstPointofContactEmail__c,FirstPointOfContactName__c,FirstPointofContactPhone__c,FirstPointOfContactTitle__c,
                                      SecondPointofContactEmail__c,SecondPointOfContactName__c,SecondPointofContactPhone__c,SecondPointOfContactTitle__c,
                                      TimeZone__c,Fees__c,Notes__c,WhatToBring__c,NextSteps__c,MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,
                                      ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,Resource__c,DaysClosed__c FROM LocationResource__c LIMIT 1 ];
        
        RE_ResourceLocationCtrl.LocationResourceWrapper wrapper = new RE_ResourceLocationCtrl.LocationResourceWrapper(locRes);
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        
        wrapper.bIsMondayClosed = false;
        wrapper.bIsTuesdayClosed = false;
        wrapper.bIsWednesdayClosed = false;
        wrapper.bIsThursdayClosed = false;
        wrapper.bIsFridayClosed = false;
        wrapper.bIsSaturdayClosed = false;
        wrapper.bIsSundayClosed = false;
        wrapper.slocationResDescription = 'Update Test Description'; 
        String locResString = JSON.serialize(wrapper);
        String resID = locRes.Resource__c;
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(communityUser) {
            RE_ResourceLocationCtrl.convertToLocalTime(wrapper.tlocationResThursdayClose);
            result = RE_ResourceLocationCtrl.updateResourceLocation(locResString, locRes.Id);
            RE_CreateLightningServerResponse rest2 = RE_ResourceLocationCtrl.checkResourceLocation(locationList[0].Id, resourceList[0].Id);
             System.assert(rest2.isSuccessful == true,'Success');
        }
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
        
    }
            
/********************************************************************************************
* @author       Kojashree Kakariya
* @date          02/07/2019
*Method Name:   updateResourceLocation
*Description:   Method to cover functionality of method - updateResourceLocationDetails.
*Returns:       none
*********************************************************************************************/
    
    @isTest static void updateResourceLocationElse(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        LocationResource__c locRes = [SELECT Id,Name,AgesServed__c,Location__c,Status__c,Phone__c,TollFree__c,Fax__c,ResourceDescription__c,
                                      Geography_Served__c,EligibilityCCAP__c,EligibilityDescription__c,EligibilityMedicaid__c,EligibilitySNAP__c,EligibilityTANF__c,
                                      FirstPointofContactEmail__c,FirstPointOfContactName__c,FirstPointofContactPhone__c,FirstPointOfContactTitle__c,
                                      SecondPointofContactEmail__c,SecondPointOfContactName__c,SecondPointofContactPhone__c,SecondPointOfContactTitle__c,
                                      TimeZone__c,Fees__c,Notes__c,WhatToBring__c,NextSteps__c,MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,
                                      ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,Resource__c,DaysClosed__c FROM LocationResource__c LIMIT 1 ];
        
        RE_ResourceLocationCtrl.LocationResourceWrapper wrapper = new RE_ResourceLocationCtrl.LocationResourceWrapper(locRes);
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        
        wrapper.bIsMondayClosed = false;
        wrapper.bIsTuesdayClosed = false;
        wrapper.bIsWednesdayClosed = false;
        wrapper.bIsThursdayClosed = false;
        wrapper.bIsFridayClosed = false;
        wrapper.bIsSaturdayClosed = false;
        wrapper.bIsSundayClosed = false;
        wrapper.tlocationResMondayOpen = null;
        wrapper.tlocationResMondayClose = null;
        wrapper.tlocationResTuesdayOpen = null;
        wrapper.tlocationResTuesdayClose = null;
        wrapper.tlocationResWednesdayOpen = null;
        wrapper.tlocationResWednesdayClose = null;
        wrapper.tlocationResThursdayOpen = null;
        wrapper.tlocationResThursdayClose = null;
        wrapper.slocationResDescription = 'Update Test Description'; 
        String locResString = JSON.serialize(wrapper);
        String resID = locRes.Resource__c;
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(communityUser) {
            //RE_ResourceLocationCtrl.convertToLocalTime(wrapper.tlocationResThursdayClose);
            result = RE_ResourceLocationCtrl.updateResourceLocation(locResString, locRes.Id);
            RE_CreateLightningServerResponse rest2 = RE_ResourceLocationCtrl.checkResourceLocation(locationList[0].Id, resourceList[0].Id);
             System.assert(rest2.isSuccessful == true,'Success');
        }
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
        
    }
}