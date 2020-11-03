@isTest
global class SingleRequestMockForPr implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
	    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"FileStream":{"FileData":"Test Data"}, "ExportData":[{"LocationCountyDescription":"FranklinTestCounty","ProviderName":null,"LocationAddress":"Frankofrt","PhoneNumber":8888888888,"MailingAddress":"testaddress"}],"ChildCareProviderDetails":[{"ProviderId":421.0,"ProviderName":"Inspection Test","ProviderStatus":"APPROVED","ProviderType":"Certified","LocationAddressLine1":"123 Main St","LocationCity":"Frankfort","LocationZipCode5":12345.0,"LocationStateDescription":"KY","NumberOfStars":0,"Distance":0.00,"IsOngoingProcess":"N","PhoneNumber":"1234567890"}],"ChildCareEnrollmentScheduleDetails":null,"ChildCareEnrollmentDetails":null,"AckResponse":{"AckResponseCode":"Test","AckResponseDescription":"testName"}}');
        res.setStatusCode(200);
		return res;
    }
	
}