public class RulesEngine {
	@AuraEnabled
    public static List<String> getRRTriggerRules(List<String> selectedValues){
        
                
        Set<string> affectedScreens = new Set<String>();
        Set<String> objectSet = new Set<String>();
        Set<String> fieldSet = new Set<String>();          
        Map<String, SObject> mapObjValues = new Map<String, SObject>();
        
        for(string str : selectedValues){
            
            str = str.removeStart('{');
            str = str.removeEnd('}');
            
            
            Object objectValue;
            
            List<String> strArr = str.split(',');
            sObject obj = Schema.getGlobalDescribe().get(str.split(',')[0]).newSObject();  
            Schema.SObjectType objSchema = Schema.getGlobalDescribe().get(str.split(',')[0]);
			Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
			for (String fieldName: fieldMap.keySet()) {                
                if((str.split(',')[1] != '' || str.split(',')[1] != null) && str.split(',')[1] == fieldName){                    
                    Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                    if(fielddataType == Schema.DisplayType.Date) { 
                        if(str.split(',')[2] != '')
                        objectValue = Date.valueOf(str.split(',')[2]);
                    }
                    if(fielddataType == Schema.DisplayType.String) { 
                        
                        if(str.split(',')[2] != '' && str.split(',')[2] != null)
                        objectValue = String.valueOf(str.split(',')[2]);
                    }
                    if(fielddataType == Schema.DisplayType.Boolean) { 
                        
                        if(strArr.size() > 2)
                        objectValue = Boolean.valueOf(str.split(',')[2]);
                    }
                }
            }
            if((str.split(',')[1] != '' || str.split(',')[1] != null) && str.split(',')[1] != 'Id'){
			obj.put(str.split(',')[1],objectValue);
            
			mapObjValues.put(str.split(',')[0] + '-' +str.split(',')[1], obj);
            
            objectSet.add(str.split(',')[0]);
            fieldSet.add(str.split(',')[1]);  
            }
        }
        
        Set<String> setRules = new Set<String>();
        List<ReviewRequiredTriggerRules__mdt> lstMetadata = [SELECT Id, Object__c, Field__c, RuleName__c,IsActive__c,
                   											ReviewRequiredScreens__c,Message__c, ReviewRequiredScreens__r.PageInfo__r.PageName__c 
                                                            FROM ReviewRequiredTriggerRules__mdt
                   											WHERE Object__c IN :objectSet AND Field__c IN :fieldSet AND IsActive__c = true];
        for(ReviewRequiredTriggerRules__mdt data : lstMetadata){
            setRules.add(data.Id);
        }
        
        List<String> flowPages = new List<String>();
        Map<String, List<String>> mapScreens = new Map<String, List<String>>();
        for(Review_Required_Screens__mdt screen : [Select Navigation_Flow_Page_Configuration__c, Review_Required_Trigger_Rules__c 
                                                   from Review_Required_Screens__mdt where Review_Required_Trigger_Rules__c IN :setRules])
        {
            if(mapScreens.containsKey(screen.Review_Required_Trigger_Rules__c)){
                List<String> lstNavFlowPage = mapScreens.get(screen.Review_Required_Trigger_Rules__c);
                lstNavFlowPage.add(screen.Navigation_Flow_Page_Configuration__c);
                flowPages.add(screen.Navigation_Flow_Page_Configuration__c);
                mapScreens.put(screen.Review_Required_Trigger_Rules__c,lstNavFlowPage);  
            }
            else{
                List<String> lstNavFlowPage = new List<String>();
                lstNavFlowPage.add(screen.Navigation_Flow_Page_Configuration__c);
           		mapScreens.put(screen.Review_Required_Trigger_Rules__c,lstNavFlowPage);  
                flowPages.add(screen.Navigation_Flow_Page_Configuration__c);
            }
		}
        
       Map<String, NavFlowPageConfig__mdt> mapNavFlowPageConfig = new Map<String, NavFlowPageConfig__mdt>();
       for(NavFlowPageConfig__mdt page : [Select Id,PageInfo__r.PageName__c 
                                          from NavFlowPageConfig__mdt where Id IN :flowPages])
        {
            mapNavFlowPageConfig.put(page.Id, page);
		}
        
        
        /*for(ReviewRequiredTriggerRules__mdt rule : lstMetadata){
            Boolean isTriggerField = RulesEngineHelper.invokeRule(rule.RuleName__c, mapObjValues.get(rule.TriggeringApplicationSectionId__c));
            if(isTriggerField){
                for(String str : mapScreens.get(rule.Id)){
                    affectedScreens.add(mapNavFlowPageConfig.get(str).PageInfo__r.PageName__c); 
                }
                //affectedScreens.add(rule.ReviewRequiredScreens__r.PageInfo__r.PageName__c); 
            }
               
        }*/
        Map<String, SObject> mapRuleObject = new Map<String, SObject>(); 
        Map<String, Id> mapRuleId = new Map<String, Id>(); 
        for(ReviewRequiredTriggerRules__mdt rule : lstMetadata){
            mapRuleId.put(rule.RuleName__c, rule.Id);
            mapRuleObject.put(rule.RuleName__c, mapObjValues.get(rule.Object__c + '-' + rule.Field__c));
        }
        
        Map<String, Boolean> mapRuleResult = RulesEngineController.invokeRule(mapRuleObject);
        for(String rule : mapRuleResult.keySet()){
            if(mapRuleResult.get(rule)){
                for(String str : mapScreens.get(mapRuleId.get(rule))){
                    affectedScreens.add(mapNavFlowPageConfig.get(str).PageInfo__r.PageName__c); 
                }
            }                
        }
        
        List<String> lstAffectedScreens = new List<String>();
        for(String screen : affectedScreens)
            lstAffectedScreens.add(screen);
        
        return lstAffectedScreens;
    }        
}