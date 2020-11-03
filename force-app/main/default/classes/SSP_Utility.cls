
/*
* classname     :  SSP_Utility
* @description  :  class to hold all utility methods for SSP
* @author       :  Shrikant Raut   
* @date         :  11/14/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public inherited sharing class SSP_Utility {

    private static Map<String, Schema.SObjectType> sObjectdescribeMap;


    //Perf Fix: Lazy initialization of getDescribe call
    private static void initializeDescribe(){
        sObjectdescribeMap = Schema.getGlobalDescribe();
    }
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         11/14/2019
* @methodname   getPickListValues
* @description  This methods is retrieve picklist label and values
* @return       Map<value, label>
* @parameters   objectName - SF Object API Name
fieldName  - SF Field API Name
firstValue - if there is some static first value needed (e.g. NONE, SELECT), pass null if no such static value needed
*****************************************************************************************************/
    public static Map<String,String> getPickListValues (String objectName, String fieldName, String firstValue) {
        Map<String,String> options = new Map<String,String>(); 
        if (firstValue != null && firstValue != '') { 
            options.put(firstValue,firstValue); 
        }

        //Perf Fix: Lazy initialization of getDescribe call
        if(sObjectdescribeMap == null){
            initializeDescribe();
        }

        Map<String, Schema.SObjectType> schemaDescribe = sObjectdescribeMap;
        Schema.DescribeFieldResult fieldResult = schemaDescribe.get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListEntry: pickListEntries) 
        {
            options.put(pickListEntry.getValue(),pickListEntry.getLabel());
        }
        return options;
    }
    


    /***************************************************************************************************
* @author       Shrikant Raut
* @date         12/04/2019
* @methodname   getFieldsforESAPI
* @description  This methods is used to remove tolabel() string from the fieldAPIs from fieldset
* @return       Set<String>
* @parameters   fieldAPISet - Set<String>
*****************************************************************************************************/
    public static set<String> getFieldsforESAPI(set<String> fieldAPISet){
        Set<String> updatedSet = new set<String>();
        if(fieldAPISet != null && !fieldAPISet.isEmpty()){
            for(String fieldAPI : fieldAPISet){
                String tmpStr =fieldAPI;
                Integer len = fieldAPI.length();
                if(len >= 8 && (fieldAPI.substring(0,8)).equalsIgnoreCase('tolabel(')){
                    //&& (fieldAPI.substring(len-1)).equalsIgnoreCase(')')){
                    //tmpStr =  fieldAPI.subString(8,len-1);
                    tmpStr =  fieldAPI.subString(8,tmpStr.indexOf(')',8));
                }
                updatedSet.add(tmpStr);
            }
        }
        return updatedSet;
    }
    
    
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/14/2019
    * @methodname   fetchRecords
    * @description  This methods is used to query for records dynamically
    * @return       List of object queried
    * @parameters   detailMap      - Map<String, String> -- 'objectName' => SF Object API Name, 'operator' => AND/OR
