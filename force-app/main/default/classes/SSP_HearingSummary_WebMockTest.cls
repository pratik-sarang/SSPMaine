@isTest
public class SSP_HearingSummary_WebMockTest implements WebServiceMock {
    public String testSenario;
    public SSP_HearingSummary_WebMockTest(string testSenario){
        this.testSenario=testSenario;
            
    }
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType) {
        
        SSP_Hearing_TempPuri.CitizenHearingViewDetailsResponse_element objResponseEle = new SSP_Hearing_TempPuri.CitizenHearingViewDetailsResponse_element();
        SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse objResponse = new SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse();
        
        SSP_HearingDataContractOrg.ArrayOfDocumentsUpload DocumentsUpload= new SSP_HearingDataContractOrg.ArrayOfDocumentsUpload();
        SSP_HearingDataContractOrg.HearingAppointment HearingAppointment= new SSP_HearingDataContractOrg.HearingAppointment();
        SSP_HearingDataContractOrg.ArrayOfHearingHistory HearingHistoryList= new SSP_HearingDataContractOrg.ArrayOfHearingHistory();
        SSP_HearingDataContractOrg.HearingSummary HearingSummary= new SSP_HearingDataContractOrg.HearingSummary();
        SSP_HearingDataContractOrg.ArrayOfNegativeActionDocuments NegativeActionDocuments= new SSP_HearingDataContractOrg.ArrayOfNegativeActionDocuments();
        SSP_HearingDataContractOrg.ArrayOfPartiesInvolved PartiesInvolved= new SSP_HearingDataContractOrg.ArrayOfPartiesInvolved();
        SSP_HearingDataContractOrg.PrehearingAppointment PrehearingAppointment= new SSP_HearingDataContractOrg.PrehearingAppointment();
        String errorCode=null;
        if(testSenario=='Positive'){

           
        
        SSP_HearingDataContractOrg.DocumentsUpload d1= new SSP_HearingDataContractOrg.DocumentsUpload();
        d1.DateOfUplaod=System.today();
        d1.DmsDocumentId='ajsfh73irwqy893dsjafdja';
        d1.DocumentName='Filename.jpg';
        d1.DocumentType='D165';
        d1.UploadedBy='test@test.com';
        system.debug('@CS DocumentsUpload '+d1);
        SSP_HearingDataContractOrg.DocumentsUpload[] docUpload= new SSP_HearingDataContractOrg.DocumentsUpload[]{d1};
        DocumentsUpload.DocumentsUpload=docUpload;
        
        HearingAppointment.ConferenceLine='Test';
        HearingAppointment.HearingDate=String.valueOf(System.today());
        HearingAppointment.HearingParticipantCode='134234';
        HearingAppointment.Location='Office';
        HearingAppointment.MeetingType='Meeting';
        HearingAppointment.TimeOfHearing=String.valueOf(System.today());
        
        SSP_HearingDataContractOrg.HearingHistory h1= new SSP_HearingDataContractOrg.HearingHistory();
        h1.HearingHistoryAction='Hearing withdraw requested';
        h1.HearingHistoryActionBy='Owner';
        h1.HearingHistoryDate=System.today();
        SSP_HearingDataContractOrg.HearingHistory[] HearingHist= new SSP_HearingDataContractOrg.HearingHistory[]{h1};
        HearingHistoryList.HearingHistory=HearingHist;
        
        HearingSummary.CaseName='test';
        HearingSummary.CaseNumber=123;
        HearingSummary.HearingDate='test';
        HearingSummary.HearingDelayReason='test';
        HearingSummary.HearingId='12342342';
        HearingSummary.HearingOfficer='test';
        HearingSummary.HearingProgram='test';
        HearingSummary.HearingReason='test';
        HearingSummary.HearingStatus='test';
        HearingSummary.HearingType='test';
        HearingSummary.IndividualId=123;
        HearingSummary.Requester='test';
        SSP_HearingDataContractOrg.NegativeActionDocuments n1= new SSP_HearingDataContractOrg.NegativeActionDocuments();
        n1.NegativeDmsDocumentId='test';
        n1.NegativeDocumentName='test.pdf';
        n1.NegativeDocumentType='test';
        n1.NegativeSentDate=system.today();
        SSP_HearingDataContractOrg.NegativeActionDocuments[] NegativeActionDocs= new SSP_HearingDataContractOrg.NegativeActionDocuments[]{n1};
        NegativeActionDocuments.NegativeActionDocuments=NegativeActionDocs;
        SSP_HearingDataContractOrg.PartiesInvolved p1= new SSP_HearingDataContractOrg.PartiesInvolved();
        p1.CompanyName='test';
        p1.ContactName='test';
        p1.Email='test';
        p1.PhoneNumber='test';
        p1.Role='test';
        SSP_HearingDataContractOrg.PartiesInvolved[] PartiesInvol= new SSP_HearingDataContractOrg.PartiesInvolved[]{p1};
        
        PartiesInvolved.PartiesInvolved=PartiesInvol;
        
        PrehearingAppointment.ConferenceLine='test';
        PrehearingAppointment.Location='test';
        PrehearingAppointment.MeetingType='test';
        PrehearingAppointment.PrehearingDate='test';
        PrehearingAppointment.PrehearingParticipantCode='test';
        PrehearingAppointment.Prehearingtime='test';
        errorCode=null;
        }
        if(testSenario=='Negative'){
            errorCode='Error';
        }
        
        system.debug('@CS objResponse '+objResponse);
        objResponse.DocumentsUpload=DocumentsUpload;
        objResponse.HearingAppointment=HearingAppointment;
        objResponse.HearingHistoryList=HearingHistoryList;
        objResponse.HearingSummary=HearingSummary;
        objResponse.NegativeActionDocuments=NegativeActionDocuments;
        objResponse.PartiesInvolved=PartiesInvolved;
        objResponse.PrehearingAppointment=PrehearingAppointment;
        objResponse.ErrorLogCode=errorCode;
        objResponseEle.CitizenHearingViewDetailsResult = objResponse;
        response.put('response_x',objResponseEle);
    }
    
}