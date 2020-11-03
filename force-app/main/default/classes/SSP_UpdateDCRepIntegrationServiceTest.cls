/**
 * Class Name    : SSP_UpdateDCRepIntegrationServiceTest
 * Owner         : DELOITTE
 * Created Date  : 24/04/2020
 * Description   : This is unit test class for SSP_UpdateDCRepIntegrationService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  24/04/2020  Ragunathan          Initial Version
 */
@isTest
public class SSP_UpdateDCRepIntegrationServiceTest {
    @isTest
    static void shouldInvokeCallout() {
        Map<String, Object> mapInputParams = createTestData();
        Test.setMock(HttpCalloutMock.class, new SSP_UpdateDCRepIntegrationServiceMock());
        Test.startTest();
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_UPDATE_DC_REPRESENTATIVE, mapInputParams);
        Test.stopTest();
        SSP_UpdateDCRepResponseWrapper response = (SSP_UpdateDCRepResponseWrapper) objList[0];
        System.assert(response.AckResponse.Success, 'Check success response');
    }
    @isTest
    static void shouldThrownExceptionWhileInvokeCallout() {
        Map<String, Object> mapInputParams = createTestData();
        Test.setMock(HttpCalloutMock.class, new SSP_UpdateDCRepIntegrationServiceErrorMock());

        Test.startTest();
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_UPDATE_DC_REPRESENTATIVE, mapInputParams);
        Test.stopTest();
        LOG_LogMessage__c logMessage = [Select InterfaceName__c, LOG_Debug_Level__c from LOG_LogMessage__c];
        System.assertEquals(SSP_InterfaceConstants.SSP_UPDATE_DC_REPRESENTATIVE, logMessage.InterfaceName__c, 'Verify the error log created for the Interface');
        System.assertEquals('Error', logMessage.LOG_Debug_Level__c, 'Verify the error log created');
    }

    private static Map<String, Object> createTestData() {
        Account acc = new Account(
            Name = 'firstName'
        );
        Account acc1 = new Account(
            Name = 'firstName'
        );
        insert new List<Account> {acc, acc1};
        Contact con = new Contact(
            AccountId = acc.Id,
            FirstName = 'John',
            MiddleName = 'T',
            LastName = 'Doe(CP Admin)',
            SuffixCode__c = 'SR',
            OrganizationName__c = 'Test corp Inc',
            OrgranizationIdentificationNumber__c = '2',
            Street__c = '401, Flat Rock Road, Somerset, KENTUCKY, United States, 42501',
            AddressLine2__c = 'testt',
            City__c = 'Somerset',
            SSP_State__c = 'KY',
            Zipcode4__c = '42502',
            Zipcode5__c = '42501',
            CountyCode__c = '200',
            PrimaryPhoneExtension__c = '1111',
            PreferredLanguageCode__c = '1',
            GenderCode__c = 'M',
            Birthdate = Date.newInstance(2019, 08, 12),
            SSN__c = '432222222',
            IsManualAuthRep__c = true,
            DCDataId__c = 5677,
            Phone = '(278) 129-1234',
            Email = 'lkankane@deloitte.com'
        );
        insert con;
        AccountContactRelation acr = new AccountContactRelation(
            StartDate = Date.newInstance(2019, 08, 12),
            ContactId = con.Id,
            AccountId = acc1.Id,
            ProgramsApplied__c = 'MA',
            PermissionLevel_Medicaid__c = 'ST',
            PermissionLevel_SNAP__c = 'SE',
            PermissionLevel_StateSupp__c = 'SE',
            PermissionLevel_KIHIPP__c = 'ST',
            PermissionLevel_KTAP__c = 'ST',
            PermissionLevel_CCAP__c = 'CA',
            IsRepresentativeVerified__c = 'N',
            DCRepresentativeId__c = 5928,
            RepresentativeRelationshipCode__c = 'EX'
        );
        insert acr;
        SSP_Application__c application = new SSP_Application__c(
            DCCaseNumber__c = 100018326,
            Account__c = acc1.Id
        );
        insert application;
        SSP_TrackDeletion__c trackDeletion = new SSP_TrackDeletion__c(
            SSP_Application__c = application.Id,
            SalesforceId__c =  acr.Id,
            SFObject__c =  'AccountContactRelation',
            Source__c =  'Representative'
        );
        insert trackDeletion;

        Map<String, Object> mapInputParams = new Map<String, Object> ();
        mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_APP_ID, application.Id);
        mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_ACR, acr);

        return mapInputParams;
    }
    public class SSP_UpdateDCRepIntegrationServiceMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =   '   {  '  + 
                                '     "AckResponse": {  '  + 
                                '       "Success": true,  '  + 
                                '       "Error": {} '  + 
                                '     }  '  + 
                                '  }  ' ; 
    }

    public class SSP_UpdateDCRepIntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}