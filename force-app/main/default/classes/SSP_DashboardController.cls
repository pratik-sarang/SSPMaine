/*
* classname     :  SSP_DashboardController
* @description  :  Controller class for User Dashboard
* @Reason For Without Sharing : Since We need to use Platform Cache
* @author       :  Kireeti Gora   
* @date         :  03/05/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public without sharing class SSP_DashboardController {        
    /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         03/05/2020
    * @methodname   triggerDashboardServiceCallOut
    * @description  This methods is used to get Dasboard data from Interface
    * @return       SSP_LightningResponse
    *****************************************************************************************************/        
    @AuraEnabled
    public static SSP_LightningResponse triggerDashboardServiceCallOut(String individualId){
        SSP_Utility.isAuthenticatedUser();
        Boolean isHeadOfHouseHold = false;
        Boolean enableRAC = false;
        Boolean enableRenewal = false;
        String strAuthReps = '';
        String strAssisters = '';
        String strAgents = '';
        String selectedRole = '';
        String sSelectedRoleAPI = ''; //Added as part of Defect - 382840
        Boolean isTeamMember = true;
        String caseOwnership = '';
        Boolean isCaseInChangeMode = true;
        String memberTypeFieldValue = '';
        SSP_DashboardCaseInformation dashboardInfo =  new SSP_DashboardCaseInformation();
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
        RSSP_DC_Wrapper response = new RSSP_DC_Wrapper();
        Map<String,String> mapCaseVsStatus = new Map<String,String>();         
        List<Object> serviceResponses =  new List<Object>();
        List<SSP_ApplicationIndividual__c> lstAppIndividual = new List<SSP_ApplicationIndividual__c>();
        List<SSP_IndividualInfoWrapper> lstIndividualData = new List<SSP_IndividualInfoWrapper>();
        List<SSP_DashboardCaseInformation.CaseInfo> lstIndividuals = new  List<SSP_DashboardCaseInformation.CaseInfo>();
        List<SSP_DashboardCaseInformation.TimeStampDetailsWrapper> lstTimeStampDetails = new  List<SSP_DashboardCaseInformation.TimeStampDetailsWrapper>();
        List<SSP_DashboardCaseInformation.Renewal> listRenewal = new  List<SSP_DashboardCaseInformation.Renewal>();
        List<SSP_DashboardCaseInformation.Renewal> listAllRenewals = new  List<SSP_DashboardCaseInformation.Renewal>();
        List<SSP_DashboardCaseInformation.Renewal> listMedicaidRenewal = new  List<SSP_DashboardCaseInformation.Renewal>();
        List<SSP_DashboardCaseInformation.AgentAssisterAuthRep> listAgentAssisterAuthRep = new  List<SSP_DashboardCaseInformation.AgentAssisterAuthRep>();
        List<AboutToExpireWrapper> lstUnsubmittedApplication = new List<AboutToExpireWrapper>();
        List<AboutToExpireWrapper> lstPendingInterviewApplications = new List<AboutToExpireWrapper>();
        List<NotificationWrapper> lstNotificationWrapper = new List<NotificationWrapper>();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        List<Account> lstAccount = new List<Account>();           
        List<AccountContactRelation> lstACR = new  List<AccountContactRelation>();    
        List<String> lstRACCases = new List<String>();
        Set<Id> lstAccountIds = new Set<Id>(); 
        Map<String, Object> mapParams = new Map<String, Object>();
        Map<String, List<string>> mapApplicationVsPrograms = new Map<String, List<string>>();
        Map<String, Boolean> mapCaseVsHOH = new Map<String, Boolean>();
        Map<String, Boolean> mapCaseVsRenewal = new Map<String, Boolean>();
        Map<String, String> mapCaseVsEligibilityRunDate = new Map<String, String>(); //387346
        Map<String, String> mapRoleVsList = new Map<String, String>();
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        Map<String, List<String>> mapCaseVsIndividualIds = new Map<String, List<String>>();
        Contact conToBeUpdated;///WIP
        DashboardCacheWrapper cacheWrap; 
	    /*	message center changes */
        map<String,Set<String>> authRepAccessForNotices = new map<String,Set<String>>();
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);       
        RSSP_DC_Wrapper wrapperResponse =  new RSSP_DC_Wrapper();        
        String currentUserIndividualIds;
        try{              
            currentUserIndividualIds = ssp_utility.getCurrentUserAllIndividualIds();
            individualId = (individualId == null) ? SSP_Utility.getIndividualId() : individualId; //WIP
            Contact individualContact = SSP_DashboardService.getIndividualContact(individualId);
            String contactName;            
            selectedRole = SSP_Utility.getSelectedRole();
            sSelectedRoleAPI = selectedRole; //Added as part of Defect - 382840
            Map<String,String> map_RoleLabelValue = SSP_Utility.getPickListValues('User', 'ApplicableRoles__c', null);
            if(selectedRole != null && selectedRole != ''){
                selectedRole = map_RoleLabelValue.get(selectedRole);
            }
            resultMap.put('selectedRole', selectedRole);

            Id memberId =  individualContact != null ? SSP_DashboardService.getMemberId(individualContact.Id) : null ;            
            if(memberId != null){
                lstAppIndividual =SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                                                   new Set<String>{'Id','IsHeadOfHousehold__c','toLabel(ProgramsApplied__c)','SSP_Application__c','SSP_Application__r.name','SSP_Application__r.dccasenumber__c','SSP_Application__r.Status__c','SSP_Application__r.ApplicationReceivedDateTime__c','createdDate','SSP_Application__r.ApplicationCreationInSSP__c','toLabel(SSP_Application__r.ProgramsApplied__c)'}, 
                                                                                                   new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> memberId/*,'SSP_Application__r.Status__c'=>'UN'*/,'SSP_Application__r.RecordType.DeveloperName'=>'SSP_Application'});
            }
            for(SSP_ApplicationIndividual__c objAppIndividual :lstAppIndividual){ 
                if(objAppIndividual.SSP_Application__r.Status__c=='P' && objAppIndividual.SSP_Application__r.dccasenumber__c == null){
                    String underReviewApplicationNumber;   
                    List<String> underReviewPrograms =  new List<String>();
                    underReviewApplicationNumber = objAppIndividual.SSP_Application__r.name;
                    if(objAppIndividual.IsHeadOfHousehold__c && objAppIndividual.SSP_Application__r.ProgramsApplied__c != null){
                        underReviewPrograms = objAppIndividual.SSP_Application__r.ProgramsApplied__c.split(';');
                    }else if((!objAppIndividual.IsHeadOfHousehold__c) && objAppIndividual.ProgramsApplied__c != null){
                        underReviewPrograms = objAppIndividual.ProgramsApplied__c.split(';');
                    }
                    mapApplicationVsPrograms.put(underReviewApplicationNumber,underReviewPrograms);
                     isHeadOfHouseHold = objAppIndividual.IsHeadOfHousehold__c; 
                }
                
               

                if(objAppIndividual.SSP_Application__r.Status__c=='UN'){            
                    isHeadOfHouseHold = objAppIndividual.IsHeadOfHousehold__c; 
                    AboutToExpireWrapper objExpire = new AboutToExpireWrapper();
                    AboutToExpireWrapper objPendinginterview = new AboutToExpireWrapper();
                    objExpire.applicationId =objAppIndividual.SSP_Application__c ; 
                    objPendinginterview.applicationId=objAppIndividual.SSP_Application__c; 
                    if(objAppIndividual.SSP_Application__r.ProgramsApplied__c != null){
                        objPendinginterview.programsApplied = objAppIndividual.SSP_Application__r.ProgramsApplied__c.replace(';',',');
                        objExpire.programsApplied = objAppIndividual.SSP_Application__r.ProgramsApplied__c.replace(';',',');
                    }
                    if(objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null && (8 - (objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(SSP_utility.today())) == 0)){
                        objExpire.daysRemaining =system.label.sspToday;
                        objExpire.isToday = true;
                        objExpire.expiryDate = system.label.sspToday;
                    }else if(objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null){
                        objExpire.daysRemaining = String.ValueOf(8 -(objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(ssp_utility.today())));
                        Date  objDate = objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.addDays(8);
                        objExpire.expiryDate =objDate.month() + '/'+objDate.day()+'/'+objDate.year(); 
                        objExpire.isToday = false;
                    }
                    if(objAppIndividual.SSP_Application__r.ApplicationReceivedDateTime__c != null && ( 30 - (Date.valueOf(objAppIndividual.SSP_Application__r.ApplicationReceivedDateTime__c).daysBetween(SSP_utility.today())) == 0)){
                        objPendinginterview.daysRemaining =system.label.sspToday;
                        objPendinginterview.isToday = true;
                    }else if(objAppIndividual.SSP_Application__r.ApplicationReceivedDateTime__c != null){
                        objPendinginterview.daysRemaining = String.ValueOf(30 -(Date.valueOf(objAppIndividual.SSP_Application__r.ApplicationReceivedDateTime__c).daysBetween(ssp_utility.today())));
                        objPendinginterview.isToday = false;
                    }
                    if(objAppIndividual.IsHeadOfHousehold__c && objExpire.daysRemaining != null && objExpire.daysRemaining != system.label.sspToday &&Integer.valueOf(objExpire.daysRemaining) <= 8 && Integer.valueOf(objExpire.daysRemaining) > 0){
                        lstUnsubmittedApplication.add(objExpire);
                    }else if(objAppIndividual.IsHeadOfHousehold__c && objExpire.daysRemaining == system.label.sspToday){
                        lstUnsubmittedApplication.add(objExpire);
                    }
                    if(objAppIndividual.IsHeadOfHousehold__c && objPendinginterview.daysRemaining != null && objPendinginterview.daysRemaining != system.label.sspToday && Integer.valueOf(objPendinginterview.daysRemaining) <= 30 && Integer.valueOf(objPendinginterview.daysRemaining) > 0){
                        lstPendingInterviewApplications.add(objPendinginterview);
                    }else if(objAppIndividual.IsHeadOfHousehold__c && objPendinginterview.daysRemaining == system.label.sspToday){
                        lstPendingInterviewApplications.add(objPendinginterview);
                    } 
                }
            }    
            if(!lstUnsubmittedApplication.isEmpty()){
                resultMap.put('hasExpiringApplications',JSON.serialize(lstUnsubmittedApplication));
                
            }
            if((!mapApplicationVsPrograms.keyset().isEmpty()) && (lstUnsubmittedApplication.isEmpty())){
                resultMap.put('underReviewApplicationNumber',mapApplicationVsPrograms.keyset());
                resultMap.put('underReviewPrograms',JSON.serialize(mapApplicationVsPrograms));
                
            }
            
            resultMap.put('isHeadOfHouseHold',isHeadOfHouseHold);     
            
            Boolean isRefreshRequired = (individualContact != null && individualContact.IsDashboardRefreshNeeded__c) ? individualContact.IsDashboardRefreshNeeded__c : !(sessionPart.get('isHeadOfHouseHold') != null);
            if(currentUserIndividualIds != null && currentUserIndividualIds !='' && isRefreshRequired){    
                                             
                SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName = SSP_InterfaceConstants.DASHBOARD_CASE_INFORMATION;               
 
                reqWrapper.primaryApplicationIndividualId = currentUserIndividualIds;
                //Start - Added as part of Defect - 382840
                if(sSelectedRoleAPI != null && String.isNotBlank(sSelectedRoleAPI)){
                    reqWrapper.role = sSelectedRoleAPI;
                }
                //End - Added as part of Defect - 382840
                mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                mapParams.put(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD,true); //PERF Fix 
                serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                if(serviceResponses != null && !serviceResponses.isEmpty()){
                    wrapperResponse = (RSSP_DC_Wrapper) serviceResponses[0];                    
                }
                if(wrapperResponse != null && wrapperResponse.dashboardCaseInfo != null && wrapperResponse.dashboardCaseInfo.CaseInfo != null){                  
                    lstIndividuals=wrapperResponse.dashboardCaseInfo.CaseInfo;
                    
                }
                //Added for multiple individual id change - Nupoor
                if(wrapperResponse != null && wrapperResponse.dashboardCaseInfo != null && wrapperResponse.dashboardCaseInfo.DemographicDetails != null){
                    List<SSP_DashboardCaseInformation.DemographicDetailsWrapper> lstDemographicDetails = wrapperResponse.dashboardCaseInfo.DemographicDetails;
                    Integer preferredIndividualId;
                    for(SSP_DashboardCaseInformation.DemographicDetailsWrapper objDemographicWrap : lstDemographicDetails){
                        
                        if(objDemographicWrap.PreferredIndividual == 'Y'){
                            
                            
                            
                            preferredIndividualId = Integer.valueOf(objDemographicWrap.IndividualId);
                            contactName = objDemographicWrap.FirstName + ' ' + objDemographicWrap.LastName;
                            sessionPart.put('contactName',contactName,3600,Cache.Visibility.ALL,false);
                            break;
                        }
                    }
                    if(preferredIndividualId != null){
                        Contact_Mapping__c objMapping = new Contact_Mapping__c();
                        Contact objContact = new Contact();
                        List<Contact> lstContactsToUpdate = new List<Contact>();
                        List<String> lstContactId = new List<String>();
                        List<User> lstUser = new List<User>();
                        List<Contact_Mapping__c> lstConMapping = SSP_SharingBypassFetcher.fetchContactMapping(preferredIndividualId);
                        for(Contact_Mapping__c objContactMapping :lstConMapping){
                            if(objContactMapping.contact__c != null){
                                lstContactId.add(objContactMapping.contact__c);
                            }
                        }
                        if(!lstContactId.isEmpty()){
                        lstUser = [SELECT Id,contactId FROM User WHERE contactId IN :lstContactId];
                        }
                        if(lstConMapping!= null && lstConMapping.size()>0){
                            String contactId;
                            if(!lstUser.isEmpty()){
                                contactId = lstUser[0].contactId;
                            }else{
                                objMapping = lstConMapping[0]; 
                                contactId = objMapping.Contact__c;
                            }
                            if(contactId != null){
                                lstContactsToUpdate =  [SELECT Id,IndividualId__c FROM Contact WHERE IndividualId__c =:String.valueOf(preferredIndividualId) AND Id != :contactId];
                                objContact = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                                  new Set<String>{'Id', 'IndividualId__c'}, 
                                                                                  new Map<String, String>{'limit'=>'1','Id'=> contactId})[0];
                            }
                            
                        }
                        for(Contact objContactToUpdate : lstContactsToUpdate){
                            objContactToUpdate.IndividualId__c = null;
                        }
                        if(!lstContactsToUpdate.isEmpty()){
                            UPDATE lstContactsToUpdate;
                        }
                        if(objContact != null){
                            sessionPart.put('individualId',preferredIndividualId,3600,Cache.Visibility.ALL,false);
                            objContact.IndividualId__c = String.valueOf(preferredIndividualId);
                            //ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
                            //ESAPI.accessController().updateAsUser(objContact, SSP_Utility.getFieldsNamesObject (objContact)); 
                            //Perf Fix
                            SSP_GenericWOSharingDMLHelper.updateRecords(new List<Contact>{objContact},  new List<String>{'IndividualId__c'});

                           
                        }
                    }
                }
                if(wrapperResponse != null && wrapperResponse.dashboardCaseInfo != null && wrapperResponse.dashboardCaseInfo.Renewal != null){
                    listAllRenewals = wrapperResponse.dashboardCaseInfo.Renewal;
                }
                if(wrapperResponse != null && wrapperResponse.dashboardCaseInfo != null && wrapperResponse.dashboardCaseInfo.TimeStampDetails != null) {
                    lstTimeStampDetails = wrapperResponse.dashboardCaseInfo.TimeStampDetails;
                }                
                for(SSP_DashboardCaseInformation.CaseInfo objCaseWrap : lstIndividuals){
                    
                    
                    mapCaseVsStatus.put(objCaseWrap.caseNumber,objCaseWrap.CaseStatusCode);
                    NotificationWrapper objNotification =  new NotificationWrapper();
                    objNotification.CaseInfoNumber = objCaseWrap.CaseNumber ;
                     if(objCaseWrap.CaseNumber  != null && objCaseWrap.IndividualId != null){
                        mapCaseVsIndividualId.put(objCaseWrap.CaseNumber ,objCaseWrap.individualId);
                        if(mapCaseVsIndividualIds.get(objCaseWrap.CaseNumber) == null) {
                            mapCaseVsIndividualIds.put(objCaseWrap.CaseNumber, new List<String>());
                        }
                        mapCaseVsIndividualIds.get(objCaseWrap.CaseNumber).add(objCaseWrap.individualId);
                    }

                    /** 387346 */
                    if(objCaseWrap.LastEligibilityTransactionDate  != null && objCaseWrap.IsHeadofhousehold != null && objCaseWrap.IsHeadofhousehold == SSP_GlobalConstants.YES){
                        mapCaseVsEligibilityRunDate.put(objCaseWrap.CaseNumber, objCaseWrap.LastEligibilityTransactionDate);
                    }
                    /**  */
                    if(objCaseWrap.CaseNumber  != null && objCaseWrap.IsHeadofhousehold != null && objCaseWrap.IsHeadofhousehold == SSP_GlobalConstants.YES){
                        mapCaseVsHOH.put(objCaseWrap.CaseNumber ,true);
                    }else  if(objCaseWrap.CaseNumber  != null && objCaseWrap.IsHeadofhousehold != null && objCaseWrap.IsHeadofhousehold == SSP_GlobalConstants.NO){
                        mapCaseVsHOH.put(objCaseWrap.CaseNumber ,false);
                    }
                    if(  objCaseWrap.IsHeadofhousehold != null && objCaseWrap.IsHeadofhousehold == SSP_GlobalConstants.YES){
                        isHeadOfHouseHold = true;
                        
                    }
                    if(objCaseWrap.IsRACEnabled!= null && objCaseWrap.IsHeadofhousehold != null && objCaseWrap.IsRACEnabled ==SSP_GlobalConstants.YES && objCaseWrap.IsHeadofhousehold == SSP_GlobalConstants.YES){
                        enableRAC = true;
                        lstRACCases.add(objCaseWrap.CaseNumber);
                    }
                    if(objCaseWrap.IsInRenewalPeriod!= null && objCaseWrap.IsHeadofhousehold != null && objCaseWrap.IsInRenewalPeriod ==SSP_GlobalConstants.YES && objCaseWrap.IsHeadofhousehold == SSP_GlobalConstants.YES){
                        mapCaseVsRenewal.put(objCaseWrap.CaseNumber,true);
                        enableRenewal = true;
                    }
                    if(objCaseWrap.RFICount != '0' && objCaseWrap.RFICount != null){
                        objNotification.hasRFI = true;
                        objNotification.RFICount= objCaseWrap.RFICount;
                    }else {
                        objNotification.hasRFI = false;
                    }
                    if(objCaseWrap.SNAPClaimAmount != null){
                        objNotification.hasSnapAmount = true;
                        objNotification.SnapAmount= objCaseWrap.SNAPClaimAmount;
                    }else {
                        objNotification.hasSnapAmount = false;
                    }
                    if(objCaseWrap.IsHeadofhousehold == SSP_GlobalConstants.YES){
                        lstNotificationWrapper.add(objNotification);
                    }
                    if(objCaseWrap.IsTmember != null){
                        if(isTeamMember == true){
                            isTeamMember = objCaseWrap.IsTmember == SSP_GlobalConstants.YES ? true : false;
                        }
                    }
                    else if(objCaseWrap.IsTmember == null){
                        isTeamMember = false;
                    }
                    if(objCaseWrap.CaseOwnership != null ){
                        caseOwnership = objCaseWrap.CaseOwnership;
                    }
                    if(objCaseWrap.ApplicationSourceType != null ){
                        caseOwnership = String.isBlank(caseOwnership) ? objCaseWrap.ApplicationSourceType : caseOwnership + ';' + objCaseWrap.ApplicationSourceType;
                    }
                    if(objCaseWrap.MedicaidApplicationType != null ){
                        caseOwnership = String.isBlank(caseOwnership) ? objCaseWrap.MedicaidApplicationType : caseOwnership + ';' + objCaseWrap.MedicaidApplicationType;
                    }
                    if(objCaseWrap.IsCaseInChangeMode != null ){
                        if(isCaseInChangeMode == true){
                            isCaseInChangeMode = objCaseWrap.IsCaseInChangeMode == SSP_GlobalConstants.YES ? true : false;
                        }
                    }
                    else if(objCaseWrap.IsCaseInChangeMode == null ){
                        isCaseInChangeMode = false;
                    }
                }
                
                resultMap.put('isCaseInChangeMode', isCaseInChangeMode);
                sessionpart.put('isCaseInChangeMode', isCaseInChangeMode, 3600, Cache.Visibility.ALL, false);

                resultMap.put('caseOwnership', caseOwnership);
                sessionpart.put('caseOwnership', caseOwnership, 3600, Cache.Visibility.ALL, false);

                resultMap.put('isTeamMember', isTeamMember);
                sessionpart.put('isTeamMember', isTeamMember, 3600, Cache.Visibility.ALL, false);
                
                for(SSP_DashboardCaseInformation.Renewal objRenewal : listAllRenewals){
                    objRenewal.RenewalDueDate = String.ValueOf(ssp_utility.today().daysBetween(Date.valueOf(objRenewal.RenewalDueDate)));
                    if(mapCaseVsRenewal.get(objRenewal.caseNumber) != null && mapCaseVsHOH.get(objRenewal.caseNumber) != null && mapCaseVsHOH.get(objRenewal.caseNumber) &&(Integer.ValueOf(objRenewal.RenewalDueDate) >= 0) && objRenewal.RenewalProgramCode == SSP_GlobalConstants.MEDICAID){
                        objRenewal.RenewalProgramCode = system.label.SSP_Medicaid;                     
                        listMedicaidRenewal.add(objRenewal);
                        lstRACCases = removeFromList(lstRACCases, objRenewal.caseNumber); //remove case no from RAC list if same is available for MA renewal.
                    }else if(mapCaseVsHOH.get(objRenewal.caseNumber) != null && mapCaseVsHOH.get(objRenewal.caseNumber) && Integer.ValueOf(objRenewal.RenewalDueDate) >= 0 && objRenewal.RenewalProgramCode ==SSP_GlobalConstants.SNAP){
                        objRenewal.RenewalProgramCode = system.label.SSP_SNAP;
                        listRenewal.add(objRenewal);
                    }  
                }
                if(memberId != null && isHeadOfHouseHold){
                    
                    lstApplicationIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualCaseData(new Set<String>{'Id', 'ProgramsApplied__c', 'SSP_Application__r.Account__c','SSP_Application__r.Status__c','IsHeadOfHousehold__c'}, 
                                                                                                                    memberId,false,null);  
                }
                if(!lstApplicationIndividual.isEmpty()){
                    for(SSP_ApplicationIndividual__c objAppIndividual: lstApplicationIndividual){
                        if(objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null && ((8 - (objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(SSP_utility.today())) >= 0)  && (objAppIndividual.SSP_Application__r.RecordType.DeveloperName=='SSP_Application')  && (objAppIndividual.ssp_application__r.Status__c == 'UN'))
                          ){
                              lstAccountIds.add(objAppIndividual.SSP_Application__r.Account__c);
                              mapCaseVsHOH.put(objAppIndividual.ssp_application__r.Account__c,objAppIndividual.IsHeadOfHousehold__c);
                          }
                    }
                }                
                if(!lstAccountIds.isEmpty()){
                    lstAccount = SSP_AccountSelector.queryAccountData(new Map<String, String>{'objectName'=>'ACCOUNT','operator'=>'AND','IN'=>'id'}, 
                                                                      new Set<String>{'Id','(SELECT accountId,id,Roles,contact.Name FROM AccountContactRelations)'}, 
                                                                      new Map<String, String>{'limit'=>'1000','id'=>String.join(new List<Id>(lstAccountIds), ',')});                    
                }
                for(Account objAccount: lstAccount){
                    if(!objAccount.AccountContactRelations.isEmpty()){                       
                        lstACR.addAll(objAccount.AccountContactRelations);                      
                    }
                } 
                for(AccountContactRelation objACR: lstACR){
                    SSP_DashboardCaseInformation.AgentAssisterAuthRep objRole =  new  SSP_DashboardCaseInformation.AgentAssisterAuthRep();
                    
                    if(objACR.Roles!= null && (objACR.Roles.contains(SSP_GlobalConstants.ASSISTER_ROLE) || objACR.Roles.contains(SSP_GlobalConstants.AGENCY_ADMIN_ROLE))){
                        objRole.RoleType = SSP_GlobalConstants.ROLE_ASSISTER;
                        objRole.FullName = objACR.contact.Name;
                        
                    } else if(objACR.Roles!= null && (objACR.Roles.contains(SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING) || objACR.Roles.contains(SSP_GlobalConstants.ORGANISATION_AUTH_REP))){
                        objRole.RoleType = SSP_GlobalConstants.ROLE_AUTH_REP;
                        objRole.FullName = objACR.contact.Name;
                        objRole.CaseNumber =objACR.accountId;
                        
                    }else if(objACR.Roles!= null && objACR.Roles.contains(SSP_GlobalConstants.INSURANCEAGENT_ROLE)){
                        objRole.RoleType = SSP_GlobalConstants.ROLE_AGENT;
                        objRole.FullName = objACR.contact.Name;
                    }
                    listAgentAssisterAuthRep.add(objRole);
                } 
                if(isHeadOfHouseHold && wrapperResponse != null && wrapperResponse.dashboardCaseInfo != null && wrapperResponse.dashboardCaseInfo.AgentAssisterAuthRep != null){
                    listAgentAssisterAuthRep.addAll(wrapperResponse.dashboardCaseInfo.AgentAssisterAuthRep);
                }
                for(SSP_DashboardCaseInformation.AgentAssisterAuthRep objAuthRep : listAgentAssisterAuthRep){                   
                    if(mapCaseVsHOH.get(objAuthRep.CaseNumber) != null && mapCaseVsHOH.get(objAuthRep.CaseNumber) && objAuthRep.RoleType == SSP_GlobalConstants.ROLE_AUTH_REP && strAuthReps == ''){
                        strAuthReps =objAuthRep.FullName;
                    }else if(mapCaseVsHOH.get(objAuthRep.CaseNumber) != null && mapCaseVsHOH.get(objAuthRep.CaseNumber) && objAuthRep.RoleType == SSP_GlobalConstants.ROLE_AUTH_REP && strAuthReps != '' && (!strAuthReps.contains(objAuthRep.FullName))){
                        strAuthReps =strAuthReps+ ', '+objAuthRep.FullName;
                    }
                    if(objAuthRep.RoleType == SSP_GlobalConstants.ROLE_ASSISTER && strAssisters == ''){
                        strAssisters =objAuthRep.FullName;
                    }else if(objAuthRep.RoleType ==  SSP_GlobalConstants.ROLE_ASSISTER && strAssisters != '' && (!strAssisters.contains(objAuthRep.FullName))){
                        strAssisters = strAssisters+', '+objAuthRep.FullName;
                    }
                    if(objAuthRep.RoleType ==  SSP_GlobalConstantS.ROLE_AGENT && strAgents == '' ){
                        strAgents =objAuthRep.FullName;
                    }else if(objAuthRep.RoleType == SSP_GlobalConstantS.ROLE_AGENT && strAgents != '' && (!strAgents.contains(objAuthRep.FullName))){
                        strAgents = strAgents+', '+objAuthRep.FullName; 
                    }
                }
                /*	message center changes
                    This block prepares, message center notice access map for Auth Representatives
                */
                if( (sSelectedRoleAPI == SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING || sSelectedRoleAPI == SSP_GlobalConstants.ORGANISATION_AUTH_REP) &&
                    wrapperResponse != null && wrapperResponse.dashboardCaseInfo != null &&  wrapperResponse.dashboardCaseInfo.AgentAssisterAuthRep != null 
                    && !wrapperResponse.dashboardCaseInfo.AgentAssisterAuthRep.isEmpty() ){
                    String nonCitizenContactId = (SSP_Utility.getUserDetails(UserInfo.getUserId())).get('contactId');
                    Set<Integer> setDCContactId = new Set<Integer>();
                    for(AccountContactRelation objACR : [select id, DCContactId__c from AccountContactRelation where DCContactId__c != null AND 
                                            Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION AND 
                                            ContactId = :nonCitizenContactId And Roles IN :new List<string>{SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING,SSP_GlobalConstants.ORGANISATION_AUTH_REP}])
                    {
                        setDCContactId.add((objACR.DCContactId__c).intValue());
                    }
					
                    for(SSP_DashboardCaseInformation.AgentAssisterAuthRep repWrap: wrapperResponse.dashboardCaseInfo.AgentAssisterAuthRep){
                        set<String> accessibleProgramsForNotices = new set<String>();
                        Integer DCRepresentativeId;
                        if(repWrap.DCRepresentativeId!=null)
                            DCRepresentativeId = Integer.valueOf(repWrap.DCRepresentativeId);

                        if(DCRepresentativeId!=null && setDCContactId.contains(DCRepresentativeId) && repWrap.PermissionLevelMA=='NT')
                            accessibleProgramsForNotices.add('MA');
                        if(DCRepresentativeId!=null && setDCContactId.contains(DCRepresentativeId) && repWrap.PermissionLevelSN=='NT')
                            accessibleProgramsForNotices.add('SN');
                        if(DCRepresentativeId!=null && setDCContactId.contains(DCRepresentativeId) && repWrap.PermissionLevelSS=='NT')
                            accessibleProgramsForNotices.add('SS');
                        if(DCRepresentativeId!=null && setDCContactId.contains(DCRepresentativeId) && repWrap.PermissionLevelKP=='NT')
                            accessibleProgramsForNotices.add('KP');
                        if(DCRepresentativeId!=null && setDCContactId.contains(DCRepresentativeId) && repWrap.PermissionLevelKT=='NT')
                            accessibleProgramsForNotices.add('KT');
                        if(DCRepresentativeId!=null && setDCContactId.contains(DCRepresentativeId) && repWrap.PermissionLevelCC=='NT')
                            accessibleProgramsForNotices.add('CC');
                        if(repWrap.CaseNumber!=null && !accessibleProgramsForNotices.isEmpty())
                            authRepAccessForNotices.put(repWrap.CaseNumber,accessibleProgramsForNotices);
                    }
                }   
                /*	message center changes
                    added message center notice access for auth reps map in Dashboard Cache Wrapper & Browser Cache
                */
                if(!authRepAccessForNotices.keyset().isEmpty()){                    
                    sessionpart.put('authRepAccessForNotices',JSON.serialize(authRepAccessForNotices),3600,Cache.Visibility.ALL,false);
                    cacheWrap = cacheWrap != null ? cacheWrap : new  DashboardCacheWrapper();
                    cacheWrap.authRepAccessForNotices = authRepAccessForNotices;                   
                }
                if(strAuthReps != ''){
                    mapRoleVsList.put(SSP_GlobalConstants.ROLE_AUTH_REP,strAuthReps);
                }
                if(strAssisters != ''){
                    mapRoleVsList.put(SSP_GlobalConstants.ROLE_ASSISTER,strAssisters);
                }
                if(strAgents != ''){
                    mapRoleVsList.put(SSP_GlobalConstantS.ROLE_AGENT,strAgents);
                }
                if(!mapRoleVsList.isEmpty()){
                    resultMap.put('hasAuthRepAgents',JSON.serialize(mapRoleVsList));
                    sessionpart.put('hasAuthRepAgents',JSON.serialize(mapRoleVsList),3600,Cache.Visibility.ALL,false);
                }
                
                
                if(!listMedicaidRenewal.isEmpty()){ 
                    resultMap.put('hasMedicaidRenewals',JSON.serialize(listMedicaidRenewal));
                    sessionpart.put('hasMedicaidRenewals',JSON.serialize(listMedicaidRenewal),3600,Cache.Visibility.ALL,false);
                }
                
                if(!listRenewal.isEmpty()){
                    resultMap.put('hasOtherRenewals',JSON.serialize(listRenewal));
                    sessionpart.put('hasOtherRenewals',JSON.serialize(listRenewal),3600,Cache.Visibility.ALL,false);
                }
                if(!lstRACCases.isEmpty()){
                    resultMap.put('hasActiveCase',JSON.serialize(lstRACCases));
                    sessionpart.put('hasActiveCase',JSON.serialize(lstRACCases),3600,Cache.Visibility.ALL,false);
                    //Shikha - added
                    cacheWrap = cacheWrap != null ? cacheWrap : new  DashboardCacheWrapper();////
                    cacheWrap.hasRACEnabled = true;
                    //Shikha - end
                }
                if(!lstNotificationWrapper.isEmpty()){
                    resultMap.put('notificationsList',JSON.serialize(lstNotificationWrapper));
                    sessionpart.put('notificationsList',JSON.serialize(lstNotificationWrapper),3600,Cache.Visibility.ALL,false);
                }
                
                     if(!mapCaseVsIndividualId.isEmpty()){                   
                    sessionpart.put('caseVsIndividualId',JSON.serialize(mapCaseVsIndividualId),3600,Cache.Visibility.ALL,false);
                           cacheWrap = cacheWrap != null ? cacheWrap : new  DashboardCacheWrapper();////
                    cacheWrap.mapCaseVsIndividualId = mapCaseVsIndividualId;
                }
                if(!mapCaseVsIndividualIds.isEmpty()) {
                    sessionpart.put('caseVsIndividualIds', JSON.serialize(mapCaseVsIndividualIds),3600,Cache.Visibility.ALL,false);
                }
                if(!mapCaseVsHOH.keyset().isEmpty()){                    
                    sessionpart.put('caseVsHOH',JSON.serialize(mapCaseVsHOH),3600,Cache.Visibility.ALL,false);

                    cacheWrap = cacheWrap != null ? cacheWrap : new  DashboardCacheWrapper();
                    cacheWrap.mapCaseVsHOH = mapCaseVsHOH;
                }

                /** #387346 */
                if(!mapCaseVsEligibilityRunDate.keySet().isEmpty()){
                    sessionpart.put('mapCaseVsEligibilityRunDate',JSON.serialize(mapCaseVsEligibilityRunDate),3600,Cache.Visibility.ALL,false);
                    cacheWrap = cacheWrap != null ? cacheWrap : new  DashboardCacheWrapper();
                    cacheWrap.mapCaseVsEligibilityRunDate = mapCaseVsEligibilityRunDate;      
                }
                /**  */
                if(!mapCaseVsStatus.keyset().isEmpty()){                    
                    resultMap.put('caseVsStatus',JSON.serialize(mapCaseVsStatus));
                    resultMap.put('caseOptions',JSON.serialize(mapCaseVsStatus.keyset()));
                    sessionpart.put('caseOptions',JSON.serialize(mapCaseVsStatus.keyset()),3600,Cache.Visibility.ALL,false);
                    sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);

                    cacheWrap = cacheWrap != null ? cacheWrap : new  DashboardCacheWrapper();
                    cacheWrap.mapCaseVsStatus = mapCaseVsStatus;                   
                }

                if(cacheWrap != null){
                    conToBeUpdated = conToBeUpdated != null ? conToBeUpdated : new Contact(Id = individualContact.Id);
                    conToBeUpdated.CacheDashboardData__c = JSON.serialize(cacheWrap);
                }
                
                if(!lstIndividuals.isEmpty()){
                    resultMap.put('isExistingUser',true);
                    sessionpart.put('isExistingUser',true,3600,Cache.Visibility.ALL,false);
                    if(individualContact != null){                        
                        conToBeUpdated = conToBeUpdated != null ? conToBeUpdated : new Contact(Id = individualContact.Id);
                        if(!individualContact.DoesCaseExistForIndividual__c){
                            conToBeUpdated.DoesCaseExistForIndividual__c = true;
                        }
                        if(isTeamMember){
                            memberTypeFieldValue = SSP_GlobalConstants.TMEM;
                        }
                        String ownershipValue = caseOwnership;
                        
                        String livingArrangement = '';
                        List<SSP_Member__c> lstMember  = new List<SSP_Member__c>();
                        if(memberId != null)
                        {
                            lstMember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                                                        new Set<String>{'Id','LaTypeCode__c'}, 
                                                                                        new Map<String, String>{'Id'=> memberId});
                        }
                        if(lstMember!=null && !lstMember.isEmpty() && lstMember[0].LaTypeCode__c != null){
                            livingArrangement = lstMember[0].LaTypeCode__c;
                        }
                        String isHOH_DEP = ((isHeadOfHouseHold == true) && livingArrangement!='DAA') ? SSP_GlobalConstants.HOH : SSP_GlobalConstants.DEP;

                        if(isCaseInChangeMode){
                            ownershipValue = String.isBlank(ownershipValue) ? SSP_GlobalConstants.CHANGE : ownershipValue + ';' + SSP_GlobalConstants.CHANGE;
                        }
                        memberTypeFieldValue = memberTypeFieldValue == '' ? isHOH_DEP : memberTypeFieldValue + ' ' + isHOH_DEP;

                        conToBeUpdated.MemberType__c = memberTypeFieldValue;
                        conToBeUpdated.CaseOwnership__c = ownershipValue;
                    }
                }
                
                Boolean boolIsEligible = individualContact.Is_Eligible_For_RSSPDC__c;
                Boolean isEligibleForRSSPDC = false;
                if(lstTimeStampDetails != null && !lstTimeStampDetails.isEmpty() && lstTimeStampDetails.get(0).TimeStamp != null && 
                   (individualContact.Last_RSSPDC_DateTime__c == null || (individualContact.Last_RSSPDC_DateTime__c != null && 
                                                                   DateTime.ValueofGMT(lstTimeStampDetails.get(0).TimeStamp.replace('T', ' ')) >
                                                                   DateTime.ValueofGMT(individualContact.Last_RSSPDC_DateTime__c)))) {
                                                                       isEligibleForRSSPDC = true;
                                                                   }
                if(boolIsEligible != isEligibleForRSSPDC) {
                    conToBeUpdated = conToBeUpdated != null ? conToBeUpdated : new Contact(Id = individualContact.Id);
                    conToBeUpdated.Is_Eligible_For_RSSPDC__c = isEligibleForRSSPDC;
                }
                resultMap.put('isHeadOfHouseHold',isHeadOfHouseHold);
                sessionpart.put('isHeadOfHouseHold',isHeadOfHouseHold,3600,Cache.Visibility.ALL,false);
                resultMap.put('caseVsIndividuals', JSON.serialize(mapCaseVsIndividualIds));
                resultMap.put('caseVsHOH', JSON.serialize(mapCaseVsHOH));
            }
            else {
                
                if(sessionpart.get('isHeadOfHouseHold') != null ){                   
                    resultMap.put('isHeadOfHouseHold',sessionPart.get('isHeadOfHouseHold'));
                } 
                if(sessionpart.get('hasActiveCase') != null ){                   
                    resultMap.put('hasActiveCase',sessionPart.get('hasActiveCase'));
                } 
                
                if(sessionpart.get('caseOptions') != null){
                    resultMap.put('caseOptions',sessionPart.get('caseOptions'));
                }
                
                if(sessionpart.get('hasMedicaidRenewals') != null){
                    resultMap.put('hasMedicaidRenewals',sessionPart.get('hasMedicaidRenewals'));
                }
                if(sessionpart.get('hasOtherRenewals') != null){
                    resultMap.put('hasOtherRenewals',sessionPart.get('hasOtherRenewals'));
                }
                if(sessionpart.get('notificationsList') != null){
                    resultMap.put('notificationsList',sessionPart.get('notificationsList'));
                }
                if(sessionpart.get('isExistingUser') != null){
                    resultMap.put('isExistingUser',sessionPart.get('isExistingUser'));
                }
                
                if(sessionpart.get('hasAuthRepAgents') != null){
                    resultMap.put('hasAuthRepAgents',sessionPart.get('hasAuthRepAgents'));
                }
                if(sessionpart.get('caseVsStatus') != null){
                    resultMap.put('caseVsStatus',sessionPart.get('caseVsStatus'));
                }

                if(sessionpart.get('isCaseInChangeMode') != null){
                    resultMap.put('isCaseInChangeMode',sessionPart.get('isCaseInChangeMode'));
                }
                if(sessionpart.get('caseOwnership') != null){
                    resultMap.put('caseOwnership',sessionPart.get('caseOwnership'));
                }
                if(sessionpart.get('isTeamMember') != null){
                    resultMap.put('isTeamMember',sessionPart.get('isTeamMember'));
                }
                if(sessionpart.get('caseVsIndividualIds') != null) {
                    resultMap.put('caseVsIndividuals', sessionpart.get('caseVsIndividualIds'));
                }
                if(sessionPart.get('caseVsHOH') != null) {
                    resultMap.put('caseVsHOH', sessionpart.get('caseVsHOH'));
                }
            } 
            if(sessionpart.get('contactName') != null){
                    resultMap.put('contactName',sessionPart.get('contactName'));
                }
            //Commented for multiple individual id change - Nupoor
            /*if(!lstIndividuals.isEmpty()){
                String conName = lstIndividuals[0] != null ? (lstIndividuals[0].FirstName +' '+lstIndividuals[0].LastName) :
                individualContact != null ? individualContact.Name : '';
                resultMap.put('contactName', conName);              
            } */
            resultMap.put('contactName', resultMap.mapResponse.get('contactName') != null ? resultMap.mapResponse.get('contactName') : (individualContact != null ? individualContact.Name : null ));
            
            if(conToBeUpdated != null && String.isNotBlank(conToBeUpdated.Id)){
                ESAPI.accessController().updateAsUser(conToBeUpdated, SSP_Utility.getFieldsNamesObject (conToBeUpdated)); 
            }
	    
            /** 2.5	Security Role Matrix and Program Access. */
            resultMap.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.INDIVIDUAL_DASHBOARD_SCREENID, null));
            /** */

            resultMap.put('isReadOnlyUser', SSP_Utility.isReadOnlyUser()); //#379955
            resultMap.put('selectedRole', SSP_Utility.getSelectedRole()); //#379955
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'triggerDashboardServiceCallOut', 'Failed to fetch Dashboard Data', true);  
            
        }
        return resultMap;
    }

    //Method to remove item from list
    @testVisible
    private static List<String> removeFromList(List<String> pList, String elementToRemove){
        List<String> updatedList = pList;
        if(pList != null && !pList.isEmpty() && String.isNotBlank(elementToRemove)){
            Set<String> tmpSet = new Set<String>();
            tmpSet.addAll(pList);
            if(tmpSet != null && tmpSet.contains(elementToRemove)){
                tmpSet.remove(elementToRemove);
            }
            updatedList = new List<String>();
            updatedList.addAll(tmpSet);
        }
        return updatedList;
    }
    
    /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         03/05/2020
    * @methodname   triggerMedicaidMCOServiceCall
    * @description  This methods is used to get Dasboard Medicaid data from Interface
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse triggerMedicaidMCOServiceCall(String individualId, Boolean bIsShoppingDataUpdated){ 
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse resultMap = new SSP_LightningResponse();                
        List<SSP_IndividualInfoWrapper> lstIndividualData = new List<SSP_IndividualInfoWrapper>();
        List<Map<String,String>> lstEnrolledMedicaids = new List<Map<String,String>>();
        List<String> lstNonEnrolledMedicaids = new List<String>();
        Set<String> lstEnrolledIndividualIds = new Set<String>();
        Set<String> lstNonEnrolledIndividualIds = new Set<String>();
        List<Object> serviceResponses =  new List<Object>();
        Map<String,List<SSP_MedicaidMCOWrapper>> mapCaseVsEnrolledPrograms = new  Map<String,List<SSP_MedicaidMCOWrapper>>();
        Map<String,List<SSP_MedicaidMCOWrapper>> mapCaseVsNonEnrolledPrograms = new  Map<String,List<SSP_MedicaidMCOWrapper>>(); 
        Map<String, Object> mapParamsMedicaid = new Map<String, Object>();
        Map<String, Boolean> mapCaseVsHOH = new Map<String, Boolean>();
        RSSP_DC_Wrapper response = new RSSP_DC_Wrapper();
        //Addendum 6.2 changes
        Map<string,List<String>> mapEnrolledMedcaids = new Map<string,List<String>>();
        Map<String,String> indToEnrolledPlanMap = new Map<string,string>();
        string currentUserIndividualIds;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        Integer caseCount = 0;
        try{     
            currentUserIndividualIds = ssp_utility.getCurrentUserAllIndividualIds();
            individualId = (individualId == null) ? SSP_Utility.getIndividualId() : individualId; //WIP
            
            //List<User> userData = SSP_Utility.getCurrentUserDetails();  
            Contact individualContact = SSP_DashboardService.getIndividualContact(individualId); //WIP
            Boolean isRefreshRequired = (individualContact != null && individualContact.IsDashboardRefreshNeeded__c) ? individualContact.IsDashboardRefreshNeeded__c : 
            !(sessionPart.get('EnrolledMedicaidPrograms') != null || sessionPart.get ('NonEnrolledMedicaidPrograms') != null);
            
            if(individualContact != null && individualContact.IndividualId__c != null && (isRefreshRequired || bIsShoppingDataUpdated) ){
                if(sessionPart.get('caseVsHOH') != null){
                    mapCaseVsHOH = (Map<String, Boolean>)JSON.deserialize(String.valueOf(sessionPart.get('caseVsHOH')),Map<String, Boolean>.class);                
                }
                SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName = SSP_InterfaceConstants.MEDICAID_MCO_INFORMATION;  
                //Commented for multiple individual id - Nupoor
                //reqWrapper.primaryApplicationIndividualId = Integer.valueOf(individualId); //WIP
                reqWrapper.primaryApplicationIndividualId = SSP_utility.getCurrentUserAllIndividualIds();
                mapParamsMedicaid.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                mapParamsMedicaid.put(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD,true); //PERF Fix 
                serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParamsMedicaid);
                if(serviceResponses != null && !serviceResponses.isEmpty()){ 
                    response = (RSSP_DC_Wrapper) serviceResponses.get(0);
                }

                if(response != null && response.medicaidMCOInformation != null && response.medicaidMCOInformation.Individual != null){                    
                    lstIndividualData  =response.medicaidMCOInformation.Individual;
                }
                //Addendum 6.2 changes
                if(response != null && response.medicaidMCOInformation != null && response.medicaidMCOInformation.MedicaidMCO != null){                    
                    for( SSP_MedicaidMCOWrapper rec: response.medicaidMCOInformation.MedicaidMCO){
            		indToEnrolledPlanMap.put(rec.IndividualId,rec.PlanName);                    
		    }
                }
                //Addendum 6.2 changes - changes for lstEnrolledMedicaids
                for(SSP_IndividualInfoWrapper objIndividual : lstIndividualData){ 
                    Boolean isHeadOfHousehold = false;
                    if(mapCaseVsHOH.get(objIndividual.CaseNumber) != null &&  mapCaseVsHOH.get(objIndividual.CaseNumber)){
                        isHeadOfHousehold = mapCaseVsHOH.get(objIndividual.CaseNumber);
                    }
                    if(isHeadOfHousehold && (objIndividual.IsEnrolledInPlan == SSP_GlobalConstants.YES)){
                        String curPlan = indToEnrolledPlanMap.get(objIndividual.IndividualId);
                        if(curPlan != null && mapEnrolledMedcaids.get(curPlan)!=null){
                            (mapEnrolledMedcaids.get(curPlan)).add(objIndividual.IndividualName);
                        }
                        else if(curPlan != null){
                            mapEnrolledMedcaids.put(curPlan,new List<String>{objIndividual.IndividualName});
                        }
                        lstEnrolledIndividualIds.add(objIndividual.IndividualId);
                    }else if(isHeadOfHousehold && (objIndividual.IsEnrolledInPlan == SSP_GlobalConstants.NO) && !lstEnrolledIndividualIds.contains(objIndividual.IndividualId)){
                       
                        lstNonEnrolledIndividualIds.add(objIndividual.IndividualId+','+objIndividual.IndividualName);
                    }
                    if((!isHeadOfHousehold) && (objIndividual.IsEnrolledInPlan == SSP_GlobalConstants.YES) && (currentUserIndividualIds != null && currentUserIndividualIds != '' && currentUserIndividualIds.contains(objIndividual.individualId))){ //WIP
                        //lstEnrolledMedicaids.add(objIndividual.IndividualName);
                        String curPlan = indToEnrolledPlanMap.get(objIndividual.IndividualId);
                        if(curPlan != null && mapEnrolledMedcaids.get(curPlan)!=null){
                            (mapEnrolledMedcaids.get(curPlan)).add(objIndividual.IndividualName);
                        }
                        else if(curPlan != null){
                            mapEnrolledMedcaids.put(curPlan,new List<String>{objIndividual.IndividualName});
                        }
                        lstEnrolledIndividualIds.add(objIndividual.IndividualId);
                    }
                    else if((!isHeadOfHousehold) && (objIndividual.IsEnrolledInPlan == SSP_GlobalConstants.NO) && (currentUserIndividualIds != null && currentUserIndividualIds != '' && currentUserIndividualIds.contains(objIndividual.individualId)) && 
                            !lstEnrolledIndividualIds.contains(objIndividual.IndividualId)){ //WIP

                        lstNonEnrolledIndividualIds.add(objIndividual.IndividualId+','+objIndividual.IndividualName);
                    }
                }    
                for(String planName : mapEnrolledMedcaids.keyset()){                    
                    lstEnrolledMedicaids.add(new map<String,String>{'planName'=>planName,'members'=>' ( '+string.join(mapEnrolledMedcaids.get(planName),', ')+' ) '});
                }                
                for(String indivId : lstNonEnrolledIndividualIds){
                    if(lstEnrolledIndividualIds!=null && !lstEnrolledIndividualIds.contains(indivId.split(',')[0])){
                        lstNonEnrolledMedicaids.add(indivId.split(',')[1]);
                    }
                }
                resultMap.put('EnrolledMedicaidPrograms',JSON.serialize(lstEnrolledMedicaids));
                sessionPart.put('EnrolledMedicaidPrograms',JSON.serialize(lstEnrolledMedicaids),3600,Cache.Visibility.ALL,false);
                resultMap.put('NonEnrolledMedicaidPrograms',JSON.serialize(lstNonEnrolledMedicaids));
                sessionPart.put('NonEnrolledMedicaidPrograms',JSON.serialize(lstNonEnrolledMedicaids),3600,Cache.Visibility.ALL,false);
                if(individualContact.IsDashboardRefreshNeeded__c){
                    //Perf Fix
                    Contact contToUpdate = new contact(Id = individualContact.Id, IsDashboardRefreshNeeded__c=false);
                    SSP_GenericDMLHelper.updateRecords(new List<Contact>{contToUpdate},  new List<String>{'IsDashboardRefreshNeeded__c'});
                    //ESAPI.accessController().updateAsUser(new contact(Id = individualContact.Id, IsDashboardRefreshNeeded__c=false), SSP_Utility.getFieldsNamesObject (new contact(id=individualContact.Id, IsDashboardRefreshNeeded__c=false))); //WIP
                }
            }
            else {                
                if(sessionpart.get('EnrolledMedicaidPrograms') != null){                   
                    resultMap.put('EnrolledMedicaidPrograms',sessionPart.get('EnrolledMedicaidPrograms'));                    
                } 
                if(sessionpart.get('NonEnrolledMedicaidPrograms') != null){
                    resultMap.put('NonEnrolledMedicaidPrograms',sessionPart.get('NonEnrolledMedicaidPrograms'));
                }
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'triggerMedicaidMCOServiceCall', 'Failed to fetch Dashboard Medicaid Data', true);  
            
        }
        return resultMap;
    }

    /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         03/05/2020
    * @methodname   triggerBenefitsServiceCall
    * @description  This methods is used to get Dasboard Benefits data from Interface
    * @return       SSP_LightningResponse
    *****************************************************************************************************/    
    @auraEnabled
    public static SSP_LightningResponse triggerBenefitsServiceCall(String individualId, Boolean isRefreshRequired){ 
        SSP_Utility.isAuthenticatedUser();
        Boolean hasBenefits = false; 
        Boolean hasKhipp = false; 
        Boolean hasMedicaid = false;
        Boolean onlyDependent = true;
        Integer onlyDependentCount = 0;
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
        Set<String> setCaseNumbers = new Set<String>();       
        List<Object> serviceResponses =  new List<Object>();
        List<String> lstActiveCases = new List<String>();
        List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper> medicaidEBTData= new List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper>();
        List<SSP_BenefitInformationWrapper> benefitData = new  List<SSP_BenefitInformationWrapper>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsActiveBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsPendingInterviewBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsPendingVerificationBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsAllBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String, Object> mapParamsBenefit = new Map<String, Object>(); 
        Map<String,String> mapCaseVsbenefitStatus = new  Map<String,String>();  
        Map<String, Boolean> mapCaseVsHOH = new Map<String, Boolean>();
        String currentUserIndividualIds;
        Boolean isPolicyHolder = false;
        String KIHIPPFlag;
        try{
            currentUserIndividualIds = ssp_utility.getCurrentUserAllIndividualIds();
            individualId = (individualId == null) ? SSP_Utility.getIndividualId() : individualId; //WIP 
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);                        
            Contact individualContact = SSP_DashboardService.getIndividualContact(individualId);
            isRefreshRequired = (individualContact != null && individualContact.IsDashboardRefreshNeeded__c) ? individualContact.IsDashboardRefreshNeeded__c :  !(sessionPart.get('hasBenefits') != null);            
            if(String.isNotBlank(individualId) && isRefreshRequired){    
                if(sessionPart.get('caseVsHOH') != null){
                    mapCaseVsHOH = (Map<String, Boolean>)JSON.deserialize(String.valueOf(sessionPart.get('caseVsHOH')),Map<String, Boolean>.class);                
                }
                SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName =SSP_InterfaceConstants.BENEFIT_INFORMATION;
                //Commented for multiple individual id - Nupoor
                //reqWrapper.primaryApplicationIndividualId = Integer.valueOf(individualId);    
                reqWrapper.primaryApplicationIndividualId = SSP_Utility.getCurrentUserAllIndividualIds();         
                mapParamsBenefit.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                mapParamsBenefit.put(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD,true); //PERF Fix  
                serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParamsBenefit);                
                if(serviceResponses != null && !serviceResponses.isEmpty()){
                    RSSP_DC_Wrapper wrapperResponse =  (RSSP_DC_Wrapper) serviceResponses[0];                    
                    
                     if(wrapperResponse != null && wrapperResponse.benefitInformations != null && wrapperResponse.benefitInformations.Benefit != null)
                     {
                         benefitData  = wrapperResponse.benefitInformations.Benefit;
                        Contact con = new Contact(Id = individualContact.Id, CacheBenefitProgramData__c = JSON.serialize(benefitData));
                         if(wrapperResponse != null && wrapperResponse.benefitInformations != null && wrapperResponse.benefitInformations.MedicardEBT != null){
                         medicaidEBTData  = wrapperResponse.benefitInformations.MedicardEBT;
                       con.CacheBenefitMedicaidEBTData__c=JSON.serialize(medicaidEBTData);
                        
                       resultMap.put('medicaidEBTData', JSON.serialize(medicaidEBTData));
                     }                      
                                                 //WIP
                        SSP_GenericDMLHelper.updateRecords(new List<Contact>{con},  new List<String>{'CacheBenefitProgramData__c', 'CacheBenefitMedicaidEBTData__c'}); //Perf Fix
                        //ESAPI.accessController().updateAsUser(con, SSP_Utility.getFieldsNamesList(new List<Contact>{con})); //ForceReviewer Fix
                        resultMap.put('benefitsData', JSON.serialize(benefitData)); //#371950
                         
                     } 
                }
                for(SSP_BenefitInformationWrapper objBenefit : benefitData){
                    setCaseNumbers.add(objBenefit.CaseNumber);
                }
                for(String strCaseNumber: setCaseNumbers){
                    Boolean isHeadOfHousehold = false;
                    if(mapCaseVsHOH.get(strCaseNumber) != null &&  mapCaseVsHOH.get(strCaseNumber)){
                        isHeadOfHousehold = mapCaseVsHOH.get(strCaseNumber);
                    }
                    
                    List<SSP_BenefitInformationWrapper> lstActiveBenefits = new List<SSP_BenefitInformationWrapper>();
                    List<SSP_BenefitInformationWrapper> lstPendingInterviewBenefits = new List<SSP_BenefitInformationWrapper>();
                    List<SSP_BenefitInformationWrapper> lstPendingVerificationBenefits = new List<SSP_BenefitInformationWrapper>();
                    List<SSP_BenefitInformationWrapper> lstAllActiveBenefits = new List<SSP_BenefitInformationWrapper>();
                    List<SSP_BenefitInformationWrapper> lstAllPendingInterviewBenefits = new List<SSP_BenefitInformationWrapper>();
                    List<SSP_BenefitInformationWrapper> lstAllPendingVerificationBenefits = new List<SSP_BenefitInformationWrapper>();
                    List<SSP_BenefitInformationWrapper> lstAllBenefits = new List<SSP_BenefitInformationWrapper>();
                    
                    
                    Map<String,List<SSP_BenefitInformationWrapper>> mapStatusVsBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
                    for(SSP_BenefitInformationWrapper objBenefit : benefitData){  
                        if(objBenefit.CaseNumber == strCaseNumber){
                            lstAllBenefits.add(objBenefit);
                        }
                        if(objBenefit.ProgramCode == SSP_GlobalConstants.KTAP){
                            objBenefit.ProgramCode = system.label.SSP_KTAP;
                        }else if(objBenefit.ProgramCode == SSP_GlobalConstants.MEDICAID){
                            objBenefit.ProgramCode =system.label.SSP_Medicaid;
                        }
                        else if(objBenefit.ProgramCode == SSP_GlobalConstants.KC_Code){
                            objBenefit.ProgramCode = system.label.sspKinshipCare;
                        }
                        else if(objBenefit.ProgramCode == SSP_GlobalConstants.CHILDCARE){
                            objBenefit.ProgramCode = system.label.SSP_ChildCareAssistance;
                        } 
                        else if(objBenefit.ProgramCode == SSP_GlobalConstants.STATE){
                            objBenefit.ProgramCode = system.label.SSP_StateSupplementation;
                        } 
                        else if(objBenefit.ProgramCode ==SSP_GlobalConstants.KHIPP){  
                            objBenefit.ProgramCode = system.label.SSP_KIHIPP;
                            //check if logged in user is policy holder
                            if(objBenefit.PolicyHolderId != null && objBenefit.PolicyHolderId.equalsIgnoreCase(individualId)){
                                isPolicyHolder= true;                
                            }
                            
                        }else if (objBenefit.ProgramCode ==SSP_GlobalConstants.SNAP){
                            objBenefit.ProgramCode = system.label.SSP_SNAP;
                        }
                        if(isHeadOfHousehold && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber){
                            lstActiveBenefits.add(objBenefit);                                
                        }else if(isHeadOfHousehold && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION && objBenefit.CaseNumber == strCaseNumber){
                            lstPendingVerificationBenefits.add(objBenefit);
                        }else if(isHeadOfHousehold && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW && objBenefit.CaseNumber == strCaseNumber){
                            lstPendingInterviewBenefits.add(objBenefit);
                        }
                        if(((!isHeadOfHousehold) && (currentUserIndividualIds != null && currentUserIndividualIds != '' && currentUserIndividualIds.contains(objBenefit.IndividualId)) && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber) ||
                         ((!isHeadOfHousehold) && (currentUserIndividualIds != null && currentUserIndividualIds != '' && currentUserIndividualIds.contains(objBenefit.IndividualId)) && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber && isPolicyHolder
                         && objBenefit.ProgramCode == system.label.SSP_KIHIPP)){
                            lstActiveBenefits.add(objBenefit);
                        }else if((!isHeadOfHousehold) && (currentUserIndividualIds != null && currentUserIndividualIds != '' && currentUserIndividualIds.contains(objBenefit.IndividualId)) && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION && objBenefit.CaseNumber == strCaseNumber){
                            lstPendingVerificationBenefits.add(objBenefit);
                        }else if((!isHeadOfHousehold) && (currentUserIndividualIds != null && currentUserIndividualIds != '' && currentUserIndividualIds.contains(objBenefit.IndividualId)) && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW && objBenefit.CaseNumber == strCaseNumber){
                            lstPendingInterviewBenefits.add(objBenefit);
                        }
                        if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber){
                            lstAllActiveBenefits.add(objBenefit);
                        }else if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION && objBenefit.CaseNumber == strCaseNumber){
                            lstAllPendingVerificationBenefits.add(objBenefit);
                        }else if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW && objBenefit.CaseNumber == strCaseNumber){
                            lstAllPendingInterviewBenefits.add(objBenefit);
                        }
                        
                        
                        if((objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW || objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION ||
                            objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED) && objBenefit.ProgramCode ==SSP_GlobalConstants.KP_Label  && objBenefit.CaseNumber == strCaseNumber && (!hasKhipp)){
                                hasKhipp = true;
                                
                        }
                        //Condition modified as part of defect 388829, by Sai Kiran (08/27)
                        if(objBenefit.ProgramCode ==system.label.SSP_Medicaid  && objBenefit.CaseNumber == strCaseNumber && (!hasMedicaid)){
                                hasMedicaid = true;
                        }
                        if(objBenefit.CaseNumber == strCaseNumber){
                            if(!isHeadOfHousehold && onlyDependent){
                                onlyDependent = true;
                                onlyDependentCount = onlyDependentCount + 1;
                            }
                            else if (((objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW || 
                                      objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION ||
                                      objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED) && 
                                      objBenefit.ProgramCode ==SSP_GlobalConstants.KP_Label  && 
                                      objBenefit.CaseNumber == strCaseNumber) && onlyDependent && isHeadOfHousehold){
                                    onlyDependent = true;
                                }
                            else{
                                onlyDependent = false;
                            }
                        }
                    }
                    if(hasKhipp){
                        resultMap.put('hasKihippProgram',true);
                        sessionPart.put('hasKihippProgram',true,3600,Cache.Visibility.ALL,false);
                    }
                    if(hasMedicaid){
                        resultMap.put('hasMedicaidProgram',true);
                        sessionPart.put('hasMedicaidProgram',true,3600,Cache.Visibility.ALL,false);
                    }
                    //condition for showing KIHIPP Summary on dashboard> I want to section. If Hoh then show for active KIHIPP prg, if non Hoh then show if policy holder
                    if(isHeadOfHousehold && hasKhipp){
                        
                        resultMap.put('showKIHIPPSummary',true);
                        sessionPart.put('showKIHIPPSummary','true',3600,Cache.Visibility.ALL,false);
                        KIHIPPFlag = 'true';
                    }else if(!isHeadOfHousehold && isPolicyHolder) {
                        
                        resultMap.put('showKIHIPPSummary',true);
                        sessionPart.put('showKIHIPPSummary','true',3600,Cache.Visibility.ALL,false);
                        KIHIPPFlag = 'true';
                    }else{
                        resultMap.put('showKIHIPPSummary',false);
                        sessionPart.put('showKIHIPPSummary','false',3600,Cache.Visibility.ALL,false);
                        KIHIPPFlag = 'false';
                    }
                    resultMap.put('individualId',individualId);
                    sessionPart.put('individualId',individualId,3600,Cache.Visibility.ALL,false);

                    if(!lstActiveBenefits.isEmpty()){                    
                        mapCaseVsActiveBenefits.put(strCaseNumber,lstActiveBenefits);  
                    }
                    if(!lstPendingInterviewBenefits.isEmpty()){    
                        mapCaseVsPendingInterviewBenefits.put(strCaseNumber,lstPendingInterviewBenefits);
                    }
                    if(!lstPendingVerificationBenefits.isEmpty()){    
                        mapCaseVsPendingVerificationBenefits.put(strCaseNumber,lstPendingVerificationBenefits);
                    }
                    if(!lstAllBenefits.isEmpty()){
                        mapCaseVsAllBenefits.put(strCaseNumber,lstAllBenefits);
                    }
                    if((!lstAllActiveBenefits.isEmpty()) && lstAllPendingInterviewBenefits.isEmpty() && lstAllPendingVerificationBenefits.isEmpty()){ 
                        if(isHeadOfHousehold){
                            lstActiveCases.add(strCaseNumber);
                        }
                        mapCaseVsbenefitStatus.put(strCaseNumber,system.label.SSP_Active);
                        
                    }else if(!(lstAllPendingInterviewBenefits.isEmpty() && lstAllPendingVerificationBenefits.isEmpty())){
                        mapCaseVsbenefitStatus.put(strCaseNumber,system.label.SSP_Pending); 
                    }else if(lstAllActiveBenefits.isEmpty() && lstAllPendingInterviewBenefits.isEmpty() && lstAllPendingVerificationBenefits.isEmpty()){ 
                        mapCaseVsbenefitStatus.put(strCaseNumber,system.label.SSP_Inactive);
                    }                  
                }               
                if(onlyDependent && onlyDependentCount > 0){
                    resultMap.put('onlyKihippHoh',true);
                    sessionPart.put('onlyKihippHoh',true,3600,Cache.Visibility.ALL,false);
                }
                if(!mapCaseVsAllBenefits.isEmpty()){ 
                    resultMap.put('AllBenefits',JSON.serialize(mapCaseVsAllBenefits));
                    sessionPart.put('AllBenefits',JSON.serialize(mapCaseVsAllBenefits),3600,Cache.Visibility.ALL,false);
                }
                if(!mapCaseVsActiveBenefits.isEmpty()){ 
                    resultMap.put('ActiveBenefits',JSON.serialize(mapCaseVsActiveBenefits));
                    sessionPart.put('ActiveBenefits',JSON.serialize(mapCaseVsActiveBenefits),3600,Cache.Visibility.ALL,false);
                }
                if(!mapCaseVsPendingInterviewBenefits.isEmpty()){ 
                    resultMap.put('PendingInterviewBenefits',JSON.serialize(mapCaseVsPendingInterviewBenefits));
                    sessionPart.put('PendingInterviewBenefits',JSON.serialize(mapCaseVsPendingInterviewBenefits),3600,Cache.Visibility.ALL,false);
                }
                if(!mapCaseVsPendingVerificationBenefits.isEmpty()){ 
                    resultMap.put('PendingVerificationBenefits',JSON.serialize(mapCaseVsPendingVerificationBenefits));
                    sessionPart.put('PendingVerificationBenefits',JSON.serialize(mapCaseVsPendingVerificationBenefits),3600,Cache.Visibility.ALL,false);
                }
                
                sessionPart.put('hasBenefits',hasBenefits,3600,Cache.Visibility.ALL,false);

                //update KIHIPP payment cache data at contact level for cachebuilder implementation
                Contact con = new Contact(Id = individualContact.Id, CacheKIHIPPSummary__c = KIHIPPFlag);
                SSP_GenericDMLHelper.updateRecords(new List<Contact>{con},  new List<String>{'CacheKIHIPPSummary__c'}); //Perf Fix
                //ESAPI.accessController().updateAsUser(con, SSP_Utility.getFieldsNamesList(new List<Contact>{con}));
            }else {
                resultMap.put('fetch from session',true);
                if(sessionpart.get('ActiveBenefits') != null){                       
                    resultMap.put('ActiveBenefits',sessionPart.get('ActiveBenefits'));
                    
                    
                } 
                if(sessionpart.get('PendingInterviewBenefits') != null){
                    resultMap.put('PendingInterviewBenefits',sessionPart.get('PendingInterviewBenefits'));
                }
                if(sessionpart.get('PendingVerificationBenefits') != null){
                    resultMap.put('PendingVerificationBenefits',sessionPart.get('PendingVerificationBenefits'));
                }
                
                if(sessionpart.get('hasKihippProgram') != null){
                    resultMap.put('hasKihippProgram',sessionPart.get('hasKihippProgram'));
                }
                if(sessionpart.get('hasMedicaidProgram') != null){
                    resultMap.put('hasMedicaidProgram',sessionPart.get('hasMedicaidProgram'));
                }
				if(sessionpart.get('onlyKihippHoh') != null){
                    resultMap.put('onlyKihippHoh',sessionPart.get('onlyKihippHoh'));
                }
                string varshowKIHIPPSummary = 'showKIHIPPSummary';
                String res = sessionpart.get('showKIHIPPSummary') != null ? String.valueOf(sessionPart.get('showKIHIPPSummary')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,varshowKIHIPPSummary));
                
                if(res == 'false'){
                    resultMap.put('showKIHIPPSummary',false);
                }else{
                    resultMap.put('showKIHIPPSummary',true);
                }
               
                 
                
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'triggerBenefitsServiceCall', 'Failed to fetch Dashboard Benefits Data', true);  
            
        }
        return resultMap;
    }
        
    @AuraEnabled(cacheable = true)
    public static SSP_LightningResponse checkHasExistingApplication(){
        Boolean isHeadOfHouseHold = false;
        Boolean enableRAC = false;
        Boolean enableRenewal = false;
        
        SSP_DashboardCaseInformation dashboardInfo =  new SSP_DashboardCaseInformation();
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
        
        List<SSP_ApplicationIndividual__c> lstAppIndividual = new List<SSP_ApplicationIndividual__c>();
        List<SSP_IndividualInfoWrapper> lstIndividualData = new List<SSP_IndividualInfoWrapper>();
        
        List<AboutToExpireWrapper> lstUnsubmittedApplication = new List<AboutToExpireWrapper>();
        
        
        
        
        try{    
            String individualId = SSP_Utility.getIndividualId();
            
            Contact individualContact = SSP_DashboardService.getIndividualContact(individualId);
            if(individualContact != null){                
                resultMap.put('contactName', individualContact.Name);                
                Id memberId =  SSP_DashboardService.getMemberId(individualContact.Id);
                if(memberId != null){
                    lstAppIndividual =SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                                                        new Set<String>{'Id','IsHeadOfHousehold__c','SSP_Application__c','SSP_Application__r.ApplicationReceivedDateTime__c','createdDate','SSP_Application__r.ApplicationCreationInSSP__c','toLabel(SSP_Application__r.ProgramsApplied__c)'}, 
                                                                                                        new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> memberId,'SSP_Application__r.Status__c'=>'UN','SSP_Application__r.RecordType.DeveloperName'=>'SSP_Application'});
                }
                for(SSP_ApplicationIndividual__c objAppIndividual :lstAppIndividual){ 
                    if(objAppIndividual.IsHeadOfHousehold__c){
                        isHeadOfHouseHold = true;
                    }
                    AboutToExpireWrapper objExpire = new AboutToExpireWrapper();
                        
                    objExpire.applicationId =objAppIndividual.SSP_Application__c ;                
                        
                    if(objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null && (8 - (objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(SSP_utility.today())) == 0)){
                        objExpire.daysRemaining =system.label.sspToday;
                        objExpire.isToday = true;
                        objExpire.expiryDate = system.label.sspToday;
                    }else if(objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null){
                        objExpire.daysRemaining = String.ValueOf(8 -(objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(ssp_utility.today())));
                        Date  objDate = objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.addDays(8);
                        objExpire.expiryDate =objDate.month() + '/'+objDate.day()+'/'+objDate.year(); 
                        objExpire.isToday = false;
                    }
                        
                    if(objAppIndividual.IsHeadOfHousehold__c && objExpire.daysRemaining != null && objExpire.daysRemaining != system.label.sspToday &&Integer.valueOf(objExpire.daysRemaining) <= 8 && Integer.valueOf(objExpire.daysRemaining) > 0){
                        lstUnsubmittedApplication.add(objExpire);
                    }else if(objAppIndividual.IsHeadOfHousehold__c && objExpire.daysRemaining == system.label.sspToday){
                        lstUnsubmittedApplication.add(objExpire);
                    }   
                }    
                if(!lstUnsubmittedApplication.isEmpty()){
                    resultMap.put('hasExpiringApplications',JSON.serialize(lstUnsubmittedApplication));    
                }
                if(!lstUnsubmittedApplication.isEmpty()){
                    resultMap.put('hasExpiringApplicationsForSelection',lstUnsubmittedApplication);
                    
                }
                
                resultMap.put('isHeadOfHouseHold',isHeadOfHouseHold);  
            }
            resultMap.put('availableProgramsSet',SSP_Utility.getAvailableProgramsByRole());  //Shrikant - added as a part of CD2 implementation - 6.1
            resultMap.put('userDetails',SSP_Utility.getUserDetails(UserInfo.getUserId()));  //Shrikant - added as a part of CD2 implementation - Multiple Roles - 4.1.2
        }  catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'triggerBenefitsServiceCall', 'Failed to fetch Dashboard Benefits Data', true);              
        }
        return resultMap;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse invokeRAC(Id sspApplicationId){
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<User> userData = SSP_Utility.getCurrentUserDetails();
        Map<String, Object> mapParams = new Map<String, Object>();
        String screenNames;
        RACSelectionWrapper detailWrapper;
        try{ 
            if(sspApplicationId != null){
                
                List<SSP_Application__c> sspAppList = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                                   new Set<String>{'Id','RAC_Selections__c','DCCaseNumber__c','ProgramsApplied__c'}, 
                                                                                                   new Map<String, String>{'limit'=>'1000','id'=> sspApplicationId, 'RecordTypeId'=>SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case')});
                if(sspAppList != null && !sspAppList.isEmpty()){
                    SSP_Application__c sspApp = sspAppList[0];
                    detailWrapper = (RACSelectionWrapper)JSON.deserialize(sspApp.RAC_Selections__c, RACSelectionWrapper.class);
                    
                    SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                    reqWrapper.viewName = SSP_InterfaceConstants.ALL_VIEWS;
                    reqWrapper.mode = SSP_InterfaceConstants.MODE_RAC;
                    reqWrapper.caseNumber = Integer.valueOf(sspApp.DCCaseNumber__c);
                    //Commented for making multiple individual id changes - Nupoor
                    //reqWrapper.primaryApplicationIndividualId = Integer.valueOf(userData[0].Contact.IndividualId__c);
                    reqWrapper.primaryApplicationIndividualId = SSP_Utility.getCurrentUserAllIndividualIds();
                    reqWrapper.programCode = sspApp.ProgramsApplied__c;
                    reqWrapper.applicationID = sspApp.Id;
                    mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                    mapParams.put(SSP_InterfaceConstants.SSP_SCREEN_NAMES,String.join(new List<String>(fetchScreenNames(detailWrapper)),';'));
                    response.put('request', JSON.serialize(mapParams));    
                    String callOutResponse = JSON.serialize(IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams));                 
                    response.put('response', callOutResponse);
                }
                else{
                    response.put('ERROR', ' No Application of type CASE found with given Application Id.');
                }
            }
        }
        catch(Exception ex){
            String req = '//Msg - '+ex.getMessage() +'  //Request - '+ JSON.serialize(mapParams); 
            response.put('ERROR', ex.getStackTraceString() + '  ' +req);
        }
        return response;
    }
    
    private static Set<String> fetchScreenNames(RACSelectionWrapper wrapper){  
        Set<String> screenNames = new Set<String>();
        if(wrapper != null){
            for(ScreenDetailWrapper screenDetails : wrapper.selectedScreens){
                if(screenDetails.screens != null){
                    List<String> screens = (screenDetails.screens).split(',');
                    screenNames.addAll(screens);
                }                
            }
        }
        return screenNames;
    }
    
    public class RACSelectionWrapper{        
        String memberId;
        List<ScreenDetailWrapper> selectedScreens;
    }
    
    public class ScreenDetailWrapper{
        String flowName;
        String screens;
    }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         03/06/2020
