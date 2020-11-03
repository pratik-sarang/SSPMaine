/***************************************************************************************************************************
*   Type         :   Service Class
*   Name         :   SSP_AlienSponsorService
*   Created By   :   Suyash Singhal
*   Created Date :   01/16/2020
*   Description  : 	 This method is use to fetch/store the Alien Sponsor data.
*  
*   Modification Log
*   Developer                 Date          	Description
*   Suyash                    01/16/2020        Initial Version
*****************************************************************************************************************************/

public with sharing class SSP_AlienSponsorService {
	/*
	* method 		: fetchAlienSponsorData
	* @description  : This method is use to fetch the Alien Sponsor data.
	* @author 		: Ashwin Kasture
	* @param 		: String applicationId - Contains Application Id
	* @param 		: String memberId - Contains Member Id
	* @return 		: List<SSP_ApplicationIndividual__c>
	* */
	public static List<SSP_ApplicationIndividual__c> fetchAlienSponsorData(String applicationId, String memberId) {
        SSP_Utility.isAuthenticatedUser();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividuals = new List<SSP_ApplicationIndividual__c>();
        Map<String, String> detailMap = new Map<String, String>();
        Map<String, String> conditionMap = new Map<String, String>();
        List<String> lstApplnIndFields = new List<String>{'Id','IsHeadOfHousehold__c','SSP_Application__c','SSP_Member__c','MedicaidType__c'};            
        List<String> lstSSPMemberFields = new List<String>{'FirstName__c','Lastname__c','SponsoredByOrganization__c','IsUSCitizenToggle__c','InternalAlienSponsor__c'};	
        List<String> lstAlienSponsorFields =  new List<String>{'SponsorFirstName__c'};
        Boolean canViewApplIndFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), lstApplnIndFields);
        Boolean canViewSSPMemberFields = ESAPI.accessController().isAuthorizedToView(SSP_Member__c.getSObjectType(), lstSSPMemberFields);
        Boolean canViewAlienSponsorFields = ESAPI.accessController().isAuthorizedToView(SSP_Aliensponsor__c.getSObjectType(), lstAlienSponsorFields);
        if(canViewApplIndFields && canViewSSPMemberFields && canViewAlienSponsorFields) {
        	/*lstApplicationIndividuals = [SELECT Id, IsHeadOfHousehold__c, SSP_Member__c, SSP_Member__r.FirstName__c, 
                                                                        	SSP_Member__r.SponsoredByOrganization__c, SSP_Member__r.Lastname__c,
                                                                            SSP_Member__r.IsUSCitizenToggle__c, SSP_Member__r.InternalAlienSponsor__c,
                                                                            SSP_Member__r.InternalAlienSponsor__r.FirstName__c, SSP_Member__r.InternalAlienSponsor__r.LastName__c,
                                                                            SSP_Member__r.ExternalAlienSponsor__c, SSP_Member__r.ExternalAlienSponsor__r.SponsorFirstName__c                                                                            
                                                               				FROM SSP_ApplicationIndividual__c
                                                               				WHERE SSP_Application__c =: applicationId];*/
            Set<String> allApplIndFieldSet = new Set<String>{'Id','IsHeadOfHousehold__c','SSP_Member__c','MedicaidType__c','SSP_Member__r.FirstName__c','SSP_Member__r.SponsoredByOrganization__c',
                'SSP_Member__r.Lastname__c','SSP_Member__r.IsUSCitizenToggle__c','SSP_Member__r.InternalAlienSponsor__c','SSP_Member__r.InternalAlienSponsor__r.FirstName__c',
                'SSP_Member__r.InternalAlienSponsor__r.LastName__c','SSP_Member__r.ExternalAlienSponsor__c','SSP_Member__r.ExternalAlienSponsor__r.SponsorFirstName__c'};
            detailMap.put('objectName','SSP_ApplicationIndividual__c');
            conditionMap.put('SSP_Application__c', applicationId);
            conditionMap.put('IsTMember__c', String.valueOf(false));
            detailMap.put('operator', 'AND');
            detailMap.put('MemberStatus__c', '!=');
            conditionMap.put('MemberStatus__c', SSP_GlobalConstants.MEMBER_REMOVE_STATUS);
            lstApplicationIndividuals = SSP_SharingBypassFetcher.fetchRecords ( 
                detailMap,
                allApplIndFieldSet,
                conditionMap
            );
            
        }
        return lstApplicationIndividuals;
    }
    
    /*
	* method 		: storeAlienSponsorData
	* @description  : This method is use to store the Alien Sponsor data.
	* @author 		: Ashwin Kasture
	* @param 		: String sAlienSponsorData - Contains Alien Sponsor data.
	* @return 		: Map<String, Object>
	* */
    public static Map<String, Object> storeAlienSponsorData(String sAlienSponsorData) {    	
        SSP_Utility.isAuthenticatedUser();
        Map<String, Object> mapAlienSponsor = (Map<String, Object>)JSON.deserializeUntyped(sAlienSponsorData);        
        Map<String, Object> mapResponse = new Map<String, Object>();
        SSP_Member__c objMemberData = new SSP_Member__c();
        SSP_AlienSponsor__c objAlienSponsorData = new SSP_AlienSponsor__c();
        String SOMEONE_ELSE = 'someoneElse';
        
        objMemberData.Id = String.valueOf(mapAlienSponsor.get('sMemberId'));
        objMemberData.SponsoredByOrganization__c = mapAlienSponsor.get('SponsoredByOrganization__c') != null ? String.valueOf(mapAlienSponsor.get('SponsoredByOrganization__c')) : '';
        objMemberData.InternalAlienSponsor__c = mapAlienSponsor.get('InternalAlienSponsor__c') != null && mapAlienSponsor.get('InternalAlienSponsor__c') != '' ? String.valueOf(mapAlienSponsor.get('InternalAlienSponsor__c')) : null;
        objMemberData.ExternalAlienSponsor__c = mapAlienSponsor.get('ExternalAlienSponsor__c') != null && mapAlienSponsor.get('ExternalAlienSponsor__c') != '' && mapAlienSponsor.get('ExternalAlienSponsor__c') != SOMEONE_ELSE ? String.valueOf(mapAlienSponsor.get('ExternalAlienSponsor__c')) : null;
        objAlienSponsorData.SponsorFirstName__c = mapAlienSponsor.get('SponsorFirstName__c') != null ? String.valueOf(mapAlienSponsor.get('SponsorFirstName__c')) : '';
        objAlienSponsorData.PrimaryPhoneNumber__c = mapAlienSponsor.get('PrimaryPhoneNumber__c') != null ? String.valueOf(mapAlienSponsor.get('PrimaryPhoneNumber__c')) : '';
        objAlienSponsorData.AddressLine1__c = mapAlienSponsor.get('sAddressLine1') != null ? String.valueOf(mapAlienSponsor.get('sAddressLine1')) : '';
        objAlienSponsorData.AddressLine2__c = mapAlienSponsor.get('sAddressLine2') != null ? String.valueOf(mapAlienSponsor.get('sAddressLine2')) : '';
        objAlienSponsorData.City__c = mapAlienSponsor.get('sCity') != null ? String.valueOf(mapAlienSponsor.get('sCity')) : '';
        objAlienSponsorData.Countycode__c = mapAlienSponsor.get('sCountyCode') != null ? String.valueOf(mapAlienSponsor.get('sCountyCode')) : '';
        objAlienSponsorData.CountryCode__c = mapAlienSponsor.get('sCountryCode') != null ? String.valueOf(mapAlienSponsor.get('sCountryCode')) : '';
        objAlienSponsorData.StateCode__c = mapAlienSponsor.get('sStateCode') != null ? String.valueOf(mapAlienSponsor.get('sStateCode')) : '';
        objAlienSponsorData.Zipcode4__c = mapAlienSponsor.get('sZipCode4') != null ? String.valueOf(mapAlienSponsor.get('sZipCode4')) : '';        

        if(objAlienSponsorData != null && mapAlienSponsor.get('SponsorFirstName__c') != null && mapAlienSponsor.get('sAddressLine1') != null) {
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objAlienSponsorData}, 'insert', 'SSP_AlienSponsor__c');
            mapResponse.put('newAlienSponsorData', objAlienSponsorData);
            objMemberData.ExternalAlienSponsor__c = objAlienSponsorData.Id;
        }
        
        if(objMemberData != null) {
            SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objMemberData}, 'update', 'SSP_Member__c');
            mapResponse.put('memberData', objMemberData);
        }
        return mapResponse;
    }
}