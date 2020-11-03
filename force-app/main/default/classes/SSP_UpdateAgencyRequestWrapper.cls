/*
 * Classname         :  SSP_UpdateAgencyRequestWrapper
 * @description  :  This class is request Wrapper for Update agency
 * @author       :  Rajeev Kumar
 * @date         :  03/18/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public class SSP_UpdateAgencyRequestWrapper {
    /**
     * @description : Wrapper class for udpate agency
     */
    public class DCAgencyIndividualCaseAssociationModelWrapper {
        // public attributes
        public List<String> AgencyId;
        public List<String> CaseNumber;
        public List<String> IndividualId;
        public List<String> AgencyEmployeeId;
        public List<String> NewAssignment;
        public List<String> IndividualContactPhone;
        public List<String> LoggedInUserId;
        public List<String> DoiAgentId;
        public List<String> IsAgentUpdate;
        public List<String> IsAssisterUpdate;
    }
    /**
     * @description : Wrapper class for upate agency request wrapper
     */
    public class UpdateAgencyRequestWrapper {
        // public attributes
        public List<DCAgencyIndividualCaseAssociationModelWrapper> DCAgencyIndividualCaseAssociationModel;
        public List<String> Operation;
    }
}