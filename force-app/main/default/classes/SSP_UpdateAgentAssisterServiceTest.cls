/*
* Classname         :  SSP_UpdateAgentAssisterServiceTest
* @description  :  This class is the test class of SSP_UpdateAgentAssisterService
* @author       :  Rijia Khatun
* @date         :  4/27/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest
public class SSP_UpdateAgentAssisterServiceTest {
    @isTest
    static void testAgent() {
        Test.setMock(HttpCalloutMock.class, new SSP_UpdateAgentAssisterMock()); 
        Test.startTest();
       	SSP_UpdateAgentAssisterRequestWrapper objReq = new SSP_UpdateAgentAssisterRequestWrapper();
        SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel objModel = new SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel();
        objModel.AgencyId = 'T';
        objModel.CaseNumber = '123';
        objModel.IndividualId = 'T';
        objModel.AgencyEmployeeId = 'T';
        objModel.IndividualContactPhone = 'T';
        objModel.DoiAgentId = 'T';
        objModel.DoiAgencyId = 'T';
        objModel.NewAssignment = 'T';
        objModel.LoggedInUserId = 'T';
		objReq.DCAgencyIndividualCaseAssociationModel = new List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel>{objModel};
		Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objReq) };
        objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,'CaseNumber');
        List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPUpdateAgentAssister_METADATANAME, objResponse);
        SSP_UpdateAgentAssisterResWrapper objRes = (SSP_UpdateAgentAssisterResWrapper)lstReturnedData[0];
        System.assertEquals(200,objRes.sStatusCode,'Correct Output'); 
        Test.stopTest();         
    }
    @isTest
    static void testAgentNeg() {
        Test.startTest();
       	SSP_UpdateAgentAssisterRequestWrapper objReq = new SSP_UpdateAgentAssisterRequestWrapper();
        SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel objModel = new SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel();
        objModel.AgencyId = 'T';
        objModel.CaseNumber = '123';
        objModel.IndividualId = 'T';
        objModel.AgencyEmployeeId = 'T';
        objModel.IndividualContactPhone = 'T';
        objModel.DoiAgentId = 'T';
        objModel.DoiAgencyId = 'T';
        objModel.NewAssignment = 'T';
        objModel.LoggedInUserId = 'T';
		objReq.DCAgencyIndividualCaseAssociationModel = new List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel>{objModel};
		Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objReq) };
        objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,'CaseNumber');
        List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPUpdateAgentAssister_METADATANAME, objResponse);
        SSP_UpdateAgentAssisterResWrapper objRes = (SSP_UpdateAgentAssisterResWrapper)lstReturnedData[0];
        System.assertEquals(null,objRes.sStatusCode,'Correct Output'); 
        Test.stopTest();         
    }
}