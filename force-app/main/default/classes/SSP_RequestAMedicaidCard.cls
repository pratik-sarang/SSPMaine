public with sharing class SSP_RequestAMedicaidCard {
    
    /***************************************************************************************************
* @author       Prasanth Prasanth
* @date         07/10/2020
* @methodname   getMailingAddress
* @description  This methods is used to call the Myinformation callout
* @return       SSP_LightningResponse
*****************************************************************************************************/  
    @AuraEnabled
    public static SSP_LightningResponse getMailingAddress(String individualId, String caseNumber){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            String lstRACCases= sessionpart.get('hasActiveCase') != null ? String.valueOf(sessionpart.get('hasActiveCase')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard .class,'hasActiveCase')); 
            if(String.isNotBlank(lstRACCases) && lstRACCases.contains(caseNumber))
            {
                objResponse.put('isRacCase',true);
            }
            else {
                objResponse.put('isRacCase',false);
            }
            if(individualId!=null){
                Map<String, Object> mapParams = new Map<String, Object>();
                SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName = SSP_InterfaceConstants.MY_INFORMATION;
                reqWrapper.primaryApplicationIndividualId =individualId;
                reqWrapper.caseNumber=Integer.valueOf(caseNumber); //'650062510';
                mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
                objResponse.put('response', JSON.serialize(responseWrapper));
                objResponse.bIsSuccess=true;
            }
            else {
                objResponse.bIsSuccess=false;
            }
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'getMailingAddress', ex.getMessage() , true); 
                             objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                            }
        return objResponse;
    }
    
    /***************************************************************************************************
* @author       Prasanth Prasanth
* @date         07/10/2020
* @methodname   medicaidCardRequestCallOut
* @description  This methods is used to call the Medicaid Callout
* @return       SSP_LightningResponse
*****************************************************************************************************/  
    @AuraEnabled
    public static SSP_LightningResponse medicaidCardRequestCallOut(Map<String,String> reqParameters){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        try{
            if(reqParameters!=null)
            {
                String dcbsId='';
                if(reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_DCBS_OFFICEID) && String.isBlank(reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_DCBS_OFFICEID))){
                    if(reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_OFFICE_RECORDID) && !String.isBlank(reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_OFFICE_RECORDID)))
                    {
                        dcbsId=getDCBSId(reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_OFFICE_RECORDID));
                    }
                    
                }
                else if(reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_DCBS_OFFICEID)) {
                    dcbsId=reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_DCBS_OFFICEID);
                }
                SSP_DatacontractOrg.MaidCardRequestModel objRequest = new SSP_DatacontractOrg.MaidCardRequestModel();
                Map<String, Object> mapParams = new Map<String, Object>();
                objRequest.CaseNumber =reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_CASENUMBER)? Integer.valueOf(reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_CASENUMBER)) :0;
                objRequest.Comment = reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_COMMENT)?reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_COMMENT) : null; 
                objRequest.IndividualId =reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_INDIVIDUALID)? Integer.valueOf(reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_INDIVIDUALID)):0;
                objRequest.IsRequestedInOffice = reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_ISDCBS)? reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_ISDCBS)=='true'? SSP_GlobalConstants.REQUEST_CARD_ISDCBS_YES:SSP_GlobalConstants.REQUEST_CARD_ISDCBS_NO:SSP_GlobalConstants.REQUEST_CARD_ISDCBS_NO;
                objRequest.SelectedCardReason = reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_REASON);
                objRequest.DcbsOffice=dcbsId;
                mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
                
                List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.MEDICAID_CARD_REQUEST, mapParams);              
                SSP_DatacontractOrg.AdhocSFServiceResponse Response_Wrapper= (SSP_DatacontractOrg.AdhocSFServiceResponse) serviceResponses[0];  
                String jsonstring=JSON.serialize(Response_Wrapper);
                
                objResponse.put('response',jsonstring );
                
                //"Status\":true 
                if(jsonstring.contains('"Status":true'))
                {
                    objResponse.bIsSuccess=true;
                    SSP_RequestAMedicaidCard.updateDashboardRefresh();
                }   
                else {
                    
                    objResponse.bIsSuccess=false;
                    
                }
            }
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'medicaidCardRequestCallOut', ex.getMessage() , true); 
                             objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                            }
        
        return objResponse;
        
    }
    /***************************************************************************************************
* @author       Prasanth Prasanth
* @date         07/10/2020
* @methodname   ebtCardRequestCallOut
* @description  This methods is used to call the EBT Callout
* @return       SSP_LightningResponse
*****************************************************************************************************/ 
    
    @AuraEnabled
    public static SSP_LightningResponse ebtCardRequestCallOut(Map<String,String> reqParameters){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        try{
            if(reqParameters!=null)
            {
                SSP_DatacontractOrg.CardDetailsModel objRequest = new SSP_DatacontractOrg.CardDetailsModel();
                Map<String, Object> mapParams = new Map<String, Object>();
                List<User> userlist=SSP_UserSelector.queryUserData(
                    new Map<String, String>{'objectName'=>'User'},
                    new Set<String>{'Id','Username'},
                    new Map<String, String>{'Id'=> UserInfo.getUserId()}
                );
                
                
                objRequest.CardStatus = SSP_GlobalConstants.REQUEST_CARD_EBT_CARD_STATUS_VALUE;
                objRequest.CardStatusDate =SSP_Utility.now();
                objRequest.Comment = reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_COMMENT)?reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_COMMENT) : null;
                objRequest.CountyCode = reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_COUNTY_CODE)?reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_COUNTY_CODE):null;
                objRequest.EBTCaseNumber =reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_CASENUMBER)? long.valueOf(reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_CASENUMBER)) :0; 
                objRequest.IndividualId = reqParameters.containsKey(SSP_GlobalConstants.REQUEST_CARD_INDIVIDUALID)? Integer.valueOf(reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_INDIVIDUALID)):0;
                objRequest.IsRequestedInOffice = SSP_GlobalConstants.REQUEST_CARD_ISDCBS_NO;
                objRequest.mode = SSP_GlobalConstants.REQUEST_CARD_EBT_MODE_VALUE;
                objRequest.SelectedCardReason = reqParameters.get(SSP_GlobalConstants.REQUEST_CARD_REASON);
                
                
                if(userlist.size()>0 && userlist[0].Username!=null)
                {
                    objRequest.WorkerIdRequest = userlist[0].Username;
                }
                mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
                
                List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.EBT_CARD_REQUEST, mapParams);              
                
                SSP_DatacontractOrg.AdhocSFServiceResponse Response_Wrapper= (SSP_DatacontractOrg.AdhocSFServiceResponse) serviceResponses[0];  
                String jsonstring=JSON.serialize(Response_Wrapper);
                objResponse.put('response',jsonstring );
                
                if(jsonstring.contains('"Status":true'))
                {
                    objResponse.bIsSuccess=true;
                    SSP_RequestAMedicaidCard.updateDashboardRefresh();
                }
                else {
                    objResponse.bIsSuccess=false;
                }
            }
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'ebtCardRequestCallOut', ex.getMessage() , true); 
                             objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                            }
        
        return objResponse;
        
    }
    /***************************************************************************************************
* @author       Prasanth Prasanth
* @date         07/10/2020
* @methodname   getReasonPickListValues
* @description  This methods is used to call the values for reason picklist
* @return       Map of Strings
*****************************************************************************************************/ 
    
    @AuraEnabled
    public static Map<String,String> getReasonPickListValues(){
        SSP_Utility.isAuthenticatedUser();
        List<String> options = System.Label.sspMedicaidEBTCard_ReasonPickList.Split(',');
        Map<String,String> mapofOptions = new Map<String,String>();
        for(String str : options)
        {
            mapofOptions.put(str.substring(0,1),str);
        }
        return mapofOptions;
    }
    
    /***************************************************************************************************
* @author       Prasanth Prasanth
* @date         07/10/2020
* @methodname   medicaidEBTData
* @description  This methods is used to call the data for MEdicaid and EBT 
* @return       SSP_LightningResponse
*****************************************************************************************************/ 
    @AuraEnabled
    public static SSP_LightningResponse medicaidEBTData(){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        Boolean showMedicaidLink=false;
        Boolean showEBTLink=false;
        Map<String,Object> secutityMatrixPermissionMedicaid = new Map<String,Object>();
         Map<String,Object> secutityMatrixPermissionEBT = new Map<String,Object>();

        secutityMatrixPermissionMedicaid.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY,SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.REQUEST_MEDICAID_CARD_SCREENID, null));
        secutityMatrixPermissionEBT.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY,SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.REQUEST_EBT_CARD_SCREENID, null));
        objResponse.put('mediCaidSecurityMatrix',secutityMatrixPermissionMedicaid);
        objResponse.put('ebtSecurityMatrix',secutityMatrixPermissionEBT);
        List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper> medicaidEBTDataList= new List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper>();
        List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper> medicaidData= new List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper>();
        List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper> ebtData= new List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper>();
        try{
            
            List<User> user=SSP_UserSelector.queryUserData(
                new Map<String, String>{'objectName'=>'User'},
                new Set<String>{'Id','ContactId'},
                new Map<String, String>{'Id'=> UserInfo.getUserId()}
            );
            List<Contact> listcon= new List<Contact>() ; 

            String individualId=SSP_Utility.getIndividualId();
            
            if(individualId!=null)
            {
                
                listcon = SSP_ContactSelector.queryContactData (
                    new Map<String, String>{'objectName'=>'Contact'},
                    new Set<String>{'Id','CacheBenefitMedicaidEBTData__c'},
                    new Map<String, String>{'IndividualId__c'=> individualId}
                );
                
            }
            if(listcon!=null && listcon.size()>0 && listcon[0].CacheBenefitMedicaidEBTData__c!=null)
            {
                Boolean ebtLinkVisibilty=false;
                Boolean medicaidLinkVisibilty=false;
                Map<String,Object> ebtLinkVisibiltyMap=getEBTLinkVisibility(user[0].id).mapResponse;
                Map<String,Object> medicaidLinkVisibiltyMap=getMedicaidLinkVisibility(user[0].id).mapResponse;
                if(ebtLinkVisibiltyMap!=null && ebtLinkVisibiltyMap.containsKey('linkRoleVisibility'))
                {
                  ebtLinkVisibilty= Boolean.valueOf(getEBTLinkVisibility(user[0].id).mapResponse.get('linkRoleVisibility'));
                }
                 if(medicaidLinkVisibiltyMap!=null && medicaidLinkVisibiltyMap.containsKey('linkRoleVisibility'))
                {
                  medicaidLinkVisibilty= Boolean.valueOf(getMedicaidLinkVisibility(user[0].id).mapResponse.get('linkRoleVisibility'));
                }

                
                Map<String,Object> mapResponse=SSP_DashboardController.getMemberTypeFlag().mapResponse;
                String getMemberTypeFlag ='';
                if(mapResponse!=null && mapResponse.get('memberType')!=null)
                {
                    getMemberTypeFlag=String.valueOf(mapResponse.get('memberType'));
                }
                
                medicaidEBTDataList=(List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper>)JSON.deserialize(listcon[0].CacheBenefitMedicaidEBTData__c, List<SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper>.class);
                objResponse.put('response',listcon[0].CacheBenefitMedicaidEBTData__c);
                objResponse.put(SSP_GlobalConstants.REQUEST_CARD_HOH_VALUE,getMemberTypeFlag);
                if(medicaidEBTDataList!=null && medicaidEBTDataList.size()>0)
                {
                    for(SSP_BenefitInformationPayloadWrapper.MedicardEBTWrapper ebtmedicaid : medicaidEBTDataList)
                    {
                        if(getMemberTypeFlag.equalsIgnoreCase(SSP_GlobalConstants.REQUEST_CARD_HOH_CHECK))
                        {
                            if(ebtmedicaid.ShowMedicard) 
                            {
                                medicaidData.add(ebtmedicaid);
                                 if(medicaidLinkVisibilty)
                                    {
                                showMedicaidLink=true;
                                    }
                            }
                            if(ebtmedicaid.ShowEBT)
                            {
                                ebtData.add(ebtmedicaid);
                                if(ebtLinkVisibilty)
                                {
                                showEBTLink=true;
                                }
                            }
                        }
                        else{
                            if(ebtmedicaid.IndividualId.equalsIgnoreCase(individualId))
                            {
                                if(ebtmedicaid.ShowMedicard) 
                                {
                                    medicaidData.add(ebtmedicaid);
                                    if(medicaidLinkVisibilty)
                                    {
                                    showMedicaidLink=true;
                                    }
                                }
                                if(ebtmedicaid.ShowEBT)
                                {
                                    ebtData.add(ebtmedicaid);
                                     if(ebtLinkVisibilty)
                                {
                                    showEBTLink=true;
                                    }
                                }
                            }
                        }
                    }
                    objResponse.put(SSP_GlobalConstants.REQUEST_CARD_MEDICAID_DATA,JSON.serialize(medicaidData));
                    objResponse.put(SSP_GlobalConstants.REQUEST_CARD_EBT_DATA,JSON.serialize(ebtData));
                    objResponse.put(SSP_GlobalConstants.REQUEST_CARD_SHOW_MEDICAID_LINK,showMedicaidLink);
                    objResponse.put(SSP_GlobalConstants.REQUEST_CARD_SHOW_EBT_LINK,showEBTLink);
                    objResponse.bIsSuccess=true;
                }
                
                
                
            }
            
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'medicaidEBTData', ex.getMessage() , true); 
                             objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                            }
        return objResponse;
    }
    
    /***************************************************************************************************
* @author       Prasanth Prasanth
* @date         07/10/2020
* @methodname   getDCBSAddress
* @description  This methods is used to call get the DCBS address 
* @return       SSP_LightningResponse
*****************************************************************************************************/ 
    
    @AuraEnabled
    public static SSP_LightningResponse getDCBSAddress(String dcbsOfficeId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        try{
            if(dcbsOfficeId!=null)
            {
                Double dcbid= Double.valueOf(dcbsOfficeId);
                
                SSP_Office__c sspoffice=[SELECT Id, DCOfficeId__c, DCPhysicalAddressId__c, PhysicalAddressLine1__c, PhysicalAddressLine2__c, PhysicalCity__c, PhysicalStateCode__c, PhysicalZipCode4__c, PhysicalCountyCode__c, PhysicalZipCode5__c FROM SSP_Office__c  WHERE DCOfficeId__c =:dcbid limit 1];
                if(sspoffice!=null)
                {
                objResponse.put('response',JSON.serialize(sspoffice));
                objResponse.bIsSuccess=true;
                }
            }
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'getDCBSAddress', ex.getMessage() , true); 
                             objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                            }
        return objResponse;
    }
    
    public static String getDCBSId(String recordId)
    {
        SSP_Utility.isAuthenticatedUser();
        String dcbsID='';
        try{
            if(recordId!=null)
            {
                SSP_Office__c sspoffice=[SELECT Id, DCOfficeId__c from SSP_Office__c WHERE Id=:recordId Limit 1];
                if(sspoffice!= null && sspoffice.DCOfficeId__c!= null)
                {
                    dcbsID=String.valueOf(sspoffice.DCOfficeId__c);
                }
            }
            
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'getDCBSId', ex.getMessage() , true); 
                            }
        return dcbsID;
    }

    @AuraEnabled
    public static SSP_LightningResponse getEBTLinkVisibility(String userId){
        SSP_Utility.isAuthenticatedUser(); 
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{  
            String userRole=SSP_Utility.getUserDetails(userId).get('userRole');          
            Map<String,Boolean> permissonToAccess=new Map<String,Boolean>();
            Map<String,Boolean> linkRoleVisibility=new Map<String,Boolean>();
            Boolean visible=false;
            permissonToAccess.put('NotAccessible',false);
            permissonToAccess.put('Editable',true);            
            permissonToAccess.put('ReadOnly',true);
            for(FieldPermissions__mdt fieldPermissions :  (List<FieldPermissions__mdt>)SSP_Utility.fetchRecords(
                new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_FIELD_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},SSP_GlobalConstants.MDT_FIELD_PERMISSIONS_FIELDS, new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1000','Role__c'=>userRole,'ScreenName__c'=>'SSP_Client_Dashboard_Benefits','FieldElementName__c'=>'SSP_REQUESTEBTCARDLINK'})){
                    linkRoleVisibility.put(fieldPermissions.FieldElementName__c, permissonToAccess.get(fieldPermissions.Permission__c));
                    visible=permissonToAccess.get(fieldPermissions.Permission__c);

                }            
            dataToSend.put('linkRoleVisibility', visible);             
            dataToSend.put('bIsSuccess', true);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'getEBTLinkVisibility', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;
    }
    
     @AuraEnabled
    public static SSP_LightningResponse getMedicaidLinkVisibility(String userId){
        SSP_Utility.isAuthenticatedUser(); 
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{  
            String userRole=SSP_Utility.getUserDetails(userId).get('userRole');          
            Map<String,Boolean> permissonToAccess=new Map<String,Boolean>();
            Map<String,Boolean> linkRoleVisibility=new Map<String,Boolean>();
             Boolean visible=false;
            permissonToAccess.put('NotAccessible',false);
            permissonToAccess.put('Editable',true);            
            permissonToAccess.put('ReadOnly',true);
            for(FieldPermissions__mdt fieldPermissions :  (List<FieldPermissions__mdt>)SSP_Utility.fetchRecords(
                new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_FIELD_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},SSP_GlobalConstants.MDT_FIELD_PERMISSIONS_FIELDS, new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1000','Role__c'=>userRole,'ScreenName__c'=>'SSP_Client_Dashboard_Benefits','FieldElementName__c'=>'SSP_REQUESTMEDICAIDCARDLINK'})){
                    linkRoleVisibility.put(fieldPermissions.FieldElementName__c, permissonToAccess.get(fieldPermissions.Permission__c));
                     visible=permissonToAccess.get(fieldPermissions.Permission__c);
                }            
            dataToSend.put('linkRoleVisibility', visible);             
            dataToSend.put('bIsSuccess', true);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'getMedicaidLinkVisibility', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;
    }

    public static SSP_LightningResponse updateDashboardRefresh()
    {   SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        try{
             
            List<Contact> listcon= new List<Contact>() ; 

            String individualId=SSP_Utility.getIndividualId();
            //user!=null && user[0].ContactId<>null
            if(individualId!=null)
            {
                //user[0].ContactId
                listcon = SSP_ContactSelector.queryContactData (
                    new Map<String, String>{'objectName'=>'Contact'},
                    new Set<String>{'Id','IsDashboardRefreshNeeded__c'},
                    new Map<String, String>{'IndividualId__c'=> individualId}
                );

                if(listcon!=null &&listcon.size()>0)
                {
                    Contact contact= listcon[0];
                    contact.IsDashboardRefreshNeeded__c=true;
                    ESAPI.accessController().updateAsUser(contact, new List<string>{'IsDashboardRefreshNeeded__c'});
                    objResponse.bIsSuccess=true;
                }
                
            }
        } catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'updateDashboardRefresh', ex.getMessage() , true);            
            objResponse.bIsSuccess= false;            
            objResponse.put('error', lstLogMessages[0].Id);
            objResponse.addException(ex, lstLogMessages[0].Id);
        } 
        return objResponse;

    }
    
    @AuraEnabled
    public static SSP_LightningResponse getMemberGenderCode(String individualId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        try{
            if(individualId!=null)
            {
                List<SSP_Member__c> listMember= SSP_MemberSelector.queryMemberData(
                    new Map<String, String>{'objectName'=>'SSP_Member__c'},
                    new Set<String>{'Id','GenderCode__c'},
                    new Map<String, String>{'IndividualId__c'=> individualId}
                );
                if(listMember!=null && listMember.size()>0&&listMember[0].GenderCode__c!=null)
                {
                    objResponse.put('genderCode',listMember[0].GenderCode__c);
                    
                    objResponse.bIsSuccess=true;
                }
                
            }
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RequestAMedicaidCard', 'getGenderCode', ex.getMessage() , true); 
                             objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
                            }
        return objResponse;
        
    }
}