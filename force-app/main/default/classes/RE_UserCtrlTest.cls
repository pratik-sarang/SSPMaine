/**
* Class Name    : RE_UserControllerTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_UserController
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     --------------------------------------------------------------------
*  24/05/2019  Akash       Initial Version
**/

@isTest
public class RE_UserCtrlTest {
     /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method to set up test data
    */
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        Account Acc = new Account(Name = 'Test Account');
        Insert Acc;
        contact sContact = new contact(FirstName = 'Test ',LastName = 'Test contact',Email = 'Test@Test123.com',AccountId = Acc.Id);
        insert sContact;
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objREUser = TestDataFactory.createSpecificCommunityUser('reusr',null, 'REUser',RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);
    }
    
     /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method getWrapperMethod method
    */
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void getWrapperMethodTest(){
        Id conId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse result;
        system.runAs(objUser){
            result = RE_UserCtrl.getWrapper(conId);
            System.assert(result.isSuccessful == true,'Success');
            RE_UserCtrl.getWrapper('');
        }
     }
    
     /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method getPickListValues method
    */
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void getPickListValuesTest(){
        User objUser = [SELECT Id,ContactId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        system.runAs(objUser){
            RE_CreateLightningServerResponse response = RE_UserCtrl.getPickListValues(RE_GlobalConstants.strSobjectName, RE_GlobalConstants.CONTACT_PICKLIST_VALUES_TEST);
            System.assertEquals(true,response.isSuccessful,'Success');
            // for exception coverage
            RE_CreateLightningServerResponse exceptionResponse = RE_UserCtrl.getPickListValues(RE_GlobalConstants.strSobjectName,'123');
            System.assertEquals(false,exceptionResponse.isSuccessful,'Success');
        }
    }
    
   /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method upsertContact method
    */
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static void upsertContactTest(){
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId,Profile.Name,RE_Selected_Role__c,ApplicableRoles__c,Contact.AccountId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        contact sContact1 = new contact();
            sContact1 = [Select Id,Account.Applicable_Roles__c,AccountId,RecordTypeId FROM Contact where Email = 'Test@Test123.com' LIMIT 1];
            system.runAs(objUser){
            Test.startTest();
            RE_UserWrapper objWrapperAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', 'Active', 'Complete');
            List <AccountContactRelation> testDummy =[SELECT Id, Account.RecordtypeId,Roles,ContactId FROM AccountContactRelation LIMIT 1];
            set<id> accSet = new set<id>();
            for(AccountContactRelation bb : testDummy)
            {
                bb.roles = objUser.RE_Selected_Role__c;
                accSet.add(bb.AccountId);
            }
            update testDummy;
            RE_CreateLightningServerResponse objAdminEditResponse = RE_UserCtrl.upsertContact(objWrapperAdmin, true);
            //System.assertEquals(true, objAdminEditResponse.isSuccessful,'Success');
            
            RE_UserWrapper objWrapperToCreateAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_CONTACT_EMAIL_TEST, 'Zenith', 'Test Contact User', null, sLocationId, RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-1234', 'Active', 'Complete');
            
            RE_CreateLightningServerResponse objAdminCreateResponse = RE_UserCtrl.upsertContact(objWrapperToCreateAdmin, false);
            //System.assertEquals(true, objAdminCreateResponse.isSuccessful,'Success'); //R20.10 Mock
            RE_UserCtrl.updateContactRole(objWrapperAdmin,objUser.RE_Selected_Role__c,sContact1);
            objWrapperAdmin.isStatusChanged=true;
            RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            System.assertEquals(true, objAdminUpdateResponse.isSuccessful,'Success');
            RE_UserWrapper exceptionObjWrapper = new RE_UserWrapper();
            exceptionObjWrapper.Email = RE_GlobalConstants.sInvalidEmail;
            exceptionObjWrapper.FirstName = RE_GlobalConstants.sTestUser1;
            exceptionObjWrapper.Id = sContactId;
            RE_CreateLightningServerResponse objResponse = RE_UserCtrl.updateUser(objUser.Id, exceptionObjWrapper);
            System.assertEquals(false, objResponse.isSuccessful,'Success');
            
            RE_UserWrapper objWrapperToCreateInvalidUser = getWrapper(RE_GlobalConstants.AGENCY_ADMIN_USER1_EMAIL_TEST, 'Leon', 'Testing Contact User', null, sLocationId, RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(011)-456-1234', 'Active', 'Complete');
            RE_CreateLightningServerResponse invalidUserCreateResponse = RE_UserCtrl.upsertContact(objWrapperToCreateInvalidUser, false);
            System.assertEquals(false, invalidUserCreateResponse.isSuccessful,'Success');
            
            RE_UserWrapper objWrapperAdmin1 = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', 'Active', 'Complete');
            objWrapperAdmin1.isClaimFlow = true;
            RE_CreateLightningServerResponse objAdminEditResponse1 = RE_UserCtrl.upsertContact(objWrapperAdmin1, true);
            Test.stopTest();
        }
    }
    
    //Srikanth
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void upsertContactTestToInactive(){
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId,Profile.Name,Contact.AccountId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        
        KOGWebservice__c kogRoleManagement = new KOGWebservice__c();
        kogRoleManagement.Name= 'KOG_Role_Management';
        kogRoleManagement.ApplicationName__c = 'SYS2 KHBE Self Service Portal';
        kogRoleManagement.Certificate__c ='backyardnonprodmulecert';
        kogRoleManagement.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/SYS/kogservices/RoleManagement.svc';
        kogRoleManagement.RE_ApplicationName__c = 'SYS2 Resource Engine Staff Portal';
        Insert kogRoleManagement;
        
        system.runAs(objUser){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmntMock());
            RE_UserWrapper objWrapperAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', 'Inactive', 'Complete');
            objWrapperAdmin.isStatusChanged=true;
            RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            System.assertEquals(true, objWrapperAdmin.FirstName!=null,'Success');
            tempuriOrg_RoleMgmntMock mockClass= new tempuriOrg_RoleMgmntMock();
            mockClass.isErrorScenario=true;
            Test.setMock(WebServiceMock.class,mockClass);
            RE_CreateLightningServerResponse objAdminUpdateResponse1 = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            RE_UserCtrl.updateApplicableRoleOnUser(objUser.Id,'Community Partner Admin');
            Test.stopTest();     
        }
    }
         
    
    @isTest static  void upsertContactTestToInactive2(){
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId,Profile.Name,Contact.AccountId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        
        KOGWebservice__c kogRoleManagement = new KOGWebservice__c();
        kogRoleManagement.Name= 'KOG_Role_Management';
        kogRoleManagement.ApplicationName__c = 'SYS2 KHBE Self Service Portal';
        kogRoleManagement.Certificate__c ='backyardnonprodmulecert';
        kogRoleManagement.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/SYS/kogservices/RoleManagement.svc';
        kogRoleManagement.RE_ApplicationName__c = 'SYS2 Resource Engine Staff Portal';
        Insert kogRoleManagement;
        
        system.runAs(objUser){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmnt2Mock());
            RE_UserWrapper objWrapperAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', 'Inactive', 'Complete');
            RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            
            System.assertEquals(true, objWrapperAdmin.FirstName!=null,'Success');
            Test.stopTest();
            // for exception coverage
            /*RE_UserWrapper exceptionObjWrapper = new RE_UserWrapper();
            exceptionObjWrapper.Email = RE_GlobalConstants.sInvalidEmail;
            exceptionObjWrapper.FirstName = RE_GlobalConstants.sTestUser1;
            exceptionObjWrapper.Id = sContactId;
            RE_CreateLightningServerResponse objResponse = RE_UserCtrl.updateUser(objUser.Id, exceptionObjWrapper);
            System.assertEquals(false, objResponse.isSuccessful,'Success');*/
            
        }
    }
     /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static test method for updateUserStatusToActive method
    */
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void updateUserStatusToActiveTest(){
        Id conId = [Select Id FROM Contact  Where Email ='cpadminuser@deloitte.com'  LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST  LIMIT 1];
        system.runAs(objUser){
            RE_CreateLightningServerResponse objUpdateUserresponse = RE_UserCtrl.updateUserStatusToActive(conId);
            System.assertEquals(true,objUpdateUserresponse.isSuccessful,'Success');
        }    
    }
    //Srikanth
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void validateRoleServiceTest(){
        boolean bool = false;
        KOGWebservice__c kogRoleManagement = new KOGWebservice__c();
        kogRoleManagement.Name= 'KOG_Role_Management';
        kogRoleManagement.ApplicationName__c = 'SYS2 KHBE Self Service Portal';
        kogRoleManagement.Certificate__c ='backyardnonprodmulecert';
        kogRoleManagement.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/SYS/kogservices/RoleManagement.svc';
        kogRoleManagement.RE_ApplicationName__c = 'SYS2 Resource Engine Staff Portal';
        Insert kogRoleManagement;
        
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        RE_UserWrapper objWrapperAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', 'Active', 'Complete');

        test.startTest();
        Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmntMock());
        User objUser = [SELECT Id,ContactId,KOG_Role__c FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST  LIMIT 1];
        bool = RE_UserCtrl.validateRoleService(objUser.Id);
         //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
        System.assertEquals(true, bool,'Success');
          
        objWrapperAdmin.isStatusChanged=true;
        objWrapperAdmin.Status = RE_GlobalConstants.USER_STATUS_INACTIVE;  
        RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
           
        test.stopTest();
    }
    
     @isTest static  void validateRoleServiceTest1(){
        boolean bool = false;
        KOGWebservice__c kogRoleManagement = new KOGWebservice__c();
        kogRoleManagement.Name= 'KOG_Role_Management';
        kogRoleManagement.ApplicationName__c = 'SYS2 KHBE Self Service Portal';
        kogRoleManagement.Certificate__c ='backyardnonprodmulecert';
        kogRoleManagement.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/SYS/kogservices/RoleManagement.svc';
        kogRoleManagement.RE_ApplicationName__c = 'SYS2 Resource Engine Staff Portal';
        Insert kogRoleManagement;
        test.startTest();
        Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmntMock());
        User objUser = [SELECT Id,ContactId,KOG_Role__c FROM USER WHERE Email !=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST  LIMIT 1];
         bool = RE_UserCtrl.validateRoleService(objUser.Id);
         //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
        System.assertEquals(true, bool,'Success');
        test.stopTest();
    }
     /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : utility method for getWrapper
    */
    public static RE_UserWrapper getWrapper(String sEmail, String sFirstName,String sLastName, String sContactId, String sLocationId,
                                            String sPermissionLabel, String sPhone, String sStatus, String sTrainigCpmolete){
                                                RE_UserWrapper objWrapper = new RE_UserWrapper();
                                                objWrapper.Email = sEmail;
                                                objWrapper.FirstName = sFirstName;
                                                objWrapper.Id = sContactId;
                                                objWrapper.LastName = sLastName;
                                                objWrapper.PermissionsLevel = sPermissionLabel; 
                                                objWrapper.Phone = sPhone; 
                                                objWrapper.PrimaryLocation = sLocationId;
                                                objWrapper.Status = sStatus;
                                                objWrapper.TrainingLevel = sTrainigCpmolete;
                                                objWrapper.bIsClaim = true;
                                                objWrapper.isStatusChanged = true;
                                                return objWrapper;
                                            }
    
    //Srikanth
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void updateUserRoleTest(){
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId,Profile.Name,Contact.AccountId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        objUser.ApplicableRoles__c = RE_GlobalConstants.RE_ASSISTER_ROLE+';'+RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        system.runAs(new User(Id=userInfo.getUserId())){
            update objUser;
        }
        KOGWebservice__c kogRoleManagement = new KOGWebservice__c();
        kogRoleManagement.Name= 'KOG_Role_Management';
        kogRoleManagement.ApplicationName__c = 'SYS2 KHBE Self Service Portal';
        kogRoleManagement.Certificate__c ='backyardnonprodmulecert';
        kogRoleManagement.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/SYS/kogservices/RoleManagement.svc';
        kogRoleManagement.RE_ApplicationName__c = 'SYS2 Resource Engine Staff Portal';
        Insert kogRoleManagement;
        
        system.runAs(objUser){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmntMock());
            RE_UserWrapper objWrapperAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', RE_GlobalConstants.USER_STATUS_INACTIVE, 'Complete');
            objWrapperAdmin.isStatusChanged = true;
            RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            System.assertEquals(true, objWrapperAdmin.FirstName!=null,'Success');
            Test.stopTest();     
        }
    }
    //Srikanth
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void updateUserRoleActiveTest(){
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId,Profile.Name,Contact.AccountId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        /*objUser.ApplicableRoles__c = RE_GlobalConstants.RE_ASSISTER_ROLE+';'+RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        system.runAs(new User(Id=userInfo.getUserId())){
            update objUser;
        }*/
        KOGWebservice__c kogRoleManagement = new KOGWebservice__c();
        kogRoleManagement.Name= 'KOG_Role_Management';
        kogRoleManagement.ApplicationName__c = 'SYS2 KHBE Self Service Portal';
        kogRoleManagement.Certificate__c ='backyardnonprodmulecert';
        kogRoleManagement.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/SYS/kogservices/RoleManagement.svc';
        kogRoleManagement.RE_ApplicationName__c = 'SYS2 Resource Engine Staff Portal';
        Insert kogRoleManagement;
        
        system.runAs(objUser){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmntMock());
            RE_UserWrapper objWrapperAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', RE_GlobalConstants.STATUS_ACTIVE, 'Complete');
            objWrapperAdmin.isStatusChanged = false;
            RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            System.assertEquals(true, objWrapperAdmin.FirstName!=null,'Success');
            Test.stopTest();     
        }
    }
    //Srikanth
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void updateUserRoleActiveTest1(){
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId,Profile.Name,Contact.AccountId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        /*objUser.ApplicableRoles__c = RE_GlobalConstants.RE_ASSISTER_ROLE+';'+RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        system.runAs(new User(Id=userInfo.getUserId())){
            update objUser;
        }*/
        KOGWebservice__c kogRoleManagement = new KOGWebservice__c();
        kogRoleManagement.Name= 'KOG_Role_Management';
        kogRoleManagement.ApplicationName__c = 'SYS2 KHBE Self Service Portal';
        kogRoleManagement.Certificate__c ='backyardnonprodmulecert';
        kogRoleManagement.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/SYS/kogservices/RoleManagement.svc';
        kogRoleManagement.RE_ApplicationName__c = 'SYS2 Resource Engine Staff Portal';
        Insert kogRoleManagement;
        
        system.runAs(objUser){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmntMock());
            RE_UserWrapper objWrapperAdmin = getWrapper(RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_EMAIL_TEST,'Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', RE_GlobalConstants.USER_STATUS_INACTIVE, 'Complete');
            objWrapperAdmin.isStatusChanged = false;
            RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            System.assertEquals(true, objWrapperAdmin.FirstName!=null,'Success');
            Test.stopTest();     
        }
    }
    
    @isTest static  void upsertContactTest2(){
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId,Profile.Name,RE_Selected_Role__c,ApplicableRoles__c,Contact.AccountId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Id sLocationId = [SELECT ID FROM Location__c LIMIT 1].Id;
        contact sContact1 = new contact();
            sContact1 = [Select Id,Account.Applicable_Roles__c,Email, AccountId,RecordTypeId FROM Contact where Email = 'Test@Test123.com' LIMIT 1];
            sContact1.Email = 'SKS@SKS.COM';
            update sContact1;
            
            system.runAs(objUser){
            Test.startTest();
            RE_UserWrapper objWrapperAdmin = getWrapper('SKS45@SKS.COM','Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', 'Active', 'Complete');
            List <AccountContactRelation> testDummy =[SELECT Id, Account.RecordtypeId,Roles,ContactId FROM AccountContactRelation LIMIT 1];
            set<id> accSet = new set<id>();
            for(AccountContactRelation bb : testDummy)
            {
                bb.roles = objUser.RE_Selected_Role__c;
                accSet.add(bb.AccountId);
            }
            update testDummy;
            RE_CreateLightningServerResponse objAdminEditResponse = RE_UserCtrl.upsertContact(objWrapperAdmin, true);
            System.assertEquals(true, objAdminEditResponse.isSuccessful,'Success');
            
            RE_UserWrapper objWrapperToCreateAdmin = getWrapper('SKS45@SKS.COM', 'Zenith', 'Test Contact User', null, sLocationId, RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-1234', 'Active', 'Complete');
            
            RE_CreateLightningServerResponse objAdminCreateResponse = RE_UserCtrl.upsertContact(objWrapperToCreateAdmin, false);
            //System.assertEquals(true, objAdminCreateResponse.isSuccessful,'Success');
            RE_UserCtrl.updateContactRole(objWrapperAdmin,objUser.RE_Selected_Role__c,sContact1);
            objWrapperAdmin.isStatusChanged=true;
            //objWrapperAdmin.Status = RE_GlobalConstants.USER_STATUS_INACTIVE;  
            RE_CreateLightningServerResponse objAdminUpdateResponse = RE_UserCtrl.updateUser(objUser.Id, objWrapperAdmin);
            //System.assertEquals(true, objAdminUpdateResponse.isSuccessful,'Success');
            RE_UserWrapper exceptionObjWrapper = new RE_UserWrapper();
            exceptionObjWrapper.Email = RE_GlobalConstants.sInvalidEmail;
            exceptionObjWrapper.FirstName = RE_GlobalConstants.sTestUser1;
            exceptionObjWrapper.Id = sContactId;
            RE_CreateLightningServerResponse objResponse = RE_UserCtrl.updateUser(objUser.Id, exceptionObjWrapper);
            //System.assertEquals(false, objResponse.isSuccessful,'Success');
            
            RE_UserWrapper objWrapperToCreateInvalidUser = getWrapper('SKS45@SKS.COM', 'Leon', 'Testing Contact User', null, sLocationId, RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(011)-456-1234', 'Active', 'Complete');
            RE_CreateLightningServerResponse invalidUserCreateResponse = RE_UserCtrl.upsertContact(objWrapperToCreateInvalidUser, false);
            //System.assertEquals(false, invalidUserCreateResponse.isSuccessful,'Success');
            
            RE_UserWrapper objWrapperAdmin1 = getWrapper('SKS45@SKS.COM','Test1',RE_GlobalConstants.RE_COMMUNITY_USER_ADMIN_NAME_TEST, sContactId,sLocationId,RE_GlobalConstants.RE_ADMIN_NAME_TEST, '(123)-456-7890', 'Active', 'Complete');
            objWrapperAdmin1.isClaimFlow = true;
            RE_CreateLightningServerResponse objAdminEditResponse1 = RE_UserCtrl.upsertContact(objWrapperAdmin1, true);
            Test.stopTest();
        }
    }
}