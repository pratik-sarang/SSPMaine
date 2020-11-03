/**
* Class Name    : RE_OrganizationSearchCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Fetch the Details from United 211 to display in public page
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/02/2019  SRIKANTH       Initial Version
**/
public with sharing class RE_OrganizationSearchCtrl {
  
/*********************************************************************************************************************************
* @author       SRIKANTH
* @date         05/02/2019
* @methodname   fetchOrganizations()
* @description  This method is used to fetch the Account details based on the user inputs given in the UI
* @param        organizationName  (String) : Organization name to search from the UI 
* @param        organizationCity  (String) : Organization city to search from the UI 
* @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchOrganizations(String organizationName,String organizationCity){
        
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Map<String, Object> errorMap = new Map<String, Object>{};
        List<Account> lstAccount = new List<Account>();
        Map<String,List<Account>> mapAccountRecs = new Map<String,List<Account>>();
        List<Account> lstClaimedAccount =new List<Account>();
        List<Account> lstUnclaimedAccount =new List<Account>();
        String switchCaseKey;
        try{
            lstAccount = RE_SharingByPassCtrl.fetchOrganizationResults(organizationName,organizationCity);
            if(!lstAccount.isEmpty()){
                for(Account acc: lstAccount){
                  /*if(acc.IsClaimed__c == true){
                        lstClaimedAccount.add(acc);
                    } 
                    else{
                        lstUnclaimedAccount.add(acc);
                    }*/ // Force Reviewer Fixes -- Kojashree Kakariya
                    switchCaseKey = (acc.IsClaimed__c == true)?'TRUE': 'FALSE';
                        switch on (switchCaseKey) {
                            when 'TRUE'{
                                lstClaimedAccount.add(acc); 
                            }
                            when 'FALSE'{
                                 lstUnclaimedAccount.add(acc);
                            }
                        }
                }
            }
            if(!lstClaimedAccount.isEmpty() && lstClaimedAccount.size()>0 ){
                mapAccountRecs.put('claimed',lstClaimedAccount);
            }
            if(!lstUnclaimedAccount.isEmpty() && lstUnclaimedAccount.size()>0){
                mapAccountRecs.put('unClaimed',lstUnclaimedAccount);
            }
            if(!lstAccount.isEmpty() && lstAccount.size()>0){
                mapResponse.put('account',mapAccountRecs);
            }
            if(!mapResponse.isEmpty()){
                bSuccess = True;
            }
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationSearchCtrl','fetchOrganizations', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    
    /*********************************************************************************************************************************
* @author       Anuj
* @date         04/24/2020
* @methodname   getUnclaimedOrgDetail()
* @description  This method is used to fetch the Account details based on the org id in params
* @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getUnclaimedOrgDetail(String orgId){
        //SOQL Injection Changes - Payal Dubela - 08/26
        orgId=String.isNotBlank(orgId)?String.escapeSingleQuotes(orgId):orgId;
        Boolean bSuccess = false;
        String sFieldsApiName;
        String sWhereClause;
        String sQuery;
        String switchCaseKey;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        List<Account> lstAccounts = new List<Account>();
        try{
            sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnUnclaimedOrg;
            sWhereClause = RE_DataBaseQueryFields.sLocationWhereClauseOnUnclaimedOrg;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Account', sFieldsApiName, mapQueryParameters);
            switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';
            List<Account> accountRec = new List<Account>();
            switch on (switchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    if(sQuery != null){
                        lstAccounts = RE_SharingByPassCtrl.getAccountRecords(sQuery, orgId);
                    }
                    mapResponse.put('isSuccessful', true);
                    mapResponse.put('Account', lstAccounts[0]);
                    bSuccess = true;
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationSearchCtrl','getUnclaimedOrgDetail','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_OrganizationSearchCtrl','getUnclaimedOrgDetail', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
}
