/*
* classname     :  SSP_WaiverController
* @description  :  Controller class for Waiver Screening Questions
* @author       :  Kireeti Gora   
* @date         :  05/30/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/

public with sharing class SSP_WaiverController {
    /*    
* @method       : getWaiverScreeningDetails
* @description  : This method returns the details required for waiver  screening questioons screen
* @author       : Kireeti Gora
* @return       : SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse getWaiverScreeningDetails(String individualId){
        SSP_LightningResponse response = new SSP_LightningResponse();       
        RSSP_DC_Wrapper wrapperResponse =  new RSSP_DC_Wrapper();         
        List<Object> serviceResponses =  new List<Object>();
        List<contact> lstContact = new List<contact>();
        List<SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper> waiverDetails =  new List<SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper>();
        SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper objWaiverDetails =  new SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper();
        try{       
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
            
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('WAIV_Screening',selectedRole);
            
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible' && individualId != null && individualId != ''){
                response.put('showScreen',true);
                
                lstContact =  SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                   new Set<String>{'Id','GenderCode__c','Name','individualId__c'}, 
                                                                   new Map<String, String>{'individualId__c'=>individualId});
                
                if(individualId != null && individualId != null){
                    Map<String, Object> mapParams = new Map<String, Object>();
                    SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
                    reqWrapper.viewName = SSP_InterfaceConstants.WAIVER_DETAILS;
                    //reqWrapper.primaryApplicationIndividualId = '890010780';
                    reqWrapper.individualIds=individualId;
                    mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                    serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                    
                    
                    
                    if(serviceResponses != null && !serviceResponses.isEmpty()){
                        wrapperResponse = (RSSP_DC_Wrapper) serviceResponses[0];                    
                    }
                    
                    if(wrapperResponse != null && wrapperResponse.waiverDetailsPayload != null && wrapperResponse.waiverDetailsPayload.WaiverDetails != null){                  
                        waiverDetails=wrapperResponse.waiverDetailsPayload.WaiverDetails;
                        
                    }
                    if(waiverDetails != null && (!waiverDetails.isEmpty())){
                        objWaiverDetails = waiverDetails[0];
                    }
                   
                    if((!lstContact.isEmpty()) && lstContact[0].GenderCode__c != null){
                       
                        response.put('contactGender',lstContact[0].GenderCode__c);
                    }
                     if((!lstContact.isEmpty()) && lstContact[0].Name != null){
                        objWaiverDetails.IndividualName = lstContact[0].Name;                       
                    }
                    if(objWaiverDetails != null){                   
                       
                        response.put('contactRecord',JSON.serialize(objWaiverDetails));
                    }else{
                        response.put('ERROR','ERROR');     
                    }
                    
                }
            }else if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='NotAccessible'){
                response.put('showScreen',false);
                
            }
            
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='ReadOnly'){
                response.put('disabled',true);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_WaiverController', 'getWaiverScreeningDetails', 'Failed to fetch Details in getWaiverScreeningDetails Method', true);  
        }
        return response;
        
    }
    /*    
* @method       : triggerWaiverScreening
* @description  : This method handles the update functionality of the waiver screening question screen
* @author       : Kireeti Gora
* @return       : SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse triggerWaiverScreening(String contactJSON){
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
        SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper objContact = new SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper();
        SSP_DatacontractOrg.WaiverResponse response = new  SSP_DatacontractOrg.WaiverResponse();
        List<Object> objList = new   List<Object>();
        try{
            objContact = (SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper)JSON.deserialize(contactJSON, SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper.class);
            
            if(objContact.individualId != null){
                SSP_DatacontractOrg.WaiverScreeningRequestModel request1 = new SSP_DatacontractOrg.WaiverScreeningRequestModel();
                request1.IndividualId = Integer.valueOf(objContact.individualId);
                request1.SelectedABICode =objContact.HasBrainInjury;
                if(objContact.WaiverScreeningId != null && objContact.WaiverScreeningId != '0'){
                    request1.WaiverScreeningId = Integer.valueOf(objContact.WaiverScreeningId);
                }else{
                    request1.WaiverScreeningId = 0;
                }
                request1.RequiresAssistanceCode =objContact.RequireAssistance;
                request1.IsDependentOnVentilator = objContact.IsVentilatorDependent;
                request1.HasIntellectualDisabilityCode =objContact.HasDevelopmentalDisability;
                request1.LikeToContinueReceivingServicesCode = objContact.WillContinueServices;               
                
                
                List<SSP_DatacontractOrg.WaiverScreeningRequestModel> requests = new List<SSP_DatacontractOrg.WaiverScreeningRequestModel> {
                    request1
                        };
                            SSP_DatacontractOrg.ArrayOfWaiverScreeningRequestModel arrRequest = new SSP_DatacontractOrg.ArrayOfWaiverScreeningRequestModel();
                arrRequest.WaiverScreeningRequestModel = requests;
                Map<String, Object> mapParams = new Map<String, Object>();
                mapParams.put(SSP_InterfaceConstants.JSON_BODY,arrRequest);
                objList = IntegrationFactory.invokeCallout('SSP_SaveWaiverScreeningResults', mapParams);
                if(objList != null && (!objList.isEmpty())){
                    response = (SSP_DatacontractOrg.WaiverResponse)objList[0]; 
                }
                
                
                if(objList != null && response != null && response.Status != null && response.Status){
                    resultMap.put('success',true);                    
                }else{
                    if(response != null && response.Error != null && response.Error.CHFSExceptionId != null){
                        resultMap.put('ERROR',response.Error.CHFSExceptionId); 
                    }else if(response != null && response.Error != null && response.Error.ErrorCode != null){
                        resultMap.put('ERROR',response.Error.ErrorCode);                  
                    }else{
                        resultMap.put('ERROR','Internal Error');  
                    }
                    
                }
            }
            
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_WaiverController', 'triggerWaiverScreening', 'Failed to fetch Details in triggerWaiverScreening Method', true);  
        }
        
        
        return resultMap;
    }
    /*  method       : triggerWaiverScreening
* @description  : This method handles the update functionality of the waiver screening question screen
* @author       : Kireeti Gora
* @return       : SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse triggerWaiverTokenGeneration(String caseNumber,String IndividualId, String Name, String targetWidget, String WaiverApplicationNumber, String roleName){
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
         List<Object> objList =  new  List<Object>();
        List<User> contactList =  new  List<User>();
        SSP_WDT_GenerateResponseWrapper response =  new SSP_WDT_GenerateResponseWrapper();
        List<String> lstName = new List<String>();
        String FirstName = '';
        String LastName = '';
        try{
            if(String.isNotBlank(Name)){
                lstName = Name.split(' ');
            }
            FirstName =(!lstName.isEmpty())? lstName[0]:'';  
            LastName =  ((!lstName.isEmpty()) && lstName.size() == 2)? lstName[1]:'';   
            
            contactList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                  new Set<String>{'Id', 'Email', 'ContactId', 'Contact.KOGSourceId__c', 'Contact.IndividualId__c', 'SelectedRole__c','Profile.Name'}, 
                                                  new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
           
            //Metadata Query- Added by Shivam for 12.4.2 - To get selectedRole label
            Map<String, String> map_roleValue_roleLabel = new Map<String, String>();
            List<SSP_RoleIdentifier__mdt> roleMetadataList = [select id, MasterLabel, Role_API__c from SSP_RoleIdentifier__mdt];
            if(roleMetadataList != null && roleMetadataList.size() > 0){
                for(SSP_RoleIdentifier__mdt meta : roleMetadataList){
                    map_roleValue_roleLabel.put(meta.Role_API__c, meta.MasterLabel);
                    switch on meta.Role_API__c{//386561
                        when 'WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR'{
                            map_roleValue_roleLabel.put(meta.Role_API__c, 'WAIVER DIRECT SERVICE PROVIDER SUPERVISOR');
                        }
                        when 'Case_Management_Administrator_Read_Only'{
                            map_roleValue_roleLabel.put(meta.Role_API__c, 'Case Management Administrator (Read Only)');
                        }
                    }
                }
            }
            String selectedRoleLabel = '';
            if(contactList[0].SelectedRole__c != null){
                selectedRoleLabel = map_roleValue_roleLabel.get(contactList[0].SelectedRole__c) != null ? map_roleValue_roleLabel.get(contactList[0].SelectedRole__c) : '';
            }
            else if(String.isNotBlank(roleName)){
                selectedRoleLabel = map_roleValue_roleLabel.get(roleName) != null ? map_roleValue_roleLabel.get(roleName) : '';
            }else if(contactList[0].Profile.Name == SSP_GlobalConstants.RE_CITIZEN_PROFILE){//392959
                selectedRoleLabel = SSP_GlobalConstants.CITIZEN;
            }
            //Shivam's changes end here
            
            SSP_WDT_GenerateWrapper request = new SSP_WDT_GenerateWrapper();
            Map<String, String> attributeMap = new Map<String, String>();
            
            
            //Changes added by Shivam - as part of 12.4.2
            attributeMap.put('TargetWidget', targetWidget);
            attributeMap.put('UserId', contactList[0].Email);			//Email of Logged-in User
            attributeMap.put('SSPRole', selectedRoleLabel);				//Role Label of loggedin user
            attributeMap.put('CurrentPortal', 'benefind');
            
            if(String.isNotBlank(selectedRoleLabel) && SSP_GlobalConstants.ALL_WAIVER_ROLES.contains(selectedRoleLabel.toUpperCase())){
                attributeMap.put('UserType', 'MWMA');
            }
            else{
                attributeMap.put('UserType', 'SSP');
            }
            
            if(!targetWidget.equalsIgnoreCase('DSH_001')){
                attributeMap.put('CaseNumber', caseNumber != null ? caseNumber : '0');
                attributeMap.put('IndividualId', IndividualId != null ? IndividualId : '0');
                
                if(targetWidget.equalsIgnoreCase('DSH_020')){
                    attributeMap.put('LoggedInUserIndividualId', contactList[0].Contact.IndividualId__c != null ? contactList[0].Contact.IndividualId__c : '0');
                }
                else if(targetWidget.equalsIgnoreCase('APP_004')){
                    if(WaiverApplicationNumber != null){
                        attributeMap.put('WaiverApplicationNumber', WaiverApplicationNumber);
                    }
                    attributeMap.put('PrimaryIndividualId', IndividualId != null ? IndividualId : '0');
                }
            }
            
            //end
            request.targetApplication = 'WCM';	//Waiver
            request.sourceApplication = 'SSP';
            request.requestType = 'GenerateToken';
            request.kogId = ((!contactList.isEmpty())&contactList[0].contact.KOGSourceId__c != null) ?contactList[0].contact.KOGSourceId__c:'';
            request.attributeMap = attributeMap;
            
            Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
            objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WDT_Generate, mapParams);
            if(objList != null && (!objList.isEmpty())){
             response = (SSP_WDT_GenerateResponseWrapper) objList[0];
                if(response != null && response.TokenId != null){
                    SSPIntegrationEndpoints__c waiverPortal = SSPIntegrationEndpoints__c.getValues('waiverPortal');			
                    resultMap.put('tokenId','https://'+waiverPortal.URL__c+'?Token='+response.TokenId);
                }else{
                    resultMap.put('ERROR',true);       
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_WaiverController', 'triggerWaiverScreening', 'Failed to fetch Details in triggerWaiverScreening Method', true);  
        }
        
        
        return resultMap;
    }
    /**
    * @author: Karthik Gulla
    * @method: checkIfIndividualApplicableForWaiver
    * @desc This method is used to get if the particular individual is eligible to check Waiver eligibility
    *       Added as part of Security Defect # 385380
    * @param String sIndividualId
    * @return Boolean
    * */
    @AuraEnabled
    public static SSP_LightningResponse checkIfIndividualApplicableForWaiver(String sIndividualId, String sCaseNumber){
        Boolean bReturnIndividualValue = false;
        Boolean bReturnCaseValue = false;
        Integer iWaiverStatusLength = 0;
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            Map<String,SSP_BenefitsPageController.waiverDetailsFormattedWrapper> mapWaiverDetails = (Map<String, SSP_BenefitsPageController.waiverDetailsFormattedWrapper>)sessionPart.get('mapWaiverDetails');
            Map<String,List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>> mapWaiverStatus = (Map<String, List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>>)sessionPart.get('mapWaiverStatus');
            List<String> lstIndividualIds = (List<String>)sessionPart.get('listIndividualIds');
            Set<String> setIndividualIds = (lstIndividualIds != null) ? new Set<String>(lstIndividualIds) : new Set<String>();
            String mapCaseVsAllBenefitsString = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
            if(String.isNotBlank(mapCaseVsAllBenefitsString) ){
                Map<String, List<SSP_BenefitInformationWrapper>> activeBenefitsMap =   (Map<String,List<SSP_BenefitInformationWrapper>>)JSON.deserialize(String.valueOf(mapCaseVsAllBenefitsString), Map<String,List<SSP_BenefitInformationWrapper>>.class);
                if(activeBenefitsMap.get(sCaseNumber) != null) {
                    for(SSP_BenefitInformationWrapper sspBenefitWrapper : activeBenefitsMap.get(sCaseNumber)){
                        if(sspBenefitWrapper.IndividualId != null){
                            setIndividualIds.add(sspBenefitWrapper.IndividualId);
                        }
                    }
                }   
            }

            if(mapWaiverDetails != null && !mapWaiverDetails.isEmpty() && sIndividualId != null && mapWaiverDetails.get(sIndividualId) != null){
                SSP_BenefitsPageController.waiverDetailsFormattedWrapper sspWaiverDetailRecord = mapWaiverDetails.get(sIndividualId);
                if(!sspWaiverDetailRecord.atleastOneAnsweredYes) {
                    bReturnIndividualValue = true;
                }
            }

            if(!setIndividualIds.isEmpty() && sIndividualId != null && setIndividualIds.contains(sIndividualId)){
                bReturnIndividualValue = true;
            }

            if(mapWaiverStatus != null && !mapWaiverStatus.isEmpty() && sIndividualId != null && mapWaiverStatus.get(sIndividualId) == null){
                bReturnIndividualValue = true;
                if(mapWaiverStatus.get(sIndividualId) != null){
                    iWaiverStatusLength = ((List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>)mapWaiverStatus.get(sIndividualId)).size();
                }
            } 
            
            Integer iClosedStatusCounter = 0;
            if(mapWaiverStatus != null && mapWaiverStatus.isEmpty() && sIndividualId != null && mapWaiverStatus.get(sIndividualId) != null){
                for(SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper sspWaiverWrapper : mapWaiverStatus.get(sIndividualId)) {
                    if(sspWaiverWrapper.ApplicationStatus == 'COM' && (sspWaiverWrapper.ProgramStatusCode=='EN'||sspWaiverWrapper.ProgramStatusCode=='WL')) {
                        iClosedStatusCounter++;
                    }
                    else if(sspWaiverWrapper.ApplicationStatus == 'COM' && (sspWaiverWrapper.WaiverCaseStatus == 'CLDTC' || sspWaiverWrapper.WaiverCaseStatus == 'CL')) {
                        iClosedStatusCounter++;
                    }
                }
            }

            if(iClosedStatusCounter> 0 && iClosedStatusCounter == iWaiverStatusLength) {
                bReturnIndividualValue = true;
            }

            Set<String> setCases = new Set<String>();
            Map<String, String> mapCaseVsStatus  =  new  Map<String, String>(); 
            String mapCaseVsStatusString = sessionPart.get('caseVsStatus') != null ? String.valueOf(sessionPart.get('caseVsStatus')) : String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
            if(String.isNotBlank(mapCaseVsStatusString)){
                mapCaseVsStatus = (Map<String,String>)JSON.deserialize(String.valueOf(mapCaseVsStatusString), Map<String,String>.class);
            }
            if(!mapCaseVsStatus.isEmpty()){
                for(String strCase:mapCaseVsStatus.keyset()){
                    setCases.add(strCase);
                }
            }

            if(!setCases.isEmpty() && sCaseNumber!= null && setCases.contains(sCaseNumber)){
                bReturnCaseValue = true;
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_WaiverController', 'checkIfIndividualApplicableForWaiver', e.getMessage(), true);
        } 
        response.put('hasAccess', (bReturnIndividualValue && bReturnCaseValue));       
        return response;
    }
}