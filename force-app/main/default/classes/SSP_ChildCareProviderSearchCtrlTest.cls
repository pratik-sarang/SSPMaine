/***************************************************************************************************************************
*   Type             :   Test Class
*   Name             :   SSP_ChildCareProviderSearchControllerTest
*   Created By       :   CHFS
*   Created Date     :   11/04/2019
*   Description      :   This class acts as a test class for SSP_ChildCareProviderSearchController
*   Modification Log :
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------
*   *   
*****************************************************************************************************************************/
@isTest
public class SSP_ChildCareProviderSearchCtrlTest 
{
    @testSetup static void setupTestData()
    {
        SSP_TestDataFactory.setupTestData();
    }
    @isTest static void testGetProviderIdsFromFavorite()
    {
        Test.startTest();
            User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1]; 
            Contact con = [SELECT Id, IndividualId__c, DoesCaseExistForIndividual__c FROM Contact where Id = :citizen.ContactId LIMIT 1];
            SSP_TestDataFactory.createFavoriteRecord(con.Id, 1, true);
            Favorite__c fav = new Favorite__c();
            fav.Client__c=[SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
            fav.Contact__c =[SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
            fav.Provider_Id__c='1234567890';
            insert fav;
            String providersId = SSP_ChildCareProviderSearchController.getProviderIdsFromFavorite();
        Test.stopTest();
        Favorite__c favorite = [SELECT Id, Provider_Id__c FROM Favorite__c WHERE Contact__c =:con.Id LIMIT 1];
        system.assertEquals(favorite.Provider_Id__c, '122');
    }
    @isTest static void testGetFavoriteCount()
    {
        Test.startTest();
            User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1]; 
            Contact con = [SELECT Id, IndividualId__c, DoesCaseExistForIndividual__c FROM Contact where Id = :citizen.ContactId LIMIT 1];
            SSP_TestDataFactory.createFavoriteRecord(con.Id, 1, true);
            SSP_ChildCareProviderSearchController.getFavoriteCount();
        Test.stopTest();
        List<Favorite__c> listOfFavorites = [SELECT Id, Provider_Id__c FROM Favorite__c WHERE Contact__c =:con.Id];
        system.assertEquals(listOfFavorites.size(), 1);
    }
    
    @isTest static void testAddToFavorite() 
    {
        Test.startTest();
            User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1]; 
            Contact con = [SELECT Id, IndividualId__c, DoesCaseExistForIndividual__c FROM Contact where Id = :citizen.ContactId LIMIT 1];
            String providerId = '122';
            SSP_ChildCareProviderSearchController.addToFavorite(providerId);
        Test.stopTest();
    }
    @isTest static void testRemoveFromFavorite() 
    {
        Test.startTest();
            User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1]; 
            Contact con = [SELECT Id, IndividualId__c, DoesCaseExistForIndividual__c FROM Contact where Id = :citizen.ContactId LIMIT 1];
            String providerId = '122';
            SSP_ChildCareProviderSearchController.removeFromFavorite(providerId);
        Test.stopTest();
    }
    
    @isTest static void testAddToFavoriteNegative() 
    {
        Test.startTest();
            User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1]; 
            Contact con = [SELECT Id, IndividualId__c, DoesCaseExistForIndividual__c FROM Contact where Id = :citizen.ContactId LIMIT 1];
            String providerId = 'psstinkxibpajgvkkxwmtlmsovnpecmpzwewhyhicftspyleoubrogqgnvbtcyzmzccmsigssssssssssssssssssssssssssssss';
            SSP_ChildCareProviderSearchController.addToFavorite(providerId);
        Test.stopTest();
    }
    @isTest static void testGetChildCareProviderDetails() 
    {
        SSP_ChildCareProviderSearchController.queryComponents queryData = new SSP_ChildCareProviderSearchController.queryComponents();
        queryData.latitude = '38.2009055';
        queryData.longitude = '-84.87328350000001';
        queryData.providerName = null;
        queryData.licenseNumber = null;
        queryData.providerIDValues = '122';
        queryData.isFavoriteSearch = true;
        Test.startTest();
        SingleRequestMock fakeResponse = new SingleRequestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String response = SSP_ChildCareProviderSearchController.getChildCareProviderDetails(queryData);
        Test.stopTest();
    }
    @isTest static void testGetInspectionReport() 
    {
        SSP_ChildCareProviderSearchController.queryDocumentDetails queryData = new SSP_ChildCareProviderSearchController.queryDocumentDetails();
        queryData.inspectionId = '291317';
        queryData.reportName =  'KID013A';
        queryData.planOfCorrectionID = '361053';
        queryData.source = 'SSRS';
        queryData.reportType = 'Planofcorrection';
        Test.startTest();
        	SingleRequestMockForPr fakeResponse2 = new SingleRequestMockForPr();
        	Test.setMock(HttpCalloutMock.class, fakeResponse2);
            SSP_ChildCareProviderSearchController.getInspectionReport(queryData);
        Test.stopTest();
    }
    
    @isTest static void testIsGuest() 
    {
        Test.startTest();
            User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1]; 
            Boolean isGuest = SSP_ChildCareProviderSearchController.isGuest();
        Test.stopTest();
        system.assertEquals(isGuest, false);
    }
    @isTest static void testDownloadCcProvList(){
        SSP_CCReport_RequestWrapper.ChildCareProviderDetailsFileRequest ccFilerequest = new SSP_CCReport_RequestWrapper.ChildCareProviderDetailsFileRequest();
        SSP_CCReport_RequestWrapper request = new SSP_CCReport_RequestWrapper();
  		request.SubmitType = 'ChildCareProviderExcel';
  		request.ChildCareProviderDetailsFileRequest = ccFilerequest;
        SingleRequestMock fakeResponse3 = new SingleRequestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse3);
        string dummy = SSP_ChildCareProviderSearchController.downloadCCProviderList();
        SSP_ChildCareProviderSearchController.DownloadInspectionReport inspecReport = new SSP_ChildCareProviderSearchController.DownloadInspectionReport('test');
    	
    }
}