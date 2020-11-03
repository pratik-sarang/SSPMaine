/*
* classname 	: SSP_PregnancyQueueingRuleTest
* @description 	: A test class for SSP_PregnancyQueueingRule class.
* @author 		: Shivam Tiwari
* @date 		: DEC-19-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 				DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Shivam Tiwari 		DEC-19-2019			Initial Version
*/
@isTest
public class SSP_PregnancyQueueingRuleTest {
    
    @testSetup
    public static void dataSetup() {
        Integer n = 1;
        List<Account> accounts = SSP_TestDataFactory.createAccounts(n , true);
        List<Contact> contacts = SSP_TestDataFactory.createContacts(n , false);
        List<SSP_Application__c> applications = SSP_TestDataFactory.createSSPApplications(n, false);
        for(Integer i = 0; i < n; ++i) {
            contacts[i].AccountId = accounts[i].Id;
            applications[i].Account__c = accounts[i].Id;
		}
		insert applications;
        insert contacts;
        
        n = 2;
        List<SSP_Member__c> members = SSP_TestDataFactory.createSSPMembers(n, false);
        members[0].IsPregnantInLastThreeMonthsToggle__c = SSP_GlobalConstants.YES;
        members[0].GenderCode__c = SSP_GlobalConstants.FEMALE;
        
        members[1].IsPregnantInLastThreeMonthsToggle__c = SSP_GlobalConstants.NO;
        members[1].GenderCode__c = SSP_GlobalConstants.FEMALE;
        for(SSP_Member__c member : members) {
            member.Contact__c = contacts[0].Id;
        }
        insert members;
        
        List<SSP_ApplicationIndividual__c> individuals = SSP_TestDataFactory.createApplicationIndividuals(n, false);
        for(Integer i = 0; i < n; ++i) {
            individuals[i].SSP_Member__c = members[i].Id;
            individuals[i].SSP_Application__c = applications[0].Id;
            individuals[i].ProgramsApplied__c = 'MA;CC;SN';
        }
        insert individuals;
    }
    
    @isTest
    public static void unitTest1() {
        String memberId = queryMember(SSP_GlobalConstants.YES).Id;
        String applicationId = queryApplication();
        SSP_ApplicationIndividual__c appIndv = queryApplicationIndividual(applicationId, memberId);
        Map<String,SSP_ApplicationIndividual__c> memberAppIndMap = new Map<String,SSP_ApplicationIndividual__c>();
        memberAppIndMap.put(memberId, appIndv);
        QueuingWrapper qwrap = new QueuingWrapper ();
        qwrap.memberAppIndividualMap = memberAppIndMap;
        ContextData ctxData = new ContextData();
        ctxData.ApplicationId = applicationId;
        ctxData.memberId = memberId;
        ctxData.queueObject = qwrap;
        Test.startTest();
        Boolean result = new SSP_PregnancyQueueingRule().isRequired(null, ctxData);
        System.assertEquals(result, true);
        
        boolean result1 = new SSP_PregnancyQueueingRule().isRequired(null, null);
        System.assertEquals(result1, false);
        Test.stopTest();
	}   
    
    private static SSP_Member__c queryMember(String IsPregnantInLastThreeMonths){
        return ([SELECT Id FROM SSP_Member__c WHERE IsPregnantInLastThreeMonthsToggle__c = :IsPregnantInLastThreeMonths LIMIT 1]);
    }
    
    private static Id queryApplication(){
        return ([SELECT Id FROM SSP_Application__c LIMIT 1].Id);
    }
    
    private static SSP_ApplicationIndividual__c queryApplicationIndividual(String applicationId, String memberId){
        return ([SELECT Id, ProgramsApplied__c, SSP_Member__r.GenderCode__c, SSP_Member__r.IsPregnantInLastThreeMonthsToggle__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :applicationId AND SSP_Member__c = :memberId LIMIT 1]);
    }

}