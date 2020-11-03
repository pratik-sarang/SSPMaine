/**
* Class Name    : SSP_MCIMergedServiceMock
* Owner         : DELOITTE
* Created Date  : 28/11/2019
* Description   : Mock class for SSP_MCIMergedServiceUtiltiy
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_MCIMergedServiceMock implements HttpCalloutMock{
    
     public static final String stringSuccessRequestBodyforFullMatch = '   {  '  + 
        '     "Mode": "Intake",  '  + 
        '     "IndividualId": "123421123",  '  + 
        '     "Applicationnumber": "1234",  '  + 
        '     "ViewName": "SSP_APP_HHMemberDetails",  '  + 
        '      "CaseNumber": "",    ' +
        '      "IsApplicationBlocked": false,    ' + 
        '	   "BlockedCaseNumber" : "",  '+
        '     "MatchStatus": "Full Match",  '  + 
        '     "Payload": {  '  + 
        '       "SSP_Member__c": [  '  + 
        '         {  '  + 
        '           "NationalityCode__c": "AI",  '  + 
        '           "FirstName__c": "ASDFGHJ",  '  + 
        '           "MiddleInitial__c": "S",  '  + 
        '           "LastName__c": "ASDFGHJ",  '  + 
        '           "SuffixCode__c": "JR.",  '  + 
        '           "BirthDate__c": "1999-11-12",  '  +
        '           "SSN__c": "456345678",  '  + 
        '           "RaceCode__c": "IN",  '  + 
        '           "EthnicityCode__c": "CI",  '  + 
        '           "DeathDate__c": "2019-11-12",  '  + 
        '           "GenderCode__c": null,  '  + 
        '           "NoReasonSSNCode__c": "AL",  '  + 
        '           "IndividualId__c": "123421123",  '  +
        '           "MCIId__c": "MCITEST001",  '  +
        '           "SSNVerified__c": "true",  '  +
        '           "PrisonerConfinementDate__c": "2009-11-19",  '  + 
        '           "DeathConfirmationCode__c": "D123",  '  + 
        '           "HasConvictedCrime__c": "true",  '  + 
        '           "IsUSCitizen__c": "true",  '  + 
        '           "IsDateOfBirthValidated__c": "true",  ' +
        '           "IsUSCitizenValidated__c": "true",  ' +
        '           "IsDateOfDeathValidated__c": "true",  ' +
        '           "IsHeadOfHousehold__c": "true",  ' + 
        '           "PseudoSSN__c": "923923923",  '  +
        '           "CitizenShipVerificationCode__c": "Y",  '  +
        '           "SSNVerificationCode__c": "Y",  '  +
        '           "InmateStatusIndicator__c": "true",  '  + 
        '           "LifeTimeQuarterQuantity__c": "11"  '  + 
        '         }  '  + 
        '       ],  '  + 
        '       "SSP_Application__c": [  '  + 
        '         {  '  +
        '           "HasConvictedCrimeToggle__c": "N" '  +  
        '         }  '  + 
        '       ],  '  +          
        '       "SSP_ApplicationIndividual__c": [  '  + 
        '         {  '  + 
        '           "IsActiveIEESCasePresent__c": "false",  '  + 
        '           "SSP_Member__c": "123421123",  '  + 
        '           "isApplicationBlocked__c": "false",  '  +
        '           "IsHeadOfHousehold__c": "true",  ' + 
        '           "BlockedCaseNumber__c": ""  '  + 
        '         }  '  + 
        '       ]  '  +
        '     },  '  +
        '       "errorData":    {' +
        '           "errorCode": "test",  ' +
        '           "errorDescription": "test"  ' +
        '         }  '  + 
        '  }  ' ;
    
    
    public static final String stringApplicationBlockedforFullMatch = '   {  '  + 
        '     "Mode": "Intake",  '  + 
        '     "IndividualId": "123421123",  '  + 
        '     "Applicationnumber": "1234",  '  + 
        '     "ViewName": "SSP_APP_HHMemberDetails",  '  + 
        '      "CaseNumber": "",    ' +
        '      "IsApplicationBlocked": true,    ' +
        '	   "BlockedCaseNumber" : "C-12339999",  '+		
        '     "MatchStatus": "Full Match",  '  + 
        '     "Payload": {  '  + 
        '       "SSP_Member__c": [  '  + 
        '         {  '  + 
        '           "NationalityCode__c": "AI",  '  + 
        '           "FirstName__c": "ASDFGHJ",  '  + 
        '           "MiddleInitial__c": "S",  '  + 
        '           "LastName__c": "ASDFGHJ",  '  + 
        '           "SuffixCode__c": "JR.",  '  + 
        '           "BirthDate__c": "1999-11-12",  '  +
        '           "SSN__c": "456345601",  '  + 
        '           "RaceCode__c": "IN",  '  + 
        '           "EthnicityCode__c": "CI",  '  + 
        '           "DeathDate__c": "2019-11-12",  '  + 
        '           "GenderCode__c": "M",  '  + 
        '           "NoReasonSSNCode__c": "AL",  '  + 
        '           "IndividualId__c": "123421123",  '  +
        '           "MCIId__c": "MCITEST001",  '  +
        '           "SSNVerified__c": "true",  '  +
        '           "PrisonerConfinementDate__c": "2009-11-19",  '  + 
        '           "DeathConfirmationCode__c": "D123",  '  + 
        '           "HasConvictedCrime__c": "true",  '  + 
        '           "IsUSCitizen__c": "true",  '  +
        '           "IsDateOfBirthValidated__c": "true",  ' +
        '           "IsUSCitizenValidated__c": "true",  ' +
        '           "IsDateOfDeathValidated__c": "true",  ' +
        '           "PseudoSSN__c": "923923923",  '  +
        '           "CitizenShipVerificationCode__c": "Y",  '  +
        '           "SSNVerificationCode__c": "Y",  '  +
        '           "InmateStatusIndicator__c": "true",  '  + 
        '           "IsHeadOfHousehold__c": "true",  ' +
        '           "LifeTimeQuarterQuantity__c": "11"  '  + 
        '         }  '  + 
        '       ],  '  + 
        '       "SSP_ApplicationIndividual__c": [  '  + 
        '         {  '  + 
        '           "IsActiveIEESCasePresent__c": "false",  '  + 
        '           "SSP_Member__c": "123421123",  '  +
        '           "isApplicationBlocked__c": "true",  '  + 
        '           "BlockedCaseNumber__c": "C-12339999"  '  + 
        '         }  '  + 
        '       ]  '  +
        '     },  '  +
        '       "errorData":    {' +
        '           "errorCode": "",  ' +
        '           "errorDescription": ""  ' +
        '         }  '  + 
        '  }  ' ;
    
    
    public static final string StringForHOHwithAdditionalOneIndividual = '   {  '  + 
        '     "Mode": "Intake",  '  + 
        '     "IndividualId": "123421125",  '  + 
        '     "Applicationnumber": "1234",  '  + 
        '     "ViewName": "SSP_APP_HHMemberDetails",  '  + 
        '      "CaseNumber": "",    ' +
        '      "IsApplicationBlocked": false,    ' + 
        '	   "BlockedCaseNumber" : "",  '+
        '     "MatchStatus": "Full Match",  '  + 
        '     "Payload": {  '  + 
        '       "SSP_Member__c": [  '  + 
        '         {  '  + 
        '           "NationalityCode__c": "AI",  '  + 
        '           "FirstName__c": "ASDFGHJ",  '  + 
        '           "MiddleInitial__c": "S",  '  + 
        '           "LastName__c": "ASDFGHJ",  '  + 
        '           "SuffixCode__c": "JR.",  '  + 
        '           "BirthDate__c": "1999-11-12",  '  +
        '           "SSN__c": "456345602",  '  + 
        '           "RaceCode__c": "IN",  '  + 
        '           "EthnicityCode__c": "CI",  '  + 
        '           "DeathDate__c": "2019-11-12",  '  + 
        '           "GenderCode__c": "M",  '  + 
        '           "NoReasonSSNCode__c": "AL",  '  + 
        '           "IndividualId__c": "123421125",  '  +
        '           "MCIId__c": "MCITEST001",  '  +
        '           "SSNVerified__c": "true",  '  +
        '           "PrisonerConfinementDate__c": "2009-11-19",  '  + 
        '           "DeathConfirmationCode__c": "D123",  '  + 
        '           "HasConvictedCrime__c": "true",  '  + 
        '           "IsUSCitizen__c": "true",  '  + 
        '           "IsDateOfBirthValidated__c": "true",  ' +
        '           "IsUSCitizenValidated__c": "true",  ' +
        '           "IsDateOfDeathValidated__c": "true",  ' +
        '           "PseudoSSN__c": "923923923",  '  +
        '           "CitizenShipVerificationCode__c": "Y",  '  +
        '           "SSNVerificationCode__c": "Y",  '  +
        '           "InmateStatusIndicator__c": "true",  '  + 
        '           "IsHeadOfHousehold__c": "true",  ' +
        '           "LifeTimeQuarterQuantity__c": "11"  '  + 
        '         },  '  + 
		'         {  '  + 
        '           "NationalityCode__c": "AI",  '  + 
        '           "FirstName__c": "ASDFGHJ",  '  + 
        '           "MiddleInitial__c": "S",  '  + 
        '           "LastName__c": "ASDFGHJ",  '  + 
        '           "SuffixCode__c": "JR.",  '  + 
        '           "BirthDate__c": "1999-11-12",  '  +
        '           "SSN__c": "456345603",  '  + 
        '           "RaceCode__c": "IN",  '  + 
        '           "EthnicityCode__c": "CI",  '  + 
        '           "DeathDate__c": "2019-11-12",  '  + 
        '           "GenderCode__c": "M",  '  + 
        '           "NoReasonSSNCode__c": "AL",  '  + 
        '           "IndividualId__c": "123421124",  '  +
        '           "MCIId__c": "MCITEST002",  '  +
        '           "SSNVerified__c": "true",  '  +
        '           "PrisonerConfinementDate__c": "2009-11-19",  '  + 
        '           "DeathConfirmationCode__c": "D123",  '  + 
        '           "HasConvictedCrime__c": "true",  '  + 
        '           "IsUSCitizen__c": "true",  '  +
        '           "IsDateOfBirthValidated__c": "true",  ' +
        '           "IsUSCitizenValidated__c": "true",  ' +
        '           "IsDateOfDeathValidated__c": "true",  ' +
        '           "PseudoSSN__c": "923923923",  '  +
        '           "CitizenShipVerificationCode__c": "Y",  '  +
        '           "SSNVerificationCode__c": "Y",  '  +
        '           "InmateStatusIndicator__c": "true",  '  + 
        '           "IsHeadOfHousehold__c": "false",  ' +
        '           "LifeTimeQuarterQuantity__c": "11"  '  + 
        '         }  '  +
        '       ],  '  + 
        '       "SSP_ApplicationIndividual__c": [  '  + 
        '         {  '  + 
        '           "IsActiveIEESCasePresent__c": "false",  '  + 
        '           "SSP_Member__c": "123421125",  '  + 
        '           "isApplicationBlocked__c": "false",  '  + 
        '           "BlockedCaseNumber__c": ""  '  + 
        '         },  '  + 
		'         {  '  + 
        '           "IsActiveIEESCasePresent__c": "false",  '  + 
        '           "SSP_Member__c": "123421124",  '  +
        '           "isApplicationBlocked__c": "false",  '  + 
        '           "BlockedCaseNumber__c": ""  '  + 
        '         }  '  +
        '       ]  '  +
        '     },  '  +
        '       "errorData":    {' +
        '           "errorCode": "",  ' +
        '           "errorDescription": ""  ' +
        '         }  '  + 
        '  }  ' ;
    
    
    public static final string StringSSNFailure = '{'+
        '   "Mode": "Intake",   '+
        '   "IndividualId": "123421134",    '+
        '   "Applicationnumber": "C-123445132", '+
        '   "ViewName": "SSP_APP_HHMemberDetails",  '+
        '   "CaseNumber": "",   ' +
        '    "IsApplicationBlocked": false,    ' + 
        '	   "BlockedCaseNumber" : "",  '+
        '   "MatchStatus": "",  '+
        '   "Payload": "",  '+
        '   "errorData":    {   '+
        '  "errorCode": "ERRSSN001",    '+
        '   "errorDescription": "No match found"    '+
        '   }'+
        '}';
    
    public static string NoMatchGotNewIndividual = '   {  '  + 
        '     "Mode": "Intake",  '  + 
        '     "IndividualId": "12342999",  '  + 
        '     "Applicationnumber": "1234",  '  + 
        '      "CaseNumber": "",    ' +
        '      "IsApplicationBlocked": false,    ' + 
        '	   "BlockedCaseNumber" : "",  '+
        '     "ViewName": "SSP_APP_HHMemberDetails",  '  + 
        '     "MatchStatus": "No Match",  '  + 
        '     "Payload": {  '  + 
        '       "SSP_Member__c": [  '  + 
        '         {  '  + 
        '           "NationalityCode__c": "AI",  '  + 
        '           "FirstName__c": "ASDFGHJ",  '  + 
        '           "MiddleInitial__c": "S",  '  + 
        '           "LastName__c": "ASDFGHJ",  '  + 
        '           "SuffixCode__c": "JR.",  '  + 
        '           "BirthDate__c": "1999-11-12",  '  +
        '           "SSN__c": "456345604",  '  + 
        '           "RaceCode__c": "IN",  '  + 
        '           "EthnicityCode__c": "CI",  '  + 
        '           "DeathDate__c": "2019-11-12",  '  + 
        '           "GenderCode__c": "M",  '  + 
        '           "NoReasonSSNCode__c": "AL",  '  + 
        '           "IndividualId__c": "123429998",  '  +
        '           "MCIId__c": "MCITEST009",  '  +
        '           "SSNVerified__c": "true",  '  +
        '           "PrisonerConfinementDate__c": "2009-11-19",  '  + 
        '           "DeathConfirmationCode__c": "D123",  '  + 
        '           "HasConvictedCrime__c": "true",  '  + 
        '           "IsUSCitizen__c": "true",  '  +
        '           "IsDateOfBirthValidated__c": "true",  ' +
        '           "IsUSCitizenValidated__c": "true",  ' +
        '           "IsDateOfDeathValidated__c": "true",  ' +
        '           "PseudoSSN__c": "923923923",  '  +
        '           "CitizenShipVerificationCode__c": "Y",  '  +
        '           "SSNVerificationCode__c": "Y",  '  +
        '           "IsHeadOfHousehold__c": "false",  ' +
        '           "InmateStatusIndicator__c": "true",  '  + 
        '           "LifeTimeQuarterQuantity__c": "11"  '  + 
        '         }  '  + 
        '       ],  '  + 
        '       "SSP_ApplicationIndividual__c": [  '  + 
        '         {  '  + 
        '           "IsActiveIEESCasePresent__c": "false",  '  + 
        '           "SSP_Member__c": "123429998",  '  + 
        '           "isApplicationBlocked__c": "false",  '  + 
        '           "BlockedCaseNumber__c": ""  '  + 
        '         }  '  + 
        '       ]  '  +
        '     },  '  +
        '       "errorData":    {' +
        '           "errorCode": "",  ' +
        '           "errorDescription": ""  ' +
        '         }  '  + 
        '  }  ' ;
    
    public static string CatchExceptioninProcessResponse = '   {  '  + 
        '     "Mode": "Intake",  '  + 
        '     "IndividualId": "12342999",  '  + 
        '     "Applicationnumber": "1234",  '  + 
        '      "CaseNumber": "",    ' +
        '      "IsApplicationBlocked": false,    ' + 
        '	   "BlockedCaseNumber" : "",  '+
        '     "ViewName": "SSP_APP_HHMemberDetails",  '  + 
        '     "MatchStatus": "No Match",  '  + 
        '     "Payload": {  '  + 
        '       "SSP_Member__c": [  '  + 
        '         {  '  + 
        '           "NationalityCode__c": "AI",  '  + 
        '           "FirstName__c": "ASDFGHJ",  '  + 
        '           "MiddleInitial__c": "S",  '  + 
        '           "LastName__c": "ASDFGHJ",  '  + 
        '           "SuffixCode__c": "JR.",  '  + 
        '           "BirthDate__c": "1999-11-12",  '  +
        '           "SSN__c": "456345604",  '  + 
        '           "RaceCode__c": "IN",  '  + 
        '           "EthnicityCode__c": "CI",  '  + 
        '           "DeathDate__c": "2019-11-12",  '  + 
        '           "GenderCode__c": "M",  '  + 
        '           "NoReasonSSNCode__c": "AL",  '  + 
        '           "IndividualId__c": "123429998",  '  +
        '           "MCIId__c": "MCITEST009",  '  +
        '           "SSNVerified__c": "true",  '  +
        '           "PrisonerConfinementDate__c": "2009-11-19T00:00:00Z",  '  + 
        '           "DeathConfirmationCode__c": "D123",  '  + 
        '           "HasConvictedCrime__c": "true",  '  + 
        '           "IsUSCitizen__c": "true",  '  +
        '           "IsDateOfBirthValidated__c": "true",  ' +
        '           "IsUSCitizenValidated__c": "true",  ' +
        '           "IsDateOfDeathValidated__c": "true",  ' +
        '           "PseudoSSN__c": "923923923",  '  +
        '           "CitizenShipVerificationCode__c": "Y",  '  +
        '           "SSNVerificationCode__c": "Y",  '  +
        '           "IsHeadOfHousehold__c": "false",  ' +
        '           "InmateStatusIndicator__c": "true",  '  + 
        '           "LifeTimeQuarterQuantity__c": "11"  '  + 
        '         }  '  + 
        '       ],  '  + 
        '       "SSP_ApplicationIndividual__c": [  '  + 
        '         {  '  + 
        '           "IsActiveIEESCasePresent__c": "false",  '  + 
        '           "SSP_Member__c": "123429998",  '  + 
        '           "isApplicationBlocked__c": "false",  '  + 
        '           "BlockedCaseNumber__c": ""  '  + 
        '         }  '  + 
        '       ]  '  +
        '     },  '  +
        '       "errorData":    {' +
        '           "errorCode": "",  ' +
        '           "errorDescription": ""  ' +
        '         }  '  + 
        '  }  ' ;
    
    public static final string partialMatchGotNewIndividual = '   {  '  + 
        '     "Mode": "Intake",  '  + 
        '     "IndividualId": "123429588",  '  + 
        '     "Applicationnumber": "1234",  '  + 
        '      "CaseNumber": "",    ' +
        '      "IsApplicationBlocked": false,    ' + 
        '	   "BlockedCaseNumber" : "",  '+
        '     "ViewName": "SSP_APP_HHMemberDetails",  '  + 
        '     "MatchStatus": "Partial Match",  '  + 
        '     "Payload": {  '  + 
        '       "SSP_Member__c": [  '  + 
        '         {  '  + 
        '           "NationalityCode__c": "AI",  '  + 
        '           "FirstName__c": "ASDFGHJ",  '  + 
        '           "MiddleInitial__c": "S",  '  + 
        '           "LastName__c": "ASDFGHJ",  '  + 
        '           "SuffixCode__c": "JR.",  '  + 
        '           "BirthDate__c": "1999-11-12",  '  +
        '           "SSN__c": "456345605",  '  + 
        '           "RaceCode__c": "IN",  '  + 
        '           "EthnicityCode__c": "CI",  '  + 
        '           "DeathDate__c": "2019-11-12",  '  + 
        '           "GenderCode__c": "M",  '  + 
        '           "NoReasonSSNCode__c": "AL",  '  + 
        '           "IndividualId__c": "123429588",  '  +
        '           "MCIId__c": "MCITEST008",  '  +
        '           "SSNVerified__c": "true",  '  +
        '           "PrisonerConfinementDate__c": "2009-11-19",  '  + 
        '           "DeathConfirmationCode__c": "D123",  '  + 
        '           "HasConvictedCrime__c": "true",  '  + 
        '           "IsUSCitizen__c": "true",  '  +
        '           "IsDateOfBirthValidated__c": "true",  ' +
        '           "IsUSCitizenValidated__c": "true",  ' +
        '           "IsDateOfDeathValidated__c": "true",  ' +
        '           "PseudoSSN__c": "923923923",  '  +
        '           "CitizenShipVerificationCode__c": "Y",  '  +
        '           "SSNVerificationCode__c": "Y",  '  +
        '           "IsHeadOfHousehold__c": "false",  ' +
        '           "InmateStatusIndicator__c": "true",  '  + 
        '           "LifeTimeQuarterQuantity__c": "11"  '  + 
        '         }  '  + 
        '       ],  '  + 
        '       "SSP_ApplicationIndividual__c": [  '  + 
        '         {  '  + 
        '           "IsActiveIEESCasePresent__c": "false",  '  + 
        '           "SSP_Member__c": "123429588",  '  + 
        '           "isApplicationBlocked__c": "false",  '  + 
        '           "BlockedCaseNumber__c": ""  '  + 
        '         }  '  + 
        '       ]  '  +
        '     },  '  +
        '       "errorData":    {' +
        '           "errorCode": "",  ' +
        '           "errorDescription": ""  ' +
        '         }  '  + 
        '  }  ' ;
    
    public static final string stringMuleException =  '{'+
        '   "Mode": "Intake",   '+
        '   "IndividualId": "", '+
        '   "Applicationnumber": "C-123445132", '+
        '    "IsApplicationBlocked": false,    ' + 
        '	   "BlockedCaseNumber" : "",  '+
        '   "ViewName": "SSP_APP_HHMemberDetails",  '+
        '   "CaseNumber": "",   ' +
        '   "MatchStatus": "",  '+
        '   "Payload": null,  '+
        '   "errorData":    {   '+
        '  "errorCode": "INT1000",  '+
        '   "errorDescription": "Trusted Data Source System Unavailable/Unreachable"    '+
        '   }'+
        '}';
    public static final string sDocumentDownloadSuccessResponse = 'testblob';
    protected string interfaceName;
    protected Integer code;
    protected boolean isError;
    protected string matchtype;
    public SSP_MCIMergedServiceMock(string interfaceName,Integer code,boolean isError,string matchtype){
        this.interfaceName = interfaceName;
        this.code = code;
        this.isError= isError;
        this.matchtype = matchtype;
    }
    
 public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
     string body = '';
      if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'Full Match'){
         body = stringSuccessRequestBodyforFullMatch;
         response.setStatus('Success');
         response.setStatusCode(200);
     }
     else if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'SSN Exception'){
         body = StringSSNFailure;
         response.setStatus('Exception');
         response.setStatusCode(200);
     }	
     else if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'Parital Match'){
         body = partialMatchGotNewIndividual;
         response.setStatus('Success');
         response.setStatusCode(200);
     }	
      else if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'No Match with New Individual'){
         body = NoMatchGotNewIndividual;
           response.setStatus('Success');
         response.setStatusCode(200);
     }
     else if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'Exception in Data'){
         body = CatchExceptioninProcessResponse;
           response.setStatus('Success');
         response.setStatusCode(200);
     }	
      else if(interfaceName == 'MCIMergedService' && code == 500 && matchtype == 'Mule Exception'){
         body = stringMuleException;
           response.setStatus('Exception');
         response.setStatusCode(500);
     }	
     else if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'Mule Exception'){
         body = stringMuleException;
           response.setStatus('Exception');
         response.setStatusCode(200);
     }	
     else if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'HOH Full Match'){
         body = StringForHOHwithAdditionalOneIndividual;
         response.setStatus('Success');
         response.setStatusCode(200);
     }
     else if(interfaceName == 'MCIMergedService' && code == 200 && matchtype == 'Application Block'){
          body = stringApplicationBlockedforFullMatch;
         response.setStatus('Success');
          response.setStatusCode(200);
     }
     else if(interfaceName == 'DocDownloadService' && code == 200){
          body = sDocumentDownloadSuccessResponse;
         response.setStatus('Success');
          response.setStatusCode(200);
     }
        response.setBody(body);
        
        return response; 
    }
}