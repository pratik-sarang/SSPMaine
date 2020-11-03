/*
* Classname 		:  SSP_VLPRequestWrapper
* @description 	:  This class is the request wrapper class for VLP
* @author 		:  Rijia Khatun
* @date 		:  12/10/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/
public class SSP_VLPRequestWrapper {

	public String SourceSystem;
	public VLPLawfulPresenceRequest vLPLawfulPresenceRequest;
	
	public class VLPLawfulPresenceRequest {
		public String CaseNumber = SSP_InterfaceConstants.SSPCASENUMBER;
		public String ApplicationNumber;
		public cls_LawfulPresenceRequestList LawfulPresenceRequestList;
	}
	public class cls_LawfulPresenceRequestList {
		public cls_LawfulPresenceRequest[] LawfulPresenceRequest;
	}
	
	public class cls_LawfulPresenceRequest {
		public boolean RequestGrantDateIndicator;
		public String RequesterCommentsForHub;
		public String PersonSurName;
		public String PersonNameSuffixText;
		public String PersonMiddleName;
		public String PersonGivenName;
		public Date PersonBirthDate;	//have to confirm-- Date or date/Time
		public String IndividualId;
		public boolean RequestSponsorDataIndicator = false;
		public boolean FiveYearBarApplicabilityIndicator = false;
		public cls_DHSId DHSId;
	}
	public class cls_DHSId {
		public NatrOfCertDocumentId NatrOfCertDocumentId;
		public MacReadI551DocumentId MacReadI551DocumentId;
		public I94UnexpForeignPassportDocumentId I94UnexpForeignPassportDocumentId;
		public I94DocumentId I94DocumentId;
		public I766DocumentId I766DocumentId;
		public TempI551DocumentId TempI551DocumentId;
		public I571DocumentId I571DocumentId;
		public I551DocumentId I551DocumentId;
		public I571DocumentId I327DocumentId;
		public I94DocumentId I20DocumentId;
		public DS2019DocumentId DS2019DocumentId;
		public CertOfCitDocumentId CertOfCitDocumentId;
        public OtherCase1DocumentId OtherCase1DocumentId;
		public UnexpForeignPassportDocumentId UnexpForeignPassportDocumentId;
	}

	public class NatrOfCertDocumentId {
		public String AlienNumber;
		public String NaturalizationNumber;
	}
    
    public class OtherCase1DocumentId {
        public String AlienNumber;
		public String CountryOfIssuance;
		public DateTime DocExpirationDate;
		public String DocDescReq;
	}

	public class UnexpForeignPassportDocumentId {
		public String CountryOfIssuance;
		public DateTime DocExpirationDate;
		public String I94Number;
		public String PassportNumber;
		public String SEVISID;
	}

	public class I94DocumentId {
		public DateTime DocExpirationDate;
		public String I94Number;
		public String SEVISID;
	}

	public class I571DocumentId {
		public String AlienNumber;
		public DateTime DocExpirationDate;
	}

	public class TempI551DocumentId {
		public String AlienNumber;
		public String CountryOfIssuance;
		public DateTime DocExpirationDate;
		public String PassportNumber;
	}

	public class I551DocumentId {
		public String AlienNumber;
		public DateTime DocExpirationDate;
		public String CardNumber;
	}

	public class I94UnexpForeignPassportDocumentId {
		public String CountryOfIssuance;
		public DateTime DocExpirationDate;
		public String I94Number;
		public String PassportNumber;
		public String SEVISID;
		public String VisaNumber;
	}

	public class CertOfCitDocumentId {
		public String AlienNumber;
		public String CitizenshipNumber;
	}

	public class DS2019DocumentId {
		public DateTime DocExpirationDate;
		public String SEVISID;
	}

	public class I766DocumentId {
		public String AlienNumber;
		public DateTime DocExpirationDate;
		public String ReceiptNumber;
	}

	public class MacReadI551DocumentId {
		public String AlienNumber;
		public String CountryOfIssuance;
		public DateTime DocExpirationDate;
		public String PassportNumber;
		public String VisaNumber;
	}

}