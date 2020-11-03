@isTest
public class SSP_KOGRegistrationTest {
    
    @isTest static  void kogRegistrationTest(){
        KOGWebservice__c obj = new KOGWebservice__c();
        obj.Name = 'KOG SSP Citizen';
        obj.Certificate__c = 'testcert';
        obj.PageURL__c = 'https://sspdev-benefind-reci.cs32.force.com/benefind/s/dashboard';
        obj.ApplicationName__c = 'DEV4 KHBE Self Service Portal';
        obj.Role__c = 'Citizen';
        obj.EndURL__c = 'https://uat.websrvgw.chfs.ky.gov/DEV/parameterpassingsvc/GatewayRedirectContextService.svc';
        insert obj;
        
        Test.startTest();
        	Test.setMock(WebServiceMock.class, new tempuriOrgGateWayRedirectMock());
        	String strContextId = SSP_KOGRegistration.getKogContextID('Citizen');
        	System.assertEquals('Test1234',strContextId);
        Test.stopTest();
        
    }
	
}