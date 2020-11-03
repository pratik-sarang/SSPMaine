/*
* classname         : SSP_SignaturePageCtrlTest
* @description      : This is the Test class for SSP_SignaturePageCtrl class.
* @author           : Sai Kiran.
* @date             : 02/27/2019.
* MODIFICATION LOG  :
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest
public class SSP_SignaturePageCtrlTest {
    
    @testSetup static void testSetUpData() {
        SSP_TestDataFactory.setupTestData();
        SSP_TestDataFactory.setUpNonCitizenUser();
        
        RecordType objRecordTypeForAccount = GeneralUtility.fetchRecordType('Citizen', 'Account');
        RecordType objRecordTypeForContact = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'EnrollmentDetail';
        lstAcc[0].RecordTypeId = objRecordTypeForAccount.id;
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        /*List<Contact> lstCon = SSP_TestDataFactory.createContacts(1, false);
        lstCon[0].FirstName='Test Contact';
        lstCon[0].LastName=' Contact';
        lstCon[0].Email='Test@gmail.com';
        lstCon[0].RecordTypeId = objRecordTypeForContact.Id;
        lstCon = ESAPI.accessController().insertAsUser(lstCon, SSP_Utility.getFieldsNamesList (lstCon)).getInsertedObjects();*/
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;
        lstAppln[0].SSPDCMessage__c='P';
        lstAppln[0].IsApplicantAuthorizedRepresentative__c = 'Y';
        lstAppln[0].ProgramsApplied__c = 'MA;SN';
        lstAppln[0].SectionStatus__c='{"Intake":{"SSP_APP_ProgramSelection":"COMPLETED","SSP_APP_HHMembersSummary":"COMPLETED"}}';
        //lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].HouseholdTotalMonthlyCashSavingAmount__c=null;
        lstAppln[0].IsDestituteFarmOrMigrantHouseholdToggle__c=null;
        lstAppln[0].HouseholdTotalMonthlyGrossIncAmount__c=null;
        lstAppln[0].HasShelterExpExceedIncomeResourcesToggle__c=null;   
        
         
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(2, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].FirstName__c ='Chris';
        lstMem[0].LastName__c ='John';
        lstMem[0].MiddleInitial__c ='W';
        lstMem[0].SuffixCode__c ='SR';
        lstMem[0].LaTypeCode__c ='BW';
        lstMem[1].contact__c=lstCon[0].Id;  
        lstMem[1].PrimaryPhoneExtension__c ='7348789790';
        lstMem[1].PrimaryPhoneNumber__c ='8983838290';
        lstMem[1].PrimaryPhoneExtension__c ='7348789790';
        lstMem[1].FirstName__c ='John';
        lstMem[1].LastName__c ='Deo';
        lstMem[1].MiddleInitial__c ='K';
        lstMem[1].SuffixCode__c ='JR';
        lstMem[1].LaTypeCode__c ='HS';
        lstMem[1].SSNVerified__c =true;
        lstMem[1].IsMigrantOrSeasonalFarmWorkerToggle__c='NO';
        
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(2, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[1].Id;
        lstAppInd[0].MedicaidType__c = 'Non-MAGI';
        lstAppInd[0].ProgramsApplied__c='SN';
        lstAppInd[1].IsHeadOfHousehold__c = true;
        lstAppInd[1].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[1].SSP_Member__c=lstMem[0].Id;
        lstAppInd[1].MedicaidType__c = 'Non-MAGI';
        lstAppInd[1].ProgramsApplied__c='SN';
        
        SSP_Asset__c ast = new SSP_Asset__c();
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();
        
        NavFlowStatus__c objNavFlowList = new NavFlowStatus__c();
        objNavFlowList.NavFlowName__c = 'ContactInformation';
        objNavFlowList.FlowDupStatus__c = 'CN';
        objNavFlowList.FlowPageStatus__c = 'CN';
        objNavFlowList.SSPApplication__c = lstAppln[0].Id;
        insert objNavFlowList;
        SSP_Relationship__c objRelationship = new SSP_Relationship__c();
        objRelationship.SSP_Member__c = lstMem[0].Id;
        objRelationship.SSP_MemberRelatedTo__c = lstMem[1].Id;
        objRelationship.RelationshipType__c = 'SP';
        objRelationship = (SSP_Relationship__c)ESAPI.accessController().insertAsUser(new List<SSP_Relationship__c>{objRelationship}, SSP_Utility.getFieldsNamesList (new List<SSP_Relationship__c>{objRelationship})).getInsertedObjects()[0];       

        RecordType objAccountRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'Citizen' AND SobjectType = 'Account' LIMIT 1];
        RecordType objContactRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'Citizen' AND SobjectType = 'Contact' LIMIT 1];
        
        
        List<Account> lstAcc1 = SSP_TestDataFactory.createAccounts(2, false);
        lstAcc1[0].Name = 'IncomeController';
        lstAcc1[0].DCDataId__c=1001;
        lstAcc1[1].Name = 'NewAccountController';
        lstAcc1[1].DCDataId__c=1002;
        insert lstAcc1;
        
        List<Contact> lstCon1 = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'NonCitizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        
        AccountContactRelation acr1 = new AccountContactRelation(); 
        acr1.Accountid = lstAcc1[0].Id;
        acr1.Contactid = lstCon1[0].Id;
        acr1.IsActive = true;
        
        insert acr1;
        
        List<SSP_Application__c> lstAppln1 = SSP_TestDataFactory.createSSPApplications(2, false);
        lstAppln1[0].Account__c=lstAcc1[0].Id;        
        lstAppln1[0].Contact__c = lstCon1[0].Id;
        lstAppln1[0].ProgramsApplied__c = 'MA;KT;SN';
        lstAppln1[1].Account__c=lstAcc1[1].Id;        
        lstAppln1[1].Contact__c = lstCon1[0].Id;
        lstAppln1[1].ProgramsApplied__c = 'MA;KT;SN';
        insert lstAppln1;
        
        
        List<SSP_Member__c> lstMem1 = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem1[0].contact__c=lstCon1[0].Id;
        lstMem1[0].firstName__c='FirstName';
        lstMem1[0].lastName__c='LastName'    ;
        lstMem1[0].GenderCode__c='M';
        lstMem1[0].BirthDate__c=system.today();
        lstMem1[0].IndividualId__c='565756';
        lstMem1[0].MailingAddressLine1__c='1 Street';
        lstMem1[0].MailingCity__c='Frankfort';
        lstMem1[0].MailingStateCode__c='KY';
        lstMem1[0].MailingZipCode5__c='40601';
        lstMem1[0].MailingZipCode4__c='4231';
        lstMem1[0].PrimaryPhoneNumber__c='555-555-5555';
        //Pooja P
        lstMem1[0].Reference_Number__c = '12345434712345';
        lstMem1[0].Identify_verification_method__c='Resume RIDP';
        lstMem1[0].Non_Citizen_Verification_Flag__c=false;
        lstMem1[0].IndividualId__c='1235';
        insert lstMem1;
        
        List<SSP_ApplicationIndividual__c> lstAppInd1 = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd1[0].SSP_Application__c=lstAppln1[0].Id;
        lstAppInd1[0].IsHeadOfHousehold__c =true;
        lstAppInd1[0].SSP_Member__c=lstMem1[0].Id;
        lstAppInd1[0].MemberProgramsApplied__c='SN;MA;KT';
        insert lstAppInd1; 
        
        AppConfig__c timeFormat = new AppConfig__c();
        timeFormat.Name='timeFormat';
        timeFormat.Value__c='yyyy-MM-dd HH:mm:s';
        AppConfig__c timeZone = new AppConfig__c();
        timeZone.Name='timeZone';
        timeZone.Value__c='America/New_York';
        List<AppConfig__c> lstAppConfig = new List<AppConfig__c>();
        lstAppConfig.add(timeFormat);
        lstAppConfig.add(timeZone);
        insert lstAppConfig;
        
        List<SSP_Asset__c> lstAsset = SSP_TestDataFactory.createAssets(6, 'Income',false);
        lstAsset[0].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income'); 
        lstAsset[0].SSP_Member__c = lstMem[0].Id;
        lstAsset[0].IncomeTypeCode__c ='DIR';
        lstAsset[0].IncomePayFrequency__c = SSP_GlobalConstants.Monthly;
        
        lstAsset[1].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[1].SSP_Member__c = lstMem[0].Id;
        lstAsset[1].IncomeTypeCode__c ='UI';
        lstAsset[1].IncomePayFrequency__c = SSP_GlobalConstants.BI_Weekly; 
        
        lstAsset[2].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[2].SSP_Member__c = lstMem[0].Id;
        lstAsset[2].IncomeTypeCode__c ='EA';
        lstAsset[2].IncomePayFrequency__c = SSP_GlobalConstants.TWICEAMONTH;
        
        lstAsset[3].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[3].SSP_Member__c = lstMem[0].Id;
        lstAsset[3].IncomeTypeCode__c ='SE';
        lstAsset[3].IncomePayFrequency__c = SSP_GlobalConstants.Week;
        
        lstAsset[4].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[4].SSP_Member__c = lstMem[0].Id;
        lstAsset[4].IncomeTypeCode__c ='SRP';
        lstAsset[4].IncomePayFrequency__c = SSP_GlobalConstants.Yearly;
        
        lstAsset[5].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[5].SSP_Member__c = lstMem[0].Id;
        lstAsset[5].IncomeTypeCode__c ='SM';
        lstAsset[5].IncomePayFrequency__c = SSP_GlobalConstants.Quarterly;
        lstAsset = ESAPI.accessController().insertAsUser(lstAsset, SSP_Utility.getFieldsNamesList (lstAsset)).getInsertedObjects();
        
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    @isTest
    public static void fetchResponseDataTest(){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        for(SSP_ApplicationIndividual__c objApplicationIndividual : objApp.SSP_ApplicationIndividuals__r){
            objApplicationIndividual.MedicaidType__c = 'Non-MAGI';
            lstAppInd.add(objApplicationIndividual);
        }
        lstAppInd[0].IsHeadOfHousehold__c = true;
        update lstAppInd;
        objResponse = SSP_SignaturePageCtrl.fetchResponseData(objApp.Id);
        objResponse = SSP_SignaturePageCtrl.fetchResponseData(null);
    }
    
     @isTest
    public static void fetchResponseDataTest4(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE, SSP_GlobalConstants.ORGANISATION_AUTH_REP);
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        for(SSP_ApplicationIndividual__c objApplicationIndividual : objApp.SSP_ApplicationIndividuals__r){
            objApplicationIndividual.MedicaidType__c = 'Non-MAGI';
            lstAppInd.add(objApplicationIndividual);
        }
        lstAppInd[0].IsHeadOfHousehold__c = true;
        update lstAppInd;
            objResponse = SSP_SignaturePageCtrl.fetchResponseData(objApp.Id);
            objResponse = SSP_SignaturePageCtrl.fetchResponseData(null);
    }
    
    @isTest
    public static void updateAgencyIdTest(){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        for(SSP_ApplicationIndividual__c objApplicationIndividual : objApp.SSP_ApplicationIndividuals__r){
            objApplicationIndividual.MedicaidType__c = 'Non-MAGI';
            lstAppInd.add(objApplicationIndividual);
        }
        lstAppInd[0].IsHeadOfHousehold__c = true;
        update lstAppInd;
        objResponse = SSP_SignaturePageCtrl.fetchResponseData(objApp.Id);
        objResponse = SSP_SignaturePageCtrl.fetchResponseData(null);
    }
    @isTest
    public static void fetchResponseDataTest1(){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        objResponse = SSP_SignaturePageCtrl.fetchResponseData(objApp.Id);
    }
    
     @isTest
    public static void fetchResponseDataTest2(){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE username = 'citizen@abc.xyz'];
        system.runAs(fetchedPortalUser)
        {
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        objResponse = SSP_SignaturePageCtrl.fetchResponseData(objApp.Id);
        }
    }
    
    @isTest
    public static void fetchCustomSettingsTest(){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        AppConfig__c timePeriod = new AppConfig__c();
        AppConfig__c timeInterval = new AppConfig__c();
        timePeriod.Name='timePeriod';
        timePeriod.Value__c='1200';
        timeInterval.Name='timeInterval';
        timeInterval.Value__c='2000';
        AppConfig__c timeFormat = new AppConfig__c();
        timeFormat.Name='timeFormat';
        timeFormat.Value__c='yyyy-MM-dd HH:mm:s';
        AppConfig__c timeZone = new AppConfig__c();
        timeZone.Name='timeZone';
        timeZone.Value__c='America/New_York';
        List<AppConfig__c> lstAppConfig = new List<AppConfig__c>();
        lstAppConfig.add(timePeriod);
        lstAppConfig.add(timeInterval);
        lstAppConfig.add(timeFormat);
        lstAppConfig.add(timeZone);
        insert lstAppConfig;
        objResponse = SSP_SignaturePageCtrl.fetchCustomSettings();
    }
    
    @isTest
    public static void fetchApplicationStatusTest(){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        objResponse = SSP_SignaturePageCtrl.fetchApplicationStatus(objApp.Id);
    }

    @isTest
    public static void sspDCServiceCallErrorTest(){
        Test.setMock(HttpCalloutMock.class, new SSP_SSPDCIntegrationServiceMock(200)); 
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,SectionStatus__c,SignatureDate__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        objApp.SignatureDate__c = System.today();
        update objApp;
        Test.startTest();
        objResponse = SSP_SignaturePageCtrl.sspDCServiceCall(objApp.Id,'Intake');
        Test.stopTest();
    }    
    @isTest
    public static void sspDCServiceCallTest(){
        Test.setMock(HttpCalloutMock.class, new SSP_SSPDCIntegrationServiceMock(200)); 
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        List<PageInfo__mdt> metaPage = (List<PageInfo__mdt>)JSON.deserialize('[{"PageName__c":"Test1"},{"PageName__c":"Test2"}]', List<PageInfo__mdt>.class);
        List<NavFlowDetail__mdt> metaDetail = (List<NavFlowDetail__mdt>)JSON.deserialize('[{"FlowName__c":"ContactInformation","FlowDisplayName__c":"ContactInformation"}]', List<NavFlowDetail__mdt>.class);
        List<NavFlowPageConfig__mdt> metaConfig = (List<NavFlowPageConfig__mdt>)JSON.deserialize('[{"NavigationFlowDetail__c":'+metaDetail[0].ID+',"PageInfo__c":'+metaPage[0].ID+',"SequenceNumber__c":"1","IsActive__c":"true"},{"NavigationFlowDetail__c":'+metaDetail[0].ID+',"PageInfo__c":'+metaPage[1].ID+',"SequenceNumber__c":"2","IsActive__c":"true"}]', List<NavFlowPageConfig__mdt>.class);        
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,SectionStatus__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        for(SSP_ApplicationIndividual__c objApplicationIndividual : objApp.SSP_ApplicationIndividuals__r){
            objApplicationIndividual.MedicaidType__c = 'Non-MAGI';
            lstAppInd.add(objApplicationIndividual);
        }
        lstAppInd[0].IsHeadOfHousehold__c = true;
        update lstAppInd;
        Test.startTest();
        objResponse = SSP_SignaturePageCtrl.sspDCServiceCall(objApp.Id,'Intake');
        objApp.SectionStatus__c = '{"Renewal":{"SSP_APP_ProgramSelection":"COMPLETED","SSP_APP_HHMembersSummary":"COMPLETED"}}';
        update objApp;
        objResponse = SSP_SignaturePageCtrl.sspDCServiceCall(objApp.Id,'Renewal');
        objApp.SectionStatus__c = '{"AddRemoveMember":{"SSP_APP_HHMembersSummary":"COMPLETED"}}';
        update objApp;
        objResponse = SSP_SignaturePageCtrl.sspDCServiceCall(objApp.Id,'RAC');
        objApp.SectionStatus__c = '{"ModifyExistingData":{"SSP_APP_HHMembersSummary":"COMPLETED"}}';
        update objApp;
        objResponse = SSP_SignaturePageCtrl.sspDCServiceCall(objApp.Id,'RAC');
        Test.stopTest();
    }
    @isTest
    public static void sspVCICallTest(){        
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,SectionStatus__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        SSP_Member__c objMem = [SELECT ID, SSNVerified__c FROM SSP_Member__c Where ID =:objApp.SSP_ApplicationIndividuals__r[0].SSP_Member__c];
        objMem.SSNVerified__c = true;
        update objMem;
        objApp.ProgramsApplied__c = 'MA';
        update objApp;
        Test.startTest();
        SSP_SignaturePageCtrl.sspVCICall(objApp.Id);
        SSP_SignaturePageCtrl.sspVCICall(null);
        Test.stopTest();
    } 
    @isTest
    public static void sspNonESIMECCall(){        
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,SectionStatus__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        SSP_Member__c objMem = [SELECT ID, SSNVerified__c FROM SSP_Member__c Where ID =:objApp.SSP_ApplicationIndividuals__r[0].SSP_Member__c];
        objMem.SSNVerified__c = true;
        update objMem;
        objApp.ProgramsApplied__c = 'MA';
        update objApp;
        Test.startTest();
        SSP_SignaturePageCtrl.sspNonESIMECCall(objApp.Id);
        Test.stopTest();
    } 
    @isTest
    public static void sspNonESIMECErrorCall(){        
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,SectionStatus__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        SSP_Member__c objMem = [SELECT ID, SSNVerified__c FROM SSP_Member__c Where ID =:objApp.SSP_ApplicationIndividuals__r[0].SSP_Member__c];
        objMem.SSNVerified__c = true;
        objMem.IndividualId__c = '5432345';
        update objMem;
        objApp.ProgramsApplied__c = 'MA';
        update objApp;
        Test.startTest();
        SSP_SignaturePageCtrl.sspNonESIMECCall(objApp.Id);
        Test.stopTest();
    } 
    @isTest
    public static void sspAVSCall(){
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();        
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,SectionStatus__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        SSP_Member__c objMem = [SELECT ID, SSNVerified__c FROM SSP_Member__c Where ID =:objApp.SSP_ApplicationIndividuals__r[0].SSP_Member__c];
        objMem.SSNVerified__c = true;
        objMem.BirthDate__c = Date.newInstance(1990, 12, 9);
        update objMem;
        objApp.ProgramsApplied__c = 'MA';
        update objApp;
        for(SSP_ApplicationIndividual__c objApplicationIndividual : objApp.SSP_ApplicationIndividuals__r){
            objApplicationIndividual.MedicaidType__c = 'Non-MAGI';
            lstAppInd.add(objApplicationIndividual);
        }
        update lstAppInd;
        Test.startTest();
        SSP_SignaturePageCtrl.sspAVSCall(objApp.Id);
        SSP_SignaturePageCtrl.sspAVSCall(null);
        Test.stopTest();
    } 
    @isTest
    public static void sspAHIall(){        
        SSP_Application__c objApp = [SELECT ID,ProgramsApplied__c,SectionStatus__c,(Select ID,SSP_Member__c,MedicaidType__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r) FROM SSP_Application__c Limit 1];
        SSP_Member__c objMem = [SELECT ID, SSNVerified__c FROM SSP_Member__c Where ID =:objApp.SSP_ApplicationIndividuals__r[0].SSP_Member__c];
        objMem.SSNVerified__c = true;
        objMem.TaxFilerStatusCurrentYear__c = 'SI';
        update objMem;
        objApp.ProgramsApplied__c = 'MA';
        update objApp;
        Test.startTest();
        SSP_SignaturePageCtrl.sspAHICall(objApp.Id,'Intake');
        Test.stopTest();
    }
     @isTest
    public static void fetchTimingTest(){
        AppConfig__c getTimeZone = new AppConfig__c();
        AppConfig__c getTimeFormat = new AppConfig__c();
        getTimeZone.Name='timeZone';
        getTimeZone.Value__c='America/New_York';
        getTimeFormat.Name='timeFormat';
        getTimeFormat.Value__c='yyyy-MM-dd HH:mm:ss';
        List<AppConfig__c> lstAppConfig = new List<AppConfig__c>();
        lstAppConfig.add(getTimeZone);
        lstAppConfig.add(getTimeFormat);
        insert lstAppConfig;
        Test.startTest();
        SSP_SignaturePageService.fetchTiming();
        Test.stopTest();
    }
    public class SSP_SSPDCIntegrationServiceMock implements HttpCalloutMock{
        public Integer statusCode;
        public SSP_SSPDCIntegrationServiceMock(Integer statusCode){
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(this.statusCode);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =   '    {    '+
                                '    "SubmitApplicationResponse": {    '+
                                '    "AckResponse": {    '+
                                '    "AckResponseCode": "INT0000",    '+
                                '    "AckResponseDescription": "Success"    '+
                                '    }    '+
                                '    }    '+
                                '    }    ';
    }

}