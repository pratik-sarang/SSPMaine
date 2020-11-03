public class SSP_RelationshipSelector {
    /***************************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/26/2019
    * @methodname   queryMemberData
    * @description  This methods is used to query for SSP_Relationship__c records
    * @return       List of records
    *****************************************************************************************************/
    
    public static List<SSP_Relationship__c> queryRelationshipData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_Relationship__c> lstMembers = new List<SSP_Relationship__c>();
        
        //if(ESAPI.accessController().isAuthorizedToView(SSP_Relationship__c.getSObjectType(), SSP_Utility.getFieldsForAuthorisedView('SSP_Relationship__c',setFields))){//Removed for Perf fix - Keshav
            lstMembers = (List<SSP_Relationship__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        //}
        return lstMembers;
    }
}