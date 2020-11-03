/*
* classname     : SSP_MemberService
* @description  : This class is a service class of SSP_MemberHandler.
* @author       : Ashwin Kasture
* @date         : 03/05/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture        03/05/2020      Initial Version
*/
public with sharing class SSP_MemberService {
    /**
    * method        : checkMembersAgeBlindDisabledInfo
    * @description  : Method executes for Member applying for Medicaid having ABD then program type on Application Individual will be Non-Magi.
    * @author       : Ashwin Kasture
    * @param        : List<SSP_Member__c> lstMember - Contains list of Members.
    * @return       : void
    * */
    public static void checkMembersAgeBlindDisabledInfo(String sApplicationId, Set<String> setMemberId) {
        try {
            SSP_Utility.isAuthenticatedUser();            
            Map<String, String> detailMap = new Map<String, String>();
            Map<String, String> mapAppIndCondition = new Map<String, String>();
            List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
            List<SSP_ApplicationIndividual__c> lstUpdateAppInd = new List<SSP_ApplicationIndividual__c>();            
            //Removed unnecessary permission checks for Performance tuning as it is handled in query - Keshav
            List<String> lstApplnIndFields = new List<String>{'Id','SSP_Application__c','SSP_Member__c','MedicaidType__c', 'IsHeadOfHousehold__c'};
            
            lstApplnIndFields.add('SSP_Application__r.ProgramsApplied__c');
            lstApplnIndFields.add('SSP_Application__r.ChangeSummaryMode__c');
            lstApplnIndFields.add('SSP_Application__r.RecordType.Name');
            lstApplnIndFields.add('SSP_Member__r.Age__c');
            lstApplnIndFields.add('SSP_Member__r.IsBlindToggle__c');
            lstApplnIndFields.add('SSP_Member__r.IsDisabledToggle__c');
            
            detailMap.put('objectName', 'SSP_ApplicationIndividual__c');
            detailMap.put('MemberStatus__c', '!=');
            mapAppIndCondition.put('MemberStatus__c', SSP_GlobalConstants.MEMBER_REMOVE_STATUS);
            Set<String> setApplnIndFields = new Set<String>(lstApplnIndFields);
            if(String.isNotBlank(sApplicationId)) {
                detailMap.put('operator', 'AND');
                mapAppIndCondition.put('SSP_Application__c', sApplicationId);                
            }
            if(setMemberId != NULL && !setMemberId.isEmpty()) {
                detailMap.put('IN', 'SSP_Member__c');
                String strMemberId = String.join(new List<String>(setMemberId), ',');
                mapAppIndCondition.put('SSP_Member__c', strMemberId);
            }
            // Get SSP_ApplicationIndividual object data
            lstAppInd = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                detailMap,
                setApplnIndFields,
                mapAppIndCondition
            );
            String oldMedicaidType;
            if(!lstAppInd.isEmpty()) {
                oldMedicaidType = String.valueOf(lstAppInd[0].MedicaidType__c);
            }
            lstUpdateAppInd = ageBlindDisabledCheck(lstAppInd);
            if(!lstUpdateAppInd.isEmpty()) {
                SSP_GenericDMLHelper.updateRecords(lstUpdateAppInd, new List<String>{'MedicaidType__c'});//Added as part of Perf Fix - Keshav
            }
        } catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberService', 'checkMembersAgeBlindDisabledInfo', ex.getMessage() , true);
        }
    }
    
    /**
    * method        : ageBlindDisabledCheck
    * @description  : Method checks for Member applying for Medicaid having ABD then program type on Application Individual will be Non-Magi.
    * @author       : Ashwin Kasture
    * @param        : List<SSP_ApplicationIndividual__c> lstAppInd
    * @return       : SSP_LightningResponse
    * */
    public static List<SSP_ApplicationIndividual__c> ageBlindDisabledCheck(List<SSP_ApplicationIndividual__c> lstAppInd) {
        List<SSP_ApplicationIndividual__c> lstUpdateAppInd = new List<SSP_ApplicationIndividual__c>();
        Set<String> setApplicationIds = new Set<String>();
        if(!lstAppInd.isEmpty()) {
           Set<String> appIsABDMemberExists = new Set<String>();
            Set<String> appIsMedicaidPrgm = new Set<String>();
            
            for(SSP_ApplicationIndividual__c objAppInd: lstAppInd) {
                List<String> lstProgram = objAppInd.SSP_Application__r.ProgramsApplied__c != null && objAppInd.SSP_Application__r.ProgramsApplied__c != '' 
                    ? objAppInd.SSP_Application__r.ProgramsApplied__c.split(';') 
                    : new List<String>();
                // To set NON-MAGI
                if(lstProgram != null && !lstProgram.isEmpty() && lstProgram.contains(SSP_GlobalConstants.MEDICAID) 
                   && (objAppInd.SSP_Member__r.Age__c >= SSP_GlobalConstants.MEMBER_AGE || 
                       objAppInd.SSP_Member__r.IsBlindToggle__c == SSP_GlobalConstants.YES || 
                       objAppInd.SSP_Member__r.IsDisabledToggle__c == SSP_GlobalConstants.YES)) {                    
                    appIsABDMemberExists.add(objAppInd.SSP_Application__c);
                    appIsMedicaidPrgm.add(objAppInd.SSP_Application__c);                             
                }
                // To set MAGI
                else if(lstProgram != null && !lstProgram.isEmpty() && lstProgram.contains(SSP_GlobalConstants.MEDICAID)) {                    
                    appIsMedicaidPrgm.add(objAppInd.SSP_Application__c);                     
                }
            }
           if(appIsABDMemberExists.size()>0) {                
                //Updated as a part of Defect # 381908 : Set MAGI/ Non MAGI in RAC
                Set<String> appids = new Set<String>();
                appids.addAll(appIsABDMemberExists);
                lstUpdateAppInd = setMedicaidType(appids, SSP_GlobalConstants.NONMAGI);
            }
            else if(appIsMedicaidPrgm.size()>0) {
                SET<String> appToUpdate = new SET<String>();
                for(String appIds :appIsMedicaidPrgm){                    
                    if(!appIsABDMemberExists.contains(appIds)){
                        appToUpdate.add(appIds);
                    }
                }         
                //Updated as a part of Defect # 381908 : Set MAGI/ Non MAGI in RAC
				lstUpdateAppInd = setMedicaidType(appToUpdate, SSP_GlobalConstants.MAGI);                
            }
        }
        return lstUpdateAppInd;
    }
    
    /**
    * method        : setMedicaidType
    * @description  : This method is use to set Medicaid Type of Application Individuals of an Application.
    * @author       : Karthik Gulla
    * @param        : Set<Id> setApplicationIds, String sMedicaidType
    * @return       : List<SSP_ApplicationIndividual__c>
    * */
    public static List<SSP_ApplicationIndividual__c> setMedicaidType(Set<String> setApplicationIds, String sMedicaidType) {
        List<SSP_ApplicationIndividual__c> lstUpdateAppInd = new List<SSP_ApplicationIndividual__c>();
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = new List<SSP_ApplicationIndividual__c>();
        try{
	    if(!setApplicationIds.isEmpty()){            
                mapConditions.put('SSP_Application__c',String.join(new List<String>(setApplicationIds), ','));
                lstApplicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','IN'=>'SSP_Application__c'}, 
                                                                    new Set<String>{'Id', 'MedicaidType__c'}, 
                                                                    mapConditions);
                for(SSP_ApplicationIndividual__c sspAppIndividual : lstApplicationIndividuals) {
                    sspAppIndividual.MedicaidType__c = sMedicaidType;
                }
            }
        } catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MemberService', 'setMedicaidType', e.getMessage(), true);
        }
        return lstApplicationIndividuals;
    }

    /**
    * method        : checkOverlappingDate
    * @description  : This service get the overlapping condition for members having Pregnancy or Emergency Medical Conditiong
    * @author       : Ashwin Kasture
    * @param        : String sOverlappingRequest
    * @return       : SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse checkOverlappingDate(String sOverlappingRequest) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            sOverlappingRequest = String.escapeSingleQuotes(sOverlappingRequest);            
            Map<String, String> mapOverlappingRequest = (Map<String, String>)JSON.deserialize(sOverlappingRequest, Map<String, String>.class);
            List<Object> lstResponseData = SSP_MemberService.getOverlappingRequest(mapOverlappingRequest);
            objResponse.bIsSuccess = true;
            objResponse.put('overlappingDatesResponse', JSON.serialize(lstResponseData));            
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberService', 'checkOverlappingDate', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /**
    * method        : getOverlappingRequest
    * @description  : This service get the overlapping condition for members having Pregnancy or Emergency Medical Conditiong
    * @author       : Ashwin Kasture
    * @param        : Map<String, String> mapOverlappingRequest
    * @return       : List<Object>
    * */
    public static List<Object> getOverlappingRequest(Map<String, String> mapOverlappingRequest) {
        List<Object> lstResponseData = new List<Object>();
        SSP_OverlapRequestWrapper objReq = new SSP_OverlapRequestWrapper();
        objReq.DcId = mapOverlappingRequest.get('dcId') != null ? Integer.valueOf(mapOverlappingRequest.get('dcId')) : 0;
        objReq.Identifier = mapOverlappingRequest.get('identifier') != null ? mapOverlappingRequest.get('identifier') : '';
        objReq.startDate = mapOverlappingRequest.get('startDate') != null ? mapOverlappingRequest.get('startDate') : '';
        objReq.EndDate = mapOverlappingRequest.get('endDate') != null ? mapOverlappingRequest.get('endDate') : '';
        objReq.IndividualId = mapOverlappingRequest.get('individualId') != null? Integer.valueOf(mapOverlappingRequest.get('individualId')) : 0;
        Map<String, Object> objResponse = new Map<String, Object> { SSP_InterfaceConstants.JSON_BODY => JSON.serialize(objReq) };
        objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID, mapOverlappingRequest.get('applicationId'));
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER, mapOverlappingRequest.get('caseNumber'));
        lstResponseData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPOverlap_METADATANAME, objResponse);        
        return lstResponseData;
    }
}