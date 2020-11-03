/**
*@author       : Karthik Gulla
*@date         : 06/16/2020
*@description  : Test class for Tax Filing Functionality
*/  
@isTest
public class SSP_TaxFilingTest {
    @testSetup static void setup() {
        SSP_TestDataFactory.setupTestData();
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Id accRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');

        List<Account> lstAccounts = SSP_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].Name = 'TaxFilingTestAppAccount';
        lstAccounts[0].RecordTypeId = accRecordTypeId;
        lstAccounts = ESAPI.accessController().insertAsUser(lstAccounts, SSP_Utility.getFieldsNamesList (lstAccounts)).getInsertedObjects();
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenOne', 'User', 'citizenone@abc.xyz', contactRecordTypeId, false));
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenTwo', 'User', 'citizentwo@abc.xyz', contactRecordTypeId, false));
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenTww', 'User', 'citizentww@abc.xyz', contactRecordTypeId, false));
        insert lstContacts;

        AccountContactRelation acrObjectMemberOne = new AccountContactRelation(); 
        acrObjectMemberOne.Accountid = lstAccounts[0].Id;
        acrObjectMemberOne.Contactid = fetchCitizenUser().ContactId;
        acrObjectMemberOne.IsActive = true;

        List<AccountContactRelation> lstACRRecords = new List<AccountContactRelation>();
        lstACRRecords.add(acrObjectMemberOne);

        ESAPI.accessController().insertAsUser(lstACRRecords, SSP_Utility.getFieldsNamesList (lstACRRecords));       
        
        List<SSP_Application__c> lstApplications = SSP_TestDataFactory.createSSPApplications(1, false);
        lstApplications[0].Account__c=lstAccounts[0].Id;
        lstApplications[0].ProgramsApplied__c = 'SN;KT;MA;SS';
        lstApplications= ESAPI.accessController().insertAsUser(lstApplications, SSP_Utility.getFieldsNamesList (lstApplications)).getInsertedObjects();
        
        List<SSP_Member__c> lstMembers = SSP_TestDataFactory.createSSPMembers(3, false);
        lstMembers[0].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[0].FirstName__c=lstContacts[0].FirstName;
        lstMembers[0].LastName__c=lstContacts[0].LastName;     
        lstMembers[0].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[0].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[0].IndividualId__c = '676976979';
        lstMembers[1].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[1].FirstName__c=lstContacts[1].FirstName;
        lstMembers[1].LastName__c=lstContacts[1].LastName;     
        lstMembers[1].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[1].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[1].IndividualId__c = '676976978';
        lstMembers[2].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[2].FirstName__c=lstContacts[2].FirstName;
        lstMembers[2].LastName__c=lstContacts[2].LastName;     
        lstMembers[2].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[2].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[2].IndividualId__c = '676976977';
        lstMembers = ESAPI.accessController().insertAsUser(lstMembers, SSP_Utility.getFieldsNamesList (lstMembers)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_TestDataFactory.createApplicationIndividuals(3, false); 
        lstAppIndividuals[0].SSP_Application__c=lstApplications[0].Id;
        lstAppIndividuals[0].SSP_Member__c=lstMembers[0].Id;
        lstAppIndividuals[0].IsHeadOfHousehold__c=true;
        lstAppIndividuals[0].DCPrograms__c = lstAppIndividuals[0].ProgramsApplied__c;
        lstAppIndividuals[1].SSP_Application__c=lstApplications[0].Id;
        lstAppIndividuals[1].SSP_Member__c=lstMembers[1].Id;
        lstAppIndividuals[1].IsHeadOfHousehold__c=false;
        lstAppIndividuals[1].DCPrograms__c = lstAppIndividuals[1].ProgramsApplied__c;
        lstAppIndividuals[2].SSP_Application__c=lstApplications[0].Id;
        lstAppIndividuals[2].SSP_Member__c=lstMembers[2].Id;
        lstAppIndividuals[2].IsHeadOfHousehold__c=false;
        lstAppIndividuals[2].DCPrograms__c = lstAppIndividuals[2].ProgramsApplied__c;
        lstAppIndividuals = ESAPI.accessController().insertAsUser(lstAppIndividuals, SSP_Utility.getFieldsNamesList (lstAppIndividuals)).getInsertedObjects();
        
        List<SSP_Relationship__c> lstRelationships = new List<SSP_Relationship__c>();
        SSP_Relationship__c sspRelationshipOne = new SSP_Relationship__c();
        sspRelationshipOne.SSP_Member__c = lstMembers[0].Id;
        sspRelationshipOne.SSP_MemberRelatedTo__c = lstMembers[1].Id;
        sspRelationshipOne.RelationshipType__c = 'SP';

        SSP_Relationship__c sspRelationshipTwo = new SSP_Relationship__c();
        sspRelationshipTwo.SSP_Member__c = lstMembers[1].Id;
        sspRelationshipTwo.SSP_MemberRelatedTo__c = lstMembers[0].Id;
        sspRelationshipTwo.RelationshipType__c = 'SP';

        SSP_Relationship__c sspRelationshipThree = new SSP_Relationship__c();
        sspRelationshipThree.SSP_Member__c = lstMembers[2].Id;
        sspRelationshipThree.SSP_MemberRelatedTo__c = lstMembers[0].Id;
        sspRelationshipThree.RelationshipType__c = 'SO';

        lstRelationships.add(sspRelationshipOne);
        lstRelationships.add(sspRelationshipTwo);
        lstRelationships.add(sspRelationshipThree);
        insert lstRelationships;

        insert new LOG_LogMessageSettings__c(
            Name = RE_GlobalConstants.LOGS_DEFAULT_AUTOGENERATED,
            LOG_Debug__c = true,
            LOG_Error__c= true,
            LOG_Info__c = true,
            LOG_Warning__c = true,
            LOG_Log_Purge__c = 365
        );

        SSPTaxFilingConfigurations__c sspTaxFilingConfig = new SSPTaxFilingConfigurations__c();
        sspTaxFilingConfig.Name = 'SSPTFC001';
        sspTaxFilingConfig.CurrentYear__c = String.valueOf(SSP_Utility.today().year());
        sspTaxFilingConfig.Enrollment_EndDate__c = SSP_Utility.today().addDays(10);
        sspTaxFilingConfig.Enrollment_StartDate__c = SSP_Utility.today().addDays(-10);
        sspTaxFilingConfig.OpenEnrollmentYear__c = String.valueOf(SSP_Utility.today().year() + 1);
        insert sspTaxFilingConfig;
    }

    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id','ContactId'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }

