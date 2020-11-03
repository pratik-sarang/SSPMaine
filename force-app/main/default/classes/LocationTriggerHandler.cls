/**
* Class Name    : LocationTriggerHandler
* Owner         : DELOITTE
* Created Date  : 07/25/2019
* Description   : Handler class for LocationTrigger
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/10/2019  Lagan Kankane   Initial Version
*********************************************************************
* 	
**/

public with sharing class LocationTriggerHandler extends TriggerHandler {
    public LocationTriggerHandler() {
        this.setMaxLoopCount(5);//recursive handling
    }
    
/********************************************************************************************
* @author       Lagan Kankane
* @date         07/24/2019
* @methodname   UpdateLocations
* @description  This methods updates all other Locations of an account to LocationType__c to 'Non Headquarters' and set the isPrimary__c field to flase
                if one location of that account is made primary and 'Headquarters'
********************************************************************************************/
    
    public void  UpdateLocations() {
        try{
        Set<ID> lstAccountIds = new Set<ID>();
        Set<ID> lstLocations = new Set<ID>();
        for(Location__c objLocation : (List<Location__c>) Trigger.new){
            //if(objLocation.isPrimary__c == true && objLocation.LocationType__c == 'Headquarters'){
               // if(objLocation.LocationType__c == 'Headquarters'){
                     if(objLocation.LocationType__c == RE_GlobalConstants.sLocationTypeHead){
                lstAccountIds.add(objLocation.Account__c);
                lstLocations.add(objLocation.Id);
            }
        }
        
        List<Location__c> lstLocationsToBeUpdated = new List<Location__c>();
        if(!lstLocations.isEmpty()){
            //
             List<Location__c> lstLocationsNew = new List<Location__c>();    
             String sQuery;
        Map<String, String> mapQueryParameters = new Map<String, String>();
             mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, RE_DataBaseQueryFields.sOrderByForReferralTest);
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWhereFieldsForLocationTrigger);
            
            //Map<Boolean, String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Location__c', 'Id, Name', mapQueryParameters);
            Map<Boolean, String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Location__c', RE_DatabaseQueryFields.sQueryFieldsForLocationTrigger, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapLocationQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                                                                                         
            switch on (switchCaseKey) {
                
                when SWITCH_SUCCESS {
                    sQuery =  mapLocationQueryResponse.get(true);
                    lstLocationsNew = Database.query(sQuery); 
                }
                
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'LocationTriggerHandler', 'UpdateLocations','Some Fields doesn\'t have the required access :: '+mapLocationQueryResponse.get(false), true);
                }
            }
            
            //
            
            //for(Location__c itrLocation:[SELECT isPrimary__c,LocationType__c,Account__c from Location__c
               /*for(Location__c itrLocation:[SELECT LocationType__c,Account__c from Location__c                           
                                         where  Id not in : lstLocations and Account__c in : lstAccountIds ])*/
            for(Location__c itrLocation: lstLocationsNew)
            {
               // itrLocation.isPrimary__c = false;
                //itrLocation.LocationType__c = 'Non Headquarters';
                 itrLocation.LocationType__c = RE_GlobalConstants.sLocationTypeNonHead;
                lstLocationsToBeUpdated.add(itrLocation);
            }
            if(!lstLocationsToBeUpdated.isEmpty()){
                RE_DataAccessChecker.updateSetUpObjects(Location__c.getSObjectType(),lstLocationsToBeUpdated);
                // update lstLocationsToBeUpdated;
            }
            
        } 
        
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'LocationTriggerHandler', 'UpdateLocations', e.getMessage(), true);
        }
    }
}