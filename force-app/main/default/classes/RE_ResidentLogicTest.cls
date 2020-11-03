/*********************************************************************************************************************************
* Class Name    : RE_ResidentLogicTest
* Owner         : Deloitte
* Created Date  : 
* Description   : TestClass for RE_ResidentLogicTest
*
*                            M O D I F I C A T I O N   L O G                                          
**/
@isTest
public class RE_ResidentLogicTest {
    @isTest
    public static void createUserinSFWithIEESIds(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        insert con;
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest',ContactId=con.Id);
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        
        test.startTest();
        RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
        // added for test
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            RE_ResidentLogic.citizenExceptionCapture citizenExp = new RE_ResidentLogic.citizenExceptionCapture();
            citizenExp = RE_ResidentLogic.createUserinSF(usr,'6456747');
		  
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true);  
        }
        
        test.stopTest();
    }
    
     @isTest
    public static void createUserinSFWithIEESIdsCoverException(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        insert con;
        
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr1 = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        insert usr1;
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest', ContactId=con.Id, federationIdentifier='KLIP');
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 786756753);
        insert cm;
        
        test.startTest();
        //RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
        // added for test
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        
        // end
        try{
            RE_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= RE_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            RE_ResidentLogic.citizenExceptionCapture citizenExp = new RE_ResidentLogic.citizenExceptionCapture();
            citizenExp = RE_ResidentLogic.createUserinSF(usr,'7867567531');
            //RE_Release 1.3 – ForceReviewer - Payal Dubela
            System.assertEquals(citizenExp.isExceptionFound,false,'Success'); 
            User updatedUser=RE_ResidentLogic.updateUserinSF(usr,'7867567531');
             
        }catch(Exception e){
              
        }
        
        test.stopTest();
    }
    @isTest
    public static void createUserinSFWithoutIEESIds(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'James',LastName = 'Cameron',Email = 'james@test.com');
        insert con1;
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm1;
        
        Contact_Mapping__c cm2 = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm2;
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
       
        test.startTest();
        try{
            RE_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= RE_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            RE_ResidentLogic.createUserinSF(usr,'6456747'); 
        }catch(Exception e){
             System.assert(e.getMessage().contains('ERR007'),true);
        }
      
        test.stopTest(); 
    }
    @isTest
    public static void createUserinSFWithIEESIdsNoContactMap(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567892);
        insert cm;
        test.startTest();
        try{
            RE_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= RE_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            RE_ResidentLogic.createUserinSF(usr,'6456747');
           
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true);
        }
        
        test.stopTest();
    }
    
    @isTest
    public static void updateUser(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr = new User(ProfileId = prof[0].id,ContactId = con.Id,Alias = 'gweygru',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = '1234567890' ,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        insert usr;
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        
        test.startTest();
        try{
            RE_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= RE_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            RE_ResidentLogic.updateUserinSF(usr,'1234567890'); 
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true); 
        }
        
        test.stopTest();
    }
    
    @isTest
    public static void updateUser2(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr = new User(ProfileId = prof[0].id,ContactId = con.Id,Alias = 'gweygru',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = '1234567890' ,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        insert usr;
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm;
        
        test.startTest();
        try{
            RE_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= RE_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(546789023);
        
            RE_ResidentLogic.getIndividualInfo('45566', usr, 'Kog');
            RE_ResidentLogic.updateUserinSF(usr,'1234567890');
        }catch(Exception e){
           System.assert(e.getMessage().contains('ERR007'),true); 
        }
        
        
        test.stopTest();
    }
    
    @isTest
    public static void updateUserWithIEESIds(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'testFN',LastName = 'testLN',Email = 'testFNLN@email.com');
        insert con1;
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr = new User(ProfileId = prof[0].id,ContactId = con.Id,Alias = 'gweygru',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = '1234567890' ,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        insert usr;
        
        User usr1 = new User(ProfileId = prof[0].id,ContactId = con1.Id,Alias = 'weweeg',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = '12345678907456' ,FirstName = 'usrFirstName',LastName = 'usrLastName',Email = 'usrtest@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest');
        insert usr1;
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm1;
        
        
        
        test.startTest();
        try{
            RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            RE_ResidentLogic.updateUserinSF(usr,'1234567890');
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true);
        }
       
        test.stopTest();
    }
    
    @isTest
    public static void updateUserNotinConMap(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr = new User(ProfileId = prof[0].id,ContactId = con.Id,Alias = 'gweygru',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = '1234567890' ,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        insert usr;
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 66666666);
        insert cm;
        
        test.startTest();
        try{
            RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            RE_ResidentLogic.updateUserinSF(usr,'1234567890'); 
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true);
        }
        
        test.stopTest();
    }
    @isTest
    public static void createUserException1(){
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        kyHbeMciDatacontractsMock mocktest=new kyHbeMciDatacontractsMock();
        mocktest.isThrowException=true;
        Test.setMock(WebServiceMock.class, mocktest);
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr = new User(ProfileId = prof[0].id,ContactId = con.Id,Alias = 'gweygru',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = '1234567890' ,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        insert usr;
        Test.startTest();
        try {
            RE_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('ERR004'),true);
        }
        test.stopTest();
        
    }
    @isTest
    public static void createUserinSFWithoutIEESIdException(){
        kyHbeMciDatacontractsMock mockTest=new kyHbeMciDatacontractsMock();
        mockTest.isNoMatch=true;
        Test.setMock(WebServiceMock.class, mockTest);
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en-US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567892);
        insert cm;
        test.startTest();
        try{
            RE_ResidentLogic.createUserinSF(usr,'6456747');
            usr.LastName='';
            RE_ResidentLogic.createUserinSF(usr,'64567471');
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true);
        }
        
        test.stopTest();
    }
    @isTest
    public static void createUserinSFWithoutIEESIdException1(){
        kyHbeMciDatacontractsMock mockTest=new kyHbeMciDatacontractsMock();
        mockTest.isNoMatch=true;
        Test.setMock(WebServiceMock.class, mockTest);
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'es-US',LocaleSidKey = 'es_US',Username = con.Email+'.idetest');
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567892);
        insert cm;
        test.startTest();
        try {
            RE_ResidentLogic.createUserinSF(usr,'6456747');
        }catch (Exception e) {
            System.assert(e.getMessage().contains('ERR005'),false);
        }
        test.stopTest();
        
    }
    @isTest
    public static void createUserinSFWithoutIEESIdException2(){
        kyHbeMciDatacontractsMock mockTest=new kyHbeMciDatacontractsMock();
        mockTest.isNoMatch=true;
        Test.setMock(WebServiceMock.class, mockTest);
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        User usr = new User(FirstName = 'FirstName',LastName = '',Email = 'test@test.com',LanguageLocaleKey = 'es-US',LocaleSidKey = 'es_US',Username = con.Email+'.idetest');
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567892);
        insert cm;
        test.startTest();
        try {
            RE_ResidentLogic.createUserinSF(usr,'6456747');
        }catch (Exception e) {
            System.assert(e.getMessage().contains('ERR007'),true);
        }
        test.stopTest();
        
    }
    @isTest
    public static void createUserinSFWithIEESIdsException(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        insert con;
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest',ContactId=con.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        User usr1 = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        insert usr1;
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm1;
        
        test.startTest();
        try{
            RE_ResidentLogic.citizenExceptionCapture capture= RE_ResidentLogic.createUserinSF(usr,'6456747');
        }catch(Exception e){
           // System.assert(capture.ExceptionCode=='ERR003','Error Scenario');
            System.assert(e.getMessage().contains('ERR003'),true);
        }
        test.stopTest();
    }
    @isTest
    public static void createUserinSFWithIEESIdsException1(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        insert con;
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        User usr1 = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        insert usr1;
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm1;
        
        Contact_Mapping__c cm2= new Contact_Mapping__c(Id=cm1.Id,IEES_Id__c=3564664);
        List<Contact_Mapping__c> conMapList=new List<Contact_Mapping__c>();
        conMapList.add(cm2);
        test.startTest();
        try{
              RE_ResidentLogic.citizenExceptionCapture capture= RE_ResidentLogic.createUserinSF(usr,'6456747');
        }catch(Exception e){
           // System.assert(capture.ExceptionCode=='ERR003','Error Scenario');
        	System.assert(e.getMessage().contains('null'),false);
        }
        test.stopTest();
    }
    @isTest
    public static void createUserinSFWithIEESIdsException2(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        insert con;
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        User usr1 = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        insert usr1;
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm1;
        
        Contact_Mapping__c cm2= new Contact_Mapping__c(Id=cm1.Id,IEES_Id__c=3564664);
        List<Contact_Mapping__c> conMapList=new List<Contact_Mapping__c>();
        conMapList.add(cm2);
        test.startTest();
        //Cover Exception
        RE_ResidentLogic.insertListSObject(conMapList,'Contact_Mapping__c');
        try{
            RE_ResidentLogic.createCitizenUser(usr,'767576574',con);
            RE_ResidentLogic.createCitizenUser(usr,'767576574',con);
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR005'),false);
        }
        test.stopTest();
    }
   
}