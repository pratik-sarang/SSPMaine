/***************************************************************************************************************************
*   Type         :   Service class
*   Name         :   SSP_PrescreeningService
*   Created By   :   Abdulrehman
*   Created Date :   06/04/2020
*   Description  :   Service class for Prescreening. Contains the method to call prescreening rule flow.
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Abdulrehman               06/04/2020   	Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_PrescreeningService{
    
    static Flow.Interview.SSP_PrescreeningRules ruleFlow;
    
    /*Name: determineEligibility
    * Description: Calls PrescreeningRule Flow and returns the result
    * Params: userInput from Prescreening Flow
    * returnType: Map of Program name and associated Decision
    */
    public static SSP_PreScreeningData determineEligibility(SSP_PreScreeningData userInput){
        
        //Set flow input variable from user inout
        Map<String, Object> flowInputMap = new Map<String, Object>();
        flowInputMap.put('noOfPeopleInHh', userInput.noOfPeopleInHh);
        flowInputMap.put('isAnyoneChild', userInput.isAnyoneChild == 'Y'? true : false);
        flowInputMap.put('checkingSavingIncome', userInput.checkingSavingIncome);
        flowInputMap.put('grossIncome', userInput.grossIncome);
        flowInputMap.put('monthlyChildCareExpense', userInput.monthlyChildCareExpense);
        flowInputMap.put('isAnyonePregnant', userInput.isAnyonePregnant == 'Y'? true : false);
        flowInputMap.put('isAnyoneMigrant', userInput.isAnyoneMigrant == 'Y'? true : false);
        flowInputMap.put('isAnyoneBlind', userInput.isAnyoneBlind == 'Y'? true : false);
        flowInputMap.put('anySSIncome', userInput.anySSIncome == 'Y'? true : false);
        flowInputMap.put('isReceivingLTC', userInput.isReceivingLTC == 'Y'? true : false);
        flowInputMap.put('isReceivingMedicare', userInput.isReceivingMedicare == 'Y'? true : false);
        flowInputMap.put('combinedShelterExpense', userInput.combinedShelterExpense);
        flowInputMap.put('anyheatingOrCoolingExpense', userInput.anyheatingOrCoolingExpense == 'Y'? true : false);
        flowInputMap.put('isHhBilledMoreThanOneExpense', userInput.isHhBilledMoreThanOneExpense == 'Y'? true : false);
        flowInputMap.put('childSupportExpense', userInput.childSupportExpense);
        
        //execute the flow
        ruleFlow = new Flow.Interview.SSP_PrescreeningRules(flowInputMap);
        ruleFlow.start();
        
        //get the output values and assign it back to user input to be used as json
        if((boolean)(ruleFlow.getVariableValue('KTAP_Decision'))){
            userInput.ktapResult = 'Eligible';
        }
        else{
            userInput.ktapResult = 'NeedMoreInfo';
        }        
        if((boolean)(ruleFlow.getVariableValue('CCAP_Decision'))){
            userInput.ccResult = 'Eligible';
        }
        else{
            userInput.ccResult = 'NeedMoreInfo';
        }
        if((boolean)(ruleFlow.getVariableValue('SNAP_Decision'))){
            userInput.snapResult = 'Eligible';
        }
        else{
            userInput.snapResult = 'NeedMoreInfo';
        }
        if((boolean)(ruleFlow.getVariableValue('MA_Decision'))){
            userInput.maResult = 'Eligible';
        }
        else{
            userInput.maResult = 'NeedMoreInfo';
        }
        
        //return the result
        return userInput;
    }
}