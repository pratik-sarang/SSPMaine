@isTest
public class SSP_NONESIMECServiceMock implements HttpCalloutMock {
    // Implement this interface method   
    
    public static final String successbody ='{'+
		'    "IsValidationError": false,'+
		'    "VerifyNonESIMECResp": {'+
		'        "NonESIMECIndividualResp": ['+
		'            {'+
		'                "Applicant": {'+
		'                    "PersonBirthDate": "1993-09-09T00:00:00",'+
		'                    "PersonName": {'+
		'                        "PersonGivenName": "HORST",'+
		'                        "PersonMiddleName": "U",'+
		'                        "PersonSurName": "BRAVOS"'+
		'                    },'+
		'                    "PersonSex": "M",'+
		'                    "PersonSSNIdentification": "123222333"'+
		'                },'+
		'                "OtherCoverage": ['+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": ['+
		'                                {'+
		'                                    "InsuranceEffectiveDate": "2015-01-01T00:00:00",'+
		'                                    "InsuranceEndDate": "2016-12-31T00:00:00",'+
		'                                    "InsuranceEndDateSpecified1": true'+
		'                                }'+
		'                            ],'+
		'                            "MECVerificationCode": "Y"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HS000000",'+
		'                            "ResponseDescriptionText": "Success",'+
		'                            "TDSResponseDescriptionText": "HS000000"'+
		'                        },'+
		'                        "OrganizationCode": "MEDI"'+
		'                    },'+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": [],'+
		'                            "MECVerificationCode": "N"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HE009999",'+
		'                            "ResponseDescriptionText": "Unexpected Response Code (com.ctc.wstx.exc.WstxEOFException)",'+
		'                            "TDSResponseDescriptionText": "HE009999"'+
		'                        },'+
		'                        "OrganizationCode": "VHPC"'+
		'                    },'+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": [],'+
		'                            "MECVerificationCode": "N"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HE009999",'+
		'                            "ResponseDescriptionText": "Unexpected Response Code (org.xml.sax.SAXParseException)",'+
		'                            "TDSResponseDescriptionText": "HE009999"'+
		'                        },'+
		'                        "OrganizationCode": "TRIC"'+
		'                    },'+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": [],'+
		'                            "MECVerificationCode": "N"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HE000001",'+
		'                            "ResponseDescriptionText": "Applicant Not Found",'+
		'                            "TDSResponseDescriptionText": "HE000001"'+
		'                        },'+
		'                        "OrganizationCode": "PECO"'+
		'                    }'+
		'                ],'+
		'                "PartialResponseIndicator": false'+
		'            },'+
		'            {'+
		'                "Applicant": {'+
		'                    "PersonBirthDate": "1993-09-09T00:00:00",'+
		'                    "PersonName": {'+
		'                        "PersonGivenName": "HORST",'+
		'                        "PersonMiddleName": "U",'+
		'                        "PersonSurName": "BRAVOS"'+
		'                    },'+
		'                    "PersonSex": "M",'+
		'                    "PersonSSNIdentification": "123222334"'+
		'                },'+
		'                "OtherCoverage": ['+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": ['+
		'                                {'+
		'                                    "InsuranceEffectiveDate": "2015-01-01T00:00:00",'+
		'                                    "InsuranceEndDate": "2016-12-31T00:00:00",'+
		'                                    "InsuranceEndDateSpecified1": true'+
		'                                }'+
		'                            ],'+
		'                            "MECVerificationCode": "Y"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HS000000",'+
		'                            "ResponseDescriptionText": "Success",'+
		'                            "TDSResponseDescriptionText": "HS000000"'+
		'                        },'+
		'                        "OrganizationCode": "MEDI"'+
		'                    },'+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": [],'+
		'                            "MECVerificationCode": "N"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HE009999",'+
		'                            "ResponseDescriptionText": "Unexpected Response Code (com.ctc.wstx.exc.WstxEOFException)",'+
		'                            "TDSResponseDescriptionText": "HE009999"'+
		'                        },'+
		'                        "OrganizationCode": "VHPC"'+
		'                    },'+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": [],'+
		'                            "MECVerificationCode": "N"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HE009999",'+
		'                            "ResponseDescriptionText": "Unexpected Response Code (org.xml.sax.SAXParseException)",'+
		'                            "TDSResponseDescriptionText": "HE009999"'+
		'                        },'+
		'                        "OrganizationCode": "TRIC"'+
		'                    },'+
		'                    {'+
		'                        "MECCoverage": {'+
		'                            "Insurance": [],'+
		'                            "MECVerificationCode": "N"'+
		'                        },'+
		'                        "NonESIMECMetadataResponse": {'+
		'                            "ResponseCode": "HE000001",'+
		'                            "ResponseDescriptionText": "Applicant Not Found",'+
		'                            "TDSResponseDescriptionText": "HE000001"'+
		'                        },'+
		'                        "OrganizationCode": "PECO"'+
		'                    }'+
		'                ],'+
		'                "PartialResponseIndicator": false'+
		'            }'+
		'        ]'+
		'    }'+
		'}';
    
     public static final string  successException = '{'+
		'  "AckResponse": {'+
		'    "AckResponseCode": "HBE9000",'+
		'    "AckResponseDescription": "System Exception"'+
		'  }'+
		'}';

    
    protected Integer code;
    protected boolean isscuess;
    public SSP_NONESIMECServiceMock(Integer code,boolean isscuess){
        this.code = code;
        this.isscuess =  isscuess;
    }
    public HTTPResponse respond(HTTPRequest req) {
        
        // Optionally, only send a mock response for a specific endpoint and method.                             
        HttpResponse res = new HttpResponse();        
        // Create a fake response            
        res.setHeader('Content-Type', 'Text');
        string body = '';
        if(code == 200 && isscuess){
            body = successbody;
            res.setStatus('Success');
            res.setStatusCode(200);
        }
        else if(code == 200 && !isscuess){
            body = successException;
            res.setStatus('Success');
            res.setStatusCode(200);
        }
        else{
            body = 'Exception';
        }
        res.setBody(body);        
        res.setStatusCode(code);
        return res;
    }
    
}
