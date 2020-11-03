/*
* classname     :  SSP_KHIPPPreferredPaymentMethodService
* @description  :  Service class for SSP_KHIPPPreferredPaymentMethod
* @author       :  Varun Kochar   
* @date         :  23/01/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_KHIPPPreferredPaymentMethodService {

    /**
    * @author: Varun Kochar
    * @method: getApplicationIndividual
    * @desc This method is used to get details for Application Individual
    * @return  List<SSP_ApplicationIndividual__c>
    * */
    public static List<SSP_ApplicationIndividual__c> getApplicationIndividual(Set<String> applicationId){
        try{
            Map<String, String> applicationIndividualConditionMap = new Map<String, String> {'SSP_Application__c' => String.join(new List<String>(applicationId), ',')};
            Map<String, String> applicationIndividualDetailMap = new Map<String, String> {'objectName' => 'SSP_ApplicationIndividual__c', 'IN'=>'SSP_Application__c'};        
          	Set<String> setapplicationIndividualFields = new Set<String>{'SSP_Member__c','SSP_Member__r.Name','SSP_Member__r.FirstName__c','SSP_Member__r.MiddleInitial__c','SSP_Member__r.SuffixCode__c','SSP_Member__r.LastName__c','SSP_Member__r.PreferredIssuanceMethod__c','SSP_Member__r.RoutingNumber__c',' SSP_Member__r.CheckingAccountNumber__c','SSP_Member__r.MailingAddressLine1__c','SSP_Member__r.MailingAddressLine2__c', 'SSP_Member__r.MailingCity__c', 'toLabel(SSP_Member__r.MailingCountyCode__c)', 'toLabel(SSP_Member__r.MailingStateCode__c)', 'SSP_Member__r.MailingCountryCode__c', 'SSP_Member__r.MailingZipCode5__c'};
            return SSP_ApplicationIndividualSelector.queryApplicationIndividualData ( applicationIndividualDetailMap, setapplicationIndividualFields, applicationIndividualConditionMap);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethodService', 'getCoveredIndividual', e.getMessage(), true);
        }
        return null;
    }
    /**
    * @author: Varun Kochar
    * @method: getCoveredIndividual
    * @desc This method is used to get details for a particular covered Individual
    * @return List<SSP_InsuranceCoveredIndiv__c>
    * */
    public static List<SSP_InsuranceCoveredIndiv__c> getCoveredIndividual(Set<String> memberId){
        try{
             Map<String, String> insuranceCovIndConditionMap = new Map<String, String> {'SSP_Member__c' => String.join(new List<String>(memberId), ','), 'IsPolicyHolder__c' => 'true','IsEnrolled__c' => 'true'};
            Map<String, String> insuranceCovIndDetailMap = new Map<String, String> {'objectName' => 'SSP_InsuranceCoveredIndiv__c', 'IN'=>'SSP_Member__c', 'operator'=>'AND'};        
                Set<String> setInsuranceCovIndFields = new Set<String>{'Id', 'Name', 'SSP_Member__c'};
                        return SSP_SharingBypassFetcher.fetchRecords(insuranceCovIndDetailMap, setInsuranceCovIndFields, insuranceCovIndConditionMap); // CD1 Security Fixes
                                
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethodService', 'getCoveredIndividual', e.getMessage(), true);
        }
        return null;
    }
    /**
    * @author: Varun Kochar
    * @method: getBankDetails
    * @desc This method is used to get bank details
    * @return List<SSP_Institution__c>
    * */
    public static List<SSP_Institution__c> getBankDetails(Set<String> routingNumber){
        try{
             Map<String, String> institutionConditionMap = new Map<String, String> {'RoutingNumber__c' => String.join(new List<String>(routingNumber), ',')};
            Map<String, String> institutionDetailMap = new Map<String, String> {'objectName' => 'SSP_Institution__c', 'IN'=>'RoutingNumber__c'};        
                Set<String> setinstitutionFields = new Set<String>{'Id','Name__c','AddressLine1__c','AddressLine2__c','City__c','Country__c','County__c','RoutingNumber__c','StateCode__c','ZipCode__c'};
                        return SSP_InstitutionSelector.queryInstitutionData ( institutionDetailMap, setinstitutionFields, institutionConditionMap);
                                
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethodService', 'getBankDetails', e.getMessage(), true);
        }
        return null;
    }
}