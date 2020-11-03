/*
* Classname         :  SSP_AVSMockClass
* @description  :  This class is to mock the response for AVS
* @author       :  Rijia Khatun
* @date         :  19/2/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
public class SSP_AVSMockClass implements WebServiceMock {
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element res = new SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element();
			res.transactionId = '1';
            response.put('response_x',res);
        }
}