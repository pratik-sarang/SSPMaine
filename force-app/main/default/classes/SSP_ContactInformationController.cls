/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_ContactInformationController
*   Created By   :   Sanchita Tibrewala
*   Created Date :   11/13/2019
*   Description  :   Controller for Primary and Non Primary Applicant Contact Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 11/13/2019     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_ContactInformationController {
	
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/13/2019
    * @methodname   saveSspMemberContactInformation
    * @description  This method saves all the Contact Information retrieved from the component
    * @param        Id, String
    * @return       none
    ********************************************************************************************/
    @AuraEnabled
    public static void saveSspMemberContactInformation(String memberId, String memberContactInfo){
        SSP_Utility.isAuthenticatedUser();
        List<SSP_ApplicationIndividual__c> sspHohApplicationIndividualList = new List<SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> sspNonHohApplicationIndividualList = new List<SSP_ApplicationIndividual__c>();
        List<SSP_Member__c> sspMemberList = new List<SSP_Member__c>();
        String oldRecord;
        String newRecord;
        try{
            if(String.isNotBlank(memberId) && String.isNotBlank(memberContactInfo)){ 
                SSP_Member__c sspMember = (SSP_Member__c)JSON.deserialize(memberContactInfo, SSP_Member__c.class);
                Schema.DescribeFieldResult fieldPicklist = SSP_Member__c.PreferredSpokenLanguageCode__c.getDescribe();
                List<Schema.PicklistEntry> picklistValues = fieldPicklist.getPicklistValues();
                Map<String,String> getValueMap = new Map<String,String>();
                for(Schema.PicklistEntry val : picklistValues) {
                    getValueMap.put(val.getLabel(), val.getValue());        
                }
                if(getValueMap.get(sspMember.PreferredSpokenLanguageCode__c) != null){
                    sspMember.PreferredSpokenLanguageCode__c = getValueMap.get(sspMember.PreferredSpokenLanguageCode__c);
                }
                String phoneType = sspMember.PrimaryPhoneTypeCode__c;
                if(phoneType == SSP_GlobalConstants.PHONE_TYPE_CODE){
                    sspMember.IsPrimaryTextPreferred__c = Null;
                }
                sspMember.Id = memberId;
                sspMemberList.add(sspMember);
                
                //DEFECT#394906
                sspHohApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'IsHeadOfHousehold__c', 'SSP_Application__c','SSP_Member__r.Email__c',
                                                                                         'SSP_Member__r.PrimaryPhoneNumber__c','SSP_Member__r.PrimaryPhoneExtension__c','SSP_Member__r.PrimaryPhoneTypeCode__c',
                                                                                         'SSP_Member__r.PreferredNotificationMethodCode__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
                if(!sspHohApplicationIndividualList.isEmpty()){
                    oldRecord=sspHohApplicationIndividualList[0].SSP_Member__r.Email__c+' '+sspHohApplicationIndividualList[0].SSP_Member__r.PrimaryPhoneNumber__c+' '+
                        			sspHohApplicationIndividualList[0].SSP_Member__r.PrimaryPhoneExtension__c+' '+sspHohApplicationIndividualList[0].SSP_Member__r.PrimaryPhoneTypeCode__c+' '+
                        			sspHohApplicationIndividualList[0].SSP_Member__r.PreferredNotificationMethodCode__c;
                    newRecord=sspMember.Email__c+' '+sspMember.PrimaryPhoneNumber__c+' '+sspMember.PrimaryPhoneExtension__c+' '+sspMember.PrimaryPhoneTypeCode__c+' '+
                        			sspMember.PreferredNotificationMethodCode__c;
                }
                if(!sspHohApplicationIndividualList.isEmpty() && sspHohApplicationIndividualList[0].IsHeadOfHousehold__c && String.valueof(oldRecord) != String.valueof(newRecord)){
                    sspNonHohApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'IsHeadOfHousehold__c', 'SSP_Application__c','SSP_Member__r.Email__c',
                                                                                         'SSP_Member__r.PrimaryPhoneNumber__c','SSP_Member__r.PrimaryPhoneExtension__c','SSP_Member__r.PrimaryPhoneTypeCode__c',
                                                                                         'SSP_Member__r.PreferredNotificationMethodCode__c','SSP_Member__r.SameContactInfoAsHOH__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(sspHohApplicationIndividualList[0].SSP_Application__c),
                                                                                         'IsHeadOfHousehold__c'=> '#false#', 'SSP_Member__r.SameContactInfoAsHOH__c'=> '#true#'});
                }
                if(!sspNonHohApplicationIndividualList.isEmpty()){
                    for(SSP_ApplicationIndividual__c appInd : sspNonHohApplicationIndividualList){
                            SSP_Member__c nonHohMem = new SSP_Member__c();
                            nonHohMem.Id = appInd.SSP_Member__c;
                            nonHohMem.Email__c = sspMember.Email__c;
                            nonHohMem.PrimaryPhoneNumber__c = sspMember.PrimaryPhoneNumber__c;
                            nonHohMem.PrimaryPhoneExtension__c = sspMember.PrimaryPhoneExtension__c;
                            nonHohMem.PrimaryPhoneTypeCode__c = sspMember.PrimaryPhoneTypeCode__c;
                            nonHohMem.PreferredNotificationMethodCode__c = sspMember.PreferredNotificationMethodCode__c;
                			sspMemberList.add(nonHohMem);
                    }
                }
                Database.upsertResult[] results = ESAPI.accessController().upsertAsUser(sspMemberList, SSP_Utility.getFieldsNamesList (sspMemberList)). getResults();
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSPContactInformationController', 'saveSspMemberContactInformation', ex.getMessage() , true);
        }
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/15/2019
    * @methodname   fetchBasicSspMemberInformation
    * @description  This method retrieves all the Contact Information for primary applicant
    * @param        String
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchBasicSspMemberInformation(String memberId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            List<SSP_Member__c> sspMemberList;
            if(String.isNotBlank(memberId)){
             	sspMemberList = 
                        SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                           new Set<String>{'Id', 'Email__c', 'PrimaryPhoneNumber__c', 'PrimaryPhoneExtension__c', 
                                                                           'SecondaryPhoneNumber__c', 'SecondaryPhoneExtension__c', 'PrimaryPhoneTypeCode__c', 
                                                                           'IsPrimaryTextPreferred__c', 'PreferredNotificationMethodCode__c', 
                                                                           'PreferredSpokenLanguageCode__c', 'PreferredWrittenLanguageCode__c', 'Contact__c'}, 
                                                           new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(memberId)});
            }
            if(!sspMemberList.isEmpty() && sspMemberList.get(0).PreferredSpokenLanguageCode__c != Null){
                Map<String,String> picklistMap = SSP_Utility.getPickListValues('SSP_Member__c', 'PreferredSpokenLanguageCode__c', null);
                String picklistLabel;
                picklistLabel = picklistMap.get(sspMemberList.get(0).PreferredSpokenLanguageCode__c);
                sspMemberList.get(0).PreferredSpokenLanguageCode__c = picklistLabel;
            }
            List<User> userList;
            if(!sspMemberList.isEmpty()){
                userList = 
                    SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User'}, 
                                                   new Set<String>{'Id', 'LanguageLocaleKey'}, 
                                                   new Map<String, String>{'limit'=>'10','ContactId'=>String.escapeSingleQuotes(sspMemberList.get(0).Contact__c)});
            }
            if(!sspMemberList.isEmpty() && !userList.isEmpty()){
                User currentUser = userList.get(0);
                String languageLabel;
                Map<String,String> languagepicklistMap = SSP_Utility.getPickListValues('User', 'LanguageLocaleKey', null);
                if(currentUser.LanguageLocaleKey == System.Label.SSP_SpanishLanguageCode){
                    languageLabel = System.Label.SSP_SpanishLanguageLabel;
                }
                else{
                    languageLabel = languagepicklistMap.get(currentUser.LanguageLocaleKey);
                }
                if(sspMemberList.get(0).PreferredSpokenLanguageCode__c == Null){
                    sspMemberList.get(0).PreferredSpokenLanguageCode__c = languageLabel;
                }
                if(sspMemberList.get(0).PreferredWrittenLanguageCode__c == Null){
                    Schema.DescribeFieldResult fieldPicklist = SSP_Member__c.PreferredWrittenLanguageCode__c.getDescribe();
                    List<Schema.PicklistEntry> picklistValues = fieldPicklist.getPicklistValues();
                    Map<String,String> getValueMap = new Map<String,String>();
                    String languageValue;
                    for( Schema.PicklistEntry val : picklistValues) {
                        getValueMap.put(val.getLabel(), val.getValue());        
                    }
                
                    languageValue = getValueMap.get(languageLabel);
                    sspMemberList.get(0).PreferredWrittenLanguageCode__c = languageValue;
                }
            }
			toSend.bIsSuccess = true;
            toSend.put('record', sspMemberList.get(0));
            toSend.put('userDetails', SSP_Utility.getUserDetails(UserInfo.getUserId()));//added by Shrikant - CD2       
        }       
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSPContactInformationController', 'fetchBasicSspMemberInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/19/2019
    * @methodname   fetchHohContactInformation
    * @description  This method retrieves the Contact Information for Hoh and shows the same for 
    *               other member of the househol 
    * @param        String
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchHohContactInformation(String applicationId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(String.isNotBlank(applicationId)){
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'IsHeadOfHousehold__c', 'SSP_Application__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId), 
                                                                                         'IsHeadOfHousehold__c'=> '#true#'});
            }
            if(!sspApplicationIndividualList.isEmpty() && sspApplicationIndividualList.get(0).SSP_Member__c != null){
                List<SSP_Member__c> sspMemberList = 
                    SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                       new Set<String>{'Id', 'Email__c', 'PrimaryPhoneNumber__c', 'PrimaryPhoneExtension__c', 
                                                           'PrimaryPhoneTypeCode__c', 'PreferredNotificationMethodCode__c',
                                                           'SameContactInfoAsHOH__c'}, 
                                                       new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(sspApplicationIndividualList.get(0).SSP_Member__c)});
                if(!sspMemberList.isEmpty()){
                    SSP_Member__c record = sspMemberList.get(0);                           
                    toSend.bIsSuccess = true;
                    toSend.put('record', record);
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSPContactInformationController', 'fetchHohContactInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/21/2019
    * @methodname   fetchBasicNonPrimaryMemberInformation
    * @description  This method retrieves all the Contact Information for non-primary applicant
    * @param        String
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchBasicNonPrimaryMemberInformation(String memberId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            if(String.isNotBlank(memberId)){
            	List<SSP_Member__c> sspMemberList = 
                        SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                           new Set<String>{'Id', 'SameContactInfoAsHOH__c','Email__c', 'PrimaryPhoneNumber__c', 'PrimaryPhoneExtension__c', 
                                                                           'PrimaryPhoneTypeCode__c', 'PreferredNotificationMethodCode__c'}, 
                                                           new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(memberId)});
                if(!sspMemberList.isEmpty()){
                    SSP_Member__c record = sspMemberList.get(0);
                    toSend.bIsSuccess = true;
                    toSend.put('record', record);
                }
            }     
        }   
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSPContactInformationController', 'fetchBasicNonPrimaryMemberInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         12/03/2019
    * @methodname   fetchHohName
    * @description  This method retrieves the Contact Information for Hoh and shows the same for 
    *               other member of the househol 
    * @param        String
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchHohName(String applicationId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(String.isNotBlank(applicationId)){
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'IsHeadOfHousehold__c', 'SSP_Application__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> applicationId, 'IsHeadOfHousehold__c'=> '#true#'});
            }
            if(!sspApplicationIndividualList.isEmpty() && sspApplicationIndividualList.get(0).SSP_Member__c != null){
                List<SSP_Member__c> sspMemberList = 
                    SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                       new Set<String>{'Id', 'FirstName__c', 'LastName__c'}, 
                                                       new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(sspApplicationIndividualList.get(0).SSP_Member__c)});
                if(!sspMemberList.isEmpty()){
                    SSP_Member__c record = sspMemberList.get(0);
                    toSend.bIsSuccess = true;
                    toSend.put('record', record);
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSPContactInformationController', 'fetchHohContactInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
}