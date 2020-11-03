/*
* classname     :  SSP_AssetTrigger_Handler
* @description  :  This class contains all the handler methods for asset trigger.
* @author       :  Yathansh Sharma   
* @date         :  12/06/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
  Yathansh Sharma               12/06/2019                          Created.
**/
public class SSP_AssetTrigger_Handler implements SSP_ITriggerHandler {
    public static String incomeRecordTypeId;
    public static String expenseRecordTypeId;
    public static String resourceRecordTypeId;
    public Map<String, String> recordFieldMapping;

    public SSP_AssetTrigger_Handler(){
        incomeRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Asset__c','Income');      
        expenseRecordTypeId= SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Asset__c','Expense');
        resourceRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
        recordFieldMapping = new Map<String, String>{
            expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_Alimony=>SSP_GlobalConstants.HAS_ALIMONY_EXPENSE,
            expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_ChildSupport=>SSP_GlobalConstants.HAS_HOUSEHOLD_PAID_CHILD_SUPPORT,
            expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_DependentCare=>SSP_GlobalConstants.HAS_DEPENDENT_CARE_EXPENSE,
          // expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_Medical=>SSP_GlobalConstants.HAS_MEDICAL_BILLS,
             expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_Medical=> 'HasDisabledExpensesToggle__c',
	    expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_Shelter=>SSP_GlobalConstants.HAS_SHELTER_EXPENSE,
            expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_TaxDeductions=>SSP_GlobalConstants.HAS_TAX_DEDUCTION_EXPENSE,
            expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_UtilityExpense=>SSP_GlobalConstants.HAS_UTILITY_EXPENSE,
            expenseRecordTypeId + '-' +System.label.SSP_ExpenseTypeAPI_EducationExpense=>SSP_GlobalConstants.HAVE_HIGHER_EDUCATION_EXPENSE,

            incomeRecordTypeId+'-DIR'=> 'HasDividendsRoyaltiesToggle__c',
            incomeRecordTypeId+'-IS'=> 'HasInsuranceSettlementBenefitToggle__c',
            incomeRecordTypeId+'-EA'=> 'HasEarnedIncomeFromEmploymentToggle__c',
            incomeRecordTypeId+'-OUI'=> 'HasServicesorPaymentsToggle__c',
            incomeRecordTypeId+'-SE'=> 'HasSelfEmploymentIncomeToggle__c',
            incomeRecordTypeId+'-SRP'=> 'HasUnearnedIncomeToggle__c',
            incomeRecordTypeId+'-SM'=> 'HasMaintenanceIncomeToggle__c',
            incomeRecordTypeId+'-DIR'=> 'HasDividendsRoyaltiesToggle__c',
            incomeRecordTypeId+'-UI'=> 'HasUnpaidEmploymentToggle__c'
        };

    } 
    
    public Boolean IsDisabled()
    {
        return false;
    }
    
