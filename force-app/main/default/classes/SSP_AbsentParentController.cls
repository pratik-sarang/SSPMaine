/***************************************************************************************************
*   Type        :   Controller Class
*   Name        :   SSP_AbsentParentController
*   Create By   :   Ajay Saini
*   Create Date :   DEC-20-2019
*   Description :   This class provides methods for absent parent screen.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini             DEC-20-2019             Initial Version
*
*****************************************************************************************************/
public with sharing class SSP_AbsentParentController {
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-20-2019
    * @methodname   getNonCustodialParentRecords
    * @description  Method to list of non-custodial parent records.
    * @return       list of records.
    ***************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getNonCustodialParentRecords(Id memberId, Id sApplicationId) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            if(memberId == null && sApplicationId != null) {
                response.bIsSuccess = false;
                return response;
            }
            List<SSP_NoncustodialRelationship__c> relationships;
            Set<ID> lstMemberIds = new Set<ID>();
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualMemberData(sApplicationId, new Set<String>{'SSP_Member__c', 'SSP_Application__c'});
            if(applicationIndividuals != null) {
                for(SSP_ApplicationIndividual__c individual: applicationIndividuals) {
                    if(memberId != individual.SSP_Member__c) {
                        lstMemberIds.add(individual.SSP_Member__c);
                    }
                }
            }
            Id absentParentRecordTypeId = Schema.SObjectType.SSP_NonCustodialParent__c.getRecordTypeInfosByName().get(SSP_GlobalConstants.ABSENT_PARENT).getRecordTypeId();
            List<String> fields = new List<String>{'SSP_NonCustodialParent__r.FirstName__c', 'SSP_NonCustodialParent__r.LastName__c', 'SSP_NonCustodialParent__r.GenderCode__c' ,'SSP_NonCustodialParent__r.MiddleInitial__c' ,'toLabel(SSP_NonCustodialParent__r.SuffixCode__c)'};
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_NoncustodialRelationship__c', 'operator' => 'AND'};
            Map<String, String> conditionsMap = new Map<String, String>{'IsDeleted__c' => '#false#', 'SSP_Member__c' => memberId, 'SSP_NonCustodialParent__r.RecordTypeId' => absentParentRecordTypeId};
			relationships = SSP_SharingBypassFetcher.fetchRecords(detailMap, new Set<String>(fields), conditionsMap); // CD2 Security Fixes 
            List<SSP_NonCustodialParent__c> parents = new List<SSP_NonCustodialParent__c>();
            if(relationships != null) {
                Schema.sObjectField fieldDescriptor = SSP_NoncustodialRelationship__c.SSP_NonCustodialParent__c.getDescribe().getSObjectField();
                for(SSP_NoncustodialRelationship__c relationship: relationships) {
                    parents.add((SSP_NonCustodialParent__c)relationship.getSObject(fieldDescriptor));
                }
            }
            response.put('parents', parents);
            String relationTypes = SSP_GlobalConstants.fathersCodeList + ',' + SSP_GlobalConstants.mothersCodeList;
            detailMap = new Map<String, String>{'objectName' => 'SSP_Relationship__c', 'operator' => 'AND', 'IN' => 'RelationshipType__c,SSP_Member__c'};
            conditionsMap = new Map<String, String>{'RelationshipType__c' => relationTypes, 'SSP_MemberRelatedTo__c' => memberId, 'SSP_Member__c' =>String.join(new List<Id>(lstMemberIds), ',')};
            List<SSP_Relationship__c> parentsList = SSP_RelationshipSelector.queryRelationshipData(detailMap, new Set<String>{'Name', 'RelationshipType__c'}, conditionsMap);
            Boolean motherMissing = true;
            Boolean fatherMissing = true;
            if(parentsList != null && !parentsList.isEmpty()) {
                for(SSP_Relationship__c parent: parentsList) {
                    if(parent.RelationshipType__c == SSP_GlobalConstants.fathersCodeList) {
                        fatherMissing = false;
                    }
                    if(parent.RelationshipType__c == SSP_GlobalConstants.mothersCodeList) {
                        motherMissing = false;
                    }
                }
            }
            response.put('fatherMissing', fatherMissing);
            response.put('motherMissing', motherMissing);

            /** 2.5	Security Role Matrix and Program Access. */
            response = SSP_Utility.constructSecurityWrap(response, new Map<String, String>{'securityMatrixSummary'=>SSP_GlobalConstants.HH_ABSENTP_SUMMARY_SCREENID, 
                                                                                           'securityMatrixDetails'=>SSP_GlobalConstants.HH_ABSENTP_DETAILS_SCREENID}); //PERF fix
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_AbsentParentController', 'getNonCustodialParentRecords', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-20-2019
    * @methodname   fetchNonCustodialParents
    * @description  Method to provide option of parents suitable for the applicant.
    * @return       list of records.
    ***************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchNonCustodialParents(Id memberId, Id applicationId) {
        SSP_LightningResponse response =  new SSP_LightningResponse();
        try {
            SSP_Utility.isAuthenticatedUser();
            if (memberId == null || applicationId == null) {
                response.bIsSuccess = false;
                return response;
            }
            List<Id> individualIds = new List<Id>();
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualMemberData(applicationId, new Set<String>());
            if(applicationIndividuals != null) {
                for(SSP_ApplicationIndividual__c individual: applicationIndividuals) {
                    if(!individual.IsTMember__c) {
                        individualIds.add(individual.SSP_Member__c);
                    }
                }
            }
            Id absentParentRecordTypeId = Schema.SObjectType.SSP_NonCustodialParent__c.getRecordTypeInfosByName().get(SSP_GlobalConstants.ABSENT_PARENT).getRecordTypeId();
            List<String> fields = new List<String>{'SSP_NonCustodialParent__r.FirstName__c', 'SSP_NonCustodialParent__r.LastName__c', 'SSP_NonCustodialParent__r.GenderCode__c','SSP_NonCustodialParent__r.MiddleInitial__c',
                'SSP_Member__c','SSP_NonCustodialParent__r.DateOfBirth__c','SSP_NonCustodialParent__r.SuffixCode__c','SSP_NonCustodialParent__r.SSN__c'};
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_NoncustodialRelationship__c', 'IN' => 'SSP_Member__c', 'operator' => 'AND'};
            Map<String, String> conditionsMap = new Map<String, String>{'IsDeleted__c' => '#false#', 'SSP_Member__c' => String.join(individualIds, ','), 'SSP_NonCustodialParent__r.IsParentUnknown__c' => '#false#', 'SSP_NonCustodialParent__r.RecordTypeId' => absentParentRecordTypeId };
            List<SSP_NoncustodialRelationship__c> relationships = SSP_NonCustodialParentSelector.queryNonCustodialParentsRelationshipWithoutSharing(detailMap, new Set<String>(fields), conditionsMap);
            Map<Id, SSP_NonCustodialParent__c> recordsMap = new Map<Id, SSP_NonCustodialParent__c>();
            Set<Id> existingParentIds = new Set<Id>();
            for(SSP_NoncustodialRelationship__c relationship: relationships) {
                SSP_NonCustodialParent__c record = (SSP_NonCustodialParent__c)relationship.getSObject(SSP_NoncustodialRelationship__c.SSP_NonCustodialParent__c.getDescribe().getSObjectField());
                recordsMap.put(record.Id, record);
                if(relationship.SSP_Member__c == memberId) {
                    existingParentIds.add(record.Id);
                }
            }
            for(Id parentId: new List<Id>(existingParentIds)) {
                if(existingParentIds.contains(parentId)) {
                    recordsMap.remove(parentId);
                }
            }
            response.put('records', recordsMap.values());
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_AbsentParentController', 'fetchNonCustodialParents', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
    
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-20-2019
    * @methodname   linkParentRecord
    * @description  Method to link nonCustodialParent record to a member and removes existing one.
    * @return       New Record
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse linkParentRecord(Id memberId, Id recordId, Id existingRecordId, Boolean isParentUnknown) {
        SSP_LightningResponse response =  new SSP_LightningResponse();
        Savepoint sp = Database.setSavepoint();
        try {
            SSP_Utility.isAuthenticatedUser();
            response.put('newDetail', false);
            if (memberId == null || recordId == null) {
                response.bIsSuccess = false;
                return response;
            }
            if(recordId == existingRecordId) {
                response.bIsSuccess = true;
                return response;
            }
            List<String> fields = new List<String>{'SSP_Member__c', 'SSP_NonCustodialParent__c', 'DCNonCustodialRelationshipId__c', 'IsDeleted__c'};
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_NoncustodialRelationship__c', 'operator' => 'AND'};
            Map<String, String> conditionsMap = new Map<String, String>{'SSP_Member__c' => memberId, 'SSP_NonCustodialParent__c' => existingRecordId == null? '#null#' : existingRecordId};
            List<SSP_NoncustodialRelationship__c> relationships = SSP_SharingBypassFetcher.fetchRecords(detailMap, new Set<String>(fields), conditionsMap); // CD2 Security Fixes
            Boolean hasCreateAccess = ESAPI.accessController().isAuthorizedToCreate(SSP_NoncustodialRelationship__c.getSObjectType(), new List<String>{'SSP_Member__c', 'SSP_NonCustodialParent__c'});
            if(relationships != null && !relationships.isEmpty()) {
                for(SSP_NoncustodialRelationship__c relation: relationships) {
                    if(relation.DCNonCustodialRelationshipId__c != null) {
                        Boolean hasUpdateAccess = ESAPI.accessController().isAuthorizedToUpdate(SSP_NoncustodialRelationship__c.getSObjectType(), new List<String>{'IsDeleted__c'});
                        if(hasUpdateAccess) {
                            relation.IsDeleted__c = true;
                            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{relation}, 'update', 'SSP_NoncustodialRelationship__c'); // CD2 Security Fixes
                            response.put('deleted', relation);
                        }
                        if(hasCreateAccess) {
                            SSP_NoncustodialRelationship__c newRelation = new SSP_NoncustodialRelationship__c(SSP_Member__c = memberId, SSP_NonCustodialParent__c = recordId);
                            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{newRelation}, 'insert', 'SSP_NoncustodialRelationship__c'); // CD2 Security Fixes
                            response.put('relationship', newRelation);
                        }
                    }
                    else {
                        Boolean hasUpdateAccess = ESAPI.accessController().isAuthorizedToUpdate(SSP_NoncustodialRelationship__c.getSObjectType(), new List<String>{'SSP_NonCustodialParent__c'});
                        if(hasUpdateAccess) {
                            relation.SSP_NonCustodialParent__c = recordId;
                            ESAPI.accessController().updateAsUser(relation, new List<String>{'SSP_NonCustodialParent__c'}); 
                            response.put('relationship', relation);
                        }
                    }
                    break;
                }
            }
            else {
                if(hasCreateAccess) {
                    SSP_NoncustodialRelationship__c relation = new SSP_NoncustodialRelationship__c(SSP_Member__c = memberId, SSP_NonCustodialParent__c = recordId);
                    SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{relation}, 'insert', 'SSP_NoncustodialRelationship__c'); // CD2 Security Fixes
                    response.put('relationship', relation);
                }
            }
            response.put('newDetail', true);
            response.bIsSuccess = true;
        }
        catch (Exception e) {
            Database.rollback(sp);
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_AbsentParentController', 'linkParentRecord', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-20-2019
    * @methodname   updateParentRecord
    * @description  Method to link nonCustodialParent record to a member and removes existing one.
    * @return       New Record
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse updateParentRecord(Id memberId, Id recordId, SSP_NonCustodialParent__c parentRecord) {
        SSP_LightningResponse response =  new SSP_LightningResponse();
        Savepoint sp = Database.setSavepoint();
        try {
            SSP_Utility.isAuthenticatedUser();
            response.put('newDetail', false);
            if (memberId == null || parentRecord == null) {
                response.bIsSuccess = false;
                return response;
            }
            List<SSP_NonCustodialParent__c> records = new List<SSP_NonCustodialParent__c>();
            //'Start' OR 'Someone Else' scenario
            if(parentRecord.Id == null) {
                SSP_NonCustodialParent__c newRecord = parentRecord.clone();
                newRecord.SSP_Member__c = memberId;
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{newRecord}, 'insert', 'SSP_NonCustodialParent__c'); // CD2 Security Fixes
                response.put('record', newRecord);
                response.put('newDetail', true);
                SSP_LightningResponse linkingResponse = linkParentRecord(memberId, newRecord.Id, recordId, parentRecord.IsParentUnknown__c);
                response.mapResponse.putAll(linkingResponse.mapResponse);
            }
            //'Edit' scenario
            else {
                SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{parentRecord}, 'update', 'SSP_NonCustodialParent__c'); // CD2 Security Fixes
                response.put('record', parentRecord);
            }
            response.bIsSuccess = true;
        }
        catch (Exception e) {
            Database.rollback(sp);
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_AbsentParentController', 'linkParentRecord', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
}