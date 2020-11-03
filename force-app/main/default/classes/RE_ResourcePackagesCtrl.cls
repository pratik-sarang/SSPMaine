/**************************************************************************************************
* Class Name    : RE_ResourcePackagesCtrl 
* Owner         : Nupoor Nimbalkar
* Created Date  : 07/01/2019
* Description   : Controller for Resource Packages component in landing page
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  
**/
public with sharing class RE_ResourcePackagesCtrl {
	@AuraEnabled(cacheable=true)
    public static RE_CreateLightningServerResponse getResourcePackages(){
        Boolean bSuccess = false;        
        Map<String, Object> errorMap    = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
            
        List<ArchetypeWrapper> lstArchetypesWrapper = new List<ArchetypeWrapper>();
		List<RE_Archetype__c> lstArchetypes = new List<RE_Archetype__c>();        
        Id recordTypeId = Schema.SObjectType.RE_Archetype__c.getRecordTypeInfosByDeveloperName().get('Archetype').getRecordTypeId();
        String userLanguage = GeneralUtility.getUserLocale();
        
        try{
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sFieldsToQueryOnArcheType = RE_DataBaseQueryFields.sFieldsToQueryOnArchetypeLP;
            String sWhereClauseForArcheType = RE_DataBaseQueryFields.sWhereClauseOnArchetypeLP;
            String sOrderByClauseForArchetype = RE_DataBaseQueryFields.sOrderByClauseOnArchetypeLP; 
            String sQuery;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForArcheType);
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderByClauseForArchetype);
            Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility('RE_Archetype__c',sFieldsToQueryOnArcheType,mapQueryParameters);
            if(mapResponseReferral.get(true) != null){
                sQuery =  mapResponseReferral.get(true);
                lstArchetypes = Database.query(sQuery); 
                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourcePackagesCtrl','getResourcePackages','***FLS Violation***'+mapResponseReferral.get(false),true);
            } 
        
                         
        
        //Getting the resources per archetype
            Map<String,Integer> mapArchetypeGoals = new Map<String,Integer>();
           
            String sFieldsToQueryOnGoal = RE_DataBaseQueryFields.sFieldsToQueryOnGoal;
            Map<Boolean,String> mapGoalResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strGoalObjectName,sFieldsToQueryOnGoal,null);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapGoalResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    
             
            
	            for(RE_Archetype__c archetype : lstArchetypes){
	                    ArchetypeWrapper wrapper = new ArchetypeWrapper();
	                    wrapper.archetypeObj = archetype;                
	                    lstArchetypesWrapper.add(wrapper);
	            }        
	            mapResponse.put('lstArchetypesWrapper', lstArchetypesWrapper); 
                    
              
                    
                    
	            bSuccess = true;
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ResourcePackagesCtrl.class.getName(), 'getResourcePackages', RE_GlobalConstants.FLS_ERROR + '' + mapGoalResponse.get(false), true);
                }
            }                                
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ResourcePackagesCtrl.class.getName(), 'getResourcePackages', e.getMessage(), true);
        }
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    @AuraEnabled(cacheable=true)
    public static RE_CreateLightningServerResponse getCarouselPackages(){
        Boolean bSuccess = false;        
        Map<String, Object> errorMap    = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
         
        List<RE_Archetype__c> lstArchetypes = new List<RE_Archetype__c>();    
        Id recordTypeId = Schema.SObjectType.RE_Archetype__c.getRecordTypeInfosByDeveloperName().get('Announcement').getRecordTypeId();
        String userLanguage = GeneralUtility.getUserLocale();
        
        try{
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sFieldsToQueryOnArcheType = RE_DataBaseQueryFields.sFieldsToQueryOnArchetypeCarousel;
            String sWhereClauseForArcheType = RE_DataBaseQueryFields.sWhereClauseOnArchetypeCarousel;
            String sOrderByClauseForArchetype = RE_DataBaseQueryFields.sOrderByClauseOnArchetypeLP;
            String sQuery;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForArcheType);
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderByClauseForArchetype);
            Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility('RE_Archetype__c',sFieldsToQueryOnArcheType,mapQueryParameters);
            if(mapResponseReferral.get(true) != null){
                sQuery =  mapResponseReferral.get(true);
                lstArchetypes = Database.query(sQuery); 
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourcePackagesCtrl','getResourcePackages','***FLS Violation***'+mapResponseReferral.get(false),true);
            }
                              
                    
            mapResponse.put('lstArchetypes', lstArchetypes); 
            bSuccess = true;
        }
        catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ResourcePackagesCtrl.class.getName(), 'getResourcePackages', e.getMessage(), true);
        }
                
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /**************************************************************************************
* @author       Kojashree Kakariya
* @date         20/02/20
* @methodname   fetchGuestAssessmentRecords
* @description  This methods is used to fetch Assessment records of Assessment template record types
* @return       RE_CreateLightningServerResponse 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchGuestAssessmentRecords(){
        List<Assessment__c> lstAssessment ;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try{
                    Id assessmentRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sAssessmentObjectName, RE_GlobalConstants.sAssessmentDeveloperName);
                    String assessmentTitle = System.Label.AssessmentTitleForGuest;
                    String sFieldsToQueryonGuestAssessment = RE_DataBaseQueryFields.sFieldsToQueryonGuestAssessment;
                    String sOrderby = RE_DataBaseQueryFields.sOrderByNameAsc;
                    String sWhereClauseOnGuestAssessment = RE_DataBaseQueryFields.sWhereClauseOnGuestAssessment;
                    
                    Map<String,String> mapAssessmentQueryParameters = new Map<String,String>();
                    mapAssessmentQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
                    mapAssessmentQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnGuestAssessment);
                    
                    Map<Boolean,String> mapAssessmentQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sAssessmentObjectName, sFieldsToQueryonGuestAssessment, mapAssessmentQueryParameters);
                   
                    String switchCaseKey = (mapAssessmentQueryResponse.get(true) != null) ? 'success' : 'failure'; 
                    switch on (switchCaseKey) {
                        when 'success' {
                            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sAssessmentObjectName, RE_DataBaseQueryFields.sFieldsToQueryonGuestAssessment, mapAssessmentQueryParameters);
                            
                            lstAssessment = Database.query(sQuery); 
                            bSuccess = true;
                            mapResponse.put('assessmentRecords', lstAssessment);
                        }
                        when 'failure' {
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords','Some Fields doesn\'t have the required access :: '+mapAssessmentQueryResponse.get(false), true);
                        }
                    }
                }catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourcePackagesCtrl','fetchGuestAssessmentRecords', e.getMessage(), true);}
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }  
    
    public class ArchetypeWrapper{
        @AuraEnabled
        public RE_Archetype__c archetypeObj;
        @AuraEnabled
        public Integer resourcesCount;
    }
}