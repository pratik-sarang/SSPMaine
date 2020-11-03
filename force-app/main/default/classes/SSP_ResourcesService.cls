/**
* @author: Karthik Gulla
* @Class Name: SSP_ResourcesService
* @desc This class is used to provide the functionalities related to Resources
* @Date 11-15-2019
MODIFICATION LOG :
* */ 
public with sharing class SSP_ResourcesService {
    public static final Id RESOURCERECORDTYPE = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
    public static Map<String,SSP_ResourceMappings__mdt> mapResourceTypeMappings;

    /**
    * @author: Karthik Gulla
    * @method: getLifeInsuranceResourcesForMember
    * @desc This method is used to get Life Insurance Resources for a particular Member
    * @param {Set<Id> setMemberIds}
    * @return List<SSP_Asset__c>
    * */
    public static List<SSP_Asset__c> getLifeInsuranceResourcesForMember(Set<Id> setMemberIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        try{            
            mapConditions.put('SSP_Member__c',String.join(new List<Id>(setMemberIds), ','));
            mapConditions.put('RecordTypeId', RESOURCERECORDTYPE);
            mapConditions.put('ResourceTypeCode__c', 'LI');
            mapConditions.put('IsDeleted__c', String.valueOf(false));
            lstAssets = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','IN'=>'SSP_Member__c','operator'=>'AND'}, 
                                                                new Set<String>{'Id','PolicyNumber__c'}, 
                                                                mapConditions);
                                
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getLifeInsuranceResourcesForMember', e.getMessage(), true);
        }
        return lstAssets;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesForMember
    * @desc This method is used to get Resources for a particular Member
    * @param {Set<Id> setMemberIds, Boolean bExistingData}
    * @return List<SSP_Asset__c>
    * */
    public static List<SSP_Asset__c> getResourcesForMember(Set<Id> setMemberIds, Boolean bExistingData, List<String> lstResourceTypes){
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        Map<String,String> mapConditions = new Map<String,String>();
        Map<String,String> mapQueryDetails = new Map<String,String>();
        try{            
            mapConditions.put('SSP_Member__c',String.join(new List<Id>(setMemberIds), ','));
            mapConditions.put('RecordTypeId', RESOURCERECORDTYPE);
            mapConditions.put('IsExistingData__c',  String.valueOf(bExistingData));
            mapConditions.put('IsDeleted__c', String.valueOf(false));
            mapQueryDetails.put('hasToLabel','true');
            mapQueryDetails.put('objectName','SSP_Asset__c');
            mapQueryDetails.put('IN','SSP_Member__c');
            if(!lstResourceTypes.isEmpty()) {           
                mapConditions.put('ResourceTypeCode__c',String.join(lstResourceTypes, ','));
                mapQueryDetails.put('IN','ResourceTypeCode__c');
            }
            mapQueryDetails.put('operator','AND');
            lstAssets = SSP_AssetSelector.queryAssetData(mapQueryDetails, new Set<String>{'Id','RecordTypeId','IsDeleted__c','InsurancePolicyAsset__c','FuneralLocation__c','Location__c','ResourceTypeCode__c','IsExistingData__c','FuneralFundCode__c','HasItemizedStmtOfGoodsSignByClientToggle__c','VehicleCategoryCode__c','HasAccessToVehicleToggle__c','StartDate__c','SSP_Member__c',
                                                                'AccountBalance__c','IsThereAnotherOwnerToggle__c','FaceValueAmount__c','LoanBalance__c','RealEstateFairMarketValue__c','PreFuneralAgmtGoodsAndServicesCost__c','ResourceSubTypeCode__c','IsIndividualAbleToRideToggle__c','NoAccessReason__c','ResourceEndReason__c','IsIncomeEssentialToSelfSupportToggle__c',
                                                                'VehicleFairMarketValue__c','NotEnoughInformation__c','Make__c','Model__c','ModelYear__c','toLabel(ResourceSubTypeCode__c) RSubtype','toLabel(ResourceTypeCode__c) Rtype','IsHomeHomesteadPropertyToggle__c','VehicleUseReason__c','VehicleDebt__c','PrimaryUserIndividual__c','PrimaryUserIfOther__c',
                                                                'InsuranceCompanyName__c','PolicyNumber__c','CashSurrenderValue__c','InsuranceCompanyAddress__c','InsuranceCompanyPhoneNumber__c','LoanBalance__c','IsPolicyDesignatedToPayBurialToggle__c','IsPolicyUsedForPrearrangedFuneralToggle__c','IsIncomeProducingPropertyToggle__c','HasPolicyAssignedToFuneralHomeToggle__c'}, 
                                                                mapConditions);
                                
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourcesForMember', e.getMessage(), true);
        }
        return lstAssets;
    }

    /**
    * @author: Keshav Poduval
    * @method: getResourcesForMember
    * @desc This method is used to get Resources for a particular Member. Added this as part of Perf fix
    * @param {Set<Id> setMemberIds}
    * @return Map<Boolean,List<SSP_Asset__c>>
    * */
    public static Map<Boolean,List<SSP_Asset__c>> getResourcesForMember(Set<Id> setMemberIds, List<String> lstResourceTypes){
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        Map<String,String> mapConditions = new Map<String,String>();
        Map<Boolean,List<SSP_Asset__c>> mapBooleanToAssets = new Map<Boolean,List<SSP_Asset__c>>();
        Map<String,String> mapQueryDetails = new Map<String,String>();
        try{            
            mapConditions.put('SSP_Member__c',String.join(new List<Id>(setMemberIds), ','));
            mapConditions.put('ResourceTypeCode__c',String.join(lstResourceTypes, ','));
            mapConditions.put('RecordTypeId', RESOURCERECORDTYPE);
            mapConditions.put('IsDeleted__c', String.valueOf(false));
            mapQueryDetails.put('hasToLabel','true');
            mapQueryDetails.put('objectName','SSP_Asset__c');
            mapQueryDetails.put('IN','SSP_Member__c');
            if(!lstResourceTypes.isEmpty()) {           
                mapConditions.put('ResourceTypeCode__c',String.join(lstResourceTypes, ','));
                mapQueryDetails.put('IN','ResourceTypeCode__c');
            }
            mapQueryDetails.put('operator','AND');
            lstAssets = SSP_AssetSelector.queryAssetData(mapQueryDetails,new Set<String>{'Id','RecordTypeId','IsDeleted__c','InsurancePolicyAsset__c','FuneralLocation__c','Location__c','ResourceTypeCode__c','IsExistingData__c','FuneralFundCode__c','HasItemizedStmtOfGoodsSignByClientToggle__c','VehicleCategoryCode__c','HasAccessToVehicleToggle__c','StartDate__c','SSP_Member__c',
                                                                'AccountBalance__c','IsThereAnotherOwnerToggle__c','FaceValueAmount__c','LoanBalance__c','RealEstateFairMarketValue__c','PreFuneralAgmtGoodsAndServicesCost__c','ResourceSubTypeCode__c','IsIndividualAbleToRideToggle__c','NoAccessReason__c','ResourceEndReason__c','IsIncomeEssentialToSelfSupportToggle__c',
                                                                'VehicleFairMarketValue__c','NotEnoughInformation__c','Make__c','Model__c','ModelYear__c','toLabel(ResourceSubTypeCode__c) RSubtype','toLabel(ResourceTypeCode__c) Rtype','IsHomeHomesteadPropertyToggle__c','VehicleUseReason__c','VehicleDebt__c','PrimaryUserIndividual__c','PrimaryUserIfOther__c',
                                                                'InsuranceCompanyName__c','PolicyNumber__c','CashSurrenderValue__c','InsuranceCompanyAddress__c','InsuranceCompanyPhoneNumber__c','LoanBalance__c','IsPolicyDesignatedToPayBurialToggle__c','IsPolicyUsedForPrearrangedFuneralToggle__c','IsIncomeProducingPropertyToggle__c','HasPolicyAssignedToFuneralHomeToggle__c'}, 
                                                                mapConditions);
            if(lstAssets != null && lstAssets.size()>0){
                for(SSP_Asset__c sspAsset : lstAssets){
                    if(!mapBooleanToAssets.containsKey(sspAsset.IsExistingData__c)){
                        mapBooleanToAssets.put(sspAsset.IsExistingData__c,new List<SSP_Asset__c>{sspAsset});
                    }else{
                        mapBooleanToAssets.get(sspAsset.IsExistingData__c).add(sspAsset);
                    }
                }
            }
                                
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourcesForMember', e.getMessage(), true);
        }
        return mapBooleanToAssets;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourceDetails
    * @desc This method is used to get details of a Particular Resource
    * @param {Set<Id> setAssetIds, Boolean bExistingData}
    * @return List<SSP_Asset__c>
    * */
    public static List<SSP_Asset__c> getResourceDetails(Set<Id> setAssetIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        try{
            mapConditions.put('Id',String.join(new List<Id>(setAssetIds), ','));
            mapConditions.put('RecordTypeId', RESOURCERECORDTYPE);
            //mapConditions.put('IsExistingData__c', String.valueOf(bExistingData));
            mapConditions.put('IsDeleted__c', String.valueOf(false));
            lstAssets = SSP_AssetSelector.queryAssetData(new Map<String, String>{'hasToLabel'=>'true','objectName'=>'SSP_Asset__c','IN'=>'Id','operator'=>'AND'}, 
                                                                new Set<String>{'Id','InsurancePolicyAsset__c','IsThereAnotherOwnerToggle__c','Location__c','FuneralLocation__c','ResourceTypeCode__c','IsExistingData__c','HasItemizedStmtOfGoodsSignByClientToggle__c','VehicleUseReason__c','HasAccessToVehicleToggle__c','StartDate__c','SSP_Member__c',
                                                                'AccountBalance__c','LoanBalance__c','NotEnoughInformation__c','FaceValueAmount__c','RealEstateFairMarketValue__c','FuneralFundCode__c','ResourceSubTypeCode__c','IsHomeHomesteadPropertyToggle__c','NoAccessReason__c','VehicleCategoryCode__c','ResourceEndReason__c','IsIncomeEssentialToSelfSupportToggle__c',
                                                                'VehicleFairMarketValue__c','PreFuneralAgmtGoodsAndServicesCost__c','Make__c','Model__c','ModelYear__c','toLabel(ResourceTypeCode__c) Rtype','VehicleDebt__c','IsIndividualAbleToRideToggle__c','PrimaryUserIndividual__c','InsuranceCompanyName__c','IsIncomeProducingPropertyToggle__c',
                                                                'PolicyNumber__c','toLabel(ResourceSubTypeCode__c) RSubtype','CashSurrenderValue__c','InsuranceCompanyAddress__c','InsuranceCompanyPhoneNumber__c','LoanBalance__c','IsPolicyDesignatedToPayBurialToggle__c','IsPolicyUsedForPrearrangedFuneralToggle__c','PrimaryUserIfOther__c','HasPolicyAssignedToFuneralHomeToggle__c'}, 
                                                                mapConditions);
                                
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourceDetails', e.getMessage(), true);
        }
        return lstAssets;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesForMember
    * @desc This method is used to get Resources for a particular Member based on Resource type
    * @param {Map<String,String> mapResInputs}
    * @return List<SSP_Asset__c>
    * */
    public static List<SSP_Asset__c> getResourcesForMemberBasedOnResourceType(Map<String,String> mapResInputs){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        try{            
            mapConditions.put('SSP_Member__c', mapResInputs.get('memberId'));
            mapConditions.put('ResourceTypeCode__c', mapResInputs.get('strResourceType'));
            mapConditions.put('RecordTypeId', RESOURCERECORDTYPE);
            mapConditions.put('IsDeleted__c', String.valueOf(false));
            lstAssets = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                                new Set<String>{'Id'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourcesForMemberBasedOnResourceType', e.getMessage(), true);
        }
        return lstAssets;
    }

    /**
    * @author: Karthik Gulla
    * @method: getMemberDetailsForResource
    * @desc This method is used to get member Details for Resources Summary
    * @param {Set<Id> setMemberIds}
    * @return List<SSP_Member__c>
    * */
    public static List<SSP_Member__c> getMemberDetailsForResource(Set<Id> setMemberIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        try{
            mapConditions.put('Id',String.join(new List<Id>(setMemberIds), ','));
            lstMembers = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id','HasOwnBankAccountToggle__c','HasVehicleToggle__c',
                                                                'HasLifeInsuranceToggle__c','HasInvestmentsToggle__c','HasRealEstatePropertyToggle__c',
                                                                'HasPreArrangedFuneralContractToggle__c','HasCashReloadableMoneyCardToggle__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getMemberDetailsForResource', e.getMessage(), true);
        }
        return lstMembers;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicationDetailsForResource
    * @desc This method is used to get application Details for Resources Summary
    * @param {Set<Id> setApplicationIds}
    * @return List<SSP_Application__c>
    * */
    public static List<SSP_Application__c> getApplicationDetailsForResource(Set<Id> setApplicationIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
        try{            
            mapConditions.put('Id',String.join(new List<Id>(setApplicationIds), ','));
            lstApplications = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id','ProgramsApplied__c','HasAnnuityToggle__c','HasBurialFundToggle__c','HasPromissoryNoteOrLandContractToggle__c',
                                                                'HasBurialPlotsToggle__c','HasLifeEstateToggle__c','HasLifeSettlementContractToggle__c','HasSpecialNeedTrustToggle__c',
                                                                'HasLTCAgreementToggle__c','HasOtherResourceToggle__c','HasPartnershipQualifiedLTCPolicyToggle__c','IsAssetsInExcess1MToggle__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getApplicationDetailsForResource', e.getMessage(), true);
        }
        return lstApplications;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicationIndividuals
    * @desc This method is used to get application Individual Details for Resources Summary
    * @param {Set<Id> setApplicationIds}
    * @return List<SSP_ApplicationIndividual__c>
    * */
    public static List<SSP_ApplicationIndividual__c> getApplicationIndividuals(Set<Id> setApplicationIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = new List<SSP_ApplicationIndividual__c>();
        try{
            mapConditions.put('SSP_Application__c',String.join(new List<Id>(setApplicationIds), ','));
            lstApplicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id','SSP_Member__c' ,'SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','MemberProgramsApplied__c','ProgramsApplied__c','MedicaidType__c','MemberStatus__c','DCPrograms__c','IsHeadOfHousehold__c','IsTMember__c','SSP_Member__r.MiddleInitial__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getApplicationIndividuals', e.getMessage(), true);
        }
        return lstApplicationIndividuals;
    }

     /**
    * @author: Karthik Gulla
    * @method: getApplicationIndividualForMember
    * @desc This method is used to get application Individual Details for a particular Member
    * @param {String sApplicationId, String sMemberId}
    * @return List<SSP_ApplicationIndividual__c>
    * */
    @AuraEnabled
    public static List<SSP_ApplicationIndividual__c> getApplicationIndividualForMember(String sApplicationId, String sMemberId){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = new List<SSP_ApplicationIndividual__c>();
        try{
            mapConditions.put('SSP_Application__c', sApplicationId);
            mapConditions.put('SSP_Member__c', sMemberId);
            lstApplicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                new Set<String>{'Id','SSP_Member__c','IsHeadOfHousehold__c','SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c', 'ProgramsApplied__c','MedicaidType__c',
                                                                                'IsMemberStillOwnsExpenses__c','IsMemberStillOwnsIncomes__c','IsMemberStillOwnsResources__c',
                                                                                'IsNoChangesToExpenses__c','IsNoChangesToIncomes__c','IsNoChangesToResources__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getApplicationIndividualForMember', e.getMessage(), true);
        }
        return lstApplicationIndividuals;
    }

    /**
    * @author: Karthik Gulla
    * @method: deleteResources
    * @desc This method is used to delete resources from resource summary
    * @param {Set<Id> setResourceIds}
    * @return void
    * */

    public static void deleteResources(Set<Id> setResourceIds){
        try{
            Map<String,String> mapConditions = new Map<String,String>();
            mapConditions.put('Id',String.join(new List<Id>(setResourceIds), ','));
            List<SSP_Asset__c> lstAssetsTobeDeleted =  SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id'}, mapConditions);
            if(lstAssetsTobeDeleted != null){                                                   
                ESAPI.accessController().deleteAsUser(lstAssetsTobeDeleted);
            } 
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'deleteResources', e.getMessage(), true);
        }
    }

    /**
    * @author: Karthik Gulla
    * @method: buildResponse
    * @desc This method is used to build LightningResponse
    * @param {String strKey, String strValue}
    * @return SSP_LightningResponse
    * */
    public static SSP_LightningResponse buildResponse(String strKey, String strValue){
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse(); 
        try{       
            clsLightningResponse.put(strKey,strValue);
            clsLightningResponse.bIsSuccess = true;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'buildResponse', e.getMessage(), true);
        }
        return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: updateGatepostQuestions
    * @desc This method is used to update gatepost questions
    * @param {Map<String,String> mapInputs, String strValue, String strAction}
    * @return void
    * */
    public static void updateGatepostQuestions(Map<String,String> mapInputs, String strValue, String strAction){
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
        Map<String,SSP_Member__c> mapMemberDetails = new Map<String,SSP_Member__c>();
        Map<String,SSP_Application__c> mapApplicationDetails = new Map<String,SSP_Application__c>();
        Set<String> setAccessFields = new Set<String>();
        try{
            mapResourceTypeMappings = getStaticResourceDetailsTypeMappings();
            if(mapInputs.get(SSP_GlobalConstants.MEMBERID) != null 
                && mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE)!= null 
                && mapResourceTypeMappings.get(mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE)).DetailsRequired__c
                && ((strAction == SSP_GlobalConstants.REMOVE && SSP_ResourcesService.getResourcesForMemberBasedOnResourceType(mapInputs).size() == 0)
                || strAction == SSP_GlobalConstants.ADD)){
                mapMemberDetails  = SSP_ResourcesController.getMemberDetails(mapInputs);
                SSP_Member__c sspMemberRecord = mapMemberDetails.get(mapInputs.get(SSP_GlobalConstants.MEMBERID));
                sspMemberRecord.put(mapResourceTypeMappings.get(mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE)).SobjectField__c, strValue);
                setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspMemberRecord));
                lstMembers.add(sspMemberRecord);
            }
                
            if(mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null
                && mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE)!= null
                && mapResourceTypeMappings.get(mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE)) != null
                && !mapResourceTypeMappings.get(mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE)).DetailsRequired__c){
                setAccessFields.clear();
                mapApplicationDetails = SSP_ResourcesController.getApplicationDetails(mapInputs);
                SSP_Application__c sspAppRecord = mapApplicationDetails.get(mapInputs.get(SSP_GlobalConstants.APPLICATIONID));
                sspAppRecord.put(mapResourceTypeMappings.get(mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE)).SobjectField__c, strValue);
                setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspAppRecord));
                lstApplications.add(sspAppRecord);
            }

            if(!lstMembers.isEmpty()){
                ESAPI.accessController().updateAsUser(new Map<ID,SSP_Member__c>(lstMembers), new List<String>(setAccessFields));
            }
            if(!lstApplications.isEmpty()){
                ESAPI.accessController().updateAsUser(new Map<ID,SSP_Application__c>(lstApplications), new List<String>(setAccessFields));
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'updateGatepostQuestions', e.getMessage(), true);
        }
    }

    /**
    * @author: Karthik Gulla
    * @method: buildResourcesWrapper
    * @desc This method is used to build resources wrapper
    * @param {SSP_Asset__c sspAssetResource}
    * @return SSP_ResourcesWrapper
    * */
    public static SSP_ResourcesWrapper buildResourcesWrapper(SSP_Asset__c sspAssetResource){
        SSP_ResourcesWrapper sspResourcesWrapper = new SSP_ResourcesWrapper();
        try{ 
            mapResourceTypeMappings = getStaticResourceDetailsTypeMappings();     
            sspResourcesWrapper.strResourceId = sspAssetResource.Id;
            sspResourcesWrapper.strResourceType = sspAssetResource.ResourceTypeCode__c;
            sspResourcesWrapper.strTempResId = String.valueof(Math.abs(Crypto.getRandomLong())).substring(0, SSP_GlobalConstants.IRANDOMVALUELENGTH);
            
            String strLine1Val = SSP_ResourcesController.getResourceTileFieldValue(mapResourceTypeMappings.get(sspAssetResource.ResourceTypeCode__c).ResourceTileFields__c, SSP_GlobalConstants.LINEONE, sspAssetResource);
            sspResourcesWrapper.strResTileLineOneValue  = (strLine1Val != null && strLine1Val != '') ? strLine1Val : String.valueOf(sspAssetResource.get(SSP_GlobalConstants.RTYPE));
            String strLine2Val = SSP_ResourcesController.getResourceTileFieldValue(mapResourceTypeMappings.get(sspAssetResource.ResourceTypeCode__c).ResourceTileFields__c, SSP_GlobalConstants.LINETWO, sspAssetResource);
            sspResourcesWrapper.strResTileLineTwoValue = (sspAssetResource.ResourceTypeCode__c == SSP_GlobalConstants.FUNERALCONTRACTRESOURCETYPE && strLine2Val!= null && strLine2Val!= '') ? strLine2Val : ((strLine2Val!= null && strLine2Val!= '')? ('$' + strLine2Val) : '');
                    
            sspResourcesWrapper.bNoInformation = sspAssetResource.NotEnoughInformation__c;
            sspResourcesWrapper.bIsCoownerResource = false;
            sspResourcesWrapper.strFuneralLocation = sspAssetResource.FuneralLocation__c;
            sspResourcesWrapper.dResourceValue = sspAssetResource.AccountBalance__c;
            sspResourcesWrapper.strGoodsServicesCost = String.valueOf(sspAssetResource.PreFuneralAgmtGoodsAndServicesCost__c);
            sspResourcesWrapper.strItemisedGoodsSigned = String.valueOf(sspAssetResource.HasItemizedStmtOfGoodsSignByClientToggle__c);
            sspResourcesWrapper.strFuneralFundedOption = sspAssetResource.FuneralFundCode__c;
            sspResourcesWrapper.strResourceSubType = sspAssetResource.ResourceSubTypeCode__c;
            sspResourcesWrapper.strHomeSteadProperty = String.valueOf(sspAssetResource.IsHomeHomesteadPropertyToggle__c);
            sspResourcesWrapper.strIncomeProducingProperty = String.valueOf(sspAssetResource.IsIncomeProducingPropertyToggle__c);
            sspResourcesWrapper.strIncomeEssentialToSupport = String.valueOf(sspAssetResource.IsIncomeEssentialToSelfSupportToggle__c);
            sspResourcesWrapper.strRealEstateAddress = sspAssetResource.Location__c;
            sspResourcesWrapper.dRealEstateFairMarketValue = sspAssetResource.RealEstateFairMarketValue__c;
            sspResourcesWrapper.strAnotherOwner = String.valueOf(sspAssetResource.IsThereAnotherOwnerToggle__c);
            sspResourcesWrapper.strResourceTypeLabel = String.valueOf(sspAssetResource.get(SSP_GlobalConstants.RTYPE));
            sspResourcesWrapper.strVehicleCategory = sspAssetResource.VehicleCategoryCode__c;
            sspResourcesWrapper.strVehicleMake = sspAssetResource.Make__c;
            sspResourcesWrapper.strVehicleModel = sspAssetResource.Model__c;
            sspResourcesWrapper.strVehicleModelYear = sspAssetResource.ModelYear__c;
            sspResourcesWrapper.strVehicleUseReason = sspAssetResource.VehicleUseReason__c;
            sspResourcesWrapper.dtResourceStartDate = sspAssetResource.StartDate__c;
            sspResourcesWrapper.dVehicleFairMarketValue = sspAssetResource.VehicleFairMarketValue__c;
            sspResourcesWrapper.dVehicleDebt = sspAssetResource.VehicleDebt__c;
            sspResourcesWrapper.strIndividualAbleToRide = String.valueOf(sspAssetResource.IsIndividualAbleToRideToggle__c);
            sspResourcesWrapper.strAccessToVehicle = String.valueOf(sspAssetResource.HasAccessToVehicleToggle__c);
            sspResourcesWrapper.strNoAccessReason = sspAssetResource.NoAccessReason__c;
            if(sspAssetResource.PrimaryUserIndividual__c != null) {
                sspResourcesWrapper.strPrimaryUserIndividual = sspAssetResource.PrimaryUserIndividual__c;
            } else {
                sspResourcesWrapper.strPrimaryUserIndividual = sspAssetResource.PrimaryUserIfOther__c;
            }
            sspResourcesWrapper.strInsuranceFaceValueAmount = String.valueOf(sspAssetResource.FaceValueAmount__c);
            sspResourcesWrapper.dCashSurrenderValue = sspAssetResource.CashSurrenderValue__c;
            sspResourcesWrapper.strInsuranceCompanyAddress = sspAssetResource.InsuranceCompanyAddress__c;
            sspResourcesWrapper.strInsuranceCompanyPhone = sspAssetResource.InsuranceCompanyPhoneNumber__c;
            sspResourcesWrapper.dLoanBalance = sspAssetResource.LoanBalance__c;
            sspResourcesWrapper.strPolicyDesignatedForBurial = String.valueOf(sspAssetResource.IsPolicyDesignatedToPayBurialToggle__c);
            sspResourcesWrapper.strPolicyUsedForFuneral = String.valueOf(sspAssetResource.IsPolicyUsedForPrearrangedFuneralToggle__c);
            sspResourcesWrapper.strInsuranceCompanyName = sspAssetResource.InsuranceCompanyName__c;
            sspResourcesWrapper.strPolicyNumber = sspAssetResource.PolicyNumber__c;
            sspResourcesWrapper.isResourceEditable = !sspAssetResource.IsExistingData__c;
            sspResourcesWrapper.bHideAdditionalDetails = sspResourcesWrapper.strResourceType != SSP_GlobalConstants.FUNERALCONTRACTRESOURCETYPE ? false : true;
            Map<String, String> mapResourceOwnershipRecords = SSP_ResourcesService.getAdditionalOwnersByResourceOwnership(sspAssetResource.Id);//Changed for perf fix - Keshav
            sspResourcesWrapper.strAdditionalOwners = (mapResourceOwnershipRecords.get('additional') != null) ? mapResourceOwnershipRecords.get('additional') : '[ ]'; //Changed for perf fix - Keshav
            sspResourcesWrapper.strOtherOwners = (mapResourceOwnershipRecords.get('other') != null) ? mapResourceOwnershipRecords.get('other') : '[]';
            if(sspResourcesWrapper.strAdditionalOwners != null && sspResourcesWrapper.strAdditionalOwners != '[ ]'){
                sspResourcesWrapper.strOtherOwners = sspResourcesWrapper.strOtherOwners + SSP_GlobalConstants.OTHERVALUE;
            }
            sspResourcesWrapper.strResourceEndReason = sspAssetResource.ResourceEndReason__c;
            sspResourcesWrapper.strInsuranceAssetId = sspAssetResource.InsurancePolicyAsset__c;
            sspResourcesWrapper.strPolicyBeenAssignedForFuneral = String.valueOf(sspAssetResource.HasPolicyAssignedToFuneralHomeToggle__c);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'buildResourcesWrapper', e.getMessage(), true);
        }
        return sspResourcesWrapper;
    }

    /**
    * @author: Karthik Gulla
    * @method: getAdditionalOwnersByResourceOwnership
    * @desc This method is used to get additional owners by resource ownership
    * @param {String strAssetId}
    * @return List<String>
    * */
    public static Map<String, String> getAdditionalOwnersByResourceOwnership(String strAssetId){
        List<String> lstMemberIds = new List<String>();
        List<SSP_ResourceDetailsController.ValueWrapper> lstAdditionalOwnerNames = new List<SSP_ResourceDetailsController.ValueWrapper>();
        List<SSP_ResourceOwnership__c> lstResourceOwnerships = new List<SSP_ResourceOwnership__c>();
        Map<String,String> mapConditions = new Map<String,String>();
        Map<String,String> mapReturnValues = new Map<String,String>();
        try{
            mapConditions.put('SSP_Asset__c', strAssetId);
            mapConditions.put('RecordTypeId',SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.RESOURCEOWNERSHIPOBJECT, SSP_GlobalConstants.JOINTOWNERSHIPRECORDTYPE));
            mapConditions.put('SSP_Asset__r.IsDeleted__c', String.valueOf(false));
            lstResourceOwnerships = SSP_ResourceOwnershipSelector.queryResourceOwnershipData(new Map<String, String>{'objectName'=>'SSP_ResourceOwnership__c','operator'=>'AND'}, 
                                                                    new Set<String>{'Id','SSP_Asset__r.SSP_Member__c','SSP_Asset__c','SSP_Member__c','JointOwnerName__c'}, 
                                                                    mapConditions);
            for(SSP_ResourceOwnership__c sspResOwnership:lstResourceOwnerships){
                if(sspResOwnership.SSP_Member__c != null && sspResOwnership.SSP_Member__c != sspResOwnership.SSP_Asset__r.SSP_Member__c){
                    lstMemberIds.add(sspResOwnership.SSP_Member__c);
                }   
                else if(sspResOwnership.SSP_Member__c == null) {
                    //Added for Performance tuning - Keshav
                    SSP_ResourceDetailsController.ValueWrapper sspResValueWrapper = new SSP_ResourceDetailsController.ValueWrapper();
                    sspResValueWrapper.value = sspResOwnership.JointOwnerName__c;
                    lstAdditionalOwnerNames.add(sspResValueWrapper);
                }
            }
            mapReturnValues.put('other', String.join(lstMemberIds,','));
            mapReturnValues.put('additional', JSON.serializePretty(lstAdditionalOwnerNames));
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getAdditionalOwnersByResourceOwnership', e.getMessage(), true);
        }
        return mapReturnValues;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesByOwnership
    * @desc This method is used to get additional resources by resource ownership
    * @param {String strMemberId}
    * @return List<String>
    * */
    public static List<SSP_ResourceOwnership__c> getResourcesByOwnership(String strMemberId, List<String> lstResourceTypes){
        List<SSP_ResourceOwnership__c> lstResourceOwnerships = new List<SSP_ResourceOwnership__c>();
        List<SSP_ResourceOwnership__c> lstActualResourceOwnerships = new List<SSP_ResourceOwnership__c>();
        Map<String,String> mapConditions = new Map<String,String>();
        try{
            mapConditions.put(SSP_GlobalConstants.SSPMEMBEROBJECT, strMemberId);
            mapConditions.put('SSP_Asset__r.IsDeleted__c', String.valueOf(false));
            if(!lstResourceTypes.isEmpty()) {
                mapConditions.put('SSP_Asset__r.ResourceTypeCode__c',String.join(lstResourceTypes, ','));
            }
            lstResourceOwnerships = SSP_ResourceOwnershipSelector.queryResourceOwnershipData(new Map<String, String>{'objectName'=>'SSP_ResourceOwnership__c','IN'=>'SSP_Asset__r.ResourceTypeCode__c','operator'=>'AND'}, 
                                                                new Set<String>{'Id','SSP_Asset__c','SSP_Member__c','SSP_Asset__r.SSP_Member__c'}, 
                                                                mapConditions);
            for(SSP_ResourceOwnership__c sspResOwnership : lstResourceOwnerships) {
                if(sspResOwnership.SSP_Member__c != sspResOwnership.SSP_Asset__r.SSP_Member__c){
                    lstActualResourceOwnerships.add(sspResOwnership);
                }
            }                                                   
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourcesByOwnership', e.getMessage(), true);
        }
        return lstActualResourceOwnerships;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourceOwnershipForResource
    * @desc This method is used to get resource ownerships for a particular resource
    * @param {Set<Id> setAssetIds}
    * @return List<SSP_ResourceOwnership__c>
    * */
    public static List<SSP_ResourceOwnership__c> getResourceOwnershipForResource(Set<Id> setAssetIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_ResourceOwnership__c> lstResourceOwnerships = new List<SSP_ResourceOwnership__c>();
        try{
            mapConditions.put(SSP_GlobalConstants.ASSETOBJECTNAME,String.join(new List<Id>(setAssetIds), ','));
            mapConditions.put('RecordTypeId',SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.RESOURCEOWNERSHIPOBJECT, SSP_GlobalConstants.JOINTOWNERSHIPRECORDTYPE));
            mapConditions.put('SSP_Asset__r.IsDeleted__c', String.valueOf(false));
            lstResourceOwnerships = SSP_ResourceOwnershipSelector.queryResourceOwnershipData(new Map<String, String>{'objectName'=>'SSP_ResourceOwnership__c','IN'=>'SSP_Asset__c','operator'=>'AND'}, 
                                                                        new Set<String>{'Id','SSP_Asset__c','SSP_Member__c'}, 
                                                                        mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourceOwnershipForResource', e.getMessage(), true);
        }
        return lstResourceOwnerships;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesDetailsMappings
    * @desc This method is used to get custom metadata from Resource Mappings
    * @param {String sKey}
    * @return Map<String,ResourceMappings__mdt>
    * */
    @AuraEnabled
    public static Map<String,SSP_ResourceMappings__mdt> getResourcesDetailsMappings(String sKey){
        SSP_Utility.isAuthenticatedUser();
        Map<String,SSP_ResourceMappings__mdt> mapResMappings = new Map<String,SSP_ResourceMappings__mdt>();
        try{
            List<String> lstResourceMappingsFields = new List<String>{'MasterLabel','DetailsRequired__c','ResourceTileFields__c','SObjectField__c','ResourceType__c','ApplicablePrograms__c'};
            Boolean canViewResourceMappingsFields = ESAPI.accessController().isAuthorizedToView(SSP_ResourceMappings__mdt.getSObjectType(), lstResourceMappingsFields);
            if(canViewResourceMappingsFields){
                for(SSP_ResourceMappings__mdt resMapping : [SELECT MasterLabel, DetailsRequired__c, ResourceTileFields__c, SObjectField__c, toLabel(ResourceType__c) Rtype, ResourceType__c, ApplicablePrograms__c FROM SSP_ResourceMappings__mdt LIMIT 50]){
                    mapResMappings.put(String.valueOf(resMapping.get(sKey)), resMapping);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourcesDetailsMappings', e.getMessage(), true);
        }
        return mapResMappings;
    }

    /**
    * @author: Karthik Gulla
    * @method: getResourcesDetailsMappings
    * @desc This method is used to get custom metadata from Resource Mappings
    * @param {String sKey, Boolean bDetailsRequired}
    * @return Map<String,ResourceMappings__mdt>
    * */
    public static Map<String,SSP_ResourceMappings__mdt> getResourcesDetailsMappings(String sKey, Boolean bDetailsRequired){
        Map<String,SSP_ResourceMappings__mdt> mapResMappings = new Map<String,SSP_ResourceMappings__mdt>();
        try{
            List<String> lstResourceMappingsFields = new List<String>{'MasterLabel','DetailsRequired__c','ResourceTileFields__c','SObjectField__c','ResourceType__c','ApplicablePrograms__c'};
            Boolean canViewResourceMappingsFields = ESAPI.accessController().isAuthorizedToView(SSP_ResourceMappings__mdt.getSObjectType(), lstResourceMappingsFields);
            if(canViewResourceMappingsFields){
                for(SSP_ResourceMappings__mdt resMapping : [SELECT MasterLabel, DetailsRequired__c, ResourceTileFields__c, SObjectField__c, toLabel(ResourceType__c) Rtype, ResourceType__c, ApplicablePrograms__c FROM SSP_ResourceMappings__mdt WHERE DetailsRequired__c = :bDetailsRequired]){
                    mapResMappings.put(String.valueOf(resMapping.get(sKey)), resMapping);
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getResourcesDetailsMappings', e.getMessage(), true);
        }
        return mapResMappings;
    }

    /**
    * @author: Karthik Gulla
    * @method: hasProgramApplicable
    * @desc This method is used to check whether a member is applicable for a particular gatepost question
    * @param {List<String> lstMemberPrograms, List<String> lstProgramMappings}
    * @return String
    * */
    public static Boolean hasProgramApplicable(List<String> lstMemberPrograms, List<String> lstProgramMappings){
        Boolean bReturnValue = false;
        try{
            for(String strProgram:lstMemberPrograms){
                bReturnValue =  lstProgramMappings.contains(strProgram) ? true : false;
                if(bReturnValue){
                    break;
                }                            
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'hasProgramApplicable', e.getMessage(), true);
        }        
        return bReturnValue;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicableAssetsBasedOnPrograms
    * @desc This method is used to get the applicable asset types based on programs on a Case/Application
    * @param {List<String> lstAppPrograms, List<String> lstAssets}
    * @return Set<String>
    * */
    public static List<String> getApplicableAssetsBasedOnPrograms(List<String> lstAppPrograms, List<String> lstAssets){
        Set<String> setApplicableAssets = new Set<String>();
        try{
           setApplicableAssets.add('ABC');
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getApplicableAssetsBasedOnPrograms', e.getMessage(), true);
        }        
        return new List<String>(setApplicableAssets);
    }

    /**
    * @author: Karthik Gulla
    * @method: getStaticResourceDetailsTypeMappings
    * @desc This method is used to get the resource details mappings
    * @return Map<String,SSP_ResourceMappings__mdt>
    * */
    public static Map<String,SSP_ResourceMappings__mdt> getStaticResourceDetailsTypeMappings() {
        try {
            if(mapResourceTypeMappings == null) {
                mapResourceTypeMappings = SSP_ResourcesService.getResourcesDetailsMappings(SSP_GlobalConstants.RESOURCETYPEAPI);
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getStaticResourceDetailsTypeMappings', e.getMessage(), true);
        }        
        return mapResourceTypeMappings;
    }

    /**
    * @author: Karthik Gulla
    * @method: isNONMagiApplication
    * @desc This method is used to identify whether an application is Magi or Non Magi
    * @param {String sApplicationId}
    * @return Boolean
    * */
    public static Boolean isNONMagiApplication(String sApplicationId){
        Set<Id> setApplicationIds = new Set<Id>();
        Boolean isNonMagi = false;
        try{
            setApplicationIds.add(sApplicationId);
            List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_ResourcesService.getApplicationIndividuals(setApplicationIds);
            for(SSP_ApplicationIndividual__c sspAppIndividual : lstAppIndividuals){ 
                if(sspAppIndividual.MedicaidType__c != null && sspAppIndividual.MedicaidType__c == SSP_GlobalConstants.NONMAGI && sspAppIndividual.MemberStatus__c != SSP_GlobalConstants.MEMBER_REMOVE_STATUS) {
                    isNonMagi = true;
                    break;
                }
            }
        } catch(Exception ex){            
            LOG_LogMessageUtility.logMessage(ex, 'SSP_ResourcesService', 'isNONMagiApplication', ex.getMessage() , true);
        }
        return isNonMagi;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicableResourcesBasedOnPrograms
    * @desc This method is used to get the applicable resource types based on programs
    * @param List<String> lstCurrentAppPrograms
    * @return List<String>
    * */
    public static List<String> getApplicableResourcesBasedOnPrograms(List<String> lstCurrentAppPrograms){
        Set<String> setResources = new Set<String>();
        try{
            Map<String,SSP_ResourceMappings__mdt> mapResourceMappings = SSP_ResourcesService.getStaticResourceDetailsTypeMappings();
            for(String strKey:mapResourceMappings.keySet()){
                List<String> lstProgramMappings = mapResourceMappings.get(strKey).ApplicablePrograms__c != null ? mapResourceMappings.get(strKey).ApplicablePrograms__c.split(',') : null;
                if(SSP_ResourcesService.hasProgramApplicable(lstCurrentAppPrograms, lstProgramMappings)){
                    setResources.add(mapResourceMappings.get(strKey).ResourceType__c);
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getApplicableResourcesBasedOnPrograms', e.getMessage(), true);
        }        
        return new List<String>(setResources);
    }
}