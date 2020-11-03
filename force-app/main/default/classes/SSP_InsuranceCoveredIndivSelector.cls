/*
* classname     : SSP_InsuranceCoveredIndivSelector
* @description  : This class is use to get the Insurance Covered Individual Details
* @author       : Ashwin Kasture
* @date         : 07/12/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public with sharing class SSP_InsuranceCoveredIndivSelector {
	/***************************************************************************************************
    * @author       Ashwin Kasture
    * @date         07/12/2019
    * @methodname   queryInsuranceCoveredIndivData
    * @description  This methods is used to query for SSP_InsuranceCoveredIndiv__c records
    * @return       List<SSP_InsuranceCoveredIndiv__c>
    *****************************************************************************************************/
    public static List<SSP_InsuranceCoveredIndiv__c> queryInsuranceCoveredIndivData(Map<String, String> detailMap, Set<String> fieldSet, Map<String, String> conditionsMap) {
        List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCoveredIndiv = new List<SSP_InsuranceCoveredIndiv__c>();
        lstInsuranceCoveredIndiv = (List<SSP_InsuranceCoveredIndiv__c>)SSP_Utility.fetchRecords(detailMap, fieldSet, conditionsMap);
        return lstInsuranceCoveredIndiv;
    }
}