@isTest
public class SSP_BenefitsPageControllerTest {
    
    @testSetup static void setup() {
        insert new LOG_LogMessageSettings__c(
        Name = RE_GlobalConstants.LOGS_DEFAULT_AUTOGENERATED,
        LOG_Debug__c = true,
        LOG_Error__c= true,
        LOG_Info__c = true,
        LOG_Warning__c = true,
        LOG_Log_Purge__c = 365
        );
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'IncomeController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName, IsDashboardRefreshNeeded__c FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];			
        contact objContact = SSP_TestDataFactory.createContacts(1, false)[0];
        objContact.IndividualId__c = '434';
        objContact.IsDashboardRefreshNeeded__c=true;
        objContact.CacheBenefitProgramData__c = '[{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"TypeOfAssistanceCode":"Medicaid","SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"AP","ProgramCode":"MA","PolicyId":null,"PolicyHolderName":null,"PolicyHolderId":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":"Y","IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"ASDFAHS ASKJFHAS","IndividualId":"920068088","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"147366","EBTCardFundLoadDate":null,"DocumentDueDate":"2020-11-01","DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100072726","BenefitEndDate":"2021-07-31","BenefitBeginDate":"2020-08-01","ApplicationSubmissionDate":"2020-08-03","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null}]';					
        objContact.CacheDashboardData__c = '{"mapCaseVsStatus":{"100072726":"AP"},"mapCaseVsIndividualId":{"100072726":"920068088"},"mapCaseVsHOH":{"100072726":true},"lstRAC":["100072726"],"hasRACEnabled":true,"authRepAccessForNotices":null}';
        INSERT objContact;
    }
    
        
    @isTest
    public static void testMethod1(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        contact objContact = [SELECT Id, Name, IndividualId__c, IsDashboardRefreshNeeded__c FROM contact WHERE IndividualId__c = '434' LIMIT 1];
        System.runAs(citizen){
            test.startTest();
            	SSP_BenefitsPageController.getDashboardRefreshFlag();
            	SSP_BenefitsPageController.getBenefitsData();
            	SSP_BenefitsPageController.applicationButtonDetails();
            test.stopTest();
        }
    }
    
    @isTest
    public static void testMethod2(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        contact objContact = [SELECT Id, Name, IndividualId__c, IsDashboardRefreshNeeded__c FROM contact WHERE IndividualId__c = '434' LIMIT 1];
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        mapCaseVsStatus.put('123456','PE');
        mapCaseVsStatus.put('445566','PE');
        mapCaseVsStatus.put('445567','PE');
        mapCaseVsStatus.put('445568','PE');
        mapCaseVsStatus.put('445570','PE');
        SSP_BenefitInformationWrapper objWrapper = new SSP_BenefitInformationWrapper();
        objWrapper.ProgramCode = system.label.SSP_KTAP;
        objWrapper.CaseNumber='123456';
        objWrapper.EdgNumber='123456';

        SSP_BenefitInformationWrapper objWrapper1 = new SSP_BenefitInformationWrapper();
        objWrapper1.ProgramCode = system.label.SSP_SNAP;
        objWrapper1.CaseNumber='445566';
        objWrapper1.EdgNumber='445566';

        SSP_BenefitInformationWrapper objWrapper2 = new SSP_BenefitInformationWrapper();
        objWrapper2.ProgramCode = SSP_GlobalConstants.ChildCareAssistance;
        objWrapper2.CaseNumber='445567';
        objWrapper2.EdgNumber='445567';
        objWrapper2.ActiveEnrollmentCount='3';
        objWrapper2.PendingEnrollmentCount='0';
        objWrapper2.IndividualId='765743';

        SSP_BenefitInformationWrapper objWrapper3 = new SSP_BenefitInformationWrapper();
        objWrapper3.ProgramCode = SSP_GlobalConstants.Kinship;
        objWrapper3.CaseNumber='445568';
        objWrapper3.EdgNumber='445568';

        SSP_BenefitInformationWrapper objWrapper4 = new SSP_BenefitInformationWrapper();
        objWrapper4.ProgramCode = system.label.SSP_Medicaid;
        objWrapper4.CaseNumber='445571';
        objWrapper4.EdgNumber='445571';

        SSP_BenefitInformationWrapper objWrapper5 = new SSP_BenefitInformationWrapper();
        objWrapper5.ProgramCode = system.label.SSP_StateSupplementation;
        objWrapper5.CaseNumber='445572';
        objWrapper5.EdgNumber='445572';

        SSP_BenefitInformationWrapper objWrapper6 = new SSP_BenefitInformationWrapper();
        objWrapper6.ProgramCode = system.label.SSP_KIHIPP;
        objWrapper6.CaseNumber='445573';
        objWrapper6.EdgNumber='445573';

        List<SSP_BenefitInformationWrapper> lstbenefits= new List<SSP_BenefitInformationWrapper>();
        lstbenefits.add(objWrapper);
        lstbenefits.add(objWrapper1);
        lstbenefits.add(objWrapper2);
        lstbenefits.add(objWrapper3);
        lstbenefits.add(objWrapper4);
        lstbenefits.add(objWrapper5);
        lstbenefits.add(objWrapper6);

        Map<String,List<SSP_BenefitInformationWrapper>> mapcasevswrapper= new Map<String,List<SSP_BenefitInformationWrapper>>();
        mapcasevswrapper.put('123456',lstbenefits);
        SSP_DashboardCaseInformation.Renewal renewal= new  SSP_DashboardCaseInformation.Renewal();
        renewal.CaseNumber='123456';
        renewal.RenewalProgramCode=SSP_GlobalConstants.PROGRAM_TYPE_MA;
        renewal.RenewalDueDate='2019-11-25';
        List<SSP_DashboardCaseInformation.Renewal> lstRenewal= new List<SSP_DashboardCaseInformation.Renewal>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);
        sessionpart.put('hasMedicaidRenewals',JSON.serialize(lstRenewal),3600,Cache.Visibility.ALL,false);
        sessionpart.put('AllBenefits',JSON.serialize(mapcasevswrapper));

