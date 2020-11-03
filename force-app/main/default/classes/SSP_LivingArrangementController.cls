/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_LivingArrangementController
*   Created By   :   Samridh Manucha
*   Created Date :   01/28/2020
*   Description  :   Controller for Living Arrangement Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Samridh               01/28/2020    Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_LivingArrangementController {
  
/********************************************************************************************
* @author       Samridh Manucha
* @date         01/28/2020
* @methodname   fetchAccountInformation
* @description  This method fetches the account Information of type organization
* @param        String
* @return       SSP_LightningResponse
********************************************************************************************/
@AuraEnabled
    public static SSP_LightningResponse fetchAccountInformation(string institutionName,string livingArrangement){
     SSP_Utility.isAuthenticatedUser();
    SSP_LightningResponse toSend = new SSP_LightningResponse();
    List<WrapperOrganization> lstOrg = new List<WrapperOrganization>();
    WrapperListOrganization wrapperLstOrg = new WrapperListOrganization();   
   try{
        if(String.isNotBlank(institutionName) && (livingArrangement == SSP_GlobalConstants.PSYCHIATRIC_TREATMENT || livingArrangement == SSP_GlobalConstants.LONG_TERM_CARE)){         
          Map<String, Object> mapParams = new Map<String, Object>();
          mapParams.put(SSP_InterfaceConstants.ORGANIZATION_NAME,institutionName);
          mapParams.put(SSP_InterfaceConstants.LIVING_ARRANGEMENT_TYPE,livingArrangement);
          List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_PROVIDER_SEARCH , mapParams);
          if(objList != null && objList.size()>0){            
            wrapperLstOrg.lstWrapperRecords = fetchWrapperOrganization(objList);
          }         
        }
        else{
        if(String.isNotBlank(institutionName)){
        String key = '%' + institutionName + '%'; 
        List<SSP_Institution__c> sspInstitutionList = (List<SSP_Institution__c>)
        SSP_SharingBypassFetcher.fetchRecords(new Map<String, String>{'objectName'=>'SSP_Institution__c','operator'=>'AND', 'Name__c' => 'like'}, 
                                                                              new Set<String>{'Id', 'Name__c', 'AddressLine1__c', 'AddressLine2__c', 'City__c', 'County__c', 'Country__c','StateCode__c','ZipCode__c'}, 
                                                                              new Map<String, String>{'RecordType.Name'=> String.escapeSingleQuotes(SSP_GlobalConstants.ORGANIZATION),'Name__c'=> String.escapeSingleQuotes(key)}); 
                                                                                                                                                                                                                           
            if(sspInstitutionList.size() > 0)
            {
                for(SSP_Institution__c wrp : sspInstitutionList){
                    WrapperOrganization wrapperOrg = new WrapperOrganization();
                    string address ;
                    wrapperOrg.organizationId = wrp.Id ;
                    if(wrp.AddressLine1__c != null) address = wrp.AddressLine1__c+',' ;
                    if(wrp.AddressLine2__c != null) address = address + wrp.AddressLine2__c+',' ;
                    if(wrp.City__c != null) address = address + wrp.City__c+',';
                    if(wrp.Country__c != null) address = address + wrp.Country__c+',';
                    if(wrp.StateCode__c != null) address = address + wrp.StateCode__c+',';
                    if(wrp.ZipCode__c != null) address = address + wrp.ZipCode__c ;
                    wrapperOrg.organizationName = wrp.Name__c;
                    wrapperOrg.organizationAddress = address;
                    wrapperOrg.isService = false;
                    lstOrg.add(wrapperOrg);
                } 
                wrapperLstOrg.lstWrapperRecords = lstOrg;        
            }
          }              
         }
         if(wrapperlstOrg != null && wrapperlstOrg.lstWrapperRecords != null && wrapperlstOrg.lstWrapperRecords.size() > 0){        
            toSend.bIsSuccess = true;
            toSend.put('organizationName', wrapperlstOrg.lstWrapperRecords);
         }
         else{
                 toSend.bIsSuccess = false;
                 toSend.put('organizationName', '');
          }
        }
        catch(Exception ex){               
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_LivingArrangementController', 'fetchAccountInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            if(lstLogMessages.size() > 0) toSend.addException(ex, lstLogMessages[0].Id);
        }
        
        return toSend;
    }
    
