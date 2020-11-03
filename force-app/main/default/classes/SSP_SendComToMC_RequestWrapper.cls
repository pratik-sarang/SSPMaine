/*
* Classname     :  SSP_SendComToMC_RequestWrapper
* @description  :  This class is request wrapper for SendComToMC Generate token Service
* @author       :  Ragunathan
* @date         :  10/01/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  10/01/2020			Initial creation
**/
public class SSP_SendComToMC_RequestWrapper {
    
    public String grant_type;
    public String client_id;
    public String client_secret;
    public String account_id;

    /**
     * Default constructor
     */
    public SSP_SendComToMC_RequestWrapper() {
        
    }
}