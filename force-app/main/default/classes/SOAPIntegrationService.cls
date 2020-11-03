/*
* Classname 	:  SOAPIntegrationService
* @description 	:  This abstract class is extended by all the SOAP service classes
* @author 		:  Rijia Khatun
* @date 		:  12/7/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/

public abstract class SOAPIntegrationService implements IIntegrationService {
    public static SSP_InterfaceDetail__mdt getCertificateName(String interfaceName){
        Map<String, SObject> mdtMap = new SSP_CustomMetadataAccessor().getAllRecordsMap('SSP_InterfaceDetail__mdt');
        SSP_InterfaceDetail__mdt interfaceDetail;
        if(!mdtMap.isEmpty() && mdtMap.get(interfaceName)!=null){
            interfaceDetail = (SSP_InterfaceDetail__mdt)mdtMap.get(interfaceName);
        }
        return interfaceDetail;
    }
}