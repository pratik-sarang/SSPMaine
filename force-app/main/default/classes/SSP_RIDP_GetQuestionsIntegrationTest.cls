/*
* Classname 	:  SSP_RIDP_GetQuestionsIntegrationTest
* @description 	:  This class is the test class of SSP_RIDP_GetQuestionsIntegrationService
* @author 		:  Ragunathan
* @date 		:  30/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description about the Change
* Ragunathan          05/30/2020            Initial Creation
**/
@isTest
public class SSP_RIDP_GetQuestionsIntegrationTest {

    @isTest
    static void shouldGetResponse() {
        Test.setMock(WebServiceMock.class, new SSP_RIDP_GetQuestionsMockClass());

		SSP_RIDP_RequestWrapper objRequestBody = new SSP_RIDP_RequestWrapper();
		SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserInfo userInfo = new SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserInfo();
		userInfo.LanguagePreference = 'EN-US';
		userInfo.LegalFirstName     = 'Emma';
		userInfo.LegalLastName      = 'Vorobyova';
		userInfo.MiddleName         = 'I';
		userInfo.NameSuffix         = null;
		userInfo.BirthDate          = DateTime.newInstance(1999, 11, 01);
		userInfo.SSN                = null;
		userInfo.StreetName         = '1 Street';
		userInfo.CityName           = 'Frankfort';
		userInfo.State              = 'KY';
		userInfo.PostalCode         = '40601';
		userInfo.PostalCodeExtension = '4231';
		userInfo.FullTelephoneNumber = '555-555-5555';

		objRequestBody.RIDPUserInfo = userInfo;
		objRequestBody.userKOGID = '3ba09890-a38e-4813-a350-e5d65f7a6be1';

		Continuation con = new Continuation(40);
		AsyncSSP_RIDP_tempuriOrg.AsyncWSHttpBinding_IRIDPStandAlone asyncBind = new AsyncSSP_RIDP_tempuriOrg.AsyncWSHttpBinding_IRIDPStandAlone();
		asyncBind.beginGetQuestions(con, userInfo, objRequestBody.userKOGID);
		Map<String,object> obj = new Map<string,object>();
		obj.put('jsonbody', JSON.serialize(objRequestBody));
		List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_RIDP_GET_QUESTIONS, obj);
		SSP_RIDP_DatacontractOrg200407Kogserv.RIDPServiceResponse response = (SSP_RIDP_DatacontractOrg200407Kogserv.RIDPServiceResponse) slist[0];
		System.assertEquals('AXBYCZD-EFGHIJ-KLM-NOP', response.SessionID);
    }
}