/*
* classname     :  SSP_MyInformationController
* @description  :  Controller Method for My Information Screen.
* @author       :  Kireeti Gora
* @date         :  12/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_MyInformationController { 
    
    public Static String LocalDCBSOffice ='';
    private static String outOfStateCounty = SSP_Utility.getPickListValues('SSP_Member__c', 'PhysicalCountyCode__c', null).get('200');
    private static String nullValue = 'null';
    /***************************************************************************************************
* @author       Kireeti Gora
* @date         12/24/2019
* @methodname   getMyInformationDetails
* @description  This methods is used to get user information details
* @return       SSP_LightningResponse
*****************************************************************************************************/ 
    @AuraEnabled
    public static SSP_LightningResponse getMyInformationDetails(String pageParam){     
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_Member__c> lstmember =new List<SSP_Member__c>(); 
        List<User> lstUser = new List<User>();
        Id sspMemberId;
        //for defect 387805
        Double DcId;
        String physicalAddress = '';
        String mailingAddress = '';
        
        try{   
            pageParam = String.escapeSingleQuotes(pageParam); //Added as part of Defect - 383060
            lstUser = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                     new Set<String>{'Id', 'ContactId','contact.Name','contact.Email','contact.firstName','contact.lastname'}, 
                                                     new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}); 
            
            String individualId = SSP_Utility.getIndividualId(); //2.5 Security Role Matrix and Program Access.
            response.put('individualId', individualId);
            Contact individualContact = SSP_DashboardService.getIndividualContact(individualId); //2.5 Security Role Matrix and Program Access.
            //Start - Added as part of Defect - 383060
            if(String.isNotBlank(pageParam) && pageParam.equalsIgnoreCase(SSP_GlobalConstants.HAMBURGER)) {
                Map<String, String> userDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());
                individualContact = userDetails.get('profileName').equalsIgnoreCase(SSP_GlobalConstants.NON_CITIZEN_PROFILE) ? null : individualContact;
            }
            //End - Added as part of Defect - 383060
            if(refreshMemberInformation().bIsSuccess && individualContact != null && String.isNotBlank(individualContact.Id)){    
                lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND','hasToLabel'=>'true'}, 
                                                               new Set<String>{'Id', 'PrimaryPhoneNumber__c', 'PrimaryPhoneExtension__c', 'PreferredNotificationMethodForTaxCode__c',
                                                                   'contact__c','SecondaryPhoneNumber__c','PhysicalAddressLine1__c','Name','FirstName__c','LastName__c', 'IndividualId__c',
                                                                   'PhysicalAddressLine2__c','MailingAddressLine1__c','MailingAddressLine2__c',
                                                                   'Email__c','toLabel(PreferredSpokenLanguageCode__c)','toLabel(PreferredWrittenLanguageCode__c)','toLabel(PreferredNotificationMethodCode__c)',
                                                                   'toLabel(PhysicalCountyCode__c)','toLabel(MailingCountyCode__c)','toLabel(PhysicalStateCode__c)','toLabel(MailingStateCode__c)','PhysicalZipCode5__c','MailingZipCode5__c',
                                                                   'PhysicalCity__c','MailingCity__c', 'PhysicalZipCode4__c', 'MailingZipCode4__c','DcId__c'}, 
                                                               new Map<String, String>{'limit' => '1','Contact__c' => individualContact.Id}); //2.5 Security Role Matrix and Program Access.
                
                
                
                
                if(!lstmember.isEmpty()){ 
                    sspMemberId =  lstmember[0].Id;
                    //for Defect 387805
                    DcId = lstmember[0].DcId__c;

                    if(lstmember[0].PreferredNotificationMethodCode__c != null && lstmember[0].PreferredNotificationMethodCode__c != '' & lstmember[0].PreferredNotificationMethodCode__c.contains(';')){
                        lstmember[0].PreferredNotificationMethodCode__c = lstmember[0].PreferredNotificationMethodCode__c.replaceAll(';',', ');
                    }
                    response.put('memberRecord', lstmember[0]);
                    response.put('memberDetail',JSON.serialize(lstmember[0])); 
                    physicalAddress = formatAddress(
                        lstmember[0].PhysicalAddressLine1__c,
                        lstmember[0].PhysicalAddressLine2__c,
                        lstmember[0].PhysicalCity__c,
                        lstmember[0].PhysicalCountyCode__c,
                        lstmember[0].PhysicalStateCode__c,
                        lstmember[0].PhysicalZipCode4__c,
                        lstmember[0].PhysicalZipCode5__c,
                        null);

                    if(physicalAddress != ''){
                        response.put('physicalAddress',physicalAddress); 
                    }
                    mailingAddress = formatAddress(
                        lstmember[0].MailingAddressLine1__c,
                        lstmember[0].MailingAddressLine2__c,
                        lstmember[0].MailingCity__c,
                        lstmember[0].MailingCountyCode__c,
                        lstmember[0].MailingStateCode__c,
                        lstmember[0].MailingZipCode4__c,
                        lstmember[0].MailingZipCode5__c,
                        null);
                    if(mailingAddress != ''){
                        response.put('mailingAddress',mailingAddress);
                    }
                    
                }
            }
            
            
            if(sspMemberId != null){
                if(LocalDCBSOffice != ''){
                    // for Defect 387805
                    if(DcId!=null){
                    response.put('office',LocalDCBSOffice);  
                    response.put('activeApplication',true); 
                    response.put('disableEdit',false);
                    }
                }else if((!lstUser.isEmpty()) && lstUser[0].contactId != null && (lstmember == null || (lstmember != null && lstmember.isEmpty()) || (lstmember != null && !lstmember.isEmpty() && String.isBlank(lstmember[0].FirstName__c)) )){
                    SSP_Member__c objMember = new SSP_Member__c();
                    objMember.FirstName__c = lstUser[0].contact.Firstname;
                    objMember.LastName__c = lstUser[0].contact.lastname;
                    objmember.Email__c = lstUser[0].contact.Email;                    
                    response.put('memberDetail',JSON.serialize(objmember));
                    SSP_Member__c memberRecord = (SSP_Member__c)response.mapResponse.get('memberRecord');
                    if(memberRecord != null) {
                        memberRecord.Email__c = lstUser[0].contact.Email;
                        response.put('memberRecord', memberRecord);
                    }
                    else {
                        response.put('memberRecord', objmember);
                    }
                }
            }else if((!lstUser.isEmpty()) && lstUser[0].contactId != null){
                SSP_Member__c objMember = new SSP_Member__c();
                objMember.FirstName__c = lstUser[0].contact.Firstname;
                objMember.LastName__c = lstUser[0].contact.lastname;
                objmember.Email__c = lstUser[0].contact.Email;
                response.put('memberDetail',JSON.serialize(objmember));
                SSP_Member__c memberRecord = (SSP_Member__c)response.mapResponse.get('memberRecord');
                if(memberRecord != null) {
                    memberRecord.Email__c = lstUser[0].contact.Email;
                    response.put('memberRecord', memberRecord);
                }
                else {
                    response.put('memberRecord', objmember);
                }
            }
            //Shikha - added 
			Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
            String racEnabled = (String)sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'racEnabledFlag');
            if(racEnabled == 'true'){
                response.put('showRAC',true);
            }
            else{
                response.put('showRAC',false);
            }

            /** 2.5  Security Role Matrix and Program Access. */
            response.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.MY_INFORMATION_LANDING_SCREENID, null));
            /** */
        }catch(Exception e) {
            /** 2.5  Security Role Matrix and Program Access. */
            response.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.MY_INFORMATION_LANDING_SCREENID, null));
            /** */
            LOG_LogMessageUtility.logMessage(e, 'SSP_MyInformationController', 'getMyInformationDetails', 'Failed to fetch Member Details in getMyInformationDetails Method', true);
        }
        
        return response;
    }
    
    /***************************************************************************************************
* @author       Shivam Tiwari
* @date         05/20/2020
* @methodname   getCaseOwnershipFlag
* @description  This methods is used to get Ownership Type field value from Contact record of logged in user 
* @return       
*****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getCaseOwnershipFlag(){
        List<User> userList = new List<User>();
        List<Contact> conList = new List<Contact>();
        String memberType = '';
        String selectedRole;
        String primaryIndId;
        try{
            selectedRole = SSP_Utility.getSelectedRole();
            primaryIndId = ssp_utility.getIndividualId();

            //Impersonisation
            if(selectedRole!=SSP_GlobalConstants.CITIZEN_ROLE && primaryIndId!=null && primaryIndId!=''){
                List<contact> lstCurrentUserContactIds = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                                    new Set<String>{'id','IndividualId__c','CaseOwnership__c'}, 
                                                                                    new Map<String, String>{'IndividualId__c'=>primaryIndId}); 
                if(!lstCurrentUserContactIds.isEmpty()){
                    memberType = lstCurrentUserContactIds[0].CaseOwnership__c;
                }
            }
            else{            
                userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId','Contact.IndividualId__c', 'Contact.MemberType__c', 'Contact.CaseOwnership__c','Contact.Name'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
                
                if(userList != null && userList.size() > 0){
                    memberType = userList[0].Contact.CaseOwnership__c;
                }  
            }          
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MyInformationController', 'getCaseOwnershipFlag', e.getMessage(), true);
        }
        return memberType;
    }
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         01/29/2020
* @methodname   fetchContactMethodDetails
* @description  This methods is used to fetch details for change contact method component.
* @return       SSP_LightningResponse
*****************************************************************************************************/ 
    @auraEnabled
    public static SSP_LightningResponse fetchContactMethodDetails(Id sspMemberId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            SSP_Member__c member = SSP_MemberSelector.queryMemberDataById(sspMemberId, new List<String>{'Id', 'IndividualId__c', 'PreferredNotificationMethodCode__c'});
                        
            MyInformationWrapper data = new MyInformationWrapper();
            
            data.availableContactMethods = SSP_Utility.getPickListValues('SSP_Member__c','PreferredNotificationMethodCode__c',null);
            data.selectedContactMethod = member.PreferredNotificationMethodCode__c;
            response.put('individualId',member.IndividualId__c);   
            response.put('dataWrapper', data);
            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MyInformationController', 'fetchContactMethodDetails', ex.getMessage() , true);            
            response.addException(ex, lstLogMessages[0].Id); 
            
        }
        return response;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse triggerMyInfoCallout(String individualId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{                            
            Map<String, Object> mapParams = new Map<String, Object>();
            mapParams.put(SSP_InterfaceConstants.IndividualId, individualId);
            List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.UPDATE_CONTACT_INFO, mapParams);
            response.bIsSuccess = false;
            if(objList.get(0) == null){
                response.put('ERROR','Null response received');
            }
            else{
                SSP_ContactInfoUpdateResponseWrapper resp = (SSP_ContactInfoUpdateResponseWrapper)  objList.get(0);
                
                if(resp.status != null && resp.status){
                    response.bIsSuccess = true;
                }
                //resp.status != null && !resp.status && resp.AckResponse != null && resp.AckResponse.AckResponseCode != null && resp.AckResponse.AckResponseDescription
                else if(resp.status != null && !resp.status && resp.AckResponse != null && resp.AckResponse.AckResponseCode != null){
                    response.put('SERVICE_ERROR', resp.AckResponse.AckResponseCode);
                }
                else{
                    response.put('ERROR','Error in service call with response : '+resp);
                }
            }        

        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MyInformationController', 'triggerMyInfoCallout', ex.getMessage() , true);            
            response.addException(ex, lstLogMessages[0].Id); 
        }
        return response;
    }
    
    /***************************************************************************************************
* @author       
* @date         03/04/2020
* @methodname   refreshMemberInformation
* @description  This methods is used to pull member data using RSSPDC service and update respective member object
* @return       SSP_LightningResponse
*****************************************************************************************************/
    public static SSP_LightningResponse refreshMemberInformation(){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{            
            //List<User> userData = SSP_Utility.getCurrentUserDetails();
            String individualId = SSP_Utility.getIndividualId(); //2.5 Security Role Matrix and Program Access. 
            response.bIsSuccess = true;
            if(String.isNotBlank(individualId)){
                Contact individualContact = SSP_DashboardService.getIndividualContact(individualId); //2.5 Security Role Matrix and Program Access. 
                Map<String,Object> mapParams=new Map<String,Object>();
                SSP_RSSPDC_RequestWrapper reqWrapper=new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName = SSP_InterfaceConstants.MY_INFORMATION;
                //Commented while doing Multiple IndividualId changes
                reqWrapper.primaryApplicationIndividualId = individualId; //2.5 Security Role Matrix and Program Access. 
                //userData[0].Contact.IndividualId__c;
                //reqWrapper.primaryApplicationIndividualId = SSP_Utility.getCurrentUserAllIndividualIds();
                mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                //Fix for 382061-MY_INFORMATION - start
                mapParams.put(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD,true);
                mapParams.put(SSP_InterfaceConstants.SKIP_DML_OPERATIONS, true);
                //Fix for 382061-MY_INFORMATION - end
                List<Object> objList=IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC,mapParams);
                RSSP_DC_Wrapper responseWrapper=(RSSP_DC_Wrapper)objList.get(0);              
                response.bIsSuccess = upsertMemberInformation(responseWrapper, individualContact.Id);
            }
            
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_Utility', 'refreshMemberInformation', ex.getMessage() , true);            
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }
    
    
    /***************************************************************************************************
* @author       
* @date         03/04/2020
* @methodname   updateMemberInformation
* @description  This methods is used to Update respective member record with the date receiver using RSSPDC service call.
* @return       Boolean
*****************************************************************************************************/    
    public static Boolean upsertMemberInformation(RSSP_DC_Wrapper responseWrapper, Id contactId){    
        
        SSP_Member__c member= new SSP_Member__c();
        List<SSP_Member__c> memberList =new List<SSP_Member__c>();
        //Fix for 382061-MY_INFORMATION
        List<String> exFieldList = new List<string>{'PreferredDCBSOffice__c','PrimaryPhoneTypeCode__c'};
            Map<String, String> fieldAPIMapping = new Map<String, String>{'IsSecondaryTextPreferred__c' => 'Send_Text_messages_to_Secondary__c'};
                Boolean result = true;
        String individualId = '';
        if(responseWrapper != null && responseWrapper.payload != null){
            Map<String, List<Object>> mapPayload = (Map<String, List<Object>>) responseWrapper.payload;            
            if(mapPayload.get('SSP_Member__c') != null){
                List<Object> memberDataList = (List<Object>)mapPayload.get('SSP_Member__c'); 
                member = (SSP_Member__c)JSON.deserialize(JSON.serialize(memberDataList.get(0)), SSP_Member__c.class);
                //Fix for 382061-MY_INFORMATION - start
                if(member.PreferredDCBSOffice__c != null && member.PreferredDCBSOffice__c != ''){
                    LocalDCBSOffice = member.PreferredDCBSOffice__c;
                }
                //Fix for 382061-MY_INFORMATION - end
            }
            if(member != null && member.IndividualId__c != null){
                memberList = SSP_MemberSelector.queryMemberData(new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME=>'SSP_Member__c'}, 
                                                                new Set<String>{'Id', 'IndividualId__c'}, 
                                                                new Map<String, String>{'limit'=>'1','IndividualId__c'=>member.IndividualId__c });
            }
            if(memberList != null && !memberList.isEmpty()){
                member.id = memberList[0].Id;
            }
            else{
                member.Contact__c =contactId;    
            }  
            
            result =  ESAPI.accessController().upsertAsUser(member, SSP_Utility.getFieldsNamesObject(member)) != null ? true :false; 
            
        }
        return result;
    }

    public static String formatAddress(String line1, String line2, String city, String county, String state, String zip4, String zip5, String country) {
        List<String> arguments = new List<String>{line1, line2, city, outOfStateCounty, state, zip4, zip5, country};
        return String.format('{0}, {1}, {2}, {3}, {4}, {6}, {5}', arguments)
            .replaceAll('null', '')
            .replaceAll(outOfStateCounty, '')
            .replaceAll(',[\\s,]*,', ', ')
            .replaceAll('(^[,\\s]+)|([,\\s]+$)', '');
    }

    public class MyInformationWrapper{
        @AuraEnabled
        public Map<String, String> availableContactMethods{get; set;}
        @AuraEnabled
        public String selectedContactMethod {get;set;}
    }
}