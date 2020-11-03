/*
* classname     : SSP_MoreHelpInfoControllerTest
* @description  : A test class for SSP_MoreHelpInfoController class
* @author       : Samridh Manucha
* @date         : FEB-05-2020
* MODIFICATION LOG:
* DEVELOPER             DATE                DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Samridh Manucha      FEB-05-2020         Initial Version
*/
@isTest
public class SSP_MoreHelpInfoControllerTest {

   @testSetup
    public static void dataSetup() {    
        FAQ__kav faq = new FAQ__kav();
        faq.Title = 'test';
        faq.HelpModal__c = 'test';
        faq.ScreenName__c = 'SSP_APP_More_Help_Info';
        faq.Language = 'en_US';
        faq.UrlName = 'test1';
        insert faq;      
    }

   @isTest
    public static void unitTest1() {      
        Test.startTest();
        SSP_MoreHelpInfoController moreHelp = new  SSP_MoreHelpInfoController();
        Test.stopTest();
    }

}