/**
* Class Name    : RE_ReferralDetailsCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Controller class for RE_ReferralDetails
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  Prashant       Initial Version
*  12/06/2019  Megha          Fixed the Name for Email
**/


public with sharing class RE_ReferralDetailsCtrl {
    /********************************************************************************************
* @author       Prashant Singh
* @date         08/05/2019
* @methodname   getReferralDetails()
* @description  This methods is used to get the referral record for the record id passed
* @param        recId           (String)   : record Id
* @return       RE_CreateLightningServerResponse  
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getReferralDetails(String strRecId) {
        
        String recId = String.escapeSingleQuotes(strRecId);
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse objResponse;
        try{
             objResponse= getReferralDetailRecord(String.escapeSingleQuotes(recId));        
        }
        catch(Exception e){
             LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl', 'getReferralDetails', e.getMessage(), true);
        }
        return objResponse;
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   updateReferralDetails()
    * @description  This methods is used to update the referral record for the object wrapper passed
    * @param        objWrapper           (RE_ReferralWrapper)   : objWrapper
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateReferralDetails( RE_ReferralWrapper objWrapper) {
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try {
                    Referral__c objReferral = new Referral__c();
                    if (objWrapper.Id != null && objWrapper.Id != '') {
                        objReferral.Id = objWrapper.Id;
                    }
                    objReferral.Status__c = objWrapper.Status;
                    if(objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_CLOSED){
                       objReferral.DateClosed__c=date.today(); 
                    }
                    
                    if(objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_CLOSED && objWrapper.isChangedStatus == true){
                        objReferral.Closed_By__c = GeneralUtility.getLoggedInUserContactName(); 
                    }else if(objReferral.Status__c != RE_GlobalConstants.REFERRAL_STATUS_CLOSED && objWrapper.isChangedStatus == true){
                        objReferral.Closed_By__c = '';
                    }
                    
                    objReferral.OwnerId = objWrapper.OwnerId;
                    if (objWrapper.Rating != null && (objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_CLOSED)){
                        createFeedback(objWrapper.sContactAccId,objWrapper.Id, objWrapper.Rating, objWrapper.AdditionalComments);
                    }
                    if (objWrapper.OutcomeReason != null && objWrapper.OutcomeReason != '') {
                        objReferral.OutcomeReason__c=objWrapper.OutcomeReason;
                        /*  //adding If condition to send email for ONEVIEW-1480
                        if(objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_CLOSED && 
                           	objReferral.OutcomeReason__c == RE_GlobalConstants.REFERRAL_CANCELLED_BY_CLIENT && 
                               objWrapper.isChangedStatus == true && objWrapper.Outcome != RE_GlobalConstants.CLAIM_ResourceProvided){
                                sendEmailWhenReferralClosed(objWrapper); 
                        } */
                    }
                    if (objWrapper.Outcome != null && objWrapper.Outcome != '') {
                        objReferral.Outcome__c=objWrapper.Outcome;
                    }
                    RE_DataAccessChecker.updateObject(Referral__c.getSObjectType(), objReferral);
                    // bSuccess = true;
                    //Lagan's changes for sending out Survey mail [User story#ONEVIEW-1474] added on 22/10
                    
                    if (objWrapper.Id != null && objWrapper.Status == RE_GlobalConstants.REFERRAL_STATUS_CLOSED
                        && objWrapper.Outcome== RE_GlobalConstants.CLAIM_ResourceProvided
                        && objWrapper.sContactPreferredCommMethod != RE_GlobalConstants.MobilePhone
                        && EmailSetting__c.getInstance('Follow up on provided resource').Is_on__c
                        && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c) {
							String surveyLink;
                            if(test.isrunningTest()){
                                surveyLink = TestDataFactory.testSurveyLink;
                            }
                            else{
								SurveyLink  = RE_InsertSurveyInvitationCtrl.saveSurveyInvitation('RE_Rate_A_Resource_Feedback',objReferral.Id,'Referral',true,false);
                            }                                                        
                            List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
                            CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
                            // Bug #350114: Starts - added by Suresh
                            objCommunicationNub.EmailSubject__c = String.format(Label.RE_ConsentFollowupEmailSub, new List<String>{objWrapper.ReferredAccountID});
                              // Bug #350114: Ends - added by Suresh
                            String strEmailTemplateBody = String.format(Label.RE_ConsentFollowupEmailBody,new List<String>{objWrapper.ContactFirstName,objWrapper.ResourceName,objWrapper.ReferredAccountID,SurveyLink});
                            strEmailTemplateBody+= Label.RE_doNotReplyMessage + ' ' + Label.RE_PIIMessage + '<br>'+Label.RE_SecurityMessage;
                            objCommunicationNub.TemplateBody__c =  strEmailTemplateBody;
                            objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                            objCommunicationNub.ToEmail__c= objWrapper.sContactEmail;
                            objCommunicationNub.FromEmail__c = objWrapper.ReferringUserEmail;
                            objCommunicationNub.TriggeredRecordId__c = objWrapper.Id;
                             //Added By Kojashree
        					objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                            
                            lstCommunicationNubInsert.add(objCommunicationNub);
                            if(lstCommunicationNubInsert!=null && lstCommunicationNubInsert.size() > 0){
                                //if(RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){   
                                    RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                               /* }
                                else{
                                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_MyPlanCtrl.class.getName(), 'shareMyPlanDetails','No Access on CommunicationLog__c Object',true);
                                } */
                            }
                        }
                        /* [Suresh] Sending SMS Requirement 357790 Starts*/
                        else if(objWrapper.Id != null && objWrapper.Status == RE_GlobalConstants.REFERRAL_STATUS_CLOSED
                        && objWrapper.Outcome== RE_GlobalConstants.CLAIM_ResourceProvided
                        && objWrapper.sContactPreferredCommMethod == RE_GlobalConstants.MobilePhone
                        && EmailSetting__c.getInstance('Follow up on provided resource').Is_on__c
                        && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c){
                            String surveyLink;
                            if(test.isrunningTest()){
                                surveyLink = TestDataFactory.testSurveyLink;
                            }
                            else{
                               surveyLink  = RE_InsertSurveyInvitationCtrl.saveSurveyInvitation('RE_Rate_A_Resource_Feedback',objReferral.Id,'Referral',true,false);
                            }    
                           // Map<String, String> mapInputWrapper = new Map<String, String>();
                           // Map<String, Object> mapObjects = new Map<String, Object>();
                            
                            List<Contact> lstContact =new List<Contact>();
                            if(RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && RE_DataAccessChecker.isSafeField('Phone', 'Contact') && objWrapper.ContactId!=null ){
                                lstContact =[SELECT Id, Phone FROM Contact Where Id =:objWrapper.ContactId AND Id != null];
                            }
                            String strResourceName = objWrapper.ResourceName.length()>28? objWrapper.ResourceName.subString(0,27):objWrapper.ResourceName;
                            String strOrgName =objWrapper.ReferredAccountID.length()>28?objWrapper.ReferredAccountID.subString(0,27):objWrapper.ReferredAccountID; 
                           // mapInputWrapper.put('toPhone', cnt.Phone);
                           // mapObjects.put('resourceId', objWrapper.Id);
                           // mapObjects.put('sResourceName', objWrapper.Name);
                           // String templateBody = String.format(Label.Follow_Up_Text_Message, new List<String>{objWrapper.ResourceName,objWrapper.ReferredAccountID,SurveyLink});
                           // RE_ShareEmailCtrl.triggerSmsFramework(templateBody, mapInputWrapper, mapObjects);
                           String strPhone = '';
                           if(!lstContact.isEmpty()){
                               strPhone = lstContact[0].Phone;
                           }
                           RE_MessageUtility.referralClosureSMS(surveylink,objWrapper.Id, objWrapper.Name,strPhone,strResourceName, strOrgName);
                        }
                        /* [Suresh] Sending SMS Requirement 357790 Ends*/
                    bSuccess = true;
                } catch (Exception e) {errorMap.put('error',e.getMessage());
                                       LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl','updateReferralDetails', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   createFeedback()
    * @description  This methods is used to create the feedback record
    * @param        String accid, String referralId, Integer rating, String Comments
    * @return       void 
    **********************************************************************************************/
    public static void createFeedback(String accid, String referralId, Decimal rating, String Comments) {        
        GeneralUtility.isAuthenticatedUser();
        Id partnerfeedbackRecTypeId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get('Client Feedback').getRecordTypeId();
        try{
            List<Feedback__c> feedbacklst=RE_SharingByPassCtrl.getFeedback(String.escapeSingleQuotes(referralId),partnerfeedbackRecTypeId);
            if(!feedbacklst.isEmpty()){
                feedbacklst[0].Rating__c=rating;
                if(Comments!=null){
                    feedbacklst[0].RatingDescription__c=String.escapeSingleQuotes(Comments);
                }                
                RE_SharingByPassCtrl.updateSobject(Feedback__c.getSObjectType(), feedbacklst[0]);
            }else{
                Feedback__c objFeedback = new Feedback__c();
                objFeedback.recordtypeid = partnerfeedbackRecTypeId;
                objFeedback.Referral__c = String.escapeSingleQuotes(referralId);  
                objFeedback.Rating__c = rating;
                if(Comments!=null){
                    objFeedback.RatingDescription__c = String.escapeSingleQuotes(Comments);
                }                
                objFeedback.AccountID__c = String.escapeSingleQuotes(accid);  
                RE_SharingByPassCtrl.insertSobject(Feedback__c.getSObjectType(), objFeedback);
            }
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl', 'createFeedback', e.getMessage(), true);
        }
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   getFeedback()
    * @description  This methods is used to get the feedback record
    * @param        String refObjId, ID rectypeID
    * @return       Feedback__c 
    **********************************************************************************************/
    public static List<Feedback__c> getFeedback(String refObjId, ID rectypeID) {
        string strRefObjId = String.escapeSingleQuotes(refObjId);
        GeneralUtility.isAuthenticatedUser();
        List<Feedback__c> feedbacklst=new List<Feedback__c>();
        try{
            String sFieldsApiNameForFeedback = RE_DataBaseQueryFields.sFieldsApiNameForFeedback;
            String sWhereClauseForFeedback = RE_DataBaseQueryFields.sWhereClauseForFeedback ;
            String sQuery;
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForFeedback);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby); 
            Map<Boolean,String> mapResponseFeedback = RE_DataAccessChecker.getFieldsAccessibility('Feedback__c',sFieldsApiNameForFeedback,mapQueryParameters);
            if(mapResponseFeedback.get(true) != null){
                sQuery =  mapResponseFeedback.get(true);
                feedbacklst = Database.query(sQuery);     
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'getfeedback','getloggedinuserid','***FLS Violation***'+mapResponseFeedback.get(false),true);
            }
        }
        catch(Exception e){ 
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl', 'getReferralDetails', e.getMessage(), true);            
        }
        return feedbacklst;
    }        
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   getPickListValues()
    * @description  This methods is used to fetch the picklist values
    * @param        String objectName, String lstFields
    * @return       void 
    **********************************************************************************************/  
    @AuraEnabled
    public static  RE_CreateLightningServerResponse getPickListValues(String strObjectName, String strLstFields){
        
        String objectName = String.escapeSingleQuotes(strObjectName);
        String lstFields = String.escapeSingleQuotes(strLstFields);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try {
                    Map<String, Map<String, String>> values = GeneralUtility.fetchFieldsPicklistValueAPIName(objectName, lstFields);
                    bSuccess = true;
                    mapResponse.put('picklistvalues', values);
                } catch(Exception e) {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl','getPickListValues', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   getReferralDetailRecord()
    * @description  This methods is used to get the referral record for the record id passed
    * @param        recId           (String)   : record Id
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    public static RE_CreateLightningServerResponse getReferralDetailRecord(String recId) {
        RE_ReferralWrapper objReferralWrapper = new RE_ReferralWrapper();
        String recordId = String.escapeSingleQuotes(recId);
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, String> mapResponse = new Map<String, String>{};
        Boolean bSuccess = false;
        Referral__c objreferral;
        try{
            String sFieldsApiNameForReferral;
            //RE_Release 1.1 – Bug 361197 - Payal Dubela -Connect button not working(as Citizen doesn't have permission for Closed By field )
            String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
             // Added By Kojashree -- SSP Merge Fixes
            String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
            if(selectedRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                sFieldsApiNameForReferral=RE_DataBaseQueryFields.sRefDetailsQueryFieldsCitizen;
            }else{
                sFieldsApiNameForReferral=RE_DataBaseQueryFields.sRefDetailsQueryFields;
            }
            
            String sWhereClauseForReferral = RE_DataBaseQueryFields.sWhereClauseIdInRecordId ;
            String sQuery;
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForReferral);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            
            Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility('Referral__c',sFieldsApiNameForReferral,mapQueryParameters);
            if(mapResponseReferral.get(true) != null){
                sQuery =  mapResponseReferral.get(true);
                objreferral = RE_SharingByPassCtrl.getReferralRecords(sQuery, recordId);                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'Re_ReferralDetailsCTrl','getReferralDetails','***FLS Violation***'+mapResponseReferral.get(false),true);
            }
            
           // List<User> lstuser=new List<User>();
            objReferralWrapper.lstUsers = getUserRecordDetails(objreferral);
            objReferralWrapper.sQueueName=GeneralUtility.getQueue(RE_GlobalConstants.sUnassignedQueueName).Name; 
            objReferralWrapper.sQueueId=GeneralUtility.getQueue(RE_GlobalConstants.sUnassignedQueueName).Id; 
            if (objreferral != null) {
                mapResponse.put('objReferral', JSON.serializePretty(objreferral));
                objReferralWrapper.Id = objreferral.Id;
                objReferralWrapper.Name = objreferral.Name;
                objReferralWrapper.OutcomeReason = objreferral.OutcomeReason__c;
                objReferralWrapper.Contacts = objreferral.Contacts__r.Firstname+' '+objreferral.Contacts__r.LastName;
                objReferralWrapper.ContactFirstName = objreferral.Contacts__r.Firstname;
                objReferralWrapper.ContactId=objreferral.Contacts__c;
                objReferralWrapper.CreatedBy = objreferral.CreatedBy.Name;
                objReferralWrapper.DateOfReferral = objreferral.Createddate;
                objReferralWrapper.ReferredAccountID = objreferral.ReferredAccountID__r.Name;
                objReferralWrapper.ReferredOrgID = objreferral.ReferredAccountID__c;
                objReferralWrapper.ReferringUserEmail = objreferral.ReferringUserEmail__c;
                if(objreferral.ReferringUserPhone__c !=null){
                    objReferralWrapper.ReferringUserPhone=GeneralUtility.formatphonenumber(objreferral.ReferringUserPhone__c);
                }
                objReferralWrapper.Status = objreferral.Status__c;
                objReferralWrapper.DaysSinceOpened=objreferral.DaysSinceOpened__c;
                objReferralWrapper.OwnerId=objreferral.OwnerId;
                objReferralWrapper.ResourceName=objreferral.Resource__r.Name;
                objReferralWrapper.Outcome=objreferral.Outcome__c;
                objReferralWrapper.OptOutInfoSharing=objreferral.Contacts__r.OptOutInfoSharing__c;
                objReferralWrapper.sContactAccId=objreferral.Contacts__r.AccountId;
				//Added by LK
                objReferralWrapper.sContactEmail = objreferral.Contacts__r.Email;
                objReferralWrapper.sContactPreferredCommMethod = objreferral.Contacts__r.PreferredCommunicationMethod__c;
                //RE_Release 1.1 – Bug 361197 - Payal Dubela
                // Updated By Kojashree --- SSP Merge Fixes
                if(selectedRole != RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                objReferralWrapper.sClosedByUser = objreferral.Closed_By__c; //RE Release 1.1 - Req#357638 - Anuj
                } 
            }
            //Need to make the recordtype dynamic
            Id partnerfeedbackRecTypeId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get('Client Feedback').getRecordTypeId();
            List<Feedback__c> feedbacklst=new List<Feedback__c>();
            feedbacklst=RE_ReferralDetailsCtrl.getFeedback(objreferral.Id,partnerfeedbackRecTypeId);
            if(!feedbacklst.isEmpty()){
                objReferralWrapper.Rating=feedbacklst[0].Rating__c;
                objReferralWrapper.AdditionalComments=feedbacklst[0].RatingDescription__c;
            }
            mapResponse.put('records', JSON.serialize(objReferralWrapper));
            bSuccess=true;
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl', 'getReferralDetails', e.getMessage(), true);
            throw e;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);        
    }
        
    public static List<User> getUserRecordDetails(Referral__c objreferral){
        List<User> lstuser=new List<User>();
        try{
            String referredAccountID = objreferral.ReferredAccountID__c;
            // Venkat: 08/01/2020: RE Security Chnages
            String sFieldsApiName = RE_DataBaseQueryFields.sQueryOnUser;
            String sWhereClause=RE_DataBaseQueryFields.WHERE_CLAUSE_getUserRecordDetails;             
            String sQueryForUser;
            Map<String,String> mapQueryParametersForUser = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sOrderByNameAsc;
            mapQueryParametersForUser.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParametersForUser.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
            mapQueryParametersForUser.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            Map<Boolean,String> mapResponseReferralUsers = RE_DataAccessChecker.getFieldsAccessibility('User',sFieldsApiName,mapQueryParametersForUser);
            if(mapResponseReferralUsers.get(true) != null){
                sQueryForUser =  mapResponseReferralUsers.get(true);
                lstuser = RE_SharingByPassCtrl.getUserDetails(sQueryForUser,referredAccountID);
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'Re_ReferralDetailsCTrl','getReferralDetails','***FLS Violation***'+mapResponseReferralUsers.get(false),true);
            }
        }Catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'Re_ReferralDetailsCTrl','getReferralDetails',e.getStackTraceString(),true);
        }
        return lstuser;
    }
    /********************************************************************************************
    * @author       Deeksha
    * @date         10/23/2019
    * @methodname   sendEmailWhenReferralClosed()
    * @description  This methods is used to send email to resident when referral is closed ONEVIEW-1480
    * @return       
    **********************************************************************************************/
    public static void sendEmailWhenReferralClosed(RE_ReferralWrapper objWrapper){
        if( EmailSetting__c.getInstance('Follow up on cancelled resources').Is_on__c
           && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c
           && objWrapper.sContactPreferredCommMethod =='Email'){
            String surveyLink;
            if(test.isrunningTest()){
            	surveyLink = TestDataFactory.testSurveyLink;
            }
            else{
                surveyLink = RE_InsertSurveyInvitationCtrl.saveSurveyInvitation('RE_Cancelled_Referral',objWrapper.Id,'Referral',true,false);            
            }
            String strEmailTemplateBody =String.format(Label.Follow_Up_Cancelled_Resource_Email_Body, new List<String>{ objWrapper.ContactFirstName,objWrapper.ResourceName,objWrapper.ReferredAccountID,surveyLink});
            List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
            CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
            Database.SaveResult[] srCommunicationNubList;
            objCommunicationNub.EmailSubject__c = Label.tellabtexperience;
            objCommunicationNub.TemplateBody__c = strEmailTemplateBody;
			objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
            objCommunicationNub.ToEmail__c = objWrapper.sContactEmail;
            objCommunicationNub.FromEmail__c = objWrapper.ReferringUserEmail;
            lstCommunicationNubInsert.add(objCommunicationNub); 
            if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){  
                srCommunicationNubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
            }
            else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_ReferralDetailsCtrl.class.getName(), 'sendEmailWhenReferralClosed','No Access on CommunicationLog__c Object',true);
            }
        }
    }
}