public class SSP_NonCustodialParentSelector {
 /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         12/16/2019
    * @methodname   queryNonCustodialParentData
    * @description  This methods is to query records related to SSP_NonCustodialParent__c object
    * @return       List<SSP_NonCustodialParent__c>
    *****************************************************************************************************/ 
    public static List<SSP_NonCustodialParent__c> queryNonCustodialParentData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_NonCustodialParent__c> lstNonCustodialParent = new List<SSP_NonCustodialParent__c>();
        lstNonCustodialParent = (List<SSP_NonCustodialParent__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstNonCustodialParent;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         JAN-5-2020
    * @methodname   queryNonCustodialParentsRelationship
    * @description  This methods is to query records related to SSP_NoncustodialRelationship__c object
    * @return       List<SSP_NoncustodialRelationship__c>
    *****************************************************************************************************/ 
    public static List<SSP_NoncustodialRelationship__c> queryNonCustodialParentsRelationship(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions) {
        List<SSP_NoncustodialRelationship__c> lstNonCustodialParent = new List<SSP_NoncustodialRelationship__c>();
        lstNonCustodialParent = (List<SSP_NoncustodialRelationship__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstNonCustodialParent;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         JAN-27-2020
    * @methodname   queryNonCustodialParentsRelationshipWithoutSharing
    * @description  This methods is to query records related to SSP_NoncustodialRelationship__c object (without sharing)
    * @return       List<SSP_NoncustodialRelationship__c>
    *****************************************************************************************************/ 
    public static List<SSP_NoncustodialRelationship__c> queryNonCustodialParentsRelationshipWithoutSharing(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions) {
        List<SSP_NoncustodialRelationship__c> lstNonCustodialParent = new List<SSP_NoncustodialRelationship__c>();
        lstNonCustodialParent = (List<SSP_NoncustodialRelationship__c>)SSP_SharingBypassFetcher.fetchRecords(mapDetails, setFields, mapConditions);
        return lstNonCustodialParent;
    }
}