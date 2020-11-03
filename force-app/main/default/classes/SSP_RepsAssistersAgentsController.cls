/*
* classname     :  SSP_RepsAssistersAgentsController
* @description  :  Controller class for Reps Assisters & Agents related screens
* @Reason For Without Sharing : Since We need to update/insert acr,contact AuthRep,Assister,Agent records which are part of day0 Record
We made this class Without Sharing
* @author       :  Kireeti Gora   
* @date         :  12/20/2019
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public without sharing class SSP_RepsAssistersAgentsController { 
    
    @AuraEnabled
    public static SSP_LightningResponse updatePrograms(String sspApplicationId){              
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<Account> lstAccountsInserted =  new List<Account>();
        set<Integer> lstCase = new  set<Integer>();        
        List<Account> lstAccount = new List<Account>();
        set<String> lstCaseToBeInserted = new  set<String>();
        List<SSP_Application__c> lstApplication = new List<SSP_Application__c>();
        List<SSP_Application__c> lstApplicationsInserted = new List<SSP_Application__c>();
        List<Contact> userList = new List<Contact>();
        List<Integer> lstExistingCases = new List<Integer>();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        List<SSP_Application__c> existingApplicationIndividual = new List<SSP_Application__c>();
        List<SSP_Application__c> existingApplicationToUpdate = new List<SSP_Application__c>();
        List<String> existingAppIndividualCaseNumbers = new List<String>();
        List<SSP_Application__c> existingCaseList = new List<SSP_Application__c>();
        List<AccountContactRelation> lstCitizenACRList = new List<AccountContactRelation>();
        List<AccountContactRelation> lstCitizenACRToBeInserted = new List<AccountContactRelation>();
        Map<String, List<String>> allBenefits =  new   Map<String, List<String>>();
        Map<String, Boolean> caseToHOHMap  =  new  Map<String, Boolean>();  
        Map<String, String> mapCaseVsStatus  =  new  Map<String, String>();  
        Map<String,object> mapRestResult = new Map<String,object>();
        String programs = '';    
        String individualId;    
        String contactMappingIndividualId;        
        try{
            contactMappingIndividualId = ssp_utility.getCurrentUserAllIndividualIds();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
            String mapCaseVsAllBenefitsString = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
            String mapCaseVsHOHString = sessionpart.get('caseVsHOH') != null ? String.valueOf(sessionpart.get('caseVsHOH')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH'));
            String mapCaseVsStatusString = sessionpart.get('caseVsStatus') != null ? String.valueOf(sessionpart.get('caseVsStatus')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
            if(individualId != null && individualId != ''){  
                userList =SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                               new Set<String>{'Id', 'FirstName','LastName','IndividualId__c','Email','GenderCode__c','BirthDate'}, 
                                                               new Map<String, String>{'IndividualId__c'=>individualId});                            
            }   
            if(String.isNotBlank(mapCaseVsAllBenefitsString) ){
                Map<String, List<SSP_BenefitInformationWrapper>> activeBenefitsMap =   (Map<String,List<SSP_BenefitInformationWrapper>>)JSON.deserialize(String.valueOf(mapCaseVsAllBenefitsString), Map<String,List<SSP_BenefitInformationWrapper>>.class);
                allBenefits = fetchExistingAppliedPrograms(activeBenefitsMap);
            }
            if(String.isNotBlank(mapCaseVsHOHString) ){
                caseToHOHMap = (Map<String, Boolean>) JSON.deserialize(String.valueOf(mapCaseVsHOHString), Map<String, Boolean>.class);
                
            }
            
            if(String.isNotBlank(mapCaseVsStatusString)){
                mapCaseVsStatus = (Map<String,String>)JSON.deserialize(String.valueOf(mapCaseVsStatusString), Map<String,String>.class);
            }
            if(!mapCaseVsStatus.isEmpty()){
                for(String strCase:mapCaseVsStatus.keyset()){
                    lstCase.add(Integer.valueOf(strCase));
                }
            }
            
            
            if(!lstCase.isEmpty()){
                
                existingCaseList =  SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND','IN'=>'DCCaseNumber__c'}, 
                                                                                 new Set<String>{'Id','DCCaseNumber__c'}, 
                                                                                 new Map<String, String>{'limit'=>'1000','DCCaseNumber__c'=> String.join(new List<Integer>(lstCase),',') , 'RecordType.DeveloperName'=>'Case'});
            }
            
            
            for(SSP_Application__c objApplication : existingCaseList){          
                if(objApplication.DCCaseNumber__c != null){
                    lstExistingCases.add(Integer.valueOf(objApplication.DCCaseNumber__c));   
                }
            }
            for(Integer caseNumber : lstCase){                     
                if(((!lstExistingCases.isEmpty()) && !lstExistingCases.contains(caseNumber)) || lstExistingCases.isEmpty()) {
                    lstCaseToBeInserted.add(String.valueOf(caseNumber));
                }                   
            }
            
            
            //for defect 385041-- start
            Map<String,Id> caseVsAccount = new Map<String,Id>();
            for(Account existingAcc : [select Id,CaseNumber__c from Account where caseNumber__c IN:lstCaseToBeInserted]){
                caseVsAccount.put(existingAcc.CaseNumber__c,existingAcc.Id);
            }
            for(String caseNumber : lstCaseToBeInserted){  
                if(!caseVsAccount.containsKey(caseNumber)){
                Account account = new Account();                    
                account.Name = 'Application Account for ' + ((!UserList.isEmpty()) ? userList[0].FirstName : '') + ' ' + ((!UserList.isEmpty()) ? userList[0].LastName:'') + ' ' + 'Household';
                account.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
                account.CaseNumber__c = caseNumber;
                lstAccount.add(account);
                }
            }
            //for defect 385041-- End
            
            if(contactMappingIndividualId != null  && contactMappingIndividualId != ''){
                Map<String, Object> mapParams = new Map<String, Object>();
                SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName = SSP_InterfaceConstants.AUTHREPS_ASSISTERS;                    
                reqWrapper.primaryApplicationIndividualId = contactMappingIndividualId;                    
                mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                mapParams.put(SSP_InterfaceConstants.ACCOUNTS,lstAccount);
                IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                
            }
            
            //  sp = Database.setSavepoint(); 
            if(!lstCaseToBeInserted.isEmpty() && Schema.sObjectType.Account.isAccessible()){//385715
                lstAccountsInserted = [SELECT Id,CaseNumber__c FROM ACCOUNT WHERE CaseNumber__c IN :lstCaseToBeInserted];  
            }
            
            for(Account account : lstAccountsInserted){
                SSP_Application__c objApplication = new SSP_Application__c();
                
                set<String> lstPrograms =  new  set<String>();
                objApplication.Account__c =  account.Id;
                objApplication.DCCaseNumber__c = Integer.valueOf(account.CaseNumber__c);
                
                if(allBenefits.get(account.CaseNumber__c) != null){
                    lstPrograms.addAll(allBenefits.get(account.CaseNumber__c));
                }
                
                
                objApplication.ProgramsApplied__c = string.join(new List<String>(lstPrograms), ';');
                objApplication.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c', 'Case');
                lstApplication.add(objApplication);
            }
            
            if(!lstApplication.isEmpty()){               
                lstApplicationsInserted= SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstApplication,'insert','SSP_Application__c');
            }
            String memberId = getMemberId(true); 
            for(SSP_Application__c application : lstApplicationsInserted){
                SSP_ApplicationIndividual__c objAppicationIndividual = new SSP_ApplicationIndividual__c();
                objAppicationIndividual.SSP_Member__c = memberId != null ? memberId :null;
                objAppicationIndividual.SSP_Application__c = application.Id;
                if(caseToHOHMap.get(String.valueOf(application.DCCaseNumber__c)) != null){
                    objAppicationIndividual.IsHeadOfHousehold__c= caseToHOHMap.get(String.valueOf(application.DCCaseNumber__c));
                    lstApplicationIndividual.add(objAppicationIndividual);
                }  
                
            }                
            
            if(!lstExistingCases.isEmpty())    {
                
                existingApplicationIndividual = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND','IN'=>'DCCaseNumber__c'}, 
                                                                                             new Set<String>{'Id','ProgramsApplied__c','DCCaseNumber__c','SectionStatus__c','(select id,ssp_member__c from ssp_applicationIndividuals__r where ssp_member__c ='+'\''+ string.valueOf(memberId) + '\''+')'},
                                                                                             new Map<String, String>{'limit'=>'1000','DCCaseNumber__c'=> String.join(new List<Integer>(lstExistingCases),',')});
            }
            
            for(SSP_Application__c objApp:existingApplicationIndividual){  
                set<String> lstPrograms =  new  set<String>();
                if(allBenefits.get(String.valueOf(objApp.DCCaseNumber__c)) != null){
                    lstPrograms.addAll(allBenefits.get(String.valueOf(objApp.DCCaseNumber__c)));
                }
                Map<String,Object> mapAppSectionStatus = objApp.SectionStatus__c!=null? (Map<String,Object>)JSON.deserializeUntyped(objApp.SectionStatus__c):null;
                if(((objApp.ProgramsApplied__c !=null && (!lstPrograms.isEmpty()) && string.join(new List<String>(lstPrograms), ';') != objApp.ProgramsApplied__c) ||
                    (objApp.ProgramsApplied__c ==null &&  (!lstPrograms.isEmpty())))
                   && (sspApplicationId == null || sspApplicationId == '')){
                       objApp.ProgramsApplied__c = string.join(new List<String>(lstPrograms), ';');
                       existingApplicationToUpdate.add(objApp);
                   }
                
                if(objApp.ssp_applicationIndividuals__r.isEmpty() && (sspApplicationId == null || sspApplicationId == '')){
                    
                    SSP_ApplicationIndividual__c objAppicationIndividual = new SSP_ApplicationIndividual__c();
                    objAppicationIndividual.SSP_Member__c = memberId != null ? memberId :null;
                    objAppicationIndividual.SSP_Application__c = objApp.Id;
                    if(caseToHOHMap.get(String.valueOf(objApp.DCCaseNumber__c)) != null){
                        objAppicationIndividual.IsHeadOfHousehold__c= caseToHOHMap.get(String.valueOf(objApp.DCCaseNumber__c));
                        lstApplicationIndividual.add(objAppicationIndividual);
                        
                    }
                }
            }
            
            if(!lstCase.isEmpty()){
              
                lstCitizenACRList = [SELECT Id,Account.CaseNumber__c,AccountId,ContactId FROM AccountContactRelation WHERE Account.CaseNumber__c IN :new List<String>(String.join(new List<Integer>(lstCase), ',').split(','))];
            }
            Map<String,String> mapCaseVsAccountId = new Map<String,String>();
            List<String> lstCasesForACRCreation = new List<String>();
            String currentUserContactId = SSP_Utility.getCurrentUserDetails()[0].ContactId;
            for(AccountContactRelation objACR : lstCitizenACRList){
                mapCaseVsAccountId.put(objACR.Account.CaseNumber__c, objACR.AccountId);
                If(objACR.contactId == currentUserContactId){
                   lstCasesForACRCreation.add(objACR.account.CaseNumber__c);
                }
            }
            for(Integer caseNo : lstCase){
                if((!lstCasesForACRCreation.contains(String.valueOf(caseNo))) && mapCaseVsAccountId.get(String.valueOf(caseNo)) != null){
                    AccountContactRelation objACR= new AccountContactRelation();
                    objACR.ContactId = currentUserContactId;
                    objACR.accountId =mapCaseVsAccountId.get(String.valueOf(caseNo));
                    lstCitizenACRToBeInserted.add(objACR);
                }
            }
             if(!lstCitizenACRToBeInserted.isEmpty()){
               INSERT lstCitizenACRToBeInserted;
                
            }
			
            if(!lstApplicationIndividual.isEmpty()){
                lstApplicationIndividual =  SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstApplicationIndividual,'insert','SSP_ApplicationIndividual__c');
                
            }
            if(!existingApplicationToUpdate.isEmpty()){               
               UPDATE  existingApplicationToUpdate;                
            }
            
            
            response.put('applicationList', JSON.serialize(lstApplication));
            //  SSP_ProgramSelectionService.resetDashboardRefreshFlag(contactList[0].Id);                                    
            
        }
        
        
        catch(Exception ex){
           
            response.put('ERROR', ex.getStackTraceString()+ ' //Msg  : '+ex.getMessage());        
            
            
        }
        return response;
    }
    
    private static Map<String, List<String>> fetchExistingAppliedPrograms(Map<String, List<SSP_BenefitInformationWrapper>> benefitsMap){
        Map<String, List<String>> existingAppliedPrograms = new Map<String, List<String>>();
        if(benefitsMap != null){
            for(String caseNo : benefitsMap.keySet()){
                List<String> lstPrograms = new List<String>();
                for(SSP_BenefitInformationWrapper objBenefit : benefitsMap.get(caseNo)){ 
                    if(objBenefit.ProgramCode == system.label.SSP_KTAP){                         
                        objBenefit.ProgramCode =SSP_GlobalConstants.KTAP ;
                    }else if(objBenefit.ProgramCode == system.label.SSP_Medicaid){                            
                        objBenefit.ProgramCode =SSP_GlobalConstants.MEDICAID;
                    } 
                    else if(objBenefit.ProgramCode == system.label.SSP_ChildCareAssistance){                            
                        objBenefit.ProgramCode = SSP_GlobalConstants.CHILDCARE;
                    } 
                    else if(objBenefit.ProgramCode == system.label.SSP_StateSupplementation){                             
                        objBenefit.ProgramCode =SSP_GlobalConstants.STATE;
                    } 
                    else if(objBenefit.ProgramCode ==system.label.SSP_KIHIPP){                              
                        objBenefit.ProgramCode =SSP_GlobalConstants.KHIPP ;
                    }else if (objBenefit.ProgramCode == system.label.SSP_SNAP){                           
                        objBenefit.ProgramCode =SSP_GlobalConstants.SNAP ;
                    }
                    List<String> programCodes = new List<String>{SSP_GlobalConstants.SNAP,SSP_GlobalConstants.KHIPP,SSP_GlobalConstants.STATE,SSP_GlobalConstants.CHILDCARE,SSP_GlobalConstants.MEDICAID,SSP_GlobalConstants.KTAP};
                    // for defect fix 385041
                    if(programCodes.contains(objBenefit.ProgramCode) && !lstPrograms.contains(objBenefit.ProgramCode)){
                        lstPrograms.add(objBenefit.ProgramCode);
                    }
                }
                existingAppliedPrograms.put(caseNo,lstPrograms);
            }
        }
        return existingAppliedPrograms;
    }
    /*    
* @method       : getCurrentUserMemberId
* @description  : This method returns the current user's member Id.
* @author       : Kireeti Gora
* @return       : Id - Current User Member Id.
* */
    public static String getMemberId(Boolean doInsert) {
        String sspMemberId;
        List<SSP_Member__c> lstmember =new List<SSP_Member__c>();
        
        List<Contact> contactList = new List<Contact>();//
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            String individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
            
		if(individualId != null && individualId != ''){  
            contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                    new Set<String>{'Id','FirstName','LastName','IndividualId__c','Email','GenderCode__c','BirthDate','Phone','Suffix'},
                                                                    new Map<String, String>{'limit'=>'1','IndividualId__c'=> individualId}); 								
            }

            if(contactList == null || (contactList !=null && contactList.isEmpty())){
                contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                    new Set<String>{'Id','FirstName','LastName','IndividualId__c','Email','GenderCode__c','BirthDate','Phone','Suffix'},
                                                                    new Map<String, String>{'limit'=>'1','Id'=> SSP_Utility.getCurrentUserDetails()[0].ContactId}); 									
            }
            
            
            if(contactList != null && !contactList.isEmpty()){
                Map<String,String> conditionMap = new Map<String, String>{'limit'=>'1','contact__c'=> String.valueOf(contactList[0].Id)}; 
                    lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                                new Set<String>{'Id'}, 
                                                                conditionMap);
            }
            else{
                lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                        new Set<String>{'Id','Contact__c','Contact__r.IndividualId__c'}, 
                                                        new Map<String, String>{'IndividualId__c'=> individualId });
            }
            
            if(lstmember != null && !lstmember.isEmpty()){ 
                sspMemberId =  lstmember[0].Id;
            }else if(doInsert && individualId !=''){			
                List<SSP_Member__c> memberList = new List<SSP_Member__c>{new SSP_Member__c(
                    //IsHeadOfHousehold__c = true,
                    FirstName__c=  contactList[0].FirstName,
                    LastName__c= contactList[0].LastName,
                    Name =  contactList[0].FirstName + ' ' +  contactList[0].LastName,
                    Contact__c =  contactList[0].Id,
                    IndividualId__c  =  contactList[0].IndividualId__c != null ?  contactList[0].IndividualId__c :null,
                    Email__c =  contactList[0].Email != null ?  contactList[0].Email : null,
                    GenderCode__c =  contactList[0].GenderCode__c != null ?  contactList[0].GenderCode__c : null,
                    BirthDate__c =   contactList[0].Birthdate != null ?  contactList[0].Birthdate : null,
                    PrimaryPhoneNumber__c = contactList[0].Phone != null ?  contactList[0].Phone : null,
                    SuffixCode__c = contactList[0].Suffix != null ?  contactList[0].Suffix : null
                )};
                    ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
                memberList = ESAPI.accessController().insertAsUser(memberList, SSP_Utility.getFieldsNamesList (memberList)).getInsertedObjects();
                if(!memberList.isEmpty()){
                    sspMemberId =memberList[0].Id;
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_utility', 'getCurrentUserMemberId', 'Failed to fetch Details in getCurrentUserMemberId Method', true);  
        }
        return sspMemberId;
    }
    
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @methodname   getRepsAssistersAgentsDetails
* @description  This methods is used to get RepsAssistersAgentsDetails
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getRepsAssistersAgentsDetails(String sspApplicationId,String mode){
        SSP_Utility.isAuthenticatedUser();
        Id sspMemberId;
        String currentUserContactId;
        String strPrograms ='';
        String strIndividualIdForAccessRequest='';
        Boolean isHOH = false; 
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        List<Account> lstAccount = new List<Account>();  
        List<AccountContactRelation> lstOrganizationAccount = new List<AccountContactRelation>();  
        List<Contact> lstContact = new List<Contact>();  
        List<AccountContactRelation> lstACR = new  List<AccountContactRelation>();        
        List< SSP_RepsAssistersAgentsController.individualWrapper> lstIndividualRecords = new  List< SSP_RepsAssistersAgentsController.individualWrapper>();
        List< SSP_RepsAssistersAgentsController.individualWrapper> lstAssisterRecords = new  List< SSP_RepsAssistersAgentsController.individualWrapper>();
        List< SSP_RepsAssistersAgentsController.individualWrapper> lstInsuranceAgentRecords = new  List< SSP_RepsAssistersAgentsController.individualWrapper>();       
        Set<Id> lstAccountIds = new Set<Id>();
         Set<Id> setAuthRepContactIds = new Set<Id>();
         Set<Id> setAssisterContactIds = new Set<Id>();
         Set<Id> setAgentContactIds = new Set<Id>();
        Set<String> lstAccountDcIds = new Set<String>();
        Set<Id> setAppindividual = new Set<Id>();
        
        Map<Id,String> mapCaseVsApplication =  new Map<Id,String>();
        Map<Id,String> mapContactVsOrganization =  new Map<Id,String>();
        Map<String,AccountContactRelation> mapDataIdVsAccountName =  new Map<String,AccountContactRelation>();
        Map<Id,SSP_Application__c> mapCaseVsApplicationDetail =  new Map<Id,SSP_Application__c>();
        Map<Id,Boolean> mapCaseVsisHOH =  new Map<Id,Boolean>();
        Map<Id,List<AccountContactRelation>> mapAccountVsACR =  new Map<Id,List<AccountContactRelation>>();
         Contact accessRequestContact;
        
        try{
            currentUserContactId = ssp_utility.getCurrentUserDetails()[0].contactId;
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
            if(sspApplicationId != null && sspApplicationId != ''){

            // for defect 388491 & 388717 -- start
           
            List<AccountContactRelation> updateInsuranceACRs = new List<AccountContactRelation>();
          

            if(selectedRole == SSP_GlobalConstants.INSURANCEAGENT_ROLE && mode=='intake'){
                SSP_Application__c getAccId = [SELECT Id, Account__c FROM SSP_Application__c where Id=:sspApplicationId][0];
                List<AccountContactRelation> insuranceAgentDetails = [select ID,DCContactId__c,Account.DcDataId__c from AccountContactRelation where DCContactId__c!=null AND Account.DcDataId__c!=null AND Account.Recordtype.Name =:SSP_GlobalConstants.ORGANIZATION AND Roles includes (: selectedRole) AND ContactId=:currentUserContactId];
                
            for(AccountContactRelation insuranceAgentACRS : [select Id,Roles,AccountId,ContactId,DCContactId__c, DCAgencyId__c from AccountContactRelation where AccountId =:getAccId.Account__c AND ContactId=:currentUserContactId])
                {
                    insuranceAgentACRS.Roles = selectedRole;
                    if(!insuranceAgentDetails.isEmpty()){
                    insuranceAgentACRS.DCContactId__c = insuranceAgentDetails[0].DCContactId__c;
                    insuranceAgentACRS.DCAgencyId__c = insuranceAgentDetails[0].Account.DcDataId__c;
                    }
                    updateInsuranceACRs.add(insuranceAgentACRS);
                }
                if(!updateInsuranceACRs.isEmpty())
                {
                    database.update(updateInsuranceACRs,false);
                }
            }

            // for defect 388491 & 388717 -- end

                SSP_LightningResponse objResponse = new SSP_LightningResponse();           
                objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(sspApplicationId);
                if(objResponse != null && objResponse.mapResponse != null && (!objResponse.mapResponse.containsKey('hasAccess'))){
                    response.put('hasNoAccess',true);
                    response.bIsSuccess = true;
                    return response;    
                }
            }
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('REPS_Home',selectedRole);
            response.put('Role',selectedRole);
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible'){
                response.put('showScreen',true);
            }else if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='NotAccessible'){
                response.put('showScreen',false);
                return response;
            }
            if(String.isBlank(mode) || (mode != null && mode != 'intake')){//385715
                updatePrograms(sspApplicationId);
            }
            sspMemberId =  getMemberId(false);
            if(sspApplicationId != null && sspApplicationId != '' && mode != null && mode != '' && mode == 'intake' && selectedRole != null && SSP_GlobalConstants.REPS_HOME_ROLES.contains(selectedRole) && currentUserContactId != null && currentUserContactId != ''){
               accessRequestContact = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                           new Set<String>{'id','RecordType.DeveloperName','IndividualId__c','DCDataId__c','Phone','Name','Email','HoursAvailableCode__c','Street__c','City__c','toLabel(SSP_State__c)','Zipcode5__c','InsuranceCompany__c','toLabel(SpokenLanguageCode__c)','Zipcode4__c','AddressLine2__c','toLabel(countycode__c)','toLabel(PreferredLanguageCode__c)','ContactGeoLocation__c',
                                                                               'MailingStreet','MailingCity','MailingState','MailingPostalCode','MailingLine2__c'}, 
                                                                           new Map<String, String>{'Id'=>currentUserContactId})[0];
            }

            String selectedRoleUsr = SSP_Utility.getSelectedRole();
            // fix 378597
            if( selectedRoleUsr != SSP_GlobalConstants.CITIZEN_ROLE && sspApplicationId != null ){
                List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(sspApplicationId,new set<string>{});
                if(applicationIndividuals != null && !applicationIndividuals.isEmpty()){
                    sspMemberId = applicationIndividuals[0].SSP_Member__c;
                }
            }
            if(sspMemberId != null){
                if(sspApplicationId != null && sspApplicationId != ''){
                    lstApplicationIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualCaseData(new Set<String>{'Id', 'ProgramsApplied__c',  'SSP_Application__r.ProgramsApplied__c','SSP_Application__r.Account__c','SSP_Application__r.Status__c','IsHeadOfHousehold__c','SSP_Member__r.IndividualId__c'}, 
                                                                                                                    sspMemberId,true,sspApplicationId);
                }else {
                    lstApplicationIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualCaseData(new Set<String>{'Id', 'ProgramsApplied__c', 'SSP_Application__r.Account__c','SSP_Application__r.Status__c','IsHeadOfHousehold__c','SSP_Member__r.IndividualId__c'}, 
                                                                                                                    sspMemberId,false,sspApplicationId);  
                }
                if(selectedRoleUsr != SSP_GlobalConstants.CITIZEN_ROLE && sspApplicationId != null && sspApplicationId !='' && (!lstApplicationIndividual.isEmpty()) && mode != null && mode == 'intake' && lstApplicationIndividual[0].SSP_Member__r.IndividualId__c != null){
                    response.put('IndividualId',lstApplicationIndividual[0].SSP_Member__r.IndividualId__c);
                }               
                if(!lstApplicationIndividual.isEmpty()){
                    for(SSP_ApplicationIndividual__c objAppIndividual: lstApplicationIndividual){
                        if((objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null && (8 - (objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(SSP_utility.today())) >= 0)  && (objAppIndividual.SSP_Application__r.RecordType.DeveloperName=='SSP_Application')  && (objAppIndividual.ssp_application__r.Status__c == 'UN')) ||
                           ((objAppIndividual.SSP_Application__r.RecordType.DeveloperName=='Case') && objAppIndividual.ssp_application__r.DCCaseNumber__c != null)
                          ){
                              if((objAppIndividual.IsHeadOfHousehold__c) && (!isHOH)){
                                  isHOH = true;
                              }
                              mapCaseVsisHOH.put(objAppIndividual.SSP_Application__r.Account__c,objAppIndividual.IsHeadOfHousehold__c);
                              
                              lstAccountIds.add(objAppIndividual.SSP_Application__r.Account__c);
                          }
                       
                    }
                }else{
                    response.put('hasNoContext',true);
                    return response;
                }
                
                if(!lstAccountIds.isEmpty()){
                    lstAccount = SSP_AccountSelector.queryAccountData(new Map<String, String>{'objectName'=>'ACCOUNT','operator'=>'AND','hasToLabel'=>'true','IN'=>'id'}, 
                                                                      new Set<String>{'Id','DcdataId__c','Name', '(SELECT Id,account__c,DCCaseNumber__c,ProgramsApplied__c,Name,RecordType.DeveloperName from SSP_Applications__r)',
                                                                          '(SELECT accountId ,RequestAccessPermission__c,DCAgencyId__c,id,Roles,contact.Id,contact.Phone,contact.Email,contact.Name,contact.MailingAddress,contact.ContactGeoLocation__c'+
                                                                          ',toLabel(PermissionLevel_Medicaid__c),toLabel(PermissionLevel_SNAP__c),toLabel(PermissionLevel_StateSupp__c),toLabel(CountyCode__c),Zipcode5__c,Zipcode4__c,AddressLine2__c,Street__c,City__c,toLabel(SSP_State__c)'+
                                                                          ',toLabel(PermissionLevel_KIHIPP__c),toLabel(PermissionLevel_KTAP__c),contact.MailingStreet,contact.MailingCity,contact.MailingState,'+
                                                                          'toLabel(PermissionLevel_CCAP__c),ProgramsApplied__c,contact.OrganizationName__c,contact.AgencyOrOrganization__r.name,contact.AgencyOrOrganization__c,'+
                                                                          'contact.Street__c,contact.City__c,toLabel(contact.SSP_State__c),contact.Zipcode5__c,contact.InsuranceCompany__c,toLabel(contact.SpokenLanguageCode__c),'+
                                                                          'contact.Zipcode4__c,contact.mailingPostalCode,contact.MailingLine2__c ,contact.AddressLine2__c,contact.HoursAvailableCode__c,toLabel(contact.countycode__c),toLabel(contact.PreferredLanguageCode__c)'+                                                                          
                                                                          'FROM AccountContactRelations)'}, 
                                                                      new Map<String, String>{'limit'=>'1000','id'=>String.join(new List<Id>(lstAccountIds), ',')});
                    
                }else{
                    response.put('hasNoContext',true);
                    return response;
                }
                
                
                for(Account objAccount: lstAccount){
                    if(!objAccount.SSP_Applications__r.isEmpty() && !objAccount.AccountContactRelations.isEmpty()){                       
                        mapAccountVsACR.put(objAccount.Id,objAccount.AccountContactRelations);
                        mapCaseVsApplication.put(objAccount.Id,String.valueOf(objAccount.SSP_Applications__r[0].DCCaseNumber__c));
                        mapCaseVsApplicationDetail.put(objAccount.Id,objAccount.SSP_Applications__r[0]);
                        lstACR.addAll(objAccount.AccountContactRelations);
                        if((!objAccount.SSP_Applications__r.isEMpty()) &&objAccount.SSP_Applications__r[0].ProgramsApplied__c != null){
                            strPrograms = strPrograms +objAccount.SSP_Applications__r[0].ProgramsApplied__c;
                        }
                    }
                    
                }
                for(AccountContactRelation objACR: lstACR){
                    if(objACR.DCAgencyId__c != null){
                        lstAccountDcIds.add(String.valueOf(objACR.DCAgencyId__c));
                    }
                }            
                if(!lstAccountDcIds.isEmpty()){
                   /* lstOrganizationAccount = SSP_AccountSelector.queryAccountData(new Map<String, String>{'objectName'=>'ACCOUNT','operator'=>'AND','hasToLabel'=>'true','IN'=>'DcdataId__c'}, 
                                                                                  new Set<String>{'Id','DcdataId__c','Name','Phone'}, 
                                                                                  new Map<String, String>{'limit'=>'1000','DcdataId__c'=>String.join(new List<String>(lstAccountDcIds), ',')});*/
                     lstOrganizationAccount = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND','IN'=>'account.DCdataId__c'}, 
                                                                              new Set<String>{'Id','account.Name','account.DCdataId__c','Roles','dcAgencyId__c','dcContactId__c','account.Phone'}, 
                                                                              new Map<String, String>{'limit'=>'1000','account.DCdataId__c'=>String.join(new List<String>(lstAccountDcIds), ','),'account.recordtype.developerName'=>'Resource_Engine'});
                    
                }
                
                for(AccountContactRelation objAccount: lstOrganizationAccount){
                    mapDataIdVsAccountName.put(String.valueOf(objAccount.account.DCdataId__c),objAccount);
                }
                for(AccountContactRelation objACR: lstACR){
                    List<String> lstPrograms = new List<String>();
                    if(mapAccountVsACR.containsKey(objACR.accountId) && mapCaseVsApplicationDetail.containsKey(objACR.accountId) && mapCaseVsisHOH.containsKey(objACR.accountId)){
                        List<SSP_RepsAssistersAgentsController.programWrapper> lstProgramPermission = new  List<SSP_RepsAssistersAgentsController.programWrapper>();  
                        if(objACR.ProgramsApplied__c != null && objACR.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID) ){
                            lstPrograms.add(system.label.SSP_Medicaid);
                            lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programWrapper(system.label.SSP_Medicaid,objACR.PermissionLevel_Medicaid__c));
                        }
                        if(objACR.ProgramsApplied__c != null && objACR.ProgramsApplied__c.contains(SSP_GlobalConstants.KTAP)){
                            lstPrograms.add(system.label.SSP_KTAPLabel);
                            lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programWrapper(system.label.SSP_KTAPLabel,objACR.PermissionLevel_KTAP__c));
                            
                        }
                        if(objACR.ProgramsApplied__c != null && objACR.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP)){
                            lstPrograms.add(system.label.SSP_SNAPLabel);
                            lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programWrapper(system.label.SSP_SNAPLabel,objACR.PermissionLevel_SNAP__c));
                            
                        }
                        if(objACR.ProgramsApplied__c != null && objACR.ProgramsApplied__c.contains(SSP_GlobalConstants.STATE)){
                            lstPrograms.add(system.label.SSP_StateSupplementation);
                            lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programWrapper(system.label.SSP_StateSupplementation,objACR.PermissionLevel_StateSupp__c));
                            
                        }
                        if(objACR.ProgramsApplied__c != null && objACR.ProgramsApplied__c.contains(SSP_GlobalConstants.CHILDCARE)){
                            lstPrograms.add(system.label.SSP_ChildCareAssistance);
                            lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programWrapper(system.label.SSP_ChildCareAssistance,objACR.PermissionLevel_CCAP__c));
                            
                        }
                        if(objACR.ProgramsApplied__c != null && objACR.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP)){
                            lstPrograms.add(system.label.SSP_KIHIPPLabel);
                            lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programWrapper(system.label.SSP_KIHIPPLabel,objACR.PermissionLevel_KIHIPP__c));
                            
                        }                       
                        if(objACR.Roles!= null && (objACR.Roles.contains(SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING) || objACR.Roles.contains(SSP_GlobalConstants.ORGANISATION_AUTH_REP) 
                                                  || objACR.Roles.contains('Authorized Representative'))){
                                                      
                            setAuthRepContactIds.add(objACR.contact.Id);
                            if((!lstProgramPermission.isEmpty())){
                            SSP_RepsAssistersAgentsController.individualWrapper objIndividualWrapper = 
                                new SSP_RepsAssistersAgentsController.individualWrapper(mapCaseVsApplicationDetail.get(objACR.accountId),objACR.contact,lstProgramPermission,objACR,SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE,
                                                                                        String.join(lstPrograms, ','),mapCaseVsisHOH.get(objACR.accountId),(objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Name:'',
                                                                                                                       (objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null &&  mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.phone != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Phone:'',false,(objACR.contactId == currentUserContactId && mode != null && mode == 'intake'&& selectedRole != null && selectedRole != '' && SSP_GlobalConstants.AUTH_REP_ROLES.contains(selectedRole))?true:false, objACR.contactId != currentUserContactId);
                            lstIndividualRecords.add(objIndividualWrapper);
                            }else if(mode != null && mode == 'intake' && objACR.contactId == currentUserContactId){
                                  SSP_RepsAssistersAgentsController.individualWrapper objIndividualWrapper = 
                                new SSP_RepsAssistersAgentsController.individualWrapper(mapCaseVsApplicationDetail.get(objACR.accountId),objACR.contact,lstProgramPermission,objACR,SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE,
                                                                                        String.join(lstPrograms, ','),mapCaseVsisHOH.get(objACR.accountId),(objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Name:'',
                                                                                                                       (objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null &&  mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.phone != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Phone:'',false,false, false);
                            lstIndividualRecords.add(objIndividualWrapper);
                            }
                        }
                        if(objACR.Roles!= null && (objACR.Roles.contains(SSP_GlobalConstants.ASSISTER_ROLE) || objACR.Roles.contains(SSP_GlobalConstants.AGENCY_ADMIN_ROLE))){
                              if(objACR.contactId == currentUserContactId && mode != null && mode == 'intake' && objACR.RequestAccessPermission__c != NULL){
                                response.put('disableNext',true);
                            }
                          //  if(objACR.RequestAccessPermission__c == NULL){
                                 setAssisterContactIds.add(objACR.contact.Id);
                            SSP_RepsAssistersAgentsController.individualWrapper objAssiterWrapper = 
                                new SSP_RepsAssistersAgentsController.individualWrapper(mapCaseVsApplicationDetail.get(objACR.accountId),objACR.contact,lstProgramPermission,objACR,SSP_GlobalConstants.ASSISTER_ROLE,
                                                                                        String.join(lstPrograms, ','),mapCaseVsisHOH.get(objACR.accountId),(objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Name:'',
                                                                                        (objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null &&  mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Phone != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Phone:'',false,false, objACR.contactId != currentUserContactId);
                            lstAssisterRecords.add(objAssiterWrapper);
                           // }
                        }
                        if(objACR.Roles!= null && objACR.Roles.contains(SSP_GlobalConstants.INSURANCEAGENT_ROLE)){
                             setAgentContactIds.add(objACR.contact.Id);
                            SSP_RepsAssistersAgentsController.individualWrapper objInsuranceWrapper = 
                                new SSP_RepsAssistersAgentsController.individualWrapper(mapCaseVsApplicationDetail.get(objACR.accountId),objACR.contact,lstProgramPermission,objACR,SSP_GlobalConstants.INSURANCE_AGENT_ROLE,
                                                                                        String.join(lstPrograms, ','),mapCaseVsisHOH.get(objACR.accountId),(objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Name:'',
                                                                                        (objACR.DCAgencyId__c != null && mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)) != null &&  mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Phone != null) ?mapDataIdVsAccountName.get(String.valueOf(objACR.DCAgencyId__c)).account.Phone:'',false,false,  objACR.contactId != currentUserContactId);
                            lstInsuranceAgentRecords.add(objInsuranceWrapper);
                        }
                    }
                    
                }
                if(sspApplicationId != null && sspApplicationId != '' && mode != null && mode == 'intake' && (setAuthRepContactIds.isEmpty() || ((!setAuthRepContactIds.isEmpty()) && (!setAuthRepContactIds.contains(currentUserContactId)))) &&  SSP_GlobalConstants.AUTH_REP_ROLES.contains(selectedRole) &&                  
                   (!lstAccount.isEmpty())){
                       response.put('disableNext',true);
                        SSP_RepsAssistersAgentsController.individualWrapper objIndividualWrapper =  new SSP_RepsAssistersAgentsController.individualWrapper(mapCaseVsApplicationDetail.get(lstAccount[0].id),accessRequestContact,null,null,SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE,
                                                                                                                                                           '',true,'','',true,false, false);
                            lstIndividualRecords.add(objIndividualWrapper);
                    
                }
                if(sspApplicationId != null && sspApplicationId != '' && mode != null && mode == 'intake' && (setAssisterContactIds.isEmpty() || ((!setAssisterContactIds.isEmpty()) && (!setAssisterContactIds.contains(currentUserContactId)))) &&  SSP_GlobalConstants.ASSISTER_ROLES.contains(selectedRole) &&  (!lstAccount.isEmpty())){
                    response.put('disableNext',true);
                        SSP_RepsAssistersAgentsController.individualWrapper objIndividualWrapper =  new SSP_RepsAssistersAgentsController.individualWrapper(mapCaseVsApplicationDetail.get(lstAccount[0].id),accessRequestContact,null,null,SSP_GlobalConstants.ASSISTER_ROLE,
                                                                                                                                                        '',true,'','',true,false, false);
                            lstAssisterRecords.add(objIndividualWrapper);
                    
                }
                if(sspApplicationId != null && sspApplicationId != '' && mode != null && mode == 'intake' && (setAgentContactIds.isEmpty() || ((!setAgentContactIds.isEmpty()) && (!setAgentContactIds.contains(currentUserContactId)))) &&   selectedRole == SSP_GlobalConstants.INSURANCEAGENT_ROLE && (!lstAccount.isEmpty())){
                        SSP_RepsAssistersAgentsController.individualWrapper objIndividualWrapper =  new SSP_RepsAssistersAgentsController.individualWrapper(mapCaseVsApplicationDetail.get(lstAccount[0].id),accessRequestContact,null,null,SSP_GlobalConstants.INSURANCE_AGENT_ROLE,
                                                                                                                                                        '',true,'','',true,false, false);
                            lstInsuranceAgentRecords.add(objIndividualWrapper);
                    
                }
                if(!lstIndividualRecords.isEmpty()){
                    response.put('authorizedRepresentativeRecords',JSON.serialize(lstIndividualRecords));
                }
                if(!lstAssisterRecords.isEmpty()){
                    response.put('assistRecords',JSON.serialize(lstAssisterRecords));
                }
                if(!lstInsuranceAgentRecords.isEmpty()){
                    response.put('insuranceAgentRecords',JSON.serialize(lstInsuranceAgentRecords));
                }
                if(strPrograms != null && strPrograms != '' && (strPrograms.contains(SSP_GlobalConstants.MEDICAID) || strPrograms.contains(SSP_GlobalConstants.KHIPP))  && sspMemberId != null ){
                    
                    response.put('hasMedicaid',true);
                }
                if(isHOH && strPrograms != null && strPrograms != '' && (strPrograms.contains(SSP_GlobalConstants.MEDICAID) || strPrograms.contains(SSP_GlobalConstants.CHILDCARE) || strPrograms.contains(SSP_GlobalConstants.STATE) || strPrograms.contains(SSP_GlobalConstants.SNAP) || strPrograms.contains(SSP_GlobalConstants.KTAP) || strPrograms.contains(SSP_GlobalConstants.KHIPP))){                  
                    response.put('hasRequiredPrograms',true);
                }
                if(isHOH){
                    response.put('isHeadOfHousehold',true);
                }
                if(objMatrix != null && objMatrix.canDelete){
                    response.put('showRemove',true);
                }
                if((objMatrix != null && objMatrix.canDelete) || (String.isNotBlank(selectedRole) && SSP_GlobalConstants.ASSISTER_ROLES.contains(selectedRole))){
                    response.put('showRemoveAuthRep',true);
                }              
                if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='Editable'){
                    response.put('showEdit',true);
                }
                if((objMatrix != null && objMatrix.fieldPermissions != null && objMatrix.fieldPermissions.get('REPS_HOME_18') != null
                   && objMatrix.fieldPermissions.get('REPS_HOME_18') != '' &&  objMatrix.fieldPermissions.get('REPS_HOME_18') != 'NotAccessible')){
                       response.put('showAddButton',true);
                   }
            }else{
                response.put('hasNoContext',true);
                return response;
            }
            
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_RepsAssistersAgentsController', 'getRepsAssistersAgentsDetails', 'Failed to fetch Details in getRepsAssistersAgentsDetails Method', true);  
        }
        return response;
    }
    
     public static List<AccountContactRelation> checkExistingAssociation(string accountId,String contactId){ 
         List<AccountContactRelation> lstExistingAssociation = new  List<AccountContactRelation>();
        Boolean hasExistingACR= false;
      lstExistingAssociation = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','account.Name','account.DCdataId__c','Roles','dcAgencyId__c','dcContactId__c','account.Phone','RequestAccessPermission__c'}, 
                                                                              new Map<String, String>{'limit'=>'1000','accountId'=>accountId,'contactId'=>contactId});
       
         return lstExistingAssociation;
     }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @methodname   removeRepsAssistersAgentsDetails
