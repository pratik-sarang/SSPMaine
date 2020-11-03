/*
* classname 	: SSP_GenericDMLHelperUtility
* @description 	: A generic class for dml operations.
* @author 		: Keshav Poduval
* @date 		: July-12-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Keshav Poduval 		July-12-2020			Initial Version
*/

public class SSP_GenericDMLHelperUtility {

     /***************************************************************************************************
* @author       Keshav Poduval
* @date         07/12/2020
* @methodname   updateRecords
* @description  This methods is used to update list of records. Check update permission on object and fields.
* @return       List<Sobject>
*****************************************************************************************************/
    public static list<sObject> updateRecords(List<sObject> lstSobjectToUpdate, List<String> listFields){
        if(!lstSobjectToUpdate.isEmpty() && lstSobjectToUpdate.size()>0){
            
            Schema.DescribeSObjectResult objectDescribe = lstSobjectToUpdate.get(0).getSObjectType().getDescribe();
            string objectName = objectDescribe.getName();
            list<sObject> successRecords = new list<sObject>();
            
            if(objectDescribe.isUpdateable()){
                Schema.DescribeFieldResult fr;
                for(String fieldName : listFields){
                    fr = objectDescribe.fields.getMap().get(fieldName).getDescribe();
                    if(fr.getRelationshipOrder() == null && !fr.isUpdateable()){
                        throw new AccessViolationException('Field access violation - No Update Permission '+objectName+'.'+fieldName);
                    }
                }
                Database.SaveResult[] srList = Database.update(lstSobjectToUpdate, true);
                Database.SaveResult saveResult;
                sObject updatedRec;
                
                // Iterate through each returned result
                for (Integer i = 0; i <lstSobjectToUpdate.size(); i++) {
                    saveResult = srList[i];
                    updatedRec = lstSobjectToUpdate[i];
                    if(saveResult.isSuccess()){
                        successRecords.add(updatedRec);
                    }                    
                    else {
                        // Operation failed, so get all errors  
                        for(Database.Error err : saveResult.getErrors()) {
                           throw new AccessViolationException(err.getMessage());
                        }
                    } 
                }
            }
            else{
                throw new AccessViolationException('Object access violation - No Update Permission '+objectName);
            }
            
            // Return Success records
            if(successRecords != null && !successRecords.isEmpty()){
                return successRecords;
            }
        }
         return null;
    }
/***************************************************************************************************
* @author       Keshav Poduval
* @date         07/16/2020
* @methodname   insertRecords
* @description  This methods is used to insert list of records. Check insert permission on object and fields.
* @return       List<SObject>
*****************************************************************************************************/
    public static list<sObject> insertRecords(List<sObject> lstSobjectToInsert, List<String> listFields){
        if(!lstSobjectToInsert.isEmpty() && lstSobjectToInsert.size()>0){
            
            Schema.DescribeSObjectResult objectDescribe = lstSobjectToInsert.get(0).getSObjectType().getDescribe();
            string objectName = objectDescribe.getName();
            list<sObject> successRecords = new list<sObject>();
            
            if(objectDescribe.isCreateable()){
                Schema.DescribeFieldResult fr;
                for(String fieldName : listFields){
                    fr = objectDescribe.fields.getMap().get(fieldName).getDescribe();
                    if(fr.getRelationshipOrder() == null && !fr.isCreateable()){
                        throw new AccessViolationException('Field access violation - No Create Permission '+objectName+'.'+fieldName);
                    }
                }
                Database.SaveResult[] srList = Database.insert(lstSobjectToInsert, true);
                Database.SaveResult saveResult;
                sObject insertedRec;
                
                // Iterate through each returned result
                for (Integer i = 0; i <lstSobjectToInsert.size(); i++) {
                    saveResult = srList[i];
                    insertedRec = lstSobjectToInsert[i];
                    if(saveResult.isSuccess()){
                        successRecords.add(insertedRec);
                    }                    
                    else {
                        // Operation failed, so get all errors  
                        for(Database.Error err : saveResult.getErrors()) {
                           throw new AccessViolationException(err.getMessage());
                        }
                    } 
                }
            }
            else{
                throw new AccessViolationException('Object access violation - No Create Permission '+objectName);
            }
            
            // Return Success records
            if(successRecords != null && !successRecords.isEmpty()){
                return successRecords;
            }
        }
         return null;
    }

