/**
* @author: Karthik Gulla
* @Class Name: SSP_ResourceDetailsController
* @desc This class is used as a controller to call ResourcesService for Resource details Functionality
* @Date 12-05-2019
MODIFICATION LOG :
* */ 
public with sharing class SSP_ResourceDetailsController {
    public static Map<String,SSP_ResourceMappings__mdt> mapResourceTypeMappings;
    public static final Id RESOURCERECORDTYPE = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
    public static final Id RESOURCEOWNERSHIPRECORDTYPE = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.RESOURCEOWNERSHIPOBJECT, SSP_GlobalConstants.JOINTOWNERSHIPRECORDTYPE);
    /**
    * @author: Karthik Gulla
    * @method: getCurrentApplicationHouseholdMembers
    * @desc This method is used to get application household members
    * @param {String sApplicationId, String sMemberId, String sMembersType}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getCurrentApplicationHouseholdMembers(String sApplicationId, String sMemberId, String sMembersType){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Set<Id> setAppIndivIds = new Set<Id>(); 
        try{
            if(sApplicationId != null){
                setAppIndivIds.add(sApplicationId);
            }
            List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = SSP_ResourcesService.getApplicationIndividuals(setAppIndivIds);
            List<SSP_ResourcesWrapper.HouseholdMemberWrapper> lstHouseholdMembers = new List<SSP_ResourcesWrapper.HouseholdMemberWrapper>();
            for(SSP_ApplicationIndividual__c sspAppIndividual : lstApplicationIndividuals){
                if((sMemberId != null && sMemberId != SSP_GlobalConstants.EMPTY 
                    && sMemberId != String.valueOf(sspAppIndividual.SSP_Member__c) && sMembersType == SSP_GlobalConstants.OTHERS)||
                    ((sMemberId == null || sMemberId == SSP_GlobalConstants.EMPTY) && sMembersType == SSP_GlobalConstants.ALL)){                                               
                    SSP_ResourcesWrapper.HouseholdMemberWrapper resHouseholdMemberWrapper = new SSP_ResourcesWrapper.HouseholdMemberWrapper();
                    resHouseholdMemberWrapper.strAppIndividualId = sspAppIndividual.Id;
                    resHouseholdMemberWrapper.strMemberId = sspAppIndividual.SSP_Member__c;
                    if(sspAppIndividual.SSP_Member__r.MiddleInitial__c != null){
                        resHouseholdMemberWrapper.strHouseholdMemberName = sspAppIndividual.SSP_Member__r.FirstName__c + ' ' + sspAppIndividual.SSP_Member__r.MiddleInitial__c + ' ' + sspAppIndividual.SSP_Member__r.LastName__c;
                    } else {
                        resHouseholdMemberWrapper.strHouseholdMemberName = sspAppIndividual.SSP_Member__r.FirstName__c + ' ' + sspAppIndividual.SSP_Member__r.LastName__c;
                    }
                    resHouseholdMemberWrapper.strAppliedPrograms = (sspAppIndividual.ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.MEDICAID)) ? (sspAppIndividual.ProgramsApplied__c + SSP_GlobalConstants.COLON + sspAppIndividual.MedicaidType__c) : sspAppIndividual.ProgramsApplied__c;
                    resHouseholdMemberWrapper.strMemberStatus = sspAppIndividual.MemberStatus__c;
                    resHouseholdMemberWrapper.strDCPrograms = sspAppIndividual.DCPrograms__c;
                    resHouseholdMemberWrapper.bHeadOfHousehold = sspAppIndividual.IsHeadOfHousehold__c;
                    resHouseholdMemberWrapper.strMemberPrograms = sspAppIndividual.MemberProgramsApplied__c;
                    resHouseholdMemberWrapper.bTMember = sspAppIndividual.IsTMember__c;
                    lstHouseholdMembers.add(resHouseholdMemberWrapper);
                }
            }
            clsLightningResponse = SSP_ResourcesService.buildResponse(SSP_GlobalConstants.HOUSEHOLDMEMBERS, JSON.serializePretty(lstHouseholdMembers));
            clsLightningResponse.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.RESOURCE_SELECTION_SCREENID, null).screenPermission);//CD2 2.5 Security Role Matrix and Program Access.
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'getCurrentApplicationHouseholdMembers', e.getMessage(), true);
        }
        return clsLightningResponse;
    } 

    /**
    * @author: Karthik Gulla
    * @method: saveResourceDetails
    * @desc This method is used to save resource details
    * @param {String sUserInputs}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse saveResourceDetails(String sUserInputs){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        try{
            mapResourceTypeMappings = SSP_ResourcesService.getStaticResourceDetailsTypeMappings();
            Map<String,Object> mapInputs = (Map<String,Object>)JSON.deserializeUntyped(sUserInputs);
            if(mapInputs.get(SSP_GlobalConstants.RESOURCETYPECODE)!= null
            && mapResourceTypeMappings.get(String.valueOf(mapInputs.get(SSP_GlobalConstants.RESOURCETYPECODE))).DetailsRequired__c){
                String strObjectName = SSP_GlobalConstants.ASSETOBJECTNAME;
                String strOtherOwners = SSP_GlobalConstants.EMPTY;
                Map<String,String> mapResults = new Map<String,String>();
                List<String> lstResOwnershipRecordIds = new List<String>();
                List<String> lstAdditionalOwners = new List<String>();
                Map<String,Object> mapConvValues = SSP_ResourceDetailsController.convertTolowerAllkeys(mapInputs);
                Map<String, Schema.SObjectType> mapSchemaDetails = Schema.getGlobalDescribe();
                Schema.SObjectType schemaObjectType = mapSchemaDetails.get(strObjectName);
                Map<String, Schema.SObjectField> mapFields = schemaObjectType.getDescribe().fields.getMap();
                SSP_Asset__c sspAssetRecord = new SSP_Asset__c();
                sspAssetRecord.RecordTypeId = RESOURCERECORDTYPE;

                Set<String> setStandardFields = new Set<String>();
                Set<String> setRelationalFields = new Set<String>();
                for(String strKeyField:mapInputs.keySet()){
                    if(mapFields.get(strKeyField.toLowerCase()) != null){
                        setStandardFields.add(strKeyField);
                    } else{
                        setRelationalFields.add(strKeyField);
                    }
                }
                Map<String, Object> mapStdReturnValues = new Map<String, Object>();
                mapStdReturnValues.put(SSP_GlobalConstants.ASSETRECORD, sspAssetRecord);
                mapStdReturnValues.put(SSP_GlobalConstants.STANDARDFIELDS, setStandardFields);

                sspAssetRecord = SSP_ResourceDetailsController.processStandardFieldsInput(mapStdReturnValues, mapFields, mapConvValues);
                Map<String, Object> mapReturnValues = SSP_ResourceDetailsController.processRelationalFieldInputs(sspAssetRecord, setRelationalFields, mapInputs);
                sspAssetRecord = (SSP_Asset__c)mapReturnValues.get(SSP_GlobalConstants.ASSETRECORD);
                lstAdditionalOwners = (List<String>)mapReturnValues.get(SSP_GlobalConstants.ADDITIONALOWNERS);
                lstResOwnershipRecordIds = (List<String>)mapReturnValues.get(SSP_GlobalConstants.RESOURCEOWNERSHIPS);
                Set<String> setAccessFields = new Set<String>();
                setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspAssetRecord));
                SObject sAssetObjResult = ESAPI.accessController().upsertAsUser(sspAssetRecord, new List<String>(setAccessFields));                
                SSP_ResourceDetailsController.removeResourceOwnershipRecords(sAssetObjResult.Id);
                
                List<String> lstAssetParameters = new List<String>();
                lstAssetParameters.add(sAssetObjResult.Id);
                lstAssetParameters.add(sspAssetRecord.ssp_member__c);
                SSP_ResourceDetailsController.createResourceOwnerships(lstResOwnershipRecordIds, lstAdditionalOwners, lstAssetParameters);   
            }else{
                SSP_ResourcesWrapper sspResWrapper = new SSP_ResourcesWrapper();
                sspResWrapper.strTempResId = String.valueOf(mapInputs.get(SSP_GlobalConstants.STRTEMPRESID));
                sspResWrapper.strResourceSubType = String.valueOf(mapInputs.get(SSP_GlobalConstants.STRRESOURCETYPE));
                clsLightningResponse = SSP_ResourcesService.buildResponse(SSP_GlobalConstants.UPDATEDRESOURCEDETAILS, JSON.serializePretty(sspResWrapper));
            }
            SSP_ResourceDetailsController.updateQuestionsBasedOnResourceType(mapInputs);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'saveResourceDetails', e.getMessage(), true);
        }
       return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: processStandardFieldsInput
    * @desc This method is used to process standard user inputs to save resource
    * @param {Map<String, object> mapStdReturnValues, Map<String, Schema.SObjectField> mapStdFields, Map<String,Object> mapStdConvValues}
    * @return SSP_Asset__c
    * */
    public static SSP_Asset__c processStandardFieldsInput(Map<String, object> mapStdReturnValues, Map<String, Schema.SObjectField> mapStdFields, Map<String,Object> mapStdConvValues){
        SSP_Asset__c sspResourceRecord = (SSP_Asset__c)mapStdReturnValues.get(SSP_GlobalConstants.ASSETRECORD);
        Set<String> setInputFields = (Set<String>)mapStdReturnValues.get(SSP_GlobalConstants.STANDARDFIELDS);
        try{
            for(String sKey:setInputFields){
                String strFieldType = String.valueOf(mapStdFields.get(sKey).getDescribe().getType());
                if(strFieldType == SSP_GlobalConstants.BOOLEANTYPE){ 
                    sspResourceRecord.put(sKey, mapStdConvValues.get(sKey.toLowerCase()) != null ? Boolean.valueOf(mapStdConvValues.get(sKey.toLowerCase())) : false);
                } else if(strFieldType == SSP_GlobalConstants.CURRENCYTYPE){
                    sspResourceRecord.put(sKey, mapStdConvValues.get(sKey.toLowerCase()) != null ? Decimal.valueOf(String.valueOf(mapStdConvValues.get(sKey.toLowerCase()))) : null);
                } else if(strFieldType == SSP_GlobalConstants.DATETYPE){
                    sspResourceRecord.put(sKey, mapStdConvValues.get(sKey.toLowerCase()) != null ? Date.valueOf(String.valueOf(mapStdConvValues.get(sKey.toLowerCase()))) : null);
                } else if(strFieldType == SSP_GlobalConstants.REFERENCE 
                && sKey == SSP_GlobalConstants.PRIMARYUSERINDIVIDUAL 
                && mapStdConvValues.get(sKey.toLowerCase()) != null
                && SSP_ResourcesController.isValidSalesforceId(String.valueOf(mapStdConvValues.get(sKey.toLowerCase())), SSP_Member__c.class)){
                    sspResourceRecord.put(sKey, mapStdConvValues.get(sKey.toLowerCase()) != null ? mapStdConvValues.get(sKey.toLowerCase()) : null);
                    sspResourceRecord.put(SSP_GlobalConstants.PRIMARYUSERIFOTHER, null);
                }  else if(strFieldType == SSP_GlobalConstants.REFERENCE
                && sKey == SSP_GlobalConstants.PRIMARYUSERINDIVIDUAL  
                && mapStdConvValues.get(sKey.toLowerCase()) != null
                && !SSP_ResourcesController.isValidSalesforceId(String.valueOf(mapStdConvValues.get(sKey.toLowerCase())), SSP_Member__c.class)){
                    sspResourceRecord.put(SSP_GlobalConstants.PRIMARYUSERIFOTHER, mapStdConvValues.get(sKey.toLowerCase()) != null ? mapStdConvValues.get(sKey.toLowerCase()) : null);
                    sspResourceRecord.put(SSP_GlobalConstants.PRIMARYUSERINDIVIDUAL, null);
                }else {
                    sspResourceRecord.put(sKey, mapStdConvValues.get(sKey.toLowerCase()) != null ? mapStdConvValues.get(sKey.toLowerCase()) : null);
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'processStandardFieldsInput', e.getMessage(), true);
        }
        return sspResourceRecord;
    }

    /**
    * @author: Karthik Gulla
    * @method: processRelationalFieldInputs
    * @desc This method is used to process relational field user inputs to save resource
    * @param {SSP_Asset__c sspResourceRecord, Set<String> setRelFields, Map<String,Object> mapUserInputs}
    * @return Map<String, Object>
    * */
    public static Map<String, Object> processRelationalFieldInputs(SSP_Asset__c sspResourceRecord, Set<String> setRelFields, Map<String,Object> mapUserInputs){
        Map<String, Object> mapReturnValues = new Map<String, Object>();        
        List<String> lstRelAdditionalOwners = new List<String>();
        List<String> lstRsOwnershipRecords = new List<String>();
        List<ValueWrapper> lstAddOwnersWrapper = new List<ValueWrapper>();
        try{
            for(String sKey: setRelFields){
                if(sKey == SSP_GlobalConstants.STRMEMBERID && mapUserInputs.get(sKey) != null){
                    sspResourceRecord.put(SSP_GlobalConstants.SSPMEMBEROBJECT,mapUserInputs.get(sKey));
                }
                else if(sKey == SSP_GlobalConstants.STRAPPLICATIONID && mapUserInputs.get(sKey) != null){
                    sspResourceRecord.put(SSP_GlobalConstants.SSPAPPLICATIONOBJECT,mapUserInputs.get(sKey));
                }
                else if(sKey == SSP_GlobalConstants.STRRESOURCEID && mapUserInputs.get(sKey) != null){
                    sspResourceRecord.put(SSP_GlobalConstants.ID,mapUserInputs.get(sKey));
                }
                else if(sKey == SSP_GlobalConstants.STRADDITIONALOWNERS 
                    && mapUserInputs.get(sKey) != null
                    && mapUserInputs.get(sKey) != SSP_GlobalConstants.EMPTYARRAY){
                    lstAddOwnersWrapper = (List<ValueWrapper>)JSON.deserialize(JSON.serializePretty(mapUserInputs.get(sKey)), List<ValueWrapper>.class);
                    lstRelAdditionalOwners  = SSP_ResourceDetailsController.buildAdditionalOwners(lstAddOwnersWrapper);     
                }
            }
            mapReturnValues.put(SSP_GlobalConstants.ASSETRECORD,sspResourceRecord);
            mapReturnValues.put(SSP_GlobalConstants.ADDITIONALOWNERS,lstRelAdditionalOwners);
            mapReturnValues.put(SSP_GlobalConstants.RESOURCEOWNERSHIPS, SSP_ResourceDetailsController.buildOtherOwners(SSP_GlobalConstants.STROTHEROWNERS, mapUserInputs));
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'processRelationalFieldInputs', e.getMessage(), true);
        }
        return mapReturnValues;
    }

    /**
    * @author: Karthik Gulla
    * @method: buildOtherOwners
    * @desc This method is used to build other owners to save resource
    * @param {String sKeyField, Map<String,Object> mapInputs}
    * @return List<String>
    * */
    public static List<String> buildOtherOwners(String sKeyField, Map<String,Object> mapInputs){
        List<String> lstResourceOwnershipRecordIds = new List<String>();
        try{
            if(sKeyField == SSP_GlobalConstants.STROTHEROWNERS 
                && mapInputs.get(sKeyField) != null
                && mapInputs.get(sKeyField) != SSP_GlobalConstants.EMPTYARRAY){
                for(String strKey:String.valueOf(mapInputs.get(sKeyField)).split(SSP_GlobalConstants.COMMA)){
                    if(strKey != SSP_GlobalConstants.OTHER){
                        lstResourceOwnershipRecordIds.add(strKey);
                    }
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'buildOtherOwners', e.getMessage(), true);
        }
        return lstResourceOwnershipRecordIds;
    }

    /**
    * @author: Karthik Gulla
    * @method: buildAdditionalOwners
    * @desc This method is used to build additional owners to save resource
    * @param {List<ValueWrapper> lstAdditionalOwnersWrapper}
    * @return Map<String, Object>
    * */
    public static List<String> buildAdditionalOwners(List<ValueWrapper> lstAdditionalOwnersWrapper){
        List<String> lstAddOwners = new List<String>();
        try{
            for(ValueWrapper vWrapper : lstAdditionalOwnersWrapper){
                if(vWrapper.value != null && vWrapper.value != SSP_GlobalConstants.EMPTY){
                    lstAddOwners.add(vWrapper.value.toUpperCase());
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'buildAdditionalOwners', e.getMessage(), true);
        }
        return lstAddOwners;
    }
    /**
    * @author: Karthik Gulla
    * @method: convertTolowerAllkeys
    * @desc This method is used to convert map keys to lowercase
    * @param {Map<String,Object> mapUserInputs}
    * @return Map<String,String>
    * */
    public static Map<String,Object> convertTolowerAllkeys(Map<String,Object> mapUserInputs){
        Map<String,Object> mapNewValues = new Map<String,Object>();
        try{            
            for(String strKey : mapUserInputs.keySet()){
                mapNewValues.put(strKey.toLowerCase(), mapUserInputs.get(strKey));
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'convertTolowerAllkeys', e.getMessage(), true);
        }
        return mapNewValues;
    }

    /**
    * @author: Karthik Gulla
    * @method: createResourceOwnerships
    * @desc This method is used to create resource ownership records
    * @param {List<String> lstResOwnershipIds, List<String> lstTobeCreatedAdditionalOwners, String strAssetId}
    * @return void
    * */
    public static void createResourceOwnerships(List<String> lstResOwnershipIds, List<String> lstTobeCreatedAdditionalOwners, List<String> lstProperties){
        try{
            List<SSP_ResourceOwnership__c> lstResOwnershipRecords = new List<SSP_ResourceOwnership__c>();
            Set<String> setAccessFields = new Set<String>();
            for(String strKey:lstResOwnershipIds){
                SSP_ResourceOwnership__c sspResOwnership = new SSP_ResourceOwnership__c();
                sspResOwnership.SSP_Asset__c = Id.valueOf(lstProperties[0]);
                sspResOwnership.SSP_Member__c = strKey;
                sspResOwnership.RecordTypeId = RESOURCEOWNERSHIPRECORDTYPE;
                lstResOwnershipRecords.add(sspResOwnership);
                setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspResOwnership));
            }

            for(String strKey:lstTobeCreatedAdditionalOwners){
                SSP_ResourceOwnership__c sspResOwnership = new SSP_ResourceOwnership__c();
                sspResOwnership.SSP_Asset__c = Id.valueOf(lstProperties[0]);
                sspResOwnership.JointOwnerName__c = strKey;
                sspResOwnership.RecordTypeId = RESOURCEOWNERSHIPRECORDTYPE;
                lstResOwnershipRecords.add(sspResOwnership);
                setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspResOwnership));
            }

            if(!lstResOwnershipIds.isEmpty() || !lstTobeCreatedAdditionalOwners.isEmpty()){
                SSP_ResourceOwnership__c sspResOwnership = new SSP_ResourceOwnership__c();
                sspResOwnership.SSP_Asset__c = Id.valueOf(lstProperties[0]);
                sspResOwnership.SSP_Member__c = Id.valueOf(lstProperties[1]);
                sspResOwnership.RecordTypeId = RESOURCEOWNERSHIPRECORDTYPE;
                lstResOwnershipRecords.add(sspResOwnership);
                setAccessFields.addAll(SSP_Utility.getFieldsNamesObject(sspResOwnership));
            }

            if(!lstResOwnershipRecords.isEmpty()){
                ESAPI.accessController().insertAsUser(lstResOwnershipRecords, new List<String>(setAccessFields));
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'createResourceOwnerships', e.getMessage(), true);
        }
    }

    /**
    * @author: Karthik Gulla
    * @method: removeResourceOwnershipRecords
    * @desc This method is used to remove resource ownership records when doing an upsert
    * @param {String strAssetId}
    * @return void
    * */
    public static void removeResourceOwnershipRecords(String strAssetId){
        try{
            Set<Id> setAssetIds = new Set<Id>();
            setAssetIds.add(strAssetId);
            List<SSP_ResourceOwnership__c> lstResourceOwnerships = SSP_ResourcesService.getResourceOwnershipForResource(setAssetIds);
            if(!lstResourceOwnerships.isEmpty()){
                ESAPI.accessController().deleteAsUser(lstResourceOwnerships);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'removeResourceOwnershipRecords', e.getMessage(), true);
        }
    }

    /**
    * @author: Karthik Gulla
    * @method: updateQuestionsBasedOnResourceType
    * @desc This method is used to update gatepost questions based on resource type
    * @param {Map<String,Object> mapInputs}
    * @return void
    * */
    public static void updateQuestionsBasedOnResourceType(Map<String,Object> mapInputs){
        Map<String,String> mapInputValues = new Map<String,String>();
        try{
            mapInputValues.put(SSP_GlobalConstants.MEMBERID, String.valueOf(mapInputs.get(SSP_GlobalConstants.STRMEMBERID)));
            mapInputValues.put(SSP_GlobalConstants.APPLICATIONID,String.valueOf(mapInputs.get(SSP_GlobalConstants.STRAPPLICATIONID)));
            mapInputValues.put(SSP_GlobalConstants.STRRESOURCETYPE,String.valueOf(mapInputs.get(SSP_GlobalConstants.RESOURCETYPECODE)));
            SSP_ResourcesService.updateGatepostQuestions(mapInputValues, SSP_GlobalConstants.YES, SSP_GlobalConstants.ADD);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'updateQuestionsBasedOnResourceType', e.getMessage(), true);
        }
    }

    /**
    * @author: Karthik Gulla
    * @method: getInsurancePolicyDetailsForAsset
    * @desc This method is used to get Life Insurance Resources for a particular Member
    * @param {String sMemberId}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getInsurancePolicyDetailsForAsset(String sMemberId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Set<Id> setMemberIds = new Set<Id>();
        try{
            if(sMemberId != null){
                setMemberIds.add(String.escapeSingleQuotes(sMemberId));
            }
            List<SSP_Asset__c> lstInsuranceAssets = SSP_ResourcesService.getLifeInsuranceResourcesForMember(setMemberIds);
            List<SSP_ResourcesWrapper.InsurancePolicyWrapper> lstInsurancePolicyRecords = new List<SSP_ResourcesWrapper.InsurancePolicyWrapper>();
            for(SSP_Asset__c sspAsset : lstInsuranceAssets){
                SSP_ResourcesWrapper.InsurancePolicyWrapper resInsurancePolicyWrapper = new SSP_ResourcesWrapper.InsurancePolicyWrapper();
                resInsurancePolicyWrapper.strInsurancePolicyNumber = sspAsset.PolicyNumber__c;
                resInsurancePolicyWrapper.strInsuranceAssetId = sspAsset.Id;
                lstInsurancePolicyRecords.add(resInsurancePolicyWrapper);
            }
            clsLightningResponse = SSP_ResourcesService.buildResponse(SSP_GlobalConstants.INSURANCEASSETS, JSON.serializePretty(lstInsurancePolicyRecords));
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourceDetailsController', 'getInsurancePolicyDetailsForAsset', e.getMessage(), true);
        }
        return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @class: ValueWrapper
    * @desc This class is used to build object wrapper for household members
    * */
    public class ValueWrapper{
        public String value {get;set;}
    }
}