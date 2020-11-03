/*
* classname     :  SSP_RoleSelectionTest
* @description  :  Test class for SSP_RoleSelection
* @author       :  Shrikant Raut   
* @date         :  05/26/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_RoleSelectionTest {
    @testSetup static void testSetUpData() {
		User nonCitizenUser = SSP_TestDataFactory.setUpNonCitizenUser();
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);        
        lstMem[0].contact__c = nonCitizenUser.ContactId;
        lstMem[0].IndividualId__c = '823968274';
        insert lstMem;
        
        Contact nonCitizenContact = new Contact(Id = nonCitizenUser.ContactId);
        nonCitizenContact.IndividualId__c = '823968274';
        update nonCitizenContact;
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'updateApplicationPrograms';
        insert lstAcc;
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = nonCitizenContact.Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = nonCitizenContact.Id;
        lstAppln[0].ProgramsApplied__c = 'MA;SN;CC;KP;KT;SS';
        lstAppln[0].ProgramsAppliedCopy__c = 'CC;KP;KT;SS';
        insert lstAppln;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].isHeadOfHouseHold__c = true;
        lstAppInd[0].memberStatus__c = SSP_GlobalConstants.MEMBER_STATUS_New;
        lstAppInd[0].MemberProgramsApplied__c = 'MA;SN;CC;KP;KT;SS';
        lstAppInd[0].MemberProgramsAppliedCopy__c = 'CC;KP;KT;SS';
        insert lstAppInd;
        
    }
    
    @isTest
    public static void updateApplicationPrograms_SSP_DashboardServiceTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 	
        Test.startTest();      
        List<SSP_Application__c> appList = [SELECT Id FROM SSP_Application__c LIMIT 1];
        NavFlowStatus__c navFlow = new NavFlowStatus__c();
        navFlow.Screen_Status__c = 'CCCCC';
        navFlow.FlowDupStatus__c = 'CCCCC';
        navFlow.FlowPageStatus__c =  'CCCCC';
        navFlow.ScreenStatusCopy__c = 'CCNCC';
        navFlow.FlowDupStatusCopy__c = 'CCNCC';
        navFlow.FlowPageStatusCopy__c =  'CCNCC';
        navFlow.SSPApplication__c = appList[0].Id;
        navFlow.NavFlowName__c = 'test';
        insert navFlow;
        System.runAs(nonCitizen){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE, SSP_GlobalConstants.ORGANISATION_AUTH_REP);
                        
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT SSP_Application__r.Account__c, SSP_Application__r.ProgramsApplied__c, SSP_Member__r.Contact__c, SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c,SSP_Application__r.ProgramsAppliedCopy__c,MemberProgramsAppliedCopy__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :appList[0].Id AND IsHeadOfHouseHold__c = true LIMIT 10];
            SSP_DashboardService.updateApplicationPrograms(appList[0].Id, appIndvList[0], SSP_GlobalConstants.SSP_INTAKE_FLOW); //#385177
            
            navFlow  = [SELECT Id, FlowDupStatusCopy__c, FlowPageStatusCopy__c, ScreenStatusCopy__c FROM NavFlowStatus__c WHERE SSPApplication__c = :appList[0].Id LIMIT 1][0];
            System.assert(String.isBlank(navFlow.FlowDupStatusCopy__c));
            System.assert(String.isBlank(navFlow.FlowDupStatusCopy__c));
            System.assert(String.isBlank(navFlow.FlowPageStatusCopy__c));
        }
        Test.stopTest();
    }
    
    @isTest
    public static void copyNavflowStatus_SSP_DashboardServiceTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 	
        Test.startTest();      
        List<SSP_Application__c> appList = [SELECT Id FROM SSP_Application__c LIMIT 1];
        NavFlowStatus__c navFlow = new NavFlowStatus__c();
        navFlow.Screen_Status__c = 'CCCCC';
        navFlow.FlowDupStatus__c = 'CCCCC';
        navFlow.FlowPageStatus__c =  'CCCCC';
        navFlow.SSPApplication__c = appList[0].Id;
        navFlow.NavFlowName__c = 'test';
        insert navFlow;
        System.runAs(nonCitizen){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE, 'PROD_Support_Read_Only');
            
           
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT SSP_Application__r.Account__c, SSP_Application__r.ProgramsApplied__c, SSP_Member__r.Contact__c, SSP_Member__r.Contact__r.Is_Eligible_For_RSSPDC__c,SSP_Application__r.ProgramsAppliedCopy__c,MemberProgramsAppliedCopy__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :appList[0].Id AND IsHeadOfHouseHold__c = true LIMIT 10];
			SSP_DashboardService.updateApplicationPrograms(appList[0].Id, appIndvList[0], SSP_GlobalConstants.SSP_INTAKE_FLOW); //#385177
            
            navFlow  = [SELECT Id, FlowDupStatusCopy__c, FlowPageStatusCopy__c, ScreenStatusCopy__c FROM NavFlowStatus__c WHERE SSPApplication__c = :appList[0].Id LIMIT 1][0];
            System.assert(String.isNotBlank(navFlow.FlowDupStatusCopy__c));
            System.assert(String.isNotBlank(navFlow.FlowPageStatusCopy__c));
            System.assert(String.isNotBlank(navFlow.ScreenStatusCopy__c));
        }
        Test.stopTest();
    }
    
    
    @isTest
    public static void getRequiredDetailsTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        SSPIntegrationEndpoints__c customSetting = new SSPIntegrationEndpoints__c();
        customSetting.Name = 'PE_URL_Redirect';
        customSetting.URL__c = 'url for waiver';
        insert customSetting;
        
        EncryptionDecryptionSettings__c encryptionSetting = new EncryptionDecryptionSettings__c();
        encryptionSetting.Name = 'SSPKey';
        encryptionSetting.Key__c = 'r5u8x!A%D*G-KaPdSgVkYp3s6v9y$B?E';
        insert encryptionSetting; 	 
        Test.startTest();      
        System.runAs(nonCitizen){
            SSP_LightningResponse response_New = SSP_RoleSelection.getRequiredDetails('gkm2TnwILNm2TTD1azbj0OQyFP7SzDqgYV9AtYo4F6jwkYzQerY4JLJW81mE1M0csbkD7QvEmsLhNAbnF0OP69Hh+72BhfV5ivELlaYYtHkQBrOeVTKufJjtcyM9ISklHITcaEecjpq2+T6HzDjoag==', null);
            SSP_LightningResponse response = SSP_RoleSelection.getRequiredDetails(null, '');
            System.assertEquals(true, response.bIsSuccess); 
            System.assertNotEquals(null, response.mapResponse.get('detailsWrap'));
            //System.assertEquals('Insurance_Agent', ((SSP_DashboardService.UserDetailsWrapper)response.mapResponse.get('detailsWrap')).selectedRole);
            System.assert(((SSP_DashboardService.UserDetailsWrapper)response.mapResponse.get('detailsWrap')).showCitizenDashboardLink);

            
            
        }
        Test.stopTest();
    }
    
    
    @isTest
    public static void updateRoleName_test(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 	 
        Test.startTest();      
        System.runAs(nonCitizen){
            Contact con = SSP_RoleSelection.updateRoleName('{"IndividualId":"222222222","CaseNumber":"123456789","SourceSystem":"SSP","UserId":null,"roleId":"5"}');        
            System.assertNotEquals(null, con);

            SSP_LightningResponse response = SSP_RoleSelection.impersonateCitizenOnLoad(JSON.serialize(con));
            System.assert(response.bIsSuccess);

            try{
                Contact con_New = SSP_RoleSelection.decrypt('gkm2TnwILNm2TTD1azbj0OQyFP7SzDqgYV9AtYo4F6jwkYzQerY4JLJW81mE1M0csbkD7QvEmsLhNAbnF0OP69Hh+72BhfV5ivELlaYYtHkQBrOeVTKufJjtcyM9ISklHITcaEecjpq2+T6HzDjoag==');
                system.assertNotEquals(null, con_New);
            }
            Catch(Exception ex){
                system.assertNotEquals(null, ex);
            }

            SSP_LightningResponse response_Negative = SSP_RoleSelection.impersonateCitizenOnLoad('1111');
            System.assert(!response_Negative.bIsSuccess);
        }
        Test.stopTest();
    }
    
    
    @isTest
    public static void constructDetailsWrapper_SSP_DashboardServiceTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0];
        SSPIntegrationEndpoints__c customSetting = new SSPIntegrationEndpoints__c();
        customSetting.Name = 'PE_URL_Redirect';
        customSetting.URL__c = 'url for waiver';
        insert customSetting; 	
        Test.startTest();      
        System.runAs(nonCitizen){            
            SSP_DashboardService.UserDetailsWrapper userDetailsWrapper = SSP_DashboardService.constructDetailsWrapper(UserInfo.getUserId(), true);
            
            System.assertNotEquals(null, userDetailsWrapper);
            System.assertEquals('DAIL_Worker', userDetailsWrapper.selectedRole);
            System.assert(userDetailsWrapper.showCitizenDashboardLink);
        }
        Test.stopTest();
    }
    

    
    @isTest
    public static void invokeFlowForPermissionSetTest_Negative(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 	
        Test.startTest();      
        System.runAs(nonCitizen){
            SSP_LightningResponse response = SSP_RoleSelection.invokeFlowForPermissionSet('ABC', new User(),true);
            System.assertEquals(false, response.bIsSuccess);             
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getMemberId_SSP_DashboardServiceTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 	
        Test.startTest();      
        System.runAs(nonCitizen){
            Contact con = SSP_DashboardService.getIndividualContact('823968274');            
            System.assertNotEquals(null, con);
            
            String memberId = SSP_DashboardService.getMemberId(con.Id);
            System.assertNotEquals(null, memberId);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void resetDashboardRefreshFlagTest(){ 
        User nonCitizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 	
        Test.startTest();      
        System.runAs(nonCitizen){
            SSP_RoleSelection.resetDashboardRefreshFlag();            
            Contact con = [SELECT Id, IsDashboardRefreshNeeded__c FROM Contact WHERE Id = :nonCitizen.ContactId LIMIT 1];
            System.assert(con.IsDashboardRefreshNeeded__c);
            
        }
        Test.stopTest();
    }
    
	  
}