/*
* classname     : SSP_InsurancePolicySelector
* @description  : This class is use to get the Insurance Policy Details
* @author       : Ashwin Kasture
* @date         : 10/12/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_InsurancePolicySelector {
	/***************************************************************************************************
    * @author       Ashwin Kasture
    * @date         10/12/2019
    * @methodname   queryInsurancePolicyData
    * @description  This methods is used to query for SSP_InsurancePolicy__c records
    * @return       List<SSP_InsurancePolicy__c>
    *****************************************************************************************************/
    public static List<SSP_InsurancePolicy__c> queryInsurancePolicyData(Map<String, String> detailMap, Set<String> fieldSet, Map<String, String> conditionsMap) {
        List<SSP_InsurancePolicy__c> lstInsurancePolicy = new List<SSP_InsurancePolicy__c>();
        lstInsurancePolicy = (List<SSP_InsurancePolicy__c>)SSP_Utility.fetchRecords(detailMap, fieldSet, conditionsMap);
        return lstInsurancePolicy;
    }
}