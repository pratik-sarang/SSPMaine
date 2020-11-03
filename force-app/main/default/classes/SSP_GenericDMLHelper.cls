public with sharing class SSP_GenericDMLHelper{
    public static list<sObject> updateRecords(List<sObject> lstSobjectToUpdate, List<String> listFields){
        return SSP_GenericDMLHelperUtility.updateRecords(lstSobjectToUpdate,listFields);
                    }
    public static list<sObject> insertRecords(List<sObject> lstSobjectToInsert, List<String> listFields){
        return SSP_GenericDMLHelperUtility.insertRecords(lstSobjectToInsert, listFields);
                }
    public static list<sObject> upsertRecords(List<sObject> lstSobjectToUpsert, List<String> listFields){
        return SSP_GenericDMLHelperUtility.upsertRecords(lstSobjectToUpsert, listFields);
        }
    public static list<sObject> upsertRecords(List<sObject> lstSobjectToUpsert, List<String> listFields, String externalIdField){
        return SSP_GenericDMLHelperUtility.upsertRecords(lstSobjectToUpsert, listFields, externalIdField);
    }
}