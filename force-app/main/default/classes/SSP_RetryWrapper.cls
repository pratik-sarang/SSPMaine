/*
 * Classname         :  SSP_RetryWrapper 
 * @description      :  Wrapper class for Retry Logic
 * @author           :  Rajeev Kumar
 * @date             :  03/04/2020
 * MODIFICATION LOG  :
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_RetryWrapper {
    // public attributes
    public boolean isRetry;
    public Integer currentCount;
    public Integer totalCount;
    
    /*
     * @description : Default Construtor
     */
    public SSP_RetryWrapper() {
        isRetry = false;
        currentCount = 0;
        totalCount = SSP_InterfaceConstants.TOTAL_RETRY;
    }
}