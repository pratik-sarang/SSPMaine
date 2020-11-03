/*
* classname     :  SSP_ExpenseControllerTest
* @description  :  Test class for SSP_ExpenseController
* @author       :  Shrikant Raut   
* @date         :  12/06/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/

@isTest(seeAllData=false)
public class SSP_ExpenseControllerTest { 
    /**
    @author : Shrikant Raut 
    Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'ExpenseController';
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
        lstMem[0].HasDisabledExpensesToggle__c = 'Y';
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_Asset__c> lstAsset = SSP_TestDataFactory.createAssets(10, 'Expense',false);
        //lstAsset[0].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Expense'); 
        lstAsset[0].SSP_Application__c = lstAppln[0].Id;
        lstAsset[0].SSP_Member__c = lstMem[0].Id;
        lstAsset[0].ExpenseTypeCode__c ='SE';

        lstAsset[1].SSP_Application__c = lstAppln[0].Id;
        lstAsset[1].SSP_Member__c = lstMem[0].Id;
        lstAsset[1].ExpenseTypeCode__c ='UE';
        
        lstAsset[2].SSP_Application__c = lstAppln[0].Id;
        lstAsset[2].SSP_Member__c = lstMem[0].Id;
        lstAsset[2].ExpenseTypeCode__c ='EE';
        
        lstAsset[3].SSP_Member__c = lstMem[0].Id;
        lstAsset[3].ExpenseTypeCode__c ='ME';
        lstAsset[3].DCID__c =2332;
        lstAsset[3].ExpenseSubType__c ='MP';
        lstAsset[3].SSP_Application__c = lstAppln[0].Id;
        
        lstAsset[4].SSP_Member__c = lstMem[0].Id;
        lstAsset[4].ExpenseTypeCode__c ='CAE';
        
        lstAsset[5].SSP_Member__c = lstMem[0].Id;
        lstAsset[5].ExpenseTypeCode__c ='DCE';
        
        lstAsset[6].SSP_Member__c = lstMem[0].Id;
        lstAsset[6].ExpenseTypeCode__c ='DE';
        
        lstAsset[7].SSP_Member__c = lstMem[0].Id;
        lstAsset[7].DCId__c = 1234;        
        lstAsset[7].ExpenseTypeCode__c ='AL';
        
        lstAsset[8].SSP_Member__c = lstMem[0].Id;
        lstAsset[8].ExpenseTypeCode__c ='AL';
        lstAsset[8].isDeleted__c = false;
        
        lstAsset[9].SSP_Member__c = lstMem[0].Id;
        lstAsset[9].ExpenseTypeCode__c ='ME';
        lstAsset[9].DCID__c =23328;
        insert lstAsset;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].MemberStatus__c = SSP_GlobalConstants.MEMBER_STATUS_New;
        lstAppInd[0].IsTMember__c = false;
        lstAppInd[0].MedicaidType__c = 'Non-MAGI';
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_fetchExistingExpenseDetails(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'ExpenseController'];
            
            List<SSP_Asset__c> assetList = [SELECT Id, Name, BusinessTypeCode__c, EmployerName__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
            
            
            test.startTest();
            
            SSP_LightningResponse response = SSP_ExpenseController.fetchExistingExpenseDetailsImperative(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c, 'sspChangeExistingExpense');
            system.assertNotEquals(null, response.mapResponse);
            system.assert(response.mapResponse.containsKey('applicationIndividual'));  
            system.assert(response.mapResponse.containsKey('expenseRecords'));
            
            SSP_LightningResponse responseSummary = SSP_ExpenseController.fetchExistingExpenseDetailsImperative(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c, 'sspExpensesSummary');
            system.assertNotEquals(null, response.mapResponse);
            
            test.stopTest();
        }
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateExistingExpenseRecords_positive(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Asset__c> assetList = [SELECT Id, ExpenseAmount__c FROM SSP_Asset__c];
            Integer oldValue = (Integer)assetList[0].ExpenseAmount__c;
            String assetId = assetList[0].Id;
            test.startTest();
            assetList[0].ExpenseAmount__c = 1111;
            SSP_ExpenseController.updateExistingExpenseRecords(JSON.serialize(assetList));
            Integer newValue = (Integer)[SELECT Id, ExpenseAmount__c FROM SSP_Asset__c WHERE Id = :assetId LIMIT 1][0].ExpenseAmount__c;
            system.assertNotEquals(oldValue, newValue);
            system.assertEquals(1111, newValue);
            test.stopTest();
        }
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateExistingExpenseRecords_negative(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Asset__c> assetList = [SELECT Id, ExpenseAmount__c FROM SSP_Asset__c];
            Integer oldValue = (Integer)assetList[0].ExpenseAmount__c;
            String assetId = assetList[0].Id;
            test.startTest();
            assetList[0].ExpenseAmount__c = 1111;
            SSP_ExpenseController.updateExistingExpenseRecords('test');
            Integer newValue = (Integer)[SELECT Id, ExpenseAmount__c FROM SSP_Asset__c WHERE Id = :assetId LIMIT 1][0].ExpenseAmount__c;
            system.assertEquals(oldValue, newValue);
            test.stopTest();
        }
    }
    
    /**
    @author : Yathansh Sharma
    Test Method to test createExpense method*/
    @isTest
    public static void testCreateExpense(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            SSP_Application__c app = [SELECT Id FROM SSP_Application__c LIMIT 1]; 
            List<SSP_Member__c> lstMem = [SELECT Id FROM SSP_Member__c];
            SSP_ExpenseController.fetchMemberList(app.id, 'addRemoveMember');
            String jsonData = '{"sspMembers":"[{\\"Id\\":\\"'+lstMem[0].id+'\\",\\"HasDependentCareExpense__c\\":true}]"}';
            
            Map<String, Object> reqMap = new Map<String, Object>();
            reqMap.put('sspMembers', JSON.serialize([SELECT Id, SSP_Member__c FROM SSP_Asset__c]));
            
            SSP_ExpenseController.createRecords(jsonData, new Map<String, String>{lstMem[0].Id => 'HasDependentCareExpense__c'}, null);
            system.assertEquals(11, [select count() from ssp_asset__c]);
            Map<String, String> changeFieldMap = new Map<String, String>();
            changeFieldMap.put('trueToFalse', '{"'+lstMem[0].id+'":["HasTaxDeductionsExpenseToggle__c"]}');
            changeFieldMap.put('trueToFalse', '{"'+lstMem[0].id+'":["HasTaxDeductionsExpenseToggle__c"]}');
            SSP_ExpenseController.deleteRecords(changeFieldMap);
        }
    }

    /**@author : Kireeti Gora
    Test Method to test getExpenseDetailsWithId method*/
    @isTest
    public static void test_getExpenseDetailsWithId(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'ExpenseController'];
            
            List<SSP_Asset__c> assetList = [SELECT Id, Name, BusinessTypeCode__c, EmployerName__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
            
            
            
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c];
            test.startTest();
            SSP_LightningResponse response = SSP_ExpenseController.getExpenseDetailsWithId(assetList[0].Id,appIndvList[0].SSP_Application__c, appIndvList[0].SSP_Member__c,'ME');      
            system.assertNotEquals(null, response.mapResponse);
            system.assert(response.mapResponse.containsKey('applicationIndividual'));  
            system.assert(response.mapResponse.containsKey('expenseRecord'));
            test.stopTest();
        }
    }
        
    /**@author : Kireeti Gora
    Test Method to test setExpenseDetails method*/
    @isTest
    public static void test_setExpenseDetails(){
        String sRetrievedExpenseObj;
        String sRetrievedExpenseObj1;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'ExpenseController'];
            
            List<SSP_Asset__c> assetList = [SELECT Id,ExpenseTypeCode__c,Name, BusinessTypeCode__c, EmployerName__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
            
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c];
            Test.startTest();
            SSP_LightningResponse sExpenseObj;
            for(SSP_Asset__c asset:assetList){
                sExpenseObj = SSP_ExpenseController.getExpenseDetailsWithId(asset.Id,appIndvList[0].SSP_Application__c, appIndvList[0].SSP_Member__c,'SE'); 
                system.assertNotEquals(null, sExpenseObj);
            }            
                        
            String result;
            for(SSP_Asset__c asset : [SELECT Id, ExpenseTypeCode__c,SSP_Member__c FROM SSP_Asset__c]){
                result = SSP_ExpenseController.setExpenseDetails(JSON.serialize(asset),appIndvList[0].SSP_Application__c);
                system.assertNotEquals(null, result);
            }
            Test.stopTest();
        }
    }

    /**@author : Kireeti Gora
    Test Method to test setExpenseDetails method*/
    @isTest
    public static void test_setExpenseDetails_False(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            Test.startTest();
            
            String sRetrievedIncomeObj = SSP_ExpenseController.setExpenseDetails('','');
            system.assertEquals('',sRetrievedIncomeObj);
            Test.stopTest();
        }
    }
        
    /**@author : Shrikant Raut
	Test Method to test validateBlankExpense method*/
    @isTest
    public static void test_validateBlankExpense(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            SSP_ApplicationIndividual__c appIndv = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c LIMIT 1];
            
            Test.startTest();
            
            Boolean result = SSP_ExpenseController.validateBlankExpense(appIndv.SSP_Application__c, appIndv.SSP_Member__c);
            system.assert(result);
            Test.stopTest();
        }   
    }
    
}