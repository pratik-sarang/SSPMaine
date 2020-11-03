/**
 * A basic rules engine implementation for workflow navigation rules.
 *
 * @author Rahman A
 * @date 09/24/2014
 *
 * @see NavFlowRule
 *
 */
public with sharing class NavFlowRulesEngine {

    private static final NavFlowRulesEngine rulesEngine = new NavFlowRulesEngine();

    /** temporary cache for rules. Key -> NavFlowRule__mdt.Id, Value -> NavFlowRule__mdt.RuleApexClassName__c instance */ 
    private transient Map<String, NavFlowRule> rulesMap = null;
    
    /** temporary cache for rules. Key -> NavFlowRule__mdt.Id, Value -> NavFlowRule__mdt.RuleLogic__c */
    private transient Map<String, String> rulesLogicMap = null;

    private NavFlowRulesEngine(){
        // singleton impl
    }

    /**
     * Returns singleton NavFlowRulesEngine instance.
     */
    public static NavFlowRulesEngine getInstance(){
        return rulesEngine;
    }

    /**
     * Invoked on workflow "next" action. Finds the NavFlowRule of the given ruleId and delegates the control to its instance.
     *
     * @param ruleId String rule name to invoke.
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */ 
    public boolean isRequired(Context ctx, ContextData ctxData, String ruleId){
    	boolean isReq = true;
    	initRule(ctx, ruleId);
    	NavFlowRule rule = rulesMap.get(ruleId);
    	if(null != rule) {
    		isReq = rule.isRequired(ctx, ctxData);
    	}
    	else {
    		
    	}
        return isReq;
    } 

    /**
     * Invoked on workflow "next" action. Finds the NavFlowRule of the given ruleId and delegates the control to its instance.
     *
     * @param ruleId String rule name to invoke.
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */ 
    public boolean isCompleted(Context ctx, ContextData ctxData, String ruleId){
    	boolean isDone = true;
    	initRule(ctx, ruleId);
    	NavFlowRule rule = rulesMap.get(ruleId);
    	if(null != rule) {
    		isDone = rule.isCompleted(ctx, ctxData);
    	}
    	else {
    		// TODO
    	}
        return isDone;
    }

    /**
     * Invoked on workflow "back" action. Finds the NavFlowRule of the given ruleId and delegates the control to its instance.
     *
     * @param ruleId String rule name to invoke.
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */ 
    public boolean isFirstRecord(Context ctx, ContextData ctxData, String ruleId){
    	boolean isFirst = true;
    	initRule(ctx, ruleId);
    	NavFlowRule rule = rulesMap.get(ruleId);
    	if(null != rule) {
    		isFirst = rule.isFirstRecord(ctx, ctxData);
    	}
    	else {
    		// TODO
    	}
        return isFirst;
    } 

    /**
     * Returns NavFlowRule instance of the given rule.
     *
     * @param ruleId String rule name to get.
     *
     * @return NavFlowRule
     */
    private void initRule(Context ctx, String ruleId){
        if(null == rulesMap){
        	rulesMap = new Map<String, NavFlowRule>();
        }
        if(null == rulesLogicMap){
        	rulesLogicMap = new Map<String, String>();
        }
        if(null == rulesMap.get(ruleId) || null == rulesLogicMap.get(ruleId)) {
        	// values not found. hence init
        	
        	NavFlowRule__mdt ruleMeta = NavFlowHelper.getNavFlowRule(ctx, ruleId);
        	if(null == ruleMeta) {
        		throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Nav flow rule meta not found for rule Id [' + ruleId + ']');
        	}
        	else if(null == ruleMeta.RuleApexClassName__c && null == ruleMeta.RuleLogic__c) {
        		throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Nav flow rule meta is incomplete for rule Id [' + ruleId + ']');
        	}
        	else {
        		if(null != ruleMeta.RuleApexClassName__c) {
        			rulesMap.put(ruleId, (NavFlowRule) Type.forName(ruleMeta.RuleApexClassName__c).newInstance());
        		}
        		if(null != ruleMeta.RuleLogic__c) {
        			rulesLogicMap.put(ruleId, ruleMeta.RuleLogic__c);
        		}
        	}
        }
    }

    
}