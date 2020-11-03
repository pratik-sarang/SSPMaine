public with sharing class RE_KOGRegistration {
public static String  getKogContextID(){
        tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService  gatewayKOGService=new tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService();
        KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG Citizen');      
    	String contextId;
        gatewayKOGService.clientCertName_x=objKog.Certificate__c;
        String pageURL = objKog.PageURL__c;
        String appName = objKog.ApplicationName__c;
        String role = objKog.Role__c    ;
        String SERVICE_URL_EP=objKog.EndURL__c;
    	Long startTime= DateTime.now().getTime();
        gatewayKOGService.endpoint_x=SERVICE_URL_EP;
    	String strGateWayServiceRequestData = '[Input Parameters : pageURL='+objKog.PageURL__c+', ApplicationName='+objKog.ApplicationName__c+', Role='+objKog.Role__c+']';
        try{
            contextId = gatewayKOGService.SaveAddRoleParametersEx(pageURL,appName,role,false);
        }
        catch(Exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= 'Callout to Gateway Service is Failed', Source__c ='RE_KOGRegistration', 
                                              Message__c =  ex.getMessage() ,SourceFunction__c = 'getKogContextID',
                                              EndPoint__c = objKog.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                              Integration_Payload__c = strGateWayServiceRequestData,InterfaceName__c = 'Gateway Service',ResponseData__c = contextId));
            if(publishEvents.size()>0){
                EventBus.publish(publishEvents);
            }  
        }
        return contextId;
    }
}