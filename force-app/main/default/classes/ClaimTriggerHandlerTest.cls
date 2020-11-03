/**
* Class Name    : ClaimTriggerHandlerTest
* Owner         : DELOITTE
* Created Date  : 08/10/2020
* Description   : Test class for ClaimTrigger
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  08/10/2020  Payal Dubela    Initial Version
********************************************************************
* 	
**/
@isTest
public class ClaimTriggerHandlerTest {
    
     @isTest
    public static void checkDuplicateEntryTest(){
        ClaimMySiteRequest__c claim1 = new ClaimMySiteRequest__c();
        claim1.FirstName__c='Test Claim';
        claim1.LastName__c='Last Name';
        claim1.Email__c='testEmail@gmail.com';
        claim1.Status__c='New';
        insert claim1;
        
        claim1.Status__c='Approved';
        update claim1;
    }
    
    

}