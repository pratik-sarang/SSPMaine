public class SSP_RulesEngine {
	@AuraEnabled
    public static void getRRTriggerRules(Id applicationId, Id memberId, List<String> selectedScreens, 
                                         List<String> reviewRequiredList, String mode)
    {
        List<ReviewRequiredScreenWrapper> lstReviewRequiredScreens = new List<ReviewRequiredScreenWrapper>();  
		Map<String, List<Review_Required_Screens__mdt>> mapRules = new Map<String, List<Review_Required_Screens__mdt>>();
        Set<String> setRulesToInvoke = new Set<String>();
        
        //get list of review required metadata       
        List<Review_Required_Screens__mdt> lstMetadata = [Select Review_Required_Trigger_Rules__r.IsActive__c, 
                                                             Review_Required_Trigger_Rules__r.RuleName__c, 
                                                             Review_Required_Trigger_Rules__r.Message__c, 
                                                             Review_Required_Trigger_Rules__r.Screen__c, 
                                                          	 Review_Required_Trigger_Rules__r.IsRuleApex__c, 
                                                             Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c, 
                                                             Navigation_Flow_Page_Configuration__r.NavigationFlowDetail__r.FlowName__c 
                                                             from Review_Required_Screens__mdt
                                                             where Review_Required_Trigger_Rules__r.IsActive__c = true
                                                             AND Review_Required_Trigger_Rules__r.Screen__c IN :selectedScreens];
                
        
        //Fetch apex rule names 
        //mapRules => store list of review required metadata against rule name                                                       
		for(Review_Required_Screens__mdt rule : lstMetadata){
            if(rule.Review_Required_Trigger_Rules__r.IsRuleApex__c == true)
            	setRulesToInvoke.add(rule.Review_Required_Trigger_Rules__r.RuleName__c);
            if(mapRules.containsKey(rule.Review_Required_Trigger_Rules__r.RuleName__c)){
            	list<Review_Required_Screens__mdt> lstScreenMetadata = mapRules.get(rule.Review_Required_Trigger_Rules__r.RuleName__c);
                lstScreenMetadata.add(rule);
                mapRules.put(rule.Review_Required_Trigger_Rules__r.RuleName__c, lstScreenMetadata);
            }
            else{
                mapRules.put(rule.Review_Required_Trigger_Rules__r.RuleName__c, new list<Review_Required_Screens__mdt>{rule});
            }
            
		}   
        //Shikha : Started
        //mapRuleVsAffectedScreen => Rule vs affected screen
        Map<String,Set<String>> mapAffectedScreenVsRule = new Map<String,Set<String>>();
        //List<String> affectedScreenList = new List<String> ();
        Map<String,Boolean> PageVsEvaluationMap = new Map<String,Boolean>();
        for(Review_Required_Screens__mdt rule : lstMetadata){
            //affectedScreenList.add(rule.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c);
            if(mapAffectedScreenVsRule.containsKey(rule.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c)){
                mapAffectedScreenVsRule.get(rule.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c).add(rule.Review_Required_Trigger_Rules__r.RuleName__c);
            }
            else{
                mapAffectedScreenVsRule.put(rule.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c,new Set<String> {rule.Review_Required_Trigger_Rules__r.RuleName__c});                
            }
        }
		
        
        //mapRuleFlowScreens=> store rule vs ReviewRequiredScreenWrapper
        Map<String, Map<String,ReviewRequiredScreenWrapper>> mapRuleFlowScreens = new Map<String, Map<String,ReviewRequiredScreenWrapper>>();
        //mapFlowScreens => store flow vs no of screens
        Map<String, Set<String>> mapFlowScreens = new Map<String, Set<String>>();  	
        //mapRuleResult=> store rule and its result
        Map<String,Boolean> mapRuleResult = new Map<String,Boolean>();  
        //mapRuleMemberIds => store rule against its member Ids
        Map<String,List<String>> mapRuleMemberIds = new Map<String,List<String>>();
        //mapRuleResponse => store rule vs apex execution response
       	Map<String, String> mapRuleResponse = SSP_RulesEngineController.invokeRule(setRulesToInvoke, applicationId, memberId);
        
        for(String rule : mapRuleResponse.keySet()){
            mapRuleResult.put(rule, Boolean.valueOf(mapRuleResponse.get(rule).split(',')[0]));
           
            if(mapRuleResponse.get(rule) != null){
            List<String> lstRuleMembers = new List<String>();
                	lstRuleMembers.addAll(mapRuleResponse.get(rule).split(','));
               lstRuleMembers.remove(0);
                mapRuleMemberIds.put(rule.split(',')[0],lstRuleMembers);
          // mapRuleMemberIds.put(rule.split(',')[0], new List<String>{(mapRuleResponse.get(rule).split(',')[1])});
            }
        }
        
        
        for(String rule : reviewRequiredList) {
            List<String> splits = rule.split(',');
            
            System.assert(splits.size() > 2, 'Insufficient number of arguments in RR rules.');
            mapRuleResult.put(splits[0], Boolean.valueOf(splits[1]));
            mapRuleMemberIds.put(splits[0], new List<String>());
            for(Integer index = 2; index < splits.size(); ++index) {
                mapRuleMemberIds.get(splits[0]).add(splits[index]);
            }
        }
        
        
        //Shikha: added 
        for(String pageName : mapAffectedScreenVsRule.keyset()) {
            Set<String> ruleSet = mapAffectedScreenVsRule.get(pageName);
            for(String rule : ruleSet){
                //Boolean responseValue = PageVsEvaluationMap != null ? PageVsEvaluationMap.get(pageName) != null 
                if(PageVsEvaluationMap != null && PageVsEvaluationMap.containsKey(pageName) && PageVsEvaluationMap.get(pageName)!= null){
                    
                    
                    Boolean ruleEval = PageVsEvaluationMap.get(pageName) || (mapRuleResult.get(rule)!=null ? mapRuleResult.get(rule) : false);
                    PageVsEvaluationMap.put(pageName,ruleEval);
                }
                else{
                    PageVsEvaluationMap.put(pageName,mapRuleResult.get(rule)!=null ? mapRuleResult.get(rule) : false);   
                }             	
            }           
        }
        
        //Shikha : 5/30
        Map<String, Set<String>> mapScreeVsRules = new Map<String,Set<String>>();
        for(String rule : mapRuleResult.keySet()){
            //if(mapRuleResult.get(rule)){  
            list<Review_Required_Screens__mdt> lstScreenMetadata = mapRules.get(rule);
            
            
            //
            if(lstScreenMetadata != null){
                for(Review_Required_Screens__mdt screenMetadata : lstScreenMetadata)
                {                    
                    if(mapRuleFlowScreens.containsKey(screenMetadata.Review_Required_Trigger_Rules__r.RuleName__c)){
                        
                        Map<String,ReviewRequiredScreenWrapper> mapFlowReviewReqScreen = mapRuleFlowScreens.get(screenMetadata.Review_Required_Trigger_Rules__r.RuleName__c);
                        ReviewRequiredScreenWrapper wrapper = new ReviewRequiredScreenWrapper();
                        if(mapFlowReviewReqScreen.containsKey(screenMetadata.Navigation_Flow_Page_Configuration__r.NavigationFlowDetail__r.FlowName__c))
                        {
                            wrapper = mapFlowReviewReqScreen.get(screenMetadata.Navigation_Flow_Page_Configuration__r.NavigationFlowDetail__r.FlowName__c);                        
                            Set<String> lstScreens = wrapper.affectedScreen;
                            lstScreens.add(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c);
                            wrapper.affectedScreen = lstScreens;
                        }
                        else
                        {                            
                        	wrapper.flowName = screenMetadata.Navigation_Flow_Page_Configuration__r.NavigationFlowDetail__r.FlowName__c;
                        	wrapper.affectedScreen = new Set<String>{screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c};                         
                        	//wrapper.mapScreenRule = new Map<String,Boolean>{screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c => mapRuleResult.get(rule)}; 
                        	String screenName = screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c;
                            wrapper.mapScreenRule = new Map<String,Boolean>{screenName =>PageVsEvaluationMap.get(screenName)};
                            wrapper.memberIds = mapRuleMemberIds.get(screenMetadata.Review_Required_Trigger_Rules__r.RuleName__c);
                        }    
                        //Shikha : 5/30
                        /*if(wrapper != null && wrapper.mapScreenRule != null && wrapper.mapScreenRule.containsKey(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c) &&
                           wrapper.mapScreenRule.get(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c) != null
                           && wrapper.mapScreenRule.get(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c)){
                        	if(mapScreeVsRules.containsKey(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c)){
                        		mapScreeVsRules.get(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c).add(rule);
                    		}
                    		else{
                        		mapScreeVsRules.put(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c,new Set<String>{rule});
                    		}
                    	}*/
                        					
                        mapFlowReviewReqScreen.put(wrapper.flowName, wrapper);
                        
                        mapRuleFlowScreens.put(screenMetadata.Review_Required_Trigger_Rules__r.RuleName__c, mapFlowReviewReqScreen);  
                          
                        
                	}
                    else{
                        
                        ReviewRequiredScreenWrapper wrapper = new ReviewRequiredScreenWrapper();
                        wrapper.flowName = screenMetadata.Navigation_Flow_Page_Configuration__r.NavigationFlowDetail__r.FlowName__c;
                        wrapper.affectedScreen = new Set<String>{screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c};                         
                        //wrapper.mapScreenRule = new Map<String,Boolean>{screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c => mapRuleResult.get(rule)}; 
                        String screenName = screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c;
                        wrapper.mapScreenRule = new Map<String,Boolean>{screenName =>PageVsEvaluationMap.get(screenName)};
                        wrapper.memberIds = mapRuleMemberIds.get(screenMetadata.Review_Required_Trigger_Rules__r.RuleName__c);
                        Map<String,ReviewRequiredScreenWrapper> mapFlowReviewReqScreen = new Map<String,ReviewRequiredScreenWrapper>();
                        mapFlowReviewReqScreen.put(wrapper.flowName, wrapper);                        
                        
                        mapRuleFlowScreens.put(screenMetadata.Review_Required_Trigger_Rules__r.RuleName__c, mapFlowReviewReqScreen);
                         
                        /*if(wrapper != null && wrapper.mapScreenRule != null && wrapper.mapScreenRule.containsKey(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c) &&
                           wrapper.mapScreenRule.get(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c) != null
                           && wrapper.mapScreenRule.get(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c)){
                        	if(mapScreeVsRules.containsKey(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c)){
                        		mapScreeVsRules.get(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c).add(rule);
                    		}
                    		else{
                        		mapScreeVsRules.put(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c,new Set<String>{rule});
                    		}
                    	}*/
                    }
                    //SHikha - 5/30
                    if(mapRuleResult.get(rule)){
                    	if(mapScreeVsRules.containsKey(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c)){
                        	mapScreeVsRules.get(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c).add(rule);
                    	}
                    	else{
                        	mapScreeVsRules.put(screenMetadata.Navigation_Flow_Page_Configuration__r.PageInfo__r.PageName__c,new Set<String>{rule});
                    	}
                    } 
                }
            }
        }
        
        //mapAffectedScreenResult=> store affected screen vs result
        Map<String, Boolean> mapAffectedScreenResult = new Map<String, Boolean>();        
        Set<String> memberIds = new Set<String>();
        for(String rule : mapRuleFlowScreens.keyset()){
            Map<String, ReviewRequiredScreenWrapper> flowScreens = mapRuleFlowScreens.get(rule);
            for(ReviewRequiredScreenWrapper wrapper : flowScreens.values()){
            	lstReviewRequiredScreens.add(wrapper);  
                memberIds.addAll(wrapper.memberIds);
                for(String screenName : wrapper.affectedScreen)
                {
                    if(mapAffectedScreenResult.containsKey(screenName)){
                        Boolean newResult = mapAffectedScreenResult.get(screenName) || mapRuleResult.get(rule);
                        mapAffectedScreenResult.put(screenName, newResult);
                    }
                    else{
                        mapAffectedScreenResult.put(screenName, mapRuleResult.get(rule));
					}
                } 
            }            
        }
        
        
        
                //mapAffectedScreenResult
		/*NavFlowManager.updateReviewRequiredFlowStatus(applicationId, memberId, selectedScreens[0], 
														lstReviewRequiredScreens, PageVsEvaluationMap,
                                                        memberIds);	*/
        SSP_ReviewRequiredRuleService.updateRRStatus(applicationId, memberId, selectedScreens[0], 
														lstReviewRequiredScreens, PageVsEvaluationMap,
                                                        memberIds, mode, mapScreeVsRules, mapRuleResult);
    }
    

    public class ReviewRequiredScreenWrapper {
       public String flowName;
       public Set<String> affectedScreen;
       //public Boolean isRuleCheck;
       public Map<String,Boolean> mapScreenRule;
       public List<String> memberIds;
    }
    
    public class ScreenStatus {
        public boolean isReviewRequired;
        public String Status;
        public String oldStatus;
        public String reviewReqScreens;
	}
}