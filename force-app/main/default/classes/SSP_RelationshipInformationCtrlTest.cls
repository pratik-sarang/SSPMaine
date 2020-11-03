/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_RelationshipInformationCtrlTest
*   Created By   :   Shivam Tiwari
*   Created Date :   12/16/2019
*   Description  :   Test class for SSP_RelationshipInformationController
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Shivam                   12/16/2019     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_RelationshipInformationCtrlTest {
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   setup
    * @description  Data creation for test class
    * @param        none
    * @return       none
    ********************************************************************************************/
   

    @TestSetup 
    public static void setup(){
        List<Account> accList = SSP_TestDataFactory.createAccounts(1, false);
        Account acc = accList.get(0);
        insert acc;
       
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Contact objCitizenContact = SSP_TestDataFactory.createContactRecord('Citizen', 'User', 'citizen@abc.xyz1', contactRecordTypeId, false);
        objCitizenContact.accountId = acc.Id;
        insert objCitizenContact;
        User objCitizenUser = SSP_TestDataFactory.createCommunityUser('sspC', objCitizenContact.Id,'citizen@abc.xyz1', 'RE Citizen Profile', true);
        Id RecordTypeIdApplication = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','SSP_Application');
        Id RecordTypeIdAccount = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen');
        Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
        
        Account account = SSP_TestDataFactory.createAccounts(1, false)[0];
        account.RecordTypeId = RecordTypeIdAccount;
        account.Name = 'Test Account';
        insert account;
        
        Account account1 = SSP_TestDataFactory.createAccounts(1, false)[0];
        account1.RecordTypeId = RecordTypeIdAccount;
        account1.Name = 'Test Account1';
        insert account1;
        
        Account account2 = SSP_TestDataFactory.createAccounts(1, false)[0];
        account2.RecordTypeId = RecordTypeIdAccount;
        account2.Name = 'Test Account2';
        insert account2;
        
        Contact contact1 = SSP_TestDataFactory.createContacts(1, false)[0];
        contact1.LastName = 'Contact1';
        contact1.FirstName = 'Test1';
        contact1.AccountId = account1.Id;
        contact1.PermissionsLevel__c = 'Admin';
        contact1.Status__c = 'Active';
        contact1.TrainingLevel__c = 'Complete';
        insert contact1;
        
        Contact contact2 = SSP_TestDataFactory.createContacts(1, false)[0];
        contact2.LastName = 'Contact2';
        contact2.FirstName = 'Test2';
        contact2.AccountId = account2.Id;
        contact2.PermissionsLevel__c = 'Admin';
        contact2.Status__c = 'Active';
        contact2.TrainingLevel__c = 'Complete';
        insert contact2;
        
        AccountContactRelation acrCitizen = new AccountContactRelation(); 
        acrCitizen.Accountid = account.Id;
        acrCitizen.Contactid = objCitizenContact.Id;
        acrCitizen.IsActive = true;
        insert acrCitizen;
        
        AccountContactRelation acrCitizen1 = new AccountContactRelation(); 
        acrCitizen1.Accountid = account1.Id;
        acrCitizen1.Contactid = objCitizenContact.Id;
        acrCitizen1.IsActive = true;
        insert acrCitizen1;
        
        AccountContactRelation acrCitizen2 = new AccountContactRelation(); 
        acrCitizen2.Accountid = account2.Id;
        acrCitizen2.Contactid = objCitizenContact.Id;
        acrCitizen2.IsActive = true;
        insert acrCitizen2;
        
        AccountContactRelation acr1 = new AccountContactRelation(); 
        acr1.Accountid = account.Id;
        acr1.Contactid = contact1.Id;
        acr1.IsActive = true;
        insert acr1;
        
        AccountContactRelation acr2 = new AccountContactRelation(); 
        acr2.Accountid = account.Id;
        acr2.Contactid = contact2.Id;
        acr2.IsActive = true;
        insert acr2;
        
        SSP_Application__c application = SSP_TestDataFactory.createSSPApplications(1, false)[0];
        application.RecordTypeId = RecordTypeIdApplication;
        application.Account__c = account.Id;
        application.ProgramsApplied__c = 'CC;DS;SS';
        insert application;
        
        SSP_Member__c member = SSP_TestDataFactory.createSSPMembers(1, false)[0];
        member.Name = 'Test Member';
        member.Contact__c = contact1.Id;
        member.GenderCode__c = 'F';
        insert member;
        
        SSP_Member__c member1 = SSP_TestDataFactory.createSSPMembers(1, false)[0];
        member1.Name = 'Test Member1';
        member1.Contact__c = contact2.Id;
        member1.GenderCode__c = 'M';
        insert member1;
        
        SSP_Relationship__c relation = new SSP_Relationship__c();
        relation.Name = 'Test Relation';
        relation.SSP_Member__c = member.Id;
        relation.SSP_MemberRelatedTo__c = member1.Id;
        relation.RecordTypeId = RecordTypeIdRelation;
        insert relation;
        
        SSP_ApplicationIndividual__c appInd = SSP_TestDataFactory.createApplicationIndividuals(1, false)[0];
        appInd.Name = 'test App Ind';
        appInd.SSP_Application__c = application.Id;
        appInd.SSP_Member__c = member.Id;
        appInd.MemberProgramsApplied__c = 'CC;DS;SS';
        insert appInd;
        
        SSP_ApplicationIndividual__c appInd1 = SSP_TestDataFactory.createApplicationIndividuals(1, false)[0];
        appInd1.Name = 'test App Ind';
        appInd1.SSP_Application__c = application.Id;
        appInd1.SSP_Member__c = member1.Id;
        appInd1.MemberProgramsApplied__c = 'CC;DS;SS';
        insert appInd1;

        SSP_TestDataFactory.setupTestData();
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].RecordTypeId = RecordTypeIdAccount;
        lstAcc[0].Name = 'Test Account5';
        insert lstAcc[0];
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
        lstMem[0].Name = 'Test Rel1';       
        insert lstMem;
        
        List<SSP_Member__c> lstMem1 = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem1[0].contact__c=lstCon[0].Id;
        lstMem1[0].Name ='Test Rel';
        insert lstMem1;
        
        SSP_Relationship__c SSPrelation = new SSP_Relationship__c();
        SSPrelation.Name = 'Test Relation2';
        SSPrelation.SSP_Member__c = lstMem1[0].Id;
        SSPrelation.SSP_MemberRelatedTo__c = lstMem1[0].Id;
        SSPrelation.RecordTypeId = RecordTypeIdRelation;
        insert SSPrelation;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
        
        List<SSP_ApplicationIndividual__c> lstAppInd1 = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd1[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd1[0].SSP_Member__c=lstMem1[0].Id;
        insert lstAppInd1;
        
        
    }   
		 
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   getRelativesTest1
    * @description  Test class for getRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void getRelativesTest1(){
        User citizen  = citizenUser();
        SSP_Member__c member = getMember();
        SSP_Member__c member1 = getMember1();
        SSP_Application__c application = getApplication('Test Account');
        SSP_Relationship__c relation = [SELECT Id, SSP_Member__c FROM SSP_Relationship__c WHERE Name = 'Test Relation' LIMIT 1];    
        delete relation;
        Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
        SSP_Relationship__c reverseRelation = new SSP_Relationship__c();
        reverseRelation.Name = 'Test Reverse Relation1';
        reverseRelation.SSP_Member__c = member1.Id;
        reverseRelation.SSP_MemberRelatedTo__c = member.Id;
        reverseRelation.RecordTypeId = RecordTypeIdRelation;
        reverseRelation.RelationshipType__c = 'UR';
        insert reverseRelation; 
        System.runAs(citizen){
            Test.startTest();
            SSP_LightningResponse lr = SSP_RelationshipInformationController.getRelatives(member.Id, application.Id);
            Test.stopTest(); 
            List<SSP_RelationshipWrapper> retrievedRelList = (List<SSP_RelationshipWrapper>)lr.mapResponse.get('relativesWrapperList'); 
            SSP_RelationshipWrapper retrievedRel;
            if(!retrievedRelList.isEmpty()){
                retrievedRel = retrievedRelList[0];
            }
            System.assertEquals(retrievedRel.showQuestionPursueLegalCustody, true); 
        }
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   getRelativesTest2
    * @description  Test class for getRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void getRelativesTest2(){
        User citizen  = citizenUser();
        SSP_Member__c member = getMember();
        SSP_Member__c member1 = getMember1();
        SSP_Application__c application = getApplication('Test Account');
        Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
        SSP_Relationship__c reverseRelation = new SSP_Relationship__c();
        reverseRelation.Name = 'Test Reverse Relation2';
        reverseRelation.SSP_Member__c = member1.Id;
        reverseRelation.SSP_MemberRelatedTo__c = member.Id;
        reverseRelation.RecordTypeId = RecordTypeIdRelation;
        reverseRelation.RelationshipType__c = 'SP';
        insert reverseRelation;
        SSP_ApplicationIndividual__c appInd = getApplicationIndividual(member1.Id);
        appInd.MemberProgramsApplied__c = 'DS;SS';
        update appInd;
        member1.GenderCode__c = 'M';
        update member1;
        System.runAs(citizen){
            Test.startTest();
            SSP_LightningResponse lr = SSP_RelationshipInformationController.getRelatives(member.Id, application.Id);
            Test.stopTest();
            List<SSP_RelationshipWrapper> retrievedRelList = (List<SSP_RelationshipWrapper>)lr.mapResponse.get('relativesWrapperList'); 
            SSP_RelationshipWrapper retrievedRel;
            if(!retrievedRelList.isEmpty()){
                retrievedRel = retrievedRelList[0];
            }
            System.assertEquals(retrievedRel.showQuestionPursueLegalCustody, false);
        }   
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   getRelativesTest3
    * @description  Test class for getRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void getRelativesTest3(){
        User citizen  = citizenUser();
        SSP_Member__c member = getMember();
        SSP_Member__c member1 = getMember1();
        SSP_Application__c application = getApplication('Test Account');
        application.ProgramsApplied__c = 'CC';
        update application;
        Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
        SSP_Relationship__c reverseRelation = new SSP_Relationship__c();
        reverseRelation.Name = 'Test Reverse Relation2';
        reverseRelation.SSP_Member__c = member1.Id;
        reverseRelation.SSP_MemberRelatedTo__c = member.Id;
        reverseRelation.RecordTypeId = RecordTypeIdRelation;
        reverseRelation.RelationshipType__c = 'SP';
        insert reverseRelation;
        member1.GenderCode__c = 'F';
        update member1;
        System.runAs(citizen){
            Test.startTest();
            SSP_LightningResponse lr = SSP_RelationshipInformationController.getRelatives(member.Id, application.Id);
            Test.stopTest();
            List<SSP_RelationshipWrapper> retrievedRelList = (List<SSP_RelationshipWrapper>)lr.mapResponse.get('relativesWrapperList'); 
            SSP_RelationshipWrapper retrievedRel;
            if(!retrievedRelList.isEmpty()){
                retrievedRel = retrievedRelList[0];
            }
            System.assertEquals(retrievedRel.showQuestionPursueLegalCustody, false);
        }   
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   getRelativesTest4
    * @description  Test class for getRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void getRelativesTest4(){
        User citizen  = citizenUser();
        SSP_Member__c member = getMember();
        SSP_Member__c member1 = getMember1();
        SSP_Application__c application = getApplication('Test Account');
        Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
        SSP_Relationship__c relation = [SELECT Id, SSP_Member__c FROM SSP_Relationship__c WHERE Name = 'Test Relation' LIMIT 1];    
        delete relation;
        SSP_Relationship__c reverseRelation = new SSP_Relationship__c();
        reverseRelation.Name = 'Test Reverse Relation2';
        reverseRelation.SSP_Member__c = member1.Id;
        reverseRelation.SSP_MemberRelatedTo__c = member.Id;
        reverseRelation.RecordTypeId = RecordTypeIdRelation;
        reverseRelation.RelationshipType__c = 'SP';
        insert reverseRelation;
        SSP_ApplicationIndividual__c appInd = getApplicationIndividual(member1.Id);
        appInd.MemberProgramsApplied__c = 'CC';
        update appInd;
        member.GenderCode__c = 'M';
        update member;
        System.runAs(citizen){
            Test.startTest();
            SSP_LightningResponse lr = SSP_RelationshipInformationController.getRelatives(member.Id, application.Id);
            Test.stopTest();
            List<SSP_RelationshipWrapper> retrievedRelList = (List<SSP_RelationshipWrapper>)lr.mapResponse.get('relativesWrapperList'); 
            SSP_RelationshipWrapper retrievedRel;
            if(!retrievedRelList.isEmpty()){
                retrievedRel = retrievedRelList[0];
            }
            System.assertEquals(retrievedRel.showQuestionPursueLegalCustody, false);
        }   
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         03/08/2020
    * @methodname   getRelativesTest5
    * @description  Test class for getRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void getRelativesTest5(){
        User citizen  = citizenUser();
        SSP_Member__c member = getMember();
        SSP_Member__c member1 = getMember1();
        SSP_Application__c application = getApplication('Test Account');
        Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
        SSP_Relationship__c relation = [SELECT Id, SSP_Member__c FROM SSP_Relationship__c WHERE Name = 'Test Relation' LIMIT 1];    
        delete relation;
        SSP_ApplicationIndividual__c appInd = getApplicationIndividual(member1.Id);
        appInd.MemberProgramsApplied__c = 'CC';
        update appInd;
        member.GenderCode__c = 'M';
        update member;
        System.runAs(citizen){
            Test.startTest();
            SSP_LightningResponse lr = SSP_RelationshipInformationController.getRelatives(member.Id, application.Id);
            Test.stopTest();
            List<SSP_RelationshipWrapper> retrievedRelList = (List<SSP_RelationshipWrapper>)lr.mapResponse.get('relativesWrapperList'); 
            SSP_RelationshipWrapper retrievedRel;
            if(!retrievedRelList.isEmpty()){
                retrievedRel = retrievedRelList[0];
            }
            System.assertEquals(retrievedRel.showQuestionPursueLegalCustody, false);
        }   
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         03/08/2020
    * @methodname   getRelativesTest6
    * @description  Test class for getRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void getRelativesTest6(){
        User citizen  = citizenUser();
        SSP_Member__c member = getMember();
        SSP_Member__c member1 = getMember1();
        SSP_Application__c application = getApplication('Test Account');
        System.runAs(citizen){
            Test.startTest();
            SSP_LightningResponse lr = SSP_RelationshipInformationController.getRelatives(member.Id, member.Id);
            Test.stopTest();
            List<SSP_RelationshipWrapper> retrievedRelList = (List<SSP_RelationshipWrapper>)lr.mapResponse.get('relativesWrapperList'); 
            SSP_RelationshipWrapper retrievedRel;
            if(!retrievedRelList.isEmpty()){
                retrievedRel = retrievedRelList[0];
            }
            System.assertEquals(retrievedRel, null);
        }   
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   saveRelativesTest
    * @description  Test class for saveRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void saveRelativesTest(){
        User citizen  = citizenUser();
        System.runAs(citizen){
            SSP_Member__c member = getMember();
            SSP_Member__c member1 = getMember1();
            SSP_Application__c application = getApplication('Test Account');
            SSP_Relationship__c relation = [SELECT Id, SSP_Member__c FROM SSP_Relationship__c WHERE Name = 'Test Relation' LIMIT 1];
            Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
            relation = updateRelation(relation);
            SSP_Relationship__c reverseRelation = new SSP_Relationship__c();
            reverseRelation.Name = 'Test Reverse Relation2';
            reverseRelation.SSP_Member__c = member1.Id;
            reverseRelation.SSP_MemberRelatedTo__c = member.Id;
            reverseRelation.RecordTypeId = RecordTypeIdRelation;
            reverseRelation.RelationshipType__c = 'MO';
            insert reverseRelation;
            String jsString = createWrapper(relation, member1.Id);
            Test.startTest();
            SSP_RelationshipInformationController.saveRelatives(member.Id, application.Id, jsString,'Intake');
            Test.stopTest();
            SSP_Relationship__c retrievedRel;
            if(member.Id != Null){
                retrievedRel = getRelative(member.Id);
            }
            System.assertEquals(retrievedRel.RelationshipType__c , relation.RelationshipType__c);
        }
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   saveRelativesTest1
    * @description  Test class for saveRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void saveRelativesTest1(){
        User citizen  = citizenUser();
        System.runAs(citizen){
            SSP_Member__c member = getMember();
            SSP_Member__c member1 = getMember1();
            SSP_Application__c application = getApplication('Test Account');
            Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
            SSP_Relationship__c relation = [SELECT Id, SSP_Member__c FROM SSP_Relationship__c WHERE Name = 'Test Relation' LIMIT 1];    
            delete relation;
            SSP_RelationshipWrapper wrap = new SSP_RelationshipWrapper();
            wrap.memberId = member1.Id;
            wrap.isActingParent = 'Y';
            wrap.isCareTaker = 'Y';
            wrap.relationshipType = 'MO';
            wrap.intendToPursueLegalCustody = 'Y'; 
            List<SSP_RelationshipWrapper> wrapList = new List<SSP_RelationshipWrapper>();
            wrapList.add(wrap);
            String retString = JSON.serialize(wrapList);
            
            Test.startTest();
            SSP_RelationshipInformationController.saveRelatives(member.Id, application.Id, retString,'Intake');
            Test.stopTest();
            SSP_Relationship__c retrievedRel;
            if(member.Id != Null){
                retrievedRel = getRelative(member.Id);
            }
            System.assertEquals(retrievedRel.RelationshipType__c , 'MO');
        }
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         08/03/2020
    * @methodname   saveRelativesTest3
    * @description  Test class for saveRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void saveRelativesTest3(){
        User citizen  = citizenUser();
        System.runAs(citizen){
            SSP_Member__c member = getMember();
            SSP_Member__c member1 = getMember1();
            SSP_Application__c application = getApplication('Test Account');
            SSP_Relationship__c relation = [SELECT Id, SSP_Member__c FROM SSP_Relationship__c WHERE Name = 'Test Relation' LIMIT 1];
            Date todayDate = SSP_Utility.today();
            DATE dob = todayDate.addYears(-18);
            member.BirthDate__c = dob;
            update member;
            Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
            SSP_Relationship__c reverseRelation = new SSP_Relationship__c();
            reverseRelation.Name = 'Test Reverse Relation2';
            reverseRelation.SSP_Member__c = member1.Id;
            reverseRelation.SSP_MemberRelatedTo__c = member.Id;
            reverseRelation.RecordTypeId = RecordTypeIdRelation;
            reverseRelation.RelationshipType__c = 'SO';
            insert reverseRelation;
            SSP_RelationshipWrapper wrap = new SSP_RelationshipWrapper();
            wrap.memberId = member1.Id;
            wrap.isActingParent = 'Y';
            wrap.isCareTaker = 'Y';
            wrap.relationshipType = 'MO';
            wrap.intendToPursueLegalCustody = 'Y';
            List<SSP_RelationshipWrapper> wrapList = new List<SSP_RelationshipWrapper>();
            wrapList.add(wrap);
            String retString = JSON.serialize(wrapList);
            Test.startTest();
            SSP_RelationshipInformationController.saveRelatives(member.Id, application.Id, retString,'Intake');
            Test.stopTest();
            SSP_Relationship__c retrievedRel;
            if(member.Id != Null){
                retrievedRel = getRelative(member.Id);
            }
            System.assertEquals(retrievedRel.RelationshipType__c , wrap.relationshipType);
        }
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         08/03/2020
    * @methodname   saveRelativesTest4
    * @description  Test class for saveRelatives
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void saveRelativesTest4(){
        User citizen  = citizenUser();
        System.runAs(citizen){
            SSP_Member__c member = getMember();
            SSP_Member__c member1 = getMember1();
            SSP_Application__c application = getApplication('Test Account');
            SSP_Relationship__c relation = [SELECT Id, SSP_Member__c FROM SSP_Relationship__c WHERE Name = 'Test Relation' LIMIT 1];
            relation.RelationshipType__c = 'SP';
            update relation;
            Date todayDate = SSP_Utility.today();
            DATE dob = todayDate.addYears(-18);
            member1.BirthDate__c = dob;
            update member1;
            SSP_RelationshipWrapper wrap = new SSP_RelationshipWrapper();
            wrap.memberId = member1.Id;
            wrap.isActingParent = 'Y';
            wrap.isCareTaker = 'Y';
            wrap.relationshipType = 'MO';
            wrap.intendToPursueLegalCustody = 'Y'; 
            List<SSP_RelationshipWrapper> wrapList = new List<SSP_RelationshipWrapper>();
            wrapList.add(wrap);
            String retString = JSON.serialize(wrapList);
            Id RecordTypeIdRelation = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Relationship__c','Relationship');
            relation = updateRelation(relation);
            SSP_Relationship__c reverseRelation = new SSP_Relationship__c();
            reverseRelation.Name = 'Test Reverse Relation2';
            reverseRelation.SSP_Member__c = member1.Id;
            reverseRelation.SSP_MemberRelatedTo__c = member.Id;
            reverseRelation.RecordTypeId = RecordTypeIdRelation;
            reverseRelation.RelationshipType__c = 'SO';
            insert reverseRelation;
            String jsString = createWrapper(relation, member1.Id);
            Test.startTest();
            SSP_RelationshipInformationController.saveRelatives(member.Id, application.Id, retString,'Intake');
            Test.stopTest();
            SSP_Relationship__c retrievedRel;
            if(member.Id != Null){
                retrievedRel = getRelative(member.Id);
            }
            System.assertEquals(retrievedRel.RelationshipType__c , 'MO');
        }
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   createWrapper
    * @description  Creates Wrapper
    * @param        SSP_Relationship__c
    * @return       String
    ********************************************************************************************/
    private static String createWrapper(SSP_Relationship__c relation, Id memId){
        SSP_RelationshipWrapper wrap = new SSP_RelationshipWrapper();
        wrap.memberId = memId;
        wrap.isActingParent = relation.IsActingParentToggle__c;
        wrap.isCareTaker = relation.IsCareTakerToggle__c;
        wrap.relationshipType = relation.RelationshipType__c;
        wrap.intendToPursueLegalCustody = relation.IntendToPursueLegalCustodyToggle__c;
        
        List<SSP_RelationshipWrapper> wrapList = new List<SSP_RelationshipWrapper>();
        wrapList.add(wrap);
        String retString = JSON.serialize(wrapList);
        return retString;
    }
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         12/16/2019
    * @methodname   updateRelation
    * @description  Updates Relationship
    * @param        SSP_Relationship__c
    * @return       SSP_Relationship__c
    ********************************************************************************************/
    private static SSP_Relationship__c updateRelation(SSP_Relationship__c relation){
        relation.IsActingParentToggle__c = 'Y';
        relation.IsCareTakerToggle__c = 'Y';
        relation.IntendToPursueLegalCustodyToggle__c = 'Y';
        relation.RelationshipType__c = 'SP';
        update relation;
        return relation;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getMember
    * @description  retrieves Member
    * @param        void
    * @return       SSP_Member__c
    ********************************************************************************************/
    private static SSP_Member__c getMember(){
        return [Select Id FROM SSP_Member__c WHERE Name = 'Test Member' LIMIT 1];
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getMember1
    * @description  retrieves Member
    * @param        void
    * @return       SSP_Member__c
    ********************************************************************************************/
    private static SSP_Member__c getMember1(){
        return [Select Id FROM SSP_Member__c WHERE Name = 'Test Member1' LIMIT 1];
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getSaveMember
    * @description  retrieves Member
    * @param        void
    * @return       SSP_Member__c
    ********************************************************************************************/
    private static SSP_Member__c getSaveMember(){
        return [Select Id FROM SSP_Member__c WHERE Name = 'Test Rel' LIMIT 1];
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getApplication
    * @description  retrieves Application
    * @param        void
    * @return       SSP_Application__c
    ********************************************************************************************/
    private static SSP_Application__c getApplication(String accountName){
        return [SELECT Id FROM SSP_Application__c WHERE Account__r.Name =:accountName];
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getApplicationIndividual
    * @description  retrieves Application Individual
    * @param        Id
    * @return       SSP_ApplicationIndividual__c
    ********************************************************************************************/
    private static SSP_ApplicationIndividual__c getApplicationIndividual(Id memberId){
        return [Select Id, SSP_Member__c, ProgramsApplied__c From SSP_ApplicationIndividual__c where SSP_Member__c =: memberId];
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   citizenUser
    * @description  retrieves Citizen User
    * @param        void
    * @return       User
    ********************************************************************************************/
    private static User citizenUser(){
        return [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz1' LIMIT 1][0];
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getRelative
    * @description  retrieves Relationship
    * @param        Id
    * @return       SSP_Relationship__c
    ********************************************************************************************/
    private static SSP_Relationship__c getRelative(Id memberId){
        return [SELECT Id, IsCareTakerToggle__c, IsActingParentToggle__c, IntendToPursueLegalCustodyToggle__c, RelationshipType__c, SSP_MemberRelatedTo__c, SSP_Member__c FROM SSP_Relationship__c WHERE SSP_Member__c =: memberId];
    }
    
}