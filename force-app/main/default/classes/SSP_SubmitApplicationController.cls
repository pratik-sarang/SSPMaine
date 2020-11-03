public without sharing class SSP_SubmitApplicationController {
    
    public static final String SSP_DC_CALL_NAME = 'SSP_DC';
    @AuraEnabled 
    public static SSP_LightningResponse fetchApplicationStatus(Id sspApplicationId){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        
        SSP_LightningResponse response = new SSP_LightningResponse();
        String status = 'Failure';
        try{
            if(Schema.sObjectType.SSP_Application__c.isAccessible()){  //Iron Dome - isAccessible Fix
                List<SSP_Application__c> sspAppList = [SELECT Id, DCCaseNumber__c FROM SSP_Application__c WHERE Id  = :sspApplicationId LIMIT 1];
                if(sspAppList != null && !sspAppList.isEmpty() && sspAppList[0].DCCaseNumber__c != null){
                    status = 'Success';
                }                                                                   
                response.put('status', status);
            }
        }
        catch(Exception ex){
            response.put('ERROR', ex.getStackTraceString());
        }
        return response;
    }

    @AuraEnabled
    public static SSP_LightningResponse invokeSSP_DC(Id applicationId){  
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix      
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            if(applicationId != null){
                Map<String, Object> requestMap = new Map<String, Object>();
                String screenListOne = System.Label.SSP_DC_Screens_One != 'NA' ? System.Label.SSP_DC_Screens_One : '' ;
                String screenListTwo = System.Label.SSP_DC_Screens_Two != 'NA' ? ','+System.Label.SSP_DC_Screens_Two : '' ;
                String screenListThree = System.Label.SSP_DC_Screens_Three != 'NA' ? ','+System.Label.SSP_DC_Screens_Three : '' ;
                String screenListFour = System.Label.SSP_DC_Screens_Four != 'NA' ? ','+System.Label.SSP_DC_Screens_Four : '' ;
                String screenNamesStr = screenListOne + screenListTwo + screenListThree +screenListFour;
                
                if(screenNamesStr != null){
                    List<String> applicableScreenList = screenNamesStr.split(',');
                    requestMap.put(SSP_InterfaceConstants.SCREEN_LIST, applicableScreenList);
                    requestMap.put(SSP_InterfaceConstants.APPLICATION_ID, applicationId);
                    requestMap.put(SSP_InterfaceConstants.SUBMIT_TYPE,SSP_InterfaceConstants.MODE_INTAKE);  
                    
                    response.put('request', JSON.serialize(requestMap));
                    List<Object> responseList = IntegrationFactory.invokeCallout('SSP_DC', requestMap);               
                    if(responseList != null){
                        response.put('response', ((HttpResponse)responseList[0]).getBody());                
                    }
                }
                else{
                    response.put('ERROR', ' Screen List is Empty');                
                }
            }
        }
        catch(Exception ex){
            
            response.put('ERROR', ex.getStackTraceString());
        }
        return response;
    }
}