/*
* classname 	: SSP_MedicalBillsFor3MonthsController
* @description 	: A controller class for handling Medical Bills for 3 Months screen.
* @author 		: Naveena Malapati
* @date 		: FEB-27-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Naveena Malapati 		FEB-27-2020 		Initial Version
*/
public with sharing class SSP_MedicalBillsFor3MonthsController {
    @AuraEnabled
    public static SSP_LightningResponse fetchApplicationDate(ID sApplicationID, ID sMemberID) {
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = new List<SSP_ApplicationIndividual__c>();
        SSP_ApplicationIndividual__c objAppInd = new SSP_ApplicationIndividual__c();
        try {
            /*SSP_Application__c application = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                   new Set<String>{'id', 'ApplicationReceivedDateTime__c'}, 
                                                                   new Map<String, String>{'id'=>applicationId})[0];*/
            lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                 new Set<String>{'Id','SSP_Member__c','SSP_Application__r.ApplicationReceivedDateTime__c','SSP_Member__r.BirthDate__c'}, 
                                                                                 new Map<String, String>{'limit'=>'1','SSP_Application__c'=> sApplicationID,'SSP_Member__c'=>sMemberID});
            
    
            //if(application != null && application.ApplicationReceivedDateTime__c != null) {
            if(!lstAppIndividuals.isEmpty()) {
                objAppInd = lstAppIndividuals[0];
                response.put('applicationReceivedDateTime', objAppInd.SSP_Application__r.ApplicationReceivedDateTime__c);
                             DateTime ApplicationDate=objAppInd.SSP_Application__r.ApplicationReceivedDateTime__c;
                             
                             String monthName= ApplicationDate.format('MMMMM');
                             
                Integer Month = ApplicationDate.Month();
                
                IF(ApplicationDate.Month() <= 3){
                    Integer Month1=ApplicationDate.Month() - 3 + 12-1;
                    
                    response.put('Month1',Month1);
                
                } Else{
                    Integer Month1=ApplicationDate.Month() - 3-1;
                    
                    response.put('Month1',Month1);
                }
                IF(ApplicationDate.Month() <= 2){
                    Integer Month2=ApplicationDate.Month() - 2 + 12-1;
                    
                    response.put('Month2',Month2);
                
                } Else{
                    Integer Month2=ApplicationDate.Month() - 2-1;
                    
                    response.put('Month2',Month2);
                }
                IF(ApplicationDate.Month() <= 1){
                    Integer Month3=ApplicationDate.Month() -1 + 12-1;
                    
                    response.put('Month3',Month3);
                
                } Else{
                    Integer Month3=ApplicationDate.Month() - 1-1;
                    
                    response.put('Month3',Month3);
                }
                if(objAppInd.SSP_Member__r.BirthDate__c != NULL){
                    response.put('ageInMonths',SSP_Utility.monthsBetweenDates(objAppInd.SSP_Member__r.BirthDate__c));
                }
                
            }
             response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_MedicalBillsFor3MonthsController', 'fetchApplicationDate', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        
        return response;
    }
}