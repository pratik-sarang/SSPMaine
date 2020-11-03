/**
 * Class Name               : SSP_NonCitizenClientInfoPayloadWrapper
 * Owner                    : DELOITTE
 * Created Date             : 28/11/2019
 * Description              : Response Wrapper of My Information for Non Citizen User
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  11/12/2019  Rajeev Kumar        Initial Version
 */
public with sharing class SSP_NonCitizenClientInfoPayloadWrapper {
    // public attributes
    public List<ClientCountInfoWrapper> ClientCountInfo;
    public List<CaseInfoWrapper> CaseInfo;
    
    /**
     * Class Name               : ClientCountInfoWrapper
     * Description              : Class to get Client Count Info
     */
    public class ClientCountInfoWrapper {
        // public attributes
        public Integer ClientCount;
        public String IndividualIds;
    }

    /**
     * Class Name               : CaseInfoWrapper
     * Description              : Class to provide case Information
     */
    public class CaseInfoWrapper {
        //public attributes
        public Integer CaseNumber;
        public Integer individualId;
        public String FirstName;
        public String LastName;
        public String MiddleInitial;
        public String Suffix;
        public String GenderCode;
        public String BirthDate;
        public String AddressLine1;
        public String AddressLine2;
        public String ZipCode;
        public String SSN;
        public String EmailAddress;
        public String PhoneNumber;
        public String AssistedbyAuthRep;
        public String AssistedbyAsister;
        public String ClientRole;
        public String RFIDueDate;
        public String NumberofRFI;
        public String RenewalDueDate;
        public String ProgramDueRenewal;
        public String MCOEnrollmentStatus;
        public String CaseStatus;
        public String SubmittedDate;
        public String LastupdatedDate;
        public String MaidCardNumber;
        public String CaseStatusSpanish;
    }

    /**
     * @method name             : SSP_NonCitizenClientInfoPayloadWrapper
     * @description             : Default Constructor
     */
    public SSP_NonCitizenClientInfoPayloadWrapper() {
        // Default Constructor
    }
}