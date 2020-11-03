/*
* classname     :  SSP_ChildCareProviderSearchController
* @description  :  Controller class for fetches Childcare Providers, add/remove favorites, gets Inspection Report
* @author       : ChangeMeIn@UserSettingsUnder.SFDoc
* @date         :  07/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
 CHFS Development Team          07/06/2020
**/
public with sharing class SSP_ChildCareProviderSearchController {
 
/*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   getChildCareProviderDetails
* @description  This methods is used to gets Child Care Provider Details for Search
* @return       String
**/
    @AuraEnabled
    public static String getChildCareProviderDetails(queryComponents queryData){

    
      SSP_CCProviderSearch_RequestWrapper.ChildCareProviderDetailsRequest ccProviderDetailsrequest = new SSP_CCProviderSearch_RequestWrapper.ChildCareProviderDetailsRequest();
     
      ccProviderDetailsrequest.AddressLattitude  = queryData.latitude ; 
      ccProviderDetailsrequest.AddressLongitude  = queryData.longitude ; 
      ccProviderDetailsrequest.ProviderName      = queryData.providerName;
      ccProviderDetailsrequest.LicenseNumber     = queryData.licenseNumber;
      ccProviderDetailsrequest.ProviderIDValues  = queryData.providerIDValues;
      ccProviderDetailsrequest.IsFavoriteSearch = queryData.isFavoriteSearch;
      SSP_CCProviderSearch_RequestWrapper request = new SSP_CCProviderSearch_RequestWrapper();
      request.SubmitType = 'ChildCareProviderDetail';
      request.ChildCareProviderDetailsRequest = ccProviderDetailsrequest;
      
      Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
      List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CHILDCARE_PROVIDER_SEARCH, mapParams);
    
       if(objList != null && !objList.isEmpty() && objList[0] != null) {
         SSP_ChildCareProviderSearchResponse response = (SSP_ChildCareProviderSearchResponse) objList[0];
         List<SSP_ChildCareProviderSearchResponse.ChildCareProviderDetails> ssProviderDetailsResponse = response.ChildCareProviderDetails;
        
         if( ssProviderDetailsResponse != null ) {
          return System.JSON.serializePretty(ssProviderDetailsResponse);
         } else {
           return null;
         }
       }
        return null;  
    }

/*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   isGuest
* @description  This methods is to check for guest User
* @return       Boolean
**/

    @AuraEnabled
    public static Boolean isGuest(){
      If (UserInfo.getUserType() == 'Guest') {
        return true;
      } else {
        return false;
      }
    }

  /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   getProviderIdsFromFavorite
* @description  This methods is gets all the Provider Ids from favorites for contact
* @return       String
**/  
    @AuraEnabled
    public  static String getProviderIdsFromFavorite(){

    GeneralUtility.isAuthenticatedUser();
      String contactId = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
      List<String> allContactFavorites = new List<String>();
      for (Favorite__c favorite : [SELECT Id, Provider_Id__c FROM Favorite__c WHERE Contact__c =:contactId]){
          allContactFavorites.add(favorite.Provider_Id__c);
      }
      return string.join(allContactFavorites,','); 
    }

  /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   addToFavorite
* @description  This methods is adds provider to favorites
* @return       
**/  

    @AuraEnabled
    public static void addToFavorite(String providerId){

      GeneralUtility.isAuthenticatedUser();
      Sobject sobj;
      String contactId = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
      try {
        boolean canCreate = ESAPI.accessController().isAuthorizedToCreate(Favorite__c.getSObjectType(), new List<String>{'Contact__c', 'Provider_Id__c'});
        if ( canCreate ) {
          Favorite__c favorite = new Favorite__c();
          favorite.Contact__c = contactId;
          favorite.Provider_Id__c = providerId;
        
          sobj = ESAPI.accessController().insertAsUser(new List<Sobject>{favorite}, SSP_Utility.getFieldsNamesList (new List<Sobject>{favorite})).getInsertedObjects()[0]; 

        }

      } catch (Exception e) {
        LOG_LogMessageUtility.logMessage(e,'SSP_ChildCareProviderSearchController', 'addToFavorite', e.getMessage() , true);
      }
    }
 
      /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   removeFromFavorite
* @description  This methods is removes provider to favorites
* @return       
**/  

    @AuraEnabled
    public static void removeFromFavorite(String providerId){

       GeneralUtility.isAuthenticatedUser();
      String contactId = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
      try {
        boolean canDelete = ESAPI.accessController().isAuthorizedToDelete(Favorite__c.getSObjectType());
        if ( canDelete ) {
          Favorite__c[] deleteFavorite = [SELECT Id FROM Favorite__c WHERE Contact__c =:contactId AND Provider_Id__c = :providerId];
          ESAPI.accessController().deleteAsUser(deleteFavorite);
        }
      } catch (Exception e) {
        LOG_LogMessageUtility.logMessage(e,'SSP_ChildCareProviderSearchController', 'removeFromFavorite', e.getMessage() , true);
      }
      
    }

          /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   getFavoriteCount
