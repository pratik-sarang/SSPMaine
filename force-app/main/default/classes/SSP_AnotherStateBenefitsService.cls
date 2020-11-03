/*
* classname 		: SSP_AnotherStateBenefitsService
* @description 		: This is the service class for Benefits from another state summary and details screen.
* @author 			: Sai Kiran
* @date 			: 11/27/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Nupoor Nimbalkar 		11/27/2019		Initial Version
*/
public class SSP_AnotherStateBenefitsService {
        /*
* method 		: fetchOutOfStateBenefits
* @description  : This method is used to fetch All the details of benefits of Member in the time frame.
* @author 		: Sai Kiran
* @param 		: sMemberId - Member ID in string format
* @return 		: List<SSP_Benefits__c>
* */
    @AuraEnabled
    public static List<SSP_Benefits__c> fetchBenefitRecords(String sBenefitIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        List<String> lstBenefitsFields = new List<String>{'State__c','State__c','BenefitInfoCounty__c','BenefitPrograms__c','BeginDate__c','EndDate__c','SSP_Member__c'};
            List<String> IDs = sBenefitIds.split(',');
        Set<ID> benefitIDs = new Set<ID>();
        try{
            for(String str : IDs){
                benefitIDs.add(String.escapeSingleQuotes(str).replace('"','').trim());
            }
            SSP_Utility.isAuthenticatedUser();
            Boolean bViewBenefitsFields = ESAPI.accessController().isAuthorizedToView(SSP_Benefits__c.getSObjectType(), lstBenefitsFields);
            if(bViewBenefitsFields){
                mapConditions.clear();
                mapConditions.put('ID',String.join(new List<Id>(benefitIDs), ','));
                lstBenefits = SSP_BenefitsSelector.queryBenefitsData(new Map<String, String>{'hasToLabel'=>'true','objectName'=>'SSP_Benefits__c','IN'=>'ID','operator'=>'AND'}, 
                                                        new Set<String>{'ID','BenefitPrograms__c','BeginDate__c','EndDate__c','SSP_Member__c'}, 
                                                        mapConditions);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_AnotherStateBenefitsService', 'validateBenefits', e.getMessage(), true);
        }
        return lstBenefits;
    }
    /*
* method 		: fetchOutOfStateBenefits
* @description  : This method is used to fetch All the details of benefits from state. 
* @author 		: Sai Kiran
* @param 		: sMemberId - Member ID in string format
* @return 		: List<SSP_Benefits__c>
* */
    @AuraEnabled
    public static List<SSP_Benefits__c> fetchOutOfStateBenefits(String sMemberId){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        List<String> lstBenefitsFields = new List<String>{'State__c','State__c','BenefitInfoCounty__c','BenefitPrograms__c','BeginDate__c','EndDate__c','SSP_Member__c'};
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Set<String> benefitProgramTypes = new Set<String>();
        benefitProgramTypes.add(SSP_GlobalConstants.SNAP);
        benefitProgramTypes.add(SSP_GlobalConstants.TANF);
        benefitProgramTypes.add(SSP_GlobalConstants.MEDICAID);
        String sQuery;
        String switchCaseKey;
        
        try{
            SSP_Utility.isAuthenticatedUser();
                Boolean bViewBenefitsFields = ESAPI.accessController().isAuthorizedToView(SSP_Benefits__c.getSObjectType(), lstBenefitsFields);
            if(bViewBenefitsFields){
                //Ashwin Changes
                Date dateBeforeMonth = SSP_Utility.today().addMonths(-SSP_GlobalConstants.SIX_MONTH);
                Date dateAfterMonth = SSP_Utility.today().addMonths(SSP_GlobalConstants.SIX_MONTH);
                //Sai Changes
                //Integer currentMonth = SSP_Utility.today().month();
                //Integer nextMonth = SSP_Utility.today().addMonths(SSP_GlobalConstants.ONE_MONTH).month();
                mapQueryParameters.put(SSP_GlobalConstants.sWhereClauseKey, SSP_GlobalConstants.sBenefitFieldsWhereClause);
                sQuery = SSP_Utility.getsQueryonFields('SSP_Benefits__c', SSP_GlobalConstants.sBenefitFields, mapQueryParameters);
                if(sQuery != NULL && !String.isBlank(sQuery)){
                    lstBenefits = Database.query(sQuery);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_AnotherStateBenefitsService', 'fetchOutOfStateBenefits', e.getMessage(), true);
        }
        return lstBenefits;
    }
    /*
* method 		: generateUniqueID
* @description  : This method is used to generate 10 digit Unique ID to Store in a Benefit Record.
* @author 		: Sai Kiran Velpula
* @return 		: String
* */
    public static String generateUniqueID(){
        String uniqueID;
        Integer len = 10;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        uniqueID = key.substring(0,len);
        return uniqueID;
    }
}