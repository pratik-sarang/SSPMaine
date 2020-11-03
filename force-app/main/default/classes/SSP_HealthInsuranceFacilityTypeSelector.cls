/*
* classname     :  SSP_HealthInsuranceFacilityTypeSelector
* @description  :  Selector class for SSP_HealthInsuranceFacilityType__c
* @author       :  Varun Kochar 
* @date         :  14/01/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_HealthInsuranceFacilityTypeSelector {

    /***************************************************************************************************
    * @author       Varun Kochar
    * @date         14/01/2020
    * @methodname   queryAssetData
    * @description  This methods is to query records related to SSP_HealthInsuranceFacilityType__c object
    * @return       List<SSP_HealthInsuranceFacilityType__c>
    *****************************************************************************************************/ 
    public static List<SSP_HealthInsuranceFacilityType__c> queryHealthInsuranceFacilityTypeData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_HealthInsuranceFacilityType__c> lstFacility = new List<SSP_HealthInsuranceFacilityType__c>();
        lstFacility = (List<SSP_HealthInsuranceFacilityType__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstFacility;
    }
    
}