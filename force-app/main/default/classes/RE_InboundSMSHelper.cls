public class RE_InboundSMSHelper {
    
    public static void consumeResponse(String responseBody, String phoneNo)
    {
        // We have nothing to do when there are no responses or phone no specified.
        if(phoneNo == null || phoneNo == '' || responseBody == null || responseBody =='')
        {

            return;
        }
        
        
        // Converting the response to upper case and trimming any extra spaces if available.
        String body = responseBody.toUpperCase().trim();

        List<String> lstRes = body.split(' ');
        String cns = lstRes[0];
        String dec = lstRes[1];
        if(dec.equalsIgnoreCase('Yes')){
            List<Consent__c> consentList = new List<Consent__c>();
            Consent__c objConsent = new Consent__c();
            Map<String, String> mapQueryParameters = new Map<String, String>();
            Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
            String sQuery;
            String sFieldsAPIName = RE_DataBaseQueryFields.sFIeldsToQueryOnConsentHttpUpdate;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnConsentHttpUpdate;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.consentobjectName, sFieldsAPIName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    
                    sQuery =  mapResponseData.get(true);
                    consentList = Database.query(sQuery);
                    if((!consentList.isEmpty())&& consentList.size()>0){
                        objConsent = consentList[0];
                    }
                }
                when SWITCH_FAILURE {

                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_InboundSMSHelper','consumeResponse','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }

            String regex = '[a-zA-Z]{1,}|\\-'; //User Global Constants
            String clientNumber = objConsent.Client__r.Phone.replaceAll(regex, '').replace('(','').replace(')','').replaceAll('\\s','');
            if(!clientNumber.startsWith('+1')){
                clientNumber = '+1'+clientNumber;
            }

            if(phoneNo==clientNumber){
                objConsent.status__c = RE_GlobalConstants.ACTIVE;
                objConsent.startDate__c = system.today();
                RE_DataAccessChecker.updateObject(Consent__c.getSObjectType(), objConsent); 
            }
            else{

                return;
            }
        }
        else{

            return;
        }
    } 
    
}