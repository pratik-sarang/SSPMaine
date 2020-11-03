/**
* Class Name    : RE_NotesCtrlTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_NotesCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  24/05/2019  Payal       Initial Version
**/
@isTest
public class RE_NotesCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static String guestUserEmail='test@guest.com';
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='43223';
        insert citizenContact;
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation = TestDataFactory.createLocations(2, true, locationRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = TestDataFactory.createResources(2, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        List<Referral__c> lstRreferral=TestDataFactory.createReferral(1,true,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,citizenContact.Id,lstCitizenAccounts,lstResource);
        Profile citizenProfile ;
        Profile guestUserProfile;
        for(Profile p:[SELECT Id,Name FROM Profile 
                       WHERE ((Name =: RE_GlobalConstants.strCitizenProfileName
                       OR Name=:RE_GlobalConstants.strGuestProfileName) AND Name != null)]){
            if(p.Name==RE_GlobalConstants.strCitizenProfileName){
                 citizenProfile=p;
            }else if(p.Name==RE_GlobalConstants.strGuestProfileName){
                 guestUserProfile=p; 
            }            
        
         }
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
        List<ContentVersion> contentVersionList = TestDataFactory.createContentVersion(1,true);
        ContentDocument docList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        List<ContentDocumentLink> contentlinkList = TestDataFactory.createContentDocLink(1,true,lstLocation[0].id,docList.Id);
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1',guestUserEmail,true);
    }
    
    @isTest public static void createNoteTest(){
      Test.startTest();
       for(Referral__c ref:[Select Id,Name 
                            FROM Referral__c]){
                                
          RE_CreateLightningServerResponse response=RE_NotesCtrl.createNote('Test_Title','Test'+ref.Name,ref.Id, false);
          System.assertEquals(response.isSuccessful,true);
       }
        RE_CreateLightningServerResponse response1=RE_NotesCtrl.createNote('Test_Title','TestDesc',null, false);
        //System.assertEquals(response1.isSuccessful,false);
     Test.stopTest();
        
    }
    
    @isTest public static void getNotesTest(){
      User communityUser;
      User guestUser;
          for(User u: [SELECT Id,ContactId,Email FROM User WHERE ((Email=:RE_GlobalConstants.strCitizenEmail 
                       OR Email=:guestUserEmail) AND Email != null)]){
              if(u.Email==RE_GlobalConstants.strCitizenEmail){
                  communityUser=u;
              }else{
                  guestUser=u;
              }
          }
      Test.startTest();
        Referral__c ref=[Select Id,OwnerId,ReferredAccountID__c from Referral__c LIMIT 1];
        for(Integer i=0;i<10;i++){
            RE_NotesCtrl.createNote('Test_Title'+i,'Test'+i,ref.Id, false);        
        }
       // RE_CreateLightningServerResponse response1=RE_NotesCtrl.getNotes(ref.Id,'2','3');
      //  System.assertEquals(response1.objectData.get('records')!=null,true);
      //  System.assertEquals(response1.isSuccessful,true); 
      
       System.runAs(communityUser){
        RE_CreateLightningServerResponse response2=RE_NotesCtrl.getNotes(ref.Id,'2','3');
        System.assertEquals(response2.objectData.get('records')!=null,true);
        System.assertEquals(response2.isSuccessful,true); 
       }
      /*  System.runAs(guestUser){
            RE_CreateLightningServerResponse response3=RE_NotesCtrl.getNotes(ref.Id,'2','3');
        } */
        
       Test.stopTest();
    }
    
    @isTest public static  void getReferralNotesTest(){
        User communityUser= [SELECT Id,ContactId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null LIMIT 1];
        List<Id> lstRefIds = new List<Id>();
        Test.startTest();
        for(Referral__c ref:[Select Id,Name FROM Referral__c LIMIT 1]){
            RE_CreateLightningServerResponse response=RE_NotesCtrl.createNote('Test_Title','Test'+ref.Name,ref.Id, false);
            lstRefIds.add(ref.Id);
        }
        
        ContentDocumentLink conDocLink = [SELECT ID,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :lstRefIds AND LinkedEntityId!= null LIMIT 1];
        System.runAs(communityUser){
            RE_CreateLightningServerResponse result = RE_NotesCtrl.getReferralNotes(conDocLink.LinkedEntityId); 
            System.assertEquals(result.isSuccessful,true); 
        }
        Test.stopTest();
    }
    @isTest public static  void updateNoteTest(){
      User communityUser= [SELECT Id,ContactId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null LIMIT 1];
      Test.startTest();
        Referral__c ref=[Select Id,OwnerId,ReferredAccountID__c from Referral__c LIMIT 1];
        for(Integer i=0;i<10;i++){
            RE_NotesCtrl.createNote('Test_Title'+i,'Test'+i,ref.Id, false);        
       }
       System.runAs(communityUser){
        RE_CreateLightningServerResponse response2=RE_NotesCtrl.getNotes(ref.Id,'2','3'); 
        List<RE_NotesCtrl.NotesWrapper> lstNotesWrapper = (List<RE_NotesCtrl.NotesWrapper>)JSON.deserialize(''+response2.objectData.get('records'), List<RE_NotesCtrl.NotesWrapper>.class);
        RE_CreateLightningServerResponse response4=RE_NotesCtrl.checkNoteEditPermission((lstNotesWrapper)[0].NoteId);
        System.assert(response4.isSuccessful == true,'Success');
        RE_CreateLightningServerResponse response5=RE_NotesCtrl.updateNote((lstNotesWrapper)[0].NoteId,'testt','test');
        System.assert(response5.isSuccessful == true,'Success');
        RE_CreateLightningServerResponse response6=RE_NotesCtrl.checkNoteEditPermission(null);
       }
        
       Test.stopTest();
        
    }

}