/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_FileUploadCtrlTest
*   Created By   :   Deloitte
*   Created Date :   05/28/2019
*   Description :   This class acts as a test class for RE_FileUploadCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                   05/28/2019        Initial Version   
*****************************************************************************************************************************/
@isTest
private class RE_FileUploadCtrlTest {
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         05/28/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setupTestData(){
        Id sREAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
        
        List<Account> accountList = TestDataFactory.createAccounts(1,true,sREAccRecTypeId);
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountList[0].Id);
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strContactRecordTypeName).getRecordTypeId();
        List<Contact> contactList = TestDataFactory.createContacts(1,true,contactRecordTypeId,accountIdList,true);
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> resourceList = TestDataFactory.createResources(2,true,resourceRecordTypeId,accountIdList);
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationList = TestDataFactory.createLocations(2,true,locationRecordTypeId,accountIdList);
    }
    
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         05/28/2019
    * @methodname   testSaveFile
    * @description  This method is used to test the functionality of method - saveFile.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testSaveFile() {
        List<File_Extension_Setting__c> lstExt= new List<File_Extension_Setting__c>();
        File_Extension_Setting__c fileExt1 = new File_Extension_Setting__c();
        fileExt1.Is_Allowed__c=true;
        fileExt1.Name='docx';
        fileExt1.Value__c='docx';
        lstExt.add(fileExt1);
        
        File_Extension_Setting__c fileExt2 = new File_Extension_Setting__c();
        fileExt2.Is_Allowed__c=true;
        fileExt2.Name='jpg';
        fileExt2.Value__c='jpg';
        lstExt.add(fileExt2);
        insert lstExt;
        
        List<Location__c> locationList = [SELECT Id FROM Location__c LIMIT 1];
        Test.startTest();
        RE_CreateLightningServerResponse result = RE_FileUploadCtrl.saveChunk(locationList[0].Id,'testFIle.jpg','testString','.jpg','','Application Form');
        RE_FileUploadCtrl.saveChunk(locationList[0].Id,'testFIle.jpg','testString','.jpg',String.valueOf(result.objectdata.get('fileId')),'Application Form');
        Test.stopTest();
        List<ContentVersion> contentDocInserted = [SELECT id,Title FROM ContentVersion];
        System.assert(contentDocInserted.size()>0,'Success');
    }
    
    
    
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         05/28/2019
    * @methodname   testGetDocTypesValues
    * @description  This method is used to test the functionality of method - getDocTypesValues.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testGetDocTypesValues() {
        Test.startTest();
        //List<String> docTypeValueList = RE_FileUploadCtrl.getDocTypesValues();
        RE_CreateLightningServerResponse result = RE_FileUploadCtrl.getDocTypesValues();
        Test.stopTest();
        System.assert(result.isSuccessful==true,'Success');
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         05/28/2019
    * @methodname   testSaveFile
    * @description  This method is used to test the functionality of catch block of method - saveFile.
    * @param        none
    * @return       none
    ********************************************************************************************/
    
    @isTest static void testSaveFileExcptn() {
        Account acc = [SELECT Id from Account LIMIT 1];
        Test.startTest();
        Id result = RE_FileUploadCtrl.saveFile(acc.Id, '', '', '', '');
        Test.stopTest();
        //
        System.assert(result == null,'Success');
    }
    
     /********************************************************************************************
    * @author       Kojashree Kakariya
    * @date         11/13/2019
    * @methodname   testSaveChunk
    * @description  This method is used to test the functionality of catch block of method - saveChunk.
    * @param        none
    * @return       none
    ********************************************************************************************/
    
    @isTest static void testSaveChunkExcptn() {
        Account acc = [SELECT Id from Account LIMIT 1];
        Test.startTest();
        RE_CreateLightningServerResponse result = RE_FileUploadCtrl.saveChunk(acc.Id, '', '', '', acc.Id, '');
        Test.stopTest();

        System.assert(result.isSuccessful == true ,'Success');
    }
     /********************************************************************************************
    * @author       Payal Dubela
    * @date         05/11/2020
    * @methodname   testgetValidExtensions
    * @description  This method is used to test the functionality of get valid extensions
    * @param        none
    * @return       none
    ********************************************************************************************/
    
    @isTest static void testgetValidExtensions() {
        List<File_Extension_Setting__c> lstExt= new List<File_Extension_Setting__c>();
        File_Extension_Setting__c fileExt1 = new File_Extension_Setting__c();
        fileExt1.Is_Allowed__c=true;
        fileExt1.Name='docx';
        fileExt1.Value__c='docx';
        lstExt.add(fileExt1);
    
        File_Extension_Setting__c fileExt2 = new File_Extension_Setting__c();
        fileExt2.Is_Allowed__c=true;
        fileExt2.Name='jpg';
        fileExt2.Value__c='jpg';
        lstExt.add(fileExt2);
        insert lstExt;
        Test.startTest();
        RE_CreateLightningServerResponse result = RE_FileUploadCtrl.getValidExtensions();
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        System.assert(result.isSuccessful == true ,'Success');
        Test.stopTest();  
    }   
}