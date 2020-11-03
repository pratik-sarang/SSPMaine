/**
 * Class Name               : SSP_NonCitizenSearchExportPayloadWrapper
 * Owner                    : DELOITTE
 * Created Date             : 07/29/2019
 * Description              : Response Wrapper of Non Citizen Search Export
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  07/29/2020  Rajeev Kumar        Initial Version
 */
public with sharing class SSP_NonCitizenSearchExportPayloadWrapper{
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
        public String MiddleInitial;
        public String LastName;
        public String Suffix;
        public String GenderCode;
        public String BirthDate;
        public String AddressLine1;
        public String AddressLine2;
        public String Zipcode;
        public String SSN;
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
     * @method name             : NonCitizenSearchExportPayloadWrapper
     * @description             : Default Constructor
     */
    public SSP_NonCitizenSearchExportPayloadWrapper() {
        // Default Constructor
    }
}