        System.runAs(citizen){
            //update objContact;
            test.startTest();
            	SSP_BenefitsPageController.getBenefitsData();
            test.stopTest();
        }
    }
    @isTest
    public static void testMethod3(){
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();        
        Test.setMock(HttpCalloutMock.class, mock);
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        contact objContact = [SELECT Id, Name, IndividualId__c, IsDashboardRefreshNeeded__c FROM contact WHERE IndividualId__c = '434' LIMIT 1];
        objContact.IsDashboardRefreshNeeded__c=true;
        update objContact;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'434');
        System.runAs(citizen){
            test.startTest();
            	SSP_BenefitsPageController.getWaiverProgramsData();
            test.stopTest(); 
        }
    }

    @isTest
    public static void testMethod4(){
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        mapCaseVsStatus.put('123456','PE');
        mapCaseVsStatus.put('445566','PE');
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];

        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,'Assister');
        sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'123456');
        sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);
        Contact objContact=SSP_TestDataFactory.createContactRecord('Test', 'Test', 'test@tester.com', contactRecordTypeId, false);
        objContact.IndividualId__c='123456';
        insert objContact;
        Contact contactRecord = [SELECT Id, AccountId FROM Contact where email='test@tester.com' LIMIT 1];

        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=contactRecord.AccountId;        
        lstAppln[0].Contact__c = contactRecord.Id;
        lstAppln[0].ProgramsApplied__c='SN;KT;CC;MA;SS;KP';
        lstAppln[0].Status__c='P';
        lstAppln[0].dccasenumber__c=null;
       insert lstAppln;

       
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=contactRecord.Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].IsHeadOfHousehold__c=true;
        insert lstAppInd;
            test.startTest();
            	SSP_BenefitsPageController.applicationButtonDetails();
            test.stopTest();
    }
    @isTest
    public static void testMethod5(){
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        mapCaseVsStatus.put('123456','PE');
        mapCaseVsStatus.put('445566','PE');
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];

        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,'Assister');
        sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'123456');
        //sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);
        Contact objContact=SSP_TestDataFactory.createContactRecord('Test', 'Test', 'test@tester.com', contactRecordTypeId, false);
        objContact.IndividualId__c='123456';
        insert objContact;
        Contact contactRecord = [SELECT Id, AccountId FROM Contact where email='test@tester.com' LIMIT 1];

        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=contactRecord.AccountId;        
        lstAppln[0].Contact__c = contactRecord.Id;
        lstAppln[0].ProgramsApplied__c='SN;KT;CC;MA;SS;KP';
        lstAppln[0].Status__c='P';
        lstAppln[0].dccasenumber__c=null;
       insert lstAppln;

       
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=contactRecord.Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].IsHeadOfHousehold__c=true;
        insert lstAppInd;
            test.startTest();
            	SSP_BenefitsPageController.applicationButtonDetails();
            test.stopTest();
    }

}