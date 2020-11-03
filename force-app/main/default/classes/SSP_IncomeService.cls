/**
* method        : SSP_IncomeService
* @description  : This class is service class for income module
* @date         :  11/20/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/ 
public with sharing class SSP_IncomeService {


/***************************************************************************************************
* @author       Shrikant Raut
* @date         11/26/2019
* @methodname   updateExistingIncomeRecords
* @description  This methods is used to update SSP_Asset__c records
* @return       Boolean
*****************************************************************************************************/    
    public static Boolean updateSSPAssetRecords(String incomeJSON){
        Boolean result = true;
        List<SSP_Asset__c> incomeList; 
        Set<String> setAccessFields = new Set<String>();
        if(incomeJSON != null && Schema.sObjectType.SSP_Asset__c.isUpdateable()){
            incomeList = (List<SSP_Asset__c>)JSON.deserialize(incomeJSON, List<SSP_Asset__c>.class);

            //Added as a part of Defect Fix to pass all fields for different asset types
            for(SSP_Asset__c sspAssetRecord : incomeList){
                setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspAssetRecord));
            }
            SSP_GenericDMLHelper.updateRecords(incomeList,  new List<String>(setAccessFields));
        }
        
        return result;
    }

    /**
    * @author: Karthik Gulla
    * @method: getIEESPicklistKeyForIncome
    * @desc This method is used to get IEES picklist key if available
    * @param {String sSourceValue, String sSalesforceKey}
    * @return String
    * */
    public static String getIEESPicklistKeyForIncome(String sSourceValue, String sIncomeType, String sSalesforceKey){
        Map<String,SSP_PicklistConversion_Configurations__mdt> mapPicklistConversionMappings = SSP_Utility.getPicklistConversionMappings('SalesforcePicklistKey__c', 'Income', sIncomeType);
        String sReturnKey = '';
        try{
            if(!mapPicklistConversionMappings.isEmpty() && mapPicklistConversionMappings.get(sSalesforceKey) != null) {
                sReturnKey = mapPicklistConversionMappings.get(sSalesforceKey).IEESReferenceKey__c;
            } else {
                sReturnKey = sSalesforceKey;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_IncomeService', 'getIEESPicklistKeyForIncome', e.getMessage(), true);
        }
        return sReturnKey;
    }
}