/**
* Helper class to initialize, load and keep track flow based pages.
*
* @author Rahman A
* @date 09/24/2014
*
*/
public with sharing class NavFlowManager {
    
    /** Page 'Required' status code. */
    public static final String STEP_REQ = 'R';
    
    /** Page 'Not Required' status code. */
    public static final String STEP_NOT_REQ = 'N';
    
    /** Page 'Completed' status code. */
    public static final String STEP_COMPLETE = 'C';
    
    public static Boolean isDupStatus = false;
    //Added to identify that flow is getting launch from framework and not from app summary
    public static Boolean isLoadRACFlow = false;
    public static QueuingWrapper queueWrapperObject;
    /**
* Initializes and load the given flow. At first, "Flow Unique ID" is retrieved from ContextData.
* <p> If "Flow Unique ID" is set in ContextData then the corresponding existing flow is loaded. Else, a new flow is created.
<p> To create a new flow, set "Flow Unique ID" as null in ContextData and invoke this method.
<p> Determines the page to load and returns it. 
*
* @param ctx Context object
* @param ctxData ContextData object
*
* @return NavFlowPageConfig__mdt
*/
public static PageToLoad loadFlow(Context ctx, ContextData ctxData) {
    NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
    NavFlowStatus__c navFlowStatus = null;
    if(ctxData.modeValue == 'RAC') {
        ctxData.SelectedScreen = NavFlowController.getMemberDetails(ctxData.ApplicationId, ctxData.MemberId, ctxData.flowName, ctxData.modeValue);        
    }
    //delete this*******************
    
    
    /* TODO for use cases where navigation flow status id is not known but want to start latest flow using contact and flow name then flow status can be fetched using contact & flow name.
But for now, just go by Id.
*/
    //Shikha:adding else part to flow to check back button
    if(String.isNotBlank(ctxData.navFlowStatusId)) {
        navFlowStatus = NavFlowHelper.getNavFlowStatus(ctx, ctxData.navFlowStatusId);
        //delete this*******************
        ctxData.recordId = navFlowStatus.RecordId__c;//passing application record Id from NavFlowStatus
        
        //Shikha: adding application and member Id
        ctxData.ApplicationId = navFlowStatus.SSPApplication__c;
        
        ctxData.MemberId = navFlowStatus.Member__c;
        
    }
    // 
    else if(ctxData.flowName != 'Report a change Member' && (ctxData.modeValue != 'RAC' && ctxData.modeValue != 'addRemoveMember')){
        navFlowStatus = NavFlowHelper.getNavFlowStausExisting(ctx, ctxData);
        
        ctxData.recordId = ctxData.recordId != null ? ctxData.recordId : navFlowStatus != null ? navFlowStatus.RecordId__c != null ? navFlowStatus.RecordId__c : '':''; //passing record Id from NavFlowStatus
        
        //
        ctxData.ApplicationId = ctxData.ApplicationId != null ? ctxData.ApplicationId : navFlowStatus != null ? navFlowStatus.SSPApplication__c != null ? navFlowStatus.SSPApplication__c : null : null;
        
        ctxData.MemberId = ctxData.MemberId != null ? ctxData.MemberId : navFlowStatus != null ? navFlowStatus.Member__c != null ? navFlowStatus.Member__c : null : null;
        
    }
    
    if(null == navFlowStatus && ctxData.flowName != 'Report a change Member' && (ctxData.modeValue != 'RAC' && ctxData.modeValue != 'addRemoveMember')){
        navFlowStatus = new NavFlowStatus__c();
        navFlowStatus.Contact__c = ctxData.contactId;
        navFlowStatus.NavFlowName__c = ctxData.flowName;
        navFlowStatus.RecordId__c = ctxData.recordId;
        //Shikha: added application and member data
        navFlowStatus.SSPApplication__c = ctxData.ApplicationId;
        navFlowStatus.Member__c = ctxData.MemberId;
        ctxData.navFlowStatus = navFlowStatus;  
        
        // now determine the pages' statuses
        if(ctxData.SelectedPrograms.isEmpty())
            navFlowStatus.FlowPageStatus__c = initNavFlowStatuses(ctx, ctxData); 
        else
            loadScreenProgramMapping(ctx, ctxData, navFlowStatus);
    }
    else if(null == navFlowStatus && (ctxData.modeValue == 'RAC' || ctxData.modeValue == 'addRemoveMember')){
        
        List<NavFlowStatus__c> navFlowStatList = NavFlowHelper.getNavFlowRACStatus(ctxData.MemberId, ctxData.ApplicationId, ctxData.flowName);                
        Map<Integer,String> PageIntegerMap = new Map<Integer,String>();
        for(integer i=0; i<navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
            PageIntegerMap.put(i,navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c);
        }
            if(!navFlowStatList.isEmpty()){
                navFlowStatus = navFlowStatList[0];
                
                //Shikha: started        
                if(!navFlowStatus.IsEdit__c){
                 	List<String> selectedScreens = ctxData.selectedScreen;
                    
                    String[] flowStatusArray = navFlowStatus.FlowPageStatus__c.split('');
                    
                    for(Integer i =0; i<PageIntegerMap.size(); i++){
                        
                                                
                        if(PageIntegerMap.containsKey(i) && selectedScreens.contains(PageIntegerMap.get(i))){                    	
                            flowStatusArray[i] = 'R';
                        } 
                    }
                    String flowStatusString = String.join(flowStatusArray,'');
                    navFlowStatus.FlowPageStatus__c = flowStatusString;
                    navFlowStatus.FlowDupStatus__c = flowStatusString;   
                    
                    if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
                    	update navFlowStatus;
                    }
                }                
                //Shikha: end                   
            }
            else{                            
                navFlowStatus = new NavFlowStatus__c();
                navFlowStatus.Contact__c = ctxData.contactId;
                navFlowStatus.NavFlowName__c = ctxData.flowName;
                navFlowStatus.RecordId__c = ctxData.recordId;
                //Shikha: added application and member data
                navFlowStatus.SSPApplication__c = ctxData.ApplicationId;
                navFlowStatus.Member__c = ctxData.MemberId;
                navFlowStatus.Id = null;
                // now determine the pages' statuses
                isLoadRACFlow = true;            
                navFlowStatus.FlowPageStatus__c = initNavFlowRACStatuses(ctx, ctxData, navFlowStatus);
                
                
                navFlowStatus.FlowDupStatus__c =  ctxData.flowDuplicateStatus;
                ctxData.navFlowStatus = navFlowStatus;    
        	}
            //navFlowStatus.FlowPageStatus__c =  ctxData.navFlowStatus.FlowPageStatus__c;
        }
        //Added by Nupoor for RAC approach
        /*if(null == 'ReportAChangePOC'){

}*/
    ctxData.navFlowStatusId = navFlowStatus.Id;
    ctxData.navFlowStatusName = navFlowStatus.Name;
    ctxData.flowName = navFlowStatus.NavFlowName__c;
    // now, set the first required page as the page to load
    Integer idx = navFlowStatus.FlowPageStatus__c.indexOf(STEP_REQ);
    if(idx == -1){
        idx = 0;
    }
    //Shikha: changed gotopageconfigId to navigate to the Page from where user left if the flow has been initiated next time.
    if(ctxData.flowName == 'Report a change Member'){
        ctxData.goToPageConfigId = navFlowDetail.Navigation_Flow_Page_Configuration__r[idx].Id;
    }
    else{
    
        ctxData.goToPageConfigId = (String)NavFlowResume.resumeFLow(ctx,ctxData);
        if(String.isBlank(ctxData.goToPageConfigId)){
            ctxData.goToPageConfigId = navFlowDetail.Navigation_Flow_Page_Configuration__r[idx].Id;
        }
    }
    
    //ctxData.goToPageConfigId = navFlowDetail.Navigation_Flow_Page_Configuration__r[idx].Id;
    
    
    PageToLoad pg = goToPage(ctx,ctxData);
    
    return pg;
}
    
    /**
* Determines next page to load and returns it.
*
* @param ctx Context object
* @param ctxData ContextData object
* @Manjunath : Added code to check NextActionGoToPage__c picklist value field on NavFlowDetail__mdt to ensure if the picklist value is 'completed' the next button loads the next page with status 'completed'
* and similarly for 'Required'
*
*/
    public static PageToLoad getNextStep(Context ctx, ContextData ctxData){
        PageToLoad response; //#379955
        NavFlowPageConfig__mdt pageConfig = null;
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        NavFlowStatus__c navFlowStatus = getNavFlowStatus(ctx, ctxData);
        String flowStatus = navFlowStatus.FlowPageStatus__c;
        boolean isFnd = false;
        String statusToCheck = 'Completed'.equals(navFlowDetail.NextActionGoToPage__c) ? STEP_COMPLETE : STEP_REQ;
        //
        // find the index of first required page in the flow. This will be used when the completed page is not found. Useful for first time flow navigation.
        Integer reqIdx = -1;
        // flag to indicate if this is current page. default to true since we are iterating from current page.
        boolean isCur = true;
        // start from current page and then find next page
        Integer idx = getCurPageIndex(ctx, ctxData, navFlowDetail);        
        Integer nextIdx = getNextIndex(idx, navFlowStatus.FlowPageStatus__c); 
        
        for(; idx < navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); idx++){
            String pageStatus = String.fromCharArray(new Integer[] {flowStatus.charAt(idx)});
            // 
            if(pageStatus.equals(statusToCheck)){
                if(isCur && pageStatus.equals(STEP_COMPLETE)){
                    isCur = false;
                    // if the current page status is completed and the status to check is also completed then skip the current page.
                    continue;
                }
                isFnd = true;
                break;
            }
            if(reqIdx == -1 && STEP_REQ.equals(pageStatus)){
                reqIdx = idx;
                //
            }
            isCur = false;
        }
        if(!isFnd){
            // no step found meeting NextActionGoToPage__c condition. So set next required page index.
            idx = reqIdx;
            if(idx == -1){
                // still no step found. reset to first page
                idx = 0;
            }
        }
        //
        pageConfig = navFlowDetail.Navigation_Flow_Page_Configuration__r[idx];
        /** #379955 fix*/
        response = preparePageToLoad(ctx, ctxData, pageConfig, navFlowStatus); 
        response.navigateToSummary = false;
        if(SSP_Utility.isReadOnlyUser()){            
            if(String.isNotBlank(navFlowStatus.FlowDupStatusCopy__c ) && (navFlowStatus.FlowDupStatusCopy__c).length() > nextIdx ){
                String screenStatus = String.fromCharArray(new Integer[] {navFlowStatus.FlowDupStatusCopy__c.charAt(nextIdx)});
                if(String.isNotBlank(screenStatus) && screenStatus.equalsIgnoreCase('R')){
                    response.navigateToSummary = true;       
                }
            }        
        }
        //Shikha - 
        system.debug('### ctxData flowName '+ctxData.flowName);
        system.debug('### response.isLastPage '+response.isLastPage);
        String flowStatusPage = navFlowStatus.FlowPageStatus__c;
        Boolean checkLastPage = !flowStatusPage.contains('R');
        system.debug('### checkLastPage '+checkLastPage);
        system.debug('### flowStatusPage.length() -1 '+(flowStatusPage.length() -1));
        if(ctxData != null && ctxData.flowName != null && NavFlowManager.orderVsFlowMap.keySet().contains(ctxData.flowName)
           && checkLastPage && ctxData.modeValue != SSP_FrameworkConstants.RACMODE){
               NavFlowStatus__c flowStatusObject = NavFlowManager.getNavFlowStatus(ctx, ctxData);
               //Review Required 
              Boolean reviewRequiredFlag = false;
               if(flowStatusObject != null && ctxData.modeValue != 'RAC' && flowStatusObject.Screen_Status__c != null){
                   Map<String,Object> screenStatusMap = (Map<String,Object>)JSON.deserializeUntyped(flowStatusObject.Screen_Status__c); 
                   for(String screenObj : screenStatusMap.keySet()){
                            SSP_RulesEngine.ScreenStatus objReview = (SSP_RulesEngine.ScreenStatus)JSON.deserialize(JSON.serialize(screenStatusMap.get(screenObj)),SSP_RulesEngine.ScreenStatus.CLASS);
                            if(objReview.isReviewRequired){
                                reviewRequiredFlag = true;
                                break;
                            }                    
                        }
               }
               //
               if(flowStatusObject != null && flowStatusObject.IsEdit__c && !reviewRequiredFlag){
                   NavFlowManager.resetNavDriver(ctxData.ApplicationId, ctxData.flowName, ctxData.MemberId, ctxData.modeValue, ctxData.queueObject);
               }
               String flowApplicable = NavFlowManager.checkQueuingRules(ctxData.ApplicationId, ctxData.MemberId, ctxData.flowName, ctxData.modeValue);
               PermissionsOrgCache orgRole = new PermissionsOrgCache();
               Map<String,App_Summary_Config__mdt> appMap = (Map<String,App_Summary_Config__mdt>)orgRole.loadAppSummary();
               response.applicableMemberFlow = flowApplicable != null && String.isNotBlank(flowApplicable) && appMap.containsKey(flowApplicable) ?
                   appMap.get(flowApplicable).PageName__c : '';
               response.navigateToSummary = String.isNotBlank(response.applicableMemberFlow) ? false : true; 
           }
        return response; 
        /** */
    }

    /** #379955 fix*/
    private static Integer getNextIndex(Integer currentIndex, String flowStatus){
        Integer nextIndex;
        for(Integer i = currentIndex+1 ; i < flowStatus.length(); i++){
            String screenStatus = String.fromCharArray(new Integer[] {flowStatus.charAt(i)});
            if(String.isNotBlank(screenStatus) && !screenStatus.equalsIgnoreCase('N')){
                nextIndex = i;
                break;
            }
        }
        return nextIndex;
    }
    
    /**
* Determines previous page to load and returns it.
*
* @param ctx Context object
* @param ctxData ContextData object
*
*/
    public static PageToLoad getPrevStep(Context ctx, ContextData ctxData){
        NavFlowPageConfig__mdt pageConfig = null;
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        
        NavFlowStatus__c navFlowStatus = getNavFlowStatus(ctx, ctxData);
        
                
        //String flowStatus = navFlowStatus.FlowPageStatus__c;
        String flowStatus = navFlowStatus.FlowDupStatus__c;
        
        
        String curNavFlowPageConfigId = ctxData.curNavFlowPageConfigId;
        
        
        Integer curIdx = getCurPageIndex(ctx, ctxData, navFlowDetail);
        
        Integer idx = curIdx -1;
        
        
        
        
        
        
        
        
        boolean isFnd = false;
        for(; idx >= 0; idx--){
            if(String.fromCharArray(new Integer[] {flowStatus.charAt(idx)}).equals(STEP_COMPLETE)){
                isFnd = true;
                break;
            }
        }
        if(!isFnd){
            // FIXME revisit this logic
            // No step found. reset to first page
            idx = 0;
        }
        pageConfig = navFlowDetail.Navigation_Flow_Page_Configuration__r[idx];
        
        return preparePageToLoad(ctx, ctxData, pageConfig, navFlowStatus);
        /*



if(isSummaryPage != null && isSummaryPage){
String newflowStatus = flowStatus.substring(0, curIdx);
idx = curIdx;

for(; idx < flowStatus.length(); idx++){
if(String.fromCharArray(new Integer[] {flowStatus.charAt(idx)}).equals(STEP_NOT_REQ)){
newflowStatus += STEP_NOT_REQ;
}
else {
newflowStatus += STEP_REQ;
}
}

navFlowStatus.FlowPageStatus__c = newflowStatus;
NavFlowHelper.storeNavFlowStatus(ctx, navFlowStatus);

}*/
        
    }
    
    //Manjunath
    public static PageToLoad goToPage(Context ctx, ContextData ctxData){
        NavFlowPageConfig__mdt pageConfig = getPageConfigById(ctx, ctxData, ctxData.goToPageConfigId);
        
        
        NavFlowStatus__c navFlowStatus = getNavFlowStatus(ctx, ctxData);       
        //
		String flowDupStatus = navFlowStatus.FlowDupStatus__c;
        String[] flowStatusArray = navFlowStatus.FlowPageStatus__c.split('');        
        
        NavFlowDetail__mdt flowDetail = getNavFlowDetail(ctx,ctxData);
        Map<Id,Integer> intPageCOnfigIdMap = new Map<Id,Integer>();
        for(integer i=0; i<flowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
            intPageConfigIdMap.put(flowDetail.Navigation_Flow_Page_Configuration__r[i].Id,i);
        }
        
        if(flowDupStatus != null && String.isNotBlank(flowDupStatus) && !flowDupStatus.contains('R') ){
            Integer idx = intPageConfigIdMap.get(ctxData.goToPageConfigId);            
            
            for(Integer i=0; i<flowStatusArray.size(); i++){
                if(i<idx){
                    flowStatusArray[i] = flowDupStatus.split('')[i];
                }
            }
            
            String updatedValue = String.join(flowStatusArray,'');
            
            navFlowStatus.FlowPageStatus__c = updatedValue;
            if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
                update navFlowStatus;
            }  
        }
        return preparePageToLoad(ctx, ctxData, pageConfig, navFlowStatus);
    }
    
    /**
* Updates flow steps' status. Flow status are stored in NavFlowStatus__c object.
*
* @param ctx Context object
* @param ctxData ContextData object
* @param view View object. Current page's view object.
*
*/
    /*public static void updateFlowStatuses(Context ctx, ContextData ctxData){
        
        
        String curNavFlowPageConfigId = ctxData.curNavFlowPageConfigId;
        NavFlowPageConfig__mdt pageConfig = getPageConfigById(ctx, ctxData, curNavFlowPageConfigId);
        
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        
        NavFlowStatus__c navFlowStatus = getNavFlowStatus(ctx, ctxData);
        
        if(null == navFlowStatus){
            navFlowStatus = new NavFlowStatus__c();
            navFlowStatus.Contact__c = ctxData.contactId;
            navFlowStatus.NavFlowName__c = ctxData.flowName;
            navFlowStatus.InitiatedUser__c = UserInfo.getUserId();
            // now determined the pages' statuses
            navFlowStatus.FlowPageStatus__c = initNavFlowStatuses(ctx, ctxData);
            //NavFlowHelper.storeNavFlowStatus(navFlowStatus);
        }
        navFlowStatus.RecordId__c = ctxData.recordId;
        Integer idx = getCurPageIndex(ctx, ctxData, navFlowDetail);
        
        
        // set current screen status
        // default to 'Complete'
        String stepStatus = STEP_COMPLETE;
        
        if(null != pageConfig.NavFlowRule__c ){
            // trigger current step's flow rule to determine if step is really completed.
            //
            if(!NavFlowRulesEngine.getInstance().isCompleted(ctx, ctxData, pageConfig.NavFlowRule__c)){
                stepStatus = STEP_REQ;
            }
        }
        navFlowStatus.FlowPageStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, idx, stepStatus);
        
        // update listener steps' status, if any        
        if(String.isNotBlank(pageConfig.ListenerPageNames__c)){
            String[] listenerSteps = pageConfig.ListenerPageNames__c.trim().split(',');
            for(String listenerStep : listenerSteps){
                updateListenerStepStatus(ctx, ctxData, listenerStep.trim(), navFlowStatus);             
            }
        }
        NavFlowHelper.storeNavFlowStatus(ctx, navFlowStatus, ctxData);
        ctxData.navFlowStatusId = navFlowStatus.Id;
    }*/
    
    //Shikha:created a newMethod to update flow step status to N when the user has not selected it
    public static void FlowStatusUpdate(Context ctx, ContextData ctxData){
        
        
        List<String> selectedPages = ctxData.SelectedScreen;
        //List<String> lstOfSelectedPrograms = new List<String>{'SNAP'};
        List<String> lstOfSelectedPrograms = ctxData.SelectedPrograms;
        
        
        String curNavFlowPageConfigId = ctxData.curNavFlowPageConfigId;
        NavFlowPageConfig__mdt pageConfig = getPageConfigById(ctx, ctxData, curNavFlowPageConfigId);
        
        ctxData.strCurrPageName = pageConfig.PageInfo__r.PageName__c;
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        
        Map<String,Integer> PageIntegerMap = new Map<String,Integer>();
        Set<Integer> RulePages = new Set<Integer>();
        Set<Integer> setOfNoMedicadePrgm = new Set<Integer>();
        Map<String,String> PageNameVsDispName = new Map<String,String>();
        
        for(integer i=0; i<navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
            PageIntegerMap.put(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c,i);
            PageNameVsDispName.put(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.Page_Display_Name_View__c,navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c);
            
            /*if(!lstOfSelectedPrograms.isEmpty() && lstOfSelectedPrograms.contains(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].Programs__c))
{
selectedPages.add(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c);

}*/
            if(!lstOfSelectedPrograms.isEmpty() && navFlowDetail.Navigation_Flow_Page_Configuration__r[i].Programs__c != null)
            {
                List<String> lstOfSplitPrgm = navFlowDetail.Navigation_Flow_Page_Configuration__r[i].Programs__c.split(',');
                
                for(String prgm: lstOfSplitPrgm)
                {
                    for(String selectedPrgm: lstOfSelectedPrograms)
                    {
                        //
                        //if selected program matches and selected programs list does not contain this program then add
                        if(prgm == selectedPrgm && !selectedPages.contains(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c) )
                        {
                            selectedPages.add(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c);
                            
                            break;
                        }
                    }
                }
                // } commented by AI            
                
                
                if(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].NavFlowRule__c != null){
                    boolean RulepageVal = NavFlowRulesEngine.getInstance().isRequired(ctx, ctxData, navFlowDetail.Navigation_Flow_Page_Configuration__r[i].NavFlowRule__c);
                    
                    
                    
                    if(RulepageVal == true){
                        RulePages.add(i);
                    }
                    else if(RulepageVal == false && !selectedPages.isEmpty() && (selectedPages.indexOf(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c) != -1) ){ //(selectedPages.size()+1)>= i && selectedPages.get(i)!= null
                        selectedPages.remove(selectedPages.indexOf(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c)); //selectedPages.remove(i);
                    }else{
                        setOfNoMedicadePrgm.add(i);
                    }
                    
                    
                    
                }            
            }//added by AI
        }
        
        
        NavFlowStatus__c navFlowStatus = getNavFlowStatus(ctx, ctxData);
        
        if(null == navFlowStatus){
            navFlowStatus = new NavFlowStatus__c();
            navFlowStatus.Contact__c = ctxData.contactId;
            navFlowStatus.NavFlowName__c = ctxData.flowName;
            // now determined the pages' statuses
            navFlowStatus.FlowPageStatus__c = initNavFlowStatuses(ctx, ctxData);            
        }
        
        if(!selectedPages.isEmpty()){
            String flowStatus = navFlowStatus.FlowPageStatus__c;            
            Set<Integer> indexValuesSet = new Set<Integer>();
            for(integer i=0; i <selectedPages.size(); i++){
                if(PageIntegerMap.containsKey(selectedPages[i])){
                    Integer seqidx = PageIntegerMap.get(selectedPages[i]);                    
                    indexValuesSet.add(seqidx);
                }
            }
            indexValuesSet.addAll(RulePages);
            
            for(integer i=0; i < flowstatus.split('').size(); i++){
                if(!indexValuesSet.contains(i)){
                    flowstatus = CommonUtil.replaceString(flowStatus, i, 'N');
                }//&& flowstatus.charAt(i) != 67
                else if(indexValuesSet.contains(i)  && !setOfNoMedicadePrgm.contains(i)){
                    flowstatus = CommonUtil.replaceString(flowStatus, i, 'R');
                }
            }
            navFlowStatus.FlowPageStatus__c = flowStatus;
        }
        
        navFlowStatus.RecordId__c = ctxData.recordId;
        Integer idx = getCurPageIndex(ctx, ctxData, navFlowDetail);
        
        
        // set current screen status
        // default to 'Complete'
        String stepStatus = STEP_COMPLETE;
        
        
        if(null != pageConfig.NavFlowRule__c ){
            // trigger current step's flow rule to determine if step is really completed.
            //
            if(!NavFlowRulesEngine.getInstance().isCompleted(ctx, ctxData, pageConfig.NavFlowRule__c)){
                stepStatus = STEP_REQ;
            }
        }
        String oldStatus = navFlowStatus.FlowPageStatus__c;
        navFlowStatus.FlowPageStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, idx, stepStatus);
        if(navFlowStatus != null && navFlowStatus.FlowDupStatus__c == null && navFlowStatus.FlowPageStatus__c != null){            
            navFlowStatus.FlowDupStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, idx, stepStatus);
        }
        else if(navFlowStatus.FlowPageStatus__c != null && navFlowStatus.FlowDupStatus__c != null && !(navFlowStatus.FlowDupStatus__c).split('').contains('R')){
            Map<String, String> statusMap = compareStatus(navFlowStatus.FlowDupStatus__c, navFlowStatus.FlowPageStatus__c);
            navFlowStatus.FlowPageStatus__c = statusMap != null && statusMap.containsKey('flowStatus') ? statusMap.get('flowStatus') : navFlowStatus.FlowPageStatus__c;
            navFlowStatus.FlowDupStatus__c = statusMap != null && statusMap.containsKey('dupStatus') ? statusMap.get('dupStatus') : navFlowStatus.FlowDupStatus__c;            
        }
        else if(navFlowStatus.FlowDupStatus__c != null && navFlowStatus.FlowDupStatus__c.charAt(idx) != 67 ){
            navFlowStatus.FlowDupStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, idx, stepStatus);
        }  
        
        // update listener steps' status, if any        
        if(String.isNotBlank(pageConfig.ListenerPageNames__c)){
            String[] listenerSteps = pageConfig.ListenerPageNames__c.trim().split(',');
            for(String listenerStep : listenerSteps){
                navFlowStatus = updateListenerStepStatus(ctx, ctxData, listenerStep.trim(), navFlowStatus);             
            }
        }
        // Added by Durga Prasad
        navFlowStatus.InitiatedUser__c = UserInfo.getUserId();
        //Shikha: added new field Values in load flow.
        
        navFlowStatus.Community_Page_URL__c = navFlowDetail.Community_Page_URL__c;
        //Shikha: added Application id and Member Id
        navFlowStatus.SSPApplication__c = ctxData.ApplicationId;
        navFlowStatus.Member__c = ctxData.MemberId;
        
        String flowCalcJSON = NavFlowStatJSONCLone.createScreenStatusJSON(ctxData,navFlowStatus,navFlowDetail,null,oldStatus);
        
        navFlowStatus.Screen_Status__c = flowCalcJSON;
        //Shikha - start no flow status RR
        if(ctxData.noFlowStatusRRPages != null && !ctxData.noFlowStatusRRPages.isEmpty()){
            
            Set<String> RRpageSet = new Set<String>();
            for(String str : ctxData.noFlowStatusRRPages){
                String noFlowDupStatus = navFlowStatus.FlowDupStatus__c;
                String[] noFlowDupStatusArray = noFlowDupStatus != null ? noFlowDupStatus.split('') : new List<String>();                
                if(PageNameVsDispName.containsKey(str) && PageNameVsDispName.get(str) != ctxData.strCurrPageName){
                    RRpageSet.add(PageNameVsDispName.get(str));
                }
            }
            //getFlowStatuses            
            
            Map<String,Object> mapScreenStatus = new Map<String,Object>();
            for(String revPage : RRpageSet){
                
            	if(navFlowStatus.Screen_Status__c != null){                
                    mapScreenStatus = (Map<String,Object>)JSON.deserializeUntyped(navFlowStatus.Screen_Status__c);
                    Object obj = (Object)mapScreenStatus.get(revPage);                    
                    SSP_RulesEngine.ScreenStatus screenStatus = (SSP_RulesEngine.ScreenStatus)JSON.deserialize(JSON.serialize(obj), SSP_RulesEngine.ScreenStatus.class);                     
                    screenStatus.isReviewRequired = screenStatus.Status != 'C' ? true : screenStatus.isReviewRequired;                    
                    mapScreenStatus.put(revPage, screenStatus);                    
            	}   
            }  
            
            if(!RRpageSet.isEmpty()){
             	navFlowStatus.Screen_Status__c = JSON.serialize(mapScreenStatus);   
            }            
            
        }
        //Shikha - end
        if(ctxData.flowName != 'Report a change Member')
            NavFlowHelper.storeNavFlowStatus(ctx, navFlowStatus, ctxData);
        else
            NavFlowHelper.storeNavFlowRACStatus(ctx,ctxData,navFlowStatus);
        ctxData.navFlowStatusId = navFlowStatus.Id;
        
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         04/01/2019
    * @methodname   compareStatus
    * @description  This method is used to maintain sync in between FlowPageStatus and FlowDupStatus
    * @return       Map<String,String> :  <flowStatus, dupStatus>
    *****************************************************************************************************/
    public static Map<String, String> compareStatus(String dupStatus, String flowStatus){
        List<String> dupStatusList = dupStatus.split('');
        List<String> flowStatusList = flowStatus.split('');
        Map<String, String> statusMap = new Map<String, String>();
        flowStatus = '';
        dupStatus = '';
        List<Integer> changedIndexList_NtoR = new List<Integer>(); 
        Boolean resetFlowPageStatus = false;

        for(Integer i = 0; i < flowStatusList.size(); i++){
            String dupStatusChar = dupStatusList.get(i);
            //if generated flow status screen is N and corresponding value in dup status is 'C' OR 'R', make it N
            if((flowStatusList.get(i).equalsIgnoreCase('N') && !dupStatusChar.equalsIgnoreCase('N'))){
                dupStatusChar = 'N';
            }

            //if generated flow status screen is R and corresponding value in dup status is 'N'
            else if(flowStatusList.get(i).equalsIgnoreCase('R') && dupStatusList.get(i).equalsIgnoreCase('N')){
                dupStatusChar = 'R';
                if(!resetFlowPageStatus && i > 0){
                    resetFlowPageStatus = true;                 
                }
                changedIndexList_NtoR.add(i);
            }

            dupStatus += dupStatusChar;
        }
        
        //if a sValue is changed from N to R, make all R's as C's before that entry in flowPageStatus
        //if a more than one sValue's are changed from N to R, make all R's as C's before the last changed entry, keeping N to R entries as same
        if(resetFlowPageStatus){
            changedIndexList_NtoR.sort();
            for(Integer i = 0; i <= changedIndexList_NtoR.get(changedIndexList_NtoR.size()-1); i++){
                if(!changedIndexList_NtoR.contains(i) && flowStatusList.get(i).equalsIgnoreCase('R')){
                    flowStatusList[i] = 'C';
                }
            }

        }

        return new Map<String, String>{'flowStatus'=>String.join(flowStatusList, ''),
                                    'dupStatus'=>dupStatus};
    }
    
    
    //Shikha: created a new method to update flow status with new method
    /*public static void updateFlowStatusUsingMap(Context ctx, ContextData ctxData){
        
        
        String curNavFlowPageConfigId = ctxData.curNavFlowPageConfigId;
        NavFlowPageConfig__mdt pageConfig = getPageConfigById(ctx, ctxData, curNavFlowPageConfigId);
        
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        
        NavFlowStatus__c navFlowStatus = getNavFlowStatus(ctx, ctxData);
        
        Map<String,String> navStatusMap = new Map<String,String>();
        if(null == navFlowStatus){
            navFlowStatus = new NavFlowStatus__c();
            navFlowStatus.Contact__c = ctxData.contactId;
            navFlowStatus.NavFlowName__c = ctxData.flowName;  
            navFlowStatus.InitiatedUser__c = UserInfo.getUserId();
            
            navStatusMap = initNavFlowStatus(ctx, ctxData);  
            //navFlowStatus.FlowPageStatus__c
            String status = '';
            for(NavFlowPageConfig__mdt nav : navFlowDetail.Navigation_Flow_Page_Configuration__r){
                if(navStatusMap.containsKey(nav.PageInfo__r.PageName__c))
                    status += navStatusMap.get(nav.PageInfo__r.PageName__c);
            }
            navFlowStatus.FlowPageStatus__c = status;
        }
        navFlowStatus.RecordId__c = ctxData.recordId;
        Integer idx = getCurPageIndex(ctx, ctxData, navFlowDetail);
        
        
        String stepStatus = STEP_COMPLETE;
        
        if(null != pageConfig.NavFlowRule__c ){           
            if(!NavFlowRulesEngine.getInstance().isCompleted(ctx, ctxData, pageConfig.NavFlowRule__c)){
                stepStatus = STEP_REQ;
            }
        }
        navFlowStatus.FlowPageStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, idx, stepStatus);
        
        // update listener steps' status, if any        
        if(String.isNotBlank(pageConfig.ListenerPageNames__c)){
            String[] listenerSteps = pageConfig.ListenerPageNames__c.trim().split(',');
            for(String listenerStep : listenerSteps){
                updateListenerStepStatus(ctx, ctxData, listenerStep.trim(), navFlowStatus);             
            }
        }
        NavFlowHelper.storeNavFlowStatus(ctx, navFlowStatus, ctxData);
        ctxData.navFlowStatusId = navFlowStatus.Id;
    }*/
    
    /**
* Initializes flow status for the given flow.
*
* @param ctx Context object
* @param ctxData ContextData object
*
*/
    //Shikha: changing access modifier to public
    public static String initNavFlowStatuses(Context ctx, ContextData ctxData){
        String status = '';
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        
        if(null == navFlowDetail || null == navFlowDetail.Navigation_Flow_Page_Configuration__r){
            throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Flow step configuration not found for flow name [' + ctxData.flowName + ']');
        }
        for(NavFlowPageConfig__mdt pageConfig : navFlowDetail.Navigation_Flow_Page_Configuration__r) {
            // below default logic is commented on 11/08/2018. Instead, the nav flow rules will be triggered for all the steps
            // by default page is required if there is no flow rule. If a page has flow rule then it will be executed as part of listner step rules to determine its status.
            //boolean isReq = (null == pageConfig.NavFlowRule__c);
            //status +=  (isReq ? STEP_REQ : STEP_NOT_REQ);
            

             /**CD2 2.5 Security Role Matrix and Program Access. */
            SSP_Utility.SecurityMatrixWrapper securityMatrix = SSP_Utility.getScreenAccessDetails(pageConfig.PageInfo__r.PageName__c, null);
            Boolean isNotAccessible = securityMatrix != null && String.isNotBlank(securityMatrix.screenPermission) && securityMatrix.screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE);             
            /** */

            // below new logic added on 11/08/2018
            boolean hasRule = isNotAccessible ? false : (null != pageConfig.NavFlowRule__c); //CD2 2.5 Security Role Matrix and Program Access.
            //
            //
            status +=  (hasRule ? (NavFlowRulesEngine.getInstance().isRequired(ctx, ctxData, pageConfig.NavFlowRule__c) ? STEP_REQ : STEP_NOT_REQ) : (isNotAccessible ? STEP_NOT_REQ : STEP_REQ)); //CD2 2.5 Security Role Matrix and Program Access.
            //
            //status +=  (hasRule ? (NavFlowRulesEngine.getInstance().isRequired(ctx, ctxData, pageConfig.NavFlowRule__c) ? STEP_REQ : STEP_NOT_REQ) : STEP_REQ);
        }
        
        return status;
    }
    
    //Added by Nupoor
    //public static Boolean isUpserted = false;
    public static String initNavFlowRACStatuses(Context ctx, ContextData ctxData, NavFlowStatus__c navFlowStatus) {
        String status = '';
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        Map<String, Integer> PageIntegerMap = new Map<String, Integer>();
        ctxData.SelectedScreen = NavFlowController.getMemberDetails(ctxData.ApplicationId, ctxData.MemberId, ctxData.flowName, ctxData.modeValue);
        for(integer i=0; i < navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++) {
            PageIntegerMap.put(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c,i);
        }
        if(null == navFlowDetail || null == navFlowDetail.Navigation_Flow_Page_Configuration__r) {
            throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Flow step configuration not found for flow name [' + ctxData.flowName + ']');
        }
        List<NavFlowStatus__c> navFlowStatList = NavFlowHelper.getNavFlowRACStatus(ctxData.MemberId, ctxData.ApplicationId, ctxData.flowName);        
        String reviewRequiredFlowStatus;
        Boolean reviewRequired = false;
        if( !navFlowStatList.isEmpty() && ctxData.modeValue == 'RAC' ){
            if(navFlowStatList[0] != null && navFlowStatList[0].Screen_Status__c != null){
           	for(NavFlowStatus__c flowStat : navFlowStatList){
                if(flowStat.Screen_Status__c != null){                   
                Map<String,Object> screenStatusMap = (Map<String,Object>)JSON.deserializeUntyped(flowStat.Screen_Status__c); 
                for(String screenObj : screenStatusMap.keySet()){
                    SSP_RulesEngine.ScreenStatus objReview = (SSP_RulesEngine.ScreenStatus)JSON.deserialize(JSON.serialize(screenStatusMap.get(screenObj)),SSP_RulesEngine.ScreenStatus.CLASS);
                    if(objReview.isReviewRequired){
                        reviewRequired = true;
                        break;
                    }                    
                }
                
            	}
            }
                //String reviewStatus = navFlowStatList[0].Screen_Status__c;
                //String reviewRequiredStatusTocheck = '\"isReviewRequired\":true';
                //reviewRequired = reviewStatus.contains(reviewRequiredStatusTocheck);
                if(reviewRequired){
                    reviewRequiredFlowStatus = navFlowStatList[0].FlowPageStatus__c;
                }
            }
        }
        for(NavFlowPageConfig__mdt pageConfig : navFlowDetail.Navigation_Flow_Page_Configuration__r) { 
            Boolean isRequired = ctxData.modeValue == 'addRemoveMember';
            //TODO: apply programs applied filter
            if(null != pageConfig.NavFlowRule__c) {
                isRequired = NavFlowRulesEngine.getInstance().isRequired(ctx, ctxData, pageConfig.NavFlowRule__c);
            }
            if(ctxData.modeValue == 'RAC' && ctxData.selectedScreen != null) {
                //isRequired = isRequired || ctxData.selectedScreen.contains(pageConfig.PageInfo__r.PageName__c);
                isRequired = ctxData.selectedScreen.contains(pageConfig.PageInfo__r.PageName__c);
            }
            status += isRequired? STEP_REQ : STEP_NOT_REQ;
        }
        if(navFlowStatus != null) {
            navFlowStatus.InitiatedUser__c = UserInfo.getUserId();
            navFlowStatus.SSPApplication__c = ctxData.ApplicationId;
            navFlowStatus.Member__c = ctxData.MemberId;
            navFlowStatus.FlowPageStatus__c = status;                        
            
            if(isLoadRACFlow){
                navFlowStatus.FlowDupStatus__c = navFlowStatus.FlowDupStatus__c != null ? navFlowStatus.FlowDupStatus__c : status;            
                navFlowStatus.Screen_Status__c = NavFlowStatJSONCLone.createScreenStatusJSON(ctxData,navFlowStatus,navFlowDetail,null,navFlowStatus.FlowPageStatus__c);             
                ctxData.flowDuplicateStatus = navFlowStatus.FlowDupStatus__c ;
            	navFlowStatus = NavFlowHelper.storeNavFlowRACStatus(ctx, ctxData, navFlowStatus);
                isLoadRACFlow = false;
            }
            
            ctxData.navFlowStatusId = navFlowStatus.Id;
            ctxData.navFlowStatus = navFlowStatus;   
        }
        else{
            NavFlowStatus__c flowStatusObj = new NavFlowStatus__c();
            flowStatusObj.FlowPageStatus__c = status;
            //flowStatusObj.FlowDupStatus__c = navFlowStatus.FlowDupStatus__c;
            //return flowStatusObj;
        }
        if(ctxData.modeValue == 'RAC' && reviewRequired){
            status = reviewRequiredFlowStatus;
        }
        return status;
    }
    
    //Shikha: added new function to init flow status to save flwstatus based on pages to be loaded
    public static Map<String,String> initNavFlowStatus(Context ctx, ContextData ctxData){
        Map<String,String> statusMap = new Map<String,String>();
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        if(null == navFlowDetail || null == navFlowDetail.Navigation_Flow_Page_Configuration__r){
            throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Flow step configuration not found for flow name [' + ctxData.flowName + ']');
        }
        for(NavFlowPageConfig__mdt pageConfig : navFlowDetail.Navigation_Flow_Page_Configuration__r) {
            boolean hasRule = (null != pageConfig.NavFlowRule__c);
            statusMap.put(pageConfig.PageInfo__r.PageName__c,(hasRule ? (NavFlowRulesEngine.getInstance().isRequired(ctx, ctxData, pageConfig.NavFlowRule__c) ? STEP_REQ : STEP_NOT_REQ) : STEP_REQ));
        }
        return statusMap;
    }
    /**
* Returns navigation flow configuration for the given flow. Flow configuration is read from NavFlowConfig__c object and cached in the ContextData for subsequent uses.
*
* @param ctx Context object
* @param ctxData ContextData object
* @param flowName String flow name whose configuration is being fetched.
*
* @return NavFlowConfig
*/ 
    public static NavFlowDetail__mdt getNavFlowDetail(Context ctx, ContextData ctxData){
        NavFlowDetail__mdt navFlowDetail = ctxData.navFlowDetail;
        if(null == navFlowDetail || !ctxData.flowName.equals(navFlowDetail.FlowName__c)){   
            //Shikha: added Selected Screen argument
            navFlowDetail = NavFlowHelper.getNavFlowDetail(ctx, ctxData.flowName, ctxData.SelectedScreen);   
        }
        ctxData.navFlowDetail = navFlowDetail;
        return navFlowDetail;
    }
    
    private static NavFlowStatus__c getNavFlowStatus(Context ctx, ContextData ctxData){
        NavFlowStatus__c navFlowStatus = ctxData.navFlowStatus;
        if(null == navFlowStatus){
            navFlowStatus = NavFlowHelper.getNavFlowStatus(ctx, ctxData.navFlowStatusId);
        }        
        
        ctxData.navFlowStatus = navFlowStatus;
        return navFlowStatus;
    }
    
    
    
    
    /**
* Returns List of group names in the given flow.
*
* @param ctx Context object
* @param ctxData ContextData object
* @param flowName Flow name to check.
*
* @return List of String
*/
    private static List<PageGroupInfo> getNavFlowPageGroupInfos(Context ctx, ContextData ctxData, NavFlowStatus__c navFlowStatus){
        
        List<PageGroupInfo> groupInfos = new List<PageGroupInfo>();
        Set<String> nfGroupNames = new Set<String>();
        Map<String, PageGroupInfo> groupMap = new Map<String, PageGroupInfo>();
        Integer[] pageStatusArr = navFlowStatus.FlowPageStatus__c.getChars();
        //Shikha - added new Integer val
        Integer[] pageDupStatusArr = new List<Integer>();
        //ctxData.action != 'loadFlow' && 
        if(navFlowStatus.FlowDupStatus__c != null){
        	pageDupStatusArr = navFlowStatus.FlowDupStatus__c.getChars();
        }
        Integer idx = 0;
        for(NavFlowPageConfig__mdt pageConfig : ctxData.navFlowDetail.Navigation_Flow_Page_Configuration__r) {
            String groupName = String.isNotBlank(pageConfig.SectionGroupName__c) ? pageConfig.SectionGroupName__c : (String.isNotBlank(pageConfig.Page_Config_Display_Name_View__c) ? pageConfig.Page_Config_Display_Name_View__c : pageConfig.PageInfo__r.Page_Display_Name_View__c);
                Integer status = pageStatusArr[idx];
                Integer dupStatus;
            if(!pageDupStatusArr.isEmpty() && pageDupStatusArr[idx] != null){
             	dupStatus = pageDupStatusArr[idx];   
            }
            
            PageGroupInfo groupInfo = groupMap.get(groupName);
            if(!nfGroupNames.contains(groupName)) {
                groupInfo = new PageGroupInfo(groupName);
                groupInfos.add(groupInfo);
                nfGroupNames.add(groupName);
                groupMap.put(groupName, groupInfo);
                if(groupName.equals(ctxData.curPageGroupName)) {
                    groupInfo.isCurrent = true;
                }
            }
            groupMap.get(groupName).pageStatuses.add(status);
            
            if(dupStatus != 0){
                groupMap.get(groupName).pageDupStatuses.add(dupStatus);   
           }
            // set the page to load when group is clicked.
            if(null == groupInfo.goToPageConfigId  && status != 78){
                groupInfo.goToPageConfigId  = pageConfig.Id;
            }
            groupInfo.pageInfos.add(new PageGroupInfo.PageInfo(pageConfig.PageInfo__r.PageName__c, (String.isNotBlank(pageConfig.Page_Config_Display_Name_View__c) ? pageConfig.Page_Config_Display_Name_View__c : pageConfig.PageInfo__r.Page_Display_Name_View__c), pageConfig.Id, status, dupStatus));
            idx++;
        }
        
        // now determine the groups statuses
        for(PageGroupInfo groupInfo : groupInfos) {
            // start with hidden status and then trickle down
            /* Chars are as follows : 
R (required) -> 82
N (not required) -> 78
C (completed) -> 67
*/
            groupInfo.groupStatus = 'Hidden';
            if(groupInfo.pageStatuses.contains(67)) {
                // page is completed.
                groupInfo.groupStatus = 'Completed';
            }
            if(groupInfo.pageStatuses.contains(82)) {
                // page is required.
                if('Completed'.equals(groupInfo.groupStatus)) {
                    // at least one page is completed. So mark the group as incomplete
                    groupInfo.groupStatus = 'Incomplete';
                }
                else {
                    // None of the page is completed. So mark the group as disabled
                    groupInfo.groupStatus = 'Disabled';
                }
            }
        }
        return groupInfos;
    }
    
    // Returns current page's index in the flow.
    private static Integer getCurPageIndex(Context ctx, ContextData ctxData, NavFlowDetail__mdt navFlowDetail) {
        Integer curIdx = 0;
        String curNavFlowPageConfigId = ctxData.curNavFlowPageConfigId;
        for(Integer i=0; i < navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++) {
            if(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].Id.equals(curNavFlowPageConfigId)){
                curIdx = i;
                break;
            }
        }
        return curIdx;
    }
    
    /**
* Updates current page's listener pages' status based on their flow rule output.
*
* @param ctx Context object
* @param ctxData ContextData object
* @param pageName String. Page name whose status needs to be updated.
* @param nfStatusDO NavFlowStatus__c object containing status of the flow.
* @param view View object. Current page's view object.
*
* @return NavFlowStatus__c
*/ 
    public static NavFlowStatus__c updateListenerStepStatus(Context ctx, ContextData ctxData, String pageName, NavFlowStatus__c navFlowStatus){
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        NavFlowPageConfig__mdt pageConfig = getPageConfigByPageName(ctx, ctxData, pageName);
        if(null != pageConfig.NavFlowRule__c){
            navFlowStatus = triggerStepRule(ctx, ctxData, pageConfig, navFlowStatus);
        }
        return navFlowStatus;
    }
    
    /**
* Triggers page's flow rule and updates the page's status accordingly.
*
* @param ctx Context object
* @param ctxData ContextData object
* @param pageInf PageInfo of the page to be updated.
* @param nfStatusDO NavFlowStatus__c object containing status of the flow.
* @param view View object. Current page's view object.
*
* @return NavFlowStatus__c
*/ 
    private static NavFlowStatus__c triggerStepRule(Context ctx, ContextData ctxData, NavFlowPageConfig__mdt pageConfig, NavFlowStatus__c navFlowStatus){
        // TODO Need to trigger separate rules for required, complete & not required methods and do the mutual exclusive to determine final status.
        String stepStatus = NavFlowRulesEngine.getInstance().isRequired(ctx, ctxData, pageConfig.NavFlowRule__c) ? STEP_REQ : STEP_NOT_REQ;
        navFlowStatus.FlowPageStatus__c = updateStepStatus(ctx, ctxData, navFlowStatus.FlowPageStatus__c, pageConfig.PageInfo__r.PageName__c, stepStatus);
        //Shikha : updating flowDupstatus
        isDupStatus = true;                
        navFlowStatus.FlowDupStatus__c = updateStepStatus(ctx, ctxData, navFlowStatus.FlowDupStatus__c, pageConfig.PageInfo__r.PageName__c, stepStatus);
        isDupStatus = false;
        //
        //Shikha : starting Review Required Logic
       
        if(ctxData.modeValue == 'RAC' && stepStatus == 'R' && !isDupStatus){           
            if(navFlowStatus.Screen_Status__c != null){                
                Map<String,Object> mapScreenStatus = (Map<String,Object>)JSON.deserializeUntyped(navFlowStatus.Screen_Status__c);
                Object obj = (Object)mapScreenStatus.get(pageConfig.PageInfo__r.PageName__c);               
                SSP_RulesEngine.ScreenStatus screenStatus = (SSP_RulesEngine.ScreenStatus)JSON.deserialize(JSON.serialize(obj), SSP_RulesEngine.ScreenStatus.class);                 
                screenStatus.isReviewRequired = true;                
                mapScreenStatus.put(pageConfig.PageInfo__r.PageName__c, screenStatus);
                navFlowStatus.Screen_Status__c = JSON.serialize(mapScreenStatus);
            }
        }       
        return navFlowStatus;
    }
    
    /**
* Updates page's status like completed, required etc. Returns a string with the updated flow status (status of all the pages in the flow).
*
* @param ctx Context object
* @param ctxData ContextData object
* @param flowStatus String. Flow status. This is a string containing all the pages' status in that flow.
* @param pageName String. Page name whose status needs to be updated.
* @param stepStatus String. Page's status.
* @param flowName Flow name to check.
*
* @return String Updated flow status.
*/ 
    private static String updateStepStatus(Context ctx, ContextData ctxData, String flowStatus, String pageName, String stepStatus){
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        NavFlowPageConfig__mdt pageConfig = null;
        Integer idx = 0;
        for(NavFlowPageConfig__mdt itrPageConfig : navFlowDetail.Navigation_Flow_Page_Configuration__r){
            if(itrPageConfig.PageInfo__r.PageName__c.equals(pageName)){
                pageConfig = itrPageConfig;
                break;
            }
            idx++;
        }
        String flowStat = (stepStatus.equalsIgnoreCase('R') && isDupStatus && flowStatus.charAt(idx) == 67) ? flowStatus : 
        CommonUtil.replaceString(flowStatus, idx, stepStatus);    
        
        return flowStat;
    }
    
    
    private static NavFlowPageConfig__mdt getPageConfigByPageName(Context ctx, ContextData ctxData, String pageName) {
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        NavFlowPageConfig__mdt pageConfig = null;
        for(NavFlowPageConfig__mdt itrPageConfig : navFlowDetail.Navigation_Flow_Page_Configuration__r){
            if(itrPageConfig.PageInfo__r.PageName__c.equalsIgnoreCase(pageName)){
                pageConfig = itrPageConfig;
                break;
            }
        }
        return pageConfig;
    }
    
    private static NavFlowPageConfig__mdt getPageConfigById(Context ctx, ContextData ctxData, String pageConfigId) {
        
                
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        
        NavFlowPageConfig__mdt pageConfig = null;
        for(NavFlowPageConfig__mdt itrPageConfig : navFlowDetail.Navigation_Flow_Page_Configuration__r){
            
            if(itrPageConfig.Id.equals(pageConfigId)){
                pageConfig = itrPageConfig;
                break;
            }
        }
        return pageConfig;
    }
    
    @TestVisible
    private static NavFlowPageConfig__mdt getPageConfigByIndex(Context ctx, ContextData ctxData, Integer idx) {
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        return navFlowDetail.Navigation_Flow_Page_Configuration__r[idx];
    }
    
    @TestVisible  
    private static PageToLoad preparePageToLoad(Context ctx, ContextData ctxData, NavFlowPageConfig__mdt pageConfig, NavFlowStatus__c navFlowStatus) {
        
        PageToLoad page = new PageToLoad();
        page.pageConfig = pageConfig;
        page.pageInfo = NavFlowHelper.getPageInfo(ctx, pageConfig.PageInfo__c);
        page.flowName = ctxData.navFlowDetail.FlowName__c;
        page.flowDispName = ctxData.navFlowDetail.FlowDisplayName__c;
        page.navFlowStatusId = ctxData.navFlowStatusId;
        page.navFlowStatusName = ctxData.navFlowStatusName;
        page.contactId = ctxData.contactId;
        page.recordId = ctxData.recordId;
        page.curGroupName = String.isNotBlank(pageConfig.SectionGroupName__c) ? pageConfig.SectionGroupName__c : (String.isNotBlank(pageConfig.Page_Config_Display_Name_View__c) ? pageConfig.Page_Config_Display_Name_View__c : pageConfig.PageInfo__r.Page_Display_Name_View__c);
        page.navButtons = null;
        
        //page.Editable=getLoggedInUserAccess(ctxData.contactId, ctxData.recordId);
        ctxData.curPageGroupName = page.curGroupName;
        page.pageGroupInfos = getNavFlowPageGroupInfos(ctx, ctxData, navFlowStatus);
        //Shikha: added application Id and Member Id
        page.applicationId = ctxData.ApplicationId;
        page.memberId = ctxData.MemberId;
        page = setNavigationDetails( ctx, ctxData, page);
        //Shikha- 
        page.flowStatus = navFlowStatus.FlowDupStatus__c;
        page.flowPageStatus = navFlowStatus.FlowPageStatus__c;
        

        /**CD2 2.5 Security Role Matrix and Program Access. */
        SSP_Utility.SecurityMatrixWrapper securityMatrix = SSP_Utility.getScreenAccessDetails(pageConfig.PageInfo__r.PageName__c, null);
        Boolean isNotAccessible = securityMatrix != null && String.isNotBlank(securityMatrix.screenPermission) && securityMatrix.screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE); 
        page.screenPermission = (securityMatrix != null && securityMatrix.screenPermission != null) ? securityMatrix.screenPermission : 'Editable';
        /** */

        return page;
    }
    @AuraEnabled
    public static boolean getLoggedInUserAccess(String contactId,String recordId){
        String Roles;        
        boolean hasdisabled = true;
        List<String> lstRoles= new List<String>();
        List<RoleAccess__mdt> lstRoleAccess = new List<RoleAccess__mdt>();
        List<AccountContactRelation> lstActCon= new List<AccountContactRelation>();
        
        
        String accountId;
        // lstActCon = [SELECT Id,Roles FROM AccountContactRelation WHERE ContactId =:contactId AND accountID =:recordId];
        
        if(recordId != null && recordId != ''){
            Id appId =(Id)recordId;
            
            String sObjName = appId.getSObjectType().getDescribe().getName();
            if(sObjName == 'SSP_Application__c'){
                
                Set<String> appFieldList = new Set<String>{'Id','Account__c'};
                List<SSP_Application__c> appRecord = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                appFieldList, 
                                                                                new Map<String, String>{'limit'=>'1','Id'=>appId});
                accountId = appRecord.isEmpty() ? appRecord[0].Account__c : null;
                //accountId =[SELECT id,Account__c FROM SSP_Application__c Where Id=:appId].Account__c;
                
            }/*else if(sObjName == 'SSP_JSON__c'){
                accountId =[SELECT id,Account_Household__c FROM SSP_JSON__c Where Id=:recordId].Account_Household__c;
            }*/
            
        }
        if(accountId != null){
            lstActCon = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','Roles'}, 
                                                                              new Map<String, String>{'limit'=>'1000','accountId'=>accountId,'contactId'=>contactId});
            //lstActCon = [SELECT Id,Roles FROM AccountContactRelation WHERE ContactId =:contactId AND isDirect = false AND accountId= :accountId];
        }
        
        if(lstActCon.size()==0){
            hasdisabled = false;
            
        }
        for(AccountContactRelation acr: lstActCon){
            if(acr.Roles != '' && acr.Roles != null){
                lstRoles.addAll(acr.Roles.split(','));
            }
        }
        
        if(Schema.sObjectType.RoleAccess__mdt.isAccessible()){      
            for(RoleAccess__mdt strRole:[SELECT Role__c,Edit__c,Id FROM RoleAccess__mdt WHERE Role__c IN :lstRoles]){
                if(strRole.Edit__c){
                    hasdisabled =false;
                }
            }
        }
        
        return hasdisabled;
    }
    
    public static List<NavFlowStatus__c> resetDriver(Set<Id> applicationIdSet, String flowName){                
        if(applicationIdSet.size() > 0){  
            /*List<SSP_ApplicationIndividual__c> appIndividualList = [SELECT Id,SSP_Member__c, SSP_Application__c 
                                                                    FROM SSP_ApplicationIndividual__c
                                                                    WHERE SSP_Application__c IN :applicationIdSet ];
            List<SSP_Member__c> memberList = [SELECT Id, Name, Application__c
                                             FROM SSP_Member__c
                                             WHERE Application__c IN :applicationIdSet];
            */
            List<NavFlowStatus__c> navFlowStatusList = [SELECT Id, FlowPageStatus__c,NavFlowName__c, FlowDupStatus__c
                                                        FROM NavFlowStatus__c
                                                        WHERE SSPApplication__c = :applicationIdSet
                                                        AND NavFlowName__c = :flowName  ];
            
            for(NavFlowStatus__c navStat : navFlowStatusList){
                ContextData ctxData = new ContextData();
                Context ctx = new Context();
                ctxData.flowName = navStat.NavFlowName__c;
                String flowStatus = NavFlowManager.initNavFlowStatuses(ctx, ctxData);
                navStat.FlowPageStatus__c = flowStatus;
                if(navStat.FlowPageStatus__c != null && navStat.FlowDupStatus__c != null && !(navStat.FlowDupStatus__c).split('').contains('R')){
                    Map<String, String> statusMap = compareStatus(navStat.FlowDupStatus__c, navStat.FlowPageStatus__c);
                    navStat.FlowPageStatus__c = statusMap != null && statusMap.containsKey('flowStatus') ? statusMap.get('flowStatus') : navStat.FlowPageStatus__c;
                    navStat.FlowDupStatus__c = statusMap != null && statusMap.containsKey('dupStatus') ? statusMap.get('dupStatus') : navStat.FlowDupStatus__c;
                }
            }
            
            if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
            	update navFlowStatusList;  
            }            
        }
        return new List<NavFlowStatus__c>();
    }
    
    public static List<NavFlowStatus__c> resetNavDriver(String applicationId, String flowName, String memberId, String mode,
                                                       QueuingWrapper queueObj){                
        if(applicationId != null && flowName != null){              
            List<NavFlowStatus__c> navFlowStatusList = [SELECT Id, FlowPageStatus__c,NavFlowName__c,FlowDupStatus__c, IsStart__c, Screen_Status__c
                                                        FROM NavFlowStatus__c
                                                        WHERE SSPApplication__c = :applicationId
                                                        AND NavFlowName__c = :flowName  
                                                        AND (Member__c =:memberId OR Member__c = null)];
            
            if(navFlowStatusList != null && !navFlowStatusList.isEmpty()){
                ContextData contextValue = new ContextData();
                Context ctxValue = new Context();
                contextValue.flowName = navFlowStatusList[0].NavFlowName__c;
                contextValue.ApplicationId = applicationId;
                contextValue.MemberId = memberId;
                contextValue.modeValue = mode;
                contextValue.queueObject = queueObj;
                
                String flowStatus = '';
                //NavFlowStatus__c navFlowStat = new NavFlowStatus__c();
                if(mode == 'Intake' || mode == 'Renewal') {
                    flowStatus = NavFlowManager.initNavFlowStatuses(ctxValue, contextValue);
                    navFlowStatusList[0].FlowPageStatus__c = flowStatus;
                }
                else {
                    flowStatus = navFlowStatusList[0].FlowDupStatus__c;
                    List<String> flowStatArr = flowStatus.split('');
                    List<String> updFlowStatArr = new List<String>();
                    for(String stat : flowStatArr){
                        if(stat == 'C' || stat == 'R'){
                            updFlowStatArr.add('R');
                        }
                        else{
                            updFlowStatArr.add('N');
                        }
                    }
                    navFlowStatusList[0].FlowPageStatus__c = String.join(updFlowStatArr, '');
                    /*flowStatus = NavFlowManager.initNavFlowRACStatuses(ctxValue, contextValue, navFlowStatusList[0]);
                    navFlowStatusList[0].FlowPageStatus__c = flowStatus;*/
                }
                
                
                if(navFlowStatusList[0].IsStart__c){
                    navFlowStatusList[0].FlowDupStatus__c = flowStatus;
                }
                if(navFlowStatusList[0].FlowPageStatus__c != null && navFlowStatusList[0].FlowDupStatus__c != null && !(navFlowStatusList[0].FlowDupStatus__c).split('').contains('R')){
                    Map<String, String> statusMap = compareStatus(navFlowStatusList[0].FlowDupStatus__c, navFlowStatusList[0].FlowPageStatus__c);
                    navFlowStatusList[0].FlowPageStatus__c = statusMap != null && statusMap.containsKey('flowStatus') ? statusMap.get('flowStatus') : navFlowStatusList[0].FlowPageStatus__c;
                    navFlowStatusList[0].FlowDupStatus__c = statusMap != null && statusMap.containsKey('dupStatus') ? statusMap.get('dupStatus') : navFlowStatusList[0].FlowDupStatus__c;
                }                                      
            	
            	if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
            		update navFlowStatusList;  
                }  
                ctxValue = new Context();
                contextValue = new ContextData();
            }
        }
        return new List<NavFlowStatus__c>();
    }
    
    public static List<NavFlowStatus__c> resetDriver(Set<Id> applicationIdSet) {
        if(applicationIdSet.size() > 0) {
            List<NavFlowStatus__c> navFlowStatusList = [SELECT Id, FlowPageStatus__c,NavFlowName__c
                                                        FROM NavFlowStatus__c
                                                        WHERE SSPApplication__c = :applicationIdSet];
            for(NavFlowStatus__c navStat : navFlowStatusList){
                ContextData ctxData = new ContextData();
                Context ctx = new Context();
                ctxData.flowName = navStat.NavFlowName__c;
                String flowStatus = NavFlowManager.initNavFlowStatuses(ctx, ctxData);
                navStat.FlowPageStatus__c = flowStatus;
            }
            if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
            	update navFlowStatusList;
            }
            return navFlowStatusList;
        }
        return new List<NavFlowStatus__c>();
    }
    
    @AuraEnabled
    public static void updateReviewRequiredFlow(String applicationId, String memberId, List<String> affectedScreens){
        SSP_Utility.isAuthenticatedUser();
        List<NavFlowPageConfig__mdt> lstNavFlowObj = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__r.FlowName__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                                                      PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c
                                                      FROM NavFlowPageConfig__mdt
                                                      WHERE IsActive__c = TRUE                                  
                                                      AND NavigationFlowDetail__r.FlowName__c = 'ContactInformation'
                                                      order by SequenceNumber__c];                                 
        
        
        Map<String,Integer> PageIntegerMap = new Map<String, Integer>();    
        for(Integer i=0; i<lstNavFlowObj.size(); i++){
            PageIntegerMap.put(lstNavFlowObj[i].PageInfo__r.PageName__c, i);        
        }
        
        
        List<NavFlowStatus__c> lstFlowStatus = [Select SSPApplication__c, Member__c, FlowPageStatus__c from NavFlowStatus__c 
                                                where SSPApplication__c = :applicationId and Member__c = :memberId];
        for(NavFlowStatus__c flow : lstFlowStatus){
            String status = flow.FlowPageStatus__c;
            for(String str : affectedScreens ){
                
                
                
                if(status.charAt(PageIntegerMap.get(str)) == 67)
                    status = CommonUtil.replaceString(status, PageIntegerMap.get(str), 'R');    
            }
            flow.FlowPageStatus__c = status;
        }
        
        if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
        	update lstFlowStatus;
		}
    }
    
    //Need to add screen status while updating
    //Remove flow status check of C
    
    /*public static void updateReviewRequiredFlowStatus(String applicationId, String memberId, String selectedScreen,
                                                      List<SSP_RulesEngine.ReviewRequiredScreenWrapper> affectedScreens,
                                                      Map<String,Boolean> mapScreenRuleResult,
                                                      Set<String> lstMemberIds
                                                     )
    {        
        if(lstMemberIds.contains('null')){
            lstMemberIds.remove('null'); 
            lstMemberIds.add(null);
        }
        List<String> lstFlowNames = new List<String>();
        Map<String, Map<String,Set<String>>> mapMemberFlowAffectedScreens = new Map<String, Map<String,Set<String>>>();        
        for(SSP_RulesEngine.ReviewRequiredScreenWrapper wrapper : affectedScreens)
        {
            lstFlowNames.add(wrapper.flowName); 
            for(String member : wrapper.memberIds)
            {
                String memberToUse = (member!='null')?member:null;
                if(mapMemberFlowAffectedScreens.containsKey(memberToUse))
                {
                    Map<String,Set<String>> mapFlowScreens = mapMemberFlowAffectedScreens.get(memberToUse);
                    //Shikha: added
                    if(mapFlowScreens.containsKey(wrapper.flowName)){
                        mapFlowScreens.get(wrapper.flowName).addAll(wrapper.affectedScreen);                        
                    }
                    else{
                        mapFlowScreens.put(wrapper.flowName, wrapper.affectedScreen);   
                    }                    
                    mapMemberFlowAffectedScreens.put(memberToUse, mapFlowScreens);            
                }
                else
                {
                    Map<String,Set<String>> mapFlowScreens = new Map<String,Set<String>>();
                    mapFlowScreens.put(wrapper.flowName, wrapper.affectedScreen);
                    mapMemberFlowAffectedScreens.put(memberToUse, mapFlowScreens);
                }  
            }                     
        }
        
        
        List<NavFlowPageConfig__mdt> lstNavFlowObj = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__r.FlowName__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                                                      PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c,
                                                      NavFlowRule__r.RuleApexClassName__c 
                                                      FROM NavFlowPageConfig__mdt
                                                      WHERE IsActive__c = TRUE                                  
                                                      AND NavigationFlowDetail__r.FlowName__c IN :lstFlowNames
                                                      order by SequenceNumber__c];  
        
        
        Map<String, Map<String,Integer>> mapFlowPageIntegerMap = new Map<String, Map<String,Integer>>();
        //Shikha: addedd
        Map<String,String> PageConfigRuleMap = new Map<String,String>();
        
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
            PageConfigRuleMap.put(lstNavFlowObj[i].PageInfo__r.PageName__c,lstNavFlowObj[i].NavFlowRule__r.RuleApexClassName__c);
        }
         
        
        
        List<NavFlowStatus__c> lstFlowStatus = [Select SSPApplication__c, Member__c, FlowPageStatus__c, NavFlowName__c, Screen_Status__c, FlowDupStatus__c
                                                from NavFlowStatus__c 
                                                where SSPApplication__c = :applicationId and Member__c IN :lstMemberIds
                                                and NavFlowName__c IN :lstFlowNames];
        
        
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
                    
                    
                    if(mapScreenRuleResult.get(str)){
                        
                        if(navFlowStatus.FlowDupStatus__c.charAt(PageIntegerMap.get(str)) != 82){
                            navFlowStatus.FlowPageStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, PageIntegerMap.get(str), 'R');  
                            navFlowStatus.FlowDupStatus__c =  CommonUtil.replaceString(navFlowStatus.FlowDupStatus__c, PageIntegerMap.get(str), 'R'); 
                            screenStatus.Status = CommonUtil.replaceString(screenStatus.Status, PageIntegerMap.get(str), 'R');
                            
                            screenStatus.isReviewRequired = true;
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
                            }else{
                                screenStatus.reviewReqScreens =String.ValueOf(selectedScreen); 
                                    }}
                    }
                    else{
                        
                        String ruleClassName = PageConfigRuleMap.get(str);
                        
                        if(ruleClassName != null){
                                Type typ = Type.forName(ruleClassName);
								BasicNavFlowRule nfr = (BasicNavFlowRule)typ.newInstance();
                                Context contextVal = new Context();
								ContextData data = new ContextData();
								data.MemberId = member;
								data.ApplicationId = navFlowStatus.SSPApplication__c;
								Boolean result = nfr.isRequired(contextVal, data);
                            	
                                screenStatus.Status = result ? screenStatus.oldStatus : 'N';                            	
                        }
                        else if(screenStatus.oldStatus!=null && screenStatus.oldStatus != screenStatus.Status &&
                           screenStatus.oldStatus != 'R')
                        {
                            screenStatus.Status = screenStatus.oldStatus;                                
                        }
                                                        
                        navFlowStatus.FlowPageStatus__c = CommonUtil.replaceString(navFlowStatus.FlowPageStatus__c, PageIntegerMap.get(str), screenStatus.Status);
                        navFlowStatus.FlowDupStatus__c = CommonUtil.replaceString(navFlowStatus.FlowDupStatus__c, PageIntegerMap.get(str), screenStatus.Status);                            
                        screenStatus.isReviewRequired = (screenStatus.Status == 'N' || screenStatus.Status == 'C') ? false : true;
                        
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
                lstFlowUpdates.add(navFlowRecord);
            }
        }       
        
        if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
        	update lstFlowStatus;
		}
    }*/
    
    
    public static String loadScreenProgramMapping(Context ctx, ContextData ctxData, NavFlowStatus__c navFlowStatus){
        
        List<String> lstOfSelectedPrograms = ctxData.SelectedPrograms;
        
        List<String> selectedPages = new List<String>();
        String status = '';
        NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);
        
        //added
        Map<String,Integer> PageIntegerMap = new Map<String,Integer>();
        for(integer i=0; i<navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
            PageIntegerMap.put(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c,i);
            
            if(!lstOfSelectedPrograms.isEmpty() && navFlowDetail.Navigation_Flow_Page_Configuration__r[i].Programs__c != null)
            {
                List<String> lstOfSplitPrgm = navFlowDetail.Navigation_Flow_Page_Configuration__r[i].Programs__c.split(',');
                
                for(String prgm: lstOfSplitPrgm)
                {
                    
                    for(String selectedPrgm: lstOfSelectedPrograms)
                    {
                        
                        //
                        //if selected program matches and selected programs list does not contain this program then add
                        if(prgm == selectedPrgm && !selectedPages.contains(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c) )
                        {
                            selectedPages.add(navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c);
                            
                            break;
                        }
                    }
                }                      
            }//added by AI
        }
        
        
        if(null == navFlowDetail || null == navFlowDetail.Navigation_Flow_Page_Configuration__r){
            throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Flow step configuration not found for flow name [' + ctxData.flowName + ']');
        }
        for(NavFlowPageConfig__mdt pageConfig : navFlowDetail.Navigation_Flow_Page_Configuration__r) { 
            boolean hasRule = (null != pageConfig.NavFlowRule__c);
            status +=  (hasRule ? (NavFlowRulesEngine.getInstance().isRequired(ctx, ctxData, pageConfig.NavFlowRule__c) ? STEP_REQ : STEP_NOT_REQ) : STEP_REQ);
        }
        
        /*for(String str : selectedPages ){
            if(status.charAt(PageIntegerMap.get(str)) == 67 )
                status = CommonUtil.replaceString(status, PageIntegerMap.get(str), 'R');    
        }*/
        Set<Integer> indexValuesSet = new Set<Integer>();
        for(integer i=0; i <selectedPages.size(); i++){
            if(PageIntegerMap.containsKey(selectedPages[i])){
                Integer seqidx = PageIntegerMap.get(selectedPages[i]);                    
                indexValuesSet.add(seqidx);
            }
        }        
        
        for(integer i=0; i < status.split('').size(); i++){
            if(!indexValuesSet.contains(i) && status.charAt(i) != 67){
                status = CommonUtil.replaceString(status, i, 'N');
            }
            else if(indexValuesSet.contains(i)  && status.charAt(i) != 67){
                status = CommonUtil.replaceString(status, i, 'R');
            }
        }
        
        
        /*NavFlowStatus__c navFlowStatus = new NavFlowStatus__c();
navFlowStatus.Contact__c = ctxData.contactId;
navFlowStatus.NavFlowName__c = ctxData.flowName;
navFlowStatus.FlowPageStatus__c = status;
navFlowStatus.RecordId__c = ctxData.recordId;*/
        navFlowStatus.InitiatedUser__c = UserInfo.getUserId();
        navFlowStatus.SSPApplication__c = ctxData.ApplicationId;
        navFlowStatus.Member__c = ctxData.MemberId;
        navFlowStatus.FlowPageStatus__c = status;
        
        // if(!isUpserted){
        navFlowStatus = NavFlowHelper.storeNavFlowRACStatus(ctx,ctxData,navFlowStatus);
        //}
        ctxData.navFlowStatusId = navFlowStatus.Id;
        ctxData.navFlowStatus = navFlowStatus;
        return status;
    }
    
     

    /***************************************************************************************************
* @author       Shrikant Raut
* @date         12/24/2019
* @methodname   setNavigationDetails
* @description  This methods is used to find the current section/page number and total number of required sections/pages
* @return       PageToLoad
*****************************************************************************************************/    
    public static PageToLoad setNavigationDetails(Context ctx, ContextData ctxData, PageToLoad page){
        try{
            String action = (ctxData != null) ? ctxData.action : null;
            NavFlowStatus__c navflowstat = NavFlowHelper.getNavFlowStausExisting(ctx, ctxdata);
            String flowPageStatus = (navflowstat != null) ? navflowstat.FlowPageStatus__c :initNavFlowStatuses(null, ctxData);

            NavFlowDetail__mdt navFlowDetail = getNavFlowDetail(ctx, ctxData);

            List<String> flowStatusSeqList = (flowPageStatus != null) ?  (flowPageStatus).split('') : null;
            Integer flowStatusSeqListSize = (flowStatusSeqList != null) ? flowStatusSeqList.size() : 0;
            Integer totalSectionCount = 0; 
            Integer currentSectionNo = 0; 
            Integer sourceSectionNo = 0 ; 
            String currentSectionId = (action != null && (action.equalsIgnoreCase('back') || action.equalsIgnoreCase('next'))) ? ctxData.curNavFlowPageConfigId : ((action != null && action.equalsIgnoreCase('goToPage')) ? ctxData.goToPageConfigId : null );
            Boolean sectionNoIdenfified = false;
            if(navFlowDetail != null && navFlowDetail.Navigation_Flow_Page_Configuration__r != null && flowStatusSeqList != null){
                //iterate on sections/screens in nav flow config
                for(Integer i=0; i < navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++) {
                    //if ith character of navFlowStatus seq is not equal to 'N' => increament total section count
                    if(i < flowStatusSeqListSize  && (flowStatusSeqList.get(i)).getChars().get(0) != 78 ){            
                        //increament current section no until the current section is identified
                        if(!sectionNoIdenfified){
                            currentSectionNo ++;
                        }    
                        totalSectionCount ++;
                    }
                    sectionNoIdenfified = ( (navFlowDetail.Navigation_Flow_Page_Configuration__r[i].Id).equals(currentSectionId)) ? true : sectionNoIdenfified;                    
                }   

            }
            
            sourceSectionNo = action.equalsIgnoreCase('next') ? currentSectionNo : sourceSectionNo;
            if((action.equalsIgnoreCase('loadFlow') || action.equalsIgnoreCase('next')) && flowStatusSeqList != null){
                //if(flowStatusSeqList != null && (action.equalsIgnoreCase('loadFlow') || (action.equalsIgnoreCase('next') && !flowStatusSeqList.contains('R')))){
                if(flowStatusSeqList.contains('R')){
                    currentSectionNo = 0;
                    for(String status : flowStatusSeqList){
                        if(!status.equalsIgnoreCase('n')){
                            currentSectionNo ++;
                        }
                        if(status.equalsIgnoreCase('r') && (sourceSectionNo < currentSectionNo)){
                            break;
                        }
                    }
                }
                else{
                    currentSectionNo = action.equalsIgnoreCase('next') ? (currentSectionNo + 1) : 1 ;
                }
            }
            currentSectionNo = (action != null && action.equalsIgnoreCase('next')) ? (currentSectionNo) : ((action != null && action.equalsIgnoreCase('back')) ? (currentSectionNo - 1) : currentSectionNo ) ;
            if(currentSectionNo <= 0) {
                currentSectionNo = 1;
            }
            page.currentPageNo = ''+currentSectionNo;
            page.totalPageCount = ''+totalSectionCount;
            page.isLastPage = (currentSectionNo == totalSectionCount);
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'NavFlowManager', 'setNavigationDetails', ex.getMessage() , true);
        }
        return page;
    }
    
    public static void resetFlowStatus(){
        
    }

    @auraEnabled
    public static SSP_LightningResponse fetchTransactionStatus(Map<String, String> detailMap){
        SSP_LightningResponse response = new SSP_LightningResponse();
        Map<String,String> map_StatusView = new Map<String,String>();
        try{
            String sHOHId = detailMap.containsKey('sHOHId') ? detailMap.get('sHOHId') : null;
            String sScreenName = detailMap.containsKey('sScreenName') ? detailMap.get('sScreenName') : null;
            String sMode = detailMap.containsKey('sMode') ? detailMap.get('sMode') : null;            
            if(sHOHId != null && sScreenName !=  null && sMode != null){               
               map_StatusView = SSP_Utility.isDataProcessed(sHOHId, sScreenName, sMode);
            }
            response.put('status',map_StatusView.get('status') == null ? 'NULL' : map_StatusView.get('status'));      
            response.put('message',map_StatusView.get('message'));      
        }
        catch(Exception ex){
            response.put('status','FAILURE');  
            response.put('ERROR', ex.getStackTraceString());
        }
        return response;
    } 
  

    @auraEnabled
    public static SSP_LightningResponse fetchApplicationDetails(String sspApplicationId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        response.put('INIT',sspApplicationId);
        Map<String, String> indvConditionMap = new Map<String,String>{
            'SSP_Application__c' => sspApplicationId,
                'limit' => '1'
                };
                try{
                        String sContactId = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                           new Set<String>{'Id', 'ContactId'}, 
                                                                           new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getUserId()})[0].ContactId;    
                        indvConditionMap.put('SSP_Member__r.Contact__c',sContactId);
                        indvConditionMap.put('IsHeadOfHousehold__c','#true#');


                        List<SSP_ApplicationIndividual__c> appIndvList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                            new Set<String>{'Id','SSP_Member__r.IndividualId__c'},
                            indvConditionMap);
                        if(appIndvList != null && !appIndvList.isEmpty() && appIndvList[0].SSP_Member__r.IndividualId__c != null){
                            response.put('sHOHId',appIndvList[0].SSP_Member__r.IndividualId__c);

                        }
                        else{
                            response.put('sHOHId','NULL');
                        }
                    }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'NavFlowManager', 'fetchApplicationDetails', ex.getMessage() , true);
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }   

    public static List<FAQ__kav> fetchKnowledgeArticles(String ScreenName, String lang){
        
        
        List<FAQ__kav> FAQList = new List<FAQ__kav>();
        FAQList = SSP_SharingBypassFetcher.queryKnowledgeArticles(ScreenName, lang);            
        
        
        return FAQList;
    }
    @AuraEnabled
    public static SSP_LightningResponse fetchReviewRequiredDetails(String applicationId,String memberId,String flowName, String mode){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{         
            List<NavFlowStatus__c> lstFlowStatus =  new  List<NavFlowStatus__c>();
            Map<String,String> mapscreenNameVsDisplayName =  new Map<String,String>();
            Map<String,Integer> mapPageNameInteger = new Map<String,Integer>();
            List<NavFlowDetail__mdt> lstNavFlow= new List<NavFlowDetail__mdt>();
            if(applicationId != null && memberId != null && flowName != null  && memberId != ''){
                lstFlowStatus = [Select SSPApplication__c, Member__c, FlowPageStatus__c, NavFlowName__c, Screen_Status__c, FlowDupStatus__c, FlowCompleteStatus__c, SSPApplication__r.SectionStatus__c
                                 from NavFlowStatus__c 
                                 where SSPApplication__c = :applicationId and Member__c = :memberId AND NavFlowName__c = :flowName ORDER BY LastModifiedDate desc LIMIT 1];
            }else  if(applicationId != null && flowName != null){
                lstFlowStatus = [Select SSPApplication__c, Member__c, FlowPageStatus__c, NavFlowName__c, Screen_Status__c, FlowDupStatus__c, FlowCompleteStatus__c, SSPApplication__r.SectionStatus__c
                                 from NavFlowStatus__c 
                                 where SSPApplication__c = :applicationId  AND NavFlowName__c = :flowName ORDER BY LastModifiedDate desc LIMIT 1];
            }
            //Shikha - started
            Context ctx = new Context();
          	ContextData ctxData = new ContextData();
            ctxData.ApplicationId = applicationId;
            ctxData.MemberId = memberId;
            ctxData.flowName = flowName;
            ctxData.modeValue = mode;
            
            SSP_LightningResponse responseNavFlowStatus = getNoStatusReviewRequired (ctx, ctxData,lstFlowStatus);
            Boolean noFlowReviewRequired = (responseNavFlowStatus != null && responseNavFlowStatus.mapResponse.containsKey('makeReviewRequired') != null) ? (Boolean)responseNavFlowStatus.mapResponse.get('makeReviewRequired'): false;
            Set<String> reviewRequireedPages = (responseNavFlowStatus != null && responseNavFlowStatus.mapResponse.containsKey('reviewRequiredPages') != null) ? (Set<String>)responseNavFlowStatus.mapResponse.get('reviewRequiredPages') : new Set<String>();
            
            //Shikha - end
            lstNavFlow=  [ SELECT Id, FlowDisplayName__c, FlowName__c, NextActionGoToPage__c, Community_Page_URL__c,
                          (SELECT Id, ListenerPageNames__c, NavigationFlowDetail__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                           PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c,PageInfo__r.PageDisplayName__c
                           FROM Navigation_Flow_Page_Configuration__r)
                          FROM NavFlowDetail__mdt];
            
            
            for(NavFlowDetail__mdt objNavFlow :lstNavFlow){
                for(NavFlowPageConfig__mdt objConfig: objNavFlow.Navigation_Flow_Page_Configuration__r){
                    mapscreenNameVsDisplayName.put( objConfig.PageInfo__r.PageName__c,objConfig.PageInfo__r.Page_Display_Name_View__c);
                    
                }
                
            }
            if(!mapscreenNameVsDisplayName.isEmpty()){
                response.put('mapScreenNames',JSON.serialize(mapscreenNameVsDisplayName));
            }
            if(!lstFlowStatus.isEmpty() && lstFlowStatus[0].Screen_Status__c != null){
                Map<String,Object> mapScreenStatus = (Map<String,Object>)JSON.deserializeUntyped(lstFlowStatus[0].Screen_Status__c);
                
                
                
                List<String> lstReviewRequiredScreens = new List<String>();
                
                for(String objScreen :  mapScreenStatus.keySet()){
                    Object obj = (Object)mapScreenStatus.get(objScreen);
                    SSP_RulesEngine.ScreenStatus objStatus= (SSP_RulesEngine.ScreenStatus)JSON.deserialize(JSON.serialize(obj),   SSP_RulesEngine.ScreenStatus.class);
                    if(objStatus.isReviewRequired){
                        lstReviewRequiredScreens.add(objScreen);
                    }
                }
                if(!lstReviewRequiredScreens.isEmpty()){
                    response.put('reviewRequiredScreens',JSON.serialize(lstReviewRequiredScreens));
                }
                response.put('screenStatus',lstFlowStatus[0].Screen_Status__c);    
                response.put('reviewLastPage',lstFlowStatus[0].FlowCompleteStatus__c);
            }
            response.put('noFlowReviewRequired',noFlowReviewRequired);
            response.put('reviewRequiredPages',reviewRequireedPages);
            
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'NavFlowNamager', 'fetchReviewRequiredDetails', ex.getMessage() , true);
        }
        return response;
    }
    
    @AuraEnabled
    public static QueuingWrapper getQueuingFields (String applicationId){
        QueuingWrapper wrapObj = new QueuingWrapper();
        List<Schema.FieldSetMember> applicationIndividualFileds = SObjectType.SSP_ApplicationIndividual__c.FieldSets.ApplicationIndividual.getFields();
        List<Schema.FieldSetMember> applicationFields = SObjectType.SSP_Application__c.FieldSets.ApplicationFields.getFields();
        List<Schema.FieldSetMember> memberFields = SObjectType.SSP_Member__c.FieldSets.MemberFields.getFields();
        List<Schema.FieldSetMember> assetFields = SObjectType.SSP_Asset__c.FieldSets.AssetFields.getFields();
        List<Schema.FieldSetMember> contactFields = SObjectType.Contact.FieldSets.SSP_Queuing.getFields();
        Set<String> memberIdSet = new Set<String>();                
        Set<String> applicableProgramSet = SSP_Utility.getAvailableProgramsByRole(); //CD2 2.5 Security Role Matrix and Program Access.
        String status = 'Removed';
        String query = 'SELECT ';
        String assetQuery = 'SELECT ';
        for(Schema.FieldSetMember field : applicationIndividualFileds){
            if(field != null)
    			query += field.getFieldPath() + ', ';
		}
        for(Schema.FieldSetMember field : applicationFields){
            if(field != null)
            	query += 'SSP_Application__r.'+field.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember field : memberFields){
            if(field != null)
            	query += 'SSP_Member__r.'+field.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember field : contactFields){
            if(field != null)
            	query += 'SSP_Member__r.Contact__r.'+field.getFieldPath() + ', ';
        }
        if(applicationId != null){
        query += 'Id FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = \''+String.escapeSingleQuotes(applicationId.trim())+'\''+
                  'AND MemberStatus__c != \''+String.escapeSingleQuotes(status.trim())+'\'' + 'ORDER BY IsHeadOfHousehold__c DESC, CreatedDate LIMIT 1000';
                  //+ ' AND SSP_Member__c = \''+String.escapeSingleQuotes(memberId.trim())+'\'';
        
		List<SSP_ApplicationIndividual__c> appIndividualData = Database.query(query);
        Map<String,SSP_ApplicationIndividual__c> mapMemberIndividualData = new Map<String,SSP_ApplicationIndividual__c>();
        for(SSP_ApplicationIndividual__c appIndiv : appIndividualData){
            mapMemberIndividualData.put(appIndiv.SSP_Member__c,appIndiv);
            memberIdSet.add('\''+appIndiv.SSP_Member__c+'\'');
        }        
        for(Schema.FieldSetMember field : assetFields){
            if(field != null)
    			assetQuery += field.getFieldPath() + ', ';
        }
        List<String> memberIdList = new List<String>();
        memberIdList.addAll(memberIdSet);
        String memberIdStr = String.join(memberIdList,',');
        
        List<SSP_Asset__c> assetList = new List<SSP_Asset__c>();
        if(String.isNotBlank(String.escapeSingleQuotes(memberIdStr))){
       		assetQuery += 'Id FROM SSP_Asset__c WHERE SSP_Member__c IN ('+memberIdStr+')';
                     
        	assetList = Database.query(assetQuery);
        	
        }
        
        //assetQuery += memberIdSet ;
        
        Map<String,List<SSP_Asset__c>> mapMemberAsset = new Map<String,List<SSP_Asset__c>>();
        for(SSP_Asset__c assetObj : assetList){
            if(mapMemberAsset.containsKey(assetObj.SSP_Member__c)){
                mapMemberAsset.get(assetObj.SSP_Member__c).add(assetObj);
            }
            else{
                mapMemberAsset.put(assetObj.SSP_Member__c,new List<SSP_Asset__c> {assetObj});   
            }            
        }
        wrapObj.applicationIndividualList = appIndividualData;
        wrapObj.memberAppIndividualMap = mapMemberIndividualData;
        wrapObj.mapMemberAsset = mapMemberAsset;
        
        }
        return wrapObj;
    }
    
    public static QueuingWrapper passQueuingWrapper (String applicationId){
        QueuingWrapper queueObj = new QueuingWrapper();
        if(queueWrapperObject != null){
            queueObj = queueWrapperObject;
        }
        else{
            queueObj = NavFlowManager.getQueuingFields(applicationId);
        }
        return queueObj;
    }

    public static SSP_LightningResponse getNoStatusReviewRequired (Context ctx, ContextData ctxData, List<NavFlowStatus__c> navFlowStatList){
        SSP_LightningResponse resp = new SSP_LightningResponse();
        Boolean makeReviewRequired = false;  
        Set<String> reviewRequiredPages = new Set<String>();           
        if(navFlowStatList.isEmpty() && ctxData.ApplicationId != null){
            String status;
            String memberSectionStatus;
            ctxData.queueObject = NavFlowManager.getQueuingFields(ctxData.ApplicationId);
                        
            //getNavFlowDetail
            NavFlowDetail__mdt flowDetail = getNavFlowDetail(ctx, ctxData);
            Map<Integer,String> pageIntegerMap = new Map<Integer,String>();
            for(Integer i=0; i< flowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
                pageIntegerMap.put(i,flowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.Page_Display_Name_View__c);
            }
            if(ctxData.queueObject != null && ctxData.queueObject.memberAppIndividualMap != null && ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) != null){
                status =  initNavFlowStatuses(ctx,ctxData);
                
                String[] statusArray = status.split('');
                for(Integer i=0; i< statusArray.size(); i++){
                    if(statusArray[i] == 'R' && pageIntegerMap.containsKey(i)){
                    	reviewRequiredPages.add(pageIntegerMap.get(i));
                    }
                }                  
                String SectionStatus = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId).SSP_Application__r.SectionStatus__c;
                Map<String,Object> sectionStatusMap = (Map<String,Object>)JSON.deserializeUntyped(SectionStatus) ;
                Object sectionValue;
                if(ctxData.modeValue == 'Intake'){
                 	sectionValue = (sectionStatusMap != null && sectionStatusMap.containsKey('Intake'))? (Object)sectionStatusMap.get('Intake') : null;   
                } 
                if(ctxData.modeValue == 'Renewal'){
                 	sectionValue = (sectionStatusMap != null && sectionStatusMap.containsKey('Renewal')) ? (Object)sectionStatusMap.get('Renewal') : null;   
                } 
                if(ctxData.modeValue == 'addRemoveMember'){
                 	sectionValue = (sectionStatusMap != null && sectionStatusMap.containsKey('AddRemoveMember')) ? (Object)sectionStatusMap.get('AddRemoveMember') : null;   
                } 
                Map<String,Object> objMap = sectionValue != null ? (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sectionValue)) : null;
                memberSectionStatus = (objMap != null && objMap.containsKey('Member_Details')) ? (String)objMap.get('Member_Details') : '';
            }       
            
            if(status!=null &&  status.contains('R') && memberSectionStatus != null && (memberSectionStatus == 'REVIEW_REQUIRED' || memberSectionStatus == 'COMPLETED')){
                makeReviewRequired = true;
            }
        }
        /*else if(ctxData.modeValue == 'addRemoveMember' && ctxData.ApplicationId != null){
        	ctxData.queueObject = NavFlowManager.getQueuingFields(ctxData.ApplicationId); 
            if(ctxData.queueObject != null && ctxData.queueObject.memberAppIndividualMap != null && ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) != null){
                
            }
        }*/
        if(makeReviewRequired){
            resp.put('reviewRequiredPages',reviewRequiredPages);
        }
        resp.put('makeReviewRequired',makeReviewRequired);
        return resp;
    }
    
    public static final Map<String,Integer> orderVsFlowMap = new Map<String,Integer>{'MemberIndividualInformation'=>1,
        'MemberHealthInformation'=>2,
        'MemberOtherInformation'=>3,
        'MemberResourcesInformation'=>4,
        'MemberIncomeSubsidiesInfo'=>5,
        'MemberExpensesInformation'=>6};
    public static final Map<Integer,String> FlowVsOrderMap = new Map<Integer,String>{1=>'MemberIndividualInformation',
        2=>'MemberHealthInformation',
        3=>'MemberOtherInformation',
        4=>'MemberResourcesInformation',
        5=>'MemberIncomeSubsidiesInfo',
        6=>'MemberExpensesInformation'};
            
            public static String checkQueuingRules (String appId, String memId, String currentFlowName, String mode){                
                Integer currentIdx = orderVsFlowMap.containsKey(currentFlowName) ? (Integer)orderVsFlowMap.get(currentFlowName) : 0;
                Integer count = currentIdx + 1;
                String applicableFlowName = '';
                //Map<String, SSP_Utility.SecurityMatrixWrapper> securityMap = SSP_ApplicationSummaryController.getScreenPermissions('Citizen_Individual');//to be replaced by null
                //QueuingWrapper queueObjectValue = NavFlowManager.getQueuingFields(appId);
                List<NavFlowPageConfig__mdt> flowPageConfigList = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__c,NavigationFlowDetail__r.Flowname__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                                                                   PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c, NavFlowRule__r.RuleApexClassName__c
                                                                   FROM NavFlowPageConfig__mdt
                                                                   WHERE NavigationFlowDetail__r.Flowname__c IN : NavFlowManager.orderVsFlowMap.keySet() 
                                                                   AND IsActive__c = TRUE ORDER By SequenceNumber__c ];
                /*Map<String,List<NavFlowPageConfig__mdt>> mapFlowNamVsPageConfigs = new Map<String,List<NavFlowPageConfig__mdt>>();
                for(NavFlowPageConfig__mdt configItem : flowPageConfigList){
                    if(mapFlowNamVsPageConfigs.containsKey(configItem.NavigationFlowDetail__r.Flowname__c)){
                        mapFlowNamVsPageConfigs.get(configItem.NavigationFlowDetail__r.Flowname__c).add(configItem);
                    }
                    else{
                        mapFlowNamVsPageConfigs.put(configItem.NavigationFlowDetail__r.Flowname__c,new List<NavFlowPageConfig__mdt>{configItem});
                    }
                }*/
                QueuingWrapper queueObjectValue = NavFlowManager.getQueuingFields(appId);
                //system.debug('### flowVsPageNameMap '+mapFlowNamVsPageConfigs);
                String flowName = currentFlowName;
                Integer nextIdx;
               // for(String flowObj : mapFlowNamVsPageConfigs.keySet()){ 
                for(Integer i=0; i<orderVsFlowMap.size(); i++ ){
                    applicableFlowName = String.isNotBlank(flowName) ? runQueuingRule(appId,memId,mode,flowName,flowPageConfigList, queueObjectValue) : ''; 
                    if(String.isNotBlank(applicableFlowName)){
                        break;
                    }
                    if(applicableFlowName == '' && (orderVsFlowMap.get(flowName)+1 < orderVsFlowMap.size())){
                        nextIdx = (Integer)orderVsFlowMap.get(flowName)+1;                        
                        flowName = FlowVsOrderMap.get(nextIdx);
                    }                                                            
                    if(String.isBlank(flowName) && nextIdx < orderVsFlowMap.size()){
                        nextIdx++;
                    }
                    //applicableFlowName = runQueuingRule(appId,memId,mode,currFlowName,flowPageConfigList, queueObjectValue);
                    //if(String.isBlank(applicableFlowName)){       
                    // && String.isNotBlank(flowName) && flowName != 'MemberExpensesInformation                 
                    /*applicableFlowName = String.isNotBlank(flowName) ? runQueuingRule(appId,memId,mode,flowName,flowPageConfigList, queueObjectValue) : '';                    
                    if(String.isBlank(applicableFlowName) && String.isNotBlank(flowName)){
                        if((orderVsFlowMap.get(flowName) + 1) < orderVsFlowMap.size()){
                            nextIdx =  (Integer) orderVsFlowMap.get(flowName) + 1;
                        }                        
                        if(nextIdx == orderVsFlowMap.get(flowObj)){
                            flowName = flowObj;
                        }
                        else if(nextIdx < orderVsFlowMap.size()){
                            nextIdx ++;
                        }                        
                    }                
                    else{
                        break;
                    }*/
            }                               
    system.debug('### applicableFlowName '+applicableFlowName);
    return applicableFlowName;
}

