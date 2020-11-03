/*
* classname 	: SSP_AnotherStateBenefitsCtrlTest
* @description 	: Test class for SSP_AnotherStateBenefitsCtrl
* @author 		: Sai Kiran
* @date 		: 12/06/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Sai Kiran 		12/06/2019		Initial Version
*/
@isTest
public class SSP_AnotherStateBenefitsCtrlTest {
    
    @testSetup static void testSetUpData() {
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'EnrollmentDetail';
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem[0].HasReceivedBenefitsFromOtherStateToggle__c='Y';
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        SSP_Benefits__c sspBenefits = new SSP_Benefits__c();
        sspBenefits.SSP_Member__c = lstMem[0].Id;
        sspBenefits.Name = 'Benefit Name';
        sspBenefits.BenefitInfoCounty__c = '1';
        sspBenefits.State__c = 'AL';
        sspBenefits.BenefitPrograms__c = 'MA';
        sspBenefits.BeginDate__c = System.today();
        sspBenefits.EndDate__c = NULL;
        lstBenefits.add(sspBenefits);
        //1st Set of Data----->
        SSP_Benefits__c sspBenefits1 = new SSP_Benefits__c();
        sspBenefits1.SSP_Member__c = lstMem[0].Id;
        sspBenefits1.Name = 'Benefit Name';
        sspBenefits1.State__c = 'AL';
        sspBenefits1.BenefitStateCountyKey__c = '123qwe456q';
        sspBenefits1.BenefitPrograms__c = 'TN';
        sspBenefits1.BeginDate__c = System.today();
        sspBenefits1.EndDate__c = NULL;
        lstBenefits.add(sspBenefits1);
        
        SSP_Benefits__c sspBenefits11 = new SSP_Benefits__c();
        sspBenefits11.SSP_Member__c = lstMem[0].Id;
        sspBenefits11.Name = 'Benefit Name';
        sspBenefits11.BenefitInfoCounty__c = '1';
        sspBenefits11.State__c = 'AL';
        sspBenefits11.BenefitPrograms__c = 'SN';
        sspBenefits11.BenefitStateCountyKey__c = '123qwe456q';
        sspBenefits11.BeginDate__c = System.today();
        sspBenefits11.EndDate__c = NULL;
        lstBenefits.add(sspBenefits11);
        //1st Data End
        //2nd Set of Data Start--->
        SSP_Benefits__c sspBenefits2 = new SSP_Benefits__c();
        sspBenefits2.SSP_Member__c = lstMem[0].Id;
        sspBenefits2.Name = 'Benefit Name';
        sspBenefits2.BenefitInfoCounty__c = '2';
        sspBenefits2.State__c = 'AL';
        sspBenefits2.BenefitPrograms__c = 'SN';
        sspBenefits2.BenefitStateCountyKey__c = '123qwe456t';
        sspBenefits2.BeginDate__c = System.today();
        sspBenefits2.EndDate__c = NULL;
        lstBenefits.add(sspBenefits2);
        
        SSP_Benefits__c sspBenefits3 = new SSP_Benefits__c();
        sspBenefits3.SSP_Member__c = lstMem[0].Id;
        sspBenefits3.Name = 'Benefit Name';
        sspBenefits3.State__c = 'AL';
        sspBenefits3.BenefitPrograms__c = 'TN';
        sspBenefits3.BenefitStateCountyKey__c = '123qwe456t';
        sspBenefits3.BeginDate__c = System.today();
        sspBenefits3.EndDate__c = NULL;
        lstBenefits.add(sspBenefits3);
        
        SSP_Benefits__c sspBenefits4= new SSP_Benefits__c();
        sspBenefits4.SSP_Member__c = lstMem[0].Id;
        sspBenefits4.Name = 'Benefit Name';
        sspBenefits4.State__c = 'AL';
        sspBenefits4.BenefitPrograms__c = 'MA';
        sspBenefits4.BenefitStateCountyKey__c = '123qwe456t';
        sspBenefits4.BeginDate__c = System.today();
        sspBenefits4.EndDate__c = NULL;
        lstBenefits.add(sspBenefits4);
        //2nd Set of Data End
        //3rd Set of Data Start-->
        SSP_Benefits__c sspBenefits5= new SSP_Benefits__c();
        sspBenefits5.SSP_Member__c = lstMem[0].Id;
        sspBenefits5.Name = 'Benefit Name';
        sspBenefits5.BenefitInfoCounty__c = '3';
        sspBenefits5.State__c = 'AL';
        sspBenefits5.BenefitPrograms__c = 'MA';
        sspBenefits5.BeginDate__c = System.today();
        sspBenefits5.BenefitStateCountyKey__c = '123qwe456w';
        sspBenefits5.EndDate__c = NULL;
        lstBenefits.add(sspBenefits5);
        //End
        insert lstBenefits;               
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    @isTest
    public static void fetchAnotherStateBenefitsTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        System.runAs(fetchCitizenUser()) {
            SSP_Member__c objSSPMember = [SELECT ID FROM SSP_Member__c LIMIT 1];
            SSP_Benefits__c sspBenefits5= new SSP_Benefits__c();
            sspBenefits5.SSP_Member__c = objSSPMember.Id;
            sspBenefits5.Name = 'Benefit Name';
            sspBenefits5.BenefitInfoCounty__c = '3';
            sspBenefits5.State__c = 'AL';
            sspBenefits5.BenefitPrograms__c = 'MA';
            sspBenefits5.BeginDate__c = System.today();
            sspBenefits5.BenefitStateCountyKey__c = '123qwe456t';
            sspBenefits5.EndDate__c = null;
            insert sspBenefits5;
            lighningResponse = SSP_AnotherStateBenefitsCtrl.fetchAnotherStateBenefits(objSSPMember.Id);
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }   
    @isTest
    public static void upsertAnotherStateBenefitsTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> benefitsList = new List<SSP_Benefits__c>();
        List<SSP_Benefits__c> lstBenefits = [SELECT ID, Name, State__c,toLabel(State__c) StateLabel, BenefitInfoCounty__c, toLabel(BenefitPrograms__c), BeginDate__c, EndDate__c, SSP_Member__c FROM SSP_Benefits__c];
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList benefitDataWrapper = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList();
        List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList> programList = new List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList programType = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_Benefits__c sspBenefits6= new SSP_Benefits__c();
        sspBenefits6.SSP_Member__c = sspMember.Id;
        sspBenefits6.Name = 'Benefit Name';
        sspBenefits6.BenefitInfoCounty__c = '3';
        sspBenefits6.State__c = 'AL';
        sspBenefits6.BenefitPrograms__c = 'MA';
        sspBenefits6.BeginDate__c = System.today();
        sspBenefits6.EndDate__c = System.today().addMonths(1);
        benefitsList.add(sspBenefits6);
        for(SSP_Benefits__c objBenefit : benefitsList){
            programType.sBenefitId = objBenefit.Id;
            programType.sBenefitProgram = objBenefit.BenefitPrograms__c;
            programType.dBenefitStartDate = objBenefit.BeginDate__c;
            programType.dBenefitEndDate = objBenefit.EndDate__c;
            programList.add(programType);
            benefitDataWrapper.sMemberId = sspMember.Id;
            benefitDataWrapper.sBenefitState = objBenefit.State__c;
            benefitDataWrapper.sBenefitCounty = objBenefit.BenefitInfoCounty__c;
            benefitDataWrapper.bIsInsert = true;
            benefitDataWrapper.bSnapCheck = true;
            benefitDataWrapper.bTanfCheck = true;
            benefitDataWrapper.bMedicaidCheck = false;
            benefitDataWrapper.sBenefitUniqueKey = 'dhd456hjk8';
            benefitDataWrapper.lstBenefitProgramList = programList;
        }
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_AnotherStateBenefitsCtrl.upsertAnotherStateBenefits(JSON.serialize(benefitDataWrapper));
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    @isTest
    public static void upsertAnotherStateBenefitsTest3(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> benefitsList = new List<SSP_Benefits__c>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList benefitDataWrapper = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList();
        List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList> programList = new List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList programType = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_Benefits__c sspBenefits6= new SSP_Benefits__c();
        sspBenefits6.SSP_Member__c = sspMember.Id;
        sspBenefits6.Name = 'Benefit Name';
        sspBenefits6.BenefitInfoCounty__c = '3';
        sspBenefits6.State__c = 'AL';
        sspBenefits6.BenefitPrograms__c = 'TN';
        sspBenefits6.BeginDate__c = System.today();
        sspBenefits6.EndDate__c = System.today().addMonths(1);
        benefitsList.add(sspBenefits6);
        for(SSP_Benefits__c objBenefit : benefitsList){
            programType.sBenefitProgram = objBenefit.BenefitPrograms__c;
            programType.dBenefitStartDate = objBenefit.BeginDate__c;
            programType.dBenefitEndDate = objBenefit.EndDate__c;
            programList.add(programType);
            benefitDataWrapper.sMemberId = objBenefit.SSP_Member__c;
            benefitDataWrapper.sBenefitState = objBenefit.State__c;
            benefitDataWrapper.sBenefitCounty = objBenefit.BenefitInfoCounty__c;
            benefitDataWrapper.bIsInsert = true;
            benefitDataWrapper.bSnapCheck = false;
            benefitDataWrapper.bTanfCheck = false;
            benefitDataWrapper.bMedicaidCheck = false;
            benefitDataWrapper.lstBenefitProgramList = programList;
        }
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_AnotherStateBenefitsCtrl.upsertAnotherStateBenefits(JSON.serialize(benefitDataWrapper));
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    @isTest
    public static void upsertAnotherStateBenefitsTest4(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> benefitsList = new List<SSP_Benefits__c>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList benefitDataWrapper = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList();
        List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList> programList = new List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList programType = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_Benefits__c sspBenefits6= new SSP_Benefits__c();
        sspBenefits6.SSP_Member__c = sspMember.Id;
        sspBenefits6.Name = 'Benefit Name';
        sspBenefits6.BenefitInfoCounty__c = '3';
        sspBenefits6.State__c = 'AL';
        sspBenefits6.BenefitPrograms__c = 'TN';
        sspBenefits6.BeginDate__c = System.today();
        sspBenefits6.EndDate__c = System.today().addMonths(1);
        benefitsList.add(sspBenefits6);
        for(SSP_Benefits__c objBenefit : benefitsList){
            programType.sBenefitProgram = objBenefit.BenefitPrograms__c;
            programType.dBenefitStartDate = objBenefit.BeginDate__c;
            programType.dBenefitEndDate = objBenefit.EndDate__c;
            programList.add(programType);
            benefitDataWrapper.sMemberId = objBenefit.SSP_Member__c;
            benefitDataWrapper.sBenefitState = objBenefit.State__c;
            benefitDataWrapper.sBenefitCounty = objBenefit.BenefitInfoCounty__c;
            benefitDataWrapper.bIsInsert = false;
            benefitDataWrapper.bSnapCheck = true;
            benefitDataWrapper.bTanfCheck = true;
            benefitDataWrapper.bMedicaidCheck = true;
            benefitDataWrapper.lstBenefitProgramList = programList;
        }
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_AnotherStateBenefitsCtrl.upsertAnotherStateBenefits(JSON.serialize(benefitDataWrapper));
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    @isTest
    public static void upsertAnotherStateBenefitsTest5(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> benefitsList = new List<SSP_Benefits__c>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList benefitDataWrapper = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList();
        List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList> programList = new List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList programType = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_Benefits__c sspBenefits6= new SSP_Benefits__c();
        sspBenefits6.SSP_Member__c = sspMember.Id;
        sspBenefits6.Name = 'Benefit Name';
        sspBenefits6.BenefitInfoCounty__c = '3';
        sspBenefits6.State__c = 'AL';
        sspBenefits6.BenefitPrograms__c = 'TN';
        sspBenefits6.BeginDate__c = System.today().addMonths(2);
        sspBenefits6.EndDate__c = System.today().addMonths(3);
        benefitsList.add(sspBenefits6);
        for(SSP_Benefits__c objBenefit : benefitsList){
            programType.sBenefitProgram = objBenefit.BenefitPrograms__c;
            programType.dBenefitStartDate = objBenefit.BeginDate__c;
            programType.dBenefitEndDate = objBenefit.EndDate__c;
            programList.add(programType);
            benefitDataWrapper.sMemberId = objBenefit.SSP_Member__c;
            benefitDataWrapper.sBenefitState = objBenefit.State__c;
            benefitDataWrapper.sBenefitCounty = objBenefit.BenefitInfoCounty__c;
            benefitDataWrapper.bIsInsert = false;
            benefitDataWrapper.bSnapCheck = true;
            benefitDataWrapper.bTanfCheck = true;
            benefitDataWrapper.bMedicaidCheck = true;
            benefitDataWrapper.lstBenefitProgramList = programList;
        }
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_AnotherStateBenefitsCtrl.upsertAnotherStateBenefits(JSON.serialize(benefitDataWrapper));
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
        
    }
    @isTest
    public static void removeBenefitDataTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> lstBenefits = [SELECT ID, Name, State__c,toLabel(State__c) StateLabel, BenefitInfoCounty__c, toLabel(BenefitPrograms__c), BeginDate__c, EndDate__c, SSP_Member__c FROM SSP_Benefits__c];
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        String benefitIds = '';
        for(SSP_Benefits__c obj : lstBenefits){
            if(benefitIds == '' || String.isBlank(benefitIds) || String.isEmpty(benefitIds)){
                benefitIds = obj.Id;
            }else{
                benefitIds = benefitIds +','+ obj.Id;
            }
            
        }
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_AnotherStateBenefitsCtrl.removeBenefitData(benefitIds,sspMember.Id);
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    @isTest
    public static void removeBenefitDataTest1(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> lstBenefits = [SELECT ID, Name, State__c,toLabel(State__c) StateLabel, BenefitInfoCounty__c, toLabel(BenefitPrograms__c), BeginDate__c, EndDate__c, SSP_Member__c FROM SSP_Benefits__c];
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        String benefitIds = '123';
        for(SSP_Benefits__c obj : lstBenefits){
            benefitIds = benefitIds + obj.Id;
        }
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_AnotherStateBenefitsCtrl.removeBenefitData(benefitIds, sspMember.Id);
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    @isTest
    public static void removeBenefitDataTest2(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        String benefitIds = '12345';
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_AnotherStateBenefitsCtrl.removeBenefitData(benefitIds, sspMember.Id);
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    @isTest
    public static void isRequiredTest(){
        SSP_AnotherStateBenefitsQueueRule queueRule = new SSP_AnotherStateBenefitsQueueRule();
        Boolean isRequired = false;
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        SSP_Member__c objMember = [SELECT ID FROM SSP_Member__c Limit 1];
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        QueuingWrapper queWrap = new QueuingWrapper();
        ctxData.MemberId = objMember.Id;
        SSP_ApplicationIndividual__c objAppInd = [Select ID, SSP_Member__c, ProgramsApplied__c,SSP_Member__r.HasReceivedBenefitsFromOtherStateToggle__c From SSP_ApplicationIndividual__c LIMIT 1];
        memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        ctxData.queueObject = queWrap;
        System.runAs(fetchCitizenUser()) {
            isRequired = queueRule.isRequired(ctx, ctxData);
        }
        ctxData.MemberId = '1234543';
        System.runAs(fetchCitizenUser()) {
            isRequired = queueRule.isRequired(ctx, ctxData);
        }
    }
    @isTest
    public static void updateMemberDataTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        System.runAs(fetchCitizenUser()) {
            Test.startTest();
            lighningResponse = SSP_AnotherStateBenefitsCtrl.updateMemberData(sspMember.Id);
            Test.stopTest();
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
     @isTest
    public static void updateMemberDataNullTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        System.runAs(fetchCitizenUser()) {
            Test.startTest();
            lighningResponse = SSP_AnotherStateBenefitsCtrl.updateMemberData('12345');
            Test.stopTest();
        }
        System.assertEquals(false, lighningResponse.bIsSuccess);
    }
}