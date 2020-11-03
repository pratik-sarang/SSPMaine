/*
* classname 	: SSP_HouseholdCircumstancesController
* @description 	: A controller class for household circumstances screen component.
* @author 		: Ajay Saini
* @date 		: DEC-1-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ajay Saini 		DEC-1-2019			Initial Version
*/
public with sharing class SSP_HouseholdCircumstancesController {
    private static final String CLASSNAME = 'SSP_HouseholdCircumstancesController';

	/***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-1-2019
    * @methodname   fetchApplicationMembers
    * @description  This methods is used to fetch for data application and member data
    * @return       application and list of applicants
    *****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse fetchApplicationMembers(Id applicationId, List<String> memberFields, String applicationMode) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
		SSP_Utility.isAuthenticatedUser();
            for(Integer i = 0; i < memberFields.size(); ++i) {
                memberFields[i] = 'SSP_Member__r.' + memberFields[i];
            }
            memberFields.add('MemberStatus__c');
            memberFields.add('MedicaidType__c');
            List<SSP_Member__c> members = new List<SSP_Member__c>();
            Map<Id, String> memberProgramsMap = new Map<Id, String>();
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, new Set<String>(memberFields));
            if(applicationIndividuals == null) {
                applicationIndividuals = new List<SSP_ApplicationIndividual__c>();
            }
            for(SSP_ApplicationIndividual__c individual: applicationIndividuals) {
                SSP_Member__c member = (SSP_Member__c)individual.getSObject(SSP_ApplicationIndividual__c.SSP_Member__c.getDescribe().getSObjectField());
                individual.ProgramsApplied__c = individual.ProgramsApplied__c != null? individual.ProgramsApplied__c : '';
                if(individual.ProgramsApplied__c.contains('MA') && individual.MedicaidType__c != null) {
                    individual.ProgramsApplied__c += ';' + individual.MedicaidType__c;
                }
                memberProgramsMap.put(individual.SSP_Member__c, individual.ProgramsApplied__c);
                if('addRemoveMember' == applicationMode) {
                    if('New' == individual.MemberStatus__c && !individual.IsTMember__c) {
                        members.add(member);
                    }
                }
                else if (applicationMode == SSP_GlobalConstants.SSP_RAC_FLOW){
                    if(!individual.IsTMember__c && SSP_Utility.getRACSelectedMembers(String.valueOf(applicationId)).contains(member.IndividualId__c)){
                    	members.add(member);    
                    }                     
                }
                else if('addRemoveMember' != applicationMode && !individual.IsTMember__c) {
                    members.add(member);
                }
            }
            response.put('applicationMode', applicationMode);
            response.put('members', members);
            response.put('memberProgramsMap', memberProgramsMap);
	        response.put('screenPermission', SSP_Utility.getScreenAccessDetails('SSP_APP_Select_HouseholdCircumstance', null).screenPermission);//CD2 2.5 Security Role Matrix and Program Access.
            response.bIsSuccess = true;
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'fetchApplicationMembers', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
    
    /***************************************************************************************************
    * @author       Sai Velpula
    * @date         05/05/2020
    * @methodname   deleteMemberData
    * @description  This methods is used to Delete for member data
    * @return       boolean
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse deleteMemberData(List<String> sMemberIds, String sApplicationId) {
        SSP_LightningResponse response = new SSP_LightningResponse();
        Set<String> setMemberIds = new Set<String>(sMemberIds);
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_TrackDeletion__c> lstTrackDeletion = new List<SSP_TrackDeletion__c>();
        List<SSP_Benefits__c> lstDeleteBenefits = new List<SSP_Benefits__c>();
        List<SSP_Benefits__c> lstAddToTrackDeletion = new List<SSP_Benefits__c>();
        List<SSP_Benefits__c> lstBenefits;
        try{
            SSP_Utility.isAuthenticatedUser();
            Id objRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Benefits__c','EntitledBenefit');
            mapConditions.clear();
            mapConditions.put('SSP_Member__c',String.join(new List<String>(setMemberIds), ','));
            mapConditions.put('RecordTypeId',objRecordTypeId);
            lstBenefits = SSP_BenefitsSelector.queryBenefitsData(new Map<String, String>{'objectName'=>'SSP_Benefits__c','IN'=>'SSP_Member__c','operator'=>'AND'}, 
                                                                 new Set<String>{'ID','DCId__c'}, 
                                                                 mapConditions);
            if(lstBenefits != NULL && !lstBenefits.IsEmpty()){
                for(SSP_Benefits__c objBenefit : lstBenefits){
                    if(objBenefit.DCId__c != NULL){
                        lstAddToTrackDeletion.add(objBenefit);
                    }else{
                        lstDeleteBenefits.add(objBenefit);
                    }
                }
            }
            if(lstDeleteBenefits != NULL && !lstDeleteBenefits.IsEmpty()){
                ESAPI.accessController().deleteAsUser(lstDeleteBenefits);
                //delete lstDeleteBenefits;
            }
            if(lstAddToTrackDeletion != NULL && !lstAddToTrackDeletion.IsEmpty() && sApplicationId != NULL && String.isNotBlank(sApplicationId)){
                for(SSP_Benefits__c objBenefit : lstAddToTrackDeletion){
                    SSP_TrackDeletion__c objTrackDeletion = new SSP_TrackDeletion__c();
                    objTrackDeletion.SSP_Application__c = sApplicationId;
                    objTrackDeletion.SalesforceId__c = objBenefit.Id;
                    objTrackDeletion.SSP_Member__c = objBenefit.SSP_Member__c;
                    objTrackDeletion.Source__c = 'SSP_APP_Select_HouseholdCircumstance';
                    objTrackDeletion.DCId__c = objBenefit.DCId__c;
                    lstTrackDeletion.add(objTrackDeletion);
                }
            }
            if(lstTrackDeletion != NULL && !lstTrackDeletion.IsEmpty()){
                ESAPI.accessController().insertAsUser(lstBenefits, SSP_Utility.getFieldsNamesList(lstTrackDeletion));
            }
        }catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'deleteMemberData', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
}