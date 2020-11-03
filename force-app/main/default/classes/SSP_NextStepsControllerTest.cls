/***************************************************************************************************
*   Type        :   Controller Test Class
*   Name        :   SSP_NextStepsControllerTest
*   Create By   :   Samridh Manucha
*   Create Date :   JAN-29-2020
*   Description :   Test class for SSP_NextStepsController.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Samridh Manucha           FEB-25-2020             Initial Version
*
*****************************************************************************************************/
@isTest(seeAllData=false)
public class SSP_NextStepsControllerTest {            
    @isTest
    public static void unitTest1() {
    User citizen  = SSP_TestDataFactory.createPortalUser();
    string jsonData = '{"SSP_EligibilitySummary": [{"IndividualId": "999033797","ProgramCode": "MA","BenefitStatusCode": "P","BenefitBeginDate": null,"BenefitEndDate": "null" ,"EligibleForExpeditedSNAP": "1","EligibleForKIHIPP": "1","IsReferredToFFM": "Y"}]}';
    SSP_EligibilitySummaryPayloadWrapper payloadWrapper = (SSP_EligibilitySummaryPayloadWrapper)System.JSON.deserialize(jsonData, SSP_EligibilitySummaryPayloadWrapper.class);
    List<SSP_EligibilitySummaryWrapper> lstEligibilitySummary = payloadWrapper.SSP_EligibilitySummary;
        System.runAs(citizen){
        Test.startTest();
        SSP_NextStepsController.memberDataWrapper response = SSP_NextStepsController.enableNextSteps(lstEligibilitySummary, new Set<String>());        
        Test.stopTest();
        }
    }
    
    @isTest
    public static void unitTest2() {
    string jsonData = '{"EligibilitySummaryPayload": {"SSP_EligibilitySummary": [{"IndividualId": "999033797","ProgramCode": "SN","BenefitStatusCode": "P","BenefitBeginDate": null,"BenefitEndDate": "null" ,"EligibleForExpeditedSNAP": "1","EligibleForKIHIPP": "1","DenialReason": "true"}]}}';
        SSP_EligibilitySummaryPayloadWrapper payloadWrapper = (SSP_EligibilitySummaryPayloadWrapper)System.JSON.deserialize(jsonData, SSP_EligibilitySummaryPayloadWrapper.class);
        List<SSP_EligibilitySummaryWrapper> lstEligibilitySummary = payloadWrapper.SSP_EligibilitySummary;
        Test.startTest();
        SSP_NextStepsController.memberDataWrapper response = SSP_NextStepsController.enableNextSteps(lstEligibilitySummary, new Set<String>()); 
        Test.stopTest();        
    }
        
}