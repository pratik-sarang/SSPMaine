/**************************************************************************************************
* Class Name    : RE_OurClientsCtrl
* Owner         : Sai Kiran
* Created Date  : 06/05/2019
* Description   : Our Clients controller class for Contact Metadata details
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
public with sharing class RE_OurClientsCtrl {
    
    @AuraEnabled
    public static  RE_CreateLightningServerResponse getContactMetadata(){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                String strContactJSON ;//= '';
        //String objType='Contact';
        String objType = RE_GlobalConstants.strSobjectName;
        String strMtdDeveloperName = RE_GlobalConstants.strMetaDataDeveloperName;
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sQuery;
        String switchCaseKey;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        List<String> myColumns = new List<String>();
        String sRole = GeneralUtility.getLoggedInUserSelectedRole();
        Boolean bIsAgencyUser = false;
        try {
            if(sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || sRole == RE_GlobalConstants.CASE_WORKER)
            {
                bIsAgencyUser = true;
            }
            //ListViewSettings__mdt lstMtdData = [SELECT List_of_Fields__c, ListOfLabels__c from ListViewSettings__mdt where DeveloperName='ClientListView'];
            ListViewSettings__mdt lstMtdData;
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnMtdData;

            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnMtdData;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('ListViewSettings__mdt', sFieldsApiName, mapQueryParameters);
            switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (switchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    lstMtdData = Database.query(sQuery); 
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OurClientsCtrl','getContactMetadata','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            List<String> lstContactFields = lstMtdData.List_of_Fields__c.split(',');
            List<String> lstContactLables = lstMtdData.ListOfLabels__c.split(',');
            
            for(Integer i=0; i<lstContactFields.size(); i++){
                if(lstContactFields[i] != 'ID'){
                    //strContactJSON = strContactJSON + '{label: '+lstContactLables[i]+', fieldName: '+lstContactFields[i]+', type: '+fieldMap.get(lstContactFields[i]).getDescribe().getType() +', sortable : true},';
                    //strContactJSON = '{"label": "'+lstContactLables[i]+'", "fieldName": "'+lstContactFields[i]+'", "type": "'+fieldMap.get(lstContactFields[i]).getDescribe().getType() +'", "sortable" : "true"}';
                   strContactJSON = RE_GlobalConstants.CONTACT_JSON;

                   
                   strContactJSON = strContactJSON.replace(RE_GlobalConstants.CONTACT_LABEL, lstContactLables[i]);

                   strContactJSON = strContactJSON.replace(RE_GlobalConstants.CONTACT_FIELD, lstContactFields[i]);
                   String sfieldType = String.valueOf(fieldMap.get(lstContactFields[i]).getDescribe().getType()); 

                   strContactJSON = strContactJSON.replace(RE_GlobalConstants.CONTACT_FIELD_TYPE, sfieldType); 

                    myColumns.add(strContactJSON);
                }
            }
            
            
            bSuccess = true;
            mapResponse.put('mycolumns', myColumns);
            mapResponse.put('bIsAgencyUser', bIsAgencyUser);
        } catch (Exception e) {errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OurClientsCtrl', 'getContactMetadata', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /**************************************************************************************
    * @author       Anuj Vashistha
    * @date         21/11/2019
    * @methodname   checkClientConsent
    * @description  This methods is used to check consent of client
    * @param        String clientId
    * @return       Boolean 
    ******************************************************************************************/
    @AuraEnabled
    public static  RE_CreateLightningServerResponse checkClientConsent(String strClientId){
        GeneralUtility.isAuthenticatedUser();
        String clientId= (!String.isBlank(strClientId))?String.escapeSingleQuotes(strClientId):'';
        
        return RE_ClientDetailsCtrl.checkConsent(clientId);
    }
    
    /**************************************************************************************
    * @author       Venkat Korra
    * @date         05/07/2020
    * @methodname   getDecryptedString
    * @description  This methods is used to decrypt the encrypted value
    * @param        String cipherText
    * @return       String 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getDecryptedString(String cipherText)
    {
        String decryptedString;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        try
        {
            cipherText = String.escapeSingleQuotes(cipherText);
            GeneralUtility.isAuthenticatedUser();
            EncryptionDecryptionSettings__c decryptionKeys = EncryptionDecryptionSettings__c.getValues('DecryptionKeyValues');
            String key = decryptionKeys.Key__c;
            String initVector = decryptionKeys.InitializationVector__c;
            if(String.isNotBlank(key) && String.isNotBlank(initVector) && String.isNotBlank(cipherText))
            {
                decryptedString = GeneralUtility.DecryptionProcess(key, initVector, cipherText);
                mapResponse.put('decryptedValue',decryptedString);
                bSuccess=true;
            }
        }catch(Exception e)
        {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_DataTableCtrl','getDecryptedString', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse); 
    }
}