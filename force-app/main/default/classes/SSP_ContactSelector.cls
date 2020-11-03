/*
* classname     :  SSP_ContactSelector
* @description  :  Selector class for contact
* @author       :  Kireeti Gora  
* @date         :  01/13/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_ContactSelector {
      /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         01/13/2019
    * @methodname   queryContactData
    * @description  This methods is to query records related to contact object
    * @return       List<contact>
    *****************************************************************************************************/ 
      public static List<contact> queryContactData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<contact> lstContact = new List<contact>();
        lstContact = (List<contact>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstContact;
    }
}