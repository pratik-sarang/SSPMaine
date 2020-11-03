/*
* Classname     :  SSP_TaxFilingTMemberMockCalloutClass
* @description  :  This class is to mock the response for TMember
* @author       :  Karthik Gulla
* @date         :  07/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
**/
@isTest
global class SSP_TaxFilingTMemberMockCalloutClass implements WebServiceMock {
    global void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
    	SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element res = new SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element();
    	SSP_TMemberDataContract.SSPCaseResponse objRes = new SSP_TMemberDataContract.SSPCaseResponse();
        objRes.CaseNumber = 1;
        objRes.IsSuccess = true;
        objRes.Message = 'Message for T Member';

        SSP_TMemberDataContract.ArrayOfSSPMemberStatus sspArrayOfMemberStatus = new SSP_TMemberDataContract.ArrayOfSSPMemberStatus();
        List<SSP_TMemberDataContract.SSPMemberStatus> lstSSPMemberStatus = new List<SSP_TMemberDataContract.SSPMemberStatus>();

        SSP_TMemberDataContract.SSPMemberStatus sspMemStatusOne = new SSP_TMemberDataContract.SSPMemberStatus();
        sspMemStatusOne.IndividualID = 676976979;
        sspMemStatusOne.MemberStatus = 'R';

        SSP_TMemberDataContract.SSPMemberStatus sspMemStatusTwo = new SSP_TMemberDataContract.SSPMemberStatus();
        sspMemStatusTwo.IndividualID = 676976978;
        sspMemStatusTwo.MemberStatus = 'T';

        SSP_TMemberDataContract.SSPMemberStatus sspMemStatusThree = new SSP_TMemberDataContract.SSPMemberStatus();
        sspMemStatusThree.IndividualID = 676976977;
        sspMemStatusThree.MemberStatus = 'R';

        lstSSPMemberStatus.add(sspMemStatusOne);
        lstSSPMemberStatus.add(sspMemStatusTwo);
        lstSSPMemberStatus.add(sspMemStatusThree);
        sspArrayOfMemberStatus.SSPMemberStatus = lstSSPMemberStatus;
        objRes.memberStatuses = sspArrayOfMemberStatus;
        res.SSPDetermineMemberResult = objRes;
        response.put('response_x', res);
    }
}