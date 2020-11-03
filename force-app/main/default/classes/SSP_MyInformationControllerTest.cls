/*
* classname     :  SSP_MyInformationControllerTest
* @description  :  Test class for SSP_MyInformationController
* @author       :  Kireeti Gora  
* @date         :  01/03/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
/**
@author : Kireeti Gora
Method to setup test data*/ 
@isTest(seeAllData=false)
public class SSP_MyInformationControllerTest {
    
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'myInformationController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1]; 
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenOne', 'User', 'citizenone@abc.xyz', contactRecordTypeId, false));
        lstContacts[0].CaseOwnership__c ='test';
        lstContacts[0].Id =lstCon[0].id;
        lstContacts[0].individualId__c ='678688';
        update lstContacts;
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].status__c = 'Approved';
        lstAppln[0].LocalDCBSOffice__c = 'Kentucky';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PhysicalAddressLine1__c='test';
        lstMem[0].PhysicalAddressLine2__c='test';
       // lstMem[0].PhysicalCountyCode__c='1';
        lstMem[0].PhysicalStateCode__c='AL';
        lstMem[0].PhysicalZipCode5__c='40014';
        lstMem[0].MailingAddressLine1__c='test';
        lstMem[0].MailingAddressLine2__c='test';
//        lstMem[0].MailingCountyCode__c='1';
        lstMem[0].MailingStateCode__c='AL';
        lstMem[0].MailingZipCode5__c='40014';
        lstMem[0].PreferredNotificationMethodCode__c='P';
        lstMem[0].PreferredDCBSOffice__c='sample';
        lstMem[0].DcId__c=7896;
        insert lstMem;
        
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;   
        
    }
    /**
@author : Kireeti Gora
Test Method to test getMyInformationDetails method*/
    @isTest
    public static void test_getMyInformationDetails(){
        Test.setMock(HttpCalloutMock.class, new SSP_DC_ReverseMockImpl());
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest();
            
            SSP_LightningResponse response = SSP_MyInformationController.getMyInformationDetails('page');
            system.assertNotEquals(null, response.mapResponse);
            system.assert(response.mapResponse.containsKey('memberDetail'));  
            
            
            
            test.stopTest();
        }
        
    } 
    /**
@author : Kireeti Gora
Test Method to test test_getMyInformationDetails_Negative method*/
    @isTest
    public static void test_getMyInformationDetails_Negative(){
        List<SSP_Member__c> lstMember =  new List<SSP_Member__c>();
        lstMember = [SELECT Id from SSP_Member__c];
        delete lstMember;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest();
            
            SSP_LightningResponse response = SSP_MyInformationController.getMyInformationDetails('page');
            
            SSP_MyInformationController.getCaseOwnershipFlag();
             Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        	sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'678688');
            sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,'Assister');
            SSP_MyInformationController.getCaseOwnershipFlag(); 
            system.assertNotEquals(null, response.mapResponse);
        
            
            
            test.stopTest();
        }
        
    } 
        /**
@author : Kireeti Gora
Test Method to test test_getMyInformationDetails_2 method*/
    @isTest
    public static void test_getMyInformationDetails_2(){
        Test.setMock(HttpCalloutMock.class, new SSP_DC_ReverseMockImpl());
        List<SSP_Application__c> lstApp =  new List<SSP_Application__c>();
        lstApp = [SELECT Id,DCCaseNumber__c from SSP_Application__c];
        lstApp[0].DCCaseNumber__c =null;
        update lstApp;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest();
             Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'678688');
            SSP_LightningResponse response = SSP_MyInformationController.getMyInformationDetails('page');
             SSP_LightningResponse response1 = SSP_MyInformationController.getMyInformationDetails(SSP_GlobalConstants.HAMBURGER);
            sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'abghhh');
            SSP_LightningResponse response2 = SSP_MyInformationController.getMyInformationDetails('page');
            SSP_Member__c currentMem = [Select Id, firstName__c, PreferredDCBSOffice__c, MailingZipCode5__c from SSP_Member__c where firstName__c='TRQSDCVIUH' LIMIT 1];
            currentMem.firstName__c = null;
            currentMem.PreferredDCBSOffice__c = '';
            update currentMem;
            SSP_MyInformationController.LocalDCBSOffice = '';
            SSP_LightningResponse response3 = SSP_MyInformationController.getMyInformationDetails('page');
            system.assertNotEquals(null, response.mapResponse);
           
            
            
            test.stopTest();
        }
        
    } 
    
    /**
@author : Kireeti Gora
Test Method to test test_getMyInformationDetails_3 method*/
    @isTest
    public static void test_getMyInformationDetails_3(){
        List<SSP_Application__c> lstApp =  new List<SSP_Application__c>();
        lstApp = [SELECT Id,DCCaseNumber__c from SSP_Application__c];
        lstApp[0].DCCaseNumber__c =null;
        update lstApp;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest();
            SSP_Member__c currentMem = [Select Id, firstName__c, PreferredDCBSOffice__c, MailingZipCode5__c from SSP_Member__c where MailingZipCode5__c='40014' LIMIT 1];
            currentMem.firstName__c = null;
            currentMem.PreferredDCBSOffice__c = '';
            update currentMem;
            SSP_MyInformationController.LocalDCBSOffice = '';
            SSP_LightningResponse response3 = SSP_MyInformationController.getMyInformationDetails('page');
            test.stopTest();
        }
        
    } 
    
        
    private static User fetchCitizenUser(){
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
        /**
    @author : Shrikant Raut
    Test Method to test fetchContactMethodDetails method
	*/
    @isTest
    public static void test_fetchContactMethodDetails(){    
        User citizen = fetchCitizenUser();
        System.runAs(citizen){
            test.startTest();
            SSP_Member__c member = [SELECT Id FROM SSP_Member__c LIMIT 1][0];
            member.PreferredNotificationMethodCode__c = 'P';
            update member;
            
            SSP_LightningResponse response = new SSP_LightningResponse();
            response = SSP_MyInformationController.fetchContactMethodDetails(citizen.Id);
            response = SSP_MyInformationController.fetchContactMethodDetails(member.Id);
            system.assertNotEquals(null, response.mapResponse, 'failed in fetching mapResponse');
            system.assertEquals(true, response.mapResponse.containsKey('dataWrapper'), 'failed in fetching mapResponse');
            test.stopTest();
        }
    }
     @isTest
    public static void test1(){
        SSP_Member__c member = [SELECT Id FROM SSP_Member__c LIMIT 1][0];
        String individualId = SSP_MyInformationControllerTest.getIndividualId();
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
        SSP_LightningResponse response2 = SSP_MyInformationController.triggerMyInfoCallout(individualId);
       
    }
    }
    @isTest
    public static void test2(){
        String line1='testline1';
        String line2='testline2'; 
        String city='testline3'; 
        String county='testline4';
        String state='testline5';
        String zip4='testline6'; 
        String zip5='testline7';
        String country='testline8';
        SSP_MyInformationController.formatAddress(line1,line2,city,county,state,zip4,zip5,country);
    }
    @isTest
        public static String getIndividualId(){
        //added by nupoor
        String individualId;
        if(UserInfo.getSessionId() != null){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        individualId = sessionPart != null ? ((sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID) != null && String.isNotBlank(String.valueOf(sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID)))) ? String.valueOf(sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID)) : String.valueOf(sessionPart.get(SSP_CacheBuilderImplementation.class, SSP_GlobalConstants.INDIVIDUAL_ID))) : null;            
        
        }
        return (individualId != null && !String.isBlank(individualId)) ? individualId : null;
    }
    @isTest
    public static void getIndividualId1(){
    List<Account> lstAcc1 = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc1[0].Name = 'myInformationController';
        insert lstAcc1;
        
        List<Contact> lstCon1 = [SELECT Id, FirstName, LastName,CaseOwnership__c FROM Contact WHERE CaseOwnership__c!=null  LIMIT 1];
        //insert lstCon1;
        
        AccountContactRelation acr1 = new AccountContactRelation(); 
        acr1.Accountid = lstAcc1[0].Id;
        acr1.Contactid = lstCon1[0].Id;
        acr1.IsActive = true;
        insert acr1;
    }
      @isTest
    public static void testupsertMemberInformation(){
    Boolean test = SSP_MyInformationController.upsertMemberInformation(null,null);
    }
    
}
