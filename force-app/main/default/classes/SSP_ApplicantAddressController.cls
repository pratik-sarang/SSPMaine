/*
* classname     : SSP_ApplicantAddressController
* @description  : A controller class for handling primary and non-primary address screen component.
* @author       : Ajay Saini
* @date         : DEC-2-2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ajay Saini        DEC-2-2019          Initial Version
*/

public with sharing class SSP_ApplicantAddressController {
    private static final String CLASSNAME = 'SSP_ApplicantAddressController';
    private static List<String> addressFields = new List<String>{
        'IsFixedAddressToggle__c',
        'HasDifferentMailingAddressToggle__c',
        'SameAddressOfHoh__c',
        'SameAddressInfoAsHOHToggle__c',
        'PhysicalAddressLine1__c',
        'PhysicalAddressLine2__c',
        'PhysicalCity__c',
        'PhysicalCountyCode__c',
        'PhysicalStateCode__c',
        'PhysicalCountryCode__c',
        'PhysicalZipCode4__c',
        'PhysicalZipCode5__c',
        'MailingAddressLine1__c',
        'MailingAddressLine2__c',
        'MailingCity__c',
        'MailingCountyCode__c',
        'MailingStateCode__c',
        'MailingCountryCode__c',
        'MailingZipCode4__c',
        'MailingZipCode5__c',
        'PhysicalAddrValidated__c',
        'PhysicalMailAddrDeliveryCode__c',
        'PhysicalCertifiedNoStatIndicator__c',
        'PhysicalResidentialDeliveryIndicator__c',
        'PhysicalCotVacancyIndicator__c',
        'MailingAddrValidated__c',
        'MailingMailAddrDeliveryCode__c',
        'MailingCertifiedNoStatIndicator__c',
        'MailingResidentialDeliveryIndicator__c',
        'MailingCotVacancyIndicator__c',
        'MailingGeolocation__Latitude__s',
        'MailingGeolocation__Longitude__s',
        'PhysicalGeolocation__Latitude__s',
        'PhysicalGeolocation__Longitude__s'
    };

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-2-2019
    * @methodname   updateAddress
    * @description  This method is used to fetch for application and member data
    * @return       Status of update operation
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse updateAddress(SSP_Member__c address, Id applicationId, Boolean bIsAddressChanged) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstAppIndividuals;
        List<SSP_Application__c>  lstApps;
        List<String> lstAppFields = new List<String>{'IsPrimaryApplicantAddressModified__c'};
        try {
            List<SSP_Member__c> recordsToUpdate = new List<SSP_Member__c>{address};
                SSP_Member__c objMember;
            Boolean isFixedAddress = address.IsFixedAddressToggle__c == SSP_GlobalConstants.YES;
            Boolean isMailingAddressDifferent = address.HasDifferentMailingAddressToggle__c == SSP_GlobalConstants.YES;
            List<LOG_LogMessage__c> logRecords = SSP_AddressService.validateMemberAddress(recordsToUpdate);
            if(isFixedAddress == true && isMailingAddressDifferent == false) {
                SSP_AddressService.copyMailingFromPhysicalAddress(recordsToUpdate);
            }
            if(address.SameAddressInfoAsHOHToggle__c == SSP_GlobalConstants.YES && applicationId != null) {
                objMember = populateAddressOnHOH(applicationId);
            }
            if(objMember != NULL){
                objMember.SameAddressOfHoh__c = true;
                objMember.IsFixedAddressToggle__c = address.IsFixedAddressToggle__c;
                objMember.HasDifferentMailingAddressToggle__c = address.HasDifferentMailingAddressToggle__c;
                objMember.PhysicalAddressLine1__c = address.PhysicalAddressLine1__c;
                objMember.PhysicalAddressLine2__c = address.PhysicalAddressLine2__c;
                objMember.PhysicalCity__c = address.PhysicalCity__c;
                objMember.PhysicalCountyCode__c = address.PhysicalCountyCode__c;
                objMember.PhysicalStateCode__c = address.PhysicalStateCode__c;
                objMember.PhysicalCountryCode__c = address.PhysicalCountryCode__c;
                objMember.PhysicalZipCode4__c = address.PhysicalZipCode4__c;
                objMember.PhysicalZipCode5__c = address.PhysicalZipCode5__c;
                
                objMember.MailingAddressLine1__c = address.MailingAddressLine1__c;
                objMember.MailingAddressLine2__c = address.MailingAddressLine2__c;
                objMember.MailingCity__c = address.MailingCity__c;
                objMember.MailingCountyCode__c = address.MailingCountyCode__c;
                objMember.MailingStateCode__c = address.MailingStateCode__c;
                objMember.MailingCountryCode__c = address.MailingCountryCode__c;
                objMember.MailingZipCode4__c = address.MailingZipCode4__c;
                objMember.MailingZipCode5__c = address.MailingZipCode5__c;
                
                objMember.PhysicalAddrValidated__c = address.PhysicalAddrValidated__c;
                objMember.PhysicalMailAddrDeliveryCode__c = address.PhysicalMailAddrDeliveryCode__c;
                objMember.PhysicalCertifiedNoStatIndicator__c = address.PhysicalCertifiedNoStatIndicator__c;
                objMember.PhysicalResidentialDeliveryIndicator__c = address.PhysicalResidentialDeliveryIndicator__c;
                objMember.PhysicalCotVacancyIndicator__c = address.PhysicalCotVacancyIndicator__c;
                objMember.PhysicalGeolocation__Latitude__s = address.PhysicalGeolocation__Latitude__s;
                objMember.PhysicalGeolocation__Longitude__s = address.PhysicalGeolocation__Longitude__s;
                
                objMember.MailingAddrValidated__c = address.MailingAddrValidated__c;
                objMember.MailingMailAddrDeliveryCode__c = address.MailingMailAddrDeliveryCode__c;
                objMember.MailingCertifiedNoStatIndicator__c = address.MailingCertifiedNoStatIndicator__c;
                objMember.MailingResidentialDeliveryIndicator__c = address.MailingResidentialDeliveryIndicator__c;
                objMember.MailingCotVacancyIndicator__c = address.MailingCotVacancyIndicator__c;
                objMember.MailingGeolocation__Latitude__s = address.MailingGeolocation__Latitude__s;
                objMember.MailingGeolocation__Longitude__s = address.MailingGeolocation__Longitude__s;
            }
            List<String> fields = new List<String>{'IsHeadOfHousehold__c'};
                for (String addressField: addressFields) {
                    fields.add('SSP_Member__r.' + addressField);
                }
            if(applicationId != NULL){
                lstApps =  SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                        new Set<String>{'Id','IsPrimaryApplicantAddressModified__c','ProgramsApplied__c'}, 
                                                                        new Map<String, String>{'Id'=> applicationId});
                lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                 new Set<String>{'Id','SSP_Member__c','SSP_Application__c','IsHeadOfHousehold__c'}, 
                                                                                 new Map<String, String>{'limit'=>'1','SSP_Application__c'=> applicationId,'IsHeadOfHousehold__c' =>'#true#'});
                if(lstApps != NULL && lstAppIndividuals != NULL && !lstAppIndividuals.isEmpty() && !lstApps.isEmpty() && lstApps[0].ProgramsApplied__c != NULL && lstApps[0].ProgramsApplied__c.contains('SN') && lstAppIndividuals[0].IsHeadOfHousehold__c && bIsAddressChanged){
                    lstApps[0].IsPrimaryApplicantAddressModified__c = true;
                    ESAPI.accessController().updateAsUser(lstApps[0], lstAppFields);
                }
            }
            if(objMember != NULL ){
                ESAPI.accessController().updateAsUser(objMember, addressFields);
                //update objMember;
            }
            if(address.SameAddressInfoAsHOHToggle__c == SSP_GlobalConstants.YES && applicationId != null) {
                recordsToUpdate.addAll(populateAddressOnAllOtherMembers(applicationId));
            }
            Map<Id, SSP_Member__c> recordsToUpdateMap = new Map<Id, SSP_Member__c>();
            for(SSP_Member__c member: recordsToUpdate) {
                recordsToUpdateMap.put(member.Id, member);
            }
            LOG_LogMessageUtility.logMessage(logRecords);
            // update recordsToUpdate;
            if(recordsToUpdateMap != NULL){
                ESAPI.accessController().updateAsUser(recordsToUpdateMap, SSP_Utility.getFieldsNamesList(recordsToUpdate));
            }
            response.bIsSuccess = true;
            response.put('fields', SSP_Utility.getFieldsNamesList(recordsToUpdate));
            response.put('recordsToUpdateMap', recordsToUpdateMap);
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'updateAddress', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }

    /***************************************************************************************************
    * @author       Sai Kiran
    * @date         05/02/2020
    * @methodname   populateAddressOnHOH
    * @description  This method is used to fetch for application and member data
    * @return       Status of update operation
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_Member__c populateAddressOnHOH(Id applicationId) {
        Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_ApplicationIndividual__c', 'operator' => 'AND'};
        List<String> fields = new List<String>{'IsHeadOfHousehold__c'};
        for (String addressField: addressFields) {
            fields.add('SSP_Member__r.' + addressField);
        }
        List<SSP_ApplicationIndividual__c> headOfHousehold = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(detailMap, new Set<String>(fields),
            new Map<String, String>{'SSP_Application__c' => applicationId,  'IsHeadOfHousehold__c'=> '#true#'});
        return headOfHousehold.get(0).SSP_Member__r;
    }
    
    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-2-2019
    * @methodname   populateAddressOnAllOtherMembers
    * @description  This method is used to fetch for application and member data
    * @return       Status of update operation
    *****************************************************************************************************/
    @AuraEnabled
    public static List<SSP_Member__c> populateAddressOnAllOtherMembers(Id applicationId) {
        Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_ApplicationIndividual__c', 'operator' => 'AND'};
        List<String> fields = new List<String>{'IsHeadOfHousehold__c'};
        for (String addressField: addressFields) {
            fields.add('SSP_Member__r.' + addressField);
        }
        List<SSP_ApplicationIndividual__c> headOfHousehold = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(detailMap, new Set<String>(fields),
            new Map<String, String>{'SSP_Application__c' => applicationId,  'IsHeadOfHousehold__c'=> '#true#'});
        List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(detailMap, new Set<String>(fields),
            new Map<String, String>{'SSP_Application__c' => applicationId,  'IsHeadOfHousehold__c'=> '#false#'});
        if(headOfHousehold.isEmpty() || applicationIndividuals.isEmpty()) {
            return new List<SSP_Member__c>();
        }
        return updateNonPrimaryMemberAddress(applicationIndividuals, headOfHousehold.get(0).SSP_Member__r);
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-2-2019
    * @methodname   updateNonPrimaryMemberAddress
    * @description  Helper method is used to copyaddress from primary applicants to non-primary applicants.
    * @return       Status of record update.
    *****************************************************************************************************/
    private static List<SSP_Member__c> updateNonPrimaryMemberAddress(List<SSP_ApplicationIndividual__c> applicationIndividuals, SSP_Member__c headOfHousehold) {
        if(headOfHousehold == null) {
            return new List<SSP_Member__c>();
        }
        List<SSP_Member__c> membersToUpdate = new List<SSP_Member__c>();
        for(SSP_ApplicationIndividual__c individual : applicationIndividuals) {
            SSP_Member__c member = (SSP_Member__c)individual.getSObject(SSP_ApplicationIndividual__c.SSP_Member__c.getDescribe().getSObjectField());
            member.SameAddressOfHoh__c = true;
            member.IsFixedAddressToggle__c = headOfHousehold.IsFixedAddressToggle__c;
            member.HasDifferentMailingAddressToggle__c = headOfHousehold.HasDifferentMailingAddressToggle__c;
            member.PhysicalAddressLine1__c = headOfHousehold.PhysicalAddressLine1__c;
            member.PhysicalAddressLine2__c = headOfHousehold.PhysicalAddressLine2__c;
            member.PhysicalCity__c = headOfHousehold.PhysicalCity__c;
            member.PhysicalCountyCode__c = headOfHousehold.PhysicalCountyCode__c;
            member.PhysicalStateCode__c = headOfHousehold.PhysicalStateCode__c;
            member.PhysicalCountryCode__c = headOfHousehold.PhysicalCountryCode__c;
            member.PhysicalZipCode4__c = headOfHousehold.PhysicalZipCode4__c;
            member.PhysicalZipCode5__c = headOfHousehold.PhysicalZipCode5__c;

            member.MailingAddressLine1__c = headOfHousehold.MailingAddressLine1__c;
            member.MailingAddressLine2__c = headOfHousehold.MailingAddressLine2__c;
            member.MailingCity__c = headOfHousehold.MailingCity__c;
            member.MailingCountyCode__c = headOfHousehold.MailingCountyCode__c;
            member.MailingStateCode__c = headOfHousehold.MailingStateCode__c;
            member.MailingCountryCode__c = headOfHousehold.MailingCountryCode__c;
            member.MailingZipCode4__c = headOfHousehold.MailingZipCode4__c;
            member.MailingZipCode5__c = headOfHousehold.MailingZipCode5__c;

            member.PhysicalAddrValidated__c = headOfHousehold.PhysicalAddrValidated__c;
            member.PhysicalMailAddrDeliveryCode__c = headOfHousehold.PhysicalMailAddrDeliveryCode__c;
            member.PhysicalCertifiedNoStatIndicator__c = headOfHousehold.PhysicalCertifiedNoStatIndicator__c;
            member.PhysicalResidentialDeliveryIndicator__c = headOfHousehold.PhysicalResidentialDeliveryIndicator__c;
            member.PhysicalCotVacancyIndicator__c = headOfHousehold.PhysicalCotVacancyIndicator__c;
            member.PhysicalGeolocation__Latitude__s = headOfHousehold.PhysicalGeolocation__Latitude__s;
            member.PhysicalGeolocation__Longitude__s = headOfHousehold.PhysicalGeolocation__Longitude__s;

            member.MailingAddrValidated__c = headOfHousehold.MailingAddrValidated__c;
            member.MailingMailAddrDeliveryCode__c = headOfHousehold.MailingMailAddrDeliveryCode__c;
            member.MailingCertifiedNoStatIndicator__c = headOfHousehold.MailingCertifiedNoStatIndicator__c;
            member.MailingResidentialDeliveryIndicator__c = headOfHousehold.MailingResidentialDeliveryIndicator__c;
            member.MailingCotVacancyIndicator__c = headOfHousehold.MailingCotVacancyIndicator__c;
            member.MailingGeolocation__Latitude__s = headOfHousehold.MailingGeolocation__Latitude__s;
            member.MailingGeolocation__Longitude__s = headOfHousehold.MailingGeolocation__Longitude__s;
            
            membersToUpdate.add(member);
        }
        return membersToUpdate;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-3-2019
    * @methodname   getPrimaryApplicantData
    * @description  This method retreives the primary applicant data from applicationId
    * @return       Primary applicant record
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getPrimaryApplicantData(Id applicationId, List<String> fields) {
        SSP_Utility.isAuthenticatedUser();
        SSP_ApplicantAddressController.updateAddressFlags(applicationId);
        
        SSP_LightningResponse response = new SSP_LightningResponse();
        if(fields ==  null) {
            fields = new List<String>();
        }
        for (String addressField: addressFields) {
            fields.add('SSP_Member__r.' + addressField);
        }
        try {
            response.bIsSuccess = false;
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(applicationId, new Set<String>(fields));
            if(applicationIndividuals != null && !applicationIndividuals.isEmpty()) {
                SSP_Member__c member = (SSP_Member__c)applicationIndividuals[0].getSObject(SSP_ApplicationIndividual__c.SSP_Member__c.getDescribe().getSObjectField());
                response.bIsSuccess = true;
                response.put('member', member);
            }
        }
        catch(Exception e) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, CLASSNAME, 'getPrimaryApplicantData', e.getMessage() , true);
            response.addException(e, lstLogMessages[0].Id);
        }
        return response;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         03/24/2019
    * @methodname   fetchMemberIdNonPrimary
    * @description  This method fetches Id of Non-Primary in the application for Review Required
    * @param        String
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse fetchMemberIdNonPrimary(String applicationId){
        SSP_Utility.isAuthenticatedUser();
        List<String> memberIdList = new List<String>();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(String.isNotBlank(applicationId)){
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Member__c', 'IsHeadOfhousehold__c', 'SSP_Application__c'}, 
                                                                                     new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId), 
                                                                                         'IsHeadOfHousehold__c'=> '#false#'});
            }
            if(!sspApplicationIndividualList.isEmpty()){
                for(SSP_ApplicationIndividual__c appInd : sspApplicationIndividualList){
                        memberIdList.add(appInd.SSP_Member__c);
        		}
            }
 			toSend.bIsSuccess = true;
            toSend.put('memberIdList', memberIdList);
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ApplicantAddressController', 'fetchMemberIdNonPrimary', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        }
        return toSend;
    }
    
    @AuraEnabled(cacheable=true)
    public static SSP_lightningResponse getExpenseDetails (String memberId){       
        SSP_Utility.isAuthenticatedUser();
        SSP_lightningResponse response = new SSP_LightningResponse();
        try{
            List<SSP_Asset__c> assetsList = new List<SSP_Asset__c>();
            /*assetsList = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','operator'=>'AND', 'IN'=>'SSP_Member__c'}, 
                                                        new Set<String>{'Id', 'SSP_Member__c', 'ExpenseTypeCode__c', 'ExpenseSubType__c', 'IsExistingCode__c'}, 
                                                        new Map<String, String>{'SSP_Member__c'=>memberId, 'RecordType.DeveloperName'=>'Expense'});*/
            assetsList = [SELECT Id, SSP_Member__c, ExpenseTypeCode__c,IsExistingData__c, EndDate__c, ExpenseSubType__c FROM SSP_ASSET__c
                        WHERE SSP_Member__c = :memberId
                        AND RecordType.name = 'Expense' 
                        AND (ExpenseTypeCode__c = 'UE' OR ExpenseTypeCode__c = 'SE')
                        AND isDeleted__c = false];
            response.put('assetsList',assetsList);
        }
        catch(exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicantAddressController', 'getExpenseDetails', e.getMessage(), true);
        }
        return response;
    }

    /**
    * @author: Karthik Gulla
    * @method: updateAddressFlags
    * @desc This method is used to get member address details and calculate flags
    * @param {String sApplicationId}
    * @return void
    * */
    public static void updateAddressFlags(Id sApplicationId){
        Set<Id> setApplicationIds = new Set<Id>();
        Set<Id> setMemberIds = new Set<Id>();
        Map<Id,Boolean> mapAppIndividualsHOH = new Map<Id,Boolean>();
        Set<String> setAccessFields = new Set<String>();
        Map<String, SSP_Member__c> mapMembers = new Map<String, SSP_Member__c>();
        SSP_Member__c sspHOHMember = null;
        try{
            setApplicationIds.add(sApplicationId);
            Map<String,String> mapConditions = new Map<String,String>();
            mapConditions.put('SSP_Application__c',String.join(new List<Id>(setApplicationIds), ','));
            List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','IN'=>'Id'}, 
                                                                    new Set<String>{'Id','SSP_Member__c' ,'IsHeadOfHousehold__c'}, 
                                                                    mapConditions);
            for(SSP_ApplicationIndividual__c sspAppIndividual:lstApplicationIndividuals){
                setMemberIds.add(sspAppIndividual.SSP_Member__c);
                mapAppIndividualsHOH.put(sspAppIndividual.SSP_Member__c, sspAppIndividual.IsHeadOfHousehold__c);
            }
            
            mapConditions.clear();
            mapConditions.put('Id',String.join(new List<Id>(setMemberIds), ','));
            List<SSP_Member__c> lstApplicationMembers = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id'}, 
                                                                new Set<String>{'Id','MailingAddressLine1__c','PhysicalAddressLine1__c','MailingAddressLine2__c','PhysicalAddressLine2__c',
                                                                                'MailingCity__c','PhysicalCity__c','MailingStateCode__c','PhysicalStateCode__c','MailingZipCode4__c',
                                                                                'PhysicalZipCode4__c','MailingZipCode5__c','PhysicalZipCode5__c','MailingCountyCode__c','PhysicalCountyCode__c',
                                                                                'MailingCountryCode__c','PhysicalCountryCode__c','SameAddressInfoAsHOHToggle__c','HasDifferentMailingAddressToggle__c',
                                                                                'DCPhysicalAddressId__c','DCMailingAddressId__c'}, 
                                                                mapConditions);
            
            for(SSP_Member__c sspMember : lstApplicationMembers){
                if(mapAppIndividualsHOH.get(sspMember.Id) != null 
                && mapAppIndividualsHOH.get(sspMember.Id)
                && sspMember.SameAddressInfoAsHOHToggle__c == null){
                    sspHOHMember = sspMember;
                }
            }

            Integer iCount = 0;
            for(SSP_Member__c sspMember : lstApplicationMembers){
                if(sspHOHMember != null && mapAppIndividualsHOH.get(sspMember.Id) != null && !mapAppIndividualsHOH.get(sspMember.Id)){
                    if((sspHOHMember.MailingAddressLine1__c != null && sspMember.MailingAddressLine1__c != null && sspHOHMember.MailingAddressLine1__c.toLowerCase() != sspMember.MailingAddressLine1__c)
                    || (sspHOHMember.PhysicalAddressLine1__c != null && sspMember.PhysicalAddressLine1__c != null && sspHOHMember.PhysicalAddressLine1__c.toLowerCase() != sspMember.PhysicalAddressLine1__c.toLowerCase())
                    || ((sspHOHMember.MailingAddressLine2__c != sspMember.MailingAddressLine2__c)  || ((sspHOHMember.PhysicalAddressLine2__c != null && sspMember.MailingAddressLine2__c != null && sspHOHMember.MailingAddressLine2__c.toLowerCase() != sspMember.MailingAddressLine2__c.toLowerCase())))
                    || ((sspHOHMember.PhysicalAddressLine2__c != sspMember.PhysicalAddressLine2__c) || ((sspHOHMember.PhysicalAddressLine2__c != null && sspMember.PhysicalAddressLine2__c != null && sspHOHMember.PhysicalAddressLine2__c.toLowerCase() != sspMember.PhysicalAddressLine2__c.toLowerCase())))
                    || (sspHOHMember.MailingCity__c != null && sspMember.MailingCity__c != null && sspHOHMember.MailingCity__c.toLowerCase() != sspMember.MailingCity__c.toLowerCase())
                    || (sspHOHMember.PhysicalCity__c != null && sspMember.PhysicalCity__c != null && sspHOHMember.PhysicalCity__c.toLowerCase() != sspMember.PhysicalCity__c.toLowerCase())
                    || (sspHOHMember.MailingStateCode__c != null && sspMember.MailingStateCode__c != null && sspHOHMember.MailingStateCode__c != sspMember.MailingStateCode__c)
                    || (sspHOHMember.PhysicalStateCode__c != null && sspMember.PhysicalStateCode__c != null && sspHOHMember.PhysicalStateCode__c != sspMember.PhysicalStateCode__c)
                    || (sspHOHMember.MailingZipCode4__c != sspMember.MailingZipCode4__c)
                    || (sspHOHMember.PhysicalZipCode4__c != sspMember.PhysicalZipCode4__c)
                    || (sspHOHMember.MailingZipCode5__c != sspMember.MailingZipCode5__c)
                    || (sspHOHMember.PhysicalZipCode5__c != sspMember.PhysicalZipCode5__c)
                    || (sspHOHMember.MailingCountyCode__c != null && sspMember.MailingCountyCode__c != null && sspHOHMember.MailingCountyCode__c != sspMember.MailingCountyCode__c)
                    || (sspHOHMember.PhysicalCountyCode__c != null && sspMember.PhysicalCountyCode__c != null && sspHOHMember.PhysicalCountyCode__c != sspMember.PhysicalCountyCode__c)
                    || (sspHOHMember.MailingCountryCode__c != sspMember.MailingCountryCode__c)
                    || (sspHOHMember.PhysicalCountryCode__c != sspMember.PhysicalCountryCode__c)) {
                        SSP_Member__c sspCurrentMember = new SSP_Member__c();
                        sspCurrentMember.Id = sspHOHMember.Id;
                        sspCurrentMember.SameAddressInfoAsHOHToggle__c = SSP_GlobalConstants.NO;
                        mapMembers.put(sspCurrentMember.Id, sspCurrentMember);
                        break;
                    }
                    iCount++;
                }
            }
           
            if(sspHOHMember != null && iCount == (lstApplicationMembers.size() - 1) && sspHOHMember.SameAddressInfoAsHOHToggle__c == null && (sspHOHMember.DCPhysicalAddressId__c != null || sspHOHMember.DCMailingAddressId__c != null)) {
                SSP_Member__c sspCurrentMember = new SSP_Member__c();
                sspCurrentMember.Id = sspHOHMember.Id;
                sspCurrentMember.SameAddressInfoAsHOHToggle__c = SSP_GlobalConstants.YES;
                mapMembers.put(sspCurrentMember.Id, sspCurrentMember);
            }

            for(SSP_Member__c sspMember : lstApplicationMembers){
                SSP_Member__c sspCurrentMember = new SSP_Member__c();
                if(sspMember.HasDifferentMailingAddressToggle__c == null){
                    if((sspMember.MailingAddressLine1__c != null && sspMember.PhysicalAddressLine1__c != null && sspMember.MailingAddressLine1__c.toLowerCase() == sspMember.PhysicalAddressLine1__c.toLowerCase())
                    && ((sspMember.MailingAddressLine2__c == sspMember.PhysicalAddressLine2__c) || ((sspMember.MailingAddressLine2__c != null && sspMember.PhysicalAddressLine2__c != null && sspMember.MailingAddressLine2__c.toLowerCase() == sspMember.PhysicalAddressLine2__c.toLowerCase())))
                    && (sspMember.MailingCity__c != null && sspMember.PhysicalCity__c != null && sspMember.MailingCity__c.toLowerCase() == sspMember.PhysicalCity__c.toLowerCase())
                    && (sspMember.MailingStateCode__c != null && sspMember.PhysicalStateCode__c != null && sspMember.MailingStateCode__c == sspMember.PhysicalStateCode__c)
                    && (sspMember.MailingZipCode4__c == sspMember.PhysicalZipCode4__c)
                    && (sspMember.MailingZipCode5__c == sspMember.PhysicalZipCode5__c)
                    && (sspMember.MailingCountyCode__c != null && sspMember.PhysicalCountyCode__c != null && sspMember.MailingCountyCode__c == sspMember.PhysicalCountyCode__c)
                    && (sspMember.MailingCountryCode__c == sspMember.PhysicalCountryCode__c)) {
                        if(mapMembers.get(sspMember.Id) != null){
                            sspCurrentMember = mapMembers.get(sspMember.Id);
                        } else {
                            sspCurrentMember.Id = sspMember.Id;
                        }
                        sspCurrentMember.HasDifferentMailingAddressToggle__c = SSP_GlobalConstants.NO; 
                        mapMembers.put(sspCurrentMember.Id, sspCurrentMember);  
                    }
                }
            }

            List<SSP_Member__c> lstTobeUpdatedMembers = mapMembers.values();
            
            if(!lstTobeUpdatedMembers.isEmpty() && Schema.getGlobalDescribe().get(SSP_GlobalConstants.SSPMEMBEROBJECT).getDescribe().isUpdateable()){
                update lstTobeUpdatedMembers;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicantAddressController', 'updateAddressFlags', e.getMessage(), true);
        }
    }
}