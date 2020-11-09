/*
* Class Name        : RE_DataAccessChecker
* Owner             : DELOITTE 
* Created Date      : 05/30/2019
* Description       : Class created to check CRUD and FLS access for Query building and DMLs.

**/

public inherited sharing class RE_DataAccessChecker {
    
    //RE_Release 1.1 – Perf - Payal Dubela– 343025
    public static final Map<String, Schema.SObjectType> SchemaMapGlobal = Schema.getGlobalDescribe();
    
    /**
* @author : Suyash Singhal
* @method: isAllowedToCreate
* @desc Checks if the user is authorized to create
* @param objType -- SObjectType 
* @return Boolean - true if allowed to create else false 
* */
    public static Boolean isAllowedToCreate(Schema.SObjectType objType) { 
        return !isPermissionCheckAllowed('CRUD') || objType.getDescribe().isCreateable();
    }
    
    /**
* @author : Suyash Singhal
* @method : isAllowedToDelete
* @desc Checks if the user is authorized to delete
* @param objType -- SObjectType 
* @return Boolean - true if allowed to delete else false
* */
    public static Boolean isAllowedToDelete(Schema.SObjectType objType) { 
        Boolean bIsAllowedToDelete = false; 
        if (objType.getDescribe().isDeletable()) {
            bIsAllowedToDelete = true; 
        }
        bIsAllowedToDelete = isPermissionCheckAllowed('CRUD') ? bIsAllowedToDelete : true;        
        return bIsAllowedToDelete; 
    }
    
    /**
* @author : Suyash Singhal
* @method: isAllowedToUpdate
* @desc Checks if the user is authorized to update
* @param objType -- SObjectType 
* @return Boolean - true if allowed to update else false
* */
    public static Boolean isAllowedToUpdate(Schema.SObjectType objType) { 
        Boolean bIsAllowedToUpdate = false;        
        if (objType.getDescribe().isUpdateable()) { 
            bIsAllowedToUpdate = true; 
        }
        bIsAllowedToUpdate = isPermissionCheckAllowed('CRUD') ? bIsAllowedToUpdate : true;
        return bIsAllowedToUpdate; 
    } 
    
    /**
* @author : Suyash Singhal
* @method: isAllowedToAccess
* @desc Checks if the user is authorized to Access
* @param objType -- SObjectType 
* @return Boolean - true if allowed to Access else false
* */
    public static Boolean isAllowedToAccess(Schema.SObjectType objType) {
        Boolean bIsAllowedToAccess = false;        
        if (objType.getDescribe().isAccessible()) { 
            bIsAllowedToAccess = true; 
        }          
        return bIsAllowedToAccess; 
    }
    
    /**
* @author : Suyash Singhal
* @method: isSafeField
* @desc Checks if the user is authentiacted to access the field on the object
* @param sFieldName - API Name of the field, sObjectName - API Name of the object
* @return true if user has read FLS 
* */
    public static Boolean isSafeField(String sFieldName, String sObjectName) {
        Boolean bIsSafe = false;
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        SObjectType objType = SchemaMapGlobal.get(sObjectName);
        if (objType.getDescribe().isAccessible()) { 
            SObjectField objField = objType.getDescribe().fields.getMap().get(sFieldName);
            if (objField.getDescribe().isAccessible()) {
                bIsSafe =  true;
            }            
        }
        return bIsSafe;
    }
    
    /**
* @author : Suyash Singhal
* @method: getSafeFields
* @desc Get the String of comma separated field Api names which are accessible by the user
* @param lstFieldNames - list of fields, sObjectName - API Name of object
* @return  Map<Boolean,String> - Key as Boolean response  true for success and 
*          false for failure.Value will be String of comma separated fields
* */
    public static Map<Boolean, String> getSafeFields(List<String> lstFieldNames, String sObjectName) {
        Map<Boolean, String> mapResponse = new Map<Boolean, String>();
        String sNoAccessFields = '';
        String sAccessibleFields = '';
        List<String> lstSafeFields = new List<String>();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        SObjectType objType = SchemaMapGlobal.get(sObjectName);
        Map<String, SObjectField> mapOfFields = objType.getDescribe().fields.getMap();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        Boolean isObjectAccessible = objType.getDescribe().isAccessible();
        if (isObjectAccessible) {
        for (String sFieldName : lstFieldNames) {            
                SObjectField objField = mapOfFields.get(sFieldName.trim());
                if ((RE_GlobalConstants.setStdFields.contains(sFieldName.toLowerCase())) || objField.getDescribe().isAccessible()) {
                    lstSafeFields.add(sFieldName);
                    sAccessibleFields += sFieldName + ', ';
                } else {
                    sNoAccessFields += sFieldName + ', ';
                }
            } 
        }
        //lstSafeFields.sort();
        if (String.isNotBlank(sNoAccessFields) && sNoAccessFields.length() > 1) {
            sNoAccessFields = sNoAccessFields.substring(0, sNoAccessFields.length() - 2) ; 
            mapResponse.put(false, sNoAccessFields);
        } else {
            sAccessibleFields = sAccessibleFields.substring(0, sAccessibleFields.length() - 2) ;
            mapResponse.put(true, sAccessibleFields);
        }
        
        
        return mapResponse;
    }
    
    /**
* @author : Suyash Singhal
* @method: getSafeFields
* @desc Get the String of comma separated field Api names which are accessible by the user
* @param lstFieldNames - list of fields, sObjectName - API Name of object
* @return  Map<Boolean,String> - Key as Boolean response  true for success and 
*          false for failure.Value will be String of comma separated fields
* */
    public static Map<Boolean, String> getSafeFields(List<String> lstFieldNames, String sObjectName,String sDMLType) {
        Map<Boolean, String> mapResponse = new Map<Boolean, String>();
        String sNoAccessFields = '';
        String sAccessibleFields = '';
        List<String> lstSafeFields = new List<String>();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        SObjectType objType = SchemaMapGlobal.get(sObjectName);
        Map<String, SObjectField> mapOfFields = objType.getDescribe().fields.getMap();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        Boolean isObjectAccessible = objType.getDescribe().isAccessible();
        if (isObjectAccessible) {
        for (String sFieldName : lstFieldNames) {            
                SObjectField objField = mapOfFields.get(sFieldName.trim());
                if ( (RE_GlobalConstants.setStdFields.contains(sFieldName.toLowerCase())) 
                    || (sDMLType == RE_GlobalConstants.sInsert && objField.getDescribe().isCreateable())
                    || (sDMLType == RE_GlobalConstants.sUpsert && objField.getDescribe().isCreateable() && objField.getDescribe().isUpdateable())
                    || (sDMLType == RE_GlobalConstants.sUpdate && objField.getDescribe().isUpdateable())
                   ) {
                       lstSafeFields.add(sFieldName);
                       sAccessibleFields += sFieldName + ', ';
                   } else {
                       sNoAccessFields += sFieldName + ', ';
                   }
            } 
        }
        //lstSafeFields.sort();
        if (String.isNotBlank(sNoAccessFields) && sNoAccessFields.length() > 1) {
            sNoAccessFields = sNoAccessFields.substring(0, sNoAccessFields.length() - 2) ; 
            mapResponse.put(false, sNoAccessFields);
        } else {
            sAccessibleFields = sAccessibleFields.substring(0, sAccessibleFields.length() - 2) ;
            mapResponse.put(true, sAccessibleFields);
        }
        
        
        return mapResponse;
    }
    
    /**
* @author : Suyash Singhal
* @method : getFieldsAccessibility
* @desc   : Get the String of comma separated field Api names which are accessible by the user.
*           This method uses specific fields as inputted by Calling class
* @param  : lstFieldNames - list of fields, sObjectName - API Name of object,
*           map<String,String> mapQueryParameters - Stores Whereclause, OrderBy clause, Limit clause, Offset Clause.  
* @return : Map<Boolean,String> - Key as Boolean response  true for success and 
*          false for failure.Value will be query String of comma separated fields in Success scenario 
*          & comma separated not Accessible fields in fail case
* */    
    public static Map<Boolean, String> getFieldsAccessibility(String objectAPIName, String fieldAPINames, Map<String, String> mapQueryParameters) {
        Map<Boolean, String> mapResponse = new Map<Boolean, String>();
        String sQuery = 'SELECT ';
        String sWhereClause = '';
        String sOrderBy = '';
        String sLimit = ''; 
        String sOffset = '';  
        Boolean bIsPermissionAllowed = isPermissionCheckAllowed('Field');
        String sNoAccessFields = '';
        List<String> lstFieldAPINames = new List<String>();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        Schema.SObjectType targetsobjectType = SchemaMapGlobal.get(String.escapeSingleQuotes(objectAPIName));
        if (String.isNotBlank(String.escapeSingleQuotes(fieldAPINames)) && bIsPermissionAllowed) {
            Map<String, Schema.SObjectField> mapOfFields = targetsobjectType.getDescribe().fields.getMap();
            lstFieldAPINames = fieldAPINames.split(',');
            List<String> lstRelatedFields = new List<String>();
            for (String strField : lstFieldAPINames) {
                strField = strField.trim();
                //Relationship
                //Check if the field is valid  
                             
                if (strField.contains('.')) {
                    lstRelatedFields.add(strField);
                } else if ((RE_GlobalConstants.setStdFields.contains(strField.toLowerCase())) 
                           || (mapOfFields.get(strField) != null
                               && mapOfFields.get(strField).getDescribe().isAccessible())) {
                                   sQuery += strField + ', ';
                               } else {
                                   sNoAccessFields += strField + ', ';
                                   
                               }
            }
            //lstRelatedFields, targetsobjectType
            Map<Boolean,String> mapRelationSHipFields = checkRelationshipFields(lstRelatedFields,targetsobjectType);
            if(mapRelationSHipFields.get(true) != null){
                sQuery += mapRelationSHipFields.get(true);
                
            }
            else{
                
                throw new RE_DataAccessException(mapRelationSHipFields.get(false), targetsobjectType);
            }
            
        } else if (String.isNotBlank(string.escapeSingleQuotes(fieldAPINames))) {
            sQuery += String.escapeSingleQuotes(fieldAPINames);
        }
        
        
        /*if (String.isNotBlank(sNoAccessFields)) {
throw new RE_DataAccessException(sNoAccessFields, targetsobjectType);
}*/
        if (mapQueryParameters != null && !mapQueryParameters.isEmpty()) {
            if (mapQueryParameters.get(RE_GlobalConstants.sWhereClauseKey) != null) {                
                sWhereClause = ' WHERE ' + mapQueryParameters.get(RE_GlobalConstants.sWhereClauseKey);
            }
            if (mapQueryParameters.get(RE_GlobalConstants.sOrderByKey) != null) {                
                sOrderBy  = ' ORDER BY ' + mapQueryParameters.get(RE_GlobalConstants.sOrderByKey);
            }
            if (mapQueryParameters.get(RE_GlobalConstants.sLimitKey) != null) {                
                sLimit = ' LIMIT ' + mapQueryParameters.get(RE_GlobalConstants.sLimitKey);
            }
            if (mapQueryParameters.get(RE_GlobalConstants.sOffset) != null) {                
                sOffset = ' OFFSET ' + mapQueryParameters.get(RE_GlobalConstants.sOffset);
            }                            
        }
        
        
        
        if (sQuery.length() > 7){ // checking that query string include some fields.              
            // sQuery = sQuery.subString(0, sQuery.length() - 2);
            sQuery = sQuery.trim().removeEnd(',');
            sQuery += ' FROM ' + objectAPIName + sWhereClause + sOrderBy + sLimit + sOffset;             
        }
        
        if (String.isNotBlank(sNoAccessFields) && sNoAccessFields.length() > 1) {
            sNoAccessFields = sNoAccessFields.subString(0, sNoAccessFields.length() - 2) ;
            mapResponse.put(false, sNoAccessFields); 
            
        } else {
            mapResponse.put(true, sQuery);
        }
        return mapResponse ;    
    } 
    
    
    public static Map<Boolean, String> checkRelationshipFields(List<String> lstRelatedFields, Schema.SObjectType sObjecttype) /*  objectType*/{        
        Map<Boolean, String> mapResponse = new Map<Boolean, String>();                
        Map<String, List<String>> mapOfParentFields = new Map<String, List<String>>();
        Map<String, String> mapObjectApi = new Map<String, String>();        
        Map<String, Schema.SObjectField> fieldMap = sObjecttype.getDescribe().fields.getMap();
        
        
        String  sFinalAccessibleFields ='';
        String sFinalInAccessibleFields= '';
        
        for (String sRelationshipName : lstRelatedFields) {
            List<String> lstFieldParams = sRelationshipName.split('[.]');                 
            RE_GlobalConstants.SWITCH_CONSTANTS switchContactUserKey = (lstFieldParams.size() == 2) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchContactUserKey) {
                    when SWITCH_SUCCESS {
                String sParentRelation = lstFieldParams[0]; //Contact__r
                String sFieldName = lstFieldParams[1]; //FirstName                       
                String sParentObjectRefField = sParentRelation.replace('__r', '__c'); //Contact__c
                sParentObjectRefField =sParentObjectRefField.trim();
                sParentObjectRefField=RE_GlobalConstants.stdObjName.contains(sParentObjectRefField)?sParentObjectRefField+'Id':sParentObjectRefField;//Adding Salesforce standard object fields
                   
                
                if(!(RE_GlobalConstants.setStdFields.contains(sParentObjectRefField.toLowerCase()))){
                    Schema.SObjectField sFieldType = fieldMap.get(sParentObjectRefField); // FirstName
                    List<Schema.sObjectType> lstReferences = sFieldType.getDescribe().getReferenceTo(); //Contact
                    Schema.sObjectType relatedObject = lstReferences[0]; //Contact
                    String sParentObjectName = relatedObject.getDescribe().getName(); //Contact
                    mapObjectApi.put(sParentObjectName, sParentRelation); //Contact => Contact__r
                    
                    if (!mapOfParentFields.containsKey(sParentObjectName)) {
                        mapOfParentFields.put(sParentObjectName, new List<String>{sFieldName});
                    } else {
                        mapOfParentFields.get(sParentObjectName).add(sFieldName); // Contact => {FirstName, LastName} 
                    }
                }
                else{
                    
                    sFinalAccessibleFields += sRelationshipName +', ';
                    
                }
            }
                when SWITCH_FAILURE {
                sFinalAccessibleFields += sRelationshipName + ', ';// by passing for more than 2 Level relationship.
            }
        }
        }
        
        for (String sKey : mapOfParentFields.keySet()) {
            Map<Boolean, String> mapFields = getSafeFields(mapOfParentFields.get(sKey), sKey);
            String sRelationShipName = mapObjectApi.get(sKey); //Contact__r
            
            
            if (mapFields.get(true) != null){
                String sAccessibleFields = mapFields.get(true); //FirstName, LastName
                
                sAccessibleFields = sRelationShipName + '.' + sAccessibleFields.replaceAll('\\,\\s', ', ' + sRelationShipName + '.'); //Contact__r.FirstName,Contact__r.LastName
                
                sFinalAccessibleFields += sAccessibleFields + ', ';
                
                
            }
            else{
                String sInAccessibleFields = mapFields.get(false); //FirstName, LastName
                sInAccessibleFields = sRelationShipName + '.' + sInAccessibleFields.replaceAll('[,]', ', ' + sRelationShipName + '.'); //Contact__r.FirstName,Contact__r.LastName
                  
                sFinalInAccessibleFields += sInAccessibleFields + ', ';
            }
        }
        
        
        if(sFinalInAccessibleFields.length()>1){
            //sFinalInAccessibleFields = sFinalInAccessibleFields.subString(0, sFinalInAccessibleFields.length() - 2) ;
            mapResponse.put(false,sFinalInAccessibleFields);
        }
        else{
            //sFinalAccessibleFields = sFinalAccessibleFields.subString(0, sFinalAccessibleFields.length() - 2) ;
            mapResponse.put(true,sFinalAccessibleFields);
        }
        
        return mapResponse; 
    }
    
    /**
* @author : Suyash Singhal
* @method : getFieldsAccessibility
* @desc   : This method check accessibility for all fields for the Input object Api name.
* @param  : sObjectName - API Name of object,map<String,String> mapQueryParameters - Stores Whereclause,
*           OrderBy clause, Limit clause, Offset Clause.  
* @return : Map<Boolean,String> - Key as Boolean response  true for success and 
*          false for failure.Value will be query String of comma separated fields in Success scenario 
*          & comma separated not Accessible fields in fail case
* */
    
    
    public static Map<Boolean,String>  getFieldsAccessibility(String objectAPIName, map<String,String> mapQueryParameters){
        
        Map<Boolean,String> mapResponse = new Map<Boolean,String>();
        String sQuery = 'SELECT ';
        String sWhereClause ='';
        String sOrderBy ='';
        String sLimit =''; 
        String sOffset ='';  
        Boolean bIsPermissionAllowed = isPermissionCheckAllowed('Field');
        String sNoAccessFields='';
        List<String> lstFieldAPINames=new List<String>();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        Schema.SObjectType targetsobjectType = SchemaMapGlobal.get(string.escapeSingleQuotes(objectAPIName));
        Map<String, Schema.SObjectField> field_map = targetsobjectType.getDescribe().fields.getMap();
        
        
        for(String strField: field_map.KeySet()){
            if(bIsPermissionAllowed){
                strField = strField.trim();
                if(field_map.get(strField)!=null && field_map.get(strField).getDescribe().isAccessible()){
                    sQuery += strField + ', ';
                }
                else{
                    
                    sNoAccessFields += strField + ', ';
                }
            }
            else{
                sQuery += strField + ', ';
            }
        }
        
        if(sQuery != null && mapQueryParameters !=null && !mapQueryParameters.isEmpty()){
            for(String skey : mapQueryParameters.keySet()){
                if(skey == RE_GlobalConstants.sWhereClauseKey){
                    sWhereClause = ' WHERE ' +mapQueryParameters.get(skey);
                }
                else if(skey == RE_GlobalConstants.sOrderByKey){
                    sOrderBy  = ' ORDER BY ' + mapQueryParameters.get(skey);
                }
                else if(skey == RE_GlobalConstants.sLimitKey){
                    sLimit = ' LIMIT ' +mapQueryParameters.get(skey);
                }
                else if(skey == RE_GlobalConstants.sOffset){
                    sOffset = ' OFFSET ' +mapQueryParameters.get(skey);
                }
            }
        }
        
        if (sQuery.length() > 7){ // checking that query string include some fields.             
            sQuery = sQuery.substring(0, sQuery.length()-2) ;         
            sQuery += ' FROM ' + objectAPIName + sWhereClause +  sOrderBy +sLimit +sOffset;
            
        }
        
        if(String.isNotBlank(sNoAccessFields) && sNoAccessFields.length()>1){
            sNoAccessFields = sNoAccessFields.substring(0, sNoAccessFields.length()-2) ;
            mapResponse.put(false,sNoAccessFields);
            
        }
        else{
            mapResponse.put(true,sQuery);
        }
        
        return mapResponse ; 
        
    }
    
    /***************************************************************************************************
* @author       Suyash Singhal
* @date         05/27/2019
* @methodname   isPermissionCheckAllowed()
* @description  This methods is used to check if Org wide Permission checks are allowed 
* @param        sCheckType    (String)   : CRUD Level or Field level check
* @return       Boolean                  : true if Permission for Check Allowed, False if not
*****************************************************************************************************/
    public static Boolean isPermissionCheckAllowed(String sCheckType) {
        CrudAndAccessibilitySettings__c CRUDAndFieldCheck = CrudAndAccessibilitySettings__c.getOrgDefaults();
        if (sCheckType =='CRUD') {
            return CRUDAndFieldCheck.CRUD__c;
        } else if (sCheckType =='Field') {
            return CRUDAndFieldCheck.FieldAccessibilityCheck__c;
        } else {
            return false;
        }
    }
    
    /*Method Name: checkSafeFields (Single Object Instance)
*@author Suyash Singhal
*@description: Returns map with the list of fields used/filled excluding Id,Autonumber And formulae fields
*@returns Map<Boolean,String> - Key as Boolean response  true for success and 
*          false for failure.Value will be query String of comma separated fields in Success scenario 
*          & comma separated not Accessible fields in fail case
*/
    public static Map<Boolean,String> checkSafeFields(SObject objname){ 
        String listfieldNames='';
        Schema.sObjectType expectedType = objname.getsObjectType();
        String sObjectName = expectedType.getDescribe().getName();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        sObjectType sobjecttypecheck = SchemaMapGlobal.get(sObjectName);
        Map<String,Schema.sObjectField> mfields=sobjecttypecheck.getDescribe().fields.getMap();
        Map<String, Object> fieldsToValue = objname.getPopulatedFieldsAsMap();
        List<String> lstStringFieldrt=New List<String>();
        For (String fieldName : fieldsToValue.keySet()){
            
            If (!fieldName.contains('__r') && !RE_GlobalConstants.setStdFields.contains(fieldName.toLowerCase())) {
                If(!fieldName.contains('.') 
                   && !mfields.get(fieldName).getDescribe().isAutoNumber() 
                   && !mfields.get(fieldName).getDescribe().isCalculated()) {
                       lstStringFieldrt.add(fieldName);
                   }           
            }   
        }
        Map<Boolean,String> mapResponse = getSafeFields(lstStringFieldrt,sObjectName);
        return mapResponse; 
    }
    
    /*Method Name: checkSafeFields (Single Object Instance)
*@author Suyash Singhal
*@description: Returns map with the list of fields used/filled excluding Id,Autonumber And formulae fields
*@returns Map<Boolean,String> - Key as Boolean response  true for success and 
*          false for failure.Value will be query String of comma separated fields in Success scenario 
*          & comma separated not Accessible fields in fail case
*/
    public static Map<Boolean,String> checkSafeFields(SObject objname, String sDMLType){ 
        String listfieldNames='';
        Schema.sObjectType expectedType = objname.getsObjectType();
        String sObjectName = expectedType.getDescribe().getName();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        sObjectType sobjecttypecheck = SchemaMapGlobal.get(sObjectName);
        Map<String,Schema.sObjectField> mfields=sobjecttypecheck.getDescribe().fields.getMap();
        Map<String, Object> fieldsToValue = objname.getPopulatedFieldsAsMap();
        List<String> lstStringFieldrt=New List<String>();
        For (String fieldName : fieldsToValue.keySet()){
            
            If (!fieldName.contains('__r') && !RE_GlobalConstants.setStdFields.contains(fieldName.toLowerCase())) {
                If(!fieldName.contains('.') 
                   && !mfields.get(fieldName).getDescribe().isAutoNumber() 
                   && !mfields.get(fieldName).getDescribe().isCalculated()) {
                       lstStringFieldrt.add(fieldName);
                   }           
            }   
        }
        
        Map<Boolean,String> mapResponse = getSafeFields(lstStringFieldrt,sObjectName,sDMLType);
        return mapResponse; 
    }
    
    /**
* @author : Suyash Singhal
* @method: getQueryStringforSetupObjects
* @desc Build the query string for Setup objects as no accessibility checks are required on these type of Objects.
* @param lstFieldNames - list of fields, sObjectName - API Name of object,
*           map<String,String> mapQueryParameters - Stores Whereclause, OrderBy clause, Limit clause, Offset Clause. 
* @return  - String -  Will return Queryable String
* */
    public static String getQueryStringforSetupObjects(String objectAPIName, String fieldAPINames, map<String,String> mapQueryParameters){
        String sQuery = 'SELECT ';
        String sWhereClause = '';
        String sOrderBy ='';
        String sLimit =''; 
        String sOffset ='';
        
        List<String> lstFieldAPINames=new List<String>();
        //RE_Release 1.1 – Perf - Payal Dubela– 343025
        Schema.SObjectType targetsobjectType = SchemaMapGlobal.get(string.escapeSingleQuotes(objectAPIName));
        if(String.isNotBlank(string.escapeSingleQuotes(fieldAPINames))){ 
            Map<String, Schema.SObjectField> field_map = targetsobjectType.getDescribe().fields.getMap();
            lstFieldAPINames=fieldAPINames.split(',');
            for(String strField:lstFieldAPINames){
                strField = strField.trim();
                sQuery += strField + ', ';
            }
        }
        
        if(sQuery != null && mapQueryParameters !=null && !mapQueryParameters.isEmpty()){
            for(String skey : mapQueryParameters.keySet()){
                if(skey == RE_GlobalConstants.sWhereClauseKey){
                    sWhereClause = ' WHERE ' +mapQueryParameters.get(skey);
                }
                else if(skey == RE_GlobalConstants.sOrderByKey){
                    sOrderBy  = ' ORDER BY ' + mapQueryParameters.get(skey);
                }
                else if(skey == RE_GlobalConstants.sLimitKey){
                    sLimit = ' LIMIT ' +mapQueryParameters.get(skey);
                }
                else if(skey == RE_GlobalConstants.sOffset){
                    sOffset = ' OFFSET ' +mapQueryParameters.get(skey);
                }
            }
        }
        if(sQuery.length() > 7){ // checking that query string include some fields. 
            
            sQuery = sQuery.substring(0, sQuery.length()-2) ;
            
            sQuery += ' FROM ' + objectAPIName + sWhereClause +  sOrderBy +sLimit +sOffset;
            
        }
        return sQuery;        
    }
    /**
* @author : Ravi Shankar Peri
* @method: insertObject
* @desc: Insert utility method  for non setup objects
* @param objectType - schema object type,
*         obj - sObject to be inserted. 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */
    public static Database.SaveResult[] insertObject(Schema.SobjectType objectType, Sobject obj) {
        return insertObjects(objectType, new List<Sobject>{obj}, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: insertObjects
* @desc: Overloaded insert utility method  for non setup objects
* @param objectType - schema object type,
*         lstObjects - list of sObject to be inserted. 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */
    public static Database.SaveResult[] insertObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) {
        
        
        return insertObjects(objectType, lstObjects, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: insertObjects
* @desc: Overloaded insert utility method  for non setup objects
* @param objectType - schema object type,
*         lstObjects - list of sObject to be inserted,
*         bAllOrNone - allow force insert or not 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */       
    public static Database.SaveResult[] insertObjects(Schema.SobjectType objectType, List<Sobject> lstObjects, Boolean bAllOrNone) {
        Database.SaveResult[] lstSaveResults;
        if (RE_DataAccessChecker.isAllowedToCreate(objectType)) {
            
            
            Map<Boolean, String> mapOfSafeFields = RE_DataAccessChecker.checkSafeFields(lstObjects[0],RE_GlobalConstants.sInsert);  
            
            if (mapOfSafeFields.get(true) != null) {
                
                lstSaveResults = Database.insert(lstObjects, bAllOrNone);
                                
            } else {
                throw new RE_DataAccessException(mapOfSafeFields.get(false), objectType);
            }
        } else {
            throw new RE_DmlException('No Create permission on the object ' + objectType);
        }
        return lstSaveResults;
    }
    /**
* @author : Ravi Shankar Peri
* @method: insertSetUpObject
* @desc: Insert utility method for setup objects 
* @param objectType - schema object type,
*        obj - sObject to be inserted. 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */
    public static Database.SaveResult[] insertSetUpObject(Schema.SobjectType objectType, Sobject obj) {
        return insertSetUpObjects(objectType, new List<Sobject>{obj}, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: insertSetUpObjects
* @desc: Overloaded insert utility method  for setup objects
* @param objectType - schema object type,
*        lstObjects - list of sObject to be inserted. 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */
    public static Database.SaveResult[] insertSetUpObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) {
        return insertSetUpObjects(objectType, lstObjects, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: insertSetUpObjects
* @desc: Overloaded insert utility method  for setup objects
* @param objectType - schema object type,
*        lstObjects - list of sObject to be inserted,
*        bAllOrNone - allow force insert or not 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */        
    public static Database.SaveResult[] insertSetUpObjects(Schema.SobjectType objectType, List<Sobject> lstObjects, Boolean bAllOrNone) {
        Database.SaveResult[] lstSaveResults;
        try{
            lstSaveResults = Database.insert(lstObjects, bAllOrNone); 
        }catch(Exception e){
            throw new RE_DmlException('Insertion failed :' + objectType + e.getMessage());
        }
        return lstSaveResults;
    }
    /**
* @author : Ravi Shankar Peri
* @method: updateSetUpObject
* @desc: update utility method for setup objects 
* @param objectType - schema object type,
*        obj - sObject to be update. 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */
    public static Database.SaveResult[] updateSetUpObject(Schema.SobjectType objectType, Sobject obj) {
        return updateSetUpObjects(objectType, new List<Sobject>{obj}, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: updateSetUpObjects
* @desc: update utility method for setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be update. 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */
    public static Database.SaveResult[] updateSetUpObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) {
        return updateSetUpObjects(objectType, lstObjects, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: updateSetUpObjects
* @desc: update utility method for setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be update,
*        bAllOrNone - allow force insert or not 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */        
    public static Database.SaveResult[] updateSetUpObjects(Schema.SobjectType objectType, List<Sobject> lstObjects, Boolean bAllOrNone) {
        Database.SaveResult[] lstSaveResults;
        try{
            lstSaveResults = Database.update(lstObjects, bAllOrNone); 
        }catch(Exception e){
            throw new RE_DmlException('Insertion failed :' + objectType + e.getMessage());
        }
        return lstSaveResults;
    }
    /**
* @author : Ravi Shankar Peri
* @method: updateObject
* @desc: update utility method for non setup objects 
* @param objectType - schema object type,
*        obj - sObject to be update,
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */   
    public static Database.SaveResult[] updateObject(Schema.SobjectType objectType, Sobject obj) {
        return updateObjects(objectType, new List<Sobject>{obj}, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: updateObjects
* @desc: update utility method for non setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be update,
*        bAllOrNone - allow force insert or not 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */  
    public static Database.SaveResult[] updateObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) {
        return updateObjects(objectType, lstObjects, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: updateObjects
* @desc: update utility method for non setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be update,
*        bAllOrNone - allow force insert or not 
* @return  - Database.SaveResult[] -  Will return array of Databse.SaveResults
* */  
    public static Database.SaveResult[] updateObjects(Schema.SobjectType objectType, List<Sobject> lstObjects, Boolean bAllOrNone) {
        Database.SaveResult[] lstSaveResults;
        if (RE_DataAccessChecker.isAllowedToUpdate(objectType)) {
            Map<Boolean, String> mapOfSafeFields = RE_DataAccessChecker.checkSafeFields(lstObjects[0],RE_GlobalConstants.sUpdate);            
            if (mapOfSafeFields.get(true) != null) {
                lstSaveResults = Database.update(lstObjects, bAllOrNone);                
            } else {
                throw new RE_DataAccessException(mapOfSafeFields.get(false), objectType);
            }
        } else {
            throw new RE_DmlException('No Edit permission on the object ' + objectType);
        }
        return lstSaveResults;
    }
    /**
* @author : Ravi Shankar Peri
* @method: upsertObject
* @desc: update utility method for upsert on non setup objects 
* @param objectType - schema object type,
*        obj - list of sObject to be upsert,
* @return  - Database.UpsertResult[] -  Will return array of Databse.SaveResults
* */  
   /* public static Database.UpsertResult[] upsertObject(Schema.SobjectType objectType, Sobject obj) {
        return upsertObjects(objectType, new List<Sobject>{obj}, true);
    } */
    /**
* @author : Ravi Shankar Peri
* @method: upsertObjects
* @desc: update utility method for upsert on non setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be upsert,
* @return  - Database.UpsertResult[] -  Will return array of Databse.SaveResults
* */  
   /* public static Database.UpsertResult[] upsertObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) {
        return upsertObjects(objectType, lstObjects, true);
    } */
    /**
* @author : Ravi Shankar Peri
* @method: upsertObjects
* @desc: update utility method for upsert on non setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be upsert,
*        bAllOrNone - allow force insert or not 
* @return  - Database.UpsertResult[] -  Will return array of Databse.SaveResults
* */  
    /*public static Database.UpsertResult[] upsertObjects(Schema.SobjectType objectType, List<Sobject> lstObjects, Boolean bAllOrNone) {
        Database.UpsertResult[] lstUpsertResults;
        
        if (RE_DataAccessChecker.isAllowedToCreate(objectType) && RE_DataAccessChecker.isAllowedToUpdate(objectType)) {
            Map<Boolean, String> mapOfSafeFields = RE_DataAccessChecker.checkSafeFields(lstObjects[0],RE_GlobalConstants.sUpsert);            
            if (mapOfSafeFields.get(true) != null) {
                lstUpsertResults = Database.upsert(lstObjects, bAllOrNone);                
            } else {
                throw new RE_DataAccessException(mapOfSafeFields.get(false), objectType);
            }
        } else {
            throw new RE_DmlException('No Upsert permission on the object ' + objectType);
        }
        return lstUpsertResults;
    } */
    /**
* @author : Ravi Shankar Peri
* @method: deleteObject
* @desc: update utility method for delete non setup objects 
* @param objectType - schema object type,
*        obj - sObject to be deleted,
*        bAllOrNone - allow force insert or not 
* @return  - Database.DeleteResult[] -  Will return array of Databse.SaveResults
* */ 
    public static Database.DeleteResult[] deleteObject(Schema.SobjectType objectType, Sobject obj) {
        return deleteObjects(objectType, new List<Sobject>{obj}, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: deleteObjects
* @desc: update utility method for delete non setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be deleted,
* @return  - Database.DeleteResult[] -  Will return array of Databse.SaveResults
* */ 
    public static Database.DeleteResult[] deleteObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) {
        return deleteObjects(objectType, lstObjects, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: deleteObjects
* @desc: update utility method for delete non setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be deleted,
* @return  - Database.DeleteResult[] -  Will return array of Databse.SaveResults
* */ 
    public static Database.DeleteResult[] deleteObjects(Schema.SobjectType objectType, List<Sobject> lstObjects, Boolean bAllOrNone) {
        Database.DeleteResult[] lstDeleteResults;
        if (RE_DataAccessChecker.isAllowedToDelete(objectType)) {            
            lstDeleteResults = Database.delete(lstObjects, bAllOrNone);                            
        } else {
            throw new RE_DmlException('No Delete permission on the object ' + objectType);
        }
        return lstDeleteResults;
    }
    /**
* @author : Ravi Shankar Peri
* @method: deleteSetUpObject
* @desc: update utility method for delete setup objects 
* @param objectType - schema object type,
*        obj - sObject to be deleted,
* @return  - Database.DeleteResult[] -  Will return array of Databse.SaveResults
* */
    public static Database.DeleteResult[] deleteSetUpObject(Schema.SobjectType objectType, Sobject obj) {
        return deleteSetUpObjects(objectType, new List<Sobject>{obj}, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: deleteSetUpObjects
* @desc: update utility method for delete setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be deleted,
* @return  - Database.DeleteResult[] -  Will return array of Databse.SaveResults
* */ 
    public static Database.DeleteResult[] deleteSetUpObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) {
        return deleteSetUpObjects(objectType, lstObjects, true);
    }
    /**
* @author : Ravi Shankar Peri
* @method: deleteSetUpObjects
* @desc: update utility method for delete setup objects 
* @param objectType - schema object type,
*        lstObjects - list of sObject to be deleted,
* @return  - Database.DeleteResult[] -  Will return array of Databse.SaveResults
* */ 
    public static Database.DeleteResult[] deleteSetUpObjects(Schema.SobjectType objectType, List<Sobject> lstObjects, Boolean bAllOrNone) {
        Database.DeleteResult[] lstDeleteResults;
        try{
            lstDeleteResults = Database.delete(lstObjects, bAllOrNone); 
        }catch(Exception e){
            throw new RE_DmlException('Deletion failed :' + objectType + e.getMessage());
        }
        return lstDeleteResults;
    }
    /**
* @author : Ravi Shankar Peri
* @Class Name: RE_DataAccessException
* @desc: Custom exception class for DML exception
* */ 
    public class RE_DataAccessException extends Exception {
        private String sFieldNames;
        private Schema.SObjectType objectType;
        public RE_DataAccessException(String sFieldNames, Schema.SObjectType objectType){
            this.objectType = objectType;
            this.sFieldNames = sFieldNames;
            this.setMessage( 'No access to the field(s) ' + sFieldNames + ' of the object ' + objectType );
        }
        
    }
    
    public class RE_DmlException extends Exception{}
    
}