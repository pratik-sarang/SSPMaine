/**
 * Class Name               : SSP_AssisterAuthRepDetailsPayloadWrapper
 * Owner                    : DELOITTE
 * Created Date             : 06/03/2020
 * Description              : Response Wrapper of Asister Auth Rep Client Details Service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  06/03/2020  Rajeev Kumar        Initial Version
 */
public with sharing class SSP_AssisterAuthRepDetailsPayloadWrapper{
    // public attributes
    public List<AuthrepandAssiterClientInfoWrapper> AuthrepandAssiterClientInfo;
    public List<CaseInfoWrapper> CaseInfo;

    /**
     * Class Name               : AuthrepandAssiterClientInfoWrapper
     * Description              : Class to provide Auth Rep and Assister client details
     */
    public class AuthrepandAssiterClientInfoWrapper {
        //public attributes
        public String RoleType;
        public String UserId;
        public String OrganizationId;
        public String FirstName;
        public String LastName;
        public String MiddleName;
        public String Suffix;
        public String SSN;
        public String Gender;
        public String Birthdate;
        public String OrganizationName;
        public String OrgranizationIdentificationNumber;
        public String Phone;
        public String Email;
        public String Street;
        public String AddressLine2;
        public String SSP_State;
        public String CountyCode;
        public String Zipcode5;
        public String PreferredLanguageCode;
        public String PrimaryPhoneExtension;
        public String DCRepresentativeId;
        public String RepresentativeRelationshipCode;
        public String ProgramsApplied;
        public String isAuthRepVerified;
        public String CaseNumber;
        public String PermissionLevelMedicaid;
        public String PermissionLevelSNAP;
        public String PermissionLevelStateSupp;
        public String PermissionLevelKIHIPP;
        public String PermissionLevelCCAP;
        public String PermissionLevelKTAP;
    }
    
    /**
     * Class Name               : CaseInfoWrapper
     * Description              : Class to provide Case Information
     */
    public class CaseInfoWrapper {
        //public attributes
        public String CaseNumber;
        public String ProgramCode;
        public String LastUpdatedDate;
        public String FirstName;
        public String LastName;
        public String Email;
        public String PrimaryPhoneNumber;
        public String PrimaryPhoneExetnsion;
        public String PrimaryPhoneTypeCode;
        public String SecondaryPhoneNumber;
        public String SecondaryPhoneExtension;
        public String SecondaryPhoneTypeCode;
        public String PreferredNotificationMethodCode;
        public String PreferredWrittenLanguageCode;
        public String PreferredSpokenLanguageCode;
    }
    
    /**
     * @method name             : SSP_AssisterAuthRepDetailsPayloadWrapper
     * @description             : Default Constructor
     */
    public SSP_AssisterAuthRepDetailsPayloadWrapper() {
        // Default Constructor
    }
}