/*
* classname     :  SSP_UtilityTest
* @description  :  test class to hold all utility methods for SSP
* @author       :  Nam Saxena 
* @date         :  09/03/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
@isTest(seeAllData=false)
public class SSP_UtilityTest {
	@TestSetup static void setup() { 
    	SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'NonCitizenUser';
        insert lstAcc;
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        lstCon[0].IndividualId__c='999033797';
        lstCon[0].DoesCaseExistForIndividual__c=true;
        update lstCon;
        
        contact_Mapping__c objConMap = new contact_Mapping__c();
        objConMap.IEES_Id__c=999033797;
        objConMap.Contact__c=lstCon[0].Id;
        insert objConMap;

        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].DCCaseNumber__c=123;
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].IndividualId__c='999033797';
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].ProgramsApplied__c='MA';
        lstAppInd[0].MemberProgramsApplied__c='MA';
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
        
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    /*@isTest
    static void testQueryPicklists()
    {
        String result = SSP_Utility.getDependentPicklistValues('BlindnessBenefitTypeCode__c');
        System.assertEquals(null, result);
    }*/
    
    @isTest
    static void testdatechecker()
    {
        Integer result = SSP_Utility.monthNow();
        System.assertNotEquals(null, result);
        
        result = SSP_Utility.nextMonthToday();
        System.assertNotEquals(null, result);
        
        result = SSP_Utility.nextMonthNow();
        System.assertNotEquals(null, result);
        
        result = SSP_Utility.monthToday();
        System.assertNotEquals(null, result);
        
        result = SSP_Utility.previousMonthToday();
        System.assertNotEquals(null, result);
        
        result = SSP_Utility.previousMonthNow();
        System.assertNotEquals(null, result);
        
        Date dt = system.today().addDays(10);
        result = SSP_Utility.monthsBetweenDates(dt);
        System.assertNotEquals(null, result);
        
        
    }

    @isTest
    static void testDataProcessedCheck(){
        Map<String,String> mapresult = SSP_Utility.isDataProcessed('C29300','MHCAC','mode');
        System.assertNotEquals(null, mapresult); 
        
        Map<String,String> mapresult1 = SSP_Utility.isDataProcessed('C29300','MHCAC','Intake');
        System.assertNotEquals(null, mapresult1);
        //get a valid screen name for 'ReverseSSPViewMapping__mdt' for additional coverage
        
        SSP_LightningResponse result = SSP_Utility.downloadWrittenStatement('MCP_Comparison_Chart');
        System.assertNotEquals(null, result);
        
        List<String> lstfieldnames = new List<String>();
        lstfieldnames.add('Name');
        lstfieldnames.add('CaseNumber__c');
        String strResult = SSP_Utility.getFields(lstfieldnames, 'Account');
        System.assertNotEquals(null, result);
        
        /*String strRsult = SSP_Utility.getDependentPicklistValues('Account\\.CountyServed__c');
        System.assertNotEquals(null, strRsult);*/
    }
    
   @isTest
    static void testAccessCheck(){
        Schema.sObjectType t = Account.sObjectType;
        
       Boolean boolresult = SSP_Utility.isAllowedToUpdate(t);
        System.assertNotEquals(null, boolresult);
        
        try{
            User u = [select id from user where usertype='Guest' limit 1];
            system.runAs(u){
            SSP_Utility.isAuthenticatedUser();
            
        }
        }
        catch (Exception e){
            //R20.09 - 10/2/2020 - Commented below line since all the communities are deactivated during PROD deployments
            //system.assert(e.getMessage().contains('You are not authenticated to access the system'));
        }
        
    }

    @isTest
    static void testDataCheck(){
        /*insert new LOG_LogMessageSettings__c(
            Name = RE_GlobalConstants.LOGS_DEFAULT_AUTOGENERATED,
            LOG_Debug__c = true,
            LOG_Error__c= true,
            LOG_Info__c = true,
            LOG_Warning__c = true,
            LOG_Log_Purge__c = 365
        );*/
        Id sCitizenAccRecTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Id sNonCitizenAccRecTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Non_Citizen');
        contact con1 = SSP_TestDataFactory.createContactRecord('Test', 'Test', 'test@tester.com', sCitizenAccRecTypeId, true);
        con1.IndividualId__c = '12121212';
        update con1;
        contact con2 = SSP_TestDataFactory.createContactRecord('Test1', 'Test1', 'test1@tester.com', sNonCitizenAccRecTypeId, true);
         String accRtypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SSP_GlobalConstants.ORGANIZATION).getRecordTypeId();
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'SSP_AuthRepAccessRequestCtrl';
        lstAcc[0].recordtypeId = accRtypeId1;
        lstAcc[0].DCDataId__c = 7777777;
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        //List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = con1.Id;
        acr.IsActive = true;
        acr.Roles = 'Organization_Auth_Rep';
        acr.DCContactId__c = 7777777;
        acr.RequestAccessPermission__c = '{"PermissionLevel_CCAP__c": "PY",   "PermissionLevel_KTAP__c": "ET",   "PermissionLevel_SNAP__c": "SE",   "PermissionLevel_KIHIPP__c": "ST",   "PermissionLevel_Medicaid__c": "NT" }';
        acr.ProgramsApplied__c = 'MA; KT; SN; SS; DS; CC; KP';
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        
        List<SSP_Member__c> lstSSPMembers = SSP_TestDataFactory.createSSPMembers(2,false);
        lstSSPMembers[0].Contact__c = con1.Id;
        lstSSPMembers[0].IndividualId__c = '12121212';
        lstSSPMembers[1].Contact__c = con2.Id;
        insert lstSSPMembers;
        contact_Mapping__c conmap = new contact_Mapping__c(Contact__c = con1.Id,IEES_Id__c = 12121212);
        insert conmap;
        /*String toDoRecTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('To Do').getRecordTypeId();
        SSP_Notifications__c notifRec4 = new SSP_Notifications__c();
            notifRec4.recordtypeid = toDoRecTypeId;
            notifRec4.recipientType__c = SSP_GlobalConstants.NOTIFICATION_CITIZEN;
            notifRec4.recipientId__c = '786756753';
            notifRec4.Status__c = SSP_GlobalConstants.NOTIFICATION_ACTIVE;
            notifRec4.notificationCode__c = 'SF-TOD-001';
            notifRec4.Reminder_Date__c = Date.today();
            notifRec4.Linked_Record_Id__c = String.valueOf(acr.Id);
            insert notifRec4; */
         List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = con2.Id;
        lstAppln[0].DCCaseNumber__c = 100375363;
        lstAppln[0].ProgramsApplied__c = 'MA; KT; SN; SS; DS; CC; KP';
        lstAppln[0].RAC_Selections__c = 'test string';
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        List<SSP_ApplicationIndividual__c> lstappInd = SSP_TestDataFactory.createApplicationIndividuals(2,false);
        lstappInd[0].SSP_Application__c = lstAppln[0].Id;
        lstappInd[1].SSP_Application__c = lstAppln[0].Id;
        lstappInd[0].SSP_Member__c = lstSSPMembers[0].Id;
        lstappInd[1].SSP_Member__c = lstSSPMembers[1].Id;
        insert lstappInd;
        
        SSP_LightningResponse result = SSP_Utility.getApplicationDetails(lstAppln[0].Id);
        System.assertNotEquals(null, result);
        
        Set<String> setResult = SSP_Utility.getRACSelectedMembers(lstAppln[0].Id);
        System.assertNotEquals(null, setResult);
        
        SSP_LightningResponse result1 = SSP_Utility.retryRSSPDCTransaction(lstAppln[0].Id, 'mode');
        System.assertNotEquals(null, result1);
        
        String result2 = SSP_Utility.getMemberId(con1.IndividualId__c);
        System.assertNotEquals(null, result2);
        
        List<SSP_ApplicationIndividual__c> lstresult = SSP_Utility.filterApplicationIndividualsForRAC(lstappInd,lstAppln[0].Id);
        System.assertNotEquals(null, lstresult);
        
        Set<String> setStr = new Set<String>();
        setStr.add('BP');
        setStr.add('WR');
        String strresult = SSP_Utility.filterPrograms('MA', setStr);
        System.assertNotEquals(null, strresult);
    }
    
    
    @isTest
    static void testgetKOGRoleFromSF(){
        
       // String getKOGRoleFromSF = SSP_Utility.getKOGRoleFromSF('Contact_Center_View_and_Edit');
        Boolean isReadOnlyUser = SSP_Utility.isReadOnlyUser();
        Map<String,SSP_PicklistConversion_Configurations__mdt> getPicklistConversionMappings = SSP_Utility.getPicklistConversionMappings('BC', 'Income', 'SE');
    	//String formatAddress = SSP_Utility.formatAddress('test', 'test line2', 'Pune', 'Samoa Americana', 'California', '12345', '43215', 'Samoa Americana');
    	 Map<String, String> getScreenViewMapping = SSP_Utility.getScreenViewMapping();
         Id getCurrentUserMemberId = SSP_Utility.getCurrentUserMemberId(True);
        List<string> listRelatedList =new list<string>();
        listRelatedList.add('PhysicalAddressLine1__c');
        listRelatedList.add('MailingAddressLine1__c');
        //listRelatedList.add('PhysicalAddressLine2__c');
        Schema.sObjectType sspMember = SSP_Member__c.sObjectType;
         String checkRelationshipFields = SSP_Utility.checkRelationshipFields(listRelatedList, sspMember);
        
        /*List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'EnrollmentDetail';
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem[0].HasReceivedBenefitsFromOtherStateToggle__c='Y';
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        SSP_Benefits__c sspBenefits = new SSP_Benefits__c();
        sspBenefits.SSP_Member__c = lstMem[0].Id;
        sspBenefits.Name = 'Benefit Name';
        sspBenefits.BenefitInfoCounty__c = '1';
        sspBenefits.State__c = 'AL';
        sspBenefits.BenefitPrograms__c = 'MA';
        sspBenefits.BeginDate__c = System.today();
        sspBenefits.EndDate__c = NULL;
        insert sspBenefits;*/

        Map<String, String> mapQueryParameters = new Map<String, String>();
        mapQueryParameters.put(SSP_GlobalConstants.sWhereClauseKey, SSP_GlobalConstants.sBenefitFieldsWhereClause);
        String sBenefitFields = 'ID,BenefitStateCountyKey__c,BenefitPrograms__c,State__c,BenefitInfoCounty__c,BeginDate__c,EndDate__c,SSP_Member__c';
        String getsQueryonFields = SSP_Utility.getsQueryonFields('SSP_Benefits__c', sBenefitFields, mapQueryParameters);
		Set<String> setFields = new Set<String>();
        setFields.add('PhysicalAddressLine1__c');
        setFields.add('MailingAddressLine1__c');
        
        List<String> getFieldsForAuthorisedView = SSP_Utility.getFieldsForAuthorisedView('SSP_Member__c', setFields);
        String getDependentPicklistValues = SSP_Utility.getDependentPicklistValues('SSP_Member__c.PhysicalCountyCode__c');
   
    }
	
    @isTest
    static void testUtilitytMethod1() {
        EncryptionDecryptionSettings__c objEncry = new EncryptionDecryptionSettings__c();
        objEncry.Name='SSPKey';
        objEncry.key__c='r5u8x!A%D*G-KaPdSgVkYp3s6v9y$B?E';
        insert objEncry;
        
        System.runAs(fetchCitizenUser()) {
            SSP_Transaction__c objTran = new SSP_Transaction__c();
        	objTran.Unique_Id__c = 'C29300;RelationshipInformation';
			insert objTran;
            
            List<SSP_ApplicationIndividual__c> lstAppInd = [select Id,ProgramsApplied__c,MemberProgramsApplied__c,SSP_Application__c,SSP_Member__c from SSP_ApplicationIndividual__c limit 1];
            User objUser= fetchCitizenUser();
            objUser.ApplicableRoles__c='Citizen_Individual';
            update objUser;
            
            Test.startTest();
            SSP_LightningResponse response = new SSP_LightningResponse();
            response=SSP_Utility.constructSecurityWrap(response, new Map<String, String>{'securityMatrixSummary'=>SSP_GlobalConstants.HH_ABSENTP_SUMMARY_SCREENID, 'securityMatrixDetails'=>SSP_GlobalConstants.HH_ABSENTP_DETAILS_SCREENID});
            String role=SSP_Utility.getKOGRoleFromSF('Assister');
            String sMemberVal=SSP_Utility.getRequiredAddressFieldValue('member','federal');
            String sMemberVal2=SSP_Utility.getRequiredAddressFieldValue('member',null);
            Map<String,String> mapPicklist=SSP_Utility.getPicklistFromLabel('a:b;x:y');
            String sMemberId=SSP_Utility.getMemberId('999033797');
            Map<Decimal,String> mapMemberId=SSP_Utility.getMemberIds(new List<Integer>{999033797});
            
            Cache.SessionPartition sessionpart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            sessionpart.put('individualId','999033797',3600,Cache.Visibility.ALL,false);
            String sIndId = SSP_Utility.getCurrentUserAllIndividualIds();
            
            Boolean bTrue=SSP_Utility.checkApplicablePrograms(new List<String>{'MA'},new Set<String>{'MA'});
            SSP_Utility.setProgramPermissions();
            RecordType ovjRecType=SSP_Utility.fetchRecordType('Case','SSP_Application__c');
            
            Map<String, Schema.SObjectType> sObjectdescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType targetsobjectType = sObjectdescribeMap.get(String.escapeSingleQuotes('SSP_Member__c'));
            String sRelFields = SSP_Utility.checkRelationshipFields(new List<String>{'Contact__r.FirstName','Contact__r.LastName'},targetsobjectType);
            
            Map<String,String> mapPick = SSP_Utility.getPickListValues('SSP_ApplicationIndividual__c','ProgramsApplied__c','MA');
            Map<String,String> mapPick1 = SSP_Utility.getPickListValue('SSP_ApplicationIndividual__c','ProgramsApplied__c','MA');
            set<String> setField=SSP_Utility.getFieldsforESAPI(new set<String>{'toLabel(MemberProgramsApplied__c)'});
            
            Map<String, String> mapQueryParameters = new Map<String, String>();
            mapQueryParameters.put(SSP_GlobalConstants.sWhereClauseKey, SSP_GlobalConstants.sBenefitFieldsWhereClause);
            mapQueryParameters.put(SSP_GlobalConstants.sOrderByKey,'BenefitPrograms__c');
            mapQueryParameters.put(SSP_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(SSP_GlobalConstants.sOffset, '1');
            String sBenefitFields = 'ID,BenefitStateCountyKey__c,BenefitPrograms__c,State__c,BenefitInfoCounty__c,BeginDate__c,EndDate__c,SSP_Member__r.FirsName__c';
            String getsQueryonFields = SSP_Utility.getsQueryonFields('SSP_Benefits__c', sBenefitFields, mapQueryParameters);
            
            Id memId=SSP_Utility.getCurrentUserMemberId(true);
            
            Map<String,String> mapresult1 = SSP_Utility.isDataProcessed('C29300','SSP_APP_RTF_Relationships','Intake');
            
            Map<String, String> mapCase = new Map<String, String>();
            mapCase.put('123','999033797');
            sessionpart.put('caseVsIndividualId',mapCase,3600,Cache.Visibility.ALL,false);
            SSP_LightningResponse resp = new SSP_LightningResponse();
            resp=SSP_Utility.retryRSSPDCTransaction(lstAppInd[0].SSP_Application__c,'RAC');
                
            //metadata
            SSP_LightningResponse response1 = new SSP_LightningResponse();
            response1=SSP_Utility.validateSSORedirect('PE_BCCTP');
            response1=SSP_Utility.validateSSORedirect('TAX_FORMS');
            String sSSPPortal=SSP_Utility.getSSPPortalConfigurations('DCBSOfficePhone');
            Test.stopTest();
        }
    }
    @isTest
    static void testUtilitytMethod2() {
        EncryptionDecryptionSettings__c objEncry = new EncryptionDecryptionSettings__c();
        objEncry.Name='SSPKey';
        objEncry.key__c='abc';
        insert objEncry;
        System.runAs(fetchCitizenUser()) {
            SSP_LightningResponse response1 = new SSP_LightningResponse();
            response1=SSP_Utility.validateSSORedirect('PE_BCCTP');
        }
    }
}