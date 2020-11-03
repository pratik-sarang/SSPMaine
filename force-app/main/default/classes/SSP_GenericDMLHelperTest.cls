/*
* Classname     :  SSP_GenericDMLHelperTest
* @description  :  This class is the test class of SSP_GenericDMLHelper
* @author       :  Ragunathan
* @date         :  08/01/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
**/
@isTest(seeAllData=false)
public class SSP_GenericDMLHelperTest {

    @isTest
    static void shouldUpdateRecords() {
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        acc.Email__c = 'test@test.com';
        
        List<sObject> updatedRec = SSP_GenericDMLHelper.updateRecords(
            										new List<sObject>  {acc}, 
            										new List<String> {'Email__c'});
    }
    
    @isTest
    static void shouldNotUpdateRecords() {
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        acc.Email__c = 'test@test.com';
        User u = createAChatterUser();
        System.runAs(u) {
            String errorMessage;
            try {
                List<sObject> updatedRec = SSP_GenericDMLHelper.updateRecords(
                    new List<sObject>  {acc}, 
                    new List<String> {'Email__c'});
            } catch (Exception ex) {
                errorMessage = ex.getMessage();
            }
            System.assertEquals('Object access violation - No Update Permission Account', errorMessage);
        }
    }
    
    @isTest
    static void shouldCreateRecords() {
        Account acc = new Account(Name = 'TestAccount',Email__c = 'test@test.com');
        
        List<sObject> updatedRec = SSP_GenericDMLHelper.insertRecords(
            										new List<sObject>  {acc}, 
            										new List<String> {'Email__c'});
    }
    
    @isTest
    static void shouldNotCreateRecords() {
        Account acc = new Account(Name = 'TestAccount', Email__c = 'test@test.com');
        User u = createAChatterUser();
        System.runAs(u) {
            String errorMessage;
            try {
                List<sObject> updatedRec = SSP_GenericDMLHelper.insertRecords(
                    new List<sObject>  {acc}, 
                    new List<String> {'Email__c'});
            } catch (Exception ex) {
                errorMessage = ex.getMessage();
            }
            System.assertEquals('Object access violation - No Create Permission Account', errorMessage);
        }
    }
    
    private static User createAChatterUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Chatter External User'];
        return new User(Alias = 'kystandt', Email='chatterUser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='chatterUser@kyssptestorg.com.kyssp');
    }
}