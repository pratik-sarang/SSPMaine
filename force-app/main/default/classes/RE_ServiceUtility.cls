/**
* Class Name    : RE_ServiceUtility
* Owner         : DELOITTE
* Created Date  : 04/06/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  SRIKANTH       Initial Version
*  
**/
public with sharing class RE_ServiceUtility {
    
    private static RE_ServiceInterface serviceInterface;
    public static RE_ServiceInterface getServiceImplementationHandler(String  sServiceName) {
        if (serviceInterface == null) {
            Type objType;
        	Map<String, String> mapQueryParameters = new Map<String, String>();
            String sFieldsApiName = RE_DataBaseQueryFields.FIELDS_SERVICE_UTILITY;
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_SERVICE_UTILITY;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ResourceEngineConfiguration__mdt',sFieldsApiName,mapQueryParameters);
            List<ResourceEngineConfiguration__mdt> lstConfigurations = Database.query(sQuery);
            if (lstConfigurations != null && lstConfigurations.size() > 0 && lstConfigurations[0].Value__c != null) {
                objType = Type.forName(lstConfigurations[0].Value__c);
            } else {
                objType = Type.forName('RE_OrganizationSearch');
            }
            serviceInterface = (RE_ServiceInterface) objType.newInstance();
        }
        return serviceInterface;
    }
    
}