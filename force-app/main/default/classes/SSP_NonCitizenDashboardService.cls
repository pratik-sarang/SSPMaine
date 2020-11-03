/*
* classname     :  SSP_NonCitizenDashboardService
* @description  :  Helper class SSP_NonCitizenDashboardController for with sharing feature for searching 
* @author       :  Chandra Shekhar   
* @date         :  05/15/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Chandra Shekhar             05/15/2020                             Created.
* ---------------------------------------------------------------------------------------------
**/
public with sharing class SSP_NonCitizenDashboardService {

  /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/25/2020
* @methodname   searchClientRealtedToIndividual
* @description  This method takes userId,userRole,searchQuery and returns List of Application realted to Individual user
* @return       list<SSP_ApplicationIndividual__c>
*****************************************************************************************************/
    
    public static list<SSP_ApplicationIndividual__c> searchClientRealtedToIndividual(String userId,String userRole,String searchQuery){   
        SSP_Utility.isAuthenticatedUser();            
        
        Map<String, String> conditionMap = new Map<String, String>();
        conditionMap.put('limit','1000');
        conditionMap.put('Account.Recordtype.DeveloperName',SSP_GlobalConstants.APPLICATION);
        conditionMap.put('Roles',userRole);
        //Defect 385706 - Start
        if(userRole.equalsIgnoreCase('Assister') || userRole.equalsIgnoreCase('Individual_Auth_Rep')){
            conditionMap.put('RequestAccessPermission__c','#null#');
        }
        //Defect 385706 - End
        list<User> loggedInUser = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'},new Set<String>{'Id', 'ContactId'}, 
                                                  new Map<String, String>{'limit'=>'1','Id'=> userId});   
        conditionMap.put('contactId',loggedInUser[0].ContactId);
        
        
        list<AccountContactRelation> acrRecords = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','Contact.FirstName','Contact.LastName','Roles','ContactId','AccountId','RequestAccessPermission__c'}, 
                                                                              conditionMap);

        for(AccountContactRelation acrRecord : acrRecords){
             SSP_NonCitizenDashboardController.setofClientAccountId.add(String.valueOf(acrRecord.AccountId));
        }
        SSP_NonCitizenDashboardController.queryAccessAssociated=SSP_NonCitizenDashboardController.queryAccessAssociated.remove('AND SSP_Application__r.Account__c in :setofClientAccountId');
        if(String.isBlank(searchQuery)){
            SSP_NonCitizenDashboardController.queryAccessAssociated=SSP_NonCitizenDashboardController.queryAccessAssociated.remove('$searchQuery$');            
        } else{
            String whereClause=SSP_NonCitizenDashboardController.buildWhereClause(searchQuery,userRole);
            SSP_NonCitizenDashboardController.queryAccessAssociated=SSP_NonCitizenDashboardController.queryAccessAssociated.replace('$searchQuery$',whereClause);              
        }      
        //return (List<SSP_ApplicationIndividual__c>)Database.query(SSP_NonCitizenDashboardController.queryAccessAssociated);
        //Defect 385706 - Start
        List<SSP_ApplicationIndividual__c> lstAppIndivToReturn = new List<SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = (List<SSP_ApplicationIndividual__c>)Database.query(SSP_NonCitizenDashboardController.queryAccessAssociated);            
        if(userRole.equalsIgnoreCase('Assister') || userRole.equalsIgnoreCase('Individual_Auth_Rep')){                        
            for(SSP_ApplicationIndividual__c app : lstAppIndividuals){

                if(SSP_NonCitizenDashboardController.setofClientAccountId.contains(app.SSP_Application__r.Account__c)){
                    lstAppIndivToReturn.add(app);
                }
            }   
        }
        else{
            lstAppIndivToReturn = lstAppIndividuals;
        }
        return lstAppIndivToReturn; //Defect 385706 - End
    }  
  /***************************************************************************************************
* @author       Chandra Shekhar
* @date         06/16/2020
* @methodname   redirectToIndividualDashboard
* @description  this method redirects the Waiver user to Individual Dashboard
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static Contact redirectToIndividualDashboard(String tokenId){
        User updateUser= new User();
        updateUser.Waiver_OrgId__c='';
        updateUser.Waiver_UserId__c='';
        SSP_WDT_ConsumeRequestWrapper consumeRequest = new SSP_WDT_ConsumeRequestWrapper();           
        consumeRequest.tokenId                  = tokenId;
        consumeRequest.requestType              = 'ConsumeToken';
        consumeRequest.currentApplicationName   = 'SSP';        
        Map<String, Object> mapConsumeParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(consumeRequest)};
        List<Object> consumeResponse = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WDT_Consume, mapConsumeParams);
        SSP_WDT_ConsumeResponseWrapper consumeWrapResponse =  (SSP_WDT_ConsumeResponseWrapper)consumeResponse[0];
        
        String redirectedUserRole=   consumeWrapResponse.tokenAttributes.get('MWMARole') ;
        updateUser.Id=UserInfo.getUserId();
        if(String.isNotBlank(redirectedUserRole)){
            switch on redirectedUserRole{//386561
                when 'WAIVER DIRECT SERVICE PROVIDER SUPERVISOR'{
                    redirectedUserRole = 'WAIVER DIRECT SERVICE PROVIDER SUPERVISO';
                }
                when 'Case Management Administrator (Read Only)'{
                    redirectedUserRole = 'Case Management Administrator (Read Only';
                }
            }            
            SSP_RoleIdentifier__mdt roleName = [Select Id, Role_API__c,RoleId__c from SSP_RoleIdentifier__mdt WHERE label = :redirectedUserRole];
            updateUser.SelectedRole__c=roleName.Role_API__c;
        }
        if(consumeWrapResponse.tokenAttributes.containsKey('UserId')){
            updateUser.Waiver_UserId__c=consumeWrapResponse.tokenAttributes.get('UserId');
        }
        if(consumeWrapResponse.tokenAttributes.containsKey('OrganizationEmployeedId')){
            updateUser.Waiver_OrgId__c=consumeWrapResponse.tokenAttributes.get('OrganizationEmployeedId');
        }                       
        SSP_GenericDMLHelper.updateRecords(new List<User>{updateUser},new List<String>{'SelectedRole__c','Waiver_OrgId__c','Waiver_UserId__c'});        
        
        Contact con= new Contact();
        Con.FirstName=consumeWrapResponse.tokenAttributes.get('IndividualFirstName') ;
        Con.LastName=consumeWrapResponse.tokenAttributes.get('IndividualLastName') ;
        Con.MiddleName=consumeWrapResponse.tokenAttributes.get('IndividualMiddleInitial');     
        Con.IndividualId__c=consumeWrapResponse.tokenAttributes.get('IndividualId') ;
        return con;
    }
    
    @AuraEnabled
    public static String updateRoleAndPermissionForWaiver(String tokenId){
        User updateUser= new User();
        updateUser.Waiver_OrgId__c='';
        updateUser.Waiver_UserId__c='';
        SSP_WDT_ConsumeRequestWrapper consumeRequest = new SSP_WDT_ConsumeRequestWrapper();           
        consumeRequest.tokenId                  = tokenId;
        consumeRequest.requestType              = 'ConsumeToken';
        consumeRequest.currentApplicationName   = 'SSP';
        
        Map<String, Object> mapConsumeParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(consumeRequest)};
        List<Object> consumeResponse = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WDT_Consume, mapConsumeParams);
        SSP_WDT_ConsumeResponseWrapper consumeWrapResponse =  (SSP_WDT_ConsumeResponseWrapper)consumeResponse[0];
        String redirectedUserRole=   consumeWrapResponse.tokenAttributes.get('MWMARole') ;
        updateUser.Id=UserInfo.getUserId();
        if(String.isNotBlank(redirectedUserRole)){
            SSP_RoleIdentifier__mdt roleName = [Select Id, Role_API__c,RoleId__c from SSP_RoleIdentifier__mdt WHERE label = :redirectedUserRole];
            updateUser.SelectedRole__c=roleName.Role_API__c;
            updateUser.ShowCitizenDashboard__c = false;
        }
        if(consumeWrapResponse.tokenAttributes.containsKey('UserId')){
            updateUser.Waiver_UserId__c=consumeWrapResponse.tokenAttributes.get('UserId');
        }
        if(consumeWrapResponse.tokenAttributes.containsKey('OrganizationEmployeedId')){
            updateUser.Waiver_OrgId__c=consumeWrapResponse.tokenAttributes.get('OrganizationEmployeedId');
        }                       
        SSP_GenericDMLHelper.updateRecords(new List<User>{updateUser},new List<String>{'SelectedRole__c','Waiver_OrgId__c','Waiver_UserId__c'}); 
        
        return String.valueOf(updateUser.SelectedRole__c);
        
    }
        /***************************************************************************************************
* @author       Chandra Shekhar
* @date         06/11/2020
* @methodname   getWantToDashboardLinkVisibility
* @description  This method takes a user role and retunrs Visibility of links on dashboard
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getWantToDashboardLinkVisibility(String userId){
        SSP_Utility.isAuthenticatedUser(); 
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{  
            String userRole=SSP_Utility.getUserDetails(userId).get('userRole');          
            Map<String,Boolean> permissonToAccess=new Map<String,Boolean>();
            Map<String,Boolean> linkRoleVisibility=new Map<String,Boolean>();
            permissonToAccess.put('NotAccessible',false);
            permissonToAccess.put('Editable',true);            
            permissonToAccess.put('ReadOnly',true);
            for(FieldPermissions__mdt fieldPermissions :  (List<FieldPermissions__mdt>)SSP_Utility.fetchRecords(
                new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_FIELD_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},SSP_GlobalConstants.MDT_FIELD_PERMISSIONS_FIELDS, new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1000','Role__c'=>userRole,'ScreenName__c'=>'SSP_NonCitDash_WantTo'})){
                    linkRoleVisibility.put(fieldPermissions.FieldElementName__c, permissonToAccess.get(fieldPermissions.Permission__c));
                }            
            dataToSend.put('linkRoleVisibility', linkRoleVisibility);             
            dataToSend.put('bIsSuccess', true);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardController', 'getWantToDashboardLinkVisibility', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;
    }
     /***************************************************************************************************
* @author       Chandra Shekhar
* @date         06/03/2020
* @methodname   getScreenPermissionBasedOnRole
* @description  This method takes userId and returns screen Visibility of Client Case Notes
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getScreenPermissionBasedOnRole(String userId){
        SSP_Utility.isAuthenticatedUser(); 
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{
            String userRole=SSP_Utility.getUserDetails(userId).get('userRole');
            Map<String,Boolean> permissonToAccess=new Map<String,Boolean>();
            permissonToAccess.put('NotAccessible',false);
            permissonToAccess.put('Editable',true);            
            permissonToAccess.put('ReadOnly',true);
            Map<String,String> screenPermissionsMap =new Map<String,String>();
            for(ScreenPermissions__mdt screenPermissions :  (List<ScreenPermissions__mdt>)SSP_Utility.fetchRecords(
                new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_SCREEN_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},
                SSP_GlobalConstants.MDT_SCREEN_PERMISSIONS_FIELDS, 
                new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1','Role__c'=>userRole,'ScreenName__c'=>'SSP_Dash_CaseNote'})){
                    screenPermissionsMap.put(userRole,screenPermissions.Permission__c);
                }
            dataToSend.put('screenPermissionsMap', screenPermissionsMap);             
            dataToSend.put('bIsSuccess', true);
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenDashboardService', 'getScreenPermissionBasedOnRole', ex.getMessage() , true);            
            dataToSend.put('bIsSuccess', false);            
            dataToSend.put('error', lstLogMessages[0].Id);
            dataToSend.addException(ex, lstLogMessages[0].Id);
        } 
        return dataToSend;        
    } 
}