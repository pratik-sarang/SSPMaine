/*
* Name       : ESAPI_SFDCAccessUtil
*Description : Class to handle accessiblity check
* Author    : Srikanth
* Date      : 1 FEB 2019
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------------------
* 
*/

public Class ESAPI_SFDCAccessUtil{

    // turn on/off switch to throw exception
    //private static ESAPI_Settings__c esapiSettings = ESAPI_Settings__c.getInstance();
    
    /*Author: Srikanth
    *Method Name: throwFieldAccessException
    *Description: throws exception if the returned fields doesn't have the access
    */
    public static void throwFieldAccessException(String strErrorMsg,Schema.SObjectType sTypeName, List<String> strSObjectFields ){
       
       /** if(esapiSettings!=null && esapiSettings.EnforceFieldAccessCheck__c){
            throw new SFDCAccessControlException(strErrorMsg, 
                                                      SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION , 
                                                      SFDCAccessControlException.ExceptionReason.NO_READ, 
                                                      sTypeName.getDescribe().getName(), 
                                                      'Recheck the field access for :'+strSObjectFields) ;
        }**/
        
    }
    
    /*Author: Srikanth
    *Method Name: DMLOperationCheck
    *Description: Throws exception if the returned parameter List doesn't have object / Fields access
    */
 /**   public static void DMLOperationCheck(String DMLoperation,List<sObject> lstobj){
        Set<String> setStringFields = retrieveAccessibleFields(lstobj);
        List<String> returnedFields = new List<String>(setStringFields);
        
        //used if the DML operation is actioned for UPSERT
        if(DMLoperation == 'Upsert'){
            boolean fieldCheckToInsert = ESAPI.accessController().isAuthorizedToCreate(PIRL__c.sObjectType, returnedFields);
            boolean fieldCheckToUpdate = ESAPI.accessController().isAuthorizedToUpdate(PIRL__c.sObjectType, returnedFields);
            if(fieldCheckToInsert == FALSE && fieldCheckToUpdate == FALSE ){
                throwFieldAccessException('Object/ Field Access Exception',PIRL__c.sObjectType,returnedFields);
            }
        }
        //used if the DML operation is actioned for INSERT
        else if(DMLoperation == 'Insert'){
            boolean fieldCheckToInsert = ESAPI.accessController().isAuthorizedToCreate(PIRL__c.sObjectType, returnedFields);
            if(fieldCheckToInsert == FALSE){
                throwFieldAccessException('Object/ Field Access Exception',PIRL__c.sObjectType,returnedFields);
            }
        }
        //used if the DML operation is actioned for UPDATE
        else if(DMLoperation == 'Update'){
            boolean fieldCheckToUpdate = ESAPI.accessController().isAuthorizedToUpdate(PIRL__c.sObjectType, returnedFields);
            if(fieldCheckToUpdate == FALSE){
                throwFieldAccessException('Object/ Field Access Exception',PIRL__c.sObjectType,returnedFields);
            }
        }
        
    }**/
    
    /*Author: Srikanth
    *Method Name: retrieveAccessibleFields
    *Description: Returns the Set of fields based on the parameter's List
    */
    public static Set<String> retrieveAccessibleFields(List<sObject> lstobj){
        Set<String> lstStringFieldrt=new Set<String>();
        for(integer i=0;i<lstobj.size();i++){
            sObject obj=lstobj[i];
            Schema.sObjectType expectedType = obj.getsObjectType();
            String sObjectName = expectedType.getDescribe().getName();
            sObjectType sobjecttypecheck = Schema.getGlobalDescribe().get(sObjectName);
            Map<String,Schema.sObjectField> mfields=sobjecttypecheck.getDescribe().fields.getMap();
            Map<String, Object> fieldsToValue = obj.getPopulatedFieldsAsMap();
            for (String fieldName : fieldsToValue.keySet()){
                if(fieldName!='Id' && !mfields.get(fieldName).getDescribe().isAutoNumber() && !mfields.get(fieldName).getDescribe().isCalculated()){
                    lstStringFieldrt.add(fieldName);
                }            
            }  
        }
      return lstStringFieldrt;  
    }
}