/**
 * Class Name                       : RSSP_DC_Wrapper 
 * Owner                            : DELOITTE
 * Created Date                     : 02/01/2020
 * Description                      : Class that holds Non Citizen search case Response
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  02/01/2020  Rajeev Kumar    Initial Version
 */
    public with sharing class SSP_KHIPPPaymentSummaryWrapper {
    // public attributes
    public List<SummaryWrapper> Summary;
    public List<PremiumDetailsWrapper> PremiumDetails;
    public List<AdjustmentDetailsWrapper> AdjustmentDetails;
    public class SummaryWrapper {
        // public attributes
        public String CaseNumber;
        public String IndividualId;
        public String KHIPPFinalPaymentId;
        public String IndividualName;
        public String ReimbursedDate;
        public String ReimbursedMonth_Year;
        public String TotalAmount;
        public String TotalPremium;
        public String Adjustment;
    }
    
	/**
 	 * Class Name                       			: PremiumDetailsWrapper 
 	 * Description                            		: Premium Details Wrapper
	 */
    public class PremiumDetailsWrapper {
        //public attributes
        public String CaseNumber;
        public String IndividualId;
        public String KHIPPFinalPaymentId;
        public String IndividualName;
        public String BenefitMonth_Year;
        public String ReimbursedDate;
        public String ApprovedPremium;
        public String ElectiveAbortion;
    }
    
	/**
 	 * Class Name                       			: AdjustmentDetailsWrapper 
 	 * Description                            		: Adjustment Details Wrapper
	 */
    public class AdjustmentDetailsWrapper {
        // public attributes
        public String CaseNumber;
        public String IndividualId;
        public String KHIPPFinalPaymentId;
        public String IndividualName;
        public String BenefitMonth_Year;
        public String ReimbursedDate;
        public String AdjustmentAmount;
        public String Reason;
    }
    
    /**
     * @methodName                          : SSP_KHIPPPaymentSummaryWrapper                                 
     * @description                         : Default constructor
     */
    public SSP_KHIPPPaymentSummaryWrapper() {
        
    }
}