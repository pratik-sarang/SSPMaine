public class RulesEngineController { 
	public static Map<String,Boolean> invokeRule(Map<String, SObject> mapRuleObject){
        Map<String,Boolean> mapRuleResult = new Map<String,Boolean>();
        
        if(mapRuleObject != null){
            if(mapRuleObject.containsKey('HasIncome') && mapRuleObject.get('HasIncome') != null){
                Boolean result = checkIncomeIncreased(mapRuleObject.get('HasIncome')); 
                mapRuleResult.put('HasIncome', result);
            }
            
            if(mapRuleObject.containsKey('HasFollowup') && mapRuleObject.get('HasFollowup') != null){
                //Boolean result = checkFollowUp(mapRuleObject.get('HasFollowup')); 
                mapRuleResult.put('HasFollowup', checkFollowUp(mapRuleObject.get('HasFollowup')));
            }
        }        
        return mapRuleResult;
    }
    
    public static Boolean checkIncomeIncreased(SObject obj){
        
        SSP_Application__c conObj = (SSP_Application__c)obj;
        /*if(conObj.Has_Income__c)
        	return true;
        else
          	return false;*/
        return true;
    }
    
    public static Boolean checkFollowUp(SObject obj){
        
        SSP_Application__c conObj = (SSP_Application__c)obj;
        /*if(conObj.Do_you_want_to_reach_out_by_phone__c)
        	return true;
        else
          	return false;*/
        return true;
    }
}