/*
* classname     :  SSP_GetInterpreterModalCtrl
* @description  :  Class to get Interpreter Modal details
* @author       :  Varun Kochar   
* @date         :  28/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_GetInterpreterModalCtrl {
    
    /***************************************************************************************************
* @author       Varun Kochar
* @date         04/02/2020
* @methodname   getGetInterpreterModalDetail
* @description  This methods is used to Interpreter Modal details
* @return       
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse getGetInterpreterModalDetail(String selectedLanguage){
        try{
            SSP_LightningResponse objResponse = new SSP_LightningResponse(); 
            String loggedInUserLanguageCode = UserInfo.getLanguage();
            SSP_GetInterpreterModalWrapper wrapper = new SSP_GetInterpreterModalWrapper();
            List<SSP_InterpreterModalConfig__mdt> interpreterModalConfigList = [SELECT DeveloperName, MasterLabel, Language, 
                                                                                Label, SSP_InterpreterModalContent__c 
                                                                                FROM SSP_InterpreterModalConfig__mdt
                                                                                LIMIT 5000];
            Map<String, String> mapOfLanguageCodeAndLanguage = new Map<String, String>();
            for(String language : Label.SSP_LanguageInterpreterModal.split(';')){
               mapOfLanguageCodeAndLanguage.put(language.split('-')[1], language.split('-')[0]);
            }
            for(SSP_InterpreterModalConfig__mdt metadata : interpreterModalConfigList){
                if(selectedLanguage == metadata.DeveloperName){
                    wrapper.interpreterModalContentInSelectedLanguage = metadata.SSP_InterpreterModalContent__c;
                }
                if(loggedInUserLanguageCode == metadata.DeveloperName){
                    wrapper.interpreterModalContentInLocalLanguage = metadata.SSP_InterpreterModalContent__c;
                    wrapper.continueButtonLabel =  String.format(Label.SSP_GetInterpreterModalContinueInEnglish, new List<String>{mapOfLanguageCodeAndLanguage.get(loggedInUserLanguageCode)});
                }
            }
            objResponse.put('wrapper', wrapper);
            return objResponse;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_GetInterpreterModalCtrl', 'getGetInterpreterModalDetail', e.getMessage(), true);
        }
        return null;
        
    }
 
    public Class SSP_GetInterpreterModalWrapper{
        @AuraEnabled public String interpreterModalContentInSelectedLanguage;
        @AuraEnabled public String interpreterModalContentInLocalLanguage;
        @AuraEnabled public String continueButtonLabel;
    }
}