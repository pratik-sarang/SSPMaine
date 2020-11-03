/*
* classname     :  SSP_HeaderCtrlTest
* @description  :  Test Class for SSP_HeaderCtrl
* @author       :  Varun Kochar   
* @date         :  28/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_HeaderCtrlTest {
    @testSetup
    static void setupTestData() {
        SSP_TestDataFactory.setupTestData();  
        User nonCitizenUser = SSP_TestDataFactory.setUpNonCitizenUser();
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);        
        lstMem[0].contact__c = nonCitizenUser.ContactId;
        lstMem[0].IndividualId__c = '823968274';
        insert lstMem;
        
        Contact nonCitizenContact = new Contact(Id = nonCitizenUser.ContactId);
        nonCitizenContact.IndividualId__c = '823968274';
         nonCitizenContact.FirstName='Fname';
        nonCitizenContact.LastName='LNAme';
        nonCitizenContact.MiddleName='M';
        nonCitizenContact.SuffixCode__c='JR'; 
        update nonCitizenContact;
        SSPIntegrationEndpoints__c ednPoint = new SSPIntegrationEndpoints__c(Name = 'PE_URL_Redirect',URL__c = 'https://dev5.benefind.chfsinet.ky.gov/selfservice/validateuser?operationName=PE_BCCTP');
       insert ednPoint;
    }    
    @isTest
    public static void testUpdateUserLanguage(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        system.runAs(citizen){
            Test.startTest();
            SSP_HeaderCtrl.updateUserLanguage('es');
            String language  = (String) SSP_HeaderCtrl.getLoggedInUserInfo().mapResponse.get('wrapper');
            system.assertEquals('es', language);
            SSP_HeaderCtrl.updateUserLanguage('es234567');
            Test.stopTest();
        }
    }
    @isTest
    public static void testUpdateUserLanguage1(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'823968274');
        system.runAs(citizen){
            Test.startTest();
            SSP_HeaderCtrl.updateUserLanguage('es');
            String language  = (String) SSP_HeaderCtrl.getLoggedInUserInfo().mapResponse.get('wrapper');
            system.assertEquals('es', language);
            SSP_HeaderCtrl.updateUserLanguage('es234567');
            Test.stopTest();
        }
    }
    @isTest
    public static void getLoggedInUserInfoTest_NonCitizen(){
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];  
        nonCitizen.LastVisitedNonCitizenRole__c='DAIL_Worker';
        nonCitizen.ShowCitizenDashboard__c=true;
        nonCitizen.SelectedRole__c='DAIL_Worker';
        nonCitizen.KOG_Role__c='';
        nonCitizen.ImpersonatedIndividualId__c='823968274';
        update nonCitizen;
        system.runAs(nonCitizen){
            Test.startTest();
            SSP_LightningResponse response = SSP_HeaderCtrl.getLoggedInUserInfo();
            system.assert(response.mapResponse.containsKey('userDetails'));
            Test.stopTest();
        }
    }
    @isTest
    public static void getLoggedInUserInfoTest_NonCitizen1(){
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Non_Citizen');
        Contact nonCitizenContact = SSP_TestDataFactory.createContactRecord('Fname1', 'LNAme1', 'noncitizen1@abc.xyz', contactRecordTypeId, true);        
        User nonCitizenUser = SSP_TestDataFactory.createCommunityUser('sspNonC', nonCitizenContact.Id,'noncitizen1@abc.xyz', 'SSP Non Citizen Profile', true);
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);        
        lstMem[0].contact__c = nonCitizenUser.ContactId;
        lstMem[0].IndividualId__c = '823968271';
        insert lstMem;
        system.runAs(nonCitizenUser){
            Test.startTest();
            SSP_LightningResponse response = SSP_HeaderCtrl.getLoggedInUserInfo();
            system.assert(response.mapResponse.containsKey('userDetails'));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getHOHFlagTest(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        system.runAs(citizen){
            Test.startTest();
            SSP_HeaderCtrl.getHOHFlag();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateMemberTypeOnContactTest1(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        system.runAs(citizen){
            Test.startTest();
            SSP_HeaderCtrl.updateMemberTypeOnContact(true);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateMemberTypeOnContactTest2(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        system.runAs(citizen){
            Test.startTest();
            SSP_HeaderCtrl.updateMemberTypeOnContact(false);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateMemberTypeOnContactTest3(){
        User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        updateMemberType(citizen.ContactId);
        system.runAs(citizen){
            Test.startTest();
            SSP_HeaderCtrl.updateMemberTypeOnContact(false);
            String operationName = 'PE_BCCTP';
            //SSP_LightningResponse resultMap = SSP_Utility.validateSSORedirect(operationName);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateMemberTypeOnContactTest4(){
        User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        updateMemberType(citizen.ContactId);
        system.runAs(citizen){
            Test.startTest();
            SSP_HeaderCtrl.updateMemberTypeOnContact(true);
            Test.stopTest();
        }
    }
    
    private static void updateMemberType(String contactId){
        if(String.isNotBlank(contactId)){
            Contact con = [SELECT Id, MemberType__c FROM Contact WHERE Id = :contactId];
            if (con != null) {
                con.MemberType__c = 'DEP';
                update con;
            }
        }
    }
    
    @isTest
    public static void returnToNonCitizenDashboardTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];  
        nonCitizen.LastVisitedNonCitizenRole__c='DAIL_Worker';
        nonCitizen.ShowCitizenDashboard__c=true;
        nonCitizen.SelectedRole__c='Insurance_Agent';
        nonCitizen.KOG_Role__c='';
        nonCitizen.ImpersonatedIndividualId__c='823968274';
        update nonCitizen;
        Test.startTest();      
        System.runAs(nonCitizen){
            SSP_LightningResponse response = SSP_HeaderCtrl.returnToNonCitizenDashboard();    
        }
        Test.stopTest();
    }
    @isTest
    public static void returnToNonCitizenDashboardTest2(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];  
        nonCitizen.LastVisitedNonCitizenRole__c='DAIL_Worker';
        nonCitizen.ShowCitizenDashboard__c=true;
        nonCitizen.SelectedRole__c='CASE_SUPERVISOR';
        nonCitizen.KOG_Role__c='';
        nonCitizen.ImpersonatedIndividualId__c='823968274';
        update nonCitizen;
        Test.startTest();      
        System.runAs(nonCitizen){
            SSP_LightningResponse response = SSP_HeaderCtrl.returnToNonCitizenDashboard();    
        }
        Test.stopTest();
    }
    @isTest
    public static void returnToNonCitizenDashboardTest1(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];  
        Test.startTest();      
        System.runAs(nonCitizen){
            SSP_HeaderCtrl.getVerticalMenuDetails();          
        }
        Test.stopTest();
    }
    
    @isTest
    public static void fetchKogURLTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];  
        Test.startTest();      
        System.runAs(nonCitizen){
            SSP_HeaderCtrl.fetchKogURL('Community Partner Admin');
            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void fetchKogURLTest1(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];  
        Test.startTest();      
        System.runAs(nonCitizen){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID, '110011001');
            //String operationName = 'PE_BCCTP';
            //SSP_LightningResponse resultMap = SSP_Utility.validateSSORedirect(operationName);
            //operationName = 'TAX_FORMS';
            //resultMap = SSP_Utility.validateSSORedirect(operationName);       
            SSP_HeaderCtrl.fetchKogURL('');             
        }
        Test.stopTest();
    }
    @isTest
    public static void fetchKogURLTest2(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];  
        Test.startTest();      
        System.runAs(nonCitizen){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID, '110011001');
            //String operationName = 'PE_BCCTP';
            //SSP_LightningResponse resultMap = SSP_Utility.validateSSORedirect(operationName);
            //operationName = 'TAX_FORMS';
            //resultMap = SSP_Utility.validateSSORedirect(operationName);       
            SSP_HeaderCtrl.fetchKogURL('Citizen');             
        }
        Test.stopTest();
    }
}