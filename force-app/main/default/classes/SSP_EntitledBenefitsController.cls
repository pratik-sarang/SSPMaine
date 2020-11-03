/*
* classname     :  SSP_EntitledBenefitsController
* @description  :  Controller class for sspEntitledBenefits
* @author       :  Shrikant Raut   
* @date         :  12/14/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_EntitledBenefitsController { 
@auraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchBenefitDetails(Id sspMemberId, Id sspApplicationId, String callingComponent ){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        Set<String> fieldSet = new Set<String>{'Id','BenefitTypeCode__c','StatusofApplication__c', 'BenefitApplicationDate__c', 'SSP_Member__c'};
        List<SSP_Benefits__c> listOfBenefits = new List<SSP_Benefits__c>();
        List<SSP_ApplicationIndividual__c> appIndividualList = new List<SSP_ApplicationIndividual__c>();
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> sspMemberId, 'RecordType.DeveloperName'=>'EntitledBenefit'};
            
            if(sspMemberId != null ){
                try{
                    listOfBenefits = SSP_BenefitsSelector.queryBenefitsData(new Map<String, String>{'objectName'=>'SSP_Benefits__c','operator'=>'AND'}, 
                                                                   fieldSet, 
                                                                   conditionMap);
                    if(sspApplicationId != null){
                        appIndividualList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(sspMemberId, sspApplicationId, new Set<String>{'MedicaidType__c'});
                    }
                     
                    response.put('applicationIndividual',appIndividualList);   
                    response.put('benefitsRecords',listOfBenefits);
                    response.put('entitledBenefitTypeId',SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Benefits__c', 'EntitledBenefit'));
                    response.bIsSuccess = true;
                }catch(Exception ex){
                    List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_EntitledBenefitsController', 'fetchExistingBenefitDetails', ex.getMessage() , true);
                    response.addException(ex, lstLogMessages[0].Id);
                }
            }
        
        return response;
    }

        
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         12/16/2019
    * @methodname   updateBenefits
    * @description  This methods is used to upsert/delete SSP_Benefits__c records
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse updateBenefits(Map<String, String> detailMap){        
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_Benefits__c> benefitsList = new List<SSP_Benefits__c>();
        try{
            if(detailMap != null && detailMap.containsKey('toUpsert')){
                String benefitsJSON = detailMap.get('toUpsert');
                benefitsList = (List<SSP_Benefits__c>)JSON.deserialize(benefitsJSON, List<SSP_Benefits__c>.class);
                ESAPI.accessController().upsertAsUser(benefitsList, SSP_Utility.getFieldsNamesList (benefitsList));
            }
            if(detailMap != null && detailMap.containsKey('toDelete')){
                String benefitsJSON = detailMap.get('toDelete');
                benefitsList = (List<SSP_Benefits__c>)JSON.deserialize(benefitsJSON, List<SSP_Benefits__c>.class);
                ESAPI.accessController().deleteAsUser(benefitsList);
            }
            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_EntitledBenefitsController', 'updateBenefits', ex.getMessage() , true);                    
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }
}