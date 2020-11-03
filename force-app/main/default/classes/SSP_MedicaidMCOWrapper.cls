/**
 * Class Name    : SSP_MedicaidMCOWrapper
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
public with sharing class SSP_MedicaidMCOWrapper {
    
    public String CaseNumber;
    public String IndividualId;
    public String IndividualName;
    public String PlanId;
    public String PlanName;
    public String PlanStatus;
    public String EnrollmentBeginDate;
    public String EnrollmentEndDate;
    
    public SSP_MedicaidMCOWrapper() {
        
    }
}