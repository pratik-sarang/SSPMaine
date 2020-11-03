/*
* classname     :  SSP_WaiverControllerTest
* @description  :  Test Class for SSP_WaiverController
* @author       :  Kireeti Gora   
* @date         :  05/30/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

*/
@isTest(seeAllData=false)
public class SSP_WaiverControllerTest {
    
    
    /**
	@author : Kireeti Gora
	Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);   
        List<SSP_BenefitInformationWrapper> lstBenefits=  new  List<SSP_BenefitInformationWrapper>();
        SSP_BenefitInformationWrapper  objBenefit = new SSP_BenefitInformationWrapper();
        objBenefit.ProgramCode = system.label.SSP_Medicaid;
        objBenefit.IndividualId = '123456789';
        objBenefit.CaseNumber='445567';
        objBenefit.EdgNumber='445567';
        objBenefit.ActiveEnrollmentCount='3';
        objBenefit.PendingEnrollmentCount='0';
        lstBenefits.add(objBenefit);
        SSP_BenefitInformationWrapper  objBenefit1 = new SSP_BenefitInformationWrapper();
        objBenefit1.ProgramCode = system.label.SSP_KTAP;
        lstBenefits.add(objBenefit1);
        SSP_BenefitInformationWrapper  objBenefit2 = new SSP_BenefitInformationWrapper();
        objBenefit2.ProgramCode = system.label.SSP_SNAP;
        lstBenefits.add(objBenefit2);
        SSP_BenefitInformationWrapper  objBenefit3 = new SSP_BenefitInformationWrapper();
        objBenefit3.ProgramCode = system.label.SSP_KIHIPP;
        lstBenefits.add(objBenefit3);
        SSP_BenefitInformationWrapper  objBenefit4 = new SSP_BenefitInformationWrapper();
        objBenefit4.ProgramCode = system.label.SSP_ChildCareAssistance;
        lstBenefits.add(objBenefit4);
        SSP_BenefitInformationWrapper  objBenefit5 = new SSP_BenefitInformationWrapper();
        objBenefit5.ProgramCode = system.label.SSP_StateSupplementation;
        lstBenefits.add(objBenefit5);
        
        
        sessionPart.put('AllBenefits',JSON.serialize(new Map<String, List<SSP_BenefitInformationWrapper>>{'987654321'=>lstBenefits}));
        
        Cache.SessionPartition sessionPart1 = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        list<SSP_BenefitsPageController.waiverDetailsFormattedWrapper> listWaiverDetailsFormattedWapper = new list<SSP_BenefitsPageController.waiverDetailsFormattedWrapper>();
        SSP_BenefitsPageController.waiverDetailsFormattedWrapper sspWaiverDetailRecord  = new SSP_BenefitsPageController.waiverDetailsFormattedWrapper();
        sspWaiverDetailRecord.fullName='Test';
        sspWaiverDetailRecord.individualId='123456789';
        sspWaiverDetailRecord.atleastOneAnsweredYes=false;
        listWaiverDetailsFormattedWapper.add(sspWaiverDetailRecord);
        Map<String,SSP_BenefitsPageController.waiverDetailsFormattedWrapper> objMap  = new Map<String,SSP_BenefitsPageController.waiverDetailsFormattedWrapper>();
        objMap.put('123456789',sspWaiverDetailRecord);
        sessionPart1.put('mapWaiverDetails',objMap);
        system.debug('@@@@mapWaiverDetails'+sspWaiverDetailRecord);
        
        Cache.SessionPartition sessionPart2 = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper> listWaiverStatusWRapper = new List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>();
        SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper objOfWaiverStatusesWrapper = new SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper();
        objOfWaiverStatusesWrapper.WavierCaseNumber='987654321';
        objOfWaiverStatusesWrapper.WaiverCaseStatus='12345678';
        objOfWaiverStatusesWrapper.ProgramStatusCode='EN';
        objOfWaiverStatusesWrapper.ProgramCode='MA';
        objOfWaiverStatusesWrapper.IndividualId='123456789';
        objOfWaiverStatusesWrapper.ApplicationNumber='1234567';
        objOfWaiverStatusesWrapper.ApplicationStatus='COM';
        objOfWaiverStatusesWrapper.IndividualName='Testing';
        listWaiverStatusWRapper.add(objOfWaiverStatusesWrapper);
        Map<string,List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>> mapOfWaiverStatusWapper = new map<string,List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>>();
        mapOfWaiverStatusWapper.put('123456789',listWaiverStatusWRapper);
        sessionPart2.put('mapWaiverStatus', mapOfWaiverStatusWapper);
        
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        mapCaseVsStatus.put('123456','PE');
        mapCaseVsStatus.put('445566','PE');
        
        sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'999034362');
        sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'IncomeController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false);
        contact objContact = SSP_TestDataFactory.createContacts(1, false)[0];
        objContact.IndividualId__c = '434';      
        
       // objContact.IsDependentOnVentilator__c = 'Y';
        //objContact.doesRequireAssistanceToRemainHome__c = 'Y';
        //objContact.DoesHaveIntellectualDisability__c = 'Y';
       // objContact.wouldLikeToContinueReceivingServices__c = 'Y';
        INSERT objContact;
        
        
       Case caseTemp = new Case();
       // caseTemp.Name = 'TestNewCase';
        caseTemp.AccountId=lstAcc[0].Id;
        caseTemp.ContactId=objContact.Id;
        caseTemp.Status = 'New';
        caseTemp.Origin ='Email';
        insert caseTemp;
        
       
    }
    /**
	@author : Kireeti Gora
	Method to setup test Waiver Methods*/
    @isTest
    public static void test_WaiverMethods(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        contact objContact = [SELECT Id,
                             Name,IndividualId__c FROM contact WHERE IndividualId__c = '434' LIMIT 1];
        System.runAs(citizen){           
            test.startTest();           
            list<SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper> listofWaiverWrapper = new list<SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper>();
            SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper wrapWaiver = new SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper();
            wrapWaiver.IndividualId='434';
            wrapWaiver.WaiverScreeningId='12345';
            wrapWaiver.IndividualName='testing';
            wrapWaiver.HasBrainInjury='Y';
            wrapWaiver.IsVentilatorDependent='Y';
             wrapWaiver.RequireAssistance='Y';
            wrapWaiver.HasDevelopmentalDisability='Y';
            wrapWaiver.WillContinueServices='Y' ;
            listofWaiverWrapper.add(wrapWaiver);
            
            SSP_LightningResponse resultMap=ssp_waiverController.getWaiverScreeningDetails(objContact.Id);
            SSP_LightningResponse resultMap1=ssp_waiverController.getWaiverScreeningDetails(null);
            SSP_LightningResponse result = ssp_waiverController.triggerWaiverScreening(JSON.serialize(wrapWaiver));
            SSP_LightningResponse resultExpection = ssp_waiverController.triggerWaiverScreening('null');
            SSP_LightningResponse checkIfIndividualApplicableForWaiver = ssp_waiverController.checkIfIndividualApplicableForWaiver('123456789', '987654321');
            SSP_LightningResponse checkIfIndividualApplicableForWaiver1 = ssp_waiverController.checkIfIndividualApplicableForWaiver('null', 'null');
            SSP_LightningResponse result1 = ssp_waiverController.triggerWaiverTokenGeneration('1234567','434','test', '1234', '123',null);
            SSP_LightningResponse result2 = ssp_waiverController.triggerWaiverTokenGeneration('1234567','434','test', '1234', '123','CAPACITY_MANAGEMENT_ADMINISTRATOR');
            SSP_LightningResponse result3 = ssp_waiverController.triggerWaiverTokenGeneration('1234567','434','test', 'DSH_020', '123','CAPACITY_MANAGEMENT_ADMINISTRATOR');
            SSP_LightningResponse result4 = ssp_waiverController.triggerWaiverTokenGeneration('1234567','434','test', 'APP_004', '123','CAPACITY_MANAGEMENT_ADMINISTRATOR');
            system.assertNotEquals(resultMap, null);
            
            test.stopTest();
        }
    }
    
    
    
    
}