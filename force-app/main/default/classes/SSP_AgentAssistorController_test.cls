/*
* classname     :  SSP_AgentAssistorController_test
* @description  :  This class tests the methods of SSP_AgentAssistorController class.
* @author       :  Yathansh Sharma  
* @date         :  01/27/2019 
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
@isTest 
public with sharing class SSP_AgentAssistorController_test { 
    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         1/27/2019
     * @methodname   testGetAgentAndAssisstor
     * @description  Method to test getAgentAndAssisstor.
     * @return       void
     *****************************************************************************************************/
    @isTest
    public static void testGetAgentAndAssisstor(){
        SSP_TestDataFactory.setupTestData();
        insert new SSP_CountyZipCodeAssociation__c(Name='R1',CountyCode__c='001', ZipCode5__c='20101');
        Test.startTest();

        SSP_AgentAssistorController.queryComponents qc = new SSP_AgentAssistorController.queryComponents();
        qc.firstname='test';
        qc.lastname='contact';
        qc.zipCode='41159';
        qc.latitude = '';
        qc.longitude = '';
        qc.organization='test';
        SSP_CountyZipCodeAssociation__c ship = new SSP_CountyZipCodeAssociation__c(Name='R2',CountyCode__c='002', ZipCode5__c='41159');
        insert ship;
        User citizen  = [SELECT Id,ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        List<SSP_Member__c> listSSPMember = SSP_TestDataFactory.createSSPMembers(1,false);
        listSSPMember[0].Contact__c = citizen.ContactId;
        listSSPMember[0].PhysicalCountyCode__c='023';
        listSSPMember[0].PhysicalGeolocation__latitude__s=50.328832;
        listSSPMember[0].PhysicalGeolocation__longitude__s=12.764771;
        insert listSSPMember;
        String agencyRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Non_Citizen');
        List<Account> listAccount = SSP_TestDataFactory.createAccounts(1,true);
        Contact objContact = SSP_TestDataFactory.createContactRecord('test','contact','test.contact@gmail.com',agencyRecordTypeId,false);
        objContact.AssociatedCountyCode__c='002';
        insert objContact;
        String accountRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        Account accRecord = new account();
        accRecord.Name = 'Test Acc1114';
        accRecord.RecordTypeId=accountRecordTypeId;
        accRecord.BillingPostalCode='41159';
        accRecord.phone='333-222-2342';
        accRecord.dcDataId__c=233354;
        insert accRecord;
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        AccountContactRelation orgACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(objContact.Id,accRecord.id , false);
        orgACR.Roles = 'Assister';
        orgACR.DCContactId__c=2333773;
        listACR.add(orgACR);
        insert listACR;
        List<Contact> conList=[SELECT id ,name ,(select id,account.recordtype.name,account.name,account.dcdataId__c,account.BillingPostalCode,account.phone from accountcontactRelations where account.recordtype.name ='Organization') ,AssociatedCountyCode__c ,MailingCountry ,MailingPostalCode ,AccountId ,Account.BillingPostalCode ,PreferredLanguageCode__c ,SpokenLanguageCode__c ,HoursAvailableCode__c ,IsSearchEnabled__c ,InHousePrivateAssister__c ,Account.Name  FROM contact WHERE Id=:objContact.Id ];
        System.debug('conList--'+conList);
        System.runAs(citizen){
            SSP_AgentAssistorController.getAgentAndAssisstor('Assister', qc);
            SSP_AgentAssistorController.getAgentAndAssisstor('Agent', qc);
            List<Contact> contacts = (List<Contact>)SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact', 'operator'=>'AND'}, 
                                                                                         new Set<String>{'id','name', 'AssociatedCountyCode__c', 'AgencyOrOrganization__c', 'AgencyOrOrganization__r.BillingPostalCode', 'CountyCode__c', 'MailingCountry', 'OtherPostalCode','MailingPostalCode', 'AccountId', 'Account.BillingPostalCode','PreferredLanguageCode__c', 'HoursAvailableCode__c', 'IsSearchEnabled__c', 'InHousePrivateAssister__c','Account.Name'}, 
                                                                                         new Map<String, String>{});
            SSP_AgentAssistorController.filterZipCodeOnContacts(contacts,'Assister',qc);
            SSP_AgentAssistorController.filterZipCodeOnContacts(conList,'Agent',qc);
        }
        test.stopTest();
    }
    
    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         1/27/2019
     * @methodname   testFetchContactInformation
     * @description  Method to test fetchContactInformation.
     * @return       void
     *****************************************************************************************************/
    @isTest
    public static void testFetchContactInformation(){
        SSP_TestDataFactory.setupTestData();
        Test.startTest();
         String agencyRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Non_Citizen');
        List<Account> listAccount = SSP_TestDataFactory.createAccounts(1,true);
        Contact objContact = SSP_TestDataFactory.createContactRecord('test','contact','test.contact@gmail.com',agencyRecordTypeId,true);
        String accountRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
         Account accRecord = new account();
        accRecord.Name = 'Test Acc1114';
        accRecord.RecordTypeId=accountRecordTypeId;
        insert accRecord;
        SSP_AgentAssistorController.queryComponents qc = new SSP_AgentAssistorController.queryComponents();
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        System.runAs(citizen){
            List<Contact> contacts = (List<Contact>)SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact', 'operator'=>'AND'}, 
                                                                   new Set<String>{'id','name', 'CountyCode__c', 'MailingCountry', 'OtherPostalCode','MailingPostalCode', 'AccountId', 'Account.BillingPostalCode','PreferredLanguageCode__c', 'HoursAvailableCode__c', 'IsSearchEnabled__c', 'InHousePrivateAssister__c','Account.Name'}, 
                                                                         new Map<String, String>{});
            SSP_AgentAssistorController.fetchContactInformation(contacts[0].id, null,'');
        }
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        AccountContactRelation orgACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(objContact.Id,accRecord.id , false);
        orgACR.Roles = 'Assister';
        orgACR.DCContactId__c=2333773;
        listACR.add(orgACR);
        insert listACR;
        System.runAs(citizen){
             SSP_AgentAssistorController.fetchContactInformation(objContact.Id, null,'');
        }
        test.stopTest(); 
    }

    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         1/27/2019
     * @methodname   testUpsertAgentAssister
     * @description  Method to test upsertAgentAssister.
     * @return       void
     *****************************************************************************************************/
    @isTest
    public static void testUpsertAgentAssister(){
        SSP_TestDataFactory.setupTestData();
        SSP_UpdateAgentAssisterMock mock = new SSP_UpdateAgentAssisterMock();
        mock.isFailure=true;
        Test.setMock(HttpCalloutMock.class,mock);
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,true));
        
        list<account> accs = new list<account>();
        accs.add(new account(name='test',DCDataId__c=1344333));
        accs.add(new account(name='test2'));
        insert accs;
        contact con = new contact(firstname='test',lastname='test', accountid=accs[1].id);
        con.IndividualId__c = '112233';
        insert con;
        List<SSP_Member__c> listSSPMember = SSP_TestDataFactory.createSSPMembers(1,false);
        listSSPMember[0].Contact__c = con.Id;
        listSSPMember[0].PhysicalCountyCode__c='023';
        insert listSSPMember;
        ssp_application__c app = new ssp_application__c(Account__c = accs[0].id);
        insert app;
        ssp_application__c app1 = new ssp_application__c(Account__c = accs[0].id);
        app1.DCCaseNumber__c = 112293335;
        app1.ProgramsApplied__c = 'DS';
        insert app1;
        List<SSP_ApplicationIndividual__c> listSSPApplicationIndividual = SSP_TestDataFactory.createApplicationIndividuals(1,false);
        listSSPApplicationIndividual[0].SSP_Application__c = app1.Id;
        listSSPApplicationIndividual[0].SSP_Member__c = listSSPMember[0].Id;
        listSSPApplicationIndividual[0].IsHeadOfHousehold__c=true;
        insert listSSPApplicationIndividual;

        User citizen  = [SELECT Id,ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        Contact con1 = new Contact();
        con1.Id=citizen.ContactId;
        con1.AssociatedCountyCode__c='023';
        update con1;
        System.runAs(citizen){
             SSP_AgentAssistorController.upsertAgentAssister(app1.id, con.id, 'Assister','1344333','',false);
        }
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        AccountContactRelation orgACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(citizen.ContactId,accs[0].id , false);
        orgACR.Roles = 'Assister';
        orgACR.DCContactId__c=2333773;
        listACR.add(orgACR);
        insert listACR;
        Test.startTest();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('individualId', '112233');
        System.runAs(citizen){
            SSP_AgentAssistorController.upsertAgentAssister(app1.id,citizen.ContactId, 'Assister','1344333','',true);
            SSP_AgentAssistorController.upsertAgentAssister(app.id,citizen.ContactId, 'Assister','1344333','1344333',false);
            SSP_AgentAssistorController.upsertAgentAssister(app.id, con.id, 'Assister','1344333','1344333',false);
            
        }
        System.runAs(citizen){
        }
        test.stopTest();
    }
    
    //Test For Latitude=null
    @isTest
    public static void testGetAgentAndAssisstornullcondition(){
        SSP_TestDataFactory.setupTestData();
        insert new SSP_CountyZipCodeAssociation__c(Name='R1',CountyCode__c='001', ZipCode5__c='20101');
        Test.startTest();
        SSP_AgentAssistorController.queryComponents qc = new SSP_AgentAssistorController.queryComponents();
        SSP_AgentAssistorController.contactOrganization co = new SSP_AgentAssistorController.contactOrganization();
        qc.firstname='test';
        qc.lastname='test';
        qc.zipCode='20101';
        qc.latitude = '';
        qc.longitude = '';
        qc.organization='test'; 
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        System.runAs(citizen){
            SSP_AgentAssistorController.getAgentAndAssisstor('Agent', qc);
            List<Contact> contacts = (List<Contact>)SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact', 'operator'=>'AND'}, 
                                                                                         new Set<String>{'id','name', 'AssociatedCountyCode__c', 'AgencyOrOrganization__c', 'AgencyOrOrganization__r.BillingPostalCode', 'CountyCode__c', 'MailingCountry', 'OtherPostalCode','MailingPostalCode', 'AccountId', 'Account.BillingPostalCode','PreferredLanguageCode__c', 'HoursAvailableCode__c', 'IsSearchEnabled__c', 'InHousePrivateAssister__c','Account.Name'}, 
                                                                                         new Map<String, String>{});
          co.objContact = contacts[0];
          co.organizationName = 'testOrg';
          co.organizationDataId = '123';
          co.organizationPhone = '123';
          co.organizationContactId = '456';
        }
        test.stopTest();
    }
    
    @isTest
    public static void triggerHBE016_Test(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,true));
        SSP_TestDataFactory.setupTestData();
        list<account> accs = new list<account>();
        accs.add(new account(name='test',DCDataId__c=1344333));
        accs.add(new account(name='test2'));
        insert accs;
        contact con = new contact(firstname='test',lastname='test', accountid=accs[1].id);
        con.IndividualId__c = '112233';
        insert con;
        List<SSP_Member__c> listSSPMember = SSP_TestDataFactory.createSSPMembers(1,false);
        listSSPMember[0].Contact__c = con.Id;
        listSSPMember[0].PhysicalCountyCode__c='023';
        listSSPMember[0].IndividualId__c='234243';
        insert listSSPMember;
        ssp_application__c app = new ssp_application__c(Account__c = accs[0].id);
        insert app;
        ssp_application__c app1 = new ssp_application__c(Account__c = accs[0].id);
        app1.DCCaseNumber__c = 112293335;
        app1.ProgramsApplied__c = 'DS';
        insert app1;
        List<SSP_ApplicationIndividual__c> listSSPApplicationIndividual = SSP_TestDataFactory.createApplicationIndividuals(1,false);
        listSSPApplicationIndividual[0].SSP_Application__c = app1.Id;
        listSSPApplicationIndividual[0].SSP_Member__c = listSSPMember[0].Id;
        listSSPApplicationIndividual[0].IsHeadOfHousehold__c=true;
        insert listSSPApplicationIndividual;

        User citizen  = [SELECT Id,ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        Contact con1 = new Contact();
        con1.Id=citizen.ContactId;
        con1.AssociatedCountyCode__c='023';
        update con1;
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        AccountContactRelation orgACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(citizen.ContactId,accs[0].id , false);
        orgACR.Roles = 'Assister';
        orgACR.DCContactId__c=2333773;
        listACR.add(orgACR);
        insert listACR;
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        mapCaseVsIndividualId.put('76590','76459');
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionpart.put('caseVsIndividualId',JSON.serialize(mapCaseVsIndividualId),3600,Cache.Visibility.ALL,false);
        Test.startTest(); 
        System.runAs(citizen){
            SSP_AgentAssistorController.triggerHBE016(app1,'1344333', '1344333','HBE-016'); 
        }
        test.stopTest();
        
    }
    @isTest
    public static void triggerHBE016_Test1(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,true));
        SSP_TestDataFactory.setupTestData();
        list<account> accs = new list<account>();
        accs.add(new account(name='test',DCDataId__c=1344333));
        accs.add(new account(name='test2'));
        insert accs;
        contact con = new contact(firstname='test',lastname='test', accountid=accs[1].id);
        con.IndividualId__c = '112233';
        insert con;
        List<SSP_Member__c> listSSPMember = SSP_TestDataFactory.createSSPMembers(1,false);
        listSSPMember[0].Contact__c = con.Id;
        listSSPMember[0].PhysicalCountyCode__c='023';
        listSSPMember[0].IndividualId__c='234243';
        insert listSSPMember;
        ssp_application__c app = new ssp_application__c(Account__c = accs[0].id);
        insert app;
        ssp_application__c app1 = new ssp_application__c(Account__c = accs[0].id);
        app1.DCCaseNumber__c = 112293335;
        app1.ProgramsApplied__c = 'DS';
        insert app1;
        List<SSP_ApplicationIndividual__c> listSSPApplicationIndividual = SSP_TestDataFactory.createApplicationIndividuals(1,false);
        listSSPApplicationIndividual[0].SSP_Application__c = app1.Id;
        listSSPApplicationIndividual[0].SSP_Member__c = listSSPMember[0].Id;
        insert listSSPApplicationIndividual;
        User citizen  = [SELECT Id,ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        mapCaseVsIndividualId.put('76590','76459');
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('individualId', '112233');
        sessionpart.put('caseVsIndividualId',JSON.serialize(mapCaseVsIndividualId),3600,Cache.Visibility.ALL,false);
        Test.startTest(); 
        ssp_application__c application=[Select name,DCCaseNumber__c, ProgramsApplied__c FROM ssp_application__c Where Id=:app1.Id];
        System.runAs(citizen){
            SSP_AgentAssistorController.triggerHBE016(application,'1344333', '1344333','HBE-016'); 
            
        }
        test.stopTest();
        
    }
     @isTest
    public static void testUpsertAgentAssister1(){
        SSP_TestDataFactory.setupTestData();
        SSP_UpdateAgentAssisterMock mock = new SSP_UpdateAgentAssisterMock();
        mock.isFailure=true;
        Test.setMock(HttpCalloutMock.class,mock);
        list<account> accs = new list<account>();
        accs.add(new account(name='test',DCDataId__c=1344333));
        accs.add(new account(name='test2'));
        insert accs;
        contact con = new contact(firstname='test',lastname='test', accountid=accs[1].id);
        con.IndividualId__c = '112233';
        insert con;
        List<SSP_Member__c> listSSPMember = SSP_TestDataFactory.createSSPMembers(1,false);
        listSSPMember[0].Contact__c = con.Id;
        listSSPMember[0].PhysicalCountyCode__c='023';
        insert listSSPMember;
        ssp_application__c app = new ssp_application__c(Account__c = accs[0].id);
        insert app;
        ssp_application__c app1 = new ssp_application__c(Account__c = accs[0].id);
        app1.DCCaseNumber__c = 112293335;
        app1.ProgramsApplied__c = 'DS';
        insert app1;
        List<SSP_ApplicationIndividual__c> listSSPApplicationIndividual = SSP_TestDataFactory.createApplicationIndividuals(1,false);
        listSSPApplicationIndividual[0].SSP_Application__c = app1.Id;
        listSSPApplicationIndividual[0].SSP_Member__c = listSSPMember[0].Id;
        listSSPApplicationIndividual[0].IsHeadOfHousehold__c=true;
        insert listSSPApplicationIndividual;

        User citizen  = [SELECT Id,ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        Contact con1 = new Contact();
        con1.Id=citizen.ContactId;
        con1.AssociatedCountyCode__c='023';
        update con1;
        System.runAs(citizen){
             SSP_AgentAssistorController.upsertAgentAssister(app1.id, con.id, 'Assister','1344333','',false);
        }
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        AccountContactRelation orgACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(citizen.ContactId,accs[0].id , false);
        orgACR.Roles = 'Assister';
        orgACR.DCContactId__c=2333773;
        listACR.add(orgACR);
        insert listACR;
        Test.startTest();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('individualId', '112233');
        System.runAs(citizen){
            SSP_AgentAssistorController.upsertAgentAssister(app1.id,citizen.ContactId, 'Assister','1344333','',true);
            SSP_AgentAssistorController.upsertAgentAssister(app.id,citizen.ContactId, 'Assister','1344333','1344333',false);
            SSP_AgentAssistorController.upsertAgentAssister(app.id, con.id, 'Assister','1344333','1344333',false);
            
        }
        System.runAs(citizen){
        }
        test.stopTest();
    }
    
    
    
    
}