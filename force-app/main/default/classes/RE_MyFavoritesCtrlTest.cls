/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_MyFavoritesCtrlTest
*   Created By   :   Deloitte
*   Created Date :   17/07/2019
*   Description :   This class acts as a test class for RE_MyFavoritesCtrlTest and RE_CreateFavCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*    Suyash Singhal             17/07/2019       Initial Version
*****************************************************************************************************************************/
@isTest
public class RE_MyFavoritesCtrlTest {
    
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
        Id citizenProfile;
        Id standardUsrProfile;
        for(Profile pf : [SELECT Id,Name FROM Profile WHERE (Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST OR Name =: RE_GlobalConstants.strCitizenProfileName) AND Name != null]){
            if(pf.Name == RE_GlobalConstants.STANDARD_USER_PROFILE_TEST){
                standardUsrProfile = pf.Id;                
            }else if(pf.Name == RE_GlobalConstants.strCitizenProfileName){
                citizenProfile = pf.Id;                
            }
        }
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(idAccount);
        Id sContactId = [SELECT Id FROM Contact WHERE Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST AND Email != null LIMIT 1].Id;
        User objReUser = TestDataFactory.createSpecificCommunityUser('reusr', null, 'REUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, standardUsrProfile, true);  
        Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 1];
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
    * @author       Suyash Singhal
    * @date         07/25/2019
    * @methodname   fetchFavoritesTest
    * @description  This method is used to test the functionality of getting favorites.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void fetchFavoritesTest(){
        List<LocationResource__c> lstLocResources = [SELECT id FROM LocationResource__c where location__c!=null];
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        Test.startTest();
        System.runAs(cpUser){
            List<Favorite__c> lstFavs = TestDataFactory.createFavoritesRecords(2,true,lstLocResources);
            RE_CreateLightningServerResponse response= RE_MyFavoritesCtrl.fetchFavResources();
            System.assertEquals(response.isSuccessful, true,'Success'); 
        }
        Test.StopTest();
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         07/25/2019
    * @methodname   fetchFavoritesNegativeTest
    * @description  This method is used to test the functionality of getting favorites.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void fetchFavoritesNegativeTest(){
        List<LocationResource__c> lstLocResources = [SELECT id,Location__c FROM LocationResource__c];
        List<Location__c> updateLocation=new List<Location__c>();
        for(Location__c loc:[SELECT Id,Address2__c from Location__c WHERE Id=:lstLocResources[0].Location__c AND Id != null]){
            loc.Address2__c='';
            updateLocation.add(loc);
        }
        update updateLocation;
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        Test.startTest();
        System.runAs(cpUser){
            List<Favorite__c> lstFavs = TestDataFactory.createFavoritesRecords(2,true,lstLocResources);
            RE_CreateLightningServerResponse response= RE_MyFavoritesCtrl.fetchFavResources();
            System.assertEquals(response.isSuccessful, true,'Success'); 
        }
        Test.StopTest();
    }
    
     /********************************************************************************************
    * @author       Suyash Singhal
    * @date         07/25/2019
    * @methodname   createFavoritesTest
    * @description  This method is used to test the functionality of creating favorites.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void createFavoritesTest(){
        List<RE_Taxonomy__c> lstTaxonomies = TestDataFactory.createTaxonomyRecords(4,true);
        List<LocationResource__c> lstLocResources = [SELECT id FROM LocationResource__c];
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        Test.startTest();
            System.runAs(cpUser){
                RE_CreateLightningServerResponse response= RE_CreateFavCtrl.createFavorite(lstLocResources[0].Id);
                System.assertEquals(response.isSuccessful, true,'Success'); 
                String locId = String.valueOf(lstLocResources[0].Id);
                locId = locId.replace(locId.right(3),'abc'); // to pass invalid Id to cover catch
                RE_CreateLightningServerResponse response1= RE_CreateFavCtrl.createFavorite(locId);
            }
        Test.StopTest();
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         07/25/2019
    * @methodname   deleteFavoritesTest
    * @description  This method is used to test the functionality of Deleting favorites.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void deleteFavoritesTest(){
        List<RE_Taxonomy__c> lstTaxonomies = TestDataFactory.createTaxonomyRecords(4,true);
        List<LocationResource__c> lstLocResources = [SELECT id FROM LocationResource__c];
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        Test.startTest();
            System.runAs(cpUser){
                List<Favorite__c> lstFavs = TestDataFactory.createFavoritesRecords(2,true,lstLocResources);
                RE_CreateLightningServerResponse response= RE_CreateFavCtrl.deleteFavorite(lstLocResources[0].Id);
                System.assertEquals(response.isSuccessful, true,'Success'); 
            }
        Test.StopTest();
    }
    
}