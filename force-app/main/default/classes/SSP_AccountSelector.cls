/*
* classname     :  SSP_AccountSelector
* @description  :  Selector class for Account
* @author       :  Kireeti Gora  
* @date         :  01/16/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_AccountSelector {
     /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         01/16/2020
    * @methodname   queryAccountData
    * @description  This methods is to query records related to Account object
    * @return       List<Account>
    *****************************************************************************************************/ 
    public static List<Account> queryAccountData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        
        List<Account> lstAccount = new List<Account>();
        lstAccount = (List<Account>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstAccount;
    }
     
    
}