/*
 * Classname                     :  SSP_PastApplicationsPayload
 * @description                  :  This class wrapper class for past Applicatons
 * @author                       :  Rajeev Kumar
 * @date                         :  03/07/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_PastApplicationsPayloadWrapper {
    //public attributes
    public List<SSP_PastApplicationsWrapper> PastApplications;
    
    /*
     * Classname                 :  SSP_PastApplicationsWrapper
     * @description              :  Wrapper Class for past applications
     */
    public class SSP_PastApplicationsWrapper {
        // public attributes
        public Integer IndividualId;
        public Integer CaseNumber;
        public String CaseStatusCode;
        public Integer ApplicationNumber;
        public String ApplicationReceivedDate;
        public String ProgramAppliedFor;
        public String DMSId;
        public String IsAgreeingToMedicaidPenalty;
        public String IsAgreeingToLTCResourceTransferConsent;
        public String IsRenewalConsent;
        public String IsApplicantAgreeToWorkRegister;
        public String IsRegisteredToVote;
        public String DeclrtnfAnnuitiesAcceptanceCode;
        public String IsDMSAnnuitiesBeneficiary;
    }
    
    /*
     * @methodName                : SSP_PastApplicationsPayloadWrapper
     * @description               : Default Construtor
     */
    public SSP_PastApplicationsPayloadWrapper() {
        
    }
}