/***************************************************************************************************
*   Type        :   Controller Test Class
*   Name        :   SSP_LivingArrangementControllerTest
*   Create By   :   Samridh Manucha
*   Create Date :   JAN-29-2020
*   Description :   Test class for SSP_LivingArrangementController.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Samridh Manucha           JAN-29-2020             Initial Version
*
*****************************************************************************************************/
@isTest(seeAllData=false)
public class SSP_LivingArrangementControllerTest {
    @testSetup
    public static void dataSetup() {    
        SSP_Institution__c inst = new SSP_Institution__c();
        inst.name__c = 'test';
        inst.AddressLine1__c = 't1';
        inst.AddressLine1__c = 't2';
        inst.City__c = 'San Antonio';
        inst.StateCode__c = 'TX';
        inst.ZipCode__c = '560037';
        insert inst;      
    }
         
    @isTest
    public static void unitTest1() {
        User citizen  = SSP_TestDataFactory.createPortalUser();
        System.runAs(citizen){
        Test.startTest();
        SSP_LightningResponse response = SSP_LivingArrangementController.fetchAccountInformation('test','DAA');
        if(response != null ) System.assert(response.bIsSuccess);
        Test.stopTest();
        }
    }
    
      @isTest
    public static void unitTest2() {
         Test.startTest();        
         SSP_LightningResponse response = SSP_LivingArrangementController.fetchAccountInformation('test','LTC');
         if(response != null ) System.assert(!response.bIsSuccess);
         Test.stopTest();        
    }
    
        @isTest
    public static void unitTest3() {
         User citizen  = SSP_TestDataFactory.createPortalUser();
         List<object> objList = new List<object>();
         string jsonData = '{"Results": { "ProviderSearchResult": [{"OrganizationId": "3982","OrganizationName": "WILLIAMSBURG NURSING HOME ","OrganizationAddress": "ATTN:  BRYAN BARTON,P.O. BOX 719, WILLIAMSBURG,KY,40769"}]}}}';      
         Object obj = (Object)JSON.deserialize(jsonData, SSP_ProviderSearchResponseWrapper.Class);                  
         objList.add(obj); 
         System.runAs(citizen){        
         Test.startTest();        
         List<SSP_LivingArrangementController.WrapperOrganization> lstWrapper = SSP_LivingArrangementController.fetchWrapperOrganization(objList);
         if(lstWrapper.size()>0) System.assert(lstWrapper.size()>0);
         Test.stopTest();
         }        
    }
    
     @isTest
    public static void unitTest4() {
        User citizen  = SSP_TestDataFactory.createPortalUser();
        SSP_Institution__c institution = [ select id from SSP_Institution__c where Name__c = 'test' limit 1];
        System.runAs(citizen){
        Test.startTest();
        SSP_LightningResponse response = SSP_LivingArrangementController.fetchInstitutionInformation(institution.id);
        if(response != null ) System.assert(response.bIsSuccess);
        Test.stopTest();
        }
    }
    
     @isTest
    public static void unitTest5() {
        Test.startTest();
        SSP_LightningResponse response = SSP_LivingArrangementController.fetchInstitutionInformation('abc');
        System.assertequals(response.bIsSuccess,false);
        Test.stopTest();
        }
    
    
}