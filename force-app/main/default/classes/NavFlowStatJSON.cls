public class NavFlowStatJSON {
	
    public static String createScreenStatusJSON(ContextData ctxData, NavFlowStatus__c navFlowStatus, 
                                                NavFlowDetail__mdt navFlowDetail, 
                                                Map<Integer,Boolean> ReviewRequiredMap, String oldStatus){
        String screenStatus = '';
        Map<Integer,String> intPageMap = new Map<Integer,String>();
        for(Integer i=0; i<navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
            intPageMap.put(i,navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c);
        }
        
        Map<String,Map<String,Object>> screenStatusMap = new Map<String,Map<String,Object>>();        
        String flowStatus = navFlowStatus.FlowDupStatus__c;
                
        Integer[] flowStatusChars = flowStatus.getChars();
        for(Integer i=0; i<flowStatusChars.size(); i++){
           Map<String,Object> parameterMap = new Map<String,Object>();
           
           String flowStat = String.fromCharArray( new List<Integer> {flowStatus.charAt(i)});
           String oldStat = String.fromCharArray( new List<Integer> {oldStatus.charAt(i)});
           parameterMap.put('Status',flowStat);
           parameterMap.put('isReviewRequired',(ReviewRequiredMap != null ? !ReviewRequiredMap.isEmpty() ? ReviewRequiredMap.containsKey(i) ? ReviewRequiredMap.get(i) : false : false : false)); 
           parameterMap.put('oldStatus',oldStat);
           parameterMap.put('reviewReqScreens',null);
           screenStatusMap.put(intPageMap.get(i),parameterMap);
        }
        
        screenStatus = JSON.serialize(screenStatusMap);
        return screenStatus;
    }
}