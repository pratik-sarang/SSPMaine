/*
 * Classname             : SSP_KIHIPPPayment
 * @description          : This is controller class for KIHIPP Preferred Payment Method
 * @author               : Shobhit Jain
 * @date                 : 07/15/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/

public with sharing class SSP_KIHIPPPayment {
    @AuraEnabled(cacheable=false)
    public static String getKIHIPPreferredPaymentMethod(string IndividualIds){
        try{
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.KIHIPP_PREFERRED_PAYMENT;
            reqWrapper.IndividualIds = IndividualIds;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            if (mapParams.isEmpty()){
                return null;
            } else {
                List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
                RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
                System.debug('Response_Wrapper'+JSON.serialize(responseWrapper));
                return JSON.serialize(responseWrapper);
            }
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethod', 'getKIHIPPreferredPaymentMethod', e.getMessage(), true);
        }
        return  null;
    }
      /***************************************************************************************************
* @author       Shobhit Jain
* @date         17/07/2020
* @methodname   getBankDetails
* @description  This methods is used to get Bank details associated to Routing Number
* @return       
*****************************************************************************************************/
@AuraEnabled
public static SSP_LightningResponse getBankDetails(String routingNumber){
    try{
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_Institution__c> sspInstitutionList = SSP_KHIPPPreferredPaymentMethodService.getBankDetails(new Set<String>{routingNumber});
        if(!sspInstitutionList.isEmpty()){
            objResponse.put('bankDetails', sspInstitutionList[0]);
            return objResponse;
        }
    }catch(Exception e){
        LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethod', 'getBankDetails', e.getMessage(), true);
    }
    
    return null;
}
/***************************************************************************************************
* @author       Shobhit Jain
* @date         17/07/2020
* @methodname   pushChangeDataToExternalSystem
* @description  This methods is used to update the change data from screen to external system.
* @return       
*****************************************************************************************************/

@AuraEnabled(cacheable=false)    
public static string pushChangeDataToExternalSystem(Integer caseNumber,Integer PolicyHolderId,string accountNumber,string IssuanceMethodCode, string RoutingNumber,
string BankName, string BankZipCode, string BankStateCode, string BankCity, string bankAddress){
		
        SSP_DataContractOrg.PreferredPaymentIssuanceRequest req = new SSP_DataContractOrg.PreferredPaymentIssuanceRequest();
        req.AccountNumber=accountNumber;
        req.RoutingNumber= RoutingNumber;
        req.BankName = BankName;
        req.IssuanceMethodCode= IssuanceMethodCode;
        req.CaseNumber= caseNumber; 
        req.PolicyHolderId = PolicyHolderId;       
        req.BankStateCode= BankStateCode;
        req.BankCity= BankCity;
        req.BankZipCode= BankZipCode;
        req.Address = bankAddress;
        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,caseNumber);
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_KIHIPPPayment_METADATANAME, objResponse);
        SSP_DataContractOrg.AdhocSFServiceResponse objResponse1 = (SSP_DataContractOrg.AdhocSFServiceResponse) lstData.get(0);
        system.debug('@@objResponse'+objResponse1);
        return JSON.serialize(objResponse1);

    }
}