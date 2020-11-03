/*
* classname     :  SSP_NonCitizenDashboardController
* @description  :  This class contains all methods to get all data for Non Citizen user
* @author       :  Chandra Shekhar   
* @date         :  04/28/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Chandra Shekhar             04/28/2020                             Created.
* ---------------------------------------------------------------------------------------------
**/
public without sharing class SSP_NonCitizenDashboardController {
    
    public static String query=SSP_GlobalConstants.query;        
    public static String queryAccessAssociated=SSP_GlobalConstants.queryAccessAssociated;
    public static Set<String> caseSearchRoles= new Set<String>{'Department_Of_Education_Representative','DJJ_Representative','Eligibility_&_Benefit_Inquiry_User'};
        public static Map<Id,String> mapClientAccountIdToAssisterDetails = new Map<Id,String>();
    public static Map<String, Boolean> fieldPermissionsMap = new Map<String, Boolean>();
    public static Map<String,String> assisterToRoleMap= new Map<String,String>();
    public static Set<Id> setofClientAccountId= new Set<Id>();
    public static Boolean assistedbyBlank=false;
    public static Boolean searchIsBlank=false;
    public static String assistedBySearch;
    public static String responseCode;
    public static String responseDescription;
    public static Integer iClientCount = 0; //Added as a part of Defect - 379964
    public static Boolean bIsClientCountGreater = false; //Added as a part of Defect - 379964
    public static Map<String,list<String>> accessToUserRoleMap=new  Map<String,list<String>>{
        'allAccess'=>new list<String>{'CHFS_Prod_Support','Contact_Center_View_and_Edit','Contact_Center_View_Only','DCBS_View_Only','DCBS_Central_Office_View_and_Edit','Department_Of_Education_Representative','DJJ_Representative','DOC_Representative','Eligibility_&_Benefit_Inquiry_User','Jailor','Mail_Center_Supervisor','Mail_Center_Worker','Psychiatric_Facility_Representative'},
            'accessAssociatedToOrganisation'=>new list<String>{'Agency_Admin','DAIL_Worker','Organization_Auth_Rep'},
                'accessAssociatedToIndividual'=>new list<String>{'Assister','Individual_Auth_Rep','Insurance_Agent','QE_Hospital','QE_Pregnancy'}
    };
    public static SET<String> clientIndividualIds = new  SET<String>();
        
        /***************************************************************************************************
* @author       Chandra Shekhar
* @date         04/28/2020
* @methodname   getNonCitizenUserInfo
* @description  This method takes a user Id and gets it ifno form KOG side
* @return       SSP_LightningResponse
*****************************************************************************************************/
        @AuraEnabled
        public static SSP_LightningResponse getNonCitizenUserInfo(String userId,Boolean isCall){
            SSP_Utility.isAuthenticatedUser(); 
            SSP_LightningResponse dataToSend = new SSP_LightningResponse();
            try{            
                String userRole=SSP_Utility.getUserDetails(userId).get('userRole');
                
                NonCitizenUserInfo userInfo= new NonCitizenUserInfo();
                List<Contact> contactList = new List<Contact>();
                list<AccountContactRelation> acrList= new list<AccountContactRelation>();
                list<SSP_ApplicationIndividual__c> applicationList;           
                list<ClientSearchResult> csrList= new list<ClientSearchResult>();
                Map<String, ClientSearchResult> csrCaseMap= new Map<String, ClientSearchResult>(); //#375342
                list<ClientSearchResult> csrAppList= new list<ClientSearchResult>();
                String orgIds='';
                String userIds='';
                //Defect 385760
            list<String> listUserRole= new list<String>();
            listUserRole.add(userRole);
            if(userRole=='Agency_Admin'){
                listUserRole.add('Assister');
            }
                String orgNames = '';
                List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'},new Set<String>{'Id', 'ContactId'},new Map<String, String>{'limit'=>'1','Id'=> userId});             
                if(userList != null && userList.size() > 0){                
                    contactList = [Select Id, FirstName, LastName,MiddleName,toLabel(PhoneType__c),IndividualId__c,Email,Phone,HomePhone,DCDataId__c,KOGSourceId__c,PreferredLanguageCode__c,IsActive__c,InHousePrivateAssister__c,AssociatedCountyCode__c,MailingStreet,MailingLine2__c,MailingCity,MailingState,MailingPostalCode, MailingCountry,PreferredCommunicationMethod__c, HoursAvailableCode__c from Contact where Id=:userList[0].ContactId limit 1];  
                    
                acrList=[Select Id,AccountId,DCContactId__c,Account.DCDataId__c,Account.Name,Account.Email__c,Account.Phone,Account.ShippingStreet,Account.ShippingLine2__c,Account.ShippingCity,Account.ShippingState,Account.ShippingPostalCode,Account.MailingZipExtension__c,Account.ShippingCountry,Account.BillingStreet,Account.BillingLine2__c,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BilingZipExtension__c,Account.BillingCountry from AccountContactRelation where Account.recordTypeId=:SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine') and ContactId=:userList[0].ContactId and (Account.DCDataId__c!=null OR (Roles='Individual_Auth_Rep' AND DCContactId__c != null))
                and Roles in:listUserRole Limit 100];                
                }            
                if(contactList!=null && !contactList.isEmpty()){        
                    userInfo.userRole=userRole;            
                    userInfo.coverageArea=contactList[0].AssociatedCountyCode__c;
                    if(!String.isBlank(userInfo.coverageArea)){
                    userInfo.coverageArea=getCountyName(userInfo.coverageArea); //Bug 396980--Payal Dubela --Coverage Area is showing County Codes instead of County Names
                    userInfo.coverageArea= userInfo.coverageArea.trim();
                    userInfo.coverageArea= userInfo.coverageArea.removeEnd(',');
                    }
                    userInfo.phoneSecondry =contactList[0].HomePhone;
                    userInfo.name=contactList[0].FirstName+' '+contactList[0].LastName;      
                    userInfo.accessPublicPrivate=contactList[0].InHousePrivateAssister__c;
                    userInfo.clientCount=String.ValueOf(csrList.size());
                    userInfo.email=contactList[0].Email;
                    userInfo.phone=contactList[0].Phone;
                    userInfo.phoneType=contactList[0].PhoneType__c;
                    userInfo.mailingAddress=contactList[0].MailingStreet+' '+contactList[0].MailingLine2__c+' '+contactList[0].MailingCity+'\n'+contactList[0].MailingState+' '+contactList[0].MailingPostalCode+'\n'+contactList[0].MailingCountry;
                    userInfo.mailingAddress=userInfo.mailingAddress.remove('null ');
                    userInfo.mailingAddress=userInfo.mailingAddress.remove('null');                
                    userInfo.preferredContact=contactList[0].PreferredCommunicationMethod__c;            
                    userInfo.preferredTimeOfContact=SSP_Utility.getPickListValues('Contact','HoursAvailableCode__c',NULL).get(contactList[0].HoursAvailableCode__c);                
                }
                if(acrList!=null && !acrList.isEmpty()){
                    for(AccountContactRelation acr:acrList){
                        if(!String.isblank(String.ValueOf(acr.Account.DCDataId__c))){
                            orgIds+=String.ValueOf(acr.Account.DCDataId__c)+','; 
                        }
                        if(!String.isblank(String.ValueOf(acr.DCContactId__c))){
                            userIds+=String.ValueOf(acr.DCContactId__c)+',';  
                        }       
                        //defect 385760
                        if(!String.isblank(String.ValueOf(acr.Account.Name))){
                            orgNames+=String.ValueOf(acr.Account.Name)+',';  
                        }                               
                    }                      
                    userInfo.userId=userIds.removeEnd(',');                
                    
                    userInfo.organization=orgIds.removeEnd(',');
                    //defect 385760
                    userInfo.organizationName = orgNames.removeEnd(',');
                    userInfo.assisterOrgName=acrList[0].Account.Name;
                    if(acrList[0] != null && acrList[0].Account.DCDataId__c != null && String.isNotBlank(String.ValueOf(acrList[0].Account.DCDataId__c))){
                        userInfo.assisterID =  String.valueOf(acrList[0].Account.DCDataId__c);
                    }                    
                    userInfo.orgEmail=acrList[0].Account.Email__c;
                    userInfo.orgPhone=acrList[0].Account.Phone;                
                //Defect 139
                userInfo.orgPhysicalAddress=acrList[0].Account.BillingStreet+' '+acrList[0].Account.BillingLine2__c+' '+acrList[0].Account.BillingCity+'\n'+acrList[0].Account.BillingState+' '+acrList[0].Account.BillingPostalCode+' '+acrList[0].Account.BilingZipExtension__c +'\n'+acrList[0].Account.BillingCountry;//ACR account 
                    userInfo.orgPhysicalAddress=userInfo.orgPhysicalAddress.remove('null ');
                    userInfo.orgPhysicalAddress=userInfo.orgPhysicalAddress.remove('null');                
                userInfo.orgMailAddress=acrList[0].Account.ShippingStreet+' '+acrList[0].Account.ShippingLine2__c+' '+acrList[0].Account.ShippingCity+'\n'+acrList[0].Account.ShippingState+' '+acrList[0].Account.ShippingPostalCode+' '+acrList[0].Account.MailingZipExtension__c+'\n'+acrList[0].Account.ShippingCountry;//ACR account 
                    userInfo.orgMailAddress=userInfo.orgMailAddress.remove('null ');
                    userInfo.orgMailAddress=userInfo.orgMailAddress.remove('null');
                }
                if(String.isBlank(userIds) && contactList!=null && !contactList.isEmpty()){
                    userInfo.userId=String.ValueOf(contactList[0].KOGSourceId__c);
                }  
                
                String organization='';
                if(userInfo.organization != null){
                    organization = userInfo.organization.replace(',', ';');
                }

                //Non-Citizen Dashboard Perf issue fix - end
                if(isCall)
                {
                    if(caseSearchRoles.contains(userRole)){                
                        csrCaseMap = searchCaseCallout(userId,userRole,null,userInfo.userId.replace(',', ';'),organization); //#375342                               
                        csrList = csrCaseMap != null && !csrCaseMap.isEmpty() ? csrCaseMap.values() : csrList; //#375342
                    }else{                
                        csrCaseMap = searchCaseCallout(userId,userRole,null,userInfo.userId.replace(',', ';'),organization); //#375342
                        String searchQuery = SSP_GlobalConstants.UnSubmittedApplication; // Added as part of Defect - 382837
                        csrAppList=searchApplications(userId,userRole,searchQuery); 
                        csrList = mergeCaseAndAppData(csrCaseMap, csrAppList); //#375342
                        // csrList.addAll(csrAppList);
                    } 
            } else {
                List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
                if(userRole == SSP_InterfaceConstants.INDIVIDUAL_AUTH_REP_ROLE && contactList != null && !contactList.isEmpty() && Schema.sObjectType.AccountContactRelation.isAccessible()) {
                    lstACR =[SELECT Id FROM AccountContactRelation 
                                WHERE Account.recordTypeId=:SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine') 
                                AND ContactId=:userList[0].ContactId
                            ];
                    if(lstACR.isEmpty()) {
                        dataToSend.put('ackStatusCode',onBoardIndvidualAuthRepCallout(contactList[0]));
                    }
                }
            }
                csrList=setResultValueBasedOnRole(csrList,userRole);
            // Added for 386023
             List<ClientSearchResult> newList = new  List<ClientSearchResult>();
             
            if( (userRole.equalsIgnoreCase('Assister')|| userRole.equalsIgnoreCase('Organization_auth_rep')||userRole.equalsIgnoreCase('Individual_auth_rep')) && csrList.size()>0 && !csrList.isEmpty()){
                for(Integer i=0;i<csrList.size();i++){                     
                    if(!csrList[i].isCase && String.isBlank(csrList[i].assistedByAssister) && String.isBlank(csrList[i].assistedByAuthRep)){
                        System.debug(' only these are to be remmoved '+csrList[i]);
                        // csrList.remove(i);                         
                    }
                    else {
                        
                        newList.add(csrList[i]);
                    }
                }             
            }
            else {
                
                newList = csrList;
            }
            //End 386023
             
            dataToSend.put('csrList After Merge Final ',csrList.size() + ' ## '+JSON.serialize(csrList));
            if(!csrList.isEmpty()){
                dataToSend.put('csrListDataToExport', JSON.serialize(csrList));
            }
            if(newList.size()<=10){
                    newList.sort();                   
                    dataToSend.put('searchResultData', newList);
                }else{
                    dataToSend.put('searchResultData', null);
                }
                
                SET<Id> individualIdList = new SET<Id>();
                for(ClientSearchResult appData :newList){
                    clientIndividualIds.add(appData.individualId);
                }
   
                 //Start - Added as a part of Defect - 379964
               
                userInfo.clientCount= String.valueOf(clientIndividualIds.size());
                //End - Added as a part of Defect - 379964
                dataToSend.put('bIsSuccess', true);
                dataToSend.put('nonCitizenInfo',userInfo);           
                dataToSend.put('searchResultCount', userInfo.clientCount);
                dataToSend.put('responseCode',responseCode);
                dataToSend.put('responseDescription',responseDescription);
                dataToSend.put(SSP_GlobalConstants.SECURITY_MATRIX_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.NON_CITIZEN_DASHBOARD_SCREENID, null));
            }
            catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardController', 'getNonCitizenUserInfo', ex.getMessage() , true);            
                dataToSend.put('bIsSuccess', false);            
                dataToSend.put('error', lstLogMessages[0].Id);
                dataToSend.addException(ex, lstLogMessages[0].Id);
            } 
            return dataToSend;
        }
    /***************************************************************************************************
    * @author       Rajeev Kumar
    * @date         09/30/2020
    * @methodname   onBoardIndvidualAuthRepCallout
    * @description  Method to Call onboard Individaul Auth Rep Service
    * @return       String: Error code if any else null
    *****************************************************************************************************/
    public static String onBoardIndvidualAuthRepCallout(Contact objContact) {
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.ONBOARD_INDV_AUTHREP ;
        reqWrapper.KeyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('FirstName',objContact.firstName));
        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('LastName',objContact.lastName));
        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('KogId',objContact.KOGSourceId__c)); 
        reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('EmailId',objContact.email)); 
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
        if(objList != null && !objList.isEmpty()) {
            RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
            if(responseWrapper != null && responseWrapper.ACKRESPONSE != null && responseWrapper.ACKRESPONSE.AckResponseCode != null) {
                return responseWrapper.ACKRESPONSE.AckResponseCode;
            }
        }
        return null;
    }
    
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/05/2020
* @methodname   getNonCitizenUserInfo
* @description  This method takes a user Id and gets it info form KOG side
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse searchNonCitizenClients(String userId,String searchQuery){
        SSP_Utility.isAuthenticatedUser(); 
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        
        try{
            searchQuery = trimSearchParams(searchQuery);
            blankSearchQuery(searchQuery);
            String userRole=SSP_Utility.getUserDetails(userId).get('userRole');
            getAssisters(userId);
            list<SSP_ApplicationIndividual__c> applicationList;
            ClientSearchResult csr;
            Map<String, ClientSearchResult> csrCaseMap= new Map<String, ClientSearchResult>(); //#375342
            list<ClientSearchResult> csrList= new list<ClientSearchResult>();
            list<ClientSearchResult> csrAppList= new list<ClientSearchResult>();
            List<Contact> contactList = new List<Contact>();
            list<AccountContactRelation> acrList= new list<AccountContactRelation>();
            Boolean searchAppWithCaseValues=false;
            String userDcID='';
            String orgDcId='';
            
            List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'},new Set<String>{'Id', 'ContactId'},new Map<String, String>{'limit'=>'1','Id'=> userId});             
            if(userList != null && userList.size() > 0){                
                contactList = [Select Id,DCDataId__c,KOGSourceId__c from Contact where Id=:userList[0].ContactId limit 1]; 
                acrList=[Select Id,Account.DCDataId__c,DCContactId__c from AccountContactRelation where Account.recordTypeId=:SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine') and ContactId=:userList[0].ContactId and (Account.DCDataId__c!=null OR DCContactId__c!=null) Limit 100]; 
            }
            if(acrList!=null && acrList.size()>0)
            {
                for(AccountContactRelation acr:acrList){
                    if(!String.isblank(String.ValueOf(acr.Account.DCDataId__c))){
                        orgDcId+=String.ValueOf(acr.Account.DCDataId__c)+';'; 
                    }
                    if(!String.isblank(String.ValueOf(acr.DCContactId__c))){
                        userDcID+=String.ValueOf(acr.DCContactId__c)+';';  
                    }                                      
                } 
            }                    
            userDcID=userDcID.removeEnd(';');                
            if(String.isBlank(userDcID) && contactList!=null && !contactList.isEmpty()){
                userDcID=String.ValueOf(contactList[0].KOGSourceId__c);
            }  
            orgDcId=orgDcId.removeEnd(';');
            
            ClientSearchQuery searchQueryResponse=(ClientSearchQuery)JSON.deserialize(searchQuery, ClientSearchQuery.class);
            String applicationSubmitted=searchQueryResponse.applicationSubmittedToggle;
            String applicationStatus=searchQueryResponse.applicationStatus; 
            String caseStatus=searchQueryResponse.caseStatus; 
            String renewalDueDate=searchQueryResponse.renewalDueDate;
            String rfiDueDate=searchQueryResponse.rfiDueDate; 
            String submittedDate=searchQueryResponse.submittedDate;
            if(String.isNotBlank(applicationStatus) || String.isNotBlank(caseStatus) || String.isNotBlank(renewalDueDate) || String.isNotBlank(rfiDueDate)){
                searchAppWithCaseValues=true; 
            }
            assistedBySearch=searchQueryResponse.assistedBy;
            if(applicationSubmitted=='false' || caseSearchRoles.contains(userRole)){                
                csrCaseMap =searchCaseCallout(userId,userRole,searchQuery,userDcID,orgDcId); //#375342               
                csrList = csrCaseMap != null && !csrCaseMap.isEmpty() ? csrCaseMap.values() : csrList; //#375342
            }else if(applicationSubmitted=='true'){ 
                csrAppList=searchApplications(userId,userRole,searchQuery);               
                if(!searchAppWithCaseValues){                        
                    csrList.addAll(csrAppList);
                }            
            }else{ 
                if(!searchIsBlank){                    
                    csrAppList=searchApplications(userId,userRole,searchQuery); 
                    csrCaseMap = searchCaseCallout(userId,userRole,searchQuery,userDcID,orgDcId); //#375342
                   // csrList = mergeCaseAndAppData(csrCaseMap, csrAppList); //#375342 commented for 380146 
                   // Start - changes for 380146 defect 
                     if(!( String.isNotBlank(caseStatus) || String.isNotBlank(renewalDueDate) || String.isNotBlank(rfiDueDate))){
                                  
                        csrList = mergeCaseAndAppData(csrCaseMap, csrAppList); 
                    } 
                    else{
                        csrList = csrCaseMap != null && !csrCaseMap.isEmpty() ? csrCaseMap.values() : csrList; //#375342
                    }
                     // End - changes for 380146 defect 
                }else{                    
                    csrCaseMap = searchCaseCallout(userId,userRole,searchQuery,userDcID,orgDcId); //#375342                    
                    csrAppList=searchApplications(userId,userRole,searchQuery);               
                    if(!searchAppWithCaseValues){                        
                        csrList = mergeCaseAndAppData(csrCaseMap, csrAppList); //#375342
                    } 
                    else{
                        csrList = csrCaseMap != null && !csrCaseMap.isEmpty() ? csrCaseMap.values() : csrList; //#375342
                    }
                }                
            }
            csrList.sort();
            csrList=setResultValueBasedOnRole(csrList,userRole);
            List<ClientSearchResult> newList = new  List<ClientSearchResult>();
            if( (userRole.equalsIgnoreCase('Assister')|| userRole.equalsIgnoreCase('Organization_auth_rep')||userRole.equalsIgnoreCase('Individual_auth_rep')) && searchIsBlank && csrList.size()>0 && !csrList.isEmpty()){
                for(Integer i=0;i<csrList.size();i++){                    
                    if(!csrList[i].isCase && String.isBlank(csrList[i].assistedByAssister) && String.isBlank(csrList[i].assistedByAuthRep)){
                       // csrList.remove(i); 
                    }
                    else {
                        newList.add(csrList[i]);
                    }
                }             
            }
            else {
               newList = csrList;
            }
            
           
          
            
            dataToSend.put('searchResultDataNC',newList);
            dataToSend.put('bIsSuccess', true);  
            dataToSend.put('responseCode',responseCode);
            dataToSend.put('responseDescription',responseDescription);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardController', 'searchNonCitizenClients', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;
    } 

    //#375342 - Method to merge applications and cases belonging to same individualId
    private static List<ClientSearchResult> mergeCaseAndAppData(Map<String, ClientSearchResult> indvIdToCaseCSRMap, List<ClientSearchResult> appCSRList){
        List<ClientSearchResult> finalList = new List<ClientSearchResult>();
        if(indvIdToCaseCSRMap != null &&  !indvIdToCaseCSRMap.isEmpty() && appCSRList != null && !appCSRList.isEmpty()){                        
            for(ClientSearchResult csr : appCSRList){   
                ClientSearchResult tmpCSR = new ClientSearchResult();               
                if(indvIdToCaseCSRMap.containsKey(csr.individualId)){
                    tmpCSR = indvIdToCaseCSRMap.get(csr.individualId);  
                    tmpCSR.applicationNumber = csr.applicationNumber;
                    tmpCSR.isApplication = true;
                    tmpCSR.caseApplicationStatus = String.isNotBlank(tmpCSR.caseApplicationStatus) ? tmpCSR.caseApplicationStatus+','+csr.caseApplicationStatus : csr.caseApplicationStatus ;
                    tmpCSR.lastupdatedDate = (tmpCSR.lastupdatedDate != null && csr.lastupdatedDate != null) ? ((tmpCSR.lastupdatedDate >  csr.lastupdatedDate) ? tmpCSR.lastupdatedDate : csr.lastupdatedDate) : (tmpCSR.lastupdatedDate != null ? tmpCSR.lastupdatedDate : csr.lastupdatedDate);
                    indvIdToCaseCSRMap.put(csr.individualId, tmpCSR);
                }else{
                    indvIdToCaseCSRMap.put(csr.individualId, csr); 
                }
            } 
            finalList = indvIdToCaseCSRMap.values();
        }
        else{
            finalList = (indvIdToCaseCSRMap != null &&  !indvIdToCaseCSRMap.isEmpty())  ? indvIdToCaseCSRMap.values() : ((appCSRList != null && !appCSRList.isEmpty()) ? appCSRList : new List<ClientSearchResult>());
        }
        return finalList;
    }

    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         04/28/2020
* @methodname   getAgeOfClient
* @description  This method takes Date Of Birth and Returns Age
* @return       Integer
*****************************************************************************************************/
    public static Integer getAgeOfClient(String DateOfBirth){
        Integer age=0;
        if(!String.isBlank(DateOfBirth)){
            list<String> dates=DateOfBirth.split('-');
            Date dob = Date.newInstance(Integer.valueOf(dates[0]), Integer.valueOf(dates[1]),Integer.valueOf(dates[2]));        
            age=Integer.ValueOf(dob.daysBetween(Date.Today())/365.2425);
        } 
        return age;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/20/2020
* @methodname   searchCaseCallout
* @description  This method makes Callout to search for cases only
* @return       list<ClientSearchResult>
*****************************************************************************************************/
    public static Map<String, ClientSearchResult> searchCaseCallout(String userId,String userRole, String searchQuery,String userIdDC,String orgId){ //#375342
        Map<String, ClientSearchResult> csrMap= new Map<String, ClientSearchResult>(); //#375342
        ClientSearchResult csr= new ClientSearchResult();       
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.KeyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
        if(String.isNotBlank(searchQuery)){
            ClientSearchQuery searchQueryResponse=(ClientSearchQuery)JSON.deserialize(searchQuery, ClientSearchQuery.class);
            
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('UserId',userIdDC));
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('organizationId',orgId));
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('AssistedbyRole',userRole));
            
            String firstName=searchQueryResponse.firstName;
            if(String.isNotBlank(firstName)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('FirstName',firstName));
            }
            String lastName=searchQueryResponse.lastName;
            if(String.isNotBlank(lastName)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('LastName',lastName));
            }            
            String assistedBy=searchQueryResponse.assistedBy;
            if(String.isNotBlank(assistedBy)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('Assistedby',assistedBy));
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('AssisterName',assistedBy));
            }            
            String caseApplication=searchQueryResponse.caseApplication;
            if(String.isNotBlank(caseApplication)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('CaseNumber',caseApplication));
            }
            String ssn=searchQueryResponse.ssn;
            if(String.isNotBlank(ssn)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('SSN',ssn));
            }
            String dob=searchQueryResponse.dob;
            if(String.isNotBlank(dob)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('BirthDate',dob));
            }
            String gender=searchQueryResponse.gender;
            if(String.isNotBlank(gender)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('Gender',gender));
            }
            String addressLine1=searchQueryResponse.addressLine1;
            if(String.isNotBlank(addressLine1)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('AddressLine1',addressLine1));
            }
            String county=searchQueryResponse.county;
            if(String.isNotBlank(county)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('County',county));
            }
            String phone=searchQueryResponse.phone;  
            if(String.isNotBlank(phone)){
                phone=phone.remove('-');
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('PhoneNumber',phone));
            }        
            String email=searchQueryResponse.email;  
            if(String.isNotBlank(email)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('EmailAddress',email));
            }          
            String maidNumber=searchQueryResponse.maidNumber;  
            if(String.isNotBlank(maidNumber)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('MaidCardNumber',maidNumber));
            }          
            String caseStatus=searchQueryResponse.caseStatus; 
            if(String.isNotBlank(caseStatus)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('CaseStatus',caseStatus));
            } 
            String renewalDueDate=searchQueryResponse.renewalDueDate;
            if(String.isNotBlank(renewalDueDate)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('RenewalDueDate',renewalDueDate));
            }
            String rfiDueDate=searchQueryResponse.rfiDueDate; 
            if(String.isNotBlank(rfiDueDate)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('RFIDueDate',rfiDueDate));
            }
            String submittedDate1=searchQueryResponse.submittedDate;    
            if(String.isNotBlank(submittedDate1)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('SubmittedDate',submittedDate1));
            }
            String applicationStatus=searchQueryResponse.applicationStatus;  
            if(String.isNotBlank(applicationStatus)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('EnrollmentStatus',applicationStatus));
            }        
            
            reqWrapper.viewName = SSP_InterfaceConstants.NON_CITIZEN_SEARCH_CASE;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            if(objList != null && !objList.isEmpty()) { //Added this Null check because it was giving Null Exception
                RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0); 
                if(responseWrapper != null) {
                    SSP_AckResponseWRapper callOutResponse=responseWrapper.ACKRESPONSE;
                    if(responseWrapper.AckResponse ==null ){//&& responseWrapper.ACKRESPONSE.AckResponseCode !=null){           
                        NonCitizenSearchCasePayloadWrapper nonCitizenInfo=responseWrapper.nonCitizenSearchCasePayload;
                        if(responseWrapper.nonCitizenSearchCasePayload!=NULL){
                            for(NonCitizenSearchCasePayloadWrapper.CaseInfoWrapper caseInfo:nonCitizenInfo.CaseInfo){ 
                                String subDate=caseInfo.SubmittedDate;
                                List<String> dateParts = subDate.split('-');
                                Datetime submittedDate = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));                    
                                String lastDate=caseInfo.LastupdatedDate;                
                                list<String> lastDateParts=lastDate.split('-');
                                DateTime lastupdatedDate=Datetime.newInstance(Integer.valueOf(lastDateParts[0]), Integer.valueOf(lastDateParts[1]), Integer.valueOf(lastDateParts[2]));
                                csr=new ClientSearchResult('',String.valueOf(caseInfo.CaseNumber),'',String.ValueOf(caseInfo.IndividualId),caseInfo.FirstName,caseInfo.LastName,caseInfo.GenderCode,caseInfo.BirthDate,getAgeOfClient(caseInfo.BirthDate),caseInfo.AddressLine1,caseInfo.AddressLine2,caseInfo.ZipCode,caseInfo.PhoneNumber,caseInfo.EmailAddress,caseInfo.SSN,'',caseInfo.AssistedbyAuthRep,caseInfo.AssistedbyAsister,caseInfo.ClientRole,caseInfo.RFIDueDate,caseInfo.NumberofRFI,caseInfo.RenewalDueDate,caseInfo.ProgramDueRenewal,caseInfo.MCOEnrollmentStatus,caseInfo.CaseStatus,submittedDate.format(SSP_GlobalConstants.DATEFORMAT),lastupdatedDate.format(SSP_GlobalConstants.DATEFORMAT),caseInfo.MaidCardNumber,false,true);                
                                //#376149
                                if(caseInfo != null ){
                                    if(String.isNotBlank(caseInfo.Suffix)){
                                        csr.suffix = caseInfo.Suffix;
                                    }
                                    if(String.isNotBlank(caseInfo.MiddleInitial)){
                                        csr.middleInitial = caseInfo.MiddleInitial; 
                                    }
                                    //Start - Added as part of Defect - 382855
                                    if(String.isNotBlank(caseInfo.CaseStatusSpanish) && UserInfo.getLanguage() == SSP_GlobalConstants.ES_US) {
                                        csr.caseApplicationStatus = caseInfo.CaseStatusSpanish;
                                    } else if(String.isNotBlank(caseInfo.CaseStatus)) {
                                        csr.caseApplicationStatus = caseInfo.CaseStatus;
                                    }
                                    //End -  Added as part of Defect - 382855
                                }
                                csr = filterCasesBasedOnStatus(csr); //#375346
                                csrMap.put(csr.individualId, csr);  //#375342             
                            }
                        }
                    }else{
                        responseCode=callOutResponse.AckResponseCode;
                        responseDescription=callOutResponse.AckResponseDescription;
                    }
                }
            }
        }else if(!SSP_GlobalConstants.waiverRoles.contains(userRole)){
            
            reqWrapper.viewName = SSP_InterfaceConstants.NON_CITIZEN_Client_INFORMATION;
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('UserId',userIdDC)); 
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('organizationId',orgId)); 
            reqWrapper.role = userRole;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0); 
            SSP_AckResponseWRapper callOutResponse=responseWrapper.AckResponse;
            
            if(responseWrapper.AckResponse==null){//} && responseWrapper.AckResponse.AckResponseCode !=null){ 
                SSP_NonCitizenClientInfoPayloadWrapper nonCitizenInfo=responseWrapper.nonCitizenClientInfoPayload;            
                if(nonCitizenInfo!=null && nonCitizenInfo.ClientCountInfo[0].IndividualIds!=null){
                   clientIndividualIds.addAll(nonCitizenInfo.ClientCountInfo[0].IndividualIds.split(';'));                                        
                }
                if(nonCitizenInfo.ClientCountInfo[0].ClientCount<=10 && nonCitizenInfo.ClientCountInfo[0].ClientCount>0){
                    for(SSP_NonCitizenClientInfoPayloadWrapper.CaseInfoWrapper caseInfo:nonCitizenInfo.CaseInfo){ 
                        String subDate=caseInfo.SubmittedDate;
                        List<String> dateParts = subDate.split('-');
                        Datetime submittedDate = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2])); 
                        String lastDate1=caseInfo.LastupdatedDate;
                        list<String> lastDateParts=lastDate1.split('-');
                        DateTime lastupdatedDate=Datetime.newInstance(Integer.valueOf(lastDateParts[0]), Integer.valueOf(lastDateParts[1]), Integer.valueOf(lastDateParts[2]));
                        csr=new ClientSearchResult('',String.valueOf(caseInfo.CaseNumber),'',String.ValueOf(caseInfo.IndividualId),caseInfo.FirstName,caseInfo.LastName,caseInfo.GenderCode,caseInfo.BirthDate,getAgeOfClient(caseInfo.BirthDate),caseInfo.AddressLine1,caseInfo.AddressLine2,caseInfo.ZipCode,caseInfo.PhoneNumber,caseInfo.EmailAddress,caseInfo.SSN,'',caseInfo.AssistedbyAuthRep,caseInfo.AssistedbyAsister,caseInfo.ClientRole,caseInfo.RFIDueDate,caseInfo.NumberofRFI,caseInfo.RenewalDueDate,caseInfo.ProgramDueRenewal,caseInfo.MCOEnrollmentStatus,caseInfo.CaseStatus,submittedDate.format(SSP_GlobalConstants.DATEFORMAT),lastupdatedDate.format(SSP_GlobalConstants.DATEFORMAT),caseInfo.MaidCardNumber,false,true);                                        
                        //#376149
                        if(caseInfo != null ){
                            if(String.isNotBlank(caseInfo.Suffix)){
                                csr.suffix = caseInfo.Suffix;
                            }
                            if(String.isNotBlank(caseInfo.MiddleInitial)){
                                csr.middleInitial = caseInfo.MiddleInitial; 
                            }
                            //Start - Added as part of Defect - 382855
                            if(String.isNotBlank(caseInfo.CaseStatusSpanish) && UserInfo.getLanguage() == SSP_GlobalConstants.ES_US) {
                                csr.caseApplicationStatus = caseInfo.CaseStatusSpanish;
                            } else if(String.isNotBlank(caseInfo.CaseStatus)) {
                                csr.caseApplicationStatus = caseInfo.CaseStatus;
                            }
                            //End -  Added as part of Defect - 382855
                        }
                        csr = filterCasesBasedOnStatus(csr); //#375346
                        csrMap.put(csr.individualId, csr);  //#375342               
                    }  
                } 
                //Start - Added as a part of Defect - 379964
                else if(nonCitizenInfo.ClientCountInfo!=null && !nonCitizenInfo.ClientCountInfo.isEmpty() && nonCitizenInfo.ClientCountInfo[0].ClientCount > 10){
                    iClientCount = Integer.valueOf(nonCitizenInfo.ClientCountInfo[0].ClientCount);
                    bIsClientCountGreater = true;
                }
                //End - Added as a part of Defect - 379964 
            }
            else{
                responseCode=callOutResponse.AckResponseCode;
                responseDescription=callOutResponse.AckResponseDescription;
            }
        }        
        return csrMap; //#375342
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/20/2020
* @methodname   searchApplications
* @description  This method makes searchs only applications in SFDC
* @return       list<ClientSearchResult>
*****************************************************************************************************/
    public static list<ClientSearchResult> searchApplications(String userId,String userRole, String searchQuery){
        list<SSP_ApplicationIndividual__c> applicationList= new list<SSP_ApplicationIndividual__c>();
        list<ClientSearchResult> csrList= new list<ClientSearchResult>();
        Map<String,ClientSearchResult> csrlistToIndividualIDMap= new Map<String,ClientSearchResult>();
        Map<Id,String> mapClientAccountIdToNonCitizenRole = new  Map<Id,String>();
        ClientSearchResult csr= new ClientSearchResult(); 
        
        if(accessToUserRoleMap.get('accessAssociatedToIndividual').contains(userRole)){
            applicationList=SSP_NonCitizenDashboardService.searchClientRealtedToIndividual(userId,userRole,searchQuery);                            
        }            
        else if(accessToUserRoleMap.get('accessAssociatedToOrganisation').contains(userRole)){
            applicationList=searchClientRelatedToUserOrganisation(userId,userRole,searchQuery);                
        }        
        else if(accessToUserRoleMap.get('allAccess').contains(userRole)){
            applicationList=searchClientOrganisationWide(userId,userRole,searchQuery);
        }
        
        Set<Id> wrapperAccountIds= new Set<Id>();
        for(SSP_ApplicationIndividual__c appIndi:applicationList){                
            wrapperAccountIds.add(appIndi.SSP_Application__r.Account__c);               
        }
        for(AccountContactRelation acrRecord :[SELECT Id,AccountId,CreatedDate,ContactId,Contact.FirstName,Contact.Lastname , Roles FROM AccountContactRelation WHERE AccountId in:wrapperAccountIds AND Roles!=null]){                    
            if(!mapClientAccountIdToAssisterDetails.containsKey(acrRecord.ContactId)){
                mapClientAccountIdToAssisterDetails.put(acrRecord.AccountId, acrRecord.Contact.FirstName+' '+acrRecord.Contact.Lastname);
                mapClientAccountIdToNonCitizenRole.put(acrRecord.AccountId,acrRecord.Roles);
            }
        } 
        
        if(applicationList.size()>0 && !applicationList.isEmpty()){
            for(SSP_ApplicationIndividual__c appIndi:applicationList){
                if(appIndi != null && appIndi.SSP_Application__r != null && isActive(appIndi.SSP_Application__r.ApplicationCreationInSSP__c)){ //#378934
                    Datetime lastModi=appIndi.SSP_Application__r.LastModifiedDate;
                    String clientRole=appIndi.IsHeadOfHousehold__c?'HeadofHousehold':'Dependent';
                    csr=new ClientSearchResult(String.ValueOf(appIndi.id),'',String.valueOf(appIndi.SSP_Application__r.Name),appIndi.SSP_Member__r.IndividualId__c,appIndi.SSP_Member__r.FirstName__c,appIndi.SSP_Member__r.LastName__c,appIndi.SSP_Member__r.GenderCode__c,String.ValueOf(appIndi.SSP_Member__r.BirthDate__c),getAgeOfClient(String.ValueOf(appIndi.SSP_Member__r.BirthDate__c)), appIndi.SSP_Member__r.MailingAddressLine1__c, appIndi.SSP_Member__r.MailingAddressLine2__c, appIndi.SSP_Member__r.MailingZipCode5__c, appIndi.SSP_Member__r.PrimaryPhoneNumber__c, appIndi.SSP_Member__r.Email__c, appIndi.SSP_Member__r.SSN__c, appIndi.SSP_Member__r.SSN__c, '','', clientRole,'','','','','',appIndi.SSP_Application__r.Status__c,'',lastModi.format(SSP_GlobalConstants.DATEFORMAT), appIndi.SSP_Member__r.MaidCardNumber__c,true,false);
                    if(mapClientAccountIdToNonCitizenRole.containsKey(appIndi.SSP_Application__r.Account__c)){
                       if(mapClientAccountIdToNonCitizenRole.get(appIndi.SSP_Application__r.Account__c).equalsIgnoreCase('Individual_auth_Rep') ||mapClientAccountIdToNonCitizenRole.get(appIndi.SSP_Application__r.Account__c).equalsIgnoreCase('Organization_auth_Rep') ){
                            csr.assistedbyAuthRep=mapClientAccountIdToAssisterDetails.get(appIndi.SSP_Application__r.Account__c); 
                        }
                        else if(mapClientAccountIdToNonCitizenRole.get(appIndi.SSP_Application__r.Account__c)=='Assister'){
                            csr.assistedByAssister=mapClientAccountIdToAssisterDetails.get(appIndi.SSP_Application__r.Account__c); 
                        }
                    }    
                    csrList.add(csr);
                } //#378934
            }  
        }
        ClientSearchResult tempList;
        //map based on Contact ID, and Individual Id will be Prefered Individual Id
        for(ClientSearchResult csr1:csrList){   
            tempList= new ClientSearchResult();  
            String appIds = '';   //#375342, #376335   
            if(csrlistToIndividualIDMap.containsKey(csr1.individualId)){
                tempList=csrlistToIndividualIDMap.get(csr1.individualId);                
                appIds+=','+csr1.applicationNumber;                
                tempList.applicationNumber=appIds.removeStart(',');                
                csrlistToIndividualIDMap.put(csr1.individualId, tempList);
            }else{
                csrlistToIndividualIDMap.put(csr1.individualId, csr1); 
            }
        }        
        csrList= new list<ClientSearchResult>();
        for(String str:csrlistToIndividualIDMap.keySet()){
            csrList.add(csrlistToIndividualIDMap.get(str));
        }
        return csrList;
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         07/15/2020
    * @methodname   searchClientRelatedToUserOrganisation
    * @description  This method is used to check if the application creation date is within past 8 day (considering present date) (#378934)
    * @return       Boolean
    *****************************************************************************************************/
     @TestVisible
    private static Boolean isActive(Date appCreationDate){
        Boolean result = false;
        if(appCreationDate != null){
            Date dateToday = SSP_utility.today();
            Integer difference = appCreationDate.daysBetween(SSP_utility.today());
            if(difference >=0 && difference <=8){
                result = true;
            }
        }
        return result;
    }

    
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/25/2020
* @methodname   searchClientRelatedToUserOrganisation
* @description  This method takes userId,userRole,searchQuery and returns List of Application realted to user orgaization
* @return       list<SSP_ApplicationIndividual__c>
*****************************************************************************************************/
    public static list<SSP_ApplicationIndividual__c> searchClientRelatedToUserOrganisation(String userId,String userRole,String searchQuery){
        Set<String> loggedInACRAccounts = new Set<String>();
        Set<Id> setContactIdsWithinOrganization = new Set<Id>(); 
        Set<String> setApprovedRequestId = new Set<String>(); //Defect 385706
        User loggedInUser = [SELECT Id, ContactId from user where id = :userId];        
        if(searchIsBlank){

            for(AccountContactRelation acrRecord : [SELECT Id, Contact.FirstName, Contact.LastName,ContactId, AccountId,RequestAccessPermission__c  FROM AccountContactRelation 
                                                    WHERE ContactId =:loggedInUser.ContactId and Account.Recordtype.Name = 'Application' ]){
                                                        setofClientAccountId.add(String.valueOf(acrRecord.AccountId));
                                                    }   
            
        }
        else{
            for(AccountContactRelation loggedInACR: [SELECT Id,Contact.FirstName, Contact.LastName,ContactId, AccountId  FROM AccountContactRelation WHERE ContactId = :loggedInUser.ContactId AND Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION]){
                loggedInACRAccounts.add(loggedInACR.AccountId); //Org account ids 
            }     
            for(AccountContactRelation acrRecord : [SELECT Id, Contact.FirstName, Contact.LastName,ContactId FROM AccountContactRelation WHERE AccountId in :loggedInACRAccounts]){           
                setContactIdsWithinOrganization.add(acrRecord.ContactId); //All contacts related to current users org
            }
            for(AccountContactRelation acrRecord : [SELECT Id, Contact.FirstName, Contact.LastName,ContactId, AccountId,RequestAccessPermission__c  FROM AccountContactRelation 
                                                    WHERE ContactId IN :setContactIdsWithinOrganization OR (AccountId in :loggedInACRAccounts 
                                                                                                            AND Contact.Recordtype.DeveloperName = :SSP_GlobalConstants.CITIZEN)]){
                                                                                                                setofClientAccountId.add(String.valueOf(acrRecord.AccountId));
                                                                                                                //Defect 385706 - Start
                                                                                                                if(userRole.equalsIgnoreCase('Organization_Auth_Rep') && acrRecord.RequestAccessPermission__c == null){
                                                                                                                    setApprovedRequestId.add(String.valueOf(acrRecord.AccountId));
                                                                                                                }
                                                                                                                //Defect 385706 - End
                                                                                                            }
        }
        if(String.isBlank(searchQuery)){
            queryAccessAssociated=queryAccessAssociated.remove('$searchQuery$'); 
        }else{
            String whereClause=buildWhereClause(searchQuery,userRole);
            queryAccessAssociated=queryAccessAssociated.replace('$searchQuery$', whereClause);
        }
        List<SSP_ApplicationIndividual__c> applicationList=(List<SSP_ApplicationIndividual__c>)Database.query(queryAccessAssociated);                
        //Defect 385706 - Start
        //return applicationList;		
        List<SSP_ApplicationIndividual__c> lstAppIndivToReturn = new List<SSP_ApplicationIndividual__c>();
        
	if(userRole.equalsIgnoreCase('Organization_Auth_Rep')){                        
            for(SSP_ApplicationIndividual__c app : applicationList){

                if(setApprovedRequestId.contains(app.SSP_Application__r.Account__c)){
                    lstAppIndivToReturn.add(app);
                }
            }   
        }
        else{
            lstAppIndivToReturn = applicationList;
        }         
        return lstAppIndivToReturn;
        //Defect 385706 - End
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/25/2020
* @methodname   searchClientOrganisationWide
* @description  This method takes userId,userRole,searchQuery and returns List of Application Across Org
* @return       list<SSP_ApplicationIndividual__c>
*****************************************************************************************************/
    public static list<SSP_ApplicationIndividual__c> searchClientOrganisationWide(String userId,String userRole,String searchQuery){
        if(String.isNotBlank(searchQuery)){
            String whereClause=buildWhereClause(searchQuery,userRole);
            query=query.replace('$searchQuery$', whereClause);            
        }else{
            query=query.remove('$searchQuery$');
        }

        return (List<SSP_ApplicationIndividual__c>)Database.query(query);        
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/25/2020
* @methodname   blankSearchQuery
* @description  This method takes searchQuery and returns if its blank search
* @return       list<SSP_ApplicationIndividual__c>
*****************************************************************************************************/
    public static boolean blankSearchQuery(String searchQuery){
        searchIsBlank = false ;
        ClientSearchQuery searchQueryResponse=(ClientSearchQuery)JSON.deserialize(searchQuery, ClientSearchQuery.class);
        String firstName=searchQueryResponse.firstName;
        String lastName=searchQueryResponse.lastName;
        String caseApplication=searchQueryResponse.caseApplication;
        String ssn=searchQueryResponse.ssn;
        String dob=searchQueryResponse.dob;
        String gender=searchQueryResponse.gender;
        String addressLine1=searchQueryResponse.addressLine1;
        String county=searchQueryResponse.county;            
        String assistedBy=searchQueryResponse.assistedBy;
        String phone=searchQueryResponse.phone;        
        String email=searchQueryResponse.email;            
        String maidNumber=searchQueryResponse.maidNumber;
        String applicationStatus=searchQueryResponse.applicationStatus; 
        String caseStatus=searchQueryResponse.caseStatus; 
        String renewalDueDate=searchQueryResponse.renewalDueDate;
        String rfiDueDate=searchQueryResponse.rfiDueDate; 
        String submittedDate=searchQueryResponse.submittedDate;
        String applicationSubmitted=searchQueryResponse.applicationSubmittedToggle;        
        
        if(String.isBlank(firstName) &&String.isBlank(lastName) &&String.isBlank(caseApplication) &&String.isBlank(ssn) &&String.isBlank(dob) &&String.isBlank(gender) &&String.isBlank(addressLine1) && 
           String.isBlank(county) &&String.isBlank(assistedBy) &&String.isBlank(phone) &&String.isBlank(email) &&String.isBlank(maidNumber) && String.isBlank(applicationStatus) && String.isBlank(caseStatus) && 
           String.isBlank(renewalDueDate) && String.isBlank(rfiDueDate) && String.isBlank(applicationSubmitted)  && (submittedDate.equalsIgnoreCase('LR') ||String.isBlank(submittedDate) )) {
               searchIsBlank = true; 
           }  
        return searchIsBlank;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/25/2020
* @methodname   buildWhereClause
* @description  This method takes userRole,searchQuery and returns Where Clause
* @return       list<SSP_ApplicationIndividual__c>
*****************************************************************************************************/
    public static String buildWhereClause(String searchQuery,String userRole){
        
        ClientSearchQuery searchQueryResponse=(ClientSearchQuery)JSON.deserialize(searchQuery, ClientSearchQuery.class);        
        String whereClause='';
        String firstName=searchQueryResponse.firstName;
        String lastName=searchQueryResponse.lastName;
        String caseApplication=searchQueryResponse.caseApplication;
        String ssn=searchQueryResponse.ssn;
        String dob=searchQueryResponse.dob;
        String gender=searchQueryResponse.gender;
        String addressLine1=searchQueryResponse.addressLine1;
        String county=searchQueryResponse.county;            
        String assistedBy=searchQueryResponse.assistedBy;
        String phone=searchQueryResponse.phone;        
        String email=searchQueryResponse.email;            
        String maidNumber=searchQueryResponse.maidNumber;
        Set<Id> assisterIds= new Set<Id>();        
        
        if(String.isNotBlank(assistedBy)){
            assistedbyBlank=true;
            setofClientAccountId.clear();
            for(AccountContactRelation acrRecord :[SELECT Id,AccountId,CreatedDate,ContactId,Contact.FirstName,Contact.Lastname FROM AccountContactRelation WHERE DCContactId__c =:Decimal.valueOf(assistedBy) AND Roles!=null]){   
                setofClientAccountId.add(acrRecord.AccountId);
                if(!mapClientAccountIdToAssisterDetails.containsKey(acrRecord.ContactId)){
                    mapClientAccountIdToAssisterDetails.put(acrRecord.AccountId, acrRecord.Contact.FirstName+' '+acrRecord.Contact.Lastname);
                }
            }
        }
        
        if( (String.isBlank(firstName) && String.isBlank(lastName) && String.isBlank(ssn) && String.isBlank(dob)
           && String.isBlank(gender) && String.isBlank(email)&& String.isBlank(phone) && !searchIsBlank) || searchIsBlank){
               whereClause+=' AND IsHeadOfHousehold__c=true ';
           }
        if(String.isNotBlank(assistedBy)){
            whereClause+=' AND SSP_Application__r.Account__c in :setofClientAccountId';
        }
        if(String.isNotBlank(firstName)){
            whereClause+=' AND SSP_Member__r.FirstName__c LIKE \'%'+String.escapeSingleQuotes(firstName)+'%\' ';
        }
        if(String.isNotBlank(lastName)){
            whereClause+=' AND SSP_Member__r.LastName__c LIKE \'%'+String.escapeSingleQuotes(lastName)+'%\' ';
        }
        if(String.isNotBlank(caseApplication)){         
            whereClause += ' AND SSP_Application__r.Name =\''+String.escapeSingleQuotes(caseApplication)+'\' ';          
        }
        if(String.isNotBlank(ssn)){
            whereClause+=' AND SSP_Member__r.SSN__c LIKE \'%'+String.escapeSingleQuotes(ssn)+'%\' ';
        }
        if(String.isNotBlank(dob)){
            whereClause+=' AND SSP_Member__r.BirthDate__c='+String.escapeSingleQuotes(dob);
        }
        if(String.isNotBlank(gender)){
            whereClause+=' AND SSP_Member__r.GenderCode__c=\''+String.escapeSingleQuotes(gender)+'\' ';
        }        
        if(String.isNotBlank(addressLine1)){
            whereClause+=' AND SSP_Member__r.MailingAddressLine1__c LIKE \'%'+String.escapeSingleQuotes(addressLine1)+'%\' ';
        }
        if(String.isNotBlank(county)){
            whereClause+=' AND SSP_Member__r.MailingCountyCode__c=\''+String.escapeSingleQuotes(county)+'\' ';
        }
        if(String.isNotBlank(phone)){
            whereClause+=' AND SSP_Member__r.PrimaryPhoneNumber__c=\''+String.escapeSingleQuotes(phone)+'\' ';
        }
        if(String.isNotBlank(maidNumber)){
            whereClause+=' AND SSP_Member__r.MaidCardNumber__c=\''+String.escapeSingleQuotes(maidNumber)+'\'';
        }
        if(String.isNotBlank(email)){
            whereClause+=' AND SSP_Member__r.Email__c=\''+String.escapeSingleQuotes(email)+'\' ';
        }        
       /* if(String.isBlank(firstName) &&String.isBlank(lastName) &&String.isBlank(caseApplication) &&String.isBlank(ssn) &&String.isBlank(dob) &&String.isBlank(gender) &&String.isBlank(addressLine1) &&String.isBlank(county) &&String.isBlank(assistedBy) &&String.isBlank(phone) &&String.isBlank(email) &&String.isBlank(maidNumber)){
            searchIsBlank=true;
        }      */ 
        return whereClause;        
    }

    //#375346
    public static Set<String> inactiveCasesKeywords = new Set<String>{SSP_GlobalConstants.DENIED_LABEL, SSP_GlobalConstants.DISCONTINUED_LABEL};
    public static ClientSearchResult filterCasesBasedOnStatus(ClientSearchResult csr){
        List<String> caseStatusList = String.isNotBlank(csr.caseApplicationStatus) ? csr.caseApplicationStatus.split(',') : new List<String>();
        List<String> caseNumberList = String.isNotBlank(csr.caseNumber) ? csr.caseNumber.split(',') : new List<String>();
        String updatedStatus = '';
        String updatedCaseNumbers = '';
        if(caseStatusList.size() == caseNumberList.size() && caseStatusList.size() > 0 &&
            (caseStatusList.contains(SSP_GlobalConstants.DISCONTINUED_LABEL) || caseStatusList.contains(SSP_GlobalConstants.DENIED_LABEL)) && (caseStatusList.contains(SSP_GlobalConstants.APPROVED_LABEL) || caseStatusList.contains(SSP_GlobalConstants.PENDING_LABEL))){
                Integer index = 0;
                for(String status : caseStatusList){
                    if(!inactiveCasesKeywords.contains(status)){
                        updatedStatus += String.isNotBlank(updatedStatus) ? ',' : '';
                        updatedCaseNumbers += String.isNotBlank(updatedCaseNumbers) ? ',' : '';

                        updatedStatus += status;
                        updatedCaseNumbers += caseNumberList.get(index);
                    }
                    index++;                
            }
            csr.caseApplicationStatus = updatedStatus.removeEnd(',');
            csr.caseNumber = updatedCaseNumbers.removeEnd(',');
        }        
        return csr;
    }

    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/27/2020
* @methodname   setResultValueBasedOnRole
* @description  This method takes userRole,list<ClientSearchResult> and Map of Field Visibility to Field Name
* @return       list<ClientSearchResult>
*****************************************************************************************************/
    public static list<ClientSearchResult> setResultValueBasedOnRole(list<ClientSearchResult> csrList, String userRole){
        SSP_LightningResponse filedVisibility=getNonCitizenUserRoleVisibility(userRole);
        list<ClientSearchResult> csrListUpdate= new list<ClientSearchResult>();        
        Map<String,Boolean> fieldPermissions=fieldPermissionsMap;
        for(ClientSearchResult csr:csrList){            
            csr.firstName=fieldPermissions.get('SSP_Excel_First_Name')?csr.firstName:'';
            csr.lastName=fieldPermissions.get('SSP_Excel_Last_Name')?csr.lastName:'';
            csr.gender=fieldPermissions.get('SSP_Excel_Gender')?csr.gender:'';
            csr.addressLine1=fieldPermissions.get('SSP_Excel_Address_Line_1')?csr.addressLine1:'';
            csr.addressLine2=fieldPermissions.get('SSP_Excel_Address_Line_2')?csr.addressLine2:'';
            csr.zipcode=fieldPermissions.get('SSP_Excel_Zip_Code')?csr.zipcode:'';
            csr.phoneNumber=fieldPermissions.get('SSP_Excel_Phone_Number')?csr.phoneNumber:'';
            csr.email=fieldPermissions.get('SSP_Excel_Email_Address')?csr.email:'';
            csr.ssn4=fieldPermissions.get('SSP_Excel_SSN4')?csr.ssn4:'';
            csr.ssn9=fieldPermissions.get('SSP_Excel_SSN9')?csr.ssn9:'';
            csr.age=fieldPermissions.get('SSP_Excel_Email_Address')?csr.age:null;
            csr.assistedByAssister=fieldPermissions.get('SSP_Excel_Assisted_By_Assister')?csr.assistedByAssister:'';
            csr.assistedByAuthRep=fieldPermissions.get('SSP_Excel_Assisted_By_AuthRep')?csr.assistedByAuthRep:'';
            csr.clientRole=fieldPermissions.get('SSP_Excel_Client_Role')?csr.clientRole:'';
            csr.rfiDueDate=fieldPermissions.get('SSP_Excel_RFI_Due_Date')?csr.rfiDueDate:'';
            csr.numberOfRFI=fieldPermissions.get('SSP_Excel_RFI_Due_Date')?csr.numberOfRFI:'';
            csr.renewalDueDate=fieldPermissions.get('SSP_Excel_Renewal_Due_Date')?csr.renewalDueDate:'';
            csr.programDueRenewal=fieldPermissions.get('SSP_Excel_Programs_Due_for_Renewal')?csr.programDueRenewal:'';
            csr.caseNumber=fieldPermissions.get('SSP_Excel_Case_Number')?csr.caseNumber:'';
            csr.applicationNumber=fieldPermissions.get('SSP_Excel_Application_Number')?csr.applicationNumber:'';
            csr.mcoEnrollmentStatus=fieldPermissions.get('SSP_Excel_MCO_Enrollment_Status')?csr.mcoEnrollmentStatus:'';
            if(fieldPermissions.get('SSP_Excel_Case_Status')==Null){
                csr.caseApplicationStatus=fieldPermissions.get('SSP_Case_Status')?csr.caseApplicationStatus:'';
            }else{
                csr.caseApplicationStatus=fieldPermissions.get('SSP_Excel_Case_Status')?csr.caseApplicationStatus:'';
            }            
            csr.submittedDate=fieldPermissions.get('SSP_Excel_Submitted_Date')?csr.submittedDate:'';
            csr.lastUpdatedDate=fieldPermissions.get('SSP_Excel_Last_Updated')?csr.lastUpdatedDate:'';
            csr.maidCardNumber=fieldPermissions.get('SSP_Excel_MAID_Number')?csr.maidCardNumber:'';             
            csrListUpdate.add(csr);
        }
        return csrListUpdate;        
    }
    
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/20/2020
* @methodname   getPicklistForSearch
* @description  This methods is used create different picklist from custom labels
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getPicklistForSearch(){
        SSP_LightningResponse response = new SSP_LightningResponse();
        
        try{
            response.put('gender',SSP_Utility.getPickListValues('Contact', 'GenderCode__c', null));
            response.put('county',SSP_Utility.getPickListValues('Contact', 'CountyCode__c', null));
            response.put('mcoStatus',getPicklistFromLabel(System.Label.SSP_ApplicationSearchStatus));
            response.put('renewalDate',getPicklistFromLabel(System.Label.SSP_DateFilter));
            response.put('caseStatus',getPicklistFromLabel(System.Label.SSP_CaseStatus));           
            response.put('submittedDate',getPicklistFromLabel(System.Label.SSP_SubmittedDate1));
            response.put('assisterPicklist',getAssisters(UserInfo.getUserId()));
            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardController', 'getRequiredDetails', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);  
        }
        return response;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/20/2020
* @methodname   getPicklistFromLabel
* @description  This methods is used get different picklist from custom labels and create slist
* @return        Map<String,String>
*****************************************************************************************************/
    public static Map<String,String> getPicklistFromLabel(String labelValue){
        list<String> listValues=labelValue.split(';');
        Map<String,String> options= new Map<String,String>();
        for(String st:listValues){
            options.put(st.split('-')[0],st.split('-')[1]);
        }
        return options;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/20/2020
* @methodname   getAssisters
* @description  This methods is used Map of list of Assiters related to user
* @return        Map<String,String>
*****************************************************************************************************/
    public static Map<String,String> getAssisters(String userId){
        
        Set<Id> setContactIdsWithinOrganization = new Set<Id>();
        Set<Id> loggedInACRAccounts = new Set<Id>();
        User loggedInUser = [SELECT Id, ContactId from user where id = :userId];
        
        for(AccountContactRelation loggedInACR: [SELECT Id,Contact.FirstName, Contact.LastName,ContactId, AccountId  FROM AccountContactRelation WHERE ContactId = :loggedInUser.ContactId AND Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION]){
            loggedInACRAccounts.add(loggedInACR.AccountId);  
        } 

        Set<String> authReps=new Set<String>{'Organization Authorized Representative','Individual Authorized Representative','Assister'};
        Map<String,String> assisterPicklist = new Map<String,String>(); 

        for(AccountContactRelation acrRecord : [SELECT Id,DCContactId__c, Contact.FirstName, Contact.LastName,ContactId,Roles FROM AccountContactRelation WHERE AccountId in :loggedInACRAccounts AND Roles in :authReps]){
            setContactIdsWithinOrganization.add(acrRecord.ContactId);
            if(acrRecord.DCContactId__c != null){
                assisterPicklist.put(String.valueOf(acrRecord.DCContactId__c),acrRecord.Contact.FirstName+' '+acrRecord.Contact.LastName);
                assisterToRoleMap.put(acrRecord.Contact.FirstName+' '+acrRecord.Contact.LastName,acrRecord.Roles);
            }
        }
        return assisterPicklist;
    }
    @AuraEnabled
    public static void getContactFromWrapper(String wrapperData){
        SSP_Utility.isAuthenticatedUser(); 
        clientSearchResult  conWrapperData=(clientSearchResult)JSON.deserialize(wrapperData, clientSearchResult.class);
        Contact con= new Contact();
        Con.FirstName=conWrapperData.firstName;
        Con.LastName=conWrapperData.lastName;
        Con.GenderCode__c=conWrapperData.gender;
        Con.IndividualId__c=String.ValueOf(conWrapperData.individualId);
        //#376149
        if(conWrapperData != null && String.isNotBlank(conWrapperData.suffix)){
            Con.SuffixCode__c = conWrapperData.suffix;
        }
        if(conWrapperData != null && String.isNotBlank(conWrapperData.middleInitial)){
            Con.MiddleName = conWrapperData.middleInitial;
        }

        impersonateCitizen(Con);        
    }
    
    public static void impersonateCitizen(Contact con){
        //Set the selected role in session cache
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        if(con != null && String.isNotBlank(con.IndividualId__c) && sessionPart != null){
            String individualId = con.IndividualId__c;
            sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID, individualId,7200);
            User loggedinUser = new User(Id = Userinfo.getUserId());
            loggedinUser.ImpersonatedIndividualId__c =  individualId;
            try{
                /** */
                Contact indv = SSP_DashboardService.getIndividualContact(individualId);
                if(indv != null){
                    //create acr
                    Contact invCon = new Contact(Id = indv.Id, IsDashboardRefreshNeeded__c = true);

                    //#376149
                    if(con != null && String.isNotBlank(con.SuffixCode__c)){
                        invCon.SuffixCode__c = con.SuffixCode__c;
                    }
                    if(con != null && String.isNotBlank(con.MiddleName)){
                        invCon.MiddleName = con.MiddleName;
                    }

                    update invCon;
                    createACR(indv);
                }
                else{
                    //create contact
                    createContact(con);
                }
                loggedinUser.ShowCitizenDashboard__c = true;
                update loggedinUser;
            }
            catch(Exception e){
                LOG_LogMessageUtility.logMessage(e, 'SSP_RoleSelection ', 'setImperosnationId', 'failed to set impersonated individual id', true);  
            }
        }
        
    }
    
    private static Contact createContact(Contact con){
        Contact indvContact;
        User loggedInUser;
        if(con != null){
            loggedInUser = (SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                           new Set<String>{'Id', 'ContactId','Profile.Name'}, 
                                                           new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}))[0];
            List<Account> accountList = new List<Account>{
                new Account(Name = con.FirstName +' '+con.LastName,
                    RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen'))};                    
                    con.IsDashboardRefreshNeeded__c = true;
            List<Contact> contactList = new List<Contact>{con};
                //creates Account and ACR to link that account and current user's contact
                Map<String, object> mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(
                    accountList, 
                    contactList,
                    loggedInUser.contactId);
            
            if(mapRestResult != null && !mapRestResult.isEmpty() && mapRestResult.containsKey('lstContacts')){                        
                contactList = ((List<Contact>)mapRestResult.get('lstContacts'));
                indvContact = contactList != null && !contactList.isEMpty() ? contactList[0] : null;
            }
        }
        return indvContact;
    }
    
    private static void createACR(Contact con){
        Boolean result= true;
        User loggedInUser = SSP_Utility.getCurrentUserDetails()[0];
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        Set<String> accountIdSet = getAccountIds(con);
        //Determine accounts that are already shared and remove the corresponding ACR's from the map
        Set<String> existingAccountSet = new Set<String>();
        for(AccountContactRelation acr : 
            SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation', 'operator'=>'AND', 'IN'=>'AccountId'}, new Set<String>{'ContactId','AccountId'}, 
                                                            new Map<String, String>{'ContactId' => loggedInUser.ContactId, 'AccountId'=> String.join(new List<String>(accountIdSet),',')})){
                                                                existingAccountSet.add(acr.AccountId);
                                                            }
        
        for(String accId : accountIdSet){
            if(existingAccountSet.isEmpty() || !existingAccountSet.contains(accId)){
                AccountContactRelation acr = new AccountContactRelation();
                acr.ContactId = loggedInUser.ContactId;
                acr.AccountId = accId;
                acrList.add(acr);
            }
        }
        
        if(!acrList.isEmpty()){
            insert acrList;
        }
    }
    
    private static Set<String> getAccountIds(Contact con){
        Set<String> accountIdSet = new Set<String>{con.AccountId};
            Set<String> applicationIdSet = new Set<String>();
        for(SSP_ApplicationIndividual__c appIndv : 
            SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                             new Set<String>{'Id','SSP_Application__r.Account__c','SSP_Application__c'}, 
                                                                             new Map<String, String>{'SSP_Member__r.Contact__c'=> con.Id})){         
                                                                                 applicationIdSet.add(appIndv.SSP_Application__c);
                                                                             }
        
        if(!applicationIdSet.isEmpty()){
            for(SSP_ApplicationIndividual__c appIndv : 
                SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND', 'IN'=>'SSP_Application__c'}, 
                                                                                 new Set<String>{'Id','SSP_Application__r.Account__c', 'SSP_Member__r.Contact__r.AccountId'}, 
                                                                                 new Map<String, String>{'limit'=>'1000','SSP_Application__c'=> String.join(new List<String>(applicationIdSet),',')})){
                                                                                     accountIdSet.add(appIndv.SSP_Application__r.Account__c);
                                                                                     accountIdSet.add(appIndv.SSP_Member__r.Contact__r.AccountId);
                                                                                     
                                                                                 }
        }
        return accountIdSet;
    }
    /***************************************************************************************************
* @author       Keshav Poduval
* @date         28/07/2020
* @methodname   exportToExcel
* @description  This method takes table data from search result and makes callout to get additional fields
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse exportToExcel(String listClientSearchResult ,String userId, string screenName){
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        List<ClientSearchResult> finalList = new  List<ClientSearchResult>();      
        ClientSearchResult ecsr ;
        List<ClientSearchResult> exportAppList = new List<ClientSearchResult>();
        Map<String, ClientSearchResult> exportCaseList = new Map<String, ClientSearchResult>();
        try{        
            string IsRoleBasedExport;
            if(screenName == 'sspMyInformationCard' ){
                IsRoleBasedExport ='Y'; 
            } else {
                IsRoleBasedExport ='N';
            }
       // List<ClientSearchResult> listResults = (List<ClientSearchResult>)JSON.deserialize(listClientSearchResult,List<ClientSearchResult>.class);
         String userRole=SSP_Utility.getSelectedRole();
         String requestString = '';
            if(string.isBlank(screenName)){
            List<ClientSearchResult> listResults = (List<ClientSearchResult>)JSON.deserialize(listClientSearchResult,List<ClientSearchResult>.class);
         if(listClientSearchResult != null){
             for(ClientSearchResult csr :listResults){             
                 if(csr.caseNumber != null && csr.caseNumber!='' ){
                     if(csr.caseNumber.contains(',')){ 
                         for(String caseNum : csr.caseNumber.split(',')){
                             requestString += csr.individualId+'-'+caseNum+';';
                         }
                     }
                     else {
                         requestString += csr.individualId+'-'+csr.caseNumber+';';
                     }
                     
                 }
                 if(csr.applicationNumber !=null){
                  exportAppList.add(csr);
                }
             }
         }	
          requestString =  requestString.removeEnd(';');   
            } else {
                exportAppList=searchApplications(userId,userRole,'');
            }
            
            if(requestString!='' || screenName == 'sspMyInformationCard'){
           
             Map<String, Object> mapParams = new Map<String, Object>();
             SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
             reqWrapper.viewName = SSP_InterfaceConstants.NON_CITIZEN_SEARCH_EXPORT;
             reqWrapper.KeyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
             reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('IsRoleBasedExport',IsRoleBasedExport));
                if(string.isBlank(screenName)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('CaseIndividuals',requestString)); // IndividualToCaseNumber format
                }
               reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('AssistedByRole',userRole));
             mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
             List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
             if(objList != null && !objList.isEmpty()) { 
             RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);            
                if(responseWrapper != null) {
                     SSP_AckResponseWRapper callOutResponse=responseWrapper.ACKRESPONSE;
                     if(responseWrapper.AckResponse ==null || responseWrapper.AckResponse.AckResponseCode ==null){
                         SSP_NonCitizenSearchExportPayloadWrapper  nonCitizenInfo = responseWrapper.nonCitizenSearchExportPayload;
                         if(responseWrapper.nonCitizenSearchExportPayload!=NULL && nonCitizenInfo.CaseInfo!= null ){
                             for(SSP_NonCitizenSearchExportPayloadWrapper.CaseInfoWrapper caseInfo:nonCitizenInfo.CaseInfo){ 
                                 String subDate=caseInfo.SubmittedDate;                                
                                 Datetime submittedDate = System.now();
                                 String lastDate=caseInfo.LastupdatedDate;                
                                 list<String> lastDateParts=lastDate.split('-');
                                 DateTime lastupdatedDate=Datetime.newInstance(Integer.valueOf(lastDateParts[0]), Integer.valueOf(lastDateParts[1]), Integer.valueOf(lastDateParts[2]));
                                 ecsr=new ClientSearchResult('',String.valueOf(caseInfo.CaseNumber),'',String.ValueOf(caseInfo.IndividualId),caseInfo.FirstName,caseInfo.LastName,caseInfo.GenderCode,caseInfo.BirthDate,getAgeOfClient(caseInfo.BirthDate),caseInfo.AddressLine1,caseInfo.AddressLine2,caseInfo.ZipCode,caseInfo.PhoneNumber,caseInfo.EmailAddress,caseInfo.SSN,'',caseInfo.AssistedbyAuthRep,caseInfo.AssistedbyAsister,caseInfo.ClientRole,caseInfo.RFIDueDate,caseInfo.NumberofRFI,caseInfo.RenewalDueDate,caseInfo.ProgramDueRenewal,caseInfo.MCOEnrollmentStatus,caseInfo.CaseStatus,submittedDate.format(SSP_GlobalConstants.DATEFORMAT),lastupdatedDate.format(SSP_GlobalConstants.DATEFORMAT),caseInfo.MaidCardNumber,false,true);                
                                 //Start - Added as part of Defect - 382855
                                 if(String.isNotBlank(caseInfo.CaseStatusSpanish) && UserInfo.getLanguage() == SSP_GlobalConstants.ES_US) {
                                    ecsr.caseApplicationStatus = caseInfo.CaseStatusSpanish;
                                 } else if(String.isNotBlank(caseInfo.CaseStatus)) {
                                    ecsr.caseApplicationStatus = caseInfo.CaseStatus;
                                 }
                                 //End -  Added as part of Defect - 382855
                                 ecsr = filterCasesBasedOnStatus(ecsr);
                                 exportCaseList.put(ecsr.individualId, ecsr);
                             }
                         }
                     }
                     else{
                         responseCode=callOutResponse.AckResponseCode;
                         responseDescription=callOutResponse.AckResponseDescription;
                         dataToSend.put('bIsSuccess', false);
                         dataToSend.put('error', responseCode);
                         return dataToSend;
                     }
                 }         
                 finalList = mergeCaseAndAppData(exportCaseList, exportAppList);
                 dataToSend.put('finalList', finalList);
                
                 dataToSend.put('bIsSuccess', true);
                
             }
                 else {
                 dataToSend.put('bIsSuccess', false);
                 LOG_LogMessage__c lstLogMessages = LOG_LogMessageUtility.logMessage (LOG_LogMessageUtility.LOG_LogLevel.Info, 'SSP_NonCitizenDashboardController', 'exportToExcel', 'empty reponse from service' , true);            
                 if (Schema.sObjectType.LOG_LogMessage__c.isAccessible()) {
                   LOG_LogMessage__c objLog = [Select ID, Name FROM LOG_LogMessage__c Where ID =:lstLogMessages.Id LIMIT 1];
                   dataToSend.put('error', objLog.Name);
                 } 
                 return dataToSend;
            }
         }
         else  if(exportAppList.size()>0){
             dataToSend.put('bIsSuccess', true);
             finalList = mergeCaseAndAppData(exportCaseList, exportAppList);
             dataToSend.put('finalList', finalList);
             
         }
           
        }
         catch(Exception ex){
             List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardController', 'exportToExcel', ex.getMessage() , true);            
             dataToSend.put('bIsSuccess', false);            
             dataToSend.put('error', lstLogMessages[0].Id);
             dataToSend.addException(ex, lstLogMessages[0].Id);
         }
        
        return dataToSend;
    
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/05/2020
* @methodname   getNonCitizenUserRoleVisibility
* @description  This method takes a user Id and gets it ifno form KOG side
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getNonCitizenUserRoleVisibility(String userRole){
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{            
            Map<String,Boolean> permissonToAccess=new Map<String,Boolean>();
            permissonToAccess.put('NotAccessible',false);
            permissonToAccess.put('Editable',true);            
            permissonToAccess.put('ReadOnly',true);
            fieldPermissionsMap.put('SSP_Excel_First_Name',false);
            fieldPermissionsMap.put('SSP_Excel_Last_Name',false);
            fieldPermissionsMap.put('SSP_Excel_Gender',false);
            fieldPermissionsMap.put('SSP_Excel_Address_Line_1',false);
            fieldPermissionsMap.put('SSP_Excel_Address_Line_2',false);
            fieldPermissionsMap.put('SSP_Excel_Zip_Code',false);
            fieldPermissionsMap.put('SSP_Excel_Phone_Number',false);
            fieldPermissionsMap.put('SSP_Excel_Email_Address',false);
            fieldPermissionsMap.put('SSP_Excel_SSN4',false);
            fieldPermissionsMap.put('SSP_Excel_SSN9',false);            
            fieldPermissionsMap.put('SSP_Excel_Assisted_By_Assister',false);
            fieldPermissionsMap.put('SSP_Excel_Assisted_By_AuthRep',false);
            fieldPermissionsMap.put('SSP_Excel_Client_Role',false);           
            fieldPermissionsMap.put('SSP_Excel_RFI_Due_Date',false);
            fieldPermissionsMap.put('SSP_Excel_Renewal_Due_Date',false);
            fieldPermissionsMap.put('SSP_Excel_Programs_Due_for_Renewal',false);
            fieldPermissionsMap.put('SSP_Excel_Case_Number',false);
            fieldPermissionsMap.put('SSP_Excel_Application_Number',false);
            fieldPermissionsMap.put('SSP_Excel_MCO_Enrollment_Status',false);
            fieldPermissionsMap.put('SSP_Case_Status',false);
            fieldPermissionsMap.put('SSP_Excel_Case_Status',false);
            fieldPermissionsMap.put('SSP_Excel_Submitted_Date',false);
            fieldPermissionsMap.put('SSP_Excel_Last_Updated',false);
            fieldPermissionsMap.put('SSP_Excel_MAID_Number',false);
            for(FieldPermissions__mdt fieldPermissions :  (List<FieldPermissions__mdt>)SSP_Utility.fetchRecords(
                new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_FIELD_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},SSP_GlobalConstants.MDT_FIELD_PERMISSIONS_FIELDS, new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1000','Role__c'=>userRole,'ScreenName__c'=>'SSSP_NonCitDash_Search'})){
                    fieldPermissionsMap.put(fieldPermissions.FieldElementName__c, permissonToAccess.get(fieldPermissions.Permission__c));
                }            
            dataToSend.put('fieldPermissionsMap', fieldPermissionsMap);             
            dataToSend.put('bIsSuccess', true);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardController', 'searchNonCitizenClients', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;
    }  
    /*****************************************************************************
* @author       Nupoor Nimbalkar
* @date         07/20/2020
* @className    resetCache
* @description  This method is used to reset the cache when non citizen user is initiating an application
**********************************************************************************/
@AuraEnabled 
    public static void resetCache(){
        try{
            if(UserInfo.getSessionId() != null){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
                
                sessionPart.remove(SSP_GlobalConstants.INDIVIDUAL_ID);
                sessionPart.remove('removedProgram');
                sessionPart.remove('AllBenefits');  
                sessionPart.remove(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits');                
                sessionPart.remove('ActiveBenefits');                                
                sessionPart.remove(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits');                                
                sessionPart.remove('PendingInterviewBenefits');
                sessionPart.remove(SSP_CacheBuilderImplementationDabhboard.class,'PendingInterviewBenefits');
                sessionPart.remove('PendingVerificationBenefits');
                sessionPart.remove(SSP_CacheBuilderImplementationDabhboard.class,'PendingVerificationBenefits');
                sessionPart.remove('caseVsHOH');
                sessionPart.remove(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH');
                sessionPart.remove('caseVsStatus');
                sessionPart.remove(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus');
                if(sessionpart.get('EnrolledMedicaidPrograms') != null){
                    sessionPart.remove('EnrolledMedicaidPrograms');
                }
                if(sessionpart.get('NonEnrolledMedicaidPrograms') != null){
                    sessionPart.remove('NonEnrolledMedicaidPrograms');
                }
                if(sessionpart.get('hasKihippProgram') != null){
                    sessionPart.remove('hasKihippProgram');
                }
                
                
                
                if(sessionpart.get('hasBenefits') != null){
                    sessionPart.remove('hasBenefits');
                }
                if(sessionpart.get('contactName') != null){
                    sessionPart.remove('contactName');
                }
                if(sessionpart.get('isCaseInChangeMode') != null){
                    sessionPart.remove('isCaseInChangeMode');
                }
                if(sessionpart.get('caseOwnership') != null){
                    sessionPart.remove('caseOwnership');
                }
                if(sessionpart.get('isTeamMember') != null){
                    sessionPart.remove('isTeamMember');
                }
                if(sessionpart.get('hasAuthRepAgents') != null){
                    sessionPart.remove('hasAuthRepAgents');
                }
                if(sessionpart.get('hasMedicaidRenewals') != null){
                    sessionPart.remove('hasMedicaidRenewals');
                }
                if(sessionpart.get('hasOtherRenewals') != null){
                    sessionPart.remove('hasOtherRenewals');
                }
                if(sessionpart.get('hasActiveCase') != null){
                    sessionPart.remove('hasActiveCase');
                }
                if(sessionpart.get('notificationsList') != null){
                    sessionPart.remove('notificationsList');
                }
            
                if(sessionpart.get('caseOptions') != null){
                    sessionPart.remove('caseOptions');
                }
                if(sessionpart.get('isExistingUser') != null){
                    sessionPart.remove('isExistingUser');
                }
                if(sessionpart.get('isHeadOfHouseHold') != null){
                    sessionPart.remove('isHeadOfHouseHold');
                }
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardController', 'resetCache', ex.getMessage() , true);            
        }
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/10/2020
* @className   NonCitizenUserInfo
* @description  This Wrapper Class is used to show NonCitizen User Information
*****************************************************************************************************/ 
    public class NonCitizenUserInfo {
        @AuraEnabled public String userId;
        @AuraEnabled public String name;
        @AuraEnabled public String userRole;
        @AuraEnabled public String organization;
        @AuraEnabled public String coverageArea;
        @AuraEnabled public Boolean accessPublicPrivate;
        @AuraEnabled public String clientCount;        
        @AuraEnabled public String email;
        @AuraEnabled public String phone; 
        @AuraEnabled public String phoneSecondry; 
        @AuraEnabled public String phoneType;
        @AuraEnabled public String mailingAddress; 
        @AuraEnabled public String preferredContact;
        @AuraEnabled public String preferredTimeOfContact;         
        @AuraEnabled public String assisterID;
        @AuraEnabled public String assisterOrgName; 
        @AuraEnabled public String orgEmail;
        @AuraEnabled public String orgPhone; 
        @AuraEnabled public String orgPhysicalAddress;
        @AuraEnabled public String orgMailAddress;
        //defect 385760
        @AuraEnabled public String organizationName;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/10/2020
* @className   ClientSearchResult
* @description  This Wrapper Class is used to show list of Application/Case for search result
*****************************************************************************************************/ 
    public class ClientSearchResult implements Comparable{
        @AuraEnabled public String recordId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String applicationNumber;
        @AuraEnabled public String individualId;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String gender;
        @AuraEnabled public String birthDate;
        @AuraEnabled public Integer age;
        @AuraEnabled public String addressLine1;
        @AuraEnabled public String addressLine2;
        @AuraEnabled public String zipcode;
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String email;
        @AuraEnabled public String ssn4;
        @AuraEnabled public String ssn9;
        @AuraEnabled public String assistedByAuthRep;
        @AuraEnabled public String assistedByAssister;
        @AuraEnabled public String clientRole;
        @AuraEnabled public String rfiDueDate;
        @AuraEnabled public String numberOfRFI;
        @AuraEnabled public String renewalDueDate;
        @AuraEnabled public String programDueRenewal;
        @AuraEnabled public String mcoEnrollmentStatus;
        @AuraEnabled public String caseApplicationStatus;
        @AuraEnabled public String submittedDate;
        @AuraEnabled public String lastUpdatedDate;
        @AuraEnabled public String maidCardNumber;
        @AuraEnabled public Boolean isApplication; 
        @AuraEnabled public Boolean isCase;     
        @AuraEnabled public String suffix; //#376149
        @AuraEnabled public String middleInitial; //#376149
        
        public ClientSearchResult(String recordId,String caseNumber,String applicationNumber,String individualId,String firstName,String lastName,String gender,String birthDate,Integer age,String addressLine1,String addressLine2,String zipcode,String phoneNumber,String email,String ssn4,String ssn9,String assistedbyAuthRep,String assistedByAssister,String clientRole,String rfiDueDate,String numberofRFI,String renewalDueDate,String programDueRenewal,String mcoEnrollmentStatus,String caseApplicationStatus,String submittedDate,String lastUpdatedDate,String maidCardNumber,Boolean isApplication,Boolean isCase){
            this.recordId=recordId;
            this.caseNumber=caseNumber;
            this.applicationNumber=applicationNumber;
            this.individualId=individualId;
            this.firstName=firstName;
            this.lastName=lastName;
            this.gender=gender;
            this.birthDate=birthDate;
            this.age=age;
            this.addressLine1=addressLine1;
            this.addressLine2=addressLine2;
            this.zipcode=zipcode;
            this.phoneNumber=phoneNumber;
            this.email=email;
            this.ssn4=ssn4;
            this.ssn9=ssn9;
            this.assistedbyAuthRep=assistedbyAuthRep;
            this.assistedByAssister=assistedByAssister;
            this.clientRole=clientRole;
            this.rfiDueDate=rfiDueDate;
            this.numberofRFI=numberofRFI;
            this.renewalDueDate=renewalDueDate;
            this.programDueRenewal=programDueRenewal;
            this.mcoEnrollmentStatus=mcoEnrollmentStatus;
            this.caseApplicationStatus=caseApplicationStatus;
            this.submittedDate=submittedDate;
            this.lastUpdatedDate=lastUpdatedDate;
            this.maidCardNumber=maidCardNumber;
            this.isApplication  =isApplication ;
            this.isCase=isCase;            
        }
        public ClientSearchResult(){            
        }        
        public  Integer compareTo(Object objToCompare) {
            ClientSearchResult csr = (ClientSearchResult) objToCompare;
            String date1=csr.submittedDate==Null?'':csr.submittedDate;
            String date2=this.submittedDate==Null?'':this.submittedDate;            
            if (date1 < date2) return +1;
            if (date1 > date2) return -1;                        
            return 0;
        }
    }

    private static String trimSearchParams(String responseString){
        String trimmedStr = responseString;
        if(String.isNotBlank(responseString)){
            ClientSearchQuery response = (ClientSearchQuery)JSON.deserialize(responseString, ClientSearchQuery.class);
            response.firstName =trimString(response.firstName);
            response.lastName =trimString(response.lastName);
            response.caseApplication =trimString(response.caseApplication);
            response.ssn =trimString(response.ssn);            
            response.gender =trimString(response.gender);
            response.addressLine1 =trimString(response.addressLine1);
            response.county =trimString(response.county);
            response.applicationStatus =trimString(response.applicationStatus);
            response.caseStatus =trimString(response.caseStatus);
            response.assistedBy =trimString(response.assistedBy);
            response.phone =trimString(response.phone);
            response.email =trimString(response.email);
            response.maidNumber =trimString(response.maidNumber);
            response.applicationSubmittedToggle =trimString(response.applicationSubmittedToggle);
            trimmedStr = JSON.serialize(response);
        }
        return trimmedStr;
    }

    private static String trimString(String value){
        return String.isNotBlank(value) ? value.trim() : value ;
    }

    /***************************************************************************************************
    * @author       Payal Dubela
    * @date         016/10/2020
    * @className    SSP_NonCitizenDashboardController
    * @description  This is used to fetch county name for country code
    //Bug 396980--Payal Dubela --Coverage Area is showing County Codes instead of County Names
    *****************************************************************************************************/

    public static String getCountyName(String coverageArea) {
        Map<String, String> values = SSP_Utility.getPickListValues('Contact', 'CountyCode__c', null);
        String sCoverageAreaName='';
        if(coverageArea != null) {
            coverageArea = coverageArea.replace(',',';');
        }
        for(String countyCode:coverageArea.split(';')){
            if(values.containsKey(countyCode)){
                sCoverageAreaName=sCoverageAreaName+values.get(countyCode)+', ';
            }
        }
        return sCoverageAreaName;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/10/2020
* @className   ClientSearchQuery
* @description  This Wrapper Class is used to Store search result prams
*****************************************************************************************************/
    public class ClientSearchQuery{
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String caseApplication;
        @AuraEnabled public String ssn;
        @AuraEnabled public String dob;
        @AuraEnabled public String gender;
        @AuraEnabled public String addressLine1;        
        @AuraEnabled public String county;
        @AuraEnabled public String applicationStatus;        
        @AuraEnabled public String caseStatus;        
        @AuraEnabled public String renewalDueDate;
        @AuraEnabled public String rfiDueDate; 
        @AuraEnabled public String submittedDate; 
        @AuraEnabled public String assistedBy;
        @AuraEnabled public String phone;
        @AuraEnabled public String email;
        @AuraEnabled public String maidNumber;
        @AuraEnabled public String applicationSubmittedToggle;
    }
    
}
