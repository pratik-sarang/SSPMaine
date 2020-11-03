/*
* classname 	: SSP_EligibilityResultsCtrlTest
* @description 	: Ctrl class for eligibilty result.
* @author 		: Vishakha verma
* @date 		: Mar-11-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*  Vishakha   		Mar-11-2019		Initial Version
*/
@isTest(seeAllData=false)
public class SSP_EligibilityResultsCtrlTest {
    
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();    
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'eligibility';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        

        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].DCCaseNumber__c = Decimal.valueOf('123456789');
        lstAppln[0].ProgramsApplied__c = 'MA;KT;SN';
        lstAppln[0].SSPDCMessage__c = SSP_GlobalConstants.SSPDC_P_Message;
        insert lstAppln;
        
             
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id; 
        lstMem[0].IndividualId__c = '999033797';
        lstMem[0].FirstName__C ='Test';
        lstMem[0].LastName__C='Last';
        insert lstMem;
        
        List<SSP_Member__c> lstMem2 = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem2[0].contact__c=lstCon[0].Id; 
        lstMem2[0].IndividualId__c = '999033791';
        lstMem2[0].FirstName__C ='Test';
        lstMem2[0].LastName__C='Last';
        insert lstMem2;
        
        SSP_ApplicationIndividual__c objAppInd = new SSP_ApplicationIndividual__c();            
        objAppInd.ProgramsApplied__c='MA';
        objAppInd.MedicaidType__c='MAGI';
        objAppInd.SSP_Member__c = lstMem2[0].Id;
        objAppInd.SSP_Application__c = lstAppln[0].Id;
        objAppInd.IsHeadOfHousehold__c = true;
        insert objAppInd;
    }
    
    
     @isTest
    public static void getEligibilityDataTest(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = [SELECT Id , name , DCCaseNumber__c, SSPDCMessage__c FROM SSP_Application__c LIMIT 1];         
            Test.setMock(HttpCalloutMock.class, new SSP_DC_ReverseMockForEligibilty());  
            test.startTest();
            system.assertNotEquals(null, SSP_EligibilityResultsCtrl.getEligibilityData(lstApps[0].id));          
            lstApps[0].SSPDCMessage__c = null;
            upsert lstApps;           
            system.assertNotEquals(null, SSP_EligibilityResultsCtrl.getEligibilityData(lstApps[0].id));          
            lstApps[0].SSPDCMessage__c ='LOG1000';
            upsert lstApps;           
            system.assertNotEquals(null, SSP_EligibilityResultsCtrl.getEligibilityData(lstApps[0].id));
            test.stopTest();           
            
        }
    }
    @isTest
    public static void getEligibilityDataTest2(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest(); 
            List<SSP_Application__c> lstApps = [SELECT Id , name , DCCaseNumber__c, SSPDCMessage__c FROM SSP_Application__c LIMIT 1];         
            system.assertNotEquals(null, SSP_EligibilityResultsCtrl.getEligibilityData(lstApps[0].id));          
           test.stopTest();           
            
        }
    }

     @isTest
        public static void buildEligibilityWrapperTest(){     
             List<SSP_Application__c> lstApps = [SELECT Id , name, DCCaseNumber__c FROM SSP_Application__c LIMIT 1];
            User citizen  = SSP_TestDataFactory.createPortalUser();
            string jsonData = '{"SSP_EligibilitySummary": [{"IndividualId": "999033797","ProgramCode": "SS","BenefitStatusCode": "P","BenefitBeginDate": null,"BenefitEndDate": "2020-08-09" ,"EligibleForExpeditedSNAP": "1","EligibleForKIHIPP": "1","IsReferredToFFM": "Y"},{"IndividualId": "999033797","ProgramCode": "MA","BenefitStatusCode": "P","BenefitBeginDate": "2020-08-09","BenefitEndDate": "2020-08-09" ,"EligibleForExpeditedSNAP": "1","EligibleForKIHIPP": "1","IsReferredToFFM": "Y"}, {"IndividualId": "999033791","ProgramCode": "KT","BenefitStatusCode": null,"BenefitBeginDate": null,"BenefitEndDate": null ,"EligibleForExpeditedSNAP": "1","EligibleForKIHIPP": "1","IsReferredToFFM": "Y"}]}';
            SSP_EligibilitySummaryPayloadWrapper payloadWrapper = (SSP_EligibilitySummaryPayloadWrapper)System.JSON.deserialize(jsonData, SSP_EligibilitySummaryPayloadWrapper.class);
            List<SSP_EligibilitySummaryWrapper> lstEligibilitySummary = payloadWrapper.SSP_EligibilitySummary;
			SSP_EligibilityResultsCtrl.buildEligibilityWrapper(lstEligibilitySummary,lstApps);
        }
}