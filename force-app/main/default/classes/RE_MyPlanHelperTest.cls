/**
* Class Name    : RE_MyPlanHelperTest
* Owner         : DELOITTE
* Created Date  : 06/19/2019
* Description   : Poplating lat and long of loaction record using zipcode through google map api test class
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/19/2019  Arun       Initial Version
*  
**/
@isTest
public class RE_MyPlanHelperTest {
    @testSetup static void setup(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Id> lstReferralAccount=new List<Id>();
        List<Account> listAccount=TestDataFactory.createAccounts(1,true,accountRecordTypeId);
        lstReferralAccount.add(listAccount[0].Id);
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        String name=[select Description,DeveloperName,Id,IsActive,Name,SobjectType from RecordType where Id =:contactRecordTypeId AND Id != null].DeveloperName;
        List<Contact> listContact=TestDataFactory.createContacts(1, true, contactRecordTypeId, lstReferralAccount,false);
        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', 'ReferralRecord');
        //Id referralRecordTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strReferralRecordTypeDeveloperName).getRecordTypeId();
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> resourceList = TestDataFactory.createResources(2, true, resourceRecordTypeId, lstReferralAccount);
        //List<Referral__c> referralList=TestDataFactory.createReferral(1, true, referralRecordTypeId, listContact[0].Id, listAccount, resourceList);
        // Create Loaction__c data
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.LOCATION).getRecordTypeId();
        List<Location__c> locationlList=TestDataFactory.createLocations(1, true, locationRecordTypeId, lstReferralAccount);
    }
    @isTest static void testConatctlatAndLong(){
        Location location1 = Location.newInstance(28.635308,77.22496);
        Location location2 = Location.newInstance(37.7749295,-122.4194155);
        List<Referral__c> referralList=[select Id from Referral__c];
        List<Location__c> listLocations=[select Id from Location__c];
        Set<Id> setReferralIds =new Set<Id>();
        Set<Id> lstLocations=new Set<Id>();
        //setReferralIds.add(referralList[0].Id);
        lstLocations.add(listLocations[0].Id);
        Test.startTest();
            RE_MyPlanHelper.execute(null);
            Double distance = RE_MyPlanHelper.getDistance(location1,location2,null);
            System.assert(distance!=0,'Success');
            //RE_MyPlanHelper.getReferralNotes(setReferralIds);
            RE_MyPlanHelper.getLocationOperatingHours(lstLocations);
        Test.stopTest();
    }
}