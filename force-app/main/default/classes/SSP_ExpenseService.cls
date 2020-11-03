public with sharing class SSP_ExpenseService {
    
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         01/03/2020
    * @methodname   isParticipatingInWorkStudyProgram
    * @description  This methods is used to identify if particular member is participating/enrolled in atleast one work study program.
    * @return       Boolean
    *****************************************************************************************************/    
    public static Boolean isParticipatingInWorkStudyProgram(Id sspMemberId){
        Boolean result = false;
        if(sspMemberId != null){
            for(SSP_Attendance__c attendance : SSP_AttendaceSelector.queryAttendanceData(new Map<String, String>{'objectName'=>'SSP_Attendance__c'}, 
                                                      new Set<String>{'IsParticipatingInWorkStudyProgramToggle__c','PlacedThroughProgramCode__c'},
                                                      new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> sspMemberId})){
                                                          if(attendance.IsParticipatingInWorkStudyProgramToggle__c == 'Y' && attendance.PlacedThroughProgramCode__c != null
                                                             && (attendance.PlacedThroughProgramCode__c == SSP_GlobalConstants.WIAPROGRAMCODE || 
                                                                 attendance.PlacedThroughProgramCode__c == SSP_GlobalConstants.TAAPROGRAMCODE)){                                                              
                                                              result = true;
                                                              break;
                                                          }
                                                      }
        }        
        return result;
    }
}