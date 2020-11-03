/**
 * Class Name    : SSP_EligibilitySummaryWrapper
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
public class SSP_EligibilitySummaryWrapper {
    // public attributes
    public String IndividualId;
    public String ProgramCode;
    public String BenefitStatusCode;
    public String BenefitBeginDate;
    public String BenefitEndDate;
    public String EligibleForExpeditedSNAP;
    public String EligibleForKIHIPP;
    public String IsReferredToFFM;
    public String DenialReason;
    public String IsPendingRFIPresentInCase;
    
    /**
     * @description                 : Default Contructor
     */
    public SSP_EligibilitySummaryWrapper() {
    }
}