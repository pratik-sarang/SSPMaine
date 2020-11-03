/*
* Classname     :  SSP_SendComToMC_ResponseWrapper
* @description  :  This class is response wrapper for SendComToMC Generate token Service
* @author       :  Ragunathan
* @date         :  10/01/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  10/01/2020			Initial creation
**/
public class SSP_SendComToMC_ResponseWrapper {

    public String access_token;
    public String error;
    public String error_uri;
    public String error_description;
    public String logName;

    /**
     * Default constructor
     */
    public SSP_SendComToMC_ResponseWrapper(){
        
    }
}