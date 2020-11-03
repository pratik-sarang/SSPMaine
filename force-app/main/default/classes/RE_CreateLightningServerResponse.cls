/**
 * Class Name    : RE_CreateLightningServerResponse
 * Owner         : Pankaj
 * Created Date  : 02/13/2017
 * Description   : Wrapper class created to send response information requested by any lightning component to client
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer       Description                                                         
 *  ----------  -----------     -------------------------------------------------------------------
 **/
 
public with sharing class RE_CreateLightningServerResponse {
    @AuraEnabled public Boolean isSuccessful {get; private set;}
    /* Commenting as not referenced anywhere
     * @AuraEnabled public String successMessage { get; private set;}
    @AuraEnabled public String errorMessage { get; private set;}
    @AuraEnabled public List<String> errorFieldApiNames { get; private set;}*/
    @AuraEnabled public map<String, Object> mapErrorInfo { get; private set; }
    @AuraEnabled public map<String, Object> objectData { get; private set; }
    /* Commenting as no references found
    public RE_CreateLightningServerResponse(Boolean isSuccessful, String message, List<String> errorFieldApiNames,map<String, Object> objectData) {
        this.isSuccessful = isSuccessful;
        if(isSuccessful)this.successMessage = message;
        else this.errorMessage = message;
        this.errorFieldApiNames = errorFieldApiNames;
        this.objectData = objectData;
    }*/
    //Overloading constructor with different input parameters
    /*Commenting as no references found
    public RE_CreateLightningServerResponse(Boolean isSuccessful,String message,map<String, Object> objectData) {
        this.isSuccessful = isSuccessful;
        if(isSuccessful)this.successMessage = message;
        this.objectData = objectData;
    }*/
    
    /* Use this contructor ALWAYS - it has error handling implemented */
    public RE_CreateLightningServerResponse(Boolean isSuccessful, map<String, Object> mapErrorInfo, map<String, Object> objectData) {
        this.isSuccessful = isSuccessful;
        this.mapErrorInfo = mapErrorInfo;
        this.objectData = objectData;
    }
    
    /*Commenting as no references found
    public RE_CreateLightningServerResponse() {
        this.isSuccessful = isSuccessful;
    }*/
  
}