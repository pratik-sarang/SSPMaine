public with sharing class SSP_RIDPServices {

/**
* @author: Prasanth Prasanth
* @method: postAnswers
* @desc: Call PostAnswers Callout
*/
@AuraEnabled
public static SSP_LightningResponse postAnswers(String mapQuestionAnswers,String userKOGID,String SessionId,String memberId){
    SSP_LightningResponse objResponse = new SSP_LightningResponse();
    objResponse.bIsSuccess = false;
    Map<String,String> selectedAnswers = (Map<String,String>)JSON.deserialize(mapQuestionAnswers, Map<String,String>.class);
    try{
        SSP_RIDP_RequestWrapper objRequestBody = new SSP_RIDP_RequestWrapper();
        List<SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet> answerSets = new List<SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet>();
        
        for(String q: selectedAnswers .keySet())
        {
            SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet ansSwet1 = new SSP_RIDP_DatacontractOrg200407KeupsB.AnswerSet();
            ansSwet1.VerificationQuestionNumber = q;
            ansSwet1.VerificationAnswer = selectedAnswers .get(q);
            answerSets.add(ansSwet1);
        }
        
        
        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfAnswerSet arrOfAnswer = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfAnswerSet();
        arrOfAnswer.AnswerSet = answerSets;
        
        SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserReply userReply = new SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserReply();
        userReply.LanguagePreference = SSP_GlobalConstants.RIDP_LANGUAGUE_PREFERENCE;
        userReply.SessionID     	 = SessionId;
        userReply.VerificationAnswers  = arrOfAnswer;
        
        
        objRequestBody.RIDPUserReply = userReply;
        objRequestBody.userKOGID = userKOGID;
        
        Map<String,object> inputParams = new Map<string,object>();
        inputParams.put('jsonbody', JSON.serialize(objRequestBody));
        List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_RIDP_POST_ANSWERS,inputParams);
        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse response = (SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse) slist[0];
        
        String jsonstring= JSON.serialize(response);

        objResponse.put('response',jsonstring);
        
        if(jsonstring.contains(SSP_GlobalConstants.RIDP_RESPONSE_CHECK))
        {
            objResponse.bIsSuccess = true;
        }
        if(jsonstring.contains('reference number'))
        {
            if(memberId!=null)
            {
            SSP_Member__c sspmem= SSP_MemberSelector.queryMemberDataById(memberId,SSP_GlobalConstants.RIDP_UPADTE_REFERENCE_NUMBER);
            String refnum=jsonstring;
            List<String> refnum1= refnum.split('reference number');
            String refnum2=refnum1[1].substring(0,13);
            sspmem.Reference_Number__c=refnum2;
            sspmem.Identify_verification_method__c='Resume RIDP';
            objResponse.put('referenceNumber',refnum2);
            
          
            ESAPI.accessController().updateAsUser(sspmem, new List<String>{'Identify_verification_method__c','Reference_Number__c'});
            objResponse.bIsSuccess = true;
            }
        }
        
        
    }
    catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'getTypeOfProofs', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                        }
    return objResponse;
}


/**
* @author: Prasanth Prasanth
* @method: getData
* @desc: Getting data from the memeber and Contact
*/


