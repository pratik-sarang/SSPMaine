/*
* Classname 		:  SSP_NONESIMECRequestWrapper
* @description 	:  This class is the request wrapper class for Non-ESI MEC Integration Service
* @author 		:  Kommana Lova Durga Prasad
* @date 		:  18/12/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Descriptio about the Change
**/
public class SSP_NONESIMECRequestWrapper {
    public Integer CaseNumber;	//10
    public Integer ApplicationNumber;	//10
    public NonESIMECIndividualRequestOuter NonESIMECIndividualRequestList;
    public class NonESIMECIndividualRequestOuter {
        public NonESIMECIndividualRequestInner[] NonESIMECIndividualRequest;
    }
    public class NonESIMECIndividualRequestInner {
        public Integer IndividualId;	//123222333
        public InsurancePolicyWrapper InsurancePolicy;
        public String LocationStateUSPostalServiceCode;	//KY
        public string[] Organization;
        public String PersonBirthDate;	//1976-05-29
        public PersonDetailWrapper PersonDetail;
        public String PersonSSNIdentificationType;	//123222333
        public String PersonSex;	//F
    }
    public class InsurancePolicyWrapper {
        public String ApplicationStartDate;	//2019-09-01T21:32:52
        public String InsurancePolicyExpirationDate;	//2020-08-31T21:32:52
    }
    
    public class PersonDetailWrapper {
        public String PersonGivenName;	//EOEPCLU
        public String PersonMiddleName;	//ABC
        public String PersonNameSuffixText;	//Ms
        public String PersonSurName;	//UJPPNZR
    }
    public static SSP_NONESIMECRequestWrapper parseNONESIMECResponse(String json){
        return (SSP_NONESIMECRequestWrapper) System.JSON.deserialize(json, SSP_NONESIMECRequestWrapper.class);
    }  
}
