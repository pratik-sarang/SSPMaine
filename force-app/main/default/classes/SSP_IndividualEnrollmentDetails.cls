/*
* classname     :  SSP_IndividualEnrollmentDetails
* @description  :  Class to get Individual Enrollment Details
* @author       :  Varun Kochar   
* @date         :  03/01/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_IndividualEnrollmentDetails {
    public static Map<String, String> facilityTypesMap = new Map<String, String>();
    /***************************************************************************************************
* @author       Varun Kochar
* @date         03/01/2019
* @methodname   fetchMemberDetails
* @description  This methods is used to fetch details of individual member
* @return       InsuranceCoveredIndividualWrapper
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse fetchMemberDetails(Id insuranceCoveredIndividualId){
        try{
            SSP_Utility.isAuthenticatedUser();
            SSP_LightningResponse objResponse = new SSP_LightningResponse();
            List<String> facilityTypesList = new List<String>();
            List<SSP_InsuranceCoveredIndiv__c> insuranceCoveredIndivList;
            InsuranceCoveredIndividualWrapper wrapper = new InsuranceCoveredIndividualWrapper();
            wrapper.coveredIndividual  = new SSP_InsuranceCoveredIndiv__c() ;
            wrapper.policyHolder = new SSP_InsuranceCoveredIndiv__c() ;
            wrapper.employerList= new List<SSP_Asset__c>() ;
            wrapper.policyListWrapperList= new List<PolicyListWrapper>();
            
            insuranceCoveredIndivList = SSP_HealthEnrollmentSummaryService.getCoveredIndividual(new Set<String>{insuranceCoveredIndividualId});
            wrapper.coveredIndividual = insuranceCoveredIndivList[0];
            if(wrapper.coveredIndividual.Recordtype.DeveloperName == SSP_GlobalConstants.INSURANCE_EXTERNAL_POLICY_HOLDER){
                wrapper.isExternalMemberPolicyHolder = true;
                wrapper.firstName = wrapper.coveredIndividual.ExtPolicyHolderFirstName__c;
                wrapper.lastName = wrapper.coveredIndividual.ExtPolicyHolderLastName__c;
                wrapper.middleName = wrapper.coveredIndividual.ExtPolicyHolderMiddleInitial__c;
            }
            else if(wrapper.coveredIndividual.Recordtype.DeveloperName == SSP_GlobalConstants.INSURANCE_EXTERNAL_COVERED_INDIVIDUAL){
                wrapper.isExternalMemberCoveredIndividual = true;
                wrapper.isExternalMemberPolicyHolder = false;
                wrapper.firstName = (wrapper.coveredIndividual.SSP_Member__c != NULL && wrapper.coveredIndividual.SSP_Member__r.FirstName__c != NULL) ? wrapper.coveredIndividual.SSP_Member__r.FirstName__c : wrapper.coveredIndividual.FirstName__c;
                wrapper.lastName = (wrapper.coveredIndividual.SSP_Member__c != NULL && wrapper.coveredIndividual.SSP_Member__r.LastName__c != NULL) ? wrapper.coveredIndividual.SSP_Member__r.LastName__c : wrapper.coveredIndividual.LastName__c;
                wrapper.middleName = (wrapper.coveredIndividual.SSP_Member__c != NULL && wrapper.coveredIndividual.SSP_Member__r.MiddleInitial__c != NULL) ? wrapper.coveredIndividual.SSP_Member__r.MiddleInitial__c : wrapper.coveredIndividual.MiddleInitial__c;
                wrapper.suffix = (wrapper.coveredIndividual.SSP_Member__c != NULL && wrapper.coveredIndividual.SSP_Member__r.SuffixCode__c != NULL) ? wrapper.coveredIndividual.SSP_Member__r.SuffixCode__c : wrapper.coveredIndividual.SuffixCode__c;
                wrapper.gender = (wrapper.coveredIndividual.SSP_Member__c != NULL && wrapper.coveredIndividual.SSP_Member__r.GenderCode__c != NULL) ? wrapper.coveredIndividual.SSP_Member__r.GenderCode__c : wrapper.coveredIndividual.Gender__c;
                wrapper.dob = (wrapper.coveredIndividual.SSP_Member__c != NULL && wrapper.coveredIndividual.SSP_Member__r.BirthDate__c != NULL) ? wrapper.coveredIndividual.SSP_Member__r.BirthDate__c : wrapper.coveredIndividual.DateofBirth__c;
                wrapper.ssn = (wrapper.coveredIndividual.SSP_Member__c != NULL && wrapper.coveredIndividual.SSP_Member__r.SSN__c != NULL) ? wrapper.coveredIndividual.SSP_Member__r.SSN__c : wrapper.coveredIndividual.SSN__c;
            }
            else{
                wrapper.firstName = wrapper.coveredIndividual.SSP_Member__r.FirstName__c;
                wrapper.lastName = wrapper.coveredIndividual.SSP_Member__r.LastName__c;
                wrapper.middleName = wrapper.coveredIndividual.SSP_Member__r.MiddleInitial__c;
                wrapper.suffix = wrapper.coveredIndividual.SSP_Member__r.SuffixCode__c;
                wrapper.gender = wrapper.coveredIndividual.SSP_Member__r.GenderCode__c;
                wrapper.dob = wrapper.coveredIndividual.SSP_Member__r.BirthDate__c;
                wrapper.ssn = wrapper.coveredIndividual.SSP_Member__r.SSN__c;
            }
            
            List<SSP_HealthInsuranceFacilityType__c> healthInsuranceList = SSP_HealthEnrollmentSummaryService.getHealthInsuranceFacilityType(new Set<String>{wrapper.coveredIndividual.Id});
            if(wrapper.coveredIndividual.IsPolicyHolder__c && String.isNotBlank(wrapper.coveredIndividual.SSP_Member__c)){
                List<SSP_Asset__c> employerList  = SSP_HealthEnrollmentSummaryService.getAssets(new Set<String>{wrapper.coveredIndividual.SSP_Member__c});
                wrapper.employerList = employerList;
            }
            else{
                List<SSP_InsuranceCoveredIndiv__c> insurancePolicyHolderList = SSP_HealthEnrollmentSummaryService.getCoveredIndividualPolicyHolder(new Set<String>{wrapper.coveredIndividual.SSP_InsurancePolicy__c});
                if(!insurancePolicyHolderList.isEmpty()){
                    wrapper.policyHolder = insurancePolicyHolderList[0];
                    if(wrapper.policyHolder.Recordtype.DeveloperName == SSP_GlobalConstants.INSURANCE_EXTERNAL_POLICY_HOLDER){
                        wrapper.firstNamePolicyHolder = wrapper.policyHolder.ExtPolicyHolderFirstName__c;
                        wrapper.lastNamePolicyHolder = wrapper.policyHolder.ExtPolicyHolderLastName__c;
                        wrapper.isPolicyHolderExternal = true;
                    }
                    else{
                        wrapper.firstNamePolicyHolder = wrapper.policyHolder.SSP_Member__r.FirstName__c;
                        wrapper.lastNamePolicyHolder = wrapper.policyHolder.SSP_Member__r.LastName__c;
                        wrapper.isPolicyHolderExternal = false;
                    }
                }
                
            }
            
            facilityTypesMap = SSP_HealthEnrollmentSummaryService.getFacilityTypesMap();
            facilityTypesList.addAll(facilityTypesMap.keySet());
            
            for(SSP_HealthInsuranceFacilityType__c healthInsurance : healthInsuranceList){
                if(facilityTypesList.contains(healthInsurance.FacilityType__c)){
                    Boolean existingPolicy = healthInsurance.DCId__c != null ? true : false;
                    wrapper.policyListWrapperList.add(new PolicyListWrapper (healthInsurance,facilityTypesMap.get(healthInsurance.FacilityType__c),true, existingPolicy));
                    facilityTypesList.remove(facilityTypesList.indexOf(healthInsurance.FacilityType__c));
                }
            }
            
            for(String facilityType : facilityTypesList){
                wrapper.policyListWrapperList.add(new PolicyListWrapper(new SSP_HealthInsuranceFacilityType__c(SSP_InsuranceCoveredIndiv__c = wrapper.coveredIndividual.Id ,FacilityType__c = facilityType),facilityTypesMap.get(facilityType),false, false));
            }
            objResponse.put('wrapper', wrapper);
            return objResponse;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_IndividualEnrollmentDetails', 'fetchMemberDetails', e.getMessage(), true);
        }
        return null;
    }
    /***************************************************************************************************
* @author       Varun Kochar
* @date         03/01/2019
* @methodname   saveIndividualDetails
* @description  This methods is used to save details of Individual members
* @return       
*****************************************************************************************************/
    
    @auraEnabled
    public static void saveIndividualDetails(String wrapper){
        try{
            SSP_Utility.isAuthenticatedUser();
            InsuranceCoveredIndividualWrapper listToSave = (InsuranceCoveredIndividualWrapper)JSON.deserialize(wrapper, InsuranceCoveredIndividualWrapper.class);
            if(!listToSave.coveredIndividual.IsCoveredIndividualUpdated__c){
                listToSave.coveredIndividual.IsCoveredIndividualUpdated__c = true;
            }
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{listToSave.coveredIndividual}, 'update', 'SSP_InsuranceCoveredIndiv__c'); // CD1 Security Fixes
            if(listToSave.coveredIndividual.IsPolicyHolder__c 
               || (listToSave.isExternalMemberPolicyHolder!= null && listToSave.isExternalMemberPolicyHolder)){
                   SSP_InsurancePolicy__c insurancePolicy = new SSP_InsurancePolicy__c(Id = listToSave.coveredIndividual.SSP_InsurancePolicy__c, EmployerName__c = listToSave.coveredIndividual.SSP_InsurancePolicy__r.EmployerName__c );
                   SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{insurancePolicy}, 'update', 'SSP_InsurancePolicy__c'); // CD1 Security Fixes
               }
            List<SSP_HealthInsuranceFacilityType__c> policyToBeUpdatedList = new List<SSP_HealthInsuranceFacilityType__c>();
            for(PolicyListWrapper policyWrapperObj : listToSave.policyListWrapperList){
                if(policyWrapperObj.selected){
                    if(policyWrapperObj.policy.CoverageEndDate__c != null){
                        policyWrapperObj.policy.IsDeleted__c  = true;
                    }
                    policyToBeUpdatedList.add(policyWrapperObj.policy);
                }
                else{
                    if(String.isNotBlank(policyWrapperObj.policy.Id)){
                        policyWrapperObj.policy.IsDeleted__c  = true;
                         policyToBeUpdatedList.add(policyWrapperObj.policy);
                    }
                }
            }
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(policyToBeUpdatedList, 'upsert', 'SSP_HealthInsuranceFacilityType__c'); // CD1 Security Fixes
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_IndividualEnrollmentDetails', 'saveIndividualDetails', e.getMessage(), true);
        }
    }
    public class InsuranceCoveredIndividualWrapper{
        @auraEnabled public SSP_InsuranceCoveredIndiv__c coveredIndividual  {get; set;}
        @auraEnabled public SSP_InsuranceCoveredIndiv__c policyHolder {get; set;}
        @auraEnabled public SSP_InsurancePolicy__c insurancePolicy {get; set;}
        @auraEnabled public List<SSP_Asset__c> employerList {get; set;}
        @auraEnabled public List<PolicyListWrapper> policyListWrapperList {get; set;}
        @auraEnabled public Boolean isExternalMemberPolicyHolder{get;set;}
        @auraEnabled public Boolean isExternalMemberCoveredIndividual{get;set;}
        @auraEnabled public String otherEmployerName{get;set;}
        @auraEnabled public String selectedEmployer{get;set;}
        @auraEnabled public String firstName{get;set;}
        @auraEnabled public String lastName{get;set;}
        @auraEnabled public String middleName{get;set;}
        @auraEnabled public String suffix{get;set;}
        @auraEnabled public String gender{get;set;}
        @auraEnabled public Date dob{get;set;}
        @auraEnabled public String ssn{get;set;}
        @auraEnabled public String firstNamePolicyHolder{get;set;}
        @auraEnabled public String lastNamePolicyHolder{get;set;}
        @auraEnabled public Boolean isPolicyHolderExternal{get;set;}
    }
    public class PolicyListWrapper{
        @auraEnabled public Boolean selected {get; set;}
        @auraEnabled public String facilityName {get; set;}
        @auraEnabled public SSP_HealthInsuranceFacilityType__c policy {get; set;}
        @auraEnabled public Boolean existingPolicy {get; set;}
        @auraEnabled public Boolean disableStartDate {get; set;}
        @auraEnabled public Boolean disablePolicySelection {get; set;}
        public PolicyListWrapper(SSP_HealthInsuranceFacilityType__c policy, String facilityName, Boolean selected, Boolean existingPolicy){
            this.policy = policy;
            this.facilityName = facilityName;
            this.selected = selected;
            this.existingPolicy = existingPolicy;
        }
    }
}