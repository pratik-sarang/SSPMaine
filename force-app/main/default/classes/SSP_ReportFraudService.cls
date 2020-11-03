public class SSP_ReportFraudService {
   
    public static final String SUCCESS = 'bIsSuccess';
    public static final String FRAUD_ID = 'fraudID';
    public static final String EXCEPTION_Id = 'ExceptionId';
    public static final String ShowVerbiage = 'ShowVerbiage';
    public static final String ERROR = 'error';
    public static final String USER_ADDRESS_1 = 'USER_ADDRESS_1';
    public static final String USER_ADDRESS_2 = 'USER_ADDRESS_2';
    public static final String USER_CITY = 'USER_CITY';
    public static final String USER_STATE = 'USER_STATE';
    public static final String USER_COUNTY = 'USER_COUNTY';
    public static final String USER_PHONE = 'USER_PHONE';
    public static final String USER_ZIP = 'USER_ZIP';
    public static final String USER_EXT = 'USER_EXT';
    public static final String PAGE_NAME='SSP_ReportFraudService';
    public static final String USER_EMAIL='USER_EMAIL';
     
    @AuraEnabled 
    public static Map<String, Object> submitFraudReport(String jsonData , boolean contactData){
        Map<String, Object> objResponse = new Map<String, Object>();
                
        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => jsonData};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_FRAUD_SUBMISSION, mapParams);
        if(objList!=null && objList.size()>0 ){
            SSP_FraudSubmission_ResponseWrapper response = (SSP_FraudSubmission_ResponseWrapper) objList[0];
            if( response!=null  && response.SubmitFraudResult!= null && response.AckResponse==null){
                objResponse.put(SUCCESS, true);
                objResponse.put(FRAUD_ID,  response.SubmitFraudResult.FraudReportId); 
                objResponse.put(EXCEPTION_Id, response.SubmitFraudResult.ExceptionId);     
               }
            else {
                objResponse.put(SUCCESS, false);
                if(response.AckResponse!=null &&response.AckResponse.AckResponseCode!=null){
                objResponse.put('error',response.AckResponse.AckResponseCode);
                }
            }
        }
        else {
             objResponse.put(SUCCESS, false);
        }     
         		
        return objResponse;
        
    }
    
    
    @AuraEnabled
    public static SSP_LightningResponse getUserContactInfo() {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            response.bIsSuccess = true;
            Set<String> userFields = new Set<String>{
                'Profile.Name', 'ShowCitizenDashboard__c', 'Contact.Email', 'Contact.Phone', 'Contact.PrimaryPhoneExtension__c', 'Contact.MailingStreet', 'Contact.MailingLine2__c', 'Contact.MailingCity', 'Contact.MailingState', 'Contact.MailingPostalCode', 'Contact.MailingCountry'
            };
            List<User> currentUser = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName' => 'User','operator' => 'AND'}, 
                            userFields, new Map<String, String>{'limit' => '1', 'Id' => UserInfo.getuserId()});
            if(currentUser != null && !currentUser.isEmpty() &&
                currentUser[0].ShowCitizenDashboard__c == false &&
                currentUser[0].Profile.Name.equalsIgnoreCase(SSP_GlobalConstants.NON_CITIZEN_PROFILE)
            ) {
                Contact contactRecord = (Contact)currentUser[0].getSObject('Contact');
                SSP_Member__c memberRecord = new SSP_Member__c();
                if(contactRecord != null) {
                    memberRecord.Email__c = contactRecord.Email;
                    memberRecord.PrimaryPhoneNumber__c = contactRecord.Phone;
                    memberRecord.PrimaryPhoneExtension__c = contactRecord.PrimaryPhoneExtension__c;
                    memberRecord.MailingAddressLine1__c = contactRecord.MailingStreet;
                    memberRecord.MailingAddressLine2__c = contactRecord.MailingLine2__c;
                    memberRecord.MailingCity__c = contactRecord.MailingCity;
                    memberRecord.MailingStateCode__c = contactRecord.MailingState;
                    memberRecord.MailingZipCode5__c = contactRecord.MailingPostalCode;
                    memberRecord.MailingCountryCode__c = contactRecord.MailingCountry;
                }
                response.put('nonCitizen', true);
                response.put('memberRecord', memberRecord);
            }
            else {
                SSP_LightningResponse myInfoCalloutResponse = SSP_MyInformationController.getMyInformationDetails('');
                response.mapResponse.putAll(myInfoCalloutResponse.mapResponse);
            }
            response.put('countyMap', SSP_Utility.getPickListValue('SSP_Member__c', 'PhysicalCountyCode__c', null));
            response.put('stateMap', SSP_Utility.getPickListValue('SSP_Member__c', 'PhysicalStateCode__c', null));
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, PAGE_NAME, 'getMemberDetailsForUser', ex.getMessage() , true);
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }
}