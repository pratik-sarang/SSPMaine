/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_MemberDisabilityController
*   Created By   :   Sanchita Tibrewala
*   Created Date :   12/19/2019
*   Description  :   Controller for Member Disability Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 12/19/2019     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_MemberDisabilityController {
    
    /********************************************************************************************
* @author       Sanchita Tibrewala
* @date         12/19/2019
* @methodname   fetchDisabilityInformation
* @description  This method fetches the disability Information for a member
* @param        String, String
* @return       SSP_LightningResponse
********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchDisabilityInformation(String memberId, String applicationId, boolean isBlindnessScreen){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            if(String.isNotBlank(memberId) && String.isNotBlank(applicationId)){
                List<SSP_MemberDisabilityWrapper> memberWrapperList = new List<SSP_MemberDisabilityWrapper>();
                SSP_MemberDisabilityWrapper memberWrapper;
                List<SSP_Member__c> sspMemberList = new List<SSP_Member__c>(); 
                
                if(!isBlindnessScreen){
                    sspMemberList = 
                        SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                           new Set<String>{'Id', 'FirstName__c', 'LastName__c', 'Age__c', 
                                                               'BenefitTypeCode__c', 'HasEndStageRenalDiseaseToggle__c', 'UnableToBuyCookForSelfToggle__c',
                                                               'ParentUnableToCareForChildToggle__c', 'DisabilityStatus__c', 'GenderCode__c', 'DisabilityVerificationCode__c'}, 
                                                           new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(memberId)});
                }
                else if(isBlindnessScreen){
                    sspMemberList = 
                        SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                           new Set<String>{'Id', 'FirstName__c', 'LastName__c', 'Age__c', 
                                                               'BlindnessBenefitTypeCode__c', 'BlindnessHasEndStageRenalDisease__c',
                                                               'BlindnessParentUnableToCareForChild__c', 'BlindnessStatus__c', 'GenderCode__c', 'BlindnessVerificationCode__c'}, 
                                                           new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(memberId)});
                    
                }
                List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c', 'ProgramsApplied__c', 'MedicaidType__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId),'SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
                if(!sspMemberList.isEmpty() && !sspApplicationIndividualList.isEmpty()){
                    Map<Id, SSP_Member__c> sspMemberMap = new Map<Id, SSP_Member__c> ();
                    for(SSP_Member__c mem : sspMemberList){
                        sspMemberMap.put(mem.Id, mem);
                    }
                    Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap = new Map<Id, SSP_ApplicationIndividual__c> ();
                    for(SSP_ApplicationIndividual__c ind : sspApplicationIndividualList){
                        sspApplicationIndividualMap.put(ind.SSP_Member__c, ind);
                    }
                    memberWrapperList = getMemberDisabilityWrapper(sspMemberMap, sspApplicationIndividualMap, isBlindnessScreen);
                    if(!memberWrapperList.isEmpty()){
                        memberWrapper = memberWrapperList.get(0);
                        toSend.bIsSuccess = true;
                        toSend.put('memberWrapper', memberWrapper);
                    }
                }   
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberDisabilityController', 'fetchDisabilityInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    /********************************************************************************************
* @author       Sanchita Tibrewala
* @date         12/19/2019
* @methodname   saveDisabilityInformation
* @description  This method saves the disability Information retrieved from the component
* @param        String, String
* @return       void
********************************************************************************************/
    @AuraEnabled
    public static void saveDisabilityInformation(String memberId, String memberDisabilityInfo, boolean isBlindnessScreen){
        SSP_Utility.isAuthenticatedUser();
        try{
            if(String.isNotBlank(memberId) && String.isNotBlank(memberDisabilityInfo)){
                SSP_MemberDisabilityWrapper memberDisabilityWrapper = (SSP_MemberDisabilityWrapper)JSON.deserialize(memberDisabilityInfo, SSP_MemberDisabilityWrapper.class);
                String data = memberDisabilityWrapper.benefitTypeCode;
                Boolean buyCookValueChange = false;

                if(String.isNotBlank(data)){
                    data = data.replace(',', ';');
                    memberDisabilityWrapper.benefitTypeCode = data;
                }
                List<SSP_Member__c> updatedMemberList = new List<SSP_Member__c>();
                List<SSP_Member__c> sspMemberList =  new List<SSP_Member__c>();
                
                if(!isBlindnessScreen){
                    sspMemberList = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                                       new Set<String>{'Id', 'FirstName__c', 'LastName__c', 'Age__c', 'DisabilityVerificationCode__c',
                                                                           'BenefitTypeCode__c', 'HasEndStageRenalDiseaseToggle__c', 'UnableToBuyCookForSelfToggle__c',
                                                                           'ParentUnableToCareForChildToggle__c', 'DisabilityStatus__c', 'GenderCode__c'}, 
                                                                       new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(memberId)});
                    
                    if(!sspMemberList.isEmpty()){
                        SSP_Member__c sspMember = sspMemberList.get(0);
                        if(!String.isNotBlank(sspMember.UnableToBuyCookForSelfToggle__c) && memberDisabilityWrapper.unableToBuyCookForSelf != null){
                            buyCookValueChange = true;
                        }
                        sspMember.BenefitTypeCode__c = memberDisabilityWrapper.benefitTypeCode;
                        if(memberDisabilityWrapper.hasEndStageRenalDisease != null){
                            sspMember.HasEndStageRenalDiseaseToggle__c = memberDisabilityWrapper.hasEndStageRenalDisease;
                        }
                        else{
                            sspMember.HasEndStageRenalDiseaseToggle__c = null;
                        }
                        if(memberDisabilityWrapper.unableToBuyCookForSelf != null){
                            sspMember.UnableToBuyCookForSelfToggle__c = memberDisabilityWrapper.unableToBuyCookForSelf;
                        }
                        else{
                            sspMember.UnableToBuyCookForSelfToggle__c = null;
                        }
                        if(memberDisabilityWrapper.parentUnableToCareForChild != null){
                            sspMember.ParentUnableToCareForChildToggle__c = memberDisabilityWrapper.parentUnableToCareForChild;
                        }
                        else{
                            sspMember.ParentUnableToCareForChildToggle__c = null;
                        }
                        sspMember.DisabilityStatus__c = memberDisabilityWrapper.disabilityPermanentTemporary;
                        
                        if(!sspMember.DisabilityVerificationCode__c || (sspMember.DisabilityVerificationCode__c && buyCookValueChange)){
                        updatedMemberList.add(sspMember);
                        //ESAPI.accessController().upsertAsUser(updatedMemberList, SSP_Utility.getFieldsNamesList (updatedMemberList));
                        SSP_GenericDMLHelper.upsertRecords(updatedMemberList,new List<String>{'HasEndStageRenalDiseaseToggle__c','UnableToBuyCookForSelfToggle__c','ParentUnableToCareForChildToggle__c','DisabilityStatus__c'});//Added for Perf fix - Keshav
                        }
                    }
                    
                }
                else if(isBlindnessScreen){
                    sspMemberList = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                                       new Set<String>{'Id', 'FirstName__c', 'LastName__c', 'Age__c', 
                                                                           'GenderCode__c', 'BlindnessBenefitTypeCode__c', 'BlindnessHasEndStageRenalDisease__c',
                                                                           'BlindnessParentUnableToCareForChild__c', 'BlindnessStatus__c','BlindnessVerificationCode__c'
                                                                           }, 
                                                                       new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(memberId)});
                    
                   

                    if(!sspMemberList.isEmpty()){
                        SSP_Member__c sspMember = sspMemberList.get(0);
                        
                        sspMember.BlindnessBenefitTypeCode__c = memberDisabilityWrapper.benefitTypeCode;
                        if(memberDisabilityWrapper.hasEndStageRenalDisease != null){
                            sspMember.BlindnessHasEndStageRenalDisease__c = memberDisabilityWrapper.hasEndStageRenalDisease;
                        }
                        else{
                            sspMember.BlindnessHasEndStageRenalDisease__c = null;
                        }
                        if(memberDisabilityWrapper.parentUnableToCareForChild != null){
                            sspMember.BlindnessParentUnableToCareForChild__c = memberDisabilityWrapper.parentUnableToCareForChild;
                        }
                        else{
                            sspMember.BlindnessParentUnableToCareForChild__c = null;
                        }
                        sspMember.BlindnessStatus__c = memberDisabilityWrapper.disabilityPermanentTemporary;
                        if(!sspMember.BlindnessVerificationCode__c){
                        updatedMemberList.add(sspMember);
                      
                        //ESAPI.accessController().upsertAsUser(updatedMemberList, SSP_Utility.getFieldsNamesList (updatedMemberList));
                        SSP_GenericDMLHelper.upsertRecords(updatedMemberList,new List<String>{'BlindnessHasEndStageRenalDisease__c','BlindnessParentUnableToCareForChild__c','BlindnessParentUnableToCareForChild__c','BlindnessStatus__c'});//Added for Perf fix - Keshav
                        }
                    }  
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ContactInformationController', 'saveSspMemberContactInformation', ex.getMessage() , true);
        } 
    }
    
    /*************************************************************************************************************************
* @author       Sanchita Tibrewala
* @date         12/19/2019
* @methodname   getMemberDisabilityWrapper
* @description  This method creates the wrapper that is sent to the screen
* @param        Map<Id, SSP_Member__c>, Map<Id, SSP_ApplicationIndividual__c>
* @return       List<SSP_MemberDisabilityWrapper>
**************************************************************************************************************************/
    public static List<SSP_MemberDisabilityWrapper> getMemberDisabilityWrapper(Map<Id, SSP_Member__c> sspMemberMap, Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap, boolean isBlindnessScreen){
        SSP_Utility.isAuthenticatedUser();
        List<SSP_MemberDisabilityWrapper> memberWrapperList = new List<SSP_MemberDisabilityWrapper>(); 
        try{
            for(Id mem : sspMemberMap.keySet()){
                SSP_MemberDisabilityWrapper memberWrapper = new SSP_MemberDisabilityWrapper();
                memberWrapper.Id = sspMemberMap.get(mem).Id;
                memberWrapper.memberFullName = sspMemberMap.get(mem).FirstName__c + ' ' +sspMemberMap.get(mem).LastName__c;
                memberWrapper.age = (Integer)sspMemberMap.get(mem).Age__c;
                memberWrapper.genderCode = sspMemberMap.get(mem).GenderCode__c;
                memberWrapper.programsApplied = sspApplicationIndividualMap.get(mem).ProgramsApplied__c;
                if(!isBlindnessScreen){
                    memberWrapper.benefitTypeCode = sspMemberMap.get(mem).BenefitTypeCode__c;
                    memberWrapper.hasEndStageRenalDisease = sspMemberMap.get(mem).HasEndStageRenalDiseaseToggle__c;
                    memberWrapper.unableToBuyCookForSelf = sspMemberMap.get(mem).UnableToBuyCookForSelfToggle__c;
                    memberWrapper.parentUnableToCareForChild = sspMemberMap.get(mem).ParentUnableToCareForChildToggle__c;
                    memberWrapper.disabilityPermanentTemporary = sspMemberMap.get(mem).DisabilityStatus__c;
                    memberWrapper.isDisabilityVerified = sspMemberMap.get(mem).DisabilityVerificationCode__c;
                }
                else if(isBlindnessScreen){
                    memberWrapper.benefitTypeCode = sspMemberMap.get(mem).BlindnessBenefitTypeCode__c;
                    memberWrapper.hasEndStageRenalDisease = sspMemberMap.get(mem).BlindnessHasEndStageRenalDisease__c;
                    memberWrapper.parentUnableToCareForChild = sspMemberMap.get(mem).BlindnessParentUnableToCareForChild__c;
                    memberWrapper.disabilityPermanentTemporary = sspMemberMap.get(mem).BlindnessStatus__c;
                    memberWrapper.isBlindnessVerified = sspMemberMap.get(mem).BlindnessVerificationCode__c;
                }
                memberWrapperList.add(memberWrapper);
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberDisabilityController', 'getMemberDisabilityWrapper', ex.getMessage() , true);
        }
        return memberWrapperList;
    }
}