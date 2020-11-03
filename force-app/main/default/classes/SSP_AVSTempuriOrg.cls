/*
* Classname 	:  SSP_AVSTempuriOrg
* @description 	:  This class is a stub class for AVS
* @author 		:  Rijia Khatun
* @date 		:  02/07/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/

public class SSP_AVSTempuriOrg {
    public class BasicHttpBinding_ITwoWayAsync {
        public String endpoint_x = 'https://hfs1vd-apne010.chfs.ds.ky.gov/AvsPostTransactionWcfService/AvsPostTransaction.svc';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/Imports', 'SSP_AVSTempuriOrgImports', 'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse', 'SSP_AVSSchemasPostAvstr', 'http://tempuri.org/', 'SSP_AVSTempuriOrg', 'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest', 'SSP_AVSSchemasPostAvstr', 'http://schemas.microsoft.com/Message', 'SSP_AVSMicrosoftComMessage'};
        public SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element PostTransaction(String[] programs,SSP_AVSSchemasPostAvstr.identity_element identity,String organizationId,String WorkerFirstName,String WorkerLastName,String IsOverride,String TransactionId,String WorkerUserId) {
            SSP_AVSSchemasPostAvstr.POST_AVSTransactionRequest_element request_x = new SSP_AVSSchemasPostAvstr.POST_AVSTransactionRequest_element();
            request_x.programs = programs;
            request_x.identity = identity;
            request_x.organizationId = organizationId;
            request_x.WorkerFirstName = WorkerFirstName;
            request_x.WorkerLastName = WorkerLastName;
            request_x.IsOverride = IsOverride;
            request_x.TransactionId = TransactionId;
            request_x.WorkerUserId = WorkerUserId;
            SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element response_x;
            Map<String, SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element> response_map_x = new Map<String, SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'PostTransaction',
              'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',
              'POST_AVSTransactionRequest',
              'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',
              'POST_AVSTransactionResponse',
              'SSP_AVSSchemasPostAvstr.POST_AVSTransactionResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}