/**
 * Class Name               : SSP_TaxForms1095AInfoPayloadWrapper
 * Owner                    : DELOITTE
 * Created Date             : 07/08/2020
 * Description              : This is Reverse SSPDC Wrapper class to read Waiver Details
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  07/08/2020   Rajeev Kumar         Initial Version
 */
public class SSP_TaxForms1095AInfoPayloadWrapper {
    //public attributes
    public List<ReqTaxFormsYearsWrapper> ReqTaxFormsYears;
    public List<ReqTaxFormsEnrollmentDetailWrapper> ReqTaxFormsEnrollmentDetail;

    /**
     * CLASS NAME            : ReqTaxFormsYearsWrapper
     * @description          : ReqTaxFormsYears Wrapper Class
     */
    public class ReqTaxFormsYearsWrapper {
        //public attributes
        public String Year;
    }

    /**
     * CLASS NAME            : ReqTaxFormsEnrollmentDetailWrapper
     * @description          : ReqTaxFormsEnrollmentDetail Wrapper Class
     */
    public class ReqTaxFormsEnrollmentDetailWrapper {
        //public Attributes
        public String CaseNumber;
        public String PlanEnrollmentId;
        public String PlanName;
        public String Year;
    }

}