    public void BeforeInsert(List<SObject> newItems) {}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         12/06/2019
     * @methodname   AfterInsert
     * @description  This method takes a map of id to sObject and uses it to check mapped fields in parent member record if atleast one record of given type exists.
     * @return       void
     *****************************************************************************************************/
    public void AfterInsert(Map<Id, SObject> newItems) {
        list<SSP_Asset__c> newList = newItems.values();
        List<Id> memberIdList = new List<Id>();
        memberIdList.addAll(getMemberIdSet(newList));
		Set<String> memberFieldstoUpdate = new Set<String>(); //Bug 376526: Perf: Replacing ESAPI update call


        if(memberIdList != null && !memberIdList.isEmpty()){
            try{
                List<SSP_Member__c> memberListToBeUpdated = new List<SSP_Member__c>();
                Map<Id, SSP_Member__c> memberMap = new Map<Id, SSP_Member__c>(SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND','IN'=>'Id'}, 
                                                                        new Set<String>{'Id','HasDividendsRoyaltiesToggle__c',
                                                                            'HasInsuranceSettlementBenefitToggle__c',
                                                                            'HasEarnedIncomeFromEmploymentToggle__c',
                                                                            'HasServicesorPaymentsToggle__c',
                                                                            'HasSelfEmploymentIncomeToggle__c',
                                                                            'HasUnearnedIncomeToggle__c',
                                                                            'HasMaintenanceIncomeToggle__c',
                                                                            'HasDividendsRoyaltiesToggle__c',
                                                                            'HasUnpaidEmploymentToggle__c',
                                                                            'HasAlimonyExpenseToggle__c',
                                                                            'HasHouseholdPaidChildSupportToggle__c',
                                                                            'HasDependentCareExpenseToggle__c',
                                                                          //  'HasMedicalBillsToggle__c',
                                                                            'HasShelterExpenseToggle__c',
                                                                            'HasTaxDeductionsExpenseToggle__c',
                                                                            'HasUtilityExpenseToggle__c',
                                                                            'HaveHigherEducationExpenseToggle__c'}, 
                                                                        new Map<String, String>{'limit'=>'1000', 'Id'=> String.join(new List<Id>(memberIdList), ',')}));

                Map<String, SSP_Member__c> mapAssetMembers = new Map<String, SSP_Member__c>();
                for(SSP_Asset__c asset: newList){
                    String recordFieldKey = asset.RecordTypeId+'-'+ ((asset.RecordTypeId).equals(incomeRecordTypeId) ? asset.IncomeTypeCode__c : ((asset.RecordTypeId).equals(expenseRecordTypeId) ? asset.ExpenseTypeCode__c : ''));
                   if(asset.SSP_Member__c != null && !asset.IsExistingData__c && memberMap.containskey(asset.SSP_Member__c) && recordFieldMapping.containsKey(recordFieldKey) && memberMap != null && memberMap.containsKey(asset.SSP_Member__c)){
                        
                        SSP_Member__c tmpMember = memberMap.get(asset.SSP_Member__c);
                        String tmpFieldAPI = recordFieldMapping.get(recordFieldKey);
                       memberFieldstoUpdate.add(tmpFieldAPI); //Bug 376526: Perf: Replacing ESAPI update call
                        if(mapAssetMembers.get(tmpMember.ID) != NULL){
                            mapAssetMembers.get(tmpMember.ID).put(tmpFieldAPI, 'Y');
                        }else{
                            tmpMember.put(tmpFieldAPI, 'Y');
                            mapAssetMembers.put(tmpMember.ID, tmpMember);
                        }
                        //SSP_Member__c tmpMember = memberMap.get(asset.SSP_Member__c);

                        //memberListToBeUpdated.add(tmpMember);                        
                    }
                }
                memberListToBeUpdated = mapAssetMembers.values();
            
                
                if(memberListToBeUpdated != null && !memberListToBeUpdated.isEmpty()){
                    //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Member__c>(memberListToBeUpdated), SSP_Utility.getFieldsNamesList (memberListToBeUpdated));
                    SSP_GenericDMLHelper.updateRecords(memberListToBeUpdated,  new List<String>(memberFieldstoUpdate));//Bug 376526: Perf: Replacing ESAPI update call
                }
            }catch(exception e){
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AssetTrigger_Handler', 'AfterInsert', e.getMessage(), true);
            }
        }
    }
    
    /***************************************************************************************************
     * @author       Karthik Gulla
     * @date         12/06/2019
     * @methodname   AfterUpdate
     * @description  This method takes a map of id to sObject and uses it to check mapped fields in parent member record if atleast one record of given type exists.
     * @return       void
     *****************************************************************************************************/
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        SSP_AssetTrigger_Handler.trackDeletedRecordsForAsset(newItems, oldItems);
    }
    
    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         12/06/2019
     * @methodname   AfterDelete
     * @description  This method takes a map of id to sObject and uses it to un-check mapped fields in parent member record if the last record of given type exists is deleted.
     * @return       void
     *****************************************************************************************************/
    public void AfterDelete(Map<Id, SObject> oldItems) {
        list<SSP_Asset__c> oldList = oldItems.values();
        Date d = ssp_utility.today();
        Map<String, String> typeToFieldMapping= recordFieldMapping;
        Set<Id> memberIds = new Set<Id>();
        for(SSP_Asset__c asset: oldList){
            if(asset.RecordTypeId == incomeRecordTypeId || asset.RecordTypeId == expenseRecordTypeId){
                memberIds.add(asset.SSP_Member__c);
            }
        }
        List<Id> memberList = new List<Id>();
        memberList.addAll(memberIds);
       try{
            List<SSP_member__c> countGroup = Database.query('Select id,HasMedicalExpensePartDToggle__c, '+String.join(recordFieldMapping.values(), ', ')+ 
                                                            ', (Select id, IncomeTypeCode__c, ExpenseSubType__c,ExpenseTypeCode__c ,RecordTypeId from SSP_Assets__r where (IncomeTypeCode__c != null OR ExpenseTypeCode__c != null) and ((IsExistingData__c=true and (EndDate__C >:d  or EndDate__c = null)) or (IsExistingData__c=false)) ) From SSP_Member__c where id in(\''+String.join(memberList, '\', \'')+ '\')');
           
            
            for(SSP_member__c member: countGroup){
            Map<String, Integer> memberCountMap = new Map<String, Integer>();
            Map<String,String>  questionVisibleMap = new  Map<String,String> ();
            memberCountMap.put(expenseRecordTypeId+'MP' +'-'+System.label.SSP_ExpenseTypeAPI_Medical,0);
            sObject obj = member;
            questionVisibleMap.put(expenseRecordTypeId+'MP' +'-'+System.label.SSP_ExpenseTypeAPI_Medical,String.valueOf(obj.get('HasMedicalExpensePartDToggle__c')));
            
            for(String key: recordFieldMapping.keySet()){
                    memberCountMap.put(key, 0);
                    questionVisibleMap.put(key, String.valueOf(obj.get(recordFieldMapping.get(key))));
                    
            }
                
                for(SSP_Asset__c asset: member.SSP_Assets__r){
                    String recordFieldKey = asset.RecordTypeId+'-'+ ((asset.RecordTypeId).equals(incomeRecordTypeId) ? asset.IncomeTypeCode__c : ((asset.RecordTypeId).equals(expenseRecordTypeId) ? asset.ExpenseTypeCode__c : ''));
                     Integer count =memberCountMap.get(recordFieldKey);                  
                    
                    if((asset.RecordTypeId).equals(expenseRecordTypeId) && recordFieldKey.equals(expenseRecordTypeId +'-'+System.label.SSP_ExpenseTypeAPI_Medical)  && asset.ExpenseSubType__c!=null &&asset.ExpenseSubType__c=='MP' ){
                       recordFieldKey= expenseRecordTypeId+'MP' +'-'+System.label.SSP_ExpenseTypeAPI_Medical;
                        count= memberCountMap.get(recordFieldKey);
                    }
                    count++;                   
                    memberCountMap.put(recordFieldKey, count);
                    
                }
                
                typeToFieldMapping.put(expenseRecordTypeId+'MP' +'-'+System.label.SSP_ExpenseTypeAPI_Medical,'HasMedicalExpensePartDToggle__c');
                
                for(String key: memberCountMap.keySet()){
                    if(memberCountMap.get(key) == 0){
		             if(questionVisibleMap.get(key)!=null) {
                      member.put(typeToFieldMapping.get(key), 'N');
                     }
                    }
                }
            }
       
       if(null!=typeToFieldMapping.values() && typeToFieldMapping.values().size()>0 && countGroup.size()>0){
            //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Member__c>(countGroup), typeToFieldMapping.values());
            SSP_GenericDMLHelper.updateRecords(countGroup,  typeToFieldMapping.values());//Bug 376526: Perf: Replacing ESAPI update call
       }
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AssetTrigger_Handler', 'AfterDelete', e.getMessage(), true);
        }
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}


    /***************************************************************************************************
     * @author       Shrikant Raut
     * @date         12/11/2019
     * @methodname   getMemberIdSet
     * @description  Construct a set Id from List of SSP_Asset__c
     * @return       Set<Id>
     *****************************************************************************************************/
    private set<Id> getMemberIdSet(List<SSP_Asset__c> assetList){
        Set<Id> memberIdSet = new Set<Id>();
        if(assetList != null && !assetList.isEmpty()){
            for(SSP_Asset__c asset : assetList){
                if(asset.SSP_Member__c != null){
                    memberIdSet.add(asset.SSP_Member__c);
                }
            }
        }
        return memberIdSet;
    }

 /***************************************************************************************************
     * @author       Karthik Gulla
     * @date         12/06/2019
     * @methodname   trackDeletedRecordsForAsset
     * @description  This method insert deleted records to Track deletion object
     * @return       void
     *****************************************************************************************************/
    public static void trackDeletedRecordsForAsset(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        try{
            Set<Id> setRecordTypes = new Set<Id>();
            setRecordTypes.add(incomeRecordTypeId);
            setRecordTypes.add(expenseRecordTypeId);
            setRecordTypes.add(resourceRecordTypeId);

            List<SSP_TrackDeletion__c> lstTrackDeletionRecords = new List<SSP_TrackDeletion__c>();        
            for(SSP_Asset__c sspAssetRecord : (List<SSP_Asset__c>)newItems.values()){
                Id uAssetId = sspAssetRecord.Id;
                SSP_Asset__c sspOldAssetRecord = (SSP_Asset__c)oldItems.get(sspAssetRecord.Id);
                if(((sspOldAssetRecord.EndDate__c == null && sspAssetRecord.EndDate__c != null)
                    || (sspAssetRecord.ResourceTypeCode__c != null && sspAssetRecord.ResourceTypeCode__c == SSP_GlobalConstants.FUNERALCONTRACTRESOURCETYPE && sspAssetRecord.EndDate__c == null))
                   && !sspOldAssetRecord.IsDeleted__c && sspAssetRecord.IsDeleted__c
                   && setRecordTypes.contains(sspAssetRecord.RecordTypeId)){
                    SSP_TrackDeletion__c sspTrackDelRecord = new SSP_TrackDeletion__c();
                    sspTrackDelRecord.DCId__c = sspAssetRecord.DCId__c;
                    sspTrackDelRecord.EndDate__c = Date.valueOf(sspAssetRecord.EndDate__c);
                    if(resourceRecordTypeId == sspAssetRecord.RecordTypeId){
                        sspTrackDelRecord.EndReason__c = sspAssetRecord.ResourceEndReason__c;
                        sspTrackDelRecord.Source__c = 'Resources'; 
                    } else if (incomeRecordTypeId == sspAssetRecord.RecordTypeId){
                         sspTrackDelRecord.EndReason__c = SSP_IncomeService.getIEESPicklistKeyForIncome('Income',sspAssetRecord.IncomeTypeCode__c,sspAssetRecord.EmploymentEndReason__c);
                         sspTrackDelRecord.Source__c = 'Income';
                    } else if (expenseRecordTypeId == sspAssetRecord.RecordTypeId){
                         sspTrackDelRecord.Source__c = 'Expenses';
                    }
                    sspTrackDelRecord.SFObject__c='SSP_Asset__c';
                    sspTrackDelRecord.SalesforceId__c = uAssetId;                
                    sspTrackDelRecord.SSP_Application__c = sspAssetRecord.SSP_Application__c;
                    sspTrackDelRecord.SSP_Member__c = Id.valueOf(sspAssetRecord.SSP_Member__c);
                    lstTrackDeletionRecords.add(sspTrackDelRecord);
                } 
            }
            if(!lstTrackDeletionRecords.isEmpty()){
                ESAPI.accessController().insertAsUser(lstTrackDeletionRecords, SSP_Utility.getFieldsNamesList(lstTrackDeletionRecords));
            }
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AssetTrigger_Handler', 'AfterUpdate', e.getMessage(), true);
        }
    }
}
