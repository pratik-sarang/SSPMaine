/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_AmericanIndianInfoControllerTest
*   Created By   :   Sanchita Tibrewala
*   Created Date :   01/13/2020
*   Description  :   Test class for SSP_AmericanIndianInformationController
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 01/13/2020     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_AmericanIndianInfoControllerTest {
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         01/13/2019
    * @methodname   fetchAmericanIndianMemberInformationTest
    * @description  Test method for fetchAmericanIndianMemberInformation
    * @param        none
    * @return       none
    ********************************************************************************************/
	@isTest
    public static void fetchAmericanIndianMemberInformationTest(){
        User u1 = SSP_TestDataFactory.createPortalUser();
        
        System.runAs(u1){
            
            List<SSP_Member__c> memList = SSP_TestDataFactory.createSSPMembers(1, false);
            SSP_Member__c mem = memList.get(0);
            mem.Contact__c = u1.ContactId;
            mem.IndianTribeCode__c = 'CROO';
            mem.IndianTribeState__c = 'KY';
            mem.IsFederalRecognizedIndianTribeToggle__c = 'Y';
            insert mem;
            Id memId = mem.Id;
            
            SSP_LightningResponse lr = SSP_AmericanIndianInformationController.fetchAmericanIndianMemberInformation(memId);
            SSP_Member__c retrievedMem = (SSP_Member__c)lr.mapResponse.get('record'); 
            
            System.assertEquals(retrievedMem.IsFederalRecognizedIndianTribeToggle__c, mem.IsFederalRecognizedIndianTribeToggle__c);
        }
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         01/13/2019
    * @methodname   saveAmericanIndianMemberInformationTest
    * @description  Test method for saveAmericanIndianMemberInformation
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void saveAmericanIndianMemberInformationTest(){
        User u1 = SSP_TestDataFactory.createPortalUser();
        
        System.runAs(u1){
        
            List<SSP_Member__c> memList = SSP_TestDataFactory.createSSPMembers(1, false);
            SSP_Member__c mem = memList.get(0);
            mem.Contact__c = u1.ContactId;
            insert mem;
            mem.IsFederalRecognizedIndianTribeToggle__c = 'N';
            mem.IndianTribeCode__c = 'CSMO';
            Id memId = mem.Id;
            
            String memString = JSON.serialize(mem);
            SSP_AmericanIndianInformationController.saveAmericanIndianMemberInformation(memId, memString);
            SSP_Member__c retrievedMem;
            if(memId != null){
                retrievedMem = [Select Id, IsFederalRecognizedIndianTribeToggle__c, IndianTribeCode__c From SSP_Member__c Where Id =:memId];
            }
            System.assertEquals(retrievedMem.IsFederalRecognizedIndianTribeToggle__c , mem.IsFederalRecognizedIndianTribeToggle__c);
        }
    }
}