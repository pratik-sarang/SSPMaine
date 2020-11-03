public class SSP_UserSelector {
	/***************************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         12/02/2019
    * @methodname   queryUserData
    * @description  This methods is used to query for User records
    * @return       List of records
    *****************************************************************************************************/
    
    public static List<User> queryUserData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<User> lstUsers = new List<User>();
        
        //if(ESAPI.accessController().isAuthorizedToView(User.getSObjectType(), SSP_Utility.getFieldsForAuthorisedView('User',setFields))){// Removed for perf fix - Keshav
            lstUsers = (List<User>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
            
       //}
        return lstUsers; 
    }
}