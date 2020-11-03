public class PermissionsOrgCache {
    final static integer TTL=60*60*24;
    
    public Object getScreenPermissions(String role) {        
        string key=role.replace('_', '').replace('&','');
        key = key + 'SP';
        Cache.OrgPartition orgPart=getPartition();
        Map<String, SSP_Utility.SecurityMatrixWrapper> screenPermMap = (Map<String, SSP_Utility.SecurityMatrixWrapper>)orgPart.get(key);        
        if(screenPermMap!=null){
           return screenPermMap;
        }else{
            //SSP_Utility.SecurityMatrixWrapper secmatrx;            
            screenPermMap = new Map<String, SSP_Utility.SecurityMatrixWrapper>();            
            Map<String, Map<String, String>> screenFieldPerm=new Map<String, Map<String, String>>();
            for(FieldPermissions__mdt fieldPermissions : [select FieldElementName__c, Permission__c, Role__c,ScreenName__c from FieldPermissions__mdt where Role__c= :role limit 10000])
            {
                
                system.debug('fieldPermissions####' + JSON.serialize(fieldPermissions));
                Map<String, String> fieldPermissionsMap;
                fieldPermissionsMap=screenFieldPerm.get(fieldPermissions.ScreenName__c);
                if(fieldPermissionsMap==null){
                    fieldPermissionsMap = new Map<String, String>();
                }
                fieldPermissionsMap.put(fieldPermissions.FieldElementName__c,fieldPermissions.Permission__c);
                screenFieldPerm.put(fieldPermissions.ScreenName__c,fieldPermissionsMap);  
              
                
                SSP_Utility.SecurityMatrixWrapper secmatrx= (!screenPermMap.isEmpty() && screenPermMap.containsKey(fieldPermissions.ScreenName__c)) ? screenPermMap.get(fieldPermissions.ScreenName__c) : new SSP_Utility.SecurityMatrixWrapper();
                    
                secmatrx.fieldPermissions= screenFieldPerm.get(fieldPermissions.ScreenName__c);
                screenPermMap.put(fieldPermissions.ScreenName__c, secmatrx);
                
            }
            for(ScreenPermissions__mdt screenPermissions : [select Permission__c, Role__c, ScreenName__c, CanDelete__c from ScreenPermissions__mdt where Role__c= :role limit 10000])
            {
                system.debug('screenPermissions#### '+JSON.serialize(screenPermissions));
                SSP_Utility.SecurityMatrixWrapper secmatrx =  screenPermMap.containsKey(screenPermissions.ScreenName__c) ? screenPermMap.get(screenPermissions.ScreenName__c) : new SSP_Utility.SecurityMatrixWrapper();
                
                secmatrx.screenPermission=screenPermissions.Permission__c;
                secmatrx.canDelete=screenPermissions.CanDelete__c;
                screenPermMap.put(screenPermissions.ScreenName__c,secmatrx);
             }            
            orgPart.put(key,screenPermMap,TTL);             
            return orgPart.get(key); 
        }
    }
    
    private Cache.OrgPartition getPartition() {        
        return Cache.Org.getPartition('local.SSP');        
    }
    
    public Object loadAppSummary()
    {
        String key = 'appSummary';
        Cache.OrgPartition orgPart=getPartition();        
        Map<String,App_Summary_Config__mdt> appConfigMap = (Map<String, App_Summary_Config__mdt>)orgPart.get(key);
        if(appConfigMap != null){
            return appConfigMap;
        }
        else{
            appConfigMap = new Map<String,App_Summary_Config__mdt>();
            List<App_Summary_Config__mdt> rawAppConfiguration = [SELECT DeveloperName, Section_Key__c, Applicable_Program_Code__c, 
                                                                 IsFlow__c, Based_On_Individual__c, Member_Filter__c, FlowName__c, PageName__c, 
                                                                 Section__c, Subsection__c, Order__c 
                                                                 FROM App_Summary_Config__mdt 
                                                                 ORDER BY Order__c LIMIT 5000];
            system.debug('### rawAppConfiguration '+rawAppConfiguration);
            for(App_Summary_Config__mdt config : rawAppConfiguration){
                system.debug('### config '+config);
                system.debug('### config flowName '+config.FlowName__c);
                appConfigMap.put(config.FlowName__c,config);
            }
            system.debug('### appConfigMap '+appConfigMap);
            orgPart.put(key,appConfigMap,TTL);        
            return orgPart.get(key);
        }
    }

    public Object getAppSummaryRecords(){
        String key = 'appSummaryList';
        Cache.OrgPartition orgPart=getPartition(); 
        List<App_Summary_Config__mdt> appSummaryList = (List<App_Summary_Config__mdt>) orgPart.get(key);
        if(appSummaryList != null){
            return appSummaryList;
        }
        else{
            appSummaryList = new List<App_Summary_Config__mdt>();
            appSummaryList = [SELECT DeveloperName, Section_Key__c, Applicable_Program_Code__c, 
                              IsFlow__c, Based_On_Individual__c, Member_Filter__c, FlowName__c, PageName__c, 
                              Section__c, Subsection__c, Order__c 
                              FROM App_Summary_Config__mdt 
                              ORDER BY Order__c LIMIT 5000];
            orgPart.put(key,appSummaryList,TTL);
            return orgPart.get(key);
        }
    }
}