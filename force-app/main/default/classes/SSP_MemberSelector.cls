public class SSP_MemberSelector {
    private static final String objectName = 'SSP_Member__c';
    /***************************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/20/2019
    * @methodname   queryMemberData
    * @description  This methods is used to query for SSP_Member__c records
    * @return       List of records
    *****************************************************************************************************/
    
    public static List<SSP_Member__c> queryMemberData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        
    
            lstMembers = (List<SSP_Member__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);

        return lstMembers;
    }
    
   /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-02-2019
    * @methodname   queryMemberDataById
    * @description  This methods is used to query for SSP_Member__c records
    * @return       List of records
    *****************************************************************************************************/
    public static SSP_Member__c queryMemberDataById(Id memberId, List<String> listFields) {
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        Map<String, String> mapDetails = new Map<String, String>{'objectName' => objectName};
       	Map<String, String> mapConditions = new Map<String, String>{'Id' => memberId};
        Set<String> setFields = new Set<String>(listFields);
        //if(ESAPI.accessController().isAuthorizedToView(SSP_Member__c.getSObjectType(), SSP_Utility.getFieldsForAuthorisedView('SSP_Member__c', setFields))){ //removed for Perf fix- Keshav
            lstMembers = (List<SSP_Member__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        //}
        if(!lstMembers.isEmpty()) {
            return lstMembers[0];
        }
        return null;
    }
}