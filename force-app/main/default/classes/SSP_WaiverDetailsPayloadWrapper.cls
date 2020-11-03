/**
 * Class Name    : SSP_WaiverDetailsPayloadWrapper
 * Owner         : DELOITTE
 * Created Date  : 05/15/2020
 * Description   : This is Reverse SSPDC Wrapper class to read Waiver Details
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  05/15/2020   Rajeev Kumar         Initial Version
 */
public with Sharing class SSP_WaiverDetailsPayloadWrapper {
    
    // public attributes
    public List<WaiverDetailsWrapper> WaiverDetails;
    public List<WaiverStatusesWrapper> WaiverStatuses;
    
    /**
     * CLASS NAME            : WaiverDetailsWrapper
     * @description          : WaiverDetailsWrapper Wrapper Class
     */
 
    public class WaiverDetailsWrapper {
        // public Attributes
        public String IndividualId;
        public String WaiverScreeningId;
        public String IndividualName;
        public String HasBrainInjury;
        public String IsVentilatorDependent;
        public String RequireAssistance;
        public String HasDevelopmentalDisability;
        public String WillContinueServices;
    }

    /**
     * CLASS NAME            : WaiverStatusesWrapper 
     * @description          : WaiverStatusesWrapper Wrapper Class
     */
    public class WaiverStatusesWrapper {
        // public attributes
        public String WavierCaseNumber;
        public String WaiverCaseStatus;
        public String ProgramStatusCode;
        public String ProgramCode;
        public String IndividualId;
        public String ApplicationNumber;
        public String ApplicationStatus;
        public String IndividualName;
    }
    
    /**
     * @methodName           : SSP_WaiverDetailsPayloadWrapper
     * @description          : Default Constructor
     */
    public SSP_WaiverDetailsPayloadWrapper() {
    }
}