* @className   AboutToExpireWrapper
* @description  This is Wrapper class is used for notifications.
*****************************************************************************************************/
    public class AboutToExpireWrapper {       
        public String applicationId;
        public String daysRemaining;
        public String expiryDate;
        public Boolean isToday;
        public String programsApplied;
        
    }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         03/06/2020
* @className   AboutToExpireWrapper
* @description  This is Wrapper class is used for notifications.
*****************************************************************************************************/
    public class NotificationWrapper { 
        public String caseInfoNumber;
        public Boolean hasSnapAmount;
        public String SnapAmount;
        public String RFICount;
        public Boolean hasRFI;
        
    }
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         04/14/2020
* @methodname   fetchRequiredData
* @description  This methods is used to fetch required details for sspFirstTimeUserDashboard cmp - CD2 6.1 to show SS block
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse fetchRequiredData(){
        SSP_LightningResponse response = new SSP_LightningResponse();       
        try {
            response.put(SSP_GlobalConstants.USER_DETAILS,SSP_Utility.getUserDetails(UserInfo.getUserId()));
            response.put(SSP_GlobalConstants.KEY_ACCESSIBLE_PROGRAMS,SSP_Utility.getAvailableProgramsByRole());
            response.bIsSuccess = true;
            
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'fetchRequiredData', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);            
        }
        return response;
    }
    
    /***************************************************************************************************
* @author       Sai Kiran
* @date         04/30/2020
* @methodname   resumeApplication
* @description  This methods is used to fetch data from RSSPDC & resume the Application with updated Data.
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse resumeApplication(String sApplicationId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        try {

            lstAppInd = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                         new Set<String>{'Id','SSP_Member__c','SSP_Application__c','SSP_Member__r.IndividualId__c','SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c','SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c', 'SSP_Member__r.Contact__r.IndividualId__c','SSP_Application__r.Application_Changed_By__c', 'SSP_Application__r.Application_Change_Start_Timestamp__c','SSP_Application__r.ProgramsApplied__c'}, 
                                                                                         new Map<String, String>{'limit'=>'1','SSP_Application__c'=> sApplicationId,'IsHeadOfHousehold__c' =>'#true#'});
            if(!SSP_Utility.isReadOnlyUser()){ //#379955                                                                                               
                if(lstAppInd[0].SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c && lstAppInd[0].SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c){
                    reqWrapper.viewName = 'All_Views';
                    //reqWrapper.primaryApplicationIndividualId = lstAppInd[0].SSP_Member__r.IndividualId__c != null ? String.valueOf(lstAppInd[0].SSP_Member__r.IndividualId__c) : String.valueOf(lstAppInd[0].SSP_Member__r.Contact__r.IndividualId__c);
                    reqWrapper.primaryApplicationIndividualId = lstAppInd[0].SSP_Member__r.Contact__r.IndividualId__c;
                    //reqWrapper.programCode = 'MA';
                    reqWrapper.mode = SSP_InterfaceConstants.MODE_INTAKE;
                    reqWrapper.applicationID = String.escapeSingleQuotes(sApplicationId);
                    mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                    List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                    RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper)objList.get(0);
                    if(responseWrapper.ACKRESPONSE != NULL && responseWrapper.ACKRESPONSE.AckResponseCode != NULL){
                        objResponse.put('bIsSuccess', false);
                        objResponse.put('error', responseWrapper.ACKRESPONSE.AckResponseCode);                              
                    }else{
                        objResponse.put('bIsSuccess', true); 
                        List<String> applicationFields = new List<String>{'Id', 'SectionStatus__c'};
                        SSP_SharingBypassFetcher.deleteRecords(sApplicationId);
                        List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                            SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                        new Set<String>{'Id', 'isHOHDetailsCompleted__c', 'SSP_Application__c'}, 
                                                                                        new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(sApplicationId)});
                        for(SSP_ApplicationIndividual__c appInd : sspApplicationIndividualList){
                            appInd.isHOHDetailsCompleted__c = false;
                        }
                        SSP_Application__c applicationRecord = SSP_ApplicationSelector.queryApplicationDataById(sApplicationId, applicationFields);
                        Map<String, Object> originalStatus = (Map<String, Object>)JSON.deserializeUntyped(applicationRecord.SectionStatus__c);
                        String appMode = SSP_GlobalConstants.SSP_INTAKE_FLOW;
                        Map<String, String> defaultStatus = new Map<String, String>{'SSP_APP_ProgramSelection' => 'COMPLETED'};
                        originalStatus.put(appMode, defaultStatus);
                        applicationRecord.SectionStatus__c = JSON.serialize(originalStatus);
                        if(sspApplicationIndividualList != null){
                            //Perf Fix
                            SSP_GenericDMLHelper.updateRecords(sspApplicationIndividualList,  new List<String>{'isHOHDetailsCompleted__c'});
                            //ESAPI.accessController().updateAsUser(new Map<ID,SSP_ApplicationIndividual__c>(sspApplicationIndividualList), new List<String>{'isHOHDetailsCompleted__c'});                        
                        }
                        //Perf Fix
                        SSP_GenericDMLHelper.updateRecords(new List<SSP_Application__c>{applicationRecord},  new List<String>{'SectionStatus__c'});
                        //ESAPI.accessController().updateAsUser(applicationRecord, new List<String>{'SectionStatus__c'});                    
                    }
                }else{
                    objResponse.put('bIsSuccess', true); 
                }
             /** #379955 Fix */    
            }
            else{
                objResponse.put('bIsSuccess', true); 
            }            
            /** */                
            
            // Driver Navigation
            if(lstAppInd[0].SSP_Application__r!=null){
                objResponse.put('applicationChangedBy', lstAppInd[0].SSP_Application__r.Application_Changed_By__c);
                objResponse.put('applicationChangeTime', lstAppInd[0].SSP_Application__r.Application_Change_Start_Timestamp__c);
                objResponse.put('applicationPrograms', lstAppInd[0].SSP_Application__r.ProgramsApplied__c);
                if(lstAppInd[0].SSP_Application__r.Application_Change_Start_Timestamp__c!=null)
                {
                    Long dt1Long = (lstAppInd[0].SSP_Application__r.Application_Change_Start_Timestamp__c).getTime();
                    Long dt2Long = DateTime.now().getTime();
                    Long milliseconds = dt2Long - dt1Long;
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    objResponse.put('minutesGap', minutes);
                }
            }
            if(AppConfig__c.getInstance('SSP_DriverNavigationUserLockTime')!=null)
	           objResponse.put('timeLock',AppConfig__c.getInstance('SSP_DriverNavigationUserLockTime').Value__c);
            objResponse.put('userRole',(SSP_Utility.getUserDetails(UserInfo.getUserId())).get(SSP_GlobalConstants.USER_ROLE));
            objResponse.put('availablePrograms',SSP_Utility.getAvailableProgramsByRole());
            objResponse.put('loggedInUserName',UserInfo.getUserName());            
        }
        catch(Exception ex){
            objResponse.put('bIsSuccess', false);
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'resumeApplication', ex.getMessage(), true);
            objResponse.addException(ex, lstLogMessages[0].Id); 
            List<LOG_LogMessage__c> lstLog = new  List<LOG_LogMessage__c>();
            LOG_LogMessage__c objLog =  new LOG_LogMessage__c();
            lstLog = SSP_LogMessageSelector.queryLogMessageData(new Map<String, String>{'objectName'=>'LOG_LogMessage__c','operator'=>'AND'}, 
                                                                 new Set<String>{'Id', 'Name'}, 
                                                                 new Map<String, String>{'limit'=>'1','Id'=> lstLogMessages[0].Id});   
            if(!lstLog.isEmpty()){
                objLog = lstLog[0];
            }
            if(objLog != null){
            objResponse.put('error',  objLog.Name);
            }
        }
        return objResponse;
    }

