@isTest
global class SingleRequestMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
	    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ChildCareProviderDetails":[{"ProviderId":421.0,"ProviderName":"Inspection Test","ProviderStatus":"APPROVED","ProviderType":"Certified","LocationAddressLine1":"123 Main St","LocationCity":"Frankfort","LocationZipCode5":12345.0,"LocationStateDescription":"KY","LocationCountyDescription":"FRANKLIN","NumberOfStars":0,"Distance":0.00,"IsOngoingProcess":"N","PhoneNumber":"1234567890","HoursOfOperationList":[{"Day":"Monday","ServiceTime":"No Information Available"},{"Day":"Tuesday","ServiceTime":"No Information Available"},{"Day":"Wednesday","ServiceTime":"No Information Available"},{"Day":"Thursday","ServiceTime":"No Information Available"},{"Day":"Friday","ServiceTime":"No Information Available"},{"Day":"Saturday","ServiceTime":"No Information Available"},{"Day":"Sunday","ServiceTime":"No Information Available"}],"Capacity":"5","InspectionHistoryList":[{"InspectionId":229.0,"ReportName":"KID013","InspectionType":"Investigation","PlanOfCorrectionID":"","InspectionStartDate":"2011-05-05T11:10:00","InspectionEndDate":"2011-05-05T11:30:00"},{"InspectionId":248.0,"ReportName":"KID013","InspectionType":"Investigation","PlanOfCorrectionID":"","InspectionStartDate":"2014-06-04T13:52:00","InspectionEndDate":"2014-06-04T14:00:00"}]}]}');
        res.setStatusCode(200);
		return res;
    }
	
}