* @description  This methods is used to remove RepsAssistersAgentsDetails
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse removeRepsAssistersAgentsDetails(id relationId,String role,string applicationId){ 
         SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();   
        List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
        List<SSP_Application__c> lstApplication = new List<SSP_Application__c>();
        SSP_UpdateDCRepResponseWrapper serviceResponse =  new SSP_UpdateDCRepResponseWrapper();
        String isUpdateAgencySuccess = '';
        contact contactForInterface;
        try{
             if(applicationId != null && applicationId != ''){
            SSP_LightningResponse objResponse = new SSP_LightningResponse();           
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(applicationId);
            if(objResponse != null && objResponse.mapResponse != null && (!objResponse.mapResponse.containsKey('hasAccess'))){
            response.put('hasNoAccess',true);
            response.bIsSuccess = true;
            return response;    
            }
            }
            lstACR = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                     new Set<String>{'Id','Roles','IsDeleted__c','ContactId','StartDate','PermissionLevel_Medicaid__c','PermissionLevel_SNAP__c','PermissionLevel_StateSupp__c'
                                                                         ,'PermissionLevel_KIHIPP__c','PermissionLevel_KTAP__c',
                                                                         'PermissionLevel_CCAP__c','ProgramsApplied__c','IsRepresentativeVerified__c','DCRepresentativeId__c','RepresentativeRelationshipCode__c'}, 
                                                                     new Map<String, String>{'limit'=>'1000','Id'=> relationId});
            if(applicationId != null && applicationId != ''){
                lstApplication = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','IsApplicantAuthorizedRepresentative__c','Account__c','DCCaseNumber__c','ProgramsApplied__c','Name'}, 
                                                                              new Map<String, String>{'limit'=>'1','Id'=>applicationId});
                
                
            }
            
            if(!lstACR.isEmpty() &&  lstACR[0].Roles != null){
                contactForInterface = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                           new Set<String>{'id','AgencyOrOrganization__r.DCDataId__c','IndividualId__c','DCDataId__c','Phone'}, 
                                                                           new Map<String, String>{'Id'=>lstACR[0].contactId})[0];
                lstACR[0].isDeleted__c = true;
                List<String> lstRoles = lstACR[0].Roles.Split(';');
                if((!lstRoles.isEmpty()) && lstRoles.size() > 1){
                    Integer j = 0;
                    String strRoles;
                    while (j < lstRoles.size())
                    {
                        if(lstRoles[j] == role)
                        {
                            lstRoles.remove(j);
                        }else
                        {
                            j++;
                        }
                    }
                    strRoles = String.join(lstRoles, ';');
                    lstACR[0].Roles = strRoles;                   
                    ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
                    ESAPI.accessController().updateAsUser(lstACR[0], SSP_Utility.getFieldsNamesObject(lstACR[0]));
                    response.put('isSuccess', true);
                }else if((!lstRoles.isEmpty()) && lstRoles.size() == 1){  
                    SSP_TrackDeletion__c objTrackDeletion= new SSP_TrackDeletion__c();
                    objTrackDeletion.SSP_Application__c = applicationId;
                    objTrackDeletion.SalesforceId__c =  lstACR[0].id;
                    if(role == SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE){
                        objTrackDeletion.Source__c = 'Representative';   
                    }else{
                        objTrackDeletion.Source__c = 'AgentAssister';    
                    }
                    objTrackDeletion.SFObject__c = 'AccountContactRelation';
                    if( lstACR[0] != NULL && lstACR[0].DCRepresentativeId__c != null && applicationId != null && (!lstApplication.isEmpty()) &&  lstApplication[0].DCCaseNumber__c != null && (role == SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE|| role == SSP_GlobalConstants.ORGANISATION_AUTH_REP)){
                        Map<String, Object> mapInputParams = new Map<String, Object> ();
                        mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_APP_ID, applicationId);
                        mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_ACR, lstACR[0]);
                        mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_CONTACT_ID,lstACR[0].contactId);
                        mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_TrackDeletion, objTrackDeletion);
                        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_UPDATE_DC_REPRESENTATIVE, mapInputParams);
                        If(objList!= null && !objList.isEmpty()){
                            serviceResponse = (SSP_UpdateDCRepResponseWrapper) objList[0];
                            
                        }
                        if(serviceResponse != null && serviceResponse.AckResponse != null &&  serviceResponse.AckResponse.success){   
                            isUpdateAgencySuccess ='true';   
                            
                        }else if(lstACR[0].id != null && serviceResponse != null && serviceResponse.AckResponse.Error != null &&  serviceResponse.AckResponse.Error.CHFSExceptionId != null){                 
                            response.put('ERROR', serviceResponse.AckResponse.Error.CHFSExceptionId); 
                        }else if(lstACR[0].id != null && serviceResponse != null && serviceResponse.AckResponse.Error != null &&  serviceResponse.AckResponse.Error.ErrorCode != null){                
                            response.put('ERROR', serviceResponse.AckResponse.Error.ErrorCode); 
                        }
                        
                    }
                    if( lstACR[0].id != null && (!lstApplication.isEmpty()) && role != SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE && role != SSP_GlobalConstants.ORGANISATION_AUTH_REP){
                        isUpdateAgencySuccess = ( lstApplication[0].DCCaseNumber__c != null)? SSP_AgentAssistorController.triggerUpdateAgentAssisterService(lstApplication[0],contactForInterface,role,true,'',''):'true';
                    }
                    if(lstACR[0].id != null &&  (isUpdateAgencySuccess =='true' ||  lstApplication[0].DCCaseNumber__c == null)){               
                        
                        ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
                        ESAPI.accessController().deleteAsUser(lstACR);  
                        ESAPI.accessController().insertAsUser(objTrackDeletion, SSP_Utility.getFieldsNamesObject(objTrackDeletion)); 
                        List<contact> userList = new   List<contact>();
                        
                        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                        String individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
                        
                        if(individualId != null && individualId != ''){  
                            
                               userList =SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                           new Set<String>{'Id', 'FirstName','LastName','IndividualId__c','Email','GenderCode__c','BirthDate'}, 
                                                                           new Map<String, String>{'IndividualId__c'=>individualId}); 
                            
                        }
                        if(!userList.isEmpty()){
                            SSP_ProgramSelectionService.resetDashboardRefreshFlag(userList[0].Id); 
                        }
                        response.put('isSuccess', true);               
                    }else if (lstACR[0].id != null && isUpdateAgencySuccess !='true' && role != SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE){
                        response.put('ERROR', isUpdateAgencySuccess);
                    }
                } 
                
            }
        }catch(Exception e){
            response.put('isSuccess', false);
            LOG_LogMessageUtility.logMessage(e, 'SSP_RepsAssistersAgentsController', 'removeRepsAssistersAgentsDetails', 'Failed to fetch Details in getRepsAssistersAgentsDetails Method', true);  
        }
        return response;
    }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @methodname   getProgramCaseDetails
