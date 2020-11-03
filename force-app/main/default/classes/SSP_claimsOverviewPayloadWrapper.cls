/**
 * Class Name               : SSP_claimsOverviewPayloadWrapper
 * Owner                    : DELOITTE
 * Created Date             : 06/01/2020
 * Description              : Response Wrapper of Claims overview
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  06/01/2020  Rajeev Kumar        Initial Version
 */
public with sharing class SSP_claimsOverviewPayloadWrapper{
    // public attributes
    public List<ClaimsOverviewWrapper> ClaimsOverview;

    /**
     * Class Name               : ClaimsOverviewWrapper
     * Description              : Class to provide Claims overview
     */
    public class ClaimsOverviewWrapper {
        //public attributes
        public String IndividualId;
        public String IndividualName;
        public String ClaimNumber;
        public String DueDate;
        public String CurrentAmountOwed;
        public String RepaymentAmount;
        public String ClaimStatus;
        public String ProgramCode;
    }

    /**
     * @method name             : SSP_claimsOverviewPayloadWrapper
     * @description             : Default Constructor
     */
    public SSP_claimsOverviewPayloadWrapper() {
        // Default Constructor
    }
}