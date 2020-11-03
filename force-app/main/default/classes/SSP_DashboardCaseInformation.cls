/**
 * Class Name    : SSP_DashboardCaseInformation
 * Owner         : DELOITTE
 * Created Date  : 03/4/2020
 * Description   : This class will holds the response data of SSP Dashboard case information service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  03/4/2020   Ragunathan           Initial Version
 */
public with Sharing class SSP_DashboardCaseInformation {
    
    // public attributes
    public List<CaseInfo> CaseInfo;
    public List<Renewal> Renewal;
    public List<AgentAssisterAuthRep> AgentAssisterAuthRep;
    public List<TimeStampDetailsWrapper> TimeStampDetails;
    public List<DemographicDetailsWrapper> DemographicDetails;
    
    /**
     * Class Name                : CaseInfo
     * Description               : CaseInfo Wrapper Class
     *
     */ 
    public class CaseInfo {
        public String CaseNumber;
        public String IsHeadOfHousehold;
        public String CaseStatusCode;
        public String RFICount;
        public String IsInRenewalPeriod;
        public String IsRACEnabled;
        public String SNAPClaimAmount;
        public String IsTmember;
        public String CaseOwnership;
        public String IsCaseInChangeMode;
        public String IndividualId;
        public String ApplicationSourceType;
        public String MedicaidApplicationType;
        public String LastEligibilityTransactionDate;
        
    }
    
    /**
     * ClassName                : Renewal
     * Description              : Renewal Wrapper Class
     *
     */    
     public class Renewal {
        // public attributes
        public String CaseNumber;
        public String RenewalProgramCode;
        public String RenewalDueDate;
    }
    
    /**
     *
     * ClassName                : AgentAssisterAuthRep 
     * Description              : AgentAssisterAuthRep  Wrapper Class
     *
     */
     public class AgentAssisterAuthRep {
        // public attributes
        public String RoleType;
        public String FullName;
        public String CaseNumber;
        public String PermissionLevelMA;
        public String PermissionLevelSN;  
        public String PermissionLevelSS;  
        public String PermissionLevelKP;  
        public String PermissionLevelKT;  
        public String PermissionLevelCC;  
        public String IsIndividualAuthRep;  
        public String DCRepresentativeId;  
    }

    /**
     *
     * ClassName                : TimeStampDetailsWrapper 
     * Description              : Timestamp Details Wrapper Class
     *
     */
    public class TimeStampDetailsWrapper {
        public String TimeStamp;
    }

    /**
     *
     * ClassName                : DemographicDetailsWrapper 
     * Description              : Demographic Detail Wrapper Class
     *
     */
    public class DemographicDetailsWrapper {
        public String FirstName;
        public String LastName;
        public String MiddleInitial;
        public String SuffixCode;
        public String GenderCode;
        public String BirthDate;
        public String PreferredIndividual;
        public String IndividualId;
    }

    /**
     * @methodName               : SSP_DashboardCaseInformation
     * @description              : Default Constructor
     */    
    public SSP_DashboardCaseInformation() {
    }
}
