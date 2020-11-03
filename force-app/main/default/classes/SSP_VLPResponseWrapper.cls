/*
* Classname 		:  SSP_VLPResponseWrapper
* @description 	:  This class is the request wrapper for VLP 
* @author 		:  Rijia Khatun
* @date 		:  11/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/
public class SSP_VLPResponseWrapper {
	public boolean IsValidationError;
	public Integer sStatusCode;
	public cls_VerifyLawfulResponse VerifyLawfulResponse;
	public class cls_VerifyLawfulResponse {
		public cls_LawfulPresenceIndividualResponse[] LawfulPresenceIndividualResponse;
	}
	public class cls_LawfulPresenceIndividualResponse {
		public cls_LawfulPresenceServiceResponseField LawfulPresenceServiceResponseField;
		public String LawfulPresenceVerified;	
		public cls_ResponseMetadataDetails ResponseMetadataDetails;
	}
	public class cls_LawfulPresenceServiceResponseField {
        public String AgencyAction;
        public String QualifiedNonCitizenIndicator;	
        public String NonCitEntryDate;	
        public String UsCitizenCode;	
        public String IavTypeCode;	
        public String FiveYearBarMetIndicator;	
        public String FiveYearBarIndicator;
        public String EligStatementCd;	
        public String CaseNbr;	
        public String NonCitCoaCode;
	}
	
	public class cls_ResponseMetadataDetails {
		public String ResponseCode;
		public String ResponseDescriptionText;
		public String TDSResponseDescriptionText;	
	}
	public static SSP_VLPResponseWrapper parseVLPResponse(String json){
		return (SSP_VLPResponseWrapper) System.JSON.deserialize(json, SSP_VLPResponseWrapper.class);
    }
}