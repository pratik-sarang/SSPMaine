/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_KIHIPPPaymentTest
*   Created By   :   Shobhit Jain
*   Created Date :   07/27/2020
*   Description  :   Test class for SSP_KIHIPPPayment
*/
@isTest
public class SSP_KIHIPPPaymentTest {
    @testSetup static void setup() {
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
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem[0].IsUSCitizenToggle__c = 'Y';
        
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_AlienSponsor__c> lstAlienSponsor = SSP_TestDataFactory.createAlienSponsor(1, false);
        lstAlienSponsor[0].SSP_Member__c=lstMem[0].Id;
        lstAlienSponsor[0].AddressLine1__c= 'SN;KT;MA;SS';
        lstAlienSponsor[0].SponsorFirstName__c = lstMem[0].InternalAlienSponsor__r.FirstName__c;
        //lstAlienSponsor[0].HasLifeEstateToggle__c = 'Y';
        lstAlienSponsor= ESAPI.accessController().insertAsUser(lstAlienSponsor, SSP_Utility.getFieldsNamesList (lstAlienSponsor)).getInsertedObjects();
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].MemberStatus__c = SSP_GlobalConstants.MEMBER_STATUS_New;
        lstAppInd[0].IsTMember__c=false;
        lstAppInd[0].MedicaidType__c= 'MAGI';
        lstAppInd[0].IsHeadOfHousehold__c = false;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();        
    
    	 SSP_Institution__c inst = new SSP_Institution__c();
        inst.name__c = 'test';
        inst.AddressLine1__c = 't1';
        inst.AddressLine1__c = 't2';
        inst.City__c = 'San Antonio';
        inst.StateCode__c = 'TX';
        inst.ZipCode__c = '560037';
        insert inst;  
        
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    @isTest
    public static void testMethodOfSSPKIHIPPPayment(){
        
         
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id,FirstName__c,Lastname__c,SponsoredByOrganization__c,IsUSCitizenToggle__c,InternalAlienSponsor__c FROM SSP_Member__c];
        List<SSP_ApplicationIndividual__c> listOfApplicationIndividual = [select id,SSP_Application__c,SSP_Member__c,IsHeadOfHousehold__c,MedicaidType__c from SSP_ApplicationIndividual__c];
        Map<String, Object> mapParams = new Map<String, Object>();
        Test.startTest();
        List<Object> response = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
 		List<RSSP_DC_Wrapper> responses = (List<RSSP_DC_Wrapper>) JSON.deserialize(JSON.serialize(response), List<RSSP_DC_Wrapper>.class);
     
        SSP_KIHIPPPayment.getKIHIPPreferredPaymentMethod(listOfApplicationIndividual[0].Id);
        SSP_KIHIPPPayment.getBankDetails('1234');
        SSP_KIHIPPPayment.getBankDetails('Exception');
        SSP_KIHIPPPayment.getKIHIPPreferredPaymentMethod(null);
        SSP_KIHIPPPayment.pushChangeDataToExternalSystem(12345,123456,'987654','CH','1234','Test','412308','California','Pune','Test');
        Test.stopTest();
    }
}