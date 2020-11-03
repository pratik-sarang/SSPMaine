/*
* Class Name    	: RE_LanguagePillSelectorCtrl
* Owner             : DELOITTE
* Created Date      : 05/02/2019
* Description       : Controller class for RE_LanguagePillSelector Component. 

**/

public class RE_LanguagePillSelectorCtrl {
    
/********************************************************************************************
* @author       Suyash Singhal
* @date         05/02/2019
* @methodname   getAllLanguageOptions
* @description  This methods is used to get all the Language Values present in the system
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/    
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse getAllLanguageOptions(){
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Map<String, Object> errorMap = new Map<String, Object>{};
    	List<String> listLanguages = new List<String>();
        Boolean bSuccess = false;
        
        try{
            listLanguages = GeneralUtility.getPicklistValues('Location__c','Language__c'); 
            
            if(!listLanguages.isEmpty() && listLanguages.size()>0){
                mapResponse.put('lstLanguages',listLanguages);
            }
            if(!mapResponse.isEmpty()){
                bSuccess = True;
            }
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LanguagePillSelectorCtrl','getAllLanguageOptions', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }

}