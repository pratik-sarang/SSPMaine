/**************************************************************************************************
* Class Name    : RE_ResourceCategoryCtrl 
* Owner         : Nupoor Nimbalkar
* Created Date  : 07/01/2019
* Description   : Controller for Resource Category component in landing page
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  
**/
public with sharing class RE_ResourceCategoryCtrl {
    @AuraEnabled(cacheable=true)
    public static RE_CreateLightningServerResponse getResourceCategories(Boolean showByCategory){
        Boolean bSuccess = false;        
        Map<String, Object> errorMap    = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
            
        Set<String> setDomains = new Set<String>(); //set of Domains              
        Map<String,List<RE_Config__c>> mapConfigMasterRecords = new Map<String,List<RE_Config__c>>(); //map of DomainCategory to Config record
        Map<String, Map<String, List<PicklistWrapper>>> mapDomainCategories = new Map<String, Map<String, List<PicklistWrapper>>>();        
        Map<String, Map<String, List<PicklistWrapper>>> mapSortedDomainCategories = new Map<String, Map<String, List<PicklistWrapper>>>();  
        Map<String,String> mapCategoryValues=new Map<String,String>();      
        String domainConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('DomainConfig').getRecordTypeId();
        
        try{
            List<RE_Config__c> lstConfig = new List<RE_Config__c>();
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sFieldsToQueryOnConfig = RE_DataBaseQueryFields.sFieldsToQueryOnConfig;
            String sFieldsToQueryOnConfigLabel = RE_DataBaseQueryFields.sFieldsToQueryOnConfigLabel;
            String sWhereClauseForConfig = RE_DataBaseQueryFields.sWhereClauseForConfig;
            String sOrderByClauseForConfig = RE_DataBaseQueryFields.sOrderByClauseForConfig;
            String sQuery;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForConfig);
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderByClauseForConfig);
            Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strConfigObjectName,sFieldsToQueryOnConfig,mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseReferral.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strConfigObjectName, RE_DataBaseQueryFields.sFieldsToQueryOnConfigLabel, mapQueryParameters);                    
                
                    lstConfig = Database.query(sQuery);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ResourceCategoryCtrl.class.getName(), 'getResourceCategories', RE_GlobalConstants.FLS_ERROR + '' + mapResponseReferral.get(false), true);
                }
            }
            //Create map of Domain Categories and its related Domain
            /*for(RE_Config__c config : [SELECT Id, DomainCategory__c, toLabel(DomainCategory__c) domainCategory, DomainOrder__c, 
                                       Domain__c, toLabel(Domain__c) domainName, IsMaster__c, DomainImage__c 
                                       FROM RE_Config__c 
                                       WHERE IsMaster__c = true AND RecordTypeId = :domainConfigRecId
                                       ORDER BY DomainCategory__c,DomainOrder__c])  */
            for(RE_Config__c config : lstConfig)
            {
                List<RE_Config__c> lstConfigRecords = new List<RE_Config__c>();
                setDomains.add(config.Domain__c);
                if(mapConfigMasterRecords.containsKey((String)config.get('domainCategory'))){                 
                    lstConfigRecords = mapConfigMasterRecords.get((String)config.get('domainCategory'));
                    lstConfigRecords.add(config);
                    mapConfigMasterRecords.put((String)config.get('domainCategory'), lstConfigRecords);
                }
                else{
                    lstConfigRecords.add(config);
                    mapConfigMasterRecords.put((String)config.get('domainCategory'), lstConfigRecords);
                }
            }        
            
            //Creating map of Domain and its categories and sub categories 
            List<RE_Config__c> lstDomainConfig = new List<RE_Config__c>();
            Map<String,String> mapDomainQueryParameters = new Map<String,String>();
            String sFieldsToQueryOnDomainConfig = RE_DataBaseQueryFields.sFieldsToQueryOnDomainConfig;
            String sFieldsToQueryOnDomainConfigLabel = RE_DataBaseQueryFields.sFieldsToQueryOnDomainConfigLabel;
            String sWhereClauseForDomainConfig;
            if(showByCategory)
            	sWhereClauseForDomainConfig = RE_DataBaseQueryFields.sWhereClauseForDomainConfig;  
            else
                sWhereClauseForDomainConfig = RE_DataBaseQueryFields.sWhereClauseForConfigLandingPage;
            String sDomainQuery;
            mapDomainQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForDomainConfig);            
            Map<Boolean,String> mapResponseConfig = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strConfigObjectName,sFieldsToQueryOnDomainConfig,mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchDomainCaseKey = (mapResponseConfig.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchDomainCaseKey) {
                when SWITCH_SUCCESS {
                    sDomainQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strConfigObjectName, RE_DataBaseQueryFields.sFieldsToQueryOnDomainConfigLabel, mapDomainQueryParameters);                    
                
                    lstDomainConfig = Database.query(sDomainQuery);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ResourceCategoryCtrl.class.getName(), 'getResourceCategories', RE_GlobalConstants.FLS_ERROR + '' + mapResponseConfig.get(false), true);
                }
            }              
            /*for(RE_Config__c config : [SELECT Id, Domain__c, toLabel(Domain__c) domainName, Category__c, 
                                       toLabel(Category__c) categoryName, Subcategory__c, toLabel(Subcategory__c) subcategoryName
                                       FROM RE_Config__c 
                                       WHERE RecordTypeId = :domainConfigRecId AND Domain__c IN :setDomains AND 
                                       Category__c!=null AND Subcategory__c!=null 
                                      ]) */
            for(RE_Config__c config : lstDomainConfig)
            {
                Map<String, List<PicklistWrapper>> mapCategorySubCategories = new Map<String, List<PicklistWrapper>>();
                List<PicklistWrapper> lstSubCategories = new List<PicklistWrapper>(); 
                
                if(mapDomainCategories.containsKey(config.Domain__c)){                
                    mapCategorySubCategories = mapDomainCategories.get(config.Domain__c);   
                    if(mapCategorySubCategories.get((String)config.get('categoryName')) != null)
                        lstSubCategories = mapCategorySubCategories.get((String)config.get('categoryName'));
                    
                    PicklistWrapper wrapper = new PicklistWrapper();
                    wrapper.picklistLabel = (String)config.get('subcategoryName');
                    wrapper.picklistValue = config.Subcategory__c;
                    
                    lstSubCategories.add(wrapper);
                    
                    mapCategorySubCategories.put((String)config.get('categoryName'), lstSubCategories);
                    mapCategoryValues.put((String)config.get('categoryName'),config.Category__c);              
                    mapDomainCategories.put(config.Domain__c, mapCategorySubCategories);
                }
                else{  
                    PicklistWrapper wrapper = new PicklistWrapper();
                    wrapper.picklistLabel = (String)config.get('subcategoryName');
                    wrapper.picklistValue = config.Subcategory__c;
                    lstSubCategories.add(wrapper);
                    
                    mapCategorySubCategories.put((String)config.get('categoryName'), lstSubCategories);
                    mapCategoryValues.put((String)config.get('categoryName'),config.Category__c);
                    mapDomainCategories.put(config.Domain__c, mapCategorySubCategories);                
                }            
            }  
            
            //sorting categories and sub categories
            for(String domain : mapDomainCategories.keyset()){
                Map<String, List<PicklistWrapper>> mapCategorySubCategories = new Map<String, List<PicklistWrapper>>();
                Map<String, List<PicklistWrapper>> mapSortedCategorySubCategories = new Map<String, List<PicklistWrapper>>();
                List<String> lstCategories = new List<String>();
                
                mapCategorySubCategories = mapDomainCategories.get(domain);            
                lstCategories.addAll(mapCategorySubCategories.keyset());
                lstCategories.sort();
                for(String category : lstCategories){
                    mapSortedCategorySubCategories.put(category, mapCategorySubCategories.get(category));
                }
                mapSortedDomainCategories.put(domain, mapSortedCategorySubCategories);
            }
            
            bSuccess = true;
            mapResponse.put('mapConfigMasterRecords', mapConfigMasterRecords);
            mapResponse.put('mapDomainCategories', mapSortedDomainCategories);
            mapResponse.put('mapCatCategories', mapCategoryValues);
        }
        catch(Exception e){
            errorMap.put('error', e.getMessage()); 
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ResourcePackagesCtrl.class.getName(), 'getResourcePackages', e.getMessage(), true);
        }
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }  
    
    public class PicklistWrapper{
        @AuraEnabled
        public String picklistLabel;
        @AuraEnabled
        public String picklistValue;        
    }

}