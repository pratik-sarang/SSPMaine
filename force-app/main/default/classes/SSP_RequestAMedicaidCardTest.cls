@isTest(seeAllData=false)
public with sharing class SSP_RequestAMedicaidCardTest {
    @TestSetup
    static void setup(){
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    system.debug('portalRole is ' + portalRole);
    
    Profile profile = [Select Id from Profile where name = 'System Administrator'];
    User portalUserCreator = new User(
        UserRoleId 			=	portalRole.Id,
        ProfileId 			=	profile.Id,
        Username			=	System.now().millisecond() + Math.random() + 'test2@test.com',
        Alias 				=	'batman',
        Email				=	'ronald.stewart@mailinators.com',
        EmailEncodingKey	=	'UTF-8',
        Firstname			=	'Bruce',
        Lastname			=	'Wayne',
        LanguageLocaleKey	=	'en_US',
        LocaleSidKey		=	'en_US',
        TimeZoneSidKey		=	'America/Chicago'
    );
    Database.insert(portalUserCreator);
    
    System.runAs ( portalUserCreator ) {
        //Create account
        Account portalUserAccount = new Account(
            Name = 'Portal Account',
            OwnerId = portalUserCreator.Id
        );
        Database.insert(portalUserAccount);
        //String individualId=SSP_Utility.getIndividualId();
        //Create contact
        Contact contactForPortalUser = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalUserAccount.Id,
            Email = System.now().millisecond() + 'test@test.com',
            IndividualId__c = '1250002321',//'1250002321',
            MemberType__c='HOH',
            CacheBenefitMedicaidEBTData__c='[{"ShowMedicard":true,"ShowEBT":true,"IndividualName":"GLOT TEST","IndividualId":"1250002321","CaseNumber":"100011699"}]'
        );
        Database.insert(contactForPortalUser);
        //Create SSP Member
        SSP_Member__c objMem = new SSP_Member__c(
            Contact__c = contactForPortalUser.Id,
            FirstName__c='Test',
            LastName__c = 'McTesty'
            
                    );
        Database.insert(objMem);
//Create SSP Application 
        SSP_Application__c SSPApp = new SSP_Application__c(
            Contact__c = contactForPortalUser.Id,
            Account__c = portalUserAccount.Id,
            Status__c = 'P',
            ProgramsApplied__c ='MA;KT;CC;SN;SS;KP'
        );
        Database.insert(SSPApp);
        
            SSP_Application__c SSPAppUn = new SSP_Application__c(
            Contact__c = contactForPortalUser.Id,
            Account__c = portalUserAccount.Id,
            Status__c = 'UN',
            RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case'),
            LocalDCBSOffice__c = 'Kentucky',
            ProgramsApplied__c ='MA;KT;CC;SN;SS;KP',
            //DCCaseNumber__c = 890,
            RAC_Selections__c='CIS_CareTaker',
            ApplicationCreationInSSP__c = system.today()
        );
        Database.insert(SSPAppUn);
        
        SSP_Application__c SSPAppNcase = new SSP_Application__c(
            Contact__c = contactForPortalUser.Id,
            Account__c = portalUserAccount.Id,
            Status__c = 'UN'
        );
        Database.insert(SSPAppNcase);
        
            SSP_Application__c SSPAppNull = new SSP_Application__c(
            Contact__c = contactForPortalUser.Id,
            Account__c = portalUserAccount.Id
        );
        Database.insert(SSPAppNull);
        
        SSP_ApplicationIndividual__c SSPAppInd = new SSP_ApplicationIndividual__c(
            SSP_Application__c = SSPApp.Id,
            SSP_Member__c= ObjMem.Id,
            IsHeadOfHousehold__c = false
        );
        Database.insert(SSPAppInd);
                    
        SSP_ApplicationIndividual__c SSPAppIndUn = new SSP_ApplicationIndividual__c(
        SSP_Application__c = SSPAppUn.Id,
        SSP_Member__c= ObjMem.Id,
        IsHeadOfHousehold__c = true
        );
        Database.insert(SSPAppIndUn);
        
        SSP_ApplicationIndividual__c SSPAppNcaseIn = new SSP_ApplicationIndividual__c(
        SSP_Application__c = SSPAppNcase.Id,
        SSP_Member__c= ObjMem.Id,
        IsHeadOfHousehold__c = true
        );
        Database.insert(SSPAppNcaseIn);

        
        //Create Portal user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name=:'RE Citizen Profile' Limit 1];
        User portalUser = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ContactId = contactForPortalUser.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'batman905',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(portalUser);
        
        SSP_Office__c sspo=new SSP_Office__c();
    sspo.Name='Testing address';
    sspo.DCOfficeId__c=1001;
    sspo.PhysicalAddressLine1__c='1 street';
    sspo.PhysicalCity__c='Frankfort';
    Database.insert(sspo);
    }

    

}
    @isTest 
    static void testmedicaidCardRequestCallOut() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.MEDICAID_CARD_REQUEST));
        
        Map<String,String> mapParams = new Map<String,String>();
          SSP_Office__c sspo=new SSP_Office__c();
    sspo.Name='Testing address';
    sspo.DCOfficeId__c=1002;
    sspo.PhysicalAddressLine1__c='1 street';
    sspo.PhysicalCity__c='Frankfort';
    Database.insert(sspo);
        
        mapParams.put('memberCaseNumber','100053289');
        mapParams.put('addInfo','Replacing Card 8');
        mapParams.put('IsRequestedInOffice','Y');
        mapParams.put('whyReplace','Requesting another one');
        mapParams.put('memberIndividualId','999018951');
        mapParams.put('recordId',sspo.Id);
        mapParams.put('officeId','');
        Test.startTest();
        SSP_LightningResponse objresp= SSP_RequestAMedicaidCard.medicaidCardRequestCallOut(mapParams);
        Test.stopTest();
        String jsonstring=String.ValueOf(objresp.mapResponse.get('response'));
        
        //"Status":true
        system.assert(jsonstring.contains('"Status":true'), 'Success');
        
        // system.assertNotEquals(null,objresp);
        
    }

     @isTest 
    static void testEBTRequestCallOut() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.EBT_CARD_REQUEST));
        
        Map<String,String> mapParams = new Map<String,String>();
        
        
        mapParams.put('memberCaseNumber','100053289');
        mapParams.put('addInfo','Replacing Card 8');
        mapParams.put('IsRequestedInOffice','N');
        mapParams.put('whyReplace','Requesting another one');
        mapParams.put('memberIndividualId','999018951');
        mapParams.put('officeId','');
        Test.startTest();
        SSP_LightningResponse objresp= SSP_RequestAMedicaidCard.ebtCardRequestCallOut(mapParams);
         Test.stopTest();
        String jsonstring=String.ValueOf(objresp.mapResponse.get('response'));
        
        //"Status":true
        system.assert(jsonstring.contains('"Status":true'), 'Success');
        
   
       
    }

     @isTest 
    static void testGetMailingAddress() {
       
        Test.setMock(HttpCalloutMock.class, new SSP_DC_ReverseMockImpl());
        
     
        Test.startTest();
        SSP_LightningResponse objresp= SSP_RequestAMedicaidCard.getMailingAddress('999018553','1234567');
        Test.stopTest();
        String jsonstring=String.ValueOf(objresp.mapResponse.get('response'));
       
        //"Status":true
       system.assert(jsonstring!=null);
	
        
           
    }

    @istest
    static void testGetReasonPickListValues()
    {
        Map<String,String> mapofoptions = SSP_RequestAMedicaidCard.getReasonPickListValues();

        system.assert(mapofoptions.size()>=3);
    }
    
    @istest
    static void testmedicaidEBTData()
    {
            User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
       
        system.runAs(fetchedPortalUser){
            Test.startTest();
            SSP_LightningResponse resp=SSP_RequestAMedicaidCard.medicaidEBTData();
            Test.stopTest();
            system.assert(resp.bIsSuccess);

        }
    }

    @istest
    static void testGetDCBSAddress()
    {
        Test.startTest();
        SSP_LightningResponse response = SSP_RequestAMedicaidCard.getDCBSAddress('1001');
        Test.stopTest();
        System.assert(response.bIsSuccess);


    }
    
    @istest
    static void testupdateDashboardRefresh()
    {
        User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
       
        system.runAs(fetchedPortalUser){
        Test.startTest();
        SSP_LightningResponse resp=SSP_RequestAMedicaidCard.updateDashboardRefresh();
            Test.stopTest();
            System.assert(resp.bIsSuccess);
            
            
        }
        
    }
   
    
     @isTest 
    static void testmedicaidEBTDataNonHohCase() {
     
           Contact con= [Select Id,MemberType__c from Contact where IndividualId__c = '1250002321' Limit 1];
        con.MemberType__c='';
        Database.update(con);
        
            User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
       
        system.runAs(fetchedPortalUser){
            Test.startTest();
            SSP_LightningResponse resp=SSP_RequestAMedicaidCard.medicaidEBTData();
            Test.stopTest();
            system.assert(resp.bIsSuccess);

        }
        
       
        
        
    }
    
     @isTest 
    static void testmedicaidCardRequestCallOutDCBSID() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.MEDICAID_CARD_REQUEST));
        
        Map<String,String> mapParams = new Map<String,String>();
          SSP_Office__c sspo=new SSP_Office__c();
    sspo.Name='Testing address';
    sspo.DCOfficeId__c=1002;
    sspo.PhysicalAddressLine1__c='1 street';
    sspo.PhysicalCity__c='Frankfort';
    Database.insert(sspo);
        
        mapParams.put('memberCaseNumber','100053289');
        mapParams.put('addInfo','Replacing Card 8');
        mapParams.put('IsRequestedInOffice','Y');
        mapParams.put('whyReplace','Requesting another one');
        mapParams.put('memberIndividualId','999018951');
        mapParams.put('recordId','');
        mapParams.put('officeId','1002');
        Test.startTest();
        SSP_LightningResponse objresp= SSP_RequestAMedicaidCard.medicaidCardRequestCallOut(mapParams);
       Test.stopTest();
        String jsonstring=String.ValueOf(objresp.mapResponse.get('response'));
        
        //"Status":true
        system.assert(jsonstring.contains('"Status":true'), 'Success');
        
    }
    
     @isTest 
    static void testGetMailingAddressNegativeScenario() {
       
        //Test.setMock(HttpCalloutMock.class, new SSP_DC_ReverseMockImpl());
        
     
        Test.startTest();
        SSP_LightningResponse objresp= SSP_RequestAMedicaidCard.getMedicaidLinkVisibility('abc');
        Test.stopTest();
        String jsonstring=String.ValueOf(objresp.mapResponse.get('response'));
        system.assert(!objresp.bIsSuccess);
        
        
           
    }
    
     @isTest 
    static void testmedicaidCardRequestCallOutNegative() {
        //Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.MEDICAID_CARD_REQUEST));
        
        Map<String,String> mapParams = new Map<String,String>();
          SSP_Office__c sspo=new SSP_Office__c();
    sspo.Name='Testing address';
    sspo.DCOfficeId__c=1002;
    sspo.PhysicalAddressLine1__c='1 street';
    sspo.PhysicalCity__c='Frankfort';
    Database.insert(sspo);

        Test.startTest();
        SSP_LightningResponse objresp= SSP_RequestAMedicaidCard.medicaidCardRequestCallOut(mapParams);
       Test.stopTest();
        String jsonstring=String.ValueOf(objresp.mapResponse.get('response'));
         system.assert(!objresp.bIsSuccess);
   
        
    }
}