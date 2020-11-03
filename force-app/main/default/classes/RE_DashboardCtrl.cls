/**
 * Class Name    : RE_DashboardCtrl
 * Owner         : DELOITTE
 * Created Date  : 05/02/2019
 * Description   : Controller class for Dashboard
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer       Description                                                         
 *  ----------  -----------     -------------------------------------------------------------------
 *  05/09/2019  PANKAJ       Initial Version
 *  7/30/2020   SIRI         New Security Changes - Changing getLoggedInUserRole method.
 **/
public with sharing class RE_DashboardCtrl{
   /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   getLoggedInUserRole()
    * @description  This methods is used to get the logged in user contact role
    * @return       RE_CreateLightningServerResponse 
    * @Modification  Siri: 7/31/2020 - fetching logged in roles instead of profiles as part of New Security Changes.
    **********************************************************************************************/
     @AuraEnabled
     public static RE_CreateLightningServerResponse getLoggedInUserRole(){
         Boolean bSuccess = false;
         Boolean bIsCPUserProfile = false;
         Boolean bIsAdminStaff = false;
         Boolean bIsAdminUser = false;
         Boolean bIsAssister = false;
         Boolean bIsResident = false;
         Boolean bIsAgencyUserProfile = false;
         Boolean bIsAgencyAdminStaff = false;
         Boolean bIsAgencyAdminUser = false;
         Map<String, Object> errorMap    = new Map<String, Object>{};
         Map<String, Object> mapResponse = new Map<String, Object>{};
             try{
               //RE_Release 1.1 – Error Log Fix - Payal Dubela
                if(UserInfo.getUserType() != RE_GlobalConstants.GUEST) {
                 String sRole = GeneralUtility.getLoggedInUserSelectedRole();
                 //Profile sProfile = GeneralUtility.getLoggedInUserProfile();
                 if(sRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN ||sRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF){
                    bIsCPUserProfile = true;
                    bIsAdminStaff=true;
                 }
                 if(sRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN){
                    bIsAdminUser=true;
                 }
                 if(sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || sRole == RE_GlobalConstants.CASE_WORKER){
                    bIsAgencyUserProfile = true;
                    bIsAgencyAdminStaff=true;
                 }
                 if(sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR){
                    bIsAgencyAdminUser = true;
                 } 
                 if(sRole == RE_GlobalConstants.strCitizenAppRole){
                     bIsResident = true;
                 }
                 if(sRole == RE_GlobalConstants.ASSISTER){
                    bIsAssister=true;
                }
                 ID userid=UserInfo.getUserId();
                 
                 mapResponse.put('bIsResident', bIsResident);
                 mapResponse.put('bIsCPUserProfile', bIsCPUserProfile);
                 mapResponse.put('userrole', sRole);
                 mapResponse.put('bIsAdminStaff', bIsAdminStaff);
                 mapResponse.put('bIsAdminUser', bIsAdminUser);
                 mapResponse.put('bIsAssister', bIsAssister);
                 mapResponse.put('bIsAgencyUserProfile', bIsAgencyUserProfile);
                 mapResponse.put('bIsAgencyAdminStaff', bIsAgencyAdminStaff);
                 mapResponse.put('bIsAgencyAdminUser', bIsAgencyAdminUser);
                 bSuccess =  true;
               }
            }catch(Exception e){
                 errorMap.put('error',e.getMessage());
                 LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_DashboardController', 'getLoggedInUserProfile', e.getMessage(), true);
             }
         
         return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
     }
}