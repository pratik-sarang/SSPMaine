/***************************************************************************************************
*   Type        :   Selector Class
*   Name        :   SSP_NavFlowStatusSelector
*   Create By   :   Ajay Saini
*   Create Date :   JAN-06-2020
*   Description :   This class provides methods for application summary screen.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini              JAN-06-2020          Initial Version
*
*****************************************************************************************************/
public class SSP_NavFlowStatusSelector {
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         JAN-06-2020 
    * @methodname   queryFlowStatus
    * @description  Utility method to select required records.
    * @return       List of records.
    *****************************************************************************************************/
    public static List<NavFlowStatus__c> queryFlowStatus(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions) {
        List<NavFlowStatus__c> lstRecords = new List<NavFlowStatus__c>();
        //if(ESAPI.accessController().isAuthorizedToView(NavFlowStatus__c.getSObjectType(), SSP_Utility.getFieldsForAuthorisedView('NavFlowStatus__c', setFields))){- //Perf fix -Keshav
            lstRecords = (List<NavFlowStatus__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        //}
        return lstRecords;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         JAN-06-2020 
    * @methodname   queryFlowStatusByApplicationId
    * @description  Fetches all flow status recors filtered by application id.
    * @return       List of records.
    *****************************************************************************************************/
    public static List<NavFlowStatus__c> queryFlowStatusByApplicationId(Id applicationId, Set<String> setFields) {
        Map<String, String> mapDetails = new Map<String, String>{'objectName' => 'NavFlowStatus__c'};
        Map<String, String> mapConditions = new Map<String, String>{'SSPApplication__c' => applicationId};
        return queryFlowStatus(mapDetails, setFields, mapConditions);
    }
}