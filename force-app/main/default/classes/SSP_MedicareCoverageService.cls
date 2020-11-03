/*
* classname     :  SSP_MedicareCoverageService
* @description  :  Service class for Medicare Coverage Summary and Details
* @author       :  Varun Kochar   
* @date         :  04/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_MedicareCoverageService {
    
    /**
* @author: Varun Kochar
* @method: getBenefit
* @desc This method is used to get details for a SSP Benefit
* @return List<SSP_Benefits__c>
* */
    public static List<SSP_Benefits__c> getBenefit(Set<String> memberId){
        try{
            Map<String, String> benefitDetailMap = new Map<String, String> {'objectName' => 'SSP_Benefits__c', 'operator'=>'AND', 'isDeleted__c'=>'!='  };        
                Set<String> setBenefitFields = new Set<String>{'Id','Name','BeginDate__c','EndDate__c','MedicareNumber__c','DCId__c','SSP_Member__c','SSP_Member__r.Name','SSP_Member__r.TBQIndividualVerificationCode__c','HasMedicareCoverageButNoInfo__c','MedicareTypeCode__c','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','isDeleted__c'};
                    Map<String, String> benefitConditionMap = new Map<String, String> {'SSP_Member__c' =>  String.join(new List<String>(memberId), ','), 'Recordtype.DeveloperName' =>'MedicareBenefit' , 'isDeleted__c'=>'true'};
                        return SSP_BenefitsSelector.queryBenefitsData ( benefitDetailMap, setBenefitFields, benefitConditionMap);
            
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MedicareCoverageService', 'getBenefit', e.getMessage(), true);
        }
        return null;
    }
    /**
* @author: Varun Kochar
* @method: getMember
* @desc This method is used to get details for a SSP Member
* @return List<SSP_Member__c>
* */
    public static List<SSP_Member__c> getMember(Set<String> memberId){
        try{
            Map<String, String> memberDetailMap = new Map<String, String> {'objectName' => 'SSP_Member__c'};        
                Set<String> setMemberFields = new Set<String>{'Id', 'FirstName__c','LastName__c' ,'IsReceivingMedicareBenefitToggle__c'};
                    Map<String, String> memberConditionMap = new Map<String, String> {'Id' =>  String.join(new List<String>(memberId), ',')};
                        return SSP_MemberSelector.queryMemberData ( memberDetailMap, setMemberFields, memberConditionMap);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MedicareCoverageService', 'getMember', e.getMessage(), true);
        }
        return null;
    }
    /**
* @author: Varun Kochar
* @method: getMedicareTypeMap
* @desc This method is used to get medicareTypeMap
* @return Map<String, String>
* */
    public static Map<String, String> getMedicareTypeMap(){
        Map<String, String> medicareTypeMap = new Map<String, String>();
        for(Schema.PicklistEntry pickList : SSP_Benefits__c.MedicareTypeCode__c.getDescribe().getPicklistValues()){
            String picklistInTitleCase = '';
            for ( String word : pickList.getLabel().split ( ' ' )) {
                picklistInTitleCase += word.subString ( 0 , 1 ).toUpperCase() + word.SubString ( 1, word.length () ).toLowerCase() + ' ' ;
            }
            medicareTypeMap.put(pickList.getValue(),picklistInTitleCase.trim());
        }
        return medicareTypeMap;                          
    }
}