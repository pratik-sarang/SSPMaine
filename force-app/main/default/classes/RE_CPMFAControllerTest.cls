/*********************************************************************************************************************************
* Class Name    : RE_CPMFAControllerTest
* Owner         : Deloitte
* Created Date  : 
* Description   : TestClass for RE_CPMFAController
*
*                            M O D I F I C A T I O N   L O G                                          
**/
@isTest
public class RE_CPMFAControllerTest {
    @testSetup static void setup() {
        RE_CPMFAController obj = new RE_CPMFAController();
       List<MFA_Router_Page__c> mpagelst = new List<MFA_Router_Page__c>();
	   MFA_Router_Page__c objMpage = new MFA_Router_Page__c();
	   objMpage.Name='RedirectURL';
	   objMpage.MFARedirectURL__c='https://kogideinternal.chfsinet.ky.gov/account/RouterPage.aspx?ReturnURL=https://benefind--r1dev.my.salesforce.com/';
	   mpagelst.add(objMpage);
	   MFA_Router_Page__c objMpage1 = new MFA_Router_Page__c();
	   objMpage1.Name='RedirectURLCP';
	   objMpage1.MFARedirectURL__c='https://kogideinternal.chfsinet.ky.gov/account/RouterPage.aspx?ReturnURL=https://r1dev-benefind-redev.cs33.force.com/';
	   mpagelst.add(objMpage1);
	   insert mpagelst;
    }
    
	@isTest
    public static void redirectToMFAPage(){
        test.startTest();
        RE_CPMFAController obj = new RE_CPMFAController();
        obj.SSOAttributeValues='';
        obj.getPageCountValue='';
        obj.redirectToMFAPage();
        system.assert(obj.redirectToMFAPage()!=null,'Success');   
        test.stopTest();
    }
    
    @isTest
    public static void redirectToMFAPageCPUser(){
        test.startTest();
		RE_CPMFAController obj = new RE_CPMFAController();
        obj.redirectToMFAPageCPUser();    
		system.assert(obj.redirectToMFAPageCPUser()!=null,'Success');        
        test.stopTest();
    }
    @isTest
    public static void testForCookies(){
        Test.startTest();
            pageReference pageRef = Page.RE_CPErrorPage;
            Test.setCurrentPage(pageRef);	
            ApexPages.currentPage().getHeaders().put('Referer', 'test');
            Cookie cookieMsg = new Cookie('counter', '10', null, -1, false);      
            pageRef.setCookies(new Cookie[]{cookieMsg});
            RE_CPMFAController testMFAController	=	new RE_CPMFAController();
            Cookie counter=ApexPages.currentPage().getCookies().get('counter');
            //RE_Release 1.3 – ForceReviewer - Payal Dubela
            System.assertEquals(counter!=null,true,'Positive Scenario'); 
       Test.stopTest();
    }
}