
/*
* classname     : SSP_ProgramSelectionService
* @description  : Service class for Program Selection screen.
* @author       : Nupoor Nimbalkar
* @date         : 13/11/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Nupoor Nimbalkar      13/11/2019      Initial Version 
*/
public with sharing class SSP_ProgramSelectionService {
    
    public static Boolean isDependentOnACase = false;
    public static Set<String> availableProgramSet = new Set<String>();//Shrikant - added as a part of CD2 6.2
    /*
    * method        : invokeAccountCreationService
    * @description  : This method is use to call account creation service and returns account id as response.
    * @author       : Nupoor Nimbalkar
    * @param        : List of accounts to be inserted
    * @return       : List of accounts created
    * */    
    public static map<String,Object> invokeAccountCreationService(List<Account> lstAccounts, List<Contact> lstContacts, String sCurrentUserContactId){
        Map<String,Object> result = new Map<String,Object>();
        try{              
            /* PERF: BUG 382668: Replacing REST API Call
            DateTime myDateTime = DateTime.now();
            Integer dtTm = Integer.valueOf(myDateTime.millisecond()+60);
            Blob data = Blob.valueOf(String.valueOf(dtTm));
            Blob signature= Test.isRunningTest() ? null : System.Crypto.signWithCertificate('RSA', data, AppConfig__c.getInstance('SSPCertificate').Value__c); 
            String dataString = data.toString();
            String signatureString = signature != null ? EncodingUtil.base64Encode(signature) : null;                        
            Set<Integer> indivIds = new Set<Integer>();
            
            SSP_ProgramSelectionService.AccountJSONWrapper wrapper = new SSP_ProgramSelectionService.AccountJSONWrapper();
            wrapper.dataString = dataString;
            wrapper.signatureString = signatureString;
            wrapper.accountsJSON = JSON.serialize(lstAccounts);
            wrapper.contactsJSON = JSON.serialize(lstContacts);
            wrapper.sCurrentUserContactId = sCurrentUserContactId;
            String jsonBody = JSON.serialize(wrapper);
            Http http = new Http();
            HttpRequest request = new HttpRequest();        
            request.setEndpoint(SSPIntegrationEndpoints__c.getInstance('CreateAccountService').URL__c);
            request.setMethod('POST');        
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');        
            request.setBody(jsonBody);
            HttpResponse response = http.send(request);        
            if(response.getBody() != null){                
                String sAccountJSON = String.valueOf(response.getBody()).contains(' ;; ') ?  response.getBody().split(' ;; ')[0] : response.getBody();
                String sBackslash = '\\';  
                sAccountJSON = sAccountJSON.removeStart('"').replace(sBackslash,'');
                result.put('lstAccounts',(List<Account>)JSON.deserialize(sAccountJSON,List<Account>.class));
                String sContactJSON;
                if(lstContacts != null && !lstContacts.isEmpty()){
                    sContactJSON = response.getBody().contains(' ;; ') ?  response.getBody().split(' ;; ')[1] : null;

                }
                if(sContactJSON != null && String.isNotBlank(sContactJSON)){ 

                    sContactJSON = sContactJSON.removeEnd('"').replace(sBackslash,'');                   
                    List<Contact> returnList = (List<Contact>)JSON.deserialize(sContactJSON,List<Contact>.class);                    
                    for(Contact conMappingcontact : returnList){
                        if(String.isNotBlank(conMappingcontact.IndividualId__c)){
                            indivIds.add(Integer.valueOf(conMappingcontact.IndividualId__c));
                        }
                    }
                    if(indivIds != null && !indivIds.isEmpty()){
                        SSP_SharingBypassFetcher.insertConMappingRecords(indivIds);
                    }
                    result.put('lstContacts',(List<Contact>)JSON.deserialize(sContactJSON,List<Contact>.class));
                }

            }            
           */ result = SSP_AccountContactService.createAccountContact(lstAccounts, lstContacts, sCurrentUserContactId); 

            //Add contact Mapping record if Individual ID is present
            Set<Integer> indivIds = new Set<Integer>();
            if(result.get('lstContacts') != null){
                for(Contact conMappingcontact : (List<contact>)result.get('lstContacts')){
                    if(String.isNotBlank(conMappingcontact.IndividualId__c)){
                        indivIds.add(Integer.valueOf(conMappingcontact.IndividualId__c));
                    }
                }
            }
            if(indivIds != null && !indivIds.isEmpty()){
                SSP_SharingBypassFetcher.insertConMappingRecords(indivIds);
            }          
        }
        catch(Exception e){
            result = null;            
            LOG_LogMessageUtility.logMessage(e, 'SSP_ProgramSelectionService', 'invokeAccountCreationService', e.getMessage() , true);
        }
        
        return result;
    }
    
    /*
* method        : getProgsAppIndividual
* @description  : This method retrieves all the application individual records for a member id.
* @author       : Nupoor Nimbalkar
* @param        : String sMemberId
* @return       : List of Application Individual records
* */
    public static List<SSP_ApplicationIndividual__c> getProgsAppIndividual(String sMemberId){
        List<SSP_ApplicationIndividual__c> lstAppIndiv = new List<SSP_ApplicationIndividual__c>();
        List<String> lstApplnIndFields = new List<String>{'Id','ProgramsApplied__c','SSP_Application__c'};
            //Boolean bViewApplIndFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), lstApplnIndFields);//Perf fix - Keshav
        
        lstAppIndiv = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                        new Set<String>{'Id',  'SSP_Application__r.ProgramsApplied__c', 'SSP_Application__r.Status__c'}, 
                                                                                        new Map<String, String>{'limit'=>'1','SSP_Member__c'=> sMemberId});
    
        return lstAppIndiv;
    }
    
    
    /*
* method        : getApplicationData
* @description  : This method retrieves application object for given application id.
* @author       : Nupoor Nimbalkar
* @param        : String sApplicationId
* @return       : List of Application records
* */
    public static List<SSP_Application__c> getApplicationData(String sApplicationId){
        List<SSP_Application__c> lstApplications = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                                                new Set<String>{'Id',  'ProgramsApplied__c', 'Status__c'}, 
                                                                                                new Map<String, String>{'limit'=>'1','Id'=> sApplicationId});
        
        return lstApplications;
    }
    
    /*
    * method        : getMemberData
    * @description  : This method retrieves member object for given member id.
    * @author       : Nupoor Nimbalkar
    * @param        : String sMemberId
    * @return       : List of Member records
    * */
    public static List<SSP_Member__c> getMemberData(String sMemberId){
       List<SSP_Member__c> lstMembers = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                                           new Set<String>{'Id', 'Contact__c', 'IsHeadOfHousehold__c', 'FirstName__c', 'LastName__c'}, 
                                                                           new Map<String, String>{'limit'=>'1','Id'=> sMemberId});
        
        return lstMembers;
    }
    
    /*
    * method        : setAvailablePrograms
    * @description  : This method marks/sets available programs based on the role of user loggedIn (Shrikant - added as a part of CD2 6.2)
    * @author       : Shrikant Raut
    * @return       : void
    * */
    private static void setAvailablePrograms(){
        Set<String> availablePrograms;// = SSP_GlobalConstants.SSP_AVAILABLE_PROGRAMS;//Assignment to be replaced by new Set, when the cache role implementation for citizen is implemented        
        if((SSP_Utility.getUserDetails(UserInfo.getUserId()).get('profileName')).equals(SSP_GlobalConstants.NON_CITIZEN_PROFILE)){
            availablePrograms = SSP_Utility.getAvailableProgramsByRole();
        }
        else{
            availablePrograms = SSP_GlobalConstants.SSP_AVAILABLE_PROGRAMS;
        }
        availableProgramSet = availablePrograms;
    }
    
    /*
    * method        : getApplicablePrograms
    * @description  : This method retrieves programs applicable for selection for member.
    * @author       : Nupoor Nimbalkar
    * @param        : List<SSP_ApplicationIndividual__c> lstAppIndiv, List<SSP_Application__c> lstApplications, 
    *                 List<SSP_Member__c> lstMembers, Map<String, String> mapPrograms
    * @return       : List of applicable prorams
    * */
    public static List<SSP_ProgramSelectionCtrl.ProgramsWrapper> getApplicablePrograms(Map<String, String> detailMap, List<SSP_Application__c> lstApplications, Map<String, String> mapPrograms){   
        Map<String, SSP_ProgramSelectionCtrl.ProgramsWrapper> applicablePrograms = new Map<String, SSP_ProgramSelectionCtrl.ProgramsWrapper>();   
        List<SSP_ProgramSelectionCtrl.ProgramsWrapper> sequentialProgramList = new List<SSP_ProgramSelectionCtrl.ProgramsWrapper>();
        String sAppId = (detailMap != null && detailMap.containsKey(SSP_GlobalConstants.SSP_APPLICATION_ID)) ? detailMap.get(SSP_GlobalConstants.SSP_APPLICATION_ID) : null;
        String mode = (detailMap != null && detailMap.containsKey(SSP_GlobalConstants.SSP_MODE)) ? detailMap.get(SSP_GlobalConstants.SSP_MODE) : null;
        String source = null;
        setAvailablePrograms();//Shrikant - added as a part of CD2 6.2

        isDependentOnACase = false;
        
        Map<String, Boolean> existingAppliedPrograms = getExistingAppliedPrograms(mapPrograms, mode);
        applicablePrograms.putAll(constructProgramWrapper(mapPrograms, existingAppliedPrograms, 'Dashboard' ));  
        mapPrograms = removeSelectedValues(mapPrograms, existingAppliedPrograms != null ? existingAppliedPrograms.keySet() : null);        
        if(sAppId != null && lstApplications != null && lstApplications[0] != null && lstApplications[0].ProgramsApplied__c != null && lstApplications[0].ProgramsApplied__c != ''){
            Map<String, Boolean> selectedPrograms = new Map<String, Boolean>();
            for(SSP_Application__c app : lstApplications){
                for(String program : app.ProgramsApplied__c.split(';')){
                    selectedPrograms.put(program, false);
                }                
            }
            applicablePrograms.putAll(constructProgramWrapper(mapPrograms, selectedPrograms, null));
        }          
        
        //AVAILABLE_PROGRAMS_SEQ

        for(Integer seqNo: SSP_GlobalConstants.AVAILABLE_PROGRAMS_SEQ.keySet()){
            if(applicablePrograms.containsKey(SSP_GlobalConstants.AVAILABLE_PROGRAMS_SEQ.get(seqNo))){
                sequentialProgramList.add(applicablePrograms.get(SSP_GlobalConstants.AVAILABLE_PROGRAMS_SEQ.get(seqNo)));
            }
        }
        
        
        return sequentialProgramList;
    }
    
    /*
* method        : removeSelectedValues
* @description  : This method is used to remove selected entried from Map based on key
* @author       : Shrikant Raut    
* @return       : Map<String, String>
* */
    private static Map<String, String> removeSelectedValues(Map<String, String> mapPrograms, Set<String> selectedPrograms){
        if(selectedPrograms != null && !selectedPrograms.isEmpty()){
            for(String prgCode : selectedPrograms){
                if(mapPrograms != null && mapPrograms.containsKey(prgCode)){
                    mapPrograms.remove(prgCode);
                }
            }
        }
        return mapPrograms;
    }
    
    /*
* method        : constructProgramWrapper
* @description  : This method is used to construct Programs Wrapper
* @author       : Shrikant Raut    
* @return       : List of SSP_ProgramSelectionCtrl
* */
    public static Map<String, SSP_ProgramSelectionCtrl.ProgramsWrapper> constructProgramWrapper(Map<String, String> availablePrograms, Map<String, Boolean> selectedPrograms, String source){
        Map<String, SSP_ProgramSelectionCtrl.ProgramsWrapper> applicablePrograms = new Map<String, SSP_ProgramSelectionCtrl.ProgramsWrapper>();   
        //selectedPrograms <programcode, isDisabled>
        for(String prog : availablePrograms.keyset()){
            if(availableProgramSet.contains(prog)){//Shrikant - modified as a part of CD2 6.2
                SSP_ProgramSelectionCtrl.ProgramsWrapper wrapper = new SSP_ProgramSelectionCtrl.ProgramsWrapper();
                wrapper.programLabel = availablePrograms.get(prog);
                wrapper.programValue = prog;
                wrapper.isSelected = false;            
                wrapper.stampOnApplication = source != null && source.equalsIgnoreCase('Dashboard') ? false : true;
                
                if(selectedPrograms !=null && selectedPrograms.containsKey(prog)){
                    //if is applied on existing case or (current member is dependent on some case and program is not KP) , mark it as unselected
                    wrapper.isSelected = (source != null && source.equalsIgnoreCase('Dashboard') || (isDependentOnACase && !prog.equalsIgnoreCase('KP'))) ? false : true;
                    wrapper.isDisabled = selectedPrograms.get(prog);
                }
                
                wrapper.isDisabled = (isDependentOnACase && !prog.equalsIgnoreCase('KP')) ? true : (wrapper.isDisabled != null ? wrapper.isDisabled : false);                 
                    applicablePrograms.put(prog, wrapper); 
            }
        }
        return applicablePrograms;
    }
    
    /*
* method        : getExistingAppliedPrograms
* @description  : This method retrieves programs that were already applied in some existing Application<Case>
* @author       : Shrikant Raut    
* @return       : Set of existing applied program codes
* */
    public static Map<String, Boolean> getExistingAppliedPrograms(Map<String, String> programsAPIToLabel, String mode){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);        
        Map<String, String> programsLabelToAPI  = new Map<String, String>();        
        Map<String, Boolean> appliedPrograms = new Map<String, Boolean>();
        for(String api : programsAPIToLabel.keySet()){
            String label = '';            
            if(api == SSP_GlobalConstants.KTAP){
                label = system.label.SSP_KTAP;                
            }else if(api == SSP_GlobalConstants.MEDICAID){
                label =system.label.SSP_Medicaid;
            } 
            else if(api == SSP_GlobalConstants.CHILDCARE){
                label = system.label.SSP_ChildCareAssistance;
            } 
            else if(api == SSP_GlobalConstants.STATE){
                label = system.label.SSP_StateSupplementation;
            } 
            else if(api ==SSP_GlobalConstants.KHIPP){  
                label = system.label.SSP_KIHIPP;
            }else if (api ==SSP_GlobalConstants.SNAP){
                label = system.label.SSP_SNAP;
            }             
            programsLabelToAPI.put(label, api);
        }
        
        //Check if current indv/HOH is dependent on some other Active or Pending Case
        String caseVsHOHCalc = sessionPart.get('caseVsHOH') != null ? String.valueOf(sessionPart.get('caseVsHOH')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH'))) ?
            						String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH')) : '';
        String caseVsStatusCalc = sessionPart.get('caseVsStatus') != null ? String.valueOf(sessionPart.get('caseVsStatus')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'))) ?
            						String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus')) : '';
        if(String.isNotBlank(caseVsHOHCalc) && String.isNotBlank(caseVsStatusCalc)){  
            Map<String, String> caseToStatusMap = (Map<String, String>) JSON.deserialize(caseVsStatusCalc, Map<String, String>.class);
            Map<String, Object> caseToHOHMap = (Map<String, Boolean>) JSON.deserialize(caseVsHOHCalc, Map<String, Boolean>.class);
            
            Boolean isHOH = true;
            Integer intValue = 0;
            for(String caseNo : caseToHOHMap.keySet()){
                if(caseToStatusMap.containsKey(caseNo) &&((caseToStatusMap.get(caseNo)).equals(SSP_GlobalConstants.BENEFIT_STATUS_APPROVED) || (caseToStatusMap.get(caseNo)).equals(SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION) || (caseToStatusMap.get(caseNo)).equals(SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW))){
                    if(!Boolean.valueOf(caseToHOHMap.get(caseNo))){
                        isHOH = false; 
                        break;  
                    }
                    intValue++;      
                }
                
            }
            
            isDependentOnACase =  !isHOH;
            
        }           
        
	
        String activeBenefitsCalc = sessionPart.get('ActiveBenefits') != null ? String.valueOf(sessionPart.get('ActiveBenefits')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits'))) ?
            						String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits')) : '';
        if(String.isNotBlank(activeBenefitsCalc)){
            Map<String, List<SSP_BenefitInformationWrapper>> activeBenefits = (Map<String, List<SSP_BenefitInformationWrapper>>)System.JSON.deserialize(activeBenefitsCalc, Map<String, List<SSP_BenefitInformationWrapper>>.class);                                                                          
        	appliedPrograms.putAll(fetchExistingAppliedPrograms(activeBenefits, programsLabelToAPI));
        }
        
        
        
        String pendingVerificationCalc = sessionPart.get('PendingVerificationBenefits') != null ? String.valueOf(sessionPart.get('PendingVerificationBenefits')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingVerificationBenefits'))) ?
            						String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingVerificationBenefits')) : '';
        if(String.isNotBlank(pendingVerificationCalc)){
            Map<String, List<SSP_BenefitInformationWrapper>> pendingVerificationBenefits = (Map<String, List<SSP_BenefitInformationWrapper>>)System.JSON.deserialize(pendingVerificationCalc, Map<String, List<SSP_BenefitInformationWrapper>>.class);
            appliedPrograms.putAll(fetchExistingAppliedPrograms(pendingVerificationBenefits, programsLabelToAPI));
        }


        String pendingInterviewCalc = sessionPart.get('PendingInterviewBenefits') != null ? String.valueOf(sessionPart.get('PendingInterviewBenefits')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingInterviewBenefits'))) ?
            						String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingInterviewBenefits')) : '';
        if(String.isNotBlank(pendingInterviewCalc)){
            Map<String, List<SSP_BenefitInformationWrapper>> pendingInterviewBenefits = (Map<String, List<SSP_BenefitInformationWrapper>>)System.JSON.deserialize(pendingInterviewCalc , Map<String, List<SSP_BenefitInformationWrapper>>.class);
            appliedPrograms.putAll(fetchExistingAppliedPrograms(pendingInterviewBenefits, programsLabelToAPI));
        }
        //Added by Keshav for Defect 373017
        User loggedInUser = SSP_Utility.getCurrentUserDetails()[0]; //Iron dome fix
        if(loggedInUser.Profile.Name == SSP_GlobalConstants.RE_CITIZEN_PROFILE){
            List<SSP_Member__c> lstMembers = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                                                new Set<String>{'Id', 'Contact__c', 'FirstName__c', 'LastName__c'}, 
                                                                                new Map<String, String>{'limit'=>'1','Contact__c'=> loggedInUser.ContactId});
            if(lstMembers != null && lstMembers.size()>0){
                List<SSP_ApplicationIndividual__c> lstAppIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                                                                       new Set<String>{'Id',  'SSP_Application__r.ProgramsApplied__c', 'SSP_Application__r.Status__c','ProgramsApplied__c','IsHeadOfHousehold__c','SSP_Application__r.Recordtype.DeveloperName','SSP_Application__r.dccasenumber__c','SSP_Application__r.SSPDCMessage__c'}, 
                                                                                                                                       new Map<String, String>{'limit'=>'1','SSP_Member__c'=> lstMembers[0].Id});
                List<String> underReviewPrograms =  new List<String>();
                for(SSP_ApplicationIndividual__c objAppIndividual :lstAppIndividual){
                    if(objAppIndividual.SSP_Application__r.Status__c ==SSP_GlobalConstants.STATUS_CODE_PENDING_VERIFICATION && (objAppIndividual.SSP_Application__r.dccasenumber__c == null || (objAppIndividual.SSP_Application__r.dccasenumber__c != null && objAppIndividual.SSP_Application__r.SSPDCMessage__c == SSP_GlobalConstants.SSPDC_HBE3_Message)))
                    {
                        if(objAppIndividual.IsHeadOfHousehold__c && objAppIndividual.SSP_Application__r.ProgramsApplied__c != null){
                            underReviewPrograms=objAppIndividual.SSP_Application__r.ProgramsApplied__c.split(';');
                        }else if((!objAppIndividual.IsHeadOfHousehold__c) && objAppIndividual.ProgramsApplied__c != null){
                            underReviewPrograms=objAppIndividual.SSP_Application__r.ProgramsApplied__c.split(';');
                        }
                    }
                }
                for(String prog :underReviewPrograms){
                    appliedPrograms.put(prog,true);
                }
            }
        }
        //Code ended for 373017
        return appliedPrograms;
    }
    
    /*
* method        : fetchExistingAppliedPrograms
* @description  : This method retrieves applied programs from SSP_BenefitInformationWrapper
* @author       : Shrikant Raut    
* @return       : Set of existing applied program codes
* */
    private static Map<String, Boolean> fetchExistingAppliedPrograms(Map<String, List<SSP_BenefitInformationWrapper>> benefitsMap, Map<String, String> programsLabelToAPI){
        Map<String, Boolean> existingAppliedPrograms = new Map<String, Boolean>();
        if(benefitsMap != null){
            for(String caseNo : benefitsMap.keySet()){
                for(SSP_BenefitInformationWrapper bWrap : benefitsMap.get(caseNo)){
                    if(programsLabelToAPI.containsKey(bWrap.ProgramCode)){
                        existingAppliedPrograms.put(programsLabelToAPI.get(bWrap.ProgramCode), true);
                    }
                }
            }
        }
        return existingAppliedPrograms;
    }
    
    /*
* method        : invokeQualifiedIndividualCall
* @description  : This method is used to queue qualified individual calls for Intake and Renewal Flow
* @author       : Shrikant Raut    
* @return       : void
* */
    public static void invokeQualifiedIndividualCall(Map<String, String> pMap, String mode){        
        try{       
            String applicationMode = SSP_InterfaceConstants.MODE_INTAKE;
            Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
            QualifiedIndividualDetailWrapper detailsWrapper;
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.ALL_VIEWS;
            if(mode != null && mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RENEWAL_FLOW)){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                
                    mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
                    
                
                reqWrapper.primaryApplicationIndividualId =   mapCaseVsIndividualId.get(pMap.get(SSP_GlobalConstants.SSP_CASE_NO));
            }else{
                reqWrapper.primaryApplicationIndividualId = pMap.get(SSP_GlobalConstants.SSP_INDV_ID) ;//Integer.valueOf(pMap.get(SSP_GlobalConstants.SSP_INDV_ID)); commenting changes for making multiple individual id changes
            }
            reqWrapper.programCode = pMap.get(SSP_GlobalConstants.SSP_PROGRAMS);
            reqWrapper.applicationID = pMap.get(SSP_GlobalConstants.SSP_APP_ID);
            if(mode != null && mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RENEWAL_FLOW)){
                reqWrapper.caseNumber = Integer.valueOf(pMap.get(SSP_GlobalConstants.SSP_CASE_NO));
                applicationMode = 'Renewal';
            }
            reqWrapper.mode = applicationMode;    

            if(pMap != null && pMap.containsKey('detailsWrapper') && pMap.get('detailsWrapper') != null){
                detailsWrapper = (QualifiedIndividualDetailWrapper)JSON.deserialize(pMap.get('detailsWrapper'), QualifiedIndividualDetailWrapper.class);
            }      
            System.enqueueJob(new SSP_RSSPDC_CalloutHelper(SSP_InterfaceConstants.REVERSE_SSP_DC, reqWrapper, detailsWrapper));
            
            if(mode != null && mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RENEWAL_FLOW)){
                invokeAuthRepsAssistersCall(pMap);
            }
        }
        catch(Exception ex){
            throw ex;
        }        
    }
    
    /*
* method        : invokeAuthRepsAssistersCall
* @description  : This method is used to queue service call to link auth reps, assisters and agents to application(case) in case of Renewal flow
* @author       : Shrikant Raut    
* @return       : void
* */
    public static void invokeAuthRepsAssistersCall(Map<String, String> pMap){        
        try{         
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.AUTHREPS_ASSISTERS;
            reqWrapper.caseNumber = Integer.valueOf(pMap.get(SSP_GlobalConstants.SSP_CASE_NO));
            // reqWrapper.primaryApplicationIndividualId = Integer.valueOf(pMap.get(SSP_GlobalConstants.SSP_INDV_ID)); comment for making multiple individual id changes
            reqWrapper.primaryApplicationIndividualId = SSP_Utility.getCurrentUserAllIndividualIds();
           // reqWrapper.primaryApplicationIndividualId =mapCaseVsIndividualId.get(pMap.get(SSP_GlobalConstants.SSP_CASE_NO));
            System.enqueueJob(new SSP_RSSPDC_CalloutHelper(SSP_InterfaceConstants.REVERSE_SSP_DC, reqWrapper));            
        }
        catch(Exception ex){            
            throw ex;
        }
    }
    
    /*
* method        : updateResponse
* @description  : Method to transform Map<String, String> tp SSP_LightningResponse
* @author       : Shrikant Raut
* @param        : SSP_LightningResponse, Map<String, String> 
* @return       : Map<String, String>, <CreatedEntity, Detail JSON>
* */
    public static SSP_LightningResponse updateResponse(SSP_LightningResponse response, Map<String, String> resultMap){
        for(String key : resultMap.keySet()){
            response.put(key, resultMap.get(key));
        }
        return response;
    }
    
    /*
* method        : resetDashboardRefreshFlag
* @description  : Method to mark IsDashboardRefreshNeeded__c as true on contact
* @author       : Shrikant Raut
* @param        : contactId 
* @return       : Map<String, String>, <CreatedEntity, Detail JSON>
* */
    public static void resetDashboardRefreshFlag(String contactId){        
        Contact currentUserCon = new Contact();
        currentUserCon.Id = contactId;
        currentUserCon.IsDashboardRefreshNeeded__c = true;
        currentUserCon.Is_Eligible_For_RSSPDC__c = false;
        //ESAPI.accessController().updateAsUser(new Map<ID,Contact>{currentUserCon.Id => currentUserCon}, SSP_Utility.getFieldsNamesList (new List<Contact>{currentUserCon}));
        SSP_GenericDMLHelper.updateRecords(new List<Contact>{currentUserCon},new List<String>{'IsDashboardRefreshNeeded__c','Is_Eligible_For_RSSPDC__c'});//Perf fix - Keshav
    }
    
    
    /*
* method        : invokeManualRecCreation
* @description  : Method to create Member, App Indv for fresh case
* @author       : Shrikant Raut
* @param        : Contact, Application 
* @return       : Map<String, String>, <CreatedEntity, Detail JSON>
* */
    public static Map<String, String> invokeManualRecCreation(Contact con, SSP_Application__c application){
        Boolean createMember = true;
        Map<String, String> result = new Map<String, String>();
        SSP_Member__c memberIndv;
        List<SSP_Member__c> lstmember = new  List<SSP_Member__c>();
        
        if(con != null && con.id != null){        
           
            lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                           new Set<String>{'Id' , 'SSN__c','PseudoSSN__c'}, 
                                                           new Map<String, String>{'limit'=>'100','Contact__c'=> con.id});
            if(!lstmember.isEmpty()){     
                createMember = false;
                memberIndv = lstmember[0];
                result.put('member', JSON.serialize(lstmember));
            }
        }

        
        //create SSP_Member__c

        if(createMember){
            List<SSP_Member__c> memberList = new List<SSP_Member__c>{new SSP_Member__c(
                FirstName__c= con.FirstName,
                LastName__c=con.LastName,
                Name = con.FirstName + ' ' + con.LastName,
                Contact__c = con.Id,
                IndividualId__c  = con.IndividualId__c,
                Email__c = con.Email,
                GenderCode__c = con.GenderCode__c,
                BirthDate__c =  con.Birthdate
            )};

            if(String.isNotBlank(con.MiddleName)){
                memberList[0].MiddleInitial__c = con.MiddleName.substring(0, 1);
            }
            memberList[0].SuffixCode__c = con.SuffixCode__c;
             memberList[0].SSN__c = con.SSN__c;
            // 384646
            if(String.isNotBlank(con.SSN__c) && con.SSN__c.startsWithIgnoreCase(SSP_GlobalConstants.INVALID_SSN_START_DIGIT)){
                 memberList[0].PseudoSSN__c = con.SSN__c;
                 memberList[0].SSN__c= null;   
            }    
            //memberList = ESAPI.accessController().insertAsUser(memberList, SSP_Utility.getFieldsNamesList (memberList)).getInsertedObjects(); //Perf fix - Keshav
            memberList = SSP_GenericDMLHelper.insertRecords(memberList,new List<String>{'FirstName__c','LastName__c','Name','Contact__c','IndividualId__c','Email__c',
                                                                                        'GenderCode__c','BirthDate__c','MiddleInitial__c','SuffixCode__c','SSN__c','PseudoSSN__c'});//Perf fix - Keshav
             result.put('member', JSON.serialize(memberList));
            memberIndv = memberList[0];
        }
        else if( !lstmember.isEmpty() && lstmember.size()>0 && lstmember[0].SSN__c!= null && String.isNotBlank(lstmember[0].SSN__c) && lstmember[0].SSN__c.startsWithIgnoreCase(SSP_GlobalConstants.INVALID_SSN_START_DIGIT) ){
            lstmember[0].PseudoSSN__c = lstmember[0].SSN__c;
            lstmember[0].SSN__c= null;   
            lstmember = SSP_GenericDMLHelper.updateRecords(lstmember,new List<String>{'SSN__c','PseudoSSN__c'});
            memberIndv = lstmember[0];
               
        }
                        
        //create appIndv
        if(memberIndv != null && memberIndv.Id != null){
            List<SSP_ApplicationIndividual__c> appIndividualList = new List<SSP_ApplicationIndividual__c>{new SSP_ApplicationIndividual__c(
                SSP_Application__c = application.Id,
                SSP_Member__c = memberIndv.Id,
                IsHeadOfHousehold__c = true
            )};
            //appIndividualList = ESAPI.accessController().insertAsUser(appIndividualList, SSP_Utility.getFieldsNamesList (appIndividualList)).getInsertedObjects();//Perf fix - Keshav
            appIndividualList = SSP_GenericDMLHelper.insertRecords(appIndividualList, new List<String>{'SSP_Application__c','SSP_Member__c','IsHeadOfHousehold__c'});//Perf fix - Keshav
            result.put('appIndv',JSON.serialize(appIndividualList));
        }
        
        return result;
    }
    
    public static Map<String, String> handleNonCitizenRecCreation(String programs, String mode, User loggedInUser){
        //App Act
        //Contact Act
        //2 ACRs to link these Acts with current user
        //user Contact
        Map<String, String> resultMap = new Map<String, String>();
        List<SSP_Member__c> memberList;
        List<SSP_Application__c> appList;
        List<Account> accountList = new List<Account>{
                            new Account(Name = 'Application Account for Household',
                                        RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application')),
                            new Account(Name = SSP_GlobalConstants.DUMMY_KEY +' '+SSP_GlobalConstants.DUMMY_KEY,
                                        RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen'))};                    
        
        List<Contact> contactList = new List<Contact>{new Contact(FirstName = SSP_GlobalConstants.DUMMY_KEY,LastName = SSP_GlobalConstants.DUMMY_KEY)};
        //creates Account and ACR to link that account and current user's contact
        Map<String, object> mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(
            accountList, 
            contactList,
            loggedInUser.contactId);

        memberList = createDummyMember(mapRestResult);
        
        if(memberList != null && !memberList.isEmpty() && memberList[0].Contact__c != null){
            resultMap.put('memberList', JSON.serialize(memberList));
            appList = createApplication(mapRestResult, memberList[0].Contact__c, programs);
        }
        
        if(appList != null && !appList.isEmpty()){
            resultMap.put('applicationList', JSON.serialize(appList));
            createAppIndividual(appList[0].Id, memberList[0].Id);
        }
        
        return resultMap;
     }


    private static List<SSP_ApplicationIndividual__c> createAppIndividual(String applicationId, String memberId){
        List<SSP_ApplicationIndividual__c> appIndvList = new List<SSP_ApplicationIndividual__c>{
            new SSP_ApplicationIndividual__c(
                SSP_Application__c = applicationId,
                SSP_Member__c = memberId,
                IsHeadOfHousehold__c = true
            )
        };
                    //appIndvList = ESAPI.accessController().insertAsUser(appIndvList, SSP_Utility.getFieldsNamesList (appIndvList)).getInsertedObjects();//Perf fix - Keshav
                    appIndvList = SSP_GenericDMLHelper.insertRecords(appIndvList,new List<String>{'SSP_Application__c','SSP_Member__c','IsHeadOfHousehold__c'});//Perf fix Keshav
        return appIndvList;
    }

    private static List<SSP_Member__c> createDummyMember(Map<String, object> mapRestResult){
        List<SSP_Member__c> memberList;
         if(mapRestResult != null && !mapRestResult.isEmpty() && mapRestResult.containsKey('lstContacts')){                        
            List<Contact> contactList = ((List<Contact>)mapRestResult.get('lstContacts'));
            if(contactList != null && !contactList.isEmpty() && contactList[0].Id != null){
                memberList = new List<SSP_Member__c>{new SSP_Member__c(
                        FirstName__c = '',
                        LastName__c  = '',
                        Contact__c =  contactList[0].Id
                    )};
                    //memberList = ESAPI.accessController().insertAsUser(memberList, SSP_Utility.getFieldsNamesList (memberList)).getInsertedObjects();//Perf fix - Keshav
                    memberList = SSP_GenericDMLHelper.insertRecords(memberList,new List<String>{'FirstName__c','LastName__c','Contact__c'});//Perf fix - Keshav
            }
         }
        return memberList;
    }

    private static List<SSP_Application__c> createApplication(Map<String, object> mapRestResult, String contactId, String programs){
        List<SSP_Application__c> applicationList;
        List<AccountContactRelation> acrList;// = new List<AccountContactRelation>();
        String accountRecordType = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
        if(mapRestResult != null && !mapRestResult.isEmpty() && mapRestResult.containsKey('lstAccounts')){
            List<Account> accountList = ((List<Account>)mapRestResult.get('lstAccounts'));
            String currentRole = SSP_Utility.getSelectedRole();
            for(Account act : accountList){
                if(act != null && act.RecordTypeId.equals(accountRecordType)){
                    applicationList = 
                        new List<SSP_Application__c>{
                            new SSP_Application__c( ProgramsApplied__c = programs,          
                            ApplicationCreationInSSP__c = SSP_Utility.today(),
                                                   ApplicationReceivedDateTime__c=SSP_Utility.now(), Status__c = SSP_GlobalConstants.BATCH_SSP_APPLICATION_STATUS_INACTIVE,
                            Account__c = act.Id,
                            RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','SSP_Application')                       
                        )};
                    if(currentRole.equalsIgnoreCase(SSP_GlobalConstants.ROLE_MAIL_CENTER_WORKER) || currentRole.equalsIgnoreCase(SSP_GlobalConstants.ROLE_MAIL_CENTER_SUPERVISOR)
                        // 397543, Remove Identity Document Upload for MWMA Users
                        || SSP_GlobalConstants.waiverRoles.contains(currentRole)
                        ){
                        applicationList[0].Status__c = 'UN';
                    }
                    acrList = new List<AccountContactRelation>{
                        new AccountContactRelation(
                            AccountId = act.Id,
                            ContactId = contactId
                    )};
                }
            }

            if(acrList != null){
                //acrList = ESAPI.accessController().insertAsUser(acrList, SSP_Utility.getFieldsNamesList(acrList)).getInsertedObjects();
                acrList = SSP_GenericDMLHelper.insertRecords(acrList, new List<String>{'AccountId','ContactId'});//Added for Perf fix Keshav
            }

            if(applicationList != null){
                //applicationList = ESAPI.accessController().insertAsUser(applicationList, SSP_Utility.getFieldsNamesList (applicationList)).getInsertedObjects();
                applicationList = SSP_GenericDMLHelper.insertRecords(applicationList, new List<String>{'ProgramsApplied__c','ApplicationCreationInSSP__c','ApplicationReceivedDateTime__c','Status__c',
                                                                                        'Account__c'});//Added for Perf fix - Keshav
            }
        }
        return applicationList;
    }
    
    /*
    * method        : identifyOperationType
    * @description  : Method to identify the steps for creation of base records and relations in order to start the flow
    * @author       : Shrikant Raut
    * @param        : DetailsWrapper instance, SSP_LightningResponse instance
    * @return       : DetailsWrapper
    * */
    public static DetailsWrapper identifyOperationType(DetailsWrapper wrap, SSP_LightningResponse response){         
        User u = wrap != null ? wrap.loggedInUser : null;
        wrap.response = null;
        //When Non Citizen user role is Impersonating with a individual Id - (Profile = NonCitizen && SelectedRole != citizen && ImpersonatedIndividualId != null)
        if(u != null && u.Profile.Name.equalsIgnoreCase(SSP_GlobalConstants.NON_CITIZEN_PROFILE) && u.ImpersonatedIndividualId__c != null && !String.isBlank(u.ImpersonatedIndividualId__c) && 
            (u.SelectedRole__c != null && !String.isBlank(u.SelectedRole__c) && !u.SelectedRole__c.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE))){
                wrap.operationType = (wrap.doesCaseExists) ? SSP_GlobalConstants.QUALIFIED_INDV_CALL : SSP_GlobalConstants.IMPERSONATED_W_INDVID_RECORD_CREATION;
        }

        //Continue as a citizen user or non citien user as a citizen role - (profile = citizen) || (selectedRole = citizen)
        else if(u != null && 
               (u.Profile.Name.equalsIgnoreCase(SSP_GlobalConstants.RE_CITIZEN_PROFILE) || 
               (wrap != null && u.SelectedRole__c == null || (u.SelectedRole__c != null && String.isBlank(u.SelectedRole__c)) || (u.SelectedRole__c != null && !String.isBlank(u.SelectedRole__c) && u.SelectedRole__c.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE))))){ 
                    //Check if blank/null selected role is to be considered as a citizen login
                    wrap.individualContact = (wrap.individualContact != null && wrap.individualContact.Id.equals(u.ContactId)) ? 
                                              wrap.individualContact : queryContactDetails(new Map<String, String>{'Id'=> u.ContactId})[0]; 
                    wrap.doesCaseExists = wrap.individualContact.DoesCaseExistForIndividual__c; 
                    wrap.operationType = (wrap.doesCaseExists) ? SSP_GlobalConstants.QUALIFIED_INDV_CALL : SSP_GlobalConstants.CITIZEN_RECORD_CREATION ;
                    
                    
        }
        
        //For impersonation without individualId - only in case of non citizen users - (profile = nonCitizen && selectedRole != null && selectedRole != citizen)
        else if(u != null && u.Profile.Name.equalsIgnoreCase(SSP_GlobalConstants.NON_CITIZEN_PROFILE) && u.SelectedRole__c != null && 
                !String.isBlank(u.SelectedRole__c) && !u.SelectedRole__c.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE)){
            wrap.operationType = SSP_GlobalConstants.IMPERSONATED_WO_INDVID_RECORD_CREATION;
        }

        //Mark error and return
        else{
            response.put('ERROR', 'Cannot proceed with, Role : '+u.SelectedRole__c+' & Profile : '+u.Profile.Name+' Combination');
            wrap.response = response;
        }


        //(loggedInUser, programs, caseNo, mode, doesCaseExists, individualContact) (operationType)
        return wrap;
    }
    
    /*
    * method        : triggerProgramSelectionOps
    * @description  : Method to trigger specific record creation operation on program selection, based on what user is logged in and how is the screen accessed
    * @author       : Shrikant Raut
    * @param        : DetailsWrapper instance, SSP_LightningResponse instance
    * @return       : SSP_LightningResponse
    * */
    public static SSP_LightningResponse triggerProgramSelectionOps(DetailsWrapper wrap, SSP_LightningResponse response){
        //(loggedInUser, programs, caseNo, mode, doesCaseExists, individualContact) (operationType)
        SSP_Application__c application;
        Map<String, String> resultMap;
        //Add condition where application creation is needed
        if(wrap.operationType != null && !wrap.operationType.equalsIgnoreCase(SSP_GlobalConstants.IMPERSONATED_WO_INDVID_RECORD_CREATION) &&
        !(wrap.operationType.equalsIgnoreCase(SSP_GlobalConstants.IMPERSONATED_W_INDVID_RECORD_CREATION) && wrap.individualContact == null)){
            application = createApplication(wrap);
            if(application == null){
                response.put('ERROR','Error in creating Application');
                return response;
            }
            else{
                response.put('applicationList', JSON.serialize(new List<SSP_Application__c>{application}));      
            }
        }        

         if(wrap.operationType != null && wrap.operationType.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_RECORD_CREATION)){
            response = SSP_ProgramSelectionService.updateResponse(response, SSP_ProgramSelectionService.invokeManualRecCreation(wrap.individualContact, application));                        
            response.put('SUCCESS',SSP_GlobalConstants.CITIZEN_RECORD_CREATION +'  '+JSON.serialize(wrap));
            response.bIsSuccess = true;
         }
         else if(wrap.operationType != null && wrap.operationType.equalsIgnoreCase(SSP_GlobalConstants.IMPERSONATED_W_INDVID_RECORD_CREATION)){
            //if there exist a contact with impersonated individual id 
            if(wrap.individualContact != null){
                response = SSP_ProgramSelectionService.updateResponse(response, SSP_ProgramSelectionService.invokeManualRecCreation(wrap.individualContact, application));                        
             }
             //if there doesnt exist a contact with impersonated individual id -
             else{
                resultMap = SSP_ProgramSelectionService.handleNonCitizenRecCreation(wrap.programs, wrap.mode, wrap.loggedInUser);
             }
             response.bIsSuccess = true;
             response.put('SUCCESS',SSP_GlobalConstants.IMPERSONATED_W_INDVID_RECORD_CREATION +'  '+JSON.serialize(wrap));
         }
         else if(wrap.operationType != null && wrap.operationType.equalsIgnoreCase(SSP_GlobalConstants.QUALIFIED_INDV_CALL)){
            SSP_ProgramSelectionService.invokeQualifiedIndividualCall(new Map<String, String>{
                SSP_GlobalConstants.SSP_PROGRAMS => application.ProgramsApplied__c,
                SSP_GlobalConstants.SSP_INDV_ID => wrap.individualContact.IndividualId__c, 
                SSP_GlobalConstants.SSP_APP_ID => application.Id,
                SSP_GlobalConstants.SSP_CASE_NO => wrap.caseNo
            }, wrap.mode);
            response.bIsSuccess = true;
            response.put('SUCCESS','Qualified Individual Service Call Triggered');
         }
         else if(wrap.operationType != null && wrap.operationType.equalsIgnoreCase(SSP_GlobalConstants.IMPERSONATED_WO_INDVID_RECORD_CREATION)){
            resultMap = SSP_ProgramSelectionService.handleNonCitizenRecCreation(wrap.programs, wrap.mode, wrap.loggedInUser);
            response.bIsSuccess = true;
            response.put('SUCCESS',SSP_GlobalConstants.IMPERSONATED_WO_INDVID_RECORD_CREATION +'  '+JSON.serialize(wrap));
         }

        //Reset DashboardRefreshFlag
        if(wrap.individualContact != null){
            SSP_ProgramSelectionService.resetDashboardRefreshFlag(wrap.individualContact.Id); 
        }

         if(resultMap != null && !resultMap.isEmpty()){
            for(String key : resultMap.keySet()){
                response.put(key, resultMap.get(key));
            }
         }
        return response;
    }

    /*
    * method        : createApplication
    * @description  : Method to create an application record, while starting the flow
    * @author       : Shrikant Raut
    * @param        : DetailsWrapper instance
    * @return       : SSP_Application__c
    * */
    private static SSP_Application__c createApplication(DetailsWrapper wrap){
        Account account = new Account();  
        SSP_Application__c existingCase = checkForExistingCase(wrap.caseNo, wrap.mode, wrap.loggedInUser.ContactId); //#376247
        String existingAccountId; //#376247
        List<SSP_Application__c> applicationList = 
            new List<SSP_Application__c>{
                new SSP_Application__c( 
                    ProgramsApplied__c = wrap.programs,  
                    ApplicationCreationInSSP__c = SSP_Utility.today(),
                    ApplicationReceivedDateTime__c=SSP_Utility.now(), Status__c = 'UN'
                )};
                    
                    
        //In case of renewal mode, copy case no to Application and Account        
        if(wrap.mode != null && wrap.mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RENEWAL_FLOW) && wrap.caseNo != null){
            applicationList[0].SectionStatus__c = '{"Renewal":{"SSP_APP_ProgramSelection":"COMPLETED"}}';
            applicationList[0].ChangeSummaryMode__c = null;
            applicationList[0].RAC_Selections__c = null;
            applicationList[0].DCCaseNumber__c = Integer.valueOf(wrap.caseNo);
            account.CaseNumber__c = wrap.caseNo;      
            existingAccountId = SSP_SharingBypassFetcher.fetchExistingAccount(wrap.caseNo, wrap.loggedInUser.ContactId); //#376247                                
        }                
        
        //If case no is null or (case no is not null and there doesn't exists any application with the same case no)
        if(existingCase == null){                            
            if(!String.isNotBlank(existingAccountId)){ //#376247
                account.Name = 'Application Account for ' + wrap.individualContact.FirstName + ' ' + wrap.individualContact.LastName + ' ' + 'Household';
                account.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
                
                //creates Account and ACR to link that account and current user's contact
                Map<String,object> mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(new List<Account>{account}, null, wrap.loggedInUser.ContactId);
                account = ((List<Account>)mapRestResult.get('lstAccounts'))[0];
                existingAccountId = account.Id; //#376247
            } //#376247
            applicationList[0].Account__c =  existingAccountId; //#376247
            applicationList[0].RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c', (wrap.mode != null && wrap.mode.equalsIgnoreCase('renewal')) ? 'Case' : 'SSP_Application');
            //Updated for Perf fix - Keshav
            if(SSP_Application__c.sObjectType.getDescribe().isCreateable()){
                insert applicationList;
            }
            //applicationList = ESAPI.accessController().insertAsUser(applicationList, SSP_Utility.getFieldsNamesList (applicationList)).getInsertedObjects();                                          
        }   
        
        //If case no is not null and there exists an application with same case no
        else{
            applicationList[0].Id = existingCase.Id;                      
            //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Application__c>(applicationList), SSP_Utility.getFieldsNamesList (applicationList));   //Perf fix - Keshav 
            SSP_GenericDMLHelper.updateRecords(applicationList,new List<String>{'ProgramsApplied__c','ApplicationCreationInSSP__c','ApplicationReceivedDateTime__c','SectionStatus__c','ChangeSummaryMode__c',
                                                                                'DCCaseNumber__c','Account__c'});
            SSP_SharingBypassFetcher.deleteRecords( existingCase.Id);
        }    
        return (applicationList != null && !applicationList.isEmpty()) ? applicationList.get(0) : null;  
    }

    /*
    * method        : checkForExistingCase
    * @description  : Method to return existing application with given case if exists, in case of renewal flow.
    * @author       : Shrikant Raut
    * @param        : Case No, Mode
    * @return       : SSP_Application__c
    * */
    private static SSP_Application__c checkForExistingCase(String caseNo, String mode, String contactId){ //#376247
        List<SSP_Application__c> existingCaseList = new List<SSP_Application__c>();
        if(caseNo != null && mode != null && mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_RENEWAL_FLOW)){
            existingCaseList = SSP_SharingBypassFetcher.fetchExistingCase(caseNo, contactId); //#376247            
        }
        return (existingCaseList != null && !existingCaseList.isEmpty()) ? existingCaseList.get(0) : null; 
    }
    
    /*
    * method        : constructProgramsString
    * @description  : Method to modify selected programs format to the expected multipicklist format
    * @author       : Shrikant Raut
    * @param        : String - csv programs
    * @return       : String
    * */
    public static String constructProgramsString(String selectedPrograms){
        String programs = '';
        if(selectedPrograms != null){
            if(selectedPrograms != null && selectedPrograms != ''){
                for(String prog : selectedPrograms.split(',')){                    
                    if(programs != ''){
                        programs = programs + ';' + prog;
                    }
                    else{
                        programs = prog;
                    }   
                }
            }
        }
        return programs;
    }

    /*
    * method        : queryContactDetails
    * @description  : Method to query for contact records
    * @author       : Shrikant Raut
    * @param        : Map<String, String> -- Condition map
    * @return       : Contact List
    * */
    public static List<Contact> queryContactDetails(Map<String, String> conditionMap){    
        conditionMap.put('limit','1');
        return SSP_ContactSelector.queryContactData(
                                new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                new Set<String>{'Id', 'FirstName', 'MiddleName', 'LastName', 'SuffixCode__c', 'IndividualId__c', 'Birthdate', 'SSN__c', 'DoesCaseExistForIndividual__c','Email','GenderCode__c'}, 
                                conditionMap);
    }
    
    /*
    * method        : DetailsWrapper
    * @description  : Wrapper structure passing values accross methods while updating programs
    * @author       : Shrikant Raut
    * @param        : 
    * @return       : 
    * */
    public class DetailsWrapper {
        public User loggedInUser;
        public String mode;
        public String caseNo;
        public String programs;
        public String operationType;
        public SSP_LightningResponse response;
        //Following details could could belong to the impersonated indvidual or logged in user based on selected role and assigned profile
        public String individualId;
        public Contact individualContact;
        public Boolean doesCaseExists = false;
    }
    
    public class AccountJSONWrapper{
        public String dataString;
        public String signatureString;
        public String accountsJSON;
        public String contactsJSON;
        public String sCurrentUserContactId;        
    }

    //Added by Shrikant CD-2
    public class QualifiedIndividualDetailWrapper{
        public SSP_ApplicationIndividual__c applicationIndividual;
        public SSP_Member__c member;
        public SSP_Member__c responseMemberData;
        public Boolean isCitizenUser;
        public Boolean triggerQualifiedCall = false;
        public SSP_Application__c applicationData;//#384698
    }
}