/********************************************************************************************
* @author       Samridh Manucha
* @date         02/09/2020
* @methodname   fetchWrapperOrganization  
* @description  This method creates wrapper for organization data 
* @param        List 
* @return       List of WrapperOrganization
********************************************************************************************/
public static List<WrapperOrganization> fetchWrapperOrganization (List<Object> objlst){
    List<WrapperOrganization> lstOrgWrapper = new List<WrapperOrganization>();
    SSP_ProviderSearchResponseWrapper  wrapperResponse  = new SSP_ProviderSearchResponseWrapper ();
    SSP_ProviderSearchResponseWrapper.ResultsWrapper resultWrapper = new SSP_ProviderSearchResponseWrapper.ResultsWrapper();
    List<SSP_ProviderSearchResponseWrapper.ProviderSearchResultWrapper> wrapperProviderSearch = new List<SSP_ProviderSearchResponseWrapper.ProviderSearchResultWrapper>();
                wrapperResponse = (SSP_ProviderSearchResponseWrapper) objlst[0]; 
                resultwrapper = wrapperResponse.Results;
                wrapperProviderSearch = resultwrapper.ProviderSearchResult;
                for(SSP_ProviderSearchResponseWrapper.ProviderSearchResultWrapper wrp : wrapperProviderSearch){
                    WrapperOrganization wrapperOrg = new WrapperOrganization();
                    wrapperOrg.organizationId = string.valueof(wrp.OrganizationId) ;
                    wrapperOrg.organizationName = wrp.OrganizationName;
                    wrapperOrg.organizationAddress = wrp.OrganizationAddress;
                    wrapperOrg.isService = true;
                    lstOrgWrapper.add(wrapperOrg);
                }                
     return lstOrgWrapper;
} 
 
     
/********************************************************************************************
* @author       Samridh Manucha
* @date         02/09/2020
* @methodname   fetchInstitutionInformation
* @description  This method fetches the institution Information 
* @param        String
* @return       SSP_LightningResponse
********************************************************************************************/
@AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchInstitutionInformation(string institutionId){
    SSP_LightningResponse toSend = new SSP_LightningResponse();
    try{
        if(String.isNotBlank(institutionId)){
        List<SSP_Institution__c> sspInstitutionList = 
        SSP_InstitutionSelector.queryInstitutionData(new Map<String, String>{'objectName'=>'SSP_Institution__c','operator'=>'AND'}, 
                                                                              new Set<String>{'Id', 'Name__c'}, 
                                                                              new Map<String, String>{'Id'=> String.escapeSingleQuotes(institutionId)}); 
                                                                                                                                                                                                                                
            if(sspInstitutionList.size() > 0)
            {
                    toSend.bIsSuccess = true;
                    toSend.put('instituteName', sspInstitutionList[0].Name__c);           
            }
          }              
        }
        catch(Exception ex){               
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_LivingArrangementController', 'fetchInstitutionInformation', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            if(lstLogMessages.size() > 0) toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }

/********************************************************************************************
* @author       Kireeti Gora
* @date         05/12/2020
* @methodname   fetchRoleType
* @description  This method fetches the Role Type
* @param        String
* @return       SSP_LightningResponse
********************************************************************************************/
@AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchRoleType(){
    SSP_LightningResponse response = new SSP_LightningResponse();
    try{
         Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
          String selectedRole = '';
       selectedRole =(sessionPart != null && sessionPart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionPart.get(SSP_GlobalConstants.SELECTED_ROLE)) :String.valueOf(sessionPart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
        if(selectedRole != null && selectedRole != '' &&  ((selectedRole == SSP_GlobalCOnstants.ORGANISATION_AUTH_REP) || (selectedRole == SSP_GlobalCOnstants.JAILOR) || (selectedRole == SSP_GlobalCOnstants.DOC_REPRESENTATIVE))){
            response.put('ShowHospitalizationDates',true);
        }     
        }
        catch(Exception ex){               
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_LivingArrangementController', 'fetchRoleType', ex.getMessage() , true);
            response.bIsSuccess = false;
            if(lstLogMessages.size() > 0) response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }


public class WrapperListOrganization{
   @AuraEnabled public List<WrapperOrganization> lstWrapperRecords;
}

public class WrapperOrganization{
        @AuraEnabled public string organizationId; 
        @AuraEnabled public string organizationName; 
        @AuraEnabled public string organizationAddress; 
        @AuraEnabled public boolean isService;
}


}