/*
* classname 		: SSP_ExpeditedSnapBenefitCtrlTest
* @description 		: This is the Test class for SSP_ExpeditedSnapBenefitCtrl class.
* @author 			: Sai Kiran
* @date 			: 01/04/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest
public class SSP_ExpeditedSnapBenefitCtrlTest {
    
    @TestSetup static void setup() { 
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
        lstAppln[0].ProgramsApplied__c = 'SN;KT;CC';
        lstAppln[0].IsApplicationSubmittedEarly__c = 'Y';
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'SN;KT;CC';
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    @isTest
    public static void fetchApplicationDataTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        Boolean enableApplicationCheck = false;
        System.runAs(fetchCitizenUser()) {
            SSP_Application__c objApplication = [SELECT ID,ProgramsApplied__c FROM SSP_Application__c Limit 1];
            lighningResponse = SSP_ExpeditedSnapBenefitCtrl.fetchApplicationData(objApplication.Id);            
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    
    @isTest
    public static void fetchApplicationDataTest1(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        System.runAs(fetchCitizenUser()) {
            lighningResponse = SSP_ExpeditedSnapBenefitCtrl.fetchApplicationData('12345');
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    
    @isTest
    public static void updateApplicationTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        System.runAs(fetchCitizenUser()) {
            SSP_Application__c objApplication = [SELECT ID FROM SSP_Application__c Limit 1];
            SSP_ExpeditedSnapBenefitWrapper objApplicationWrap = new SSP_ExpeditedSnapBenefitWrapper();
            objApplicationWrap.sApplicationId = objApplication.Id;
            objApplicationWrap.bDestituteFarmOrMigrantHouseholdToggle = 'Y';
            objApplicationWrap.bShelterExpExceedIncomeResourcesToggle = 'Y';
            objApplicationWrap.sCashSavingAmount = 200;
            objApplicationWrap.sGrossIncAmount = 200;
            lighningResponse = SSP_ExpeditedSnapBenefitCtrl.updateApplication(JSON.serialize(objApplicationWrap));
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
    }
    
    @isTest
    public static void updateApplicationNullTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        System.runAs(fetchCitizenUser()) {
            SSP_ExpeditedSnapBenefitWrapper objApplicationWrap = new SSP_ExpeditedSnapBenefitWrapper();
            objApplicationWrap.bDestituteFarmOrMigrantHouseholdToggle = 'Y';
            objApplicationWrap.bShelterExpExceedIncomeResourcesToggle = 'Y';
            objApplicationWrap.sCashSavingAmount = 200;
            objApplicationWrap.sGrossIncAmount = 200;
            lighningResponse = SSP_ExpeditedSnapBenefitCtrl.updateApplication(JSON.serialize(objApplicationWrap));
        }
        System.assertEquals(false, lighningResponse.bIsSuccess);
    }

     @isTest
    public static void queueRuleTest(){
        SSP_ExpeditedSnapBenefitQueueRule queueRule = new SSP_ExpeditedSnapBenefitQueueRule();
        Boolean isRequired = false;
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> applicationIndividualList = new List<SSP_ApplicationIndividual__c>();
        SSP_Member__c objMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_Application__c objApp = [SELECT ID FROM SSP_Application__c Limit 1];
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        QueuingWrapper queWrap = new QueuingWrapper();
        
        ctxData.MemberId = objMember.Id;
        ctxData.ApplicationId = objApp.Id;
        SSP_ApplicationIndividual__c objAppInd = [Select ID, SSP_Member__c, ProgramsApplied__c,SSP_Application__r.IsApplicationSubmittedEarly__c From SSP_ApplicationIndividual__c LIMIT 1];
        memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        applicationIndividualList.add(objAppInd);
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        queWrap.applicationIndividualList = applicationIndividualList;
        ctxData.queueObject = queWrap;
        System.runAs(fetchCitizenUser()) {
            isRequired = queueRule.isRequired(ctx, ctxData);
        }
        
        ctxData.ApplicationId = '12345654';
        System.runAs(fetchCitizenUser()) {
            isRequired = queueRule.isRequired(ctx, ctxData);
        }
    }
    
}