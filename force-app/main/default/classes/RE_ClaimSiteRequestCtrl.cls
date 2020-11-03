/**
 * Class Name    : RE_ClaimSiteRequestCtrl{
 * Owner         : DELOITTE
 * Created Date  : 05/16/2019
 * Description   : Claim my site request record insertion
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer       Description                                                         
 *  ----------  -----------     -------------------------------------------------------------------
 *  05/16/2019  SRIKANTH       Initial Version
*  10/17/2019  Lagan Kankane  Added createCommunicationNubecord method, modified saveClaimSiteRequest method
for creation of communication nub record.
 *  Test checkin
 **/

public with sharing class RE_ClaimSiteRequestCtrl{
  
/*********************************************************************************************************************************
    * @author       SRIKANTH
    * @date         05/16/2019
    * @methodname   saveClaimSiteRequest()
    * @description  This method is to create the claim record 
    * @param        ClaimRecord    (sObject)  : To retrieve the data from the UI.
    * @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
    
   @AuraEnabled
    public static RE_CreateLightningServerResponse saveClaimSiteRequest(ClaimMySiteRequest__c claimRecord) {  
        boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        String sTicketNumber;
        
        try {
            if (claimRecord != null) { 
                ClaimMySiteRequest__c claimSiteRequest = new ClaimMySiteRequest__c();
                
                List<Group> lstGroup = RE_SharingByPassCtrl.getGroup();
                
                RecordType objRecordType = GeneralUtility.fetchRecordType(System.Label.ClaimRecordTypeStaff, 'ClaimMySiteRequest__c');
                claimRecord.RecordTypeId = objRecordType.Id;
                claimRecord.Status__c = 'New';
                claimRecord.DateOfRequest__c = Date.today();
                claimRecord.OwnerId = lstGroup[0].Id;
                
                claimSiteRequest = RE_SharingByPassCtrl.createClaimSite(claimRecord);
                
                String recId = claimSiteRequest.Id;
                
                sObject obj = RE_SharingByPassCtrl.getRecord(recId,RE_GlobalConstants.strClaimObjectName);
                String strClaimobj = string.valueOf(obj);
                if(strClaimobj.contains('Name=')){
                    sTicketNumber = strClaimobj.substringBetween('CLM-','}');
                  }
                
                
                //modified below line for && conditions
                if (claimSiteRequest.Id != null 
                    && EmailSetting__c.getInstance('Claim Site request submission mail').Is_on__c
                    && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c) {
                        mapResponse.put('claimRecord', claimRecord);
                        //Lagan's changes
                        String sTemplateBody = RE_GlobalConstants.sEmptyString;
                       
                        claimSiteRequest.OrganizationRole__c = (claimSiteRequest.OrganizationRole__c=='Other') ? claimSiteRequest.OtherRole__c : claimSiteRequest.OrganizationRole__c; //PMD Issue fix, adding ternary operator[Anuj - 2/19/2020]
                        
                        sTemplateBody = String.format(Label.RE_ClaimMySiteBodyLine1,new List<String>{claimSiteRequest.FirstName__c,claimSiteRequest.LastName__c,claimSiteRequest.RequestingOrganizationName__c,sTicketNumber});                        
                        sTemplateBody+=String.format(Label.RE_ClaimMySiteBodyLine2,new List<String>{claimSiteRequest.FirstName__c,claimSiteRequest.LastName__c,claimSiteRequest.Email__c,claimSiteRequest.PhoneNumber__c,claimSiteRequest.OrganizationRole__c,Label.System_Name,(claimSiteRequest.HearAboutRE__c != null ? claimSiteRequest.HearAboutRE__c : '')});
                        sTemplateBody += Label.RE_doNotReplyMessage;
                        sTemplateBody += '<br>'+Label.RE_SecurityMessage;
                        Re_ClaimSiteRequestCtrl.sendEmail(sTemplateBody, claimSiteRequest.Email__c);
                        bSuccess = true;
                    }                
            }
        }
        catch(Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClaimSiteRequest', 'saveClaimSiteRequest', e.getMessage()+' ' +e.getLineNumber()+' '+e.getStackTraceString(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    
     /*********************************************************************************************************************************
    * @author       Anuj
    * @date         04/29/2020
    * @methodname   sendEmail()
    * @description  This method is to send email and create a communication hub record in the system
    * @param        NA
    * @return       void 
    ************************************************************************************************************************************/ 
    public static void sendEmail(String sTemplateBody, String sEmail){ 
        List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
        CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
        objCommunicationNub.EmailSubject__c = String.format(Label.RE_ClaimMySiteSub, new List<String>{ Label.System_Name });
        objCommunicationNub.TemplateBody__c = sTemplateBody;
        objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
        objCommunicationNub.ToEmail__c= sEmail;
        //Added By Kojashree
        objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
        lstCommunicationNubInsert.add(objCommunicationNub);
        if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){
            /*if(RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){  */ 
                RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
            }
            else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_MyPlanCtrl.class.getName(), 'shareMyPlanDetails','No Access on CommunicationLog__c Object',true);
            }
    }
    
    
