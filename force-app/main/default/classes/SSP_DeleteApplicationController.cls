public with sharing class SSP_DeleteApplicationController {
    
    public static final Map<String, Map<String,String>> paramMap= new Map<String, Map<String, String>>{
        'Member' => new Map<String, String>{
                    'FirstName__c' => 'ClientFirstName',
                    'MiddleInitial__c' => 'ClientMI',
                    'LastName__c' => 'ClientLastName',
                    'MailingAddressLine1__c' => 'ClientStreetAddressLine1',
                    'MailingAddressLine2__c' => 'ClientStreetAddressLine2',
                    'MailingCity__c' => 'ClientCity',
                    'MailingStateCode__c' => 'ClientState',
                    'PreferredSpokenLanguageCode__c' => 'LanguagePreference',
                    'MailingZipCode4__c' => 'Zipcode4',
                    'MailingZipCode5__c' => 'ZipCode5',
                    'PreferredNotificationMethodCode__c' => 'PreferredContactMethodCode',
                    'PreferredNotificationMethodCode__c' => 'PreferredNotificationMethodCode',
                    'PhysicalAddressLine1__c' => 'ClientStreetAddressLine1',
                    'PhysicalAddressLine2__c' => 'ClientStreetAddressLine2',
                    'PhysicalCity__c' => 'ClientCity',
                    'PhysicalStateCode__c' => 'ClientState',
                    'PhysicalZipCode4__c' => 'Zipcode4',
                    'PhysicalZipCode5__c' => 'ZipCode5'
                },
        'Application' => new Map<String, String>{
                    'ProgramsApplied__c' => 'ProgramCode',
                    'ApplicationReceivedDateTime__c' => 'ApplicationDate'
                },
        'Contact' => new Map<String, String>{
                    'FirstName' => 'AuthRepFirstname',
                    'MiddleName' => 'AuthRepMiddleIntial',
                    'LastName' => 'AuthRepLastName',
                    'Street__c' => 'AuthRepStreetAddressLine1',
                    'AddressLine2__c' => 'AuthRepStreetAddressLine2',
                    'City__c' => 'AuthRepCity',
                    'State__c' => 'AuthRepState',
                    'PreferredLanguageCode__c' => 'AuthRepLanguagePreference'
                }
    };

    public static final List<String> specialFieldsList = new List<String>{
        'MailingAddressLine2__c',
        'MailingCity__c',
        'MailingStateCode__c',
        'MailingAddressLine1__c',
        'MailingZipCode4__c',
        'MailingZipCode5__c',
        'PhysicalAddressLine1__c',
        'PhysicalAddressLine2__c',
        'PhysicalCity__c',
        'PhysicalStateCode__c',
        'PhysicalZipCode4__c',
        'PhysicalZipCode5__c'
    };

    @AuraEnabled
    public static ssp_LightningResponse sendNotificationAndDeleteApplication(Id applicationId){
        String groupIdentifier = System.Label.SSP_IntegrationDeleteGroupIdentifier;

        ssp_LightningResponse response = new ssp_LightningResponse();
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('SSP-001');
        SSP_Application__c application = SSP_ApplicationSelector.queryApplicationDataById(applicationId,
                                                new List<String>{'Id', 'Name', 'ProgramsApplied__c', 'ApplicationReceivedDateTime__c','Status__c', 'Account__c', '(Select id, SSP_member__r.Contact__r.IndividualId__c from SSP_ApplicationIndividuals__r where IsHeadOfHousehold__c=true)'});

        List<ssp_member__c> lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                               paramMap.get('Member').keySet(), 
                                                               new Map<String, String>{'limit'=>'1','id'=>application.SSP_ApplicationIndividuals__r[0].SSP_Member__c});

        List<AccountContactRelation> acRecords = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                   new Set<String>{'id', 'contactId'}, 
                                                                   new Map<String, String>{'accountId'=>application.account__c, 'roles'=>'Authorized Representative'});

        List<String> authRepIds = new List<String>();
        for(AccountContactRelation acr: acRecords){
            authRepIds.add(acr.contactId);
        }
        
        List<Contact> authRepContact = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND', 'IN'=>'Id'}, 
                                                                   paramMap.get('Contact').keySet(),
                                                                   new Map<String, String>{'Id'=>String.join(authRepIds, ',')});
        crw.ApplicationNumber = Integer.valueOf(application.Name);
        crw.CorrespondenceCode = groupIdentifier;
        crw.UpdatedDate = SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        crw.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
        crw.RequestTriggerStatusCode = 'NEW';
        crw.Reqtype = 'InsertCorrespondenceTrigger';
        crw.CreatedUserId = UserInfo.getUserName();
        crw.UpdatedUserId = UserInfo.getUserName();
        if(application.SSP_ApplicationIndividuals__r[0].SSP_Member__r.Contact__r.IndividualId__c != NULL){
            crw.IndividualId = Integer.valueOf(application.SSP_ApplicationIndividuals__r[0].SSP_Member__r.Contact__r.IndividualId__c);
        }
        crw.CreatedDate = SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
      //  SSP_CorrespondenceRequestWrapper.MiscellaneousParametersListWrapper ListofMtWrapper = new SSP_CorrespondenceRequestWrapper.MiscellaneousParametersListWrapper();
        List<SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper> lstofMts = new List<SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper>();
        Map<String, String> interateMap = paramMap.get('Member');
        for(String str:interateMap.keySet()){
            if(!specialFieldsList.contains(str)){
                SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper mt = new SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper();
                mt.GroupIdentifier = groupIdentifier;
                mt.ParamName = interateMap.get(str);
                mt.ParamValue = String.valueOf(lstmember[0].get(str));
                lstofMts.add(mt);
            }
        }

        lstofMts = SSP_DeleteApplicationController.evaluateSpecialFields(lstmember[0], lstofMts, groupIdentifier);
        interateMap = paramMap.get('Application');
        for(String str:interateMap.keySet()){
            SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper mt = new SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper();
            mt.GroupIdentifier = groupIdentifier;
            mt.ParamName = interateMap.get(str);
            mt.ParamValue = String.valueOf(application.get(str));
            lstofMts.add(mt);
        }

        interateMap = paramMap.get('Contact');
        for(Integer i=0;i<authRepContact.size(); i++){
            for(String str:interateMap.keySet()){
                SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper mt = new SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper();
                mt.GroupIdentifier = groupIdentifier+'_'+i;
                mt.ParamName = interateMap.get(str);
                mt.ParamValue = String.valueOf(authRepContact[i].get(str));
                lstofMts.add(mt);
            }
        }
      //  ListofMtWrapper.MiscellaneousParametersTable = lstofMts;
        crw.MiscellaneousParametersList = lstofMts;
        Map<String,object> obj = new Map<string,object>();
        List<String> lstAppFields = new List<String>{'Status__c'};
		List<object> slist = new List<object>();
        obj.put('jsonbody', JSON.serialize(crw));
        if(application.SSP_ApplicationIndividuals__r[0].SSP_Member__r.Contact__r.IndividualId__c != NULL){
            invokeFutureCallout('SSP_Correspondence',JSON.serialize(obj));
        }
                try{
                    if(application != NULL){
                        application.Status__c = SSP_GlobalConstants.STATUS_INACTIVE;
                        ESAPI.accessController().updateAsUser(application, lstAppFields);  
                    }
                    response.bIsSuccess = true;
                } catch(Exception e){
                    response.bIsSuccess = false;
                    response.put('SERVICE_ERROR', e.getMessage());
                }
        return response;
    }

    public static List<SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper> evaluateSpecialFields(ssp_member__c authRepContact, List<SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper> lstofMts, String groupIdentifier){
        Map<String, String> interateMap = paramMap.get('Member');
        List<String> specialFieldList = new List<String>();
        if(
            authRepContact.MailingAddressLine1__c != null ||
            authRepContact.MailingAddressLine2__c != null ||
            authRepContact.MailingCity__c != null ||
            authRepContact.MailingStateCode__c != null ||
            authRepContact.MailingZipCode4__c != null ||
            authRepContact.MailingZipCode5__c != null
        ){
            specialFieldList.add('MailingAddressLine1__c');
            specialFieldList.add('MailingAddressLine2__c');
            specialFieldList.add('MailingCity__c');
            specialFieldList.add('MailingStateCode__c');
            specialFieldList.add('MailingZipCode4__c');
            specialFieldList.add('MailingZipCode5__c');
        }else{
            specialFieldList.add('PhysicalAddressLine1__c');
            specialFieldList.add('PhysicalAddressLine2__c');
            specialFieldList.add('PhysicalCity__c');
            specialFieldList.add('PhysicalStateCode__c');
            specialFieldList.add('PhysicalZipCode4__c');
            specialFieldList.add('PhysicalZipCode5__c');
        }

        for(String str:specialFieldList){
            SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper mt = new SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper();
            mt.GroupIdentifier = groupIdentifier;
            mt.ParamName = interateMap.get(str);
            mt.ParamValue = String.valueOf(authRepContact.get(str));
            lstofMts.add(mt);
        }

        return lstofMts;
    }

    //Perf Fix: Making correspondance call asynchronous
    @future(callout=true)
    public static void invokeFutureCallout(String developerName, String jsonMap){
        try{
            Map<String,object> obj = (Map<String, Object>)JSON.deserializeUntyped(jsonMap);
            system.debug(obj);
            List<object> slist = new List<object>();
            slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
        }
        catch(Exception e){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_DeleteApplicationController', 'invokeFutureCallout', e.getMessage() , true);
        }
	}
}