* @description  This methods is used to get details for Add Authorized Representative - Permissions Screen
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getProgramCaseDetails(String relationId,String sspApplicationId){
         SSP_Utility.isAuthenticatedUser();
        Id sspMemberId;
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<AccountcontactRelation> lstACR = new List<AccountContactRelation>();
         List<User> UserList = new List<User>();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        List<SSP_Application__c> lstApplication = new List<SSP_Application__c>();
        List<SSP_RepsAssistersAgentsController.picklistWrapper> lstCase = new List<SSP_RepsAssistersAgentsController.picklistWrapper>();
        List<Account> lstAccount = new List<Account>();  
        List< SSP_RepsAssistersAgentsController.picklistWrapper> medicaidOptions = new  List< SSP_RepsAssistersAgentsController.picklistWrapper>();
        List< SSP_RepsAssistersAgentsController.picklistWrapper> snapOptions = new  List< SSP_RepsAssistersAgentsController.picklistWrapper>();
        List< SSP_RepsAssistersAgentsController.picklistWrapper> ktapOptions = new  List< SSP_RepsAssistersAgentsController.picklistWrapper>();
        List< SSP_RepsAssistersAgentsController.picklistWrapper> stateOptions = new  List< SSP_RepsAssistersAgentsController.picklistWrapper>();
        List< SSP_RepsAssistersAgentsController.picklistWrapper> childOptions = new  List< SSP_RepsAssistersAgentsController.picklistWrapper>();
        List< SSP_RepsAssistersAgentsController.picklistWrapper> khippOptions = new  List< SSP_RepsAssistersAgentsController.picklistWrapper>();    
        Set<Id> lstAccountIds = new Set<Id>();
        Set<Id> lstApplicationIds = new Set<Id>();    
        Map<Id,String> mapCaseVsApplication =  new Map<Id,String>();
        Map<String,String> mapCaseProgramVsPermissions = new  Map<String,String>();
        Map<String,Map<String,String>> mapCaseVsExistingPermissions = new   Map<String,Map<String,String>>();
        Map<Id,List<SSP_ApplicationIndividual__c>> mapAccountVsAppIndividual =  new Map<Id,List<SSP_ApplicationIndividual__c>>();
        Map<String,String> mapApplicationVsPrograms = new   Map<String,String>();       
        Map<String,List<SSP_RepsAssistersAgentsController.programPermissionWrapper>> mapCaseVsPrograms =  new Map<String,List<SSP_RepsAssistersAgentsController.programPermissionWrapper>>();
        
        try{
             if(sspApplicationId != null && sspApplicationId != ''){
            SSP_LightningResponse objResponse = new SSP_LightningResponse();           
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(sspApplicationId);
            if(objResponse != null && objResponse.mapResponse != null && (!objResponse.mapResponse.containsKey('hasAccess'))){
            response.put('hasNoAccess',true);
            response.bIsSuccess = true;
            return response;    
            }
            }
            //sspMemberId = SSP_Utility.getCurrentUserMemberId(true);
             Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                     
          
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
            if( selectedRole != SSP_GlobalConstants.CITIZEN_ROLE && !String.isBlank(sspApplicationId) ){
                List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(sspApplicationId,new set<string>{});
                if(applicationIndividuals != null && !applicationIndividuals.isEmpty()){
                    sspMemberId = applicationIndividuals[0].SSP_Member__c;
                }
            }else{
            sspMemberId = getMemberId(false);
            }
            Schema.DescribeFieldResult fieldResult = AccountContactRelation.PermissionLevel_Medicaid__c.getDescribe();
            List<Schema.PicklistEntry> lstPermissionsOptions = fieldResult.getPicklistValues();
            
            for(Schema.PicklistEntry objOption:lstPermissionsOptions){
                if(objOption.value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST){
                    medicaidOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                    snapOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                    ktapOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                    stateOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                    childOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                    khippOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                }
                if(objOption.value == SSP_GlobalConstants.AUTH_REP_PERMISSION_NT){
                    medicaidOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));                   
                    childOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                }
                if(objOption.value == SSP_GlobalConstants.AUTH_REP_PERMISSION_SE || objOption.value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ET){
                    snapOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                    ktapOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));
                }
                
                if(objOption.value == SSP_GlobalConstants.CHILDCARE || objOption.value == SSP_GlobalConstants.AUTH_REP_PERMISSION_CA || objOption.value == SSP_GlobalConstants.AUTH_REP_PERMISSION_PY){
                    childOptions.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objOption.label,objOption.value));                   
                }
                
            }
            if(selectedRole != null && selectedRole != '' && SSP_GlobalCOnstants.AUTH_REP_ROLES.contains(selectedRole)){
              UserList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                  new Set<String>{'Id', 'ContactId','Contact.FirstName','contact.LastName','contact.DCDataId__c'}, 
                                                  new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
            }
            
            if(sspMemberId != null && sspApplicationId != null && sspApplicationId != ''){
                
                lstApplicationIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                                            new Set<String>{'Id','SSP_Application__c','SSP_Application__r.Status__c','SSP_Application__r.DCCaseNumber__c','SSP_Application__r.Name','IsHeadOfHousehold__c','ssp_application__r.ApplicationCreationInSSP__c','SSP_Application__r.RecordType.DeveloperName',
                                                                                                                'SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c', 'SSP_Member__r.Email__c', 'SSP_Member__r.PrimaryPhoneNumber__c', 'SSP_Member__r.PreferredNotificationMethodCode__c',
                                                                                                                 'SSP_Member__r.PreferredWrittenLanguageCode__c','SSP_Application__r.ProgramsApplied__c','SSP_Application__r.LastModifiedDate','SSP_Member__r.IndividualId__c'}, 
                                                                                                            new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> sspMemberId,'IsHeadOfHousehold__c'=>'true','SSP_Application__c'=>sspApplicationId});
            }else if(sspMemberId != null){
                 lstApplicationIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                                            new Set<String>{'Id','SSP_Application__c','SSP_Application__r.Status__c','SSP_Application__r.DCCaseNumber__c','SSP_Application__r.Name','IsHeadOfHousehold__c','ssp_application__r.ApplicationCreationInSSP__c','SSP_Application__r.RecordType.DeveloperName',
                                                                                                                'SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c', 'SSP_Member__r.Email__c', 'SSP_Member__r.PrimaryPhoneNumber__c', 'SSP_Member__r.PreferredNotificationMethodCode__c',
                                                                                                                 'SSP_Member__r.PreferredWrittenLanguageCode__c','SSP_Application__r.ProgramsApplied__c','SSP_Application__r.LastModifiedDate','SSP_Member__r.IndividualId__c'}, 
                                                                                                            new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> sspMemberId,'IsHeadOfHousehold__c'=>'true'});
            }
            
            for(SSP_ApplicationIndividual__c objAppIndividual: lstApplicationIndividual){
                if((objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null && (8 - (objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(SSP_utility.today())) >= 0)  && (objAppIndividual.SSP_Application__r.RecordType.DeveloperName=='SSP_Application')  && (objAppIndividual.ssp_application__r.Status__c == 'UN')) ||
                   ((objAppIndividual.SSP_Application__r.RecordType.DeveloperName=='Case') && objAppIndividual.ssp_application__r.DCCaseNumber__c != null)
                  ){
                      lstApplicationIds.add(objAppIndividual.SSP_Application__c); 
                  }
            }
            if(!lstApplicationIds.isEmpty()){                    
                
                lstApplication = SSP_ApplicationSelector.queryApplicationProgramData(new Set<String>{'Id', '(SELECT id,ProgramsApplied__c FROM SSP_ApplicationIndividuals__r)', 'Account__c','Status__c','DCCaseNumber__c','Name','ProgramsApplied__c','LastModifiedDate'}, 
                                                                                     lstApplicationIds,false);
            }
            for(SSP_Application__c objApplication: lstApplication){
                mapAccountVsAppIndividual.put(objApplication.Account__c,objApplication.SSP_ApplicationIndividuals__r);
                
            }
            
            for(SSP_Application__c objApplication: lstApplication){ 
                String strPrograms;
                Map<String,String> mapProgramsVsPermissions = new Map<String,String>();
                lstAccountIds.add(objApplication.Account__c);
                if(mapAccountVsAppIndividual.get(objApplication.Account__c) != null 
                  ){
                      // for(SSP_ApplicationIndividual__c objAppIndividual: mapAccountVsAppIndividual.get(objApplication.Account__c)){
                      if(objApplication.ProgramsApplied__c != null && strPrograms != null){
                          strPrograms = strPrograms + objApplication.ProgramsApplied__c + ';';
                      }else if(objApplication.ProgramsApplied__c != null){
                          strPrograms =  objApplication.ProgramsApplied__c + ';';
                      }
                      // }
                      mapApplicationVsPrograms.put(String.valueOf(objApplication.Account__c),strPrograms);
                  }
            }
            
            if(relationId != null && relationId != ''){
                lstACR = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                         new Set<String>{'accountId' ,'id','Roles','PermissionLevel_Medicaid__c','PermissionLevel_SNAP__c','PermissionLevel_StateSupp__c',
                                                                             'PermissionLevel_KIHIPP__c','PermissionLevel_KTAP__c','PermissionLevel_CCAP__c','ProgramsApplied__c'},
                                                                         new Map<String, String>{'limit'=>'1','id'=>relationId});   
                if(!lstACR.isEmpty()){
                    lstAccountIds.clear();
                    lstAccountIds.add(lstACR[0].accountId);
                }
            }
            if(!lstAccountIds.isEmpty()){
                lstAccount = SSP_AccountSelector.queryAccountData(new Map<String, String>{'objectName'=>'ACCOUNT','operator'=>'AND','hasToLabel'=>'true','IN'=>'id'}, 
                                                                  new Set<String>{'Id', '(SELECT Id,account__c,DCCaseNumber__c,Name,Recordtype.Developername from SSP_Applications__r)',
                                                                      '(SELECT accountId ,id,Roles'+
                                                                      ',PermissionLevel_Medicaid__c,PermissionLevel_SNAP__c,PermissionLevel_StateSupp__c'+
                                                                      ',PermissionLevel_KIHIPP__c,PermissionLevel_KTAP__c,'+
                                                                      'PermissionLevel_CCAP__c,ProgramsApplied__c,contact.OrganizationName__c,contact.AgencyOrOrganization__r.name,contact.AgencyOrOrganization__c,'+
                                                                      'contact.Street__c,contact.City__c,contact.SSP_State__c,contact.Zipcode5__c,contact.InsuranceCompany__c,'+
                                                                      'contact.Zipcode4__c,contact.mailingPostalCode,contact.AddressLine2__c,contact.countycode__c,toLabel(contact.PreferredLanguageCode__c)'+
                                                                      'FROM AccountContactRelations)'}, 
                                                                  new Map<String, String>{'limit'=>'1000','id'=>String.join(new List<Id>(lstAccountIds), ',')});
                
            }
            
            
            
            
            
            for(Account objAccount: lstAccount){
                String strMedicaidPermissions;
                String strKtapPermissions;
                String strChildCarePermissions;
                String strSnapPermissions;
                String strKhippPermissions;
                String strStatePermissions;
                Map<String,String> mapExistingProgramsVsPermissions = new Map<String,String>();             
                for(AccountContactRelation objRelation:objAccount.AccountContactRelations){
                    if(objRelation.PermissionLevel_Medicaid__c != null){
                        strMedicaidPermissions = strMedicaidPermissions + objRelation.PermissionLevel_Medicaid__c + ',';
                    }
                    if(objRelation.PermissionLevel_SNAP__c != null){
                        strSnapPermissions = strSnapPermissions + objRelation.PermissionLevel_SNAP__c+ ',';
                    }
                    if(objRelation.PermissionLevel_CCAP__c != null){
                        strChildCarePermissions = strChildCarePermissions + objRelation.PermissionLevel_CCAP__c+ ',';
                    }
                    if(objRelation.PermissionLevel_KIHIPP__c != null){
                        strKhippPermissions = strKhippPermissions + objRelation.PermissionLevel_KIHIPP__c+ ',';
                    }
                    if(objRelation.PermissionLevel_StateSupp__c != null){
                        strStatePermissions = strStatePermissions + objRelation.PermissionLevel_StateSupp__c+ ',';
                    }
                    if(objRelation.PermissionLevel_KTAP__c != null){
                        strKtapPermissions = strKtapPermissions + objRelation.PermissionLevel_KTAP__c+ ',';
                    }                         
                    
                }
                if( strMedicaidPermissions != null && strMedicaidPermissions != ''){
                    mapExistingProgramsVsPermissions.put(SSP_GlobalConstants.MEDICAID,strMedicaidPermissions);
                } if( strKtapPermissions != null && strKtapPermissions != ''){
                    mapExistingProgramsVsPermissions.put(SSP_GlobalConstants.KTAP,strKtapPermissions);
                }
                if( strStatePermissions != null && strStatePermissions != ''){
                    mapExistingProgramsVsPermissions.put(SSP_GlobalConstants.STATE,strStatePermissions);
                }
                if( strKhippPermissions != null && strKhippPermissions != ''){
                    mapExistingProgramsVsPermissions.put(SSP_GlobalConstants.KHIPP,strKhippPermissions);
                } if( strChildCarePermissions != null && strChildCarePermissions != ''){
                    mapExistingProgramsVsPermissions.put(SSP_GlobalConstants.CHILDCARE,strChildCarePermissions);
                } if( strSnapPermissions != null && strSnapPermissions != ''){
                    mapExistingProgramsVsPermissions.put(SSP_GlobalConstants.SNAP,strSnapPermissions);
                }
                
                if(!mapExistingProgramsVsPermissions.isEmpty()){
                    mapCaseVsExistingPermissions.put(objAccount.Id,mapExistingProgramsVsPermissions);    
                }
            }
            
            
            for(Account objAccount: lstAccount){
                List<String> lstPrograms = new List<String>();
                List<SSP_RepsAssistersAgentsController.programPermissionWrapper> lstProgramPermission = new  List<SSP_RepsAssistersAgentsController.programPermissionWrapper>();
                List<SSP_RepsAssistersAgentsController.picklistWrapper> lstMedicaidOptions = new List<SSP_RepsAssistersAgentsController.picklistWrapper>();
                lstMedicaidOptions.addAll(medicaidOptions);
                
                if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.MEDICAID) &&
                   ((mapCaseVsExistingPermissions.get(objAccount.Id) == null) || (mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.MEDICAID) == null))){
                       lstPrograms.add(system.label.SSP_Medicaid);
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_Medicaid,lstMedicaidOptions,SSP_GlobalConstants.MEDICAID,false,''));
                   }
                else if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.MEDICAID) 
                        && mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.MEDICAID) != null 
                       ){                              
                           
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.MEDICAID).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_ST)) 
                           {
                               Integer j = 0;
                               while (j < lstMedicaidOptions.size())
                               {
                                   if(lstMedicaidOptions[j].value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_Medicaid__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST ))))
                                   {
                                       lstMedicaidOptions.remove(j);
                                   }else 
                                   {
                                       j++;
                                   }
                                   
                               }   
                           }
                           
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.MEDICAID).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_NT))
                           {
                               Integer j = 0;
                               while (j < lstMedicaidOptions.size())
                               {
                                   if(lstMedicaidOptions[j].value == SSP_GlobalConstants.AUTH_REP_PERMISSION_NT && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_Medicaid__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_NT ))))
                                   {
                                       lstMedicaidOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                                   
                               }   
                               
                           }
                           if(!lstMedicaidOptions.isEmpty()){
                               lstPrograms.add(system.label.SSP_Medicaid);
                               if(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_Medicaid__c != null )){
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_Medicaid,lstMedicaidOptions,SSP_GlobalConstants.MEDICAID,true,lstACR[0].PermissionLevel_Medicaid__c));
                               }else {
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_Medicaid,lstMedicaidOptions,SSP_GlobalConstants.MEDICAID,false,'')); 
                               }
                               
                           }
                       }
                
                
                List<SSP_RepsAssistersAgentsController.picklistWrapper> lstKtapOptions = new List<SSP_RepsAssistersAgentsController.picklistWrapper>();
                lstKtapOptions.addAll(ktapOptions);
                if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.KTAP) &&
                   ((mapCaseVsExistingPermissions.get(objAccount.Id) == null) || (mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.KTAP) == null))){                   
                       lstPrograms.add(system.label.SSP_KTAP);
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_KTAPLabel,lstKtapOptions,SSP_GlobalConstants.KTAP,false,''));
                   }
                else if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.KTAP) 
                        && mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.KTAP) != null
                       ){                            
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.KTAP).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_ST)){
                               Integer j = 0;
                               while (j < lstKtapOptions.size())
                               {
                                   if(lstKtapOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_KTAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST ))))
                                   {
                                       lstKtapOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               } 
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.KTAP).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_SE)){
                               Integer j = 0; 
                               while (j < lstKtapOptions.size())
                               {
                                   if(lstKtapOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_SE && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_KTAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_SE ))))
                                       
                                   {
                                       lstKtapOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }   
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.KTAP).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_ET)){
                               Integer j = 0;
                               while (j < lstKtapOptions.size())
                               {
                                   if(lstKtapOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ET && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_KTAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_ET ))))
                                   {
                                       lstKtapOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }                               
                           }
                           if(!lstKtapOptions.isEmpty()){
                               lstPrograms.add(system.label.SSP_KTAP); 
                               if(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_KTAP__c != null )){
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_KTAPLabel,lstKtapOptions,SSP_GlobalConstants.KTAP,true,lstACR[0].PermissionLevel_KTAP__c));
                               }else {
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_KTAPLabel,lstKtapOptions,SSP_GlobalConstants.KTAP,false,''));
                               }
                           }
                       }
                
                List<SSP_RepsAssistersAgentsController.picklistWrapper> lstSnapOptions = new List<SSP_RepsAssistersAgentsController.picklistWrapper>();
                lstSnapOptions.addAll(snapOptions);
                if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.SNAP) 
                   && ((mapCaseVsExistingPermissions.get(objAccount.Id) == null) || (mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.SNAP) == null))){
                       lstPrograms.add(system.label.SSP_SNAP);
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_SNAPLabel,lstSnapOptions,SSP_GlobalConstants.SNAP,false,''));
                   }
                else if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.SNAP) 
                        && mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.SNAP) != null
                       ){
                           Boolean isExistingProgram = false;
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.SNAP).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_ST)){
                               Integer j = 0;
                               while (j < lstSnapOptions.size())
                               {
                                   if(lstSnapOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_SNAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST ))))
                                   {
                                       lstSnapOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }    
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.SNAP).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_SE) ){
                               Integer j = 0;
                               while (j < lstSnapOptions.size())
                               {
                                   if(lstSnapOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_SE && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_SNAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_SE ))))
                                   {
                                       lstSnapOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }       
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.SNAP).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_ET)){
                               Integer j = 0;
                               while (j < lstSnapOptions.size())
                               {
                                   if(lstSnapOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ET && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_SNAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_ET ))))
                                   {
                                       lstSnapOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }        
                           }
                           if(!lstSnapOptions.isEmpty()){
                               lstPrograms.add(system.label.SSP_SNAP);
                               if(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_SNAP__c != null )){
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_SNAPLabel,lstSnapOptions,SSP_GlobalConstants.SNAP,true,lstACR[0].PermissionLevel_SNAP__c));
                               }else {
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_SNAPLabel,lstSnapOptions,SSP_GlobalConstants.SNAP,false,''));
                               }
                           }
                           
                       }  
                
                
                
                List<SSP_RepsAssistersAgentsController.picklistWrapper> lstChildOptions= new List<SSP_RepsAssistersAgentsController.picklistWrapper>();
                lstChildOptions.addAll(childOptions);
                if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.CHILDCARE) 
                   && ((mapCaseVsExistingPermissions.get(objAccount.Id) == null) || (mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.CHILDCARE) == null))){
                       lstPrograms.add(system.label.SSP_ChildCareAssistance);
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_ChildCareAssistance,lstChildOptions,SSP_GlobalConstants.CHILDCARE,false,''));
                   }
                else if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.CHILDCARE) 
                        && mapCaseVsExistingPermissions.get(objAccount.Id) != null  && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.CHILDCARE) != null
                       ){                           
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.CHILDCARE).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_ST)){
                               Integer j = 0;
                               while (j < lstChildOptions.size())
                               {
                                   if(lstChildOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_CCAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_ST ))))
                                   {
                                       lstChildOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }        
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.CHILDCARE).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_NT)){
                               Integer j = 0;
                               while (j < lstChildOptions.size())
                               {
                                   if(lstChildOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_NT && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_CCAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_NT ))))
                                   {
                                       lstChildOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }           
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.CHILDCARE).contains(SSP_GlobalConstants.CHILDCARE) ){
                               Integer j = 0;
                               while (j < lstChildOptions.size())
                               {
                                   if(lstChildOptions.get(j).value == SSP_GlobalConstants.CHILDCARE && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_CCAP__c == SSP_GlobalConstants.CHILDCARE ))))
                                   {
                                       lstChildOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }          
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.CHILDCARE).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_CA)){
                               Integer j = 0;
                               while (j < lstChildOptions.size())
                               {
                                   if(lstChildOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_CA && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_CCAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_CA ))))
                                   {
                                       lstChildOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }          
                           }
                           if(mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.CHILDCARE).contains(SSP_GlobalConstants.AUTH_REP_PERMISSION_PY)){
                               Integer j = 0;
                               while (j < lstChildOptions.size())
                               {
                                   if(lstChildOptions.get(j).value == SSP_GlobalConstants.AUTH_REP_PERMISSION_PY && 
                                      (!(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_CCAP__c == SSP_GlobalConstants.AUTH_REP_PERMISSION_PY ))))
                                   {
                                       lstChildOptions.remove(j);
                                   }else
                                   {
                                       j++;
                                   }
                               }          
                           }
                           if(!lstChildOptions.isEmpty()){
                               lstPrograms.add(system.label.SSP_ChildCareAssistance);
                               if(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_CCAP__c != null )){
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_ChildCareAssistance,lstChildOptions,SSP_GlobalConstants.CHILDCARE,true,lstACR[0].PermissionLevel_CCAP__c));
                               }else{
                                   lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_ChildCareAssistance,lstChildOptions,SSP_GlobalConstants.CHILDCARE,false,''));
                               }
                           } 
                       }
                
                if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.STATE) 
                   && ((mapCaseVsExistingPermissions.get(objAccount.Id) == null) || (mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.STATE) == null))){
                       lstPrograms.add(system.label.SSP_StateSupplementation);                       
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_StateSupplementation,stateOptions,SSP_GlobalConstants.STATE,false,''));   
                       
                   }else if(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_StateSupp__c != null )){
                       
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_StateSupplementation,stateOptions,SSP_GlobalConstants.STATE,true,lstACR[0].PermissionLevel_StateSupp__c));
                   }
                if(mapApplicationVsPrograms.get(objAccount.Id) != null && mapApplicationVsPrograms.get(objAccount.Id).contains(SSP_GlobalConstants.KHIPP) 
                   && ((mapCaseVsExistingPermissions.get(objAccount.Id) == null) || (mapCaseVsExistingPermissions.get(objAccount.Id) != null && mapCaseVsExistingPermissions.get(objAccount.Id).get(SSP_GlobalConstants.KHIPP) == null))){
                       lstPrograms.add(system.label.SSP_KIHIPP);
                       
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_KIHIPPLabel,khippOptions,SSP_GlobalConstants.KHIPP,false,''));      
                       
                   }else if(!lstACR.isEmpty() && (lstACR[0].PermissionLevel_KIHIPP__c != null )){                          
                       lstProgramPermission.add(new SSP_RepsAssistersAgentsController.programPermissionWrapper(system.label.SSP_KIHIPPLabel,khippOptions,SSP_GlobalConstants.KHIPP,true,lstACR[0].PermissionLevel_KIHIPP__c));
                   }
                
                
                if((!objAccount.SSP_Applications__r.isEmpty()) && objAccount.SSP_Applications__r[0].DCCaseNumber__c != NULL && !lstProgramPermission.isEmpty() &&  objAccount.SSP_Applications__r[0].recordtype.DeveloperName == 'Case'){                       
                    lstCase.add(new SSP_RepsAssistersAgentsController.picklistWrapper(String.valueOf(objAccount.SSP_Applications__r[0].DCCaseNumber__c)+' #: '+String.join(lstPrograms,','),objAccount.Id));
                    mapCaseVsPrograms.put(objAccount.Id,lstProgramPermission);
                } else if((!objAccount.SSP_Applications__r.isEmpty()) && objAccount.SSP_Applications__r[0].Name != NULL && !lstProgramPermission.isEmpty()){                       
                    lstCase.add(new SSP_RepsAssistersAgentsController.picklistWrapper(objAccount.SSP_Applications__r[0].Name+' #: '+String.join(lstPrograms,','),objAccount.Id));
                    mapCaseVsPrograms.put(objAccount.Id,lstProgramPermission);
                }
            }
            
            
            if(!mapCaseVsPrograms.isEmpty() && !lstCase.isEmpty()){
                response.put('casePrograms',JSON.serialize(mapCaseVsPrograms));
                response.put('lstCaseOptions',lstCase); 
                
            }
            if(!userList.isEmpty()){
               
                response.put('authRepDetails',JSON.serialize(userList[0])); 
            }
            if((!userList.isEmpty()) && (!mapCaseVsPrograms.isEmpty()) && (!lstCase.isEmpty())){
               	List<SSP_RepsAssistersAgentsController.programPermissionWrapper> lstProgramPermission = new List<SSP_RepsAssistersAgentsController.programPermissionWrapper>();
                Map<String,String> mapProgramVsPermissionForRequest =new  Map<String,String>();
                if(mapCaseVsPrograms.get(lstCase[0].value) != null){
                lstProgramPermission = mapCaseVsPrograms.get(lstCase[0].value);
                }
                for(SSP_RepsAssistersAgentsController.programPermissionWrapper objPermission : lstProgramPermission){
                    mapProgramVsPermissionForRequest.put(objPermission.programId,objPermission.permission);
                    
                    }
                if(!mapProgramVsPermissionForRequest.isEmpty()){
                     response.put('existingPermissionsForAuthRepRole',JSON.serialize(mapProgramVsPermissionForRequest)); 
                }
               
            }
            if((!userList.isEmpty()) && (!lstApplicationIndividual.isEmpty())){
                response.put('applicationData',JSON.serialize(lstApplicationIndividual[0])); 
            }
            
            
            
        }catch(Exception e){
            response.put('isSuccess', false);
            LOG_LogMessageUtility.logMessage(e, 'SSP_RepsAssistersAgentsController', 'getProgramCaseDetails', 'Failed to fetch Details in getProgramCaseDetails Method', true);  
        }
        return response;
    }
    /***************************************************************************************************
* @author      Kireeti Gora
* @date         02/02/2020
* @methodname   updateACRRecords
* @description  This methods is used to update ACR records
* @return       Boolean
*****************************************************************************************************/   
    @AuraEnabled
    public static String updateACRRecords(String relationJSON,String sspApplicationId){
         SSP_Utility.isAuthenticatedUser();
        Boolean result = true;
        String ErrorCode = '';
        String applicationAccountId='';
        String requestAccessId='';
        Boolean hasExistingAssociation = false;
        try{
              if(sspApplicationId != null && sspApplicationId != ''){
            SSP_LightningResponse objResponse = new SSP_LightningResponse();           
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(sspApplicationId);
            if(objResponse != null && objResponse.mapResponse != null && (!objResponse.mapResponse.containsKey('hasAccess'))){
            ErrorCode = 'No Access';
            return ErrorCode;    
            }
            }
            List<AccountContactRelation> acrList=new List<AccountContactRelation>();
             List<AccountContactRelation> acrListForAgency=new List<AccountContactRelation>();
            List<SSP_Application__c> objApplication = new List<SSP_Application__c>();
            AccountContactRelation objACR = (AccountContactRelation)JSON.deserialize(relationJSON, AccountContactRelation.class);
            List<AccountContactRelation> lstACR = new List<AccountContactRelation>(); 
            SSP_UpdateDCRepResponseWrapper response =  new SSP_UpdateDCRepResponseWrapper();        
            
          
            
            if(sspApplicationId != null && sspApplicationId != ''){
                objApplication = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','IsApplicantAuthorizedRepresentative__c','DCCaseNumber__c','account__r.Id'}, 
                                                                              new Map<String, String>{'limit'=>'1','Id'=>sspApplicationId});
                if(!objApplication.isEmpty() &&  objApplication[0].IsApplicantAuthorizedRepresentative__c != 'Y'){
                    
                    objApplication[0].IsApplicantAuthorizedRepresentative__c = 'Y';
                }
                 applicationAccountId = (!objApplication.isEmpty())?  objApplication[0].Account__r.Id:null;          
            }
          
             if(objACR.contactId != null && objACR.Id == null && applicationAccountId != null){
                 List<AccountContactRelation> lstACRWithPendingRequest = new List<AccountContactRelation>();
                   lstACRWithPendingRequest = checkExistingAssociation(applicationAccountId,objACR.contactId);
                 if((!lstACRWithPendingRequest.isEmpty()) && lstACRWithPendingRequest[0] != null && lstACRWithPendingRequest[0].Id != null) {
                       objACR.Id =   lstACRWithPendingRequest[0].Id;
                     if(lstACRWithPendingRequest[0].RequestAccessPermission__c != null){
            			requestAccessId = lstACRWithPendingRequest[0].Id;
                     }
                 }
                 if((!lstACRWithPendingRequest.isEmpty()) && lstACRWithPendingRequest[0] != null && lstACRWithPendingRequest[0].RequestAccessPermission__c == null &&lstACRWithPendingRequest[0].Roles != null && lstACRWithPendingRequest[0].Roles != SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE && lstACRWithPendingRequest[0].Roles != SSP_GlobalConstants.ORGANISATION_AUTH_REP){
                     hasExistingAssociation =true;
                 }
            }
             if(hasExistingAssociation){
                ErrorCode = 'User is already assocaited with the case.';
                return ErrorCode;
            }
            if(requestAccessId != null && requestAccessId != ''){
                List<SSP_Notifications__c> lstNotifications = new List<SSP_Notifications__c>();
                lstNotifications = [SELECT id,Linked_Record_Id__c,Status__c  FROM SSP_Notifications__c Where Linked_Record_Id__c=:requestAccessId AND 
                                    notificationCode__c ='SF-TOD-002' AND Status__c = 'Active'];
                for(SSP_Notifications__c objNotification: lstNotifications){
                    objNotification.status__c = 'Expired';
                }
                UPDATE lstNotifications;
            }
            if(objACR.Id != null){
                lstACR = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                         new Set<String>{'Id','ProgramsApplied__c','IsDeleted__c','ContactId','StartDate','PermissionLevel_Medicaid__c','PermissionLevel_SNAP__c','PermissionLevel_StateSupp__c'
                                                                             ,'PermissionLevel_KIHIPP__c','PermissionLevel_KTAP__c','Roles','dcAgencyId__c','dcContactId__c',
                                                                             'PermissionLevel_CCAP__c','IsRepresentativeVerified__c','DCRepresentativeId__c','RepresentativeRelationshipCode__c','RequestAccessPermission__c'}, 
                                                                         new Map<String, String>{'limit'=>'1000','Id'=> objAcr.Id});
                
                
            }
            if(!lstACR.isEmpty() && lstACR[0].ProgramsApplied__c != null){               
                List<String> lstPrograms = lstACR[0].ProgramsApplied__c.Split(';');               
                objACR.StartDate =  lstACR[0].StartDate!= null?  lstACR[0].StartDate:null;
                objACR.IsRepresentativeVerified__c =  lstACR[0].IsRepresentativeVerified__c!= null?  lstACR[0].IsRepresentativeVerified__c:null;
                objACR.DCRepresentativeId__c =  lstACR[0].DCRepresentativeId__c!= null?  lstACR[0].DCRepresentativeId__c:null;
               	objACR.DCAgencyId__c = lstACR[0].DCAgencyId__c!= null?  lstACR[0].DCAgencyId__c:null;
                	objACR.DCContactId__c = lstACR[0].DCContactId__c!= null?  lstACR[0].DCContactId__c:null;
                
                If((!lstPrograms.contains(SSP_GlobalConstants.MEDICAID)) && objACR.PermissionLevel_Medicaid__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.MEDICAID);
                    
                }
                If((!lstPrograms.isEmpty()) && (!lstPrograms.contains(SSP_GlobalConstants.SNAP)) && objACR.PermissionLevel_SNAP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.SNAP);
                    
                }
                If((!lstPrograms.isEmpty()) && (!lstPrograms.contains(SSP_GlobalConstants.KTAP)) && objACR.PermissionLevel_KTAP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.KTAP);
                    
                }
                If((!lstPrograms.isEmpty()) && (!lstPrograms.contains(SSP_GlobalConstants.CHILDCARE)) && objACR.PermissionLevel_CCAP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.CHILDCARE);
                    
                }
                If((!lstPrograms.isEmpty()) && (!lstPrograms.contains(SSP_GlobalConstants.KHIPP)) && objACR.PermissionLevel_KIHIPP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.KHIPP);
                    
                }
                If((!lstPrograms.isEmpty()) && (!lstPrograms.contains(SSP_GlobalConstants.STATE)) && objACR.PermissionLevel_StateSupp__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.STATE);
                    
                }
                Integer j = 0;  
                while (j < lstPrograms.size())
                {
                    if(lstPrograms[j] == SSP_GlobalConstants.MEDICAID && objACR.PermissionLevel_Medicaid__c == null)
                    {
                        lstPrograms.remove(j);
                    }else if(lstPrograms[j] == SSP_GlobalConstants.SNAP && objACR.PermissionLevel_SNAP__c == null)
                    {
                        lstPrograms.remove(j);
                    }else if(lstPrograms[j] == SSP_GlobalConstants.KTAP && objACR.PermissionLevel_KTAP__c == null)
                    {
                        lstPrograms.remove(j);
                    }else if(lstPrograms[j] == SSP_GlobalConstants.CHILDCARE && objACR.PermissionLevel_CCAP__c == null)
                    {
                        lstPrograms.remove(j);
                    }else if(lstPrograms[j] == SSP_GlobalConstants.KHIPP && objACR.PermissionLevel_KIHIPP__c == null)
                    {
                        lstPrograms.remove(j);
                    }else if(lstPrograms[j] == SSP_GlobalConstants.STATE && objACR.PermissionLevel_StateSupp__c == null)
                    {
                        lstPrograms.remove(j);
                    }else
                    {
                        j++;
                    }
                    
                }
                
                String strPrograms;
                strPrograms = String.join(lstPrograms, ';');
                objACR.ProgramsApplied__c = strPrograms;
                
                
                
            }else {
                List<String> lstPrograms = new List<String>();
                If(objACR.PermissionLevel_Medicaid__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.MEDICAID);
                    
                }
                If(objACR.PermissionLevel_SNAP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.SNAP);
                    
                }
                If(objACR.PermissionLevel_KTAP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.KTAP);
                    
                }
                If(objACR.PermissionLevel_CCAP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.CHILDCARE);
                    
                }
                If(objACR.PermissionLevel_KIHIPP__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.KHIPP);
                    
                }
                If(objACR.PermissionLevel_StateSupp__c != NULL){
                    lstPrograms.add(SSP_GlobalConstants.STATE);
                    
                }
                String strPrograms;
                strPrograms = String.join(lstPrograms, ';');
                objACR.ProgramsApplied__c = strPrograms;
            }
            
            if(!lstACR.isEmpty()){
                     acrListForAgency = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','account.Name','account.DCdataId__c','Roles','dcAgencyId__c','dcContactId__c'}, 
                                                                              new Map<String, String>{'limit'=>'1000','contactId'=> lstACR[0].contactId,'account.recordtype.developerName '=>'Resource_Engine'});
                }else if(objACR.contactId != null){
                     acrListForAgency = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','account.Name','account.DCdataId__c','Roles','dcAgencyId__c','dcContactId__c'}, 
                                                                              new Map<String, String>{'limit'=>'1000','contactId'=> objACR.contactId,'account.recordtype.developerName '=>'Resource_Engine'});
                }
            if((!acrListForAgency.isEmpty()) && acrListForAgency[0].account.DCdataId__c !=null){
              objACR.DCAgencyId__c = acrListForAgency[0].account.DCdataId__c;
            }
             if((!acrListForAgency.isEmpty()) && acrListForAgency[0].dcContactId__c !=null){
              objACR.dcContactId__c = acrListForAgency[0].dcContactId__c;
            }
             if((!acrListForAgency.isEmpty()) &&  acrListForAgency[0].Roles != null && acrListForAgency[0].Roles.contains(SSP_GlobalConstants.ORGANISATION_AUTH_REP)){
              objACR.Roles = SSP_GlobalConstants.ORGANISATION_AUTH_REP;
             }else{
              objACR.Roles = SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING;  
             }
            if(objACR.Id == null) {
                objACR.StartDate = SSP_Utility.today();
            }
           
            if(objACR != null && sspApplicationId!= null && (!objApplication.isEmpty()) &&  objApplication[0].DCCaseNumber__c != null){
                Map<String, Object> mapInputParams = new Map<String, Object> ();
                mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_APP_ID, sspApplicationId);
                /*if the user role is non auth rep the set IsRepresentativeVerified__c to Y else,
                 pass the value as N*/
                 User objUser = [Select SelectedRole__c from User where id=:UserInfo.getUserId()];
                 if(objUser.SelectedRole__c!= null && (objUser.SelectedRole__c.equals(SSP_GlobalConstants.INDIVIDUAL_AUTH_REP) || objUser.SelectedRole__c.equals(SSP_GlobalConstants.ORGANIZATION_AUTH_REP))) {
                     if (objACR.IsRepresentativeVerified__c == null ) {
                         objACR.IsRepresentativeVerified__c  = 'N';
                     } 
                 } else {
                     objACR.IsRepresentativeVerified__c = 'Y';
                 }  
                mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_ACR,objACR);
                if(!lstACR.isEmpty()){
                    mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_CONTACT_ID,lstACR[0].contactId);
                }else if(objACR.contactId != null){
                    mapInputParams.put(SSP_InterfaceConstants.SSP_UPDATE_DC_REP_CONTACT_ID,objACR.contactId);
                }
                List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_UPDATE_DC_REPRESENTATIVE, mapInputParams);
                If(objList!= null && !objList.isEmpty()){
                    response = (SSP_UpdateDCRepResponseWrapper) objList[0];
                    
                }
            }
            
           
            if(objACR != null && objACR.id != null &&  (!objApplication.isEmpty()) && ((response != null && response.AckResponse != null  && response.AckResponse.success != null &&  response.AckResponse.success && objApplication[0] != null && objApplication[0].DCCaseNumber__c != null) || (objApplication[0] != null &&  objApplication[0].DCCaseNumber__c == null))){               
                 objACR.RequestAccessPermission__c=null;                
                UPDATE objACR;            
            }else if(objACR != null && objACR.id == null &&  (!objApplication.isEmpty()) && ((response != null && response.AckResponse != null &&  response.AckResponse.success != null && response.AckResponse.success && objApplication[0] != null && objApplication[0].DCCaseNumber__c != null) || (objApplication[0] != null && objApplication[0].DCCaseNumber__c == null))){               
                
                ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
                ESAPI.accessController().insertAsUser(objACR, SSP_Utility.getFieldsNamesObject(objACR)); 
                List<Contact> userList = new   List<Contact>();
                
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                String individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
                
                if(individualId != null && individualId != ''){  
                    
                  userList =SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                           new Set<String>{'Id', 'FirstName','LastName','IndividualId__c','Email','GenderCode__c','BirthDate'}, 
                                                                           new Map<String, String>{'IndividualId__c'=>individualId}); 
                    
                    
                }
                if(!userList.isEmpty()){
                    SSP_ProgramSelectionService.resetDashboardRefreshFlag(userList[0].Id); 
                }
            }else if(objACR != null && response != null && response.AckResponse.Error != null &&  response.AckResponse.Error.CHFSExceptionId != null){ 
                ErrorCode = response.AckResponse.Error.CHFSExceptionId;
            }else if(objACR != null && response != null && response.AckResponse.Error != null &&  response.AckResponse.Error.ErrorCode != null){ 
                ErrorCode = response.AckResponse.Error.ErrorCode;
            }
            
            
            if(!objApplication.isEmpty() &&  ErrorCode == ''){
                
                UPDATE objApplication[0]; 
            }
            
            
        }catch(Exception e){
            result = false;
            LOG_LogMessageUtility.logMessage(e, 'SSP_RepsAssistersAgentsController', 'updateACRRecords', 'Failed to Update in updateACRRecords Method', true);  
        }
        return ErrorCode;
    }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @className   individualWrapper
