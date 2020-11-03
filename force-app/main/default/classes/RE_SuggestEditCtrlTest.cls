@isTest
public class RE_SuggestEditCtrlTest {
    
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = 38.328732;
        citizenContact.ContactGeoLocation__Longitude__s = 85.764771; 
        citizenContact.MailingPostalCode='35271';
        insert citizenContact;
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation = TestDataFactory.createLocations(3, false, locationRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        for(Location__c loc : lstLocation){
            loc.Geolocation__Latitude__s = 50.328832;
            loc.Geolocation__Longitude__s = 12.764771;
        }
        insert lstLocation;
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = TestDataFactory.createResources(3, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});

        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
    }
    
    @isTest public static  void fetchUserProfileTest(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' AND Name != null LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest123@test.com1','test@guest.com',true);
        User citizenUserfail = [SELECT Id, ContactId,Contact.Email FROM User WHERE Profile.Name='Resource Engine Profile' and isActive=true LIMIT 1];

        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='RE_Resident'];
        //insert new PermissionSetAssignment(AssigneeId = citizenUser.id, PermissionSetId = ps.Id);
        Test.startTest();
        
        System.runAs(citizenUser){
            RE_CreateLightningServerResponse response = RE_SuggestEditCtrl.fetchUserProfile();
            
            System.assertEquals(response.isSuccessful, true,'Success');
        }
        System.runAs(citizenUserfail){
            RE_CreateLightningServerResponse response2 = RE_SuggestEditCtrl.fetchUserProfile();
            
            System.assertEquals(response2.isSuccessful, true,'Success');
        }
        Test.stopTest();
        
    }
    
    @isTest public static  void insertReportConcernTest(){
    
        List<Location__c> lstlocation=[Select id,name from Location__c LIMIT 2];
        List<Resource__c> lstresource = [Select id,name from Resource__c LIMIT 2];
        RE_SuggestEditCtrl.ReportConcern objWrap = new RE_SuggestEditCtrl.ReportConcern();
        
        RE_SuggestEditCtrl.ReportConcern objWrap1 = new RE_SuggestEditCtrl.ReportConcern();
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        objWrap.accountid = idAccount;
       // objWrap.category = 'Address';
       objWrap.category='[{"Id":"Address","Name":"Address"}]';
        
        objWrap.details = 'Test';
       // objWrap.email = 'abc@deloitte.com';
        objWrap.isGuest = true;
        objWrap.locationid = lstlocation[0].id;
      //  objWrap.name = 'Test';
      //  objWrap.phone = '(423) 424-4444';
        objWrap.resourceid = lstresource[0].id;
        
        
        //bisguest
        objWrap1.accountid = idAccount;
       // objWrap.category = 'Address';
       objWrap1.category='[{"Id":"Address","Name":"Address"}]';
        
        objWrap1.details = 'Test';
       // objWrap.email = 'abc@deloitte.com';
        objWrap1.isGuest = false;
        objWrap1.locationid = lstlocation[0].id;
      //  objWrap.name = 'Test';
      //  objWrap.phone = '(423) 424-4444';
        objWrap1.resourceid = lstresource[0].id;
        
        
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Contact cpusercontact =[Select id,phone,primarylocation__c from contact where id=:communityUser.contactid];
       // Location__c loc=[Select id,name from location__c limit 1];
        cpusercontact.Phone='(423) 424-4444';
        update cpusercontact;

        
        
        Test.startTest();
        
        System.runAs(communityUser){
            RE_CreateLightningServerResponse response = RE_SuggestEditCtrl.insertReportConcern(objWrap);
            
            
            RE_CreateLightningServerResponse response2 = RE_SuggestEditCtrl.insertReportConcern(objWrap1);
            
            RE_CreateLightningServerResponse response1 = RE_SuggestEditCtrl.insertReportConcernRec(objWrap);
            RE_CreateLightningServerResponse response3 = RE_SuggestEditCtrl.insertReportConcernRec(objWrap1);
            System.assertEquals(response.isSuccessful, true,'Success');
        }
        Test.stopTest();
        
    }
    
     @isTest public static  void getPickListValuesTest(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Test.startTest();
        System.runAs(citizenUser){
            RE_CreateLightningServerResponse response=RE_SuggestEditCtrl.getPickListValues('ReportConcern__c','Identity__c');
            System.assertEquals(response.isSuccessful,true,'Success');
            RE_CreateLightningServerResponse response1=RE_SuggestEditCtrl.getPickListValues('ReportConcern','Identity__c');
            System.assertEquals(response1.isSuccessful,false,'Success');
        }
        Test.stopTest();
    }
}