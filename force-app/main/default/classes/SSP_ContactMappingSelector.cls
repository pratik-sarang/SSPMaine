public class SSP_ContactMappingSelector {
      /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         06/10/2020
    * @methodname   queryContactMappingData
    * @description  This methods is to query records related to contact object
    * @return       List<contact_Mapping__c>
    *****************************************************************************************************/ 
      public static List<contact_Mapping__c> queryContactMappingData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<contact_Mapping__c> lstContactMapping = new List<contact_Mapping__c>();
        lstContactMapping = (List<contact_Mapping__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstContactMapping;
    }
}