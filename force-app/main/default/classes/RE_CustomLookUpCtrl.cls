/**
* Class Name    : RE_CustomLookUpCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Controller class for RE_ReferralDetails
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  Prashant       Initial Version
*  06/24/2019  Suyash		  PMD Checks - Exception Handling 
**/

public with sharing class RE_CustomLookUpCtrl {
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchLookUpValues(String strSearchKeyWord, String strObjectName,Boolean bfilter) { 
       
        String searchKeyWord = String.escapeSingleQuotes(strSearchKeyWord);
        String objectName = String.escapeSingleQuotes(strObjectName);
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                Boolean bSuccess = false; 
        try{
            Id partneraccounttypeid ;
            Id agencyaccounttypeid;
            if(objectName=='Account'){
                partneraccounttypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Re_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
            }else if(objectName=='Contact' || objectName=='Consent__c'){
                partneraccounttypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Re_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
            }else if(objectName=='Location__c'){
                partneraccounttypeid = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(Re_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
            }
                Map<String, String> mapInputs= new Map<String, String>();
                mapInputs.put('searchKeyWord',searchKeyWord);
            	mapInputs.put('objectName',objectName);
                mapInputs.put('rectypeID',partneraccounttypeid);
            	mapInputs.put('bfilter',String.valueOf(bfilter));
            
           mapResponse.put('lookUpValues',RE_SharingBypassCtrl.fetchLookUpValues(mapInputs));
            bSuccess=true;
        }
        catch(Exception e){errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateReferral','fetchloggedInUserInfo', e.getMessage(), true);
            
        }
        //return RE_SharingBypassCtrl.fetchLookUpValues(searchKeyWord,ObjectName,partneraccounttypeid);
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
        
    }
    
    
    /**************************************************************************************
* @author       Prashant Singh
* @date         08/05/2019
* @methodname   fetchLookUpValues()
* @description  This methods is used to create notes
* @param        String searchKeyWord, String ObjectName
* @return       void 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getObjectRecord(String recID, String ObjectName ) {
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        try {
            sObject returnObj = RE_SharingByPassCtrl.getRecord(String.escapeSingleQuotes(recID),String.escapeSingleQuotes(objectName));
            bSuccess = true;
            mapResponse.put('getRec', returnObj);
        }catch (Exception e) {errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getAllOptions', e.getMessage(),true);
        } 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
}