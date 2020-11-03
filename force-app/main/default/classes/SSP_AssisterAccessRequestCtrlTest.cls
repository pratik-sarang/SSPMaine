@isTest
private class SSP_AssisterAccessRequestCtrlTest {
    @isTest
    public static void testAssisterAccessRequestInstantiation() {
        Test.startTest();
        List<SSP_AssisterAccessRequestCtrl.CaseInfoWrapper> listCaseInfo = new List<SSP_AssisterAccessRequestCtrl.CaseInfoWrapper>();
        SSP_AssisterAccessRequestCtrl.CaseInfoWrapper newCaseInfoWrapper = new SSP_AssisterAccessRequestCtrl.CaseInfoWrapper();
        newCaseInfoWrapper.CaseNumber = '1234';
        newCaseInfoWrapper.ProgramCode = '2334';
        newCaseInfoWrapper.LastUpdatedDate = '11-07-2020';
        newCaseInfoWrapper.FirstName = 'TestFName';
        newCaseInfoWrapper.LastName = 'TestLName';
        newCaseInfoWrapper.Email = 'testRandomEmail@domain.com';
        newCaseInfoWrapper.PrimaryPhoneTypeCode = 'P';
        newCaseInfoWrapper.PrimaryPhoneNumber = '8098787688';
        newCaseInfoWrapper.PrimaryPhoneExetnsion = '022';
        newCaseInfoWrapper.SecondaryPhoneTypeCode = 'S';
        newCaseInfoWrapper.SecondaryPhoneNumber = '8098334488';
        newCaseInfoWrapper.SecondaryPhoneExtension = '022';
        newCaseInfoWrapper.PreferredWrittenLanguageCode = 'Eng';
        newCaseInfoWrapper.PreferredSpokenLanguageCode = 'Eng';
        newCaseInfoWrapper.PreferredNotificationMethodCode = 'N';
        listCaseInfo.add(newCaseInfoWrapper);

        List<SSP_AssisterAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper> listAuthrepandAssiterClientInfo = new List<SSP_AssisterAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper>();
        SSP_AssisterAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper newAuthRepAndAssiterClientInfoWrapper = new SSP_AssisterAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper();
        newAuthRepAndAssiterClientInfoWrapper.UserId = '00099878';
        newAuthRepAndAssiterClientInfoWrapper.RepresentativeRelationshipCode = 'C';
        newAuthRepAndAssiterClientInfoWrapper.ProgramsApplied = 'TestApplied';
        newAuthRepAndAssiterClientInfoWrapper.CaseNumber = '1234';
        newAuthRepAndAssiterClientInfoWrapper.PermissionLevelMedicaid = '7367489';
        newAuthRepAndAssiterClientInfoWrapper.PermissionLevelSNAP = 'TestPermissionLevelSNAP';
        newAuthRepAndAssiterClientInfoWrapper.PermissionLevelStateSupp = 'TestPermissionLevelStateSupp';
        newAuthRepAndAssiterClientInfoWrapper.PermissionLevelKIHIPP = 'TestPermissionLevelKIHIPP';
        newAuthRepAndAssiterClientInfoWrapper.PermissionLevelCCAP = 'TestPermissionLevelCCAP';
        newAuthRepAndAssiterClientInfoWrapper.PermissionLevelKTAP = 'TestPermissionLevelKTAP';
        listAuthrepandAssiterClientInfo.add(newAuthRepAndAssiterClientInfoWrapper);

        SSP_AssisterAccessRequestCtrl.ReverseSSPDCResponseWrapper reverseSSPDCResponseWrapper = new SSP_AssisterAccessRequestCtrl.ReverseSSPDCResponseWrapper();
        reverseSSPDCResponseWrapper.AuthrepandAssiterClientInfo = listAuthrepandAssiterClientInfo;
        reverseSSPDCResponseWrapper.CaseInfo = listCaseInfo;
        Test.stopTest();

        System.assertNotEquals(null, reverseSSPDCResponseWrapper);
    }
}