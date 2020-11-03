/*
* classname 	: SSP_HealthConditionController
* @description 	: A controller class for handling health condition screen.
* @author 		: Naveena Malapati
* @date 		: FEB-10-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Naveena Malapati 		FEB-10-2020 		Initial Version
*/
public with sharing class SSP_HealthConditionController {
    private static final String CLASSNAME = 'SSP_HealthConditionController';
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchProgramsApplied(Id applicationId, Id memberId) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        Date timeTravelTodayDate;
        try {
            SSP_Utility.isAuthenticatedUser();
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                memberId, 
                applicationId, 
                new Set<String>{'SSP_Application__r.DCCaseNumber__c','SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c'}
            );
            if(applicationIndividuals != null && !applicationIndividuals.isEmpty()) {
                if(applicationIndividuals[0].ProgramsApplied__c!=null){
                response.put('programsApplied', applicationIndividuals[0].ProgramsApplied__c.split(';'));
                }
                if(applicationIndividuals[0].MedicaidType__c!=null){
                response.put('medicaidType',applicationIndividuals[0].MedicaidType__c.split(';'));
                }
          		response.put('dcCaseNumber',applicationIndividuals[0].SSP_Application__r.DCCaseNumber__c);
                response.put('doesCaseExists',applicationIndividuals[0].SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c);
            }
            timeTravelTodayDate = SSP_Utility.today();
            response.put('timeTravelTodayDate', timeTravelTodayDate);
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'fetchEducationDetail', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
}