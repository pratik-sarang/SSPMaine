/*
* Classname 		:  SSP_VCIMockClass
* @description 	:  This class is to mock the response for VCI
* @author 		:  Rijia Khatun
* @date 		:  12/10/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/
public class SSP_VCIMockClass implements HttpCalloutMock {    
    // Implement this interface method    
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.                             
        HttpResponse res = new HttpResponse();
        String body =   '   {  '  + 
        '     "IsValidationError": false,  '  + 
        '     "IsValidationErrorSpecified": true,  '  + 
        '     "VCIResp": {  '  + 
        '       "ResponseMetadata": {},  '  + 
        '       "ResponseInformation": {  '  + 
        '         "ResponseInformation": [  '  + 
        '           {  '  + 
        '             "ResponseMetadata": {  '  + 
        '               "ResponseCode": "HS000000",  '  + 
        '               "ResponseDescriptionText": "Success"  '  + 
        '             },  '  + 
        '             "EmployeeInformation": {  '  + 
        '               "PersonBirthDate": {  '  + 
        '                 "Date": "0001-01-01T00:00:00"  '  + 
        '               },  '  + 
        '               "PersonName": {}  '  + 
        '             },  '  + 
        '             "CurrentIncomeInformation": {  '  + 
        '               "CurrentIncomeInformation": [  '  + 
        '                 {  '  + 
        '                   "Tier": "1",  '  + 
        '                   "AsOfDate": {  '  + 
        '                     "Date": "2013-04-20T00:00:00"  '  + 
        '                   },  '  + 
        '                   "VerificationMetadata": {  '  + 
        '                     "VerificationID": "XREF-4239903"  '  + 
        '                   },  '  + 
        '                   "EmployeeInformation": {  '  + 
        '                     "PersonBirthDate": {  '  + 
        '                       "Date": "1966-06-06T00:00:00"  '  + 
        '                     },  '  + 
        '                     "PersonName": {  '  + 
        '                       "PersonGivenName": "Mock",  '  + 
        '                       "PersonMiddleName": "M",  '  + 
        '                       "PersonSurName": "Mocker"  '  + 
        '                     },  '  + 
        '                     "PersonSSNIdentification": "765432456"  '  + 
        '                   },  '  + 
        '                   "EmployerInformation": {  '  + 
        '                     "EmployerOrganization": {  '  + 
        '                       "OrganizationIdentification": {  '  + 
        '                         "IdentificationID": "12-7654363"  '  + 
        '                       },  '  + 
        '                       "OrganizationName": "Mockrosoft"  '  + 
        '                     },  '  + 
        '                     "EmployerAddress": {  '  + 
        '                       "LocationStreet": {  '  + 
        '                         "StreetFullText": "8652CLEARMOCKTARMOCK",  '  + 
        '                         "StreetExtensionText": "Suite500"  '  + 
        '                       },  '  + 
        '                       "LocationCityName": "MOCKFORD",  '  + 
        '                       "LocationStateUSPostalServiceCode": "IN",  '  + 
        '                       "LocationPostalCode": "86457"  '  + 
        '                     }  '  + 
        '                   },  '  + 
        '                   "EmploymentInformation": {  '  + 
        '                     "EmploymentInformation": {  '  + 
        '                       "EmployeeStatusCode": 1,  '  + 
        '                       "EmployeeStatusMessage": "Active",  '  + 
        '                       "PersonEmploymentAssociation": {  '  + 
        '                         "AssociationBeginDate": {  '  + 
        '                           "Date": "2013-04-20T00:00:00"  '  + 
        '                         },  '  + 
        '                         "EmploymentOriginalHireDate": {  '  + 
        '                           "Date": "2013-04-20T00:00:00"  '  + 
        '                         }  '  + 
        '                       }  '  + 
        '                     }  '  + 
        '                   },  '  + 
        '                   "BaseCompensationInformation": {  '  + 
        '                     "BaseCompensationInformation": {  '  + 
        '                       "PayRate": {  '  + 
        '                         "IncomeAmountSpecified": false  '  + 
        '                       },  '  + 
        '                       "PayFrequencyCode": "1",  '  + 
        '                       "PayFrequencyMessage": "Annual",  '  + 
        '                       "PayPeriodFrequencyCode": "1",  '  + 
        '                       "PayPeriodFrequencyMessage": "Annual",  '  + 
        '                       "AnnualizedIncomeSpecified": false  '  + 
        '                     }  '  + 
        '                   },  '  + 
        '                   "PayPeriod": {  '  + 
        '                     "PayPeriod": [  '  + 
        '                       {  '  + 
        '                         "PayPeriodEndDate": {  '  + 
        '                           "Date": "2014-04-19T00:00:00"  '  + 
        '                         },  '  + 
        '                         "IncomeDetail": {  '  + 
        '                           "IncomeAmount": 20800,  '  + 
        '                           "IncomeHoursPerWeekMeasure": 40,  '  + 
        '                           "IncomeDate": {  '  + 
        '                             "Date": "2014-04-26T00:00:00"  '  + 
        '                           },  '  + 
        '                           "IncomeNetPaymentAmount": 18720  '  + 
        '                         }  '  + 
        '                       }  '  + 
        '                     ]  '  + 
        '                   },  '  + 
        '                   "AnnualCompensation": {  '  + 
        '                     "AnnualCompensation": [  '  + 
        '                       {  '  + 
        '                         "IncomeYear": {  '  + 
        '                           "Year": "2013"  '  + 
        '                         },  '  + 
        '                         "BaseCompensationSpecified": false,  '  + 
        '                         "TotalCompensation": 18720,  '  + 
        '                         "TotalCompensationSpecified": true  '  + 
        '                       }  '  + 
        '                     ]  '  + 
        '                   }  '  + 
        '                 }  '  + 
        '               ]  '  + 
        '             }  '  + 
        '           }  '  + 
        '         ]  '  + 
        '       }  '  + 
        '     }  '  + 
        '  }  ' ; 
        // Create a fake response            
        res.setHeader('Content-Type', 'Text');
        res.setBody(body);        
        res.setStatusCode(200);
        return res;
    }
}