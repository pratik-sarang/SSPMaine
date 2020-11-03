/*
* classname     :  SSP_ExpenseController
* @description  :  Controller class for sspChangeExistingExpense
* @author       :  Shrikant Raut   
* @date         :  11/26/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_ExpenseController {
    
    public static String HAS_MEDICAL_BILL_GATEPOST_QUESTION = 'HasMedicalBillsToggle__c';
    public static final Map<String, String> fieldToTypeMap = new Map<String, String>{
        'HasMedicalBillsToggle__c' => 'ME',
            'HasDisabledExpensesToggle__c' => 'ME',
            'HaveHigherEducationExpenseToggle__c' => 'EE',
            'HasTaxDeductionsExpenseToggle__c' => 'DE',
            'HasUtilityExpenseToggle__c' => 'UE',
            'HasShelterExpenseToggle__c' => 'SE',
            'HasAlimonyExpenseToggle__c' => 'AL',
            'HasMedicalExpensePartDToggle__c' => 'ME',
            'HasHouseholdPaidChildSupportToggle__c' => 'CAE',
            'HasDependentCareExpenseToggle__c' => 'DCE'
            };

    public static final Map<String, String> fieldToSubTypeMap = new Map<String, String>{
            'HasMedicalExpensePartDToggle__c' => 'MP'
            };

    public static final Map<String, String> typeToFieldMap = new Map<String, String>{
          //  'ME' => 'HasMedicalBillsToggle__c',
            'ME' => 'HasDisabledExpensesToggle__c',
            'EE' => 'HaveHigherEducationExpenseToggle__c',
            'DE' => 'HasTaxDeductionsExpenseToggle__c',
            'UE' => 'HasUtilityExpenseToggle__c',
            'SE' => 'HasShelterExpenseToggle__c',
            'AL' => 'HasAlimonyExpenseToggle__c',
            'ME-MP' => 'HasMedicalExpensePartDToggle__c',
            'CAE' => 'HasHouseholdPaidChildSupportToggle__c',
            'DCE' => 'HasDependentCareExpenseToggle__c'
            };
                
    public static final Map<String, String> mapExpensesToPrograms = new Map<String, String>{
                                'ME' => 'Non-MAGI,SN',
                                    'EE' => 'SN',
                                    'DE' => 'MA',
                                    'UE' => 'Non-MAGI,SN',
                                    'SE' => 'Non-MAGI,SN',
                                    'AL' => 'KT',
                                    'CAE' => 'SN,KT,Non-MAGI,CC',
                                    'DCE' => 'SN,KT'
                                    };                                    
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         02/19/2020
    * @methodname   fetchExistingExpenseDetailsImperative
    * @description  This methods is used to fetch  existing expense(SSP_Asset__c) records for specified member
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchExistingExpenseDetailsImperative(Id sspMemberId, Id sspApplicationId, String callingComponent ){
        return fetchExistingExpenseDetails(sspMemberId, sspApplicationId, callingComponent);
    }     

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/26/2019 
    * @methodname   fetchExistingExpenseDetails
    * @description  This methods is used to fetch  existing expense(SSP_Asset__c) records for specified member
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @auraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchExistingExpenseDetails(Id sspMemberId, Id sspApplicationId, String callingComponent ){ 
         SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
         SSP_LightningResponse response = new SSP_LightningResponse();
         Set<String> fieldSet = new Set<String>{'Id','IsExistingData__c','EndDate__c','ExpenseTypeCode__c', 'ExpenseSubType__c', 'SSP_Member__c', 'ExpenseFrequencyCode__c','ExpenseAmount__c','ExpensesAmount__c','TuitionAmount__c','BooksAmount__c','FeesAmount__c','MiscellaneousAmount__c', 'SSP_Member__r.Name', 'SSP_Member__r.HasReceivedBenefitsFromOtherStateToggle__c'};
         List<SSP_Asset__c> expenseList = new List<SSP_Asset__c>();
         List<SSP_Asset__c> updatesExpenseList = new  List<SSP_Asset__c>();
         List<SSP_ApplicationIndividual__C> updatedAppIndivList = new List<SSP_ApplicationIndividual__C>();
         Boolean showExpenseAndShelterQuestion = false;
         Set<String> memberSet = new Set<String>();
         List<SSP_ApplicationIndividual__c> appIndividualList = new List<SSP_ApplicationIndividual__c>();
        List<String> lstPrograms = new List<String>();
         Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> sspMemberId, 'RecordType.DeveloperName'=>'Expense'};
        Boolean isParticipatingInWorkStudyProgram = false;
            
            if(sspMemberId != null ){
                memberSet.add(sspMemberId);
                try{
                    if(sspApplicationId != null){
                        appIndividualList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(sspMemberId, sspApplicationId, new Set<String>{'MedicaidType__c','IsNoChangesToExpenses__c','ProgramsApplied__c'});
                    }

                    if(!appIndividualList.isEmpty() && appIndividualList[0].ProgramsApplied__c != null){
                        lstPrograms = appIndividualList[0].ProgramsApplied__c.split(';');
                        if(lstPrograms.contains(SSP_GlobalConstants.MEDICAID) && appIndividualList[0].MedicaidType__c != null){         
                            lstPrograms.add(appIndividualList[0].MedicaidType__c);
                        }
                    }

                    List<String> lstExpenseBasedPrograms = getApplicableExpensesBasedOnPrograms(lstPrograms);
                    if(!lstExpenseBasedPrograms.isEmpty()) {           
                        conditionMap.put('ExpenseTypeCode__c',String.join(lstExpenseBasedPrograms, ','));
                    }
                    if(callingComponent != null && (callingComponent.equalsIgnoreCase('sspChangeExistingExpense') || callingComponent.equalsIgnoreCase('sspRemoveExistingExpense'))){
                        conditionMap.put('IsExistingData__c','#true#');
                       // conditionMap.put('EndDate__c','#null#');                      
                    }
                    
                    if(callingComponent != null && callingComponent.equalsIgnoreCase('sspExpensesSummary')){ 
                        /** 2.5	Security Role Matrix and Program Access. */
                        response.put('securityMatrixSummary', SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HH_EXPENSE_SUMMARY_SCREENID, null));
                        response.put('securityMatrixDetails', SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HH_EXPENSE_DETAILS_SCREENID, null));                        
                        /** */                                   
                        fieldSet.addAll(new Set<String>{'ReceiveInHouseAssistance__c','IsNonHouseHoldMemberPayingExpenseToggle__c','ProviderName__c','ExpenseSubType__c','StartDate__c','EndDate__c','ExpenseAmount__c','ChildName__c','DependentCareProvider__c','DependentIndividual__c'});
                    }
                    conditionMap.put('isDeleted__c','#false#');
                    expenseList = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND','IN'=>'ExpenseTypeCode__c'}, 
                                                                    fieldSet, 
                                                                    conditionMap);   
                   
                    isParticipatingInWorkStudyProgram = SSP_ExpenseService.isParticipatingInWorkStudyProgram(sspMemberId);
                    List<SSP_Asset__c> deleteExpenseList = new List<SSP_Asset__c>();
                    for(SSP_Asset__c expenseCheck :expenseList){                        
                        if(expenseCheck.ExpenseTypeCode__c == SSP_GlobalConstants.EDUCATION_EXPENSE_TYPE ){
                            if(appIndividualList!=null && appIndividualList.size()>0){
                                if(isParticipatingInWorkStudyProgram && appIndividualList[0].ProgramsApplied__c.contains('SN')){
                                    updatesExpenseList.add(expenseCheck);
                                } else {
                                    deleteExpenseList.add(expenseCheck);
                                }
                            }
                        }
                        else {
                              updatesExpenseList.add(expenseCheck);
                        }
                    }
                   
                    if(!deleteExpenseList.isEmpty() && Schema.sObjectType.SSP_Asset__c.isDeletable()){
                        delete deleteExpenseList;
                    }
                                        
                    response.put('applicationIndividual',appIndividualList);   
                    response.put('memberDisabilityMatrix', constructMemberDisabilityMatrix(appIndividualList));
                    response.put('expenseRecords',updatesExpenseList);
                    response.put('expenseTypes',SSP_Utility.getPickListValues('SSP_Asset__c', 'ExpenseTypeCode__c', null));
                    response.put('expenseSubTypes',SSP_Utility.getPickListValues('SSP_Asset__c', 'ExpenseSubType__c', null));
                    response.put('expenseFrequencies',SSP_Utility.getPickListValues('SSP_Asset__c', 'ExpenseFrequencyCode__c', null));
                    response.put('isParticipatingInWorkStudyProgram', isParticipatingInWorkStudyProgram);
                    response.put('timeTravelDate', SSP_Utility.today());
                    response.bIsSuccess = true;
                }
                catch(Exception ex){                                       
                    response.put('ERROR',ex.getStackTraceString());
                    List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpenseController', 'fetchExistingExpenseDetails', ex.getMessage() , true);
                }
            }
        
        return response;
    }
    
    
    
    public static Map<String, Set<String>> constructMemberDisabilityMatrix (List<SSP_ApplicationIndividual__c> appIndvList){
        Map<String, Set<String>> resultMap = new Map<String, Set<String>>();
        Set<String> memberIdSet = new Set<String>();
       
        if(appIndvList != null && !appIndvList.isEmpty()){
            for(SSP_ApplicationIndividual__c appIndv : appIndvList){
                if(appIndv != null && appIndv.SSP_Member__c != null){
                    memberIdSet.add(appIndv.SSP_Member__c);
                    resultMap.put(appIndv.SSP_Member__c, new Set<String>());
                }
            }
        }

        if(!memberIdSet.isEmpty()){
            for(SSP_Asset__c expenseData : 
            SSP_AssetSelector.queryAssetData(
                new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND','IN'=>'SSP_Member__c'}, 
                new Set<String>{'Id','SSP_Member__c','ExpenseTypeCode__c','ExpenseSubType__c','SSP_Member__r.HasShelterExpenseToggle__c','SSP_Member__r.HasUtilityExpenseToggle__c','SSP_Member__r.HasMedicalExpensePartDToggle__c','SSP_Member__r.HasDependentCareExpenseToggle__c',
                                                                          'SSP_Member__r.HasTaxDeductionsExpenseToggle__c','SSP_Member__r.HasAlimonyExpenseToggle__c','SSP_Member__r.HaveHigherEducationExpenseToggle__c','IsExistingData__c','EndDate__c','IsDeleted__c',
                                                                          'SSP_Member__r.HasHouseholdPaidChildSupportToggle__c' ,'SSP_Member__r.HasMedicalBillsToggle__c','SSP_Member__r.HasDisabledExpensesToggle__c' }, 
                new Map<String, String>{'IsExistingData__c'=>'#true#','RecordType.DeveloperName'=>'Expense','SSP_Member__c'=> String.join(new List<String>(memberIdSet), ',')})){
                   
                    
                   
                    if(expenseData != null && expenseData.ExpenseTypeCode__c != null && typeToFieldMap.containsKey(expenseData.ExpenseTypeCode__c)  && expenseData.isDeleted__c==false && ((expenseData.IsExistingData__c && (expenseData.EndDate__c>ssp_utility.today() ||  expenseData.EndDate__c==null) ) || (!expenseData.IsExistingData__c))){
                        
                        if(null!=typeToFieldMap.get(expenseData.ExpenseTypeCode__c +'-'+expenseData.ExpenseSubType__c)) {
                            resultMap.get(expenseData.SSP_Member__c).add(typeToFieldMap.get(expenseData.ExpenseTypeCode__c +'-'+expenseData.ExpenseSubType__c));
                        }
                        
                        else if(null!=typeToFieldMap.get(expenseData.ExpenseTypeCode__c) && expenseData.ExpenseTypeCode__c=='ME' ){
                            
                            if(null!=expenseData.SSP_Member__r.HasDisabledExpensesToggle__c && expenseData.SSP_Member__r.HasDisabledExpensesToggle__c=='Y' ){
                                resultMap.get(expenseData.SSP_Member__c).add('HasDisabledExpensesToggle__c');
                            }
                        }                                               
                        else if(null!=typeToFieldMap.get(expenseData.ExpenseTypeCode__c) ){
                        resultMap.get(expenseData.SSP_Member__c).add(typeToFieldMap.get(expenseData.ExpenseTypeCode__c));
                        }
                         
                    }
                }
            
        }
        return resultMap;

    }
    
    
    /***************************************************************************************************
* @author       Shrikant Raut
* @date         11/26/2019
* @methodname   updateExistingExpenseRecords
* @description  This methods is used to update SSP_Asset__c records
* @return       Boolean
*****************************************************************************************************/
    @auraEnabled
    public static Boolean updateExistingExpenseRecords(String incomeJSON){  
      
        Boolean result = true;
        try{
            result = SSP_IncomeService.updateSSPAssetRecords(incomeJSON);
        }
        catch(Exception ex){
            //log exception here
            result = false;
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_ExpenseController', 'updateExistingExpenseRecords', ex.getMessage(), true);
        }
        return result;
    }
    
    /***************************************************************************************************
* @author       Yathansh Sharma
* @date         12/04/2019
* @methodname   fetchMemberList
* @description  This methods is used to fetch member list for the current user
* @return       LightningResponse
*****************************************************************************************************/
    @auraEnabled(cacheable=true)
    public static ssp_LightningResponse fetchMemberList(Id sspApplicationId, String sMode){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        Map<String, String> appIndDetailMap = new Map<String, String>();
		Map<String, String> appIndConditionMap = new Map<String, String>();
        List<SSP_Member__c> memberList = new List<SSP_Member__c>();
        List<SSP_ApplicationIndividual__c> appIndividualList = new List<SSP_ApplicationIndividual__c>();
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1000'};
        Map<String, String> expenseTypes = new Map<String, String>();
    
        try{
        sMode = String.escapeSingleQuotes(sMode);
        appIndDetailMap.put('objectName', 'SSP_ApplicationIndividual__c');
        appIndConditionMap.put('SSP_Application__c', sspApplicationId);
        // Added below condition for addRemoveMember flow
        if(String.isNotBlank(sMode) && SSP_GlobalConstants.MODE.equals(sMode)) {
        	appIndDetailMap.put('operator', 'AND');
            appIndConditionMap.put('MemberStatus__c', SSP_GlobalConstants.MEMBER_STATUS_New);                
        }
        List<SSP_ApplicationIndividual__c> applicationIndis = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
            appIndDetailMap, 
            new Set<String>{'Id','SSP_Member__c','IsTMember__c','ProgramsApplied__c','MedicaidType__c','SSP_Member__r.birthDate__c'}, 
            appIndConditionMap
        );
        //[select id, SSP_Member__c from SSP_ApplicationIndividual__c where SSP_Application__c=:sspApplicationId];
        List<Id> memberIds = new list<id>();
        Map<String, Set<String>> removeMember = new Map<String, Set<String>>();
        List<SSP_ApplicationIndividual__c>  appIndividual = new  List<SSP_ApplicationIndividual__c> ();    
        Set<String> memberIdSet = new Set<String>();
            Map<String,List<SSP_Relationship__c>> mapRelationship = new Map<String,List<SSP_Relationship__c>>();
            for(SSP_ApplicationIndividual__c appInd : applicationIndis){
                memberIdSet.add(appInd.SSP_Member__c);
            }
            List<SSP_Relationship__c> relationList = SSP_SignaturePageService.fetchRelationShip(memberIdSet);
            for(SSP_Relationship__c relation : relationList){
                if(mapRelationship.containsKey(relation.SSP_Member__c)){
                    mapRelationship.get(relation.SSP_Member__c).add(relation);
                }
                else{
                    mapRelationship.put(relation.SSP_Member__c,new List<SSP_Relationship__c> {relation});   
                }                
            }
            Boolean hasCommunitySpouse = false;
            Set<String> setPrograms = new Set<String>();
            for(SSP_ApplicationIndividual__c ai: applicationIndis){
                if(!ai.IsTMember__c){
                    memberIds.add(ai.SSP_Member__c);
                    appIndividual.add(ai);  
                    
                    if(ai.ProgramsApplied__c != null) {
                        setPrograms.addAll(ai.ProgramsApplied__c.split(';'));
                    }

                    if(ai.ProgramsApplied__c != null
                        && !ai.ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.SNAP)
                        && !(ai.ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.MEDICAID) 
                                && ai.MedicaidType__c!=null 
                                && ai.MedicaidType__c==SSP_GlobalConstants.NONMAGI
                            )){
                        removeMember.put(ai.SSP_Member__c, new SET<String>{'HasShelterExpenseToggle__c','HasUtilityExpenseToggle__c'});
                    } else if(ai.ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.MEDICAID)
                        && ai.MedicaidType__c!=null 
                        &&  ai.MedicaidType__c==SSP_GlobalConstants.NONMAGI){
                        removeMember.put(ai.SSP_Member__c, new SET<String>{'HasShelterExpenseToggle__c','HasUtilityExpenseToggle__c'});
                        if(mapRelationship!=null && mapRelationship.size()>0 && mapRelationship.containsKey(ai.SSP_Member__c) && !hasCommunitySpouse){
                            for(SSP_Relationship__c objRelation : mapRelationship.get(ai.SSP_Member__c)){
                                hasCommunitySpouse = String.isNotBlank(objRelation.SSP_MemberRelatedTo__r.LaTypeCode__c) && String.isNotBlank(objRelation.SSP_Member__r.LaTypeCode__c) && 
                                                     (objRelation.SSP_MemberRelatedTo__r.LaTypeCode__c == SSP_GlobalConstants.HOSP || objRelation.SSP_MemberRelatedTo__r.LaTypeCode__c == SSP_GlobalConstants.LTC) &&
                                                     objRelation.RelationshipType__c ==  SSP_GlobalConstants.SPOUSE && objRelation.SSP_Member__r.LaTypeCode__c != SSP_GlobalConstants.HOSP;
                            }
                        }                   
                    }

                    if(ai.ProgramsApplied__c != null && ai.ProgramsApplied__c.contains('MA') && SSP_Utility.monthsBetweenDates(ai.SSP_Member__r.birthDate__c) == 0){
                        removeMember.put(ai.SSP_Member__c, new SET<String>{'HasMedicalBillsToggle__c'});
                    }
                }
            } 

            for(String strMember : removeMember.keyset()) {
                if((hasCommunitySpouse 
                    && (setPrograms.contains(SSP_GlobalConstants.MEDICAID) && SSP_ResourcesService.isNONMagiApplication(sspApplicationId)))
                    ||(setPrograms.contains(SSP_GlobalConstants.SNAP))) {
                    removeMember.get(strMember).remove('HasShelterExpenseToggle__c');
                    removeMember.get(strMember).remove('HasUtilityExpenseToggle__c');
                }
            }
        conditionMap.put('Id',String.join(memberIds,','));
        Set<String> fieldsToQuery = new Set<String>{'Id','Name', 'FirstName__c', 'LastName__c','Age__c','(Select ProgramsApplied__c, MedicaidType__c from SSP_ApplicationIndividuals__r where SSP_Application__c = \''+String.escapeSingleQuotes(sspApplicationId)+'\')'};
            fieldsToQuery.addAll(SSP_ExpenseController.fieldToTypeMap.keySet());
        memberList = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND', 'IN'=>'Id'}, 
                                                        fieldsToQuery,
                                                        conditionMap);
            
        
        response.put('memberList',memberList);
        response.put('removeMemberForShelterUtility',removeMember);
        response.put('memberDisabilityMatrix', constructMemberDisabilityMatrix(appIndividual));
        /** 2.5	Security Role Matrix and Program Access. */
            response.put('screenPermission', SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.EXPENSE_SELECTION_SCREENID, null).screenPermission);
        /** */
    }catch(Exception ex){
        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_ExpenseController', 'fetchMemberList', ex.getMessage(), true);
    }
        
        return response;
    }
    /**
* method        : getExpenseDetails
* @description  : This method fetches Expense details With Id
* @author       : Kireeti Gora
* @param        : sId - Id for fetching Expense Details
* @returnType   : String 
* */ 
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getExpenseDetailsWithId(String sId,Id sspApplicationId,Id sspMemberId,String expenseName){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        String sExpense = '';
        List<SSP_Member__c> lstmember =new List<SSP_Member__c>();
        List<SSP_Asset__c> lstAsset = new List<SSP_Asset__c>(); 
        response.put('timeTravelDate', SSP_Utility.today());
        try{
            if(sId != null && sId != '' && Schema.sObjectType.SSP_Asset__c.isAccessible() 
               && Schema.sObjectType.SSP_Member__c.isAccessible()){   
                   if(expenseName == SSP_GlobalConstants.MEDICAL_EXPENSE_TYPE || expenseName ==  SSP_GlobalConstants.TAX_DEDUCTION_EXPENSE_TYPE){
                       lstAsset = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                   new Set<String>{'Id','ExpenseAmount__c','TuitionAmount__c','BooksAmount__c','FeesAmount__c',
                                                                       'MiscellaneousAmount__c','RecordTypeId', 'RecordType.Name',
                                                                       'RecordType.DeveloperName', 'SSP_Member__r.Name','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','EndDate__c','IsNonHouseHoldMemberPayingExpenseToggle__c',
                                                                       'ExpenseTypeCode__c', 'ExpenseFrequencyCode__c','toLabel(ExpenseSubType__c)','StartDate__c','ProviderName__c',
                                                                       'EndDate__c','ChildName__c','DependentCareProvider__c','DependentIndividual__c','SSP_Member__c',
                                                                       'DivorceDate__c','ReceiveInHouseAssistance__c','IsMoneyPaidToOutsideToggle__c'}, 
                                                                   new Map<String, String>{'limit'=>'1','Id'=> sId});
                       
                   }else{
                       lstAsset = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                                   new Set<String>{'Id','ExpenseAmount__c','TuitionAmount__c','BooksAmount__c','FeesAmount__c',
                                                                       'MiscellaneousAmount__c','RecordTypeId', 'RecordType.Name',
                                                                       'RecordType.DeveloperName', 'SSP_Member__r.Name','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c', 'EndDate__c','IsNonHouseHoldMemberPayingExpenseToggle__c',
                                                                       'ExpenseTypeCode__c', 'ExpenseFrequencyCode__c','ExpenseSubType__c','StartDate__c','ProviderName__c',
                                                                       'EndDate__c','ChildName__c','DependentCareProvider__c','DependentIndividual__c','SSP_Member__c',
                                                                       'DivorceDate__c','ReceiveInHouseAssistance__c','IsMoneyPaidToOutsideToggle__c'}, 
                                                                   new Map<String, String>{'limit'=>'1','Id'=> sId});
                       
                       
                   }
                   
                   //sExpense = JSON.serialize(lstAsset[0]); 
                   if(!lstAsset.isEmpty()){                     
                       response.put('expenseRecord',JSON.serialize(lstAsset[0])); 
                       sspMemberId = lstAsset[0].SSP_Member__c;
                   }
               }
            if(sspApplicationId != null){
                lstApplicationIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, sspApplicationId, null);
                if(!lstApplicationIndividual.isEmpty()){    
                    List<SSP_ApplicationIndividual__c> filteredAppIndividuals = new List<SSP_ApplicationIndividual__c>();
                    for(SSP_ApplicationIndividual__c sspAppIndividual : lstApplicationIndividual){
                        if(!sspAppIndividual.IsTMember__c){
                            filteredAppIndividuals.add(sspAppIndividual);
                        }
                    }
                    response.put('applicationIndividual',filteredAppIndividuals);  
                }
            }
            if(sspApplicationId != null && sspMemberId != null){
                
                List<SSP_ApplicationIndividual__c> lstApplicationIndividualForProgram = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(sspMemberId, sspApplicationId, null);
                if(!lstApplicationIndividualForProgram.isEmpty()){    
                    response.put('applicationIndividualPrograms',lstApplicationIndividualForProgram);  
                }
            }
            if( sspMemberId != null){
              
                    response.put('isParticipatingInWorkStudyProgram',SSP_ExpenseService.isParticipatingInWorkStudyProgram(sspMemberId));
                
            }
            
        }catch(Exception e){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_ExpenseService', 'getExpenseDetailsWithId', 'Failed to fetch Expense Details', true);  
        }
        
        return response;
    }
    /**
* method        : setExpenseDetails
* @description  : This method gets details from Expense Details Screen and Commits to database
* @author       : Kireeti Gora
* @param        : String sExpenseJSON - JSON String of Expense Details.
* @returnType   : Boolean
* */   
    @AuraEnabled
    public static String setExpenseDetails(String sIncomeJSON,String sspApplicationId){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        String sObjExpense = '';
        SSP_Asset__c objExpense = new SSP_Asset__c();
        SSP_Member__c objMember = new SSP_Member__c();
        List<SSP_Member__c> lstmember =new List<SSP_Member__c>();
        
        
        
        if(sIncomeJSON != null && Schema.sObjectType.SSP_Asset__c.isUpdateable() && Schema.sObjectType.SSP_Member__c.isUpdateable()){
            try{                
                objExpense = (SSP_Asset__c)JSON.deserialize(sIncomeJSON, SSP_Asset__c.class);  
                objExpense.RecordTypeId =Schema.SObjectType.SSP_Asset__c.getRecordTypeInfosByName()
                    .get('Expense').getRecordTypeId();
                objExpense.SSP_Application__c = sspApplicationId;
                if(objExpense.SSP_Member__c != null && Schema.sObjectType.SSP_Asset__c.isAccessible() 
                   && Schema.sObjectType.SSP_Member__c.isAccessible()){ 
                       lstmember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND'}, 
                                                                      new Set<String>{'Id', 'HasShelterExpenseToggle__c',
                                                                          'HasUtilityExpenseToggle__c','HasMedicalExpensePartDToggle__c','HasDependentCareExpenseToggle__c',
                                                                          'HasTaxDeductionsExpenseToggle__c','HasAlimonyExpenseToggle__c','HaveHigherEducationExpenseToggle__c',
                                                                          'HasHouseholdPaidChildSupportToggle__c'}, 
                                                                      new Map<String, String>{'limit'=>'1','Id'=> objExpense.SSP_Member__c});
                       
                       if(!lstmember.isEmpty()){     
                           objMember = lstmember[0];
                           objMember = constructMemberData(lstmember[0], objExpense);
                           
                           ESAPI.accessController().updateAsUser(objMember, SSP_Utility.getFieldsNamesObject(objMember));
                           
                           
                       }
                   } 
                
                ESAPI.accessController().upsertAsUser(objExpense, SSP_Utility.getFieldsNamesObject(objExpense));
                
                
                sObjExpense = JSON.serialize(objExpense);
                
            }
            catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpenseController', 'setExpenseDetails', 'Failed to update Expense Details', true);        
                
            }
        }
        return sObjExpense;
        
    }
         /**
* method        : constructMemberData
* @description  : This method constructs member data to update 
* @author       : Kireeti Gora
* @returnType   : SSP_Member__c Object
* */  
    private static SSP_Member__c constructMemberData(SSP_Member__c objMember, SSP_Asset__c objExpense){
        
        if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.SHELTER_EXPENSE_TYPE) {
            objMember.HasShelterExpenseToggle__c =  'Y';
                                         
        } else if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.UTILITY_EXPENSE_TYPE) {
            objMember.HasUtilityExpenseToggle__c = 'Y';
        } else if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.EDUCATION_EXPENSE_TYPE) {
            objMember.HaveHigherEducationExpenseToggle__c  =  'Y';                      
        } else if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.MEDICAL_EXPENSE_TYPE) {
            objMember.HasMedicalExpensePartDToggle__c =  'Y';
        } else if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.CHILD_SUPPORT_EXPENSE_TYPE) {
            objMember.HasHouseholdPaidChildSupportToggle__c  = 'Y';
        } else if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.DEPENDENT_CARE_EXPENSE_TYPE) {
            objMember.HasDependentCareExpenseToggle__c = 'Y';
        } else if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.TAX_DEDUCTION_EXPENSE_TYPE) {
            objMember.HasTaxDeductionsExpenseToggle__c = 'Y';
            
        } else if (objExpense.ExpenseTypeCode__c == SSP_GlobalConstants.ALIMONY_EXPENSE_TYPE) {
            objMember.HasAlimonyExpenseToggle__c = 'Y'; 
            
        }
        return objMember;
    }
    
     /**
* method        : createRecords
* @description  : This method creates empty records for expense.
* @author       : Yathansh Sharma
* @param        : String sExpenseJSON - JSON String of Expense Details.
* @returnType   : Boolean
* */
    @AuraEnabled
    public static boolean createRecords(String dataJSON, Map<String, String> changedFieldsMap, Id sspApplicationId){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        Boolean returnStatus = true;
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(dataJSON);
        if(jsonMap.size() == 0){
            return returnStatus;
        }
       String quesListString = (String)jsonMap.get('sspMembers');
        List<Object> quesList = (List<Object>) JSON.deserializeUntyped(quesListString);
        
        String expenseRecordType = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Asset__c','Expense');
        List<SSP_Asset__c> assets = new list<SSP_Asset__c>();
        if(null!=changedFieldsMap && !changedFieldsMap.isEmpty()) 
            for(Object obj: quesList){
            Map<String, Object> mapRec = (Map<String, Object>) obj;
            
            boolean addToList = false;
            String sMember;
            for(String key: mapRec.keySet()){
                addToList=false;
                SSP_Asset__c asset = new SSP_Asset__c();
                asset.recordtypeId = expenseRecordType;
                if(key=='Id'){
                   sMember = (String) mapRec.get(key);
                }else{
                    if((Boolean)mapRec.get(key)==true && key!=HAS_MEDICAL_BILL_GATEPOST_QUESTION){
                        asset.SSP_Member__c = sMember;
                        asset.ExpenseTypeCode__c = fieldToTypeMap.get(key);
                        asset.ExpenseSubType__c = fieldToSubTypeMap.get(key);
                        asset.ssp_application__c = sspApplicationId;
                        addToList = true;
                    }
                }
                if(addToList){                   
                   assets.add(asset);
                }
            }
           
           
        }
        if(assets != null && !assets.isEmpty()){
            try{
                ESAPI.accessController().insertAsUser(assets, SSP_Utility.getFieldsNamesList (assets));
            }catch(exception e){
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_ExpenseController', 'createRecords', e.getMessage(), true);
                returnStatus = false;
            }
        }

        if(!SSP_ExpenseController.deleteRecords(changedFieldsMap)){
            returnStatus = false;
        }

        return returnStatus;
    }

    public static boolean deleteRecords(Map<String, String> changedFieldsMap){
        Boolean response = true;
        String trueToFalseString = changedFieldsMap.get('trueToFalse');
        
        Map<String, List<String>> parsedData;
        List<SSP_Asset__c> assetsList;
        Set<String> memberFieldstoUpdate = new Set<String>(); //Bug 376526: Perf: Replacing ESAPI update call
        if(trueToFalseString != null){
            parsedData = (Map<String, List<String>>) JSON.deserialize(trueToFalseString, Map<String, List<String>>.class);
            List<String> idsToJoin = new List<String>(parsedData.keySet());
            if(!idsToJoin.isEmpty())
            {
            assetsList = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND', 'IN'=>'SSP_Member__c'}, 
                                                                    new Set<String>{'Id', 'SSP_Member__c', 'ExpenseTypeCode__c', 'ExpenseSubType__c'}, 
                                                                    new Map<String, String>{'SSP_Member__c'=>String.join(idsToJoin, ','), 'RecordType.DeveloperName'=>'Expense', 'IsExistingData__c'=>'#false#'});
            } 
        }
        else{
            parsedData = new Map<String, List<String>>();
            assetsList = new List<SSP_Asset__c>();
        }

        List<SSP_Asset__c> assetsToDelete = new List<SSP_Asset__c>();

        for(SSP_asset__c asset: assetsList){
           
            
            if(parsedData.get(asset.SSP_Member__c) != null && 
            (
                parsedData.get(asset.SSP_Member__c).contains(SSP_ExpenseController.typeToFieldMap.get(asset.ExpenseTypeCode__c)) ||
                (parsedData.get(asset.SSP_Member__c).contains(SSP_ExpenseController.typeToFieldMap.get(asset.ExpenseTypeCode__c+'-'+asset.ExpenseSubType__c)))
            )
            ){
               
                asset.IsDeleted__c=true;
                assetsToDelete.add(asset);
            }
        }

        Map<ID,SSP_Member__c> memberMap = new Map<ID,SSP_Member__c>();
        for(String key: parsedData.keySet()){
            SSP_member__c member = new SSP_Member__c(id=key);
            List<String> fieldsToUpdate = parsedData.get(key);
            memberFieldstoUpdate.addAll(fieldsToUpdate); //Bug 376526: Perf: Replacing ESAPI update call
            if(null!=fieldsToUpdate && !fieldsToUpdate.isEmpty()){
                for(String field: fieldsToUpdate){
                    if(null!=field)
                    {                
                        member.put(field, 'N');
                    }
                }
                memberMap.put(key, member);
            }
        }

        if(changedFieldsMap.get('falseToTrue')!= null){
            parsedData = (Map<String, List<String>>) JSON.deserialize(changedFieldsMap.get('falseToTrue'), Map<String, List<String>>.class);
           for(String key: parsedData.keySet()){
                SSP_member__c member = (memberMap.get(key)!= null)?memberMap.get(key): new SSP_Member__c(id=key);
                List<String> fieldsToUpdate = parsedData.get(key);
                memberFieldstoUpdate.addAll(fieldsToUpdate); //Bug 376526: Perf: Replacing ESAPI update call
               if(null!=fieldsToUpdate && !fieldsToUpdate.isEmpty()){ 
                for(String field: fieldsToUpdate){
                      if(null!=field) {
                          member.put(field, 'Y');
                      }
                }
                memberMap.put(key, member);
               }
            }
        }

        Savepoint sp = Database.setSavepoint();
        try{
            if(assetsToDelete.size()>0){
                ESAPI.accessController().deleteAsUser(assetsToDelete);
            }
             if(memberMap.size()>0) {
            	//ESAPI.accessController().updateAsUser(memberMap, SSP_Utility.getFieldsNamesList (memberMap.values()));
                SSP_GenericDMLHelper.updateRecords(memberMap.values(),  new List<String>(memberFieldstoUpdate));
            }//Bug 376526: Perf: Replacing ESAPI update call
        }catch(exception e){
            response = false;
            Database.rollback(sp);
    }
        return response;
    }
    
    public static boolean validateBlankExpense(Id applicationId, Id memberId){
        Boolean validationSuccess = false;
        if(memberId == null){
            return validationSuccess;
        }
        List<SSP_Asset__c> assets = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                                    new Set<String>{'Id', 'SSP_Member__c', 'ExpenseTypeCode__c', 'ExpenseSubType__c', 'StartDate__c', 'ExpenseAmount__c'}, 
                                                                    new Map<String, String>{'SSP_Application__c'=>applicationId, 'SSP_Member__c'=>memberId, 'RecordType.DeveloperName'=>'Expense', 'IsExistingData__c'=>'#false#'});
        for(SSP_Asset__c asset: assets){
            if(asset.ExpenseTypeCode__c == 'EE' && asset.StartDate__c == null){
                validationSuccess = true;
                break;
            }
            if(asset.ExpenseTypeCode__c != 'EE' && asset.ExpenseAmount__c == null){
                validationSuccess = true;
                break;
            }
        }
        return validationSuccess;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicableExpensesBasedOnPrograms
    * @desc This method is used to get the applicable expense types based on programs
    * @param List<String> lstCurrentAppPrograms
    * @return List<String>
    * */
    public static List<String> getApplicableExpensesBasedOnPrograms(List<String> lstCurrentAppPrograms){
        Set<String> setExpenses = new Set<String>();
        try{
            for(String strExpenseValue : mapExpensesToPrograms.keySet()) {
                List<String> lstPrograms = mapExpensesToPrograms.get(strExpenseValue).split(',');
                if(SSP_Utility.checkApplicablePrograms(lstCurrentAppPrograms, new Set<String>(lstPrograms))){
                    setExpenses.add(strExpenseValue);
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ExpenseController', 'getApplicableExpensesBasedOnPrograms', e.getMessage(), true);
        }        
        return new List<String>(setExpenses);
    }
}
