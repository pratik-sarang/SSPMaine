/*
* classname     :  SSP_IncomeController
* @description  :  Controller Method for sspChangeExistingIncome, sspRemoveIncomeModal LWC Components
* @author       :  Shrikant Raut   
* @date         :  11/12/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_IncomeController {
    public static final Map<String, String> mapIncomesToPrograms = new Map<String, String>{
                                'DIR' => 'MA,KT,SN,CC,SS',
                                    'IS' => 'MA,KT,SN,CC,SS',
                                    'EA' => 'MA,KT,SN,CC,SS',
                                    'OUI' => 'MA,KT,SN,CC,SS',
                                    'SE' => 'MA,KT,SN,CC,SS',
                                    'SRP' => 'MA,KT,SN,CC,SS',
                                    'SM' => 'MA,KT,SN,CC,SS',
                                    'UI' => 'CC'
                                    };

    /***************************************************************************************************
* @author       Shrikant Raut
* @date         11/13/2019
* @methodname   fetchExistingIncomeDetails
* @description  This methods is used to fetch IncomePayFrequency__c picklist values and existing income(SSP_Asset__c) records for specified member
* @return       String                  :  Serialized Map<String, Object> - (Keys - incomeRecords, incomeFrequencies)
*****************************************************************************************************/
    @auraEnabled(cacheable=true)
    public static String fetchExistingIncomeDetails(Id sspMemberId, Id sspApplicationId, String callingComponent ){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        Map<String, Object> detailMap = new Map<String, Object>();
        List<SSP_Asset__c> incomeList = new List<SSP_Asset__c>();
        List<SSP_ApplicationIndividual__c> appIndividualList = new List<SSP_ApplicationIndividual__c>();
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> sspMemberId, 'RecordType.DeveloperName'=>'Income'};
            Map<String, String> queryDetailMap =  new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'};
                Set<String> fieldSet = new Set<String>{'Id', 'BusinessTypeCode__c', 'EmployerName__c','IsDeleted__c', 'IsExistingData__c', 'EndDate__c','Tips__c', 'Name', 'IncomeTypeCode__c', 'IncomePayFrequency__c', 'TotalGrossAmount__c', 'IncomePayDetailHoursPerWeek__c', 'ExpenseAmount__c','ExpensesAmount__c', 'RecordTypeId', 'RecordType.Name', 'RecordType.DeveloperName', 'SSP_Member__r.Name','IncomeSubtypeCode__c', 'ActivityType__c','ContractStartDate__c','ContractEndDate__c'};
                    Map<String, String> incomeFrequencies = new Map<String, String>();
        Map<String, String> incomeTypes = new Map<String, String>();
        Map<String, String> incomeBusinessTypes = new Map<String, String>();
         Map<String, String> incomeSubtypeCodes = new Map<String, String>();
        List<String> lstPrograms = new List<String>();
        if(sspMemberId != null ){
            try{
                if(sspApplicationId != null){
                    appIndividualList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(sspMemberId, sspApplicationId, null);
                }
                if(!appIndividualList.isEmpty() && appIndividualList[0].ProgramsApplied__c != null){
                    lstPrograms = appIndividualList[0].ProgramsApplied__c.split(';');
                    if(lstPrograms.contains(SSP_GlobalConstants.MEDICAID) && appIndividualList[0].MedicaidType__c != null){         
                        lstPrograms.add(appIndividualList[0].MedicaidType__c);
                    }
                }
                List<String> lstIncomeBasedPrograms = getApplicableIncomesBasedOnPrograms(lstPrograms);
                if(!lstIncomeBasedPrograms.isEmpty()) {           
                    conditionMap.put('IncomeTypeCode__c',String.join(lstIncomeBasedPrograms, ','));
                }
                if(callingComponent != null && (callingComponent.equalsIgnoreCase('sspChangeExistingIncome') || callingComponent.equalsIgnoreCase('sspRemoveExistingIncome'))){
                    conditionMap.put('IsExistingData__c','#true#');
                }
                if(callingComponent != null && callingComponent.equalsIgnoreCase('sspRemoveExistingIncome')){
                   fieldSet.removeAll(new Set<String>{'IncomeSubtypeCode__c','BusinessTypeCode__c','IncomePayFrequency__c'});
                   fieldSet.addAll(new Set<String>{'toLabel(IncomeSubtypeCode__c)','toLabel(BusinessTypeCode__c)', 'toLabel(IncomePayFrequency__c)'});
                 }
                conditionMap.put('isDeleted__c','#false#');
                queryDetailMap.put('hasToLabel','true');
                queryDetailMap.put('IN','IncomeTypeCode__c');
                fieldSet.removeAll(new Set<String>{'ActivityType__c'});
                fieldSet.addAll(new Set<String>{'toLabel(ActivityType__c)'});
               
                incomeList = SSP_AssetSelector.queryAssetData(queryDetailMap, fieldSet, conditionMap);
                
                
                


                
                if(callingComponent == null || (callingComponent != null && !callingComponent.equalsIgnoreCase('sspChangeExistingIncome'))){
                    incomeFrequencies = SSP_Utility.getPickListValues('SSP_Asset__c', 'IncomePayFrequency__c', null);
                    incomeTypes = SSP_Utility.getPickListValues('SSP_Asset__c', 'IncomeTypeCode__c', null);
                    incomeBusinessTypes = SSP_Utility.getPickListValues('SSP_Asset__c', 'BusinessTypeCode__c', null);
                    incomeSubtypeCodes = SSP_Utility.getPickListValues('SSP_Asset__c', 'IncomeSubtypeCode__c',null);
                    
                    detailMap.put('incomeTypes',incomeTypes);
                    detailMap.put('incomeBusinessTypes',incomeBusinessTypes);
                    detailMap.put('incomeFrequencies',incomeFrequencies);  
		     detailMap.put('incomeSubtypeCodes', incomeSubtypeCodes);
                }

                /** 2.5	Security Role Matrix and Program Access. */
                if(String.isNotBlank(callingComponent) && callingComponent.equalsIgnoreCase('sspIncomeSummary')){
                    detailMap.put('securityMatrixSummary', SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HH_INCOME_SUMMARY_SCREENID, null));
                    detailMap.put('securityMatrixDetails', SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HH_INCOME_DETAILS_SCREENID, null));                        
                }
                /** */  
                detailMap.put('applicationIndividual',appIndividualList);   
                detailMap.put('incomeRecords',incomeList);
                detailMap.put('timeTravelDate', SSP_Utility.today());
            }catch(Exception ex){
                detailMap.put('ERROR',ex.getStackTraceString());
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeController', 'fetchExistingIncomeDetails', ex.getMessage() , true);
            }
        }
        
        return JSON.serialize(detailMap);
    }

    @AuraEnabled
    public static string fetchExistingIncomeDetailsImperative(Id sspMemberId, Id sspApplicationId, String callingComponent ){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
	return SSP_IncomeController.fetchExistingIncomeDetails(sspMemberId, sspApplicationId, callingComponent);
    }
    
    
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         11/13/2019
* @methodname   updateExistingIncomeRecords
* @description  This methods is used to update SSP_Asset__c records
* @return       Boolean
*****************************************************************************************************/
    @auraEnabled
    public static Boolean updateExistingIncomeRecords(String incomeJSON){        
        Boolean result = true;
        
        try{
            result = updateSSPAssetRecords(incomeJSON);
        }
        catch(Exception ex){
            result = false;
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_IncomeController', 'updateExistingIncomeRecords', ex.getMessage(), true);
        }
        return result;
    }
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         11/26/2019
* @methodname   updateExistingIncomeRecords
* @description  This methods is used to update SSP_Asset__c records
* @return       Boolean
*****************************************************************************************************/    
    public static Boolean updateSSPAssetRecords(String incomeJSON){
        Boolean result = true;
        List<SSP_Asset__c> incomeList; 
        
        if(incomeJSON != null && Schema.sObjectType.SSP_Asset__c.isUpdateable()){
            incomeList = (List<SSP_Asset__c>)JSON.deserialize(incomeJSON, List<SSP_Asset__c>.class);
            ESAPI.accessController().updateAsUser(new Map<ID,SSP_Asset__c>(incomeList), SSP_Utility.getFieldsNamesList (incomeList)); //ForceReviewer Fix
        }
        
        return result;
    }
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         11/18/2019
* @methodname   deleteIncomeRecord
* @description  This methods is used to fetch IncomePayFrequency__c picklist values and existing income(SSP_Asset__c) records for specified member
* @return       Boolean    :  Deletion result
*****************************************************************************************************/
    @AuraEnabled
    public static Boolean deleteIncomeRecord(Id incomeId){
        Boolean result = true;
        try{
            List<SSP_Asset__c> incomesToBeRemoved = new List<SSP_Asset__c>{new SSP_Asset__c(Id = incomeId)};                        
                ESAPI.accessController().deleteAsUser(incomesToBeRemoved);
        }
        catch(Exception ex){
            result = false;
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_IncomeController', 'deleteIncomeRecord', ex.getMessage(), true);
        }
        return result;
    }
    /**
* method        : setIncomeDetails
* @description  : This method gets details from Income Details Screen and Commits to database
* @author       : Kireeti Gora
* @param        : String sIncomeJSON - JSON String of Income Details.
* @returnType   : Boolean
* */   
    @AuraEnabled
    public static String setIncomeDetails(String sIncomeJSON,String sspApplicationId){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        String sObjIncome = '';
        SSP_Asset__c objIncome = new SSP_Asset__c();
        SSP_Member__c objMember = new SSP_Member__c();
        List<SSP_Member__c> lstmember =new List<SSP_Member__c>();
        
        
        if(sIncomeJSON != null && Schema.sObjectType.SSP_Asset__c.isUpdateable() && Schema.sObjectType.SSP_Member__c.isUpdateable()){
            try{                
                objIncome = (SSP_Asset__c)JSON.deserialize(sIncomeJSON, SSP_Asset__c.class);
                //Address Validation Service
                //REMOVED AS PART OF DEFECT 376109 - SAI
                //validateMemberPhysicalAddress(objIncome);
                objIncome.SSP_Application__c = sspApplicationId;
                objIncome.RecordTypeId =Schema.SObjectType.SSP_Asset__c.getRecordTypeInfosByName()
                    .get('Income').getRecordTypeId(); 
                if(objIncome.SSP_Member__c != null && Schema.sObjectType.SSP_Asset__c.isAccessible() 
                   && Schema.sObjectType.SSP_Member__c.isAccessible()){ 
                       lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                                      new Set<String>{'Id',
                                                                          'HasDividendsRoyaltiesToggle__c','HasUnpaidEmploymentToggle__c','HasEarnedIncomeFromEmploymentToggle__c',
                                                                          'HasSelfEmploymentIncomeToggle__c','HasServicesorPaymentsToggle__c','HasMaintenanceIncomeToggle__c','HasInsuranceSettlementBenefitToggle__c',
                                                                          'HasUnearnedIncomeToggle__c'}, 
                                                                      new Map<String, String>{'limit'=>'1','Id'=> objIncome.SSP_Member__c});
                       
                       if(!lstmember.isEmpty()){     
                           objMember = constructMemberData(lstmember[0], objIncome);
                           
                           ESAPI.accessController().updateAsUser(objMember, SSP_Utility.getFieldsNamesObject(objMember)); 
                           
                           
                       }
                   } 
                
                ESAPI.accessController().upsertAsUser(objIncome, SSP_Utility.getFieldsNamesObject(objIncome));
                
                
                sObjIncome = JSON.serialize(objIncome);
            }
            catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeController', 'setIncomeDetails', 'Failed to update Income Details', true);        
                
            }
        }
        return sObjIncome;
        
    }
     /**
* method        : constructMemberData
* @description  : This method constructs member data to update 
* @author       : Kireeti Gora
* @returnType   : SSP_Member__c Object
* */  
    private static SSP_Member__c constructMemberData(SSP_Member__c objMember, SSP_Asset__c objIncome){
     
        if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.DIVIDEND_INCOME_TYPE) {
            objMember.HasDividendsRoyaltiesToggle__c = 'Y';
        } else if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.UNPAID_INCOME_TYPE) {
            objMember.HasUnpaidEmploymentToggle__c = 'Y';
        } else if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.EARNED_EMPLOYMENT_INCOME_TYPE) {
            objMember.HasEarnedIncomeFromEmploymentToggle__c = 'Y';  
        } else if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.SELF_EMPLOYMENT_INCOME_TYPE) {
            objMember.HasSelfEmploymentIncomeToggle__c = 'Y';
        } else if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.SERVICE_INCOME_TYPE) {
            objMember.HasServicesorPaymentsToggle__c = 'Y';
        } else if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.MAINTENANCE_INCOME_TYPE) {
            objMember.HasMaintenanceIncomeToggle__c = 'Y';        
        } else if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.INSURANCE_INCOME_TYPE) {
            objMember.HasInsuranceSettlementBenefitToggle__c ='Y';
        } else if (objIncome.IncomeTypeCode__c == SSP_GlobalConstants.UNEARNED_INCOME_TYPE) {
            objMember.HasUnearnedIncomeToggle__c ='Y';
        }
        return objMember;
    }
    
    /**
* method        : getDuplicateEmployerIncomeDetails
* @description  : This method getsduplicate income details if user is try to insert
* @author       : Kireeti Gora
* @param        : String sIncomeJSON - JSON String of Income Details.
* @returnType   : Json String of Income Object
* */  
    
    
    @AuraEnabled 
    public static String getDuplicateEmployerIncomeDetails(String sIncomeJSON){
        String sIncomeObj = '';
        SSP_Asset__c objIncome = new SSP_Asset__c();       
        List<SSP_Asset__c> lstAsset =new List<SSP_Asset__c>();   
        Map<String, String> queryDetailMap =  new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'};
            Set<String> fieldSet = new Set<String>{'Id', 'SSP_Member__c', 'EmployerName__c', 'TotalGrossAmount__c','IncomePayFrequency__c'};
                if(sIncomeJSON != null){
                    try{  
                        objIncome = (SSP_Asset__c)JSON.deserialize(sIncomeJSON, SSP_Asset__c.class);  
                        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> objIncome.SSP_Member__c, 'RecordType.DeveloperName'=>'Income',
                            'EmployerName__c'=>objIncome.EmployerName__c };
                                
                                if(objIncome != null ){
                                    queryDetailMap.put('hasToLabel','true');
                                    lstAsset = SSP_AssetSelector.queryAssetData(queryDetailMap,fieldSet,conditionMap); 
                                    if(!lstAsset.isEmpty() ){     
                                        sIncomeObj =JSON.serialize(lstAsset[0]);
                                    }
                                }}catch(Exception ex){
                                    List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeController', 'getDuplicateEmployerIncomeDetails', 'Failed to update Income Details', true);        
                                    
                                }
                }
        return sIncomeObj;
    }
    /**
* method        : getIncomeDetails
* @description  : This method fetches Income details With Id
* @author       : Kireeti Gora
* @param        : sId - Id for fetching Income Details
* @returnType   : String 
* */  
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getIncomeDetailsWithId(String sId,Id sspApplicationId,Id sspMemberId){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        String sIncome = '';
        List<SSP_Asset__c> lstAsset = new List<SSP_Asset__c>();
        response.put('timeTravelDate', SSP_Utility.today());
        try{
            if(sId != null && sId != '' && Schema.sObjectType.SSP_Asset__c.isAccessible() 
               && Schema.sObjectType.SSP_Member__c.isAccessible()){   
                   lstAsset = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                               new Set<String>{'Id', 'SSP_Member__c', 'EmployerName__c', 'EIN__c','AddressLine1__c','AddressLine2__c','City__c','CountyCode__c','CountryCode__c',
                                                                   'StateCode__c','ZipCode4__c','ZipCode5__c',
                                                                   'BusinessTitle__c', 'ActivityType__c', 'IsSchoolDegreeRequiredToggle__c', 'IsUnempBenefitsRequiredToggle__c', 'IncomeTypeCode__c',
                                                                   'IncomeSubtypeCode__c', 'IncomePayFrequency__c', 'TotalGrossAmount__c', 'Tips__c', 'IncomePayDetailHoursPerWeek__c',
                                                                   'ExpenseAmount__c', 'ActivityStartDate__c', 'StartDate__c', 'EndDate__c', 'PrimaryPhoneNumber__c',
                                                                   'PrimaryPhoneExtension__c','BusinessTypeCode__c','DivorceDate__c','ContractStartDate__c','ContractEndDate__c'}, 
                                                               new Map<String, String>{'limit'=>'1','Id'=> sId});
                   
                   if(!lstAsset.isEmpty()){                     
                       response.put('incomeRecord',JSON.serialize(lstAsset[0])); 
                       sspMemberId = lstAsset[0].SSP_Member__c;
                   }                   
               }
            if(sspApplicationId != null && sspMemberId != null){
                
                List<SSP_ApplicationIndividual__c> lstApplicationIndividualForProgram = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(sspMemberId, sspApplicationId, null);
                if(!lstApplicationIndividualForProgram.isEmpty()){    
                    response.put('applicationIndividualPrograms',lstApplicationIndividualForProgram);  
                }
            }        
            
        }catch(Exception e){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_IncomeController', 'getIncomeDetailsWithId', 'Failed to fetch Income Details', true);  
        }
        
        return response;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicableIncomesBasedOnPrograms
    * @desc This method is used to get the applicable income types based on programs
    * @param List<String> lstCurrentAppPrograms
    * @return List<String>
    * */
    public static List<String> getApplicableIncomesBasedOnPrograms(List<String> lstCurrentAppPrograms){
        Set<String> setIncomes = new Set<String>();
        try{
            for(String strIncomeValue : mapIncomesToPrograms.keySet()) {
                List<String> lstPrograms = mapIncomesToPrograms.get(strIncomeValue).split(',');
                if(SSP_Utility.checkApplicablePrograms(lstCurrentAppPrograms, new Set<String>(lstPrograms))){
                    setIncomes.add(strIncomeValue);
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_IncomeController', 'getApplicableIncomesBasedOnPrograms', e.getMessage(), true);
        }        
        return new List<String>(setIncomes);
    }
}