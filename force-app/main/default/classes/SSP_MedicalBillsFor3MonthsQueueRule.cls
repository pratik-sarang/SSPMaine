/*
* classname 	: SSP_MedicalBillsFor3MonthsQueueRule
* @description 	: A controller class for handling Medical Bills For 3 Months screen.
* @author 		: Naveena Malapati
* @date 		: MAR-2-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Naveena Malapati 		MAR-2-2020 		Initial Version
*/
public with sharing class SSP_MedicalBillsFor3MonthsQueueRule extends BasicNavFlowRule{
    /**
* Invoked on workflow "next" action. If true is returned then the page will be marked as "required" in the
* current flow and so it will be queued to be loaded on its turn. If false is returned then the page
* will be marked as "not required" and hence will not be loaded in the flow.
*
* @param ctx Context object
* @param ctxData ContextData object
*
* @return boolean
*/
     public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            Date timeTravelTodayDate;
            List<SSP_ApplicationIndividual__c> lstAppIndividuals = new List<SSP_ApplicationIndividual__c> ();
            timeTravelTodayDate = SSP_Utility.today();
            if(ctxData.queueObject != null && ctxData.MemberId != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ? ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ?
                												   ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c ();
                Integer numberDaysDue = appIndividualRecord != null ? appIndividualRecord.SSP_Member__r.BirthDate__c != null ?
                    					appIndividualRecord.SSP_Member__r.BirthDate__c.daysBetween(timeTravelTodayDate) : 0 : 0;
                
                String programs = appIndividualRecord.ProgramsApplied__c;
                List<String> programValues = programs != null ? programs.split(';') : new List<String> ();
                if(appIndividualRecord.SSP_Member__r.HasMedicalBillsToggle__c == SSP_GlobalConstants.YES && numberDaysDue>=30 && programValues.contains(SSP_GlobalConstants.MEDICAID))
                 {
                    result=true;
                 }
            }           
        }
         catch(Exception ex){   
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MedicalBillsFor3MonthsQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
     }
}