public static Map<String, SSP_Utility.SecurityMatrixWrapper> securityMap;

public static  Map<String, SSP_Utility.SecurityMatrixWrapper> passSecurityMap (){
    if(securityMap == null){            
        securityMap = SSP_ApplicationSummaryController.getScreenPermissions('Citizen_Individual');
    }   
    return securityMap;
}
    
public static String runQueuingRule (String appId, String memId, String mode, String currFlowName, List<NavFlowPageConfig__mdt> navFlowPageConfigList, QueuingWrapper queueObjectValue){        
    //security = SSP_ApplicationSummaryController.getScreenPermissions('Citizen_Individual');//to be replaced by null   
    securityMap = passSecurityMap();        
    Integer nextIdx = ((orderVsFlowMap.get(currFlowName) + 1) <= orderVsFlowMap.size()) ? 
        			  (Integer)orderVsFlowMap.get(currFlowName)+1 :0;  
        //orderVsFlowMap.containsKey(currFlowName) && ((orderVsFlowMap.get(currFlowName) + 1) < orderVsFlowMap.size()) ? 
        //(Integer)orderVsFlowMap.get(currFlowName) + 1 : 0;
    string applicableFlowName = '';
    for(NavFlowPageConfig__mdt pageConfig : navFlowPageConfigList){
        if(nextIdx != 0 && nextIdx ==  orderVsFlowMap.get(pageConfig.NavigationFlowDetail__r.Flowname__c)){
            Boolean isAccessible = securityMap != null && !securityMap.isEmpty() && securityMap.containsKey(pageConfig.PageInfo__r.PageName__c) && 
                securityMap.get(pageConfig.PageInfo__r.PageName__c).screenPermission != null ?
                !securityMap.get(pageConfig.PageInfo__r.PageName__c).screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE) : true;
            Boolean result = false;
            system.debug('### isAccessible '+isAccessible);
            if(mode != SSP_FrameworkConstants.RACMODE && pageConfig.NavFlowRule__r.RuleApexClassName__c != null){
                Type typ = Type.forName(pageConfig.NavFlowRule__r.RuleApexClassName__c);
                BasicNavFlowRule nfr = (BasicNavFlowRule)typ.newInstance();
                Context contextVal = new Context();
                ContextData data = new ContextData();
                data.MemberId = memId;
                data.ApplicationId = appId;
                data.queueObject = queueObjectValue;
                data.modeValue = mode;
                result = isAccessible && nfr.isRequired(contextVal, data); //2.5 Security Role Matrix and Program Access.
            }
            system.debug('### que Result '+result);
            if(result){
                applicableFlowName = pageConfig.NavigationFlowDetail__r.Flowname__c;
                break;
            }
        }
    }
    return applicableFlowName;
}

}