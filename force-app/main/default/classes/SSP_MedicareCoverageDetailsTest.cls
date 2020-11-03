/*
* classname     :  SSP_MedicareCoverageDetails
* @description  :  Test Class for SSP_MedicareCoverageDetailsTest
* @author       :  Varun Kochar   
* @date         :  04/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_MedicareCoverageDetailsTest {
    @testSetup
    static void setupTestData() {
        SSP_TestDataFactory.setupTestData();  
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
            
            List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
            lstMem[0].contact__c=lstCon[0].Id; 
            lstMem[0].IsReceivingMedicareBenefitToggle__c = 'N';
            insert lstMem;
            String benefitRecordtypeId = Schema.SObjectType.SSP_Benefits__c.getRecordTypeInfosByDeveloperName().get(SSP_GlobalConstants.MEDICAREBENEFIT).getRecordTypeId();
            List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
            SSP_Benefits__c sspBenefits = new SSP_Benefits__c();
            sspBenefits.SSP_Member__c = lstMem[0].Id;
            sspBenefits.Name = 'Benefit Name';
            sspBenefits.BenefitInfoCounty__c = '1';
            sspBenefits.State__c = 'AL';
            sspBenefits.BenefitPrograms__c = 'MA';
            sspBenefits.BeginDate__c = System.today();
            sspBenefits.EndDate__c = System.today().addMonths(1);
            sspBenefits.RecordTypeId = benefitRecordtypeId;
            lstBenefits.add(sspBenefits);
            insert lstBenefits;
        }
    }
    @isTest
    public static void testGetMedicalCoverageDetail(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        system.runAs(citizen){
            Test.startTest();
            List<SSP_Benefits__c> sspBenefitList = [select Id, SSP_Member__c,SSP_Member__r.IsReceivingMedicareBenefitToggle__c From SSP_Benefits__c ];
            SSP_LightningResponse response = SSP_MedicareCoverageDetails.getMedicalCoverageDetail(sspBenefitList[0].Id, sspBenefitList[0].SSP_Member__c);
            SSP_MedicareCoverageDetails.SSP_MedicareCoverageDetailsWrapper wrapper  = (SSP_MedicareCoverageDetails.SSP_MedicareCoverageDetailsWrapper) response.mapResponse.get('wrapper');
            SSP_MedicareCoverageDetails.getMedicalCoverageDetail(null, sspBenefitList[0].SSP_Member__c);
            SSP_MedicareCoverageDetails.saveMedicalCoverageDetail(sspBenefitList[0], sspBenefitList[0].SSP_Member__c);
            SSP_MedicareCoverageDetails.getMedicalCoverageDetail(null, null);
            SSP_MedicareCoverageDetails.getMedicalCoverageDetail(null, '123443');
            SSP_MedicareCoverageDetails.saveMedicalCoverageDetail(null, null);
            SSP_MedicareCoverageDetails.saveMedicalCoverageDetail(null, '123454');
            SSP_MedicareCoverageDetails.saveMedicalCoverageDetail(new SSP_Benefits__c(), null);
            system.assertEquals(sspBenefitList[0].Id, wrapper.benefit.Id);
            Test.stopTest();
            
        }
    }
}