* @description  This is Wrapper class is used to get RepsAssistersAgentsDetails
*****************************************************************************************************/
    public class IndividualWrapper{ 
        
        @AuraEnabled
        public String caseNumber{get;set;}
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String programsApplied{get;set;}
        @AuraEnabled
        public String contactId{get;set;}
        @AuraEnabled
        public String contactPhone{get;set;}
        @AuraEnabled
        public String contactName{get;set;}
        @AuraEnabled
        public String contactEmail{get;set;}
        @AuraEnabled
        public String mailingAddress{get;set;}
        @AuraEnabled
        public String contactOrganization{get;set;}
        @AuraEnabled
        public boolean showCaseNumber{get;set;}
        @AuraEnabled
        public String language{get;set;}
        @AuraEnabled
        public Location mailingAddressGeoLocation{get;set;}
        @AuraEnabled
        public List<SSP_RepsAssistersAgentsController.programWrapper> programPermissions{get;set;}
        @AuraEnabled
        public String addressURL{get;set;}
        @AuraEnabled
        public String company{get;set;}
        @AuraEnabled
        public String role{get;set;}
        @AuraEnabled
        public String applicationId{get;set;}
        @AuraEnabled
        public List<String> hoursAvailableCodes { get; set;}
        @AuraEnabled
        public Boolean isHOH { get; set;}
        @AuraEnabled
        public string applicationName { get; set;}
         @AuraEnabled
        public Boolean showPhone { get; set;}
         @AuraEnabled
        public Boolean isAccessRequest { get; set;}
      	 @AuraEnabled
        public Boolean isEditAccessRequest { get; set;}
        @AuraEnabled
        public Boolean showRemoveButtonToCurrentUser { get; set;}
        
        
        
        public individualWrapper(SSP_Application__c application,contact contact,List<SSP_RepsAssistersAgentsController.programWrapper> programPermissions,AccountContactRelation objContactRelation,String role,String strPrograms,Boolean isHOH,String organizationName,String OrganizationPhone,Boolean isAccessRequest,Boolean isEditAccessRequest, Boolean showRemoveButtonToCurrentUser){            
            this.id= objContactRelation != null ?objContactRelation.Id:null;
            this.isAccessRequest = isAccessRequest;
             this.isEditAccessRequest = isEditAccessRequest;
            this.caseNumber=application != null ?String.valueOf(application.DCCaseNumber__c):'';//application
            if(objContactRelation != null && objContactRelation.ProgramsApplied__c != null){
                //this.ProgramsApplied=objContactRelation.ProgramsApplied__c.replaceAll(';', ', ');
                this.programsApplied=strPrograms;
            }
            if(objContactRelation != null && objContactRelation.contact.HoursAvailableCode__c != null){
                List<String> hoursAvailableCodesValues=objContactRelation.contact.HoursAvailableCode__c.split(';');
                this.hoursAvailableCodes = new List<String>();
                Map<String, String> codes = SSP_Utility.getPickListValues('Contact', 'HoursAvailableCode__c', null);
                for(String code: hoursAvailableCodesValues){
                    this.hoursAvailableCodes.add(codes.get(code));
                }
            }
            this.contactId = contact.Id;
            this.applicationName = application != null ?application.name:'';
            if(role == SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE){
            this.contactPhone = contact.Phone!= NULL?contact.Phone:'';
            }else{
            this.contactPhone = OrganizationPhone != null?OrganizationPhone:'';        
                }
            if(this.contactPhone != null && this.contactPhone != ''){
                this.showPhone =  true;
            }else{
                this.showPhone =  false;
            }
            this.contactName =  contact.Name;
            this.contactEmail = contact.Email;  
            this.contactOrganization = organizationName !=null ?organizationName:'';            
           
            this.applicationId = application != null?application.Id: null;
            if(this.caseNumber != null && this.caseNumber != '' && application!= null && application.recordtype.DeveloperName == 'Case'){
                this.showCaseNumber = true; 
            }else{
                this.showCaseNumber = false;
            }
            if(role == SSP_GlobalConstants.INSURANCE_AGENT_ROLE){
                this.language =  ((contact.SpokenLanguageCode__c != null) ? contact.SpokenLanguageCode__c : '');
            }else{
                this.language = ((contact.PreferredLanguageCode__c != null) ? contact.PreferredLanguageCode__c : '');  
            }
            
            this.company = contact.InsuranceCompany__c != null ?contact.InsuranceCompany__c:'' ;
            this.programPermissions = programPermissions != null ?programPermissions:null;   
            this.mailingAddressGeoLocation = contact.ContactGeoLocation__c;
            this.role = role;     
          
             if(role == SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE && objContactRelation != null){
            this.MailingAddress = ((objContactRelation.Street__c != null) ? objContactRelation.Street__c : '') + ((objContactRelation.AddressLine2__c != null) ? ', '+objContactRelation.AddressLine2__c : '') + 
                ((objContactRelation.CountyCode__c != null) ? ', '+ objContactRelation.CountyCode__c : '')  + ((objContactRelation.City__c != null) ? ', '+ objContactRelation.City__c : '' )+ 
                ( (objContactRelation.SSP_State__c != null) ? ', '+ objContactRelation.SSP_State__c : '') + ((objContactRelation.Zipcode5__c != null) ? ', '+objContactRelation.Zipcode5__c : '');
            }else{
           this.MailingAddress = ((contact.MailingStreet != null) ? contact.MailingStreet : '')+ ((contact.MailingLine2__c != null) ? ', '+contact.MailingLine2__c : '') + ((contact.MailingCity != null) ? ', '+contact.MailingCity : '') + 
              ((contact.CountyCode__c != null) ? ', '+ contact.CountyCode__c : '' )+  ((contact.MailingState != null) ? ', '+ contact.MailingState : '')  + 
                     ((contact.MailingPostalCode != null) ? ', '+ contact.MailingPostalCode : '' );
            }
            this.addressURL=SSP_GlobalConstants.MAP_URL+this.MailingAddress;
            this.isHOH = isHOH;
            this.showRemoveButtonToCurrentUser = showRemoveButtonToCurrentUser;
            
        }
    }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @className   programWrapper
