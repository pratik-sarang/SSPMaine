/**
* Class Name    : RE_CartLoginModelCtrl
* Owner         : DELOITTE
* Created Date  : 09/25/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  
*  
**/
public class RE_CartLoginModelCtrl {
	@AuraEnabled
    public static RE_CreateLightningServerResponse fetchKogURL(){
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        try{
            //callout to KOG to fetch the context Id
            
            Long startTime= DateTime.now().getTime();
            KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG Citizen');
            String strGateWayServiceRequestData = '[Input Parameters : pageURL='+objKog.PageURL__c+', ApplicationName='+objKog.ApplicationName__c+', Role='+objKog.Role__c+']';
            string contextId = RE_KOGRegistration.getKogContextID();
            if(String.isEmpty(contextId)){
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                publishEvents.add(new ErrorLog__e(StackTrace__c = '', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                  ErroLog__c= 'Null response from Gateway Service', Source__c ='RE_CartLoginModelCtrl', 
                                                  Message__c =  '' ,SourceFunction__c = 'fetchKogURL',
                                                  EndPoint__c = objKog.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                                  Integration_Payload__c = strGateWayServiceRequestData,InterfaceName__c = 'Gateway Service',ResponseData__c = contextId));
                if(publishEvents.size()>0){
                    EventBus.publish(publishEvents);
                } 
            }
            String kogInitialURL = objKog.KOG_Registration_URL__c;
            String KogRegistartionURL = objKog.KOG_URL__c+contextId;
            String encodeRegistrationURL = kogInitialURL+EncodingUtil.urlEncode(KogRegistartionURL, 'UTF-8');
            mapResponse.put('KogRegistrationURL', encodeRegistrationURL);
            mapResponse.put('KogLoginURL', objKog.Kog_Login_URL__c);
        }catch(exception ex){
            errorMap.put('error',ex.getMessage());
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
}