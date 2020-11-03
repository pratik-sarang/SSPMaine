/*
* classname     : SSP_Attendance_TriggerHandler
* @description  : This class is a Handler class for SSP_Attendance_Trigger.
* @author       : Karthik Gulla
* @date         : 06/22/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Karthik Gulla        06/22/2020      Initial Version
*/
public with sharing class SSP_Attendance_TriggerHandler implements SSP_ITriggerHandler {
    
    public void beforeInsert(List<SObject> newItems) {}
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {}

    /**
	* method 		: AfterUpdate
	* @description 	: Method to execute on update of IsDeleted flag on Attendance records
	* @author 		: Karthik Gulla
	* @param 		: List<SObject> newItems - Contains updated Attendance data
	* @param		: Map<Id, SObject> oldItems - Contains old Attendance data.
	* @return		: void
	* */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try{
            List<SSP_Attendance__c> lstDeletedAttendanceRecords = new List<SSP_Attendance__c>();
            for(SSP_Attendance__c sspAttendanceRecord : (List<SSP_Attendance__c>)newItems.values()){
                if(!((SSP_Attendance__c)oldItems.get(sspAttendanceRecord.Id)).IsDeleted__c
                    && sspAttendanceRecord.IsDeleted__c) {
                    lstDeletedAttendanceRecords.add(sspAttendanceRecord);
                }
            }
            if(!lstDeletedAttendanceRecords.isEmpty()) {
                trackDeletedRecordsForAttendance(lstDeletedAttendanceRecords);
            }
        } catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberHandler', 'AfterUpdate', ex.getMessage() , true);
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    public Boolean isDisabled() {
        return false;
    }

    /***************************************************************************************************
     * @author       Karthik Gulla
     * @date         06/22/2020
     * @methodname   trackDeletedRecordsForAttendance
     * @description  This method insert deleted records to Track deletion object
     * @return       void
    *****************************************************************************************************/
    public static void trackDeletedRecordsForAttendance(List<SSP_Attendance__c> lstAttendanceRecords){
        try{
            List<SSP_TrackDeletion__c> lstTrackDeletionRecords = new List<SSP_TrackDeletion__c>();        
            for(SSP_Attendance__c sspAttendanceRecord : lstAttendanceRecords){
                SSP_TrackDeletion__c sspTrackDelRecord = new SSP_TrackDeletion__c();
                sspTrackDelRecord.DCId__c = sspAttendanceRecord.DCId__c;
                sspTrackDelRecord.Source__c = SSP_GlobalConstants.EDUCATIONENROLLMENT; 
                sspTrackDelRecord.SFObject__c='SSP_Attendance__c';
                sspTrackDelRecord.SalesforceId__c = sspAttendanceRecord.Id;                
                sspTrackDelRecord.SSP_Application__c = sspAttendanceRecord.SSP_Application__c;
                sspTrackDelRecord.SSP_Member__c = sspAttendanceRecord.SSP_Member__c;
                lstTrackDeletionRecords.add(sspTrackDelRecord); 
            }
            if(!lstTrackDeletionRecords.isEmpty()){
                ESAPI.accessController().insertAsUser(lstTrackDeletionRecords, SSP_Utility.getFieldsNamesList(lstTrackDeletionRecords));
            }
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AttendanceTrigger_Handler', 'trackDeletedRecordsForAttendance', e.getMessage(), true);
        }
    }
}