/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_MemberConvictionController
*   Created By   :   Samridh Manucha
*   Created Date :   01/20/2020
*   Description  :   Controller for Member Conviction Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Samridh               01/20/2020    Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_MemberConvictionController {
  
/********************************************************************************************
* @author       Samridh Manucha
* @date         12/19/2019
* @methodname   fetchDisabilityInformation
* @description  This method fetches the disability Information for a member
* @param        String, String
* @return       SSP_LightningResponse
********************************************************************************************/
@AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchConvictionInformation(String memberId, String applicationId){
    SSP_Utility.isAuthenticatedUser();        
    SSP_LightningResponse toSend = new SSP_LightningResponse();
    try{
        if(String.isNotBlank(memberId) && String.isNotBlank(applicationId)){
        List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                        SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                         new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c', 'ProgramsApplied__c', 'MedicaidType__c'}, 
                                                                                         new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId),'SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
        List<string> programsApplied = new List<string>();
            if(sspApplicationIndividualList.size() > 0)
            {
                for(SSP_ApplicationIndividual__c ind : sspApplicationIndividualList){
                                programsApplied.add(ind.programsApplied__c);           
                }                       
            }
            if(programsApplied.size() > 0)
            {
                    toSend.bIsSuccess = true;
                    toSend.put('programsApplied', programsApplied);           
            }         
          }        
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberConvictionController', 'fetchConvictionInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
}