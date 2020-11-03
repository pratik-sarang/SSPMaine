@istest
public class SSP_RulesEngineControllerTest {
     @TestSetup static void setup() {
    	SSP_TestDataFactory.setupTestData();
         
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'HealthSelectionCtrl';
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
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(2, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem[0].RaceCode__c='IN';
        lstMem[0].BirthDate__c=date.ValueOf('1998-06-22');
        lstMem[0].IsUSCitizenToggle__c= SSP_GlobalConstants.NO;
        lstMem[0].HasAlienSponsorToggle__c= SSP_GlobalConstants.NO;
        lstMem[1].contact__c=lstCon[0].Id;  
        lstMem[1].IsUSCitizenToggle__c= SSP_GlobalConstants.NO;
        lstMem[1].HasAlienSponsorToggle__c= SSP_GlobalConstants.NO;
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(2, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
         lstAppInd[0].IsHeadOfhousehold__c=false;
        lstAppInd[1].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[1].SSP_Member__c=lstMem[1].Id;
        lstAppInd[1].IsHeadOfhousehold__c=false;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();        
    }
     private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
   @istest
    public static void invokeRuleTest(){
         List<SSP_Application__c> lstAppln = [Select Id from SSP_Application__c];
         List<SSP_Member__c> lstMember = [Select Id from SSP_Member__c];
        System.runAs(fetchCitizenUser()) {  
            Test.startTest();
            Set<String> setRulesToInvoketest=new Set<String>{'ReviewResource','review_tax_filing','SameAddressForNonPrimary','AgeGreaterThan17USCitizen','review_expense_summary'};   
            SSP_RulesEngineController.invokeRule(setRulesToInvoketest,lstAppln[0].Id,lstMember[0].Id);
            SSP_RulesEngineController.getNonPrimaryMemberId(lstMember[0].Id);
              Test.stopTest();
       }
        SSP_RulesEngineController.getNonPrimaryMemberId(lstMember[0].Id);
        SSP_RulesEngineController.getNonUSCitizen(lstMember[0].Id,lstAppln[0].Id);
    }
     @istest
    public static void invokeRuleTest1(){
         List<SSP_Application__c> lstAppln = [Select Id from SSP_Application__c];
         List<SSP_Member__c> lstMember = [Select Id,IsUSCitizenToggle__c,HasAlienSponsorToggle__c from SSP_Member__c];
        lstMember[0].IsUSCitizenToggle__c=SSP_GlobalConstants.NO;
         SSP_RulesEngineController.getNonUSCitizen(lstMember[0].Id,lstAppln[0].Id);
        
    }
}