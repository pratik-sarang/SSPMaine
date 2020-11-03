/*
* classname     :  SSP_IncomeAndSubsidiesSelControllerTest
* @description  :  Test class for SSP_IncomeAndSubsidiesSelController
* @author       :  Shrikant Raut   
* @date         :  12/05/2019 
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_IncomeAndSubsidiesSelControllerTest {
    /**
    @author : Shrikant Raut
    Method to setup test data*/
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();    
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'IncomeController';
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
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].memberStatus__c = SSP_GlobalConstants.MEMBER_STATUS_New;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects(); 
        
        
    }

    private static User fetchCitizenUser(){
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_fetchIncomeSubsidiesDetails(){
        System.runAs(fetchCitizenUser()){
            List<SSP_ApplicationIndividual__c> appIndvList = (List<SSP_ApplicationIndividual__c>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c'}, new Map<String, String>{'SSP_Application__r.Account__r.Name'=>'IncomeController'});            
            
            List<SSP_Asset__c> assetList = (List<SSP_Asset__c>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'SSP_Asset__c'}, new Set<String>{'Id', 'Name', 'BusinessTypeCode__c', 'EmployerName__c', 'IsExistingData__c', 'Tips__c', 'IncomeTypeCode__c', 'IncomePayFrequency__c', 'TotalGrossAmount__c', 'IncomePayDetailHoursPerWeek__c'}, new Map<String, String>{'SSP_Member__c'=>appIndvList[0].SSP_Member__c});                                   
            
            test.startTest();
            SSP_LightningResponse response = SSP_IncomeAndSubsidiesSelController.fetchIncomeSubsidiesDetails(appIndvList[0].SSP_Application__c,'addRemoveMember');
            system.assertNotEquals(null, response.mapResponse);
            system.assert(response.mapResponse.containsKey('applicationIndividuals'));                        
            test.stopTest();
        }
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateRecords(){
        System.runAs(fetchCitizenUser()){
            Boolean result = true;
            List<SSP_Member__c> memberList = new List<SSP_Member__c>();
            Map<String, List<String>> changedFieldsJSON = new Map<String, List<String>>();
            Map<String, String> detailMap = new Map<String, String>();
            for(SSP_Member__c member : [SELECT Id, HasEarnedIncomeFromEmploymentToggle__c, HasInsuranceSettlementBenefitToggle__c, HasMaintenanceIncomeToggle__c, HasReceivedBenefitsFromOtherStateToggle__c, HasSelfEmploymentIncomeToggle__c, HasServicesorPaymentsToggle__c, HasUnearnedIncomeToggle__c, HasUnpaidEmploymentToggle__c, HasDividendsRoyaltiesToggle__c FROM SSP_Member__c LIMIT 50]){
                member.HasEarnedIncomeFromEmploymentToggle__c = 'Y';
                member.HasInsuranceSettlementBenefitToggle__c= 'Y';
                member.HasMaintenanceIncomeToggle__c= 'Y';
                member.HasReceivedBenefitsFromOtherStateToggle__c= 'Y';
                member.HasSelfEmploymentIncomeToggle__c= 'Y';
                member.HasServicesorPaymentsToggle__c= 'Y';
                member.HasUnearnedIncomeToggle__c= 'Y';
                member.HasUnpaidEmploymentToggle__c='Y';
                member.HasDividendsRoyaltiesToggle__c= 'Y';
                memberList.add(member);
                changedFieldsJSON.put(member.Id, new List<String>{'HasEarnedIncomeFromEmploymentToggle__c','HasInsuranceSettlementBenefitToggle__c','HasMaintenanceIncomeToggle__c','HasReceivedBenefitsFromOtherStateToggle__c',
                    'HasSelfEmploymentIncomeToggle__c','HasServicesorPaymentsToggle__c','HasUnearnedIncomeToggle__c','HasUnpaidEmploymentToggle__c','HasDividendsRoyaltiesToggle__c'});
            }
            
            List<SSP_Application__c> applicationList = [SELECT Id, IsReceivingHousingAssistanceToggle__c FROM SSP_Application__c LIMIT 10];            
            applicationList[0].IsReceivingHousingAssistanceToggle__c = 'Y';            
            detailMap.put('SSP_Member__c', JSON.serialize(memberList));
            detailMap.put('SSP_Application__c', JSON.serialize(applicationList));
            test.startTest();

            result = (SSP_IncomeAndSubsidiesSelController.updateRecords(JSON.serialize(detailMap), new Map<String, String>{'falseToTrue' => JSON.serialize(changedFieldsJSON)})).bIsSuccess;
                    
            for(SSP_Member__c member : [SELECT Id, HasEarnedIncomeFromEmploymentToggle__c, HasInsuranceSettlementBenefitToggle__c, HasMaintenanceIncomeToggle__c, HasReceivedBenefitsFromOtherStateToggle__c, HasSelfEmploymentIncomeToggle__c, HasServicesorPaymentsToggle__c, HasUnearnedIncomeToggle__c, HasUnpaidEmploymentToggle__c, HasDividendsRoyaltiesToggle__c FROM SSP_Member__c LIMIT 50]){                
                System.assertEquals(member.HasEarnedIncomeFromEmploymentToggle__c,'Y');
                System.assertEquals(member.HasInsuranceSettlementBenefitToggle__c,'Y');
                System.assertEquals(member.HasMaintenanceIncomeToggle__c,'Y');
                System.assertEquals(member.HasReceivedBenefitsFromOtherStateToggle__c,'Y');
                System.assertEquals(member.HasSelfEmploymentIncomeToggle__c,'Y');
                System.assertEquals(member.HasServicesorPaymentsToggle__c,'Y');
                System.assertEquals(member.HasUnearnedIncomeToggle__c,'Y');
                System.assertEquals(member.HasUnpaidEmploymentToggle__c,'Y');
                System.assertEquals(member.HasDividendsRoyaltiesToggle__c,'Y');
            }   
            system.assert(result);

            SSP_IncomeAndSubsidiesSelController.updateRecords(JSON.serialize(detailMap), new Map<String, String>{'trueToFalse' => JSON.serialize(changedFieldsJSON)});
            test.stopTest();
        }
    }


    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateRecords_False(){
        System.runAs(fetchCitizenUser()){
            Boolean result =true;
            test.startTest();

            result = (SSP_IncomeAndSubsidiesSelController.updateRecords('test', new Map<String, String>{'falseToTrue' => 'test'})).bIsSuccess;
            system.assert(!result);
            test.stopTest();
        }
    }


    
    
   
}