//@Shikha: created a class to check the resume functionality

public class NavFlowResume {
	    
    
    public static List<NavFlowStatus__c> getNavFlowStatList(String contactId){
        //Need to pass Application Id instead of contactId
        List<NavFlowStatus__c> navFlowStatList = [SELECT Id, Name, Contact__r.Name, FlowPageStatus__c, NavFlowName__c, RecordId__c, SSPApplication__c, InitiatedUser__c
                                                  FROM NavFlowStatus__c
                                                  WHERE Contact__c = :contactId
                                                  AND InitiatedUser__c = :UserInfo.getUserId()];
        return navFlowStatList;
    }
    
    public static String resumeFLow(Context ctx,ContextData ctxData){
        
        String gotoPageConfigId = '';
        
        
                
        NavFlowStatus__c existedNavFlowRecord = NavFlowHelper.getNavFlowStausExisting(ctx, ctxData);
        gotoPageConfigId = fetchConfigId(existedNavFlowRecord, ctx, ctxData);
        return gotoPageConfigId;
            
    }
    //ccccrrr-
    public static String fetchConfigId(NavFlowStatus__c existedNavFlowRecord, Context ctx, ContextData ctxData){
        String gotoPageConfigId = '';
        if(existedNavFlowRecord != null){
            String flowStatus = existedNavFlowRecord.FlowPageStatus__c;
        	
        	NavFlowDetail__mdt flowDetail = NavFlowManager.getNavFlowDetail(ctx, ctxData);
        	Map<Integer,String> IntegerPageMap = new Map<Integer,String>();
        	for(Integer i=0; i < flowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
            	IntegerPageMap.put(i,flowDetail.Navigation_Flow_Page_Configuration__r[i].Id);
        	}
        	
        	Integer idx = flowStatus.indexOf('R');
        	
        	gotoPageConfigId = IntegerPageMap.get(idx);
        	
        }
        return gotoPageConfigId;
    }
}