/***************************************************************************************************
* @author       Aniket Shinde
* @date         05/20/2020
* @methodname   driverNavigationDetails
* @description  This methods is used to fetch data for Driver Navigation
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse driverNavigationDetails(String caseNumber){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String, Object> mapParams = new Map<String, Object>();
        List<SSP_Application__c> sspAppList = new List<SSP_Application__c>();
        try {
            sspAppList = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                                   new Set<String>{'Id','Application_Changed_By__c', 'Application_Change_Start_Timestamp__c','ProgramsApplied__c'}, 
                                                                                                   new Map<String, String>{'limit'=>'1','DCCaseNumber__c'=> caseNumber, 'RecordType.DeveloperName'=>'Case'});
            if(sspAppList != null && !sspAppList.isEmpty()){
                objResponse.put('applicationChangedBy', sspAppList[0].Application_Changed_By__c);
                objResponse.put('applicationChangeTime', sspAppList[0].Application_Change_Start_Timestamp__c);
                objResponse.put('applicationPrograms', sspAppList[0].ProgramsApplied__c);
                if(sspAppList[0].Application_Change_Start_Timestamp__c!=null)
                {
                    Long dt1Long = (sspAppList[0].Application_Change_Start_Timestamp__c).getTime();
                    Long dt2Long = DateTime.now().getTime();
                    Long milliseconds = dt2Long - dt1Long;
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    objResponse.put('minutesGap', minutes);
                }
            }
            if(AppConfig__c.getInstance('SSP_DriverNavigationUserLockTime')!=null)
	           objResponse.put('timeLock',AppConfig__c.getInstance('SSP_DriverNavigationUserLockTime').Value__c);
            objResponse.put('userRole',(SSP_Utility.getUserDetails(UserInfo.getUserId())).get(SSP_GlobalConstants.USER_ROLE));
            objResponse.put('availablePrograms',SSP_Utility.getAvailableProgramsByRole());
            objResponse.put('loggedInUserName',UserInfo.getUserName());    
            objResponse.put('bIsSuccess', true);         
        }
        catch(Exception ex){
            objResponse.put('bIsSuccess', false);
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'driverNavigationDetails', ex.getMessage(), true);
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }


/***************************************************************************************************
* @author       Shivam Tiwari
* @date         05/20/2020
* @methodname   getMemberTypeFlag
* @description  This methods is used to get Ownership Type field value from Contact record of logged in user 
* @return       
*****************************************************************************************************/
@AuraEnabled
public static SSP_LightningResponse getMemberTypeFlag(){
    List<User> userList = new List<User>();
    SSP_LightningResponse toSend = new SSP_LightningResponse();
   try{
        String individualId = SSP_Utility.getIndividualId();
        Contact individualContact = SSP_DashboardService.getIndividualContact(individualId);

        if(individualContact != null){
            toSend.put('memberType', individualContact.MemberType__c);
            toSend.put('ownerType', individualContact.CaseOwnership__c);
        }        
        toSend.put('selectedRole', SSP_Utility.getSelectedRole()); //#371950    
    }
    catch(Exception e){
        LOG_LogMessageUtility.logMessage(e, 'SSP_MyInformationController', 'getMemberTypeFlag', e.getMessage(), true);
    }
    return toSend;
}


    /***************************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         08/06/2020
    * @methodname   getOnlyDependentFlag
    * @description  This methods is used to check whether Apply for Benefits button is to be showed for Dependent or not 
    * @return       
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getOnlyDependentFlag(){
       SSP_LightningResponse toSend = new SSP_LightningResponse();
    try{
         Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
         String onlyKihippHoh = sessionPart.get('onlyKihippHoh') != null ? String.valueOf(sessionPart.get('onlyKihippHoh')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'onlyKihippHoh'))) ?
                String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'onlyKihippHoh')) : '';   
        String hasKhipp = sessionPart.get('hasKihippProgram') != null ? String.valueOf(sessionPart.get('hasKihippProgram')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'hasKihippProgram'))) ?
                String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'hasKihippProgram')) : '';   
         if(onlyKihippHoh == 'true' && hasKhipp == 'true'){
            toSend.put('onlyDependent', true); 
         }
         else{
            toSend.put('onlyDependent', false);
         }
       
    }
    catch(Exception e){
        LOG_LogMessageUtility.logMessage(e, 'SSP_MyDashboardController', 'getOnlyDependentFlag', e.getMessage(), true);
    }
    return toSend; 
    }
/***************************************************************************************************
    * @author       Chandra Shekhar
    * @date         05/29/2020
    * @methodname   getContactNameFirstTime
    * @description  This methods is used to get contact name for logged in user
    * @return       String
    * @Bug          368092
    *****************************************************************************************************/    
    public static String getContactNameFirstTime(){
        list<Contact> individualContact;
        String contactName;
        list<User> contactUser = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'},new Set<String>{'Id', 'ContactId'},new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});        
        
        individualContact = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                 new Set<String>{'Id', 'FirstName', 'LastName', 'IndividualId__c', 'Birthdate','DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                                                 new Map<String, String>{'limit'=>'1','Id'=> contactUser[0].ContactId});
        contactName=individualContact[0].FirstName + ' ' +individualContact[0].LastName;
        return contactName;
    }

  /***************************************************************************************************
	* @author       Aniket Shinde
	* @date         03/05/2020
	* @methodname   fetchMessageCenterData
	* @description  This methods is used to retrieve message center data, call service as needed
	* @return       SSP_LightningResponse
	*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse fetchMessageCenterData(){     
        SSP_LightningResponse response = new SSP_LightningResponse();
        String selectedRole;
        String callingFlag = 'Dashboard';
        String messageCenterSummary = 'MessageCenter';
        Map<String , Object> mergedCriticalMessagesNotifications = new Map<String,Object>();
        SSP_LightningResponse msgSummary = new SSP_LightningResponse();
        Map<String , Object> msgCenterSummary = new Map<String,Object>();
        SSP_LightningResponse mergedMessagesNotifications = new SSP_LightningResponse();

        String contactId;
        String primaryIndId;
        try{ 

            Map<String,String> mapUserDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());//Defect 38059 - Keshav
            selectedRole = mapUserDetails.get(SSP_GlobalConstants.USER_ROLE);//SSP_Utility.getSelectedRole();
            primaryIndId = ssp_utility.getIndividualId();
            // Service callout based notifications
            // fix - 380259
            if( ((selectedRole==SSP_GlobalConstants.CITIZEN_ROLE || selectedRole == SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING 
                || selectedRole == SSP_GlobalConstants.ORGANISATION_AUTH_REP || selectedRole == SSP_GlobalConstants.ASSISTER_ROLE 
                || selectedRole == SSP_GlobalConstants.AGENCY_ADMIN_ROLE) && !SSP_GlobalConstants.waiverRoles.contains(selectedRole))||
                (primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE) || //Defect 38059 - Keshav
                mapUserDetails.get('impersonatedIndividualId') != null)
            {
                //Impersonisation
                if(selectedRole!=SSP_GlobalConstants.CITIZEN_ROLE && mapUserDetails.get('impersonatedIndividualId') != null){
                    List<contact> lstCurrentUserContactIds = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                                        new Set<String>{'id','IndividualId__c','DoesCaseExistForIndividual__c','IsDashboardRefreshNeeded__c','Name'}, 
                                                                                        new Map<String, String>{'IndividualId__c'=>primaryIndId});
                    
                    if(!lstCurrentUserContactIds.isEmpty()){
                        contactId = lstCurrentUserContactIds[0].Id;
                    }
                }
                //Non impersonisation ( Citizen or Non citizen )
                else{
                    contactId = (SSP_Utility.getUserDetails(UserInfo.getUserId())).get('contactId');
                }
                // Fix for 384753
                
                //transaction issue fix - start
                String uniqueTransactionKey;
                // Citizen context OR Impersonised citizen
                if( selectedRole==SSP_GlobalConstants.CITIZEN_ROLE || 
                    ((primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE) || //Defect 38059 - Keshav
                        mapUserDetails.get('impersonatedIndividualId') != null)
                    )
                {
                    uniqueTransactionKey = contactId+';'+SSP_GlobalConstants.CITIZEN_ROLE+';'+SSP_InterfaceConstants.NOTIFICATION_INFORMATION;
                }
                // Non citizen's own dashboard
                else{
                    uniqueTransactionKey = contactId+';'+selectedRole+';'+SSP_InterfaceConstants.NOTIFICATION_INFORMATION;
                }
                //transaction issue fix - end

                List<SSP_Transaction__c> lstNotificationTransaction = [select id, lastmodifieddate, Unique_Id__c from SSP_Transaction__c 
                                                where Status__c = 'Success' AND Unique_Id__c = :uniqueTransactionKey 
                                                order by LastModifiedDate Desc limit 1 ];
                // Time travel fix
                Date currentDate=SSP_Utility.today();
                DateTime startDT=DateTime.newInstanceGmt(currentDate.year(), currentDate.month() , currentDate.day(), 0, 00, 0);
                DateTime endDT=DateTime.newInstanceGmt(currentDate.year(), currentDate.month() , currentDate.day(), 23, 59, 0);
                // 383035 fix
                AppConfig__c transactionCheck = AppConfig__c.getInstance('SSPNotificationCalloutSwitch');
                // 383035 fix
                // Transaction check is ON && Have today's transacction && citizen or impersonization context, prep dashboard data
                if( (transactionCheck!=null && transactionCheck.Value__c == 'ON') && 
                    lstNotificationTransaction != null && !lstNotificationTransaction.isEmpty() && 
                    lstNotificationTransaction[0].LastModifiedDate >= startDT && lstNotificationTransaction[0].LastModifiedDate <= endDT
                    && ((primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE) || //Defect 38059 - Keshav
                        mapUserDetails.get('impersonatedIndividualId') != null) ){
                       //  mergedCriticalMessagesNotifications = retrieveNotifications();
                       
                       mergedMessagesNotifications =  SSP_MessageCenterCtrl.initMessageCenter(callingFlag);
                       mergedCriticalMessagesNotifications = mergedMessagesNotifications.mapResponse;
                       //for message Summary Widget 
                        msgSummary = SSP_MessageCenterCtrl.initMessageCenter(messageCenterSummary);
                        msgCenterSummary = msgSummary.mapResponse;
                }
                // 383035 fix
                //Call service - if not todays transaction date if transaction check is ON or else allow if transaction check is OFF
                else if(    (transactionCheck!=null && transactionCheck.Value__c == 'OFF') ||
                         ( (transactionCheck!=null && transactionCheck.Value__c == 'ON') && !(lstNotificationTransaction != null && !lstNotificationTransaction.isEmpty() && 
                         lstNotificationTransaction[0].LastModifiedDate >= startDT && lstNotificationTransaction[0].LastModifiedDate <= endDT) )
                        )
                {
                    Map<String, Object> mapParams = new Map<String, Object>();
                    SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                    reqWrapper.viewName = SSP_InterfaceConstants.NOTIFICATION_INFORMATION ;
                    reqWrapper.KeyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
                    if(lstNotificationTransaction != null && !lstNotificationTransaction.isEmpty()){
                        String transactionDate = ((lstNotificationTransaction[0]).lastmodifieddate).format('YYYY-MM-dd');
                        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('LastTransactionDate',transactionDate)); 
                    }
                    // Citizen context OR Impersonised citizen
                    if( selectedRole==SSP_GlobalConstants.CITIZEN_ROLE || 
                        ((primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE) || //Defect 38059 - Keshav
                            mapUserDetails.get('impersonatedIndividualId') != null)
                    ){
                        reqWrapper.primaryApplicationIndividualId = ssp_utility.getCurrentUserAllIndividualIds();
                        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('RecipientType','Citizen'));   
                    }
                    // Non citizen's own dashboard
                    else{
                        list<Integer> listNonCitizenIdentifier = new list<Integer>();
                        for(AccountContactRelation objACR : [select id, DCContactId__c from AccountContactRelation where 
                                        DCContactId__c != null AND  Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION 
                                        AND ContactId = :contactId AND Roles = :selectedRole])
                        {
                            Integer intVal = (objACR.DCContactId__c).intValue();
                            listNonCitizenIdentifier.add(Integer.valueOf(intVal));
                        }
                        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('RecipientType',SSP_MessageCenterService.getOtherRoleString(selectedRole)));
                        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('RecipientId',String.join(listNonCitizenIdentifier,';')));
                    }
                    mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                    List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                    RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
                    // failure in service call
                    if(ResponseWRapper.ACKRESPONSE != null && ResponseWRapper.ACKRESPONSE.AckResponseCode != null){
                        // servie call failure handling
                    }
                    // success in service call + fetch message center data relevent to dashboard only for citizen or impersonisation
                    else if(((primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE) || //Defect 38059 - Keshav
                            mapUserDetails.get('impersonatedIndividualId') != null)){
                        // call method to retrieve data of notifications
                        mergedMessagesNotifications =  SSP_MessageCenterCtrl.initMessageCenter(callingFlag);
                        mergedCriticalMessagesNotifications = mergedMessagesNotifications.mapResponse;
                        //for message Summary Widget 
                            msgSummary = SSP_MessageCenterCtrl.initMessageCenter(messageCenterSummary);
                            msgCenterSummary = msgSummary.mapResponse;
                    }
                }
            }
            // SF Specific notifications + fetch message center data relevent to dashboard only for citizen or impersonisation
            else if((primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE) || //Defect 38059 - Keshav
                            mapUserDetails.get('impersonatedIndividualId') != null){
                //call method to retrieve data of notifications
               mergedMessagesNotifications =  SSP_MessageCenterCtrl.initMessageCenter(callingFlag);
               mergedCriticalMessagesNotifications = mergedMessagesNotifications.mapResponse;
               //for message Summary Widget 
               msgSummary = SSP_MessageCenterCtrl.initMessageCenter(messageCenterSummary);
               msgCenterSummary = msgSummary.mapResponse;
            }
            //Message center role based rendering - start
            //Impersonisation
            if(selectedRole!=SSP_GlobalConstants.CITIZEN_ROLE && mapUserDetails.get('impersonatedIndividualId') != null){
                Set<string> noMsgCenterAccessRoles = new Set<String>{'QE_Hospital','QE_Pregnancy','DJJ_Representative','Eligibility_&_Benefit_Inquiry_User','Department_Of_Education_Representative'};
                if(noMsgCenterAccessRoles.contains(selectedRole)){
                    response.put('hideMessageCenter',true);
                }
                else{
                    response.put('hideMessageCenter',false);
                }
            }
            //Non-Impersonisation
            else{
                response.put('hideMessageCenter',false);
            }
            //Message center role based rendering - end
            response.bIsSuccess = true;
            response.put('messageWrapper',mergedCriticalMessagesNotifications);
            response.put('msgCenterSummary',msgCenterSummary);
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'fetchMessageCenterData', 'Failed to fetch Message Center data', true);
			response.bIsSuccess = false;           
        }
        return response;
    }

    public class DashboardCacheWrapper{
        public Map<String, String> mapCaseVsStatus;
        public Map<String, Boolean> mapCaseVsHOH;
        public Map<String, String> mapCaseVsIndividualId;
        public Map<String, String> mapCaseVsEligibilityRunDate; //#387346
        /*	message center changes
            added message center notice access for auth reps map in Dashboard Cache
        */
        public map<String,Set<String>> authRepAccessForNotices;
        public boolean hasRACEnabled;
    }
	
	    /*for defect fix 379797 added by Gunjyot Walia*/
    @AuraEnabled
    public static string backYardNavigate(){
        string commURL;
       commURL = AppConfig__c.getInstance('navigateToBackYard').Value__c;
        return commURL;
    }


    /***************************************************************************************************
    * @date         10/10/2020
    * @methodname   getHOHContactForNextSteps
    * @description  This is helper method for Citizen Impersonation from Next Step screen
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getHOHContactForNextSteps(String applicationId){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            if(String.isNotBlank(applicationId)){
                List<SSP_ApplicationIndividual__c> lstAppInds = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                                                                new Set<String>{'Id','SSP_Member__c','SSP_Application__c','SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c', 'SSP_Member__r.Contact__r.IndividualId__c', 'SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c', 'SSP_Member__r.MiddleInitial__c', 'SSP_Member__r.IndividualId__c'}, 
                                                                                                                                new Map<String, String>{'limit'=>'1','SSP_Application__c'=> applicationId,'IsHeadOfHousehold__c' =>'#true#'});


                if(lstAppInds != null && lstAppInds.size() > 0){
                    SSP_ApplicationIndividual__c hohIndividual = lstAppInds[0];
                    Contact memberContact= new Contact();
                    memberContact.FirstName = hohIndividual.SSP_Member__r.FirstName__c;
                    memberContact.LastName = hohIndividual.SSP_Member__r.LastName__c;
                    memberContact.MiddleName = hohIndividual.SSP_Member__r.MiddleInitial__c;     
                    memberContact.IndividualId__c = hohIndividual.SSP_Member__r.IndividualId__c; //hohIndividual.SSP_Member__r.IndividualId__c   //hohIndividual.SSP_Member__r.Contact__r.IndividualId__c

                    toSend.put('contactJSON', JSON.serialize(memberContact));
                    toSend.put('isWaiverRole', SSP_GlobalConstants.waiverRoles.contains(SSP_Utility.getSelectedRole()));
                    return toSend;
                }
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'getHOHContactForNextSteps', 'Failed in getHOHContactForNextSteps', true);
        }
        return null;
    }
	
    @AuraEnabled
    public static void updateUserLanguage(String language){
        try{
            if(String.isNotBlank(language)){
                User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId()];
                if(language == 'es_US'){
                    currentUserInfo.LanguageLocaleKey = 'es_US';
                }else{
                    currentUserInfo.LanguageLocaleKey = 'en_US';          
                }
                update currentUserInfo;
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_DashboardController', 'updateUserLanguage', 'Failed in update user language', true);
            //response.bIsSuccess = false;           
        }
    }
}