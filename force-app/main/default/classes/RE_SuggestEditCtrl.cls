/*********************************************************************************************************************************
* Class Name    : RE_SuggestEditCtrl 
* Owner         : Prashant
* Created Date  : 08/12/2019 
* Description   : Insert report concern record
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/
public with sharing class RE_SuggestEditCtrl {
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchUserProfile(){
        Map<String, Object> errorMap    = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Boolean bSuccess = false; 
        Boolean bIsGuestUser = false;
        try{
            Profile sProfile = GeneralUtility.getLoggedInUserProfile();
            if(sProfile.Name == RE_GlobalConstants.strGuestProfileName){
                bIsGuestUser=true;
            }
            mapResponse.put('records', JSON.serialize(bIsGuestUser));
            bSuccess=true;
        }
        catch(Exception e){errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateReferral','fetchloggedInUserInfo', e.getMessage(), true);
		}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/12/2019
    * @methodname   insertReportConcern()
    * @description  This methods is used to get the location records
    * @param        void
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
    @AuraEnabled
     public static RE_CreateLightningServerResponse insertReportConcern(RE_SuggestEditCtrl.ReportConcern objwrapper) 
    {
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Boolean bSuccess = false;
        
        try{     
            Id reportconcernchange = Schema.SObjectType.ReportConcern__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strRecordTypeDeveloperNameReportconcern).getRecordTypeId();
            
            ReportConcern__c objReportConcern= new ReportConcern__c();
            objReportConcern.recordtypeid=reportconcernchange; 
            objReportConcern.ConcernStatus__c= RE_GlobalConstants.STATUS_NEW;
            objReportConcern.ConcernType__c= RE_GlobalConstants.strRecordTypeDeveloperNameReportconcern;
            objReportConcern.LocationID__c= objwrapper.locationid;
            objReportConcern.Organization__c= objwrapper.accountid;
            objReportConcern.ResourceID__c= objwrapper.resourceid;
		String category = RE_GlobalConstants.sEmptyString;
            if(objwrapper.category!=null){
                List<Object> lstJsonParsestatus = (List<Object>)Json.deserializeUntyped(objwrapper.category);
                for(Object obj : lstJsonParsestatus){
                    Map<String,Object> mapStrObj = (Map<string,Object>)obj;
                    category = category +String.valueof(mapStrObj.get('Id'))+';';
                }  
            }
            objReportConcern.Category__c=category;
            objReportConcern.ConcernDetails__c=objwrapper.details;
            if(!objwrapper.isGuest){
                RE_CreateLightningServerResponse cplocresponse=RE_CreateReferralCtrl.fetchloggedInUserInfo();
                Contact conobj=(Contact)JSON.deserialize(String.valueOf(cplocresponse.objectData.get('records')), Contact.class);
                objReportConcern.ReporterEmail__c=conobj.Email;
                objReportConcern.ReporterName__c=conobj.Name;
                objReportConcern.ReporterPhone__c=conobj.Phone;
            }else{
                objReportConcern.ReporterEmail__c=objwrapper.email;
                objReportConcern.ReporterName__c=objwrapper.name;
                objReportConcern.ReporterPhone__c=objwrapper.phone;
            }
            // insert objReportConcern;
             //RE_DataAccessChecker.insertObject(ReportConcern__c.getSObjectType(), objReportConcern);
            RE_SharingByPassCtrl.insertsObject(ReportConcern__c.getSObjectType(), objReportConcern);
            String recID=objReportConcern.Id;
            // ReportConcern__c objReportConcerninserted=[Select id,Name from ReportConcern__c where id=:recID];
            String sFieldsApiName = RE_DataBaseQueryFields.sIdNameField; 
            String sWhereClause=RE_DataBaseQueryFields.sRecIdCondition;
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            Map<String,String> mapQueryParametersForReportConcern = new Map<String,String>();
            mapQueryParametersForReportConcern.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParametersForReportConcern.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParametersForReportConcern.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            ReportConcern__c objReportConcerninserted;
           
            Map<Boolean,String> mapResponseReportConcern = RE_DataAccessChecker.getFieldsAccessibility('ReportConcern__c',sFieldsApiName,mapQueryParametersForReportConcern);
            if(mapResponseReportConcern.get(true) != null){
                String sQueryForReportConcern =  mapResponseReportConcern.get(true);
                objReportConcerninserted = RE_SharingByPassCtrl.getReportConcerRecords(sQueryForReportConcern, recID);
                    //Database.query(sQueryForReportConcern);  
            }else{LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','insertReportConcern','***FLS Violation***'+mapResponseReportConcern.get(false),true);}
            mapResponse.put('records', JSON.serialize(objReportConcerninserted.Name));
            bSuccess=true;
        }catch(Exception e){ errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SuggestEditCtrl','insertReportConcernRec',e.getMessage(),true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/12/2019
    * @methodname   insertReportConcernRec()
    * @description  This is used to insert report concern object
    * @param        void
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReportConcernRec(RE_SuggestEditCtrl.ReportConcern objwrapper) 
    {
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Boolean bSuccess = false;
        try{     
            Id reportconcernchange = Schema.SObjectType.ReportConcern__c.getRecordTypeInfosByName().get('Concern').getRecordTypeId();
            ReportConcern__c objReportConcern= new ReportConcern__c();
            objReportConcern.recordtypeid=reportconcernchange; 
            objReportConcern.ConcernStatus__c= RE_GlobalConstants.STATUS_NEW;
            objReportConcern.ConcernType__c= RE_GlobalConstants.sConcernKey;
            objReportConcern.Identity__c= objwrapper.identity;
            String category = RE_GlobalConstants.sEmptyString;
            if(objwrapper.category!=null){
                List<Object> lstJsonParsestatus = (List<Object>)Json.deserializeUntyped(objwrapper.category);
                for(Object obj : lstJsonParsestatus){
                    Map<String,Object> mapStrObj = (Map<string,Object>)obj;
                    category = category +String.valueof(mapStrObj.get('Id'))+';';
                }  
            }
            objReportConcern.Category__c=category;
            objReportConcern.ConcernDetails__c=objwrapper.details;
            if(!objwrapper.isGuest){
                RE_CreateLightningServerResponse cplocresponse=RE_CreateReferralCtrl.fetchloggedInUserInfo();
                Contact conobj=(Contact)JSON.deserialize(String.valueOf(cplocresponse.objectData.get('records')), Contact.class);
                objReportConcern.ReporterEmail__c=conobj.Email;
                objReportConcern.ReporterName__c=conobj.Name;
                objReportConcern.ReporterPhone__c=conobj.Phone;
            }else{
                objReportConcern.ReporterEmail__c=objwrapper.email;
                objReportConcern.ReporterName__c=objwrapper.name;
                objReportConcern.ReporterPhone__c=objwrapper.phone;
            }
            // insert objReportConcern;
             //RE_DataAccessChecker.insertObject(ReportConcern__c.getSObjectType(), objReportConcern);
            RE_SharingByPassCtrl.insertsObject(ReportConcern__c.getSObjectType(), objReportConcern);
            String recID=objReportConcern.Id;
            // ReportConcern__c objReportConcerninserted=[Select id,Name from ReportConcern__c where id=:recID];
            String sFieldsApiName = RE_DataBaseQueryFields.sIdNameField; 
            String sWhereClause=RE_DataBaseQueryFields.sRecIdCondition;
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            Map<String,String> mapQueryParametersForReportConcern = new Map<String,String>();
            mapQueryParametersForReportConcern.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParametersForReportConcern.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParametersForReportConcern.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            ReportConcern__c objReportConcerninserted;
           
            Map<Boolean,String> mapResponseReportConcern = RE_DataAccessChecker.getFieldsAccessibility('ReportConcern__c',sFieldsApiName,mapQueryParametersForReportConcern);
            if(mapResponseReportConcern.get(true) != null){
                String sQueryForReportConcern =  mapResponseReportConcern.get(true);
                objReportConcerninserted = RE_SharingByPassCtrl.getReportConcerRecords(sQueryForReportConcern, recID);
                    //Database.query(sQueryForReportConcern);  
            }else{LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','insertReportConcern','***FLS Violation***'+mapResponseReportConcern.get(false),true);}
            mapResponse.put('records', JSON.serialize(objReportConcerninserted.Name));
            bSuccess=true;
        }catch(Exception e){ errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SuggestEditCtrl','insertReportConcernRec',e.getMessage(),true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
       
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         29/08/2019
    * @methodname   getPickListValues()
    * @description  This methods is used to fetch the picklist values
    * @param        String objectName, String lstFields
    * @return       void 
    **********************************************************************************************/  
    @AuraEnabled
    public static  RE_CreateLightningServerResponse getPickListValues(String objectName, String lstFields){
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{}; 
           try { //SOQL injection made to the below line.
               Map<String, Map<String, String>> values = GeneralUtility.fetchFieldsPicklistValueAPIName(String.escapeSingleQuotes(objectName), String.escapeSingleQuotes(lstFields));
               bSuccess = true;
               mapResponse.put('picklistvalues', values);
          } catch(Exception e) {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SuggestEdit','getPickListValues', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    public class ReportConcern{
        @AuraEnabled public String accountid{get; set;}
        @AuraEnabled public String locationid{get; set;}
        @AuraEnabled public String resourceid{get; set;}
        @AuraEnabled public String name{get; set;}
        @AuraEnabled public String email{get; set;}
        @AuraEnabled public String phone{get; set;}
        @AuraEnabled public String details{get; set;}
        @AuraEnabled public String category{get; set;}
        @AuraEnabled public Boolean isGuest{get; set;}
        @AuraEnabled public String identity{get; set;}
    }
    
}