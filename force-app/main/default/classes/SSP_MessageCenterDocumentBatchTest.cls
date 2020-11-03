/*
* classname   : SSP_MessageCenterDocumentBatchTest
* @description   : This class is use to cover class of SSP_MessageCenterDocumentBatch
* @author     : Chandra Shekhar
* @date     : 08/18/2020
* MODIFICATION LOG:
* DEVELOPER       DATE       DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SSP_MessageCenterDocumentBatchTest{
    
    @testSetup static void setup() {
        SSP_TestDataFactory.setupTestData();
         Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        String agencyRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Non_Citizen');
        Contact objContact = SSP_TestDataFactory.createContactRecord('test','contact','test.contact@gmail.com',agencyRecordTypeId,true);
         Contact objCitizenContact = SSP_TestDataFactory.createContactRecord('Citizen', 'User', 'citizen1@abc.xyz', contactRecordTypeId, true);
        User objUser = SSP_TestDataFactory.createCommunityUser('tste',objContact.Id,'test.contact@gmail.com','SSP Non Citizen Profile',true);
        User objCitizenUser = SSP_TestDataFactory.createCommunityUser('sspC', objCitizenContact.Id,'citizen1@abc.xyz', 'RE Citizen Profile', true);
        User usr = [select id from User where email = 'citizen@abc.xyz' Limit 1][0];
        List<DocumentDetail__c> docDetail = new List<DocumentDetail__c>();
        DocumentDetail__c dd1= new DocumentDetail__c();
        DocumentDetail__c dd2= new DocumentDetail__c();
        System.runAs(usr){
        DocumentDetail__c dd= new DocumentDetail__c();
        dd.Document_Type_Description__c='Hearing Doc';
        dd.Hearing_Id__c='12342342';
        dd.Hearing_Request_Number__c='12342342';
        dd.Hearing_Document_Type__c='DT154';
        dd.Name='Test.pdf';
        dd.UserId__c='9998288232';
        dd.ContentDocumentId__c='0011assassjd';
        dd.StatusCode__c='Fail';
        dd.FailureReason__c=SSP_GlobalConstants.VIRUS_AFFECTED;  
        dd.IndividualId__c = '999036537';
        docDetail.add(dd);
         insert docDetail; 
        }
        System.runAs(objUser){
        dd1.Document_Type_Description__c='Hearing Doc';
        dd1.Hearing_Id__c='1234a2342';
        dd1.Hearing_Request_Number__c='12a342342';
        dd1.Hearing_Document_Type__c='DT154';
        dd1.Name='Taest.pdf';
        dd1.UserId__c='9998288232';
        dd1.ContentDocumentId__c='0011assassjd';
        dd1.StatusCode__c='Fail';
        dd1.FailureReason__c=SSP_GlobalConstants.PASSWORD_PROTECTED; 
        dd1.IndividualId__c = '999036538';
            insert dd1;
        }
        System.runAs(objCitizenUser){
        dd2.Document_Type_Description__c='Hearing Doc';
        dd2.Hearing_Id__c='12342332';
        dd2.Hearing_Request_Number__c='12342322';
        dd2.Hearing_Document_Type__c='DT154';
        dd2.Name='Test.pdf';
        dd2.UserId__c='9948288232';
        dd2.ContentDocumentId__c='0011adsassjd';
        dd2.StatusCode__c='Fail';
        dd2.FailureReason__c=SSP_GlobalConstants.VIRUS_AFFECTED;  
        dd2.IndividualId__c = '999036536';
        insert dd2;
            
        }
        List<Contact> conList = SSP_TestDataFactory.createContacts(1,false);
        Account accRecord = new account();
        accRecord.Name = 'Test Acc1114';
        insert accRecord;
        conList[0].AccountId = accRecord.Id;
        insert conList;
        
        List<SSP_Member__c> sspMemberList = SSP_TestDataFactory.createSSPMembers(3,false);
        sspMemberList[0].IndividualId__c = docDetail[0].IndividualId__c;
        sspMemberList[0].PreferredWrittenLanguageCode__c = '1';
        sspMemberList[0].PreferredNotificationMethodCode__c = 'ES';
        sspMemberList[0].PrimaryPhoneNumber__c = '1112223334';
        sspMemberList[0].Email__c = '999036538fake@fake.com';
        sspMemberList[0].Contact__c = conList[0].id;
        
        sspMemberList[1].IndividualId__c = dd1.IndividualId__c;
        sspMemberList[1].PreferredWrittenLanguageCode__c = '4';
        sspMemberList[1].PreferredNotificationMethodCode__c = 'EE';
        sspMemberList[1].PrimaryPhoneNumber__c = '1112223331';
        sspMemberList[1].Email__c = '999036538fake1@fake.com';
        sspMemberList[1].Contact__c = conList[0].id;
       
        sspMemberList[2].IndividualId__c = dd2.IndividualId__c;
        sspMemberList[2].PreferredWrittenLanguageCode__c = '4';
        sspMemberList[2].PreferredNotificationMethodCode__c = 'EE';
        sspMemberList[2].PrimaryPhoneNumber__c = '1112223331';
        sspMemberList[2].Email__c = '999036538fake1@fake.com';
        sspMemberList[2].Contact__c = conList[0].id;
        
        /*sspMemberList[2].IndividualId__c = docDetail[0].IndividualId__c;
        sspMemberList[2].PreferredWrittenLanguageCode__c = '1';
        sspMemberList[2].PreferredNotificationMethodCode__c = 'P';
        sspMemberList[2].PrimaryPhoneNumber__c = '1112223334';
        sspMemberList[2].Email__c = '999036538fake@fake.com';
        sspMemberList[2].Contact__c = conList[0].id;
        
        sspMemberList[3].IndividualId__c = docDetail[0].IndividualId__c;
        sspMemberList[3].PreferredWrittenLanguageCode__c = '1';
        sspMemberList[3].PreferredNotificationMethodCode__c = 'ES';
        sspMemberList[3].PrimaryPhoneNumber__c = '1112223334';
        sspMemberList[3].Email__c = '999036538fake@fake.com';
        sspMemberList[3].Contact__c = conList[0].id;*/
        
        insert sspMemberList;
        
       /* SSP_Member__c updateInfo = new SSP_Member__c(Id = sspMemberList[0].Id,PreferredNotificationMethodCode__c = 'EE',Contact__c = conList[0].id);
        sspMemberListnew.add(updateInfo);
        update sspMemberListnew;*/
        
       // User objCitizenUser = SSP_TestDataFactory.createCommunityUser('sspC', objCitizenContact.Id,'citizen@abc.xyz', 'RE Citizen Profile', true);
        
        
    }
    @isTest
    public static void messageCenterBatch(){
        User usr = [select id from User where email = 'citizen@abc.xyz' Limit 1][0];
        System.runAs(usr){
            SSP_MessageCenterDocumentBatch batchObj = new SSP_MessageCenterDocumentBatch();
            database.executebatch(batchObj);
        }
    }
     @isTest
    static void shouldScheduleBatchtest() { 
        test.startTest();
        SSP_MessageCenterDocumentBatch msgCenterObject = new SSP_MessageCenterDocumentBatch();
        String sch = '0 0 23 * * ?';
        ID idJob = System.Schedule('test status Check', sch, msgCenterObject);
        System.assertNotEquals(idJob,null,'Correct Output');
        test.stopTest();
    }
}