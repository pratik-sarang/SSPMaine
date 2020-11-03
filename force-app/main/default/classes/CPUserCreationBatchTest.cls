/**************************************************************************************************
* Class Name    : CPUserCreationBatchTest
* Owner         : Sai Kiran Velpula
* Created Date  : 11/19/2019
* Description   : CPUserCreationBatchTest Test class for CPUserCreationBatch
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
@isTest
public class CPUserCreationBatchTest {
    @testSetup static void testDataSetup(){
        RecordType objRecordType = [SELECT ID FROM RecordType where DeveloperName = 'CPUserContact'];
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');

        List<Account> accountList = TestDataFactory.createAccounts(1,true,sREAccRecTypeId);
        Contact objCon = TestDataFactory.createCPContact('FirstName','LastName','cpuser@email.com','Admin',objRecordType.Id,true);
        
    }
    @isTest
    public static void CPUserCreationBatchExecuteTest(){
        insert new KOGWebservice__c(name = 'KOG Inquiry Service', KOG_Login_URL__c = 'abc');
        insert new KOGWebservice__c(name = 'KOG CP Admin', KOG_Login_URL__c = 'abc');
        insert new KOGWebservice__c(name = 'KOG CP Staff', KOG_Login_URL__c = 'abc');
        Test.startTest();
        Test.setMock(WebServiceMock.class, new tempuriOrgMock('A'));
                //Test.setMock(WebServiceMock.class, new tempuriOrgMock('B'));
        
        RecordType objAccountRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'Resource_Engine' AND SobjectType = 'Account'];
        RecordType objContactRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'CPUserContact' AND SobjectType = 'Contact'];
        List<Id> accountIDs = new List<Id>();
        Set<Id> contactIDs = new Set<Id>();
        List<Account> lstAccount = TestDataFactory.createAccounts(1,true,objAccountRecordType.Id);
        for(Account objAccount : lstAccount){
            accountIDs.add(objAccount.Id);
        }
                //Test.setMock(WebServiceMock.class, new tempuriOrgGateWayRedirectMock());
        List<Contact> lstContact = TestDataFactory.createContacts(1,true,objContactRecordType.Id,accountIDs,true);
        for(Contact objContact : lstContact){
            contactIDs.add(objContact.Id);
        }


        Database.executeBatch(new CPUserCreationBatch(contactIDs), 200);
        Account testres = [SELECT Id from Account WHERE ID =:lstAccount[0].Id LIMIT 1 ];
        System.assertNotEquals(testres, null);
        Test.stopTest();



    }
    
}