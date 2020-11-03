/*
* Classname 	:  SSP_RIDP_CheckResumeIntegrationTest
* @description 	:  This class is the test class of SSP_RIDP_CheckResumeIntegrationService
* @author 		:  Ragunathan
* @date 		:  30/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description about the Change
* Ragunathan          05/30/2020            Initial Creation
**/
@isTest
public class SSP_RIDP_CheckResumeIntegrationTest {

    @isTest
    static void shouldGetResponse() {
        Test.setMock(WebServiceMock.class, new SSP_RIDP_CheckResumeMockClass());
        SSP_RIDP_RequestWrapper objRequestBody = new SSP_RIDP_RequestWrapper();

        SSP_RIDP_DatacontractOrg200407System.SystemExceptionDetails sysExceptionDetails = new SSP_RIDP_DatacontractOrg200407System.SystemExceptionDetails();
        SSP_RIDP_DatacontractOrg200407System.Exception_x except = new SSP_RIDP_DatacontractOrg200407System.Exception_x();
        SSP_RIDP_DatacontractOrg200407System.FaultExceptionDetails faultExcep = new SSP_RIDP_DatacontractOrg200407System.FaultExceptionDetails();
        SSP_RIDP_DatacontractOrg200407System.CommunicationExceptionDetails commException = new SSP_RIDP_DatacontractOrg200407System.CommunicationExceptionDetails();
        SSP_RIDP_DatacontractOrg200407System.ArrayOfFaultException_FaultCodeData arrOfFaultCode = new SSP_RIDP_DatacontractOrg200407System.ArrayOfFaultException_FaultCodeData();
        SSP_RIDP_DatacontractOrg200407System.FaultException_FaultCodeData faultCode = new SSP_RIDP_DatacontractOrg200407System.FaultException_FaultCodeData();
        faultCode.name = 'test';
        faultCode.ns = 'test';
        List<SSP_RIDP_DatacontractOrg200407System.FaultException_FaultCodeData> faultCodes = new List<SSP_RIDP_DatacontractOrg200407System.FaultException_FaultCodeData>();
        faultCodes.add(faultCode);

        arrOfFaultCode.FaultException_FaultCodeData = faultCodes;

        SSP_RIDP_DatacontractOrg200407System.FaultException_FaultReasonData faultException = 
                new SSP_RIDP_DatacontractOrg200407System.FaultException_FaultReasonData();

        faultException.text = 'test';
        faultException.xmlLang = 'test';
        List<SSP_RIDP_DatacontractOrg200407System.FaultException_FaultReasonData> faultExceptions = 
                new List<SSP_RIDP_DatacontractOrg200407System.FaultException_FaultReasonData>();
        faultExceptions.add(faultException);

        List<SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring> keyValues = 
                new List<SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring>();
        SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring keyValue = new SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring();
        keyValue.key = 'test';
        keyValue.value = 'test';
        keyValues.add(keyValue);

        SSP_RIDP_DatacontractOrg200407System systemObj = new SSP_RIDP_DatacontractOrg200407System();
        SSP_RIDP_DatacontractOrg200407System.ArrayOfKeyValuePairOfstringstring arrOfKeyValues = 
                new SSP_RIDP_DatacontractOrg200407System.ArrayOfKeyValuePairOfstringstring();
        arrOfKeyValues.KeyValuePairOfstringstring = keyValues;

        SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserResume userResume = new SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserResume();
        userResume.LanguagePreference = 'EN-US';
        userResume.LegalLastName      =  'Vorobyova';
        userResume.BirthDate          = DateTime.newInstance(1999, 11, 01);
        userResume.ReferenceNumber    = '12243';

        objRequestBody.RIDPUserResume = userResume;
        objRequestBody.userKOGID      = '3ba09890-a38e-4813-a350-e5d65f7a6be1';

        Continuation con = new Continuation(40);
		AsyncSSP_RIDP_tempuriOrg.AsyncWSHttpBinding_IRIDPStandAlone asyncBind = new AsyncSSP_RIDP_tempuriOrg.AsyncWSHttpBinding_IRIDPStandAlone();
		asyncBind.beginCheckResume(con, userResume, objRequestBody.userKOGID);
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(objRequestBody));
        Test.startTest();
        List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_RIDP_CHECK_RESUME, obj);
        Test.stopTest();
        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse response = (SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse) slist[0];
        SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse[] messageResponses = response.MessageResponse;
        System.assertEquals(1234, messageResponses[0].MessageCode);
        System.assertEquals('Please enter valid values which are pending resume stage.', messageResponses[0].MessageDescription);
    }
}