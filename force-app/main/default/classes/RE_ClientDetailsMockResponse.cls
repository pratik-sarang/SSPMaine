/**
* Class Name    : RE_ClientDetailsMockResponse
* Owner         : DELOITTE
* Created Date  : 11/19/2019
* Description   : Test response for Client Deatils 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  11/19/2019                 Initial Version
*  
**/
@isTest
global class RE_ClientDetailsMockResponse implements HttpCalloutMock {
    public String scenario='';
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(scenario=='resultzero'){
            res.setBody('{"matchResult": 0,"memberData": {"individualId": 920052997,"firstName": "ashap","lastName": "Ryan","gender": "M","dob": "1957-02-02","addressData": {"addressType": "PH","addressLine1": "Dents Run, #4","addressLine2": "Second Level Address","city": "Mannington","county": "078","state": "KY","zipCode": "26582-"},"contactData": {"PreferredNotificationMethodCode": "Email","email":"ryan@yahoo.com","phoneNumber": "5555551212"},"programData": {"programs": [{"assistanceType": "MA","eligibilityBeginDate": "2019-11-01","eligibilityEndDate": "","renewalDate": "2020-10-31"}]}},"houseHoldMembersData": {"houseHoldMembers": [{"firstName": "ashaii","lastName": "Ryan","gender": "F","dob": "1992-01-24","relationship": "Daughter"}]},"errorData": {"errorCode":"SDH0000","errorDescription": ""}}');
        }else if(scenario=='errorScenario'){
            res.setBody('{"matchResult": 0,"memberData": {"individualId": 920052997,"firstName": "ashap","lastName": "Ryan","gender": "M","dob": "1957-02-02","addressData": {"addressType": "PH","addressLine1": "Dents Run, #4","addressLine2": "Second Level Address","city": "Mannington","county": "078","state": "KY","zipCode": "26582-"},"contactData": {"PreferredNotificationMethodCode": "Email","email":"ryan@yahoo.com","phoneNumber": "5555551212"},"programData": {"programs": [{"assistanceType": "MA","eligibilityBeginDate": "2019-11-01","eligibilityEndDate": "","renewalDate": "2020-10-31"}]}},"houseHoldMembersData": {"houseHoldMembers": [{"firstName": "ashaii","lastName": "Ryan","gender": "F","dob": "1992-01-24","relationship": "Daughter"}]},"errorData": {"errorCode":"SDH0001","errorDescription": ""}}');
        }else if(scenario=='exception'){
            res.setBody('{"matchResult": 0,"memberData": {"individualId": 920052997,"firstName": "ashap","lastName": "Ryan","gender": "M","dob": "1957-02-02","addressData": {"addressType": "PH","addressLine1": "Dents Run, #4","addressLine2": "Second Level Address","city": "Mannington","county": "078","state": "KY","zipCode": "26582-"},"contactData": {"PreferredNotificationMethodCode": "Email""email":"ryan@yahoo.com","phoneNumber": "5555551212"},"programData": {"programs": [{"assistanceType": "MA","eligibilityBeginDate": "2019-11-01","eligibilityEndDate": "","renewalDate": "2020-10-31"}]}},"houseHoldMembersData": {"houseHoldMembers": [{"firstName": "ashaii","lastName": "Ryan","gender": "F","dob": "1992-01-24","relationship": "Daughter"}]},"errorData": {"errorCode":"SDH0001","errorDescription": ""}}');
        }else{
        res.setBody('{"matchResult": 1,"memberData": {"individualId": 920052997,"firstName": "ashap","lastName": "Ryan","gender": "M","dob": "1957-02-02","addressData": {"addressType": "PH","addressLine1": "Dents Run, #4","addressLine2": "Second Level Address","city": "Mannington","county": "078","state": "KY","zipCode": "26582-"},"contactData": {"PreferredNotificationMethodCode": "Email","email":"ryan@yahoo.com","phoneNumber": "5555551212"},"programData": {"programs": [{"assistanceType": "MA","eligibilityBeginDate": "2019-11-01","eligibilityEndDate": "","renewalDate": "2020-10-31"}]}},"houseHoldMembersData": {"houseHoldMembers": [{"firstName": "ashaii","lastName": "Ryan","gender": "F","dob": "1992-01-24","relationship": "Daughter"}]},"errorData": {"errorCode":"SDH0000","errorDescription": ""}}');
        }
        res.setStatusCode(200);
        return res;
    }
}