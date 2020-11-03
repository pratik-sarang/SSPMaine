/**
 * Class Name    : SSP_BenefitInformationPayloadWrapper
 * Owner         : DELOITTE
 * Created Date  : 02/23/2020
 * Description   : This class will holds the response data of SSP Benefit Information Payload
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  02/23/2020   Ragunathan           Initial Version
 *  07/06/2020    Rajeev Kumar
 */
public with sharing class SSP_BenefitInformationPayloadWrapper {
    // public attributes
    public List<SSP_BenefitInformationWrapper> Benefit;
    public List<MedicardEBTWrapper> MedicardEBT;
    
    /**
     * CLASS NAME: MedicardEBTWrapper
     * @description: Medicaid EBT WRapper Class
     */
    public class MedicardEBTWrapper {
        //public attributes
        public String IndividualId;
        public String IndividualName;
        public String CaseNumber;
        public Boolean ShowEBT;
        public Boolean ShowMedicard;
    }

    /*
     * @description : Default Constructor
     */
    public SSP_BenefitInformationPayloadWrapper() {
        
    }
}