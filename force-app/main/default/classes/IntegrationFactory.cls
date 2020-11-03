/**
* Class Name    : IntegrationFactory 
* Owner         : DELOITTE
* Created Date  : 11/12/2019
* Description   : single point of entry for all webservice callouts.
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          Description                                                         
*  ----------  --------------     ------------------------------------------------------------------
*  11-Dec-2019  Abdulrehman        Initial Version
*  
**/

public with sharing class IntegrationFactory {
    public static List<Object> invokeCallout(string interfaceName, Map<String, Object> mapInputParams){
        List<object> objectList; 
        try{
            //Instantiate the class with the interface object reference
            Map<String, SObject> mdtMap = new SSP_CustomMetadataAccessor().getAllRecordsMap(SSP_InterfaceConstants.SSP_INTERFACE_DETAIL_MD);
            
            Type serviceClassType;
            if(!mdtMap.isEmpty() && mdtMap.get(interfaceName)!=null){
                serviceClassType = type.forName((String)mdtMap.get(interfaceName).get(SSP_InterfaceConstants.SSP_SERVICE_CLASSNAME_OBJ));
                if(mdtMap.get(interfaceName).get('Is_debug__c') != null) {
                    mapInputParams.put(SSP_InterfaceConstants.IS_DEBUG, mdtMap.get(interfaceName).get('Is_debug__c'));
                }
            }
            if(serviceClassType==null){
                throw new CustomException(CustomException.EXCEPTION_TYP.SYS, SSP_InterfaceConstants.SSP_NOT_A_VALID_INTERFACE); 
            }
            //SSP_IIntegrationService service = (SSP_IIntegrationService)serviceClassType.newInstance();
            IIntegrationService service = (IIntegrationService)serviceClassType.newInstance();
            
            //invoke the method of service class
            objectList = service.invokeCallout(interfaceName, mapInputParams);
         }
        catch(Exception e){
        }
        return objectList;
    }
}