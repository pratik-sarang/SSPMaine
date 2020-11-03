public class GenericValidationController {
    
    @AuraEnabled
    public static EntityMappingWrapper getMetadataList(List<String> FieldEntityConcatList, String screenName){
        String sessionId = UserInfo.getSessionId();
        Map<String, VisibilityMatrix> renderingMap = new Map<String, VisibilityMatrix>(); //Added by Shrikant
        EntityMappingWrapper entityMappingObj = new EntityMappingWrapper();
        String sMatrixScreenName = screenName; //Added by Shrikant
        Map<String, EntityMapping__mdt> mapOfEntityMapping = new Map<String, EntityMapping__mdt>();
		Set<String> EntityNameSet = new Set<String>();
        Set<String> fieldNameSet = new Set<String>();        
        Map<String, String> picklistLabelValue = new Map<String, String>();
        for(String str : FieldEntityConcatList){
            String objName = String.escapeSingleQuotes(str.split(',')[1]); //Added by Shrikant
            String fieldName = str.split(',')[0]; //Added by Shrikant
            if(!objName.equalsIgnoreCase('ScreenName')){ //Added by Shrikant
                EntityNameSet.add(objName);
                fieldNameSet.add(fieldName);
            }
            else{
                sMatrixScreenName = fieldName;
            } //Added by Shrikant
        }
        
    	List<EntityMapping__mdt> metaList = [SELECT Id, Programs__c, Label, SF_ObjectAPI__c, SF_FieldAPI__c, ScreenName__c,PassportNumberValidator__c,toLabel(PassportNumberValidator_Msg__c),
                                             emailValidator__c, toLabel(emailValidator_Msg__c),IllegalCharactersValidator__c,IllegalCharactersValidator_AllowNumber__c,toLabel(IllegalCharValidator_AllowNumber_Msg__c),
                                             toLabel(IllegalCharactersValidator_Msg__c), Input_Numeric__c, toLabel(Input_Numeric_Msg__c), Input_Required__c, toLabel(Input_Required_Msg__c),
                                             Is_Date_Future__c, toLabel(Is_Date_Future_Msg__c), Is_Date_Past__c, toLabel(Past_Date_Validation_Msg__c), Specify_Pattern__c, toLabel(Specify_Pattern_Msg__c),
                                             SSNValidator__c, toLabel(SSNValidator_Msg__c), Validate_AreaCode__c, toLabel(Validate_AreaCode_Msg__c), Validate_Phone_Pattern__c,
                                             toLabel(Validate_Phone_Pattern_Msg__c),Allow_Only_1_Selection__c,toLabel(Allow_Only_1_Selection_Msg__c),Validate_Maxlength__c, toLabel(Validate_Maxlength_Msg__c),
                                             Validate_Minlength__c,toLabel(Validate_Minlength_Msg__c), LessThanEqualToValidator__c, NonZeroValidator__c, toLabel(NonZeroValidator_Msg__c), toLabel(LessThanEqualToValidator_Msg__c),
                                             toLabel(Allow_Numeric_Msg__c),Allow_Numeric__c,Validate_AlphaNumeric__c,toLabel(Validate_AlphaNumeric_Msg__c), NoZeroSpecialCharValidator__c, toLabel(NoZeroSpecialCharValidator_Msg__c),
                                             ImmigrationNumberValidator__c, toLabel(ImmigrationNumberValidator_Msg__c), I94Validator__c, toLabel(I94Validator_Msg__c),
                                             NextCurrentYear_Validator__c, toLabel(NextCurrentYear_Validator_Msg__c), SignatureMatchValidator__c, toLabel(SignatureMatchValidator_Msg__c),CompareDateValidator__c,toLabel(CompareDateValidatorMessage__c)
                							 FROM EntityMapping__mdt 
                							 WHERE SF_ObjectAPI__c IN :EntityNameSet 
                                             AND SF_FieldAPI__c IN :fieldNameSet
                                             AND ScreenName__c = : screenName];                                             

        /**Added by Shrikant - Security matrix implementation */
        if(sessionId != null){
            entityMappingObj.applicableProgramSet = SSP_Utility.getAvailableProgramsByRole();
            entityMappingObj.securityMatrix = SSP_Utility.getScreenAccessDetails(sMatrixScreenName, null);
        }
        else{
            entityMappingObj.securityMatrix = new SSP_Utility.SecurityMatrixWrapper();
        }
        /** */

        //Perf Fix: limiting global describe calls.
        Map<String,Map<String, Schema.SObjectField>> describeObjectFieldMap = new Map<String,Map<String, Schema.SObjectField>>();
        Map<String, Schema.SObjectType> globalDescribe;
        for(EntityMapping__mdt entObj : metaList)
        {
            mapOfEntityMapping.put(entObj.SF_FieldAPI__c+','+entObj.SF_ObjectAPI__c, entObj);

            //Perf Fix: limiting global describe calls.
            if(globalDescribe == null){
                globalDescribe = Schema.getGlobalDescribe();
            }
            if(!describeObjectFieldMap.containsKey(entObj.SF_ObjectAPI__c)){
                describeObjectFieldMap.put(entObj.SF_ObjectAPI__c,globalDescribe.get(entObj.SF_ObjectAPI__c).getDescribe().fields.getMap());
            }

            Schema.DescribeFieldResult fieldResult  = describeObjectFieldMap.get(entObj.SF_ObjectAPI__c).get(entObj.SF_FieldAPI__c).getDescribe();

            if(String.valueOf(fieldResult.getType()) == 'PICKLIST')
            {                                
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
                for(Schema.PicklistEntry f : ple)
                {
                    picklistLabelValue.put(f.getLabel(), f.getValue());
                } 
            }

            /**Added By Shrikant - Security Matrix Implementation */
            VisibilityMatrix tmpVisibilityMatrix = new VisibilityMatrix();
            Set<String> fieldPrograms = String.isNotBlank(entObj.Programs__c) ? new Set<String>((entObj.Programs__c).split(',')) : null;
            tmpVisibilityMatrix.isDisabled = (entityMappingObj.securityMatrix != null && String.isNotBlank(entityMappingObj.securityMatrix.screenPermission) && entityMappingObj.securityMatrix.screenPermission.equalsIgnoreCase('ReadOnly')) ? true : false;
            //tmpVisibilityMatrix.renderElement = (fieldPrograms != null && !fieldPrograms.isEmpty()) ? SSP_CareTakerServicesQueueRule.checkPrograms(fieldPrograms, entityMappingObj.applicableProgramSet) : true;
            tmpVisibilityMatrix.programs = fieldPrograms;
            tmpVisibilityMatrix.renderElement = true;
            renderingMap.put(entObj.SF_FieldAPI__c, tmpVisibilityMatrix);
            /** */
        }				
        entityMappingObj.renderingMap = renderingMap;
        entityMappingObj.metadataList = mapOfEntityMapping;
        entityMappingObj.mapOfPicklistOptions = picklistLabelValue;	
        return entityMappingObj;   
    }
    public class EntityMappingWrapper
    {                       
        @AuraEnabled
        public Map<String, EntityMapping__mdt> metadataList {get;set;} 
        @AuraEnabled
        public Map<String, String> mapOfPicklistOptions {get;set;}      
        /**Added by Shrikant - Security matrix implementation */
        @AuraEnabled
        public Set<String> applicableProgramSet {get; set;}        
        @AuraEnabled
        public Map<String, VisibilityMatrix> renderingMap {get; set;}
        @AuraEnabled
        public SSP_Utility.SecurityMatrixWrapper securityMatrix {get; set;}
        
    }

    /**Added by Shrikant - Security matrix implementation */
    public class VisibilityMatrix
    {
        @AuraEnabled
        public Boolean renderElement {get; set;}
        @AuraEnabled
        public Boolean isDisabled {get; set;}
        @AuraEnabled
        public Set<String> programs {get; set;}
    }
}