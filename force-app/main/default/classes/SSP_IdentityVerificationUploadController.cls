public with sharing class SSP_IdentityVerificationUploadController {
/**
* @author: Prasanth Prasanth
* @method: getValuesFromPickList
* @desc: picklist values of Form of proof from Identity Verification Upload
*/

@AuraEnabled
public static SSP_LightningResponse getValuesFromPickList(String objectName,String fieldName, String memberId){

    SSP_LightningResponse objResponse = new SSP_LightningResponse();
    objResponse.bIsSuccess = false;
    try{
        objResponse.put(SSP_GlobalConstants.IDENTITY_DOCUMENT_UPLOAD_FOP_OPTIONS,SSP_Utility.getPickListValues(objectName,fieldName, null));                
        //Get member name
        List<SSP_Member__c> lstMember = SSP_MemberSelector.queryMemberData(
                                        new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                        new Set<String>{'Id','IndividualId__c','FirstName__c','LastName__c'},
                                        new Map<String, String>{'limit'=>'1','Id'=>memberId});
        if(lstMember!=null && lstMember.size()>0){
        	objResponse.put('memberName', lstMember[0].FirstName__c + ' ' + lstMember[0].LastName__c);
        }
        
        objResponse.bIsSuccess = true;
    }
    catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IdentityVerificationUploadController', 'getValuesFromPickList', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                        }
    return objResponse;
    
    
}
/**
* @author: Prasanth Prasanth
* @method: createJSONWrapper
* @desc: Execute MCI callout
*/

    @AuraEnabled
public static SSP_LightningResponse createJSONWrapper(String memberId, String appId,Boolean sMode, String sPage){
    SSP_LightningResponse objResponse = new SSP_LightningResponse();
    Map<String,Object> mapHouseholdDetails = new Map<String,Object>();
    List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper> lstWrapper = new List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper>();
    objResponse.bIsSuccess = false;
    try{
        SSP_HouseHoldSummaryService.MCIcalloutstatuscheck=true;
        SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objJson = new SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        List<String> lstApplicationIds = new List<String>{appId};
        objJson = getHohWrapper(lstApplicationIds, sMode);

        if(sPage.equals('documentUpload')){
           sessionPart.put('MCICallDocUPload',true);
        }else if(sPage.equals('RIDPPage')){
            sessionPart.put('MCICallRIDP',true);
        }
                      
        objResponse.put('finalProgramList',sessionPart.get('finalProgramList'));
        objResponse.put('programRemoved',sessionPart.get('programRemoved'));        
    }catch(Exception ex) { 
        List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IdentityVerificationUploadController', 'createJSONWrapper', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
    }
    return objResponse;
    
}
/**
* @author: Prasanth Prasanth
* @method: getHohWrapper
* @desc: Creating SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper wrapper object
*/

public static SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper getHohWrapper(List<String> lstApplicationId , Boolean sMode){
    List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
    map<String,SSP_ApplicationIndividual__c> mapMemberVsAppIndiv = new Map<String,SSP_ApplicationIndividual__c>();
    List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper> lstWrapper = new List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper>();
    List<SSP_Application__c> lstApps = new List<SSP_Application__c>();           
    set<String> sUnassignedPrograms = new set<String>();
    Map<String,Object> mapResult = SSP_HouseHoldSummaryService.getHouseHoldMembers(lstApplicationId[0]);
    
    lstMembers = mapResult.get('lstMembers') != null ? (List<SSP_Member__c>)mapResult.get('lstMembers') : new List<SSP_member__c>();
    lstApps =  (List<SSP_Application__c>)mapResult.get('lstApps');        
    mapMemberVsAppIndiv = (map<String,SSP_ApplicationIndividual__c>)mapResult.get('mapMemberVsAppIndiv');
    sUnassignedPrograms = (set<String>)mapResult.get('sUnassignedPrograms');
    
    for (SSP_Member__c objMember : lstMembers){
        if(null!=lstApps && lstApps.size()>0){
            SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrapper  = SSP_HouseHoldSummaryService.buildWrapperObject(objMember,mapMemberVsAppIndiv.get(objMember.Id),lstApps, sMode);                        
            if (mapMemberVsAppIndiv.get(objMember.Id).IsHeadOfHousehold__c){
                objWrapper.sHOHMCIId =String.valueOf(objMember.IndividualId__c);
                
            } 
            lstWrapper.add(objWrapper);
        }
        
        
    }
    return lstWrapper[0];   
}

        


}