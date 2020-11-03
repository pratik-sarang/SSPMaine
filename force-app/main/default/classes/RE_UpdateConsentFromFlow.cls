/**
* Class Name    : RE_UpdateConsentFromFlow
* Owner         : DELOITTE
* Created Date  : 04/27/2020
* Description   : Update Consent details
*
* M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  
**/

public with sharing class RE_UpdateConsentFromFlow {
    
    
    @InvocableMethod(label = 'UpdateConsentRecordEnglish')
    public static void UpdateConsentRecordsEnglish(List<FlowInputs> request){
        Map<String, Object> errorMap  = new Map<String, Object>();
       
        FlowInputs flowDataWrapper = new FlowInputs();
        flowDataWrapper = request[0];
        String sconsentId = flowDataWrapper.consentId;
        
       
        Consent__c consentRec = new Consent__c(Id= sconsentId);
        consentRec.ConsentProvidedBy__c = flowDataWrapper.ConsentProvidedBy; 
        consentRec.StartDate__c = ((flowDataWrapper.I_Agree == 'True')? System.Today() : null) ;
        consentRec.EndDate__c = ((flowDataWrapper.I_Agree == 'False')? System.Today() : null);
        consentRec.Status__c = flowDataWrapper.I_Agree == 'True'? RE_GlobalConstants.ACTIVE : RE_GlobalConstants.INACTIVE; 
       
        try{
                //RE_DataAccessChecker.updateSetUpObject(Consent__c.getSObjectType(), consentRec);
                RE_SharingByPassCtrl.updateSobject(Consent__c.getSObjectType(), consentRec);
                     
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UpdateConsentFromFlow','UpdateConsentRecordsEnglish', e.getMessage(), true);
            throw e;
        } 
        
        Consent__c consent = new Consent__c();
        if(RE_DataAccessChecker.isAllowedToAccess(Consent__c.sObjectType) && RE_DataAccessChecker.isSafeField('Client__c', 'Consent__c') && sconsentId!=null){
               //consent = [SELECT Id,Name,Client__c FROM Consent__c WHERE Id=:sconsentId AND Id != null];
               consent = RE_SharingByPassCtrl.fetchConsentRecord('SELECT Id,Name,Client__c FROM Consent__c WHERE Id=:sconsentId AND Id != null', sconsentId)[0];
               
         }
        
        String clientId = consent.Client__c;
        
        Contact contactRec;
        Contact contactRecToUpdate = new Contact(id = clientId );
        
         if(RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && clientId!= null){
             //contactRec = [SELECT Id,Name,Phone,PreferredCommunicationMethod__c,ConsentToTexts__c FROM Contact WHERE Id =: contactId AND Id != null];   
             contactRec = RE_SharingByPassCtrl.getContactDetails('SELECT Id,Name,Phone,PreferredCommunicationMethod__c,ConsentToTexts__c FROM Contact WHERE Id =: clientId AND Id != null', clientId);
         }
        String communicationPref;
        If(flowDataWrapper.Communication_Preference == RE_GlobalConstants.CelularPhone || flowDataWrapper.Communication_Preference == RE_GlobalConstants.MobilePhone){
            communicationPref = RE_GlobalConstants.MobilePhone;
        }else if(flowDataWrapper.Communication_Preference == RE_GlobalConstants.EmailOption){
            communicationPref = RE_GlobalConstants.EmailOption;
        }
        
        if(!String.isBlank(flowDataWrapper.Communication_Preference) ){
             contactRecToUpdate.PreferredCommunicationMethod__c = communicationPref;
        }else{
            contactRecToUpdate.PreferredCommunicationMethod__c  = contactRec.PreferredCommunicationMethod__c; 
        }
        if(!String.isBlank(flowDataWrapper.ConsentToText)  ){
             contactRecToUpdate.ConsentToTexts__c = (flowDataWrapper.ConsentToText == 'True'? True : False );
        }else{
            contactRecToUpdate.ConsentToTexts__c = contactRec.ConsentToTexts__c;
        }
        if(!String.isBlank(flowDataWrapper.MobilePhone)){
             contactRecToUpdate.Phone = flowDataWrapper.MobilePhone; 
        }else{
            contactRecToUpdate.Phone = contactRec.Phone;
        }
       
         
        try{
            //RE_DataAccessChecker.updateSetUpObject(Contact.getSObjectType(), contactRecToUpdate);    
            RE_SharingByPassCtrl.updateSobject(Contact.getSObjectType(), contactRecToUpdate);
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UpdateConsentFromFlow','UpdateConsentRecordsEnglish', e.getMessage(), true);
            throw e;
        } 
        
        String InvitationId =  flowDataWrapper.invitationId;
        List<SurveyInvitation> lstSurveyInvites = new List<SurveyInvitation>();
        SurveyInvitation inv = new SurveyInvitation();
       
        try{
            if(InvitationId != null){
                String switchchoiceKey = (Schema.sObjectType.SurveyInvitation.isAccessible()) ? 'success' : 'failure'; 
                switch on (switchchoiceKey){
                    when  'success'{
                        inv = [SELECT Id,InviteExpiryDateTime,Name,Flow_Expiration_Date__c FROM SurveyInvitation WHERE ID=:InvitationId AND ID != null];
                        datetime currentdatetime = datetime.now();
                        Datetime myDate = Datetime.newInstanceGmt(currentdatetime.dateGmt(), currentdatetime.timeGmt());
                        inv.Flow_Expiration_Date__c = myDate;
                        lstSurveyInvites.add(inv);
                        
                        if(lstSurveyInvites != null){
                            RE_SharingByPassCtrl.updateSobjects(SurveyInvitation.getSObjectType(),lstSurveyInvites);
                        }
                           
                    }
                    when  'failure'{                            
                        errorMap.put('error','The insert of SurveyInvitation failed');
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UpdateConsentFromFlow','UpdateConsentRecordsEnglish','The insert of SurveyInvitation failed', true);                                        
                    }
                }        
                
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UpdateConsentFromFlow','UpdateConsentRecordsEnglish','Error Occured:: '+ e.getMessage(), true);
        }
            
        
    }
    
 
    //input details that comes to apex from flow
    public class FlowInputs{
        
        @InvocableVariable
        public String invitationId;
            
        @InvocableVariable
        public String prefMethodBolVal;
        
        @InvocableVariable
        public String consentId;
        
        @InvocableVariable
        public String contactId;
        
        @InvocableVariable
        public String Communication_Preference;
        
        @InvocableVariable
        public String MobilePhone;
        
        @InvocableVariable
        public String ConsentToText;
        
        @InvocableVariable
        public String I_Agree;
        
        @InvocableVariable
        public String ConsentProvidedBy;
        
    }
}