@isTest
private class SSP_DisqualificationDetailControllerTest implements HttpCalloutMock {
    @isTest
    public static void testDisqualificationDetailController() {
        String individualId = '8973647';
        Test.setMock(HttpCalloutMock.class, new SSP_DisqualificationDetailControllerTest());

        Test.startTest();
        SSP_DisqualificationDetailsController.fetchDisqualificationData(individualId);
        SSP_DisqualificationDetailsController.DisqualificationWrapper disqualificationWrapper = new SSP_DisqualificationDetailsController.DisqualificationWrapper();
        disqualificationWrapper.caseNumber = 1;
        disqualificationWrapper.ProgramCode = '123';
        disqualificationWrapper.PenaltyDisqualificationType = 'TestPenaltyDisqualificationType';
        disqualificationWrapper.EffectiveStartDate = '11-7-2020';
        disqualificationWrapper.EffectiveEndDate = '12-7-2020';
        disqualificationWrapper.DMSId = '12345';
        System.assertNotEquals(null, disqualificationWrapper);
        Test.stopTest();
    }

    public HTTPResponse respond(HTTPRequest req) {
        // Create a test response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"DisqualificationPayload":{"DisqualificationDetails":[]}}');
        res.setStatusCode(200);
        return res;
    }
}