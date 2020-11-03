/*
* classname 	: SSP_CollateralContactTest
* @description 	: class for collateral contact record
* @author 		: Rahul Kumar
* @date 		: July-16-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*  Rahul   		July-16-2020		Initial Version
*/
@isTest(seeAllData=false)
public class SSP_CollateralContactTest {
     @isTest
        public static void getCurrentLoggedInUserLangTest(){  
              SSP_CollateralContact.getCurrentLoggedInUserLang();
        }
    @isTest
    public static void fetchCollateralContactDataTest(){
         List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'eligibility';
        insert lstAcc;
        
        List<contact> lstCon = SSP_TestDataFactory.createContacts(1, false); 
        lstCon[0].FirstName='fname';
        lstCon[0].LastName='lname';
        insert lstCon;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].Contact_Name__c='Test';
        lstAppln[0].Contact_Phone_Number__c='897-686-8765'; 
        lstAppln[0].Relationship_To_You__c='Father';
        insert lstAppln;
        SSP_CollateralContact.fetchCollateralContactData(lstAppln[0].Id);
        SSP_CollateralContact.fetchCollateralContactData(lstAppln[0].Contact_Phone_Number__c);
    }
        
        
}