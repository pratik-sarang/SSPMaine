/***************************************************************************************************************************
*   Type         :   
*   Name         :   SSP_PreScreeningData
*   Created By   :   Narapa Naidu Pulipati
*   Created Date :   06/1/2020
*   Description  :   Class whose object contains the data answered on the Prescreening tool
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*    Narapa Naidu Pulipati      06/01/2020      Initial Version
*****************************************************************************************************************************/
public class SSP_PreScreeningData{
    @AuraEnabled public Decimal noOfPeopleInHh{get;set;}
    @AuraEnabled public String isAnyoneChild{get;set;}
    @AuraEnabled public Decimal checkingSavingIncome{get;set;}
    @AuraEnabled public Decimal grossIncome{get;set;}
    @AuraEnabled public Decimal monthlyChildCareExpense{get;set;}
    @AuraEnabled public String isAnyonePregnant{get;set;}
    @AuraEnabled public String isAnyoneMigrant{get;set;}
    @AuraEnabled public String isAnyoneBlind{get;set;}
    @AuraEnabled public String anySSIncome{get;set;}
    @AuraEnabled public String isReceivingLTC{get;set;}
    @AuraEnabled public String isReceivingMedicare{get;set;}
    @AuraEnabled public Decimal combinedShelterExpense{get;set;}
    @AuraEnabled public String anyheatingOrCoolingExpense{get;set;}
    @AuraEnabled public String isHhBilledMoreThanOneExpense{get;set;}
    @AuraEnabled public Decimal childSupportExpense{get;set;}
    @AuraEnabled public String maResult{get;set;}
    @AuraEnabled public String snapResult{get;set;}
    @AuraEnabled public String ccResult{get;set;}
    @AuraEnabled public String ktapResult{get;set;}
}