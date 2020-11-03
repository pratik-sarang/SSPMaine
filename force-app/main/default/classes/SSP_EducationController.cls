/*
* classname 	: SSP_EducationController
* @description 	: A controller class for handling education summary screen.
* @author 		: Ajay Saini
* @date 		: DEC-9-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ajay Saini 		DEC-9-2019			Initial Version
*/
public with sharing class SSP_EducationController {
    private static final String CLASSNAME = 'SSP_EducationController';
    public static List<String> attendanceFields = new List<String>{'DCId__c', 'School_Name__c', 'InstitutionSchoolTypeCode__c', 'InstitutionSchoolName__r.Name__c', 'ExpectedGraduationDate__c', 'EnrollmentTypeCode__c' };
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-9-2019
    * @methodname   fetchEducationDetail
    * @description  This method is used to fetch for attendance records for a member
    * @return       List of attendance records
    *****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchEducationDetail(Id applicationId, Id memberId) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            Map<String, String> enrollmentPicklistMap = SSP_Utility.getPickListValues('SSP_Attendance__c', 'EnrollmentTypeCode__c', null);
            Map<String, String> instituteTypePicklistMap = SSP_Utility.getPickListValues('SSP_Attendance__c', 'InstitutionSchoolTypeCode__c', null);
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(memberId, applicationId, new Set<String>());
            List<SSP_Attendance__c> attendanceRecords = SSP_AttendaceSelector.queryByMemberId(new Set<Id>{memberId}, attendanceFields, false);
            if(attendanceRecords != null && !attendanceRecords.isEmpty()) {
                List<Map<String, Object>> items = new List<Map<String, Object>>();
                for(SSP_Attendance__c record: attendanceRecords) {
                    Map<String, Object> item = new Map<String, Object>();
                    item.put('Id', record.Id);
                    item.put('InstitutionSchoolName__c', record.InstitutionSchoolName__r.Name__c);
                    item.put('School_Name__c', record.School_Name__c);
                    item.put('EnrollmentTypeCode__c', enrollmentPicklistMap.get(record.EnrollmentTypeCode__c));
                    item.put('InstitutionSchoolTypeCode__c', instituteTypePicklistMap.get(record.InstitutionSchoolTypeCode__c));
                    item.put('DCId__c',record.DCId__c);
                    items.add(item);
                }
                response.put('attendanceRecords', items);
            }
            if(applicationIndividuals != null && !applicationIndividuals.isEmpty() && applicationIndividuals[0].ProgramsApplied__c != null) {
                response.put('programsApplied', applicationIndividuals[0].ProgramsApplied__c.split(';'));
            }

            /** 2.5	Security Role Matrix and Program Access. */
            response = SSP_Utility.constructSecurityWrap(response, new Map<String, String>{'securityMatrixSummary'=>SSP_GlobalConstants.HH_EDUCATION_SUMMARY_SCREENID, 
                                                                                           'securityMatrixHighestDetails'=>SSP_GlobalConstants.HH_HIGHEST_EDUCATION_DETAILS_SCREENID,
                                                                                           'securityMatrixCurrentDetails'=>SSP_GlobalConstants.HH_CURRENT_EDUCATION_DETAILS_SCREENID}); //PERF fix
            /** */
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'fetchEducationDetail', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-9-2019
    * @methodname   fetchSchoolRecords
    * @description  This method is used to fetch for account records of school type.
    * @return       List of attendance records
    *****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchSchoolRecords() {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            Set<String> fields = new Set<String>{'Name__c', 'City__c'};
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_Institution__c'};
            Map<String, String> conditionMap = new Map<String, String>{'limit' => '3000', 'RecordType.DeveloperName' => SSP_GlobalConstants.SCHOOL_RECORDTYPE_NAME};
            List<SObject> schools = SSP_SharingBypassFetcher.fetchRecords(detailMap, fields, conditionMap);
            response.put('schools', schools);
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'fetchSchoolRecords', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    /***************************************************************************************************
    * @author       Sai Kiran Velpula
    * @date         05/09/2020
    * @methodname   showHideRemoveIcon
    * @description  This method is used to show/hide the remove icon on Highest education tile.
    * @return       boolean
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse showHideRemoveIcon(Id applicationId,Id memberId) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> applicationIndividuals;
        SSP_ApplicationIndividual__c objApplicationIndividual;
        Boolean bShowRemoveIcon = true;
        try{
            SSP_Utility.isAuthenticatedUser();
            applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(memberId, applicationId, new Set<String>{'MemberProgramsApplied__c','SSP_Member__r.Age__c'});
            if(applicationIndividuals != NULL && !applicationIndividuals.isEmpty()){
                objApplicationIndividual = applicationIndividuals[0];

                Set<String> memPrograms = new Set<String>();
                if(objApplicationIndividual.MemberProgramsApplied__c!=null)
                    memPrograms.addAll(objApplicationIndividual.MemberProgramsApplied__c.split(';'));
                
                if((memPrograms.contains('SN') && (objApplicationIndividual.SSP_Member__r.Age__c >= 15 && objApplicationIndividual.SSP_Member__r.Age__c <= 49)) ||
                    memPrograms.contains('KT') || memPrograms.contains('CC')){
                    bShowRemoveIcon = false;
                }
                
            }
            response.put('bShowRemoveIcon',bShowRemoveIcon);
            response.put('MemberProgramsApplied',objApplicationIndividual.MemberProgramsApplied__c);
            response.put('Age',objApplicationIndividual.SSP_Member__r.Age__c);
            response.bIsSuccess = true;
        }catch(Exception e) {
            response.bIsSuccess = false;
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'showHideRemoveIcon', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    /***************************************************************************************************
    * @author       Karthik Gulla
    * @date         06/22/2020
    * @methodname   updateDeleteOnCurrentEducationDetailsForMembers
    * @description  This method is used to update isdeleted flag on current education records.
    * @return       boolean
    *****************************************************************************************************/
    public static void updateDeleteOnCurrentEducationDetailsForMembers(Set<Id> setMemberIds) {
        try{
            List<SSP_Attendance__c> lstAttendanceRecords = SSP_AttendaceSelector.queryByMemberId(setMemberIds, attendanceFields, false); 
            List<SSP_Attendance__c> lstToBeUpdatedRecords = new List<SSP_Attendance__c>();
            List<SSP_Attendance__c> lstToBeDeletedRecords = new List<SSP_Attendance__c>();
            for(SSP_Attendance__c sspAttendance : lstAttendanceRecords){
                if(sspAttendance.DCId__c != null){
                    sspAttendance.IsDeleted__c = true;
                    lstToBeUpdatedRecords.add(sspAttendance);
                } else {
                    lstToBeDeletedRecords.add(sspAttendance);
                }
            }
            if(!lstToBeUpdatedRecords.isEmpty()){
                ESAPI.accessController().updateAsUser(new Map<ID,SSP_Attendance__c>(lstToBeUpdatedRecords), SSP_Utility.getFieldsNamesList(lstToBeUpdatedRecords));
            }

            if(!lstToBeDeletedRecords.isEmpty()){
                ESAPI.accessController().deleteAsUser(lstToBeDeletedRecords);
            }
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'updateDeleteOnCurrentEducationDetailsForMembers', e.getMessage() , true);
        }
    }
    
    
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         JUL-11-2020
    * @methodname   isTeenParent
    * @description  This method is used to fetch for attendance records for a member
    * @return       List of attendance records
    *****************************************************************************************************/
    @AuraEnabled
    public static Boolean isTeenParent(Id applicationId, Id memberId) {
        try {
            SSP_Member__c member, hoh;
            Set<Id> members = new Set<Id>();
            List<SSP_ApplicationIndividual__c> memberIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, new Set<String>{'SSP_Member__r.Age__c'});
            for(SSP_ApplicationIndividual__c individual: memberIndividuals) {
                if(individual.SSP_Member__c == memberId) {
                    member = individual.SSP_Member__r;
                }
                if(individual.IsHeadOfHousehold__c) {
                    hoh = individual.SSP_Member__r;
                }
                if(individual.SSP_Member__c != null) {
                    members.add(individual.SSP_Member__c);
                }
            }
            if(hoh == null || member == null) {
                return null;
            }
            if(member.Age__c < 13 || member.Age__c > 17) {
                return false;
            }
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_Relationship__c', 'operator' => 'AND', 'IN' => 'RelationshipType__c'};
            Map<String, String> conditionsMap1 = new Map<String, String>{'RelationshipType__c' => 'MO,FA', 'SSP_Member__c' => hoh.Id};
            Map<String, String> conditionsMap2 = new Map<String, String>{'RelationshipType__c' => 'MO,FA', 'SSP_Member__c' => member.Id};
            List<SSP_Relationship__c> childRelationsOfHOh = SSP_RelationshipSelector.queryRelationshipData(detailMap, new Set<String>{'Name', 'SSP_MemberRelatedTo__c'}, conditionsMap1);
            List<SSP_Relationship__c> childRelationsOfMember = SSP_RelationshipSelector.queryRelationshipData(detailMap, new Set<String>{'Name', 'SSP_MemberRelatedTo__c'}, conditionsMap2);
            Set<Id> childrenOfHOh = new Set<Id>();
            Set<Id> childrenOfMember = new Set<Id>();
            for(SSP_Relationship__c relations: childRelationsOfHOh) {
                if(relations.SSP_MemberRelatedTo__c != null && members.contains(relations.SSP_MemberRelatedTo__c)) {
                    childrenOfHOh.add(relations.SSP_MemberRelatedTo__c);
                }
            }
            for(SSP_Relationship__c relations: childRelationsOfMember) {
                if(relations.SSP_MemberRelatedTo__c != null && members.contains(relations.SSP_MemberRelatedTo__c)) {
                    childrenOfMember.add(relations.SSP_MemberRelatedTo__c);
                }
            }
            childrenOfMember.retainAll(childrenOfHOh);
            return childrenOfMember.size() > 0;
        }
        catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'isTeenParent', e.getMessage() , true);
        }
        return null;
    }
}