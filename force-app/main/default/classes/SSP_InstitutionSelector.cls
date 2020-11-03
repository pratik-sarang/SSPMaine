/*
* classname     :  SSP_InstitutionSelector
* @description  :  Selector class for Institution
* @author       :  Samridh Manucha  
* @date         :  02/08/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_InstitutionSelector {
     /***************************************************************************************************
    * @author       Samridh Manucha
    * @date         02/08/2020
    * @methodname   queryInstitutionData
    * @description  This methods is to query records related to SSP_Institution object
    * @return       List<SSP_Institution__c>
    *****************************************************************************************************/ 
    public static List<SSP_Institution__c> queryInstitutionData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        
        List<SSP_Institution__c> lstInstitution = new List<SSP_Institution__c>();
        lstInstitution = (List<SSP_Institution__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstInstitution;
    }
     
    
}