    @isTest
    public static void testTaxFilingQueueRule(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id LIMIT 1];
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = [SELECT Id, ProgramsApplied__c, MedicaidType__c, SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> lstNewAppIndividuals = [SELECT Id, MedicaidType__c, SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];

        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = lstMembers[0].Id;
        ctxData.ApplicationId = lstApplications[0].Id;
        
        for(SSP_ApplicationIndividual__c sspAppIndividual:lstAppIndividuals){
            memberAppIndividualMap.put(sspAppIndividual.SSP_Member__c, sspAppIndividual);
        }

        QueuingWrapper qWrapper = new QueuingWrapper();
        qWrapper.memberAppIndividualMap = memberAppIndividualMap;
        ctxData.queueobject = qWrapper;
        System.runAs(fetchCitizenUser()){
            SSP_TaxFilingScreenQueueRule sspTaxFilingRule = new SSP_TaxFilingScreenQueueRule();
            Boolean bRequired = sspTaxFilingRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, true);
        }  

        memberAppIndividualMap.clear();
        for(SSP_ApplicationIndividual__c sspAppIndividual:lstNewAppIndividuals){
            memberAppIndividualMap.put(sspAppIndividual.SSP_Member__c, sspAppIndividual);
        }
        qWrapper.memberAppIndividualMap = memberAppIndividualMap; 
        System.runAs(fetchCitizenUser()){
            SSP_TaxFilingScreenQueueRule sspTaxFilingRule = new SSP_TaxFilingScreenQueueRule();
            Boolean bRequired = sspTaxFilingRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, false);
        }   

        qWrapper.memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>(); 
        System.runAs(fetchCitizenUser()){
            SSP_TaxFilingScreenQueueRule sspTaxFilingRule = new SSP_TaxFilingScreenQueueRule();
            Boolean bRequired = sspTaxFilingRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, false);
        }
    }

    @isTest
    public static void testTMemberCallAndResponse() {
        User citizenUser = fetchCitizenUser();
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c LIMIT 1];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id];      
        Map<String,String> mapUserInputs = new Map<String,String>();
        mapUserInputs.put('applicationId', lstApplications[0].Id);
        mapUserInputs.put('memberId', lstMembers[0].Id);

        List<NavFlowStatus__c> lstNavFlowStatus = new List<NavFlowStatus__c>();
        NavFlowStatus__c navFlowStatsOne = new NavFlowStatus__c();
        navFlowStatsOne.NavFlowName__c = SSP_GlobalConstants.RELATIONSHIPSANDTAXFILINGFLOWNAME;
        navFlowStatsOne.SSPApplication__c = lstApplications[0].Id;
        navFlowStatsOne.Member__c = lstMembers[0].Id;
        navFlowStatsOne.FlowDupStatus__c = 'CCC';
        navFlowStatsOne.FlowPageStatus__c = 'CCC';
        lstNavFlowStatus.add(navFlowStatsOne);

        NavFlowStatus__c navFlowStatsTwo = new NavFlowStatus__c();
        navFlowStatsTwo.NavFlowName__c = SSP_GlobalConstants.RELATIONSHIPSANDTAXFILINGFLOWNAME;
        navFlowStatsTwo.SSPApplication__c = lstApplications[0].Id;
        navFlowStatsTwo.Member__c = lstMembers[1].Id;
        navFlowStatsTwo.FlowDupStatus__c = 'CCC';
        navFlowStatsTwo.FlowPageStatus__c = 'CCC';
        lstNavFlowStatus.add(navFlowStatsTwo);

        NavFlowStatus__c navFlowStatsThree = new NavFlowStatus__c();
        navFlowStatsThree.NavFlowName__c = SSP_GlobalConstants.RELATIONSHIPSANDTAXFILINGFLOWNAME;
        navFlowStatsThree.SSPApplication__c = lstApplications[0].Id;
        navFlowStatsThree.Member__c = lstMembers[2].Id;
        navFlowStatsThree.FlowDupStatus__c = 'CCC';
        navFlowStatsThree.FlowPageStatus__c = 'CCC';

        lstNavFlowStatus.add(navFlowStatsThree);
        ESAPI.accessController().insertAsUser(lstNavFlowStatus, SSP_Utility.getFieldsNamesList (lstNavFlowStatus)); 
        
        System.runAs(citizenUser){ 
            Test.setMock(WebServiceMock.class, new SSP_TaxFilingTMemberMockCalloutClass());
            Test.startTest();  
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.checkToInvokeTMemberCall(mapUserInputs);
            Test.stopTest();
        }
    }

    @isTest
    public static void testTaxFilingDetailsController(){
        User citizenUser = fetchCitizenUser();
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c LIMIT 1];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id];
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = [SELECT Id, ProgramsApplied__c, MedicaidType__c, SSP_Member__c, IsTMember__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];
        Map<String,String> mapUserInputs = new Map<String,String>();
        mapUserInputs.put('applicationId', lstApplications[0].Id);
        mapUserInputs.put('memberId', lstMembers[0].Id);

        System.runAs(citizenUser){
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.getTaxFilingDetailsForMember(mapUserInputs);
        }

        mapUserInputs.put('applicationId', '9700267374');
        System.runAs(citizenUser){
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.getTaxFilingDetailsForMember(mapUserInputs);
        }

        System.runAs(citizenUser){
            SSP_TaxFilingDetailsController.invokeReviewRequiredChangeToMember(lstAppIndividuals,lstApplications[0].Id, lstMembers[0].Id, 'RAC');
        }
        
        String strSIJSON = '{"TaxFilerStatusCurrentYear__c":"SI","taxFilingDetailsClaimingDependentCurrentYear":"N","TaxFilerStatusNextYear__c":"SI","taxFilingDetailsClaimingDependentNextYear":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'","TaxFilingClaimingCurrent__c":"N","TaxFilerMemberCurrent__c":null,"TaxFilingClaimingNext__c":"N","TaxFilerMemberNext__c":null}';
        System.runAs(citizenUser){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strSIJSON);
        }

        String strSIJSONOne = '{"TaxFilerStatusCurrentYear__c":"SI","taxFilingDetailsClaimingDependentCurrentYear":"N","TaxFilerStatusNextYear__c":"SI","taxFilingDetailsClaimingDependentNextYear":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'","TaxFilingClaimingCurrent__c":"Y","TaxFilerMemberCurrent__c":["'+lstMembers[2].Id+'"],"TaxFilerMemberNext__c":["'+lstMembers[2].Id+'"],"TaxFilingClaimingNext__c":"Y"}';
        System.runAs(citizenUser){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strSIJSONOne);
        }

        String strSIJSONTwo = '{"TaxFilerStatusCurrentYear__c":"SI","taxFilingDetailsClaimingDependentCurrentYear":"N","TaxFilerStatusNextYear__c":"SI","taxFilingDetailsClaimingDependentNextYear":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'","TaxFilingClaimingCurrent__c":"N","TaxFilerMemberCurrent__c": null,"TaxFilerMemberNext__c": null,"TaxFilingClaimingNext__c":"N"}';
        System.runAs(citizenUser){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strSIJSONTwo);
        }

        String strDMJSON = '{"TaxFilerStatusCurrentYear__c":"DM","taxFilingDetailsClaimingDependentCurrentYear":"N","TaxFilerStatusNextYear__c":"DM","taxFilingDetailsClaimingDependentNextYear":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'","TaxFilingClaimingCurrent__c":"N","TaxFilerMemberCurrent__c":"'+lstMembers[1].Id+'","TaxFilingClaimingNext__c":"N","TaxFilerMemberNext__c":"'+lstMembers[1].Id+'"}';
        System.runAs(citizenUser){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strDMJSON);
        }
        
        Test.startTest();
        String strDNJSON = '{"TaxFilerStatusCurrentYear__c":"DN","HasParentOrSiblingCurrentOutHousehold__c":"N","TaxFilerStatusNextYear__c":"DN","HasParentOrSiblingNextOutHousehold__c":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'"}';
        System.runAs(citizenUser){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strDNJSON);
        }

        String strFJJSON = '{"TaxFilerStatusCurrentYear__c":"FJ","taxFilingDetailsClaimingDependentCurrentYear":"N","TaxFilerStatusNextYear__c":"FJ","taxFilingDetailsClaimingDependentNextYear":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'","TaxFilingClaimingCurrent__c":"Y","TaxFilerMemberCurrent__c":["'+lstMembers[2].Id+'"],"TaxFilerMemberNext__c":["'+lstMembers[2].Id+'"],"TaxFilingClaimingNext__c":"Y"}';
        System.runAs(citizenUser){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strFJJSON);
        }

        
        String strFJJSONOne = '{"TaxFilerStatusCurrentYear__c":"FJ","taxFilingDetailsClaimingDependentCurrentYear":"N","TaxFilerStatusNextYear__c":"FJ","taxFilingDetailsClaimingDependentNextYear":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'","TaxFilingClaimingCurrent__c":"N","TaxFilerMemberCurrent__c": null,"TaxFilerMemberNext__c": null,"TaxFilingClaimingNext__c":"N"}';
        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strFJJSONOne);
        }

        String strNAJSON = '{"TaxFilerStatusCurrentYear__c":"NA","previousTaxFilingStatus":"FJ","HasParentOrSiblingCurrentOutHousehold__c":"N","TaxFilerStatusNextYear__c":"NA","HasParentOrSiblingNextOutHousehold__c":"N","memberId":"'+lstMembers[0].Id+'","applicationId":"'+lstApplications[0].Id+'"}';
        System.runAs(citizenUser){ 
            SSP_LightningResponse clsResponse = SSP_TaxFilingDetailsController.updateTaxFilingDetails(strNAJSON);
        }

        System.runAs(citizenUser){ 
            SSP_TaxFilingDetailsController.getCurrentApplicationMemberIds('374834334');
        }
        Test.stopTest();
    }

    @isTest
    public static void testTaxFilingDetailsService(){
        Set<Id> setMemberIds = null;
        System.runAs(fetchCitizenUser()){ 
            SSP_TaxFilingDetailsService.getDependentTaxFilingDetailsCurrentYearFromMember(setMemberIds,'mem23545');
            SSP_TaxFilingDetailsService.getDependentTaxFilingDetailsNextYearFromMember(setMemberIds,'mem23545');            
        }

        System.runAs(fetchCitizenUser()){ 
            SSP_TaxFilingDetailsService.getRelationshipsForApplicationMembers(setMemberIds);
            SSP_TaxFilingDetailsService.getApplicationDetailsForTaxFiling(setMemberIds);            
        }
    }
}