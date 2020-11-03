@isTest
public class SSP_ClaimsAndPayments_HttpMocktest implements HttpCalloutMock{
    public String callView;
    public SSP_ClaimsAndPayments_HttpMocktest(String callView){
        this.callView=callView;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body='';        
        if(callView=='getScreenData'){
            body='{"viewName":"ClaimsOverview","caseNumber":0,"primaryApplicantIndividualId":999034376,"individualIds":"","programCode":"","mode":"","applicationID":"","miscelleanousParameter":"","Payload":{"ClaimsOverview":{"IndividualId":"830008781","IndividualName":"STEPHEN ALLEN","ClaimNumber":"1000004512","DueDate":"2018-02-21","CurrentAmountOwed":"170","RepaymentAmount":"400","ClaimStatus":"UN"}}}';
        }else if(callView=='getPaymentURL'){
            body='{"GetPaymentURLResponse":{"CartId":"1704d500-23ce-4734-971a-d174f1486f4c","PaymentURL":"https://secure.test.kentucky.gov/PaymentServices.Hosted/MakePayment.aspx?cartid=1704d500-23ce-4734-971a-d174f1486f4c"}}';
        }else if(callView=='getPaymentStatus'){
            body='{"NotifyPaymentResponse":{"CartId":"a41f125d-a6e9-42f4-bb57-ef0be513e39c","RequestStatus":"FAIL","Errorcode":"HBE9000","ErrorDescription":"System Exception"}}';
        }
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
    
}