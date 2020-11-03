public class SSP_ApplicationIndividualSelector {
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/13/2019
    * @methodname   queryApplicationIndividualData
    * @description  This methods is used to query for SSP_ApplicationIndividual__c records
    * @return       Boolean
    *****************************************************************************************************/
    public static List<SSP_ApplicationIndividual__c> queryApplicationIndividualData(Map<String, String> detailMap, Set<String> fieldSet, Map<String, String> conditionsMap){
        List<SSP_ApplicationIndividual__c> appIndividualList = new List<SSP_ApplicationIndividual__c>();
        Boolean hasMemberStatus = false;
        /* for(String conditions : conditionsMap.values()) {
            if(!conditions.contains(SSP_GlobalConstants.MEMBER_REMOVE_STATUS) ||!conditions.contains(SSP_GlobalConstants.MEMBER_STATUS_New) ){
                 detailMap.put('operator', 'AND');
                detailMap.put('MemberStatus__c', '!=');
                conditionsMap.put('MemberStatus__c', SSP_GlobalConstants.MEMBER_REMOVE_STATUS);
            }
        }*/
        if(!detailMap.containsKey(SSP_GlobalConstants.SSP_OPERATOR)){
                detailMap.put(SSP_GlobalConstants.SSP_OPERATOR,'AND');
        } 
            
        if(null!=conditionsMap && conditionsMap.size()>0)
            //Below code modified for perf fix - Keshav
            if(conditionsMap.keySet().contains('MemberStatus__c')){
                hasMemberStatus=true;
            }
            /*for (String key : conditionsMap.keySet()) 
            {
                if(key.equalsIgnoreCase('MemberStatus__c'))
                {
                    hasMemberStatus=true;
                }
            }*/
            
        if(!hasMemberStatus){
                detailMap.put('MemberStatus__c', '!=');
                conditionsMap.put('MemberStatus__c', SSP_GlobalConstants.MEMBER_REMOVE_STATUS);
        } 


        appIndividualList = (List<SSP_ApplicationIndividual__c>)SSP_Utility.fetchRecords(detailMap, fieldSet, conditionsMap);
        return appIndividualList;
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/13/2019
    * @methodname   queryApplicationIndividualData
    * @description  This methods is used to query for SSP_ApplicationIndividual__c records
    * @return       Boolean
    *****************************************************************************************************/
    public static List<SSP_ApplicationIndividual__c> queryApplicationIndividualData(Id sspMemberId, Id sspApplicationId, Set<String> additionalFields){
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1'};
        Set<String> fieldSet = new Set<String>{'Id', 'IsTMember__c','SSP_Member__r.IndividualId__c','IsHeadOfHousehold__c', 'MedicaidType__c','ProgramsApplied__c','SSP_Member__r.Name','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','IsMemberStillOwnsIncomes__c','IsNoChangesToIncomes__c'};
        if(additionalFields != null && !additionalFields.isEmpty()){
            fieldSet.addAll(additionalFields);
        }
        
        if(sspMemberId != null){
            conditionMap.put('SSP_Member__c', sspMemberId);
        }
        if(sspApplicationId != null){
            conditionMap.put('SSP_Application__c', sspApplicationId);
            if(sspMemberId == null){
                conditionMap.put('limit','1000');
            }
        }
        conditionMap.put('MemberStatus__c', 'Removed');
        return queryApplicationIndividualData(
            new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c', 'operator' => 'AND', 'MemberStatus__c' => '!='},
            fieldSet, conditionMap);
    }
    
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/13/2019
    * @methodname   queryApplicationIndividualData
    * @description  This methods is used to query for SSP_ApplicationIndividual__c records
    * @return       Boolean
    *****************************************************************************************************/
    public static List<SSP_ApplicationIndividual__c> queryApplicationIndividualData(Id sspMemberId, Id sspApplicationId, Set<String> additionalFields, String memberStaus){
        Map<String, String> appIndDetailMap = new Map<String, String>();
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1'};
        Set<String> fieldSet = new Set<String>{'Id', 'IsHeadOfHousehold__c', 'MedicaidType__c','ProgramsApplied__c','SSP_Member__r.Name','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c'};
        if(additionalFields != null && !additionalFields.isEmpty()) {
            fieldSet.addAll(additionalFields);
        }
        
        if(sspMemberId != null) {
            conditionMap.put('SSP_Member__c', sspMemberId);
        }
        if(sspApplicationId != null) {
            conditionMap.put('SSP_Application__c', sspApplicationId);
            if(sspMemberId == null) {
                conditionMap.put('limit','1000');
            }
            // To add MemberStatus__c filter condition in query
            if(String.isNotBlank(memberStaus)) {
                appIndDetailMap.put('operator', 'AND');
            	conditionMap.put('MemberStatus__c', memberStaus);
            } else {
                appIndDetailMap.put('operator', 'AND');
                appIndDetailMap.put('MemberStatus__c', '!=');
                conditionMap.put('MemberStatus__c', SSP_GlobalConstants.MEMBER_REMOVE_STATUS);
            }
        }
        appIndDetailMap.put('objectName', 'SSP_ApplicationIndividual__c');
        return queryApplicationIndividualData (
            appIndDetailMap,
            fieldSet, 
            conditionMap
        );
    }
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-2-2019
    * @methodname   queryApplicationPrimaryIndividualData
    * @description  Method to query for SSP_ApplicationIndividual__c records for a primary applicant
    * @return       list of SSP_ApplicationIndividual__c records
    *****************************************************************************************************/
    public static List<SSP_ApplicationIndividual__c> queryApplicationPrimaryIndividualData(Id sspApplicationId, Set<String> additionalFields){
        Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_ApplicationIndividual__c', 'operator' => 'AND'};
        Set<String> fieldSet = new Set<String>{'Id', 'IsHeadOfHousehold__c', 'MedicaidType__c','ProgramsApplied__c','SSP_Member__r.Name','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','SSP_Member__c','SSP_Member__r.IndividualId__c','SSP_Member__r.PrimaryPhoneNumber__c','SSP_Member__r.Email__c','SSP_Member__r.MiddleInitial__c','SSP_Member__r.SuffixCode__c','SSP_Member__r.PhysicalCountyCode__c'};
       	if(additionalFields != null && !additionalFields.isEmpty()){
            fieldSet.addAll(additionalFields);
        }
        Map<String, String> conditionMap = new Map<String, String>{
            'limit' => '1',
            'IsHeadOfHousehold__c' => '#true#'
        };
        if(sspApplicationId != null) {
            conditionMap.put('SSP_Application__c', sspApplicationId);
        }
        return queryApplicationIndividualData(detailMap, fieldSet, conditionMap);
    }
    
    /***************************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         12/05/2019
    * @methodname   queryApplicationIndividualMemberData
    * @description  Method to query for SSP_ApplicationIndividual__c records for a primary applicant
    * @return       list of SSP_ApplicationIndividual__c records
    *****************************************************************************************************/
    public static List<SSP_ApplicationIndividual__c> queryApplicationIndividualMemberData(Id sspApplicationId, Set<String> additionalFields){
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'100'};
        Set<String> fieldSet = new Set<String>{'Id','IsTMember__c','IsHeadOfHousehold__c', 'ProgramsApplied__c','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c', 'SSP_Member__r.GenderCode__c'};
        
       	if(additionalFields != null && !additionalFields.isEmpty()){
            fieldSet.addAll(additionalFields);
        }
        if(sspApplicationId != null){
            conditionMap.put('SSP_Application__c', sspApplicationId);
        }
        conditionMap.put('limit','1000');
        return queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                fieldSet, 
                                        	                       conditionMap);                                                      
    }
      /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         01/21/2020
    * @methodname   queryApplicationIndividualCaseData
    * @description  This methods is used to query for SSP_ApplicationIndividual__c records 
    * @return       Boolean
    *****************************************************************************************************/
    public static List<SSP_ApplicationIndividual__c> queryApplicationIndividualCaseData(Set<String> fieldSet, Id sspMemberId,Boolean hasApplicationId,String sspApplicationId){
        List<SSP_ApplicationIndividual__c> appIndividualList = new List<SSP_ApplicationIndividual__c>();
        
            //if(ESAPI.accessController().isAuthorizedToView((Schema.getGlobalDescribe().get('SSP_ApplicationIndividual__c').newSObject()).getSObjectType(), SSP_Utility.getFieldsForAuthorisedView('SSP_ApplicationIndividual__c', fieldSet))){
            if(Schema.sObjectType.SSP_ApplicationIndividual__c.isAccessible()) {//Added for Perf fix - Keshav
                if(hasApplicationId){
                     appIndividualList = [SELECT Id, SSP_Application__c, ProgramsApplied__c, SSP_Application__r.Account__c,SSP_Application__r.Status__c,SSP_Application__r.ProgramsApplied__c,SSP_Application__r.DCCaseNumber__c,SSP_Application__r.Name,IsHeadOfHousehold__c,ssp_application__r.ApplicationCreationInSSP__c,SSP_Application__r.RecordType.DeveloperName,SSP_Member__r.IndividualId__c FROM SSP_ApplicationIndividual__c WHERE SSP_Member__c =:sspMemberId AND (ssp_application__r.Status__c = 'UN' OR ssp_application__r.DCCaseNumber__c != NULL) AND SSP_Application__c = :sspApplicationId];

                }else{
                    appIndividualList = [SELECT Id, SSP_Application__c, ProgramsApplied__c, SSP_Application__r.Account__c,SSP_Application__r.Status__c,SSP_Application__r.ProgramsApplied__c,SSP_Application__r.DCCaseNumber__c,SSP_Application__r.Name,IsHeadOfHousehold__c,ssp_application__r.ApplicationCreationInSSP__c,SSP_Application__r.RecordType.DeveloperName,SSP_Member__r.IndividualId__c FROM SSP_ApplicationIndividual__c WHERE SSP_Member__c =:sspMemberId AND (ssp_application__r.Status__c = 'UN' OR ssp_application__r.DCCaseNumber__c != NULL)];
 
                }
               
    }
        return appIndividualList;
    }
    
}