@isTest
private class SSP_DataContractOrgTest {
    @isTest
    public static void testDataContractOrgTest() {
		Test.startTest(); 
        
        list<SSP_DataContractOrg.SuspensionExcludedIndividual> listSusExInd = new list<SSP_DataContractOrg.SuspensionExcludedIndividual>();     
        listSusExInd.add(new SSP_DataContractOrg.SuspensionExcludedIndividual());
        SSP_DataContractOrg.ArrayOfSuspensionExcludedIndividual newArraySusExInd =  new SSP_DataContractOrg.ArrayOfSuspensionExcludedIndividual();
        newArraySusExInd.SuspensionExcludedIndividual= listSusExInd;
        
        list<SSP_DataContractOrg.SuspensionDetail> listSusDetail = new list<SSP_DataContractOrg.SuspensionDetail>();
        listSusDetail.add(new SSP_DataContractOrg.SuspensionDetail());
        SSP_DataContractOrg.ArrayOfSuspensionDetail newArray =  new SSP_DataContractOrg.ArrayOfSuspensionDetail();
        newArray.SuspensionDetail= listSusDetail; 
        
        SSP_DataContractOrg.SSPDCError sSPDCError = new SSP_DataContractOrg.SSPDCError();
        SSP_DataContractOrg.ArrayOfSSPOverPaymentDiscrepancyModel arrayOfSSPOverPaymentDiscrepancyModel = new SSP_DataContractOrg.ArrayOfSSPOverPaymentDiscrepancyModel();
        SSP_DataContractOrg.SSPOverPaymentDiscrepancyModel sSPOverPaymentDiscrepancyModel = new SSP_DataContractOrg.SSPOverPaymentDiscrepancyModel();
        SSP_DataContractOrg.MaidCardRequestModel maidCardRequestModel = new SSP_DataContractOrg.MaidCardRequestModel();
        SSP_DataContractOrg.IndividualAuthRepCreationModel individualAuthRepCreationModel = new SSP_DataContractOrg.IndividualAuthRepCreationModel();
        SSP_DataContractOrg.ArrayOfHealthScreeningModel arrayOfHealthScreeningModel = new SSP_DataContractOrg.ArrayOfHealthScreeningModel();
        SSP_DataContractOrg.AdhocSFServiceResponse adhocSFServiceResponse = new SSP_DataContractOrg.AdhocSFServiceResponse();
        SSP_DataContractOrg.WaiverScreeningRequestModel waiverScreeningRequestModel = new SSP_DataContractOrg.WaiverScreeningRequestModel();
        SSP_DataContractOrg.CardDetailsModel cardDetailsModel = new SSP_DataContractOrg.CardDetailsModel();
        SSP_DataContractOrg.NonPaymentGoodCauseModel nonPaymentGoodCauseModel = new SSP_DataContractOrg.NonPaymentGoodCauseModel();
        SSP_DataContractOrg.HealthScreeningModel healthScreeningModel = new SSP_DataContractOrg.HealthScreeningModel();
        SSP_DataContractOrg.IncarcerationSuspensionRecord incarcerationSuspensionRecord = new SSP_DataContractOrg.IncarcerationSuspensionRecord();
        SSP_DataContractOrg.AdhocServiceResponse adhocServiceResponse = new SSP_DataContractOrg.AdhocServiceResponse();
        SSP_DataContractOrg.DetailsOfIndividualToDiscontinue detailsOfIndividualToDiscontinue = new SSP_DataContractOrg.DetailsOfIndividualToDiscontinue();
        SSP_DataContractOrg.SSPOverPaymentDiscrepanciesModel sSPOverPaymentDiscrepanciesModel = new SSP_DataContractOrg.SSPOverPaymentDiscrepanciesModel();
        SSP_DataContractOrg.MyInformationRequestModel myInformationRequestModel = new SSP_DataContractOrg.MyInformationRequestModel();
        SSP_DataContractOrg.ArrayOfWaiverScreeningRequestModel arrayOfWaiverScreeningRequestModel = new SSP_DataContractOrg.ArrayOfWaiverScreeningRequestModel();
        SSP_DataContractOrg.CaseWithdrawModel caseWithdrawModel = new SSP_DataContractOrg.CaseWithdrawModel();
        SSP_DataContractOrg.AddressToUpdate addressToUpdate = new SSP_DataContractOrg.AddressToUpdate();
        SSP_DataContractOrg.ArrayOfDetailsOfIndividualToDiscontinue arrayOfDetailsOfIndividualToDiscontinue = new SSP_DataContractOrg.ArrayOfDetailsOfIndividualToDiscontinue();
        SSP_DataContractOrg.AdhocProcessingException1 adhocProcessingException1 = new SSP_DataContractOrg.AdhocProcessingException1();
        SSP_DataContractOrg.SspdcsfCommonError sspdcsfCommonError = new SSP_DataContractOrg.SspdcsfCommonError();
        SSP_DataContractOrg.DiscontinueRequestModel discontinueRequestModel = new SSP_DataContractOrg.DiscontinueRequestModel();
        SSP_DataContractOrg.PaymentEntryDetailsModel paymentEntryDetailsModel = new SSP_DataContractOrg.PaymentEntryDetailsModel();
        SSP_DataContractOrg.WaiverResponse waiverResponse = new SSP_DataContractOrg.WaiverResponse();
        SSP_DataContractOrg.GoodCauseDocumentDetails goodCauseDocumentDetails = new SSP_DataContractOrg.GoodCauseDocumentDetails();
        SSP_DataContractOrg.UnknownAddressRecord unknownAddressRecord = new SSP_DataContractOrg.UnknownAddressRecord();
        SSP_DataContractOrg.MyRewardAssignmentModel myRewardAssignmentModel = new SSP_DataContractOrg.MyRewardAssignmentModel();
        SSP_DataContractOrg.AptcCsrAmountModel aptcCsrAmountModel = new SSP_DataContractOrg.AptcCsrAmountModel();
        SSP_DataContractOrg.ArrayOfDisposedAptcCsr arrayOfDisposedAptcCsr = new SSP_DataContractOrg.ArrayOfDisposedAptcCsr();
        SSP_DataContractOrg.DisposedAptcCsr disposedAptcCsr = new SSP_DataContractOrg.DisposedAptcCsr();
        
        Test.stopTest();
    }
}