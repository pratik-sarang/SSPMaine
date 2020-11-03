/*
 * Classname             : SSP_DisqualificationPayloadWrapper
 * @description          : This class is request Wrapper for Disqualification Details
 * @author               : Rajeev Kumar
 * @date                 : 03/17/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public class SSP_DisqualificationPayloadWrapper {
    // public Atrributes
    public List<DisqualificationDetailsWrapper> DisqualificationDetails;
    
    /**
     * @description : This is wrapper class for disqualification details
     */
    public class DisqualificationDetailsWrapper {
        // public attributes
        public Integer caseNumber;
        public String ProgramCode;
        public String PenaltyDisqualificationType;
        public String EffectiveStartDate;
        public String EffectiveEndDate;
        public String DMSId;
    }
    
    public SSP_DisqualificationPayloadWrapper() {
        
    }
}