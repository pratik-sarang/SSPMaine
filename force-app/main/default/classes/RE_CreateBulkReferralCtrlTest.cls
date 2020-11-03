/**
* Class Name    : RE_CreateBulkReferralCtrlTest
* Owner         : DELOITTE
* Created Date  : 09/23/2019
* Description   : Test class for Create Bulk Referrals
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  09/23/2019  Payal           Initial Version
**/
@isTest
public class RE_CreateBulkReferralCtrlTest {
     static Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
     static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
      /********************************************************************************************
    * @author       Payal Dubela
    * @date         09/23/2019
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
        Id citizenProfile;
        Id standardUsrProfile;
        for(Profile pf : [SELECT Id,Name FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName ]){
              citizenProfile = pf.Id;                
        }
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(idAccount);
        Id sContactId = [SELECT Id FROM Contact WHERE Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(lstCitizenAccounts[0].Id);
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='35321';
        if(RE_DataAccessChecker.isAllowedToCreate(Contact.getSObjectType())){
            insert citizenContact;
        }
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile, true);                   
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> resourceLst = TestDataFactory.createResources(2, true, resourceRecordTypeId, lstAccountIds);
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationLst = TestDataFactory.createLocations(2, true, locationRecordTypeId, lstAccountIds);
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(2, true, null, locationLst, resourceLst);
       
    }
    
    
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         09/23/2019
    * @methodname   getTableDataTest
    * @description  This method is used to test the functionality of createReferralsTest
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void getTableDataTest(){
        List<LocationResource__c> lstLocResources = [SELECT id,location__c,Resource__c FROM LocationResource__c where location__c!=null];
        User cpUser = [SELECT Id,ContactId FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Contact cpContact=new Contact();
        cpContact.Id=cpUser.ContactId;
        cpContact.Phone='(323) 332-7653';
        update cpContact;
        Contact citizenContact=[Select Id,Name,Phone,Email From Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Test.startTest();
        System.runAs(cpUser){
            EmailSetting__c eml = new EmailSetting__c(Name='Referral created mail', Is_on__c = true);
            insert eml;
            Email_Text_Communication_Settings__c melTxt = new Email_Text_Communication_Settings__c(Email_Communication__c = true, Name='ii');
            insert melTxt;
            RE_CreateBulkReferralCtrl.RE_RefWrapper objWrapper = new RE_CreateBulkReferralCtrl.RE_RefWrapper();
            objWrapper.Name='test';
            objWrapper.Contact=citizenContact.id;
            objWrapper.Email='abc@xyz.com';
            objWrapper.Location=lstLocResources[0].location__c;
            objWrapper.Resource=lstLocResources[0].Resource__c;
            objWrapper.Phone='(671) 289-1256';
            objWrapper.Organization='test organization';
            objWrapper.Notes='test note';
            objWrapper.sStatus='Active';
            List<Favorite__c> lstFavs = TestDataFactory.createFavoritesRecords(2,true,lstLocResources);
            RE_CreateLightningServerResponse response= RE_MyFavoritesCtrl.fetchFavResources();
            List<RE_MyFavoritesCtrl.FavoritesWrapper> lstWrapper=(List<RE_MyFavoritesCtrl.FavoritesWrapper>)response.objectData.get('favorites');
            lstWrapper[0].bisSelected=true;
            lstWrapper[1].bisSelected=true;
            response=RE_CreateBulkReferralCtrl.getTableData(JSON.serialize(lstWrapper));
            System.assertEquals(response.isSuccessful,true,'Positive scenario');
            String screenWrapperData='{"sClientId":"'+citizenContact.Id+'","sNotes":"test","sPhone":"(322) 453-7664","sEmail":"testabc@deloitte.com"}';
            RE_CreateLightningServerResponse response1= RE_CreateBulkReferralCtrl.createReferrals(JSON.serialize(lstWrapper),screenWrapperData);
            System.assertEquals(response1.objectData.get('NumberRefsCreated'),2,'First Case');
            RE_CreateLightningServerResponse response2= RE_CreateBulkReferralCtrl.createReferrals(JSON.serialize(lstWrapper),screenWrapperData);
            System.assertEquals(response2.objectData.get('NumberRefsCreated'),0,'Second Case');
            
        }
        Test.StopTest();
        
    }
    

}