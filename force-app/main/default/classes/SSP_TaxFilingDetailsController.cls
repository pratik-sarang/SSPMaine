/**
* @author: Karthik Gulla
* @Class Name: SSP_TaxFilingDetailsController
* @desc This class is used as a controller for Tax Filing details Functionality
* @Date 02-25-2020
MODIFICATION LOG :
* */ 
public with sharing class SSP_TaxFilingDetailsController {
    /**
    * @author: Karthik Gulla
    * @method: getTaxFilingDetailsForMember
    * @desc This method is used to get Tax filing details for a member
    * @param {String sMemberId}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse getTaxFilingDetailsForMember(Map<String,String> mapInputs){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Map<String,Object> mapReturnValues = new Map<String,Object>();
        Date dtEnrollmentStartDate;
        Date dtEnrollmentEndDate;
        String strApplicationId = mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.APPLICATIONID)) : SSP_GlobalConstants.EMPTY;
        String strMemberId = mapInputs.get(SSP_GlobalConstants.MEMBERID) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.MEMBERID)) : SSP_GlobalConstants.EMPTY;
        Set<Id> setMemberIds = new Set<Id>();
        try{
            setMemberIds.add(strMemberId);
            List<SSPTaxFilingConfigurations__c> lstTaxFilingConfigurations = SSPTaxFilingConfigurations__c.getall().values();
            Date dtDateToday = SSP_Utility.today();
            Integer iCurrentYear = dtDateToday.year();
            for(SSPTaxFilingConfigurations__c sspTaxFilingConfiguration : lstTaxFilingConfigurations){
                if(String.valueOf(iCurrentYear) == sspTaxFilingConfiguration.CurrentYear__c){
                   mapReturnValues.put(SSP_GlobalConstants.CURRENTENROLLMENTYEAR, iCurrentYear + 1);
                   dtEnrollmentStartDate = sspTaxFilingConfiguration.Enrollment_StartDate__c;
                   dtEnrollmentEndDate = sspTaxFilingConfiguration.Enrollment_EndDate__c;
                }
                mapReturnValues.put(SSP_GlobalConstants.ISINOPENENROLLMENT, SSP_TaxFilingDetailsController.isCurrentDateWithinEnrollmentDates(dtDateToday, dtEnrollmentStartDate, dtEnrollmentEndDate));
            }
            clsLightningResponse = SSP_ResourcesService.buildResponse(SSP_GlobalConstants.TAXFILINGDETAILS, JSON.serializePretty(mapReturnValues));
            
            List<SSP_Member__c> lstTaxFilingMembers = SSP_TaxFilingDetailsController.getTaxFilingDetailsForApplicationMembers(strApplicationId, strMemberId);
            Map<String,SSP_TaxFilingDetailsController.TaxFilingDetailsWrapper> mapTaxFilingMembers = new Map<String,SSP_TaxFilingDetailsController.TaxFilingDetailsWrapper>();
            for(SSP_Member__c sspMember : lstTaxFilingMembers){
                SSP_TaxFilingDetailsController.TaxFilingDetailsWrapper taxFilingWrapper = new SSP_TaxFilingDetailsController.TaxFilingDetailsWrapper();
                taxFilingWrapper.strMemberId = sspMember.Id;
                taxFilingWrapper.strMemberName = sspMember.FirstName__c + ' ' + sspMember.LastName__c;
                taxFilingWrapper.strTaxFilingStatusCurrentYear = sspMember.TaxFilerStatusCurrentYear__c;
                taxFilingWrapper.strTaxFilingStatusNextYear = sspMember.TaxFilerStatusNextYear__c;
                taxFilingWrapper.strTaxFilerMemberCurrentYear = sspMember.TaxFilerMemberCurrent__c;
                taxFilingWrapper.strTaxFilerMemberNextYear = sspMember.TaxFilerMemberNext__c;
                taxFilingWrapper.strTaxFilingClaimingCurrentYear = sspMember.TaxFilingClaimingCurrent__c;
                taxFilingWrapper.strTaxFilingClaimingNextYear = sspMember.TaxFilingClaimingNext__c;
                taxFilingWrapper.strHasParentOrSiblingOutOfHouseholdCurrentYear = sspMember.HasParentOrSiblingCurrentOutHousehold__c;
                taxFilingWrapper.strHasParentOrSiblingOutOfHouseholdNextYear = sspMember.HasParentOrSiblingNextOutHousehold__c;
                taxFilingWrapper.strTaxFilerMemberCurrentYearName = sspMember.TaxFilerMemberCurrent__r.FirstName__c + ' ' + sspMember.TaxFilerMemberCurrent__r.LastName__c;
                taxFilingWrapper.strTaxFilerMemberNextYearName = sspMember.TaxFilerMemberNext__r.FirstName__c + ' ' + sspMember.TaxFilerMemberNext__r.LastName__c;
                taxFilingWrapper.iMemberAge = sspMember.Age__c;
                mapTaxFilingMembers.put(sspMember.Id, taxFilingWrapper);
            }
            clsLightningResponse.put(SSP_GlobalConstants.TAXFILINGMEMBERS, JSON.serializePretty(mapTaxFilingMembers));

            List<SSP_TaxFilingDetailsController.RelationshipWrapper> lstRelationshipDetails = new List<SSP_TaxFilingDetailsController.RelationshipWrapper>();
            List<SSP_Relationship__c> lstRelationships = SSP_TaxFilingDetailsController.filterActiveRelationships(SSP_TaxFilingDetailsService.getRelationshipsForApplicationMembers(setMemberIds),strApplicationId);
            if(lstRelationships != null && lstRelationships.size()>0){
                for(SSP_Relationship__c sspRelationship : lstRelationships){
                    SSP_TaxFilingDetailsController.RelationshipWrapper relationshipWrapper = new SSP_TaxFilingDetailsController.RelationshipWrapper();
                    relationshipWrapper.strRelationshipType = sspRelationship.RelationshipType__c;
                    relationshipWrapper.strMemberId = sspRelationship.SSP_Member__c;
                    relationshipWrapper.strRelatedMemberId = sspRelationship.SSP_MemberRelatedTo__c;
                    lstRelationshipDetails.add(relationshipWrapper);
                }
            }
            clsLightningResponse.put(SSP_GlobalConstants.RELATIONSHIPS, JSON.serializePretty(lstRelationshipDetails));
            clsLightningResponse.bIsSuccess = true;
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'getTaxFilingDetailsForMember', e.getMessage(), true);
        }
        return clsLightningResponse;
    }

    /**
    * @author: Karthik Gulla
    * @method: isCurrentDateWithinEnrollmentDates
    * @desc This method is used to check whether time trvel date is in open enrollment
    * @param {Date today, Date startDate, Date endDate}
    * @return Boolean
    * */
    public static Boolean isCurrentDateWithinEnrollmentDates(Date today, Date startDate, Date endDate){
        Boolean bReturnValue = false;
        try{            
            if(startDate <= today && today <= endDate){
                bReturnValue = true;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'isCurrentDateWithinEnrollmentDates', e.getMessage(), true);
        }
        return bReturnValue;
    }

     /**
    * @author: Karthik Gulla
    * @method: updateTaxFilingDetails
    * @desc This method is used to get update tax filing details entered by user
    * @params {String sUpdatedValues}
    * @return SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse updateTaxFilingDetails(String sUpdatedValues){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        Map<String, SSP_Member__c> mapMembers = new Map<String, SSP_Member__c>();
        List<String> lstClaimingDependentsStatusList = new List<String> {'HH', 'QW', 'SI'};
        List<String> lstMarriedStatusList = new List<String> {'FJ', 'FS'};
        try{
            Map<String,Object> mapInputs = (Map<String,Object>)JSON.deserializeUntyped(sUpdatedValues);
            Id currentMemberId = mapInputs.get(SSP_GlobalConstants.MEMBERID) != null ? Id.valueOf(String.valueOf(mapInputs.get(SSP_GlobalConstants.MEMBERID))) : SSP_GlobalConstants.EMPTY;
            Id currentApplicationId = mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null ? Id.valueOf(String.valueOf(mapInputs.get(SSP_GlobalConstants.APPLICATIONID))) : SSP_GlobalConstants.EMPTY;
            if(currentMemberId != null 
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) == 'DM'){
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null){
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerStatusCurrentYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR)) : null;
                sspFlowMember.TaxFilerMemberCurrent__c = Id.valueOf(String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERCURRENT)));
                sspFlowMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                mapMembers.put(sspFlowMember.Id, sspFlowMember);
            }

            if(currentMemberId != null 
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) == 'DM'){
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null){
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerStatusNextYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR)) : null;
                sspFlowMember.TaxFilerMemberNext__c = Id.valueOf(String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERNEXT)));
                mapMembers.put(sspFlowMember.Id, sspFlowMember);
            }

            if (mapInputs.get(SSP_GlobalConstants.MEMBERID) != null 
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) == 'DN') {
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null){
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerStatusCurrentYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR)) : null;
                sspFlowMember.TaxFilerMemberCurrent__c = null;
                sspFlowMember.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                sspFlowMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                mapMembers.put(sspFlowMember.Id, sspFlowMember);
            } 
            
            if (mapInputs.get(SSP_GlobalConstants.MEMBERID) != null 
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) == 'DN') {
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null){
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerStatusNextYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR)) : null;
                sspFlowMember.TaxFilerMemberNext__c = null;
                sspFlowMember.HasParentOrSiblingNextOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD)) : null;
                mapMembers.put(sspFlowMember.Id, sspFlowMember);
            }

            if(currentMemberId != null 
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null
            && (mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) == 'FJ' || mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) == 'FS')) {
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null){
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerStatusCurrentYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR)) : null;
                sspFlowMember.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                sspFlowMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                sspFlowMember.TaxFilingClaimingCurrent__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGCURRENTYEAR) != null) ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGCURRENTYEAR)) : null;
                mapMembers.put(sspFlowMember.Id, sspFlowMember);

                Set<Id> setRelMemberIds = new Set<Id>();
                setRelMemberIds.add(sspFlowMember.Id);
		
		
		        List<SSP_Relationship__c> lstRelationships = SSP_TaxFilingDetailsController.filterActiveRelationships(SSP_TaxFilingDetailsService.getRelationshipsForApplicationMembers(setRelMemberIds),currentApplicationId);
                for(SSP_Relationship__c sspRelationship : lstRelationships){
                    Id currentRelatedMemberId = Id.valueOf(String.valueOf(sspRelationship.SSP_MemberRelatedTo__c));
                    SSP_Member__c sspFlowMember1 = new SSP_Member__c();
                    if(sspRelationship.RelationshipType__c == 'SP'){
                        if(mapMembers.get(currentRelatedMemberId) != null){
                            sspFlowMember1 = mapMembers.get(currentRelatedMemberId);
                        } else {
                            sspFlowMember1.Id = currentRelatedMemberId;
                        }
                        sspFlowMember1.TaxFilerStatusCurrentYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR)) : null;
                        sspFlowMember1.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                        sspFlowMember1.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                        mapMembers.put(sspFlowMember1.Id, sspFlowMember1);
                    }
                }

                if(mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERCURRENT) != null){
                    for(Object objMember : (List<Object>)mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERCURRENT)){
                        String strMember = String.valueOf(objMember);
                        SSP_Member__c sspTaxFilingMember = new SSP_Member__c();
                        if(mapMembers.get(strMember) != null){
                            sspTaxFilingMember = mapMembers.get(strMember);
                        } else {
                            sspTaxFilingMember.Id = strMember;
                        }
                        sspTaxFilingMember.TaxFilerStatusCurrentYear__c = 'DM';
                        sspTaxFilingMember.TaxFilerMemberCurrent__c = Id.valueOf(String.valueOf(mapInputs.get(SSP_GlobalConstants.MEMBERID)));
                        sspTaxFilingMember.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                        sspTaxFilingMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                        mapMembers.put(strMember, sspTaxFilingMember);
                    }
                }
            } 
            
            if(currentMemberId != null 
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null
            && (mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) == 'FJ' || mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) == 'FS')) {
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null){
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerStatusNextYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR)) : null;
                sspFlowMember.HasParentOrSiblingNextOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD)) : null;
                sspFlowMember.TaxFilingClaimingNext__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGNEXTYEAR) != null) ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGNEXTYEAR)) : null;

                mapMembers.put(sspFlowMember.Id, sspFlowMember);

                Set<Id> setRelMemberIds = new Set<Id>();
                setRelMemberIds.add(sspFlowMember.Id);
                List<SSP_Relationship__c> lstRelationships = SSP_TaxFilingDetailsController.filterActiveRelationships(SSP_TaxFilingDetailsService.getRelationshipsForApplicationMembers(setRelMemberIds), currentApplicationId);
                for(SSP_Relationship__c sspRelationship : lstRelationships){
                    Id currentRelatedMemberId = Id.valueOf(String.valueOf(sspRelationship.SSP_MemberRelatedTo__c));
                    if(sspRelationship.RelationshipType__c == 'SP'){
                        SSP_Member__c sspFlowMember1 = new SSP_Member__c();
                        if(mapMembers.get(currentRelatedMemberId) != null){
                            sspFlowMember1 = mapMembers.get(currentRelatedMemberId);
                        } else {
                            sspFlowMember1.Id = currentRelatedMemberId;
                        }
                        sspFlowMember1.TaxFilerStatusNextYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR)) : null;
                        sspFlowMember1.HasParentOrSiblingNextOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD)) : null;
                        mapMembers.put(sspFlowMember1.Id, sspFlowMember1);
                    }
                }

                if(mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERNEXT) != null){
                    for(Object objMember : (List<Object>)mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERNEXT)){
                        String strMember = String.valueOf(objMember);
                        SSP_Member__c sspTaxFilingMember = new SSP_Member__c();
                        if(mapMembers.get(strMember) != null){
                            sspTaxFilingMember = mapMembers.get(strMember);
                        } else {
                            sspTaxFilingMember.Id = strMember;
                        }
                        sspTaxFilingMember.TaxFilerStatusNextYear__c = 'DM';
                        sspTaxFilingMember.TaxFilerMemberNext__c = Id.valueOf(String.valueOf(mapInputs.get(SSP_GlobalConstants.MEMBERID)));
                        sspTaxFilingMember.HasParentOrSiblingNextOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD)) : null;
                        mapMembers.put(strMember, sspTaxFilingMember);
                    }
                }
            }

            if(currentMemberId != null
            && (mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null && lstClaimingDependentsStatusList.contains(String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR)))
            || (mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null && lstClaimingDependentsStatusList.contains(String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR)))))) {
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null){
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerStatusCurrentYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR)) : null;
                sspFlowMember.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                sspFlowMember.TaxFilerStatusNextYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR)) : null;
                sspFlowMember.HasParentOrSiblingNextOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD)) : null;
                sspFlowMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                sspFlowMember.TaxFilingClaimingCurrent__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGCURRENTYEAR) != null) ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGCURRENTYEAR)) : null;
                sspFlowMember.TaxFilingClaimingNext__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGNEXTYEAR) != null) ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGCLAIMINGNEXTYEAR)) : null;
                mapMembers.put(sspFlowMember.Id, sspFlowMember);

                if(mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERCURRENT) != null){
                    for(Object objMember : (List<Object>)mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERCURRENT)){
                        String strMember = String.valueOf(objMember);
                        SSP_Member__c sspTaxFilingMember = new SSP_Member__c();
                        if(mapMembers.get(strMember) != null){
                            sspTaxFilingMember = mapMembers.get(strMember);
                        } else {
                            sspTaxFilingMember.Id = strMember;
                        }
                        sspTaxFilingMember.TaxFilerStatusCurrentYear__c = lstClaimingDependentsStatusList.contains(String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR))) ? 'DM' : SSP_GlobalConstants.EMPTY;
                        sspTaxFilingMember.TaxFilerMemberCurrent__c = Id.valueOf(String.valueOf(mapInputs.get(SSP_GlobalConstants.MEMBERID)));
                        sspTaxFilingMember.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                        sspTaxFilingMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                        mapMembers.put(strMember, sspTaxFilingMember);
                    }
                } else {
                    List<SSP_Member__c> lstCurrentAppDependentMembers = SSP_TaxFilingDetailsService.getDependentTaxFilingDetailsCurrentYearFromMember(SSP_TaxFilingDetailsController.getCurrentApplicationMemberIds(currentApplicationId), currentMemberId);
                    for(SSP_Member__c objMember : lstCurrentAppDependentMembers){
                        SSP_Member__c sspTaxFilingMember = new SSP_Member__c();
                        if(mapMembers.get(objMember.Id) != null){
                            sspTaxFilingMember = mapMembers.get(objMember.Id);
                        } else {
                            sspTaxFilingMember.Id = objMember.Id;
                        }
                        sspTaxFilingMember.TaxFilerStatusCurrentYear__c = null;
                        sspTaxFilingMember.TaxFilerMemberCurrent__c = null;
                        sspTaxFilingMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                        mapMembers.put(objMember.Id, sspTaxFilingMember);
                    }
                }

                if(mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERNEXT) != null){
                    for(Object objMember : (List<Object>)mapInputs.get(SSP_GlobalConstants.TAXFILERMEMBERNEXT)){
                        String strMember = String.valueOf(objMember);
                        SSP_Member__c sspTaxFilingMember = new SSP_Member__c();
                        if(mapMembers.get(strMember) != null){
                            sspTaxFilingMember = mapMembers.get(strMember);
                        } else {
                            sspTaxFilingMember.Id = strMember;
                        }
                        sspTaxFilingMember.TaxFilerStatusNextYear__c = lstClaimingDependentsStatusList.contains(String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR))) ? 'DM' : SSP_GlobalConstants.EMPTY;
                        sspTaxFilingMember.TaxFilerMemberNext__c = currentMemberId;
                        sspTaxFilingMember.HasParentOrSiblingNextOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD)) : null;
                        mapMembers.put(strMember, sspTaxFilingMember);
                    }
                } else {
                    List<SSP_Member__c> lstNextAppDependentMembers = SSP_TaxFilingDetailsService.getDependentTaxFilingDetailsNextYearFromMember(SSP_TaxFilingDetailsController.getCurrentApplicationMemberIds(currentApplicationId), currentMemberId);
                    for(SSP_Member__c objMember : lstNextAppDependentMembers){
                        SSP_Member__c sspTaxFilingMember = new SSP_Member__c();
                        if(mapMembers.get(objMember.Id) != null){
                            sspTaxFilingMember = mapMembers.get(objMember.Id);
                        } else {
                            sspTaxFilingMember.Id = objMember.Id;
                        }
                        sspTaxFilingMember.TaxFilerStatusNextYear__c = null;
                        sspTaxFilingMember.TaxFilerMemberNext__c = null;
                        sspTaxFilingMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                        mapMembers.put(objMember.Id, sspTaxFilingMember);
                    }
                }
            }

            if(currentMemberId != null 
            && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null
            && (mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) == 'NA' ||  mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) == 'NF')) {
                SSP_Member__c sspTaxFilingMember = new SSP_Member__c();
                sspTaxFilingMember.Id = currentMemberId;
                sspTaxFilingMember.TaxFilerStatusCurrentYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR)) : null;
                sspTaxFilingMember.TaxFilerStatusNextYear__c = mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSNEXTYEAR)) : null;
                sspTaxFilingMember.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                sspTaxFilingMember.HasParentOrSiblingNextOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGNEXTOUTHOUSEHOLD)) : null;
                sspTaxFilingMember.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                mapMembers.put(sspTaxFilingMember.Id, sspTaxFilingMember);

                Set<Id> setRelMemberIds = new Set<Id>();
                setRelMemberIds.add(sspTaxFilingMember.Id);

                List<SSP_Relationship__c> lstRelationships = SSP_TaxFilingDetailsController.filterActiveRelationships(SSP_TaxFilingDetailsService.getRelationshipsForApplicationMembers(setRelMemberIds),currentApplicationId);
                for(SSP_Relationship__c sspRelationship : lstRelationships){
                    Id currentRelatedMemberId = Id.valueOf(String.valueOf(sspRelationship.SSP_MemberRelatedTo__c));
                    SSP_Member__c sspFlowMember1 = new SSP_Member__c();
                    if(sspRelationship.RelationshipType__c == 'SP'
                        && mapInputs.get(SSP_GlobalConstants.PREVIOUSTAXFILINGSTATUS) != null
                        && mapInputs.get(SSP_GlobalConstants.PREVIOUSTAXFILINGSTATUS) == 'FJ'){
                        if(mapMembers.get(currentRelatedMemberId) != null){
                            sspFlowMember1 = mapMembers.get(currentRelatedMemberId);
                        } else {
                            sspFlowMember1.Id = currentRelatedMemberId;
                        }
                        sspFlowMember1.TaxFilerStatusCurrentYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) != null && mapInputs.get(SSP_GlobalConstants.TAXFILERSTATUSCURRENTYEAR) == 'NF')? 'FS' : null;
                        sspFlowMember1.HasParentOrSiblingCurrentOutHousehold__c = mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD) != null ? String.valueOf(mapInputs.get(SSP_GlobalConstants.HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD)) : null;
                        sspFlowMember1.TaxFilingSameNextYear__c = (mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR) != null && String.valueOf(mapInputs.get(SSP_GlobalConstants.TAXFILINGSAMENEXTYEAR)) == SSP_GlobalConstants.YES) ? true : false;
                        mapMembers.put(sspFlowMember1.Id, sspFlowMember1);
                    }
                }
            }

            if(currentMemberId != null && mapInputs.get(SSP_GlobalConstants.PREVIOUSTAXFILINGSTATUS) == 'DM') {
                SSP_Member__c sspFlowMember = new SSP_Member__c();
                if(mapMembers.get(currentMemberId) != null) {
                    sspFlowMember = mapMembers.get(currentMemberId);
                } else {
                    sspFlowMember.Id = currentMemberId;
                }
                sspFlowMember.TaxFilerMemberCurrent__c = null;
                mapMembers.put(sspFlowMember.Id, sspFlowMember);
            }
            
            List<SSP_Member__c> lstTobeUpdatedMembers = mapMembers.values();
            Map<String, Object> reviewRequiredResponse = fireReviewRequiredRules(currentApplicationId, currentMemberId, mapMembers);
            clsLightningResponse.put(SSP_GlobalConstants.REVIEWREQUIREDRESPONSE, reviewRequiredResponse);
            Set<String> setAccessFields = new Set<String>();
            if(!lstTobeUpdatedMembers.isEmpty()){
                SSP_GenericDMLHelper.updateRecords(lstTobeUpdatedMembers,new List<String>{'HasParentOrSiblingNextOutHousehold__c','TaxFilerStatusNextYear__c','TaxFilerMemberNext__c','TaxFilerMemberCurrent__c',
                                                                                            'TaxFilingClaimingNext__c','TaxFilingClaimingCurrent__c','TaxFilingSameNextYear__c',
                                                                                            'HasParentOrSiblingCurrentOutHousehold__c','TaxFilerStatusCurrentYear__c'});//Perf fix - Keshav
            }
            //Shikha - Defect 3676added for tax filing review required
            List<SSP_ApplicationIndividual__c> appIndividualList =             
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND', 'MemberStatus__c' => '!='}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c','IsTaxRRCompleted__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(currentApplicationId),
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(currentMemberId),'MemberStatus__c'=> 'Removed'});
            if(!appIndividualList.isEMpty()){
                List<SSPTaxFilingConfigurations__c> lstTaxFilingConfigurations = SSPTaxFilingConfigurations__c.getall().values();
            	Date dtDateToday = SSP_Utility.today();
            	Integer iCurrentYear = dtDateToday.year();
                Map<String,Boolean> mapVal = new Map<String,Boolean>();
                Date dtEnrollmentStartDate;
                Date dtEnrollmentEndDate;
            	for(SSPTaxFilingConfigurations__c sspTaxFilingConfiguration : lstTaxFilingConfigurations){
                	if(String.valueOf(iCurrentYear) == sspTaxFilingConfiguration.CurrentYear__c){                   		
                   		dtEnrollmentStartDate = sspTaxFilingConfiguration.Enrollment_StartDate__c;
                   		dtEnrollmentEndDate = sspTaxFilingConfiguration.Enrollment_EndDate__c;
                	}
                	mapVal.put(SSP_GlobalConstants.ISINOPENENROLLMENT, SSP_TaxFilingDetailsController.isCurrentDateWithinEnrollmentDates(dtDateToday, dtEnrollmentStartDate, dtEnrollmentEndDate));
            	}
                if(mapVal.get(SSP_GlobalConstants.ISINOPENENROLLMENT)){
                    appIndividualList[0].IsTaxRRCompleted__c = true;    
                    SSP_ApplicationIndividual__c appIndividualObj = new SSP_ApplicationIndividual__c ();
                    appIndividualObj.Id = appIndividualList[0].id;
                    appIndividualObj.IsTaxRRCompleted__c = appIndividualList[0].IsTaxRRCompleted__c;
                    SSP_GenericDMLHelper.updateRecords(new List<SSP_ApplicationIndividual__c>{appIndividualObj}, new List<String> {'IsTaxRRCompleted__c'});
                }
            }
            clsLightningResponse.bIsSuccess = true;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'updateTaxFilingDetails', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    }

     /**
    * @author: Karthik Gulla
    * @method: getTaxFilingDetailsForApplicationMembers
    * @desc This method is used to get taxfiling details for application members
    * @params {String sApplicationId, String sMemberId}
    * @return List<SSP_Member__c>
    * */
    public static List<SSP_Member__c> getTaxFilingDetailsForApplicationMembers(String sApplicationId, String sMemberId){
        Set<Id> setMemberIds = new Set<Id>();
        try{
            //added below code for performance improvement - Keshav
            Map<String,String> mapConditions = new Map<String,String>();
            List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = new List<SSP_ApplicationIndividual__c>();
            
            mapConditions.put('SSP_Application__c',String.join(new List<Id>{Id.valueOf(sApplicationId)}, ','));
            lstApplicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','IN'=>'Id'}, 
                                                                                                            new Set<String>{'Id','SSP_Member__c'}, 
                                                                                                            mapConditions);
            if(lstApplicationIndividuals != null && lstApplicationIndividuals.size()>0){
                for(SSP_ApplicationIndividual__c appIndiv : lstApplicationIndividuals){
                    setMemberIds.add(appIndiv.SSP_Member__c);
                }
            }
            
            List<SSP_Member__c> lstHouseholdMembersTaxFiling = SSP_TaxFilingDetailsService.getMembersTaxFilingDetails(setMemberIds);
            
            return lstHouseholdMembersTaxFiling;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'getTaxFilingDetailsForApplicationMembers', e.getMessage(), true);
            return null;
        }
    }

     /**
    * @author: Karthik Gulla
    * @method: invokeTMemberServiceCall
    * @desc This method is used to get file cleared value using T Member Service call
    * @params {String sApplicationId}
    * @return List<SSP_Member__c>
    * */
    public static Map<String,Boolean> invokeTMemberServiceCall(String sApplicationId, List<SSP_ResourcesWrapper.HouseholdMemberWrapper> lstHouseholdMembers){
        Map<String,Boolean> mapTMemberValues = new Map<String,Boolean>();       
        try{
            Set<Id> setMemberIds = new Set<Id>();
            Set<Id> setApplicationIds = new Set<Id>();
            Map<Id,Boolean> mapAppHeadofHouseholds = new Map<Id,Boolean>();
            setApplicationIds.add(sApplicationId);

            for(SSP_ResourcesWrapper.HouseholdMemberWrapper sspHouseholdMemberWrapper : lstHouseholdMembers){
                setMemberIds.add(sspHouseholdMemberWrapper.strMemberId);
                mapAppHeadofHouseholds.put(sspHouseholdMemberWrapper.strMemberId, sspHouseholdMemberWrapper.bHeadOfHousehold);
            }

            Map<String, SSP_Member__c> mapMembers = new Map<String, SSP_Member__c>();
            Map<String, String> mapIndividualToMembers = new Map<String, String>();
            for(SSP_Member__c sspMember : SSP_TaxFilingDetailsService.getMembersTaxFilingDetails(setMemberIds)){
                mapMembers.put(sspMember.Id, sspMember);
                if(sspMember.IndividualId__c != null){
                    mapIndividualToMembers.put(sspMember.IndividualId__c, sspMember.Id);
                }
            }
           
            Map<String, List<SSP_Relationship__c>> mapRelationships = new Map<String, List<SSP_Relationship__c>>();
            List<SSP_Relationship__c> lstNewRelationships = new List<SSP_Relationship__c>();
            for(SSP_Relationship__c sspRelationship : SSP_TaxFilingDetailsController.filterActiveRelationships(SSP_TaxFilingDetailsService.getRelationshipsForApplicationMembers(setMemberIds),sApplicationId)){
                if(mapRelationships.get(sspRelationship.SSP_Member__c) != null){
                    mapRelationships.get(sspRelationship.SSP_Member__c).add(sspRelationship);
                } else {
                    lstNewRelationships.clear();
                    lstNewRelationships.add(sspRelationship);
                    List<SSP_Relationship__c> lstTempRelationships = lstNewRelationships.clone();
                    mapRelationships.put(sspRelationship.SSP_Member__c, lstTempRelationships);
                }
            }

            List<SSP_Application__c> lstApplications = SSP_TaxFilingDetailsService.getApplicationDetailsForTaxFiling(setApplicationIds);
            SSP_TMemberDataContract.SSPCaseRequest sspTMemberDataContractRequest = new SSP_TMemberDataContract.SSPCaseRequest();
            sspTMemberDataContractRequest.CaseNumber = lstApplications[0].ApplicationId__c != null ? Integer.valueOf(lstApplications[0].ApplicationId__c) : 0;
            sspTMemberDataContractRequest.ApplicationNumber = Integer.valueOf(lstApplications[0].Name);
            sspTMemberDataContractRequest.SourceSystem = SSP_GlobalConstants.SSP;
            sspTMemberDataContractRequest.SystemDate = SSP_Utility.today();

            List<SSP_TMemberDataContract.SSPProgram> lstProgramCodes = new List<SSP_TMemberDataContract.SSPProgram>();
            List<SSP_TMemberDataContract.SSPIndividual> lstTMemberDataContractIndividuals = new List<SSP_TMemberDataContract.SSPIndividual>();
            List<String> lstProgramsAppliedCode = new List<String>();
            List<String> lstEmpty = new List<String>();
            List<String> lstDCProgramsCode = new List<String>();
            Set<String> setPrograms = new Set<String>();
            List<SSP_TMemberDataContract.SSPRelationship> lstTMemberRelationships = new List<SSP_TMemberDataContract.SSPRelationship>();
            
            for(SSP_ResourcesWrapper.HouseholdMemberWrapper sspHHMemberWrapper: lstHouseholdMembers){
                lstProgramsAppliedCode = sspHHMemberWrapper.strMemberPrograms != null ? sspHHMemberWrapper.strMemberPrograms.split(';') : lstEmpty;
                lstDCProgramsCode = sspHHMemberWrapper.strDCPrograms != null ? sspHHMemberWrapper.strDCPrograms.split(';') : lstEmpty;
                setPrograms.addAll(lstProgramsAppliedCode);
                setPrograms.addAll(lstDCProgramsCode);

                for(String strProgram:setPrograms){
                    SSP_TMemberDataContract.SSPProgram sspProgramCode = new SSP_TMemberDataContract.SSPProgram();
                    sspProgramCode.ProgramCode = strProgram;
                    lstProgramCodes.add(sspProgramCode);
                }
                
                SSP_TMemberDataContract.SSPIndividual objTMemberIndividual = new SSP_TMemberDataContract.SSPIndividual();
                objTMemberIndividual.AppliedForKTAP = (sspHHMemberWrapper.strMemberPrograms != null && sspHHMemberWrapper.strMemberPrograms.contains(SSP_GlobalConstants.KTAP)) || (sspHHMemberWrapper.strDCPrograms != null && sspHHMemberWrapper.strDCPrograms.contains(SSP_GlobalConstants.KTAP));
                objTMemberIndividual.AppliedForCC = (sspHHMemberWrapper.strMemberPrograms != null && sspHHMemberWrapper.strMemberPrograms.contains(SSP_GlobalConstants.CHILDCARE)) || (sspHHMemberWrapper.strDCPrograms != null && sspHHMemberWrapper.strDCPrograms.contains(SSP_GlobalConstants.CHILDCARE));
                objTMemberIndividual.AppliedForSNAP = (sspHHMemberWrapper.strMemberPrograms != null && sspHHMemberWrapper.strMemberPrograms.contains(SSP_GlobalConstants.SNAP)) || (sspHHMemberWrapper.strDCPrograms != null && sspHHMemberWrapper.strDCPrograms.contains(SSP_GlobalConstants.SNAP));
                objTMemberIndividual.AppliedForMA = (sspHHMemberWrapper.strMemberPrograms != null && sspHHMemberWrapper.strMemberPrograms.contains(SSP_GlobalConstants.MEDICAID)) || (sspHHMemberWrapper.strDCPrograms != null && sspHHMemberWrapper.strDCPrograms.contains(SSP_GlobalConstants.MEDICAID));
                objTMemberIndividual.AppliedForSS = (sspHHMemberWrapper.strMemberPrograms != null && sspHHMemberWrapper.strMemberPrograms.contains(SSP_GlobalConstants.STATE)) || (sspHHMemberWrapper.strDCPrograms != null && sspHHMemberWrapper.strDCPrograms.contains(SSP_GlobalConstants.STATE));

                objTMemberIndividual.IndividualAge = (mapMembers.get(sspHHMemberWrapper.strMemberId) !=null && mapMembers.get(sspHHMemberWrapper.strMemberId).BirthDate__c != null )? mapMembers.get(sspHHMemberWrapper.strMemberId).BirthDate__c.monthsBetween(SSP_Utility.today()): null;                
                objTMemberIndividual.HouseholdStatus = SSP_GlobalConstants.TMEMBERHOUSEHOLDSTATUS;
                objTMemberIndividual.IndividualId = (mapMembers.get(sspHHMemberWrapper.strMemberId) != null && mapMembers.get(sspHHMemberWrapper.strMemberId).IndividualId__c != null) ? Long.valueOf(String.valueOf(mapMembers.get(sspHHMemberWrapper.strMemberId).IndividualId__c)) : null;
                objTMemberIndividual.IsHeadOfHousehold = sspHHMemberWrapper.bHeadOfHousehold;
                objTMemberIndividual.LivingArrangement = mapMembers.get(sspHHMemberWrapper.strMemberId) != null ? mapMembers.get(sspHHMemberWrapper.strMemberId).LaTypeCode__c : null;
                objTMemberIndividual.PurchasesAndPreparesTogether = mapMembers.get(sspHHMemberWrapper.strMemberId) != null ? mapMembers.get(sspHHMemberWrapper.strMemberId).CanBuyCookWithHOH__c : null;
                objTMemberIndividual.DependentIndividualId = (mapMembers.get(sspHHMemberWrapper.strMemberId) != null && mapMembers.get(sspHHMemberWrapper.strMemberId).TaxFilerMemberCurrent__r.IndividualId__c != null) ? Long.valueOf(mapMembers.get(sspHHMemberWrapper.strMemberId).TaxFilerMemberCurrent__r.IndividualId__c) : null;
                objTMemberIndividual.TaxFilingStatus = (mapMembers.get(sspHHMemberWrapper.strMemberId) != null) ? mapMembers.get(sspHHMemberWrapper.strMemberId).TaxFilerStatusCurrentYear__c : null;
               
                List<SSP_Relationship__c> lstRelationships = mapRelationships.get(sspHHMemberWrapper.strMemberId);
                lstTMemberRelationships.clear();
                for(SSP_Relationship__c sspRelationship : lstRelationships){
                    SSP_TMemberDataContract.SSPRelationship objRelationship = new SSP_TMemberDataContract.SSPRelationship();
                    objRelationship.IndividualId = sspRelationship.SSP_Member__r.IndividualId__c != null ? Long.valueOf(String.valueOf(sspRelationship.SSP_Member__r.IndividualId__c)) : null;
                    objRelationship.ReferenceIndividualId = sspRelationship.SSP_MemberRelatedTo__r.IndividualId__c != null ? Long.valueOf(String.valueOf(sspRelationship.SSP_MemberRelatedTo__r.IndividualId__c)) : null;
                    objRelationship.RelationshipTypeCode = sspRelationship.RelationshipType__c;
                    lstTMemberRelationships.add(objRelationship);
                }
                List<SSP_TMemberDataContract.SSPRelationship> lstTempTMemberRelationships = lstTMemberRelationships.clone();
               
                SSP_TMemberDataContract.ArrayOfSSPRelationship objArrayRelationships = new SSP_TMemberDataContract.ArrayOfSSPRelationship();
                objArrayRelationships.SSPRelationship = lstTempTMemberRelationships;
                objTMemberIndividual.Relationship = objArrayRelationships;
                lstTMemberDataContractIndividuals.add(objTMemberIndividual);
            }

            SSP_TMemberDataContract.ArrayOfSSPProgram objArrayPrograms = new SSP_TMemberDataContract.ArrayOfSSPProgram();
            objArrayPrograms.SSPProgram = lstProgramCodes;
            sspTMemberDataContractRequest.ProgramCodes = objArrayPrograms;

            SSP_TMemberDataContract.ArrayOfSSPIndividual objArrayOfIndividuals = new SSP_TMemberDataContract.ArrayOfSSPIndividual();
            objArrayOfIndividuals.SSPIndividual = lstTMemberDataContractIndividuals;
            sspTMemberDataContractRequest.Individuals = objArrayOfIndividuals;

            Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(sspTMemberDataContractRequest)};
            List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPTMember_METADATANAME, objResponse);

            SSP_TMemberDataContract.SSPCaseResponse objdata = (SSP_TMemberDataContract.SSPCaseResponse)lstData[0];
            if(objData.IsSuccess){
                for(SSP_TMemberDataContract.SSPMemberStatus sspMemberSts: objdata.memberStatuses.SSPMemberStatus){
                    //Shikha -- 
                    if(sspMemberSts.MemberStatus != null                       
                        && sspMemberSts.IndividualID != null 
                        && mapIndividualToMembers.get(String.valueOf(sspMemberSts.IndividualID))!= null
                        && !mapAppHeadofHouseholds.get(mapIndividualToMembers.get(String.valueOf(sspMemberSts.IndividualID)))){
                            if(sspMemberSts.MemberStatus == SSP_GlobalConstants.TMEMBERSTATUS){
                                mapTMemberValues.put(mapIndividualToMembers.get(String.valueOf(sspMemberSts.IndividualID)), true);
                            }                        
                            else{
                                mapTMemberValues.put(mapIndividualToMembers.get(String.valueOf(sspMemberSts.IndividualID)), false);
                            }
                    }
                    //Shikha
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'invokeTMemberServiceCall', e.getMessage(), true);
        }
        return mapTMemberValues;
    }

     /**
    * @author: Karthik Gulla
    * @method: checkToInvokeTMemberCall
    * @desc This method is used to get file cleared value using T Member Service call
    * @params {String sApplicationId, String sMemberId}
    * @return List<SSP_Member__c>
    * */
    @AuraEnabled
    public static SSP_LightningResponse checkToInvokeTMemberCall(Map<String,String> mapInputs){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse clsLightningResponse = new SSP_LightningResponse();
        try{
            String strApplicationId = mapInputs.get(SSP_GlobalConstants.APPLICATIONID) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.APPLICATIONID)) : SSP_GlobalConstants.EMPTY;
            String strMemberId = mapInputs.get(SSP_GlobalConstants.MEMBERID) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.MEMBERID)) : SSP_GlobalConstants.EMPTY;
            String strMode = mapInputs.get(SSP_GlobalConstants.MODEVALUE) != null ? String.escapeSingleQuotes(mapInputs.get(SSP_GlobalConstants.MODEVALUE)) : SSP_GlobalConstants.EMPTY;
            Set<Id> setMemberIds = new Set<Id>();
            Map<String,SSP_ResourcesWrapper.HouseholdMemberWrapper> mapMemberAppIndividuals = new Map<String,SSP_ResourcesWrapper.HouseholdMemberWrapper>();
            Map<String,SSP_ApplicationIndividual__c> mapAppIndividuals = new Map<String,SSP_ApplicationIndividual__c>();
            SSP_LightningResponse householdMembersResponse = SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers(strApplicationId, SSP_GlobalConstants.EMPTY, SSP_GlobalConstants.ALL);
            List<SSP_ResourcesWrapper.HouseholdMemberWrapper> lstHouseholdMembers = (List<SSP_ResourcesWrapper.HouseholdMemberWrapper>)JSON.deserialize(String.valueOf(householdMembersResponse.mapResponse.get(SSP_GlobalConstants.HOUSEHOLDMEMBERS)), List<SSP_ResourcesWrapper.HouseholdMemberWrapper>.class);
            List<SSP_ApplicationIndividual__c> oldApplicationIndividuals = new List<SSP_ApplicationIndividual__c> ();
            Boolean triggerReviewRequired = false;// flag added for Performance tuning - Keshav

            for(SSP_ResourcesWrapper.HouseholdMemberWrapper sspHouseholdMemberWrapper : lstHouseholdMembers){
                setMemberIds.add(sspHouseholdMemberWrapper.strMemberId);
                mapMemberAppIndividuals.put(sspHouseholdMemberWrapper.strMemberId, sspHouseholdMemberWrapper);
            }

            String strNavFlowStatus = SSP_GlobalConstants.EMPTY;
            Integer navFlowStatusCount = 0;
            for(NavFlowStatus__c navFlowStatusRecord :[SELECT Id, Name, Contact__c, FlowPageStatus__c, NavFlowName__c, RecordId__c,Screen_Status__c,
                                   SSPApplication__c, InitiatedUser__c, Community_Page_URL__c, Member__c, FlowDupStatus__c, FlowCompleteStatus__c 
                                   FROM NavFlowStatus__c 
                                   WHERE NavFlowName__c = :SSP_GlobalConstants.RELATIONSHIPSANDTAXFILINGFLOWNAME
                                   AND SSPApplication__c =:strApplicationId
                                   AND Member__c In :setMemberIds]){

                strNavFlowStatus = strNavFlowStatus + navFlowStatusRecord.FlowDupStatus__c;
                navFlowStatusCount++;
            }

            if(navFlowStatusCount == setMemberIds.size()
                && strNavFlowStatus!= null && (strNavFlowStatus.countMatches('R') == 0 || strNavFlowStatus.countMatches('R') == 1)){
                Map<String,Boolean> mapIndividualTMembers = SSP_TaxFilingDetailsController.invokeTMemberServiceCall(strApplicationId, lstHouseholdMembers);
                if(!mapIndividualTMembers.isEmpty()){
                    List<SSP_ApplicationIndividual__c> lstAppIndividuals = new List<SSP_ApplicationIndividual__c>();
                    String strTMembers = SSP_GlobalConstants.EMPTY;
                    for(String sMemberId : mapIndividualTMembers.keyset()){
                        SSP_ApplicationIndividual__c sspAppIndividual = new SSP_ApplicationIndividual__c();
                        sspAppIndividual.Id = mapMemberAppIndividuals.get(sMemberId).strAppIndividualId;
                        //Shikha -- added condition to remove tmember
                        if(mapIndividualTMembers.get(sMemberId)){
                            sspAppIndividual.IsTMember__c = true;
                            strTMembers = strTMembers + mapMemberAppIndividuals.get(sMemberId).strHouseholdMemberName + ',';
                        } //Below condition added for Performance tuning - Keshav                       
                        else if(mapMemberAppIndividuals.get(sMemberId).bTMember){
                            sspAppIndividual.IsTMember__c = false;
                            triggerReviewRequired = true;
                        }
                        lstAppIndividuals.add(sspAppIndividual);
                        clsLightningResponse.put(sMemberId, mapMemberAppIndividuals.get(sMemberId));
                    }
                    if(!lstAppIndividuals.isEmpty()){
                        //Code updated below for Performance tuning - Keshav
                        SSP_GenericDMLHelper.updateRecords(lstAppIndividuals, new List<String> {'IsTMember__c'});
                    }
                    strTMembers = String.isNotBlank(strTMembers) ? strTMembers.substring(0, strTMembers.length() - 1) : SSP_GlobalConstants.EMPTY;
                    clsLightningResponse.put('TMembers', strTMembers);
                    clsLightningResponse.bIsSuccess = true;
                } else {
                    clsLightningResponse.put('TMembers', SSP_GlobalConstants.NOTMEMBERS);
                    clsLightningResponse.bIsSuccess = true;
                }
            } else {
                clsLightningResponse.put('TMembers', SSP_GlobalConstants.TMEMBERSNOTTRIGGERED);
                clsLightningResponse.bIsSuccess = true;
            }
            //Shikha - added Review Required Method
            
            if(strMode != 'RAC' && triggerReviewRequired){
                //Below code added for Performance tuning - Keshav
                List<String> reviewRequiredList = new List<String>();
                reviewRequiredList.add('reviewTMemberChange,'+true+',null');
                SSP_RulesEngine.getRRTriggerRules(strApplicationId, strMemberId, new List<String>{SSP_GlobalConstants.TAXFILINGPAGE}, reviewRequiredList, strMode);
            }
            	
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'checkToInvokeTMemberCall', e.getMessage(), true);
            clsLightningResponse.bIsSuccess = false;
        }
        return clsLightningResponse;
    } 

     /**
    * @author: Karthik Gulla
    * @method: filterActiveRelationships
    * @desc This method is used to get active relationships on a particular application
    * @params {List<SSP_Relationship__c> lstRelationships, String sApplicationId}
    * @return List<SSP_Relationship__c>
    * */
    public static List<SSP_Relationship__c> filterActiveRelationships(List<SSP_Relationship__c> lstRelationships, String sApplicationId) {
        List<SSP_Relationship__c> lstFilteredRelationships = new List<SSP_Relationship__c>();
        Set<Id> setApplications = new Set<Id>();
        setApplications.add(sApplicationId);
        try{
            Set<Id> setActiveMembers = new Set<Id>();
            for(SSP_ApplicationIndividual__c sspAppIndividual: SSP_TaxFilingDetailsService.getApplicationIndividuals(setApplications)){
                setActiveMembers.add(sspAppIndividual.SSP_Member__c);
            }

            for(SSP_Relationship__c sspRelationship : lstRelationships){
                if(setActiveMembers.contains(sspRelationship.SSP_Member__c) && setActiveMembers.contains(sspRelationship.SSP_MemberRelatedTo__c)) {
                    lstFilteredRelationships.add(sspRelationship);
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'filterActiveRelationships', e.getMessage(), true);
        }
        return lstFilteredRelationships;
    }

    /**
    * @author: Karthik Gulla
    * @method: getCurrentApplicationMemberIds
    * @desc This method is used to get active current application members
    * @params {String sApplicationId}
    * @return Set<Id>
    * */
    public static Set<Id> getCurrentApplicationMemberIds(String sApplicationId) {
        Set<Id> setMemberIds = new Set<Id>();
        try{    
            SSP_LightningResponse housholdMembersResponse = SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers(sApplicationId, SSP_GlobalConstants.EMPTY, SSP_GlobalConstants.ALL);
            List<SSP_ResourcesWrapper.HouseholdMemberWrapper> lstHouseholdMembers = (List<SSP_ResourcesWrapper.HouseholdMemberWrapper>)JSON.deserialize(String.valueOf(housholdMembersResponse.mapResponse.get(SSP_GlobalConstants.HOUSEHOLDMEMBERS)), List<SSP_ResourcesWrapper.HouseholdMemberWrapper>.class);
            
            for(SSP_ResourcesWrapper.HouseholdMemberWrapper sspHouseholdMemberWrapper : lstHouseholdMembers){
                setMemberIds.add(sspHouseholdMemberWrapper.strMemberId);
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'getCurrentApplicationMemberIds', e.getMessage(), true);
        }
        return setMemberIds;
    }

    /**
     * @author Ajay Saini
     * @desc This method is used to get active current application members
     */
    private static Map<String, Object> fireReviewRequiredRules(Id applicationId, Id memberId, Map<String, SSP_Member__c> membersMap) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            Map<Id, SSP_Member__c> membersOldMap = new Map<Id, SSP_Member__c>();
            Map<Id, List<Id>> dependantMemberMap = new Map<Id, List<Id>>();
            Map<Id, List<Id>> newDependantMemberMap = new Map<Id, List<Id>>();
            Set<String> fields = new Set<String>{'SSP_Member__r.TaxFilerMemberCurrent__c', 'SSP_Member__r.TaxFilerStatusCurrentYear__c'};
            List<SSP_ApplicationIndividual__c> individuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, fields, null);
            for(SSP_ApplicationIndividual__c individual: individuals) {
                membersOldMap.put(individual.SSP_Member__c, individual.SSP_Member__r);
                if(individual.SSP_Member__r.TaxFilerMemberCurrent__c != null) {
                    if(!dependantMemberMap.containsKey(individual.SSP_Member__r.TaxFilerMemberCurrent__c)) {
                        dependantMemberMap.put(individual.SSP_Member__r.TaxFilerMemberCurrent__c, new List<Id>());
                    }
                    dependantMemberMap.get(individual.SSP_Member__r.TaxFilerMemberCurrent__c).add(individual.SSP_Member__c);
                }
            }
            List<String> reviewRequiredList = new List<String>();
            for(SSP_Member__c member: membersMap.values()) {
                if(member.TaxFilerMemberCurrent__c != null) {
                    if(!newDependantMemberMap.containsKey(member.TaxFilerMemberCurrent__c)) {
                        newDependantMemberMap.put(member.TaxFilerMemberCurrent__c, new List<Id>());
                    }
                    newDependantMemberMap.get(member.TaxFilerMemberCurrent__c).add(member.Id);
                }
                if(membersOldMap.get(member.Id) != null) {
                    //When Claimant changes claiming status
                    if(
                        membersOldMap.get(member.Id).TaxFilerStatusCurrentYear__c == 'HH' &&
                        membersOldMap.get(member.Id).TaxFilerStatusCurrentYear__c != member.TaxFilerStatusCurrentYear__c
                    ) {
                        if(dependantMemberMap.get(member.Id) != null && !dependantMemberMap.get(member.Id).isEmpty()) {
                            reviewRequiredList.add('Tax_Filing_Status_Change,true,' + String.join(dependantMemberMap.get(member.Id), ','));
                        }
                    }
                    //When Dependant changes tax filer
                    if(
                        member.TaxFilerStatusCurrentYear__c == 'DM' &&
                        membersOldMap.get(member.Id).TaxFilerMemberCurrent__c != null && 
                        membersOldMap.get(member.Id).TaxFilerMemberCurrent__c != member.TaxFilerMemberCurrent__c) {
                        reviewRequiredList.add('Dependant_Of_Change,true,' + membersOldMap.get(member.Id).TaxFilerMemberCurrent__c);
                    }
                    //When Dependant changes depedent status
                    if(
                        member.TaxFilerStatusCurrentYear__c != 'DM' &&
                        membersOldMap.get(member.Id).TaxFilerStatusCurrentYear__c == 'DM' &&
                        membersOldMap.get(member.Id).TaxFilerMemberCurrent__c != null) {
                        reviewRequiredList.add('Dependant_Of_Change,true,' + membersOldMap.get(member.Id).TaxFilerMemberCurrent__c);
                    }
                }
            }
            List<Id> existingDependants = dependantMemberMap.get(memberId);
            List<Id> newDependants = newDependantMemberMap.get(memberId);
            Set<Id> removedDependantsSet = new Set<Id>();
            if(existingDependants != null) {
                removedDependantsSet.addAll(existingDependants);
            }
            if(newDependants != null) {
                removedDependantsSet.removeAll(newDependants);
            }
            response.put(SSP_GlobalConstants.REVIEWREQUIREDLIST, reviewRequiredList);
            response.put(SSP_GlobalConstants.DEPENDANTMEMBERMAP, dependantMemberMap);
            response.put(SSP_GlobalConstants.NEWDEPENDANTMEMBERMAP, newDependantMemberMap);
            response.put(SSP_GlobalConstants.REMOVEDDEPENDANTS, new List<Id>(removedDependantsSet));
            SSP_RulesEngine.getRRTriggerRules(applicationId, memberId, new List<String>{'SSP_APP_RTF_TaxFiling'}, reviewRequiredList, 'Intake');
        }
        catch(Exception e) {
            response.put('errorLogs', LOG_LogMessageUtility.logMessage(e, 'SSP_TaxFilingDetailsController', 'fireReviewRequiredRules', e.getMessage(), true));
        }
        return response;
    }

    //Shikha - 
    public static void invokeReviewRequiredChangeToMember(List<SSP_ApplicationIndividual__c> oldApplicationIndividuals, String strApplicationId, String memberId,String mode){        
        Map<String,Boolean> oldIndividualMap = new Map<String,Boolean>();
        for(SSP_ApplicationIndividual__c appInd : oldApplicationIndividuals){
            oldIndividualMap.put(appInd.Id, appInd.IsTMember__c);
        }        
        List<SSP_ApplicationIndividual__c> newApplicationIndividuals = SSP_TaxFilingDetailsService.getApplicationIndividuals(new Set<Id> {strApplicationId});
        List<SSP_ApplicationIndividual__c> updateMemberStatusList = new List<SSP_ApplicationIndividual__c>();        
        for(SSP_ApplicationIndividual__c appIndividual : newApplicationIndividuals){            
            if(appIndividual.IsTMember__c != oldIndividualMap.get(appIndividual.Id) && !appIndividual.IsTMember__c){                
                //appIndividual.MemberStatus__c = SSP_GlobalConstants.MEMBER_STATUS_New;
                updateMemberStatusList.add(appIndividual);             
            }
        }        
        if(!updateMemberStatusList.isEmpty()){
            update updateMemberStatusList;
            List<String> reviewRequiredList = new List<String>();
		    reviewRequiredList.add('reviewTMemberChange,'+true+',null');            
            SSP_RulesEngine.getRRTriggerRules(strApplicationId, memberId, new List<String>{'SSP_APP_RTF_TaxFiling'}, reviewRequiredList, mode);
        }        
    }
    /**
    * @author: Karthik Gulla
    * @class: taxFilingDetailsWrapper
    * @desc This class is used to build tax filing details wrapper for Tax Filing
    * */
    public class TaxFilingDetailsWrapper{
        public String strMemberId                                    {get;set;}
        public String strMemberName                                  {get;set;}
        public String strTaxFilingStatusCurrentYear                  {get;set;}
        public String strTaxFilingStatusNextYear                     {get;set;}
        public String strTaxFilerMemberCurrentYear                   {get;set;}
        public String strTaxFilerMemberNextYear                      {get;set;}
        public String strTaxFilerMemberCurrentYearName               {get;set;}
        public String strTaxFilerMemberNextYearName                  {get;set;}
        public String strHasParentOrSiblingOutOfHouseholdCurrentYear {get;set;}
        public String strHasParentOrSiblingOutOfHouseholdNextYear    {get;set;}
        public Decimal iMemberAge                                    {get;set;}
        public String strTaxFilingClaimingCurrentYear                {get;set;}
        public String strTaxFilingClaimingNextYear                   {get;set;}
    }

    /**
    * @author: Karthik Gulla
    * @class: RelationshipWrapper
    * @desc This class is used to build relationship wrapper for Tax Filing
    * */
    public class RelationshipWrapper{
        public String strRelationshipType   {get;set;}
        public String strMemberId           {get;set;}
        public String strRelatedMemberId    {get;set;}
    }
}