/**
 * Class Name    : SSP_HearingsSummaryInfoPayloadWrapper
 * Owner         : DELOITTE
 * Created Date  : 14/7/2020
 * Description   : Class holds the response of Hearings Summary Wrapper
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  02/7/2020    Rajeev Kumar       Initial Version
 */
public with sharing class SSP_HearingsSummaryInfoPayloadWrapper {
    // public attributes
    public List<HearingSummaryWrapper> HearingSummary;
    public List<PreferredDetailsWrapper> PreferredDetails;

    /**
     * Class Name                   : HearingSummaryWrapper
     * Description                  : Hearing Summary Wrapper
     * 
     */
    public class HearingSummaryWrapper {
        // Public attributes
        public String CaseNumber;
        public String HearingId;
        public String RequestId;
        public String HearingReason;
        public String HearingType;
        public String HearingProgram;
        public String HearingDate;
        public String HearingStatus;
        public String IndividualId;

    }
    
    /**
     * Class Name                   : PreferredDetailsWrapper
     * Description                  : Preferred Dtails Wrapper
     * 
     */
    public class PreferredDetailsWrapper {
        //public attributes
        public String FirstName;
        public String LastName;
        public String MiddleInitial;
        public String City;
        public String StateCode;
        public String AddressLine1;
        public String AddressLine2;
        public String CountyCode;
        public String Email;
        public String GenderCode;
        public String PrimaryPhoneExtension;
        public String PrimaryPhoneNumber;
        public String PrimaryPhoneTypeCode;
        public String ZipCode4;
        public String ZipCode5;
    }

    /**
     * @method Name                 : SSP_HearingsSummaryInfoPayloadWrapper
     * @description                 : Default Constructor
     */
    public SSP_HearingsSummaryInfoPayloadWrapper() {
        
    }
}