@AuraEnabled
public static SSP_LightningResponse getData(String memberId)
{
    SSP_LightningResponse objResponse= new SSP_LightningResponse();
    objResponse.bIsSuccess=false;


    try{
        List<User> user= [SELECT Id, ContactId FROM User where Id=:UserInfo.getUserId()];
            SSP_Member__c sspmem ;
            
        if(memberId<>null)
        {
            sspmem= SSP_MemberSelector.queryMemberDataById(memberId,SSP_GlobalConstants.RIDP_MEMBER_QUERY_FIELDS);
            
        } 
            List<Contact> listcon= new List<Contact>() ; 
        
        if(user[0].ContactId<>null)
        {
        
        listcon = [SELECT Id, KOGSourceId__c FROM Contact where Id=:user[0].ContactId];
      
        }
        if(sspmem != null){        
        objResponse.put(SSP_GlobalConstants.RIDP_LEGAL_FIRST_NAME, sspmem.FirstName__c);
        objResponse.put(SSP_GlobalConstants.RIDP_LEGAL_LAST_NAME, sspmem.LastName__c);
        objResponse.put(SSP_GlobalConstants.RIDP_MIDDLE_NAME, sspmem.MiddleInitial__c);
        objResponse.put(SSP_GlobalConstants.RIDP_NAME_SUFFIX, sspmem.SuffixCode__c);
        objResponse.put(SSP_GlobalConstants.RIDP_BIRTH_DATE,''+ sspmem.BirthDate__c);
        objResponse.put(SSP_GlobalConstants.RIDP_SSN, sspmem.SSN__c);
        objResponse.put(SSP_GlobalConstants.RIDP_STREET_NAME, sspmem.MailingAddressLine1__c);
        objResponse.put(SSP_GlobalConstants.RIDP_CITY_NAME, sspmem.MailingCity__c);
        objResponse.put(SSP_GlobalConstants.RIDP_STATE, sspmem.MailingStateCode__c);
        objResponse.put(SSP_GlobalConstants.RIDP_POSTAL_CODE, sspmem.MailingZipCode5__c);
        objResponse.put(SSP_GlobalConstants.RIDP_POSTAL_CODE_EXTENSION, sspmem.MailingZipCode4__c);
        objResponse.put(SSP_GlobalConstants.RIDP_FULL_TELEPHONE_NUMBER, sspmem.PrimaryPhoneNumber__c);
        objResponse.put(SSP_GlobalConstants.RIDP_USER_KOGID, listcon[0].KOGSourceId__c);
        objResponse.put(SSP_GlobalConstants.RIDP_IDENTITY_VERIFICATION_METHOD, sspmem.Identify_verification_method__c);
        objResponse.put(SSP_GlobalConstants.RIDP_REFERENCE_NUMBER,sspmem.Reference_Number__c );
        objResponse.put(SSP_GlobalConstants.RIDP_GENDER,sspmem.GenderCode__c );
        objResponse.put(SSP_GlobalConstants.RIDP_INDIVIDUALID,sspmem.IndividualId__c );
        objResponse.put(SSP_GlobalConstants.RIDP_NON_CITIZEN_FLAG,sspmem.Non_Citizen_Verification_Flag__c);
        objResponse.bIsSuccess=true;
        }
    }
    catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RIDPServices', 'getData', ex.getMessage() , true); 
                            objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                        }
    return objResponse;
}
/**
* @author: Prasanth Prasanth
* @method: resumeRIDP
* @desc: Calling Resume RIDP callout
*/

@AuraEnabled
public static SSP_LightningResponse resumeRIDP(Map<String,String> mp){
    SSP_LightningResponse objResponse= new SSP_LightningResponse();
    objResponse.bIsSuccess=false;
    try{
        SSP_RIDP_RequestWrapper objRequestBody = new SSP_RIDP_RequestWrapper();
        
        SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserResume userResume = new SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserResume();
        List<String> dateStringList ;
        List<String> dateStringList1;
        if(mp.containsKey(SSP_GlobalConstants.RIDP_BIRTH_DATE))
        {
            dateStringList1=mp.get(SSP_GlobalConstants.RIDP_BIRTH_DATE).split(' ');
            dateStringList =dateStringList1[0].split('-');
        }
        
        userResume.LanguagePreference = SSP_GlobalConstants.RIDP_LANGUAGUE_PREFERENCE;
        userResume.LegalLastName      = mp.get(SSP_GlobalConstants.RIDP_LEGAL_LAST_NAME);
        userResume.BirthDate          = DateTime.newInstance(Integer.valueOf(dateStringList[0]),Integer.valueOf(dateStringList[1]),Integer.valueOf(dateStringList[2]));
        userResume.ReferenceNumber    = mp.get(SSP_GlobalConstants.RIDP_REFERENCE_NUMBER);
        
        objRequestBody.RIDPUserResume = userResume;
        objRequestBody.userKOGID      = mp.get(SSP_GlobalConstants.RIDP_USER_KOGID);
        
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(objRequestBody));
        List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_RIDP_CHECK_RESUME, obj);
        SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse response = (SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse) slist[0];
        
        String jsonstring = JSON.serialize(response);
                    
        objResponse.put('response',jsonstring);
        if(jsonstring.contains(SSP_GlobalConstants.RIDP_RESPONSE_CHECK))
        {
            objResponse.bIsSuccess = true;
        }
        
        
    }
    catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RIDPServices', 'resumeRIDP', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                        }
    return objResponse;
    
}
/**
* @author: Prasanth Prasanth
* @method: getQuestions
* @desc: Calling getQuestions Service callout
*/

