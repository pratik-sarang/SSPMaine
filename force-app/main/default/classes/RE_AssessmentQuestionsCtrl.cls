/**
* Class Name    : RE_AssessmentQuestionsCtrl
* Owner         : DELOITTE
* Created Date  : 09/12/2019
* Description   : Controller class for RE_ReferralDetails
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  12/09/2019  Prashant       Initial Version
*
**/


public with sharing class RE_AssessmentQuestionsCtrl {
    
    /********************************************************************************************
* @author       Prashant
* @date         09/12/2019
* @methodname   getAssessmentQuestions()
* @description  This methods is used to get favorite resources
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getAssessmentQuestions( String strAssessmentId, String sContactId){
        String sAssessmentId = String.escapeSingleQuotes(strAssessmentId);
         //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
        sContactId=String.isNotBlank(sContactId)?String.escapeSingleQuotes(sContactId):sContactId;
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                Boolean bSuccess = false; 
        RE_AssessmentQuestionsWrapper quesAnsWrapper = new RE_AssessmentQuestionsWrapper();
        List<RE_AssessmentQuestionsWrapper.Question> lstQuestionWrapper = new List<RE_AssessmentQuestionsWrapper.Question>();
        try{
            //Code to fetch the questions and answers
                String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnQuestions; 
           
            String sWhereClause=RE_DataBaseQueryFields.sWhereClauseOnQuestions;
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            Map<String,String> mapQueryParametersForQuestion = new Map<String,String>();
            mapQueryParametersForQuestion.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParametersForQuestion.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParametersForQuestion.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            Id sQuesRecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('Resource Engine Assessment Question').getRecordTypeId();
            Map<Boolean,String> mapResponseQues = RE_DataAccessChecker.getFieldsAccessibility('Question__c',sFieldsApiName,mapQueryParametersForQuestion);
            
            
            String sFieldsApiNameAnswer = RE_DataBaseQueryFields.sFieldsToQueryOnAnswer;
           
            String sOrderbyAnswer = RE_DataBaseQueryFields.sCreatedDateASC;
            Map<String,String> mapQueryParametersForAnswer = new Map<String,String>();
            
            Map<Boolean,String> mapResponseAns = RE_DataAccessChecker.getFieldsAccessibility('AnswerChoice__c',sFieldsApiNameAnswer,mapQueryParametersForAnswer);			
            
            
           
           
            String squerystring=RE_DatabaseQueryFields.sQueryString;
            List<Question__c> lstquestions;
            if(mapResponseQues.get(true) != null && mapResponseAns.get(true) != null){
                
                lstquestions =Database.query(squerystring); 
               
                
            }
            else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_AssessmentQuestionsCtrl','getAssessmentQuestions','***FLS Violation***mapResponseQues'+mapResponseQues.get(false),true);
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_AssessmentQuestionsCtrl','getAssessmentQuestions','***FLS Violation***mapResponseAns'+mapResponseAns.get(false),true);
            }
          
            for(Question__c ques : lstquestions)
            {
                RE_AssessmentQuestionsWrapper.Question q=new RE_AssessmentQuestionsWrapper.Question(ques);
                List<RE_AssessmentQuestionsWrapper.AnswerChoice> anslst=new List<RE_AssessmentQuestionsWrapper.AnswerChoice>();
                
                
                Map<String,String> mapResponseValue = new Map<String,String>();
                Map<Decimal,String> mapResponseId = new Map<Decimal,String>();
                List<RE_AssessmentQuestionsWrapper.OptionsWrapper> lstOptionsToDisplay = new List<RE_AssessmentQuestionsWrapper.OptionsWrapper>();
                for(AnswerChoice__c answerchoice : ques.Answer_Choices__r){
                    RE_AssessmentQuestionsWrapper.OptionsWrapper objOption = new RE_AssessmentQuestionsWrapper.OptionsWrapper();
                    objOption.label = answerchoice.Answer__c;
                    
                    objOption.value = answerchoice.Id;
                    
                    mapResponseValue.put(answerchoice.Answer__c,answerchoice.Id);
                    lstOptionsToDisplay.add(objOption);
                    mapResponseId.put(answerchoice.Score__c,answerchoice.Id);
                    RE_AssessmentQuestionsWrapper.AnswerChoice ans=new RE_AssessmentQuestionsWrapper.AnswerChoice(answerchoice);
                    anslst.add(ans);
                } 
               
                q.lstOptions = lstOptionsToDisplay;
                
                lstQuestionWrapper.add(q);
               
            }
            
            
            Contact objcon = new Contact();
            String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
             //Added By Kojashree  -- SSP Merge Fixes
      		  String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
      
            if(loggedinProfile == RE_GlobalConstants.strGuestProfileName){
                RE_AssessmentQuestionsWrapper.bIsAnonymous = true;
            }else{
                RE_AssessmentQuestionsWrapper.bIsAnonymous = false;
            }
            
            
            Id conid; 
            
             if(sContactId!=null && sContactId != 'undefined' && sContactId != '' && loggedinProfile != RE_GlobalConstants.strGuestProfileName){
                conid = sContactId;
            
      
                
            }//Updated By Kojashree
            else if((sContactId == null || sContactId == 'undefined' || sContactId == '')&& selectedRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
              
                User u=RE_sharingbypassctrl.getLoggedinUserAccount();                        
                conid=u.contactid;
            }

            if(conid != null && loggedinProfile!= RE_GlobalConstants.strGuestProfileName){
              String sFieldsApiNameContact = RE_DataBaseQueryFields.sFieldsToQueryOnContactForAssessment; 
              String sWhereClauseContact = RE_DataBaseQueryFields.sWhereClauseOnContactForAssessment;
           
            Map<String,String> mapQueryParametersForContact = new Map<String,String>();
            mapQueryParametersForContact.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseContact);
              
            Map<Boolean,String> mapResponseContact = RE_DataAccessChecker.getFieldsAccessibility('Contact',sFieldsApiNameContact,mapQueryParametersForContact);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseContact.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
          
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    String sQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('Contact', sFieldsApiNameContact, mapQueryParametersForContact);
                   
                    objcon = Database.query(sQuery);
                   
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentQuestionsCtrl.class.getName(), 'getAssessmentQuestions', RE_GlobalConstants.FLS_ERROR + '' + mapResponseContact.get(false), true);
                }
             }  
            }
            
            String address='';
            if(objcon!=null){
                 
                if(!String.isblank(objcon.MailingStreet)){
                 
                    address=address+objcon.MailingStreet+ ', ';
                }
                if(!String.isblank(objcon.MailingCity)){
                    address=address+objcon.MailingCity+ ', ';
                }
                if(!String.isblank(objcon.MailingState)){
                    address=address+objcon.MailingState+ ', ';
                }
                if(!String.isblank(objcon.MailingPostalCode)){
                    address=address+objcon.MailingPostalCode+ ', ';
                }
                if(!String.isblank(objcon.MailingCountry)){
                    address=address+objcon.MailingCountry;
                }
                
            }
            String sGuestUserEmail = '';
            
            mapResponse.put('records', JSON.serialize(lstQuestionWrapper));
            mapResponse.put('addressrec', address);
            mapResponse.put('isanonymous',RE_AssessmentQuestionsWrapper.bIsAnonymous);
            
            bSuccess=true;
            
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentQuestionsCtrl','getAssessmentQuestions', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);        
        
    }
    /*   @AuraEnabled
public static String createAssessment(Map<String, Object> objwrapper){

return ''+objwrapper.get('data');
}  */
    /********************************************************************************************
* @author       Prashant
* @date         09/12/2019
* @methodname   getAssessmentQuestions()
* @description  This methods is used to get favorite resources
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/	
    
    @AuraEnabled
    // public static RE_CreateLightningServerResponse createAssessment(List<RE_AssessmentQuestionsWrapper.Question> objwrapper){
    public static RE_CreateLightningServerResponse createAssessment(String strmyString, String strContactId, String strAssessmentTemplateId, String strTempName,String strEmail){
      // Commented to fix the Assessment Flow having questions with quotes
       // String myString = String.escapeSingleQuotes(strmyString);
        String myString = strmyString;
        String sContactId;
        Id conid;
        String sEmail= String.isNotBlank(strEmail)?String.escapeSingleQuotes(strEmail):'';
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
       // Added By Kojashree --- SSP Merge
        String sRole = GeneralUtility.getLoggedInUserSelectedRole();
        
       /* if(loggedinProfile == RE_GlobalConstants.strCitizenProfileName){
            User u=RE_sharingbypassctrl.getLoggedinUserAccount();                        
           
            conid = u.contactid;
            
        }*/
        
        if(sRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
            User u=RE_sharingbypassctrl.getLoggedinUserAccount();                        
            conid = u.contactid;
         }
        
        if(strContactId !='' &&strContactId !='undefined' && loggedinProfile != RE_GlobalConstants.strGuestProfileName){ 
            sContactId= String.escapeSingleQuotes(strContactId);
        }//else if(loggedinProfile == RE_GlobalConstants.strCitizenProfileName){
        else if(sRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
            sContactId= conid;
        }
        
        
        String sAssessmentTemplateId = String.escapeSingleQuotes(strAssessmentTemplateId);
        String sTempName = String.escapeSingleQuotes(strTempName);
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                Boolean bSuccess = false; 
        
        List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question> ) JSON.deserialize(myString, List<RE_AssessmentQuestionsWrapper.Question>.class);
        
        try{
            //Code to create user assessment records
            Id userAssessmentId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('User Assessment').getRecordTypeId();
            Assessment__c userAssessmentObj = new Assessment__c();
            userAssessmentObj.AssessmentTemplate__c= sAssessmentTemplateId;
            
            //Added for Guest User Assessment Flow
            if(loggedinProfile != RE_GlobalConstants.strGuestProfileName){
                userAssessmentObj.Partner__c = GeneralUtility.getLoggedInUserContactId(); 
            }else{
                userAssessmentObj.Partner__c = sContactId;
            }
            
            userAssessmentObj.recordtypeid=userAssessmentId;
            
            userAssessmentObj.Resident__c= sContactId;
            
           
            
            //Code to create assessment response records
            List <AssessmentResponse__c> asmntresplst = new List<AssessmentResponse__c>();
           
            //  For calculating lat long
            for(RE_AssessmentQuestionsWrapper.Question qs : retVal){
                AssessmentResponse__c assessmentresponseObj = new AssessmentResponse__c();
                //Moved below to fix the "You have uncommitted work pending. Please commit or rollback before calling out"
                //assessmentresponseObj.Assessment__c=userAssessmentObj.Id;
                if (qs.sResponse instanceOf Id ){
                    assessmentresponseObj.AnswerChoice__c=qs.sResponse;
                }else if(qs.sResponse!=null && qs.dQuesOrder == 1){
                    String strLatLong = GeneralUtility.getLatLong(qs.sResponse);
                    //Nandita: Added condition to fix Defect # 362841 Release_1.1
                    If(strLatLong != null){
                        List<String> lstLatLong = strLatLong.split('##');
                        Double dblLat = Double.valueOf(lstLatLong[0]);
                        Double dblLon = Double.valueOf(lstLatLong[1]);
                        assessmentresponseObj.AssessmentGeolocation__Latitude__s= dblLat;
                        assessmentresponseObj.AssessmentGeolocation__Longitude__s=dblLon;    
                    }
                    assessmentresponseObj.TextAnswer__c=qs.sResponse;
                    if(loggedinProfile == RE_GlobalConstants.strGuestProfileName){
                        assessmentresponseObj.Email__c = sEmail;//for guest user email field
                    }
                    
                }else if(qs.sResponse!=null && qs.dQuesOrder != 1){
                    assessmentresponseObj.TextAnswer__c=qs.sResponse;
                }
                assessmentresponseObj.Question__c=qs.questionId;
                
                assessmentresponseObj.Resident__c=sContactId;
                
                
                asmntresplst.add(assessmentresponseObj); 
            }
            //Moved below 
            if(loggedinProfile != RE_GlobalConstants.strGuestProfileName){
                RE_DataAccessChecker.insertObject(Assessment__c.getSObjectType(), userAssessmentObj);
            }else{
                RE_SharingbypassCtrl.insertSobject(Assessment__c.getSObjectType(), userAssessmentObj);
            }
             
            
            Id sAssessmentRespRecTypeId = Schema.SObjectType.AssessmentResponse__c.getRecordTypeInfosByName().get('Resource Engine Assessment Response').getRecordTypeId();//Nandita: Added cod eto get Assessment Response Record Type Id
            //Code to add the user tempalte record id
            for(AssessmentResponse__c resp : asmntresplst ){
                resp.Assessment__c=userAssessmentObj.Id;
                resp.recordtypeid = sAssessmentRespRecTypeId; // Nandita: Added code to set the record type id
            }
            
            if(!asmntresplst.IsEmpty()){ 
                
                if(loggedinProfile != RE_GlobalConstants.strGuestProfileName){
                    RE_DataAccessChecker.insertObjects(AssessmentResponse__c.getSObjectType(), asmntresplst); 
                }else{
                    RE_SharingbypassCtrl.insertSobjects(AssessmentResponse__c.getSObjectType(), asmntresplst);   
                }
                
                
            }
            
            RE_SDOHscore.calculateSDOHScoreAndSaveCat(userAssessmentObj.Id,sContactId);
            
            mapResponse.put('records', JSON.serialize(userAssessmentObj.Id));
            bSuccess = true; 
           
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentQuestionsCtrl','createAssessment', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
* @author       Nandita
* @date         04/30/2020
* @methodname   checkLoggedinUserRole()
* @description  This methods is used to determine logged in user profile
* @return       Map<String,boolean>
**********************************************************************************************/	
  @AuraEnabled
   public static Map<String,String> checkLoggedinUserRole(String userAssessmentId){
       String UserProfile = '';
        String selectedRole = '';
       //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
       userAssessmentId=String.isNotBlank(userAssessmentId)?String.escapeSingleQuotes(userAssessmentId):userAssessmentId;
       Map<String,String> mapUserProfile = new map<String,String>();
       Assessment__c objAssessment = new Assessment__c();
       try{
          String decryptAssessmentId;
          UserProfile = GeneralUtility.getLoggedInUserProfileName();
           //Added By Kojashree  -- SSP Merge Fixes
          selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
          // if(UserProfile == RE_GlobalConstants.strCitizenProfileName){
          if(selectedRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
             mapUserProfile.put('UserType','Citizen');
             //Force Reviewer Changes : Kojashree Kakariya
             RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (userAssessmentId != null && userAssessmentId != '')? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
       	     switch on (switchCaseKey) {
                 when SWITCH_SUCCESS { 
                     decryptAssessmentId = decryptParameter(userAssessmentId);
                     objAssessment.Id = decryptAssessmentId;
                     objAssessment.Resident__c = GeneralUtility.getLoggedInUserContactId();
                     //RE_Release 1.4 – Bug 376896 - Payal Dubela 
                     objAssessment.Partner__c=GeneralUtility.getLoggedInUserContactId();
                     boolean isSuccess = RE_SharingByPassCtrl.updateSobject(Assessment__c.getSObjectType(),objAssessment);
                     mapUserProfile.put('AssessmentId',decryptAssessmentId);
                 }
                }
            }
          // else if(UserProfile == RE_GlobalConstants.RE_ASSISTER_PROFILE){
          else if(selectedRole == RE_GlobalConstants.RE_ASSISTER_ROLE){
              mapUserProfile.put('UserType','Assister');
          }
          //else if(UserProfile == RE_GlobalConstants.strCommunityProfileName){
          else if(selectedRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || selectedRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF ){
              mapUserProfile.put('UserType','CPAdmin');
          }
          else if(UserProfile == RE_GlobalConstants.strGuestProfileName){
              //Force Reviewer Fixes : Kojashree Kakariya
              RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (userAssessmentId != null && userAssessmentId != '')? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
              switch on (switchCaseKey) {
                  when SWITCH_SUCCESS {
                      decryptAssessmentId = decryptParameter(userAssessmentId);
                      mapUserProfile.put('AssessmentId',decryptAssessmentId);
                  }
              }
             mapUserProfile.put('UserType','Guest');
          }

       }
       catch(Exception e){
            //errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentQuestionsCtrl','checkLoggedinUserRole', e.getMessage()+' ' + e.getStackTraceString(), true);
       }
       return mapUserProfile;
   }
   /********************************************************************************************
* @author       Nandita
* @date         05/05/2019
* @methodname   encryptParameter()
* @description  This methods is used to encrypt URL parameter using AES256
* @return       String
**********************************************************************************************/	
   
   @AuraEnabled
   public static String encryptParameter(String sParamValue){
       string sEncodedValue = '';
       //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
       sParamValue=String.isNotBlank(sParamValue)?String.escapeSingleQuotes(sParamValue):sParamValue;
       try{
            RE_AES_Encryption_Key__c objAESKey = RE_AES_Encryption_Key__c.getOrgDefaults();
            Blob cryptoKey = EncodingUtil.base64Decode(objAESKey.AES_Key__c); 
            Blob data =  Blob.valueOf(sParamValue);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data); 
            sEncodedValue = EncodingUtil.base64Encode(encryptedData);
       }
       catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentQuestionsCtrl','encryptParameter', e.getMessage()+' ' + e.getStackTraceString(), true);
       }
       return sEncodedValue;
    }

    /********************************************************************************************
* @author       Nandita
* @date         05/05/2019
* @methodname   decryptParameter()
* @description  This methods is used to decrypt URL parameter using AES256
* @return       String
**********************************************************************************************/	
   
     @AuraEnabled
   public static String decryptParameter(String sParamValue){
       String decryptedData='';
        //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
        sParamValue=String.isNotBlank(sParamValue)?String.escapeSingleQuotes(sParamValue):sParamValue;
       try{
        RE_AES_Encryption_Key__c objAESKey = RE_AES_Encryption_Key__c.getOrgDefaults();
        Blob cryptoKey = EncodingUtil.base64Decode(objAESKey.AES_Key__c);  
        Blob data = EncodingUtil.base64Decode(sParamValue);
        Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES256', cryptoKey, data); 
         decryptedData= dataToDecrypt.toString(); 
       }
       catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_AssessmentQuestionsCtrl','decryptParameter', e.getMessage()+' ' + e.getStackTraceString(), true);
       }
       return decryptedData;
   }
    
}