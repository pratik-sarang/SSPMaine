/*
* classname 	: SSP_AddressService
* @description 	: Service class for managing operations related to address.
* @author 		: Ajay Saini
* @date 		: DEC-4-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ajay Saini 		DEC-4-2019			Initial Version
*/

public with sharing class SSP_AddressService {

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-4-2019
    * @methodname   getCountyCode
    * @description  helper to fetch County code from county name
    * @return       return if update is attempted and was successfull.
    *****************************************************************************************************/
    public static String getCountyCode(String countyName) {
        countyName = countyName.toLowerCase();
        Map<String, String> values = SSP_Utility.getPickListValues('SSP_Member__c', 'PhysicalCountyCode__c', null);
        for(String countyCode: values.keySet()) {
            if(countyName == values.get(countyCode).toLowerCase()) {
                return countyCode;
            }
        }
        //return OUT OF COUNTY code, if not found
        return '200';
    }
   /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-4-2019
    * @methodname   validateMemberPhysicalAddress
    * @description  method to validate member's physical address
    * @return       updated record after if the address is validated successfully.
    *****************************************************************************************************/
    public static List<LOG_LogMessage__c> validateMemberPhysicalAddress(SSP_Member__c member) {
        SSP_AddressVerificationWSDLService.COT_USAC_County_op1 request = new SSP_AddressVerificationWSDLService.COT_USAC_County_op1();
        request.record_id = '';
        request.line1 = String.isEmpty(member.PhysicalAddressLine1__c)? '' : member.PhysicalAddressLine1__c;
        request.line2 = String.isEmpty(member.PhysicalAddressLine2__c)? '' : member.PhysicalAddressLine2__c;
        request.city = String.isEmpty(member.PhysicalCity__c)? '' : member.PhysicalCity__c;
        request.state = String.isEmpty(member.PhysicalStateCode__c)? '' : member.PhysicalStateCode__c; 
        request.zip = String.isEmpty(member.PhysicalZipCode5__c)? '' : member.PhysicalZipCode5__c;
        List<Object> responseRecords = IntegrationFactory.invokeCallout('SSP_AddressVerification', new Map<String, Object>{'body' => JSON.serialize(request)});
        if(responseRecords != null && !responseRecords.isEmpty() && responseRecords[0] != null) {
            SSP_AddressResponseWrapper responseContainer = (SSP_AddressResponseWrapper)responseRecords[0];
            SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1 response = (SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1)responseContainer.responseDetail;
            if(response != null) {
                member.PhysicalAddrValidated__c = true;
                member.PhysicalMailAddrDeliveryCode__c = response.cot_mail_delivery_code;
                member.PhysicalCertifiedNoStatIndicator__c = response.cass_no_stat_ind;
                member.PhysicalResidentialDeliveryIndicator__c = response.cass_rdi_ind;
                member.PhysicalCotVacancyIndicator__c = response.cass_vac_ind;
                if(response.cot_mail_delivery_code == 'G') {
                    member.PhysicalAddressLine1__c = SSP_Utility.getRequiredAddressFieldValue(member.PhysicalAddressLine1__c, response.cass_line1);
                    if(String.isNotBlank(response.cass_line2)) {
                        member.PhysicalAddressLine2__c = response.cass_line2;
                    }
                    member.PhysicalCity__c = SSP_Utility.getRequiredAddressFieldValue(member.PhysicalCity__c, response.cass_city);
                    member.PhysicalStateCode__c = SSP_Utility.getRequiredAddressFieldValue(member.PhysicalStateCode__c, response.cass_state);
                    member.PhysicalZipCode4__c = response.cass_zip4;
                    member.PhysicalZipCode5__c = SSP_Utility.getRequiredAddressFieldValue(member.PhysicalZipCode5__c, response.cass_zip5);
                    member.PhysicalCountyCode__c = String.isNotBlank(response.usps_county_name) ? getCountyCode(response.usps_county_name) : SSP_Utility.getRequiredAddressFieldValue(member.PhysicalCountyCode__c, response.usps_county_name);
                }
                else if(response.cot_mail_delivery_code == 'R') {
                    member.PhysicalAddressLine1__c = SSP_Utility.getRequiredAddressFieldValue(member.PhysicalAddressLine1__c, response.cass_line1);
                    if(String.isNotBlank(response.cass_line2)) {
                        member.PhysicalAddressLine2__c = response.cass_line2;
                    }
                    member.PhysicalCity__c = SSP_Utility.getRequiredAddressFieldValue(member.PhysicalCity__c, response.cass_city);
                    member.PhysicalStateCode__c = SSP_Utility.getRequiredAddressFieldValue( member.PhysicalStateCode__c, response.cass_state);
                    member.PhysicalCountyCode__c = String.isNotBlank(response.usps_county_name) ? getCountyCode(response.usps_county_name) : SSP_Utility.getRequiredAddressFieldValue(member.PhysicalCountyCode__c, response.usps_county_name);
                }
            }
            return responseContainer.lstofLogMessages;
        }
        return null;
    }

   /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-4-2019
    * @methodname   validateMemberMailingAddress
    * @description  method to validate member's mailing address
    * @return       updated record after if the address is validated successfully.
    *****************************************************************************************************/
    public static List<LOG_LogMessage__c> validateMemberMailingAddress(SSP_Member__c member) {
        SSP_AddressVerificationWSDLService.COT_USAC_County_op1 request = new SSP_AddressVerificationWSDLService.COT_USAC_County_op1();
        request.record_id = '';
        request.line1 = String.isEmpty(member.MailingAddressLine1__c)? '' : member.MailingAddressLine1__c;
        request.line2 = String.isEmpty(member.MailingAddressLine2__c)? '' : member.MailingAddressLine2__c;
        request.city = String.isEmpty(member.MailingCity__c)? '' : member.MailingCity__c;
        request.state = String.isEmpty(member.MailingStateCode__c)? '' : member.MailingStateCode__c; 
        request.zip = String.isEmpty(member.MailingZipCode5__c)? '' : member.MailingZipCode5__c;
        List<Object> responseRecords = IntegrationFactory.invokeCallout('SSP_AddressVerification', new Map<String, Object>{'body' => JSON.serialize(request)});
        if(responseRecords != null && !responseRecords.isEmpty() && responseRecords[0] != null) {
            SSP_AddressResponseWrapper responseContainer = (SSP_AddressResponseWrapper)responseRecords[0];
            SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1 response = (SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1)responseContainer.responseDetail;
            if(response != null) {
                member.MailingAddrValidated__c = true;
                member.MailingMailAddrDeliveryCode__c = response.cot_mail_delivery_code;
                member.MailingCertifiedNoStatIndicator__c = response.cass_no_stat_ind;
                member.MailingResidentialDeliveryIndicator__c = response.cass_rdi_ind;
                member.MailingCotVacancyIndicator__c = response.cass_vac_ind;
                if(response.cot_mail_delivery_code == 'G') {
                    member.MailingAddressLine1__c = SSP_Utility.getRequiredAddressFieldValue(member.MailingAddressLine1__c, response.cass_line1);
                    if(String.isNotBlank(response.cass_line2)) {
                        member.MailingAddressLine2__c = response.cass_line2;
                    }
                    member.MailingCity__c = SSP_Utility.getRequiredAddressFieldValue(member.MailingCity__c, response.cass_city);
                    member.MailingStateCode__c = SSP_Utility.getRequiredAddressFieldValue(member.MailingStateCode__c,response.cass_state);
                    member.MailingZipCode4__c = response.cass_zip4;
                    member.MailingZipCode5__c = SSP_Utility.getRequiredAddressFieldValue(member.MailingZipCode5__c, response.cass_zip5);
                    member.MailingCountyCode__c = String.isNotBlank(response.usps_county_name) ? getCountyCode(response.usps_county_name) : SSP_Utility.getRequiredAddressFieldValue(member.MailingCountyCode__c, response.usps_county_name);
                }
                else if (response.cot_mail_delivery_code == 'R') {
                    member.MailingAddressLine1__c = SSP_Utility.getRequiredAddressFieldValue(response.cass_line1,member.MailingAddressLine1__c);
                    if(String.isNotBlank(response.cass_line2)) {
                        member.MailingAddressLine2__c = response.cass_line2;
                    }
                    member.MailingCity__c = SSP_Utility.getRequiredAddressFieldValue(response.cass_city, member.MailingCity__c);
                    member.MailingStateCode__c = SSP_Utility.getRequiredAddressFieldValue(member.MailingStateCode__c, response.cass_state);
                    member.MailingCountyCode__c =  String.isNotBlank(response.usps_county_name) ? getCountyCode(response.usps_county_name) : SSP_Utility.getRequiredAddressFieldValue(member.MailingCountyCode__c, response.usps_county_name);
                }
            }
            return responseContainer.lstofLogMessages;
        }
        return null;
    }

    /***************************************************************************************************
    * @author       Ajay Saini
    * @date         DEC-4-2019
    * @methodname   validate
    * @description  update utility for saving/updating the addresses on member records
                    with provision to bypass validation.
    * @return       return if update is attempted and was successfull.
    *****************************************************************************************************/
    public static List<LOG_LogMessage__c> validateMemberAddress(List<SSP_Member__c> members) {
        Set<String> physicalAddressFields = new Set<String>{
            'PhysicalAddressLine1__c',
            'PhysicalAddressLine2__c',
            'PhysicalCity__c',
            'PhysicalCountyCode__c',
            'PhysicalStateCode__c',
            'PhysicalZipCode4__c',
            'PhysicalZipCode5__c',
            'PhysicalCountryCode__c',
            'PhysicalGeolocation__Latitude__s',
            'PhysicalGeolocation__Longitude__s',
            'PhysicalAddrValidated__c',
            'PhysicalMailAddrDeliveryCode__c',
            'PhysicalCertifiedNoStatIndicator__c',
            'PhysicalResidentialDeliveryIndicator__c',
            'PhysicalCotVacancyIndicator__c'
            };
        Set<String> mailingAddressFields = new Set<String>{
            'MailingAddressLine1__c',
            'MailingAddressLine2__c',
            'MailingCity__c',
            'MailingCountyCode__c',
            'MailingStateCode__c',
            'MailingZipCode4__c',
            'MailingZipCode5__c',
            'MailingCountryCode__c',
            'MailingGeolocation__Latitude__s',
            'MailingGeolocation__Longitude__s',
            'MailingAddrValidated__c',
            'MailingMailAddrDeliveryCode__c',
            'MailingCertifiedNoStatIndicator__c',
            'MailingResidentialDeliveryIndicator__c',
            'MailingCotVacancyIndicator__c'
            };
        List<LOG_LogMessage__c> logRecords = new List<LOG_LogMessage__c>();
        for(SSP_Member__c member: members) {
            Boolean isFixedAddress = member.IsFixedAddressToggle__c == SSP_GlobalConstants.YES;
            Boolean isMailingAddressDifferent = member.HasDifferentMailingAddressToggle__c == SSP_GlobalConstants.YES;

            if(isFixedAddress == true) {
                List<LOG_LogMessage__c> physicalAddressLogs = validateMemberPhysicalAddress(member);
                if(physicalAddressLogs != null) {
                    logRecords.addAll(physicalAddressLogs);
                }
            }

            if(isMailingAddressDifferent == true) {
                List<LOG_LogMessage__c> mailingAddressLogs = validateMemberMailingAddress(member);
                if(mailingAddressLogs != null) {
                    logRecords.addAll(mailingAddressLogs);
                }
            }
            
            if(isFixedAddress == false) {
                for(String field: physicalAddressFields) {
                    member.put(field, null);
                }
                member.PhysicalAddrValidated__c = false;
            }
            
            if(isFixedAddress == true && isMailingAddressDifferent == false) {
                member.MailingAddrValidated__c = false;
            }
        }
        return logRecords;
    }

    public static List<SSP_Member__c> copyMailingFromPhysicalAddress(List<SSP_Member__c> members) {
        if(members == null && members.isEmpty()) {
            return members;
        }
        for(SSP_Member__c member: members) {
            if(member.HasDifferentMailingAddressToggle__c != SSP_GlobalConstants.YES) {
                member.MailingAddressLine1__c = member.PhysicalAddressLine1__c;
                member.MailingAddressLine2__c = member.PhysicalAddressLine2__c;
                member.MailingCity__c = member.PhysicalCity__c;
                member.MailingStateCode__c = member.PhysicalStateCode__c;
                member.MailingZipCode4__c = member.PhysicalZipCode4__c;
                member.MailingZipCode5__c = member.PhysicalZipCode5__c;
                member.MailingCountyCode__c = member.PhysicalCountyCode__c;
                member.MailingCountryCode__c = member.PhysicalCountryCode__c;
                member.MailingGeolocation__Latitude__s = member.PhysicalGeolocation__Latitude__s;
                member.MailingGeolocation__Longitude__s = member.PhysicalGeolocation__Longitude__s;
                member.MailingAddrValidated__c = member.PhysicalAddrValidated__c;
                member.MailingMailAddrDeliveryCode__c = member.PhysicalMailAddrDeliveryCode__c;
                member.MailingCertifiedNoStatIndicator__c = member.PhysicalCertifiedNoStatIndicator__c;
                member.MailingResidentialDeliveryIndicator__c = member.PhysicalResidentialDeliveryIndicator__c;
                member.MailingCotVacancyIndicator__c = member.PhysicalResidentialDeliveryIndicator__c;
            }
        }
        return members;
    }
}