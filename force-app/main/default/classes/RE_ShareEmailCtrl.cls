/**
* Class Name    : RE_ShareEmailCtrl
* Owner         : DELOITTE
* Created Date  : 06/05/2019
* Description   : Controller class for aura component RE_ShareResourceModal
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer        Description                                                         
*  ----------  -----------      -------------------------------------------------------------------
*  06/05/2019  DEEKSHA          Initial Version
*  07/08/2019  Lagan Kankane    Added logic to send SMS
*  07/24/2019  Abhijeet Vaishnab Generic method added to create central hub record with SMS details	
**/

public with Sharing class RE_ShareEmailCtrl {
     
    @AuraEnabled
    public static Boolean isCitizenProfileUser{get;set;}
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/05/2019
    * @methodname   checkIfCitizenUser()
    * @description  This methods is used to check if logged in user is Citizen user
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse checkIfCitizenUser(){
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        isCitizenProfileUser=false;
        try{
            String sLoggedInUserProfileName = GeneralUtility.getLoggedInUserSelectedRole();
            String sUserName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
            String sUserId = UserInfo.getUserId();
            String phone = '';
            if(sLoggedInUserProfileName != RE_GlobalConstants.strGuestProfileName){
               // Contact objContact;
                User objUser;
                String ownerId = String.valueOf(UserInfo.getUserId());
                String sFieldsApiNameUser = RE_DataBaseQueryFields.sQueryFieldsForGettingPhoneFromContact;
                String sWhereClauseForUser = RE_DataBaseQueryFields.sWhereFieldsForGettingPhoneFromUser ;
                String sQuery;
                Map<String,String> mapQueryParameters = new Map<String,String>();
                String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForUser);
                mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
                Map<Boolean,String> mapUser = RE_DataAccessChecker.getFieldsAccessibility('User',sFieldsApiNameUser,mapQueryParameters);
                if(mapUser.get(true) != null){
                    sQuery =  mapUser.get(true);
                    objUser = Database.query(sQuery);
                }else{
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ShareEmailCtrl','checkIfCitizenUser','***FLS Violation***'+mapUser.get(false),true);
                }
                if(objUser.Phone != null && objUser.Phone != ''){
                    phone = String.valueOf(objUser.Phone);
                }                
            }
            
            sUserName.replace('null','');
            if(sLoggedInUserProfileName == RE_GlobalConstants.strCitizenAppRole || sLoggedInUserProfileName == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || sLoggedInUserProfileName == RE_GlobalConstants.CASE_WORKER || sLoggedInUserProfileName == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || sLoggedInUserProfileName == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF 
               || sLoggedInUserProfileName == RE_GlobalConstants.ASSISTER){
                isCitizenProfileUser =  true;
                mapResponse.put('isCitizenProfileUser',String.valueOf(isCitizenProfileUser));
                mapResponse.put('userName',sUserName);
                mapResponse.put('userEmail',UserInfo.getUserEmail());
                if(phone!=null){
                    mapResponse.put('userPhone',phone);
                }
            }
            bSuccess = true;
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ShareEmailCtrl.class.getName() ,'checkIfCommunityUser',RE_GlobalConstants.PROFILE_MISMATCH_ERROR, true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/05/2019
    * @methodname   shareResourceDetailsViaEmail()
    * @description  This methods is used to create central hub record with email details
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse shareResourceDetailsViaEmail(Map<String,Object> resourceDetailsWrapper,Map<String,String> mapInputWrapper){
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try{
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyEmailSetting = (EmailSetting__c.getInstance('Share Resource Information').Is_on__c && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyEmailSetting) {
             when SWITCH_SUCCESS {  
				//process the address line to remove null and consecutive nulls from address line      
				//String sAddressLine = resourceDetailsWrapper.get('sReferralOrgCity')+','+resourceDetailsWrapper.get('sReferralOrgState')+','+resourceDetailsWrapper.get('sReferralOrgZip')+','+resourceDetailsWrapper.get('sReferralOrgZipExt');
				String sAddressLine = resourceDetailsWrapper.get('sLocationCity')+', '+resourceDetailsWrapper.get('sLocationState')+' '+resourceDetailsWrapper.get('sLocationZip');
                String sAddressFinal='';            
                for(String sPart : sAddressLine.split(',') ){                
                    if(sPart!='null'){
                        sAddressFinal+=sPart+',';
                    }
                }
                if(sAddressFinal.endsWith(',')){
                    sAddressFinal = sAddressFinal.removeEnd(',');
                }
                //address line process ends
                List<String> labelParameters = new List<String>();
                labelParameters.add(mapInputWrapper.get('yourName'));
                labelParameters.add(Label.System_Name);
                labelParameters.add(Label.System_Name);
                labelParameters.add(Label.System_Name);
               
                String strEmailTemplateBody = Label.RE_Hello+',<p>'+String.format(Label.RE_Share_Email_Body_Line_1, labelParameters);
                strEmailTemplateBody+='<p>'+Label.RE_Resource+': '+resourceDetailsWrapper.get('sResourceName')+'<br>'+Label.Category+': '+resourceDetailsWrapper.get('sSDOHCategory')+'<br>'+Label.organization+': '+resourceDetailsWrapper.get('sReferralOrgName');
                strEmailTemplateBody+='<br><br>'+resourceDetailsWrapper.get('sLocationAddress1');
                if(resourceDetailsWrapper.get('sLocationAddress2') !=null){
                    strEmailTemplateBody+='<br>'+resourceDetailsWrapper.get('sLocationAddress2');
                }
                strEmailTemplateBody+='<br>'+sAddressFinal; 
                strEmailTemplateBody+='<br>'+Label.phone+': '+resourceDetailsWrapper.get('sPOCPhone')+'<br>'+Label.Website+': '+'<a href='+resourceDetailsWrapper.get('sReferralOrgUrl')+'>'+resourceDetailsWrapper.get('sReferralOrgUrl')+'</a>';
                String resourceURL = Community_URL_Settings__c.getOrgDefaults().URL__c+'/s/resource-details?zipcode='+resourceDetailsWrapper.get('sLocationZipEncode')+'&resourceId='+resourceDetailsWrapper.get('resourceId')+'&locationId='+resourceDetailsWrapper.get('sLocationId');
                strEmailTemplateBody+='<br>'+Label.RE_Link_to_Resource+' <a href ='+ resourceURL + '>'+ resourceURL+ '</a>';
                strEmailTemplateBody+= Label.RE_doNotReplyMessage + ' ' + Label.RE_PIIMessage;
                //replace all the null with empty string in email body
                if(strEmailTemplateBody.contains('null')){
                    strEmailTemplateBody = strEmailTemplateBody.replace('null','');
                }
                
                List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
                CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
                Database.SaveResult[] srCommunicationNubList;
				
				objCommunicationNub.EmailSubject__c = String.format(Label.RE_ShareEmailSubject, new List<String>{ Label.System_Name });
                objCommunicationNub.TemplateBody__c = strEmailTemplateBody;
                objCommunicationNub.ToEmail__c = mapInputWrapper.get('toEmail');
                objCommunicationNub.FromEmail__c = mapInputWrapper.get('yourEmail');
                //objCommunicationNub.TriggeredRecordId__c = String.valueOf(resourceDetailsWrapper.get('resourceId'));
                objCommunicationNub.TriggeredRecordName__c= String.valueOf(resourceDetailsWrapper.get('sResourceName'));
                objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                objCommunicationNub.TemplateName__c= Label.RE_EmailTemplateNameShareResource;
                 //Added By Kojashree
        		objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                            
                lstCommunicationNubInsert.add(objCommunicationNub); 
                            
                if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){  
                    srCommunicationNubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                    bSuccess = true;
                }
                else{
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_ShareEmailCtrl.class.getName(), 'shareResourceDetailsViaEmail','No Access on CommunicationLog__c Object',true);
                }  
            }
         }      
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ShareEmailCtrl.class.getName(), 'shareResourceDetailsViaEmail', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /********************************************************************************************
* @author       Lagan Kankane
* @date         07/08/2019
* @methodname   shareResourceDetailsViaPhone(Map<String,Object> resourceDetailsWrapper,Map<String,String> mapInputWrapper)
* @description  This methods is used to create a Framework_Log__c object of type communication which triggers SMS sending 
through process builder.
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse shareResourceDetailsViaPhone(Map<String,Object> resourceDetailsWrapper,Map<String,String> mapInputWrapper){
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> mapForSMS = new Map<String, Object>();
        
        
        try{
            
            String strPhoneTemplateBody = Label.RE_Hello+'! '+String.format(Label.RE_SendSMS_Line1, new List<String>{ mapInputWrapper.get('yourName') });
            
            
             if(test.isRunningTest() == true){
                     strPhoneTemplateBody+= ' <a>'+ 'This is test message' +'</a>';
                    
                }else{
                      strPhoneTemplateBody+= ' <a>'+ RE_URLShortnerService.getShortURL(String.valueOf(mapInputWrapper.get('recourceDetailUrl'))) +'</a>';
                }
            
            
            
           // strPhoneTemplateBody+= ' <a>'+ RE_URLShortnerService.getShortURL(String.valueOf(mapInputWrapper.get('recourceDetailUrl'))) +'</a>';
            strPhoneTemplateBody+= Label.RE_SendSMS_Line3;
           
            //replace all the null with empty string in email body
            if(strPhoneTemplateBody.contains('null')){
                strPhoneTemplateBody = strPhoneTemplateBody.replace('null','');
            }
            
            RE_CreateLightningServerResponse resp = triggerSmsFramework(strPhoneTemplateBody,mapInputWrapper,resourceDetailsWrapper);
            if(resp.isSuccessful==true){
                bSuccess = true;
            }
            
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ShareEmailCtrl.class.getName(), 'shareResourceDetailsViaPhone', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/24/2019
* @methodname   triggerSmsFramework()
* @description  This is a generic method to create central hub record with SMS details
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    public static RE_CreateLightningServerResponse triggerSmsFramework(String strPhoneTemplateBody,Map<String,String> mapInputWrapper,Map<String,Object> objectDetailsWrapper){
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try{
            if(strPhoneTemplateBody.contains('null')){
                strPhoneTemplateBody = strPhoneTemplateBody.replace('null','');
            }
            
            
            List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
            Database.SaveResult[] srCommunicationNubList;
            
             
                
            	CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
                        
                        objCommunicationNub.TemplateBody__c = strPhoneTemplateBody;
                        
                        
                        objCommunicationNub.TriggeredRecordId__c = String.valueOf(objectDetailsWrapper.get('resourceId'));
                        objCommunicationNub.TriggeredRecordName__c= String.valueOf(objectDetailsWrapper.get('sResourceName'));
            /*[Suresh] Send SMS Requirement #357709 - Starts */
            //objCommunicationNub.SMSReceivers__c = String.valueOf(mapInputWrapper.get('toPhone'));
            objCommunicationNub.Recipient_Phone_Number__c = String.valueOf(mapInputWrapper.get('toPhone'));
            //objCommunicationNub.SendersName__c = String.valueOf(mapInputWrapper.get('yourName'));
            objCommunicationNub.Status__c = 'In Progress';
            objCommunicationNub.Send_SMS__c = true;
            objCommunicationNub.SendMail__c = false;
            /*[Suresh] Send SMS Requirement #357709 - Ends */
             //Added By Kojashree
        		objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;      
                        
                        
                        lstCommunicationNubInsert.add(objCommunicationNub);
                        if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){                
                            srCommunicationNubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                            bSuccess = true;
                            
                        }
                        else{
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_ShareEmailCtrl.class.getName(), 'triggerSmsFramework','No Access on Framework_Log__c Object',true);
                        }
                
        }
        catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ShareEmailCtrl.class.getName(), 'triggerSmsFramework', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
}