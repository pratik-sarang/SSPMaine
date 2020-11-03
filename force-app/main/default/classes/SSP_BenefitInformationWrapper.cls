/**
 * Class Name           : SSP_BenefitInformationWrapper
 * Owner                : DELOITTE
 * Created Date         : 24/02/2020
 * Description          : Wrapper Class that holds Information related to BenefitInformation view
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  24/02/2020  Ragunathan		   Initial Version
 *  13/07/2020   Rajeev Kumar       New Attributes added
 */
public with sharing class SSP_BenefitInformationWrapper {
    // public attributes
    public String CaseNumber;
    public String IndividualId;
    public String IndividualName;
    public String ProgramCode;
    public String ProgramStatusCode;
    public String BenefitBeginDate;
    public String BenefitEndDate;
    public String RenewalDueDate;
    public String ReviewDate;
    public String DocumentDueDate;
    public String ApplicationSubmissionDate;
    public String DenialEffectiveDate;
    public String DenialReason;
    public String PatientLiabilityCurrentMonth;
    public String CurrentMonthPatientLiabilityAmount;
    public String PatientLiabilityUpcomingMonth;
    public String UpcomingMonthPatientLiabilityAmount;
    public String IsWaiverLinkEnabled;
    public String HasActiveSuspension;
    public String HasActivePenalty;
    public String PenaltyBeginDate;
    public String PenaltyEndDate;
    public String ReferredToFFM;
    public String PolicyHolderName;
    public String InsuranceComanyName;
    public String InsurancePlanName;
    public String PolicyId;
    public String IsPreferredPaymentAccessed;
    public String AllotmentMonth1;
    public String AllotmentAmountMonth1;
    public String AllotmentMonth2;
    public String AllotmentAmountMonth2;
    public String AllotmentMonth3;
    public String AllotmentAmountMonth3;
    public String EBTCardFundLoadDate;
    public String SNAPClaimAmount;
    public String EdgNumber;
    public String CopayMonth1;
    public String CopayAmountMonth1;
    public String CopayMonth2;
    public String CopayAmountMonth2;
    public String CopayMonth3;
    public String CopayAmountMonth3;
    public String CopayEffectiveDate;
    public String ActiveEnrollmentCount;
    public String PendingEnrollmentCount;
    public String WaiverApplicationNumber;
    public String WaiverProgramCode;
    public String DMSDocumentId;
    public String PolicyHolderId;
    public String TypeOfAssistanceCode;
    
    /**
     * @methodName      : SSP_BenefitInformationWrapper
     * @description     : Default Constructor
     */
    public SSP_BenefitInformationWrapper(){
        
    }
}