fieldSet       - Set of SF Field API Names to be queried
conditionsMap  - Map of conditions (Key - fieldName, value - expected value)    
For Boolean conditions use '#true#' or '#false#'   
For IN Clause make entry in detailMap : 'IN' => 'comma separated fieldAPI's for which IN operation has to be performed'
AND in conditionMap follow the same approach 'fieldAPI' => 'comma separated string of list entries to be added in IN clause against the field API given in key'
if query contains toLabel(), add 'hasToLabel' => 'true' in detailMap 
For Date/DateTime fields, pass the serialized form in to condition map e.g(JSON.serialize(date/datetimevalue))
For comparator other than '=', add an entry to detail map eg. 'fieldAPI' => '<='         
For the values that do not need type conversion, add an entry to detail map eg. 'noTypeConversion' => <csv of fieldAPI>                                      
For the values that should not be added in quotes while querying, add an entry to detail map eg. 'directComparison' => <csv of fieldAPI>                                      
*****************************************************************************************************/
    public static List<SObject> fetchRecords(Map<String, String> detailMap, Set<String> fieldSet, Map<String, String> conditionsMap) {            
        String fields = ''; //to hold comma separated field API names
        String query = ''; //to hold construct query
        String conditions = ''; //to hold query conditions
        String limitValue = '1000'; //to hold query limit value
        List<String> fieldTypes = new List<String>{'integer','double','boolean','currency','date','datetime','directcomparison'};
            List<SObject> sObjList = new List<SObject>();
        List<String> fieldAPI_INClause = (detailMap != null && !detailMap.isEmpty() && detailMap.containsKey('IN')) ? (detailMap.get('IN')).split(',') : new List<String>(); 
        List<String> excludeTypeConversion = (detailMap != null && !detailMap.isEmpty() && detailMap.containsKey('noTypeConversion')) ? (detailMap.get('noTypeConversion')).split(',') : new List<String>(); 
        List<String> directComparisonList = (detailMap != null && !detailMap.isEmpty() && detailMap.containsKey('directComparison')) ? (detailMap.get('directComparison')).split(',') : new List<String>(); 
        String objName = (detailMap != null && !detailMap.isEmpty() && detailMap.containsKey('objectName')) ? detailMap.get('objectName') : null;
        String operator = (detailMap != null && !detailMap.isEmpty() && detailMap.containsKey('operator')) ? detailMap.get('operator') : null;
        Boolean hasToLabel = (detailMap != null && !detailMap.isEmpty() && detailMap.containsKey('hasToLabel'));
        try
        {   
            //Set<String> fieldSetESAPI = hasToLabel ? getFieldsforESAPI(fieldSet) : fieldSet;//Removed for Perf fix - Keshav
            //Below code commented for Performance tuning - Keshav - logic included in getFieldType method
            /*if(!((objName != null && (objName.right(5)).equalsIgnoreCase('__mdt')) || ESAPI.accessController().isAuthorizedToView(sObjectdescribeMap.get(objName), SSP_Utility.getFieldsForAuthorisedView(objName, fieldSetESAPI)))){            
                
                return new List<SObject>();
            }*/
            for(String field : fieldSet) {
                fields += field + ' ,';
            }                
            fields=fields.substring(0, fields.length()-1);
            
            if (conditionsMap != null && !conditionsMap.isEmpty()) {
                for (String fieldAPI : conditionsMap.keySet()){
                    if(fieldAPI.toLowerCase().trim() == 'limit') {
                        limitValue = conditionsMap.get(fieldAPI);
                        conditionsMap.remove('limit');
                        continue;
                        }
                    String condValue = conditionsMap.get(fieldAPI);
                    String fieldType;// = getFieldType(objName, cond.trim());
                    fieldAPI = fieldAPI.trim();
                    
                    
                    Map<String, String> fieldValueMap = (directComparisonList != null && directComparisonList.contains(fieldAPI)) ? new Map<String, String>{'fieldType'=>'directComparison','value'=>condValue}: determineFieldType(objName, fieldAPI, excludeTypeConversion.contains(fieldAPI)  ? null : condValue);
                    fieldType =    (fieldValueMap != null && fieldValueMap.containsKey('fieldType')) ? fieldValueMap.get('fieldType') :fieldType;
                    condValue = (!excludeTypeConversion.contains(fieldAPI) && fieldValueMap != null && fieldValueMap.containsKey('value')) ? fieldValueMap.get('value') : condValue;
                    
                    condValue = condValue != null ? String.escapeSingleQuotes(condValue) : condValue;
                    fieldAPI = fieldAPI != null ? String.escapeSingleQuotes(fieldAPI) : fieldAPI;
                    operator = operator!=null ? String.escapeSingleQuotes(operator) : operator;

                    //For IN and specific field type
                    if(fieldTypes.contains(fieldType.toLowerCase()) && fieldAPI_INClause.contains(fieldAPI) && condValue.contains(',')){
                        conditions += fieldAPI + ' IN ( ' + condValue + ' ) ' + operator + ' ';   
                    }
                    //For specific field type
                    else if(fieldTypes.contains(fieldType.toLowerCase())){
                        String comparator = (detailMap != null && detailMap.containsKey(fieldAPI)) ? (detailMap.get(fieldAPI)+' ') : '= ';
                        conditions += fieldAPI + ' ' + comparator +condValue + ' ' + operator + ' ';   
                    }
                    //For IN
                    else if(fieldAPI_INClause.contains(fieldAPI) && conditionsMap.get(fieldAPI).contains(',')){
                        String newValue = condValue.replaceAll(',','\',\'').trim();
                        conditions += fieldAPI + ' IN ( \'' + newValue + '\' ) ' + operator + ' ';   
                    }
                    //Normal comparison
                    else{
                        String comparator = (detailMap != null && detailMap.containsKey(fieldAPI)) ? (detailMap.get(fieldAPI)+' ') : '= ';
                        conditions += fieldAPI + ' ' + comparator+'\'' + condValue + '\' ' + operator + ' ';   
                    }   
                }
                conditions = conditions.removeEnd(operator+' ');
            }
         if(objname.equalsIgnoreCase('SSP_ApplicationIndividual__c') ){
             if (conditionsMap != null && !conditionsMap.isEmpty() && limitValue != '' && objName != null){
                 query = 'SELECT '+ fields +' FROM '+objName+' WHERE ' + conditions + ' Order By IsHeadOfHousehold__c DESC,SSP_Member__r.IndividualId__c LIMIT ' + limitValue;
             }
             else if(objName != null){
                 query = 'SELECT '+ fields +' FROM '+objName + ' Order By IsHeadOfHousehold__c DESC,SSP_Member__r.IndividualId__c LIMIT ' + limitValue;
             }
         }else{
             if (conditionsMap != null && !conditionsMap.isEmpty() && limitValue != '' && objName != null){
                 query = 'SELECT '+ fields +' FROM '+objName+' WHERE ' + conditions + ' LIMIT ' + limitValue;
             }
             else if(objName != null){
                 query = 'SELECT '+ fields +' FROM '+objName + ' LIMIT ' + limitValue;
             }
         }
            if(query != null){
                sObjList = Database.query(query);
            }
        }
        catch(Exception e){
            throw e;
        } 
        return sObjList; 
    } 
    
    
    private static Map<String, String> determineFieldType(String objName, String fieldName, String value){
        String fieldType;
        
        if(value != null && (value.equalsIgnoreCase('#true#') || value.equalsIgnoreCase('#false#') || value.equalsIgnoreCase('#null#'))){
            value = (value.equalsIgnoreCase('#true#')) ? 'true' : (value.equalsIgnoreCase('#false#') ? 'false' : (value.equalsIgnoreCase('#null#') ? 'null' : value)) ;
                fieldType = 'boolean';
        }
        else{
            fieldType = getFieldType(objName, fieldName);
            if(fieldType.equalsIgnoreCase('date') && value != null){
                DateTime dateValue = Date.valueOf(value);//(Date)JSON.deserialize(value, Date.class);
                value= dateValue.format('yyyy-MM-dd','GMT');
            }
            else if(fieldType.equalsIgnoreCase('datetime') && value != null){
                DateTime dateTimeValue = (DateTime)JSON.deserialize(value, DateTime.class);
                value = dateTimeValue.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }
        }
        return new Map<String, String> {'fieldType'=> fieldType, 'value' => value};
            
            }
    
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         11/14/2019
* @methodname   getFieldType
* @description  This methods is identify the datatype of field
* @return       String - datatype name
* @parameters   objName    - SF object API name
fieldName  - SF field API name
*****************************************************************************************************/
    public static String getFieldType(String objName, String fieldName)
    {
        if(fieldName.contains('.')){
            List<String> splitStr = fieldName.split('\\.');
            String tmpObjName;
            fieldName = splitStr[splitStr.size()-1];
            tmpObjName = splitStr[splitStr.size()-2];
            objName = ((tmpObjName.right(3)).equalsIgnoreCase('__r')) ? tmpObjName.subString(0, tmpObjName.length()-1)+'c' : tmpObjName;
        }
        Schema.DescribeFieldResult fr;
        try{
            if(String.isNotBlank(objName) && String.isNotBlank(fieldName)){ 
                //Perf Fix: Lazy initialization of getDescribe call
                if(sObjectdescribeMap == null){
                    initializeDescribe();
                }
            
                Schema.SObjectType t = sObjectdescribeMap.get(objName);                    
                if(t != null){ 
                    Schema.DescribeSObjectResult res = t.getDescribe();        
                    fr = res.fields.getMap().get(fieldName).getDescribe();
                    //Code added for Performance tuning - Keshav
                    if(!(objName.right(5)).equalsIgnoreCase('__mdt') && !fr.isAccessible()){
                        throw new AccessException('Field not accessible '+fieldName);
                    }   
                }	
        	} 
        }
        catch(Exception e)
        {
            throw e;
        }
        return (fr != null && fr.getType() != null) ? String.valueOf(fr.getType()) : 'NA'; 
    }
    public class AccessException extends Exception {}

    /***************************************************************************************************
* @author       Kireeti Gora
* @date         11/18/2019
* @methodname   getDependentPicklistValues
* @description  This methods is fetch depenedent picklist values
* @return       String - JSON String of Picklist Values
* @parameters   strSObjectField    - sfObjectApiName.SfFieldApiName

*****************************************************************************************************/    
    @AuraEnabled(cacheable=true)
    public static String getDependentPicklistValues( String strSObjectField )
    {   
        
        List<String> splitString = strSObjectField.split('\\.');
        
        //Perf Fix: Lazy initialization of getDescribe call
        if(sObjectdescribeMap == null){
            initializeDescribe();
        }
        
        Schema.SobjectField dependToken = sObjectdescribeMap.get(splitString[0]).getDescribe().fields.getMap().get(splitString[1]);
        List<Schema.PicklistEntry> lstValues = new List<Schema.PicklistEntry>();
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
                if(!lstValues.contains(entry)){
                    lstValues.add(entry);
                }
            }
        }
        string str = JSON.serialize(lstValues);
        return str;
    }
    /*Method Name: retFieldsNamesList (List of Object)
*@date :
*@author Karthik Gulla
*@description: Returns columns from the list excluding Id,Autonumber And formulae field
*@returns List<String>
*/
    public static List<String> getFieldsNamesList(List<sObject> lstObjRecords) {
        SObject obj = lstObjRecords[0];
        return getFieldsNamesObject(obj);
    }
    
    /*Method Name: getFieldsNamesObject (Single Object)
*@date :
*@author Karthik Gulla
*@description: Returns columns from the list excluding Id,Autonumber And formulae field
*@returns List<String>
*/
    public static List<String> getFieldsNamesObject(SObject objname){        
        Schema.sObjectType expectedType = objname.getsObjectType();
        String sObjectName = expectedType.getDescribe().getName();
        
        //Perf Fix: Lazy initialization of getDescribe call
        if(sObjectdescribeMap == null){
            initializeDescribe();
        }
        
        sObjectType sobjecttypecheck = sObjectdescribeMap.get(sObjectName);
        Map<String,Schema.sObjectField> mfields=sobjecttypecheck.getDescribe().fields.getMap();
        Map<String, Object> fieldsToValue = objname.getPopulatedFieldsAsMap();
        List<String> lstStringFieldrt=New List<String>();
        Set<String> setAuditFields = New Set<String>{'Id', 'CreatedDate', 'LastModifiedDate', 'CreatedBy', 'LastModifiedBy','Profile'};
            for (String fieldName : fieldsToValue.keySet()){
                if (!fieldName.contains('__r')) {
                    if(!fieldName.contains('.') && !setAuditFields.contains(fieldName)
                       && !mfields.get(fieldName).getDescribe().isAutoNumber() 
                       && !mfields.get(fieldName).getDescribe().isCalculated()) {
                           lstStringFieldrt.add(fieldName);
                       }           
                }   
            }
        return lstStringFieldrt;
    }
    
    public static List<String> getFieldsForAuthorisedView(String strObjectName, Set<String> setFields) {
        
        //Perf Fix: Lazy initialization of getDescribe call
        if(sObjectdescribeMap == null){
            initializeDescribe();
        }
    
        sObjectType sobjecttypecheck = sObjectdescribeMap.get(strObjectName);
        Map<String,Schema.sObjectField> mfields=sobjecttypecheck.getDescribe().fields.getMap();
        List<String> lstStringFieldrt=New List<String>();
        Set<String> setAuditFields = New Set<String>{'Id', 'CreatedDate', 'LastModifiedDate', 'CreatedBy', 'LastModifiedBy','Profile'};
            for (String fieldName : setFields){
                if (!fieldName.contains('__r')) {
                     if(!fieldName.contains('.') && !setAuditFields.contains(fieldName)){
                        //Edited for perf fix
                        Schema.DescribeFieldResult dfr = mfields.get(fieldName).getDescribe();
                        if(!dfr.isAutoNumber() && !dfr.isCalculated()){
                            lstStringFieldrt.add(fieldName);
                        }
                    }
                      /* && !mfields.get(fieldName).getDescribe().isAutoNumber() 
                       && !mfields.get(fieldName).getDescribe().isCalculated()) {
                           lstStringFieldrt.add(fieldName);
                       }    */       
                }   
            }
        return lstStringFieldrt;
    }
    
    /*
*Method Name: fetchRecordType
*Description: Method to fetch the record type based on provided record type developer name And sobject name.
Returns record type instance.
*
*Author: Ingole Anuja
*/
public Static RecordType fetchRecordType(String strRecordTypeDeveloperName, String strSobjectName){
        RecordType result = null;
        If (strRecordTypeDeveloperName != null && strSobjectName != null){
            

            List<RecordType> lstRecordType = (List<RecordType>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'RecordType','operator'=>'AND'}, new Set<String>{'Description','DeveloperName','IsActive','Id','Name','SobjectType'}, new Map<String, String>{'limit'=>'1','DeveloperName'=>strRecordTypeDeveloperName,'SobjectType'=>strSobjectName});            
            if(lstRecordType != null && !lstRecordType.isEmpty())                     
                result =  lstRecordType[0];
        }   
        return result;            
    }
    
    /*
* Method Name: isAuthenticatedUser
* Description: Checks if the user is authentiacted to access the system
* Returns throws exception for non authenticated users.
* Author: Nupoor Nimbalkar
* */    
    public static void isAuthenticatedUser() {
        if (UserInfo.getUserType() == 'Guest') {
            throw new AuthenticationException('*** You are not authenticated to access the system ***');
        }        
    }        
    /*
*Method Name: getRecrodTypeIdBySobjectAndDevName
*Description: Method to fetch the record type based on provided record type developer name And sobject name.
*Returns record type instance.    
*Author: Shrikant Raut
*/
    Public Static Id getRecrodTypeIdBySobjectAndDevName(String sobjectName, String strRecordTypeDeveloperName ){
        return Schema.describeSObjects(New String[]{sobjectName}).get(0).getRecordTypeInfosByDeveloperName().get(strRecordTypeDeveloperName).getRecordTypeId();
    }    
    Public Class AuthenticationException extends Exception{}    
    /**
* @author : Sai Kiran
* @method : getsQueryonFields
* @desc   : Get the String of comma separated field Api names.
*           This method uses specific fields as inputted by Calling class
* @param  : lstFieldNames - list of fields, sObjectName - API Name of object,
*           map<String,String> mapQueryParameters - Stores Whereclause, OrderBy clause, Limit clause, Offset Clause.  
* @return : String Query
* */    
    public static String getsQueryonFields(String objectAPIName, String fieldAPINames, Map<String, String> mapQueryParameters) {
        Map<Boolean, String> mapResponse = new Map<Boolean, String>();
        String sQuery = 'SELECT ';
        String sWhereClause = '';
        String sOrderBy = '';
        String sLimit = ''; 
        String sOffset = '';          
        List<String> lstFieldAPINames = new List<String>();
        
        //Perf Fix: Lazy initialization of getDescribe call
        if(sObjectdescribeMap == null){
            initializeDescribe();
        }
        
        Schema.SObjectType targetsobjectType = sObjectdescribeMap.get(String.escapeSingleQuotes(objectAPIName));
        if (String.isNotBlank(String.escapeSingleQuotes(fieldAPINames))) {
            Map<String, Schema.SObjectField> mapOfFields = targetsobjectType.getDescribe().fields.getMap();
            lstFieldAPINames = fieldAPINames.split(',');
            List<String> lstRelatedFields = new List<String>();
            for (String strField : lstFieldAPINames) {
                strField = strField.trim();
                //Relationship
                //Check if the field is valid  
                
                if (strField.contains('.')) {
                    lstRelatedFields.add(strField);
                } else if(SSP_GlobalConstants.setStdFields.contains(strField.toLowerCase()) || mapOfFields.get(strField) != null) {
                    sQuery += strField + ', ';
                }             
            }
            //lstRelatedFields, targetsobjectType
            String sAPIRelationFields = checkRelationshipFields(lstRelatedFields,targetsobjectType);
            if(String.isNotBlank(sAPIRelationFields)){ //Iron Dome fix (7-22)
                sQuery += sAPIRelationFields;
                
            }
            
        } 
        
        if (mapQueryParameters != null && !mapQueryParameters.isEmpty()) {
            if (mapQueryParameters.get(SSP_GlobalConstants.sWhereClauseKey) != null) {                
                sWhereClause = ' WHERE ' + mapQueryParameters.get(SSP_GlobalConstants.sWhereClauseKey);
            }
            if (mapQueryParameters.get(SSP_GlobalConstants.sOrderByKey) != null) {                
                sOrderBy  = ' ORDER BY ' + mapQueryParameters.get(SSP_GlobalConstants.sOrderByKey);
            }
            if (mapQueryParameters.get(SSP_GlobalConstants.sLimitKey) != null) {                
                sLimit = ' LIMIT ' + mapQueryParameters.get(SSP_GlobalConstants.sLimitKey);
            }
            if (mapQueryParameters.get(SSP_GlobalConstants.sOffset) != null) {                
                sOffset = ' OFFSET ' + mapQueryParameters.get(SSP_GlobalConstants.sOffset);
            }                            
        }
        
        
        
        if (sQuery.length() > 7){ // checking that query string include some fields.              
            sQuery = sQuery.trim().removeEnd(',');
            sQuery += ' FROM ' + objectAPIName + sWhereClause + sOrderBy + sLimit + sOffset;             
        }
        
        return sQuery ;    
    } 
    /**
* @author : Sai Kiran
* @method: checkRelationshipFields
* @desc Get the String of comma separated field Api names which.
* @param lstFieldNames - list of fields, sObjectName - API Name of object
* @return  String
* */
    
    public static String checkRelationshipFields(List<String> lstRelatedFields, Schema.SObjectType sObjecttype) /*  objectType*/{        
        Map<Boolean, String> mapResponse = new Map<Boolean, String>();                
        Map<String, List<String>> mapOfParentFields = new Map<String, List<String>>();
        Map<String, String> mapObjectApi = new Map<String, String>();        
        Map<String, Schema.SObjectField> fieldMap = sObjecttype.getDescribe().fields.getMap();
        String  sFinalAPIFields ='';
        
        for (String sRelationshipName : lstRelatedFields) {
            List<String> lstFieldParams = sRelationshipName.split('[.]');                 
            if (lstFieldParams.size() == 2) {
                String sParentRelation = lstFieldParams[0]; //Contact__r
                String sFieldName = lstFieldParams[1]; //FirstName                       
                String sParentObjectRefField = sParentRelation.replace('__r', '__c'); //Contact__c
                sParentObjectRefField =sParentObjectRefField.trim();
                sParentObjectRefField=SSP_GlobalConstants.stdObjName.contains(sParentObjectRefField)?sParentObjectRefField+'Id':sParentObjectRefField;//Adding Salesforce standard object fields
                
                if(!(SSP_GlobalConstants.setStdFields.contains(sParentObjectRefField.toLowerCase()))){
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
                    
                    sFinalAPIFields += sRelationshipName +', ';
                    
                }
            }
            else{
                sFinalAPIFields += sRelationshipName + ', ';// by passing for more than 2 Level relationship.
            }
        }
        
        for (String sKey : mapOfParentFields.keySet()) {
            String sAPIFields = getFields(mapOfParentFields.get(sKey), sKey);
            String sRelationShipName = mapObjectApi.get(sKey); //Contact__r
            
            sAPIFields = sRelationShipName + '.' + sAPIFields.replaceAll('\\,\\s', ', ' + sRelationShipName + '.'); //Contact__r.FirstName,Contact__r.LastName
            
            sFinalAPIFields += sAPIFields + ', ';
        }
        return sFinalAPIFields; 
    }
    
    /**
* @author : Sai Kiran
* @method: getFields
* @desc Get the String of comma separated field Api names which.
* @param lstFieldNames - list of fields, sObjectName - API Name of object
* @return  String
* */
    public static String getFields(List<String> lstFieldNames, String sObjectName) {
        
        String sApiFields = '';
        
        //Perf Fix: Lazy initialization of getDescribe call
        if(sObjectdescribeMap == null){
            initializeDescribe();
        }
        
        Map<String, Schema.SObjectType> schemaMap = sObjectdescribeMap;
        SObjectType objType = schemaMap.get(sObjectName);
        Map<String, SObjectField> mapOfFields = objType.getDescribe().fields.getMap();
        for (String sFieldName : lstFieldNames) {            
            sApiFields += sFieldName + ', ';
        } 
        if (String.isNotBlank(sApiFields)) {
            sApiFields = sApiFields.substring(0, sApiFields.length() - 2) ;
        }
        return sApiFields;
    }    
   
    /*
    * @method 		: today
    * @description  : This method returns the Date based on TimeTravelSetting__c Custom Setting.
    * @author 		: Ashwin Kasture
    * @return 		: Date - return the Date from TimeTravelSetting__c Custom Setting.
    * */
    @AuraEnabled(cacheable=true)
    public static Date today() {
        return TimeTravelSetting__c.getInstance().Today__c != null ? TimeTravelSetting__c.getInstance().Today__c : System.today();
    }
    /*
* @method 		: now
* @description  : This method returns the DateTime based on TimeTravelSetting__c Custom Setting.
* @author 		: Ashwin Kasture
* @return 		: DateTime - return the DateTime from TimeTravelSetting__c Custom Setting.
* */
    public static DateTime now() {
        return TimeTravelSetting__c.getInstance().Now__c != null ? TimeTravelSetting__c.getInstance().Now__c : System.now();
    }
    /*
* @method 		: monthToday
* @description  : This method returns the Month based on TimeTravelSetting__c Custom Setting.
* @author 		: Ashwin Kasture
* @return 		: Integer - return the month from TimeTravelSetting__c Custom Setting.
* */    
    public static Integer monthToday() {
        return TimeTravelSetting__c.getInstance().Today__c != null ? TimeTravelSetting__c.getInstance().Today__c.month() : System.today().month();
    }
    /*
* @method 		: monthNow
* @description  : This method returns the Month based on TimeTravelSetting__c Custom Setting.
* @author 		: Ashwin Kasture
* @return 		: Integer - returns the month from TimeTravelSetting__c Custom Setting.
* */
    public static Integer monthNow() {
        return TimeTravelSetting__c.getInstance().Now__c != null ? TimeTravelSetting__c.getInstance().Now__c.month() : System.now().month();
    }
    /*
* @method 		: nextMonthToday
* @description  : This method returns the next Month based on TimeTravelSetting__c Custom Setting.
* @author 		: Ashwin Kasture
* @return 		: Integer - returns the next month from TimeTravelSetting__c Custom Setting.
* */    
    public static Integer nextMonthToday() {
        Date newDate = TimeTravelSetting__c.getInstance().Today__c != null ? TimeTravelSetting__c.getInstance().Today__c.addMonths(1) : System.today().addMonths(1);
        return newDate.month();
    }
    /*    
* @method 		: nextMonthNow
* @description  : This method returns the Month based on TimeTravelSetting__c Custom Setting.
* @author 		: Ashwin Kasture
* @return 		: Integer - returns the month from TimeTravelSetting__c Custom Setting.
* */
    public static Integer nextMonthNow() {
        DateTime newDate = TimeTravelSetting__c.getInstance().Now__c != null ? TimeTravelSetting__c.getInstance().Now__c.addMonths(1) : System.now().addMonths(1);
        return newDate.month();
    }    
    /*    
    * @method 		: previousMonthToday
    * @description  : This method returns the previous Month based on TimeTravelSetting__c Custom Setting.
    * @author 		: Ashwin Kasture
    * @return 		: Integer - returns the previous month from TimeTravelSetting__c Custom Setting.
    * */    
    public static Integer previousMonthToday() {
        Date newDate = TimeTravelSetting__c.getInstance().Today__c != null ? TimeTravelSetting__c.getInstance().Today__c.addMonths(-1) : System.today().addMonths(-1);
        return newDate.month();
    }
    /*    
    * @method 		: previousMonthNow
    * @description  : This method returns the previous Month based on TimeTravelSetting__c Custom Setting.
    * @author 		: Ashwin Kasture
    * @return 		: Integer - returns the previous month from TimeTravelSetting__c Custom Setting.
    * */
    public static Integer previousMonthNow() {
        DateTime newDate = TimeTravelSetting__c.getInstance().Now__c != null ? TimeTravelSetting__c.getInstance().Now__c.addMonths(-1) : System.now().addMonths(-1);
        return newDate.month();
    }   
    /*    
* @method       : getCurrentUserMemberId
* @description  : This method returns the current user's member Id.
* @author       : Kireeti Gora
* @return       : Id - Current User Member Id.
* */
    public static Id getCurrentUserMemberId(Boolean isHeadOfHouseHold) {
        Id sspMemberId;
        List<SSP_Member__c> lstmember =new List<SSP_Member__c>();
        String contactId = getCurrentUserDetails()[0].ContactId;  //Iron Dome - isAccessible Fix
        Map<String,String> conditionMap = new Map<String, String>{'limit'=>'1','contact__c'=> contactId}; 
        try{
           
            if(contactId != null && contactId != '' ){   
                lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                               new Set<String>{'Id'}, 
                                                               conditionMap);
            }
            if(!lstmember.isEmpty()){ 
                sspMemberId =  lstmember[0].Id;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_utility', 'getCurrentUserMemberId', 'Failed to fetch Details in getCurrentUserMemberId Method', true);  
        }
        return sspMemberId;
    }  

    /*    
    * @method       : getCurrentUserDetails 
    * @description  : This method returns the current user's details (For Community Users).
    * @author       : Shrikant Raut
    * @return       : List<User>
    * */
    public static List<User> getCurrentUserDetails(){
        return SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                            new Set<String>{'Id', 'ImpersonatedIndividualId__c', 'Profile.Name', 'ContactId','Contact.IndividualId__c', 'Contact.DoesCaseExistForIndividual__c','Contact.IsDashboardRefreshNeeded__c','Contact.Name','contact.Visited_Document_Center__c','username','LanguageLocaleKey','contact.Salutation'}, 
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});        
    } 
    /*
     * Method Name          : isDataProcessed
     * Params               : sApplicationOrCaseNumber - Unique Interface Name
     *                        sHOHId - Request Parameters
     *                      : sScreenName - Screen Name to validate
     *                      : sMode - Mode of the application Intake or RAC
     * Return               : Status of the transaction record.
     * Description          : Method to validate Transaction record.
     */
    public static Map<String,String> isDataProcessed(String sHOHId, String sScreenName, String sMode) {
        String sViewName;
        Map<String,String> map_StatusView = new Map<String,String>{'status' => null};
        Set<String> setScreens;
        List<ReverseSSPViewMapping__mdt> lstMapping = new List<ReverseSSPViewMapping__mdt>();  //Iron Dome - isAccessible Fix
        if(Schema.sObjectType.ReverseSSPViewMapping__mdt.isAccessible()){  //Iron Dome - isAccessible Fix
            if(sMode == SSP_GlobalConstants.SSP_INTAKE_FLOW) {
                lstMapping = [SELECT id, View__c,Screens__c, is_Intake__c, is_RAC__c
                FROM ReverseSSPViewMapping__mdt 
                WHERE is_Intake__c = true
                ORDER BY Order__c];
            } else {
                lstMapping = [SELECT id, View__c,Screens__c, is_Intake__c, is_RAC__c
                FROM ReverseSSPViewMapping__mdt 
                WHERE is_RAC__c = true
                ORDER BY Order__c];
            }    
        } //Iron Dome - isAccessible Fix    
        // Iterate to get the veiw name
        for(ReverseSSPViewMapping__mdt objMap : lstMapping) {
            if(!String.IsEmpty(objMap.Screens__c)) {
                setScreens = new set<String>(objMap.Screens__c.split(SSP_InterfaceConstants.NEW_LINE));                
                if(setScreens.contains(sScreenName)) {
                    sViewName = objMap.View__c; 
                    break;
                }
            }
        }
        // Get the transaction record and send the status
        if(sViewName != null) {
            string uniqueId = sHOHId+';'+sViewName;
            //Added to fetch transaction records in Without sharing mode
            for(SSP_Transaction__c objTransaction : SSP_SharingBypassFetcher.fetchTransactionRecords(uniqueId)) {
                map_StatusView.put('status', objTransaction.Status__c);
                map_StatusView.put('message', objTransaction.Log_Message__c);
            }
        }
        //return null;
        return map_StatusView;
    }

    public static Map<String,String> getPickListValue (String objectName, String fieldName, String firstValue) {
        Map<String,String> options = new Map<String,String>();
        if (firstValue != null && firstValue != '') { 
            options.put(firstValue,firstValue); 
        }
        
        //Perf Fix: Lazy initialization of getDescribe call
        if(sObjectdescribeMap == null){
            initializeDescribe();
        }
        
        Map<String, Schema.SObjectType> schemaDescribe = sObjectdescribeMap;
        Schema.DescribeFieldResult fieldResult = schemaDescribe.get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListEntry: pickListEntries) 
        {
            options.put(pickListEntry.getLabel(),pickListEntry.getValue());
        }
        return options;
    }

    /*
    * @author       Keshav Poduval 
    * @date         04/14/2020 
    * @methodname   setProgramPermissions
    * @description  This methods is used to set programaccess for the logged in user.
    * @return       Set of available programs
    **/
    public static void setProgramPermissions(){
        //Added by Nupoor
        if(UserInfo.getSessionId() != null){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        for(String programCode : SSP_GlobalConstants.ALL_AVAILABLE_PROGRAMS){
            sessionPart.put(programCode,hasPermission(programCode));
            }
        }
    } 

    /*
    * @author       Shrikant Raut 
    * @date         04/08/2020 
    * @methodname   getAvailableProgramsByRole
    * @description  This methods is used to fetch set of available programs for loggedIn individual based on its role as defined in Program Security Matrix (Shrikant - added as a part of CD2 6.2)
    * @return       Set of available programs
    **/
    public static Set<String> getAvailableProgramsByRole(){        
        Set<String> availablePrograms = new Set<String>();
        if(UserInfo.getSessionId() != null){
            try{
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_InterfaceConstants.CACHE_PARTITION_NAME);  
        for(String programCode : SSP_InterfaceConstants.ALL_AVAILABLE_PROGRAMS){
            if(!sessionPart.contains(programCode)){
                sessionPart.put(programCode,hasPermission(programCode));                
            }
            if(Boolean.valueOf(sessionPart.get(programCode))){
                availablePrograms.add(programCode); 
            }
                }
            }
            catch(Exception e){}
        }
        return availablePrograms;
    }

    
    /*
    * @author       Shrikant Raut 
    * @date         04/16/2020 
    * @methodname   getUserDetails
    * @description  This methods is used to fetch user profile and role
    * @return       Map if required user details
    **/
    @auraEnabled
    public static Map<String, String> getUserDetails(String userId){
        Map<String, String> detailMap = new Map<String, String>();
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        userId = userId != null ? userId : UserInfo.getUserId(); 
        List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                            new Set<String>{'Id', 'ContactId', 'Profile.Name','ImpersonatedIndividualId__c','Contact.IndividualId__c','ShowCitizenDashboard__c','LanguageLocaleKey'}, 
                                                                            new Map<String, String>{'limit'=>'1','Id'=> userId});
        if(userList != null && !userList.isEmpty()){                                                       
            detailMap.put('profileName', userList[0].Profile.Name);
            detailMap.put('impersonatedIndividualId', userList[0].ImpersonatedIndividualId__c);
            detailMap.put('userRole', getSelectedRole() );
            detailMap.put('contactId', userList[0].ContactId);
            detailMap.put('selfIndividualId', userList[0].Contact.IndividualId__c);
            detailMap.put('showCitizenDashboard', String.valueOf(userList[0].ShowCitizenDashboard__c));
            detailMap.put('LanguageLocaleKey', userList[0].LanguageLocaleKey);
        }
        return detailMap;
    }
    
    /*
    * @author       Shrikant Raut 
    * @date         05/18/2020 
    * @methodname   getIndividualId
    * @description  This methods is used to fetch individualId for current context/Session from Cache
    * @return       String - individualId
    **/
    @AuraEnabled
    public static String getIndividualId(){
        //added by nupoor
        String individualId;
        if(UserInfo.getSessionId() != null){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        individualId = sessionPart != null ? ((sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID) != null && String.isNotBlank(String.valueOf(sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID)))) ? String.valueOf(sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID)) : String.valueOf(sessionPart.get(SSP_CacheBuilderImplementation.class, SSP_GlobalConstants.INDIVIDUAL_ID))) : null;            
        
        }
        return (individualId != null && !String.isBlank(individualId)) ? individualId : null;
    }

            /*
    * @author       Shrikant Raut 
    * @date         05/18/2020 
    * @methodname   getSelectedRole
    * @description  This methods is used to fetch individualId for current context/Session from Cache
    * @return       String - selectedRole
    **/
    @AuraEnabled
    public static String getSelectedRole(){
        String selectedRole ='';
        try{
            if(UserInfo.getSessionId() != null){
            	Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_InterfaceConstants.CACHE_PARTITION_NAME);  
                
                selectedRole = sessionPart != null ? ((sessionPart.get(SSP_InterfaceConstants.SELECTED_ROLE) != null && String.isNotBlank(String.valueOf(sessionPart.get(SSP_InterfaceConstants.SELECTED_ROLE)))) ? String.valueOf(sessionPart.get(SSP_InterfaceConstants.SELECTED_ROLE)) : String.valueOf(sessionPart.get(SSP_CacheBuilderImplementation.class, SSP_InterfaceConstants.SELECTED_ROLE))) : null;        
                
            }
        }
        catch(Exception e){}
        return (String.isNotBlank(selectedRole)) ? selectedRole : null;
    }
    
    /*
    * @author       Keshav Poduval 
    * @date         04/10/2020 
    * @methodname   hasPermission
    * @description  This method is used to check if the user has permission to a particular program
    * @param        customPermissionName - This stores custom permission in the name of program code. Send input as program name to check if has access to those programs.
    * @return       true or false
    **/
     @AuraEnabled
    public static boolean hasPermission(string customPermissionName){
        return FeatureManagement.checkPermission(customPermissionName);
    }

    /**
    * @author: Karthik Gulla
    * @method: getRACSelectedMembers
    * @desc This method is get the members selected on RAC selections screen
    * @param {String sApplicationId}
    * @return Set<Id>
    * */
    public static Set<String> getRACSelectedMembers(String sApplicationId){
        Set<String> setRACMembers = new Set<String>();
        try{
            Set<Id> setApplicationIds = new Set<Id>();
            setApplicationIds.add(sApplicationId);

            Map<String,String> mapConditions = new Map<String,String>();
            mapConditions.put('Id',String.join(new List<Id>(setApplicationIds), ','));
            List<SSP_Application__c> lstApplications = SSP_ApplicationSelector.queryApplicationData(new Map<String, 			String>{'objectName'=>'SSP_Application__c','IN'=>'Id'}, 
                                                                    new Set<String>{'Id','RAC_Selections__c'}, 
                                                                    mapConditions);
            if(lstApplications[0].RAC_Selections__c != null) {
                List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper> lstSelectedRACData = (List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper>) JSON.deserialize(lstApplications[0].RAC_Selections__c, List<SSP_ReportChangeSelectionCtrl.RACSelectionWrapper>.class);
                for(SSP_ReportChangeSelectionCtrl.RACSelectionWrapper racSelectWrapper : lstSelectedRACData){
                    if(racSelectWrapper.memberId != null){
                        setRACMembers.add(racSelectWrapper.memberId);
                    }
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'getRACSelectedMembers', e.getMessage(), true);
        }
        return setRACMembers;
    }

    /**
    * @author: Karthik Gulla
    * @method: filterApplicationIndividualsForRAC
    * @desc This method is filter the members selected on RAC selections screen to be shown on Selection screens
    * @param {List<SSP_ApplicationIndividual__c> lstAppIndividuals, String sApplicationId}
    * @return List<SSP_ApplicationIndividual__c>
    * */
    public static List<SSP_ApplicationIndividual__c> filterApplicationIndividualsForRAC(List<SSP_ApplicationIndividual__c> lstAppIndividuals, String sApplicationId){
        List<SSP_ApplicationIndividual__c> lstFilteredAppIndividuals = new List<SSP_ApplicationIndividual__c>();
        try{
            for(SSP_ApplicationIndividual__c sspAppIndividual : lstAppIndividuals){
                if(sspAppIndividual.SSP_Member__r.IndividualId__c != null 
                && SSP_Utility.getRACSelectedMembers(sApplicationId).contains(sspAppIndividual.SSP_Member__r.IndividualId__c)) {
                    lstFilteredAppIndividuals.add(sspAppIndividual);
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'filterApplicationIndividualsForRAC', e.getMessage(), true);
        }
        return lstFilteredAppIndividuals;
    }

    /*
    * @author       Shrikant Raut 
    * @date         04/22/2020 
    * @methodname   getScreenAccessDetails
    * @description  This methods is used to fetch screen and field level access details
    * @return       Wrapper of screen and field access details
    **/
    /*public static SecurityMatrixWrapper getScreenAccessDetails(String screenId, String selectedRole){
        SecurityMatrixWrapper accessDetails;
        //Added by Nupoor 
        if(UserInfo.getSessionId() != null){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        selectedRole = (selectedRole != null) ? selectedRole : getSelectedRole();
        if(screenId != null && selectedRole != null){
            accessDetails = new SecurityMatrixWrapper();
            for(ScreenPermissions__mdt screenPermissions :  (List<ScreenPermissions__mdt>)SSP_Utility.fetchRecords(
                new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_SCREEN_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},
                SSP_GlobalConstants.MDT_SCREEN_PERMISSIONS_FIELDS, 
                new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1','Role__c'=>selectedRole,'ScreenName__c'=>screenId})){
                    accessDetails.canDelete = screenPermissions.CanDelete__c;
                    accessDetails.screenPermission = screenPermissions.Permission__c;
            }

            Map<String, String> fieldPermissionsMap = new Map<String, String>();
            for(FieldPermissions__mdt fieldPermissions :  (List<FieldPermissions__mdt>)SSP_Utility.fetchRecords(
                new Map<String, String>{SSP_GlobalConstants.SSP_OBJECT_NAME => SSP_GlobalConstants.MDT_FIELD_PERMISSIONS, SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND},
                SSP_GlobalConstants.MDT_FIELD_PERMISSIONS_FIELDS, 
                new Map<String, String>{SSP_GlobalConstants.KEY_LIMIT=>'1000','Role__c'=>selectedRole,'ScreenName__c'=>screenId})){
                    fieldPermissionsMap.put(fieldPermissions.FieldElementName__c, fieldPermissions.Permission__c);
            }
            accessDetails.fieldPermissions = fieldPermissionsMap;
           
        }
        }
        return accessDetails;
    }*/

    //PERF Fix
    public static SecurityMatrixWrapper getScreenAccessDetails(String screenId, String selectedRole){
        Map<String, SecurityMatrixWrapper> accessDetailsMap = getScreenAccessDetails(new List<String>{screenId}, selectedRole);
        SecurityMatrixWrapper accessDetails = new SecurityMatrixWrapper();
        if(accessDetailsMap != null && !accessDetailsMap.isEmpty() && accessDetailsMap.containsKey(screenId)){
            accessDetails = accessDetailsMap.get(screenId);
        }
        return accessDetails;
    }

    //PERF Fix : Implemented Cache
    public static Map<String, SecurityMatrixWrapper> getScreenAccessDetails(List<String> screenIds, String selectedRole){
        Map<String, SecurityMatrixWrapper> accessDetailsMap = new Map<String, SecurityMatrixWrapper>();
        Map<String, SecurityMatrixWrapper> securityMatrixMap ;
        
        //Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        PermissionsOrgCache permissionObj =new PermissionsOrgCache();  
        selectedRole = (selectedRole != null) ? selectedRole : getSelectedRole();
        if(screenIds != null && !screenIds.isEmpty() && selectedRole != null){
            // accessDetailsMap = new Map<String, SecurityMatrixWrapper>();
            securityMatrixMap = (Map<String, SecurityMatrixWrapper>) permissionObj.getScreenPermissions(selectedRole);
            for(String screenId : screenIds){
                if(String.isNotBlank(screenId)){                                  
                    accessDetailsMap.put(screenId, (securityMatrixMap != null && !securityMatrixMap.isEmpty() && securityMatrixMap.containsKey(screenId)) ? securityMatrixMap.get(screenId) : new SecurityMatrixWrapper());                             
                }
            }
        }
        
        return accessDetailsMap;
    }

    /**
     * @author Ajay Saini
     * @description: Build a Screen vs. View map
     */
    public static Map<String, String> getScreenViewMapping() {
        Map<String, String> screenViewMap = new Map<String, String>();
        if(Schema.sObjectType.ReverseSSPViewMapping__mdt.isAccessible()){  //Iron Dome - isAccessible Fix
            ReverseSSPViewMapping__mdt[] metadataRecords = [SELECT View__c, Screens__c FROM ReverseSSPViewMapping__mdt];
            for(ReverseSSPViewMapping__mdt record: metadataRecords) {
                if(String.isBlank(record.Screens__c)) {
                    continue;
                }
                for(String screen: record.Screens__c.split(SSP_InterfaceConstants.NEW_LINE)) {
                    screenViewMap.put(screen.trim(), record.View__c.trim());
                }
            }
        }  //Iron Dome - isAccessible Fix
        return screenViewMap;
    }
    
    //Shikha - check accessible program
    public static Boolean checkApplicablePrograms (List<String> selectedProgram, Set<string> evaluatingSet){
        Boolean result = false;	
        if(!selectedProgram.isEmpty() && !evaluatingSet.isEmpty()){
            for(String prog : evaluatingSet){
                if(selectedProgram.contains(prog)){
                    result = true;
                    break;
                }
            }
        }
        return result;
    }

    //CD2 2.5 Security Role Matrix and Program Access. - Added by Shrikant
    public static String filterPrograms(String appPrograms, Set<String> applicableProgramSet){        
        String updatedAppPrograms = appPrograms;
        if(String.isNotBlank(appPrograms) && applicableProgramSet != null && !applicableProgramSet.isEmpty()){            
            updatedAppPrograms = '';
            List<String> applicationPrograms = appPrograms.split(';');
            for(String programCode : applicationPrograms){
                if(applicableProgramSet.contains(programCode)){
                    updatedAppPrograms += programCode + ';';
                }
                
            }
            updatedAppPrograms = updatedAppPrograms.removeEnd(';');
        }

        return updatedAppPrograms;
    }

    /*
    * method        : SecurityMatrixWrapper
    * @description  : Wrapper structure for Screen/Field access as per security matrix
    * @author       : Shrikant Raut
    * @param        : 
    * @return       : 
    * */
    public class SecurityMatrixWrapper {
        @AuraEnabled public String screenPermission {get;set;}
        @AuraEnabled public Boolean canDelete {get;set;}
        @AuraEnabled public Map<String, String> fieldPermissions {get;set;}
    }
    @AuraEnabled
    public static SSP_LightningResponse retryRSSPDCTransaction(Id applicationId, String mode) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        try {
            //Added by Nupoor
            if(UserInfo.getSessionId() != null){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            String individualId = (sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID) != null) ? String.valueOf(sessionPart.get(SSP_GlobalConstants.INDIVIDUAL_ID))
                :String.valueOf(sessionPart.get(SSP_CacheBuilderImplementation.class, SSP_GlobalConstants.INDIVIDUAL_ID));
            response.put('individualId', individualId);
            Set<String> setFields = new Set<String>{'DoesCaseExistForIndividual__c'};
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'Contact'};
            Map<String, String> conditionMap = new Map<String, String>{'IndividualId__c' => individualId};
            List<Contact> records = (List<Contact>)SSP_Utility.fetchRecords(detailMap, setFields, conditionMap);
            if(records.isEmpty()) {
                response.bIsSuccess = false;
                return response;
            }
            if(records[0].DoesCaseExistForIndividual__c == false) {
                response.bIsSuccess = true;
                return response;
            }
            List<SSP_Application__c> applicationRecords = SSP_ApplicationSelector.queryApplicationData(
                new Map<String, String>{'objectName' => 'SSP_Application__c','operator' => 'AND'}, 
                new Set<String>{'Id','DCCaseNumber__c','ProgramsApplied__c'}, 
                new Map<String, String>{'limit' => '1', 'Id' => applicationId}
            );
            if(applicationRecords.isEmpty()) {
                response.bIsSuccess = false;
                return response;
            }
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.mode = mode;
            if(mode != SSP_InterfaceConstants.MODE_INTAKE) {
                reqWrapper.caseNumber = Integer.valueOf(applicationRecords[0].DCCaseNumber__c); 
            }
            reqWrapper.viewName = SSP_InterfaceConstants.PENDING_VIEWS;
            //Commented for making multiple individual id changes - Nupoor
            //reqWrapper.primaryApplicationIndividualId = Integer.valueOf(individualId);
            if(mode != SSP_GlobalConstants.SSP_INTAKE_FLOW)
            {                           
                mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize( sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId')), Map<String, String>.class);
                reqWrapper.primaryApplicationIndividualId = mapCaseVsIndividualId.get(String.valueOf(applicationRecords[0].DCCaseNumber__c));
            }
            else{
            	reqWrapper.primaryApplicationIndividualId = individualId;
            }                
            reqWrapper.applicationId = applicationId;
            reqWrapper.programCode = applicationRecords[0].ProgramsApplied__c;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY, reqWrapper);
            Object callOutResponse = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            response.put('callOutResponse', callOutResponse);
            response.bIsSuccess = true;
            }
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'retryTransaction', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
    /*    
    * @method       : getCurrentUserAllIndividualIds 
    * @description  : This method returns the current user's Individua ids from contact mapping .
    * @author       : Kireeti Gora
    * @return       : String
    * */
     public static String getCurrentUserAllIndividualIds(){
        String individualId = ssp_utility.getIndividualId();         
        String contactId='';
        String strAllIndividualIds;
        List<String> lstCurrentUserIndividualIds =  new List<String>();
        List<contact> lstCurrentUserContactIds =  new List<contact>();
      	List<User> lstCurrentUser =  new List<User>();
        if(String.isNotBlank(individualId)){ //Iron Dome fix (7-22)
            lstCurrentUserContactIds =SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                           new Set<String>{'id','IndividualId__c','DoesCaseExistForIndividual__c','IsDashboardRefreshNeeded__c','Name'}, 
                                                                           new Map<String, String>{'IndividualId__c'=>individualId});
            /*lstCurrentUserContactIds = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                       new Set<String>{'Id', 'ContactId','Contact.IndividualId__c', 'Contact.DoesCaseExistForIndividual__c','Contact.IsDashboardRefreshNeeded__c','Contact.Name','contact.Visited_Document_Center__c','username'}, 
                                                       new Map<String, String>{'limit'=>'1','Contact.IndividualId__c'=> individualId}); */
        }
               
        if(!lstCurrentUserContactIds.isEmpty()){
            contactId = lstCurrentUserContactIds[0].Id;
        }
        else {
             lstCurrentUser = SSP_Utility.getCurrentUserDetails();   
            if(!lstCurrentUser.isEmpty()){
            contactId = lstCurrentUser[0].Contactid;
            }
         }
         
        if(String.isNotBlank(contactId)){ //Iron Dome fix (7-22)
            for(Contact_Mapping__c objContactMapping : SSP_ContactMappingSelector.queryContactMappingData(new Map<String, String>{'objectName'=>'contact_Mapping__c','operator'=>'AND'}, 
                                                                                new Set<String>{'Id', 'Contact__c','IEES_Id__c'}, 
                                                                                new Map<String, String>{'limit'=>'100','Contact__c'=> contactId})){
                if(objContactMapping.IEES_Id__c != null) {
                    lstCurrentUserIndividualIds.add(string.valueOf(objContactMapping.IEES_Id__c));
                }
            }
        }
        if(!lstCurrentUserIndividualIds.isEmpty()){
            strAllIndividualIds =   String.join(lstCurrentUserIndividualIds, ';');
            
        }
        
        
        return strAllIndividualIds;
    }

    /*    
    * @method       : getMemberId 
    * @description  : This method returns the memberId based on contact mapping individual Id .
    * @author       : Kireeti Gora
    * @return       : String
    * */
    public static String getMemberId(String IndividualId){               
        String contactId='';
        String strAllIndividualIds;
        String memberId;
        List<contact_Mapping__c> lstContact =  new List<contact_Mapping__c>();
        List<SSP_Member__c> lstMember =  new List<SSP_Member__c>();
        if(String.isNotBlank(individualId)){ //Iron Dome fix (7-22)
            lstContact = SSP_ContactMappingSelector.queryContactMappingData(new Map<String, String>{'objectName'=>'contact_Mapping__c','operator'=>'AND'}, 
                                                                            new Set<String>{'Id', 'Contact__c'}, 
                                                                            new Map<String, String>{'limit'=>'1','IEES_Id__c'=> IndividualId}); 
        }
        if(!lstContact.isEmpty()){
            contactId = lstContact[0].Contact__c; 
        }
        if(String.isNotBlank(contactId)){ //Iron Dome fix (7-22)
            lstMember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                           new Set<String>{'Id', 'Contact__c'}, 
                                                           new Map<String, String>{'limit'=>'1','Contact__c'=> contactId});   
        }    
        if(!lstMember.isEmpty()){
            memberId = lstMember[0].Id; 
        }
        
        return memberId;
    } 
    
    /*    
    * @method       : getMemberIds 
    * @description  : This method returns the memberIds based on contact mapping individual Ids .
    * @author       : Kireeti Gora
    * @return       :   Map<Decimal,String>
    * */
    public static Map<Decimal,String> getMemberIds(List<Integer> lstIndividualId){               
        String contactId='';
        String strAllIndividualIds;
        String memberId;
        List<contact_Mapping__c> lstContact =  new List<contact_Mapping__c>();
        
        List<SSP_Member__c> lstMember =  new List<SSP_Member__c>();
        Map<Decimal,String> mapIndividualIdVsMember = new Map<Decimal,String>();
        Map<String,Decimal> mapContactVsIndividualId = new Map<String,Decimal>();
        if(!lstIndividualId.isEmpty()){
            lstContact = SSP_ContactMappingSelector.queryContactMappingData(new Map<String, String>{'objectName'=>'contact_Mapping__c','operator'=>'AND','IN'=>'IEES_Id__c'}, 
                                                                            new Set<String>{'Id', 'Contact__c','IEES_Id__c'}, 
                                                                            new Map<String, String>{'limit'=>'100','IEES_Id__c'=> String.join(lstIndividualId ,',')}); 
        }
        for(contact_Mapping__c objConMapping:lstContact){
            mapContactVsIndividualId.put(objConMapping.Contact__c,objConMapping.IEES_Id__c);
            
        }
        if(!mapContactVsIndividualId.keySet().isEmpty()){
            lstMember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND','IN'=>'Contact__c'}, 
                                                           new Set<String>{'Id', 'Contact__c'}, 
                                                           new Map<String, String>{'limit'=>'100','Contact__c'=> String.join(new List<String>(mapContactVsIndividualId.keySet()),',')});   
        }    
        for(SSP_Member__c objMember:lstMember){
            mapIndividualIdVsMember.put(mapContactVsIndividualId.get(objMember.Contact__c),objMember.Id);
        }
        
        return mapIndividualIdVsMember;
    } 

  
    /**
    * @author: Karthik Gulla
    * @method: getPicklistConversionMappings
    * @desc This method is used to get custom metadata from Picklist Conversion Mappings
    * @param {String sKey, String sSourceValue}
    * @return Map<String,SSP_PicklistConversion_Configurations__mdt>
    * */
    public static Map<String,SSP_PicklistConversion_Configurations__mdt> getPicklistConversionMappings(String sKey, String sSourceValue, String sControllingFieldValue){
        Map<String,SSP_PicklistConversion_Configurations__mdt> mapPicklistConversionMappings = new Map<String,SSP_PicklistConversion_Configurations__mdt>();
        try{
            List<String> lstPicklistConvConfigFields = new List<String>{'MasterLabel','Source__c','ControllingFieldCode__c','IEESReferenceKey__c','SalesforcePicklistKey__c'};
            Boolean canViewPicklistConvConfigFields = ESAPI.accessController().isAuthorizedToView(SSP_PicklistConversion_Configurations__mdt.getSObjectType(), lstPicklistConvConfigFields);
            if(canViewPicklistConvConfigFields && Schema.sObjectType.SSP_PicklistConversion_Configurations__mdt.isAccessible()){ //Iron Dome - isAccessible Fix
                for(SSP_PicklistConversion_Configurations__mdt pMapping : [SELECT MasterLabel, Source__c, ControllingFieldCode__c, IEESReferenceKey__c, SalesforcePicklistKey__c FROM SSP_PicklistConversion_Configurations__mdt WHERE Source__c = :sSourceValue AND ControllingFieldCode__c = :sControllingFieldValue]){
                    mapPicklistConversionMappings.put(String.valueOf(pMapping.get(sKey)), pMapping);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'getPicklistConversionMappings', e.getMessage(), true);
        }
        return mapPicklistConversionMappings;
    }

     /**
    * @author: Karthik Gulla
    * @method: getSSPPortalConfigurations
    * @desc This method is used to get custom metadata from SSP Portal Configurations
    * @param {String sKey}
    * @return Map<String,mapPortalConfigurations>
    * */
    public static String getSSPPortalConfigurations(String sKey){
        Map<String,SSP_PortalConfigurations__mdt> mapPortalConfigurations = new Map<String,SSP_PortalConfigurations__mdt>();
        String strReturnValue = '';
        try{
            List<String> lstPortalConfigurationsFields = new List<String>{'MasterLabel','Value__c'};
            Boolean canViewPortalConfigurationsFields = ESAPI.accessController().isAuthorizedToView(SSP_PortalConfigurations__mdt.getSObjectType(), lstPortalConfigurationsFields);
            if(canViewPortalConfigurationsFields && Schema.sObjectType.SSP_PortalConfigurations__mdt.isAccessible()){ //Iron Dome - isAccessible Fix
                for(SSP_PortalConfigurations__mdt pMapping : [SELECT MasterLabel, Value__c FROM SSP_PortalConfigurations__mdt WHERE MasterLabel = :skey LIMIT 1]){
                    strReturnValue = pMapping.Value__c;
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'getSSPPortalConfigurations', e.getMessage(), true);
            return strReturnValue;
        }
        return strReturnValue;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicationDetails
    * @desc This method is used to get application Details
    * @param {Id applicationId}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse getApplicationDetails(Id applicationId){
    	SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
        Set<Id> setApplicationIds = new Set<Id>();
        setApplicationIds.add(applicationId);        
        try{            
            mapConditions.put('Id',String.join(new List<Id>(setApplicationIds), ','));
            lstApplications = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id','Name','DCCaseNumber__c','RecordType.DeveloperName','Status__c'}, 
                                                                mapConditions);
            clsLightningResponse.put('applicationDetails', JSON.serializePretty(lstApplications[0]));
            clsLightningResponse.bIsSuccess = true;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'getApplicationDetails', e.getMessage(), true);
        }
        return clsLightningResponse;
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/20/2020
* @methodname   getPicklistFromLabel
* @description  This methods is used get different picklist from custom labels and create slist
* @return        Map<String,String>
*****************************************************************************************************/
    public static Map<String,String> getPicklistFromLabel(String labelValue){
        list<String> listValues=labelValue.split(';');
        Map<String,String> options= new Map<String,String>();
        for(String st:listValues){
            options.put(st.split(':')[0],st.split(':')[1]);
        }
        return options;
    }
    
     /*
    * method        : downloadWrittenStatement
    * @description  : This method is use to download Written Statement from static resource.
    * @author       : Shikha Khanuja
    * @param        : 
    * @return       : SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse downloadWrittenStatement(String staticResourceName) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {                        
            PageReference pr = new PageReference('/resource/SSP_Assert/'+staticResourceName);
        	Blob content;
            if(!test.IsRunningTest()) 
        		content = pr.getContent(); 
        	else
                content = Blob.valueOf('');
            objResponse.put('resourceBody', EncodingUtil.base64Encode(content));
            
            objResponse.bIsSuccess = true;            
        } catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'downloadWrittenStatement', ex.getMessage() , true);  objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
        }                
        return objResponse;
    }
    
    /***************************************************************************************************
    * @author       Karthik Gulla
    * @date         07/01/2020
    * @methodname   getRequiredAddressFieldValue
    * @description  utility to fetch required address field value
    * @return       return google api value if Federal Service returns empty value.
    *****************************************************************************************************/
    public static String getRequiredAddressFieldValue(String sMemberValue, String sFederalValue) {
        String sReturnValue;
        try{            
            if(String.isNotBlank(sFederalValue)){
                sReturnValue = sFederalValue;
            } else {
                sReturnValue = sMemberValue;
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'getRequiredAddressFieldValue', e.getMessage(), true);
        }
        return sReturnValue;
    }
    /*
    * @method       : isAllowedToUpdate
    * @description  : This method Checks if the user is authorized to update
    * @author       : Ashwin Kasture
    * @param objType: SObjectType
    * @return       : Boolean true/false
    * */
    public static Boolean isAllowedToUpdate(Schema.SObjectType objType) { 
        Boolean bIsAllowedToUpdate = false;        
        if (objType.getDescribe().isUpdateable()) { 
            bIsAllowedToUpdate = true; 
        }          
        return bIsAllowedToUpdate; 
    }

    //#379955
    public static Boolean isReadOnlyUser(){
        List<String> readOnlyRoleList = (System.Label.SSP_ReadOnlyRoles).split(';');
        return readOnlyRoleList != null ? readOnlyRoleList.contains(getSelectedRole()) : false;
    }
    
    /*
    * @method       : monthsBetweenDates
    * @description  : This method returns the no of Months between two dates
    * @author       : Sai Kiran Velpula
    * @param objType: Dates
    * @return       : Integer
    * */
    public static Integer monthsBetweenDates(Date dateOfBirth) {
        Integer noOfMonths;
        try{
            noOfMonths = dateOfBirth.monthsBetween(today());
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_Utility', 'monthsBetweenDates', e.getMessage(), true);
        }
        return noOfMonths;
    } 

    /*
    * @method       : validateSSORedirect
    * @description  : Method to create SSO URL with Encrypted parameter
    * @author       : Rajeev Kumar
    * @param sOperationName : Operation Name of the feature
    * @return       : SSP_LightningResponse
    * */
	@AuraEnabled
    public static SSP_LightningResponse validateSSORedirect(String sOperationName) {
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
        List<SSO_Redirection__mdt> lstRedirection;
        RedirectionWrapper objWrapper = new RedirectionWrapper();

        try {
            if(!String.isBlank(sOperationName)) {
                lstRedirection = [SELECT Id, SSO_URL__c, Expiry_Time_In_Minutes__c, Activated__c FROM SSO_Redirection__mdt WHERE DeveloperName = :sOperationName];
            }
            if(lstRedirection != null && !lstRedirection.isEmpty() && !String.isBlank(lstRedirection[0].SSO_URL__c) && lstRedirection[0].Activated__c) {
                Integer intDurationseconds = 15*60;
                if(lstRedirection[0].Expiry_Time_In_Minutes__c != null) {
                    intDurationseconds = Integer.valueOf(lstRedirection[0].Expiry_Time_In_Minutes__c*60);
                }
                objWrapper.operationName = sOperationName;
                objWrapper.expiryTime = string.valueof(now().addSeconds(intDurationseconds).format('yyyy-MM-dd\'T\'HH:mm:ss'));
                if(sOperationName == 'PE_BCCTP' && Schema.SobjectType.User.isAccessible()) {
                    User objUser = [SELECT Id, ApplicableRoles__c from User WHERE Id=: userInfo.getUserId()];
                    if(!String.isBlank(objUser.ApplicableRoles__c)) {
                        objWrapper.role = getKOGRoleFromSF(objUser.ApplicableRoles__c.split(';')[0]);
                    }
                } else {
                    objWrapper.role = getKOGRoleFromSF(getSelectedRole());
                }
                objWrapper.hohId = getIndividualId();
                objWrapper.operationName = sOperationName;
                Blob data = Blob.valueOf(JSON.serialize(objWrapper)); 
                blob key = Blob.valueof(String.valueOf(EncryptionDecryptionSettings__c.getValues('SSPKey').get('key__c')));
                Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data ); 
                resultMap.put('endPoint', lstRedirection[0].SSO_URL__c);
                resultMap.put('encryptedToken', EncodingUtil.base64Encode(encryptedData));
                //resultMap.put('encryptedToken', EncodingUtil.urlEncode(EncodingUtil.base64Encode(encryptedData), 'UTF-8')); 
            }
            If(sOperationName=='TAX_FORMS') {
                resultMap.put('portal1095BToken', SSP_RequestTaxFormController.getPortal1095BToken());
            }
            resultMap.bIsSuccess = true;
            resultMap.put('status',true);  
        } catch(exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HearingController', 'getHearingSummary', ex.getMessage() , true);
            resultMap.bIsSuccess = false;
            resultMap.addException(ex, lstLogMessages[0].Id);
        }
        return resultMap;
    }

    /*
    * @method       : getKOGRoleFromSF
    * @description  : Method to get KOG Role from Salesforce
    * @author       : Rajeev Kumar
    * @param sUserRole : User Role from SF
    * @return       : KOG Role from Custom Metadata
    * */
    public static String getKOGRoleFromSF(String sUserRole) {
        if(!String.isBlank(sUserRole) && Schema.sObjectType.KOGRoleMapping__mdt.isAccessible()) {
            List<KOGRoleMapping__mdt> lstKOGRole = [SELECT Id, label, developerName,  Role_Name__c from KOGRoleMapping__mdt WHERE developerName = :sUserRole];
            if(lstKOGRole!= null && !lstKOGRole.isEmpty()) {
                return lstKOGRole.get(0).Role_Name__c.toUpperCase();
            }
        }
        return null;
    }

    /*
    * ClassName       	: RedirectionWrapper
    * @description  	: Wrapper for SSO Redirection
    * @author       	: Rajeev Kumar
    * */
    public class RedirectionWrapper {
        public String operationName;
        public String hohId;
        public String expiryTime;
        public String role;
    }

    /*
    * @method       : constructSecurityWrap
    * @description  : This method adds screenAccessDetails to SSP_LightningResponse
    * @author       : Shrikant Raut
    * @return       : SSP_LightningResponse
    * */
    public static SSP_LightningResponse constructSecurityWrap(SSP_LightningResponse response, Map<String, String> screenInfoMap){
        if(response != null && screenInfoMap != null && !screenInfoMap.isEmpty()){
            Map<String, SSP_Utility.SecurityMatrixWrapper> accessDetailMap = SSP_Utility.getScreenAccessDetails(screenInfoMap.values(), null);
            for(String responseKey : screenInfoMap.keySet()){
                String screenId = screenInfoMap.get(responseKey);
                response.put(responseKey, (accessDetailMap != null && !accessDetailMap.isEmpty() && accessDetailMap.containsKey(screenId)) ?  accessDetailMap.get(screenId) : new SSP_Utility.SecurityMatrixWrapper());    
            }
        }
        return response;
    }
}