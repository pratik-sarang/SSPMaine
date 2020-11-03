/**************************************************************************************
* Apex Class Name:  SSP_CustomMetadataAccessor
* Version     : 1.0 
* Created Date    : 18 Nov 2019
* Function    : This class is to accessor to all custom metadata classes. 
*
* Modification Log :
* Developer         Date            ModificationId          Description
* ----------------------------------------------------------------------------                 
* Abdulrehman       18 Nov 2019         1.0             Created the class with basic methods
*************************************************************************************/
public class SSP_CustomMetadataAccessor {

   //get all fields for given custom metadte
   public List<String> getFieldNameList(String mdtAPIName){
        Schema.SObjectType describeResult;
        if (mdtAPIName!=null){
            describeResult = Schema.getGlobalDescribe().get(mdtAPIName);
        }
        if(describeResult == null){
            throw new CustomException(CustomException.EXCEPTION_TYP.SYS, SSP_InterfaceConstants.SSP_METADATA_NOT_PRESENT_IN_SYS);//Irondome Report : Moved string value to SSP Interface COnstants
        }  
        return new List<String>(describeResult.getDescribe().fields.getMap().Keyset());
    }

    //get all records
    public List <sobject> getAllRecords(String mdtAPIName){
        //build dynamic query
        String query = createQueryString(getFieldNameList(mdtAPIName), mdtAPIName, null);

        //to-do: use ESAPI to check the list
        //to-do: Error handling
        return Database.query(query);

    }

    //get all records using order by field
    public List <sobject> getAllRecordsOrderBy(String mdtAPIName, String orderByField){
        //build dynamic query
        String query = createQueryString(getFieldNameList(mdtAPIName), mdtAPIName, orderByField);

        //to-do: use ESAPI to check the list
        //to-do: Error handling
        return Database.query(query);

    }

    //get all records in a map
    public Map<String, sObject> getAllRecordsMap(String mdtAPIName){
        List<sObject> mdtList = getAllRecords(mdtAPIName);
        //create map of name and corresponding object
        Map<String, sobject> mdtMap = new Map<String, sObject>();
        for(sObject mdtObj : mdtList){
            //mdtMap.put((String)mdtObj.get('Name'), mdtObj);
            mdtMap.put((String)mdtObj.get('DeveloperName'), mdtObj);
        }
        return mdtMap;
    }
    //create Query method -To-do: move to utility
    public String createQueryString(List<String> fieldList, String objectName, String orderByField){
        String query = 'SELECT {0} FROM {1}';
        if(orderByField != null)
            query += ' ORDER BY {2} NULLS LAST';
        String fieldNames = String.join(fieldList,',');

        /*String fieldNames = '';
        for (String fieldname: fieldList){
            fieldNames =  fieldNames + fieldName + ',';
        }
        
        fieldNames = fieldNames.removeEnd(',');*/
        //to-do: hard coding
        return String.format(query,new List<String>{fieldNames, objectName, orderByField});
    }
}