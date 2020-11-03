
/*
* classname     :  SSP_BenefitsSelector
* @description  :  Selector class for SSP_Benefits__c
* @author       :  Shrikant Raut   
* @date         :  11/27/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_BenefitsSelector {
            /***************************************************************************************************
        * @author       Shrikant Raut
        * @date         11/27/2019
        * @methodname   queryBenefitsData
        * @description  This methods is to query records related to SSP_Benefits__c object
        * @return       List<SSP_Benefits__c>
        *****************************************************************************************************/ 
	    public static List<SSP_Benefits__c> queryBenefitsData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        lstBenefits = (List<SSP_Benefits__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstBenefits;
    }
} 