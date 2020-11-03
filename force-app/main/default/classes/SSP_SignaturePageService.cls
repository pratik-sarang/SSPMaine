/*
* classname 		: SSP_SignaturePageService
* @description 		: This is the Service class for SignaturePageCtrl.
* @author 			: Sai Kiran.
* @date 			: 02/06/2019.
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_SignaturePageService {
    
     /*
* method 		: fetchApplication
* @description  : This method is used to fetch Application Obj with Application ID.
* @author 		: Sai Kiran Velpula.
* @param 		: sApplicationID - String. 
* @return 		: SSP_Application__c
* */
    public static SSP_Application__c fetchApplication(String sApplicationId){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
        SSP_Application__c objApplication;
        /*try{
}catch(Exception ex){
List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageService', 'fetchApplication', ex.getMessage() , true);
}*/
        
        List<String> lstApplicationFields = new List<String>{'ProgramsApplied__c'};
            SSP_Utility.isAuthenticatedUser();
        Boolean bViewApplicationFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), lstApplicationFields);
        if(bViewApplicationFields){
            mapConditions.put('ID',sApplicationID);
            mapConditions.put('limit','1');
            lstApplications = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                           new Set<String>{'ID','Account__c','ProgramsApplied__c','(Select ID,SSP_Member__c,MedicaidType__c,IsHeadOfHousehold__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.LaTypeCode__c From SSP_ApplicationIndividuals__r)'}, 
                                                                           mapConditions);
        }
        if(lstApplications.size()>0){
            objApplication = lstApplications[0];
        }
        return objApplication;
    }
        
    /*
* method 		: fetchRelationShip
* @description  : This method is used to fetch Relationship Obj with Member ID.
* @author 		: Sai Kiran Velpula.
* @param 		: sMemberId - String. 
* @return 		: List<SSP_Relationship__c>
* */
    public static List<SSP_Relationship__c> fetchRelationShip(Set<String> lstMemberIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Relationship__c> lstRelationship = new List<SSP_Relationship__c>();
        /*try{
}catch(Exception ex){
List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageService', 'fetchRelationship', ex.getMessage() , true);
}*/
        List<String> lstRelationshipFields = new List<String>{'RelationshipType__c','SSP_Member__c','SSP_MemberRelatedTo__c'};
            SSP_Utility.isAuthenticatedUser();
        Boolean bViewRelationshipFields = ESAPI.accessController().isAuthorizedToView(SSP_Relationship__c.getSObjectType(), lstRelationshipFields);
        if(bViewRelationshipFields){
            mapConditions.put('SSP_MemberRelatedTo__c',String.join(new List<String>(lstMemberIds), ','));
            /*mapConditions.put('RelationshipType__c','SP');
            mapConditions.put('limit','1');*/
            lstRelationship = SSP_RelationshipSelector.queryRelationshipData(new Map<String, String>{'objectName'=>'SSP_Relationship__c','IN'=>'SSP_MemberRelatedTo__c'}, 
                                                                           new Set<String>{'ID','RelationshipType__c','SSP_Member__c','SSP_Member__r.Name',
                                                                               'SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','SSP_Member__r.MiddleInitial__c','SSP_Member__r.SuffixCode__c',
                                                                               'SSP_Member__r.LaTypeCode__c','SSP_MemberRelatedTo__c','SSP_MemberRelatedTo__r.FirstName__c','SSP_MemberRelatedTo__r.LaTypeCode__c'}, 
                                                                           mapConditions);
        }
        
        return lstRelationship;
    }
    
    /*
* method 		: fetchMember
* @description  : This method is used to fetch  SSP_Member__c with Member IDs.
* @author 		: Sai Kiran Velpula.
* @param 		: memberIDs - Set. 
* @return 		: List<SSP_Member__c>
* */
    /*public static List<SSP_Member__c> fetchMember(Set<String> memberIDs){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Member__c> lstMember = new List<SSP_Member__c>();
        List<String> lstMemberFields = new List<String>{'ProgramsApplied__c'};
            try{
}catch(Exception ex){
List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageService', 'fetchRelationship', ex.getMessage() , true);
}
        SSP_Utility.isAuthenticatedUser();
        Boolean bViewMemberFields = ESAPI.accessController().isAuthorizedToView(SSP_Member__c.getSObjectType(), lstMemberFields);
        if(bViewMemberFields){
            mapConditions.put('ID',String.join(new List<String>(memberIDs), ','));
            mapConditions.put('limit','1');
            lstMember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','ID'=>'IN','operator'=>'AND'}, 
                                                                           new Set<String>{'ID','ProgramsApplied__c'}, 
                                                                           mapConditions);
        }
        
        return lstMember;
    }*/
    @AuraEnabled 
    public static SSP_LightningResponse fetchApplicationStatus(Id sApplicationId){
        
        SSP_LightningResponse response = new SSP_LightningResponse();
        String status = 'Failure';
        try{
            List<SSP_Application__c> sspAppList = [SELECT Id, DCCaseNumber__c, SSPDCMessage__c,CHFS_Exception_ID__c FROM SSP_Application__c WHERE Id  = :sApplicationId LIMIT 1];
            // List<SSP_Application__c> sspAppList = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
            //                                                        new Set<String>{'Id','DCCaseNumber__c'}, 
            //                                                        new Map<String, String>{'limit'=>'1','id'=> sApplicationId});
            if(sspAppList != null && !sspAppList.isEmpty() && sspAppList[0].SSPDCMessage__c != NULL && String.isNotBlank(sspAppList[0].SSPDCMessage__c)){
                status = 'Success';
                response.put('DCCaseNumber',sspAppList[0].DCCaseNumber__c);
                response.put('SSPDCMessage',sspAppList[0].SSPDCMessage__c);
                response.put('CHFSError',sspAppList[0].CHFS_Exception_ID__c);
            }
		response.put('status', status);
        }
        catch(Exception ex){
            response.put('ERROR', ex.getStackTraceString());
        }
        return response;
    }
    @AuraEnabled 
    public static List<AppConfig__c> fetchCustomSettings(){
        List<AppConfig__c> lstAppConfig = new List<AppConfig__c>();
        lstAppConfig = [SELECT Id, Name, Value__c from AppConfig__c WHERE Name IN ('timePeriod','timeInterval')];
        return lstAppConfig;
    }
    
    /*
* method 		: fetchTiming
* @description  : This method is used to return flag on signautre page to show banner during non bussiness working hour.
* @author 		: Rahul Kumar.
* @param 		: NA 
* @return 		: bModalFlag
* */
    
    @AuraEnabled 
    public static boolean fetchTiming(){
        
        DateTime dtMyDateTime = SSP_Utility.now(); // GMT 
        Datetime dtFormattedNow;
       
        AppConfig__c getTimeZone = AppConfig__c.getValues('timeZone');
        AppConfig__c getTimeFormat = AppConfig__c.getValues('timeFormat');
        
        String sCurrDateToStr = dtMyDateTime.format(getTimeFormat.Value__c,getTimeZone.Value__c);
        
        Timezone tz = Timezone.getTimeZone(getTimeZone.Value__c);
        Integer offset = tz.getOffset(Datetime.ValueOf(sCurrDateToStr))/(60 * 60 * 1000); 
        
        dtFormattedNow = Datetime.valueOfGMT(sCurrDateToStr);
       
        sCurrDateToStr=String.valueOfGMT(dtFormattedNow);
        String dayOfWeek= dtFormattedNow.formatGmt(SSP_GlobalConstants.DAY_FORMAT);
        
        Boolean bDailyCheck = false;
        Boolean bHolidayCheck= false;
        Boolean bWeekEndCheck= false;
        Boolean bModalFlag =false;
        
        
        try{
            List<Holiday> lstHoliday =[SELECT Id, ActivityDate FROM Holiday Limit 500];
            if(lstHoliday.size()>0){
                for(Holiday holidayData :lstHoliday){
                    Date myDate = holidayData.ActivityDate;
                    String stDateFormat = DateTime.newInstance(myDate.year(), myDate.month(), myDate.day()).format('yyyy-MM-dd');
                    
                    //dtFormattedNow.day()
                    String sCurrentDate = DateTime.newInstance(dtFormattedNow.year(), dtFormattedNow.month(),Integer.valueOf(sCurrDateToStr.split('-')[2].split(' ')[0])).format('yyyy-MM-dd');
                    if(stDateFormat == sCurrentDate){
                        bHolidayCheck= true;
                    }
                }  
            }   
            
            
            AppConfig__c getEndWorkingHour = AppConfig__c.getValues('DCBSEndWorkingHours_hr');
            AppConfig__c getEndWorkingMin = AppConfig__c.getValues('DCBSEndWorkingHours_min');
            AppConfig__c getStartWorkingHour = AppConfig__c.getValues('DCBSStartWorkingHours_hr');
            AppConfig__c getStartWorkingMin = AppConfig__c.getValues('DCBSStartWorkingHours_min');
            
            Date dtCurrentDate = SSP_Utility.today();
            
            Integer intStartHour = Integer.valueOf(getStartWorkingHour.Value__c) ;//+offset;
            Integer intEndHour = Integer.valueOf(getEndWorkingHour.Value__c) ;//+ offset;
            
            Time tNonStartWoringHour = Time.newInstance(intStartHour, Integer.valueOf(getStartWorkingMin.Value__c), 0 , 0);
            DateTime dtFormat = DateTime.newInstanceGMT(dtCurrentDate, tNonStartWoringHour);
            
            Time tNonEndHour = Time.newInstance(intEndHour, Integer.valueOf(getEndWorkingMin.Value__c), 0, 0);
            DateTime dtMidNight = DateTime.newInstanceGMT(dtCurrentDate, tNonEndHour);
            
            Datetime dtFormattedEveTime = dtFormat;
            Datetime dtFormattedMidnightTime = dtMidNight;
            
            
            if(dtFormattedNow>dtFormattedEveTime &&
               dtFormattedNow<dtFormattedMidnightTime){
                   bDailyCheck = true;
               }
            
            if(dayOfWeek == SSP_GlobalConstants.SATURDAY || dayOfWeek == SSP_GlobalConstants.SUNDAY){
                bWeekEndCheck =true;

            }
           
           
            if(bDailyCheck|| bHolidayCheck|| bWeekEndCheck){
                bModalFlag = true;
            }
        }
        catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageService', 'fetchTiming', ex.getMessage() , true);            
        }
        
        return bModalFlag;
    }

}