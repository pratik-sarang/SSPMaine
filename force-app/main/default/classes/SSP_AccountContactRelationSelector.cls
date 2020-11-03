/*
* classname     :  SSP_AccountContactRelationSelector
* @description  :  Selector class for AccountContactRelation
* @author       :  Shrikant Raut   
* @date         :  01/27/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_AccountContactRelationSelector {

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         01/27/2020
    * @methodname   queryACRData
    * @description  This methods is to query records related to AccountContactRelation object
    * @return       List<AccountContactRelation>
    *****************************************************************************************************/ 
    public static List<AccountContactRelation> queryACRData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList = (List<AccountContactRelation>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return acrList;
    }
    

}