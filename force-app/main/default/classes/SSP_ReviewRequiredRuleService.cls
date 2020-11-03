public class SSP_ReviewRequiredRuleService {
    
    public static String contactId = '';
    public static void updateRRStatus (String applicationId, String memberId, String selectedScreen, List<SSP_RulesEngine.ReviewRequiredScreenWrapper> affectedScreens, Map<String,Boolean> mapScreenRuleResult, Set<String> lstMemberIds, String mode,Map<String,Set<String>> screenVslstRuleMap, map<String,Boolean> mapRuleResult){
        if(lstMemberIds.contains('null')){
            lstMemberIds.remove('null'); 
            lstMemberIds.add(null);
        }
        QueuingWrapper queueObject = NavFlowManager.getQueuingFields(applicationId);		                                                         
        
        
        //Shikha: adding memberStatus code 
        Map<String,String> MemberAppStatusMap = new Map<String,String>();  
        if(queueObject.applicationIndividualList != null ){
            for(SSP_ApplicationIndividual__c appIndividual : queueObject.applicationIndividualList){
                MemberAppStatusMap.put(appIndividual.SSP_Member__c , appIndividual.MemberStatus__c);                                            
            }
        }
        
        contactId = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
        new Set<String>{'Id', 'ContactId'}, 
        new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()})[0].contactId;
        Set<String> lstFlowNames = new Set<String>();
        Map<String, Map<String,Set<String>>> mapMemberFlowAffectedScreens = new Map<String, Map<String,Set<String>>>(); 
        
        for(SSP_RulesEngine.ReviewRequiredScreenWrapper wrapper : affectedScreens){
            
            lstFlowNames.add(wrapper.flowName);
            
            for(Integer i = 0; i< wrapper.memberIds.size(); i++){   
                String memberToUse = (wrapper.memberIds[i]!='null')?wrapper.memberIds[i]:null;
                Map<String, Set<String>> tmpMap = (mapMemberFlowAffectedScreens != null && mapMemberFlowAffectedScreens.containsKey(memberToUse)) ?
                    mapMemberFlowAffectedScreens.get(memberToUse) : 
                new Map<String, Set<String>>(); 
                
                Set<String> tmpScreens =  (tmpMap != null && tmpMap.containsKey(wrapper.flowName)) ?
                    tmpMap.get(wrapper.flowName) : 
                new Set<String>();
                
                mapMemberFlowAffectedScreens.put(memberToUse, new Map<String, Set<String>>());
                
                tmpScreens.addAll(wrapper.affectedScreen);
                tmpMap.put(wrapper.flowName, tmpScreens);
                mapMemberFlowAffectedScreens.put(memberToUse, tmpMap);   
            }                     
        }
        
                                        
        //
        
        List<NavFlowPageConfig__mdt> lstNavFlowObj = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__r.FlowName__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                                                      PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c,
                                                      NavFlowRule__r.RuleApexClassName__c 
                                                      FROM NavFlowPageConfig__mdt
                                                      WHERE IsActive__c = TRUE                                  
                                                      AND NavigationFlowDetail__r.FlowName__c IN :lstFlowNames
                                                      order by SequenceNumber__c];  
        
        
        
        //mapFlowPageIntegerMap => store flow vs page vs sequence number
        Map<String, Map<String,Integer>> mapFlowPageIntegerMap = new Map<String, Map<String,Integer>>();
        //Shikha: addedd
        //PageConfigRuleMap => store pageName vs ruleName
        Map<String,String> PageConfigRuleMap = new Map<String,String>();
        Map<String,Set<String>> flowPageSetMap = new Map<String,Set<String>>();                                                 
        
        for(Integer i=0; i<lstNavFlowObj.size(); i++){            
            if(mapFlowPageIntegerMap.containsKey(lstNavFlowObj[i].NavigationFlowDetail__r.FlowName__c)){
                Map<String,Integer> PageIntegerMap = mapFlowPageIntegerMap.get(lstNavFlowObj[i].NavigationFlowDetail__r.FlowName__c);
                PageIntegerMap.put(lstNavFlowObj[i].PageInfo__r.PageName__c, (Integer)(lstNavFlowObj[i].SequenceNumber__c - 1)); 
                mapFlowPageIntegerMap.put(lstNavFlowObj[i].NavigationFlowDetail__r.FlowName__c, PageIntegerMap);
            }
            else{
                Map<String,Integer> PageIntegerMap = new Map<String, Integer>(); 
                PageIntegerMap.put(lstNavFlowObj[i].PageInfo__r.PageName__c, (Integer)(lstNavFlowObj[i].SequenceNumber__c - 1)); 
                mapFlowPageIntegerMap.put(lstNavFlowObj[i].NavigationFlowDetail__r.FlowName__c, PageIntegerMap);
            }
            if(flowPageSetMap.containsKey(lstNavFlowObj[i].NavigationFlowDetail__r.FlowName__c)){
                flowPageSetMap.get(lstNavFlowObj[i].NavigationFlowDetail__r.FlowName__c).add(lstNavFlowObj[i].PageInfo__r.PageName__c);
            }
            else{
                flowPageSetMap.put(lstNavFlowObj[i].NavigationFlowDetail__r.FlowName__c,new Set<String>{lstNavFlowObj[i].PageInfo__r.PageName__c}); 
            }
            PageConfigRuleMap.put(lstNavFlowObj[i].PageInfo__r.PageName__c,lstNavFlowObj[i].NavFlowRule__r.RuleApexClassName__c);
        }
         
                                                                                                                     
        List<NavFlowStatus__c> lstFlowStatus = [Select Id,SSPApplication__c, Member__c, FlowPageStatus__c, NavFlowName__c, Screen_Status__c, FlowDupStatus__c
                                                from NavFlowStatus__c 
                                                where SSPApplication__c = :applicationId and Member__c IN :lstMemberIds                                                
                                                ORDER BY CreatedDate DESC];
                                                                                                                
        //navFlowStatus = initNavFlowReviewRequiredStatus(applicationId, member, flowName,flowPageSetMap);
        //mapMemberFlowStatus => store member vs flowName vs flowstatus
        Map<String, Map<String, NavFlowStatus__c>> mapMemberFlowStatus = new Map<String, Map<String, NavFlowStatus__c>>(); 
        
        for(NavFlowStatus__c flowStatus : lstFlowStatus){
            if(mapMemberFlowStatus.containsKey(flowStatus.Member__c))
            {
                Map<String, NavFlowStatus__c> mapFlowPageStatus = mapMemberFlowStatus.get(flowStatus.Member__c);
                mapFlowPageStatus.put(flowStatus.NavFlowName__c, flowStatus);
                mapMemberFlowStatus.put(flowStatus.Member__c, mapFlowPageStatus);            
            }
            else
            {
                Map<String, NavFlowStatus__c> mapFlowPageStatus = new Map<String,NavFlowStatus__c>();
                mapFlowPageStatus.put(flowStatus.NavFlowName__c, flowStatus);
                mapMemberFlowStatus.put(flowStatus.Member__c, mapFlowPageStatus);
            }            
            //mapFlowPageStatus.put(flowStatus.NavFlowName__c, flowStatus);
        }        
        
        //Shikha added : new 30/4
        List<NavFlowStatus__c> flowStatusCreatedList = new List<NavFlowstatus__c>();    
        if(mode == 'RAC' || mode == 'addRemoveMember'){
            for(String member : mapMemberFlowAffectedScreens.keySet()){
                
                for(String flow : mapMemberFlowAffectedScreens.get(member).keySet()){
                                    
                    if((mapMemberFlowStatus == null || mapMemberFlowStatus.isEMpty()
                        || !mapMemberFlowStatus.containskey(member) || !mapMemberFlowStatus.get(member).containskey(flow)) && member != null && MemberAppStatusMap.containsKey(member) && MemberAppStatusMap.get(member) != 'New') {
                            NavFlowStatus__c flowStatRec = new NavFlowStatus__c();
                            flowStatRec = initNavFlowReviewRequiredStatus(applicationId, member, flow ,flowPageSetMap);
                            flowStatusCreatedList.add(flowStatRec);
                            Map<String,NavFlowStatus__c> memberFlowStatMap = new Map<String,NavFlowStatus__c>();
                            memberFlowStatMap.put(flow,flowStatRec);
                            mapMemberFlowStatus.put(member, memberFlowStatMap);
                        }                      
                }
            }        
            for(String str : lstFlowNames ){
                if(str == 'HouseholdInformation' || str == 'HealthcareCoverage'){
                    NavFlowStatus__c flowStatRec = new NavFlowStatus__c();
                    flowStatRec = initNavFlowReviewRequiredStatus(applicationId, null, str ,flowPageSetMap);
                    flowStatusCreatedList.add(flowStatRec); 
                }
            }
        }                                                   
        //}                                                  
        
                                                                 
        
        for(String member : mapMemberFlowStatus.keyset())
        {
            for(String flowName : mapMemberFlowStatus.get(member).keySet())
            {
                
                
                
                
                NavFlowStatus__c navFlowStatus = mapMemberFlowStatus != null ? mapMemberFlowStatus.get(member) != null ?
                    mapMemberFlowStatus.get(member).get(flowName) != null ?
                    mapMemberFlowStatus.get(member).get(flowName) : null : null : null;
                
                
                
                
                
                
                if(mapMemberFlowAffectedScreens.get(member) != null && 
                   mapMemberFlowAffectedScreens.get(member).get(flowName) != null && navFlowStatus != null)
                {                                         
                    
                    for(String str : mapMemberFlowAffectedScreens.get(member).get(flowName)){
                        Map<String,Integer> PageIntegerMap = mapFlowPageIntegerMap.get(flowName);
                        //
                        //
                        
                        //get the json value
                        
                        Map<String,Object> mapScreenStatus = (Map<String,Object>)JSON.deserializeUntyped(navFlowStatus.Screen_Status__c);
                        
                        Object obj = (Object)mapScreenStatus.get(str);
                        
                        SSP_RulesEngine.ScreenStatus screenStatus = (SSP_RulesEngine.ScreenStatus)JSON.deserialize(JSON.serialize(obj), SSP_RulesEngine.ScreenStatus.class);
                        
                        
                        //Shikha : 
                        String ruleClassName = PageConfigRuleMap.get(str);
                        
                        Boolean queResult = true;
                        if(ruleClassName != null){
                            Type typ = Type.forName(ruleClassName);
                            BasicNavFlowRule nfr = (BasicNavFlowRule)typ.newInstance();
                            Context contextVal = new Context();
                            ContextData data = new ContextData();
                            data.MemberId = member;
                            data.ApplicationId = navFlowStatus.SSPApplication__c;
                            data.modeValue = mode;
                            data.queueObject = queueObject;
                            queResult = nfr.isRequired(contextVal, data);
                            
                        }
                        
                        if(mapScreenRuleResult.get(str)){
                            
                            if(navFlowStatus.FlowDupStatus__c.charAt(PageIntegerMap.get(str)) != 82){
                                screenStatus.isReviewRequired = (mode != 'RAC') ? queResult ? true : false : true;                                
                                if(screenStatus.isReviewRequired){
                                    navFlowStatus.FlowPageStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, PageIntegerMap.get(str), 'R');  
                                    navFlowStatus.FlowDupStatus__c =  CommonUtil.replaceString(navFlowStatus.FlowDupStatus__c, PageIntegerMap.get(str), 'R'); 
                                    screenStatus.Status = 'R';//CommonUtil.replaceString(screenStatus.Status, PageIntegerMap.get(str), 'R');
                                    
                                    
                                    if(screenStatus.reviewReqScreens != null && screenStatus.reviewReqScreens != ''){                                    
                                        List<string> lstReviewNames = screenStatus.reviewReqScreens.split(',');
                                        lstReviewNames.add(selectedScreen);
                                        Set<String> setReviewNames =  new  Set<String>();
                                        if(!lstReviewNames.isEmpty()){
                                            setReviewNames.addAll(lstReviewNames);
                                        }
                                        if(!setReviewNames.isEmpty()){
                                            screenStatus.reviewReqScreens = String.join(new List<String>(setReviewNames),',');
                                        }
                                        /*List<String> revRules = screenStatus.reviewReqScreens.split(',');                                   
Set<String> revSet = !screenVslstRuleMap.isEmpty() ? screenVslstRuleMap.containsKey(str) ?
screenVslstRuleMap.get(str) != null ? screenVslstRuleMap.get(str) : new Set<String>():
new Set<String>() : new Set<String>();                                     
if(!revRules.isEmpty()){
revSet.addAll(revRules);
}
if(!revSet.isEmpty()){
screenStatus.reviewReqScreens = String.join(new List<String>(revSet),',');
} */                                   
                                    }else{
                                        screenStatus.reviewReqScreens =String.ValueOf(selectedScreen); 
                                        /*Set<String> revSet = !screenVslstRuleMap.isEmpty() ? screenVslstRuleMap.containsKey(str) ?
screenVslstRuleMap.get(str) != null ? screenVslstRuleMap.get(str) : new Set<String>():
new Set<String>() : new Set<String>();                                     
screenStatus.reviewReqScreens = String.join(new List<String>(revSet),',');*/
                                    }
                                }
                            }
                        }
                        else{
                            
                            if(screenStatus.isReviewRequired == true || selectedScreen == 'SSP_APP_Select_Health'){
                                
                                /*String ruleClassName = PageConfigRuleMap.get(str);


if(ruleClassName != null){
Type typ = Type.forName(ruleClassName);
BasicNavFlowRule nfr = (BasicNavFlowRule)typ.newInstance();
Context contextVal = new Context();
ContextData data = new ContextData();
data.MemberId = member;
data.ApplicationId = navFlowStatus.SSPApplication__c;
data.queueObject = queueObject;
Boolean result = nfr.isRequired(contextVal, data);

screenStatus.Status = result ? 'C' : 'N';                            	
}*/
                                screenStatus.Status = 'N';
                                if(queResult && mode != 'RAC'){
                                    screenStatus.Status = 'C';    
                                }
                                else if(screenStatus.oldStatus!=null && screenStatus.oldStatus != screenStatus.Status &&
                                        screenStatus.oldStatus != 'R' && selectedScreen != 'SSP_APP_Select_Health')
                                {
                                    screenStatus.Status = screenStatus.oldStatus;                                                                
                                }                            
                                navFlowStatus.FlowPageStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, PageIntegerMap.get(str), screenStatus.Status);
                                navFlowStatus.FlowDupStatus__c = CommonUtil.replaceString(navFlowStatus.FlowDupStatus__c, PageIntegerMap.get(str), screenStatus.Status);                            
                                
                                screenStatus.isReviewRequired = (screenStatus.Status == 'N' || screenStatus.Status == 'C') ? false : true;
                                
                            }  
                        }
                        mapScreenStatus.put(str, screenStatus);
                        
                        navFlowStatus.Screen_Status__c = JSON.serialize(mapScreenStatus);
                        
                    }
                }
                mapMemberFlowStatus.get(member).put(flowName, navFlowStatus);
                //mapFlowPageStatus.put(flowName, navFlowStatus);
            }
        }           
        
        
        List<NavFlowStatus__c> lstFlowUpdates = new List<NavFlowStatus__c>();
        for(String member : mapMemberFlowStatus.keyset()){
            
            for(NavFlowStatus__c navFlowRecord : mapMemberFlowStatus.get(member).values())
            {
                /*String flowStat = navFlowRecord.FlowPageStatus__c;
if((flowStat.contains('R') || flowStat.contains('C')) && (mode == 'RAC' || mode == 'addRemoveMember')){
lstFlowUpdates.add(navFlowRecord);
}  
else if(mode == 'Intake' || mode == 'Renewal'){*/
                lstFlowUpdates.add(navFlowRecord);
                //}
            }
        }       
        
        List<NavFlowStatus__c> updatedFlowStatusList = new List<NavFlowStatus__c>();  
        //updatedFlowStatusList.addAll(lstFlowUpdates);
        
        if(!lstFlowUpdates.isEmpty()){                                                 
            for(Integer nav = 0; nav <= lstFlowUpdates.size(); nav++){                                                   
                if(lstFlowUpdates.size() > nav){
                    String flowStat = lstFlowUpdates[nav].FlowPageStatus__c ;
                    
                    
                    
                    
                    if(lstFlowUpdates[nav].Id == null){
                        String[] flowStatArray = String.isNotBlank(flowStat) ? flowStat.split('') : new List<String>();
                        Integer count = 0;
                        if(!flowStatArray.isEmpty()){
                            for(Integer i=0; i<flowStatArray.size(); i++){
                                if(flowStatArray[i] == 'N'){
                                    count++;
                                }
                            }
                            
                            if(flowStatArray.size() != count){
                                
                                updatedFlowStatusList.add(lstFlowUpdates[nav]);   
                            } 
                        }
                    }
                    else{
                        updatedFlowStatusList.add(lstFlowUpdates[nav]);   
                    }
                }
            }    
            if(!SSP_Utility.isReadOnlyUser()){
                upsert updatedFlowStatusList;
            }
        }
    }
    
    
    public static NavFlowStatus__c initNavFlowReviewRequiredStatus(String appId, String memberId, String flowName, Map<String,Set<String>> flowSetMap){
        NavFlowDetail__mdt navFlowDetail = NavFlowHelper.getNavFlowDetail(null, flowName, null); 
        ContextData ctxData = new ContextData();
        NavFlowStatus__c flowStatRecord = new NavFlowStatus__c();
        flowStatRecord.SSPApplication__c = appId;
        flowStatRecord.Member__c = memberId;
        flowStatRecord.NavFlowName__c = flowName;
        flowStatRecord.RecordId__c = appId;
        String flowStatus = '';
        for(integer i=0; i < flowSetMap.get(flowName).size(); i++){
            flowStatus = flowStatus+'N';
        }
        flowStatRecord.FlowPageStatus__c = flowStatus;
        flowStatRecord.FlowDupStatus__c = flowStatus;
        flowStatRecord.InitiatedUser__c = UserInfo.getUserId();
        flowStatRecord.Contact__c = contactId;
        
        
        
        flowStatRecord.Screen_Status__c = NavFlowStatJSONCLone.createScreenStatusJSON(ctxData,flowStatRecord,navFlowDetail,null,flowStatRecord.FlowPageStatus__c);             
        
        return flowStatRecord;                     
    }
}