/**
 * Class Name    : SSP_IndividualInfoWrapper
 * Owner         : DELOITTE
 * Created Date  : 24/02/2020
 * Description   : Wrapper Class that holds Information related to MedicaidMCOInformation view
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  24/02/2020  Ragunathan		   Initial Version
 */
public with sharing class SSP_IndividualInfoWrapper {
    	public String CaseNumber;
        public String IndividualId;
        public String IndividualName;
        public String IsEnrolledInPlan;
        public String IsEligibleToEnroll;
        public String InEligibleDueToLTC;
        public String InEligibleDueToIncarceration;
        public String InEligibleDueToKIHIPP;
        public String MCOBeginDate;
    
    public SSP_IndividualInfoWrapper(){
        
    }
}