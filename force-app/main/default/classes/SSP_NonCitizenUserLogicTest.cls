@isTest
public class SSP_NonCitizenUserLogicTest {
    @isTest
    public static void createCitizenContact(){
        user usr = new user();
        usr.FirstName = 'FirstName';
        usr.LastName = 'LastName';
        usr.MiddleName = 'MiddleName';
        usr.FederationIdentifier = 'FederationIdentifier';
        usr.LanguageLocaleKey  = 'en-US';
        usr.Email = 'Email@test.com';
        usr.UserName = 'UserName@test.com';
        
        String federationIdentifier = 'FederationIdentifier';
        String RoleName = 'Citizen'; 
        //RecordType objAccountRecordType = GeneralUtility.fetchRecordType('CitizenAccount', 'Account'); //For DEV
        //RecordType objAccountRecordType = GeneralUtility.fetchRecordType('Citizen', 'Account'); //For SIT
        Id accountRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen');
        Account acc = new Account();
        acc.Name = usr.FirstName+' '+usr.LastName;
        acc.RecordTypeId = accountRecordTypeId;
        insert acc;
        
        //RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Contact con = new Contact();
        con.RecordTypeId = contactRecordTypeId;
        con.FirstName = usr.FirstName;  
        con.LastName = usr.LastName;
        con.Email = usr.Email;
        con.MiddleName = usr.MiddleName;
        con.PermissionsLevel__c = 'Admin';
        con.Status__c = 'Active';
        con.TrainingLevel__c = 'Complete';
        con.KOGSourceId__c = usr.FederationIdentifier; 
        con.AccountId  = acc.Id;
        insert con;
        List<String> lstRoles = new List<String>{'Assister'};
        SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper;
        
        try{
        User usrTest = SSP_NonCitizenUserLogic.createNonCitizenUser(usr,federationIdentifier,con,RoleName,lstRoles);
        Contact conTest = SSP_NonCitizenUserLogic.updateNonCitizenContact(con, returnResultMCIwrapper);
        User usrTest1 = SSP_NonCitizenUserLogic.updateNonCitizenUserinSF(usr,con.Name,federationIdentifier); 
        con.KOGSourceId__c = '1234'; 
        update con;
        usr.LanguageLocaleKey = 'es-Us';
        User usrTest2 = SSP_NonCitizenUserLogic.createNonCitizenUser(usr,'1234',con,RoleName,lstRoles);
        } catch(Exception e) {}
        try{
            WebServiceSettings__c mciConfig1 = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        	insert mciConfig1;
            User usrTest3 = SSP_NonCitizenUserLogic.createNonCitizenUserinSF(usr,'1234',RoleName,lstRoles,null); 
        }catch(Exception e){}
    }
    
    @isTest
    public static void createCitizenContact1(){
        user usr = new user();
        usr.FirstName = 'FirstName';
        usr.LastName = 'LastName';
        usr.MiddleName = 'MiddleName';
        usr.FederationIdentifier = 'FederationIdentifier';
        usr.LanguageLocaleKey  = 'en-US';
        usr.Email = 'Email@test.com';
        usr.UserName = 'UserName@test.com';
        
        String federationIdentifier = 'FederationIdentifier';
        String RoleName = 'Citizen';
        List<String> lstRoles = new List<String>{'Assister'};
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        SSP_NonCitizenUserLogic.createNonCitizenUserinSF(usr,federationIdentifier,RoleName,lstRoles, 'AgentId');
    }
    
     @isTest
    public static void createUserinSFWithIEESIds1(){
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        //RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con1 = new Contact(RecordTypeId = contactRecordTypeId, FirstName = 'FirstNameOne', LastName = 'LastNameOne',Email = 'testone@email.com' );
        insert con1;
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com' );
        //insert con;
        
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest',ContactId=con.Id);
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        
        Contact_Mapping__c cm = new Contact_Mapping__c(Group_Id__c = 'Grp123',IEES_Id__c = 234567788);//Contact__c = con.Id,
        //insert cm;
        
        List<String> strApplicableRoles = new List<String>{'Citizen_Individual'};
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Group_Id__c = 'Grp123',IEES_Id__c = 234567788, Contact__c= con1.Id);
        List<Contact_Mapping__c> cmList = new List<Contact_Mapping__c>(); 
        cmList.add(cm1);
        test.startTest();
        SSP_ResidentLogic.getIndividualInfo('1234', usr, 'Kog');
        // added for test
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        SSP_NonCitizenUserLogic.updateConMappingRecords(JSON.serialize(cmList));
        User u1 = new User();
        try{
            u1 = SSP_NonCitizenUserLogic.createNonCitizenUserinSF(usr,'546734567','Non Citizen',strApplicableRoles,null);
            u1 = SSP_NonCitizenUserLogic.createNonCitizenUserinSF(usr,'234567788','Non Citizen',strApplicableRoles,null);
            u1 = SSP_NonCitizenUserLogic.createNonCitizenUserinSF(usr,'546789023','Non Citizen',strApplicableRoles,null);
			
        }catch(Exception e){
           system.debug(e); 
        }
        test.stopTest();
    }
   
    
}