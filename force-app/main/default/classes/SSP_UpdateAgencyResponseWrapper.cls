/*
 * Classname         :  SSP_UpdateAgencyResponseWrapper
 * @description  :  This class is Resposne wrapper for update agency
 * @author       :  Rajeev Kumar
 * @date         :  03/18/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public class SSP_UpdateAgencyResponseWrapper {
    //public attributes
    public UpdateAgencyResponseWrapper UpdateAgencyResponse;
    
    /**
     * @description:  Wrapper class for update agency
     */
    public class UpdateAgencyResponseWrapper {
        public Boolean updateAgencyResult;
    }

    /*
    public static SSP_UpdateAgencyResponseWrapper parse(String json) {
        return (SSP_UpdateAgencyResponseWrapper ) System.JSON.deserialize(json, SSP_UpdateAgencyResponseWrapper .class);
    }
    */
}