/*
* Classname 	:  SSP_TMemberCalloutClass
* @description 	:  This class is a stub class for TMember
* @author 		:  Rijia Khatun
* @date 		:  01/7/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/

public class SSP_TMemberCalloutClass {
    public class DetermineMemberResponse_element {
        public SSP_TMemberDataContract.CaseResponse DetermineMemberResult;
        private String[] DetermineMemberResult_type_info = new String[]{'DetermineMemberResult','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'DetermineMemberResult'};
    }
    public class DetermineMember_element {
        public SSP_TMemberDataContract.CaseRequest caseRequest;
        private String[] caseRequest_type_info = new String[]{'caseRequest','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'caseRequest'};
    }
    public class SSPDetermineMemberResponse_element {
        public SSP_TMemberDataContract.SSPCaseResponse SSPDetermineMemberResult;
        private String[] SSPDetermineMemberResult_type_info = new String[]{'SSPDetermineMemberResult','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SSPDetermineMemberResult'};
    }
    public class SSPDetermineMember_element {
        public SSP_TMemberDataContract.SSPCaseRequest sspCaseRequest;
        private String[] sspCaseRequest_type_info = new String[]{'sspCaseRequest','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'sspCaseRequest'};
    }
    public class BasicHttpsBinding_IKyHbeEdbcHHMBRService {
        public String endpoint_x = 'https://dev4.kyrules.chfsinet.ky.gov/KyHbeEdbcHHMBR/KyHbeEdbcHHMBRService.svc';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'SSP_TMemberStubClass', 'http://tempuri.org/', 'SSP_TMemberCalloutClass', 'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom', 'SSP_TMemberDataContract', 'http://schemas.microsoft.com/2003/10/Serialization/', 'SSP_TMemberStubClass', 'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service', 'SSP_TMemberDataContract'};
        public SSP_TMemberDataContract.SSPCaseResponse SSPDetermineMember(SSP_TMemberDataContract.SSPCaseRequest sspCaseRequest) {
            SSP_TMemberCalloutClass.SSPDetermineMember_element request_x = new SSP_TMemberCalloutClass.SSPDetermineMember_element();
            request_x.sspCaseRequest = sspCaseRequest;
            SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element response_x;
            Map<String, SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element> response_map_x = new Map<String, SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/IKyHbeEdbcHHMBRService/SSPDetermineMember',
              'http://tempuri.org/',
              'SSPDetermineMember',
              'http://tempuri.org/',
              'SSPDetermineMemberResponse',
              'SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SSPDetermineMemberResult;
        }
    }
}