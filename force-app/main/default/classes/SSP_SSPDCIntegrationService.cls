/*
* Classname 		:  SSP_SSPDCIntegrationService
* @description 	:  This class is to make callout for SSPDC.
* @author 		:  Rijia Khatun 
* @date 		:  09/05/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
* Mahesh              12/02/2020           Mocking response
**/
public with sharing class SSP_SSPDCIntegrationService extends RestIntegrationService{
    public static String sErrorMSg = null;
    public static Set<Id> setMemberId = new Set<Id>();
    public static Set<Id> setAlienSponsorId = new Set<Id>();
    public static Set<Id> setACRId = new Set<Id>();
    public static Set<Id> setInsuranceIds = new Set<Id>();
    public static Set<Id> setContactId = new Set<Id>();
    public static final Set<String> setWithoutSharingObjects = new Set<String>{SSP_InterfaceConstants.ACCOUNTCONTACTRELATION,'Contact',
    SSP_InterfaceConstants.SSP_INSURANCEPOLICY,SSP_InterfaceConstants.SSP_ALIENSPONSOR,SSP_InterfaceConstants.SSP_TRACKDELETION,SSP_InterfaceConstants.SSP_TRANSACTION};//IronDome Report : Moved Hardcode string values to SSP Interface constants
    public static final string SSPSFDCERROR = 'LOG1000';
    public static final string SSPREADTIMEOUT = 'LOG4000';
    public static final string SSPBLANKRES = 'LOG2000';
    public static final string SSPXMLRES = 'LOG3000';
    public static final string SSPAUTHREPSCREEN = 'REPS_ADDAUTHORIZEDREPRESENTATIVE1';	
    public static final string SSPSUBMITTEDBY = 'SubmittedBy';
    public static final string SSPUSERROLE = 'UserRole';
    public static final string SSPUSERWaiverUserId = 'Waiver_UserId__c';
    public static final string SSPUSERWaiverOrgId = 'Waiver_OrgId__c';
    public static final Set<string> SSPROLESTOEXCLUDE = new Set<string>{'Organization_Auth_Rep','Individual_Auth_Rep','Insurance_Agent','Assister'};
    public static final string SSPFLOWNAME = 'ModifyExistingData';
    public static final string SSPFLOWKEYNAME = 'ChangeSummaryMode';
    public static final Map<String, Set<String>> mapMemberFields = new Map<String, Set<String>>{'SSP_Member__c'=>
    new set<String>{SSP_InterfaceConstants.PHYSICALADDRESSLINE1,SSP_InterfaceConstants.MAILINGADDRESSLINE1,SSP_InterfaceConstants.PHYSICALCITY, SSP_InterfaceConstants.MAILING_CITY_OBJ,
    SSP_InterfaceConstants.PHYSICALSTATECODE, SSP_InterfaceConstants.MAILINGSTATECODE}}; 
    public static final Map<String, String> mapRoles = new Map<String, String>{'Citizen_Individual'=>'Citizen',
    'Agency_Admin'=>'Agency Admin','CHFS_Prod_Support'=>'CHFS Prod Support','Contact_Center_View_and_Edit'=>'Contact Center (View and Edit)',
    'Contact_Center_View_Only'=>'Contact Center (View Only)','DAIL_Worker'=>'DAIL Worker',
    'DCBS_View_Only' =>'DCBS - View Only','DCBS_Central_Office_View_and_Edit'=>'DCBS Central Office - View & Edit',
    'Department_Of_Education_Representative'=>'Department of Education Representative','DJJ_Representative'=>'DJJ Representative',
    'DOC_Representative'=>'DOC Representative','Eligibility_&_Benefit_Inquiry_User'=>'Eligibility & Benefit Inquiry User',
    'Individual_Auth_Rep'=>'Individual Authorized Representative','Insurance_Agent'=>'Agent','Mail_Center_Supervisor'=>'Mail Center Supervisor',
    'Mail_Center_Worker'=>'Mail Center Worker','Organization_Auth_Rep'=>'Organization Authorized Representative',
    'Psychiatric_Facility_Representative'=>'Psychiatric Facility Representative','QE_Hospital'=>'QEHospital',
    'QE_Pregnancy'=>'QEPregnancy'};
    public static final Map<String, String> mapProgramCode = new Map<String, String>{'PermissionLevel_CCAP__c' => SSP_GlobalConstants.CHILD_CARE_CODE,
    'PermissionLevel_KTAP__c' => SSP_GlobalConstants.KTAP,
    'PermissionLevel_SNAP__c' => SSP_GlobalConstants.SNAP,
    'PermissionLevel_KIHIPP__c' => SSP_GlobalConstants.KHIPP,
    'PermissionLevel_Medicaid__c' =>SSP_GlobalConstants.MEDICAID };
 public static List<Object> invokeCallout(String developerName, Map<String, Object> mapInputParams){
        //Temporary addition - Please remove. 
        String sAllScreens ='';
        List<Object> lstReturnData = new List<Object>();
        List<String> lstRACScreens = new List<String>{SSP_InterfaceConstants.SSP_APP_REMOVECOVERAGEMODAL,SSPAUTHREPSCREEN};    
        HttpResponse response = new HttpResponse();
        HttpRequest request= new HttpRequest();
        Long timeTaken;
        Datetime startTime;

        //Mahesh              12/02/2020           Mocking response
        String applid1;

        try{
            startTime = Datetime.now();
            if(mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE)==null){
                throw new CustomException(CustomException.EXCEPTION_TYP.SYS, SSP_InterfaceConstants.SUNMIT_TYPE_IS_MISSING);
            }
            if(!mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE).equals(SSP_GlobalConstants.SNAP_FULL)) {
                 User objUser = [Select ContactID,SelectedRole__c, Waiver_OrgId__c, Waiver_UserId__c from User where id=:UserInfo.getUserId()];
                 String idApp = (String)mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID);
                 String idAccountId = (String)mapInputParams.get(SSP_InterfaceConstants.ACCOUNT_ID);
                 List<AccountContactRelation> lstACR = [Select id from AccountContactRelation where ContactId=:objUser.ContactID and AccountId=:idAccountId];
                 if(lstACR.isEmpty()) {
                     lstReturnData.add(response);
                     return lstReturnData;
                 }
                //throw error if required parameters are not present
                if(mapInputParams.get(SSP_InterfaceConstants.SCREEN_LIST) ==null || mapInputParams.get(SSP_InterfaceConstants.APPLICATION_ID)==null){
					throw new CustomException(CustomException.EXCEPTION_TYP.SYS, SSP_InterfaceConstants.INCORRECT_PARAMETERS_FOR_INTERFACE);
                }
                for(String sScreens: ((List<String>)mapInputParams.get(SSP_InterfaceConstants.SCREEN_LIST))) {
                    sAllScreens = sAllScreens+', '+sScreens;
                    lstRACScreens.add(sScreens.toUpperCase());
                }
                //Code for dependent screens
                List<String> lstDependant = new List<String>();
                List<SSP_DependentScreenMapping__mdt> lstDependentScreens  = (List<SSP_DependentScreenMapping__mdt>)new SSP_CustomMetadataAccessor().getAllRecords(SSP_InterfaceConstants.SSP_DEPENDENTSCREENMAPPING_MD);
                for (SSP_DependentScreenMapping__mdt obj : lstDependentScreens) {
                    if(lstRACScreens.contains(obj.Screen__c.toUpperCase())) {
                        for (String sData : obj.DependentScreen__c.split(',')) {
                            sAllScreens = sAllScreens+', '+sData;
                            lstDependant.add(sData.toUpperCase());
                        }
                    }
                }
                lstRACScreens.addAll(lstDependant);

                //Mahesh              12/02/2020           Mocking response
                 applid1 = (String)mapInputParams.get(SSP_InterfaceConstants.APPLICATION_ID);

                String body = createBody(lstRACScreens, (String)mapInputParams.get(SSP_InterfaceConstants.APPLICATION_ID), 
                    (String)mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE),(DateTime)mapInputParams.get(SSP_InterfaceConstants.APPLICATIONRECEIVEDDATETIME),
                    (String)mapInputParams.get(SSPFLOWKEYNAME),objUser);
                mapInputParams.put(SSP_InterfaceConstants.JSON_BODY, body);
            }else if (mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE).equals(SSP_GlobalConstants.SNAP_FULL) && mapInputParams.get(SSP_InterfaceConstants.JSON_BODY)== null){
                throw new CustomException(CustomException.EXCEPTION_TYP.SYS, SSP_InterfaceConstants.INCORRECT_PARAMETERS_FOR_INTERFACE);
            }
            request= generateRequest(developerName, mapInputParams);

            ////Mahesh              12/02/2020           Mocking response
            //response = sendRequest(request);
            response.setStatusCode(200);
            response.setBody( '{' +
                                    '	"SubmitApplicationResponse":{	'+
                                    '	"AckResponse":{			'+
                                    '	"AckResponseCode":"HBE0000",	'+
                                    '	"AckResponseDescription":"Success"	'+
                                        '	}	'+
                                        '	}	'+
                                    '	}'  );
                    SSP_Application__c appl = new SSP_Application__c();
                    appl.id = applid1;
                    appl.SSPDCMessage__c = 'P';
                    update appl;



            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            if(!mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE).equals(SSP_GlobalConstants.SNAP_FULL)) {
                ServiceResponse wrapperResponse ;
                if(String.isBlank(response.getbody())) {
                     sErrorMSg = SSPBLANKRES;
                     createLogMessage(mapInputParams,request,response,timeTaken,LOG_LogMessageUtility.LOG_LogLevel.Error,
                    developerName,sAllScreens);
                } else {
                    sErrorMSg = SSPXMLRES;
                    wrapperResponse = (ServiceResponse) JSON.deserialize(response.getbody(),ServiceResponse.class);
                    sErrorMSg = null; 
                }
            }
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG) &&
                ((mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE).equals(SSP_GlobalConstants.SNAP_FULL))||
                (!mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE).equals(SSP_GlobalConstants.SNAP_FULL) && !String.isBlank(response.getbody())))) {
                createLogMessage(mapInputParams,request,response,timeTaken,LOG_LogMessageUtility.LOG_LogLevel.Info,
                    developerName,sAllScreens);
            }
        } catch(System.CalloutException e) {
            sErrorMSg = SSPREADTIMEOUT;
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+response.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER)+'\nScreens:'+sAllScreens;
            LOG_LogMessageUtility.logMessage (
                                        e,
                                        request.getEndpoint(),
                                        developerName,
                                        SSP_InterfaceConstants.SSP_SSPDCINTEGRATIONSERVICE,
                                        'invokeCallout',
                                        stErrorMessage,
                                        request.getMethod(),
                                        request.getBody(),
                                        'Status Code: '+response.getStatusCode(),
                                        response.getBody(),
                                        timeTaken, 
                                        true);
        } catch(Exception e){
            DateTime endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            if(sErrorMSg == null || sErrorMSg != SSPXMLRES) {
                sErrorMSg = SSPSFDCERROR;
            }
            String stErrorMessage =  'Status : '+response.getStatus()+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                					 SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                					 mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER)+'\nScreens:'+sAllScreens;
            LOG_LogMessageUtility.logMessage (
                                        e,
                                        request.getEndpoint(),
                                        developerName,
                                        SSP_InterfaceConstants.SSP_SSPDCINTEGRATIONSERVICE,
                                        'invokeCallout',
                                        stErrorMessage,
                                        request.getMethod(),
                                        request.getBody(),
                                        'Status Code: '+response.getStatusCode(),
                                        response.getBody(),
                                        timeTaken, 
                                        true
                                    );
        }
        lstReturnData.add(response);
        if(sErrorMSg != null) {
            lstReturnData.add(sErrorMSg);
        }
        if(!mapInputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE).equals(SSP_GlobalConstants.SNAP_FULL) && (sErrorMSg==  null || !sErrorMSg.equals(SSPSFDCERROR))){
            createTransactionDetail( developerName, mapInputParams);
        }
        return lstReturnData;
    }
    
     /**
    * Method Name   : createRequest
    * Created Date  : 11/12/2019
    * Params        : lstEntity - List of Screen Names received from Screen Driver as Input
    sApplicationId - Salesforce Id for the object SSP_Application__c for which the SSP-DC Request body has to created
    * Description   : Creates the request body i.e. the payload for the SSP-DC Callout at the end of a Intake/RAC/Recert Flow
    * TO-DO         : Add Error Handling
    */
    public Static String createBody(List<String> lstEntity, String sApplicationId, String submitType, DateTime DApplicationReceivedDateTime, 
            String sFlowName, User objUser){
        
        String retJSON;//returnString for this method of the unserialized type Map<String,List<Object>>
        //mapObjectFieldSets to create SObject to Associated Fields map from the lstEntity provided.
        Map<String,Set<String>> mapObjectFieldSets = new Map<String,Set<String>>();
        Set<String> setOfNonNAObjects = new Set<String>();
        //Set<String> setObjects = new Set<String>();
        //Query to get Mapping for objects and fields based on the List of Screens provided via lstEntity
        List<EntityMapping__mdt> lstEntityMapping  = (List<EntityMapping__mdt>)new SSP_CustomMetadataAccessor().getAllRecords(SSP_InterfaceConstants.ENTITY_MAPPING_MDT_API);
        
        //Logic to populate mapObjectFieldSets
        //creating a set for contains operation later
        Set<String> setEntityMapping;
        if(lstEntityMapping != null)
            setEntityMapping = new Set<String>(lstEntity);
        for(EntityMapping__mdt objMet : lstEntityMapping){
            //skip if the current screen name is not requested 
            //if(!setEntityMapping.contains(objMet.screenname__c) || !objMet.Used_for_SSPDC__c ) continue;
            if(!setEntityMapping.contains(objMet.screenname__c.toUpperCase()) || (objMet.screenname__c.toUpperCase().equals(SSP_InterfaceConstants.SSP_APP_REMOVECOVERAGEMODAL) && objMet.SF_ObjectAPI__c.equals(SSP_InterfaceConstants.SSP_INSURANCEPOLICY))) continue;
            if (submitType != 'Intake' && mapMemberFields.containsKey(objMet.SF_ObjectAPI__c) && objMet.screenname__c== 'NA' &&
                mapMemberFields.get(objMet.SF_ObjectAPI__c).contains(objMet.SF_FieldAPI__c)) {
                    continue;
            }
           //populate set to avoid duplicate field vaules
            Set<String> setFieldSet = mapObjectFieldSets.get(objMet.SF_ObjectAPI__c);
            if(setFieldSet == null || setFieldSet.isEmpty()){
                setFieldSet = new Set<String>();
            }            
            setFieldSet.add(objMet.SF_FieldAPI__c);           
            mapObjectFieldSets.put(objMet.SF_ObjectAPI__c, setFieldSet); 
            if(!objMet.ScreenName__c.equals('NA')) {	
                setOfNonNAObjects.add(objMet.SF_ObjectAPI__c);	
            }
        }
        // getWhereClauseMap call to get respective WHERE Clauses for all objects for which Query has to be built 
        Map<String,String> mapSObjectWhereClause = getWhereClauseMap();
        // generateRACBody call to build the jsonBody for the SSP-DC Request
        Map<String,Object> generateRACBody = generateRACBody(mapObjectFieldSets,setOfNonNAObjects,sApplicationId,mapSObjectWhereClause,sFlowName);
        if(DApplicationReceivedDateTime == null) {
            generateRACBody.put(SSP_InterfaceConstants.APPLICATIONRECEIVEDDATETIME, system.now());
        } else {
            generateRACBody.put(SSP_InterfaceConstants.APPLICATIONRECEIVEDDATETIME, DApplicationReceivedDateTime);
        }
        generateRACBody.put(SSP_InterfaceConstants.SUBMIT_TYPE, submitType);
        generateRACBody.put(SSPSUBMITTEDBY, objUser.ContactID);
        if (mapRoles.containsKey(objUser.SelectedRole__c)) {
            generateRACBody.put(SSPUSERROLE,mapRoles.get(objUser.SelectedRole__c));
        } else {
            generateRACBody.put(SSPUSERROLE,objUser.SelectedRole__c);
        }
        generateRACBody.put(SSPUSERWaiverUserId, objUser.Waiver_UserId__c );
        generateRACBody.put(SSPUSERWaiverOrgId, objUser.Waiver_OrgId__c );
        //Serialize and return value
        retJSON = JSON.serializePretty(generateRACBody);
        //Yay, Return.
        return retJSON;
    }
    /**
    * Method Name   : getWhereClauseMap
    * Created Date  : 11/12/2019
    * Params        : setObjectAPINames - Set of Sobject API Names in the form of a String.
    * Description   : Returns a map where Key is SObject API Name and It's respective SSP-DC Record Filter Where Clause for SSP-DC request Building
    */
    public static Map<String,String> getWhereClauseMap (){
        Map<String,String> mapSObjectWhereClause = new Map<String,String>();
        for(SSPDCFilterMapping__mdt objSSPDCFilterMapping : (List<SSPDCFilterMapping__mdt>) new SSP_CustomMetadataAccessor().getAllRecordsOrderBy(SSP_InterfaceConstants.SSPDC_FILTER_MDT_API, 'order__c')){
            mapSObjectWhereClause.put(objSSPDCFilterMapping.SObjectAPIName__c,objSSPDCFilterMapping.WhereClause__c);
        }
        return mapSObjectWhereClause;
    }
    /**
    * Method Name   : generateRACBody
    * Created Date  : 11/12/2019
    * Params        : mapObjectFieldSets - map of Object (key) to the list of Field API Names
                    sApplicationId - Salesforce Id Field on the SSP_Application__c object
                    mapSObjectWhereClause - map of Object (key) to the WHERE Clause for Querying
    * Description   : Returns a map where Key is SObject API Name and It's respective SSP-DC Record Filter Where Clause for SSP-DC request Building
    * TO-DO         : Add Error Handling
    */
    public Static Map<String,Object> generateRACBody(Map<String,Set<String>> mapObjectFieldSets,Set<String> setOfNonNAObjects, String sApplicationId,Map<String,String> mapSObjectWhereClause, String sFlowName){
        //Initialize the return Structure
        Map<String,Object> retVal = new Map<String,Object>();
        Map<String,List<Object>> mapRetVal = new Map<String,List<Object>>();
        //Put SSP_TrackDeletion__c as the first object to query and add the SF id to member set
        String TrackDeletion_API = SSP_InterfaceConstants.SSP_TRACKDELETION;  
        mapRetVal = getRecordDetails(String.join(new List<String>(mapObjectFieldSets.get(TrackDeletion_API)),','),mapSObjectWhereClause.get(TrackDeletion_API),TrackDeletion_API,sApplicationId, null,null);
        if(mapRetVal != null && mapRetVal.get(TrackDeletion_API) != null){
            retVal.put(TrackDeletion_API,mapRetVal.get(TrackDeletion_API));
        }
        setMemberId.remove(null);
        //get Member details first , to be used in other queries  
        mapRetVal = getRecordDetails(String.join(new List<String>(mapObjectFieldSets.get(SSP_InterfaceConstants.MEMBER_API)),','),mapSObjectWhereClause.get(SSP_InterfaceConstants.MEMBER_API),SSP_InterfaceConstants.MEMBER_API,sApplicationId, null,null);
        if(mapRetVal != null && mapRetVal.get(SSP_InterfaceConstants.MEMBER_API) != null){
            retVal.put(SSP_InterfaceConstants.MEMBER_API,mapRetVal.get(SSP_InterfaceConstants.MEMBER_API));
        }
        String Insurance_API = SSP_InterfaceConstants.SSP_INSURANCEPOLICY;  
        if(setOfNonNAObjects.contains(Insurance_API)) {
            mapRetVal = getRecordDetails(String.join(new List<String>(mapObjectFieldSets.get(Insurance_API)),','),mapSObjectWhereClause.get(Insurance_API),Insurance_API,sApplicationId, setMemberId,null);
            if(mapRetVal != null && mapRetVal.get(Insurance_API) != null){
                retVal.put(Insurance_API,mapRetVal.get(Insurance_API));
            }   
        }
        //get ACR details first , to be used in other queries  
        String ACR_API = SSP_InterfaceConstants.ACCOUNTCONTACTRELATION;
        if(setOfNonNAObjects.contains(ACR_API)) {
            mapRetVal = getRecordDetails(String.join(new List<String>(mapObjectFieldSets.get(ACR_API)),','),mapSObjectWhereClause.get(ACR_API),ACR_API,sApplicationId, null,sFlowName);
            if(mapRetVal != null && mapRetVal.get(ACR_API) != null){
                retVal.put(ACR_API,mapRetVal.get(ACR_API));
            }
        }
        setOfNonNAObjects.add(SSP_InterfaceConstants.SSP_APPLICATIONINDIVIDUAL);
        setOfNonNAObjects.add(SSP_InterfaceConstants.SSP_APPLICATION_OBJ);
        setOfNonNAObjects.add(SSP_InterfaceConstants.SSP_TRANSACTION);
        //Query for other objects
        for(String sObjectName : mapObjectFieldSets.keySet()){
            if(!setOfNonNAObjects.contains(sObjectName) || sObjectName == SSP_InterfaceConstants.MEMBER_API || sObjectName == ACR_API 
                || sObjectName == TrackDeletion_API || sObjectName == Insurance_API
                || mapSObjectWhereClause.get(sObjectName) == null){
                continue; 
            }
            mapRetVal = getRecordDetails(String.join(new List<String>(mapObjectFieldSets.get(sObjectName)),','),mapSObjectWhereClause.get(sObjectName),sObjectName,sApplicationId, setMemberId, null);
                if(mapRetVal != null && mapRetVal.get(sObjectName) != null){
                    retVal.put(sObjectName,mapRetVal.get(sObjectName));
                }      
            }
        
        return retVal;
    }
    
    
    /**
    * Method Name   : getRecordDetails
    * Created Date  : 11/12/2019
    * Params        : sFields - Comma separated Field API Names of the Object to Query except Id Field
                    sWhereClause - WHERE Clause
                    sObjectAPIName - API Name of the Object for which Query has to be performed
    * Description   : Returns a map where Key is SObject API Name and It's respective List of SSP-DC Records for SSP-DC request Building
    * TO-DO         : Add Error Handling
                    Move Query to Selector Class 
    */
    public static Map<String,List<Object>> getRecordDetails(String sFields, String sWhereClause, String sObjectAPIName,String sApplicationId, set<Id> setMemberIds, String sFlowName){
        Map<String,List<Object>> mapRetVal = new Map<String,List<Object>>();
        //TO-DO Move Query code to the selector class. Implement Field validation before querying
        if(!String.isEmpty(sFields)) sFields = ', '+sFields;
        String sQuery = 'SELECT Id '+sFields+ ' FROM '+sObjectAPIName+' '+(sWhereClause==null?'':sWhereClause); 
        List<sObject> sobjList = new List<sObject>();
        if(setWithoutSharingObjects.contains(sObjectAPIName)) {
            sobjList = SSP_SharingBypassFetcher.getSSPDCRecords(sQuery,sApplicationId,setContactId,setMemberIds,setAlienSponsorId);
        } else{
            sobjList = Database.query(sQuery);
        }
        List<Map<String,Object>> sNewobjList = new List<Map<String,Object>>();
        /*Directly Serializing the list of queried records add an additional key-value pair named attributes.
        This needs to be removed from the body because it hold no processing significance and adds size to the payload.
        Reason for removal is optimization.*/
        for(sObject objsObject : sobjList){
            if(objsObject.getSobjectType() == Schema.SSP_Member__c.getSobjectType()){
                setMemberId.add((Id)objsObject.get(Schema.SSP_Member__c.Id));
                if(objsObject.get(Schema.SSP_Member__c.ExternalAlienSponsor__c) != null) {
                    setAlienSponsorId.add((Id)objsObject.get(Schema.SSP_Member__c.ExternalAlienSponsor__c));
                }
            }
            if(objsObject.getSobjectType() == Schema.SSP_InsurancePolicy__c.getSobjectType()){
                setInsuranceIds.add((Id)objsObject.get(Schema.SSP_InsurancePolicy__c.Id));
            }
            if(objsObject.getSobjectType() == Schema.SSP_TrackDeletion__c.getSobjectType()){
                setMemberId.add((Id)objsObject.get(Schema.SSP_TrackDeletion__c.SalesforceId__c));
            }
            if(objsObject.getSobjectType() == Schema.AccountContactRelation.getSobjectType()){
                if (sFlowName != null && sFlowName.equals(SSPFLOWNAME) && SSPROLESTOEXCLUDE.contains((String)objsObject.get(Schema.AccountContactRelation.Roles))){
                   continue; 
                }
                setACRId.add((Id)objsObject.get(Schema.AccountContactRelation.Id));
                setContactId.add((Id)objsObject.get(Schema.AccountContactRelation.ContactId));
            }
            Map<String,Object> unTypedObject = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objsObject));  
           if(unTypedObject.containsKey('RecordType')) {
                Map<String,Object> unTypedRecordType =  (Map<String,Object>)unTypedObject.get('RecordType'); 
                unTypedRecordType.remove('attributes');
                unTypedRecordType.remove('Id');           
            }
            if(unTypedObject.containsKey('RequestAccessPermission__c')) {
                String sProgramsApplied;
                String sPermissionData = (String)unTypedObject.get('RequestAccessPermission__c');
                Map<String,Object> unTypedObjectWithPermission = (Map<String,Object>)JSON.deserializeUntyped(sPermissionData); 
                for (String sPermission : unTypedObjectWithPermission.keySet()) {
                    unTypedObject.put(sPermission,unTypedObjectWithPermission.get(sPermission));
                    if(mapProgramCode.containsKey(sPermission)) {
                        if (sProgramsApplied == null) {
                            sProgramsApplied = mapProgramCode.get(sPermission);
                        } else {
                            sProgramsApplied=sProgramsApplied+ ';'+mapProgramCode.get(sPermission);
                        }
                    }
                } 
                unTypedObject.put('ProgramsApplied__c',sProgramsApplied);
                unTypedObject.remove('RequestAccessPermission__c');
            }
            unTypedObject.remove('RecordTypeId');                 
            unTypedObject.remove('attributes');
            sNewobjList.add(unTypedObject);
        }
        if(!sNewobjList.isEmpty())
            mapRetVal.put(sObjectAPIName,sNewobjList);
        return mapRetVal;
    }
    /**
	 * Method Name  : createTransactionDetail
	 * Created Date : March 31st 2020
	 * Params 		:
	 * Description  :
	 */    
    private static void createTransactionDetail(String interfaceName, Map<String, Object> inputParams) {
        SSP_Transaction__c transactionDetail = new SSP_Transaction__c (
        	InterfaceName__c 	= interfaceName,
            ApplicationId__c 	= (String) inputParams.get(SSP_InterfaceConstants.APPLICATION_ID),
            Status__c 		 	= SSP_InterfaceConstants.PENDING,
            Unique_Id__c 	 	= interfaceName+'-'+inputParams.get(SSP_InterfaceConstants.SUBMIT_TYPE)+'-'+inputParams.get(SSP_InterfaceConstants.APPLICATION_ID),
            MapOfInputParams__c = JSON.serialize(inputParams),
            No_of_Retry__c  = 0
        );
        upsert transactionDetail Unique_Id__c;
    }
    /**
	 * Method Name  : createLogMessage
	 * Created Date : May 18th 2020
	 * Params 		:
	 * Description  :
	 */    
    private static LOG_LogMessage__c createLogMessage(Map<String, Object> inputParams,HttpRequest request,HttpResponse response,
        Long timeTaken, LOG_LogMessageUtility.LOG_LogLevel logLevel, String developerName, String AllScreens) {
            String stErrorMessage =  'Status : '+response.getStatus()+'\n'+
            SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
            inputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
            SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
            inputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER)+'\nScreens:'+AllScreens;
            return LOG_LogMessageUtility.logMessage (
                    logLevel,
                    request.getEndpoint(), 
                    SSP_InterfaceConstants.SSP_SSPDCINTEGRATIONSERVICE,
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    request.getMethod(),
                    request.getBody(),
                    'Status Code: '+response.getStatusCode(),
                    response.getBody(),
                    timeTaken, 
                    true);
    }
    public class ServiceResponse {
        public SubmitApplicationResponse SubmitApplicationResponse;
    }
    public class SubmitApplicationResponse {
        public AckResponse AckResponse;
    }
    public class AckResponse {
        public String AckResponseCode;
        public String AckResponseDescription;
    }

}
