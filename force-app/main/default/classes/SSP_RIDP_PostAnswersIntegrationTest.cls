/*
* Classname 	:  SSP_RIDP_PostAnswersIntegrationTest
* @description 	:  This class is the test class of SSP_RIDP_PostAnswersIntegrationService
* @author 		:  Ragunathan
* @date 		:  30/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description about the Change
* Ragunathan          05/30/2020            Initial Creation
**/
@isTest
public class SSP_RIDP_PostAnswersIntegrationTest {

    @isTest
    static void shouldGetResponse() {
        Test.setMock(WebServiceMock.class, new SSP_RIDP_PostAnswersMockClass());
        SSP_RIDP_RequestWrapper objRequestBody = new SSP_RIDP_RequestWrapper();
        
        List<SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring> keyValues = 
                new List<SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring>();
        SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring keyValue = new SSP_RIDP_DatacontractOrg200407System.KeyValuePairOfstringstring();
        keyValue.key = 'test';
        keyValue.value = 'test';
        keyValues.add(keyValue);

		SSP_RIDP_DatacontractOrg200407System.ArrayOfKeyValuePairOfstringstring arrOfKeyValues = 
                new SSP_RIDP_DatacontractOrg200407System.ArrayOfKeyValuePairOfstringstring();
        arrOfKeyValues.KeyValuePairOfstringstring = keyValues;
        
        SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse msgResponse = new SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse();
        msgResponse.MessageCode = 0;
        msgResponse.MessageDescription = '';
        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse arrOfMessageResponse = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse();
        arrOfMessageResponse.MessageResponse = new List<SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse> {msgResponse};

		SSP_RIDP_DatacontractOrg200407KeupsB.QuestionSet arrOfQueSet = new SSP_RIDP_DatacontractOrg200407KeupsB.QuestionSet();
		arrOfQueSet.x_x003C_AnswerSetBlock_x003E_k_xBackingField = arrOfKeyValues;
		SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfQuestionSet arrOfQueSets = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfQuestionSet();
		SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfAnswerSet arrOfAnsSet = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfAnswerSet();
		SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSet = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
		ansSet.VerificationAnswer = 'ansTest';
		ansSet.VerificationQuestionNumber = 'ansTest';

		arrOfAnsSet.AnswerSet = new List<SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet> {ansSet};
            
        List<SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet> answerSets = new List<SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet>();

        SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet1 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
        ansSwet1.VerificationQuestionNumber = '1';
        ansSwet1.VerificationAnswer = '1';
        answerSets.add(ansSwet1);

        SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet2 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
        ansSwet2.VerificationQuestionNumber = '2';
        ansSwet2.VerificationAnswer = '1';
        answerSets.add(ansSwet2);

        SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet3 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
        ansSwet3.VerificationQuestionNumber = '3';
        ansSwet3.VerificationAnswer = '1';
        answerSets.add(ansSwet3);

        SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet4 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
        ansSwet4.VerificationQuestionNumber = '4';
        ansSwet4.VerificationAnswer = '1';
        answerSets.add(ansSwet4);

        SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet5 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
        ansSwet5.VerificationQuestionNumber = '5';
        ansSwet5.VerificationAnswer = '1';
        answerSets.add(ansSwet5);

        SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet6 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
        ansSwet6.VerificationQuestionNumber = '6';
        ansSwet6.VerificationAnswer = '1';
        answerSets.add(ansSwet6);

        SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet7 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
        ansSwet7.VerificationQuestionNumber = '7';
        ansSwet7.VerificationAnswer = '1';
        answerSets.add(ansSwet7);


        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfAnswerSet arrOfAnswer = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfAnswerSet();
        arrOfAnswer.AnswerSet = answerSets;

        SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserReply userReply = new SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserReply();
        userReply.LanguagePreference = 'EN-US';
        userReply.SessionID     	 = '1XQBKVC4UOM20FZYVJDFKQD2.pidd1v-1712211339080210051946419';
        userReply.VerificationAnswers  = arrOfAnswer;


        objRequestBody.RIDPUserReply = userReply;
        objRequestBody.userKOGID = '3ba09890-a38e-4813-a350-e5d65f7a6be1';

        Continuation con = new Continuation(40);
		AsyncSSP_RIDP_tempuriOrg.AsyncWSHttpBinding_IRIDPStandAlone asyncBind = new AsyncSSP_RIDP_tempuriOrg.AsyncWSHttpBinding_IRIDPStandAlone();
		asyncBind.beginPostAnswers(con, userReply, objRequestBody.userKOGID);

        Map<String,object> inputParams = new Map<string,object>();
        inputParams.put('jsonbody', JSON.serialize(objRequestBody));
        List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_RIDP_POST_ANSWERS,inputParams);
        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse response = (SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse) slist[0];
        SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse[] messageResponses = response.MessageResponse;
        System.assertEquals(0, messageResponses[0].MessageCode);
        System.assertEquals('Identity proofing request Successful.reference number', messageResponses[0].MessageDescription);
    }
}