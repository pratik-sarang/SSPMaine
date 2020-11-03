
/*
* classname     :  SSP_AssetSelector
* @description  :  Selector class for SSP_Asset__c
* @author       :  Shrikant Raut   
* @date         :  11/14/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public class SSP_AssetSelector {

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/14/2019
    * @methodname   queryAssetData
    * @description  This methods is to query records related to SSP_Asset__c object
    * @return       List<SSP_Asset__c>
    *****************************************************************************************************/ 
    public static List<SSP_Asset__c> queryAssetData(Map<String, String> mapDetails, Set<String> setFields, Map<String, String> mapConditions){
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        lstAssets = (List<SSP_Asset__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
        return lstAssets;
    }
    
    public static List<SSP_Asset__c> getDuplicateEmployerIncomeDetails(SSP_Asset__c objAsset){
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        lstAssets = [SELECT Id, SSP_Member__c, EmployerName__c, EIN__c, EmployerAddress__c, EmployerAddressLine2__c,
                     BusinessTitle__c, ActivityType__c, IncomeTypeCode__c,
                     IncomeSubtypeCode__c, TotalGrossAmount__c, Tips__c, IncomePayDetailHoursPerWeek__c,
                     ExpenseAmount__c, ActivityStartDate__c, StartDate__c, EndDate__c, SSP_Member__r.PrimaryPhoneNumber__c,
                     SSP_Member__r.PrimaryPhoneExtension__c,BusinessTypeCode__c,toLabel(IncomePayFrequency__c) FROM SSP_Asset__c WHERE SSP_Member__c =:objAsset.SSP_Member__c AND EmployerName__c =:objAsset.EmployerName__c
                     AND TotalGrossAmount__c =:objAsset.TotalGrossAmount__c AND IncomePayFrequency__c = :objAsset.IncomePayFrequency__c];
        
        return lstAssets;
    }
    public static String getExpenseDetailsWithId(String sId){
        String sObjExpense = '';
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        lstAssets = [SELECT Id, SSP_Member__c, ExpenseSubType__c,StartDate__c,EndDate__c,TuitionAmount__c,BooksAmount__c,FeesAmount__c,MiscellaneousAmount__c,
                     ExpenseFrequencyCode__c,ExpensesAmount__c,ChildName__c,DependentCareProvider__c,DependentCareProvider__r.name,DependentIndividual__c 
                     FROM SSP_Asset__c WHERE 
                     Id =:sId];
        if(!lstAssets.isEmpty()){
            sObjExpense = JSON.serialize(lstAssets[0]);
        }
        
        return sObjExpense;
    }
     public static String fetchExistingIncomeDetails(String sMemberId){
        String sObjExpense = '';
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        lstAssets = [SELECT Id, SSP_Member__c, ExpenseSubType__c,StartDate__c,EndDate__c,TuitionAmount__c,BooksAmount__c,FeesAmount__c,MiscellaneousAmount__c,
                     ExpenseFrequencyCode__c,ExpensesAmount__c,ChildName__c,DependentCareProvider__c,DependentCareProvider__r.name,DependentIndividual__c,EmploymentEndReason__c 
                     FROM SSP_Asset__c WHERE 
                     SSP_Member__c =:sMemberId  AND EmploymentEndReason__c = null and EndDate__c= null];
        if(!lstAssets.isEmpty()){
            sObjExpense = JSON.serialize(lstAssets);
        }
        
        return sObjExpense;
    }
}