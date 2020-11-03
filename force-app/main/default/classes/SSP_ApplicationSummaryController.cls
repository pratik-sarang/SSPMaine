/***************************************************************************************************
*   Type        :   Controller Class
*   Name        :   SSP_ApplicationSummaryController
*   Create By   :   Ajay Saini
*   Create Date :   JAN-06-2020
*   Description :   This class provides methods for application summary screen.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini              JAN-06-2020          Initial Version
*    Shikha Khanuja          JULY-01-2020         Natural Ageing calculation
*****************************************************************************************************/
public with sharing class SSP_ApplicationSummaryController {
    
    public static QueuingWrapper queueObjectValue;
    public static Map<String,Map<String,String>> initialNavFlowStatuses;
    public static Set<String> memberId65Set;
    
    /***************************************************************************************************
* @author       Ajay Saini
* @date         MAR-13-2020
* @methodname   getNavFlowStatus
* @description  Fetches all required detail for summary page.
* @return       Map of nav flow status records grouped by flowNames.
*****************************************************************************************************/
    @TestVisible
    private static Map<String, Object> getNavFlowStatus(Id applicationId) {
        Set<String> flowStatusFields = new Set<String>{'FlowPageStatus__c', 'Member__c', 'NavFlowName__c', 'Screen_Status__c', 'IsStart__c', 'IsContinue__c', 'IsEdit__c', 'IsNotRequired__c'};
            Map<String, Map<String, NavFlowStatus__c>> memberFlowStatusMap = new Map<String, Map<String, NavFlowStatus__c>>();
            Map<String, Object> statusMap = new Map<String, Object>();
        Map<String, List<NavFlowStatus__c>> flowStatusMap = new Map<String, List<NavFlowStatus__c>>();
        if(!Schema.sObjectType.NavFlowStatus__c.isAccessible()){ 
            return statusMap;
        }
        List<NavFlowStatus__c> flowStatus = [SELECT Id, FlowPageStatus__c, Member__c, NavFlowName__c, Screen_Status__c, IsStart__c, IsContinue__c, IsEdit__c, IsNotRequired__c
                                             FROM NavFlowStatus__c WHERE SSPApplication__c =:applicationId];
        //SSP_NavFlowStatusSelector.queryFlowStatusByApplicationId(applicationId, flowStatusFields);
        for(NavFlowStatus__c status: flowStatus) {
            if(status.Member__c != null) {
                if(!memberFlowStatusMap.containsKey(status.Member__c)) {
                    if(status.NavFlowName__c != null) {
                        memberFlowStatusMap.put(status.Member__c,
                                                new Map<String, NavFlowStatus__c>{status.NavFlowName__c => status});
                    }
                }
                else {
                    if(status.NavFlowName__c != null) {
                        memberFlowStatusMap
                            .get(status.Member__c)
                            .put(status.NavFlowName__c, status);
                    }
                }
            }
            if(status.NavFlowName__c != null) {
                if(!flowStatusMap.containsKey(status.NavFlowName__c)) {
                    flowStatusMap.put(status.NavFlowName__c, new List<NavFlowStatus__c>{status});
                }
                else {
                    flowStatusMap.get(status.NavFlowName__c).add(status);
                }
            }
        }        
        statusMap.putAll(flowStatusMap);
        statusMap.putAll(memberFlowStatusMap);
        return statusMap;
    }
    
    /***************************************************************************************************
* @author       Ajay Saini
* @date         MAR-13-2020
* @methodname   getChangeSummaryConfig2
* @description  Fetches metadata for change summary page.
* @return       List of metadata wrapped in wrapper.
*****************************************************************************************************/

    @TestVisible
    private static List<AppSummaryItemWrapper> getChangeSummaryConfig2(SSP_Application__c application, Map<String, SSP_Member__c> membersMap, Map<String, Object> flowStatusMap) {
        List<AppSummaryItemWrapper> configItems = new List<AppSummaryItemWrapper>();
        Map<String, List<String>> selectedMembersForRAC = new Map<String, List<String>>();
        List<Object> selections = (List<Object>)JSON.deserializeUntyped(application.RAC_Selections__c);
        // selectedMembersForRAC.put('SignAndSubmit', new List<String>());
        Set<String> allSelectedMembers = new Set<String>();
        for(Object selectionObject: selections) {
            Map<String, Object> selection = (Map<String, Object>)selectionObject;
            String memberId;
            if(selection.get('memberId') != null) {
                memberId = (String)selection.get('memberId');
                allSelectedMembers.add(memberId);
            }
            if(!selection.containsKey('selectedScreens')) {
                continue;
            }
            // selectedMembersForRAC.get('SignAndSubmit').add(memberId);
            List<Object> selectedScreens = (List<Object>)selection.get('selectedScreens');
            for(Object selectedScreenObject: selectedScreens) {
                Map<String, Object> selectedScreen = (Map<String, Object>)selectedScreenObject;
                if(selectedScreen.containsKey('flowName')) {
                    String flowName = (String)selectedScreen.get('flowName');
                    if(!selectedMembersForRAC.containsKey(flowName)) {
                        selectedMembersForRAC.put(flowName, new List<String>());
                    }
                    selectedMembersForRAC.get(flowName).add(memberId);
                }
                else if(selectedScreen.containsKey('screens')) {
                    List<String> screens = ((String)selectedScreen.get('screens')).split(',');
                    for(String screen : screens) {
                        if(!selectedMembersForRAC.containsKey(screen)) {
                            selectedMembersForRAC.put(screen, new List<String>());
                        }
                        selectedMembersForRAC.get(screen).add(memberId);
                    }
                }
            }
        }
        List<App_Summary_Config__mdt> rawAppConfiguration = [SELECT DeveloperName, Section_Key__c, Applicable_Program_Code__c, IsFlow__c, Based_On_Individual__c, Member_Filter__c, FlowName__c, PageName__c, Section__c, Subsection__c, Order__c FROM App_Summary_Config__mdt ORDER BY Order__c LIMIT 5000];
        if(rawAppConfiguration.isEmpty()) {
            return configItems;
        }
        Set<String> reviewRequiredSections = new Set<String>();
        if(application.SectionStatus__c != null) {
            Map<String, Object> completeSectionStatusMap = (Map<String, Object>)JSON.deserializeUntyped(application.SectionStatus__c);
            String summaryMode = application.ChangeSummaryMode__c;
            if(completeSectionStatusMap.containsKey(summaryMode)) {
                Map<String, Object> statusMap = (Map<String, Object>)completeSectionStatusMap.get(summaryMode);
                for(String section: statusMap.keySet()) {
                    if(statusMap.containsKey(section)) {
                        reviewRequiredSections.add(section);
                    }
                }
            }
        }
        for(App_Summary_Config__mdt config: rawAppConfiguration) {
            if(selectedMembersForRAC.containsKey(config.FlowName__c) || flowStatusMap.containsKey(config.FlowName__c) || !selectedMembersForRAC.containsKey('HealthcareCoverage') && config.Section_Key__c == 'Member_Details') {
                AppSummaryItemWrapper wrapper = new AppSummaryItemWrapper(config);
                if(wrapper.memberLevel) {
                    String key = wrapper.flowName;
                    if(key == null) {
                        key = wrapper.screenName;
                    }
                    if(selectedMembersForRAC.get(key) != null) {
                        for(String member: selectedMembersForRAC.get(key)) {
                            if(membersMap.get(member) != null) {
                                wrapper.members.add(membersMap.get(member).Id);
                            }
                        }
                    }
                    if (flowStatusMap.get(config.FlowName__c) != null) {
                        List<NavFlowStatus__c> statusRecords = (List<NavFlowStatus__c>)flowStatusMap.get(config.FlowName__c);
                        for(NavFlowStatus__c record: statusRecords) {
                            if(record.Member__c != null) {
                                wrapper.members.add(record.Member__c);
                            }
                        }
                    }
                    if(wrapper.members.isEmpty()) {
                        for(String member: allSelectedMembers) {
                            if(membersMap.get(member) != null) {
                                wrapper.members.add(membersMap.get(member).Id);
                            }
                        }
                    }
                }
                configItems.add(wrapper);
            }
            if(config.IsFlow__c == false && reviewRequiredSections.contains(config.FlowName__c)) {
                AppSummaryItemWrapper wrapper = new AppSummaryItemWrapper(config);
                configItems.add(wrapper);
            }
        }
        return configItems;
    }
    
    /***************************************************************************************************
* @author       Ajay Saini
* @date         MAR-13-2020
* @methodname   getApplicationSummaryConfig
* @description  Fetches metadata for app summary page.
* @return       List of metadata wrapped in wrapper.
*****************************************************************************************************/
    @TestVisible
    private static List<AppSummaryItemWrapper> getApplicationSummaryConfig(Set<Id> members) {
        List<AppSummaryItemWrapper> configItems = new List<AppSummaryItemWrapper>();
        List<App_Summary_Config__mdt> rawAppConfiguration = [SELECT DeveloperName, Section_Key__c, Applicable_Program_Code__c, IsFlow__c, Based_On_Individual__c, Member_Filter__c, FlowName__c, PageName__c, Section__c, Subsection__c, Order__c FROM App_Summary_Config__mdt ORDER BY Order__c limit 1000];
        if(rawAppConfiguration.isEmpty()) {
            return configItems;
        }
        for(App_Summary_Config__mdt config: rawAppConfiguration) {
            AppSummaryItemWrapper wrapper = new AppSummaryItemWrapper(config);
            if(wrapper.memberLevel) {
                wrapper.members.addAll(members);
            }
            configItems.add(wrapper);
        }
        return configItems;
    }
    
    /***************************************************************************************************
* @author       Ajay Saini
* @date         MAR-18-2020
* @methodname   getRemoveMemberSummaryConfig
* @description  Fetches metadata for app summary page for remove member flow.
* @return       List of metadata wrapped in wrapper.
*****************************************************************************************************/
    @TestVisible
    private static List<AppSummaryItemWrapper> getRemoveMemberSummaryConfig(Map<String, Object> flowStatusMap) {
        Set<String> sections = new Set<String>{'SSP_APP_HHMembersSummary', 'SignAndSubmit'};
            sections.addAll(flowStatusMap.keySet());
        List<AppSummaryItemWrapper> configItems = new List<AppSummaryItemWrapper>();
        List<App_Summary_Config__mdt> rawAppConfiguration = [SELECT DeveloperName, Section_Key__c, Applicable_Program_Code__c, IsFlow__c, Based_On_Individual__c, Member_Filter__c, FlowName__c, PageName__c, Section__c, Subsection__c, Order__c FROM App_Summary_Config__mdt WHERE FlowName__c IN :sections ORDER BY Order__c limit 5000];
        if(rawAppConfiguration.isEmpty()) {
            return configItems;
        }
        for(App_Summary_Config__mdt config: rawAppConfiguration) {
            AppSummaryItemWrapper wrapper = new AppSummaryItemWrapper(config);
            if (wrapper.memberLevel == true && flowStatusMap.get(config.FlowName__c) != null) {
                List<NavFlowStatus__c> statusRecords = (List<NavFlowStatus__c>)flowStatusMap.get(config.FlowName__c);
                for(NavFlowStatus__c record: statusRecords) {
                    if(record.Member__c != null) {
                        wrapper.members.add(record.Member__c);
                    }
                }
            }
            configItems.add(wrapper);
        }
        return configItems;
    }
    
    /***************************************************************************************************
* @author       Ajay Saini
* @date         JAN-06-2020 
* @methodname   

* @description  Fetches all required detail for summary page.
* @return       Multiple items wrapped in LightningResponse.
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getApplicationSummaryDetail(Id applicationId, String mode) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        Id APPRECORDTYPE = Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName().get(SSP_FrameworkConstants.APPRECORDTYPENAME).getRecordTypeId();
        //SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.APPOBJECTNAME, SSP_GlobalConstants.APPRECORDTYPENAME);
        Id CASERECORDTYPE = Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName().get(SSP_FrameworkConstants.CASERECORDTYPENAME).getRecordTypeId();
        //SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.APPOBJECTNAME, SSP_GlobalConstants.CASERECORDTYPENAME);
        try {
            SSP_Utility.isAuthenticatedUser();
            List<String> applicationFields = new List<String>{'Name', 'ProgramsApplied__c', 'SectionStatus__c', 'RAC_Selections__c', 'IsTMember__c', 'DCCaseNumber__c', 'ChangeSummaryMode__c'};
            List<String> memberFields = new List<String>{'FirstName__c', 'LastName__c', 'SuffixCode__c', 'MiddleInitial__c', 'Contact__r.IndividualId__c', 'Contact__r.Is_Eligible_For_RSSPDC__c'};
            for(Integer i = 0; i < memberFields.size(); ++i) {
                memberFields[i] = 'SSP_Member__r.' + memberFields[i];
            }
            for(Integer i = 0; i < applicationFields.size(); ++i) {
                applicationFields[i] = 'SSP_Application__r.' + applicationFields[i];
            }
            Set<String> fieldSet = new Set<String>();
            fieldSet.addAll(memberFields);
            fieldSet.addAll(applicationFields);
            SSP_Application__c application;
            List<SSP_Member__c> members = new List<SSP_Member__c>();
            Map<Id, SSP_ApplicationIndividual__c> membersMapById = new Map<Id, SSP_ApplicationIndividual__c>();
            Map<String, SSP_Member__c> membersMapByIndividualId = new Map<String, SSP_Member__c>();
            
            // List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, fieldSet);
            // Driver Navigation - fields added - SSP_Application__r.Application_Changed_By__c, SSP_Application__r.Application_Change_Start_Timestamp__c
            /*List<SSP_ApplicationIndividual__c> applicationIndividuals = [SELECT Id, MemberStatus__c, IsTMember__c, IsHeadOfHousehold__c, MedicaidType__c, 
                                                                         ProgramsApplied__c, SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c, 
                                                                         SSP_Member__r.IndividualId__c, SSP_Member__r.Name, SSP_Member__r.FirstName__c, SSP_Member__r.LastName__c, toLabel(SSP_Member__r.SuffixCode__c), 
                                                                         SSP_Member__r.MiddleInitial__c, SSP_Application__r.Name, SSP_Application__r.RecordType.Name,  SSP_Application__r.ProgramsApplied__c, 
                                                                         SSP_Application__r.SectionStatus__c ,SSP_Application__r.RAC_Selections__c, SSP_Application__r.DCCaseNumber__c, SSP_Application__r.ChangeSummaryMode__c,
                                                                         SSP_Member__c, SSP_Application__r.Application_Changed_By__c, SSP_Application__r.Application_Change_Start_Timestamp__c
                                                                         FROM SSP_ApplicationIndividual__c 
                                                                         WHERE SSP_Application__c = :applicationId 
                                                                         AND MemberStatus__c != 'Removed' 
                                                                         ORDER BY IsHeadOfHousehold__c DESC, CreatedDate LIMIT 1000];*/
            queueObjectValue = SSP_ApplicationSummaryController.passQueuingObject(applicationId);
            List<SSP_ApplicationIndividual__c> applicationIndividuals = queueObjectValue.applicationIndividualList != null ? queueObjectValue.applicationIndividualList : new List<SSP_ApplicationIndividual__c>();
            Boolean isEligibleRSSPDC = false;
            String contactId;
            Integer newMembers = 0;
            List<String> ageChangeRevRules = new List<String>();
            //Shikha
            SSP_ApplicationIndividual__c HOHAppIndividual = new SSP_ApplicationIndividual__c();
            for(SSP_ApplicationIndividual__c individual: applicationIndividuals) {
                if(individual.IsHeadOfHousehold__c){
                    HOHAppIndividual = individual;
                }
                SSP_Member__c member = (SSP_Member__c)individual.getSObject(SSP_ApplicationIndividual__c.SSP_Member__c.getDescribe().getSObjectField());
                application = (SSP_Application__c)individual.getSObject(SSP_ApplicationIndividual__c.SSP_Application__c.getDescribe().getSObjectField());
                if(String.isNotBlank(member.FirstName__c)) {
                    member.Name = member.FirstName__c;
                }
                if(String.isNotBlank(member.LastName__c)) {
                    member.Name += ' ' + member.LastName__c;
                }
                if(application.LastSummaryLoadDate__c != null && application.LastSummaryLoadDate__c != SSP_Utility.today() && member != null ) {                    
                    Integer oldAge = getAge(member.BirthDate__c, application.LastSummaryLoadDate__c);                    
                    Integer newAge = Integer.valueOf(member.Age__c);                    
                    ageChangeRevRules.addAll(getApplicableAgeChangeRule(oldAge, newAge, member, application));
                }
                membersMapById.put(member.Id, individual);
                membersMapByIndividualId.put(member.IndividualId__c, member);
                if(individual.MemberStatus__c == 'New') {
                    newMembers++;
                }
                if(individual.IsHeadOfHousehold__c) {
                    response.put('caseUpdated', individual.SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c);
                }
            }
            isEligibleRSSPDC = (HOHAppIndividual != null && HOHAppIndividual.SSP_Member__r != null && HOHAppIndividual.SSP_Member__r.Contact__r != null)?
                				HOHAppIndividual.SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c : false;
            contactId = HOHAppIndividual.SSP_Member__r.Contact__c;
            if(memberId65Set != null && !memberId65Set.isEmpty()){
                SSP_MemberService.checkMembersAgeBlindDisabledInfo(application.Id,null);
            }
            if(application == null) {
                response.put('applicationReady', false);
                response.bIsSuccess = true;
                return response;
            }
            response.put('applicationReady', true);
            Date todayDate = SSP_Utility.today();            
            Integer iCurrentYear = todayDate.year();            
            List<SSPTaxFilingConfigurations__c> lstTaxFilingConfigurations = [SELECT Id,Enrollment_StartDate__c, Enrollment_EndDate__c, CurrentYear__c 
                                                           FROM SSPTaxFilingConfigurations__c WHERE CurrentYear__c = :String.valueOf(iCurrentYear)];            
            if((!lstTaxFilingConfigurations.isEmpty() && 
               SSP_TaxFilingDetailsController.isCurrentDateWithinEnrollmentDates(todayDate, lstTaxFilingConfigurations[0].Enrollment_StartDate__c, lstTaxFilingConfigurations[0].Enrollment_EndDate__c))
              && (application.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID) ||
                  application.ProgramsApplied__c.contains(SSP_GlobalConstants.STATE))){
                 SSP_RulesEngine.getRRTriggerRules(application.Id, null, new List<String> {'SSP_ApplicationSummary'}, 
                                              new List<String>() , mode);
            }
            if(!ageChangeRevRules.isEmpty() && mode != 'RAC') {                
                List<String> selectedScreenList = new List<String>();
                selectedScreenList.add('SSP_APP_HHMemberDetails');
                selectedScreenList.add('SSP_APP_Select_Health');
                SSP_RulesEngine.getRRTriggerRules(application.Id, null, selectedScreenList, 
                                ageChangeRevRules, mode);
            }
            Map<String, Object> flowStatusMap = getNavFlowStatus(application.Id);
            if(mode == 'RAC') {
                if(application.ChangeSummaryMode__c == 'AddRemoveMember' && newMembers > 0) {
                    response.put('appSummaryConfig', getApplicationSummaryConfig(membersMapById.keySet()));
                }
                else if (application.ChangeSummaryMode__c == 'AddRemoveMember' || application.ChangeSummaryMode__c == null) {
                    response.put('appSummaryConfig', getRemoveMemberSummaryConfig(flowStatusMap));
                }
                else {
                    response.put('appSummaryConfig', getChangeSummaryConfig2(application, membersMapByIndividualId, flowStatusMap));
                }
            }
            else {
                response.put('appSummaryConfig', getApplicationSummaryConfig(membersMapById.keySet()));
            }
            //replaceLabelsWithalues(response.mapResponse.get('appSummaryConfig')); //Bug 378743: Performance Fix
            
            Map<String, Object> mergedMap = new Map<String, Object>();
            if(application.SectionStatus__c != null) {
                Map<String, Object> sectionStatusMap = (Map<String, Object>)JSON.deserializeUntyped(application.SectionStatus__c);
                String changeMode = application.RecordTypeId == CASERECORDTYPE? 'Renewal' : 'Intake';
                if(application.ChangeSummaryMode__c != null) {
                    changeMode = application.ChangeSummaryMode__c;
                }
                if(sectionStatusMap.containsKey(changeMode)) {
                    mergedMap = (Map<String, Object>)sectionStatusMap.get(changeMode);
                }
            }
            //Driver Navigation flag updates
            //if(mode == 'Intake' && application!=null && application.Id != null){
            if(application!=null && application.Id != null){
                application.IsApplicationSubmittedEarly__c = 'N';
                if(application.Application_Changed_By__c != UserInfo.getUserName())
                    application.Application_Changed_By__c = UserInfo.getUserName();
                application.Application_Change_Start_Timestamp__c = Datetime.now();
                application.LastSummaryLoadDate__c = todayDate;
                List<String> lstFields = new List<String>{'Application_Changed_By__c','Application_Change_Start_Timestamp__c','IsApplicationSubmittedEarly__c','LastSummaryLoadDate__c'};
                //ESAPI.accessController().updateAsUser(application, lstFields);
                SSP_GenericDMLHelper.updateRecords(new List<SSP_Application__c>{application},lstFields);//Added as part of Perf fix - Keshav
            }            
            mergedMap.putAll(flowStatusMap);
            String effectiveMode = mode;
            if(application.ChangeSummaryMode__c == 'AddRemoveMember') {
                effectiveMode = 'AddRemoveMember';
            }
            response.put('flowStatusMap', mergedMap);
            response.put('members', membersMapById.values());
            response.put('application', application);
            response.put('initNavFlowStatus', passMapNavFlowStatus(application.Id, effectiveMode));
            response.put('debugSelectedScreenMap', getSelectedScreensMap(application));
            response.put('selectedScreensMap', getSelectedScreensMap(application));
            response.put('queriesLeft', Limits.getLimitQueries() - Limits.getQueries());
            /** #379955 fix*/
            response.put('readOnlyUser',SSP_Utility.isReadOnlyUser());
            //response.put('taxFilingRR',SSP_ApplicationSummaryController.setTaxFilingRRequired(application.Id));
            //Shikha: resetRSSPDC
            SSP_DashboardService.updateApplicationPrograms(applicationId, HOHAppIndividual, mode); //2.5 Security Role Matrix and Program Access //#385177 Added mode param
            String screenPermission = SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.EARLY_SUBMISSION_SCREENID, null).screenPermission;
            response.put(SSP_GlobalConstants.EARLY_SUBMISSION, String.isNotBlank(screenPermission) ? screenPermission : SSP_GlobalConstants.EDITABLE  );
            response.put('isEligibleRSSPDC',isEligibleRSSPDC);
            response.put('contactId',contactId);
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicationSummaryController', 'getApplicationSummaryDetail', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
    
    public static Integer getAge(Date birthDate, Date today) {
        return birthDate.daysBetween(today);
    }

    @TestVisible
    private static Set<String> getApplicableAgeChangeRule(Integer oldAgeValue, Integer newAgeValue, SSP_Member__c member, SSP_Application__c application) {
        List<Integer> ageBoundaries = new List<Integer>{13, 17, 19, 60};
        List<Integer> ageBoundariesConditional = new List<Integer>{4, 11, 17, 65, 18};
        Set<Integer> selectionBoundaries = new Set<Integer> {13, 17, 19};
        Map<Integer, String> ruleNameMap = new Map<Integer, String>{			
            13 => 'age_change_13',
            17 => 'AgeGreaterThan17',            
            19 => 'checkAge19AndAbove',
            60 => 'AgeGreaterThan60'                      
        };
        Map<Integer, String> ruleNameConditionalMap = new Map<Integer,String>{
        	4 => 'checkAge4MonthsAndAbove',
            11 => 'checkAge11AndAbove',
            17 => 'AgeGreaterThan17USCitizen',
            65 => 'NonMagiSelection;NonMagiMember',
            18 => 'AbsentParentReviewRequired'
        };
        
        Set<String> rules = new Set<String>();
        Set<String> memberIdsMedicaidType = new Set<String>();
        Integer oldAge = Integer.valueOf(oldAgeValue/365);   
        Integer newAge = newAgeValue;        
        for(Integer boundary: ageBoundaries) {             
             if(oldAge <= boundary && boundary <= newAge && !selectionBoundaries.contains(boundary)) {                   
                 rules.add('review_age_change,true,'+member.Id);
                 rules.add(ruleNameMap.get(boundary) + ',true,' + member.Id);
             }  
             if(oldAge <= boundary && boundary <= newAge && selectionBoundaries.contains(boundary)){                
                rules.add(ruleNameMap.get(boundary) + ',true,null');
                rules.add('review_age_change,true,'+member.Id);
             }
         }        
        for(Integer condBound : ageBoundariesConditional){
            if(condBound == 4){                
                Integer oldAge1 = Math.abs(oldAgeValue/30);                    
                Integer newAge1 = getAge(member.BirthDate__c, SSP_Utility.today());                
                newAge1 = Math.abs(newAge1/30);                
                if(oldAge1 <= condBound && condBound <= newAge1) {                      
                	rules.add(ruleNameConditionalMap.get(condBound) + ',true,' + member.Id);
                    rules.add('review_age_change,true,'+member.Id);
                }
            }   
            if(condBound == 18){
            	Integer oldAge1 = Math.abs(oldAge/30);
                Integer newAge1 = getAge(member.BirthDate__c, Date.today());
                newAge1 = Math.abs(newAge/30);  
                if(oldAge1 >= condBound && newAge1 <= condBound){                   
                   rules.add(ruleNameConditionalMap.get(condBound)+',true,'+member.Id);
                   rules.add('review_age_change,true,'+member.Id);
                }
            }
            if(oldAge <= condBound && condBound <= newAge){
                rules.add('review_age_change,true,'+member.Id);
                if(condBound == 11 && member.GenderCode__c == 'F'){                    
                    rules.add(ruleNameConditionalMap.get(condBound) + ',true,null');                   
                }
                if(condBound == 17 && member.IsUSCitizenToggle__c == 'N'){                    
                    rules.add(ruleNameConditionalMap.get(condBound) + ',true,'+member.Id);                    
                }
                if(condBound == 65 ){                    
                    memberIdsMedicaidType.add(member.Id);  
                    String[] ruleName = ruleNameConditionalMap.get(condBound).split(';');
                    rules.add(ruleName[0] + ',true,null');
                    rules.add(ruleName[1] + ',true,'+member.Id);                    
                }                
            }
        }
        if(!memberIdsMedicaidType.isEmpty()){
            memberId65Set = memberIdsMedicaidType;            
        }
        
        return rules;
    }
    
    /***************************************************************************************************
* @author       Ajay Saini
* @date         MAR-23-2020 
* @methodname   getInitialNavFlowStatus
* @description  Fetches initial nav flow status.
* @return       Multiple items wrapped in LightningResponse.
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getInitialNavFlowStatus(Id applicationId, Id memberId, String flowName, String mode) {
                                                                    SSP_LightningResponse response = new SSP_LightningResponse();
                                                                    //   
                                                                    //QueuingWrapper wrapperObj = (QueuingWrapper) JSON.deserialize(queueObj, QueuingWrapper.class);
                                                                    //     
                                                                    queueObjectValue = passQueuingObject(applicationId);                                                          
                                                                    try {
                                                                        ContextData ctxData = new ContextData();
                                                                        ctxData.applicationId = applicationId;
                                                                        ctxData.memberId = memberId;
                                                                        ctxData.flowName = flowName;
                                                                        ctxData.modeValue = mode;
                                                                        ctxData.queueObject = queueObjectValue;
                                                                        
                                                                        if(mode == 'RAC') {
                                                                            List<String> fields = new List<String>{'ChangeSummaryMode__c'};
                                                                                SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, fields);
                                                                            if(application.ChangeSummaryMode__c == 'AddRemoveMember') {
                                                                                ctxData.modeValue = 'addRemoveMember';
                                                                            }
                                                                            else {
                                                                                ctxData.SelectedScreen = NavFlowController.getMemberDetails(ctxData.ApplicationId, ctxData.MemberId, ctxData.flowName, ctxData.modeValue);
                                                                            }
                                                                            response.put('statusString', NavFlowManager.initNavFlowRACStatuses(null, ctxData, null));
                                                                        }
                                                                        else {
                                                                            response.put('statusString', NavFlowManager.initNavFlowStatuses(null, ctxData));
                                                                        }
                                                                    }
                                                                    catch(Exception e) {
                                                                        List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicationSummaryController', 'getInitialNavFlowStatus', e.getMessage() , true);
                                                                        response.addException(e, lstLogMessages[0].Id);
                                                                    }
                                                                    return response;
                                                                }
    
    /***************************************************************************************************
* @author       Ajay Saini
* @date         APR-06-2020 
* @methodname   setInitialNavFlowStatuses
* @description  Set Initial nav flow status.
* @return       Multiple items wrapped in LightningResponse.
*****************************************************************************************************/
    public static List<AppSummaryItemWrapper> setInitialNavFlowStatuses(Id applicationId, String mode, List<AppSummaryItemWrapper> configItems) {
        for(AppSummaryItemWrapper item: configItems) {
            if(item.flowName == null) {
                continue;
            }
            if(item.memberLevel) {
                for(Id memberId: item.members) {
                    ContextData ctxData = new ContextData();
                    ctxData.applicationId = applicationId;
                    ctxData.memberId = memberId;
                    ctxData.flowName = item.flowName;
                    if(mode == 'RAC') {
                        item.initialStatusMap.put(memberId, NavFlowManager.initNavFlowRACStatuses(null, ctxData, null));
                    }
                    else {
                        item.initialStatusMap.put(memberId, NavFlowManager.initNavFlowStatuses(null, ctxData));
                    }
                }
            }
            else {
                ContextData ctxData = new ContextData();
                ctxData.applicationId = applicationId;
                ctxData.memberId = null;
                ctxData.flowName = item.flowName;
                if(mode == 'RAC') {
                    item.initialStatusMap.put(null,  NavFlowManager.initNavFlowRACStatuses(null, ctxData, null));
                }
                else {
                    item.initialStatusMap.put(null, NavFlowManager.initNavFlowStatuses(null, ctxData));
                }
            }
        }
        return configItems;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse fetchApplicationStatus(Id applicationId) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, new List<String>{'DCCaseNumber__c'});
            Boolean applicationReady = application != null && application.DCCaseNumber__c != null;
            response.put('applicationReady', applicationReady);
            response.put('application', application);
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicationSummaryController', 'fetchApplicationStatus', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
    
    @AuraEnabled
    public static void resetStatus(String applicationId, String flowName, String memberId, String mode, String queueObject) {        
        //queueObj
        /*
        QueuingWrapper wrapperObj = (QueuingWrapper) JSON.deserialize(queueObject, QueuingWrapper.class);
         */  
        SSP_Utility.isAuthenticatedUser();
        queueObjectValue = passQueuingObject(applicationId);
        if(applicationId != null && String.isNotEmpty(flowName)) {
            NavFlowManager.resetNavDriver(applicationId, flowName, memberId,mode,queueObjectValue);
        }
        else if(applicationId != null) {
            NavFlowManager.resetDriver(new Set<Id> {applicationId});
        }
    }
        
    @AuraEnabled
    public static SSP_LightningResponse markSectionsComplete(Id applicationId, String sections) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<String> applicationFields = new List<String>{'SectionStatus__c', 'RAC_Selections__c', 'ChangeSummaryMode__c', 'RecordType.Name'};
            try {
            SSP_Utility.isAuthenticatedUser();
                if(applicationId == null) {
                    response.bIsSuccess = false;
                    return response;
                }
                
                SSP_Application__c applicationRecord = SSP_ApplicationSelector.queryApplicationDataById(applicationId, applicationFields);
                if(applicationRecord == null) {
                    response.bIsSuccess = false;
                    return response;
                }
                if(String.isBlank(sections)) {
                    response.put('applicationRecord', applicationRecord);
                    response.bIsSuccess = false;
                    return response;
                }
                String mode = applicationRecord.RecordType.Name.contains('Case')? 'Renewal' : 'Intake';
                if(applicationRecord.ChangeSummaryMode__c != null) {
                    mode = applicationRecord.ChangeSummaryMode__c;
                }
                List<String> newlyCompletedSections = new List<String>();
                Map<String, String> sectionStatusMap = new Map<String, String>();
                Map<String, Object> finalObject = new Map<String, Object>();
                if(applicationRecord.SectionStatus__c != null) {
                    finalObject = (Map<String, Object>)JSON.deserializeUntyped(applicationRecord.SectionStatus__c);
                }
                if(finalObject.containsKey(mode)) {
                    Map<String, Object> originalStatus = (Map<String, Object>)finalObject.get(mode);
                    for(String sectionId: originalStatus.keySet()) {
                        sectionStatusMap.put(sectionId, (String)originalStatus.get(sectionId));
                    }
                }
                for(String sectionId: sections.split(';')) {
                    if(!sectionStatusMap.containsKey(sectionId)) {
                        newlyCompletedSections.add(sectionId);
                    }
                    sectionStatusMap.put(sectionId, 'COMPLETED');
                }
                finalObject.put(mode, sectionStatusMap);
                applicationRecord.SectionStatus__c = JSON.serialize(finalObject);
                //ESAPI.accessController().updateAsUser(applicationRecord, new List<String>{'SectionStatus__c'});
                /** #379955 fix*/
                if(!SSP_Utility.isReadOnlyUser()){
                    SSP_GenericDMLHelper.updateRecords(new List<SSP_Application__c>{applicationRecord}, new List<String>{'SectionStatus__c'});//Added as part of Perf fix - Keshav
                }
                response.put('applicationRecord', applicationRecord);
                response.put('newlyCompletedSections', newlyCompletedSections);
                response.bIsSuccess = true;
            }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicationSummaryController', 'markSectionsComplete', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse markSectionsReviewRequired(Id applicationId, String sections) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<String> applicationFields = new List<String>{'SectionStatus__c', 'ChangeSummaryMode__c', 'RecordType.Name'};
            try {
                if(applicationId == null) {
                    response.bIsSuccess = false;
                    return response;
                }
                SSP_Application__c applicationRecord = SSP_ApplicationSelector.queryApplicationDataById(applicationId, applicationFields);
                if(applicationRecord == null) {
                    response.bIsSuccess = false;
                    return response;
                }
                if(String.isBlank(sections)) {
                    response.put('applicationRecord', applicationRecord);
                    response.bIsSuccess = false;
                    return response;
                }
                Map<String, String> sectionStatusMap = new Map<String, String>();
                Map<String, Object> newSectionStatusMap = new Map<String, Object>();
                List<String> successfullSections = new List<String>();
                Map<String, Object> finalObject = new Map<String, Object>();
                if(applicationRecord.SectionStatus__c != null) {
                    finalObject = (Map<String, Object>)JSON.deserializeUntyped(applicationRecord.SectionStatus__c);
                }
                String mode = applicationRecord.RecordType.Name.contains('Case')? 'Renewal' : 'Intake';
                if(applicationRecord.ChangeSummaryMode__c != null) {
                    mode = applicationRecord.ChangeSummaryMode__c;
                }
                Map<String, Object> originalStatus = new Map<String, Object>();
                if(finalObject.containsKey(mode)) {
                    originalStatus = (Map<String, Object>)finalObject.get(mode);
                }
                for(String sectionId: sections.split(';')) {
                    if(originalStatus.containsKey(sectionId) && originalStatus.get(sectionId) != null) {
                        String oldStatus = (String)originalStatus.get(sectionId);
                        response.put(sectionId, oldStatus);
                        if(oldStatus == 'COMPLETED') {
                            sectionStatusMap.put(sectionId, 'REVIEW_REQUIRED');
                            successfullSections.add(sectionId);
                        }
                    }
                    else if(applicationRecord.ChangeSummaryMode__c != null) {
                        sectionStatusMap.put(sectionId, 'REVIEW_REQUIRED');
                        successfullSections.add(sectionId);
                    }
                }
                newSectionStatusMap.putAll(originalStatus);
                newSectionStatusMap.putAll(sectionStatusMap);
                finalObject.put(mode, newSectionStatusMap);
                applicationRecord.SectionStatus__c = JSON.serialize(finalObject);
                //ESAPI.accessController().updateAsUser(applicationRecord, new List<String>{'SectionStatus__c'});
                 /** #379955 fix*/
                if(!SSP_Utility.isReadOnlyUser()){
                    SSP_GenericDMLHelper.updateRecords(new List<SSP_Application__c>{applicationRecord}, new List<String>{'SectionStatus__c'});//Added as part of Perf fix - Keshav
                }
                response.put('requiredSections', successfullSections);
                response.put('applicationRecord', applicationRecord);
                response.bIsSuccess = true;
            }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicationSummaryController', 'markSectionsReviewRequired', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
     
    @AuraEnabled 
    public static SSP_LightningResponse getTransactionStatus(Id applicationId, String mode) { //Added extra parameter - mode
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            SSP_LightningResponse objResponse = new SSP_LightningResponse();  
            //PERF Fix - Added Role check
            if(applicationId != null && SSP_Utility.getSelectedRole() != SSP_FrameworkConstants.CITIZEN_ROLE){            
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(applicationId);
            if(objResponse != null && objResponse.mapResponse != null && (!( objResponse.mapResponse.containsKey('hasAccess'))) && objResponse.mapResponse.containsKey('isAuthRep')){
            response.put('hasNoAccess',true);
            response.bIsSuccess = true;
            return response;   
            }
            }
            /** 2.5 Security Role Matrix and Program Access */
            String screenID = String.isNotBlank(mode) ? (mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RENEWAL_FLOW) ? SSP_GlobalConstants.RENEWAL_SUMMARY_SCREENID : (mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RAC_FLOW) ? SSP_GlobalConstants.CHANGE_SUMMARY_SCREENID : SSP_GlobalConstants.APPLICATION_SUMMARY_SCREENID)) : SSP_GlobalConstants.APPLICATION_SUMMARY_SCREENID ;
            String screenPermission = SSP_Utility.getScreenAccessDetails(screenID, null).screenPermission;
            response.put('isNotAccessible', String.isNotBlank(screenPermission) && screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE) ? true : false);
            if(Boolean.valueOf(response.mapResponse.get('isNotAccessible'))){
                response.bIsSuccess = true;
                return response;
            }
            /** */

            String individualId = SSP_Utility.getIndividualId();
            response.put('individualId', individualId);
            if(String.isBlank(individualId)) {
                response.bIsSuccess = true;
                response.put('allSuccessFull', true);
                return response;
            }
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'Contact'};
            Map<String, String> conditionMap = new Map<String, String>{'IndividualId__c' => individualId};
            Set<String> fieldSet = new Set<String>{'DoesCaseExistForIndividual__c'};
            List<Contact> contactRecords = (List<Contact>)SSP_Utility.fetchRecords(detailMap, fieldSet, conditionMap);
            if(!contactRecords.isEmpty() && contactRecords[0].DoesCaseExistForIndividual__c == false) {
                response.bIsSuccess = true;
                response.put('allSuccessFull', true);
                return response;
            }
            Set<String> logs = new Set<String>();
            Set<String> views = getRequiredViews(applicationId);
            response.put('views', views);
            List<SSP_Transaction__c> transactions = SSP_SharingBypassFetcher.fetchTransactionRecords(individualId, views);
            if(transactions.isEmpty()) {
                response.bIsSuccess = true;
                response.put('allSuccessFull', false);
                response.put('anyFailed', false);
                return response;
            }
            Boolean allSuccessFull = true;
            Boolean anyFailed = false;
            Map<String, String> viewStatusMap = new Map<String, String>();
            for(SSP_Transaction__c txn : transactions) {
                viewStatusMap.put(txn.View_Name__c, txn.Status__c);
                if(txn.Status__c == SSP_InterfaceConstants.FAILED || txn.Status__c == SSP_InterfaceConstants.CANCELLED) {
                    logs.add(txn.Log_Message__c);
                    anyFailed = true;
                }
                if(txn.Status__c != SSP_InterfaceConstants.SUCCESS) {
                    allSuccessFull = false;
                }
            }
            response.put('txnStatuses', viewStatusMap);
            response.put('logs', logs);
            response.put('allSuccessFull', allSuccessFull);
            response.put('anyFailed', anyFailed);
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicationSummaryController', 'getTransactionStatus', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }


    @AuraEnabled
    public static void fireCallouts(Id applicationId, String mode) {
        SSP_SignaturePageCtrl.sspAHICall(applicationId, mode);
        SSP_SignaturePageCtrl.sspNonESIMECCall(applicationId);
        SSP_SignaturePageCtrl.sspVCICall(applicationId);
        SSP_SignaturePageCtrl.sspAVSCall(applicationId);
    }
    
    @TestVisible
    private static Set<String> getRequiredViews(Id applicationId) {
        Set<String> selectedScreens = new Set<String>();
        Set<String> views = new Set<String>();
        if(applicationId == null) {
            return views;
        }
        SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, new List<String>{'RAC_Selections__c'});
        if(String.isBlank(application.RAC_Selections__c)) {
            /*ReverseSSPViewMapping__mdt[] metadataRecords = [SELECT View__c, Screens__c FROM ReverseSSPViewMapping__mdt WHERE Is_Intake__c = true];
            for(ReverseSSPViewMapping__mdt record: metadataRecords) {
                views.add(record.View__c);
            }*/
            views.add(SSP_InterfaceConstants.QUALIFIED_INDIVIDUAL);
            views.add(SSP_InterfaceConstants.MEMBER_INFORMATION);
            return views;
            //return new Set<String>{SSP_InterfaceConstants.COMPLETE_VIEW_STATUS};
        }
        List<Object> selections = (List<Object>)JSON.deserializeUntyped(application.RAC_Selections__c);
        for(Object selectionObject: selections) {
            Map<String, Object> selection = (Map<String, Object>)selectionObject;
            if(!selection.containsKey('selectedScreens')) {
                continue;
            }
            for(Object selectedScreenObject: (List<Object>)selection.get('selectedScreens')) {
                Map<String, Object> selectedScreen = (Map<String, Object>)selectedScreenObject;
                if(selectedScreen.containsKey('screens')) {
                    List<String> screens = ((String)selectedScreen.get('screens')).split(',');
                    selectedScreens.addAll(screens);
                }
            }
        }
        Map<String, String> screenViewMap = SSP_Utility.getScreenViewMapping();
        for(String screen: selectedScreens) {
            if(screenViewMap.containsKey(screen)) {
                views.add(screenViewMap.get(screen));
            }
        }
        return views;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse resetRSSPDCEligibility(String mode, String contactId) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            SSP_Utility.isAuthenticatedUser();
            //List<SSP_ApplicationIndividual__c> appIndv = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(applicationId, new Set<String>{'SSP_Application__r.Account__c', 'SSP_Application__r.ProgramsApplied__c', 'SSP_Member__r.Contact__c', 'SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c','SSP_Application__r.ProgramsAppliedCopy__c','MemberProgramsAppliedCopy__c'}); //#379955 //2.5 Security Role Matrix and Program Access. Added LastModifiedById fields
            if(mode != null && mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_INTAKE_FLOW) && String.isNotBlank(contactId)){			                               
                Contact hohCon = new Contact(Id = contactId);
                hohCon.Is_Eligible_For_RSSPDC__c = false;
                //ESAPI.accessController().updateAsUser(hohCon, new List<String>{'Is_Eligible_For_RSSPDC__c'});
                SSP_GenericDMLHelper.updateRecords(new List<Contact>{hohCon},new List<String>{'Is_Eligible_For_RSSPDC__c'});//Added as part of Perf fix - Keshav                
            }	

            /*SSP_DashboardService.updateApplicationPrograms(applicationId, appIndv[0], mode); //2.5 Security Role Matrix and Program Access //#385177 Added mode param
            String screenPermission = SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.EARLY_SUBMISSION_SCREENID, null).screenPermission;
            response.put(SSP_GlobalConstants.EARLY_SUBMISSION, String.isNotBlank(screenPermission) ? screenPermission : SSP_GlobalConstants.EDITABLE  );
            response.bIsSuccess = true;	*/
        }
        catch(Exception ex){
            response.bIsSuccess = false;
            
        }
        return response;
    }
    
    /*public static boolean setTaxFilingRRequired(String applicationId){
        Boolean result = false;        
        /*List<SSP_Application__c> applicationList = [SELECT Id, ProgramsApplied__c FROM SSP_Application__c
WHERE Id = :applicationId]; */  
        //
        /*List<SSP_Application__c> applicationList = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                                new Set<String>{'Id', 'ProgramsApplied__c'}, 
                                                                                                new Map<String, String>{'limit'=>'1','Id'=> String.escapeSingleQuotes(applicationId)});
        
        Date todayDate = SSP_Utility.today();
        Date enrollmentStartDate;
        Date enrollmentEndDate;
        Integer iCurrentYear = todayDate.year();
        Map<String,Boolean> mapOpenEnrollmentDate = new Map<String,Boolean>();
        List<SSPTaxFilingConfigurations__c> lstTaxFilingConfigurations = SSPTaxFilingConfigurations__c.getall().values();
        for(SSPTaxFilingConfigurations__c taxConfig : lstTaxFilingConfigurations){
            if(String.valueOf(iCurrentYear) == taxConfig.CurrentYear__c){
                EnrollmentStartDate = taxConfig.Enrollment_StartDate__c;
                EnrollmentEndDate = taxConfig.Enrollment_EndDate__c;
                mapOpenEnrollmentDate.put('openEnrollment',SSP_TaxFilingDetailsController.isCurrentDateWithinEnrollmentDates(todayDate, EnrollmentStartDate, EnrollmentEndDate));
            }
        }
        
        
        result = (mapOpenEnrollmentDate != null && mapOpenEnrollmentDate.containsKey('openEnrollment') && 
                  mapOpenEnrollmentDate.get('openEnrollment') != null
                  && mapOpenEnrollmentDate.get('openEnrollment')) &&
            (!applicationList.isEmpty() ? 
             (applicationList[0].ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID) ||
              applicationList[0].ProgramsApplied__c.contains(SSP_GlobalConstants.STATE)):false);
        return result;
    }*/
    
    @AuraEnabled
    public static SSP_LightningResponse fireReviewRequiredOnProgramChange(Id applicationId,  List<String> newPrograms) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId, new List<String>{'ProgramsApplied__c'});
            List<String> oldPrograms = new List<String>();
            if(application.ProgramsApplied__c != null) {
                oldPrograms = application.ProgramsApplied__c.split(';');
            }
            Set<String> allPrograms = new Set<String>();
            allPrograms.addAll(oldPrograms);
            allPrograms.addAll(newPrograms);
            Map<NavFlowPageConfig__mdt, Integer> pageIndexMap = new Map<NavFlowPageConfig__mdt, Integer>();
            Map<String, List<NavFlowPageConfig__mdt>> flowPageMap = new Map<String, List<NavFlowPageConfig__mdt>>();
            // List<NavFlowPageConfig__mdt> newlyRequiredScreens = new List<NavFlowPageConfig__mdt>();
            Map<NavFlowPageConfig__mdt, List<String>> newlyRequiredScreens = new Map<NavFlowPageConfig__mdt, List<String>>();
            Set<String> flows = new Set<String>();
            Set<String> memberBasedFlows = new Set<String>();
            List<App_Summary_Config__mdt> rawAppConfiguration = [SELECT Based_On_Individual__c, FlowName__c FROM App_Summary_Config__mdt WHERE IsFlow__c = true limit 1000];
            for(App_Summary_Config__mdt config: rawAppConfiguration) {
                if(config.FlowName__c != null) {
                    flows.add(config.FlowName__c);
                }
                if(config.Based_On_Individual__c == true) {
                    memberBasedFlows.add(config.FlowName__c);
                }
            }
            List<NavFlowPageConfig__mdt> pageConfigurations = [SELECT Id, Label, Programs__c, PageInfo__r.PageName__c, NavFlowRule__c, NavigationFlowDetail__r.FlowName__c, SequenceNumber__c FROM NavFlowPageConfig__mdt WHERE IsActive__c = true AND NavigationFlowDetail__r.FlowName__c IN :flows ORDER BY NavigationFlowDetail__c, SequenceNumber__c];
            response.put('pageConfigurations', pageConfigurations);
            Set<Id> memberSet = new Set<Id>();
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, new Set<String>());
            for(SSP_ApplicationIndividual__c individual: applicationIndividuals) {
                memberSet.add(individual.SSP_Member__c);
            }
            List<Id> members = new List<Id>(memberSet);
            Set<String> oldProgramSet = new Set<String>(oldPrograms);
            Set<String> newProgramSet = new Set<String>(newPrograms);
            Map<String, Set<String>> applicableProgramsMap = new Map<String, Set<String>>();
            for (NavFlowPageConfig__mdt pageConfig: pageConfigurations) {
                if(String.isBlank(pageConfig.Programs__c) || String.isBlank(pageConfig.NavFlowRule__c)) {
                    continue;
                }
                Set<String> applicablePrograms = new Set<String>(pageConfig.Programs__c.split(';'));
                // oldProgramSet.retainAll(applicablePrograms);
                // newProgramSet.retainAll(applicablePrograms);
                applicablePrograms.removeAll(oldProgramSet);
                applicablePrograms.retainAll(newProgramSet);
                applicableProgramsMap.put(pageConfig.PageInfo__r.PageName__c, applicablePrograms);
                if(!applicablePrograms.isEmpty()) {
                    List<String> applicableMembers = new List<String>();
                    if (memberBasedFlows.contains(pageConfig.NavigationFlowDetail__r.FlowName__c)) {
                        for(Id memberId: members) {
                            ContextData ctxData = new ContextData();
                            ctxData.applicationId = applicationId;
                            ctxData.flowName = pageConfig.NavigationFlowDetail__r.FlowName__c;
                            ctxData.modeValue = 'Intake';
                            ctxData.memberId = memberId;
                            ctxData.queueObject = NavFlowManager.getQueuingFields(applicationId);
                            Boolean isRequired = NavFlowRulesEngine.getInstance().isRequired(new Context(), ctxData, pageConfig.NavFlowRule__c);
                            if(isRequired) {
                                applicableMembers.add(memberId);
                            }
                        }    
                    }
                    else {
                        ContextData ctxData = new ContextData();
                        ctxData.applicationId = applicationId;
                        ctxData.flowName = pageConfig.NavigationFlowDetail__r.FlowName__c;
                        ctxData.modeValue = 'Intake';
                        ctxData.queueObject = NavFlowManager.getQueuingFields(applicationId);
                        //for non-member flows
                        Boolean isRequired = NavFlowRulesEngine.getInstance().isRequired(new Context(), ctxData, pageConfig.NavFlowRule__c);
                        if(isRequired) {
                            applicableMembers.add('HOH');
                        }
                    }
                    if(!applicableMembers.isEmpty()) {
                        newlyRequiredScreens.put(pageConfig, applicableMembers);
                    }
                }
                if(!flowPageMap.containsKey(pageConfig.NavigationFlowDetail__r.FlowName__c)) {
                    flowPageMap.put(pageConfig.NavigationFlowDetail__r.FlowName__c, new List<NavFlowPageConfig__mdt>());
                }
                pageIndexMap.put(pageConfig, flowPageMap.get(pageConfig.NavigationFlowDetail__r.FlowName__c).size());
                flowPageMap.get(pageConfig.NavigationFlowDetail__r.FlowName__c).add(pageConfig);
            }
            response.put('applicableProgramsMap', applicableProgramsMap);
            List<NavFlowStatus__c> flowSatusRecords = [SELECT Id, NavFlowName__c, FlowPageStatus__c, FlowDupStatus__c, Member__c, IsEdit__c, Screen_Status__c FROM NavFlowStatus__c WHERE SSPApplication__c =: applicationId];
            Map<String, NavFlowStatus__c> flowStatusMap = new Map<String, NavFlowStatus__c>();
            for(NavFlowStatus__c record: flowSatusRecords) {
                String key = record.NavFlowName__c + '|' + (record.Member__c != null? String.valueOf(record.Member__c) : 'HOH');
                flowStatusMap.put(key, record);
            }
            List<String> logs = new List<String>();
            response.put('oldMap', flowStatusMap);
            response.put('newlyRequiredScreens', newlyRequiredScreens.keySet());
            for(NavFlowPageConfig__mdt pageConfig: newlyRequiredScreens.keySet()) {
                for(String member: newlyRequiredScreens.get(pageConfig)) {
                    String key = pageConfig.NavigationFlowDetail__r.FlowName__c + '|' + member;
                    NavFlowStatus__c flowStatusRecord = flowStatusMap.get(key);
                    if(flowStatusRecord == null) {
                        continue;
                    }
                    Integer index = pageIndexMap.get(pageConfig);
                    String statusString = flowStatusRecord.FlowPageStatus__c.substring(index, index + 1);
                    if(statusString == 'C' || flowStatusRecord.IsEdit__c == true && statusString == 'N') {
                        String originalStatus = flowStatusRecord.FlowDupStatus__c;
                        String newStatus = originalStatus.substring(0, index) + 'R' + originalStatus.substring(index + 1);
                        flowStatusRecord.FlowPageStatus__c = newStatus;
                        flowStatusRecord.FlowDupStatus__c = newStatus;
                        if(flowStatusRecord.Screen_Status__c != null) {
                            Map<String, Object> screenDetail = (Map<String, Object>)JSON.deserializeUntyped(flowStatusRecord.Screen_Status__c);
                            NavFlowStatJSONCLone.ReviewRequiredWrapper wrapperObject = (NavFlowStatJSONClone.ReviewRequiredWrapper)JSON.deserialize(JSON.serialize(screenDetail.get(pageConfig.PageInfo__r.PageName__c)), NavFlowStatJSONCLone.ReviewRequiredWrapper.class);
                            if(wrapperObject != null) {
                                wrapperObject.isReviewRequired = true;
                            }
                            else {
                                wrapperObject = new NavFlowStatJSONCLone.ReviewRequiredWrapper();
                                wrapperObject.isReviewRequired = true;
                            }
                            screenDetail.put(pageConfig.PageInfo__r.PageName__c, wrapperObject);
                            flowStatusRecord.Screen_Status__c = JSON.serialize(screenDetail);
                        }
                        else {
                            Map<String, Object> screenDetail = new Map<String, Object>();
                            NavFlowStatJSONCLone.ReviewRequiredWrapper wrapperObject = new NavFlowStatJSONCLone.ReviewRequiredWrapper();
                            wrapperObject.isReviewRequired = true;
                            screenDetail.put(pageConfig.PageInfo__r.PageName__c, wrapperObject);
                            flowStatusRecord.Screen_Status__c = JSON.serialize(screenDetail);
                        }
                        String log = String.format(' Screen: {0}, Member:{1} OldStatus: {2}, NewStatus: {3}, Id: {4}', new List<String>{pageConfig.Label, member, 'C', 'R', flowStatusRecord.Id});
                        logs.add(log);
                    }
                    else {
                        String log = String.format(' Screen: {0}, Member:{1} OldStatus: {2}, NewStatus: {3}, Id: {4}', new List<String>{pageConfig.Label, member, statusString, statusString, flowStatusRecord.Id});
                        logs.add(log);
                    }
                }
            }
            response.put('logs', logs);
            response.put('newMap', flowStatusMap);
            update flowStatusMap.values();
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ApplicationSummaryController', 'markSectionsComplete', ex.getMessage() , true);
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }
    
    public static QueuingWrapper passQueuingObject (String applicationId){
        if(queueObjectValue == null){
            queueObjectValue = NavFlowManager.getQueuingFields(applicationId);
        }
        return queueObjectValue;
    }
    
    public static Map<String,Map<String,String>> passMapNavFlowStatus (String appId, String mode) {
        if(initialNavFlowStatuses == null || initialNavFlowStatuses.isEmpty()){
            initialNavFlowStatuses = getCombinedNavFlowStatus (appId, mode);
        }
        return initialNavFlowStatuses;
    }

    public static Map<String, Set<String>> getSelectedScreensMap(SSP_Application__c application) {
        Map<String, Set<String>> responseMap = new Map<String, Set<String>>();
        if(application.RAC_Selections__c == null) {
            return responseMap;
        }
        List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper> RACWrapperList = (List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper>)
        JSON.deserialize(application.RAC_Selections__c, List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper>.class);
        for(SSP_ReportChangeSelectionCtrl.RACSelectionWrapper wrap : RACWrapperList) {
            for(SSP_ReportChangeSelectionCtrl.ScreenDetailWrapper screenWrap: wrap.selectedScreens) {
                String key = 'HOH';
                if(wrap.memberId != null && screenWrap.flowName != 'HouseholdInformation') {
                    key = wrap.memberId;
                }
                if(!responseMap.containsKey(key)) {
                    responseMap.put(key, new Set<String>());
                }
                responseMap.get(key).addAll(screenWrap.screens.split(','));
            }
        }
        return responseMap;
    }

    /**2.5 Security Role Matrix and Program Access */
    @TestVisible
    /*private static Map<String, Boolean> getScreenPermissions(String selectedRole){
        Map<String, Boolean> pageNameToAccessMap = new Map<String, Boolean>();
        if(UserInfo.getSessionId() != null){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            selectedRole = (selectedRole != null) ? selectedRole : SSP_Utility.getSelectedRole();
            if(String.isNotBlank(selectedRole)){
                for(ScreenPermissions__mdt screenPermission :  (List<ScreenPermissions__mdt>)SSP_Utility.fetchRecords(
                    new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_SCREEN_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},
                    SSP_GlobalConstants.MDT_SCREEN_PERMISSIONS_FIELDS, 
                    new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1000','Role__c'=>selectedRole})){
                        Boolean isAccessible = !(screenPermission != null && screenPermission.Permission__c != null && screenPermission.Permission__c.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE));
                        pageNameToAccessMap.put(screenPermission.ScreenName__c, isAccessible);
                    }
            }
        }
        return pageNameToAccessMap;
    }*/
    /**2.5 Security Role Matrix and Program Access */
    public static Map<String, SSP_Utility.SecurityMatrixWrapper> getScreenPermissions(String selectedRole){
        //Map<String, Boolean> pageNameToAccessMap = new Map<String, Boolean>();
        Map<String, SSP_Utility.SecurityMatrixWrapper> securityMatrixMap = new Map<String, SSP_Utility.SecurityMatrixWrapper>();        
            PermissionsOrgCache permissionObj =new PermissionsOrgCache();
            selectedRole = (selectedRole != null) ? selectedRole : SSP_Utility.getSelectedRole();
            securityMatrixMap = (Map<String, SSP_Utility.SecurityMatrixWrapper>) permissionObj.getScreenPermissions(selectedRole);            
        return securityMatrixMap;
    }
    

    public static Map<String,Map<String,String>> getCombinedNavFlowStatus (String appId, String mode){
        Map<String, Map<String,String>> memberFlowStatusMap = new Map<String,Map<String,String>>();
        Set<String> flowNameSet = new Set<String>();
        Set<String> memberBasedFlows = new Set<String>();
        List<App_Summary_Config__mdt> rawAppConfiguration = [SELECT DeveloperName, Section_Key__c, Applicable_Program_Code__c, IsFlow__c, Based_On_Individual__c, Member_Filter__c, FlowName__c, PageName__c, Section__c, Subsection__c, Order__c FROM App_Summary_Config__mdt ORDER BY Order__c limit 1000];
        for(App_Summary_Config__mdt appConfig : rawAppConfiguration){
            flowNameSet.add(appConfig.FlowName__c);           
            if(appConfig.Based_On_Individual__c == true) {
                memberBasedFlows.add(appConfig.FlowName__c);
            } 
        }
        List<NavFlowPageConfig__mdt> pageConfigList = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__c,NavigationFlowDetail__r.Flowname__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                                                       PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c, NavFlowRule__r.RuleApexClassName__c
                                                       FROM NavFlowPageConfig__mdt
                                                       WHERE NavigationFlowDetail__r.Flowname__c IN : flowNameSet AND IsActive__c = TRUE ORDER By SequenceNumber__c ];
                    
        queueObjectValue = passQueuingObject(appId);
        SSP_Application__c applicationRecord = queueObjectValue.applicationIndividualList[0].SSP_Application__r;
        Map<String, Set<String>> selectedScreensMap = getSelectedScreensMap(applicationRecord);
        Boolean newMemberExist = false;
        //Map<String, Boolean> screenPermissions = getScreenPermissions(null);
        //PERF Fix - Changed definition of Screen Permission
        Map<String, SSP_Utility.SecurityMatrixWrapper> securityMap = getScreenPermissions(null);
        for(SSP_ApplicationIndividual__c queue : queueObjectValue.applicationIndividualList){
            for(NavFlowPageConfig__mdt pageConfig: pageConfigList) {
                //Boolean isAccessible = (screenPermissions != null && !screenPermissions.isEmpty() && screenPermissions.containsKey(pageConfig.PageInfo__r.PageName__c))  ? screenPermissions.get(pageConfig.PageInfo__r.PageName__c) : true; //2.5 Security Role Matrix and Program Access
                //PERF Fix - Changed definition of Screen Permission     
                Boolean isAccessible = securityMap != null && !securityMap.isEmpty() && securityMap.containsKey(pageConfig.PageInfo__r.PageName__c) && 
                    securityMap.get(pageConfig.PageInfo__r.PageName__c).screenPermission != null ?
                    !securityMap.get(pageConfig.PageInfo__r.PageName__c).screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE) : true;           
                
                if(!memberBasedFlows.contains(pageConfig.NavigationFlowDetail__r.Flowname__c)) {
                    continue;
                }
                Map<String,String> pageNameStatusMap = new Map<String,String>();
                newMemberExist = newMemberExist || queue.MemberStatus__c == 'New';
                Boolean result = mode != 'RAC' || queue.MemberStatus__c == 'New' && applicationRecord.ChangeSummaryMode__c == 'AddRemoveMember';
                if((mode != 'RAC' || queue.MemberStatus__c == 'New' && applicationRecord.ChangeSummaryMode__c == 'AddRemoveMember') && pageConfig.NavFlowRule__r.RuleApexClassName__c != null){
                    Type typ = Type.forName(pageConfig.NavFlowRule__r.RuleApexClassName__c);
                    BasicNavFlowRule nfr = (BasicNavFlowRule)typ.newInstance();
                    Context contextVal = new Context();
                    ContextData data = new ContextData();
                    data.MemberId = queue.SSP_Member__c;
                    data.ApplicationId = queue.SSP_Application__c;
                    data.queueObject = queueObjectValue;
                        data.modeValue = mode;
                    result = isAccessible && nfr.isRequired(contextVal, data); //2.5 Security Role Matrix and Program Access.
                }
                else if(selectedScreensMap.containsKey(queue.SSP_Member__r.IndividualId__c)) {
                    result = isAccessible && selectedScreensMap.get(queue.SSP_Member__r.IndividualId__c).contains(pageConfig.PageInfo__r.PageName__c); //2.5 Security Role Matrix and Program Access.
                }
                //Check flow status directly    
                if(memberFlowStatusMap.containskey(queue.SSP_Member__c)) {  
                    Map<String,String> FlowPageStatusMap = memberFlowStatusMap.get(queue.SSP_Member__c);
                    if(FlowPageStatusMap.containskey(pageConfig.NavigationFlowDetail__r.Flowname__c)){
                        String statusString = FlowPageStatusMap.get(pageConfig.NavigationFlowDetail__r.Flowname__c) + (result ? 'R' : 'N');
                        FlowPageStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c,statusString);
                    }
                    else{
                        FlowPageStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c, (result ? 'R' : 'N'));
                    }
                    memberFlowStatusMap.put(queue.SSP_Member__c,FlowPageStatusMap);
                }
                else{
                    Map<String,String> flowStatusMap = new Map<String,String> ();
                    if(flowStatusMap.containskey(pageConfig.NavigationFlowDetail__r.Flowname__c)){
                        String statusString = flowStatusMap.get(pageConfig.NavigationFlowDetail__r.Flowname__c) + (result ? 'R' : 'N');
                        flowStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c,statusString);
                    }
                    else{
                        flowStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c, (result ? 'R' : 'N'));
                    }
                    memberFlowStatusMap.put(queue.SSP_Member__c,flowStatusMap);
                }
            }
        }
        //non-member based flows
        //PERF Fix - Changed definition of Screen Permission
        for(NavFlowPageConfig__mdt pageConfig: pageConfigList) {
            //Boolean isAccessible = (screenPermissions != null && !screenPermissions.isEmpty() && screenPermissions.containsKey(pageConfig.PageInfo__r.PageName__c))  ? screenPermissions.get(pageConfig.PageInfo__r.PageName__c) : true; //2.5 Security Role Matrix and Program Access
            Boolean isAccessible = securityMap != null && !securityMap.isEmpty() && securityMap.containsKey(pageConfig.PageInfo__r.PageName__c) && securityMap.get(pageConfig.PageInfo__r.PageName__c).screenPermission != null ?
                !securityMap.get(pageConfig.PageInfo__r.PageName__c).screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE) : true;
            
            /** */
            if(memberBasedFlows.contains(pageConfig.NavigationFlowDetail__r.Flowname__c)) {
                continue;
            }
            Map<String,String> pageNameStatusMap = new Map<String,String>();
            Boolean result = mode != 'RAC' || newMemberExist && applicationRecord.ChangeSummaryMode__c == 'AddRemoveMember';
            if((mode != 'RAC' || newMemberExist && applicationRecord.ChangeSummaryMode__c == 'AddRemoveMember') && pageConfig.NavFlowRule__r.RuleApexClassName__c != null){
                Type typ = Type.forName(pageConfig.NavFlowRule__r.RuleApexClassName__c);
                BasicNavFlowRule nfr = (BasicNavFlowRule)typ.newInstance();
                Context contextVal = new Context();
                ContextData data = new ContextData();
                data.ApplicationId = applicationRecord.Id;
                data.queueObject = queueObjectValue;
                    data.modeValue = mode;
                result = isAccessible && nfr.isRequired(contextVal, data);//2.5 Security Role Matrix and Program Access
            }
            else if(selectedScreensMap.containsKey('HOH') && selectedScreensMap.get('HOH').contains(pageConfig.PageInfo__r.PageName__c)) {
                result = isAccessible; //2.5 Security Role Matrix and Program Access
            }
            //Hard-Code Sign and Submit
            if('SSP_APP_Signature' == pageConfig.PageInfo__r.PageName__c) {
                result = isAccessible; //2.5 Security Role Matrix and Program Access
            }
            if(memberFlowStatusMap.containskey('HOH')) {  
                Map<String,String> FlowPageStatusMap = memberFlowStatusMap.get('HOH');
                if(FlowPageStatusMap.containskey(pageConfig.NavigationFlowDetail__r.Flowname__c)){
                    String statusString = FlowPageStatusMap.get(pageConfig.NavigationFlowDetail__r.Flowname__c) + (result ? 'R' : 'N');
                    FlowPageStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c,statusString);
                }
                else {
                    FlowPageStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c, (result ? 'R' : 'N'));
                }
                memberFlowStatusMap.put('HOH', FlowPageStatusMap);
            }
            else{
                Map<String,String> flowStatusMap = new Map<String,String> ();
                if(flowStatusMap.containskey(pageConfig.NavigationFlowDetail__r.Flowname__c)){
                    String statusString = flowStatusMap.get(pageConfig.NavigationFlowDetail__r.Flowname__c) + (result ? 'R' : 'N');
                    flowStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c,statusString);
                }
                else{
                    flowStatusMap.put(pageConfig.NavigationFlowDetail__r.Flowname__c, (result ? 'R' : 'N'));
                }
                memberFlowStatusMap.put('HOH', flowStatusMap);
            }
        }
        return memberFlowStatusMap;
    }
    
    /*Bug 378743: Performance Fix: Moved labels to LWC
    private static void replaceLabelsWithalues(Object itemsObject) {
        List<AppSummaryItemWrapper> itemsList = (List<AppSummaryItemWrapper>)itemsObject;
        List<String> labelNames = new List<String>();
        for(AppSummaryItemWrapper item: itemsList) {
            if(String.isNotBlank(item.sectionName)) {
                labelNames.add(item.sectionName);
            }
            if(String.isNotBlank(item.subsectionName)) {
                labelNames.add(item.subsectionName);
            }
        }
        Map<String, String> labelsMap = SSP_LabelService.getValues(labelNames);
        for(AppSummaryItemWrapper item: itemsList) {
            if(String.isNotBlank(item.sectionName) && labelsMap.containsKey(item.sectionName)) {
                item.sectionName = labelsMap.get(item.sectionName);
            }
            if(String.isNotBlank(item.subsectionName) && labelsMap.containsKey(item.subsectionName)) {
                item.subsectionName = labelsMap.get(item.subsectionName);
            }
        }
    }
    */
    
    public class AppSummaryItemWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String sectionName;
        @AuraEnabled
        public String subsectionName;
        @AuraEnabled
        public String pageName;
        @AuraEnabled
        public String flowName;
        @AuraEnabled
        public String screenName;
        @AuraEnabled
        public Boolean memberLevel;
        @AuraEnabled
        public Boolean subsectionLevel;
        @AuraEnabled
        public String memberFilter;
        @AuraEnabled
        public String[] applicablePrograms;
        @AuraEnabled
        public List<Id> members = new List<Id>();
        
        @AuraEnabled
        public Map<Id, String> initialStatusMap = new Map<Id, String>();
        Map<Id, ContextData> contextMap = new Map<Id, ContextData>();
        
        @TestVisible
        AppSummaryItemWrapper(App_Summary_Config__mdt data) {
            id = data.Section_Key__c;
            sectionName = data.Section__c;
            subsectionName = data.Subsection__c;
            pageName = data.PageName__c;
            if(data.IsFlow__c) {
                flowName = data.FlowName__c;
            }
            else {
                screenName = data.FlowName__c;
            }
            memberLevel = data.Based_On_Individual__c;
            subsectionLevel = String.isNotBlank(data.Subsection__c);
            if(memberLevel) {
                memberFilter = data.Member_Filter__c;
            }
            if(data.Applicable_Program_Code__c != null) {
                applicablePrograms = data.Applicable_Program_Code__c.split(';');
            }
        }
    } 
}