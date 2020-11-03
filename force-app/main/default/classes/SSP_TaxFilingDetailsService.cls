/**
* @author: Karthik Gulla
* @Class Name: SSP_TaxFilingDetailsService
* @desc This class is used as a service class for Tax Filing details Functionality
* @Date 03-04-2020
MODIFICATION LOG :
* */
public with sharing class SSP_TaxFilingDetailsService {
    /**
    * @author: Karthik Gulla
    * @method: getRelationshipsForApplicationMembers
    * @desc This method is used to get Relationships for Tax Filing screen
    * @param {Set<Id> setMemberIds}
    * @return List<SSP_Relationship__c>
    * */
    public static List<SSP_Relationship__c> getRelationshipsForApplicationMembers(Set<Id> setMemberIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Relationship__c> lstRelationships = new List<SSP_Relationship__c>();
        try{            
            Set<Id> setRelationshipMembers = new Set<Id>();
            Map<Id,String> mapMemberToStatus = new Map<Id,String>();           
            mapConditions.put('SSP_Member__c',String.join(new List<Id>(setMemberIds), ','));
            lstRelationships = SSP_RelationshipSelector.queryRelationshipData(new Map<String, String>{'objectName'=>'SSP_Relationship__c','IN'=>'SSP_Member__c'}, 
                                                                                                        new Set<String>{'Id','SSP_Member__c','SSP_Member__r.IndividualId__c','SSP_MemberRelatedTo__c','SSP_MemberRelatedTo__r.IndividualId__c','RelationshipType__c'}, 
                                                                                                        mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsService', 'getRelationshipsForApplicationMembers', e.getMessage(), true);
        }
        return lstRelationships;
    }

    /**
    * @author: Karthik Gulla
    * @method: getApplicationDetailsForTaxFiling
    * @desc This method is used to get application Details for Tax Filing Details
    * @param {Set<Id> setApplicationIds}
    * @return List<SSP_Application__c>
    * */
    public static List<SSP_Application__c> getApplicationDetailsForTaxFiling(Set<Id> setApplicationIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
        try{            
            mapConditions.put('Id',String.join(new List<Id>(setApplicationIds), ','));
            lstApplications = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id','ProgramsApplied__c','Name','ApplicationId__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ResourcesService', 'getApplicationDetailsForTaxFiling', e.getMessage(), true);
        }
        return lstApplications;
    }
    
    /**
    * @author: Karthik Gulla
    * @method: getMembersTaxFilingDetails
    * @desc This method is used to get member tax filing Details 
    * @param {Set<Id> setMemberIds}
    * @return List<SSP_Member__c>
    * */
    public static List<SSP_Member__c> getMembersTaxFilingDetails(Set<Id> setMemberIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        try{            
            mapConditions.put('Id',String.join(new List<Id>(setMemberIds), ','));
            lstMembers = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id', 'Age__c','IndividualId__c','CanBuyCookWithHOH__c','LaTypeCode__c','TaxFilerMemberCurrent__r.IndividualId__c','TaxFilerMemberCurrent__c', 'TaxFilerMemberNext__c', 'TaxFilerStatusCurrentYear__c', 'TaxFilerStatusNextYear__c', 
                                                                'HasParentOrSiblingCurrentOutHousehold__c','HasParentOrSiblingNextOutHousehold__c','FirstName__c','LastName__c','Age__c','TaxFilingClaimingCurrent__c','TaxFilingClaimingNext__c','BirthDate__c',
                                                                'TaxFilerMemberCurrent__r.FirstName__c', 'TaxFilerMemberNext__r.FirstName__c','TaxFilerMemberCurrent__r.LastName__c', 'TaxFilerMemberNext__r.LastName__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsService', 'getMembersTaxFilingDetails', e.getMessage(), true);
        }
        return lstMembers;
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
            lstApplicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','IN'=>'SSP_Application__c'}, 
                                                                new Set<String>{'Id','SSP_Member__c' ,'SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','MemberProgramsApplied__c','ProgramsApplied__c','MedicaidType__c','MemberStatus__c','DCPrograms__c','IsHeadOfHousehold__c','IsTMember__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsService', 'getApplicationIndividuals', e.getMessage(), true);
        }
        return lstApplicationIndividuals;
    }

    /**
    * @author: Karthik Gulla
    * @method: getDependentTaxFilingDetailsCurrentYearFromMember
    * @desc This method is used to get dependent tax filing Details
    * @param {Set<Id> setMemberIds,String sMemberId}
    * @return List<SSP_Member__c>
    * */
    public static List<SSP_Member__c> getDependentTaxFilingDetailsCurrentYearFromMember(Set<Id> setMemberIds, String sMemberId){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        try{            
            mapConditions.put('Id',String.join(new List<Id>(setMemberIds), ','));
            mapConditions.put('TaxFilerMemberCurrent__c',sMemberId);
            lstMembers = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id','operator'=>'AND'}, 
                                                                new Set<String>{'Id','TaxFilerMemberCurrent__c','TaxFilerStatusCurrentYear__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsService', 'getDependentTaxFilingDetailsCurrentYearFromMember', e.getMessage(), true);
        }
        return lstMembers;
    }

    /**
    * @author: Karthik Gulla
    * @method: getDependentTaxFilingDetailsNextYearFromMember
    * @desc This method is used to get dependent tax filing Details
    * @param {Set<Id> setMemberIds,String sMemberId}
    * @return List<SSP_Member__c>
    * */
    public static List<SSP_Member__c> getDependentTaxFilingDetailsNextYearFromMember(Set<Id> setMemberIds, String sMemberId){
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        try{            
            mapConditions.put('Id',String.join(new List<Id>(setMemberIds), ','));
            mapConditions.put('TaxFilerMemberNext__c',sMemberId);
            lstMembers = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id','operator'=>'AND'}, 
                                                                new Set<String>{'Id','TaxFilerMemberNext__c','TaxFilerStatusNextYear__c'}, 
                                                                mapConditions);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsService', 'getDependentTaxFilingDetailsNextYearFromMember', e.getMessage(), true);
        }
        return lstMembers;
    }
}