/**
* Class Name    : RE_DataTableCtrlTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_DataTableCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  24/05/2019  Payal       Initial Version
**/
@isTest
public class RE_DataTableCtrlTest {
     static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         05/30/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id,HasOptedOutOfAccount__c FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        lstCitizenAccounts[0].HasOptedOutOfAccount__c=false;
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = 38.328732;
        citizenContact.ContactGeoLocation__Longitude__s = 85.764771; 
        citizenContact.MailingPostalCode='43521';
        citizenContact.Birthdate=(System.now()-112086).date();
        insert citizenContact;
        REIntegrationCodes__c intCode=new REIntegrationCodes__c(Name='SuccessCode',Code__c='SDH0000');
        insert intCode;
    }
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         05/30/2019
    * @methodname   getLocationsTest
    * @description  This method is used to test the functionality of method - getLocations.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void getLocationsTest(){
        User u= [SELECT Id,contactid FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        Contact cpusercontact =[Select id,phone,primarylocation__c from contact where id=:u.contactid];
        Location__c loc=[Select id,name from location__c limit 1];
        cpusercontact.Phone='(423) 424-4444';
        cpusercontact.primarylocation__c=loc.id;
        update cpusercontact;
        RE_CreateLightningServerResponse locationStringAdmin=RE_DataTableCtrl.getLocations();
        Test.startTest();
        System.runAs(u){
            RE_CreateLightningServerResponse locationString=RE_DataTableCtrl.getLocations();
           System.assert(locationString.isSuccessful==true,'Success');
        }
        Test.stopTest();
    }
    
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         05/30/2019
    * @methodname   getDataTestForContact
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void getDataTestForContact(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'TrainingLevel__c'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = false;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        System.runAs(u){
            /*RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData('Contact',new List<String>{'TrainingLevel__c'},'2','3','All');
            RE_CreateLightningServerResponse response1=RE_DataTableCtrl.getData('Contact',new List<String>{'TrainingLevel__c'},'2','3',locationList[0].Id);
            System.assertEquals(response1.isSuccessful,true);
            
            RE_CreateLightningServerResponse response2=RE_DataTableCtrl.getData('Resource__c',new List<String>{'Fees__c','Name'},'2','3','All');
            System.assertEquals(response2.isSuccessful,true);
            
            RE_CreateLightningServerResponse response4=RE_DataTableCtrl.getData('Referral__c',new List<String>{'ClientRating__c'},'2','3','All');
            System.assertEquals(response4.isSuccessful,true);
            RE_CreateLightningServerResponse response5=RE_DataTableCtrl.getData('Referral__c',new List<String>{'ClientRating__c'},'2','3',locationList[0].Id);
            System.assertEquals(response5.isSuccessful,true);*/
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            objDataTblWrap.recid =locationList[0].Id;
            RE_CreateLightningServerResponse response1=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response1.isSuccessful,false,'Success');
        }
    }    
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         05/30/2019
    * @methodname   getDataTestForConObj
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void getDataTestForConObj(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        String conWrapper1 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : " ", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        String conWrapper2 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : " ", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        String conWrapper3 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : " "}';
        
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'Name'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = null;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
        
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap2 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap2.sObjectName = 'Contact';
        objDataTblWrap2.lstFlieds=new List<String>{'Name'};
        objDataTblWrap2.pageSize = '2';
        objDataTblWrap2.pageNumber = '3';
        objDataTblWrap2.recid = 'null';
        objDataTblWrap2.citizenCheck = true;
        objDataTblWrap2.allClientsCheck = false;
        objDataTblWrap2.clientSearchDetails = conWrapper;
        objDataTblWrap2.sortField ='Name';
        objDataTblWrap2.sortDirection ='asc';
        objDataTblWrap2.isReferralOutboxTabClicked=true;
        
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            RE_CreateLightningServerResponse response2=RE_DataTableCtrl.getData(objDataTblWrap2);
            System.assertEquals(response.isSuccessful,true,'Success');
        }
    }    
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         05/30/2019
    * @methodname   testGetDataForConObj
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void testGetDataForConObj(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'PrimaryLocation','PermissionsLevel'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'All';
        objDataTblWrap.citizenCheck = false;
        objDataTblWrap.allClientsCheck = false;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response.isSuccessful,true,'Success');
        }
        
    }    
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         05/30/2019
    * @methodname   testGetDataForConObj
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void testGetDataForConsent(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2]; 
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Consent__c';
        objDataTblWrap.lstFlieds=new List<String>{'Status__c'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        Consent__c consent=new Consent__c();
        RE_ContactWrapper contactWrap=new RE_ContactWrapper(consent);
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response.isSuccessful,true,'Success');
        }
    }    
    /******************************************************************************************
    * @author       Deeksha
    * @date         05/30/2019
    * @methodname   getDataTestForResource
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void getDataTestForResource(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Resource__c';
        objDataTblWrap.lstFlieds=new List<String>{'Name'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response.isSuccessful,true,'Success');
        }
    }
    /******************************************************************************************
    * @author       Deeksha
    * @date         05/30/2019
    * @methodname   getDataTestForReferral
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void getDataTestForReferral(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id,Name FROM Location__c LIMIT 2];
        List<Resource__c> resourceList=[SELECT Id FROM Resource__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Referral__c';
        objDataTblWrap.lstFlieds=new List<String>{'ClientRating__c'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='CreatedById';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
        List<Contact> conlst=[Select id,name from contact];
        //For filter wrapper
        //RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        RE_DataTableCtrl.DataTableReferralFilterWrapper referralfilterwrapper = new RE_DataTableCtrl.DataTableReferralFilterWrapper();
        
        referralfilterwrapper.lstLocationFilter=locationList;
        referralfilterwrapper.contactId=conlst[0].id;
        referralfilterwrapper.lstResourceFilter=resourceList;
        referralfilterwrapper.status='[{"Id":"New","Name":"New"},{"Id":"In Progress - Org in System","Name":"In Progress - Org in System"},{"Id":"In Progress - Org Not in System","Name":"In Progress - Org Not in System"},{"Id":"Closed","Name":"Closed"}]';
        referralfilterwrapper.lessgreaterthan='Greater than';
        referralfilterwrapper.createddate=date.today();
        referralfilterwrapper.dayssinceopened=0; 
        
        objDataTblWrap.referralfilterwrapper=referralfilterwrapper;
      /*
        objDataTblWrap.referralfilterwrapper.contactId=conlst[0].id;
        objDataTblWrap.referralfilterwrapper.lstResourceFilter=resourceList;
        objDataTblWrap.referralfilterwrapper.status='[{"Id":"New","Name":"New"},{"Id":"In Progress - Org in System","Name":"In Progress - Org in System"},{"Id":"In Progress - Org Not in System","Name":"In Progress - Org Not in System"},{"Id":"Closed","Name":"Closed"}]';
        objDataTblWrap.referralfilterwrapper.lessgreaterthan='';
        objDataTblWrap.referralfilterwrapper.dafaultstatus=RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
        
        objDataTblWrap.referralfilterwrapper.createddate=date.today();
        */
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap2 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap2.sObjectName = 'Referral__c';
        objDataTblWrap2.lstFlieds=new List<String>{'ClientRating__c'};
        objDataTblWrap2.pageSize = '2';
        objDataTblWrap2.pageNumber = '3';
        objDataTblWrap2.recid = 'null';
        objDataTblWrap2.citizenCheck = true;
        objDataTblWrap2.allClientsCheck = true;
        objDataTblWrap2.clientSearchDetails = conWrapper;
        objDataTblWrap2.sortField ='Name';
        objDataTblWrap2.sortDirection ='asc';
        objDataTblWrap2.isReferralOutboxTabClicked=true;
        //For filter wrapper

        RE_DataTableCtrl.DataTableReferralFilterWrapper referralfilterwrapper2 = new RE_DataTableCtrl.DataTableReferralFilterWrapper();
        
        referralfilterwrapper2.lstLocationFilter=locationList;
        referralfilterwrapper2.contactId=conlst[0].id;
        referralfilterwrapper2.lstResourceFilter=resourceList;
        referralfilterwrapper2.status='[{"Id":"New","Name":"New"},{"Id":"In Progress - Org in System","Name":"In Progress - Org in System"},{"Id":"In Progress - Org Not in System","Name":"In Progress - Org Not in System"},{"Id":"Closed","Name":"Closed"}]';
        referralfilterwrapper2.lessgreaterthan='Greater than';
        referralfilterwrapper2.createddate=date.today();
        referralfilterwrapper2.dayssinceopened=0; 
        referralfilterwrapper2.organizationName='test';
        referralfilterwrapper2.resourceName='test';
        referralfilterwrapper2.dafaultstatus='Closed';
        referralfilterwrapper2.defaultloc='test';
        
        objDataTblWrap2.referralfilterwrapper=referralfilterwrapper;
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response.isSuccessful,true,'Success');
            objDataTblWrap.recid =locationList[0].Id;
            RE_CreateLightningServerResponse response1=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response1.isSuccessful,true,'Success');
            RE_CreateLightningServerResponse response2=RE_DataTableCtrl.getData(objDataTblWrap2);
            objDataTblWrap2.recid = 'All';
            RE_CreateLightningServerResponse response3=RE_DataTableCtrl.getData(objDataTblWrap2);
        }
    }
    
    /******************************************************************************************
    * @author       Shubham
    * @date         12/11/2019
    * @methodname   getDataTestForReferralElse
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void getDataTestForReferralElse(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id,Name FROM Location__c LIMIT 2];
        List<Resource__c> resourceList=[SELECT Id FROM Resource__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Referral__c';
        objDataTblWrap.lstFlieds=new List<String>{'ClientRating__c'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
        List<Contact> conlst=[Select id,name from contact];
        RE_DataTableCtrl.DataTableReferralFilterWrapper referralfilterwrapper = new RE_DataTableCtrl.DataTableReferralFilterWrapper();
        
        referralfilterwrapper.lstLocationFilter=locationList;
        referralfilterwrapper.contactId=conlst[0].id;
        referralfilterwrapper.lstResourceFilter=resourceList;
        referralfilterwrapper.status='[{"Id":"New","Name":"New"},{"Id":"In Progress - Org in System","Name":"In Progress - Org in System"},{"Id":"In Progress - Org Not in System","Name":"In Progress - Org Not in System"},{"Id":"Closed","Name":"Closed"}]';
        referralfilterwrapper.lessgreaterthan='Less than';
        referralfilterwrapper.createddate=date.today();
        referralfilterwrapper.dayssinceopened=0;
        referralfilterwrapper.dafaultstatus=RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
        referralfilterwrapper.organizationName='test';
        referralfilterwrapper.resourceName='test';
        referralfilterwrapper.defaultloc='test';
        
        objDataTblWrap.referralfilterwrapper=referralfilterwrapper;
        
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap2 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap2.sObjectName = 'Referral__c';
        objDataTblWrap2.lstFlieds=new List<String>{'ClientRating__c'};
        objDataTblWrap2.pageSize = '2';
        objDataTblWrap2.pageNumber = '3';
        objDataTblWrap2.recid = 'null';
        objDataTblWrap2.citizenCheck = true;
        objDataTblWrap2.allClientsCheck = true;
        objDataTblWrap2.clientSearchDetails = conWrapper;
        objDataTblWrap2.sortField ='Name';
        objDataTblWrap2.sortDirection ='asc';
        objDataTblWrap2.isReferralOutboxTabClicked=true;
        
        RE_DataTableCtrl.DataTableReferralFilterWrapper referralfilterwrapper2 = new RE_DataTableCtrl.DataTableReferralFilterWrapper();
        referralfilterwrapper2.lstLocationFilter=locationList;
        referralfilterwrapper2.contactId=conlst[0].id;
        referralfilterwrapper2.lstResourceFilter=resourceList;
        referralfilterwrapper2.status='[{"Id":"New","Name":"New"},{"Id":"In Progress - Org in System","Name":"In Progress - Org in System"},{"Id":"In Progress - Org Not in System","Name":"In Progress - Org Not in System"},{"Id":"Closed","Name":"Closed"}]';
        referralfilterwrapper2.lessgreaterthan='Greater than';
        referralfilterwrapper2.createddate=date.today();
        referralfilterwrapper2.dayssinceopened=0; 
        referralfilterwrapper2.organizationName='test';
        referralfilterwrapper2.resourceName='test';
        referralfilterwrapper2.dafaultstatus='Closed';
        referralfilterwrapper2.defaultloc='test';
        
        objDataTblWrap2.referralfilterwrapper=referralfilterwrapper;
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response.isSuccessful,true,'Success');
            objDataTblWrap.recid =locationList[0].Id;
            RE_CreateLightningServerResponse response1=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response1.isSuccessful,true,'Success');
            RE_CreateLightningServerResponse response2=RE_DataTableCtrl.getData(objDataTblWrap2);
        }
    }
    
    /********************************************************************************************
    * @author       Deloitte
    * @date         07/09/2019
    * @methodname   getUserRole()
    * @description  This methods is used to get the user role
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
        
    @isTest public static  void getAssisterDataTest(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "Bostonic Bulk Company", "LastName" : null, "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'Name'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = null;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';

        RE_DataTableCtrl.DataTableWrapper objDataTblWrap2 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap2.sObjectName = 'Contact';
        objDataTblWrap2.lstFlieds=new List<String>{'Name'};
        objDataTblWrap2.pageSize = '2';
        objDataTblWrap2.pageNumber = '3';
        objDataTblWrap2.recid = 'null';
        objDataTblWrap2.citizenCheck = true;
        objDataTblWrap2.allClientsCheck = false;
        objDataTblWrap2.clientSearchDetails = null;
        objDataTblWrap2.sortField ='Name';
        objDataTblWrap2.sortDirection ='asc';
        
        //Consent
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap1 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap1.sObjectName = 'Consent__c';
        objDataTblWrap1.lstFlieds=new List<String>{'Status__c'};
        objDataTblWrap1.pageSize = '2';
        objDataTblWrap1.pageNumber = '3';
        objDataTblWrap1.recid = 'null';
        objDataTblWrap1.citizenCheck = true;
        objDataTblWrap1.allClientsCheck = true;
        objDataTblWrap1.clientSearchDetails = conWrapper;
        objDataTblWrap1.sortField ='Name';
        objDataTblWrap1.sortDirection ='asc';
        objDataTblWrap1.citizenCheck =true;
        Consent__c consent=new Consent__c();
        RE_ContactWrapper contactWrap=new RE_ContactWrapper(consent);
        
        //Consent end
        Test.startTest();
        System.runAs(u){
            //For Consent
            RE_CreateLightningServerResponse response3=RE_DataTableCtrl.getAssisterData(objDataTblWrap1);
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getAssisterData(objDataTblWrap);            
            conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : null, "LastName" : "test", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
            objDataTblWrap2.clientSearchDetails = conWrapper;
            RE_DataTableCtrl.getAssisterData(objDataTblWrap2);
            objDataTblWrap2.recid = 'All';
            RE_DataTableCtrl.getAssisterData(objDataTblWrap2);
            String conWrapper2 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : null, "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
            objDataTblWrap2.clientSearchDetails = conWrapper2;
            RE_DataTableCtrl.getAssisterData(objDataTblWrap2);
            String conWrapper3 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : "test", "Email" : "Technology", "Phone" : "123456", "BirthDate" : null }';
            objDataTblWrap2.clientSearchDetails = conWrapper3;            
            RE_DataTableCtrl.getAssisterData(objDataTblWrap2);
            string conWrapper4 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : "test", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
            objDataTblWrap2.clientSearchDetails = conWrapper4;            
            RE_DataTableCtrl.getAssisterData(objDataTblWrap2);
            objDataTblWrap2.clientSearchDetails = null;            
            RE_DataTableCtrl.getAssisterData(objDataTblWrap2);
            System.assertEquals(response.isSuccessful,true,'Success');
            objDataTblWrap.recid =locationList[0].Id;
            RE_CreateLightningServerResponse response1=RE_DataTableCtrl.getAssisterData(objDataTblWrap);
        }
         Test.stopTest();
    }
    
    
    /********************************************************************************************
    * @author       Deloitte
    * @date         07/09/2019
    * @methodname   getUserRole()
    * @description  This methods is used to get the user role
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
    @isTest public static  void getUserRoleTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        System.runAs(u){
        RE_CreateLightningServerResponse response1=RE_DataTableCtrl.getUserRole();
            System.assertEquals(response1.isSuccessful,true,'Success');
        }
    }
    
    /********************************************************************************************
    * @author       Arun
    * @date         09/27/2019
    * @methodname   getAssisterDataNullTest()
    * @description  This methods is used to get the Assister data
    * @return       
    **********************************************************************************************/
        
    @isTest public static void getAssisterDataNullTest(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : null, "LastName" : "test", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        String conWrapper2 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : "test", "Email" : "Technology", "Phone" : "123456", "BirthDate" : null }';
        String conWrapper3 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : null, "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'Name'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = null;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        // birthdate null wrapper
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap3 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap3.sObjectName = 'Contact';
        objDataTblWrap3.lstFlieds=new List<String>{'Name'};
        objDataTblWrap3.pageSize = '2';
        objDataTblWrap3.pageNumber = '3';
        objDataTblWrap3.recid = 'null';
        objDataTblWrap3.citizenCheck = true;
        objDataTblWrap3.allClientsCheck = true;
        objDataTblWrap3.clientSearchDetails = conWrapper2;
        objDataTblWrap3.sortField ='Name';
        objDataTblWrap3.sortDirection ='asc';
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap7 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap7.sObjectName = 'Contact';
        objDataTblWrap7.lstFlieds=new List<String>{'Name'};
        objDataTblWrap7.pageSize = '2';
        objDataTblWrap7.pageNumber = '3';
        objDataTblWrap7.recid = 'null';
        objDataTblWrap7.citizenCheck = true;
        objDataTblWrap7.allClientsCheck = true;
        objDataTblWrap7.clientSearchDetails = conWrapper3;
        objDataTblWrap7.sortField ='Name';
        objDataTblWrap7.sortDirection ='asc';
        //  null wrapper
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap4 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap4.sObjectName = 'Contact';
        objDataTblWrap4.lstFlieds=new List<String>{'Name'};
        objDataTblWrap4.pageSize = '2';
        objDataTblWrap4.pageNumber = '3';
        objDataTblWrap4.recid = 'null';
        objDataTblWrap4.citizenCheck = true;
        objDataTblWrap4.allClientsCheck = false;
        objDataTblWrap4.sortField ='Name';
        objDataTblWrap4.sortDirection ='asc';
        objDataTblWrap4.clientSearchDetails = null;
        //  allClientsCheck false wrapper
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap5 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap5.sObjectName = 'Contact';
        objDataTblWrap5.lstFlieds=new List<String>{'Name'};
        objDataTblWrap5.pageSize = '2';
        objDataTblWrap5.pageNumber = '3';
        objDataTblWrap5.recid = 'null';
        objDataTblWrap5.citizenCheck = true;
        objDataTblWrap5.allClientsCheck = false;
        objDataTblWrap5.sortField ='Name';
        objDataTblWrap5.sortDirection ='asc';
        objDataTblWrap5.clientSearchDetails = conWrapper2;
        //Consent
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap1 = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap1.sObjectName = 'Consent__c';
        objDataTblWrap1.lstFlieds=new List<String>{'Status__c'};
        objDataTblWrap1.pageSize = '2';
        objDataTblWrap1.pageNumber = '3';
        objDataTblWrap1.recid = 'null';
        objDataTblWrap1.citizenCheck = true;
        objDataTblWrap1.allClientsCheck = true;
        objDataTblWrap1.clientSearchDetails = conWrapper2;
        objDataTblWrap1.sortField ='Name';
        objDataTblWrap1.sortDirection ='asc';
        objDataTblWrap1.citizenCheck =true;
        Consent__c consent=new Consent__c();
        RE_ContactWrapper contactWrap=new RE_ContactWrapper(consent);
        
        //Consent end
        Test.startTest();
        System.runAs(u){
            //For Consent
            RE_CreateLightningServerResponse response3=RE_DataTableCtrl.getAssisterData(objDataTblWrap1);
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getAssisterData(objDataTblWrap);
            RE_CreateLightningServerResponse responseNull=RE_DataTableCtrl.getAssisterData(objDataTblWrap3);
            RE_CreateLightningServerResponse responseNull1=RE_DataTableCtrl.getAssisterData(objDataTblWrap7);
            RE_CreateLightningServerResponse response4=RE_DataTableCtrl.getAssisterData(objDataTblWrap4);
            RE_CreateLightningServerResponse response5=RE_DataTableCtrl.getAssisterData(objDataTblWrap5);
            System.assertEquals(response.isSuccessful,true,'Success');
            objDataTblWrap.recid =locationList[0].Id;
            RE_CreateLightningServerResponse response1=RE_DataTableCtrl.getAssisterData(objDataTblWrap);
           // System.assertEquals(response1.isSuccessful,true,'Success');
        }
         Test.stopTest();
    }
        /******************************************************************************************
    * @author       Payal Dubela
    * @date         05/30/2019
    * @methodname   testGetDataForConObj
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void testGetDataForConObjRestCall(){
        Test.setMock(HttpCalloutMock.class, new RE_ClientSearchMockResponse());
        String birthdate= (System.now()-112086).format('YYYY-MM-dd');
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : "user", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "'+birthdate+'" }';
        REIntegrationEndpoints__c setting = new REIntegrationEndpoints__c();
        setting.Name='ClientSearch';
        setting.Endpoint_URI__c='https://ms-nonprod-lb.ky.gov/ky-re-case-services-xapi-development/api/case/search';
        setting.Content_Type__c='application/json';
        setting.Http_Method_Type__c='POST';
        setting.Is_Cert_Required__c=false;
        setting.Certificate_Name__c='test';
        insert setting;
        
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'FirstName','LastName','Email','Phone','BirthDate'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = true;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
            Test.startTest();
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
        objDataTblWrap.sortField ='CreatedById';
        response=RE_DataTableCtrl.getData(objDataTblWrap);
            Test.stopTest();
            System.assertEquals(response.isSuccessful,true,'Success');
    }  
    /******************************************************************************************
    * @author       Megha Mittal
    * @date         01/07/2020
    * @methodname   testGetDataforContactObject
    * @description  This method is used to test the functionality of method - getData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void testGetDataForConObj1(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : null, "LastName" : "232323", "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'Name'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = false;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            System.assertEquals(response.isSuccessful,true,'Success');
        }
        
    }
    @isTest public static void testGetDataForConObj3(){
        String conWrapper = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : null, "Email" : "Technology", "Phone" : "123456", "BirthDate" : "13-06-29" }';
        Contact con=[Select id from contact where email=:RE_GlobalConstants.strCitizenEmail limit 1];
        List<Location__c> locationList=[SELECT Id FROM Location__c LIMIT 2];
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        RE_DataTableCtrl.DataTableWrapper objDataTblWrap = new RE_DataTableCtrl.DataTableWrapper();
        objDataTblWrap.sObjectName = 'Contact';
        objDataTblWrap.lstFlieds=new List<String>{'Name'};
        objDataTblWrap.pageSize = '2';
        objDataTblWrap.pageNumber = '3';
        objDataTblWrap.recid = 'null';
        objDataTblWrap.citizenCheck = true;
        objDataTblWrap.allClientsCheck = false;
        objDataTblWrap.clientSearchDetails = conWrapper;
        objDataTblWrap.sortField ='Name';
        objDataTblWrap.sortDirection ='asc';
        objDataTblWrap.isReferralOutboxTabClicked=false;
        System.runAs(u){
            RE_CreateLightningServerResponse response=RE_DataTableCtrl.getData(objDataTblWrap);
            RE_DataTableCtrl.getAssisterData(objDataTblWrap);            
            RE_DataTableCtrl.checkUserForContact(con.Id);                        
            String conWrapper1 = '{ "Id" : "001B000000oAg2fIAC", "FirstName" : "test", "LastName" : "test2", "Email" : "Technology", "Phone" : "123456", "BirthDate" : null }';
            objDataTblWrap.clientSearchDetails = conWrapper1;    
            RE_DataTableCtrl.getData(objDataTblWrap);            
            objDataTblWrap.recid = 'All';
            RE_DataTableCtrl.getData(objDataTblWrap);            
            objDataTblWrap.clientSearchDetails = null;
            RE_DataTableCtrl.getData(objDataTblWrap);            
            RE_DataTableCtrl.getPickListValues('Referral__c','CartAction__c') ;
            RE_DataTableCtrl.createContactForIEESData('Test111');   
            System.assertEquals(response.isSuccessful,true,'Success');
        }
        
    }
    
}