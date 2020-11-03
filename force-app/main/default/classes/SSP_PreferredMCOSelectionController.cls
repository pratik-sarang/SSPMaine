/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_PreferredMCOSelectionController
*   Created By   :   Sanchita Tibrewala
*   Created Date :   08/10/2020
*   Description  :   Controller for Preferred MCO Selection Screen
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 08/10/2020     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_PreferredMCOSelectionController {
	
    /********************************************************************************************
* @author       Sanchita Tibrewala
* @date         08/10/2020
* @methodname   getMCODetails
* @description  This method is used to get MCO details from Interface
* @return       SSP_LightningResponse
********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getMCODetails(String memberId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse(); 
        try{
            String individualId = SSP_Utility.getIndividualId();
            List<SSP_Member__c> sspMemberList = new List<SSP_Member__c>();
            Map<String,String> plansMap = new Map<String,String>();
            if(String.isNotBlank(memberId)){
             	sspMemberList = 
                        SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                           new Set<String>{'Id','MailingAddressLine1__c','MailingAddressLine2__c','MailingCity__c', 
                                                                           'MailingCountyCode__c','MailingStateCode__c','MailingZipCode4__c',
                                                               			   'MailingZipCode5__c','PreferredMCOName__c','IndividualId__c'}, 
                                                           new Map<String, String>{'limit'=>'10','Id'=>String.escapeSingleQuotes(memberId)});
            }
            if(!sspMemberList.isEmpty()){
                SSP_DataContractOrg.RequestMcoAddres requestAddress = new SSP_DataContractOrg.RequestMcoAddres();
                requestAddress.AddressLine1 = sspMemberList.get(0).MailingAddressLine1__c;
                requestAddress.AddressLine2 = sspMemberList.get(0).MailingAddressLine2__c;
                requestAddress.City = sspMemberList.get(0).MailingCity__c;
                requestAddress.StateCode = sspMemberList.get(0).MailingStateCode__c;
                requestAddress.ZipCode4 = sspMemberList.get(0).MailingZipCode4__c;
                requestAddress.CountyCode = sspMemberList.get(0).MailingCountyCode__c;
                requestAddress.ZipCode5 = sspMemberList.get(0).MailingZipCode5__c;
                SSP_DataContractOrg.PreferredMcoRequest request = new SSP_DataContractOrg.PreferredMcoRequest();
                if(String.isNotBlank(individualId)){
                    request.IndividualId = Integer.valueOf(individualId);
                }
                else if(String.isNotBlank(sspMemberList.get(0).IndividualId__c)){
                 	request.IndividualId = Integer.valueOf(sspMemberList.get(0).IndividualId__c);
                }
                request.MCOSelectionRequestDate = SSP_Utility.now();
                request.Address = requestAddress;
                
                Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => request};
                List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_PREFERRED_MCO_SELECTION, mapParams);
                SSP_DataContractOrg.PreferredMcoResponse response = (SSP_DataContractOrg.PreferredMcoResponse) objList[0];
                
                SSP_DataContractOrg.ArrayOfPlan PlansList = response.Plans;
                plansMap.put(System.label.SSP_MCONoPreference, SSP_GlobalConstants.ZERO);
                Set<String> oldMCOPlans = new Set<String>();
                Set<String> newMCOPlans = new Set<String>();
                if(PlansList != null && PlansList.Plan != null){
                    for(SSP_DataContractOrg.Plan eachPlan : PlansList.Plan){
                        plansMap.put(eachPlan.PlanName, eachPlan.PlanId);
                        
                        if(eachPlan.IsOldMCO != null && eachPlan.IsOldMCO == true) {
                            oldMCOPlans.add( eachPlan.PlanName );
                        } else if(eachPlan.IsNewMCO != null && eachPlan.IsNewMCO == true) {
                            newMCOPlans.add( eachPlan.PlanName );
                        }
                    }
                }
                if(!oldMCOPlans.isEmpty()) {
                    toSend.put('oldMCOPlans', oldMCOPlans);
                }
                if(!newMCOPlans.isEmpty()) {
                    toSend.put('newMCOPlans', newMCOPlans);
                }                
                toSend.put('planDetails',plansMap);
                toSend.put('memberObject',sspMemberList.get(0));
                toSend.put('status', response.Status);                
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_PreferredMCOSelectionController', 'getMCODetails', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        } 
        return toSend;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         08/11/2020
    * @methodname   saveSspMemberContactInformation
    * @description  This method saves all the Contact Information retrieved from the component
    * @param        Id, String
    * @return       none
    ********************************************************************************************/
    @AuraEnabled
    public static void saveMCODetails(String memberId, String memberPlanInfo){
        SSP_Utility.isAuthenticatedUser();
        try{
            if(String.isNotBlank(memberId) && String.isNotBlank(memberPlanInfo)){ 
                SSP_Member__c sspMember = (SSP_Member__c)JSON.deserialize(memberPlanInfo, SSP_Member__c.class);
                Schema.DescribeFieldResult fieldPicklist = SSP_Member__c.PreferredSpokenLanguageCode__c.getDescribe();
                sspMember.Id = memberId;
                List<SSP_Member__c> sspMemberList = new List<SSP_Member__c>();
                sspMemberList.add(sspMember);
                SSP_GenericDMLHelper.updateRecords(sspMemberList,SSP_Utility.getFieldsNamesList (sspMemberList));
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_PreferredMCOSelectionController', 'saveMCODetails', ex.getMessage() , true);
        }
    }
}