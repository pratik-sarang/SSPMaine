/*
* classname     :  SSP_MedicalEnforcementControllerTest 
* @description  : Test  Class For Medical Enforcement Screen
* @author       :  Kireeti Gora
* @date         :  12/19/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/

   /**
@author : Kireeti Gora
Method to setup test data*/ 
@isTest(seeAllData=false)
public class SSP_MedicalEnforcementControllerTest { 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'medicalEnforcementController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id; 
         lstMem[0].isHeadOfHousehold__c = true;
        insert lstMem;
        
        
        List<SSP_NonCustodialParent__c> lstNonCustodialParent = SSP_TestDataFactory.createNoncustodialParentRecords(1, true, lstMem[0].Id);
        
        SSP_NoncustodialRelationship__c objNonCustodialParent = new SSP_NoncustodialRelationship__c();
        objNonCustodialParent.SSP_Member__c = lstMem[0].Id;
        objNonCustodialParent.HasChildSupportToggle__c ='Y';
        objNonCustodialParent.SSP_NonCustodialParent__c=lstNonCustodialParent[0].Id;
       //objNonCustodialParent.RecordTypeId =Schema.SObjectType.SSP_NoncustodialRelationship__c.getRecordTypeInfosByDeveloperName()
    //.get('ChildMedicalSupport').getRecordTypeId();
        insert objNonCustodialParent;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'KT';
         lstAppInd[0].MedicaidType__c = 'MAGI';
        insert lstAppInd; 
        
    }
       /**
@author : Kireeti Gora
Method to test getMedicalEnforcementDetailsWithId method*/
    @isTest
    public static void test_getMedicalEnforcementDetailsWithId(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'medicalEnforcementController'];
            
            List<SSP_Asset__c> assetList = [SELECT Id, Name, BusinessTypeCode__c, EmployerName__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
            
            
            test.startTest();
            
            SSP_LightningResponse response = SSP_MedicalEnforcementController.getMedicalEnforcementDetailsWithId( appIndvList[0].SSP_Application__c,appIndvList[0].SSP_Member__c);
            system.assertNotEquals(null, response.mapResponse);
            system.assert(response.mapResponse.containsKey('applicationIndividualPrograms'));  
            system.assert(response.mapResponse.containsKey('nonCustodialRelationshipRecord'));
            
            
            test.stopTest();
        }
        
    }
           /**
@author : Kireeti Gora
Method to test getMedicalEnforcementDetailsWithId method negatively*/
     @isTest
    public static void test_getMedicalEnforcementDetailsWithId_false(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
         
            test.startTest();
            
            SSP_LightningResponse response = SSP_MedicalEnforcementController.getMedicalEnforcementDetailsWithId( 'fhsjk','fsj');
           
            system.assert(!response.mapResponse.containsKey('applicationIndividualPrograms'));  
            system.assert(!response.mapResponse.containsKey('nonCustodialParentRecord'));
            
            
            test.stopTest();
        }
        
    }
           /**
@author : Kireeti Gora
Method to test updateNonCustodRecords method */    
      @isTest
    public static void test_updateNonCustodRecords(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
          SSP_NoncustodialRelationship__c objNonCustodialParent= New SSP_NoncustodialRelationship__c();
         objNonCustodialParent =[SELECT Id,HasChildSupportToggle__c,GoodCauseCode__c,MedicalSupportComments__c,SSP_Member__c FROM SSP_NoncustodialRelationship__c limit 1][0];
        System.runAs(citizen){
        
            objNonCustodialParent.HasChildSupportToggle__c='N';
            objNonCustodialParent.GoodCauseCode__c='Y';
            objNonCustodialParent.MedicalSupportComments__c='abc';
            
            test.startTest();
            
            Boolean response = SSP_MedicalEnforcementController.updateNonCustodRecords( JSON.serialize(objNonCustodialParent));
            Boolean responseNegative = SSP_MedicalEnforcementController.updateNonCustodRecords('null');
           
            system.assert(response);  
           
            test.stopTest();
        }
        
    }
     /********************************************************************************************
    * @author      Kireeti Gora
    * @date         02/18/2020
    * @methodname   isRequiredTest
    * @description  Test method for isRequired
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void isRequiredTest(){
       
            test.startTest();
       SSP_ApplicationIndividual__c objApp = [SELECT Id,SSP_Member__c,SSP_Application__c FROM SSP_ApplicationIndividual__c limit 1];
        
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = objApp.SSP_Member__c;
        ctxData.ApplicationId = objApp.SSP_Application__c;
        
        SSP_ChildMedicalEnforcementRule cls = new SSP_ChildMedicalEnforcementRule();
        boolean result = cls.isRequired(ctx, ctxData);
        System.assertNotEquals(result, null);
        
        boolean result1 = cls.isRequired(null, null);
        System.assertNotEquals(result1, null);
        
        SSP_MedicalEnforcementRule clsMedical = new SSP_MedicalEnforcementRule();
        boolean resultMedical = clsMedical.isRequired(ctx, ctxData);
        System.assertNotEquals(result, null);
        
        boolean result1Medical = clsMedical.isRequired(null, null);
        System.assertNotEquals(result1, null);
            test.stopTest();
    
    }
}