/*
* classname 	: SSP_ClientCaseNoteCtrl
* @description 	: A controller class for Client Case Notes screen
* @author 		: Keshav Poduval
* @date 		: May-12-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Keshav Poduval 		May-12-2020			Initial Version
*/
public without sharing class SSP_ClientCaseNoteCtrl {

     /***************************************************************************************************
* @author       Keshav Poduval
* @date         06/13/2020
* @methodname   getCaseDetails
* @description  This method returns Case number and status for impersonated individual
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getCaseDetails(){
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{
            Map<String,String> mapcaseVsStatus = new Map<String,String>();
            //Map<String,String> mapStatusCodeToValue = SSP_NonCitizenDashboardController.getPicklistFromLabel(System.Label.SSP_CaseStatus);//381136
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            mapcaseVsStatus = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsStatus') != null ? 
                                                                     String.valueOf(sessionpart.get('caseVsStatus')):
                                                                     String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus')), 
                                                                     Map<String, String>.class);
            
            if(mapcaseVsStatus.size()>0){
                for(String caseNumber : mapcaseVsStatus.keySet()){
                    //mapcaseVsStatus.put(caseNumber,mapStatusCodeToValue.get(mapcaseVsStatus.get(caseNumber)));
                    mapcaseVsStatus.put(caseNumber,mapcaseVsStatus.get(caseNumber));//381136
                }
            }
            
            dataToSend.put('caseDetails',mapcaseVsStatus);
            dataToSend.put('bIsSuccess', true);
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardService', 'getCaseDetails', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;  
        
    }
    
         /***************************************************************************************************
* @author       Keshav Poduval
* @date         06/13/2020
* @methodname   getClientCaseNotes
* @description  This method takes caseNumebr and returns Case notes
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getClientCaseNotes(Integer caseNumber){
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{
            
            list<SSP_ClientCaseNote__c> listClientCaseNotes = [SELECT Id,Comments__c,Case_Number__c,LastModifiedDate FROM SSP_ClientCaseNote__c WHERE Case_Number__c = :caseNumber Order by LastModifiedDate DESC];   //381136                  
            dataToSend.put('listClientCaseNotes', listClientCaseNotes);             
            dataToSend.put('bIsSuccess', true);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardService', 'getClientCaseNotes', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;  
    }
    
    /***************************************************************************************************
* @author       Keshav Poduval
* @date         06/13/2020
* @methodname   saveClientCaseNotes
* @description  This method Save ClientCaseNotes
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse saveClientCaseNotes(Integer caseNumber,String comment){
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        SSP_ClientCaseNote__c caseNote = new SSP_ClientCaseNote__c();
        List<SSP_ClientCaseNote__c> listCCN = new List<SSP_ClientCaseNote__c>();
        caseNote.Comments__c = comment;
        caseNote.Case_Number__c = caseNumber;
        listCCN.add(caseNote);
        //ESAPI.accessController().insertAsUser(listCCN, SSP_Utility.getFieldsNamesObject(listCCN[0]));
        insert caseNote;
        dataToSend.put('dmlSuccess', true);
        dataToSend.put('bIsSuccess', true);

        return dataToSend; 
    }
}