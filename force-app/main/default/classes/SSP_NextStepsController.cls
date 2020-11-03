/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_NextStepsController
*   Created By   :   Samridh Manucha
*   Created Date :   02/24/2020
*   Description  :   Controller for Next Steps Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Samridh               02/24/2020    Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_NextStepsController {
  
/********************************************************************************************
* @author       Samridh Manucha
* @date         02/24/2020
* @methodname   enableNextSteps
* @description  This method enables next steps to be performed
* @param        List
* @return       memberDataWrapper
********************************************************************************************/

    public static memberDataWrapper enableNextSteps(List<SSP_EligibilitySummaryWrapper> SSP_EligibilitySummaryInList, Set<String> existingProgramsSet){
      memberDataWrapper memWrapper = new memberDataWrapper();
   try  {        
         if(SSP_EligibilitySummaryInList.size() > 0){
         boolean isPendingVerification = false, isPendingInterview = false, isExpeditedSNAP = false, isReferredToFFM = false, isKIHIPP = false , isKPPendingVerification= false;
         list<string> programCode = new list<string>();
         list<String> additionalProgramCodes = new list<string>();
         list<String> lstPendingInterviewPrograms = new list<string>();
         set<String> setPendingInterviewPrograms = new set<string>();
         set<string> allPrograms = SSP_GlobalConstants.ALL_PROGRAMS ;
         set<string> programs = new set<string>();           
         for(SSP_EligibilitySummaryWrapper esWrapper : SSP_EligibilitySummaryInList)
         {
             //added for KI-HIPP CR 6.11.2
             if(esWrapper.ProgramCode == SSP_GlobalConstants.PROGRAM_TYPE_KP && esWrapper.BenefitStatusCode == SSP_GlobalConstants.STATUS_CODE_PENDING_VERIFICATION){
                 isKPPendingVerification = true;
             }
            if(esWrapper.BenefitStatusCode == SSP_GlobalConstants.STATUS_CODE_PENDING_VERIFICATION) isPendingVerification = true;
            if(esWrapper.BenefitStatusCode == SSP_GlobalConstants.STATUS_CODE_PENDING_INTERVIEW)
            {            
               isPendingInterview = true;
               setPendingInterviewPrograms.add(esWrapper.ProgramCode);
             }
            if(esWrapper.EligibleForExpeditedSNAP == SSP_GlobalConstants.STATUS_CODE_ONE) isExpeditedSNAP = true;
            if(esWrapper.EligibleForKIHIPP == SSP_GlobalConstants.STATUS_CODE_ONE) isKIHIPP = true;
            if(esWrapper.IsReferredToFFM == SSP_GlobalConstants.YES && esWrapper.ProgramCode == SSP_GlobalConstants.MEDICAID) isReferredToFFM = true;
            programs.add(esWrapper.ProgramCode);
            if(allPrograms.contains(esWrapper.ProgramCode))  allPrograms.remove(esWrapper.ProgramCode);            
         }

         if(existingProgramsSet != null && !existingProgramsSet.isEmpty()){
          for(String pCode : existingProgramsSet){
            if(allPrograms.contains(pCode))  allPrograms.remove(pCode);            
          }
        }
         programCode.addall(programs) ;
         lstPendingInterviewPrograms.addall(setPendingInterviewPrograms);
         additionalProgramCodes.addall(allPrograms);        
         memWrapper.isPendingVerification = isPendingVerification;
         memWrapper.isPendingInterview = isPendingInterview;
         memWrapper.isExpeditedSNAP = isExpeditedSNAP;
         memWrapper.isReferredToFFM = isReferredToFFM;
         memWrapper.eligibleForKIHIPP = isKIHIPP;
         memWrapper.ProgramCode = programCode;  
         memWrapper.additionalPrograms = additionalProgramCodes;
         memWrapper.pendingInterviewPrograms = lstPendingInterviewPrograms;  
         memWrapper.isKPPendingVerification = isKPPendingVerification;        
        }          
      }
      catch(Exception ex){                    
          List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NextStepsController', 'enableNextSteps', ex.getMessage() , true);          
        }
        return memWrapper;
    }

    
    /********************************************************************************************
    * @author           Samridh Manucha
    * @date             FEB-25-2020
    * @SubclassName     memberDataWrapper
    * @description      This is a wrapper subclass 
    ********************************************************************************************/
    public class memberDataWrapper {
        @AuraEnabled public boolean isPendingVerification;
        @AuraEnabled public boolean isPendingInterview;
        @AuraEnabled public boolean isExpeditedSNAP;
        @AuraEnabled public boolean isReferredToFFM;
        @AuraEnabled public boolean eligibleForKIHIPP;
        @AuraEnabled public list<string> ProgramCode;
        @AuraEnabled public list<string> additionalPrograms; 
        @AuraEnabled public list<string> pendingInterviewPrograms;     
        @AuraEnabled public boolean isKPPendingVerification;
    }
    
}