@isTest
public  with sharing class SSP_DC_ReverseMockForEligibilty implements HttpCalloutMock {
    /**
     * method       : respond
     * @description     : Mock method to generate response
     * @author      : Rahul
     * @param req : HttpRequest for hitting the service
     */    
   public HTTPResponse respond(HTTPRequest req) {
        httpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        //Map<String, Object> reqBody = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
        
        string jsonData = '{"Payload" : {"CaseRFIInfo" : [ {"ReportedPolicyDetails" : "Y","ShowKHIPPVerificationText" : "Y","ShowBanner" : "Y","IsPendingRFIPresentInCase" : "Y"} ],"HOHReceivingBenefit" : [ {"ProgramApplied" : "SN","IndividualId" : "919222091"} ],"SSP_EligibilitySummary__c" : [ {"DenialReason" : null,"IsReferredToFFM" : null,"EligibleForKIHIPP" : null,"EligibleForExpeditedSNAP" : 0,"BenefitEndDate" : null,"BenefitBeginDate" : "2020-08-09","BenefitStatusCode" : "I","ProgramCode" : "SN","IndividualId" : "919222091"},{"DenialReason" : null,"IsReferredToFFM" : null,"EligibleForKIHIPP" : null,"EligibleForExpeditedSNAP" : 0,"BenefitEndDate" : null,"BenefitBeginDate" : null,"BenefitStatusCode" :null,"ProgramCode" : "SN","IndividualId" : "919222091"}  ]},"role" : "Citizen_Individual","miscelleanousParameter" : "","applicationID" : "","mode" : "","programCode" : "MA","individualIds" : "","primaryApplicantIndividualId" : "810188876","caseNumber" : "100375664","viewName" : "EligibilitySummary"}';

        response.setBody(jsonData);
        
        return Response;
    }
 }
/*
@isTest
global class SSP_DC_ReverseMockForEligibilty implements WebServiceMock {
    global void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
                          String soapAction,String requestName,String responseNS,String responseName,String responseType) {
                              RSSP_DC_Wrapper responseWrapper = new RSSP_DC_Wrapper();
                              responseWrapper.ACKRESPONSE = null;
                              string jsonData = '{"Payload" : {"CaseRFIInfo" : [ {"ReportedPolicyDetails" : null,"ShowKHIPPVerificationText" : "N","ShowBanner" : "N","IsPendingRFIPresentInCase" : "N"} ],"HOHReceivingBenefit" : [ {"ProgramApplied" : "SN","IndividualId" : "919222091"} ],"SSP_EligibilitySummary__c" : [ {"DenialReason" : null,"IsReferredToFFM" : null,"EligibleForKIHIPP" : null,"EligibleForExpeditedSNAP" : 0,"BenefitEndDate" : null,"BenefitBeginDate" : null,"BenefitStatusCode" : "I","ProgramCode" : "SN","IndividualId" : "919222091"} ]},"role" : "Citizen_Individual","miscelleanousParameter" : "","applicationID" : "","mode" : "","programCode" : "MA","individualIds" : "","primaryApplicantIndividualId" : "810188876","caseNumber" : "100375664","viewName" : "EligibilitySummary"}';
							response.put('response_x', jsonData); 
                          }*/