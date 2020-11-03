@isTest(seeAllData=false)
public with sharing class SSP_IdentityDocumentUploadControllerTest {
 @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();   
        SSP_TestDataFactory.setUpNonCitizenUser(); 
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(2, false);
        lstAcc[0].Name = 'IncomeController';
        lstAcc[1].Name = 'NewAccountController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'NonCitizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;

        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(2, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].ProgramsApplied__c = 'MA;KT;SN';
        lstAppln[1].Account__c=lstAcc[1].Id;        
        lstAppln[1].Contact__c = lstCon[0].Id;
        lstAppln[1].ProgramsApplied__c = 'MA;KT;SN';
        insert lstAppln;
        
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;
        lstMem[0].firstName__c='FirstName';
        lstMem[0].lastName__c='LastName'    ;
        lstMem[0].GenderCode__c='M';
        lstMem[0].BirthDate__c=system.today();
        lstMem[0].IndividualId__c='565756';
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].IsHeadOfHousehold__c =true;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].MemberProgramsApplied__c='SN;MA;KT';
        insert lstAppInd;   
        
    }

    @isTest
    public static void createJSONWrapperTest()  
    {
        

                User noncitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        

                    List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
            List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50]; 
            Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',200,false,'Full Match'));         
            test.startTest();
             
        SSP_LightningResponse objResponse= SSP_IdentityVerificationUploadController.createJSONWrapper(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c, true,'documentUpload');
           system.assertNotEquals(null, objResponse.mapResponse);

            test.stopTest();
    }
    
    @isTest
    public static void createJSONWrapperTest1()  
    {        
        User noncitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50]; 
        Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',200,false,'Full Match'));         
        test.startTest();
        SSP_LightningResponse objResponse= SSP_IdentityVerificationUploadController.createJSONWrapper(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c, true,'RIDPPage');
        system.assertNotEquals(null, objResponse.mapResponse);        
        test.stopTest();
}
@istest
public static void getValuesFromPickListTest()
{
     User noncitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        System.runAs(noncitizen){
            List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 1];   
    SSP_LightningResponse objResponse=SSP_IdentityVerificationUploadController.getValuesFromPickList('DocumentDetail__c','Identity_Form_of_Proof__c',lstMembers[0].Id);
    system.assertNotEquals(null, objResponse.mapResponse);

        }
}
}