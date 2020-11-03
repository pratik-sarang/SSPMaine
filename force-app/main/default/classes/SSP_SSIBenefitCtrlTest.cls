/*
* classname 		: SSP_SSIBenefitCtrlTest
* @description 		: This is the Test class for SSP_SSIBenefitCtrl class.
* @author 			: Sai Kiran
* @date 			: 01/10/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest
public class SSP_SSIBenefitCtrlTest {
    
    @testSetup static void testSetUpData() {
        //SSP_TestDataFactory.setupTestData();
        RecordType objAccountRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'Citizen' AND SobjectType = 'Account' LIMIT 1];
        RecordType objContactRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'Citizen' AND SobjectType = 'Contact' LIMIT 1];
        Account objAccount = new Account(Name = 'CitizenAccount', RecordTypeId = objAccountRecordType.ID);
        insert objAccount;
        Contact objContact = new Contact(FirstName = 'Citizen', LastName = 'Contact', RecordTypeId = objContactRecordType.Id, ZipCode__c = 11570, MailingPostalCode = '11570');
        insert objContact;
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c= objAccount.Id;        
        lstAppln[0].Contact__c = objContact.Id;
        insert lstAppln;
        SSP_Member__c sspMember = new SSP_Member__c();
        sspMember.Name = 'sspMemner';
        sspMember.Contact__c = objContact.Id;
        sspMember.ReceivesSSIBenefitsToggle__c = 'Y';
        insert sspMember;
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=sspMember.Id;
        insert lstAppInd;
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        SSP_Benefits__c sspBenefits6= new SSP_Benefits__c();
        sspBenefits6.SSP_Member__c = sspMember.Id;
        sspBenefits6.Name = 'Benefit Name';
        sspBenefits6.StatusofApplication__c='AE';
        sspBenefits6.BenefitDenialReason__c='O';
        sspBenefits6.BenefitApplicationDate__c = System.today();
        sspBenefits6.BenefitDenialDate__c = System.today().addMonths(1);
        sspBenefits6.RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Benefits__c','SSIBenefits');
        lstBenefits.add(sspBenefits6);
        insert lstBenefits;
    }
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    @isTest
    public static void fetchSSIBenefitsTest(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        Contact objContact = [SELECT ID FROM Contact LIMIT 1];
        User usr = SSP_TestDataFactory.createPortalUserOnContact(objContact.Id);
        //User usr  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(usr){
            lighningResponse = SSP_SSIBenefitCtrl.fetchSSIBenefits(sspMember.Id);
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
        
    }
    /*@isTest
    public static void fetchSSIBenefitsTest1(){
        SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        Contact objContact = [SELECT ID FROM Contact LIMIT 1];
        User usr = SSP_TestDataFactory.createPortalUserOnContact(objContact.Id);
        //User usr  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(usr){
            lighningResponse = SSP_SSIBenefitCtrl.fetchSSIBenefits('12345');
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
        
    }*/
    @isTest
    public static void updateSSIBenefitsTest(){
		SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_SSIBenefitWrapper ssiBenefitWrapper = new SSP_SSIBenefitWrapper();
        ssiBenefitWrapper.dBenefitApplicationDate = System.today();
        ssiBenefitWrapper.dBenefitDenialDate = System.today().addMonths(1);
        ssiBenefitWrapper.sApplicationStatus = 'DN';
        ssiBenefitWrapper.sBenefitDenialReason = 'O';
        ssiBenefitWrapper.sMemberId = sspMember.Id;
        Contact objContact = [SELECT ID FROM Contact LIMIT 1];
        User usr = SSP_TestDataFactory.createPortalUserOnContact(objContact.Id);
        //User usr  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(usr){
            lighningResponse = SSP_SSIBenefitCtrl.updateSSIBenefits(JSON.serialize(ssiBenefitWrapper));
        }
        System.assertEquals(true, lighningResponse.bIsSuccess);
            
    }
    
    @isTest
    public static void updateSSIBenefitsTest1(){
		SSP_LightningResponse lighningResponse = new SSP_LightningResponse();
        SSP_Member__c sspMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_SSIBenefitWrapper ssiBenefitWrapper = new SSP_SSIBenefitWrapper();
        ssiBenefitWrapper.dBenefitApplicationDate = System.today();
        ssiBenefitWrapper.dBenefitDenialDate = System.today().addMonths(1);
        ssiBenefitWrapper.sApplicationStatus = 'DN';
        ssiBenefitWrapper.sBenefitDenialReason = 'O';
        ssiBenefitWrapper.sMemberId = sspMember.Id;
        Contact objContact = [SELECT ID FROM Contact LIMIT 1];
        User usr = SSP_TestDataFactory.createPortalUserOnContact(objContact.Id);
        //User usr  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(usr){
            lighningResponse = SSP_SSIBenefitCtrl.updateSSIBenefits('ssiBenefitWrapper');
        }
        System.assertEquals(false, lighningResponse.bIsSuccess);
            
    }
    @isTest
    public static void queueRuleTest(){
        SSP_SSIBenefitQueueRule queueRule = new SSP_SSIBenefitQueueRule();
        Boolean isRequired = false;
        Contact objContact = [SELECT ID FROM Contact LIMIT 1];
        User usr = SSP_TestDataFactory.createPortalUserOnContact(objContact.Id);
        //User usr  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        SSP_Member__c objMember = [SELECT ID FROM SSP_Member__c Limit 1];
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        QueuingWrapper queWrap = new QueuingWrapper();
        ctxData.MemberId = objMember.Id;
        SSP_ApplicationIndividual__c objAppInd = [Select ID, SSP_Member__c, ProgramsApplied__c,SSP_Member__r.ReceivesSSIBenefitsToggle__c From SSP_ApplicationIndividual__c LIMIT 1];
        memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        ctxData.queueObject = queWrap;
        System.runAs(usr){
            isRequired = queueRule.isRequired(ctx, ctxData);
        }
    }

}