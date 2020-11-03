public with sharing class SSP_AssisterRequestAccessService {

    public static Map<String,Object> checkCaseForAssociation(String sRequestAccessDetails, SSP_AuthRepAccessRequestCtrl.MCIResponseWrapper objMCIDetails,
                                                             String sCaseNumber)
    {
        Map<String, Object> objResponse = new Map<String, Object>();        
        SSP_AssisterAccessRequestCtrl.ReverseSSPDCResponseWrapper objRevResponse = (SSP_AssisterAccessRequestCtrl.ReverseSSPDCResponseWrapper)JSON.deserialize(sRequestAccessDetails, SSP_AssisterAccessRequestCtrl.ReverseSSPDCResponseWrapper.class);        
        
        Map<String, SSP_AssisterAccessRequestCtrl.CaseInfoWrapper> mapCaseInfo = new Map<String, SSP_AssisterAccessRequestCtrl.CaseInfoWrapper>();
        Set<Integer> setCaseIds = new Set<Integer>();
        List<Integer> lstCaseIds = new List<Integer>();
        List<User> userList = new List<User>();
        userList = SSP_SharingBypassFetcher.fetchRecords (
                                new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.DCDataId__c'}, 
                                new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}
                              );
        
        String currentRole = SSP_Utility.getSelectedRole();
        List<AccountContactRelation> lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','Roles'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'Account.RecordType.DeveloperName'=>'Resource_Engine'}
                                                          );
        AccountContactRelation objCurrentUserACR = new AccountContactRelation();
        List<String> lstRoles = new List<String>();
        if(String.isNotBlank(currentRole) && currentRole == 'Agency_Admin'){
            currentRole = 'Assister';
        }
        for(AccountContactRelation acr : lstCurrentUserACR){            
            if(acr.roles != null && acr.Roles.contains(';')){
                lstRoles = acr.Roles.split(';');
            }
            else{
                lstRoles.add(acr.roles);
            }
            if(!lstRoles.isEmpty() && lstRoles.contains(currentRole)){
                objCurrentUserACR = acr;
                break;
            }            
        }
        
            /*[Select Id,DCContactId__c,Account.DCDataId__c from AccountContactRelation 
                                                          where ContactId = :userList[0].ContactId and 
                                                          Account.RecordType.DeveloperName = 'Resource_Engine' and 
                                                          Roles = :currentRole];*/
        Boolean accessPresent = false;
        Boolean anotherAssisterPresent = false;
        Boolean isCaseInactive = false;
        Boolean canRequestAccess = false;
        Boolean pendingRequest = false;
                
        //Iterate over cases
        if(objRevResponse != null && objRevResponse.CaseInfo != null){//385790
            for(SSP_AssisterAccessRequestCtrl.CaseInfoWrapper  caseInfo :objRevResponse.CaseInfo){
                if(caseInfo.ProgramCode!=null){
                    if(sCaseNumber != null && caseInfo.CaseNumber == sCaseNumber && (caseInfo.ProgramCode.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA) || caseInfo.ProgramCode.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP))){
                        setCaseIds.add(Integer.valueOf(caseInfo.CaseNumber));
                        mapCaseInfo.put(caseInfo.CaseNumber, caseInfo);   
                    }            
                    else if((sCaseNumber == null || sCaseNumber == '') && (caseInfo.ProgramCode.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA) || caseInfo.ProgramCode.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP))){                 
                        setCaseIds.add(Integer.valueOf(caseInfo.CaseNumber));
                        mapCaseInfo.put(caseInfo.CaseNumber, caseInfo);                
                    }
                }
            }
            //add logic if case no is entered by user
        }
        lstCaseIds.addAll(setCaseIds);
        
        if(objMCIDetails.bIsFullMatch && (setCaseIds == null || setCaseIds.size() == 0)){
            isCaseInactive = true;
        }
        
        //Iterate over Assister Info 
        if(objRevResponse.AuthrepandAssiterClientInfo!=null){       
            for(SSP_AssisterAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper  assisterInfo :objRevResponse.AuthrepandAssiterClientInfo){
                
                if(assisterInfo.UserId == string.valueOf(objCurrentUserACR.DCContactId__c) && setCaseIds.contains(Integer.valueOf(assisterInfo.CaseNumber))){
                    setCaseIds.remove(Integer.valueOf(assisterInfo.CaseNumber));
                    accessPresent = true;
                }
                else if(assisterInfo.UserId != string.valueOf(objCurrentUserACR.DCContactId__c) && setCaseIds.contains(Integer.valueOf(assisterInfo.CaseNumber))){
                    anotherAssisterPresent = true;
                }
            }
        }
        
        //check if request is in pending state
        if(setCaseIds!=null && setCaseIds.size()>0){
            List<SSP_Application__c> lstExistingCase = SSP_SharingBypassFetcher.fetchRecords(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND','IN'=>'DCCaseNumber__c'}, 
                                                                   new Set<String>{'Id','Account__c','DCCaseNumber__c','Account__r.CaseNumber__c'}, 
                                                                   new Map<String, String>{'DCCaseNumber__c'=> String.join(lstCaseIds, ','), 'RecordTypeId'=>SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case')}
                                                                   );
            List<String> lstAccountIds = new List<String>();
            for(SSP_Application__c app : lstExistingCase){
                lstAccountIds.add(app.Account__c);
            }
            if(lstExistingCase!=null && lstExistingCase.size()>0){
                List<AccountContactRelation> lstACR = SSP_SharingBypassFetcher.fetchRecords(
                                                        new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND','IN'=>'AccountId'}, 
                                                        new Set<String>{'AccountId', 'ContactId', 'RequestAccessPermission__c'}, 
                                                        new Map<String, string>{'AccountId'=>String.join(lstAccountIds, ','), 'ContactId' =>userList[0].ContactId}
                                                      );
                for(AccountContactRelation acr : lstACR){
                    if(lstACR != null && lstACR.size() > 0 && acr.RequestAccessPermission__c != null){
                        pendingRequest = true;
                        break;                        
                    }
                }
            }
        }
        
        if(setCaseIds!=null && setCaseIds.size()>0 && !pendingRequest){
            canRequestAccess = true;
        }
        
        objResponse.put('isCaseInactive',isCaseInactive);
        objResponse.put('accessPresent',accessPresent);
        objResponse.put('pendingRequest',pendingRequest);
        objResponse.put('anotherAssisterPresent',anotherAssisterPresent);
        objResponse.put('canRequestAccess',canRequestAccess);
        objResponse.put('setCaseIds',setCaseIds);
        objResponse.put('mapCaseInfo',mapCaseInfo);
        objResponse.put('assisterName',UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        
        return objResponse;
    }
    
    public static List<AccountContactRelation> createAssisterUnverifiedACR(list<Integer> setCaseIds, Map<String, SSP_AssisterAccessRequestCtrl.CaseInfoWrapper> mapCaseInfo)
    {
        List<SSP_Application__c> lstExistingCase = new List<SSP_Application__c>();
        List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation>();
        List<AccountContactRelation> lstCreatedACRs = new List<AccountContactRelation>();
        List<AccountContactRelation> finalACRList = new List<AccountContactRelation>();
        List<User> userList = new List<User>();
        userList = SSP_SharingBypassFetcher.fetchRecords (
            new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.DCDataId__c'}, 
            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}
        );
        
        String currentRole = SSP_Utility.getSelectedRole();
        List<AccountContactRelation> lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c', 'Roles'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'Account.RecordType.DeveloperName'=>'Resource_Engine'}
                                                          );
        AccountContactRelation objCurrentUserACR = new AccountContactRelation();
        List<String> lstRoles = new List<String>();
        for(AccountContactRelation acr : lstCurrentUserACR){            
            if(acr.roles != null && acr.Roles.contains(';')){
                lstRoles = acr.Roles.split(';');
            }
            else{
                lstRoles.add(acr.roles);
            }
            if(!lstRoles.isEmpty() && lstRoles.contains(currentRole)){
                objCurrentUserACR = acr;
                break;
            }            
        }

        if(setCaseIds!=null && setCaseIds.size()>0){
           Set<String> existingCases = new Set<String>(); //C1
            Map<String, SSP_Application__c> mapExistingCases = new Map<String, SSP_Application__c>();
            Set<String> newCases = new Set<String>(); //c3
            List<String> listAccountIds = new List<String>();
            
            lstExistingCase = SSP_SharingBypassFetcher.fetchRecords(
                                                                    new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND','IN'=>'DCCaseNumber__c'}, 
                                                                    new Set<String>{'Id','Account__c','DCCaseNumber__c','Account__r.CaseNumber__c'}, 
                                                                    new Map<String, String>{'DCCaseNumber__c'=> String.join(setCaseIds, ','), 'RecordTypeId'=>SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case')}
                													);          
            
            for(SSP_Application__c app : lstExistingCase){
               	existingCases.add(String.valueOf(app.DCCaseNumber__c));                
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = app.Account__c;
                listAccountIds.add(app.Account__c);
                acr.ContactId = userList[0].ContactId;  //SF contact id -- Added JSON formation here
                
                acr.Roles = currentRole;
                acr.DCContactId__c = objCurrentUserACR.DCContactId__c;
                acr.DCAgencyId__c = objCurrentUserACR.Account.DCDataId__c;
                JSONGenerator generator = JSON.createGenerator(true);
                generator.writeStartObject();
                String programs = mapCaseInfo.get(String.valueOf(app.DCCaseNumber__c)).ProgramCode;
                if(programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA) && programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP)){
                    generator.writeStringField('PermissionLevel_Medicaid__c', 'true');
                    generator.writeStringField('PermissionLevel_KIHIPP__c', 'true');
                }
                else if(programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA)){
                    generator.writeStringField('PermissionLevel_Medicaid__c', 'true');
                }
                else if(programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP)){
                    generator.writeStringField('PermissionLevel_KIHIPP__c', 'true');
                }
                
                generator.writeEndObject();
                String jsonPermissionString = generator.getAsString(); 
                acr.RequestAccessPermission__c=jsonPermissionString;
                lstAccountContact.add(acr);                
            }           
            if(listAccountIds!=null && listAccountIds.size()>0){
                List<AccountContactRelation> lstExistingACR = SSP_SharingBypassFetcher.fetchRecords ( new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                                                     new Set<String>{'Id','AccountId'}, 
                                                                                                     new Map<String, String>{'ContactId'=> userList[0].ContactId,'AccountId'=> String.join(listAccountIds, ',')}
                                                                                                    );  
                MAP<String, String> mapAcr = new MAP<String, String>();
                for(AccountContactRelation acrs :lstExistingACR){
                    mapAcr.put(acrs.AccountId , acrs.Id);
                }
                
                for(AccountContactRelation updatedAcr : lstAccountContact){
                    if(mapAcr.get(updatedAcr.AccountId)!=null){
                        updatedAcr.id = mapAcr.get(updatedAcr.AccountId);
                    }
                    finalACRList.add(updatedAcr);
                } 
                
            }
            
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(finalACRList, 'upsert', 'AccountContactRelation');

            lstCreatedACRs.addAll(finalACRList);
            
            //New
            List<Account> lstAccount = new List<Account>();
            List<SSP_Application__c> applicationList = new List<SSP_Application__c>();
            List<AccountContactRelation> lstACR = new List<AccountContactRelation>();            
            for(Integer caseNo : setCaseIds){                 
                if(!existingCases.contains(String.valueOf(caseNo)))
                {                    
                    Account account = new Account();
                    account.Name = 'Application Account for ' + UserList[0].Contact.FirstName + ' ' + userList[0].Contact.LastName;
                    account.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
                    account.CaseNumber__c = string.valueOf(caseNo);
                    lstAccount.add(account);                    
            	}  
            }
            List<Account> createdAccounts = new List<Account>();
            if(lstAccount!=null && lstAccount.size()>0){
                Map<String,object> mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(lstAccount, null, NULL);
                createdAccounts = (List<Account>)mapRestResult.get('lstAccounts');                  
            }
            
            for(Account acc : createdAccounts){
                SSP_Application__c app = new SSP_Application__c();
                app.DCCaseNumber__c = Integer.valueOf(acc.CaseNumber__c);
                app.ApplicationCreationInSSP__c = SSP_Utility.today();
                app.ApplicationReceivedDateTime__c = SSP_Utility.now();
                app.Account__c =  acc.Id;
                app.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
                applicationList.add(app);
                
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = acc.Id;
                acr.ContactId = userList[0].ContactId; //Also populate the json here in acr
                
                acr.Roles = currentRole;
                acr.DCContactId__c = objCurrentUserACR.DCContactId__c;
                acr.DCAgencyId__c = objCurrentUserACR.Account.DCDataId__c;
                JSONGenerator generator = JSON.createGenerator(true);
                generator.writeStartObject();
                String programs = mapCaseInfo.get(String.valueOf(app.DCCaseNumber__c)).ProgramCode;
                if(programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA) && programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP)){
                    generator.writeStringField('PermissionLevel_Medicaid__c', 'true');
                    generator.writeStringField('PermissionLevel_KIHIPP__c', 'true');
                }
                else if(programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA)){
                    generator.writeStringField('PermissionLevel_Medicaid__c', 'true');
                }
                else if(programs.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP)){
                    generator.writeStringField('PermissionLevel_KIHIPP__c', 'true');
                }
                
                generator.writeEndObject();
                String jsonPermissionString = generator.getAsString(); 
                acr.RequestAccessPermission__c=jsonPermissionString;
                
                lstACR.add(acr);
            }
           
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(applicationList, 'insert', 'SSP_Application__c');
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstACR, 'insert', 'AccountContactRelation');
            
            lstCreatedACRs.addAll(lstACR);           
        }        
        return lstCreatedACRs;
    }
    
    public static Map<String,Object> checkApplicationAssociation(String sSourceIndividualId, String sApplicationNumber)
    {
        Map<String, Object> objResponse = new Map<String, Object>();
        List<Integer> lstIndividualIds = new List<Integer>();        
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        List<String> lstIndIds = sSourceIndividualId.split(';');
        for(String sIndInds: lstIndIds) {
            lstIndividualIds.add(Integer.valueOf(sIndInds));
        }
               
        List<Contact_Mapping__c> lstContactMapping = SSP_SharingBypassFetcher.fetchContactMappingRecordList(lstIndividualIds);
        
        String individualContactId = lstContactMapping[0].Contact__c;
        
        User loggedInUser = [Select Id, ContactId from User where Id = :UserInfo.getUserId()];
       
        Set<String> allApplIndFieldSet = new Set<String>{'Id', 'SSP_Application__r.Name', 'SSP_Application__r.Account__c', 'SSP_Member__r.Contact__r.DCDataId__c', 'SSP_Application__r.ProgramsApplied__c',
            'SSP_Member__r.PreferredNotificationMethodCode__c', 'SSP_Member__r.PreferredWrittenLanguageCode__c', 'SSP_Member__r.Email__c',
            'SSP_Member__r.PrimaryPhoneNumber__c', 'SSP_Member__r.SecondaryPhoneNumber__c', 'SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c',
            'SSP_Member__r.SecondaryPhoneTypeCode__c', 'SSP_Member__r.PrimaryPhoneTypeCode__c'};

        Map<String, String> detailMap = new Map<String,String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'};
        Map<String, String> conditionMap = new Map<String, String>{'SSP_Member__r.Contact__c'=>individualContactId,'SSP_Application__r.Name'=>sApplicationNumber};
        lstAppInd = SSP_SharingBypassFetcher.fetchRecords (detailMap,allApplIndFieldSet,conditionMap);
        
        if(lstAppInd!= null && lstAppInd.size()>0 && 
          (lstAppInd[0].SSP_Application__r.ProgramsApplied__c.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA) || lstAppInd[0].SSP_Application__r.ProgramsApplied__c.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP)))
        {
                    
           /* List<AccountContactRelation> lstACR =
            SSP_SharingBypassFetcher.fetchRecords(
                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                            new Set<String>{'AccountId', 'ContactId', 'RequestAccessPermission__c'}, 
                            new Map<String, string>{'AccountId'=>lstAppInd[0].SSP_Application__r.Account__c, 'ContactId' =>loggedInUser.ContactId}
            ); */     
            List<AccountContactRelation> lstACR = SSP_SharingBypassFetcher.fetchAssisterCurrentACRList(lstAppInd[0].SSP_Application__r.Account__c, loggedInUser.ContactId);
            List<AccountContactRelation> lstAssisterPresentACR = SSP_SharingBypassFetcher.fetchAssisterPresentACRList(lstAppInd[0].SSP_Application__r.Account__c, loggedInUser.ContactId);
            
            if(lstAssisterPresentACR != null && lstAssisterPresentACR.size() > 0){
                objResponse.put('anotherAssisterPresent', true);
            }
            
           if(lstACR != null && lstACR.size() > 0 && lstACR[0].RequestAccessPermission__c == null){
                objResponse.put('accessPresent', true);
            }
            else if(lstACR != null && lstACR.size() > 0 && lstACR[0].RequestAccessPermission__c != null){
                objResponse.put('pendingRequest', true);
            }  
            else{
                objResponse.put('canRequestAccess', true);
                SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper objCaseInfo = new SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper();
                objCaseInfo.ProgramCode = lstAppInd[0].SSP_Application__r.ProgramsApplied__c;
                objCaseInfo.FirstName = lstAppInd[0].SSP_Member__r.FirstName__c;
                objCaseInfo.LastName = lstAppInd[0].SSP_Member__r.LastName__c;
                objCaseInfo.Email = lstAppInd[0].SSP_Member__r.Email__c;
                objCaseInfo.PrimaryPhoneTypeCode =  lstAppInd[0].SSP_Member__r.PrimaryPhoneTypeCode__c;
                objCaseInfo.PrimaryPhoneNumber = lstAppInd[0].SSP_Member__r.PrimaryPhoneNumber__c;                
                objCaseInfo.SecondaryPhoneTypeCode = lstAppInd[0].SSP_Member__r.SecondaryPhoneTypeCode__c;
                objCaseInfo.SecondaryPhoneNumber = lstAppInd[0].SSP_Member__r.SecondaryPhoneNumber__c;               
                objCaseInfo.PreferredWrittenLanguageCode = lstAppInd[0].SSP_Member__r.PreferredWrittenLanguageCode__c;                
                objCaseInfo.PreferredNotificationMethodCode = lstAppInd[0].SSP_Member__r.PreferredNotificationMethodCode__c;
                Map<String, SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper> mapAppInfo = new Map<String, SSP_AuthRepAccessRequestCtrl.CaseInfoWrapper>();
                mapAppInfo.put(sApplicationNumber, objCaseInfo);
                objResponse.put('mapAppInfo', mapAppInfo);
                objResponse.put('contactName', lstAppInd[0].SSP_Member__r.FirstName__c + ' ' + lstAppInd[0].SSP_Member__r.LastName__c);
            }
        }
        else{
            objResponse.put('isCaseInactive',true);
        }
        objResponse.put('assisterName',UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        
        return objResponse;
    }

	public static List<AccountContactRelation> createAssisterUnverifiedAppACR(String sSourceIndividualId, String sApplicationNumber)
    {
        List<SSP_Application__c> lstExistingCase = new List<SSP_Application__c>();
        List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation>();
        List<AccountContactRelation> lstCreatedACRs = new List<AccountContactRelation>();
         List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
        List<User> userList = SSP_UserSelector.queryUserData (
            new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName','Contact.DCDataId__c'}, 
            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}
        );
        
        String currentRole = SSP_Utility.getSelectedRole();
        
        List<AccountContactRelation> lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','Roles'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'Account.RecordType.DeveloperName'=>'Resource_Engine'}
                                                          );
        
        AccountContactRelation objCurrentUserACR = new AccountContactRelation();
        List<String> lstRoles = new List<String>();
        for(AccountContactRelation acr : lstCurrentUserACR){            
            if(acr.roles != null && acr.Roles.contains(';')){
                lstRoles = acr.Roles.split(';');
            }
            else{
                lstRoles.add(acr.roles);
            }
            if(!lstRoles.isEmpty() && lstRoles.contains(currentRole)){
                objCurrentUserACR = acr;
                break;
            }            
        }
        
        if(sApplicationNumber!=null && sApplicationNumber!=''){           
            //Existing - Put in sharing by pass fetcher                        
            lstExistingCase =SSP_SharingBypassFetcher.fetchRecords(
                            new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                            new Set<String>{'DCCaseNumber__c', 'Id', 'Account__c','ProgramsApplied__c'}, 
                            new Map<String, string>{'Name'=>sApplicationNumber}
            );  
            if((!lstExistingCase.isEmpty()) && lstExistingCase[0].Account__c != null){
             lstACR =
            SSP_SharingBypassFetcher.fetchRecords(
                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                            new Set<String>{'AccountId', 'ContactId', 'RequestAccessPermission__c','Id'}, 
                            new Map<String, string>{'AccountId'=>lstExistingCase[0].Account__c, 'ContactId' =>userList[0].ContactId}
            );
            }
            for(SSP_Application__c app : lstExistingCase){               
                AccountContactRelation acr = new AccountContactRelation();
                if(!lstACR.isEmpty()){
                acr.id =  lstACR[0].Id;                
                }else{
                acr.AccountId = app.Account__c;
                acr.ContactId = userList[0].ContactId;  //SF contact id -- Added JSON formation here
                }
                
                //acr.Roles='Assister';
                acr.Roles = currentRole;
                acr.DCContactId__c = objCurrentUserACR.DCContactId__c;
                acr.DCAgencyId__c = objCurrentUserACR.Account.DCDataId__c;
                JSONGenerator generator = JSON.createGenerator(true);
                generator.writeStartObject();                    
                if(app.ProgramsApplied__c.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA) && app.ProgramsApplied__c.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP)){
                    generator.writeStringField('PermissionLevel_Medicaid__c', 'true');
                    generator.writeStringField('PermissionLevel_KIHIPP__c', 'true');
                }
                else if(app.ProgramsApplied__c.contains(SSP_GlobalConstants.PROGRAM_TYPE_MA)){
                    generator.writeStringField('PermissionLevel_Medicaid__c', 'true');
                }
                else if(app.ProgramsApplied__c.contains(SSP_GlobalConstants.PROGRAM_TYPE_KP)){
                    generator.writeStringField('PermissionLevel_KIHIPP__c', 'true');
                }
                
                generator.writeEndObject();
                String jsonPermissionString = generator.getAsString(); 
                acr.RequestAccessPermission__c=jsonPermissionString;
                lstAccountContact.add(acr);                
            }
            
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstAccountContact, 'upsert', 'AccountContactRelation');

            lstCreatedACRs.addAll(lstAccountContact);              
        }        
        return lstCreatedACRs;
    }
    
    @AuraEnabled
    Public static  Map<String, Object> fetchAcrResponse(string snotifiId){        
        Map<String, Object> objResponse = new Map<String, Object>();
        try{
            List<SSP_Notifications__c> notificationRec = new List<SSP_Notifications__c>();
            if(snotifiId !=null){           
                notificationRec = SSP_SharingBypassFetcher.fetchRecords (
                    new Map<String, String>{'objectName'=>'SSP_Notifications__c'}, 
                    new Set<String>{'Id','recipientId__c','Linked_Record_Id__c'},
                    new Map<String, String>{'Id'=> snotifiId});
            }
            //Query ACR
            String sPermissionJsn;
            List<AccountContactRelation> lstAccountContact = new List<AccountContactRelation>();
            if(notificationRec.size()>0){        
             lstAccountContact = SSP_SharingBypassFetcher.fetchRecords (
                    new Map<String, String>{'objectName'=>'AccountContactRelation'}, 
                    new Set<String>{'Id','AccountId','ContactId','RequestAccessPermission__c'},
                    new Map<String, String>{'Id'=> notificationRec[0].Linked_Record_Id__c});
                
             }
            if(lstAccountContact.size()>0){
                 sPermissionJsn =lstAccountContact[0].RequestAccessPermission__c;
            }
             
              JSONParser parser = JSON.createParser(sPermissionJsn);
            while (parser.nextToken() != null) {
                if(parser.getText() == 'PermissionLevel_Medicaid__c'){
                    parser.nextToken();
                                    
                    objResponse.put('PermissionLevelMedicaid','MEDICAID');
                }
                if(parser.getText() == 'PermissionLevel_KIHIPP__c'){
                    parser.nextToken();
                                    
                    objResponse.put('PermissionLevelKIHIPP','KHIPP');
                }                 
                                     
                //Query Contact  
                List<Contact> lstContact = new List<Contact>();
                if(lstAccountContact.size()>0){            
                   lstContact=  SSP_SharingBypassFetcher.fetchRecords (
                        new Map<String, String>{'objectName'=>'contact'}, 
                        new Set<String>{'Id','Name','DCDataId__c'},
                        new Map<String, String>{'Id'=> lstAccountContact[0].ContactId});
                     
                }              
                objResponse.put('AssisterName', lstContact[0].Name);    
            }  
        }
        catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'fetchAcrResponse', ex.getMessage() , true);            
        }
        return objResponse;
    }
    
    @AuraEnabled
    Public static Boolean searchAssister(String sEmailId){
        Boolean bMatchFound = false;
        try{            
            List<Contact> lstConDetails = new List<Contact>();
            if(sEmailId != ''){                       
                lstConDetails=SSP_SharingBypassFetcher.fetchRecords (
                              new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                              new Set<String>{'Id','Email','RecordTypeId'},
                              new Map<String, String>{'Email'=>sEmailId,'RecordTypeId'=>SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Assister')});
            }        
            if(lstConDetails.size()>0){            
                bMatchFound= true;
            }else{
                bMatchFound= false;
            }  
        }
        catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_AssisterRequestAccessCtrl', 'searchAssister', ex.getMessage() , true);            
        }
        return bMatchFound;
    }
}