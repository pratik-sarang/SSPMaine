/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_HouseholdMembersSummaryCtrl
*   Created By   :   Suyash Singhal
*   Created Date :   11/13/2019
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                    11/13/2019        Initial Version
*****************************************************************************************************************************/

public with sharing class SSP_HouseholdMembersSummaryCtrl {


    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @methodname   getHouseholdDetails
    * @description  This method gets all the Household details as an init method
    * @param        sApplicationId
    * @return       none
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getHouseholdDetails(String sApplicationId, Boolean sMode, String mode){ //#385177 added mode param


       SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String,Object> mapResponse = new Map<String,Object>();
        try{ 
            SSP_Utility.isAuthenticatedUser();
            /** #385177 */
            if(String.isNotBlank(mode) && mode.equalsIgnoreCase(SSP_GlobalConstants.RAC_AddMember)){
                SSP_ApplicationSummaryController.resetRSSPDCEligibility(sApplicationId, mode);
            }
            /** */
            if(String.isNotBlank(sApplicationId)){
                List<String> lstApplicationIds = new List<String>{sApplicationId};
                mapResponse =  SSP_HouseHoldSummaryService.getHouseholdDetail(lstApplicationIds, sMode);
            }
            objResponse.bIsSuccess = Boolean.valueOf(mapResponse.get('bIsSuccess'));
            objResponse.mapResponse = MapResponse;
        }catch(Exception ex) {
            objResponse.put('bIsSuccess', false);  
            objResponse.put('error', ex);  
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseholdMembersSummaryCtrl', 'getHouseholdDetails', ex.getMessage() , true);
        }
       
        return objResponse;

    }


    

    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @methodname   getJSONData
    * @description  This method is used to collect the JSON data from the LWC component and 
                    accordingly call External services
    * @param        none
    * @return       none
    ********************************************************************************************/

    @AuraEnabled
    public static SSP_LightningResponse saveData(String sJSON,Boolean bSSNRetryFlag, Boolean sMode, Boolean callMCI){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String,Object> mapResponse = new Map<String,Object>();
        try {
            if(callMCI){
                SSP_HouseHoldSummaryService.MCIcalloutstatuscheck=true;
            }
            mapResponse = SSP_HouseHoldSummaryService.saveDataService(sJSON,bSSNRetryFlag, sMode);
            Map<String, Object> parsedJSON = (Map<String, Object>)JSON.deserializeUntyped(sJSON);
            if(sMode == true && parsedJSON.get('sRecordId') == null) {
                Id applicationId = (Id)parsedJSON.get('sApplicationId');
                SSP_Application__c application = new SSP_Application__c(
                    Id = applicationId,
                    ChangeSummaryMode__c = SSP_GlobalConstants.SSP_RAC_ADDMEMBER_SECTION
                );
                ESAPI.accessController().updateAsUser(application, new List<String>{'ChangeSummaryMode__c'});
            }
            objResponse.bIsSuccess = Boolean.valueOf(MapResponse.get('bIsSuccess'));
            objResponse.mapResponse = MapResponse;
        }catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseholdMembersSummaryCtrl', 'saveData', ex.getMessage() , true);
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;

    }

     /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @methodname   removeMember
    * @description  This method is used to delete the member record  from the SSP_Member object
                   
    * @param        sMemberId
    * @return       SSP_LightningResponse
    ********************************************************************************************/

    @AuraEnabled
    public static SSP_LightningResponse deleteMember(String sMemberId, String sApplicationIndividualId, String sMode) { 
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String,Object> mapResponse = new Map<String,Object>();
        try{
            SSP_Utility.isAuthenticatedUser();
            Map<String,Object> triggerMap = reviewRequiredOnMemberDeletion(sMemberId, sApplicationIndividualId, sMode);
            mapResponse = SSP_HouseHoldSummaryService.deleteMember(sMemberId,sApplicationIndividualId);
            mapResponse.putAll(triggerMap);
            if(triggerMap.get('triggerRule') == true) {
                ContextData ctxData = new ContextData();
                ctxData.MemberId = (Id)triggerMap.get('memberId');
                ctxData.ApplicationId = (Id)mapResponse.get('applicationId');
                SSP_RulesEngine.getRRTriggerRules(
                    (Id)mapResponse.get('applicationId'), 
                    (Id)triggerMap.get('memberId'), 
                    (List<String>)triggerMap.get('screenName'),
                    (List<String>)triggerMap.get('rules'),
                    sMode
                );
            }
            if(sMode == 'addRemoveMember') {
                Id applicationId = (Id)mapResponse.get('applicationId');
                SSP_Application__c application = new SSP_Application__c(
                    Id = applicationId,
                    ChangeSummaryMode__c = SSP_GlobalConstants.SSP_RAC_ADDMEMBER_SECTION
                );
                ESAPI.accessController().updateAsUser(application, new List<String>{'ChangeSummaryMode__c'});
            }
            objResponse.bIsSuccess = Boolean.valueOf(mapResponse.get('bIsSuccess'));
            objResponse.mapResponse = mapResponse;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseholdMembersSummaryCtrl', 'deleteMember', ex.getMessage() , true);
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }

    public static Map<String, Object> reviewRequiredOnMemberDeletion(Id memberId, Id applicationId, String mode) {
        // 1. Absent Parent Summary
        Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_Relationship__c', 'operator' => 'AND', 'IN' => 'RelationshipType__c'};
        Map<String, String> conditionsMap1 = new Map<String, String>{'RelationshipType__c' => SSP_GlobalConstants.fathersCodeList, 'SSP_Member__c' => memberId};
        Map<String, String> conditionsMap2 = new Map<String, String>{'RelationshipType__c' => SSP_GlobalConstants.mothersCodeList, 'SSP_Member__c' => memberId};
        List<SSP_Relationship__c> fathers = SSP_RelationshipSelector.queryRelationshipData(detailMap, new Set<String>{'Name', 'SSP_MemberRelatedTo__c'}, conditionsMap1);
        List<SSP_Relationship__c> mothers = SSP_RelationshipSelector.queryRelationshipData(detailMap, new Set<String>{'Name', 'SSP_MemberRelatedTo__c'}, conditionsMap2);
        Map<String,Object> mapResponse = new Map<String,Object>();
        mapResponse.put('fathers', fathers);
        mapResponse.put('mothers', mothers);
        Set<Id> children = new Set<Id>();
        for(SSP_Relationship__c parent: fathers) {
            children.add(parent.SSP_MemberRelatedTo__c); 
        }
        for(SSP_Relationship__c parent: mothers) {
            children.add(parent.SSP_MemberRelatedTo__c);
        }
        mapResponse.put('children', children);
        if(!children.isEmpty()) {
            mapResponse.put('triggerRule', true);
            mapResponse.put('memberId', new List<Id>(children).get(0));
            mapResponse.put('screenName', new List<String>{'SSP_APP_RTF_Relationships'});
            mapResponse.put('rules', new List<String>{'removeParentRelationship,true,' + String.join(new List<Id>(children), ',')});
        }
        return mapResponse;
    }

     /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @methodname   removeUnassignedProgramsOnAPP
    * @description  This method removes all the Unassigned prog from the Application record of Household
    * @param        sApplicationId
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse removeUnassignedProgramsOnAPP(String sApplicationId,String sUnassignedProgramsJson){

 
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String,Object> mapResponse = new Map<String,Object>();
        try{
            SSP_Utility.isAuthenticatedUser();
            if(String.isNotBlank(sApplicationId)){
                List<String> lstApplicationIds = new List<String>{sApplicationId};
                mapResponse = SSP_HouseHoldSummaryService.removeUnassignedProgramsOnAPP(lstApplicationIds,sUnassignedProgramsJson);
            }
            
        }catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseholdMembersSummaryCtrl', 'getHouseholdDetails', ex.getMessage() , true);
        }

        objResponse.bIsSuccess = Boolean.valueOf(mapResponse.get('bIsSuccess'));
        objResponse.mapResponse = mapResponse;
        
        return objResponse;
    }
        
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         03/20/2019
    * @methodname   fetchMemberIdNotCitizen
    * @description  This method fetches Id of Non-Citizens in the application for Review Required
    * @param        String, String
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchMemberIdNotCitizen(String memberId, String applicationId){
        List<String> memberIdList = new List<String>();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            SSP_Utility.isAuthenticatedUser();
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(String.isNotBlank(applicationId)){
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'SSP_Member__r.Age__c', 'SSP_Member__r.IsUSCitizenToggle__c', 
                                                                                         'SSP_Member__r.HasAlienSponsorToggle__c', 'SSP_Application__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId)});
            }
            if(!sspApplicationIndividualList.isEmpty()){
                for(SSP_ApplicationIndividual__c appInd : sspApplicationIndividualList){
					if(appInd.SSP_Member__r.IsUSCitizenToggle__c == SSP_GlobalConstants.NO && 
                       appInd.SSP_Member__r.HasAlienSponsorToggle__c == SSP_GlobalConstants.NO && 
                       appInd.SSP_Member__c != memberId){
                        memberIdList.add(appInd.SSP_Member__c);
                    }
        		}
            }
 			toSend.bIsSuccess = true;
            toSend.put('memberIdList', memberIdList);
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseholdMembersSummaryCtrl', 'fetchMemberIdNotCitizen', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }


    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchApplicationPrograms(String applicationId){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            SSP_Utility.isAuthenticatedUser();
            if (String.isNotBlank(applicationId)) {
                List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c', 'ProgramsApplied__c', 'MedicaidType__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId)});

                
                if (sspApplicationIndividualList != null && sspApplicationIndividualList.size() > 0) {
                    SSP_ApplicationIndividual__c appIndividual = sspApplicationIndividualList[0];
                    toSend.bIsSuccess = true;
                    toSend.put('programs', appIndividual.ProgramsApplied__c);
                    toSend.put('medicaidType', appIndividual.MedicaidType__c);

                    /** CD2 2.5	Security Role Matrix and Program Access. */
                    toSend.put('applicablePrograms', SSP_Utility.getAvailableProgramsByRole());
                    toSend.put(SSP_GlobalConstants.SECURITY_MATRIX_SUMMARY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.SSP_APP_HHMembersSummary, null)); 
                    toSend.put(SSP_GlobalConstants.SECURITY_MATRIX_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.SCREEN_ID_HH_DETAIL, null));
                    toSend.put(SSP_GlobalConstants.RAC_HH_COMPOSITION, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.RAC_HH_COMPOSITION_SCREENID, null));
                    /** */
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseholdMembersSummaryCtrl', 'fetchApplicationPrograms', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }

    //Added by Shrikant - CD2
    @AuraEnabled
    public static SSP_LightningResponse isDataProcessed(String applicationId, String mode){
        Map<String, String> detailMap = new Map<String, String>();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            SSP_Utility.isAuthenticatedUser();
            SSP_ApplicationIndividual__c appIndv = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(applicationId, new Set<String>{'SSP_Member__c','SSP_Member__r.IndividualId__c'})[0];
            if(appIndv != null && appIndv.SSP_Member__c != null && appIndv.SSP_Member__r.IndividualId__c != null){
                detailMap.put('sHOHId',appIndv.SSP_Member__r.IndividualId__c);
                detailMap.put('sScreenName','SSP_APP_HHMembersSummary');
                detailMap.put('sMode',mode);
                response= NavFlowManager.fetchTransactionStatus(detailMap);
                if( mode != null && String.isNotBlank(mode) && mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RAC_ADDMEMBER_SECTION)){
                    detailMap.put('sHOHId',appIndv.SSP_Member__r.IndividualId__c);
                    detailMap.put('sScreenName','SSP_APP_RTF_TaxFiling');
                    detailMap.put('sMode',mode);
                    response=NavFlowManager.fetchTransactionStatus(detailMap);                    
                }
            }
            else if(appIndv != null && appIndv.SSP_Member__c != null){
                response.put('status', 'NULL');
            }
            else{
                response.put('status', 'Pending');
            }
        }    
        catch(Exception ex){
            response.put('status','Pending');
            response.put('message',ex.getMessage());
        }  
        return response;
        
    }

    @auraEnabled   
    public static SSP_LightningResponse storeHOHIndvIdToCache(String applicationId){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            SSP_Utility.isAuthenticatedUser();
            Map<String, String> userDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());
            if(userDetails != null && applicationId != null && !String.isBlank(applicationId) && userDetails.containsKey('profileName') && userDetails.get('profileName').equalsIgnoreCase(SSP_GlobalConstants.NON_CITIZEN_PROFILE) && 
               userDetails.containsKey('userRole') && !userDetails.get('userRole').equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE) &&
               userDetails.containsKey('impersonatedIndividualId') && (userDetails.get('impersonatedIndividualId') == null || (userDetails.get('impersonatedIndividualId') != null && String.isBlank(userDetails.get('impersonatedIndividualId'))))){
                   SSP_ApplicationIndividual__c appIndv = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(applicationId, new Set<String>{'SSP_Member__r.IndividualId__c'})[0];
                   if(appIndv != null && appIndv.SSP_Member__r.IndividualId__c != null && !String.isBlank(appIndv.SSP_Member__r.IndividualId__c)){
                       Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
                       sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID, appIndv.SSP_Member__r.IndividualId__c);
                       User currentUser = new User(Id = UserInfo.getUserId(), ImpersonatedIndividualId__c = appIndv.SSP_Member__r.IndividualId__c);
                       update currentUser;
                   }
               }
            response.bIsSuccess = true;
        }
        catch(Exception ex){
            response.bIsSuccess = false;
        }
        return response;
    }

    /********************************************************************************************
    * @author       Suyash
    * @date          11/13/2019
    * @classname    MemberDetailsWrapper
    * @description  Wrapper class for Member Details
    **********************************************************************************************/
    public class MemberDetailsWrapper{
        @AuraEnabled public String sIdentityMethod; //CD2 Identity verfication
        @AuraEnabled public String referenceNumber; //CD2 Identity verfication
        @AuraEnabled public Boolean nonCitizenVerificationFlag; //CD2 Identity verfication
        @AuraEnabled public String matchType;
        
        @AuraEnabled public String sRecordId;
        @AuraEnabled public String sAppIndividualId;
        @AuraEnabled public String sApplicationId;
        @AuraEnabled public String memberIndividualId;
        @AuraEnabled public String sHOHMCIId;
        @AuraEnabled public String sCaseNumber;
        @AuraEnabled public boolean bisApplicationBlocked;
        @AuraEnabled public boolean bisHOH;
        @AuraEnabled public String sAge;
        @AuraEnabled public string sName;
        @AuraEnabled public string sFirstName;
        @AuraEnabled public string sMiddleName;
        @AuraEnabled public string sLastName;
        @AuraEnabled public Date dDOB;
        @AuraEnabled public String sSSN;
        @AuraEnabled public String sGender;
        @AuraEnabled public boolean bSSNVerified;
        @AuraEnabled public String bSSNPresent; 
        @AuraEnabled public boolean isUSCitizenValidated;  
        @AuraEnabled public String bisUSCitizen;
       
        @AuraEnabled public String bServedInUSMilitary;
        
        @AuraEnabled public String bKentuckyResident;
        @AuraEnabled public string sRace;
        @AuraEnabled public string sPrograms;
        @AuraEnabled public string sSufficeCode;
        
        @AuraEnabled public String sSpecialNeedIndicator;
        @AuraEnabled public string sNationalityCode;
        @AuraEnabled public String bisHispanicLatino;
        @AuraEnabled public string sEthnicityCode;
        @AuraEnabled public Date dDeathDate;
        @AuraEnabled public string sProgramsRequested;
        @AuraEnabled public string sNoReasonSSNCode;
        @AuraEnabled public string buttonAltTExt;
        @AuraEnabled public boolean showEdit ;
        @AuraEnabled public boolean isHeadOfHousehold;
        @AuraEnabled public boolean isHOHDetailsCompleted  ;
		@AuraEnabled public String appSectionStatus;
        @AuraEnabled public Boolean isFullMatch;
        @AuraEnabled public String MemberStatus;
        @AuraEnabled public Integer mciCallCount;
        @AuraEnabled public Integer sApplicationNumber;
        @AuraEnabled public String sTaxFilerMemberCurrent;
        @AuraEnabled public String sTaxFilerMemberNext;
        @AuraEnabled public Boolean sIsFileCleared;
        @AuraEnabled public Boolean bIsRACMealsRuleTriggered;
        @AuraEnabled public Boolean bIsDODVerified;
        @AuraEnabled public Boolean everyoneInHouseholdHaveSameAddress;
        @AuraEnabled public String mailingAddressLine1;
        @AuraEnabled public String physicalAddressLine1;
        @AuraEnabled public String medicaidType;
        @AuraEnabled public Boolean isBlind;
        @AuraEnabled public Boolean isDisabled;
        @AuraEnabled public Boolean isTMember;
        @AuraEnabled public String sDeathDateVerification;
        @AuraEnabled public String sAliasFirstName; // CR Changes
        @AuraEnabled public String sAliasLastName; // CR Changes
    }    
}