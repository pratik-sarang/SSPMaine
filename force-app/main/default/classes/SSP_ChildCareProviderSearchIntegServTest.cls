/**
 * Class Name    : SSP_ChildCareProviderSearchIntegServTest
 * Owner         : DELOITTE
 * Created Date  : 15/05/2020
 * Description   : This is unit test class for SSP_ChildCareProviderSearchIntegService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  15/05/2020  Ragunathan          Initial Version
 */
@isTest
public class SSP_ChildCareProviderSearchIntegServTest {

    static testmethod void shouldInvokeCalloutForEnrollSummary() {
        Test.setMock(HttpCalloutMock.class, new SSP_ChildCareProviderSearchIntegServiceMock('ChildCareEnrollmentSummary'));
        SSP_CCEnrollSummary_RequestWrapper request = new SSP_CCEnrollSummary_RequestWrapper();
        request.CaseNumber = '100169612';
        request.IndividualId = '810203133';
        request.SubmitType = 'ChildCareEnrollmentSummary';
        
        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
        Test.startTest();		
		List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CHILDCARE_PROVIDER_SEARCH, mapParams);
		Test.stopTest();
		SSP_ChildCareProviderSearchResponse expectedResponse = prepareExpectedResponse();
        SSP_ChildCareProviderSearchResponse response = (SSP_ChildCareProviderSearchResponse) objList[0];
        List<SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentDetails> ccEnrollmentDetails = response.ChildCareEnrollmentDetails;
        List<SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentScheduleDetails> ccEnrollmentSchDetails = response.ChildCareEnrollmentScheduleDetails;
        System.assertEquals(expectedResponse.ChildCareEnrollmentDetails[0].EnrolledChildName, ccEnrollmentDetails[0].EnrolledChildName, 'Check success response');
    }

    static testmethod void shouldThrownExceptionWhileInvokeCallout() {
        Map<String, Object> mapInputParams = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new SSP_ChildCareProviderSearchIntegServiceErrorMock());

        Test.startTest();
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CHILDCARE_PROVIDER_SEARCH, mapInputParams);
        Test.stopTest();
        LOG_LogMessage__c logMessage = [Select InterfaceName__c, LOG_Debug_Level__c from LOG_LogMessage__c];
        System.assertEquals(SSP_InterfaceConstants.SSP_CHILDCARE_PROVIDER_SEARCH, logMessage.InterfaceName__c, 'Verify the error log created for the Interface');
        System.assertEquals('Error', logMessage.LOG_Debug_Level__c, 'Verify the error log created');
	}
	
	static SSP_ChildCareProviderSearchResponse prepareExpectedResponse() {
		SSP_ChildCareProviderSearchResponse expectedResponse = new SSP_ChildCareProviderSearchResponse();
		expectedResponse.ChildCareEnrollmentDetails = new List<SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentDetails>();
		SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentDetails ccEnrollDetails = new SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentDetails();
		ccEnrollDetails.IndividualId = '810203134';
		ccEnrollDetails.Casenumber	 = '100169612';
		ccEnrollDetails.EnrolledChildName = 'PPPTLV EDLTI';
		ccEnrollDetails.EnrollmentId = '1000021645';
		ccEnrollDetails.EnrollmentProviderId = '250893';
		ccEnrollDetails.EnrollmentProviderName = '';
		ccEnrollDetails.EnrollmentStatus = 'Active';
		ccEnrollDetails.EnrollmentStatusFromDate = '2018-01-11T00:00:00';
		ccEnrollDetails.IndividualAllocatedDailyCoPayAmount = '0';
		ccEnrollDetails.FamilyAllocatedDailyCoPayAmount = '0';

		expectedResponse.ChildCareEnrollmentDetails.add(ccEnrollDetails);

		SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentScheduleDetails ccEnrollScheDetails = new SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentScheduleDetails();

		ccEnrollScheDetails.CaseNumber = '34567890';
		ccEnrollScheDetails.EnrollmentID = '1987456789';
		ccEnrollScheDetails.FlexiMaxFullDays = '5';
		ccEnrollScheDetails.FlexiMaxPartDays = '4';
		ccEnrollScheDetails.ServiceScheduleOnMonday = 'Not Needed';
		ccEnrollScheDetails.ServiceScheduleOnTuesday = 'Not Needed';
		ccEnrollScheDetails.ServiceScheduleOnWednesday = 'Not Needed';
		ccEnrollScheDetails.ServiceScheduleOnThursday = 'Not Needed';
		ccEnrollScheDetails.ServiceScheduleOnFriday = 'Not Needed';
		ccEnrollScheDetails.ServiceScheduleOnSaturday = 'Not Needed';
		ccEnrollScheDetails.ServiceScheduleOnSunday = 'Not Needed';

		expectedResponse.ChildCareEnrollmentScheduleDetails = new List<SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentScheduleDetails>();

		expectedResponse.ChildCareEnrollmentScheduleDetails.add(ccEnrollScheDetails);

		SSP_ChildCareProviderSearchResponse.InspectionHistoryList histList = new SSP_ChildCareProviderSearchResponse.InspectionHistoryList();

		histList.InspectionId = 45678.87;
		histList.ReportName = 'testr';
		histList.InspectionType = 'testr';
		histList.PlanOfCorrectionID = 'testr';
		histList.Source = 'testr';
		histList.DocumentType = 'testr';
		histList.DocumentID = 'testr';
		histList.InspectionStartDate='2020-2-21';
		histList.InspectionEndDate='2020-12-21';

		SSP_ChildCareProviderSearchResponse.OnGoingProcessList ogpList = new SSP_ChildCareProviderSearchResponse.OnGoingProcessList();
		ogpList.ProcessType = 'sampkle';
		ogpList.Status = 'Status';
		SSP_ChildCareProviderSearchResponse.ServiceCostList scList = new SSP_ChildCareProviderSearchResponse.ServiceCostList();
		scList.AgeGroup = '20s';
		scList.FullTimeCost = 240;
		scList.PartTimeCost = 130;
		SSP_ChildCareProviderSearchResponse.HoursOfOperationList hop = new SSP_ChildCareProviderSearchResponse.HoursOfOperationList();
		hop.Day = 'Sunday';
		hop.ServiceTime = '9';
		SSP_ChildCareProviderSearchResponse.ChildCareProviderDetails ccProviderDetails = new SSP_ChildCareProviderSearchResponse.ChildCareProviderDetails();

		ccProviderDetails.ProviderId = 456789;
		ccProviderDetails.ProviderName = 'tete';
		ccProviderDetails.ProviderStatus = 'status';
		ccProviderDetails.ProviderType = 'test type';
		ccProviderDetails.LocationAddressLine1 = 'address 1';
		ccProviderDetails.LocationAddressLine2 = 'address 2';
		ccProviderDetails.LocationCity = 'Lousiana';
		ccProviderDetails.LocationZipCode5 = 5666;
		ccProviderDetails.LocationStateDescription = 'testt';
		ccProviderDetails.LocationCountyDescription = 'County desc';
		ccProviderDetails.NumberOfStars = 4;
		ccProviderDetails.Distance = 788.7;
		ccProviderDetails.IsOngoingProcess = 'N';
		ccProviderDetails.PhoneNumber = '876543234';
		ccProviderDetails.HoursOfOperationList = new List<SSP_ChildCareProviderSearchResponse.HoursOfOperationList> {hop};
		ccProviderDetails.Capacity = '12';
		ccProviderDetails.IsSubsidyAccepted = 'Y';
		ccProviderDetails.IsAcceditationsAvailable = 'N';
		ccProviderDetails.Transportation = 'Van';
		ccProviderDetails.Infant = '2';
		ccProviderDetails.Toddler = '2';
		ccProviderDetails.PreSchool = 'N';
		ccProviderDetails.SchoolAge = '5';
		ccProviderDetails.ServiceCostList = new List<SSP_ChildCareProviderSearchResponse.ServiceCostList>{ scList};
		ccProviderDetails.InspectionHistoryList = new List<SSP_ChildCareProviderSearchResponse.InspectionHistoryList> {histList};
		ccProviderDetails.OnGoingProcessList = new List<SSP_ChildCareProviderSearchResponse.OnGoingProcessList>{ ogpList};
		ccProviderDetails.IsFoodPermitAvailable = 'N';

		expectedResponse.ChildCareProviderDetails = new List<SSP_ChildCareProviderSearchResponse.ChildCareProviderDetails>{ccProviderDetails};

		return expectedResponse;
	}
	
    public class SSP_ChildCareProviderSearchIntegServiceMock implements HttpCalloutMock{

		public String responseBody;
		public SSP_ChildCareProviderSearchIntegServiceMock(String submitType) {
			if(submitType == 'ChildCareEnrollmentSummary'){
				this.responseBody = sChildCareEnrollmentSummary;
			} else if(submitType == 'ChildCareProviderDetails'){
				this.responseBody = sChildCareProviderDetail;
			} if(submitType == 'ChildCareProviderDetailFile'){
				this.responseBody = sChildCareProviderDetailFile;
			} 
		}
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(this.responseBody);
            return response;
		}

		String sChildCareProviderDetailFile =  '  {"FileStream":{"FileData":"JVBERi0xLjMNCjEgMCBvYmoNClsvUERGIC9UZXh0IC9JbWFnZUIgL0ltY="}}  ' ; 
		
		String  sChildCareProviderDetail =  '   {  '  + 
		'     "ChildCareProviderDetails": [  '  + 
		'       {  '  + 
		'         "ProviderId": 122,  '  + 
		'         "ProviderName": "Pebbles Daycare Center",  '  + 
		'         "ProviderStatus": "APPROVED                                                                                                                                                                                                ",  '  + 
		'         "ProviderType": "Certified",  '  + 
		'         "LocationAddressLine1": "123 First St",  '  + 
		'         "LocationAddressLine2": "PROVIDER ST2",  '  + 
		'         "LocationCity": "Frankfort",  '  + 
		'         "LocationZipCode5": 12345,  '  + 
		'         "LocationStateDescription": "KY                                                                                                                                                                                                      ",  '  + 
		'         "LocationCountyDescription": "FRANKLIN                                                                                                                                                                                                ",  '  + 
		'         "NumberOfStars": 1,  '  + 
		'         "Distance": 0,  '  + 
		'         "IsOngoingProcess": "N",  '  + 
		'         "PhoneNumber": "5025550001",  '  + 
		'         "HoursOfOperationList": [  '  + 
		'           {  '  + 
		'             "Day": "Monday",  '  + 
		'             "ServiceTime": "No Information Available"  '  + 
		'           },  '  + 
		'           {  '  + 
		'             "Day": "Tuesday",  '  + 
		'             "ServiceTime": "No Information Available"  '  + 
		'           },  '  + 
		'           {  '  + 
		'             "Day": "Wednesday",  '  + 
		'             "ServiceTime": "No Information Available"  '  + 
		'           },  '  + 
		'           {  '  + 
		'             "Day": "Thursday",  '  + 
		'             "ServiceTime": "No Information Available"  '  + 
		'           },  '  + 
		'           {  '  + 
		'             "Day": "Friday",  '  + 
		'             "ServiceTime": "No Information Available"  '  + 
		'           },  '  + 
		'           {  '  + 
		'             "Day": "Saturday",  '  + 
		'             "ServiceTime": "No Information Available"  '  + 
		'           },  '  + 
		'           {  '  + 
		'             "Day": "Sunday",  '  + 
		'             "ServiceTime": "No Information Available"  '  + 
		'           }  '  + 
		'         ],  '  + 
		'         "Capacity": "6"  '  + 
		'       }  '  + 
		'     ]  '  + 
		'  }  ' ; 
        
        String sChildCareEnrollmentSummary =     '   {  '  + 
                                 '     "ChildCareEnrollmentDetails": [  '  + 
                                 '       {  '  + 
                                 '         "IndividualId": 810203134,  '  + 
                                 '         "Casenumber": 100169612,  '  + 
                                 '         "EnrolledChildName": "PPPTLV EDLTI",  '  + 
                                 '         "EnrollmentId": 1000021645,  '  + 
                                 '         "EnrollmentProviderId": 250893,  '  + 
                                 '         "EnrollmentProviderName": "",  '  + 
                                 '         "EnrollmentStatus": "Active",  '  + 
                                 '         "EnrollmentStatusFromDate": "2018-01-11T00:00:00",  '  + 
                                 '         "IndividualAllocatedDailyCoPayAmount": 0,  '  + 
                                 '         "FamilyAllocatedDailyCoPayAmount": 0  '  + 
                                 '       },  '  + 
                                 '       {  '  + 
                                 '         "IndividualId": 810203134,  '  + 
                                 '         "Casenumber": 100169612,  '  + 
                                 '         "EnrolledChildName": "PPPTLV EDLTI",  '  + 
                                 '         "EnrollmentId": 1000021646,  '  + 
                                 '         "EnrollmentProviderId": 250866,  '  + 
                                 '         "EnrollmentProviderName": "",  '  + 
                                 '         "EnrollmentStatus": "Active",  '  + 
                                 '         "EnrollmentStatusFromDate": "2018-01-11T00:00:00",  '  + 
                                 '         "IndividualAllocatedDailyCoPayAmount": 0,  '  + 
                                 '         "FamilyAllocatedDailyCoPayAmount": 0  '  + 
                                 '       }  '  + 
                                 '     ],  '  + 
                                 '     "ChildCareEnrollmentScheduleDetails": [  '  + 
                                 '       {  '  + 
                                 '         "CaseNumber": 100169612,  '  + 
                                 '         "EnrollmentID": 1000021645,  '  + 
                                 '         "ServiceScheduleOnMonday": "Part Day",  '  + 
                                 '         "ServiceScheduleOnTuesday": "Part Day",  '  + 
                                 '         "ServiceScheduleOnWednesday": "Part Day",  '  + 
                                 '         "ServiceScheduleOnThursday": "Part Day",  '  + 
                                 '         "ServiceScheduleOnFriday": "Part Day",  '  + 
                                 '         "ServiceScheduleOnSaturday": "Part Day",  '  + 
                                 '         "ServiceScheduleOnSunday": "Part Day"  '  + 
                                 '       },  '  + 
                                 '       {  '  + 
                                 '         "CaseNumber": 100169612,  '  + 
                                 '         "EnrollmentID": 1000021646,  '  + 
                                 '         "ServiceScheduleOnMonday": "Not Needed",  '  + 
                                 '         "ServiceScheduleOnTuesday": "Not Needed",  '  + 
                                 '         "ServiceScheduleOnWednesday": "Not Needed",  '  + 
                                 '         "ServiceScheduleOnThursday": "Not Needed",  '  + 
                                 '         "ServiceScheduleOnFriday": "Not Needed",  '  + 
                                 '         "ServiceScheduleOnSaturday": "Not Needed",  '  + 
                                 '         "ServiceScheduleOnSunday": "Not Needed"  '  + 
                                 '       },  '  + 
                                 '       {  '  + 
                                 '         "CaseNumber": 100169612,  '  + 
                                 '         "EnrollmentID": 1000021646,  '  + 
                                 '         "FlexiMaxFullDays": "4",  '  + 
                                 '         "FlexiMaxPartDays": "3"  '  + 
                                 '       }  '  + 
                                 '     ]  '  + 
                                 '  }  ' ; 
    }

    public class SSP_ChildCareProviderSearchIntegServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}