/*
* classname 	: SSP_AttendaceSelector
* @description 	: A service class query attendace records.
* @author 		: Ajay Saini
* @date 		: DEC-9-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ajay Saini 		DEC-9-2019			Initial Version
*/
public class SSP_AttendaceSelector {
    private static final String OBJECTNAME = 'SSP_Attendance__c';
 
 
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         01/03/2020
    * @methodname   queryAttendanceData
    * @description  This methods is to query records related to SSP_Attendance__c object
    * @return       List<SSP_Attendance__c>
    *****************************************************************************************************/ 
    public static List<SSP_Attendance__c> queryAttendanceData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_Attendance__c> lstAttendance = new List<SSP_Attendance__c>();
        lstAttendance = (List<SSP_Attendance__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstAttendance;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-12-2019
    * @methodname   queryByMemberId
    * @description  This methods is used to query for SSP_Attendance__c records filtered on basis of member id.
    * @return       List of records
    *****************************************************************************************************/
     public static List<SSP_Attendance__c> queryByMemberId(Set<Id> setMemberIds, List<String> listFields, Boolean bIsDeleted) {
        List<SSP_Attendance__c> attendanceRecords = new List<SSP_Attendance__c>();
        Map<String, String> mapDetails = new Map<String, String>{'objectName' => OBJECTNAME,'IN'=>'SSP_Member__c', 'operator'=>'AND'};
       	Map<String, String> mapConditions = new Map<String, String>{'SSP_Member__c' => String.join(new List<Id>(setMemberIds), ','), 'IsDeleted__c' => String.valueOf(bIsDeleted)};
        Set<String> setFields = new Set<String>(listFields);
        if(ESAPI.accessController().isAuthorizedToView(SSP_Attendance__c.getSObjectType(), SSP_Utility.getFieldsForAuthorisedView(OBJECTNAME, setFields))) {
            attendanceRecords = (List<SSP_Attendance__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        }
        return attendanceRecords;
     }
}