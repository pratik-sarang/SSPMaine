/**
* Helper class to read Navigation Flow Configurations from <b>NavFlowDetail__mdt</b> object.
*
* @author Rahman A
* @date 08/28/2014
*
* @see NavFlowConfig
*/
public with sharing class NavFlowHelper {
    
    
    /**
* Reads the workflow based configuration for the given workflow name and returns NavFlowConfig object.
*
* @param ctx Context object.
* @param flowName String Flow name.
*
* @return NavFlowConfig.
*/  public static NavFlowStatus__c navStausExisting;
    //Shikha: adding extra argument to know the screens selected in RAC
    //Shikha: added a new column Community URL to navigate when application has to be resumed
    public static NavFlowDetail__mdt getNavFlowDetail(Context ctx, String flowName, List<String> SelectedScreen){
              
        NavFlowDetail__mdt navFlowObj = new NavFlowDetail__mdt();
        /* if(flowName == 'RAC' && SelectedScreen != null && !SelectedScreen.isEmpty()){

            //Shikha: added Method to Check NavRule 
            
            //SelectedPages.addAll(SelectedScreen);
            List<String> RuleScreenList = RACCheckRule.CheckRule();
            if(!RuleScreenList.isEmpty()){            
            SelectedScreen.addAll(RuleScreenList);
            }
            Set<String> SelectedPages = new Set<String>(SelectedScreen);


            navFlowObj = [ SELECT Id, FlowDisplayName__c, FlowName__c, NextActionGoToPage__c, 
            (SELECT Id, ListenerPageNames__c, NavigationFlowDetail__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, PageDisplayName__c,
            PageInfo__r.PageName__c, PageInfo__r.PageDisplayName__c, PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c
            FROM Navigation_Flow_Page_Configuration__r
            WHERE IsActive__c = TRUE AND PageInfo__r.PageName__c IN :SelectedPages                             	
            order by SequenceNumber__c)
            FROM NavFlowDetail__mdt
            WHERE FlowName__c =: flowName];
            }
            else{*/

         navFlowObj = [ SELECT Id, FlowDisplayName__c, FlowName__c, NextActionGoToPage__c, Community_Page_URL__c,
                      (SELECT Id, ListenerPageNames__c, NavigationFlowDetail__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                       PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c
                       FROM Navigation_Flow_Page_Configuration__r
                       WHERE IsActive__c = TRUE 
                       order by SequenceNumber__c)
                      FROM NavFlowDetail__mdt
                      WHERE FlowName__c =: flowName];	
        //}

        return navFlowObj;
    }
    
    public static PageInfo__mdt getPageInfo(Context ctx, String pageInfoId) {
        return [SELECT Id, LightningComponentName__c, toLabel(Page_Display_Name_View__c), PageName__c, URL__c FROM PageInfo__mdt WHERE Id =: pageInfoId];
    }
    
    public static NavFlowStatus__c getNavFlowStatus(Context ctx, String navFlowStatusId) {
        return String.isBlank(navFlowStatusId) ? null : [SELECT Id, Name, Contact__c, FlowPageStatus__c, NavFlowName__c, RecordId__c, SSPApplication__c, InitiatedUser__c , Community_Page_URL__c,
                                                         Member__c, FlowDupStatus__c,Screen_Status__c, FlowCompleteStatus__c, IsEdit__c, FlowDupStatusCopy__c, FlowPageStatusCopy__c //#379955
                                                         FROM NavFlowStatus__c 
                                                         WHERE Id =: navFlowStatusId];
                                                             }
    
    //Shikha: Added New Method to fetch existin NavFlowStatus
    public static NavFlowStatus__c getNavFlowStausExisting(Context ctx, ContextData ctxData){
        if(navStausExisting == null ){
	        List<NavFlowStatus__c> existedNavFlowRecord = new List<NavFlowStatus__c>();
	        if(ctxData.recordId != Null){
	            existedNavFlowRecord =[SELECT Id, Name, Contact__c, FlowPageStatus__c, NavFlowName__c, RecordId__c,Screen_Status__c,
	                                   SSPApplication__c, InitiatedUser__c, Community_Page_URL__c, Member__c, FlowDupStatus__c, FlowCompleteStatus__c 
	                                   FROM NavFlowStatus__c 
	                                   WHERE NavFlowName__c = :ctxData.flowName
	                                   //AND InitiatedUser__c=:UserInfo.getUserId()
	                                   //AND Contact__c=:ctxData.contactId 
	                                   //AND RecordId__c = :ctxData.recordId 
	                                   AND SSPApplication__c =:ctxData.ApplicationId
	                                   AND Member__c =:ctxData.MemberId
	                                   ORDER BY CreatedDate ASC];
	        }
	        if(!existedNavFlowRecord.isEmpty()){
	            NavFlowStatus__c flowStatusObj = new NavFlowStatus__c(); 
	            List<NavFlowStatus__c> flowStatSet = new List<NavFlowStatus__c>();                       
	                flowStatusObj = existedNavFlowRecord[0];
	                for(integer i=1; i < existedNavFlowRecord.size(); i++){                    
	                    flowStatSet.add(existedNavFlowRecord[i]);
	                }
	            if(!flowStatSet.isEmpty() && Schema.sObjectType.NavFlowStatus__c.isDeletable()){
	             	delete flowStatSet;               
	            }                	
	                navStausExisting =  flowStatusObj;
	        }
        }
        return navStausExisting;
    }
    
    // this method can be useful when navigation flow status is not known but want to start latest flow using contact and flow name.
    public static NavFlowStatus__c getNavFlowStatus(Context ctx, String contactId, String flowName) {
        NavFlowStatus__c[] statuses = [SELECT Id, Name, Contact__c, Contact__r.Name,FlowPageStatus__c, NavFlowName__c, RecordId__c, InitiatedUser__c, Community_Page_URL__c,
                                       SSPApplication__c,Member__c,Screen_Status__c, FlowCompleteStatus__c, FlowDupStatus__c, FlowDupStatusCopy__c, FlowPageStatusCopy__c //#379955
                                       FROM NavFlowStatus__c 
                                       WHERE Contact__c =: contactId AND NavFlowName__c =: flowName ORDER BY LastModifiedDate DESC];
        return ((null == statuses || statuses.size() < 1)  ? null : statuses[0]);
    }
    
    public static NavFlowStatus__c storeNavFlowStatus(Context ctx, NavFlowStatus__c navFlowStatus, ContextData ctxData) {
        // Added by Durga Prasad and we need to change


        //Need to change the contact Id to record Id in where parameter
        //Shikha: added to check if record exists
        List<NavFlowStatus__c> lstofExistedNavFlowRecords  =[SELECT Id, Contact__c, FlowPageStatus__c, NavFlowName__c, RecordId__c, 
                                                             SSPApplication__c, InitiatedUser__c , Community_Page_URL__c, Member__c,Screen_Status__c
                                                             FROM NavFlowStatus__c WHERE NavFlowName__c = :navFlowStatus.NavFlowName__c                                                             
                                                             AND RecordId__c = :ctxData.recordId 
                                                             AND SSPApplication__c = :ctxData.ApplicationId
                                                             AND Member__c =:ctxData.MemberId
                                                             ORDER BY CreatedDate DESC LIMIT 1];
        //&& ctxData.flowName != 'ReportAchange'
        if(!lstofExistedNavFlowRecords.isEmpty()){
            
            navFlowStatus.id=lstofExistedNavFlowRecords[0].id;
        }
        
        UPSERT navFlowStatus;
        //NavFlowManager.isUpserted = true;
        return navFlowStatus;
    }
    
    public static NavFlowStatus__c storeNavFlowRACStatus(Context ctx, ContextData ctxData, NavFlowStatus__c navFlowStatus){
        
        List<NavFlowStatus__c> navFlowList = [SELECT Id FROM NavFlowStatus__c 
                                              WHERE SSPApplication__c =: ctxData.ApplicationId
                                              AND NavFlowName__c =:ctxData.flowName
                                              AND Member__c =: ctxData.MemberId];
        if(!navFlowList.isEmpty() && navFlowList.size()>1 && Schema.sObjectType.NavFlowStatus__c.isDeletable()){
            delete navFlowList;
        }
        else{
            navFlowStatus = !navFlowList.isEmpty() ? navFlowList[0] : navFlowStatus;
        }
        if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
        	upsert navFlowStatus;   
        }        
        //NavFlowManager.isUpserted = true;
        return navFlowStatus;
    }
    
    public static NavFlowRule__mdt getNavFlowRule(Context ctx, String ruleId) {        
        NavFlowRule__mdt ruleMetadata = new NavFlowRule__mdt ();
        if(Schema.sObjectType.NavFlowRule__mdt.isAccessible()){
            ruleMetadata = [SELECT RuleApexClassName__c, RuleLogic__c, RuleName__c FROM NavFlowRule__mdt WHERE Id = : ruleId];
        }        
        return ruleMetadata;

    }
    //Manjunath
    public static NavFlowPageConfig__mdt getnavpageconfig (Context ctx, ContextData ctxData){
        
        set<string> setGroups = new set<string>();
        NavFlowPageConfig__mdt navFlowConfigList = new NavFlowPageConfig__mdt();
        if(Schema.sObjectType.NavFlowPageConfig__mdt.isAccessible()){      
            for( NavFlowPageConfig__mdt navflow : [select SectionGroupName__c  from NavFlowPageConfig__mdt where id=:ctxData.curNavFlowPageConfigId]){            
                setGroups.add(navflow.SectionGroupName__c);
            }
        }
        if(!setGroups.isEmpty() && Schema.sObjectType.NavFlowPageConfig__mdt.isAccessible()){
           navFlowConfigList = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c FROM NavFlowPageConfig__mdt
                WHERE IsActive__c = TRUE and SectionGroupName__c IN :setGroups order by SequenceNumber__c limit 1];
        }
        return navFlowConfigList;        
    }

    //Shikha: Added to fetch Member Details
    public static SSP_Member__c getMemberDetails(String MemberId){
        return [SELECT Id, FirstName__c, LastName__c from SSP_Member__c
                WHERE Id = :MemberId];
    }

    public static List<NavFlowStatus__c> getNavFlowRACStatus (String memberId, String appId, String flowName){
        List<NavFlowStatus__c> navFlowStatList = [SELECT Id, Name, Contact__c, FlowPageStatus__c, NavFlowName__c, RecordId__c,Screen_Status__c,IsEdit__c,
                                   				  SSPApplication__c, InitiatedUser__c, Community_Page_URL__c, Member__c, FlowDupStatus__c, FlowCompleteStatus__c 
                                   				  FROM NavFlowStatus__c  
                                                  WHERE navFlowName__c = :flowName AND SSPApplication__c =:appId AND
                                                  Member__c = :memberId];
        return navFlowStatList;
    }
        
}