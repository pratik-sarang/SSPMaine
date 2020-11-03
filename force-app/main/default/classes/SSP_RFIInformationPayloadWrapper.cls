/*
 * Classname         :  SSP_RFIInformationPayload
 * @description  :  RFI Information payload
 * @author       :  Rajeev Kumar
 * @date         :  03/04/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public class SSP_RFIInformationPayloadWrapper {
    // public Attributes
    public List<SSP_RFIInformationWrapper> RFIInformation;
    public List<CaseInformationWrapper> CaseInformation;
    public List<DocumentMetaDataWrapper> DocumentMetaData;
    
    /**
     * @description : Wrapper class for RFI Information
     */
    public class SSP_RFIInformationWrapper {
        //public attributes
        public Integer IndividualId;
        public Integer CaseNumber;
        public String FullName;
        public String TypeOfProof;
        public String DueDate;
        public String ProgramCode;
        public String TypeOfProofRefCode;
        public String UniqueIdentifier;
        public String RecordIdentifier;
    }

    /**
     * @description : Wrapper class All CaseInformation
     */
    public class CaseInformationWrapper {
        public Integer IndividualId;
        public Integer CaseNumber;
        public String ProgramCode;
        public String FullName;
        public String IsEligibleforRenewal;
    }

    /**
     * @description : Wrapper class for Document Metadata
     */
    public class DocumentMetaDataWrapper {
        public Integer IndividualId;
        public Integer CaseNumber;
        public String IndividualName;
        public String DocumentMetaDataId;
        public String DocumentName;
        public String Extension;
        public String MimeType;
        public String DocumentType;
        public String SubmittedDate;
        public String Statuscode;
    }
    
    public SSP_RFIInformationPayloadWrapper() {
        
    }
}
