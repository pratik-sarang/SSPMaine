@isTest(seeAllData=false)
public class SSP_DiscontinueBenefitsControllerTest {
    @TestSetup static void setup() { 
    	SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'NonCitizenUser';
        lstAcc[0].caseNumber__c = '890';
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        lstCon[0].IndividualId__c='999033797';
        lstCon[0].DoesCaseExistForIndividual__c=true;
        update lstCon;
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].status__c = 'P';
        lstAppln[0].RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
        lstAppln[0].LocalDCBSOffice__c = 'Kentucky';
        lstAppln[0].ProgramsApplied__c ='MA;KT;CC;SN;SS;KP';
        lstAppln[0].DCCaseNumber__c = 890;
        lstAppln[0].RAC_Selections__c='CIS_CareTaker';
        lstAppln[0].ApplicationCreationInSSP__c = system.today();
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
	@isTest
    public static void testGetActiveBenefitsDetails(){
        System.runAs(fetchCitizenUser()) {
            List<SSP_Application__c> lstAppln = [Select Id From SSP_Application__c];
            Test.startTest();
            //KTAP
            Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsActiveBenefits = new Map<String,List<SSP_BenefitInformationWrapper>>();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            SSP_BenefitInformationWrapper objWrapper = new SSP_BenefitInformationWrapper();
            objWrapper.ProgramCode = system.label.SSP_KTAP;
            objWrapper.ProgramStatusCode= SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION;
            objWrapper.IndividualName='abc';
            objWrapper.IndividualId='999033797';
            mapCaseVsActiveBenefits.put(lstAppln[0].Id,new List<SSP_BenefitInformationWrapper>{objWrapper});
            sessionpart.put('AllBenefits',JSON.serialize(mapCaseVsActiveBenefits),3600,Cache.Visibility.ALL,false);        
            SSP_LightningResponse response = SSP_DiscontinueBenefitsController.getActiveBenefitsDetails(lstAppln[0].Id);
            System.assert(response.mapResponse.get('Benefits')!= null);
            
            //MA
            SSP_BenefitInformationWrapper objWrapper1 = new SSP_BenefitInformationWrapper();
            objWrapper1.ProgramCode = system.label.SSP_Medicaid;
            objWrapper1.ProgramStatusCode= SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION;
            objWrapper1.IndividualName='abc';
            objWrapper1.IndividualId='999033797';
            mapCaseVsActiveBenefits.put(lstAppln[0].Id,new List<SSP_BenefitInformationWrapper>{objWrapper1});        
            sessionpart.put('AllBenefits',JSON.serialize(mapCaseVsActiveBenefits),3600,Cache.Visibility.ALL,false);        
            SSP_LightningResponse response1 = SSP_DiscontinueBenefitsController.getActiveBenefitsDetails(lstAppln[0].Id);
            System.assert(response1.mapResponse.get('Benefits')!= null);
            
            //CC
            SSP_BenefitInformationWrapper objWrapper2 = new SSP_BenefitInformationWrapper();
            objWrapper2.ProgramCode = system.label.SSP_ChildCareAssistance;
            objWrapper2.ProgramStatusCode= SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION;
            objWrapper2.IndividualName='abc';
            objWrapper2.IndividualId='999033797';
            mapCaseVsActiveBenefits.put(lstAppln[0].Id,new List<SSP_BenefitInformationWrapper>{objWrapper2});        
            sessionpart.put('AllBenefits',JSON.serialize(mapCaseVsActiveBenefits),3600,Cache.Visibility.ALL,false);        
            SSP_LightningResponse response2 = SSP_DiscontinueBenefitsController.getActiveBenefitsDetails(lstAppln[0].Id);
            System.assert(response2.mapResponse.get('Benefits')!= null);
            
            //SNAP
            SSP_BenefitInformationWrapper objWrapper3 = new SSP_BenefitInformationWrapper();
            objWrapper3.ProgramCode = system.label.SSP_SNAP;
            objWrapper3.ProgramStatusCode= SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION;
            objWrapper3.IndividualName='abc';
            objWrapper3.IndividualId='999033797';
            mapCaseVsActiveBenefits.put(lstAppln[0].Id,new List<SSP_BenefitInformationWrapper>{objWrapper3});        
            sessionpart.put('AllBenefits',JSON.serialize(mapCaseVsActiveBenefits),3600,Cache.Visibility.ALL,false);        
            SSP_LightningResponse response3 = SSP_DiscontinueBenefitsController.getActiveBenefitsDetails(lstAppln[0].Id);
            System.assert(response3.mapResponse.get('Benefits')!= null);
            Test.stopTest();
        }
    }
	
    @isTest
    public static void testTriggerDiscontinueBenefitsCallout(){
       /* List<String> listIndividualId = new List<String>();
        listIndividualId.add('76512');*/

        SSP_DiscontinueBenefitsController.benfitsResponseProgramWrapper objProgWrapper = new SSP_DiscontinueBenefitsController.benfitsResponseProgramWrapper();
        objProgWrapper.Program = 'KY';
        objProgWrapper.individualId = new List<String>{'76512'};

        SSP_DiscontinueBenefitsController.benfitsResponseWrapper objBenefit = new SSP_DiscontinueBenefitsController.benfitsResponseWrapper();
        objBenefit.caseNumber ='32516';
        objBenefit.benefitIndividuals = new List<SSP_DiscontinueBenefitsController.benfitsResponseProgramWrapper>{objProgWrapper};

        String strJSONdData = JSON.serialize(objBenefit,true);
        SSP_LightningResponse response = new SSP_LightningResponse();
        SSP_LightningResponse resAct = new SSP_LightningResponse();
        SSP_DiscontinueBenefitsController.triggerDiscontinueBenefitsCallout(strJSONdData);
    }
}