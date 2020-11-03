public with sharing class SSP_ReportChangeSelectionCtrl {
    
    /**2.5 Security Role Matrix and Program Access. */
    @AuraEnabled
    public static SSP_LightningResponse getScreenPermission(){
        SSP_LightningResponse response = new SSP_LightningResponse();        
        try{
            response.bIsSuccess = true;
            String screenPermission = SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.RAC_CHANGES_SCREENID, null).screenPermission;
            response.put('isNotAccessible', String.isNotBlank(screenPermission) && screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE) ? true : false);            
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'getScreenPermission', ex.getMessage() , true);
            response.bIsSuccess = false;
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getAppSummaryMetadata (String applicationId) {
        Set<String> fieldSet = new Set<String>();
        List<String> applicationFields = new List<String>{'Name', 'ProgramsApplied__c'};    //Add more Application level fields
            List<String> memberFields = new List<String>{'FirstName__c', 'LastName__c'};    //Add more Member level fields
                for(Integer i = 0; i < memberFields.size(); ++i) {
                    memberFields[i] = 'SSP_Member__r.' + memberFields[i];
                }
        for(Integer i = 0; i < applicationFields.size(); ++i) {
            applicationFields[i] = 'SSP_Application__r.' + applicationFields[i];
        }
        fieldSet.addAll(memberFields);
        fieldSet.addAll(applicationFields);
        SSP_Application__c application = new SSP_Application__c();
        List<Map<String, String>> memberOptions = new List<Map<String, String>>();
        Map<Id, SSP_Member__c> membersMap = new Map<Id, SSP_Member__c>();
        List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, fieldSet);
        for(SSP_ApplicationIndividual__c individual: applicationIndividuals) {
            SSP_Member__c member = (SSP_Member__c)individual.getSObject(SSP_ApplicationIndividual__c.SSP_Member__c.getDescribe().getSObjectField());
            application = (SSP_Application__c)individual.getSObject(SSP_ApplicationIndividual__c.SSP_Application__c.getDescribe().getSObjectField());
            membersMap.put(member.Id, member);
            memberOptions.add(new Map<String, String>{
                'label' => member.FirstName__c + ' '+ member.LastName__c,
                    'value' => member.Id
                    });
        }
        Map<String, metadataWrapper> configItems = new Map<String, metadataWrapper>();
        List<RAC_Screen_Config__mdt> racConfigs = new List<RAC_Screen_Config__mdt>();
        if(Schema.sObjectType.RAC_Screen_Config__mdt.isAccessible()){
            racConfigs = [SELECT DeveloperName, Label, Order__c, Based_On_Individual__c, toLabel(RAC_Menu_Selection__c),toLabel(RAC_Help_Text__c),toLabel(RAC_Menu_Subheader__c),(SELECT Label, PageInfo__r.PageName__c, NavigationFlowDetail__r.FlowName__c FROM Navigation_Flow_Page_Configuration__r) FROM RAC_Screen_Config__mdt ORDER BY Order__c];
        }
        for(RAC_Screen_Config__mdt config: racConfigs) {            
            metadataWrapper wrapper = new metadataWrapper();
            wrapper.optionId = config.DeveloperName;
            wrapper.RACMenuOption = config.RAC_Menu_Selection__c;            
            wrapper.isBasedOnIndividual = !config.Based_On_Individual__c;
            wrapper.showHelpText = String.isNotBlank(config.RAC_Help_Text__c); 
            wrapper.showSubHeading = String.isNotBlank(config.RAC_Menu_Subheader__c);
            wrapper.RACHelpText = config.RAC_Help_Text__c;
            wrapper.RACSubheader = config.RAC_Menu_Subheader__c;
            wrapper.members = memberOptions;
            wrapper.membersMap = membersMap;
            wrapper.screensToBeQueued = new List<Map<String, String>>();
            for(NavFlowPageConfig__mdt pageConfig: config.Navigation_Flow_Page_Configuration__r) {
                wrapper.screensToBeQueued.add(new Map<String, String> {
                    'screen' => pageConfig.PageInfo__r.PageName__c,
                        'flowName' => pageConfig.NavigationFlowDetail__r.FlowName__c
                        });
            }
            configItems.put(config.DeveloperName, wrapper);
        }
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        toSend.put('lst_mData', configItems.values());
        toSend.put('map_mData', configItems);
        toSend.bIsSuccess = true;
        return toSend;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse updateRACSelections(String applicationId, String jsonData, Boolean modifyChangeType, List<String> optionList) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try {
            if(String.isNotBlank(applicationId) && String.isNotBlank(jsonData)){
                jsonData = jsonData.trim();
                List<String> listFields = new List<String>{'Id', 'RAC_Selections__c'};
                    List<RAC_Screen_Config__mdt> racConfigs = [SELECT Review_Required_Screens_for_RAC__c, Order__c, (SELECT NavigationFlowDetail__r.FlowName__c FROM Navigation_Flow_Page_Configuration__r) 
                                                               FROM RAC_Screen_Config__mdt 
                                                               WHERE RAC_Menu_Selection__c IN :optionList
                                                               ORDER BY Order__c LIMIT 5000];                
                Set<String> reviewRequiredSet = new Set<String>();
                for(RAC_Screen_Config__mdt reviewObj : racConfigs){
                    if(reviewObj.Review_Required_Screens_for_RAC__c!=null){
                        String[] reviewRequiredList = reviewObj.Review_Required_Screens_for_RAC__c.split(';');
                        reviewRequiredSet.addAll(reviewRequiredList);
                    }
                }                
                Boolean viewApplicationFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), listFields);
                if(viewApplicationFields) {
                    SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, listFields);
                    if(application != null) {
                        application.ChangeSummaryMode__c = 'ModifyExistingData';
                        application.RAC_Selections__c = jsonData;
                        application.RAC_Selected_Options__c = String.join(optionList,',');
                        //ESAPI.accessController().updateAsUser(application);
                        // update application;
                        jsonData = jsonData.startsWith('[') ? jsonData : '[' + jsonData + ']';
                        //Make the below string a SET before.
                        List<RACSelectionWrapper> selectedWrappedData = (List<RACSelectionWrapper>)JSON.deserialize(jsonData, List<RACSelectionWrapper>.class);
                        
                        List<RACSelectionWrapper> returnRecord = new List<RACSelectionWrapper>();
                        List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                                                                                new Set<String>{'Id','SSP_Member__c', 'SSP_Application__c'},
                                                                                                                                                new Map<String, String>{'limit'=>'100','SSP_Application__c'=> applicationId}); 
                        
                        Set<String> jsonFlowNamesList = new Set<String>();
                        Set<String> selectedScreensSet = new Set<String>();
                        if(!selectedWrappedData.isEmpty()) {
                            for(RACSelectionWrapper wrap:  selectedWrappedData){
                                RACSelectionWrapper newWrap = new RACSelectionWrapper(); 
                                if(wrap.memberId!=null) {
                                    newWrap.memberId = wrap.memberId ;
                                }
                                List<ScreenDetailWrapper> screensList = wrap.selectedScreens;
                                List<ScreenDetailWrapper> newScreenList = new List<ScreenDetailWrapper>();
                                if(!screensList.isEmpty()){
                                    for(ScreenDetailWrapper sWrap : screensList){
                                        ScreenDetailWrapper wrapData = new ScreenDetailWrapper();   
                                        jsonFlowNamesList.add(sWrap.flowName);
                                        wrapData.flowName = sWrap.flowName;
                                        selectedScreensSet.addAll(sWrap.screens.split(','));
                                        // Added for 369668
                                        if (sWrap.screens.containsIgnoreCase('SSP_APP_RTF_Relationships') && lstAppIndividuals.size()<2){
                                            wrapData.screens =sWrap.screens.remove('SSP_APP_RTF_Relationships') ;
                                        }
                                        else {
                                            wrapData.screens= sWrap.screens;
                                        }
                                        if(wrapData.flowName!=null) {
                                            newScreenList.add(wrapData);
                                        }
                                    }
                                }
                                newWrap.selectedScreens = newScreenList;
                                returnRecord.add(newWrap);
                            }
                        }
                        
                        // Added for 369668
                        application.RAC_Selections__c = JSON.serialize(returnRecord, true);
                        ESAPI.accessController().updateAsUser(application, SSP_Utility.getFieldsNamesObject(application));
                        
                        if(String.isNotBlank(Label.SSP_PrimaryScreensList)) {
                            selectedScreensSet.addAll(Label.SSP_PrimaryScreensList.split(';'));
                        }
                        //Adding Review Required Set
                        if(!reviewRequiredSet.isEmpty()){
                            selectedScreensSet.addAll(reviewRequiredSet);
                        }
                        
                        //Make Reverse SSPDC Callout
                        if(!modifyChangeType){
                            invokeReverseSSPHelper(applicationId, String.join(new List<String>(selectedScreensSet), ';'));
                        }
                    }
                }
            }
            toSend.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'updateRACSelections', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse updateIndividualId(String caseNumber,String IndividualId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        List<Contact> contactList = new List<Contact>();
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
        IndividualId = SSP_Utility.getIndividualId(); //#374843
        if(IndividualId != null && IndividualId != ''){            
            
            contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                               new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c', 'Birthdate','DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                                               new Map<String, String>{'limit'=>'1','IndividualId__c'=> IndividualId});
        }else{
            List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                 new Set<String>{'Id', 'ContactId'}, 
                                                                 new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
            contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                               new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c', 'Birthdate','DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                                               new Map<String, String>{'limit'=>'1','Id'=> userList[0].ContactId});
            
        }
        if((!contactList.isEmpty()) && caseNumber != null && caseNumber !=''){
            contactList[0].IndividualId__c = mapCaseVsIndividualId.get(caseNumber);
            contactList[0].IsDashboardRefreshNeeded__c = true;
            sessionPart.put('individualId',mapCaseVsIndividualId.get(caseNumber),3600,Cache.Visibility.ALL,false);
            ESAPI.accessController().updateAsUser(new Map<ID,Contact>(contactList), SSP_Utility.getFieldsNamesList(contactList));
        }
        toSend.put('success',true);
        return toSend;
    }
    @AuraEnabled
    public static SSP_LightningResponse insertCaseApplicationAndAccount(String caseNumber){
        SSP_LightningResponse toSend = new SSP_LightningResponse();         
        try{
            if(String.isNotBlank(caseNumber)) {
                List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                     new Set<String>{'Id', 'ContactId','Profile.Name'},  //Added Profile.Name
                                                                     new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
                
                if(userList != null && userList.size() > 0){
                    List<Contact> contactList = new List<Contact>();
                    
                    contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                       new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c', 'Birthdate','DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                                                       constructConditionMap(userList[0])); //Added constructConditionMap                   
                    
                    List<SSP_Application__c> applicationList = new List<SSP_Application__c>{
                        new SSP_Application__c(
                            DCCaseNumber__c = Decimal.ValueOf(caseNumber),
                            ApplicationCreationInSSP__c = SSP_Utility.today(),
                            ApplicationReceivedDateTime__c = SSP_Utility.now()
                        )
                            
                            };
                    //Check for existing case   
                    List<SSP_Application__c> existingCaseList = new List<SSP_Application__c>();                                     
                    existingCaseList = SSP_SharingByPassFetcher.fetchExistingCase(caseNumber, userList[0].ContactId); //#374843
                    if(existingCaseList == null || (existingCaseList != null && existingCaseList.isEmpty())){
                        //Construct Application account
                        Account account = new Account();
                        account.Name = 'Application Account for ' + contactList[0].FirstName + ' ' + contactList[0].LastName;
                        account.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
                        account.CaseNumber__c = caseNumber;
                        //creates Account and ACR to link that account and current user's contact
                        Map<String,object> mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(new List<Account>{account}, null, userList[0].ContactId);//contactList[0].Id
                        account = ((List<Account>)mapRestResult.get('lstAccounts'))[0];                                                                                  
                        applicationList[0].Account__c =  account.Id;
                        applicationList[0].RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
                        applicationList = ESAPI.accessController().insertAsUser(applicationList, SSP_Utility.getFieldsNamesList (applicationList)).getInsertedObjects();                                          
                    }
                    else{
                        applicationList[0].Id = existingCaseList[0].Id;   
                        applicationList[0].SectionStatus__c = null;
                        applicationList[0].RAC_Selections__c = null;
                        ESAPI.accessController().updateAsUser(new Map<ID,SSP_Application__c>(applicationList), SSP_Utility.getFieldsNamesList (applicationList));    
                        deleteNavFlowStatus(applicationList[0].Id);
                    }
                    
                    toSend.bIsSuccess = true;
                    
                    if(contactList[0].DoesCaseExistForIndividual__c){                        
                        toSend.put('applicationId',applicationList[0].Id);
                    }                    
                }                
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'insertCaseApplicationAndAccount', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    public static void deleteNavFlowStatus(String appId) {
        SSP_SharingBypassFetcher.deleteRecords(appId);        
    }
    
    public static Contact getPrimaryIndividualId(){
        try{
            List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                 new Set<String>{'Id', 'ContactId','Profile.Name'}, //Added Profile.Name 
                                                                 new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
            
            if(userList != null && userList.size() > 0){
                List<Contact> contactList = new List<Contact>();
                
                contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                   new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c','DoesCaseExistForIndividual__c'}, 
                                                                   constructConditionMap(userList[0])); //Added constructConditionMap
                if(contactList != null && contactList.size() > 0){
                    return contactList[0];
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'getPrimaryIndividualId', ex.getMessage() , true);
        }
        return null;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse invokeQualifiedCalloutHelper(String applicationId, String caseNumber){
        SSP_Utility.isAuthenticatedUser();
        Map<String, metadataWrapper> processedData = new Map<String, metadataWrapper>();
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        
        try{
            String userID = UserInfo.getuserId();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
            
            if(String.isNotBlank(applicationId) && String.isNotBlank(caseNumber)){
                List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                     new Set<String>{'Id', 'ContactId','Profile.Name'}, //Added Profile.Name 
                                                                     new Map<String, String>{'limit'=>'1','Id'=> userID});
                
                if(userList != null && userList.size() > 0) {
                    Id contactId = userList[0].ContactId;
                    List<Contact> contactList = new List<Contact>();
                    contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                       new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c', 'Birthdate','DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                                                       constructConditionMap(userList[0])); //Added constructConditionMap                    
                    if(contactList[0].DoesCaseExistForIndividual__c){
                        //String processedDataJSON = 
                        invokeQualifiedIndividualService(new Map<String, String>{
                            'appId' => applicationId,
                                'indId' => mapCaseVsIndividualId.get(caseNumber),
                                'caseNo' => caseNumber
                                });
                        toSend.bIsSuccess = true;
                        toSend.put('result', true);
                        //toSend.put('processedData', processedData);
                    }
                    
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'insertCaseApplicationAndAccount', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    @future(callout=true)
    public static void invokeQualifiedIndividualService(Map<String, String> pMap){
        List<Object> resObj = new List<Object>();   // Confirm what to return
        Map<String, metadataWrapper> processedData = new Map<String, metadataWrapper>();
        try{                
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.QUALIFIED_INDIVIDUALS;
            reqWrapper.mode = SSP_InterfaceConstants.MODE_RAC;
            reqWrapper.primaryApplicationIndividualId = pMap.get('indId');
            reqWrapper.applicationID = pMap.get('appId');
            reqWrapper.caseNumber = Integer.valueOf(pMap.get('caseNo'));
            //reqWrapper.programCode = pMap.get('programs');    // to be confirmed if this is needed
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            
            
            /*if(resObj != null){
processedData = invokeRACSelectionService(new Map<String, String>{
'appId' => reqWrapper.applicationID,
'indId' => String.valueOf(reqWrapper.primaryApplicationIndividualId)
});
}*/
            
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'invokeQualifiedIndividualService', ex.getMessage() , true);
        }
        //return JSON.serialize(processedData);
    }
    
    @AuraEnabled
    public static SSP_LightningResponse invokeRACServiceCalloutHelper(String applicationId, String caseNumber){
        SSP_Utility.isAuthenticatedUser();
        Map<String, metadataWrapper> processedData = new Map<String, metadataWrapper>();
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        String sErrorCode;
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            
            mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
            
            if(String.isNotBlank(applicationId) && String.isNotBlank(caseNumber)){
                
                Contact contact = getPrimaryIndividualId();
                
                objResponse =  invokeRACSelectionService(new Map<String, String>{
                    'appId' => applicationId,
                        'caseNo' => caseNumber,
                        'indId' => mapCaseVsIndividualId.get(caseNumber)
                        });
                if(objResponse != NULL){
                    processedData = (Map<String, metadataWrapper>)objResponse.mapResponse.get('processedData');
                    sErrorCode = (String)objResponse.mapResponse.get('error');
                    if(sErrorCode != NULL && String.isNotBlank(sErrorCode)){
                        //toSend.bIsSuccess = false;
                        toSend.put('bIsSuccess', false);
                        tosend.put('error', sErrorCode);
                    }else{
                        if(processedData != null && processedData.keySet().size() > 0){
                            //toSend.bIsSuccess = true;
                            toSend.put('bIsSuccess', true);
                            toSend.put('processedData', processedData);
                            toSend.put('processedDataList', processedData.values());
                            toSend.put('applicationReady', true);
                        }
                    }
                    /*else{
toSend.put('applicationReady', false);
tosend.put('serverFailure', true);
}*/
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'insertCaseApplicationAndAccount', ex.getMessage() , true);
            //toSend.bIsSuccess = false;
            toSend.put('bIsSuccess', false);
            toSend.put('applicationReady', false);
            toSend.put('error', lstLogMessages[0].Id);
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    @AuraEnabled    
    public static SSP_LightningResponse invokeRACSelectionService(Map<String, String> pMap){
        List<Object> resObj = new List<Object>();   //Confirm what to return
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        RSSP_DC_Wrapper wrapperResponse  = new RSSP_DC_Wrapper();
        Map<String, metadataWrapper> processedData = new Map<String, metadataWrapper>();
        try{                
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.RAC_SELECTION_DETAILS;
            reqWrapper.mode = SSP_InterfaceConstants.MODE_RAC;
            reqWrapper.caseNumber = Integer.valueOf(pMap.get('caseNo'));
            reqWrapper.applicationID = pMap.get('appId');
            reqWrapper.primaryApplicationIndividualId = pMap.get('indId');
            //reqWrapper.programCode = pMap.get('programs');    // to be confirmed if this is needed
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            resObj = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            
            if(resObj != null){
                wrapperResponse =  (RSSP_DC_Wrapper) resObj[0];
                if(wrapperResponse.ACKRESPONSE != NULL && wrapperResponse.ACKRESPONSE.AckResponseCode != NULL){ 
                    objResponse.put('error', wrapperResponse.ACKRESPONSE.AckResponseCode);
                }else{
                    RACCalloutDataWrapper wrapResult = parseRACSelectionServiceResponse(JSON.serialize(resObj));
                    Map<String, metadataWrapper> racConfigsMap = getRACConfigMetadata();
                    processedData = RACOptionRenderHelper(racConfigsMap, wrapResult, pMap.get('appId'), pMap.get('indId'));
                }
            }
            objResponse.put('processedData',processedData);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'invokeRACSelectionService', ex.getMessage() , true);
        }
        return objResponse;
    }
    /*@AuraEnabled    
public static Map<String, metadataWrapper> invokeRACSelectionService(Map<String, String> pMap){
List<Object> resObj = new List<Object>();   //Confirm what to return
Map<String, metadataWrapper> processedData = new Map<String, metadataWrapper>();
try{                
Map<String, Object> mapParams = new Map<String, Object>();
SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
reqWrapper.viewName = SSP_InterfaceConstants.RAC_SELECTION_DETAILS;
reqWrapper.mode = SSP_InterfaceConstants.MODE_RAC;
reqWrapper.caseNumber = Integer.valueOf(pMap.get('caseNo'));
reqWrapper.applicationID = pMap.get('appId');
reqWrapper.primaryApplicationIndividualId = Integer.valueOf(pMap.get('indId'));
//reqWrapper.programCode = pMap.get('programs');    // to be confirmed if this is needed
mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
resObj = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams); 

if(resObj != null){
RACCalloutDataWrapper wrapResult = parseRACSelectionServiceResponse(JSON.serialize(resObj));
Map<String, metadataWrapper> racConfigsMap = getRACConfigMetadata();
processedData = RACOptionRenderHelper(racConfigsMap, wrapResult, pMap.get('appId'));
}
}
catch(Exception ex){
List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'invokeRACSelectionService', ex.getMessage() , true);
}
return processedData;
}*/
    
    public static void invokeReverseSSPHelper(Id applicationId, String selectedScreens){
        try{
            Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            
            mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
            
            if(String.isNotBlank(applicationId) && String.isNotBlank(selectedScreens)){
                List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                     new Set<String>{'Id', 'ContactId','Profile.Name'}, //Added Profile.Name 
                                                                     new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
                
                if(userList != null && userList.size() > 0){
                    List<Contact> contactList = new List<Contact>();
                    
                    contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                       new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c', 'Birthdate','DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                                                       constructConditionMap(userList[0])); //Added constructConditionMap                    
                    if(contactList[0].DoesCaseExistForIndividual__c){
                        //invokeReverseSSPService(applicationId, selectedScreens, contactList[0].IndividualId__c,mapCaseVsIndividualId);
                        System.enqueueJob(new SSP_ReportChangeSelectionService(applicationId, selectedScreens, contactList[0].IndividualId__c,mapCaseVsIndividualId));
                    }       
                }
                
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'invokeReverseSSPHelper', ex.getMessage() , true);
        }
    }
    
    
    //@future(callout=true)
    public static void invokeReverseSSPService(String applicationId, String selectedScreens, String individualId,Map<String, String> mapCaseVsIndividualId){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        selectedScreens = selectedScreens + ';' + 'SSP_RAC_SelectChangesToReport';        
        try{
            //List<User> userData = SSP_Utility.getCurrentUserDetails();
            Map<String, Object> mapParams = new Map<String, Object>();
            if(String.isNotBlank(applicationId) && String.isNotBlank(selectedScreens)){
                List<SSP_Application__c> sspAppList = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                                   new Set<String>{'Id','RAC_Selections__c','DCCaseNumber__c','ProgramsApplied__c'}, 
                                                                                                   new Map<String, String>{'limit'=>'1000','id'=> applicationId, 'RecordTypeId'=>SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case')});
                if(!sspAppList.isEmpty()){
                    SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                    reqWrapper.viewName = SSP_InterfaceConstants.ALL_VIEWS;
                    reqWrapper.mode = SSP_InterfaceConstants.MODE_RAC;
                    reqWrapper.caseNumber = Integer.valueOf(sspAppList[0].DCCaseNumber__c);
                    //reqWrapper.primaryApplicationIndividualId = Integer.valueOf(userData[0].Contact.IndividualId__c);
                    reqWrapper.primaryApplicationIndividualId = mapCaseVsIndividualId.get(String.valueOf(sspAppList[0].DCCaseNumber__c));
                    reqWrapper.programCode = sspAppList[0].ProgramsApplied__c;
                    reqWrapper.applicationID = applicationId;
                    mapParams.put(SSP_InterfaceConstants.JSON_BODY, reqWrapper);
                    mapParams.put(SSP_InterfaceConstants.SSP_SCREEN_NAMES, selectedScreens);
                    String callOutResponse = JSON.serialize(IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams));
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'invokeReverseSSPService', ex.getMessage() , true);
        }
    }
    
    
    @AuraEnabled
    public static void invokeReverseSSPAddRemoveMemberHelper(Id applicationId, String caseNumber){
        SSP_Utility.isAuthenticatedUser();
        try{
            Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            
            mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
            
            if(String.isNotBlank(applicationId) && String.isNotBlank(caseNumber)){
                List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                     new Set<String>{'Id', 'ContactId','Profile.Name'}, //Added Profile.Name 
                                                                     new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
                
                List<String> listFields = new List<String>{'Id', 'ProgramsApplied__c', 'ApplicationReceivedDateTime__c'};
                    SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, listFields);
                
                if(userList != null && userList.size() > 0 && application != null){
                    List<Contact> contactList = new List<Contact>();
                    
                    contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                       new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c', 'Birthdate','DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                                                       constructConditionMap(userList[0])); //Added constructConditionMap
                    if(contactList[0].DoesCaseExistForIndividual__c){
                        // Invoke Reverse SSP DC Service for Add/Remove Members
                        invokeReverseSSPForAddRemoveMember(applicationId, caseNumber, mapCaseVsIndividualId.get(caseNumber), application.ProgramsApplied__c);
                        application.ApplicationReceivedDateTime__c = SSP_Utility.now();
                        ESAPI.accessController().updateAsUser(application, SSP_Utility.getFieldsNamesObject(application));
                    }
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'invokeReverseSSPHelper', ex.getMessage() , true);
        }
    }
    
    
    public static void invokeReverseSSPForAddRemoveMember(String applicationId, String caseNumber, String individualId, String programs){
        try{
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.ALL_VIEWS;
            reqWrapper.primaryApplicationIndividualId = individualId;
            reqWrapper.programCode = programs;
            reqWrapper.applicationID = applicationId;
            reqWrapper.caseNumber = Integer.valueOf(caseNumber);
            reqWrapper.mode = SSP_InterfaceConstants.MODE_RAC;
            System.enqueueJob(new SSP_RSSPDC_CalloutHelper(SSP_InterfaceConstants.REVERSE_SSP_DC, reqWrapper));
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'invokeReverseSSPForAddRemoveMember', ex.getMessage() , true);
        }
    }
    
    
    @AuraEnabled
    public static SSP_Application__c getProgramsAppliedOnApplication(String applicationId){
        SSP_Application__c application = new SSP_Application__c();
        try{
            if(String.isNotBlank(applicationId)){
                List<String> listFields = new List<String>{'Id', 'ProgramsApplied__c'};
                    Boolean viewApplicationFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), listFields);
                if(viewApplicationFields){
                    application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, listFields);
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'getProgramsAppliedOnApplication', ex.getMessage() , true);
        }
        return application;
    }
    
    
    
    //public static void renderRACOptionsConditionally(String RACCallResponse){
    public static RACCalloutDataWrapper parseRACSelectionServiceResponse(String RACCallResponse){
        //Get the picklist values
        Map<String,String> mapCoverageCode = SSP_Utility.getPickListValues ('SSP_InsurancePolicy__c', 'TypeOfCoverageCode__c',''); 
        Map<String,String> mapIncomeTypeCode = SSP_Utility.getPickListValues ('SSP_Asset__c', 'IncomeTypeCode__c',''); 
        Map<String,String> mapIncomeSubTypeCode = SSP_Utility.getPickListValues ('SSP_Asset__c', 'IncomeSubtypeCode__c',''); 
        Map<String,String> mapIncomePayFrequency = SSP_Utility.getPickListValues ('SSP_Asset__c', 'IncomePayFrequency__c',''); 
        Map<String,String> mapBusinessTypeCode = SSP_Utility.getPickListValues ('SSP_Asset__c', 'BusinessTypeCode__c',''); 
        Map<String,String> mapFrequency = new Map<String,String>{'MO'=> System.Label.ssp_month , 'BW'=> System.Label.SSP_BIWeek ,'QU' => System.Label.SSP_Quarter,'SM' => System.Label.SSP_TwiceMonth ,'WE' => System.Label.SSP_Week,'YR' => System.Label.SSP_YearFrequency,'DA' => System.Label.SSP_DayFrequency,'HO' => System.Label.SSP_Hour,'SP' => System.Label.SSP_Contractual,'ON' => System.Label.SSP_LumpSum};
            
            RACCalloutDataWrapper dataWrap = new RACCalloutDataWrapper();
        List<RSSP_DC_Wrapper> wrappedResponse = new List<RSSP_DC_Wrapper>();
        try{
            if(String.isNotBlank(RACCallResponse)){
                wrappedResponse = (List<RSSP_DC_Wrapper>)JSON.deserialize(RACCallResponse, List<RSSP_DC_Wrapper>.class);
                SSP_RACSelectionDetailsWrapper payloadWrapper = wrappedResponse[0].racSelectionWrapper;
                List<healthCareInfo> healthCareList = new List<healthCareInfo>();
                List<memberInfo> membersList = new List<memberInfo>();
                List<incomeInfo> incomeList = new List<incomeInfo>();
                
                if(payloadWrapper.Healthcare != null){
                    for(SSP_RACSelectionDetailsWrapper.Healthcare health : payloadWrapper.Healthcare){
                        healthCareInfo healthInfo = new healthCareInfo();
                        healthInfo.PlanName = health.PlanName;
                        healthInfo.InsuranceCompanyName = health.InsuranceCompanyName;
                        healthInfo.InsurancePolicyNumber = health.InsurancePolicyNumber;
                        healthInfo.PolicyHolderName = health.PolicyHolderName;
                        healthInfo.TypeOfCoverageCode = mapCoverageCode.get(health.TypeOfCoverageCode);
                        healthCareList.add(healthInfo);
                    }                    
                    dataWrap.healthCareInfoList = healthCareList;
                }
                if(payloadWrapper.SSPMember != null){
                    for(SSP_RACSelectionDetailsWrapper.SSPMember member : payloadWrapper.SSPMember){
                        memberInfo memberData = new memberInfo();
                        memberData.FullName = member.FullName;
                        memberData.IndividualId = member.IndividualId;
                        memberData.BirthDate = member.BirthDate;
                        memberData.IsReceivingMedicareBenefitToggle = member.IsReceivingMedicareBenefitToggle;
                        memberData.IsUSCitizenToggle = member.IsUSCitizenToggle;
                        memberData.HasEmergencyMedicalConditionToggle = member.HasEmergencyMedicalConditionToggle;
                        memberData.IsRecoveryFromIllnessOrInjuryToggle = member.IsRecoveryFromIllnessOrInjuryToggle;
                        memberData.IsDisabledToggle = member.IsDisabledToggle;
                        memberData.IsBlindToggle = member.IsBlindToggle;
                        memberData.IsPregnantInLastThreeMonthsToggle = member.IsPregnantInLastThreeMonthsToggle;
                        memberData.GenderCode = member.GenderCode;
                        memberData.TemporarilyLivesElsewhereToggle = member.TemporarilyLivesElsewhereToggle;
                        memberData.InHomeCareType = member.InHomeCareType;
                        memberData.IsEnrolledInSchool = member.IsEnrolledInSchool;
                        membersList.add(memberData);
                    }                    
                    dataWrap.memberInfoList = membersList;
                }
                if(payloadWrapper.Income != null){
                    for(SSP_RACSelectionDetailsWrapper.Income income : payloadWrapper.Income){
                        incomeInfo incomeData = new incomeInfo();
                        incomeData.IncomeTypeCode = mapIncomeTypeCode.get(income.IncomeTypeCode);
                        incomeData.IncomeSubTypeCode = mapIncomeSubTypeCode.get(income.IncomeSubTypeCode);
                        incomeData.IncomePayFrequency = mapFrequency.get(income.IncomePayFrequency);//mapIncomePayFrequency.get(income.IncomePayFrequency);
                        incomeData.TotalGrossAmount = income.TotalGrossAmount;
                        incomeData.EmployerName = income.EmployerName;
                        incomeData.BusinessTypeCode = mapBusinessTypeCode.get(income.BusinessTypeCode);
                        incomeData.IncomePayDetailHoursPerWeek = income.IncomePayDetailHoursPerWeek;
                        incomeData.IndividualId = income.IndividualId;
                        incomeData.FullName = income.FullName;
                        String payFrequency = null!=mapFrequency.get(income.IncomePayFrequency) ? '/' + mapFrequency.get(income.IncomePayFrequency):'';
                        
                        
                        if(income.IncomeTypeCode == 'EA'){
                            incomeData.incomeSourceName = income.EmployerName;
                            incomeData.grossIncomeFormatted = '$ ' + income.TotalGrossAmount + payFrequency ; //'/' + mapIncomePayFrequency.get(income.IncomePayFrequency);  
                        }
                        else if(income.IncomeTypeCode == 'SE'){
                            incomeData.incomeSourceName = mapBusinessTypeCode.get(income.BusinessTypeCode);
                            incomeData.grossIncomeFormatted = '$ ' + income.TotalGrossAmount +  payFrequency;  //'/' + mapIncomePayFrequency.get(income.IncomePayFrequency);  
                        }
                        else{
                            incomeData.incomeSourceName = mapIncomeSubTypeCode.get(income.IncomeSubTypeCode);
                            if(income.IncomeTypeCode == 'UI'){
                                incomeData.grossIncomeFormatted = income.IncomePayDetailHoursPerWeek + 'hours' + payFrequency; //+ mapIncomePayFrequency.get(income.IncomePayFrequency);
                            }
                            else{
                                incomeData.grossIncomeFormatted = '$ ' + income.TotalGrossAmount + payFrequency ; //'/' + mapIncomePayFrequency.get(income.IncomePayFrequency);
                            }
                        }
                        
                        incomeList.add(incomeData);
                    }                    
                    dataWrap.incomeInfoList = incomeList;
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'renderRACOptionsConditionally', ex.getMessage() , true);
        }
        return dataWrap;
        //return wrappedResponse;
    }
    
    
    public static Map<String, metadataWrapper> getRACConfigMetadata(){
        Map<String, metadataWrapper> configItems = new Map<String, metadataWrapper>();        
        List<RAC_Screen_Config__mdt> racConfigs = new List<RAC_Screen_Config__mdt>();

        if(Schema.sObjectType.RAC_Screen_Config__mdt.isAccessible()){
            racConfigs = [SELECT RAC_Screen_Ids__c,DeveloperName, Label, Order__c, Based_On_Individual__c,toLabel(RAC_Menu_Selection__c),toLabel(RAC_Help_Text__c),toLabel(RAC_Menu_Subheader__c), (SELECT Label, PageInfo__r.PageName__c, NavigationFlowDetail__r.FlowName__c FROM Navigation_Flow_Page_Configuration__r) FROM RAC_Screen_Config__mdt ORDER BY Order__c];
        }   
        if(!racConfigs.isEmpty()){
            for(RAC_Screen_Config__mdt config: racConfigs) {
                metadataWrapper wrapper = new metadataWrapper();
                wrapper.optionId = config.DeveloperName;                
                wrapper.RACMenuOption = config.RAC_Menu_Selection__c;                
                wrapper.isBasedOnIndividual = !config.Based_On_Individual__c;
                wrapper.showHelpText = String.isNotBlank(config.RAC_Help_Text__c); 
                wrapper.showSubHeading = String.isNotBlank(config.RAC_Menu_Subheader__c);
                wrapper.RACHelpText = config.RAC_Help_Text__c;
                wrapper.RACSubheader = config.RAC_Menu_Subheader__c;
                //wrapper.members = memberOptions;
                //wrapper.membersMap = membersMap;
                wrapper.screensToBeQueued = new List<Map<String, String>>();
                for(NavFlowPageConfig__mdt pageConfig: config.Navigation_Flow_Page_Configuration__r) {
                    wrapper.screensToBeQueued.add(new Map<String, String> {
                        'screen' => pageConfig.PageInfo__r.PageName__c,
                            'flowName' => pageConfig.NavigationFlowDetail__r.FlowName__c
                            });
                }
                if(config.DeveloperName=='CIS_CareTaker'){
                    wrapper.screensToBeQueued.add(new Map<String, String> {
                        'screen' => 'SSP_APP_Select_Health',
                            'flowName' => 'HouseholdInformation'
                            });
                    wrapper.screensToBeQueued.add(new Map<String, String> {
                        'screen' => 'CIS_CareTaker',
                            'flowName' => 'CIS_CareTaker'
                            });
                    
                }
                if(config.DeveloperName == 'Member_Information'){
                    wrapper.screensToBeQueued.add(new Map<String, String> {
                        'screen' => config.RAC_Screen_Ids__c,
                            'flowName' => config.RAC_Screen_Ids__c
                            });
                }                
                configItems.put(config.DeveloperName, wrapper);
            }
        }
        return configItems;
    }
    
    
    public static Map<String, metadataWrapper> RACOptionRenderHelper(Map<String, metadataWrapper> mapRACConfigs, RACCalloutDataWrapper wrapResult, String applicationId, String primaryIndividualId){
        SSP_Application__c application = new SSP_Application__c();
        //Logic to include Applied Programs filtering on Options
        if(String.isNotBlank(applicationId) && wrapResult != null && !(mapRACConfigs.keySet()).isEmpty()){
            application = getProgramsAppliedOnApplication(applicationId);
        }
        if(application != null){
            String programs = application.ProgramsApplied__c;
            if(String.isNotBlank(programs)){
                for(String mapKey : mapRACConfigs.keySet()){                    
                    if(mapKey == 'Healthcare_Coverage'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.KHIPP) ){
                            metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                            if(wrapResult.healthCareInfoList != null){
                                List<healthCareInfo> healthInfoList = wrapResult.healthCareInfoList;
                                for(healthCareInfo health : healthInfoList){
                                    health.isHealth = true;
                                }
                                if(healthInfoList != null && healthInfoList.size() > 0){
                                    mdWrap.summary = healthInfoList;
                                }
                                else {
                                    mdWrap.summary = new List<Object>();
                                }
                            }
                            else{
                                mdWrap.summary = new List<Object>();
                            }
                        }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Contact_Information'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE) || 
                           programs.contains(SSP_GlobalConstants.KHIPP) || programs.contains(SSP_GlobalConstants.STATE) ){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               if(wrapResult.memberInfoList != null) {
                                   for(MemberInfo member: wrapResult.memberInfoList) {
                                       if(String.isNotBlank(member.BirthDate)) {
                                           Date birthDate = Date.valueOf(member.birthDate);
                                           
                                           Double age = Math.floor((birthDate.daysBetween(SSP_Utility.today()))/365.2545); //Defect# 386005
                                           if(age >= 16 || primaryIndividualId == member.IndividualId) {
                                               mdWrap.memberInfoList.add(member);
                                           }
                                       }
                                   }
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Education'){
                        metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                        List<memberInfo> memList = wrapResult.memberInfoList;
                        if(memList != null && !memList.isEmpty()){
                            for(memberInfo mem : memList){
                                Date birthDate = Date.valueOf(mem.birthDate);
                                //Integer age = Integer.valueOf(birthDate.daysBetween(SSP_Utility.today()) / 365);
                                Double age = Math.floor((birthDate.daysBetween(SSP_Utility.today()))/365.2545);
                                //if(mem.IsEnrolledInSchool == 'Y'){
                                //Call Validation Method
                                Boolean toBeAdded = validateEducationScreenUsers(programs,age);
                                if(toBeAdded){
                                 mdWrap.memberInfoList.add(mem);   
                                }
                                //}
                            }
                            if(!mdWrap.memberInfoList.isEmpty()){
                                mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                            }
                        }
                        if(mdWrap.members.isEmpty()){
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Pregnancy'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.STATE) ){
                               Date todayDate = SSP_Utility.today();
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               List<memberInfo> memList = wrapResult.memberInfoList;
                               if(memList != null){
                                   for(memberInfo mem : memList){
                                       if(mem.BirthDate != null){
                                           List<String> dateElements = mem.BirthDate.split('-');
                                           Date birthDate = date.newInstance(Integer.valueOf(dateElements[0]), Integer.valueOf(dateElements[1]), Integer.valueOf(dateElements[2]));
                                           Double age = Math.floor((birthDate.daysBetween(todayDate))/365.2545); // Fixed as a part of Defect # 386005
                                           if(mem.GenderCode == 'F' && age >= 11){  // check if this needed:- mem.IsPregnantInLastThreeMonthsToggle
                                               mdWrap.memberInfoList.add(mem);
                                           }
                                       }
                                   }
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    else if(mapKey == 'CIS_CareTaker'){
                        String selectedRole  = SSP_Utility.getSelectedRole();
                        if(programs.contains(SSP_GlobalConstants.STATE) && selectedRole!=SSP_GlobalConstants.CITIZEN_ROLE && SSP_Utility.getAvailableProgramsByRole().contains(SSP_GlobalConstants.STATE) ){
                            metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                            if(wrapResult.memberInfoList != null){
                                mdWrap.memberInfoList = wrapResult.memberInfoList;
                                mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                            }
                        }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    else if(mapKey == 'Relationship_and_Tax_filing_Status'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE) || 
                           programs.contains(SSP_GlobalConstants.STATE) ){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               if(wrapResult.memberInfoList != null){
                                   //if(wrapResult.memberInfoList.size() >= 2){
                                   mdWrap.memberInfoList = wrapResult.memberInfoList;
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                                   //}
                                   if (!(programs.contains(SSP_GlobalConstants.MEDICAID)) && !(programs.contains(SSP_GlobalConstants.STATE)) && wrapResult.memberInfoList.size() == 1) {
                                       mapRACConfigs.remove(mapKey);
                                   }
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Living_Arrangement'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE) || 
                           programs.contains(SSP_GlobalConstants.STATE) ){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               List<memberInfo> memList = wrapResult.memberInfoList;
                               if(memList != null){
                                   for(memberInfo mem : memList){
                                       //if(mem.TemporarilyLivesElsewhereToggle == 'Y' || mem.InHomeCareType == 'Y'){
                                       mdWrap.memberInfoList.add(mem);
                                       //}
                                   }
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Resource_Any_Resource'){
                        String[] progList = programs != null ? programs.split(';') : new List<String>();
                        Boolean isNonMAGI = false;
                        for(memberInfo mem : wrapResult.memberInfoList){                            
                            if((progList.contains(SSP_GlobalConstants.MEDICAID) && 
                                (mem.IsDisabledToggle == SSP_GlobalConstants.YES || mem.IsBlindToggle == SSP_GlobalConstants.YES 
                                                            || SSP_ResourcesService.isNONMagiApplication(applicationId)))){
                                isNonMAGI = true;
                                break;
                            }
                        }
                        if(isNonMAGI ||
                          (programs!= null && SSP_ResourcesService.hasProgramApplicable(programs.split(';'), new List<String>{
                            SSP_GlobalConstants.SNAP, SSP_GlobalConstants.KTAP, SSP_GlobalConstants.STATE
                        }))){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               if(wrapResult.memberInfoList != null){
                                   mdWrap.memberInfoList = wrapResult.memberInfoList;
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Expense_Any_Expense'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE) || 
                           programs.contains(SSP_GlobalConstants.STATE) ){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               if(wrapResult.memberInfoList != null){
                                   mdWrap.memberInfoList = wrapResult.memberInfoList;
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList); 
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Emergency_Medical_Condition_and_Disabi'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE) || 
                           programs.contains(SSP_GlobalConstants.STATE) ){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               List<memberInfo> memList = wrapResult.memberInfoList;
                               if(memList != null){
                                   for(memberInfo mem : memList){
                                       //if(mem.HasEmergencyMedicalConditionToggle == 'Y' || mem.IsBlindToggle == 'Y' || mem.IsDisabledToggle == 'Y' || mem.IsRecoveryFromIllnessOrInjuryToggle == 'Y'){
                                       mdWrap.memberInfoList.add(mem);
                                       //}
                                   }
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Medicare_Coverage'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.STATE) ){
                            metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                            List<memberInfo> memList = wrapResult.memberInfoList;
                            if(memList != null){
                                for(memberInfo mem : memList){
                                    //if(mem.IsReceivingMedicareBenefitToggle == 'Y'){
                                    mdWrap.memberInfoList.add(mem);
                                    //}
                                }
                                mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                            }
                        }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Member_Information'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE) || 
                           programs.contains(SSP_GlobalConstants.KHIPP) || programs.contains(SSP_GlobalConstants.STATE) ){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               if(wrapResult.memberInfoList != null){
                                   mdWrap.memberInfoList = wrapResult.memberInfoList;
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                    else if(mapKey == 'Income_Any_Income'){
                        if(programs.contains(SSP_GlobalConstants.MEDICAID) || programs.contains(SSP_GlobalConstants.SNAP) || 
                           programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE) || 
                            programs.contains(SSP_GlobalConstants.STATE) ){
                               metadataWrapper mdWrap = mapRACConfigs.get(mapKey);
                               List<incomeInfo> incomeInfoList = wrapResult.incomeInfoList;
                               if(wrapResult.incomeInfoList != null){
                                   for(incomeInfo income : incomeInfoList){
                                       income.isIncome = true;
                                   }
                                   mdWrap.summary = incomeInfoList;
                               }
                               // Try- Make map of Income for Each Member
                               Map<String, List<incomeInfo>> incomePerMemberMap = new Map<String, List<incomeInfo>>();
                               if(wrapResult.incomeInfoList != null){
                                   for(incomeInfo income : incomeInfoList){
                                       income.isIncome = true;
                                       if(!incomePerMemberMap.containsKey(income.FullName)){
                                           incomePerMemberMap.put(income.FullName, new List<incomeInfo>());
                                       }
                                       List<incomeInfo> tempIncomeList = incomePerMemberMap.get(income.FullName);
                                       tempIncomeList.add(income);
                                       incomePerMemberMap.put(income.FullName, tempIncomeList);
                                   }
                                   //mdWrap.incomeMap = (List<Object>) incomePerMemberMap.values();
                                   mdWrap.incomeMap = incomePerMemberMap;
                               }
                               
                               if(wrapResult.memberInfoList != null){
                                   mdWrap.memberInfoList = wrapResult.memberInfoList;
                                   mdWrap.members = createMemberOptions(mdWrap.memberInfoList);
                               }
                           }
                        else{
                            mapRACConfigs.remove(mapKey);
                        }
                    }
                    
                }
            }
        }
        return mapRACConfigs;
    }
    
    public static List<Map<String,String>> createMemberOptions(List<memberInfo> memList){
        List<Map<String,String>> memOptionsList = new List<Map<String,String>>();
        if(memList != null){
            for(memberInfo mem : memList){
                memOptionsList.add(new Map<String, String>{
                    'label' => mem.FullName,
                        'value' => mem.IndividualId
                        });
            }
        }
        return memOptionsList;
    }
    
    @AuraEnabled
    public static void deleteCreatedDataOnExit(String applicationId){
        SSP_Utility.isAuthenticatedUser();
        try{
            if(String.isNotBlank(applicationId)){
                List<SSP_Member__c> memberDeleteList = new List<SSP_Member__c>();
                SSP_Application__c application = new SSP_Application__c();
                List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId)});           
                
                for(SSP_ApplicationIndividual__c appInd : sspApplicationIndividualList){
                    memberDeleteList.add(new SSP_Member__c(Id = appInd.SSP_Member__c));
                }
                
                List<String> listFields = new List<String>{'Id', 'Account__c'};
                    Boolean viewApplicationFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), listFields);
                if(viewApplicationFields){
                    application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, listFields);
                }
                
                delete (new Account(Id = application.Account__c));
                delete memberDeleteList;
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'getProgramsAppliedOnApplication', ex.getMessage() , true);
        }
    }
    
    @AuraEnabled
    public static SSP_LightningResponse applicationIndividualForPolling(String applicationId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            if(String.isNotBlank(applicationId)){
                Contact contact = getPrimaryIndividualId();
                String appId = contact.IndividualId__c;
                Map<String,String> status = SSP_Utility.isDataProcessed(appId, 'SSP_RAC_SelectChangesToReport', 'RAC');
                toSend.put('status', status);
                if(status.get('status') == 'Failed') {
                    toSend.put('statusFailed', true);
                    LOG_LogMessage__c objLogMessage = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, 'SSP_ReportChangeSelectionCtrl', 'applicationIndividualForPolling', 'Unable to get the RAC Data' , true);
                    toSend.put('Error', objLogMessage.Name);
                }
                Map<String,String> mapConditions = new Map<String,String>();
                mapConditions.put('SSP_Application__c', applicationId);
                List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                new Set<String>{'Id','Name','ProgramsApplied__c'}, 
                                                                mapConditions);
                if(applicationIndividuals != null && applicationIndividuals.size() > 0){
                    toSend.bIsSuccess = true;
                    toSend.put('applicationReady', true);
                    toSend.put('applicationIndividual',applicationIndividuals);
                }
                else{
                    toSend.bIsSuccess = true;
                    toSend.put('applicationReady', false);
                }
            }
        }
        catch(Exception ex){
            toSend.bIsSuccess = false;
            toSend.put('applicationReady', false);
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_KHIPPPreferredPaymentMethodQueueRule', 'applicationIndividualForPolling', ex.getMessage() , true);
            toSend.put('Error', lstLogMessages[0].Name);
        }
        return toSend;
    }
    
    
    public class metadataWrapper{
        @AuraEnabled public String optionId;
        @AuraEnabled public Boolean isBasedOnIndividual;
        @AuraEnabled public Boolean showSubHeading;
        @AuraEnabled public Boolean showHelpText;
        @AuraEnabled public String RACMenuOption;
        @AuraEnabled public String RACSubheader;
        @AuraEnabled public String  RACHelpText;
        @AuraEnabled public Map<Id, SSP_Member__c> membersMap = new Map<Id, SSP_Member__c>();
        @AuraEnabled public List<Map<String, String>> members = new List<Map<String, String>>();
        @AuraEnabled public List<Map<String, String>> screensToBeQueued = new List<Map<String, String>>();
        //@AuraEnabled public List<healthCareInfo> healthInfoList = new List<healthCareInfo>();
        @AuraEnabled public List<memberInfo> memberInfoList = new List<memberInfo>();
        @AuraEnabled public List<Object> summary;
        @AuraEnabled public Map<String,List<incomeInfo>> incomeMap;
    }
    
    public class healthCareInfo{
        @AuraEnabled public String PlanName;
        @AuraEnabled public String InsuranceCompanyName;
        @AuraEnabled public String TypeOfCoverageCode;
        @AuraEnabled public String InsurancePolicyNumber;
        @AuraEnabled public String PolicyHolderName;
        @AuraEnabled public boolean isHealth;
    }
    
    public class memberInfo {
        @AuraEnabled public String IndividualId;
        @AuraEnabled public String FullName;
        @AuraEnabled public String BirthDate;
        @AuraEnabled public String IsReceivingMedicareBenefitToggle;
        @AuraEnabled public String IsUSCitizenToggle;
        @AuraEnabled public String HasEmergencyMedicalConditionToggle;
        @AuraEnabled public String IsRecoveryFromIllnessOrInjuryToggle;
        @AuraEnabled public String IsDisabledToggle;
        @AuraEnabled public String IsBlindToggle;
        @AuraEnabled public String IsPregnantInLastThreeMonthsToggle;
        @AuraEnabled public String GenderCode;
        @AuraEnabled public String TemporarilyLivesElsewhereToggle;
        @AuraEnabled public String InHomeCareType;
        @AuraEnabled public String IsEnrolledInSchool;
    }
    
    public class incomeInfo{
        @AuraEnabled public String IncomeTypeCode;
        @AuraEnabled public String IncomeSubTypeCode;
        @AuraEnabled public String IncomePayFrequency;
        @AuraEnabled public String TotalGrossAmount;
        @AuraEnabled public String EmployerName;
        @AuraEnabled public String BusinessTypeCode;
        @AuraEnabled public String IncomePayDetailHoursPerWeek;
        @AuraEnabled public String IndividualId;
        @AuraEnabled public String FullName;
        @AuraEnabled public boolean isIncome;
        @AuraEnabled public String incomeSourceName;
        @AuraEnabled public String grossIncomeFormatted;
    }
    
    public class RACCalloutDataWrapper{
        @AuraEnabled public List<incomeInfo> incomeInfoList;
        @AuraEnabled public List<memberInfo> memberInfoList;
        @AuraEnabled public List<healthCareInfo> healthCareInfoList;
        
    }
    
    public class RACSelectionWrapper{        
        public String memberId;
        public List<ScreenDetailWrapper> selectedScreens;
    }
    
    public class ScreenDetailWrapper{
        public String flowName;
        public String screens;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse dummyRACCallout(){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        Map<String, metadataWrapper> processedData = new Map<String, metadataWrapper>();
        try{
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.RAC_SELECTION_DETAILS;
            //reqWrapper.caseNumber = 100059260;
            reqWrapper.caseNumber = 100059260;
            reqWrapper.mode = SSP_InterfaceConstants.SSP_MODE_RAC;
            reqWrapper.applicationID = 'a0Xr00000010pwxEAA';
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> resObj = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);             
            //String sss = JSON.serialize(resObj);
            String sss = '[{"viewName":"RACSelectionDetails","transactionStatus":null,"screenNames":null,"racSelectionWrapper":{"SSPMember":[{"IndividualId":"999034247","FullName":"SFTESTUSER ALLSCENLFH","BirthDate":"1984-12-09T00:00:00","IsReceivingMedicareBenefitToggle":"Y","IsUSCitizenToggle":"N","HasEmergencyMedicalConditionToggle":"N","IsRecoveryFromIllnessOrInjuryToggle":"Y","IsDisabledToggle":"N","IsBlindToggle":"N","IsPregnantInLastThreeMonthsToggle":"N","GenderCode":"M","TemporarilyLivesElsewhereToggle":"N","InHomeCareType":"MFP","IsEnrolledInSchool":"Y"},{"IndividualId":"999034248","FullName":"SDONELDKJ ISECODLKFJK","BirthDate":"1987-01-17T00:00:00","IsReceivingMedicareBenefitToggle":"N","IsUSCitizenToggle":"N","HasEmergencyMedicalConditionToggle":"Y","IsRecoveryFromIllnessOrInjuryToggle":"Y","IsDisabledToggle":"N","IsBlindToggle":"N","IsPregnantInLastThreeMonthsToggle":"N","GenderCode":"M","TemporarilyLivesElsewhereToggle":"N","InHomeCareType":"Y","IsEnrolledInSchool":"Y"},{"IndividualId":"999034249","FullName":"TLIYDFKJ LKDHFNVGTR","BirthDate":"1987-12-02T00:00:00","IsReceivingMedicareBenefitToggle":"N","IsUSCitizenToggle":"Y","HasEmergencyMedicalConditionToggle":"N","IsRecoveryFromIllnessOrInjuryToggle":"N","IsDisabledToggle":"N","IsBlindToggle":"N","IsPregnantInLastThreeMonthsToggle":"Y","GenderCode":"F","TemporarilyLivesElsewhereToggle":"Y","InHomeCareType":"N","IsEnrolledInSchool":"N"},{"IndividualId":"999034250","FullName":"CHILDLKDFJ LKDFK","BirthDate":"2019-01-10T00:00:00","IsReceivingMedicareBenefitToggle":"N","IsUSCitizenToggle":"N","HasEmergencyMedicalConditionToggle":"N","IsRecoveryFromIllnessOrInjuryToggle":"Y","IsDisabledToggle":"N","IsBlindToggle":"N","IsPregnantInLastThreeMonthsToggle":"N","GenderCode":"F","TemporarilyLivesElsewhereToggle":"N","InHomeCareType":"N","IsEnrolledInSchool":"Y"}],"Income":[{"TotalGrossAmount":"844.00","IndividualId":"999034247","IncomeTypeCode":"EA","IncomePayFrequency":"MO","IncomePayDetailHoursPerWeek":"40","FullName":"SFTESTUSER ALLSCENLFH","EmployerName":"delook","BusinessTypeCode":null},{"TotalGrossAmount":"44.00","IndividualId":"999034249","IncomeTypeCode":"SE","IncomePayFrequency":"MO","IncomePayDetailHoursPerWeek":null,"FullName":"TLIYDFKJ LKDHFNVGTR","EmployerName":null,"BusinessTypeCode":"RE"},{"TotalGrossAmount":"44.00","IndividualId":"999034248","IncomeTypeCode":"SE","IncomePayFrequency":"MO","IncomePayDetailHoursPerWeek":null,"FullName":"SDONELDKJ ISECODLKFJK","EmployerName":null,"BusinessTypeCode":"SF"},{"TotalGrossAmount":"55.00","IndividualId":"999034247","IncomeTypeCode":"DIR","IncomePayFrequency":"QU","IncomePayDetailHoursPerWeek":null,"FullName":"SFTESTUSER ALLSCENLFH","EmployerName":null,"BusinessTypeCode":null}],"Healthcare":[{"TypeOfCoverageCode":"EM","PolicyHolderName":"EXTERNL PHOLDER","PolicyHolderId":null,"PlanName":"extIPNdlfjk","InsurancePolicyNumber":"EPIDi4tt          ","InsuranceCompanyName":"HIP"},{"TypeOfCoverageCode":"CO","PolicyHolderName":"SFTESTUSER ALLSCENLFH","PolicyHolderId":"999034247","PlanName":"IPN jeevan","InsurancePolicyNumber":"PID23535          ","InsuranceCompanyName":"INS COMPANY"}]},"primaryApplicationIndividualId":null,"payload":null,"MyInformation":null,"mode":"RAC","miscelleanousParameters":null,"medicaidMCOInformation":null,"KHIPPPaymentSummaryPayload":null,"individualIds":"","errorMessage":null,"errorCode":null,"EligibilitySummaryPayload":null,"dashboardInformation":null,"dashboardCaseInfo":null,"caseNumber":100059260,"benefitInformations":null,"applicationID":"a0Xr00000010pwx"}]';
            RACCalloutDataWrapper wrapResult = parseRACSelectionServiceResponse(sss);
            Map<String, metadataWrapper> racConfigsMap = getRACConfigMetadata();           
            processedData = RACOptionRenderHelper(racConfigsMap, wrapResult, '123', '999034247');
            toSend.bIsSuccess = true;
            toSend.put('processedData', processedData);
            toSend.put('processedDataList', processedData.values());
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ReportChangeSelectionCtrl', 'renderRACOptionsConditionally', ex.getMessage() , true);
        }
        return toSend;
    } 
    
    private static Map<String, String> constructConditionMap(User u){
        Map<String, String> condnMap = new Map<String, String>{'limit'=>'1'};                                                                 
        if(u.Profile.Name.equalsIgnoreCase(SSP_GlobalConstants.SSP_Non_Citizen_Profile)){
            condnMap.put('IndividualId__c',SSP_Utility.getIndividualId());
        } 
        else{
            condnMap.put('Id', u.ContactId);
        }
        return condnMap;
    }
    
    private static Boolean validateEducationScreenUsers(String programs,Double age){
        Boolean bShouldAddMember = false;
        if((programs.contains(SSP_GlobalConstants.MEDICAID) && age >= 18) || (programs.contains(SSP_GlobalConstants.SNAP) && age >= 15 && age <=49) || programs.contains(SSP_GlobalConstants.KTAP) || programs.contains(SSP_GlobalConstants.CHILDCARE)){
            bShouldAddMember = true;
        }
        return bShouldAddMember;
    }
}