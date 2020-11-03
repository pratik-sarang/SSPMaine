public with sharing class NavFlowController {
    
    
    /**
     * Executes load, next, back or finish action of the navigation flow. Returns the page to be loaded.
     *
     * @param action String. Navigation flow action. Possible values are : loadFlow, next, back, finish
     * @param contactId String. Contact.Id for whom the navigation flow is started.
     * @param flowName String. Navigation flow name NavFlowDetail__mdt.FlowName__c to load. 
     * @param curNavFlowPageConfigId String. Current page's NavFlowPageConfig__mdt.Id. This value is needed when next, back or finish action is invoked.
     * @param navFlowStatusId String. Current flow's NavFlowStatus__c.Id. This value is needed when next, back or finish action is invoked.
     * @param recordId String. Optional value. SObject Id which can be used to fetch data in the current page or navigation flow rules. If present then it will be stored in NavFlowStatus__c.RecordId__c. Pass this value when next, back or finish action is invoked.
     * @param goToPageConfigId. Optional value. Page to load NavFlowPageConfig__mdt.Id. Used on click action of group/section in the progress bar. If present, it wi
     * @param objs List of Objects. Optional value. List of SObjects can be passed to be used in navigation flow rules. Pass this value when next, back or finish action is invoked.
     *
     * @return PageToLoad If null is returned then the current page will be reloaded. Else, the returned PageToLoad will be loaded.
     */
    //Shikha: adding new argument Set<String> to pass only values which are selected when RAC flow is executed
    @AuraEnabled
    public static PageToLoad execute(String action, String contactId, String flowName, String curNavFlowPageConfigId, 
                                     String navFlowStatusId, String recordId, String goToPageConfigId,
                                     Object[] objs, List<String> selectedScreens,List<String> lstOfSelectedPrograms, String ApplicationId, String MemberId, String mode, List<String> noStatusReviewRequired) 
    {
        PageToLoad page = null;

        try {
            String conId = getLoggedInUserContactId();
            
            Context ctx = new Context();
            ContextData ctxData = new ContextData();
            ctxData.action= action;
            ctxData.contactId= conId;//contactId;
            ctxData.flowName= flowName;
            ctxData.curNavFlowPageConfigId = curNavFlowPageConfigId;
            ctxData.navFlowStatusId= navFlowStatusId;
            ctxData.recordId= recordId;
            ctxData.goToPageConfigId = goToPageConfigId;
            ctxData.objs= objs;
            ctxData.SelectedScreen = selectedScreens;
            ctxData.SelectedPrograms = lstOfSelectedPrograms;
            //Shikha added: adding Application Id and Member Id 
            ctxData.ApplicationId = ApplicationId;
            ctxData.MemberId = MemberId;            
            //Shikha: modeValue
            ctxData.modeValue = mode;
            
            //Shikha added - 5/23/2020            
            ctxData.queueObject = NavFlowManager.getQueuingFields(ApplicationId);            
            ctxData.noFlowStatusRRPages = noStatusReviewRequired;
            if('loadFlow'.equalsIgnoreCase(action)){
                page = loadFlow(ctx, ctxData);  
            }
            else if('next'.equalsIgnoreCase(action)){
                page = next(ctx, ctxData);  
            }
            else if('back'.equalsIgnoreCase(action)){
                page = back(ctx, ctxData);  
            }
            else if('finish'.equalsIgnoreCase(action)){
                // for now, call next
                page = next(ctx, ctxData);  
            }
            
            else if('goToPage'.equalsIgnoreCase(action))
            {
                page = goToPage(ctx, ctxData); 
            }
            
        }
        catch(CustomException ce) {
            //
            throw(ce);
        }
        return page;
    }
    
    private static PageToLoad loadFlow(Context ctx, ContextData ctxData) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        PageToLoad objPageToLoad = new PageToLoad();
        if(ctxData.ApplicationId != null && SSP_Utility.getSelectedRole() != SSP_FrameworkConstants.CITIZEN_ROLE){
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(ctxData.ApplicationId);            
           if(objResponse != null && objResponse.mapResponse != null && objResponse.mapResponse.containsKey('hasAccess')){
               objPageToLoad =  NavFlowManager.loadFlow(ctx, ctxData); 
           }else{            
               objPageToLoad.hasNoAccess = true;            
           }
        }           
        else{
            objPageToLoad =  NavFlowManager.loadFlow(ctx, ctxData); 
        }
        return objPageToLoad;
    }

    /**
     * Invoked on <i>wf_next</i> and <i>wf_finish</i> actions from visualforce page. Validates page's view object and then stores data.
     * Updates the current page's status in the flow. Finally, gets the next page to load.
     *
     * @param ctx Context object
     * @param ctxData ContextData object
     * @param view View object of the currently opening page.
     * @param viewProc ViewProcessor object which contains page's custom/business logics.
     *
     * @return PageToLoad If null is returned then the current page will be reloaded. Else, the returned PageToLoad will be loaded.
     */
    private static PageToLoad next(Context ctx, ContextData ctxData){        
        NavFlowManager.FlowStatusUpdate(ctx, ctxData);
        return NavFlowManager.getNextStep(ctx, ctxData);        
        
    }
    // Manjunath
    
    private static PageToLoad goToPage(Context ctx, ContextData ctxData){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        PageToLoad objPageToLoad = new PageToLoad();
        if(ctxData.ApplicationId != null && SSP_Utility.getSelectedRole() != SSP_FrameworkConstants.CITIZEN_ROLE){
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(ctxData.ApplicationId);
            if(objResponse != null && objResponse.mapResponse != null && objResponse.mapResponse.containsKey('hasAccess')){
                objPageToLoad =  NavFlowManager.goToPage(ctx, ctxData);
            }else{            
                objPageToLoad.hasNoAccess = true;            
            }
        }
        else{
            objPageToLoad =  NavFlowManager.goToPage(ctx, ctxData);
        }
        return objPageToLoad;
        
    }

    /**
     * Invoked on <i>wf_back</i> action from visualforce page. Gets the previous page to load.
     *
     * @param ctx Context object
     * @param ctxData ContextData object
     * @param view View object of the currently opening page.
     * @param viewProc ViewProcessor object which contains page's custom/business logics.
     *
     * @return PageToLoad If null is returned then the current page will be reloaded. Else, the returned PageToLoad will be loaded.
     */
    private static PageToLoad back(Context ctx, ContextData ctxData){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        PageToLoad objPageToLoad = new PageToLoad();
        if(ctxData.ApplicationId != null && SSP_Utility.getSelectedRole() == SSP_FrameworkConstants.CITIZEN_ROLE){
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(ctxData.ApplicationId);
            if(objResponse != null && objResponse.mapResponse != null && objResponse.mapResponse.containsKey('hasAccess')){            
                objPageToLoad =  NavFlowManager.getPrevStep(ctx, ctxData);
            }else{            
                objPageToLoad.hasNoAccess = true;
            }
        }
        else{
            objPageToLoad =  NavFlowManager.getPrevStep(ctx, ctxData);
        }
        return objPageToLoad;
        
    }
    
    /**
     * Invoked on loading the flow from community where pageRef is null
     *
     *
     *
    * @return Contact Id of logged in user.
     */
    @AuraEnabled
    public static String getLoggedInUserContactId(){
        /*return SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()})[0].contactId;*/
        return [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
    } 
    
    /**
     * Invoked on loading the flow from community where pageRef is null
     *@
    * @return Contact Id of logged in user.
     */
   /* @AuraEnabled
    public static String updateContactRecord(Contact conObj){
        String result = 'fail';
        try{
            //Contact con = new Contact(Id= '0032F00000BSEi8QAH', FirstName = 'Sarah');
            //
            if(conObj != null ){
             //update conObj;
                List<Contact> conList = new List<Contact>{conObj};  
                SharingBypass.performUpdate(conList);
                result = 'Success';
            }
        }
        Catch(Exception exc){
            
        }
        return result;
    } 
    
    //Shikha : added New Method to retreive data from COntact
    @AuraEnabled
    public static Contact queryConData(String ContactId)
    {
        Contact con = new Contact();
        con = TestApplicantCommunityCtrl.retreiveContactDetails(ContactId);
        //
        return con;
    }*/
    
    //Shikha: added new method to fetch member details
    @AuraEnabled
    public static SSP_Member__c fetchMemberDetails(String memberId){
        return NavFlowHelper.getMemberDetails(memberId);
    }
    
    @AuraEnabled
    public static void resetStatus (Id applicationId, String flowName) {
        NavFlowManager.resetDriver(new Set<Id> {applicationId}, flowName);
    }
        
    //Shikha:Added new method to fetch help content of modal
    @AuraEnabled
    public static SSP_LightningResponse fetchHelpContent(String screenName, String language){
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<FAQ__kav> FAQList = NavFlowManager.fetchKnowledgeArticles(screenName, language);
        response.put('helpContent',FAQList);
        
        return response;
    }

    //#392585
    @AuraEnabled
    public static SSP_LightningResponse getMemberDataImperative(Id memberId, Id applicationId) {
        return getMemberData(memberId, applicationId);
    }
    
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getMemberData(Id memberId, Id applicationId) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            if(memberId == null || applicationId == null) {
                return response;
            }
            
            List<SSP_ApplicationIndividual__c> individuals = [SELECT Id, SSP_Member__r.FirstName__c, IsHeadOfHousehold__c,
                        SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c
                        FROM SSP_ApplicationIndividual__c
                        WHERE SSP_Member__c =:memberId AND SSP_Application__c = :applicationId];
               // SSP_ApplicationIndividualSelector.queryApplicationIndividualData(memberId, applicationId, null);

            if(individuals != null && !individuals.isEmpty()) {
                SSP_ApplicationIndividual__c individual = individuals.get(0);
                response.put('individual', individual);
            }
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'NavFlowController', 'getMemberData', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    } 
    
   @AuraEnabled(cacheable=true) 
   public static List<String> getMemberDetails(String applicationId, String memberId, String flowName, String mode){
        //SSP_LightningResponse response = new SSP_LightningResponse();
        SSP_Utility.isAuthenticatedUser();
        List<String> selectedScreens = new List<String>();
        try{
            SSP_ApplicationIndividual__c appIndiv = new SSP_ApplicationIndividual__c ();
            if(flowName == 'HealthcareCoverage' || flowName == 'SignAndSubmit' || flowName == 'HouseholdInformation'){                
           	 	appIndiv = [SELECT Id, SSP_Member__r.FirstName__c, IsHeadOfHousehold__c,
                        SSP_Member__r.LastName__c, SSP_Application__r.RAC_Selections__c,SSP_Member__r.IndividualId__c
                        FROM SSP_ApplicationIndividual__c
                        WHERE SSP_Application__c = :applicationId AND IsHeadOfHousehold__c = true limit 1];
            }
            else{            
                appIndiv = [SELECT Id, SSP_Member__r.FirstName__c, IsHeadOfHousehold__c,
                            SSP_Member__r.LastName__c, SSP_Application__r.RAC_Selections__c,SSP_Member__r.IndividualId__c
                            FROM SSP_ApplicationIndividual__c
                            WHERE SSP_Member__c =:memberId AND SSP_Application__c = :applicationId limit 1];
            }
            //response.put('appIndiv',appIndiv);
            
            
            //response.put('Mode',mode);
            if(mode == 'RAC'){
                //response.put('RAC','inRAC');                
                String rac = appIndiv.SSP_Application__r.RAC_Selections__c; 
                
                List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper> RACWrapperList = (List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper>)JSON.deserialize(rac, List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper>.class);
                 
                //response.put('RACWrapperList',RACWrapperList);
                List<SSP_ReportChangeSelectionCtrl.ScreenDetailWrapper> screenWrapper = new List<SSP_ReportChangeSelectionCtrl.ScreenDetailWrapper>();
                for(SSP_ReportChangeSelectionCtrl.RACSelectionWrapper wrap : RACWrapperList){
                    
                    
                    if(wrap.memberId == appIndiv.SSP_Member__r.IndividualId__c && 
                      (flowName != 'HealthcareCoverage' && flowName != 'SignAndSubmit')){
                        //response.put('selectedwrap',wrap.selectedScreens);
                        screenWrapper = wrap.selectedScreens;                    
                        break;
                    }
                    else if(wrap.memberId != null && flowName == 'HouseholdInformation'){
                        screenWrapper.addAll(wrap.selectedScreens); 
                        break;
                    }
                    else if(wrap.memberId == null){
                        screenWrapper.addAll(wrap.selectedScreens);                         
                    }
                }
                //response.put('screenWrapper',screenWrapper);
                
                
                for(SSP_ReportChangeSelectionCtrl.ScreenDetailWrapper screenWrap : screenWrapper){
                    if(screenWrap.flowName == flowName){
                        //selectedScreens = new List<String>{screenWrap.screens};
                        if(screenWrap.screens!=null)
                        	selectedScreens = screenWrap.screens.split(',');
                        break;
                    }
                }
                
                //response.put('selectedScreens', selectedScreens);
            }
            
        }
        catch(Exception ex){
            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'NavFlowController', 'getMemberDetails', ex.getMessage() , true);
            //response.addException(ex, lstLogMessages[0].Id);
        }
        return selectedScreens;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse getOrStartRSSPDCTransaction(Id applicationId, String screenName, String mode) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        try {
            String viewName = SSP_Utility.getScreenViewMapping().get(screenName);
            response.put('viewName', viewName);
            Set<String> fields = new Set<String>{'SSP_Application__c', 'SSP_Application__r.DCCaseNumber__c', 'SSP_Member__r.Contact__r.IndividualId__c', 'SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c'};
            List<SSP_ApplicationIndividual__c> individuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(applicationId, fields);
            if(String.isBlank(viewName) || individuals == null || individuals.isEmpty()) {
                response.bIsSuccess = false;
                return response;
            }
            if(individuals[0].SSP_Member__r.Contact__r.IndividualId__c == null || individuals[0].SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c == false) {
                response.put('isSuccess', true);
                response.bIsSuccess = true;
                return response;
            }
            String uniqueId = String.valueOf(individuals[0].SSP_Member__r.Contact__r.IndividualId__c) + ';' + viewName;
           // List<SSP_Transaction__c> transactions = [SELECT Id, Status__c, Log_Message__c FROM SSP_Transaction__c WHERE Unique_Id__c = :uniqueId];
            List<SSP_Transaction__c> transactions = SSP_SharingBypassFetcher.fetchTransactionRecords(uniqueId);
            
            if(transactions.isEmpty() || transactions[0].Status__c == SSP_InterfaceConstants.NOT_STARTED) {
                String individualId = '';
                if(mode != SSP_GlobalConstants.SSP_INTAKE_FLOW)
                {
                    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);            
                	mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
                	individualId = mapCaseVsIndividualId.get(String.valueOf(individuals[0].SSP_Application__r.DCCaseNumber__c));
                }
                else{
                    individualId = individuals[0].SSP_Member__r.Contact__r.IndividualId__c;
                }
                Boolean isStarted = startRSSPDCTransaction(individuals[0].SSP_Application__c, screenName, individualId);
                response.put('status', SSP_InterfaceConstants.NOT_STARTED);
                response.put('started', isStarted);
            }
            else {
                response.put('isSuccess', transactions[0].Status__c == SSP_InterfaceConstants.SUCCESS);
                response.put('isFailed', transactions[0].Status__c == SSP_InterfaceConstants.FAILED);
                response.put('status', transactions[0].Status__c);
                response.put('logName', transactions[0].Log_Message__c);
            }
            response.bIsSuccess = true;
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'NavFlowController', 'getOrStartRSSPDCTransaction', ex.getMessage() , true);
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }

    public static Boolean startRSSPDCTransaction(String applicationId, String selectedScreens, String individualId) {
        if(String.isBlank(applicationId) || String.isBlank(selectedScreens)){
            return false;
        }
        Map<String, Object> mapParams = new Map<String, Object>();
        List<SSP_Application__c> sspAppList = SSP_ApplicationSelector.queryApplicationData(
            new Map<String, String>{'objectName' => 'SSP_Application__c','operator' => 'AND'}, 
            new Set<String>{'Id','DCCaseNumber__c','ProgramsApplied__c'}, 
            new Map<String, String>{'limit' => '1', 'Id' => applicationId, 'RecordTypeId' => SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case')}
        );
        if(!sspAppList.isEmpty()) {
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.ADHOC_VIEWS;
            reqWrapper.mode = SSP_InterfaceConstants.MODE_RAC;
            reqWrapper.caseNumber = Integer.valueOf(sspAppList[0].DCCaseNumber__c);
            //reqWrapper.primaryApplicationIndividualId = Integer.valueOf(userData[0].Contact.IndividualId__c);
            reqWrapper.primaryApplicationIndividualId = individualId;
            reqWrapper.programCode = sspAppList[0].ProgramsApplied__c;
            reqWrapper.applicationID = applicationId;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY, reqWrapper);
            mapParams.put(SSP_InterfaceConstants.SSP_SCREEN_NAMES, selectedScreens);
            String callOutResponse = JSON.serialize(IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams));
            SSP_ApplicationSummaryController.markSectionsComplete(applicationId, '$' + selectedScreens.replaceAll(';', ','));
            return true;
        }
        return false;
    }
}