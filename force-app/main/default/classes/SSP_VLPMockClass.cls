/*
* Classname         :  SSP_VLPMockClass
* @description  :  This class is to mock the response for VLP
* @author       :  Rijia Khatun
* @date         :  12/10/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
public class SSP_VLPMockClass implements HttpCalloutMock {
    // Implement this interface method    
    public HTTPResponse respond(HTTPRequest req) {
                // Optionally, only send a mock response for a specific endpoint and method.                             
                HttpResponse res = new HttpResponse();
                String body =    '   {  '  + 
         '     "IsValidationError": true,  '  + 
         '     "ResponseMetadataDetails": {  '  + 
         '       "ResponseCode": "ResponseCode_0",  '  + 
         '       "ResponseDescriptionText": "ResponseDescriptionText_0",  '  + 
         '       "TDSResponseDescriptionText": "TDSResponseDescriptionText_0"  '  + 
         '     },  '  + 
         '     "ValidationResult": {  '  + 
         '       "ValidationOutput": [  '  + 
         '         {  '  + 
         '           "ErrorCode": "ErrorCode_0",  '  + 
         '           "ErrorDescription": "ErrorDescription_0"  '  + 
         '         },  '  + 
         '         {  '  + 
         '           "ErrorCode": "ErrorCode_0",  '  + 
         '           "ErrorDescription": "ErrorDescription_0"  '  + 
         '         },  '  + 
         '         {  '  + 
         '           "ErrorCode": "ErrorCode_0",  '  + 
         '           "ErrorDescription": "ErrorDescription_0"  '  + 
         '         }  '  + 
         '       ]  '  + 
         '     },  '  + 
         '     "VerifyLawfulResponse": {  '  + 
         '       "LawfulPresenceIndividualResponse": [  '  + 
         '         {  '  + 
         '           "LawfulPresenceServiceResponseField": {  '  + 
         '             "CaseNbr": "CaseNbr_0",  '  + 
         '             "CaseSentToSecondaryIndicator": true,  '  + 
         '             "DSHAutoTriggerStepTwo": "DSHAutoTriggerStepTwo_0",  '  + 
         '             "EligStatementCd": "EligStatementCd_0",  '  + 
         '             "EligStatementTxt": "EligStatementTxt_0",  '  + 
         '             "FiveYearBarIndicator": "FiveYearBarIndicator_0",  '  + 
         '             "FiveYearBarMetIndicator": "FiveYearBarMetIndicator_0",  '  + 
         '             "GrantDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "GrantDateReasonCd": "GrantDateReasonCd_0",  '  + 
         '             "IavTypeCode": "IavTypeCode_0",  '  + 
         '             "IavTypeTxt": "IavTypeTxt_0",  '  + 
         '             "NonCitAdmittedToDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitAdmittedToText": "NonCitAdmittedToText_0",  '  + 
         '             "NonCitBirthDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitCoaCode": "NonCitCoaCode_0",  '  + 
         '             "NonCitCountryBirthCd": "NonCitCountryBirthCd_0",  '  + 
         '             "NonCitCountryCitCd": "NonCitCountryCitCd_0",  '  + 
         '             "NonCitEadsExpireDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitEntryDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitFirstName": "NonCitFirstName_0",  '  + 
         '             "NonCitLastName": "NonCitLastName_0",  '  + 
         '             "NonCitMiddleName": "NonCitMiddleName_0",  '  + 
         '             "PhotoIncludedIndicator": true,  '  + 
         '             "QualifiedNonCitizenIndicator": "QualifiedNonCitizenIndicator_0",  '  + 
         '             "SponsorDataFoundIndicator": true,  '  + 
         '             "SponsorshipData": {  '  + 
         '               "SponsorshipData": [  '  + 
         '                 {  '  + 
         '                   "Address1": "Address1_0",  '  + 
         '                   "Address2": "Address2_0",  '  + 
         '                   "City": "City_0",  '  + 
         '                   "FirstName": "FirstName_0",  '  + 
         '                   "LastName": "LastName_0",  '  + 
         '                   "MiddleName": "MiddleName_0",  '  + 
         '                   "Ssn": "Ssn_0",  '  + 
         '                   "StateCode": "StateCode_0",  '  + 
         '                   "ZipCode": "ZipCode_0"  '  + 
         '                 },  '  + 
         '                 {  '  + 
         '                   "Address1": "Address1_0",  '  + 
         '                   "Address2": "Address2_0",  '  + 
         '                   "City": "City_0",  '  + 
         '                   "FirstName": "FirstName_0",  '  + 
         '                   "LastName": "LastName_0",  '  + 
         '                   "MiddleName": "MiddleName_0",  '  + 
         '                   "Ssn": "Ssn_0",  '  + 
         '                   "StateCode": "StateCode_0",  '  + 
         '                   "ZipCode": "ZipCode_0"  '  + 
         '                 }  '  + 
         '               ]  '  + 
         '             },  '  + 
         '             "SponsorshipReasonCd": "SponsorshipReasonCd_0",  '  + 
         '             "UsCitizenCode": "UsCitizenCode_0",  '  + 
         '             "WebServSftwrVer": "WebServSftwrVer_0"  '  + 
         '           },  '  + 
         '           "LawfulPresenceVerified": "LawfulPresenceVerified_0",  '  + 
         '           "ResponseMetadataDetails": {  '  + 
         '             "ResponseCode": "ResponseCode_0",  '  + 
         '             "ResponseDescriptionText": "ResponseDescriptionText_0",  '  + 
         '             "TDSResponseDescriptionText": "TDSResponseDescriptionText_0"  '  + 
         '           }  '  + 
         '         },  '  + 
         '         {  '  + 
         '           "LawfulPresenceServiceResponseField": {  '  + 
         '             "CaseNbr": "CaseNbr_0",  '  + 
         '             "CaseSentToSecondaryIndicator": true,  '  + 
         '             "DSHAutoTriggerStepTwo": "DSHAutoTriggerStepTwo_0",  '  + 
         '             "EligStatementCd": "EligStatementCd_0",  '  + 
         '             "EligStatementTxt": "EligStatementTxt_0",  '  + 
         '             "FiveYearBarIndicator": "FiveYearBarIndicator_0",  '  + 
         '             "FiveYearBarMetIndicator": "FiveYearBarMetIndicator_0",  '  + 
         '             "GrantDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "GrantDateReasonCd": "GrantDateReasonCd_0",  '  + 
         '             "IavTypeCode": "IavTypeCode_0",  '  + 
         '             "IavTypeTxt": "IavTypeTxt_0",  '  + 
         '             "NonCitAdmittedToDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitAdmittedToText": "NonCitAdmittedToText_0",  '  + 
         '             "NonCitBirthDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitCoaCode": "NonCitCoaCode_0",  '  + 
         '             "NonCitCountryBirthCd": "NonCitCountryBirthCd_0",  '  + 
         '             "NonCitCountryCitCd": "NonCitCountryCitCd_0",  '  + 
         '             "NonCitEadsExpireDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitEntryDate": "1999-05-31T14:20:00-04:00",  '  + 
         '             "NonCitFirstName": "NonCitFirstName_0",  '  + 
         '             "NonCitLastName": "NonCitLastName_0",  '  + 
         '             "NonCitMiddleName": "NonCitMiddleName_0",  '  + 
         '             "PhotoIncludedIndicator": true,  '  + 
         '             "QualifiedNonCitizenIndicator": "QualifiedNonCitizenIndicator_0",  '  + 
         '             "SponsorDataFoundIndicator": true,  '  + 
         '             "SponsorshipData": {  '  + 
         '               "SponsorshipData": [  '  + 
         '                 {  '  + 
         '                   "Address1": "Address1_0",  '  + 
         '                   "Address2": "Address2_0",  '  + 
         '                   "City": "City_0",  '  + 
         '                   "FirstName": "FirstName_0",  '  + 
         '                   "LastName": "LastName_0",  '  + 
         '                   "MiddleName": "MiddleName_0",  '  + 
         '                   "Ssn": "Ssn_0",  '  + 
         '                   "StateCode": "StateCode_0",  '  + 
         '                   "ZipCode": "ZipCode_0"  '  + 
         '                 },  '  + 
         '                 {  '  + 
         '                   "Address1": "Address1_0",  '  + 
         '                   "Address2": "Address2_0",  '  + 
         '                   "City": "City_0",  '  + 
         '                   "FirstName": "FirstName_0",  '  + 
         '                   "LastName": "LastName_0",  '  + 
         '                   "MiddleName": "MiddleName_0",  '  + 
         '                   "Ssn": "Ssn_0",  '  + 
         '                   "StateCode": "StateCode_0",  '  + 
         '                   "ZipCode": "ZipCode_0"  '  + 
         '                 }  '  + 
         '               ]  '  + 
         '             },  '  + 
         '             "SponsorshipReasonCd": "SponsorshipReasonCd_0",  '  + 
         '             "UsCitizenCode": "UsCitizenCode_0",  '  + 
         '             "WebServSftwrVer": "WebServSftwrVer_0"  '  + 
         '           },  '  + 
         '           "LawfulPresenceVerified": "LawfulPresenceVerified_0",  '  + 
         '           "ResponseMetadataDetails": {  '  + 
         '             "ResponseCode": "ResponseCode_0",  '  + 
         '             "ResponseDescriptionText": "ResponseDescriptionText_0",  '  + 
         '             "TDSResponseDescriptionText": "TDSResponseDescriptionText_0"  '  + 
         '           }  '  + 
         '         }  '  + 
         '       ]  '  + 
         '     }  '  + 
         '   }  '  + 
         '    ' ; 
        // Create a fake response            
        res.setHeader('Content-Type', 'Text');
        res.setBody(body);        
        res.setStatusCode(200);
        return res;
    }
}