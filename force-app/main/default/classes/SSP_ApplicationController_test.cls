/*
* classname     :  sspApplicationController_test
* @description  :  This class contains the test methods for sspApplicationController.
* @author       :  Yathansh Sharma   
* @date         :  12/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
  Yathansh Sharma               12/23/2019                          Created.
**/
@isTest
public class SSP_ApplicationController_test {

    public static String caseApplicationRecordTypeId = Schema.describeSObjects(New String[]{'SSP_Application__c'}).get(0).getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         12/23/2019
     * @methodname   testFetchApplicationRecords
     * @description  This method is used to test the method fetchApplicationList.
     * @return       void
     *****************************************************************************************************/
    @isTest
    public static void testFetchApplicationRecords(){
        SSP_TestDataFactory.setupTestData();  
        test.startTest();
        account acc = new account(name='test');
        insert acc;
        ssp_application__c app = new ssp_application__c(Account__c = acc.id,Status__c='AP',RecordTypeId=caseApplicationRecordTypeId);
        insert app;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        SSP_Member__c mem = new SSP_Member__c();
        mem.name = 'test';
        mem.contact__c = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> citizen.id})[0].contactId;
        insert mem;
        AccountContactRelation acr = new AccountContactRelation();
        acr.contactId = mem.contact__c;
        acr.accountId = app.Account__c;
        acr.roles = 'Authorized Representative';
        insert acr;
        SSP_ApplicationIndividual__c ai = new SSP_ApplicationIndividual__c();
        ai.SSP_Member__c = mem.id;
        ai.SSP_Application__c = app.id;
        insert ai;
        System.runAs(citizen){
            SSP_ApplicationController.fetchApplicationList(null, null,null,null);
        
        	system.assertEquals(1, [select count() from ssp_application__c]);
        }
        test.stopTest();
    }

    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         2/24/2020
     * @methodname   testGetRenewalWrapperData
     * @description  This method is used to test the method getRenewalWrapperData.
     * @return       void
     *****************************************************************************************************/
    @isTest
    public static void testGetRenewalWrapperData(){
        SSP_TestDataFactory.setupTestData();  
        test.startTest();
        account acc = new account(name='test');
        insert acc;
        ssp_application__c app = new ssp_application__c(Account__c = acc.id);
        app.RecordTypeId = Schema.describeSObjects(New String[]{'SSP_Application__c'}).get(0).getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
        app.ProgramsApplied__c = 'MA';
        insert app;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        SSP_Member__c mem = new SSP_Member__c();
        mem.name = 'test';
        mem.contact__c = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> citizen.id})[0].contactId;
        insert mem;
        AccountContactRelation acr = new AccountContactRelation();
        acr.contactId = mem.contact__c;
        acr.accountId = app.Account__c;
        acr.roles = 'Authorized Representative';
        insert acr;
        SSP_DashboardCaseInformation.Renewal renewal= new  SSP_DashboardCaseInformation.Renewal();
        renewal.CaseNumber='76590';
        renewal.RenewalProgramCode=SSP_GlobalConstants.PROGRAM_TYPE_MA;
        renewal.RenewalDueDate=String.valueof(5);
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        mapCaseVsIndividualId.put('76590','76459');
       
        List<SSP_DashboardCaseInformation.Renewal> lstRenewal= new List<SSP_DashboardCaseInformation.Renewal>();
        lstRenewal.add(renewal);
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionpart.put('hasMedicaidRenewals',JSON.serialize(lstRenewal),3600,Cache.Visibility.ALL,false);
        sessionpart.put('caseVsIndividualId',JSON.serialize(mapCaseVsIndividualId),3600,Cache.Visibility.ALL,false);
        System.runAs(citizen){
            SSP_ApplicationController.getRenewalWrapperData(app.id);
        }
        test.stopTest();
    }
    
    //To cover Else block in above function
   	@isTest
    public static void testGetRenewalWrapperDataElse(){
        SSP_TestDataFactory.setupTestData();  
        test.startTest();
        account acc = new account(name='test');
        insert acc;
        ssp_application__c app = new ssp_application__c(Account__c = acc.id);
        app.RecordTypeId = Schema.describeSObjects(New String[]{'SSP_Application__c'}).get(0).getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
        app.ProgramsApplied__c = 'KT';
        insert app;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        SSP_Member__c mem = new SSP_Member__c();
        mem.name = 'test';
        mem.contact__c = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> citizen.id})[0].contactId;
        insert mem;
        AccountContactRelation acr = new AccountContactRelation();
        acr.contactId = mem.contact__c;
        acr.accountId = app.Account__c;
        acr.roles = 'Authorized Representative';
        insert acr;
        SSP_DashboardCaseInformation.Renewal renewal= new  SSP_DashboardCaseInformation.Renewal();
        renewal.CaseNumber='76590';
        renewal.RenewalProgramCode=SSP_GlobalConstants.PROGRAM_TYPE_MA;
        renewal.RenewalDueDate=String.valueof(5);
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        mapCaseVsIndividualId.put('76590','76459');
        List<SSP_DashboardCaseInformation.Renewal> lstRenewal= new List<SSP_DashboardCaseInformation.Renewal>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionpart.put('hasMedicaidRenewals',JSON.serialize(lstRenewal),3600,Cache.Visibility.ALL,false);
        sessionpart.put('caseVsIndividualId',JSON.serialize(mapCaseVsIndividualId),3600,Cache.Visibility.ALL,false);
        System.runAs(citizen){
            SSP_ApplicationController.getRenewalWrapperData(app.id);
        }
        test.stopTest();
    }
    
    //to cover If{} in fetchApplicationRecords() 
       @isTest
    public static void testFetchApplicationRecordsIf(){
        SSP_TestDataFactory.setupTestData();  
        test.startTest();
        account acc = new account(name='test');
        insert acc;
        ssp_application__c app = new ssp_application__c(Account__c = acc.id,Status__c='UN',ProgramsApplied__c='MA',RecordTypeId=caseApplicationRecordTypeId,DCCaseNumber__c=12345,ApplicationCreationInSSP__c=DATE.today().addDays(8));
        insert app;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        SSP_Member__c mem = new SSP_Member__c();
        mem.name = 'test';
        mem.contact__c = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> citizen.id})[0].contactId;
        insert mem;
        AccountContactRelation acr = new AccountContactRelation();
        acr.contactId = mem.contact__c;
        acr.accountId = app.Account__c;
        acr.roles = 'Authorized Representative';
        insert acr;
        SSP_ApplicationIndividual__c ai = new SSP_ApplicationIndividual__c();
        ai.SSP_Member__c = mem.id;
        ai.SSP_Application__c = app.id;
        ai.IsHeadOfHousehold__c=true;
        insert ai;
        System.runAs(citizen){
            SSP_ApplicationController.fetchApplicationList(null, 'sspAssisterOrAgentModal',app.id,'Assister');
        
        	system.assertEquals(1, [select count() from ssp_application__c]);
        }
        test.stopTest();
    }
    
    @isTest
    public static void testgetProgramFromCache(){
        SSP_BenefitInformationWrapper objWrapper = new SSP_BenefitInformationWrapper();
        objWrapper.ProgramCode = system.label.SSP_KTAP;
        objWrapper.CaseNumber='123456';
        objWrapper.EdgNumber='123456';

        List<SSP_BenefitInformationWrapper> lstbenefits= new List<SSP_BenefitInformationWrapper>();
        lstbenefits.add(objWrapper);

        Map<String,List<SSP_BenefitInformationWrapper>> mapcasevswrapper= new Map<String,List<SSP_BenefitInformationWrapper>>();
        mapcasevswrapper.put('123456',lstbenefits);
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionpart.put('AllBenefits',JSON.serialize(mapcasevswrapper));

        Test.startTest();
        ssp_LightningResponse response=SSP_ApplicationController.getProgramFromCache();
        System.assertEquals(response.mapResponse.get('cacheResponse')!=null,true);
        Test.stopTest();

    }
    @isTest
    public static void testhandleMedicaidRenewal(){
        Test.startTest();
        ssp_LightningResponse response=SSP_ApplicationController.handleMedicaidRenewal('123456');
        ssp_LightningResponse response1=SSP_ApplicationController.handleMedicaidRenewal(null);
        Test.stopTest();
    }
    //renewalNextAction
    /*   @isTest
    public static void renewalNextActionTest(){
        SSP_TestDataFactory.setupTestData();  
        test.startTest();
        account acc = new account(name='test');
        insert acc;
        ssp_application__c app = new ssp_application__c(Account__c = acc.id);
        insert app;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        SSP_Member__c mem = new SSP_Member__c();
        mem.name = 'test';
        mem.contact__c = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> citizen.id})[0].contactId;
        insert mem;
        AccountContactRelation acr = new AccountContactRelation();
        acr.contactId = mem.contact__c;
        acr.accountId = app.Account__c;
        acr.roles = 'Authorized Representative';
        insert acr;
        SSP_ApplicationIndividual__c ai = new SSP_ApplicationIndividual__c();
        ai.SSP_Member__c = mem.id;
        ai.SSP_Application__c = app.id;
        insert ai;
        System.runAs(citizen){
            SSP_ApplicationController.renewalNextAction(app.Id);
        
       // 	system.assertEquals(1, [select count() from ssp_application__c]);
        }
        test.stopTest();
        
    } */
        
        
        
    
}