/**
 * Class Name    : SSP_UpdateDCRepIntegrationUtility
 * Owner         : DELOITTE
 * Created Date  : 21/04/2020
 * Description   : This class will hold utility methods that is used in SSP_UpdateDCRepIntegrationService class
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  21/04/2020  Ragunathan          Initial Version
 */
public class SSP_UpdateDCRepIntegrationUtility {

/**
 * method                                   : prepareRequestParam
 * @description                             : Method to prepare the service request.
 * @author                                  : Ragunathan
 * @param mapParams                         : Map of input request parameters
 * @return Map<String, Object>              : Map of prepare list of objects for service request
 */
public static Map<String, Object> prepareRequestParam(Map<String, Object> mapInputParams) {
    Map<String, List<sObject>> objectsMap = new Map<String, List<sObject>>();
    String applicationId    = (String) mapInputParams.get('applicationId');
    String contactId    = (String) mapInputParams.get(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_CONTACT_ID);
    Boolean deleteIndicator = (Boolean) mapInputParams.get(SSP_InterfaceConstants.SSP_UPDATE_DC_DELETE_INDICATOR);
    List<SSP_Application__c> applications = new List<SSP_Application__c>();
    applications = SSP_SharingBypassFetcher.getSSPApplicationForUpdateDCRep(applicationId);        
    objectsMap.put('SSP_Application__c', applications);
    List<AccountContactRelation> acrs;
    if(mapInputParams.get('acr') != null) {
        List<AccountContactRelation> acrelations = new List<AccountContactRelation> {(AccountContactRelation) mapInputParams.get('acr')};
        if(!acrelations.IsEmpty() && acrelations[0].ContactId == null) {
            Map<String, Object> acrObjMap = (Map<String, Object>)JSON.deserializeUntyped(
                                            JSON.serialize(mapInputParams.get('acr'))
                                        );
            acrObjMap.put('ContactId', contactId);
            acrs = new List<AccountContactRelation> {(AccountContactRelation)JSON.deserialize(
                JSON.serialize(acrObjMap),
                AccountContactRelation.Class
            )};
        } else {
            acrs = new List<AccountContactRelation> {(AccountContactRelation) mapInputParams.get('acr')};
        }     
    } else {
        acrs = new List<AccountContactRelation>();
    }
    objectsMap.put('AccountContactRelation', acrs);
    List<Contact> contacts = new List<Contact>();        
    if(!acrs.IsEmpty()) {
       contacts = SSP_SharingBypassFetcher.getContactsForUpdateDCRep(contactId);            
    }
    objectsMap.put('Contact', contacts);
    List<SSP_TrackDeletion__c> trackDeletions = new List<SSP_TrackDeletion__c> { 
                                        (SSP_TrackDeletion__c) mapInputParams.get(SSP_InterfaceConstants.SSP_UPDATE_DC_TrackDeletion) 
                                        };
    objectsMap.put('SSP_TrackDeletion__c', trackDeletions); 
    
    return removeAttribute (objectsMap);
}

/**
 * method                                   : removeAttribute
 * @description                             : Method to remove attributes from sObject that is not required to send.
 * @author                                  : Ragunathan
 * @param mapParams                         : Map of input request parameters
 * @return Map<String, Object>              : Map of prepare list of objects for service request
 */
private static Map<String, Object> removeAttribute(Map<String, List<sObject>> objectsMap) {
    Map<String, List<Map<String, Object>>> mapRemovedAttibute = new Map<String, List<Map<String, Object>>>();
    for(String objName: objectsMap.keySet()) {
        List<Map<String, Object>> objectRemovedAttribute = new List<Map<String, Object>>();
        for(sObject objsObject : objectsMap.get(objName)){
            Map<String,Object> unTypedObject = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objsObject));  
            if(unTypedObject != null){
            if(objName == 'SSP_Application__c' || objName == 'SSP_TrackDeletion__c'){
                unTypedObject.remove('Id');
            }
            if(objName == 'Contact'){
                if(unTypedObject.containsKey('DCDataId__c')) {
                    unTypedObject.remove('DCDataId__c');
                }
            }
            if(objName == 'AccountContactRelation') {
                unTypedObject.remove('SuffixCode__c');
                unTypedObject.remove('ConsentDate__c');
                unTypedObject.remove('MiddleName__c');
                unTypedObject.remove('FirstName__c');
                unTypedObject.remove('LastName__c');
                if(unTypedObject.get('StartDate') == null) {
                    unTypedObject.remove('StartDate');
                }
                if(unTypedObject.get('DCAgencyId__c') == null) {
                    unTypedObject.remove('DCAgencyId__c');
                }
                if(unTypedObject.get('DCContactId__c') == null) {
                    unTypedObject.remove('DCContactId__c');
                }                    
                if(unTypedObject.containsKey('RequestAccessPermission__c')) {
                    unTypedObject.remove('RequestAccessPermission__c');
                }
            }
            unTypedObject.remove('attributes');  
            }              
            objectRemovedAttribute.add(unTypedObject);
        }
        mapRemovedAttibute.put(objName, objectRemovedAttribute);
    }
    return new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(mapRemovedAttibute)};
}
}