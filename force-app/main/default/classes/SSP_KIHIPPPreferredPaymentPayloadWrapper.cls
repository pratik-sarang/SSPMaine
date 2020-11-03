/**
 * Class Name    : SSP_KIHIPPPreferredPaymentPayloadWrapper
 * Owner         : DELOITTE
 * Created Date  : 14/7/2020
 * Description   : Class holds the response for KIHIPP Preferred Payment
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  14/7/2020    Rajeev Kumar       Initial Version
 */
public class SSP_KIHIPPPreferredPaymentPayloadWrapper {
    // public Attributes
    public List<KIHIPPPreferredPaymentWrapper> KIHIPPPreferredPayment;
    /**
     * ClassName            : KIHIPPPreferredPaymentWrapper
     * @description         : KIHIPP Preferred Payment Wrapper
     */
    public class KIHIPPPreferredPaymentWrapper{
        public String IndividualId;
        public String FirstName;
        public String LastName;
        public String MiddleInitial;
        public String SuffixCode;
        public String PreferredIssuanceMethod;
        public String RoutingNumber;
        public String CheckingAccountNumber;
        public String MailingAddressLine1;
        public String MailingAddressLine2;
        public String MailingCity;
        public String MailingCountyCode;
        public String MailingStateCode;
        public String MailingZipCode5;
    }
}