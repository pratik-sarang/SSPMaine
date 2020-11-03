/**
 * Class Name    : SSP_EligibilitySummaryPayloadWrapper
 * Owner         : DELOITTE
 * Created Date  : 02/7/2020
 * Description   : Class holds the response of Eligibility Summary Information
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  02/7/2020    Rajeev Kumar       Initial Version
 */
public with sharing class SSP_EligibilitySummaryPayloadWrapper {
    // public attributes
    public List<SSP_EligibilitySummaryWrapper> SSP_EligibilitySummary;
    public List<HOHReceivingBenefitWrapper> HOHReceivingBenefit;
    public List<CaseRFIInfoWrapper> CaseRFIInfo;

    /**
     * Class Name                   : HOHReceivingBenefitWrapper
     * Description                  : HOH Receiving Benefit Class
     * 
     */
    public class HOHReceivingBenefitWrapper {
        // Public attributes
        public String IndividualId;
        public String ProgramApplied;
    }
    
    /**
     * Class Name                   : CaseRFIInfoWrapper
     * Description                  : Case RFI InfoWrapper
     * 
     */
    public class CaseRFIInfoWrapper {
        //public attributes
        public String IsPendingRFIPresentInCase;
        public String ShowBanner;
        public String ReportedPolicyDetails;
        public String ShowKHIPPVerificationText;
    }

    /**
     * @method Name                 : SSP_EligibilitySummaryPayloadWrapper
     * @description                 : Default Constructor
     */
    public SSP_EligibilitySummaryPayloadWrapper() {
        
    }
}