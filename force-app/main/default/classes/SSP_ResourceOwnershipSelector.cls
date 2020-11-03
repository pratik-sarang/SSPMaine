/**
* @author: Karthik Gulla
* @Class Name: SSP_ResourceOwnershipSelector
* @desc This class is used to provide the functionalities related to Resources
* @Date 11-28-2019
MODIFICATION LOG :
* */ 
public with sharing class SSP_ResourceOwnershipSelector {
   public static List<SSP_ResourceOwnership__c> queryResourceOwnershipData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_ResourceOwnership__c> lstResourceOwnershipRecords = new List<SSP_ResourceOwnership__c>();
        //if(ESAPI.accessController().isAuthorizedToView(SSP_ResourceOwnership__c.getSObjectType(), SSP_Utility.getFieldsForAuthorisedView('SSP_ResourceOwnership__c',setFields))){//Removed for Perf fix
            lstResourceOwnershipRecords = (List<SSP_ResourceOwnership__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        //}
        return lstResourceOwnershipRecords;
    }
}