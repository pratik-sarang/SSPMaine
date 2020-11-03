/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_AmericanIndianInformationController
*   Created By   :   Sanchita Tibrewala
*   Created Date :   01/08/2020
*   Description  :   Controller American Indian and Alaskan Native Information Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 01/08/2020     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_AmericanIndianInformationController {
	
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         01/08/2020
    * @methodname   fetchAmericanIndianMemberInformation
    * @description  This method retrieves all the American Indian Tribe Information for a member
    * @param        String
    * @return       SSP_LightningResponseResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchAmericanIndianMemberInformation(String memberId){        
		SSP_Utility.isAuthenticatedUser();        
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            List<SSP_Member__c> sspMemberList;
            if(String.isNotBlank(memberId)){
             	sspMemberList = 
                        SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                           new Set<String>{'Id', 'IsFederalRecognizedIndianTribeToggle__c', 'IndianTribeCode__c', 'IndianTribeState__c', 
                                                                           'IsEligibleForIHFlagToggle__c', 'IsEligibleForIndianHealthServicesToggle__c'}, 
                                                           new Map<String, String>{'limit'=>'10','Id'=> String.escapeSingleQuotes(memberId)});
            }
            if(!sspMemberList.isEmpty()){
                SSP_Member__c record = sspMemberList.get(0);
                if(record.IndianTribeCode__c != Null){
                    Map<String,String> picklistMap = SSP_Utility.getPickListValues('SSP_Member__c', 'IndianTribeCode__c', null);
                    String picklistLabel;
                    picklistLabel = picklistMap.get(record.IndianTribeCode__c);
                    record.IndianTribeCode__c = picklistLabel;
                }
                if(record.IndianTribeState__c != Null){
                    Map<String,String> picklistMap = SSP_Utility.getPickListValues('SSP_Member__c', 'IndianTribeState__c', null);
                    String picklistLabel;
                    picklistLabel = picklistMap.get(record.IndianTribeState__c);
                    record.IndianTribeState__c = picklistLabel;
                }
                toSend.bIsSuccess = true;
                toSend.put('record', record);
            }
        }       
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AmericanIndianInformationController', 'fetchAmericanIndianMemberInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         01/08/2020
    * @methodname   saveAmericanIndianMemberInformation
    * @description  This method saves all the American Indian Tribe Information retrieved from the component
    * @param        Id, String
    * @return       none
    ********************************************************************************************/
    @AuraEnabled
    public static void saveAmericanIndianMemberInformation(String memberId, String memberAmericanIndianInfo){
        SSP_Utility.isAuthenticatedUser();
        try{
            if(String.isNotBlank(memberId) && String.isNotBlank(memberAmericanIndianInfo)){ 
                SSP_Member__c sspMember = (SSP_Member__c)JSON.deserialize(memberAmericanIndianInfo, SSP_Member__c.class);
                if(sspMember.IsFederalRecognizedIndianTribeToggle__c == Null || sspMember.IsFederalRecognizedIndianTribeToggle__c == SSP_GlobalConstants.NO){
                    sspMember.IndianTribeCode__c = Null;
                    sspMember.IndianTribeState__c = Null;
                }
                if(sspMember.IsEligibleForIHFlagToggle__c == Null || sspMember.IsEligibleForIHFlagToggle__c == SSP_GlobalConstants.YES){
                    sspMember.IsEligibleForIndianHealthServicesToggle__c = Null;
                }
                sspMember.Id = memberId;
                List<SSP_Member__c> sspMemberList = new List<SSP_Member__c>();
                sspMemberList.add(sspMember);
                Database.upsertResult[] results = ESAPI.accessController().upsertAsUser(sspMemberList, SSP_Utility.getFieldsNamesList (sspMemberList)). getResults();
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AmericanIndianInformationController', 'saveAmericanIndianMemberInformation', ex.getMessage() , true);
        }
    }
}