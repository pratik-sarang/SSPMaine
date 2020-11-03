@isTest
public with sharing class SSP_ExpensesSelectionQueueRule_test {
    @isTest
    public static void testIsRequired() {
        SSP_TestDataFactory.setupTestData();  
        test.startTest();
        account acc = new account(name='test');
        insert acc;
        ssp_application__c app = new ssp_application__c(Account__c = acc.id);
        app.RecordTypeId = Schema.describeSObjects(New String[]{'SSP_Application__c'}).get(0).getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
        app.ProgramsApplied__c = 'MA';
        insert app;
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        SSP_Member__c mem = new SSP_Member__c();
        mem.name = 'test';
        mem.contact__c = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                        new Set<String>{'Id', 'ContactId'}, 
                                                        new Map<String, String>{'limit'=>'1','Id'=> citizen.id})[0].contactId;
        insert mem;
        AccountContactRelation acr = new AccountContactRelation();
        acr.contactId = mem.contact__c;
        acr.accountId = app.Account__c;
        insert acr;

        SSP_ApplicationIndividual__c ai = new SSP_ApplicationIndividual__c();
        ai.SSP_Application__c = app.id;
        ai.SSP_Member__c = mem.id;
        ai.IsHeadOfHousehold__c = true;
        ai.ProgramsApplied__c = 'MA';
        ai.MedicaidType__c = 'MAGI';
        insert ai;

        System.runAs(citizen){
            SSP_ExpensesSelectionQueueRule esr = new SSP_ExpensesSelectionQueueRule();
            ContextData data = new ContextData();
            data.ApplicationId = app.id;
            esr.isRequired(null, data);

            ai.ProgramsApplied__c = 'CC';
            update ai;

            System.assertEquals(esr.isRequired(null, data), false);

            data.ApplicationId = '1';
            try{
                esr.isRequired(null, data);
            }catch(exception e){
                
            }
        }
        test.stopTest();
    }
}
