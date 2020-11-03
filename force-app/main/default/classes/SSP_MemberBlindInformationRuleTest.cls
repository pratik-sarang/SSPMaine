/*
* classname 	: SSP_MemberBlindInformationRuleTest
* @description 	: A test class for SSP_MemberBlindInformationRule class.
* @author 		: Shivam Tiwari
* @date 		: DEC-23-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 				DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Shivam Tiwari 		DEC-23-2019			Initial Version
*/
@isTest
public class SSP_MemberBlindInformationRuleTest {
    
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
        members[0].IsBlindToggle__c = SSP_GlobalConstants.NO;
        members[1].IsBlindToggle__c = SSP_GlobalConstants.YES;
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
        String memberId = getmemberId(SSP_GlobalConstants.YES);
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
        Context ctx = new Context();
        Test.startTest();
        Boolean result = new SSP_MemberBlindInformationRule().isRequired(ctx, ctxData);
        System.assert(result);
        
        Boolean result1 = new SSP_MemberBlindInformationRule().isRequired(null, null);
        System.assertEquals(result1, false);
        Test.stopTest();
	}
    
    private static String getmemberId(String isBlind){
        return ([SELECT Id FROM SSP_Member__c WHERE IsBlindToggle__c = :isBlind LIMIT 1].Id);
    }
    
    private static Id queryApplication(){
        return ([SELECT Id FROM SSP_Application__c LIMIT 1].Id);
    }
    
    private static SSP_ApplicationIndividual__c queryApplicationIndividual(String applicationId, String memberId){
        return ([SELECT Id, ProgramsApplied__c, SSP_Member__r.IsBlindToggle__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :applicationId AND SSP_Member__c = :memberId LIMIT 1]);
    }

}