/*
* classname     :  SSP_IncomeAndSubsidiesSelController
* @description  :  Controller Method for sspIncomeAndSubsidiesSelection LWC Components
* @author       :  Shrikant Raut   
* @date         :  11/21/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_IncomeAndSubsidiesSelController {

    //IncomeSelection_For_ExpenseSummary - IncomeSelection_IncomeSumary
    //IncomeSelection_For_OutOfStateBenefits - IncomeSelection_OutOfStateBenefits

    private static Set<String> memberRR_IncomeSummary_Positive;// = new Set<String>;
    private static Set<String> memberRR_BenefitsSummary_Positive;// = new Set<String>;
    private static Set<String> memberRR_IncomeSummary_Negative;// = new Set<String>;
    private static Set<String> memberRR_BenefitsSummary_Negative;// = new Set<String>;
    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/19/2019
    * @methodname   fetchIncomeSubsidiesDetails
    * @description  This methods is used to fetch Application Individual records 
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse fetchIncomeSubsidiesDetails(Id sspApplicationId, String sMode){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        String memberStatus = '';
        SSP_LightningResponse response = new SSP_LightningResponse();
        Set<String> additionalFieldsSet = new Set<String>{'IsTMember__c','SSP_Member__c','SSP_Member__r.Name','SSP_Member__r.DCId__c','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','SSP_Application__r.ProgramsApplied__c','SSP_Application__r.isReceivingHousingAssistanceToggle__c','SSP_Member__r.hasEarnedIncomeFromEmploymentToggle__c','SSP_Member__r.hasSelfEmploymentIncomeToggle__c','SSP_Member__r.hasUnEarnedIncomeToggle__c','SSP_Member__r.hasDividendsRoyaltiesToggle__c','SSP_Member__r.hasMaintenanceIncomeToggle__c','SSP_Member__r.hasInsuranceSettlementBenefitToggle__c','SSP_Member__r.hasServicesorPaymentsToggle__c','SSP_Member__r.hasUnpaidEmploymentToggle__c','SSP_Member__r.hasReceivedBenefitsFromOtherStateToggle__c'};
        try {
            // Added below condition for addRemoveMember flow
            if(String.isNotBlank(sMode) && SSP_GlobalConstants.MODE.equals(sMode)) {
                memberStatus = SSP_GlobalConstants.MEMBER_STATUS_New;                
            }
            List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, sspApplicationId, additionalFieldsSet, memberStatus);
            List<SSP_ApplicationIndividual__c> filteredAppIndividuals = new List<SSP_ApplicationIndividual__c>();
            for(SSP_ApplicationIndividual__c sspAppIndividual : lstAppIndividuals){
                if(!sspAppIndividual.IsTMember__c){
                    filteredAppIndividuals.add(sspAppIndividual);
                }
            }
            response.put('applicationIndividuals', filteredAppIndividuals);  
            response.put('memberDisabilityMatrix', constructMemberDisabilityMatrix(filteredAppIndividuals));            
            response.put('timeTravelCurrentMonth', SSP_Utility.monthToday());
            /** 2.5	Security Role Matrix and Program Access. */
            response.put('screenPermission', SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.INCOME_SELECTION_SCREENID, null).screenPermission);
            /** */

            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeAndSubsidiesSelController', 'fetchIncomeSubsidiesDetails', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);            
        }
        return response;
    }

    private static Map<String, Set<String>> constructMemberDisabilityMatrix (List<SSP_ApplicationIndividual__c> appIndvList){
        Map<String, Set<String>> resultMap = new Map<String, Set<String>>();
        Set<String> memberIdSet = new Set<String>();
        Map<String, String> incomeTypeToMemFieldAPI = new Map<String, String>{
            'DIR'=>'HasDividendsRoyaltiesToggle__c',
            'EA'=>'HasEarnedIncomeFromEmploymentToggle__c',
            'IS'=>'HasInsuranceSettlementBenefitToggle__c',
            'SM'=>'HasMaintenanceIncomeToggle__c',
            'SE'=>'HasSelfEmploymentIncomeToggle__c',
            'OUI'=>'HasServicesorPaymentsToggle__c',
            'SRP'=>'HasUnearnedIncomeToggle__c',
            'UI'=>'HasUnpaidEmploymentToggle__c'
        };

        if(appIndvList != null && !appIndvList.isEmpty()){
            for(SSP_ApplicationIndividual__c appIndv : appIndvList){
                if(appIndv != null && appIndv.SSP_Member__c != null){
                    memberIdSet.add(appIndv.SSP_Member__c);
                    resultMap.put(appIndv.SSP_Member__c, new Set<String>());
                }
            }
        }

        if(!memberIdSet.isEmpty()){
            for(SSP_Asset__c income : 
            SSP_AssetSelector.queryAssetData(
                new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND','IN'=>'SSP_Member__c'}, 
                new Set<String>{'Id','SSP_Member__c','IncomeTypeCode__c','SSP_Member__r.HasDividendsRoyaltiesToggle__c', 'SSP_Member__r.HasEarnedIncomeFromEmploymentToggle__c','SSP_Member__r.HasInsuranceSettlementBenefitToggle__c','SSP_Member__r.HasMaintenanceIncomeToggle__c', 'SSP_Member__r.HasSelfEmploymentIncomeToggle__c','SSP_Member__r.HasServicesorPaymentsToggle__c', 'SSP_Member__r.HasUnearnedIncomeToggle__c','SSP_Member__r.HasUnpaidEmploymentToggle__c', 'IsExistingData__c','EndDate__c'}, 
                new Map<String, String>{'IsExistingData__c'=>'#true#','RecordType.DeveloperName'=>'Income','SSP_Member__c'=> String.join(new List<String>(memberIdSet), ',')})){
                    if(income != null && income.IncomeTypeCode__c != null && incomeTypeToMemFieldAPI.containsKey(income.IncomeTypeCode__c) && ((income.IsExistingData__c && (income.EndDate__c>ssp_utility.today()|| income.EndDate__c==null) ) || (!income.IsExistingData__c))){
                        resultMap.get(income.SSP_Member__c).add(incomeTypeToMemFieldAPI.get(income.IncomeTypeCode__c) );
                    }
            }

            for(SSP_Benefits__c benefit : 
            SSP_BenefitsSelector.queryBenefitsData(
                new Map<String, String>{'objectName'=>'SSP_Benefits__c','operator'=>'AND','IN'=>'SSP_Member__c'}, 
                new Set<String>{'Id', 'SSP_Member__c','DCId__c'}, 
                new Map<String, String>{'SSP_Member__c'=>String.join(new List<String>(memberIdSet), ','),  'RecordType.DeveloperName'=>'OutOfStateBenefit'} )){                   
                    if(benefit != null && benefit.DCId__c != null){ 
                        resultMap.get(benefit.SSP_Member__c).add('HasReceivedBenefitsFromOtherStateToggle__c');
                    }
                }
        }
        return resultMap;

    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/19/2019
    * @methodname   updateExistingIncomeRecords
    * @description  This methods is used to update SSP_Asset__c records
    * @return       Boolean
    *****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse updateRecords(String dataJSON, Map<String,String> changedFieldsMap){
        SSP_LightningResponse response = new SSP_LightningResponse();
        response.bIsSuccess= true;
        Map<String, String> detailMap = new Map<String, String>();
        List<SSP_Member__c> memberList;
        List<SSP_Application__c> applicationList;             
        memberRR_IncomeSummary_Positive = new Set<String>();
        memberRR_BenefitsSummary_Positive = new Set<String>();
        memberRR_IncomeSummary_Negative = new Set<String>();
        memberRR_BenefitsSummary_Negative = new Set<String>();
        String recordTypeId = Schema.SObjectType.SSP_Asset__c.getRecordTypeInfosByDeveloperName().get('Income').getRecordTypeId();
        String benefitsRecordTypeId = Schema.SObjectType.SSP_Benefits__c.getRecordTypeInfosByDeveloperName().get('OutOfStateBenefit').getRecordTypeId();
        Map<String, SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper> IncomeAndSubsidiesWrapperMap = new Map<String, SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper> {
                'HasDividendsRoyaltiesToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'DIR','RecordTypeId'=>recordTypeId}, 1),
                'HasEarnedIncomeFromEmploymentToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'EA','RecordTypeId'=>recordTypeId}, 1),
                'HasInsuranceSettlementBenefitToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'IS','RecordTypeId'=>recordTypeId}, 1),
                'HasMaintenanceIncomeToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'SM','RecordTypeId'=>recordTypeId}, 1),
                'HasReceivedBenefitsFromOtherStateToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Benefits__c', new Map<String, String>{'RecordTypeId'=>benefitsRecordTypeId}, 1),
                'HasSelfEmploymentIncomeToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'SE','RecordTypeId'=>recordTypeId}, 1),
                'HasServicesorPaymentsToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'OUI','RecordTypeId'=>recordTypeId}, 1),
                'HasUnearnedIncomeToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'SRP','RecordTypeId'=>recordTypeId}, 1),
                'HasUnpaidEmploymentToggle__c'=>new SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper('SSP_Asset__c', new Map<String, String>{'IncomeTypeCode__c'=>'UI','RecordTypeId'=>recordTypeId}, 1)
            };
        if(dataJSON != null && Schema.sObjectType.SSP_Member__c.isUpdateable() && Schema.sObjectType.SSP_Application__c.isUpdateable() && Schema.sObjectType.SSP_Asset__c.isCreateable()){
            try{
                detailMap = (Map<String, String>)JSON.deserialize(dataJSON, Map<String, String>.class);    
                for(String key : detailMap.keySet() ){
                    if(key.equalsIgnoreCase('SSP_Member__c')){
                        memberList = (List<SSP_Member__c>)JSON.deserialize(detailMap.get(key), List<SSP_Member__c>.class);
                         
                    }
                    else if(key.equalsIgnoreCase('SSP_Application__c')){
                        applicationList = (List<SSP_Application__c>)JSON.deserialize(detailMap.get(key), List<SSP_Application__c>.class);
                    }
                }
                
                Set<String> setAccessFields = new Set<String>();
                if(memberList != null  && !memberList.isEmpty()){
                    for(SSP_Member__c sspMemberRecord : memberList){                    
                        setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspMemberRecord));
                    }
                    //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Member__c>(memberList), new List<String>(setAccessFields));
                    //Perf Fix: 08/29 :SV
                    SSP_GenericDMLHelper.updateRecords(memberList,  new List<String>(setAccessFields));

                }
                if(applicationList != null && !applicationList.isEmpty()){
                     //ESAPI.accessController().updateAsUser(new Map<ID,SSP_Application__c>(applicationList), SSP_Utility.getFieldsNamesList (applicationList));
                     //Perf Fix: 08/29 :SV
                     SSP_GenericDMLHelper.updateRecords(applicationList,  SSP_Utility.getFieldsNamesList (applicationList));
                
                }
                handleRecCreation(changedFieldsMap.get('falseToTrue'), IncomeAndSubsidiesWrapperMap);
                handleRecDeletion(changedFieldsMap.get('trueToFalse'), IncomeAndSubsidiesWrapperMap);
                response.put('reviewRequiredParams',constructRRList());
               
            }
            catch(Exception ex){                
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_IncomeAndSubsidiesSelController', 'updateRecords', ex.getMessage(), true);
                response.addException(ex, lstLogMessages[0].Id); 
            }
        }

        return response;
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         03/13/2020
    * @methodname   constructRRList
    * @description  Method to construct a list to handle review required scenario
    * @return       void
    *****************************************************************************************************/
    private static List<String> constructRRList (){
        List<String> reviewRequiredList = new List<String>();    
        if(memberRR_IncomeSummary_Positive != null && !memberRR_IncomeSummary_Positive.isEmpty() ){
            reviewRequiredList.add('IncomeSelection_IncomeSummary,'+true+','+String.join((Iterable<String>)memberRR_IncomeSummary_Positive,','));
        }
        if(memberRR_BenefitsSummary_Positive != null && !memberRR_BenefitsSummary_Positive.isEmpty()){
            reviewRequiredList.add('IncomeSelection_OutOfStateBenefits,'+true+','+String.join((Iterable<String>)memberRR_BenefitsSummary_Positive,','));
        }
        if(memberRR_BenefitsSummary_Negative != null && !memberRR_BenefitsSummary_Negative.isEmpty()){  
            reviewRequiredList.add('IncomeSelection_OutOfStateBenefits,'+false+','+String.join((Iterable<String>)memberRR_BenefitsSummary_Negative,','));
        }
        return reviewRequiredList;
    }

     

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/25/2019
    * @methodname   handleRecCreation
    * @description  This methods is used to handle record creation based on selections on Income&SubsidiesSelection screen
    * @return       void
    *****************************************************************************************************/
    private static void  handleRecCreation(String changedFieldsJSON, Map<String, SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper> IncomeAndSubsidiesWrapperMap){
        List<SSP_Asset__c> assetList = new List<SSP_Asset__c>();
        List<SSP_Benefits__c> benefitsList = new List<SSP_Benefits__c>();
        Map<String, List<String>> changedFieldsMap = new Map<String, List<String>>();         
        if(changedFieldsJSON != null){
            changedFieldsMap = (Map<String, List<String>>)JSON.deserialize(changedFieldsJSON, Map<String, List<String>>.class);
            for(String memberId : changedFieldsMap.keySet()){
                if(changedFieldsMap.get(memberId) != null && !(changedFieldsMap.get(memberId)).isEmpty()){
                    for(String fieldAPI : changedFieldsMap.get(memberId)){
                        if(IncomeAndSubsidiesWrapperMap.containsKey(fieldAPI)){
                            SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper tmpWrapper = IncomeAndSubsidiesWrapperMap.get(fieldAPI);                            
                            String objAPI = tmpWrapper.objAPI;

                            for(Integer i=0 ; i < tmpWrapper.noOfRecords; i++){
                                SObject sObj = Schema.getGlobalDescribe().get(objAPI).newSObject() ;
                                for(String fAPI : tmpWrapper.sObjDetails.keySet()){
                                    sObj.put(fAPI, tmpWrapper.sObjDetails.get(fAPI));
                                }
                                sObj.put('SSP_Member__c', memberId);
                                if(objAPI.equalsIgnoreCase('SSP_Asset__c')){
                                    assetList.add((SSP_Asset__c)sObj);
                                    memberRR_IncomeSummary_Positive.add(memberId);
                                }
                                if(objAPI.equalsIgnoreCase('SSP_Benefits__c')){
                                    benefitsList.add((SSP_Benefits__c)sObj);
                                    memberRR_BenefitsSummary_Positive.add(memberId);
                                }
                            }                            
                         }
                    }
                }
            }
        }
        if(assetList != null && !assetList.isEmpty()){
            ESAPI.accessController().insertAsUser(assetList, SSP_Utility.getFieldsNamesList (assetList));
        }
        if(benefitsList != null && !benefitsList.isEmpty()){
            ESAPI.accessController().insertAsUser(benefitsList, SSP_Utility.getFieldsNamesList (benefitsList));
        }
    }


     /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/27/2019
    * @methodname   handleRecDeletion
    * @description  This methods is used to handle deletion of records when correspinding field value is changed from true to false 
    * @return       void
    *****************************************************************************************************/
    private static void  handleRecDeletion(String changedFieldsJSON, Map<String, SSP_IncomeAndSubsidiesSelController.IncomeAndSubsidiesWrapper> IncomeAndSubsidiesWrapperMap){
        Map<String, List<String>> changedFieldsMap = new Map<String, List<String>>(); 
        List<SSP_Asset__c> assetList = new List<SSP_Asset__c>();
        List<SSP_Benefits__c> benefitsList = new List<SSP_Benefits__c>();
        if(changedFieldsJSON != null){  
            changedFieldsMap = (Map<String, List<String>>)JSON.deserialize(changedFieldsJSON, Map<String, List<String>>.class);
            assetList.addAll(fetchAssetsToBeDeleted(changedFieldsMap));
            benefitsList.addAll(fetchBenefitsToBeDeleted(changedFieldsMap));
        }

        if(assetList != null && !assetList.isEmpty()){
                ESAPI.accessController().deleteAsUser(assetList);
        }
        if(benefitsList != null && !benefitsList.isEmpty()){
                ESAPI.accessController().deleteAsUser(benefitsList);
        }
    }

     /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/27/2019
    * @methodname   fetchAssetsToBeDeleted
    * @description  This methods is used to fetch asset records that should be deleted due to changes in selection in IncomeSubsidies selection scereen
    * @return       List<SObject> to be deleted
    *****************************************************************************************************/
    private static Set<SSP_Asset__c> fetchAssetsToBeDeleted(Map<String, List<String>> changedFieldsMap){
        Set<SSP_Asset__c> assetsToBeDeleted = new Set<SSP_Asset__c>();
        String csvMemberList = '';        
        Map<String, String> incomeTypeToMemFieldAPI = new Map<String, String>{
            'DIR'=>'HasDividendsRoyaltiesToggle__c',
            'EA'=>'HasEarnedIncomeFromEmploymentToggle__c',
            'IS'=>'HasInsuranceSettlementBenefitToggle__c',
            'SM'=>'HasMaintenanceIncomeToggle__c',
            'SE'=>'HasSelfEmploymentIncomeToggle__c',
            'OUI'=>'HasServicesorPaymentsToggle__c',
            'SRP'=>'HasUnearnedIncomeToggle__c',
            'UI'=>'HasUnpaidEmploymentToggle__c'
        };
        for(Id memberId : changedFieldsMap.keySet()){
            csvMemberList += memberId + ',';
        }
        csvMemberList = (csvMemberList.length()>0) ? csvMemberList.removeEnd(',') : csvMemberList;
        for(SSP_Asset__c asset :
        SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND','IN'=>'SSP_Member__c'}, 
                                        new Set<String>{'Id', 'IsExistingData__c',  'IncomeTypeCode__c', 'SSP_Member__c'},
                                        new Map<String, String>{'SSP_Member__c'=>csvMemberList, 'IsExistingData__c' => '#false#', 'RecordType.DeveloperName'=>'Income'} )
        
         ){
             String memFieldAPI = incomeTypeToMemFieldAPI.containsKey(asset.IncomeTypeCode__c) ? incomeTypeToMemFieldAPI.get(asset.IncomeTypeCode__c) : null;
            
            if(memFieldAPI != null && changedFieldsMap.containsKey(asset.SSP_Member__c) && (changedFieldsMap.get(asset.SSP_Member__c)).contains(memFieldAPI)){
                SSP_Asset__c tmpAsset = new SSP_Asset__c(Id = asset.Id);
                assetsToBeDeleted.add(tmpAsset);
                if(!memberRR_IncomeSummary_Positive.contains(asset.SSP_Member__c)){ 
                    memberRR_IncomeSummary_Negative.add(asset.SSP_Member__c);   
                } 
            } 
        }
        return assetsToBeDeleted;
    }

     /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         11/27/2019
    * @methodname   fetchBenefitsToBeDeleted
    * @description  This methods is used to fetch benefits records that should be deleted due to changes in selection in IncomeSubsidies selection scereen
    * @return       List<SObject> to be deleted
    *****************************************************************************************************/
    private static Set<SSP_Benefits__c> fetchBenefitsToBeDeleted(Map<String, List<String>> changedFieldsMap){
        Set<SSP_Benefits__c> benefitsToBeDeleted = new Set<SSP_Benefits__c>();
        String csvMemberList = '';
        for(Id memberId : changedFieldsMap.keySet()){
            csvMemberList += memberId + ',';
        }
        csvMemberList = (csvMemberList.length()>0) ? csvMemberList.removeEnd(',') : csvMemberList;
        for(SSP_Benefits__c benefit : SSP_BenefitsSelector.queryBenefitsData(new Map<String, String>{'objectName'=>'SSP_Benefits__c','operator'=>'AND','IN'=>'SSP_Member__c'}, 
                                        new Set<String>{'Id', 'SSP_Member__c'}, 
                                        new Map<String, String>{'SSP_Member__c'=>csvMemberList,  'RecordType.DeveloperName'=>'OutOfStateBenefit'} )){
                                            SSP_Benefits__c tmpBenefits = new SSP_Benefits__c(Id  = benefit.Id);
                benefitsToBeDeleted.add(tmpBenefits);   
                if(!memberRR_BenefitsSummary_Positive.contains(benefit.SSP_Member__c)){ 
                    memberRR_BenefitsSummary_Negative.add(benefit.SSP_Member__c);
                }
        }
        return benefitsToBeDeleted;
    }

    class IncomeAndSubsidiesWrapper{
        public Integer noOfRecords;
        public Map<String, String> sObjDetails;   
        public String objAPI;    
        public IncomeAndSubsidiesWrapper(String objAPI, Map<String, String> sObjDetails, Integer noOfRecords){
            this.sObjDetails = sObjDetails;
            this.objAPI = objAPI;
            this.noOfRecords = noOfRecords;
        }
    }
}