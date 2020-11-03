/*
* classname     :  SSP_DashboardService
* @description  :  Controller Method for SSP_DashboardController and SSP_RoleSelection
* @author       :  Shrikant Raut   
* @date         :  04/20/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public inherited sharing class SSP_DashboardService {
     Public static Boolean isRedirectedForImpersonation =false;
     public static List<KOGRoleMapping__mdt> sspKOGROleList; //#397070
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         04/30/2020
    * @methodname   constructDetailsWrapper
    * @description  This methods is used to fetch required data for role selection cmp - CD2 4.1.2 Multiple Roles
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    public static UserDetailsWrapper constructDetailsWrapper(String userId, Boolean performDMLs){
         User u = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                            new Set<String>{'Id', 'LastVisitedNonCitizenRole__c', 'ShowCitizenDashboard__c', 'Profile.Name' ,'ContactId','SelectedRole__c','KOG_Role__c','ApplicableRoles__c','Profile.Name','ImpersonatedIndividualId__c','Contact.FirstName','Contact.LastName','Contact.MiddleName','Contact.SuffixCode__c'},  //#376149 Added SuffixCode__c and MiddleName
                                                                            new Map<String, String>{'limit'=>'1','Id'=> userId})[0];        
        Map<String,String> rolesMap = SSP_Utility.getPickListValues('User', 'ApplicableRoles__c', null);         
        Set<String> applicableRolesSet = getApplicableRoleSet(getAssignedPermissionSets(userId), u.ApplicableRoles__c);//new Set<String>((u.ApplicableRoles__c != null && !String.isBlank(u.ApplicableRoles__c)) ? u.ApplicableRoles__c.split(';') : new List<String>());
        List<String> applicableRoleList = new List<String>();
        UserDetailsWrapper wrap = new UserDetailsWrapper();
        if(String.isBlank(u.SelectedRole__c)){
            wrap.reloadPage = true;
        }  
        wrap.rolesMap = rolesMap;
        wrap.userFirstName = u.Contact.FirstName;
        wrap.userLastName = u.Contact.LastName;
        wrap.userMiddleInitial = u.Contact.MiddleName; //#376149
        wrap.userSuffix = u.Contact.SuffixCode__c; //#376149
        wrap.impersonatedIndividualId = u.ImpersonatedIndividualId__c;
        wrap.selectedRole = u.SelectedRole__c;
        wrap.lastVisitedNonCitizenRole = u.lastVisitedNonCitizenRole__c;
        wrap.userProfile = u.Profile.Name;
        wrap.showCitizenDashboard = u.ShowCitizenDashboard__c; 
        //PE URL Redirection code added 
        wrap.showQeHospitalRole = false; 
        wrap.isQeRedirect = false;
        //Getting PE URL from custom setting
        wrap.qeRedirectUrl = SSPIntegrationEndpoints__c.getInstance('PE_URL_Redirect').URL__c;
        if( u.ApplicableRoles__c!=null) {
            applicableRoleList =  getSSPRoles(new Set<String>(u.ApplicableRoles__c.split(';'))); //#397070
        }
        wrap.showCitizenDashboardLink = (applicableRolesSet != null && applicableRolesSet.size() > 0 && applicableRolesSet.contains(SSP_GlobalConstants.CITIZEN_ROLE));
        if(applicableRolesSet.contains(SSP_GlobalConstants.CITIZEN_ROLE)){
            applicableRolesSet.remove(SSP_GlobalConstants.CITIZEN_ROLE);
        }

        // If QE Hospital or QE Pregnancy roles are present in applicable roles then show QE redirect URL on dashboard
        if(applicableRoleList != null && !applicableRoleList.isEmpty()) {
            if(applicableRoleList.contains(SSP_GlobalConstants.QE_HOSPITAL_ROLE) || applicableRoleList.contains(SSP_GlobalConstants.QE_PREGNANCY_ROLE)) {
                //Getting PE URL from custom setting
                SSP_LightningResponse validateSSORes = SSP_Utility.validateSSORedirect('PE_BCCTP');
                if(validateSSORes != null && validateSSORes.mapResponse.containsKey('endPoint') && validateSSORes.mapResponse.containskey('encryptedToken')) {
                    wrap.endPoint = (String) validateSSORes.mapResponse.get('endPoint');
                    wrap.encryptedToken = (String) validateSSORes.mapResponse.get('encryptedToken');
                }
                wrap.showQeHospitalRole = true;
                if(applicableRoleList.size() == 1 ||  (applicableRoleList.size() == 2 && applicableRoleList.contains(SSP_GlobalConstants.QE_HOSPITAL_ROLE) && applicableRoleList.contains(SSP_GlobalConstants.QE_PREGNANCY_ROLE))) {
                    wrap.isQeRedirect = true;
                } 
            }
        }
        applicableRoleList = new List<String>();
        wrap.showProfileDropDown = (applicableRolesSet != null && !applicableRolesSet.isEmpty() && applicableRolesSet.size() > 0) ? true : false;         
        wrap.selectedRole = !performDMLs ? wrap.selectedRole : (String.isNotBlank(wrap.selectedRole) && !wrap.selectedRole.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE)) ? wrap.selectedRole : ( String.isNotBlank(wrap.lastVisitedNonCitizenRole) ? wrap.lastVisitedNonCitizenRole : ((applicableRolesSet != null && !applicableRolesSet.isEmpty()) ? new List<String>(applicableRolesSet).get(0) : null));
        wrap.lastVisitedNonCitizenRole = !performDMLs ? ((String.isNotBlank(wrap.selectedRole) && wrap.selectedRole.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE)) ? wrap.lastVisitedNonCitizenRole : wrap.selectedRole ) : wrap.lastVisitedNonCitizenRole;
        for(String roleAPI : rolesMap.keySet()){
            if(applicableRolesSet != null && !applicableRolesSet.isEmpty() && applicableRolesSet.contains(roleAPI) && !roleAPI.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE)){
                wrap.applicableRoles.add(new SSP_RepsAssistersAgentsController.picklistWrapper(rolesMap.get(roleAPI), roleAPI));  
                applicableRoleList.add(roleAPI);                                 
            }
        }

        if(applicableRoleList!= null && applicableRoleList.size() > 0 && !String.isBlank(wrap.selectedRole)) {
            if(!applicableRoleList.contains(wrap.selectedRole)) {
                wrap.selectedRole = applicableRoleList[0];
            }
        }
        if(wrap.selectedRole != null && performDMLs && !wrap.showCitizenDashboard){
            SSP_RoleSelection.invokeFlowForPermissionSet(wrap.selectedRole, u,isRedirectedForImpersonation);
        }
        return wrap;                                                                       
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         10/05/2020
    * @methodname   getKOGROleList - //#397070
    * @description  This methods is used query KOGRoleMapping__mdt for SSP roles.
    * @return       List<KOGRoleMapping__mdt>
    *****************************************************************************************************/
    private static List<KOGRoleMapping__mdt> getKOGROleList(){
        if(sspKOGROleList == null || (sspKOGROleList != null && sspKOGROleList.isEmpty()))
        {
            sspKOGROleList = [SELECT Id, DeveloperName FROM KOGRoleMapping__mdt WHERE Is_SSP_User__c = true LIMIT 1000];
        }
        return sspKOGROleList;
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         10/05/2020
    * @methodname   getSSPRoles - //#397070
    * @description  This method is used to exclude RE related roles from user's applicable roles picklist values.
    * @return       List<String> - List<SSP Applicable roles>
    *****************************************************************************************************/
    private static List<String> getSSPRoles(Set<String> applicableRoles){
        List<String> roleSet = new List<String>();
        Set<String> kogSSPRoles = new Set<String>();
        Map<String, String> permissionSetToRoleAPIMap = new Map<String, String>{
            'Eligibility_Benefit_Inquiry_User' => 'Eligibility_&_Benefit_Inquiry_User',
            'Waiver_Direct_Service_Provider_Superviso' => 'WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR'
        };
        if(applicableRoles != null && !applicableRoles.isEmpty()){
            for(KOGRoleMapping__mdt kogRole : getKOGROleList()){
                kogSSPRoles.add(permissionSetToRoleAPIMap.containsKey(kogRole.DeveloperName) ? permissionSetToRoleAPIMap.get(kogRole.DeveloperName).toLowerCase() : kogRole.DeveloperName.toLowerCase());
            }
            if(!kogSSPRoles.isEmpty()){
                for(String role : applicableRoles){
                    if(kogSSPRoles.contains(role.toLowerCase())){
                        roleSet.add(role);
                    }
                }
            }
        }
        return roleSet;
    }
    
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         04/30/2020
    * @methodname   getApplicableRoleSet
    * @description  This methods is used to construct set of applicable roles
    * @return       Set<String>
    *****************************************************************************************************/
    private static Set<String> getApplicableRoleSet(Set<String> assignedPermissionSets, String applicableRoles){

        Set<String> applicableRolesSet = new Set<String>();
        Set<String> kogSSPRoles = new Set<String>(); //#397070
        Map<String, String> permissionSetToRoleAPIMap = new Map<String, String>{
            'Eligibility_Benefit_Inquiry_User' => 'Eligibility_&_Benefit_Inquiry_User',
            'Waiver_Direct_Service_Provider_Superviso' => 'WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR'
        }; //#397070
        if(String.isNotBlank(applicableRoles) && assignedPermissionSets != null && !assignedPermissionSets.isEmpty()){
            /** 397070 */            
            Set<String> rawApplicableRoleSet = new Set<String>(applicableRoles.split(';'));

            for(KOGRoleMapping__mdt kogRole : getKOGROleList()){ 
                kogSSPRoles.add(permissionSetToRoleAPIMap.containsKey(kogRole.DeveloperName) ? permissionSetToRoleAPIMap.get(kogRole.DeveloperName).toLowerCase() : kogRole.DeveloperName.toLowerCase());
            }
            /** */
            for(String role : rawApplicableRoleSet){  //#397070
                if(kogSSPRoles.contains(role.toLowerCase()) && assignedPermissionSets.contains(role) && (!role.EqualsIgnoreCase(SSP_GlobalConstants.QE_HOSPITAL_ROLE) && !role.EqualsIgnoreCase(SSP_GlobalConstants.QE_PREGNANCY_ROLE))){ //#397070
                    applicableRolesSet.add(role);
                }
            }
        }
        return applicableRolesSet;
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         05/07/2020
    * @methodname   getAssignedPermissionSets
    * @description  This methods is used to get the names of assigned permission sets.
    * @return       Set<String>
    *****************************************************************************************************/
    private static Set<String> getAssignedPermissionSets(String userId){
        Set<String> assignedPermissionSets = new Set<String>();
        /** #379715 */
        Map<String, String> permissionSetToRoleAPIMap = new Map<String, String>{
            SSP_GlobalConstants.ELIGIBILITY_BENEFIT_PERMISSION_SET_API => SSP_GlobalConstants.ELIGIBILITY_BENEFIT_ROLE_API
        };
       
        
        for(PermissionSetAssignment pSet : [select id, PermissionSet.Name from permissionsetassignment where AssigneeId = :userId]){
            String permissionName = pSet.PermissionSet.Name;
            if(String.isNotBlank(permissionName) && permissionSetToRoleAPIMap != null && permissionSetToRoleAPIMap.containsKey(permissionName)){
                assignedPermissionSets.add(permissionSetToRoleAPIMap.get(permissionName));
            }
            else{
                assignedPermissionSets.add(pSet.PermissionSet.Name);
            }
        }
        /** */ 
        return assignedPermissionSets;                                                            
    }

    public class UserDetailsWrapper{
        @AuraEnabled public Boolean showCitizenDashboardLink = false;
        @AuraEnabled public Boolean showProfileDropDown = false;
        @AuraEnabled public Boolean reloadPage = false;
        @AuraEnabled public Boolean isQeRedirect;
        @AuraEnabled public Boolean showCitizenDashboard;
        @AuraEnabled public Boolean showQeHospitalRole;
        @AuraEnabled public String selectedRole;
        @AuraEnabled public String userProfile;
        @AuraEnabled public String impersonatedIndividualId;  
        @AuraEnabled public String userFirstName;
        @AuraEnabled public String userLastName;  
        @AuraEnabled public String userMiddleInitial;  //#376149
        @AuraEnabled public String userSuffix; //#376149 
        @AuraEnabled public String lastVisitedNonCitizenRole;
        @AuraEnabled public String qeRedirectUrl;
        @AuraEnabled public String endPoint;
        @AuraEnabled public String encryptedToken;
        @AuraEnabled public Object citizenContact;
        @AuraEnabled public Map<String, String> rolesMap;
        @AuraEnabled public List<SSP_RepsAssistersAgentsController.picklistWrapper> applicableRoles = new List<SSP_RepsAssistersAgentsController.picklistWrapper>();        
    }
 
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         05/18/2020
    * @methodname   getIndividualContact
    * @description  This methods is used to get contact record using individual id
    * @return       Contact
    *****************************************************************************************************/    
    public static Contact getIndividualContact(String individualId){
        Contact individualContact;
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1'};
        if(String.isNotBlank(individualId)){
            conditionMap.put('IndividualId__c', individualId);
        }
        else{
            Map<String, String> userDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());
            String profileName = userDetails.containsKey('profileName') ? userDetails.get('profileName') : null;
            String userRole = userDetails.containsKey('userRole') ? userDetails.get('userRole') : null;
            if(String.isNotBlank(profileName) && (profileName.equalsIgnoreCase(SSP_GlobalConstants.RE_CITIZEN_PROFILE) || 
              (String.isNotBlank(userRole) && profileName.equalsIgnoreCase(SSP_GlobalConstants.NON_CITIZEN_PROFILE) && userRole.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE)))){
                conditionMap.put('Id', userDetails.get('contactId'));
            }
        }

        if(conditionMap.size() > 1){
            List<Contact> contactList = (List<Contact>)SSP_ContactSelector.queryContactData(
                    new Map<String, String>{'hasToLabel'=>'true','objectName'=>'Contact', 'operator'=>'AND'}, 
                    new Set<String>{'Id', 'FirstName', 'LastName', 'MiddleName', 'toLabel(SuffixCode__c) Suffix', 'SuffixCode__c', 'AccountId', 'IsDashboardRefreshNeeded__c', 'Last_RSSPDC_DateTime__c', 'Is_Eligible_For_RSSPDC__c', 'Name', 'IndividualId__c','DoesCaseExistForIndividual__c','CacheBenefitProgramData__c','CacheDashboardData__c','MemberType__c', 'CaseOwnership__c', 'CacheKIHIPPSummary__c'},  //#376149
                    conditionMap);
            if(contactList != null && !contactList.isEmpty()){ 
                individualContact = contactList[0];
            }
        }

        return individualContact;
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         05/18/2020
    * @methodname   getMemberId
    * @description  This methods is used to get memberId using contactId
    * @return       String
    *****************************************************************************************************/        
    public static String getMemberId(String contactId){
        String memberId;
        if(String.isNotBlank(contactId)){

            List<SSP_Member__c> lstMembers = getMemberDetails(new Map<String, String>{'Contact__c'=>  contactId});
            if(lstMembers != null && !lstMembers.isEmpty()){
                memberId = lstMembers[0].Id;
            }
        }
        return memberId;
    }  


    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         05/18/2020
    * @methodname   getMemberDetails
    * @description  This methods is used to get member details
    * @return       String
    *****************************************************************************************************/        
    public static List<SSP_Member__c> getMemberDetails(Map<String, String> conditionMap){
        String memberId;
        conditionMap.put('limit','1');
        return (List<SSP_Member__c>)SSP_MemberSelector.queryMemberData(new Map<String, String>{'hasToLabel'=>'true','objectName'=>'SSP_Member__c', 'operator'=>'AND'}, 
                                                                                                     new Set<String>{'Id', 'FirstName__c', 'LastName__c','MiddleInitial__c', 'toLabel(SuffixCode__c)'}, conditionMap);     
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         06/20/2020
    * @methodname   updateApplicationPrograms
    * @description  This methods is used to update application and applicationIndividual programs based on program access
    * @return       void
    *****************************************************************************************************/     
    public static void updateApplicationPrograms(String applicationId, SSP_ApplicationIndividual__c primaryAppIndv, String mode){ //#385177
        Set<String> accessiblePrograms =  new Set<String>();
        List<SSP_ApplicationIndividual__c> appIndvList = new List<SSP_ApplicationIndividual__c>();
        try{
            Boolean isReadOnlyUser = SSP_Utility.isReadOnlyUser(); //#379955
            Map<String, String> userDetails = SSP_Utility.getUserDetails(null);
            Set<String> availablePrograms = SSP_Utility.getAvailableProgramsByRole();         
            String filteredPrograms;            
            if(primaryAppIndv != null && String.isNotBlank(applicationId) && userDetails != null && !userDetails.isEmpty() && String.isNotBlank(userDetails.get('contactId')) && String.isNotBlank(userDetails.get('userRole'))){
                    
                String appAccountId = primaryAppIndv.SSP_Application__r.Account__c;
                String appProgramsApplied = primaryAppIndv.SSP_Application__r.ProgramsApplied__c;
                String appProgramsAppliedCopy = primaryAppIndv.SSP_Application__r.ProgramsAppliedCopy__c; //#379955
                filteredPrograms = availablePrograms != null && !availablePrograms.isEmpty() ? String.join(new List<String>(availablePrograms), ';') : null;                    

                //For AuthReps                
                if(SSP_GlobalConstants.AUTH_REP_ROLES.contains(userDetails.get('userRole'))){
                    List<AccountContactRelation> acrList = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                        new Set<String>{'Id', 'RepresentativeRelationshipCode__c','ProgramsApplied__c'}, 
                                                                        new Map<String, String>{'limit'=>'1','ContactId'=> userDetails.get('contactId'), 'AccountId' => appAccountId});

                    //Filter accessible programs based on access provided to authrep                                                                        
                    if(acrList != null && !acrList.isEmpty() && acrList[0] != null && String.isNotBlank(acrList[0].ProgramsApplied__c)){
                        filteredPrograms = SSP_Utility.filterPrograms(acrList[0].ProgramsApplied__c,  availablePrograms);                    
                    }
                }
                
                accessiblePrograms = String.isNotBlank(filteredPrograms) ? new Set<String>(filteredPrograms.split(';')) : new Set<String>();

                //Update programs on Application if there are any extra programs that current user doesn't have access to
                if((!isReadOnlyUser && String.isNotBlank(appProgramsAppliedCopy)) || isUpdateRequired(accessiblePrograms, String.isNotBlank(appProgramsApplied) ? appProgramsApplied.split(';') : new List<String>())){                    
                    //Filter common programs from application and filtered programs(i.e. programs that current user has access to) & update them on application 
                    SSP_Application__c applicationToUpdate = new SSP_Application__c(Id = applicationId);                   
                    /** #379955 */
                    if(isReadOnlyUser){
                        applicationToUpdate.ProgramsAppliedCopy__c = appProgramsApplied;
                    }
                    else if(String.isNotBlank(appProgramsAppliedCopy)){
                        applicationToUpdate.ProgramsApplied__c = appProgramsAppliedCopy;
                        appProgramsApplied = appProgramsAppliedCopy;
                        applicationToUpdate.ProgramsAppliedCopy__c = '';
                    }
                    /** */

                    String appPrograms = SSP_Utility.filterPrograms(filteredPrograms, new Set<String>(appProgramsApplied.split(';')));
                    applicationToUpdate.ProgramsApplied__c = appPrograms;                                       
                    if(Schema.sObjectType.SSP_Application__c.isUpdateable()){
                        update applicationToUpdate;
                    }
                }
                
                //Filter and update MemberProgramsApplied__c field on SSP_ApplicationIndividual__c
                for(SSP_ApplicationIndividual__c appIndv : SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                new Set<String>{'MemberProgramsApplied__c','MemberProgramsAppliedCopy__c'}, //#379955
                                new Map<String, String>{'limit'=>'100','SSP_Application__c'=>applicationId})){

                                    if(appIndv != null && String.isNotBlank(appIndv.MemberProgramsApplied__c) && ((!isReadOnlyUser && String.isNotBlank(appIndv.MemberProgramsAppliedCopy__c)) || isUpdateRequired(accessiblePrograms, appIndv.MemberProgramsApplied__c.split(';')))){ //#379955
                                        /** #379955 */
                                        if(isReadOnlyUser){
                                            appIndv.MemberProgramsAppliedCopy__c = appIndv.MemberProgramsApplied__c;
                                        }
                                        else if(String.isNotBlank(appIndv.MemberProgramsAppliedCopy__c)){
                                            appIndv.MemberProgramsApplied__c = appIndv.MemberProgramsAppliedCopy__c;
                                            appIndv.MemberProgramsAppliedCopy__c = '';
                                        }
                                        /** */                                        
                                        appIndv.MemberProgramsApplied__c = SSP_Utility.filterPrograms(filteredPrograms, new Set<String>(appIndv.MemberProgramsApplied__c.split(';')));
                                        appIndvList.add(appIndv);                
                                    }
                }

                if(!appIndvList.isEmpty() && Schema.sObjectType.SSP_ApplicationIndividual__c.isUpdateable()){                    
                    update appIndvList;
                }
            }

            if(String.isNotBlank(mode) &&  mode.equalsIgnoreCase(SSP_GlobalConstants.SSP_INTAKE_FLOW)){ //#385177
                copyNavflowStatus(applicationId); 
            } //#385177
        }
        catch(Exception ex){

        }
    }

    private static Boolean isUpdateRequired(Set<String> accessiblePrograms, List<String> programList){
        Boolean result = false;            
        for(String programCode : programList){
            if(!accessiblePrograms.contains(programCode)){
                result = true;
                break;
            }
        }
        return result;
    }

    /** #379955 */
    private static Boolean copyNavflowStatus(String applicationId){
        List<NavFlowStatus__c> flowStatList = new List<NavFlowStatus__c>();
        Boolean result = false;
        if(String.isNotBlank(applicationId)){
            Boolean isReadOnlyUser = SSP_Utility.isReadOnlyUser();
            for(NavFlowStatus__c pageStatus : SSP_NavFlowStatusSelector.queryFlowStatusByApplicationId(applicationId, new Set<String>{'Id','ScreenStatusCopy__c','Screen_Status__c','FlowDupStatus__c','FlowPageStatus__c','FlowDupStatusCopy__c','FlowPageStatusCopy__c'})){            
                if(isReadOnlyUser){
                    pageStatus.FlowDupStatusCopy__c = pageStatus.FlowDupStatus__c;
                    pageStatus.FlowPageStatusCopy__c = pageStatus.FlowDupStatus__c;
                    pageStatus.ScreenStatusCopy__c = pageStatus.Screen_Status__c;
                }
                else{
                    pageStatus.FlowDupStatus__c = String.isNotBlank(pageStatus.FlowDupStatusCopy__c) ? pageStatus.FlowDupStatusCopy__c : pageStatus.FlowDupStatus__c;
                    pageStatus.FlowPageStatus__c = String.isNotBlank(pageStatus.FlowPageStatusCopy__c) ? pageStatus.FlowPageStatusCopy__c : pageStatus.FlowPageStatus__c;
                    pageStatus.Screen_Status__c = String.isNotBlank(pageStatus.ScreenStatusCopy__c) ? pageStatus.ScreenStatusCopy__c : pageStatus.Screen_Status__c;
                    pageStatus.FlowDupStatusCopy__c = '';
                    pageStatus.FlowPageStatusCopy__c = '';
                    pageStatus.ScreenStatusCopy__c = '';
                }
                flowStatList.add(pageStatus);
            }
            if(flowStatList != null && !flowStatList.isEmpty()){
                //result = ESAPI.accessController().updateAsUser(new Map<Id, NavFlowStatus__c>(flowStatList), SSP_Utility.getFieldsNamesList (flowStatList)).wasSuccessful();    
                SSP_GenericDMLHelper.updateRecords(flowStatList, new List<String>{'FlowDupStatusCopy__c','FlowPageStatusCopy__c','ScreenStatusCopy__c','Screen_Status__c','FlowDupStatus__c','FlowPageStatus__c'});//Added for PErf fix - Keshav
                result = true;
            }
        }
        return result;
    }
}