* @description  This is Wrapper class is used to get program Permission Levels.
*****************************************************************************************************/
    public class ProgramWrapper{    
        
        @AuraEnabled
        public String programName{get;set;}
        @AuraEnabled
        public String permissionLevel{get;set;}  
        public programWrapper(String programName,String permissionLevel){            
            
            this.programName = programName;
            if(permissionLevel != null){
                this.permissionLevel = permissionLevel;
            }
            
        }
    }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @className   picklistWrapper
* @description  This is Wrapper class for picklist options.
*****************************************************************************************************/
    public class PicklistWrapper{    
        
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}        
        public picklistWrapper(String label,String value){            
            
            this.label = label;
            this.value = value;
            
            
        }
    }
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @className   programWrapper
* @description  This is Wrapper class is used to get program Permission Levels.
*****************************************************************************************************/
    public class ProgramPermissionWrapper{    
        
        @AuraEnabled
        public String programName{get;set;}
        @AuraEnabled
        public List<SSP_RepsAssistersAgentsController.picklistWrapper> permissionLevel{get;set;} 
        @AuraEnabled
        public String programId{get;set;} 
        @AuraEnabled
        public Boolean selected{get;set;} 
        @AuraEnabled
        public String permission{get;set;} 
        public programPermissionWrapper(String programName,List<SSP_RepsAssistersAgentsController.picklistWrapper> permissionLevel,String programId,Boolean selected,String permission){            
            
            this.programName = programName;
            if(permissionLevel != null){
                this.permissionLevel = permissionLevel;
            }
            this.programId = programId;
            this.selected = selected;
            this.permission = permission;
            
        }
    }
}
