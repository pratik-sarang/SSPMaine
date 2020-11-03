/**************************************************************************************************
* Class Name    : RE_AssessmentResultsCtrl 
* Owner         : Ashwin Kasture
* Created Date  : 11/09/2019
* Description   : Assessment Results class
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  11/09/2019  Ashwin Kasture 	Initial Development
**/
public with sharing class RE_AssessmentResultsCtrl {
	@AuraEnabled
    public static RE_CreateLightningServerResponse getAssessmentResourcesResults(String sUserAssessmentId,  String sGuestAssessmentResponse)
    {
        RE_AssessmentResultsWrapper objAssessmentWrapper = new RE_AssessmentResultsWrapper();
    	Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Boolean bSuccess = false;
        try
        {            
            if(String.isNotBlank(sUserAssessmentId)){
            	objAssessmentWrapper = RE_AssessmentResultsHelper.getAssessmentResources(String.escapeSingleQuotes(sUserAssessmentId), sGuestAssessmentResponse);
                mapResponse.put('lstAssessmentResults',objAssessmentWrapper);
                bSuccess = true;
            }
        }
        catch(Exception e){
            
            bSuccess = false;errorMap.put('error',e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentResultsCtrl','getAssessmentResourcesResults',e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    
        /********************************************************************************************
    * @author       Sai Kiran
    * @date         08/19/2019
    * @methodname   getOptOutInfoSharingDetails()
    * @description  This methods is used to get OptOutInfoSharing Information from Account
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getOptOutInfoSharingDetails(){
        return RE_MyPlanCtrl.getOptOutInfoSharingDetails();
    }
    
    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         08/19/2019
    * @methodname   connectDraftReferralsFromArcheTypeResults()
    * @description  This methods is used to connect Draft Referrals
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse connectDraftReferralsFromArcheTypeResults(String sAchReferralId, Boolean bAchConsentAgreed){
        //RE_Release 1.4 – Iron Dome Changes(07/14) - Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        return RE_MyPlanCtrl.connectDraftReferrals(String.escapeSingleQuotes(sAchReferralId), bAchConsentAgreed);
    }
        /********************************************************************************************
	* @author       Ashwin Kasture
	* @date         15/07/2019
	* @methodname   insertReferralForResident()
	* @description  This methods is used to insert the referral
	* @param        String objResource
	* @return       RE_CreateLightningServerResponse  
	**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReferralForResident(String strobjResource, String locationID, Boolean bConsentAgreed){//String sArchid){
        
        //RE_Release 1.4 – Iron Dome Changes(07/14) - Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        String objResource = strobjResource; //String.escapeSingleQuotes(strobjResource);
        Map<String, Object> mapRespone = (Map<String, Object>)JSON.deserializeUntyped(objResource);
        
        String strLocationId=String.isNotBlank(locationID)?String.escapeSingleQuotes(locationID):'';
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapLighnResponse = new Map<String, Object>();
        List<Referral__c> referrallst = new List<Referral__c>();
        Boolean accountIsClaimed = false;
        String accountStatus = '';
        
        if(mapRespone.get('accountIsClaimed') != null){
            accountIsClaimed = Boolean.valueOf(mapRespone.get('accountIsClaimed'));
        }
        if(mapRespone.get('accountStatus') != null){
            accountStatus = String.valueOf(mapRespone.get('accountStatus'));
        }
             
        try{
            Referral__c objReferral= new Referral__c();
            
            
            if(accountIsClaimed && accountStatus == RE_GlobalConstants.sAccountStatus){
                objReferral.Status__c= RE_GlobalConstants.STATUS_NEW;
            }else if(!accountIsClaimed){
                objReferral.Status__c= RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
            } 
            
            Id contactId = GeneralUtility.getLoggedInUserContactId();
            objReferral.Contacts__c = contactId;
            objReferral.Location__c = strLocationId;
            objReferral.Resource__c = (Id)mapRespone.get('resourceId');
            objReferral.ReferredAccountID__c = (Id)mapRespone.get('accountId');
            objReferral.OwnerId = UserInfo.getUserId();
            objReferral.DateOfReferral__c = Date.today();
            objReferral.Source__c= RE_GlobalConstants.ADDED_BY_RESIDENT;
           
                       
            RE_SharingByPassCtrl.insertReferral(objReferral);   
            bSuccess = true;  
            if(bConsentAgreed){
                Account objAccount = new Account();
                objAccount.Id = GeneralUtility.getLoggedInUserAccountId();
                objAccount.HasOptedOutOfAccount__c = false;
                RE_SharingByPassCtrl.updateSobject(Account.getSObjectType(), objAccount);
            }
            mapLighnResponse.put('referals',objReferral);
        }catch(Exception e){
            errorMap.put('error',e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ArchetypeCtrl', 'insertReferralForResident', e.getMessage()+' '+e.getStackTraceString(), true);}
 
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapLighnResponse);        
    }

/********************************************************************************************
    * @author       Nandita Bapaye
    * @date        04/10/2020
    * @methodname   loadMoreResources
    * @description  query and display goal resources on clickof Show All Resources.
    * @param        String sUserAssessId, String sGoalId,double dblLat,double dblLon
    * @return     RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse loadMoreResources(String sUserAssessId,  String sGoalId,double dblLat,double dblLon)
    {
        RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock = new RE_ArchetypeDetailWrapper.GoalBlockCls();
    	Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Boolean bSuccess = false;
        try
        {      
            if(String.isNotBlank(sGoalId)){
                
            	objGoalBlock = RE_AssessmentResultsHelper.loadMoreResources(sUserAssessId, sGoalId,dblLat,dblLon);
                mapResponse.put('lstAssessmentResults',objGoalBlock);
                bSuccess = true;
            }
        }
        catch(Exception e){
           
            bSuccess = false;errorMap.put('error',e.getMessage());    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentResultsCtrl','loadMoreResources',e.getMessage(), true);}
         return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Nandita Bapaye
    * @date        04/10/2020
    * @methodname   loadLessResources
    * @description  remove resources for goal resource list on click of See less resources
    * @param        String sGoalId,List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> objGoalBlock
    * @return     RE_CreateLightningServerResponse 
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse loadLessResources(String sGoalId,List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> objGoalBlock)
    {
        
        RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlk = new RE_ArchetypeDetailWrapper.GoalBlockCls();
    	Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Boolean bSuccess = false;
        try
        {      
            if(String.isNotBlank(sGoalId)){
            	objGoalBlk = RE_AssessmentResultsHelper.loadLessResources(sGoalId,objGoalBlock);
                mapResponse.put('lstAssessmentResults',objGoalBlk);
                bSuccess = true;
            }
        }
        catch(Exception e){
           
            bSuccess = false;errorMap.put('error',e.getMessage());    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentResultsCtrl','loadMoreResources',e.getMessage(), true);}
         return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
}