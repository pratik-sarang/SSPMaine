/*
* classname 	: SSP_HealthSelectionCtrl
* @description 	: This class is use to select the member information
* @author 		: Ajay Saini
* @date 		: DEC-1-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ajay Saini 		DEC-1-2019		Initial Version
*/
public class SSP_ApplicationSelector {
    private static final String objectName = 'SSP_Application__c';
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-1-2019
    * @methodname   queryApplicationData
    * @description  This methods is used to query for SSP_Application__c records
    * @return       List of application records
    *****************************************************************************************************/
    public static List<SSP_Application__c> queryApplicationData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_Application__c> records = new List<SSP_Application__c>();
        //if(ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), SSP_Utility.getFieldsForAuthorisedView(objectName, setFields))){ //Perf fix - Keshav
            records = (List<SSP_Application__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        //}
        return records;
    }
    
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-1-2019
    * @methodname   queryApplicationDataById
    * @description  This methods is used to query for SSP_Application__c records by application id
    * @return       Application record
    *****************************************************************************************************/
    public static SSP_Application__c queryApplicationDataById(Id applicationId, List<String> listFields) {
        Map<String, String> mapDetails = new Map<String, String>{'objectName' => objectName};
        Set<String> setFields = new Set<String>(listFields);
        Map<String, String> mapConditions = new Map<String, String>{'Id' => applicationId};
        List<SSP_Application__c> records = queryApplicationData(mapDetails, setFields, mapConditions);
        if(!records.isEmpty()) {
            return records[0];
        }
        return null;
    }
     /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         02/02/2020
    * @methodname   queryApplicationProgramData
    * @description  This methods is used to query for SSP_Application__c records with combination of and,or
    * @return       Application record
    *****************************************************************************************************/
     public static List<SSP_Application__c> queryApplicationProgramData(Set<String> fieldSet, Set<Id> lstAppId,Boolean hasLabel){
        List<SSP_Application__c> applicationList = new List<SSP_Application__c>();
        
            //if(ESAPI.accessController().isAuthorizedToView((Schema.getGlobalDescribe().get('SSP_Application__c').newSObject()).getSObjectType(), SSP_Utility.getFieldsForAuthorisedView('SSP_Application__c', fieldSet))){
            if(Schema.sObjectType.SSP_Application__c.isAccessible()) {  //Added for Perf fix - Keshav    
                if(hasLabel){
                     applicationList = [SELECT Id, (SELECT ProgramsApplied__c FROM SSP_ApplicationIndividuals__r), ProgramsApplied__c,Account__c,Status__c,DCCaseNumber__c,Name FROM SSP_Application__c WHERE Id IN :lstAppId AND (Status__c = 'UN' OR DCCaseNumber__c != NULL)];

                }else{
                    applicationList = [SELECT Id, (SELECT ProgramsApplied__c FROM SSP_ApplicationIndividuals__r), ProgramsApplied__c,Account__c,Status__c,DCCaseNumber__c,Name FROM SSP_Application__c WHERE Id IN :lstAppId AND (Status__c = 'UN' OR DCCaseNumber__c != NULL)];
 
                }
               
    }
        return applicationList;
    }
}