/*********************************************************************************************************************************
* Class Name    : SSP_ResidentLogicTest
* Owner         : Deloitte
* Created Date  : 
* Description   : TestClass for SSP_ResidentLogicTest
*
*                            M O D I F I C A T I O N   L O G                                          
**/
@isTest
public class SSP_ResidentLogicTest {
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
        
        String strApplicableRoles = 'Citizen_Individual';
        
        test.startTest();
        SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
        // added for test
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            SSP_ResidentLogic.citizenExceptionCapture citizenExp = new SSP_ResidentLogic.citizenExceptionCapture();
            citizenExp = SSP_ResidentLogic.createUserinSF(usr,'546734567',strApplicableRoles);
            citizenExp = SSP_ResidentLogic.createUserinSF(usr,'234567788',strApplicableRoles);
            citizenExp = SSP_ResidentLogic.createUserinSF(usr,'546789023',strApplicableRoles);

        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true);  
        }
        SSP_ResidentLogic.citizenExceptionCapture citizenExp = new SSP_ResidentLogic.citizenExceptionCapture();
        citizenExp = SSP_ResidentLogic.createUserinSF(usr,'6456748',strApplicableRoles);
        test.stopTest();
    }
    
    @isTest
    public static void createUserinSFWithIEESIds1(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest',ContactId=con.Id);
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Group_Id__c = 'Grp123',IEES_Id__c = 234567788);//Contact__c = con.Id,
        
        String strApplicableRoles = 'Citizen_Individual';
        
        test.startTest();
        SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
        // added for test
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            SSP_ResidentLogic.citizenExceptionCapture citizenExp = new SSP_ResidentLogic.citizenExceptionCapture();
            //citizenExp = SSP_ResidentLogic.createUserinSF(usr,'6456747',strApplicableRoles);
            citizenExp = SSP_ResidentLogic.createUserinSF(usr,'546734567',strApplicableRoles);
            citizenExp = SSP_ResidentLogic.createUserinSF(usr,'234567788',strApplicableRoles);
            citizenExp = SSP_ResidentLogic.createUserinSF(usr,'546789023',strApplicableRoles);

        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR007'),true);  
        }
        SSP_ResidentLogic.citizenExceptionCapture citizenExp = new SSP_ResidentLogic.citizenExceptionCapture();
        citizenExp = SSP_ResidentLogic.createUserinSF(usr,'6456748',strApplicableRoles);
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
        String strApplicableRoles = 'Citizen_Individual';
        
        test.startTest();
        //SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
        // added for test
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        
        // end
        try{
            SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= SSP_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            SSP_ResidentLogic.citizenExceptionCapture citizenExp = new SSP_ResidentLogic.citizenExceptionCapture();
            citizenExp = SSP_ResidentLogic.createUserinSF(usr,'7867567531',strApplicableRoles);
            SSP_ResidentLogic.updateUserinSF(usr,'7867567531');
             
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
       
        String strApplicableRoles = 'Citizen_Individual';
            
        test.startTest();
        try{
            SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= SSP_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            SSP_ResidentLogic.createUserinSF(usr,'6456747',strApplicableRoles); 
            
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
        String strApplicableRoles = 'Citizen_Individual';
        
        test.startTest();
        try{
            SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= SSP_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            SSP_ResidentLogic.createUserinSF(usr,'6456747',strApplicableRoles);
            
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
        Contact con2 = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName2',LastName = 'LastName2',Email = 'test2@email.com',SSN__C = null);
        insert con2;
        
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('SSN','123456');
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr = new User(ProfileId = prof[0].id,ContactId = con.Id,Alias = 'gweygru',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = '1234567890' ,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest');
        insert usr;
        User usr2 = new User(ProfileId = prof[0].id,ContactId = con2.Id,Alias = 'gweygru',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',FederationIdentifier = null ,FirstName = 'FirstName2',LastName = 'LastName2',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con2.Email+'.idetest2');
        insert usr2;
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        
        List<sObject> sObjectList = new List<sObject>();
        sObject sObj = cm;
        sObjectList.add(cm);
        test.startTest();
        try{
            SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= SSP_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        returnResultMCIwrapper.setIeesIds.add(234567788);
            SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            SSP_ResidentLogic.updateUserinSF(usr,'1234567890'); 
            SSP_ResidentLogic.insertListSObject(sObjectList,'1234567890');
            SSP_ResidentLogic.insertListSObject(new List<sObject>(),'1234567890');
            SSP_ResidentLogic.updateContact(con2.Id,paramMap);
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
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        
        test.startTest();
        try{
            SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper= SSP_ResidentLogic.getIndividualInfo('7867567530',usr,'Kog');
        
        returnResultMCIwrapper.setIeesIds.add(786756751);
        
            SSP_ResidentLogic.getIndividualInfo('45566', usr, 'Kog');
            SSP_ResidentLogic.updateUserinSF(usr,'1234567890');
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
            SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            SSP_ResidentLogic.updateUserinSF(usr,'1234567890');
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
            SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
            SSP_ResidentLogic.updateUserinSF(usr,'1234567890'); 
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
            SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
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
        String strApplicableRoles = 'Citizen_Individual';
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567892);
        insert cm;
        test.startTest();
        try{
            SSP_ResidentLogic.createUserinSF(usr,'6456747',strApplicableRoles);
            usr.LastName='';
            SSP_ResidentLogic.createUserinSF(usr,'64567471',strApplicableRoles);
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
        
        String strApplicableRoles = 'Citizen_Individual';
        
        test.startTest();
        try {
            SSP_ResidentLogic.createUserinSF(usr,'6456747',strApplicableRoles);
        }catch (Exception e) {
            
            System.assert(e.getMessage().contains('ERR005'),false);
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
        User usr2 = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=null);
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm;
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm1;
       String strApplicableRoles = 'Citizen_Individual'; 
        
        test.startTest();
        try{
            SSP_ResidentLogic.citizenExceptionCapture capture= SSP_ResidentLogic.createUserinSF(usr,'6456747',strApplicableRoles);
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
        String strApplicableRoles = 'Citizen_Individual';
        
        test.startTest();
        try{
              SSP_ResidentLogic.citizenExceptionCapture capture= SSP_ResidentLogic.createUserinSF(usr,'6456747',strApplicableRoles);
        }catch(Exception e){
            
            System.assert(e.getMessage().contains('null'),false);
        }
      
        
        
        test.stopTest();
    }
    
    @isTest
    public static void createCitizenUserTest(){  
        
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        insert con;
        
         String strApplicableRoles = 'Citizen_Individual';
        String federationId = '4567-4567-12346-67890';
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(KOG_Role__c = 'Citizen',FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest',ContactId=con.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        
        
        //SSP_ResidentLogic.createCitizenUser(usr,federationId,con,strApplicableRoles);
        //SSP_ResidentLogic.createDifferentUser(usr,federationId,con);
    }
    
    @isTest
    public static void assignpermissionset(){  
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con = new Contact(FirstName = 'testforstname',LastName = 'TestLastName',PermissionsLevel__c='Admin',Status__c='Active',TrainingLevel__c='Complete',RecordTypeId = objRecordType.Id);
        insert con;
        Contact con2 = new Contact(FirstName = 'testforstname',LastName = 'TestLastName',PermissionsLevel__c='Staff',Status__c='Active',TrainingLevel__c='Complete',RecordTypeId = objRecordType.Id);
        insert con2;
        
        user usr2 = new user();
        usr2.FirstName = 'ganekahsk';
        usr2.username = 'usrname88@test.com';
        usr2.lastname = 'lasdyug';
        usr2.email='emailredtype@test.com';
        usr2.Alias = 'alisa12';
        usr2.LanguageLocaleKey='en_US';
        usr2.LocaleSidKey = 'en_US';
        
        usr2.ContactId = con2.id;
        usr2.FederationIdentifier = '';
        
        user usr = new user();
        usr.FirstName = 'ganekahsk';
        usr.username = 'usrname88@test.com';
        usr.lastname = 'lasdyug';
        usr.email='emailredtype@test.com';
        usr.Alias = 'alisa12';
        usr.LanguageLocaleKey='en_US';
        usr.LocaleSidKey = 'en_US';
        
        usr.TimeZoneSidKey = 'America/New_York';
        usr.EmailEncodingKey = 'UTF-8';
        usr.ContactId = con.id;
        usr.FederationIdentifier = '7686-23465-23765';
        usr.ApplicableRoles__c = 'Citizen_Individual';
        List<profile> prof = [Select Id from Profile where Name =: SSP_GlobalConstants.RE_CITIZEN_PROFILE];
        usr.ProfileId = prof[0].Id;
        
        String strApplicableRoles = 'Citizen_Individual';
        insert usr;
        List<string> lstKogroles = new List<String>{'Citizen'};
        List<string> lstKogrolesfail = new List<String>{''};
        SSP_ResidentLogic.assignPermissionsetClone(usr.FederationIdentifier,lstKogroles );
        SSP_ResidentLogic.assignPermissionsetClone(usr2.FederationIdentifier,lstKogrolesfail );
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        try{
              SSP_ResidentLogic.createDifferentUser(usr,usr.FederationIdentifier,con,strApplicableRoles);
        }catch(Exception e){
            
           System.assert(e.getMessage().contains('ERR014'),false);
        }
        
        
    }

}