    /***************************************************************************************************
* @author       Keshav Poduval
* @date         08/08/2020
* @methodname   upsertRecords
* @description  This methods is used to upsert list of records. Check upsert permission on object and fields.
* @return       List<SObject>
*****************************************************************************************************/
    public static list<sObject> upsertRecords(List<sObject> lstSobjectToUpsert, List<String> listFields){
        if(!lstSobjectToUpsert.isEmpty() && lstSobjectToUpsert.size()>0){
            
            Schema.DescribeSObjectResult objectDescribe = lstSobjectToUpsert.get(0).getSObjectType().getDescribe();
            string objectName = objectDescribe.getName();
            list<sObject> successRecords = new list<sObject>();
            
            if(objectDescribe.isCreateable() || objectDescribe.isUpdateable()){//same check as ESAPI
                Schema.DescribeFieldResult fr;
                for(String fieldName : listFields){
                    fr = objectDescribe.fields.getMap().get(fieldName).getDescribe();
                    if(fr.getRelationshipOrder() == null && (!fr.isCreateable() || !fr.isUpdateable())){//same check as ESAPI
                        throw new AccessViolationException('Field access violation - No Create or Update Permission '+objectName+'.'+fieldName);
                    }
                }
                Database.UpsertResult[] srList = Database.upsert(lstSobjectToUpsert, true);
                Database.UpsertResult saveResult;
                sObject upsertedRec;
                
                // Iterate through each returned result
                for (Integer i = 0; i <lstSobjectToUpsert.size(); i++) {
                    saveResult = srList[i];
                    upsertedRec = lstSobjectToUpsert[i];
                    if(saveResult.isSuccess()){
                        successRecords.add(upsertedRec);
                    }                    
                    else {
                        // Operation failed, so get all errors  
                        for(Database.Error err : saveResult.getErrors()) {
                           throw new AccessViolationException(err.getMessage());
                        }
                    } 
                }
            }
            else{
                throw new AccessViolationException('Object access violation - No Create or Update Permission '+objectName);
            }
            
            // Return Success records
            if(successRecords != null && !successRecords.isEmpty()){
                return successRecords;
            }
        }
         return null;
    }
    
    public static list<sObject> upsertRecords(List<sObject> lstSobjectToUpsert, List<String> listFields, String externalFieldName){
        if(!lstSobjectToUpsert.isEmpty() && lstSobjectToUpsert.size() > 0 && String.isNotBlank(externalFieldName)){
            if(!listFields.contains(externalFieldName)) {
                throw new AccessViolationException('Please include external field in your list of fields.');
            }
            Schema.DescribeSObjectResult objectDescribe = lstSobjectToUpsert.get(0).getSObjectType().getDescribe();
            string objectName = objectDescribe.getName();
            list<sObject> successRecords = new list<sObject>();
            
            if(objectDescribe.isCreateable() || objectDescribe.isUpdateable()){//same check as ESAPI
                Schema.DescribeFieldResult fr;
                for(String fieldName : listFields){
                    fr = objectDescribe.fields.getMap().get(fieldName).getDescribe();
                    if(fr.getRelationshipOrder() == null && (!fr.isCreateable() || !fr.isUpdateable())){//same check as ESAPI
                        throw new AccessViolationException('Field access violation - No Create or Update Permission '+objectName+'.'+fieldName);
                    }
                }
                Schema.SObjectField externalIdField = objectDescribe.fields.getMap().get(externalFieldName);
                Database.UpsertResult[] srList = Database.upsert(lstSobjectToUpsert, externalIdField, true);
                Database.UpsertResult saveResult;
                sObject upsertedRec;
                
                // Iterate through each returned result
                for (Integer i = 0; i <lstSobjectToUpsert.size(); i++) {
                    saveResult = srList[i];
                    upsertedRec = lstSobjectToUpsert[i];
                    if(saveResult.isSuccess()){
                        successRecords.add(upsertedRec);
                    }                    
                    else {
                        // Operation failed, so get all errors  
                        for(Database.Error err : saveResult.getErrors()) {
                           throw new AccessViolationException(err.getMessage());
                        }
                    } 
                }
            }
            else{
                throw new AccessViolationException('Object access violation - No Create or Update Permission '+objectName);
            }
            
            // Return Success records
            if(successRecords != null && !successRecords.isEmpty()){
                return successRecords;
            }
        }
         return null;
    }

    public class AccessViolationException extends Exception{}

}