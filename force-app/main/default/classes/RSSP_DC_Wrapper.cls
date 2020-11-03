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
public with sharing class RSSP_DC_Wrapper {
    //public attributes
    public String primaryApplicationIndividualId;
    public Integer caseNumber;
    public String applicationID;
    public String individualIds;
    public String miscelleanousParameters;
    public String mode;
    public String viewName;
    public String role;
    public Object payload;
    public SSP_DashBoardInformationWrapper dashboardInformation;
    public SSP_EligibilitySummaryPayloadWrapper EligibilitySummaryPayload;
    public SSP_BenefitInformationPayloadWrapper benefitInformations;
    public SSP_MedicaidMCOInformationWrapper medicaidMCOInformation;
    public SSP_KHIPPPaymentSummaryWrapper KHIPPPaymentSummaryPayload;
    public SSP_DashboardCaseInformation dashboardCaseInfo;
    public SSP_RACSelectionDetailsWrapper racSelectionWrapper;
    public SSP_DisqualificationPayloadWrapper DisqualificationPayload;
    public SSP_PastApplicationsPayloadWrapper PastApplicationsPayload;
    public SSP_RFIInformationPayloadWrapper RFIInformationPayload;
    public SSP_NonCitizenClientInfoPayloadWrapper nonCitizenClientInfoPayload;
    public SSP_WaiverDetailsPayloadWrapper waiverDetailsPayload;
    public NonCitizenSearchCasePayloadWrapper nonCitizenSearchCasePayload;
    public SSP_claimsOverviewPayloadWrapper claimsOverviewPayload;
    public SSP_AssisterAuthRepDetailsPayloadWrapper assisterAuthRepDetailsPayload;
    public SSP_TaxForms1095AInfoPayloadWrapper taxForms1095AInfoPayload;
    public SSP_HearingsSummaryInfoPayloadWrapper hearingsSummaryInfoPayload;
    public SSP_KIHIPPPreferredPaymentPayloadWrapper KIHIPPPreferredPaymentPayload;
    public SSP_NonCitizenSearchExportPayloadWrapper nonCitizenSearchExportPayload;
    public SSP_AckResponseWRapper ACKRESPONSE;
    

    /**
     * @methodName                          : RSSP_DC_Wrapper                                 
     * @description                         : Default constructor
     */
    public RSSP_DC_Wrapper() {
        ACKRESPONSE = new SSP_AckResponseWRapper();
    }
}