/***************************************************************************************************************************
*   Type         :   
*   Name         :   JsonPageResponse
*   Created By   :   Narapa Naidu Pulipati
*   Created Date :   05/27/2020
*   Description  :   Class which contains attributes like Navigation Flow Detail Metadata, Page Info Metadata, Navigation Flow Page Configuration
*                    metadata and used to move data between client and server containing all these details
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*    Narapa Naidu Pulipati      05/27/2020      Initial Version
*****************************************************************************************************************************/
public with sharing class JsonPageResponse {
    
    @AuraEnabled
    public Object pageObjectData {get; set;}

    @AuraEnabled
    public Sobject sObj {get; set;}

    @AuraEnabled
    public PageConfData pageConfData {get; set;}

    @AuraEnabled
    public List<ValidationMessage> vMessages {get; set;}


    public class PageConfData {

        @AuraEnabled
        public NavFlowDetail__mdt navFlowDetail {get; set;}
        
        @AuraEnabled
        public PageInfo pageInf {get; set;}
    }

    public class PageInfo {

        @AuraEnabled
        public NavFlowPageConfig__mdt navFlowPageConfig {get; set;}

        @AuraEnabled
        public PageInfo__mdt pageInfoMdt {get; set;}
        
        @AuraEnabled
        public String objectSchema {get; set;}
        
        @AuraEnabled
        public String layoutSchema {get; set;}

        @AuraEnabled
        public String picklistsRecordTypeId {get; set;}

        public PageInfo(NavFlowPageConfig__mdt navFlowPageConfig){
            this.navFlowPageConfig = navFlowPageConfig;
        }

        public PageInfo(PageInfo__mdt pageInfoMdt){
            this.pageInfoMdt = pageInfoMdt;
        }

        public PageInfo(String objectSchema, String layoutSchema){
            this.objectSchema = objectSchema;
            this.layoutSchema = layoutSchema;
        }
    }

    public class ValidationMessage {

        @AuraEnabled
        public String fieldName {get; set;}
        
        @AuraEnabled
        public String errCode {get; set;}

        @AuraEnabled
        public String errMsg {get; set;}
    }

    public class JsonPageException extends Exception {

        /** Exception code */
        @AuraEnabled
        public String code {get; set;}

        /** Exception message */
        @AuraEnabled
        public String message {get; set;}

        /**
         * Constructor.
         * 
         * @param message String
         * @param code String
         */
        public JsonPageException(String code, String message){
            this(code, message, null);
        }

        /**
         * Constructor.
         * 
         * @param message String
         * @param code String
         * @param ex Exception
         */
        public JsonPageException(String code, String message, Exception ex){
            this.code = code;
            this.message = message + (null == ex ? '' : ex.getMessage() + ': Stack Trace: ' + ex.getStackTraceString());
        }
    }

    public class ObjectSchema {
        @AuraEnabled public SobjectInfo sobjectInfo {get;set;} 
        @AuraEnabled public String controller {get;set;} 
        @AuraEnabled public boolean isSaveOnSubmit  {get;set;}
        
    }

    public class SobjectInfo {
        @AuraEnabled public String objectName {get;set;}
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String recordTypeName {get;set;}
    }
}