@AuraEnabled
public static SSP_LightningResponse getQuestions(Map<String,String> mp,String LanguagePreference,String memberId){
    
    SSP_LightningResponse objResponse = new SSP_LightningResponse();
    objResponse.bIsSuccess = false;
    String jsonstring;
    try{
            SSP_RIDP_RequestWrapper objRequestBody = new SSP_RIDP_RequestWrapper();
        SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserInfo userInfo = new SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserInfo();
        List<String> dateStringList1;
        List<String> dateStringList;
        if(mp.containsKey(SSP_GlobalConstants.RIDP_BIRTH_DATE))
        {
            dateStringList1=mp.get(SSP_GlobalConstants.RIDP_BIRTH_DATE).split(' ');
            dateStringList =dateStringList1[0].split('-');
        }
        userInfo.LanguagePreference = SSP_GlobalConstants.RIDP_LANGUAGUE_PREFERENCE;
        userInfo.LegalFirstName     = mp.containsKey(SSP_GlobalConstants.RIDP_LEGAL_FIRST_NAME)? mp.get(SSP_GlobalConstants.RIDP_LEGAL_FIRST_NAME) :null;
        userInfo.LegalLastName      = mp.containsKey(SSP_GlobalConstants.RIDP_LEGAL_LAST_NAME)? mp.get(SSP_GlobalConstants.RIDP_LEGAL_LAST_NAME) :null;
        userInfo.MiddleName         = mp.containsKey(SSP_GlobalConstants.RIDP_MIDDLE_NAME)? mp.get(SSP_GlobalConstants.RIDP_MIDDLE_NAME) :null;
        userInfo.NameSuffix         = mp.containsKey(SSP_GlobalConstants.RIDP_NAME_SUFFIX)? mp.get(SSP_GlobalConstants.RIDP_NAME_SUFFIX) :null;
        userInfo.BirthDate          = DateTime.newInstance(Integer.valueOf(dateStringList[0]),Integer.valueOf(dateStringList[1]),Integer.valueOf(dateStringList[2]))  ;
        userInfo.SSN                = mp.containsKey(SSP_GlobalConstants.RIDP_SSN)? mp.get(SSP_GlobalConstants.RIDP_SSN) :null;
        userInfo.StreetName         = mp.containsKey(SSP_GlobalConstants.RIDP_STREET_NAME)? (mp.get(SSP_GlobalConstants.RIDP_STREET_NAME).contains(',') ? mp.get(SSP_GlobalConstants.RIDP_STREET_NAME).replace(',','') : mp.get(SSP_GlobalConstants.RIDP_STREET_NAME)) :null;
        userInfo.CityName           = mp.containsKey(SSP_GlobalConstants.RIDP_CITY_NAME)? mp.get(SSP_GlobalConstants.RIDP_CITY_NAME) :null;
        userInfo.State              = mp.containsKey(SSP_GlobalConstants.RIDP_STATE)? mp.get(SSP_GlobalConstants.RIDP_STATE) :null;
        userInfo.PostalCode         = mp.containsKey(SSP_GlobalConstants.RIDP_POSTAL_CODE)? mp.get(SSP_GlobalConstants.RIDP_POSTAL_CODE) :null;
        userInfo.PostalCodeExtension = mp.containsKey(SSP_GlobalConstants.RIDP_POSTAL_CODE_EXTENSION)? mp.get(SSP_GlobalConstants.RIDP_POSTAL_CODE_EXTENSION) :null;
        userInfo.FullTelephoneNumber = mp.containsKey(SSP_GlobalConstants.RIDP_FULL_TELEPHONE_NUMBER)? mp.get(SSP_GlobalConstants.RIDP_FULL_TELEPHONE_NUMBER) :null;
        
        objRequestBody.RIDPUserInfo = userInfo;
        objRequestBody.userKOGID = mp.containsKey(SSP_GlobalConstants.RIDP_USER_KOGID)? mp.get(SSP_GlobalConstants.RIDP_USER_KOGID) :null;
        
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(objRequestBody));
        List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_RIDP_GET_QUESTIONS, obj);
        SSP_RIDP_DatacontractOrg200407Kogserv.RIDPServiceResponse response = (SSP_RIDP_DatacontractOrg200407Kogserv.RIDPServiceResponse) slist[0];
        
        jsonstring= JSON.serialize(response);
        objResponse.put('response',jsonstring);
        if(jsonstring.contains(SSP_GlobalConstants.RIDP_RESPONSE_CHECK))
        {
            objResponse.bIsSuccess = true;
        }
        if(jsonstring.contains('reference number'))
        //reference number
        {
            if(memberId!=null)
            {
            SSP_Member__c sspmem= SSP_MemberSelector.queryMemberDataById(memberId,SSP_GlobalConstants.RIDP_UPADTE_REFERENCE_NUMBER);
            String refnum=jsonstring;
            List<String> refnum1= refnum.split('reference number');
            String refnum2=refnum1[1].substring(0,13);
            sspmem.Reference_Number__c=refnum2;
            sspmem.Identify_verification_method__c='Resume RIDP';
            objResponse.put('referenceNumber',refnum2);
            
          //update sspmem;
            ESAPI.accessController().updateAsUser(sspmem, new List<String>{'Identify_verification_method__c','Reference_Number__c'});
            objResponse.bIsSuccess = true;
            }
        }
        
        
    }
    catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RIDPServices', 'getQuestions', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                            
                        }
    return objResponse;
    
    
}

    /**
    * @author: Prasanth Prasanth
    * @method: updateApplicationStatusUnSubmitted
    * @desc: updating application status to unsubmitted and update Non_Citizen_Verification_Flag__c to true
    */
    @AuraEnabled
    public static SSP_LightningResponse updateApplicationStatusUnSubmitted(String applicationId, String memberId, String sPage){
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        SSP_HouseHoldSummaryService.MCIcalloutstatuscheck=true; //Since the MCI Call should happen from HH Member details, setting this flag here - Added by Nupoor 
        objResponse.bIsSuccess=false;
        try{
            //Since MCI will be handled from HH Member screen itself, adding this here - Nupoor
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            if(sPage.equals('documentUpload')){
                sessionPart.put('MCICallDocUPload',true);
            }else if(sPage.equals('RIDPPage') || sPage.equals('AddHouseHoldMemberPage')){ //Defect-387064 - Only 'AddHouseHoldMemberPage'
                sessionPart.put('MCICallRIDP',true);
            }
            SSP_Application__c sspapp=SSP_ApplicationSelector.queryApplicationDataById(applicationId,new List<String>{'Status__c'});
            sspapp.Status__c=SSP_GlobalConstants.BATCH_SSP_APPLICATION_STATUS_UN;
            ESAPI.accessController().updateAsUser(sspapp,new List<String>{'Status__c'});
            
            SSP_Member__c sspmem= SSP_MemberSelector.queryMemberDataById(memberId, new List<String>{'Non_Citizen_Verification_Flag__c','Identify_verification_method__c'}); //Defect-387064 - added 'Identify_verification_method__c'
            sspmem.Non_Citizen_Verification_Flag__c=true;
            //Start - Defect - 387064
            if(String.isNotBlank(sPage) && sPage.equals('AddHouseHoldMemberPage')) {
                sspmem.Identify_verification_method__c = SSP_GlobalConstants.RIDP_RESUME_RIDP_VALUE;
            }
            //End - Defect - 387064
            ESAPI.accessController().updateAsUser(sspmem,new List<String>{'Non_Citizen_Verification_Flag__c','Identify_verification_method__c'}); ////Defect-387064 - added 'Identify_verification_method__c'
            
            objResponse.bIsSuccess=true;
            
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RIDPServices', 'updateApplicationStatusUnSubmitted', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);}
        return objResponse;
        
    }
    @AuraEnabled
    public static void deleteNavFlowRecords(String applicationId){
        try{
            SSP_SharingBypassFetcher.deleteRecords(applicationId);
        }
         catch(Exception ex) { 
             LOG_LogMessageUtility.logMessage(ex, 'SSP_RIDPServices', 'deleteNavFlowRecords', ex.getMessage() , true); 
         }
    }
}