* @description  This methods is return contact's  favorites provider count
* @return       Integer
**/  
    @AuraEnabled
    public static Integer getFavoriteCount(){
     
      Integer favoriteCount = 0;
      try {
        String contactId = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getuserId()].ContactId;
        List<Favorite__c> allContactFavorites = [SELECT Id, Provider_Id__c FROM Favorite__c WHERE Contact__c =:contactId];
        favoriteCount = allContactFavorites.size();
      } catch (Exception e) {
        LOG_LogMessageUtility.logMessage(e,'SSP_ChildCareProviderSearchController', 'getFavoriteCount', e.getMessage() , true);
      }
      return favoriteCount;
    }

    /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   getInspectionReport
* @description  This methods is used to gets inspection report for download
* @return       DownloadInspectionReport wrapper
**/


    @AuraEnabled
    public static DownloadInspectionReport getInspectionReport(queryDocumentDetails queryData){

      SSP_CCReport_RequestWrapper.ChildCareProviderDetailsFileRequest ccFilerequest = new SSP_CCReport_RequestWrapper.ChildCareProviderDetailsFileRequest();
      ccFilerequest.InspectionId  = queryData.inspectionId; 
      ccFilerequest.ReportName  = queryData.reportName;
      ccFilerequest.PlanOfCorrectionID      = queryData.planOfCorrectionID; 
      ccFilerequest.Source     = queryData.source; 
      ccFilerequest.ReportType  =  queryData.reportType; 
      SSP_CCReport_RequestWrapper request = new SSP_CCReport_RequestWrapper();
      request.SubmitType = 'ChildCareProviderDetailFile';
      request.ChildCareProviderDetailsFileRequest = ccFilerequest;
      
      Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
      List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CHILDCARE_PROVIDER_SEARCH, mapParams);
      if(objList != null && !objList.isEmpty() && objList[0] != null) {
          SSP_ChildCareProviderSearchResponse response = (SSP_ChildCareProviderSearchResponse) objList[0];
           
          if(response.FileStream != null) {
            DownloadInspectionReport downloadWrap = new DownloadInspectionReport(response.FileStream.FileData);            
            return downloadWrap;
            }
      }
        return null;
    }

   /*
* @author       CHFS Development Team
* @date         07/21/2020 
* @methodname   downloadCCProviderList
* @description  This methods is used to gets inspection report for download
* @return       DownloadInspectionReport wrapper
**/
@AuraEnabled
public static String downloadCCProviderList(){
  SSP_CCReport_RequestWrapper.ChildCareProviderDetailsFileRequest ccFilerequest = new SSP_CCReport_RequestWrapper.ChildCareProviderDetailsFileRequest();
  SSP_CCReport_RequestWrapper request = new SSP_CCReport_RequestWrapper();
  request.SubmitType = 'ChildCareProviderExcel';
  request.ChildCareProviderDetailsFileRequest = ccFilerequest;
  Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
  List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CHILDCARE_PROVIDER_SEARCH, mapParams);
  if(objList != null && !objList.isEmpty() && objList[0] != null) {
      SSP_ChildCareProviderSearchResponse response = (SSP_ChildCareProviderSearchResponse) objList[0];
      if(response.ExportData != null ) {          
        return System.JSON.serializePretty(response.ExportData);
      }
  }
    return null;
}
 /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   DownloadInspectionReport
* @description  This methods is used wrapper to capture inspection report for download
* @return       DownloadInspectionReport wrapper
**/

    public class DownloadInspectionReport {

      @AuraEnabled
      public string binaryData{get;set;}    
      public DownloadInspectionReport(string binaryData) {
           this.binaryData = binaryData;            
      }
    }

 /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   queryDocumentDetails
* @description  This methods is used as wrapper call capture/pass request parameters for inspection report for download
* @return       
**/

    public class queryDocumentDetails{
      @AuraEnabled
      public String inspectionId { get; set;}
      @AuraEnabled
      public String reportName { get; set;}
      @AuraEnabled
      public String planOfCorrectionID { get; set;}
      @AuraEnabled
      public String source { get; set;}
      @AuraEnabled
      public String reportType { get; set;}
     
  }

 /*
* @author       CHFS Development Team
* @date         07/06/2020 
* @methodname   queryDocumentDetails
* @description  This methods is used as wrapper to capture/pass request parameters for child care provider search
* @return       
**/

  public class queryComponents{
      @AuraEnabled
      public String latitude { get; set;}
      @AuraEnabled
      public String longitude { get; set;}
      @AuraEnabled
      public String providerName { get; set;}
      @AuraEnabled
      public String licenseNumber { get; set;}
      @AuraEnabled
      public String providerIDValues { get; set;}
      @AuraEnabled
      public Boolean isFavoriteSearch { get; set;}
  }

}