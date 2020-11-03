/*
* Classname         :  SSP_CreateHearingIntegrationServiceTest
* @description  :  This class is the test class of SSP_CreateHearingIntegrationService
* @author       :  Rijia Khatun 
* @date         :  8/3/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest
public class SSP_CreateHearingIntegrationServiceTest {
    @isTest 
    static void testCreateHearing() {
        Test.setMock(WebServiceMock.class, new SSP_CreateHearingIntegrationServiceMock());
        Test.startTest();
        SSP_ShortSnapWrapper objWap = new SSP_ShortSnapWrapper();
        objWap.SubmitType = '';
        objWap.SSP_Application = new SSP_Application__c();
        SSP_HearingDataContractOrg.CitizenHearingRequest req = new SSP_HearingDataContractOrg.CitizenHearingRequest();
        req.AccommodationList = 'IN,DI,IL';
        req.CaseName= 'CaseName';
        req.ContinueBenefits ='Y';
        req.DCCaseNumber= 100373492;
        req.DCContactId= null;
        req.RequireAccommodation = 'Y';
        req.UploadDate = system.now();
        req.DMSDocumentId= 'a0Xr00000014rqb';
        req.DMSDocumentId= '0f8fad5b-d9cb-469f-a165-70867728950e';
        req.DocumentName ='ARA';
        req.Extension = 'pdf';
        req.HealthInDanger = 'N';
        req.HearingProgram= 'MEDCD';
        req.HearingReason = 'FAILC';
        req.HearingReason = 'INCR';
        req.IndividualId = 919218728;
        req.PartyType = 'INDV';
        SSP_HearingDataContractOrg.IndividualAddress obj  = new SSP_HearingDataContractOrg.IndividualAddress();
        obj.AddressLine1 = 'ug';
        obj.AddressLine2 = 'jg';
        obj.City ='ky';
        obj.CountyCode = '056';
        obj.Email= 'test@test.com';
        obj.FirstName= 'kiieyjhe';
        obj.GenderCode= 'M';
        obj.LastName= 'evdhev';
        obj.PrimaryPhoneExtension = 10;  
        obj.PrimaryPhoneNumber= '345667898';
        obj.PrimaryPhoneTypeCode= 'CE';
        obj.StateCode= 'KY';
        obj.ZipCode5= '76543';
        req.IndividualAddress = obj;
        Map<String, Object> objReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CREATEHEARING_METADATANAME, objReq);
        System.assertEquals(1,lstData.size(),'Wrong Output');
        Test.stopTest();     
    }
    @isTest 
    static void testNegetiveCreate() {
        Test.startTest();
        SSP_HearingDataContractOrg.CitizenHearingRequest req = new SSP_HearingDataContractOrg.CitizenHearingRequest();
        Map<String, Object> objReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> null};        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CREATEHEARING_METADATANAME, objReq);
        System.assertEquals(1,lstData.size(),'Wrong Output');
        Test.stopTest();         
    }
       @isTest 
    static void testWithdrawHearing() {
        Test.setMock(WebServiceMock.class, new SSP_WithdrawHearingIntegrationSeviceMock());
        Test.startTest();
        SSP_HearingDataContractOrg.RepresentativeDetails objRepDet = new SSP_HearingDataContractOrg.RepresentativeDetails();
        objRepDet.RepresentativeAddressLine1 = '';
        objRepDet.RepresentativeAddressLine2= '';
        objRepDet.RepresentativeCity= '';
        objRepDet.RepresentativeCountry= '';
        objRepDet.RepresentativeCounty= '';
        objRepDet.RepresentativeEmail= '';
        objRepDet.RepresentativeFirstName= '';
        objRepDet.RepresentativeLastName= '';
        objRepDet.RepresentativeOrganisationName= '';
        objRepDet.RepresentativePhoneNo= '';
        objRepDet.RepresentativeState= '';
        objRepDet.RepresentativeZip4= '';
        objRepDet.RepresentativeZip5= '';

        SSP_HearingDataContractOrg.HearingSummary objSum = new SSP_HearingDataContractOrg.HearingSummary();
        objSum.CaseName = '';
        objSum.CaseNumber = 12;
        objSum.HearingDate= '';
        objSum.HearingDelayReason= '';
        objSum.HearingId= '';
        objSum.HearingOfficer= '';
        objSum.HearingProgram= '';
        objSum.HearingReason= '';
        objSum.HearingStatus= '';
        objSum.HearingType= '';
        objSum.IndividualId = 23;
        objSum.Requester = '';

        SSP_HearingDataContractOrg.SFHearingCommonError  objErr = new SSP_HearingDataContractOrg.SFHearingCommonError ();
        objErr.CHFSExceptionId= '';
        objErr.ErrorCode= '';
        objErr.ErrorDescription= '';

        SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse objBulk = new SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse();
        objBulk.DocumentsUpload = new SSP_HearingDataContractOrg.ArrayOfDocumentsUpload();
        objBulk.HearingAppointment = new SSP_HearingDataContractOrg.HearingAppointment();
        objBulk.HearingHistoryList = new SSP_HearingDataContractOrg.ArrayOfHearingHistory();
        objBulk.HearingSummary = new SSP_HearingDataContractOrg.HearingSummary();
        objBulk.NegativeActionDocuments = new SSP_HearingDataContractOrg.ArrayOfNegativeActionDocuments();
        objBulk.PartiesInvolved = new SSP_HearingDataContractOrg.ArrayOfPartiesInvolved();
        objBulk.PrehearingAppointment = new SSP_HearingDataContractOrg.PrehearingAppointment();
        objBulk.ErrorLogCode ='';
     
        SSP_HearingDataContractOrg.PrehearingAppointment objPre = new SSP_HearingDataContractOrg.PrehearingAppointment();
        objPre.ConferenceLine = '';
        objPre.Location= '';
        objPre.MeetingType= '';
        objPre.PrehearingDate= '';
        objPre.PrehearingParticipantCode= '';
        objPre.Prehearingtime= '';
        SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest req = new SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest();
        req.HearingDelayReason = '123456789';
        req.HearingDate = system.now();
        req.HearingId= '1003914';
        req.loggedInUserEmailId= 'abc@gmail.com';
        Map<String, Object> objReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WITHDRAWHEARING_METADATANAME, objReq);
        System.assertEquals(1,lstData.size(),'Wrong Output');
        Test.stopTest();     
    }
    @isTest 
    static void testNegetive() {
        Test.startTest();
        SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest req = new SSP_HearingDataContractOrg.CitizenWithdrawHearingRequest();
        req.HearingDelayReason = '123456789';
        req.HearingDate = system.now();
        req.HearingId= '1003914';
        req.loggedInUserEmailId= 'abc@gmail.com';
        Map<String, Object> objReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WITHDRAWHEARING_METADATANAME, objReq);
        System.assertEquals(1,lstData.size(),'Wrong Output');
        Test.stopTest();         
    }
}