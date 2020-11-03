/**
* Class Name    : SSP_KOGRegistration
* Owner         : DELOITTE
* Created Date  : 11/12/2019
* Description   : Class that will generate the context Id for KOG
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
public with sharing class SSP_KOGRegistration{
    /**
* method        : getKogContextID
* @description  : This method is will generate contextId based on the KOG Webservice settings
* @author       : Kommana Lova Durga Prasad
* */    
    public static String  getKogContextID(string selectedRole){
        tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService  gatewayKOGService=new tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService();
        KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG SSP Citizen');      
        gatewayKOGService.clientCertName_x=objKog.Certificate__c;
        String pageURL = objKog.PageURL__c;
        String appName = objKog.ApplicationName__c;
        String role ;
        if(string.isNotBlank(selectedRole)){
            role = selectedRole;
        }
        else{
            role = objKog.Role__c;
        }
        String SERVICE_URL_EP=objKog.EndURL__c;
        gatewayKOGService.endpoint_x=SERVICE_URL_EP;
        String contextId = gatewayKOGService.SaveAddRoleParametersEx(pageURL,appName,role,false);
        return contextId;
    }    
}