/**
* Class Name    : RE_ServiceHandler
* Owner         : DELOITTE
* Created Date  : 04/06/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  04/06/2019  SRIKANTH       Initial Version
*  
**/

public with sharing class RE_ServiceHandler {
    
    @AuraEnabled
    public static Map<String, Object> handleExecutionResults(String sClassImpl, Map<String, Object> mapInputData) {
        // this will instantiate interface object with instance of Project specific implementation handler   
        RE_ServiceInterface service  = (RE_ServiceInterface) RE_ServiceUtility.getServiceImplementationHandler(sClassImpl);         
        Map<String, Object> mapOutput = new Map<String, Object>();
        mapOutput = service.execute(mapInputData);
       
        return mapOutput;
    }
}