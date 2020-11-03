/*
* classname     : SSP_CPMFAControllerTest
* @description  : This class is use to cover class of SSP_CPMFAController
* @author       : Payal Dubela
* @date         : 08/18/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SSP_CPMFAControllerTest {

    @testSetup static void setup() {
        insert new MFA_Router_Page__c(Name='RedirectURL',MFARedirectURL__c='https://testurl.com');
        insert new MFA_Router_Page__c(Name='SSP_RedirectURLCP',MFARedirectURL__c='https://testurl.com');
        insert new MFA_Router_Page__c(Name='Agentrole',MFARedirectURL__c='https://testurl.com');
    }

    @isTest
    public static void testMethod1(){
        SSP_CPMFAController controller1= new SSP_CPMFAController();
        pageReference pageRef = Page.RE_CPErrorPage;
        Test.setCurrentPage(pageRef);	
        ApexPages.currentPage().getHeaders().put('Referer', 'test');
        Cookie cookieMsg = new Cookie('counter', '10', null, -1, false);      
        pageRef.setCookies(new Cookie[]{cookieMsg});
        SSP_CPMFAController controller= new SSP_CPMFAController();
        controller.redirectToMFAPage();
        controller.redirectToMFAPageCPUser();
        controller.redirectAgentToPortal();
        Cookie counter=ApexPages.currentPage().getCookies().get('counter');
        System.assertEquals(counter!=null,true,'Positive Scenario'); 
    }

}