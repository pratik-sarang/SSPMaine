/***************************************************************************************************************************
*   Type         :   Wrapper Class
*   Name         :   SSP_ShortSnapWrapper
*   Created By   :   Naveena Malapati
*   Created Date :   9/04/2020
*   Description  :   Wrapper for ShortSnap
*  
*   Modification Log   
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Naveena                 9/04/2020     Initial Version
*****************************************************************************************************************************/
public class SSP_ShortSnapWrapper {
    public SSP_ShortSnapWrapper() {
    }
    @AuraEnabled public String SubmitType;
    @AuraEnabled public SSP_Application__c SSP_Application;
}