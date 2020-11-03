/*
* classname     :  SSP_MedicareCoverageSummaryTest
* @description  :  Test Class for SSP_MedicareCoverageSummary
* @author       :  Varun Kochar   
* @date         :  04/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_MedicareCoverageSummaryTest {
    @testSetup
    static void setupTestData() {
        SSP_TestDataFactory.setupTestData();  
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
            
            List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
            lstMem[0].contact__c=lstCon[0].Id; 
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
    public static void testGetMedicalCoverageSummary(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        system.runAs(citizen){
            Test.startTest();
            
            List<SSP_Benefits__c> sspBenefitList = [select Id, SSP_Member__c From SSP_Benefits__c ];
            String memberId = sspBenefitList[0].SSP_Member__c;
            SSP_LightningResponse response = SSP_MedicareCoverageSummary.getMedicalCoverageSummary(sspBenefitList[0].SSP_Member__c);
            List<SSP_MedicareCoverageSummary.MedicareCoverageSummaryWrapper> wrapper = (List<SSP_MedicareCoverageSummary.MedicareCoverageSummaryWrapper>)response.mapResponse.get('wrapper');
            system.assertEquals(1, wrapper.size());
            SSP_MedicareCoverageSummary.removeBenefit(JSON.serializePretty(wrapper[0]), memberId,'');
            SSP_MedicareCoverageSummary.getMedicalCoverageSummary(memberId);
            
            SSP_MedicareCoverageSummary.removeBenefit(null, memberId,'');
            SSP_MedicareCoverageSummary.getMedicalCoverageSummary(null);
            String dummyMemberId = '123';
            SSP_MedicareCoverageService.getBenefit(new Set<String>{dummyMemberId});
            SSP_MedicareCoverageService.getMember(new Set<String>{dummyMemberId});
            Test.stopTest();
            
        }
    }
}