/*********************************************************************************************************************************
    * @author       SRIKANTH
    * @date         05/16/2019
    * @methodname   fetchOrgRolePickValues()
    * @description  This method is to retrieve the Organization Role Picklist values to the UI 
    * @param        NA
    * @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/    
   @AuraEnabled
   public static RE_CreateLightningServerResponse fetchOrgRolePickValues(){       
       Boolean bSuccess = true;
       Map<String, Object> mapResponse = new Map<String, Object>{};
       Map<String, Object> errorMap = new Map<String, Object>{};
           
       try {
                    List<Schema.PicklistEntry> lstOrganizationRolePicklistOptions = ClaimMySiteRequest__c.OrganizationRole__c.getDescribe().getPicklistValues();
                    List<PicklistWrapper> lstOrganizationRole = new List<PicklistWrapper>();
                    for(Schema.PicklistEntry itrStatus : lstOrganizationRolePicklistOptions){
                        lstOrganizationRole.add(new PicklistWrapper(itrStatus.getLabel(),itrStatus.getValue(),false));
                    } 
                    if(!lstOrganizationRole.isEmpty()){
                        mapResponse.put('OrganizationRole', lstOrganizationRole);
                        bSuccess = true;
                    }
                    /*//GeneralUtility.getPicklistValues() method is returning list of strings for picklist values which doesn't work spanish translation
                    List<String> pickval = GeneralUtility.getPicklistValues('ClaimMySiteRequest__c','OrganizationRole__c');
                    if(!pickval.isEmpty()){
                        mapResponse.put('OrganizationRole', pickval);
                    } 
					*/
       } catch(Exception e) {
           //error message is to store the error recorded in failure
           errorMap.put('error',e.getMessage());
           LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClaimSiteRequest','fetchOrgRolePickValues', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
/*********************************************************************************************************************************
* @author       Lagan Kankane
* @date         10/17/2019
* @methodname   createCommunicationNubecord()
* @description  This method is to create the Communication nub record for email sent on Approval/Denial of
                claim site request, which is being invoked by the procss builder "RE Claim Request Flow"
* @param        consentRecordId - id of the consent record updated
* @return       void, since it is an invocable method. 
************************************************************************************************************************************/    

    @InvocableMethod
    public static void createCommunicationNubecord(List<Id> consentRecordId ){
        //for querying the communication nub record
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<Boolean, String> mapResponse = new Map<Boolean, String>();
        Map<String, Object> errorMap = new Map<String, Object>{};
        String sQuery;
        Boolean bSuccess = false;
        
        try{
            List<ClaimMySiteRequest__c> consentLogList = new List<ClaimMySiteRequest__c>();
            
            String sFieldsAPIName = RE_DataBaseQueryFields.sClaimFieldsForEmailTemplate;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseClaimForEmailTemplate;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('ClaimMySiteRequest__c', sFieldsAPIName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    consentLogList = Database.query(sQuery);
                    if((!consentLogList.isEmpty())&& consentLogList.size()>0 && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c){
                        
                         List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
                         CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
                         Database.SaveResult[] srCommunicationNubList;
                         objCommunicationNub.ToEmail__c = consentLogList[0].Email__c;
                         objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                        //Added By Kojashree
        				 objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                                               
                        if(consentLogList[0].Status__c == RE_GlobalConstants.CLAIM_STATUS_APPROVED
                           && EmailSetting__c.getInstance('Claim Site Approval mail').Is_on__c ){
                               //code for approval
                               objCommunicationNub.EmailSubject__c = String.format(Label.RE_ClaimApprovedSub, new List<String>{ Label.System_Name });
                               String strEmailTemplateBody = String.format(Label.RE_ClaimApprovedBody, new List<String>{ consentLogList[0].FirstName__c,consentLogList[0].LastName__c,consentLogList[0].RequestingOrganizationName__c,Label.System_Name,Label.StateHelpdesk,'KOG URL'});
                               strEmailTemplateBody += Label.RE_doNotReplyMessage;
                               strEmailTemplateBody += '<br>'+Label.RE_SecurityMessage;
                               objCommunicationNub.TemplateBody__c = strEmailTemplateBody;
                               lstCommunicationNubInsert.add(objCommunicationNub);
                               //
                           }
                        
                        if(consentLogList[0].Status__c == RE_GlobalConstants.CLAIM_STATUS_DENIED
                           && EmailSetting__c.getInstance('Claim Site Denial mail').Is_on__c ){
                               //code for denied
                               
                               objCommunicationNub.EmailSubject__c = String.format(Label.RE_ClaimBodySub, new List<String>{ Label.System_Name });
                               String strEmailTemplateBody = String.format(Label.RE_ClaimDeniedBody, new List<String>{ consentLogList[0].FirstName__c,consentLogList[0].LastName__c,consentLogList[0].RequestingOrganizationName__c,Label.System_Name,consentLogList[0].ReasonForDenial__c,Label.StateHelpdesk });
                               strEmailTemplateBody += Label.RE_doNotReplyMessage;
                               strEmailTemplateBody += '<br>'+Label.RE_SecurityMessage;
                               objCommunicationNub.TemplateBody__c = strEmailTemplateBody;
                               lstCommunicationNubInsert.add(objCommunicationNub);
                               //
                           }
                         
                        
                        if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){  
                            srCommunicationNubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                            bSuccess = true;
                        }
                    }
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClaimSiteRequestCtrl','invokeCommunicationFramework','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            //
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ClaimSiteRequestCtrl.class.getName(), 'shareResourceDetailsViaEmail', e.getMessage(), true);
        }
        
    }
    public class PicklistWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String value {get;set;}
        @AuraEnabled
        public Boolean selected{get;set;}
        
        
        public PicklistWrapper(String label, String value, Boolean selected){
            this.label = label;
            this.value = value; 
            this.selected = selected;
        }
    }
}