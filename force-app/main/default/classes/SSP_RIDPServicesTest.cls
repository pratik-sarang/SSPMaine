@isTest(seeAllData=false)
public with sharing class SSP_RIDPServicesTest {
    
    @TestSetup
    static void setup(){
        
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
        lstMem[0].MailingAddressLine1__c='1 Street';
        lstMem[0].MailingCity__c='Frankfort';
        lstMem[0].MailingStateCode__c='KY';
        lstMem[0].MailingZipCode5__c='40601';
        lstMem[0].MailingZipCode4__c='4231';
        lstMem[0].PrimaryPhoneNumber__c='555-555-5555';
        //Pooja P
        lstMem[0].Reference_Number__c = '12345434712345';
        lstMem[0].Identify_verification_method__c='Resume RIDP';
        lstMem[0].Non_Citizen_Verification_Flag__c=false;
        lstMem[0].IndividualId__c='1235';
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].IsHeadOfHousehold__c =true;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].MemberProgramsApplied__c='SN;MA;KT';
        insert lstAppInd; 
        
        
    }
    
    
    @isTest
    public static void getQuestionsTest()
    {
        
        User noncitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        
        
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50];  
        
        Test.setMock(WebServiceMock.class, new SSP_RIDP_GetQuestionsMockClass());
        test.startTest();
        SSP_LightningResponse objResponse= SSP_RIDPServices.getData(appIndvList[0].SSP_Member__c);
        
        
        map<string,string> newMap= new Map<string,string>();
        for(String strKey: objResponse.mapResponse.keyset())
        {
            newMap.put(strKey, String.valueof(objResponse.mapResponse.get(strKey)));
        }
        SSP_LightningResponse objResponse1= SSP_RIDPServices.getQuestions(newMap, 'EN-US', appIndvList[0].SSP_Member__c);
        test.stopTest();
        system.assertNotEquals(null, objResponse1.mapResponse);
        
        
    }
    
    @istest
    public static void resumeRIDPTest()
    {     
        
        User noncitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        
        
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50];  
        Test.setMock(WebServiceMock.class, new SSP_RIDP_CheckResumeMockClass()); 
        test.startTest();
        SSP_LightningResponse objResponse= SSP_RIDPServices.getData(appIndvList[0].SSP_Member__c);
        
        
        map<string,string> newMap= new Map<string,string>();
        for(String strKey: objResponse.mapResponse.keyset())
        {
            newMap.put(strKey, String.valueof(objResponse.mapResponse.get(strKey)));
        }
        SSP_LightningResponse objResponse1=SSP_RIDPServices.resumeRIDP(newMap);
        test.stopTest();
        system.assertNotEquals(null, objResponse1.mapResponse);
        
    }
    
    
    @istest
    public static void postAnswersTest()
    {
        
        User noncitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50]; 
        
        Test.setMock(WebServiceMock.class, new SSP_RIDP_PostAnswersMockClass());
        
        Map<String,String> mp= new Map<String,String>();
        mp.put('1','1');
        mp.put('2','2');
        mp.put('3','3');
        test.startTest();
        SSP_LightningResponse objResponse1=SSP_RIDPServices.postAnswers(JSON.serialize(mp),'3ba09890-a38e-4813-a350-e5d6' ,'1XQBKVC4UOM20FZYVJDFKQD2.pidd1v-171221133',appIndvList[0].SSP_Member__c);
        test.stopTest();
        system.assertNotEquals(null, objResponse1.mapResponse);
        
        
    }
    //Pooja
    @isTest
    public static void updateApplicationStatusUnSubmitted(){
        test.startTest();
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        SSP_LightningResponse objResponse1=SSP_RIDPServices.updateApplicationStatusUnSubmitted(lstApps[0].Id,appIndvList[0].SSP_Member__c,'documentUpload');
        system.assertEquals(true, objResponse1.bIsSuccess);
        test.stopTest();
    }
    
    @isTest
    public static void updateApplicationStatusUnSubmittedtestforRIDPpage(){
        test.startTest();
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        SSP_LightningResponse objResponse1=SSP_RIDPServices.updateApplicationStatusUnSubmitted(lstApps[0].Id,appIndvList[0].SSP_Member__c,'RIDPPage');
        system.assertEquals(true, objResponse1.bIsSuccess);
        test.stopTest();
    }
     @isTest
    public static void updateApplicationStatusUnSubmittedtestforRIDPpageNegativeSenario(){
        test.startTest();
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        SSP_LightningResponse objResponse1=SSP_RIDPServices.updateApplicationStatusUnSubmitted(null,null,'RIDPPage');
        system.assertEquals(false, objResponse1.bIsSuccess);
        test.stopTest();
    }
     @isTest
    public static void testdeleteNavFlowRecords(){
        test.startTest();
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
           SSP_RIDPServices.deleteNavFlowRecords(null);

        List<SSP_Application__c> lstApps1 = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        system.assert(lstApps1!=null);
        
        
        //system.assertEquals(true, objResponse1.bIsSuccess);
        test.stopTest();
    }
    
    @isTest
    static void getDataTest()
    {
        User noncitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        Contact con=[Select Id,	KOGSourceId__c from Contact where FirstName='NonCitizen' Limit 1];
        con.KOGSourceId__c='1234';
        Database.update(con);
        
        system.runAs(noncitizen){
        
        List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 2];
        List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id] ;
        List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50];  
        Test.startTest();
        SSP_LightningResponse objResponse= SSP_RIDPServices.getData(appIndvList[0].SSP_Member__c);
            Test.stopTest();
            System.assert(objResponse.bIsSuccess);
        }
        
    }
    
    
    
}