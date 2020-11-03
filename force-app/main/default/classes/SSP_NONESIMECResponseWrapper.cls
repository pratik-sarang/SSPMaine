/*
* Classname 		:  SSP_NONESIMECResponseWrapper
* @description 	:  This class is the response wrapper for Non-ESI MEC Integration Service 
* @author 		:  Kommana Lova Durga Prasad
* @date 		:  18/12/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/
public class SSP_NONESIMECResponseWrapper {
	public boolean IsValidationError;
	public VerifyNonESIMECRespWrapper VerifyNonESIMECResp;
	public class VerifyNonESIMECRespWrapper {
		public NonESIMECIndividualRespWrapper[] NonESIMECIndividualResp;
	}
	public class NonESIMECIndividualRespWrapper {
		public ApplicantWrapper Applicant;
		public OtherCoverageWrapper[] OtherCoverage;
		public boolean PartialResponseIndicator;
	}
	public class ApplicantWrapper {
		public String PersonBirthDate;	//1993-09-09T00:00:00
		public PersonNameWrapper PersonName;
		public String PersonSex;	//M
		public String PersonSSNIdentification;	//123222333
	}
	public class PersonNameWrapper {
		public String PersonGivenName;	//HORST
		public String PersonMiddleName;	//U
		public String PersonSurName;	//BRAVOS
	}
	public class OtherCoverageWrapper {
		public MECCoverageWrapper MECCoverage;
		public NonESIMECMetadataResponseWrapper NonESIMECMetadataResponse;
		public String OrganizationCode;	//MEDI
	}
	public class MECCoverageWrapper {
		public InsuranceWrapper[] Insurance;
		public String MECVerificationCode;	//Y
	}
	public class InsuranceWrapper {
		public String InsuranceEffectiveDate;	//2015-01-01T00:00:00
		public String InsuranceEndDate;	//2016-12-31T00:00:00
		public boolean InsuranceEndDateSpecified1;
	}
	public class NonESIMECMetadataResponseWrapper {
		public String ResponseCode;	//HS000000
		public String ResponseDescriptionText;	//Success
		public String TDSResponseDescriptionText;	//HS000000
	}
    public AckResponse AckResponse;
    public class AckResponse{
        public String AckResponseCode;
        public String AckResponseDescription;
        
    }
    public boolean IsSuccess;
    public List<SSP_Transaction__c> lstofTransactionsToInsert;
    public List<SSP_Transaction__c> lstofTransactionsToDelete;
    public List<LOG_LogMessage__c> lstofLogMessages;
    
    public static SSP_NONESIMECResponseWrapper parseNONESIMECResponse(String json){
		return (SSP_NONESIMECResponseWrapper) System.JSON.deserialize(json, SSP_NONESIMECResponseWrapper.class);
	}

}
