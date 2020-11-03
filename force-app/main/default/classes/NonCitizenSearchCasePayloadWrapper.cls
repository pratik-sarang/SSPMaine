/**
 * Class Name               : NonCitizenSearchCasePayloadWrapper
 * Owner                    : DELOITTE
 * Created Date             : 28/11/2019
 * Description              : Response Wrapper of Non Citizen Search Case
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  05/28/2020  Rajeev Kumar        Initial Version
 */
public with sharing class NonCitizenSearchCasePayloadWrapper{
    // public attributes
    public List<CaseInfoWrapper> CaseInfo;

    /**
     * Class Name               : CaseInfoWrapper
     * Description              : Class to provide case Information
     */
    public class CaseInfoWrapper {
        //public attributes
        public String CaseNumber;
        public String individualId;
        public String FirstName;
        public String LastName;
        public String MiddleInitial;
        public String Suffix;
        public String GenderCode;
        public String BirthDate;
        public String SSN;
        public String AddressLine1;
        public String AddressLine2;
        public String Zipcode;
        public String EmailAddress;
        public String PhoneNumber;
        public String AssistedbyAuthRep;
        public String AssistedbyAsister;
        public String AssisterName;
        public String AssignmentStartDate;
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
     * @method name             : NonCitizenSearchCasePayloadWrapper
     * @description             : Default Constructor
     */
    public NonCitizenSearchCasePayloadWrapper() {
        // Default Constructor
    }
}