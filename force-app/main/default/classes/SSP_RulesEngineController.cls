public class SSP_RulesEngineController {
	public static Map<String,String> invokeRule(Set<String> setRulesToInvoke, Id applicationId, Id memberId){
        Map<String,String> mapRuleResult = new Map<String,String>();
        
        if(setRulesToInvoke != null){
            if(setRulesToInvoke.contains('ReviewResource')){                
                mapRuleResult.put('ReviewResource', 'true,' + memberId);
            }  
            /*if(setRulesToInvoke.contains('AmericanIndian')){
                Boolean result = checkAmericanIndian(memberId); 
                mapRuleResult.put('AmericanIndian', String.valueOf(result) + ','+ memberId);
            }*/                       
            
            /*if(setRulesToInvoke.contains('SameAddressForNonPrimary')){                
                ResultWrapper res = checkSameAddressAsHOH(applicationId, memberId);
                mapRuleResult.put('SameAddressForNonPrimary', String.valueOf(res.result)+','+String.join(res.memberIds, ','));
                
            }*/
            
            /*if(setRulesToInvoke.contains('AgeGreaterThan17USCitizen')){
                ResultWrapper res = getNonUSCitizen(memberId, applicationId);
                mapRuleResult.put('AgeGreaterThan17USCitizen', String.valueOf(res.result) + ','+ String.join(res.memberIds,','));
            }*/
            
            if(setRulesToInvoke.contains('review_expense_summary')){
                Boolean result = SSP_ExpenseController.validateBlankExpense(applicationId, memberId); 
                /*if(result)
                    mapRuleResult.put('review_expense_summary', String.valueOf(result) + ','+ memberId);*/
            }
            if(setRulesToInvoke.contains('review_tax_filing')){
                //Boolean result = SSP_ApplicationSummaryController.setTaxFilingRRequired(applicationId); 
                String memberIdStr = '';
                
                List<SSP_ApplicationIndividual__c> appIndList =             
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND', 'MemberStatus__c' => '!='}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c','IsTaxRRCompleted__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(applicationId),
                                                                                         'MemberStatus__c'=> 'Removed'});
                    Set<String> memberIdSet = new Set<String>();
                    for(SSP_ApplicationIndividual__c appInd : appIndList){
                        if(!appInd.IsTaxRRCompleted__c){
                            memberIdSet.add(appInd.SSP_Member__c);
                        }                        
                    }
                    List<String> memberIdList = new List<String>();
                    memberIdList.addAll(memberIdSet);
                    
                   	memberIdStr = String.join(memberIdList,',');
                
                //if(result){
                    
                	mapRuleResult.put('review_tax_filing', 'true,'+ memberIdStr);                       
                //}                
            }
        }        
        return mapRuleResult;
    }   
    
    /*public static Boolean checkAmericanIndian(Id memberId){
        Boolean result;
        List<SSP_Member__c> memObj = [SELECT Id, RaceCode__c FROM SSP_Member__c where Id = :memberId];
        List<String> raceValues = memObj.get(0).RaceCode__c.split(';');
        if(raceValues.contains(SSP_GlobalConstants.AMERICAN_INDIAN_RACE_CODE)){
            result = true;
        }
        else {
            result = false;
        }
        return result;
    }*/
    
    /*public static Boolean checkAge60(Id memberId){
        Boolean result;
        List<SSP_Member__c> memObj = [SELECT Id, Age__c FROM SSP_Member__c where Id = :memberId];
        
        if(memObj.get(0).Age__c >= 60){
            result = true;
        }
        else {
            result = false;
        }
        return result;
    }*/

	/*public static Boolean checkAge17(Id memberId){
        Boolean result;
        SSP_Member__c memObj = [SELECT Id, Age__c FROM SSP_Member__c where Id = :memberId];
        
        if(memObj.Age__c >= 17){
            result = true;
        }
        else {
            result = false;
        }
        return result;
    }*/
    
    /*public static Boolean checkUSCitizen(Id memberId){
        Boolean result;
        SSP_Member__c memObj = [SELECT Id, IsUSCitizenToggle__c FROM SSP_Member__c where Id = :memberId];
        if(memObj.IsUSCitizenToggle__c == SSP_GlobalConstants.NO){
            result = true;
        }
        else {
            result = false;
        }
        return result;
    }*/
    
    
    /*public static Boolean checkSameAddressForAll(Id memberId){
        Boolean result;
        SSP_Member__c memObj = [SELECT Id, SameAddressInfoAsHOHToggle__c FROM SSP_Member__c where Id = :memberId];
        if(memObj.SameAddressInfoAsHOHToggle__c == SSP_GlobalConstants.NO){
            result = true;
        }
        else {
            result = false;
        }
        return result;
    }*/
    
    public static List<String> getNonPrimaryMemberId(Id applicationId){
        List<String> memIdList = new List<String>();
        List<SSP_ApplicationIndividual__c> appIndList = [SELECT Id, SSP_Member__c FROM SSP_ApplicationIndividual__c where SSP_Application__c = :applicationId
                                                         AND IsHeadOfhousehold__c = false];
        if(!appIndList.isEmpty()){
         	for(SSP_ApplicationIndividual__c appInd : appIndList){
            memIdList.add(appInd.SSP_Member__c);            
        	}   
        }        
        return memIdList;
    }
    
    /*public static ResultWrapper checkSameAddressAsHOH(Id applicationId, Id memberId){
    	ResultWrapper resultWrap = new ResultWrapper();
        List<Id> memberIdLIst = new List<Id>();
        SSP_ApplicationIndividual__c hoh;
        List<SSP_ApplicationIndividual__c> appIndList = [SELECT Id, SSP_Member__c, IsHeadOfhousehold__c, SSP_Member__r.SameAddressInfoAsHOHToggle__c FROM SSP_ApplicationIndividual__c 
                                                         WHERE SSP_Application__c = :applicationId
                                                         AND MemberStatus__c != :SSP_GlobalConstants.MEMBER_REMOVE_STATUS];
        if(!appIndList.isEmpty()){
            for(SSP_ApplicationIndividual__c appIndiv : appIndList){
                if(!appIndiv.IsHeadOfhousehold__c){
                    memberIdLIst.add(appIndiv.SSP_Member__c);
                }
                if(appIndiv.SSP_Member__c == memberId){
                    hoh = appIndiv;
                }
            }
        }
        
        if(hoh.SSP_Member__r.SameAddressInfoAsHOHToggle__c == SSP_GlobalConstants.NO && hoh.IsHeadOfhousehold__c && appIndList.size()>1){
			resultWrap.result = true;         
        }
        else{
            resultWrap.result = false;
        }
        resultWrap.memberIds = memberIdList;
        
        return resultWrap;
    }*/
    
    public static resultWrapper getNonUSCitizen(Id memberId, Id applicationId){
        List<String> memIdList = new List<String>();
        ResultWrapper resultWrap = new ResultWrapper();
        SSP_ApplicationIndividual__c member;
        List<SSP_ApplicationIndividual__c> appIndList = [SELECT Id, SSP_Member__c, SSP_Member__r.Age__c, 
                                                         		SSP_Member__r.IsUSCitizenToggle__c, SSP_Member__r.HasAlienSponsorToggle__c 
                                                         FROM SSP_ApplicationIndividual__c 
                                                         WHERE SSP_Application__c = :applicationId];
        for(SSP_ApplicationIndividual__c appInd : appIndList){
            if(appInd.SSP_Member__c == memberId){
                member = appInd;
            }
            else if(appInd.SSP_Member__r.IsUSCitizenToggle__c == SSP_GlobalConstants.NO && appInd.SSP_Member__r.HasAlienSponsorToggle__c == SSP_GlobalConstants.NO){
                memIdList.add(appInd.SSP_Member__c);
            }
        }
        resultWrap.memberIds = memIdList;
        if(member.SSP_Member__r.IsUSCitizenToggle__c == SSP_GlobalConstants.YES && member.SSP_Member__r.Age__c >= 17 && !memIdList.isEmpty()){
            resultWrap.result = true;
        }
        else {
            resultWrap.result = false;
        }   
        return resultWrap;
    }
    
    public class ResultWrapper{
        public boolean result {get;set;}
        public List<Id> memberIds {get;set;}
    }
}