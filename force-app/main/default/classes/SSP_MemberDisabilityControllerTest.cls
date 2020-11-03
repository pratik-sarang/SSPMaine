/*
* classname     : SSP_MemberDisabilityControllerTest
* @description  : A test class for SSP_MemberDisabilityController class.
* @author       : Shivam Tiwari
* @date         : DEC-23-2019
* MODIFICATION LOG:
* DEVELOPER             DATE                DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Shivam Tiwari         DEC-23-2019         Initial Version
*/
@isTest
public class SSP_MemberDisabilityControllerTest {
    
    @testSetup
    public static void setup(){
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'TestAcc';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];     
        
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
        lstMem[0].Name='TestMember';
        lstMem[0].contact__c=lstCon[0].Id;        
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].Name='TestInd';
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
    }
    
    @isTest
    public static void fetchDisabilityInformationTest(){
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            List<SSP_ApplicationIndividual__c> appIndvList = getApplicationIndividuals(lstApps[0].Id);
            List<SSP_Member__c> lstMembers =  getMembers();
            Id memberId = null;
            for(SSP_Member__c mem : lstMembers){
                if(mem.Name == 'TestMember'){
                    memberId = mem.Id;
                    break;
                }
            }
            test.startTest();
                SSP_MemberDisabilityController.fetchDisabilityInformation(memberId, lstApps[0].Id, false);
            test.stopTest();
        }
    }
    
    @isTest
    public static void fetchBlindnessInformationTest(){
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            List<SSP_ApplicationIndividual__c> appIndvList = getApplicationIndividuals(lstApps[0].Id);
            List<SSP_Member__c> lstMembers =  getMembers();
            Id memberId = null;
            for(SSP_Member__c mem : lstMembers){
                if(mem.Name == 'TestMember'){
                    memberId = mem.Id;
                    break;
                }
            }
            test.startTest();
                SSP_MemberDisabilityController.fetchDisabilityInformation(memberId, lstApps[0].Id, true);
            test.stopTest();
        }
    }
    
    @isTest
    public static void saveDisabilityInformationTest(){
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            List<SSP_ApplicationIndividual__c> appIndvList = getApplicationIndividuals(lstApps[0].Id);
            List<SSP_Member__c> lstMembers =  getMembers();
            Id memberId = null;
            for(SSP_Member__c mem : lstMembers){
                if(mem.Name == 'TestMember'){
                    memberId = mem.Id;
                    break;
                }
            }
            SSP_MemberDisabilityWrapper wrap = wrapperObject();
            String wrapStr = JSON.serialize(wrap);
            test.startTest();
                SSP_MemberDisabilityController.saveDisabilityInformation(memberId, wrapStr, false);
            test.stopTest();
        }
    }
    
    @isTest
    public static void saveBlindnessInformationTest(){
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            List<SSP_ApplicationIndividual__c> appIndvList = getApplicationIndividuals(lstApps[0].Id);
            List<SSP_Member__c> lstMembers =  getMembers();
            Id memberId = null;
            for(SSP_Member__c mem : lstMembers){
                if(mem.Name == 'TestMember'){
                    memberId = mem.Id;
                    break;
                }
            }
            SSP_MemberDisabilityWrapper wrap = wrapperObject();
            String wrapStr = JSON.serialize(wrap);
            test.startTest();
                SSP_MemberDisabilityController.saveDisabilityInformation(memberId, wrapStr, true);
            test.stopTest();
        }
    }
    
    @isTest
    public static void saveDisabilityInformationTest1(){
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            List<SSP_ApplicationIndividual__c> appIndvList = getApplicationIndividuals(lstApps[0].Id);
            List<SSP_Member__c> lstMembers =  getMembers();
            Id memberId = null;
            for(SSP_Member__c mem : lstMembers){
                if(mem.Name == 'TestMember'){
                    memberId = mem.Id;
                    break;
                }
            }
            SSP_MemberDisabilityWrapper wrap = wrapperObject();
            wrap.hasEndStageRenalDisease = null;
            wrap.unableToBuyCookForSelf = null;
            wrap.parentUnableToCareForChild = null;
            String wrapStr = JSON.serialize(wrap);
            test.startTest();
                SSP_MemberDisabilityController.saveDisabilityInformation(memberId, wrapStr, false);
            test.stopTest();
        }
    }
    
    @isTest
    public static void saveBlindnessInformationTest1(){
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            List<SSP_ApplicationIndividual__c> appIndvList = getApplicationIndividuals(lstApps[0].Id) ;
            List<SSP_Member__c> lstMembers =  getMembers();
            Id memberId = null;
            for(SSP_Member__c mem : lstMembers){
                if(mem.Name == 'TestMember'){
                    memberId = mem.Id;
                    break;
                }
            }
            SSP_MemberDisabilityWrapper wrap = wrapperObject();
            wrap.hasEndStageRenalDisease = null;
            wrap.unableToBuyCookForSelf = null;
            wrap.parentUnableToCareForChild = null;
            String wrapStr = JSON.serialize(wrap);
            test.startTest();
                SSP_MemberDisabilityController.saveDisabilityInformation(memberId, wrapStr, true);
            test.stopTest();
        }
    }
    
    private static SSP_MemberDisabilityWrapper wrapperObject(){
        SSP_MemberDisabilityWrapper wrap = new SSP_MemberDisabilityWrapper();
        wrap.Id = null;
        wrap.memberFullName = 'Test Wrap';
        wrap.age = 50;
        wrap.benefitTypeCode = 'MA, SN, KT';
        wrap.hasEndStageRenalDisease = SSP_GlobalConstants.YES;
        wrap.unableToBuyCookForSelf = SSP_GlobalConstants.YES;
        wrap.parentUnableToCareForChild = SSP_GlobalConstants.YES;
        wrap.disabilityPermanentTemporary = 'Permanent';
        wrap.genderCode = 'F';
        wrap.programsApplied = 'SS';
        wrap.isNonMagi = true;
        return wrap;
    }
    
    private static List<SSP_Application__c> getApplications(){
        return ([SELECT Id  FROM SSP_Application__c LIMIT 1]);
    }
    
    private static User getCitizenUser(){
        return ([SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]);
    }
    
    private static List<SSP_ApplicationIndividual__c> getApplicationIndividuals(String appsId){
        return ([SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: appsId]);
    }
    
    private static List<SSP_Member__c> getMembers(){
        return ([SELECT Id, Name FROM SSP_Member__c LIMIT 50]);
    }
}