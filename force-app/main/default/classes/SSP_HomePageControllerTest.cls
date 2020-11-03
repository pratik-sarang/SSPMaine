/*
* classname     : SSP_HomePageControllerTest
* @description  : A test class for SSP_HomePageController class.
* @author       : Samridh Manucha
* @date         : MARCH-05-2020
* MODIFICATION LOG:
* DEVELOPER             DATE                DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Samridh Manucha      MARCH-05-2020         Initial Version
*/
@isTest
public class SSP_HomePageControllerTest {

   @testSetup
    public static void dataSetup() {  
    AppConfig__c setting = new AppConfig__c();
    setting.Name = 'BackyardURL';
    setting.Value__c = 'sspDevCertificate';
    insert setting;
    }

    @isTest
    public static void unitTest1() {      
        Test.startTest();
        SSP_LightningResponse response = SSP_HomePageController.fetchCommunityURL();
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest2() {
        AppConfig__c config = AppConfig__c.getInstance('BackyardURL');
        config.Name = 'TEST CS Name';
        update config;
        Test.startTest();
        SSP_LightningResponse response = SSP_HomePageController.fetchCommunityURL();
        Test.stopTest();
    }

}