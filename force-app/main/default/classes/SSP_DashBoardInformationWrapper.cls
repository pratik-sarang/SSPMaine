/**
 * Class Name    : SSP_DC_DashBoardInfoWrapperClone
 * Owner         : DELOITTE
 * Created Date  : 24/01/2020
 * Description   : Temporary class that holds DashBoard Information related data.
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 * Date        Developer          Description                                                         
 * ----------  --------------     -------------------------------------------------------------------
 * 24/01/2020  Ragunathan          Initial Version
 */
public with sharing class SSP_DashBoardInformationWrapper {
    // public attributes
    public List<SSP_MemberWrapper> SSP_Member;
    public List<SSP_CasesWrapper> Cases;
    public List<SSP_CaseIndividualsWrapper> CaseIndividuals;
    public List<SSP_CaseProgramsWrapper> CasePrograms;
    public List<SSP_CaseProgramIndividualsWrapper> CaseProgramIndividuals;
    /**
     * 
     */
    public class SSP_CasesWrapper {
        public String CaseNumber;
        public String CaseStatusCode;
        public String IsHeadofhousehold;
        public String EnableReportAchange;
        public String EnableRenewal;
    }
    
    /**
     * 
     */
    public class SSP_CaseIndividualsWrapper {
        public String CaseNumber;
        public String IndividualId;
        public String IsHeadofhousehold;
    }
    /**
     * 
     */
    public class SSP_CaseProgramsWrapper {
        public String CaseNumber;
        public String ProgramCode;
        public String CaseProgramStatusCode;
    }
    /**
     * 
     */
    public class SSP_CaseProgramIndividualsWrapper {
        public String CaseNumber;
        public String ProgramCode;
        public String IndividualId;
        public String CaseProgramStatusCode;
    }
    /**
     * 
     */
    public class SSP_MemberWrapper {
        public String PseudoSSN;
        public String IsDateOfDeathValidated;
        public String IsDateOfBirthValidated;
        public String SSNVerified;
        public String MCIId;
        public String IndividualId;
        public String NoReasonSSNCode;
        public String GenderCode;
        public String DeathDate;
        public String SSN;
        public String EthnicityCode;
        public String SuffixCode;
        public String MiddleInitial;
        public String BirthDate;
        public String LastName;
        public String FirstName;
    }
}