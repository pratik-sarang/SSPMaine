/*
* Classname         :  SSP_VCIIntegrationService
* @description  :  This class is to make callout for VCI
* @author       :  Rijia Khatun
* @date         :  11/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
public with sharing class SSP_VCIIntegrationService extends RestIntegrationService  {
    @TestVisible private static Boolean boolNegative = false;
    /**
    * method        : processResponse
    * @description  : This method is to process the response
    * @author       : Rijia Khatun
    * @param lstResponseObject : 
    * @param request : Instance of HttpRequest
    * @param response : Response of the callout that needs to be parsed
    * @return: List<Object>
    * */
    public static List<Object> processResponse(HttpResponse response, String sAppId, Set<String> setOfSSNs) {
        if(response.getStatusCode() != 500 && !String.isBlank(response.getBody()) ) {
            if(sAppId != null) {
                //Delete the existing records for this application
                SSP_SharingBypassFetcher.deleteExistingData(sAppId,setOfSSNs);
                //Create new records
                saveVCIData(response.getBody(),sAppId);
            }
        }   
        return null;
    }
    /**
    * method        : invokeCallout
    * @description  : This method is to make callout for VCI interface
    * @author       : Rijia Khatun
    * @param developerName : MetaData record name
    * @param mapInputParams : Request body in a map format
    * @return: List<Object>
    * */
    public static List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams) {
        HttpResponse objRes = new HttpResponse();
        HttpRequest objReq = new HttpRequest();
        List<Object> response = new List<Object>();
        LOG_LogMessage__c logMessage;
        DateTime startTime = Datetime.now();
        Long timeTaken;
        DateTime endTime;
        try{
            objReq = generateRequest(developerName,mapInputParams);
            objRes = sendRequest(objReq);
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            processResponse(objRes,(String)mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID),
            (Set<String>)mapInputParams.get(SSP_InterfaceConstants.SSPVCI_SETOFSSNs));
            if(mapInputParams.containsKey(SSP_InterfaceConstants.IS_DEBUG) && (Boolean) mapInputParams.get(SSP_InterfaceConstants.IS_DEBUG)) {
                String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                    SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                    SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                    mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
                logMessage = LOG_LogMessageUtility.logMessage (
                    LOG_LogMessageUtility.LOG_LogLevel.Info,
                    objReq.getEndpoint(), 
                    'SSP_VCIIntegrationService',
                    developerName,
                    'invokeCallout',
                    stErrorMessage,
                    objReq.getMethod(),
                    objReq.getBody(),
                    'Status Code: '+objRes.getStatusCode(),
                    objRes.getBody(),
                    timeTaken, 
                    false);
            }

        }catch(Exception ex) {
            endTime = Datetime.now();
            timeTaken = endTime.getTime() - startTime.getTime();
            String stErrorMessage =  'Status : '+objRes.getStatus()+'\n'+
                                     SSP_InterfaceConstants.SSPAHI_APPLICATIONID+': '+
                                     mapInputParams.get(SSP_InterfaceConstants.SSPAHI_APPLICATIONID)+'\n'+
                                     SSP_InterfaceConstants.SSPAHI_CASENUMBER+': '+
                                     mapInputParams.get(SSP_InterfaceConstants.SSPAHI_CASENUMBER);
            logMessage= LOG_LogMessageUtility.logMessage (
                                        ex,
                                        objReq.getEndpoint(),
                                        developerName,
                                        'SSP_VCIIntegrationService',
                                        'invokeCallout',
                                        stErrorMessage,
                                        objReq.getMethod(),
                                        objReq.getBody(),
                                        'Status Code: '+objRes.getStatusCode(),
                                        objRes.getBody(),
                                        timeTaken, 
                                        false
                                    );
        }
        response.add(objRes);
        if(logMessage != null) {
            response.add(logMessage);
        }
        return response;
    }
    /**
    * method        : saveVCIData
    * @description  : This method is to save data from VCI interface
    * @author       : Rijia Khatun
    * */
    public static void  saveVCIData (String sResponseBody, String sAppId) {
        List<SSP_Transaction__c> lstData = new List<SSP_Transaction__c>();
        Map<String, Object> mapResults = (Map<String, Object>)JSON.deserializeUntyped(sResponseBody);
        if(mapResults.containsKey('VCIResp')) {
            Map<String, Object> mapResultsResInfo = ((Map<String, Object>)((Map<String, Object>)mapResults.get('VCIResp')).get('ResponseInformation'));
            if(mapResultsResInfo.get('ResponseInformation') != null) {
                for(object objResInfo : (List<Object>)(mapResultsResInfo.get('ResponseInformation'))) {
                    Map<String, Object> mapToGetCurrentInfo = (Map<String, Object>)objResInfo;
                    Map<String, Object> mapIncome =  ((Map<String, Object>) mapToGetCurrentInfo.get('CurrentIncomeInformation'));
                    if(mapIncome != null && mapIncome.get('CurrentIncomeInformation') != null) {
                        for (object objCurrentInfo : (List<Object>) mapIncome.get('CurrentIncomeInformation')) {
                            Map<String, Object> mapCurrentInfo = (Map<String, Object>)objCurrentInfo;
                            Map<String, Object> mapEmployeeInfo = (Map<String, Object>)mapCurrentInfo.get('EmployeeInformation');
                            SSP_Transaction__c objTxn;
                            //Get the employee information
                            if(mapCurrentInfo != null && mapCurrentInfo.containsKey('EmployeeInformation') && mapCurrentInfo.get('EmployeeInformation') !=null) {
                                objTxn = new SSP_Transaction__c();
                                objTxn = assignParentToChild(objTxn,sAppID,mapEmployeeInfo);
                                //skip the loop is SSN is missing
                                if(objTxn.SSN__c == null) {
                                    continue;
                                }
                            }
                            //Get the employer information
                            if(mapCurrentInfo != null && mapCurrentInfo.containsKey('EmployerInformation') && mapCurrentInfo.get('EmployerInformation') !=null) {
                                Map<String, Object> mapEmployerInfo = (Map<String, Object>)mapCurrentInfo.get('EmployerInformation');
                                Map<String, Object> mapEmployerOrg = (Map<String, Object>)mapEmployerInfo.get('EmployerOrganization');
                                Map<String, Object> mapEmployerIdentification = (Map<String, Object>)mapEmployerOrg.get('OrganizationIdentification');
                                objTxn.OrganizationName__c = (String)mapEmployerOrg.get('OrganizationName');
                                objTxn.IdentificationID__c = (String)mapEmployerIdentification.get('IdentificationID');
                            }
                            //Get the employment information
                            if(mapCurrentInfo.containsKey('EmploymentInformation') && mapCurrentInfo.get('EmploymentInformation') !=null) {
                                Map<String, Object> mapEmploymentInfo = (Map<String, Object>)((Map<String, Object>)mapCurrentInfo.get('EmploymentInformation')).get('EmploymentInformation');
                                objTxn.EmployeeStatusCode__c = String.valueOf(mapEmploymentInfo.get('EmployeeStatusCode'));
                                Map<String, Object> mapEmploymentAssociation = (Map<String, Object>)mapEmploymentInfo.get('PersonEmploymentAssociation');
                                if(mapEmploymentAssociation != null) {
                                    Map<String, Object> mapEmploymentStartDate = (Map<String, Object>)mapEmploymentAssociation.get('AssociationBeginDate');
                                    if(mapEmploymentStartDate != null) {
                                        objTxn.put('StartDate__c',Date.valueOf(((String)mapEmploymentStartDate.get('Date')).split('T')[0]));
                                    }
                                    Map<String, Object> mapEmploymentEndDate = (Map<String, Object>)mapEmploymentAssociation.get('AssociationEndDate');// Not getting in res
                                    if(mapEmploymentEndDate != null) {
                                        objTxn.put('EndDate__c',Date.valueOf(((String)mapEmploymentEndDate.get('Date')).split('T')[0]));
                                    }
                                }
                            }
                            //Get base component info
                            if(mapCurrentInfo.containsKey('BaseCompensationInformation') && mapCurrentInfo.get('BaseCompensationInformation') !=null) {
                                Map<String, Object> mapCompensationInfo = (Map<String, Object>)((Map<String, Object>)mapCurrentInfo.get('BaseCompensationInformation')).get('BaseCompensationInformation');
                                if(mapCompensationInfo.get('PayPeriodFrequencyCode') != null) {
                                    objTxn.PayPeriodFrequencyCode__c = (String)mapCompensationInfo.get('PayPeriodFrequencyCode');
                                }
                                if(mapCompensationInfo.get('AnnualizedIncome') != null) {
                                    //objTxn.AnnualizedIncome__c = Decimal.valueOf((String)mapCompensationInfo.get('AnnualizedIncome')); //not getting in res
                                    objTxn.AnnualizedIncome__c = (Decimal)mapCompensationInfo.get('AnnualizedIncome');
                                }
                            }
                            objTxn.Type__c = SSP_GlobalConstants.EMPLOYMENT; //SSP_Interface_Security Fixes moved to Global Constants
                            lstData.add(objTxn);
                            //Get the pay period info 
                            if(mapCurrentInfo.containsKey('PayPeriod') && mapCurrentInfo.get('PayPeriod') !=null) {
                                for (object objPayPeriod : (List<Object>) ((Map<String, Object>) mapCurrentInfo.get('PayPeriod')).get('PayPeriod')) {
                                    Map<String, Object> mapPayPeriod = (Map<String, Object>)objPayPeriod;
                                    Map<String, Object> mapPayPeriodEndDate = (Map<String, Object>)mapPayPeriod.get('PayPeriodEndDate');
                                    Map<String, Object> mapPayPeriodIncome = (Map<String, Object>)mapPayPeriod.get('IncomeDetail');
                                    SSP_Transaction__c objTxnPayPeriod;
                                    if (mapPayPeriodEndDate != null && objTxnPayPeriod == null) {
                                        objTxnPayPeriod = new SSP_Transaction__c();
                                    }
                                    if (mapPayPeriodIncome != null && objTxnPayPeriod == null) {
                                        objTxnPayPeriod = new SSP_Transaction__c();
                                    }
                                    if(objTxnPayPeriod != null) {
                                        objTxnPayPeriod.put('EndDate__c',Date.valueOf(((String)mapPayPeriodEndDate.get('Date')).split('T')[0]));
                                        objTxnPayPeriod.IncomeAmount__c = (Decimal)mapPayPeriodIncome.get('IncomeAmount');
                                        objTxnPayPeriod.Type__c = SSP_GlobalConstants.PAY_PERIOD; //SSP_Interface_Security Fixes moved to Global Constants
                                        objTxnPayPeriod.IdentificationID__c = objTxn.IdentificationID__c;
                                        assignParentToChild(objTxnPayPeriod,sAppID,mapEmployeeInfo);
                                        lstData.add(objTxnPayPeriod);
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(!lstData.isEmpty() && Schema.sObjectType.SSP_Transaction__c.isCreateable() ) {
                Database.insert(lstData);
            }
        }
    }
    /**
    * method        : assignParentToChild
    * @description  : This method is to link parent with child data 
    * @author       : Rijia Khatun
    * */
    public static SSP_Transaction__c assignParentToChild(SSP_Transaction__c objTxn, String sAppID,Map<String, Object> mapEmployeeInfo) {
        Map<String, Object> mapDateOfBirth = (Map<String, Object>)mapEmployeeInfo.get('PersonBirthDate');
        Map<String, Object> mapName = (Map<String, Object>)mapEmployeeInfo.get('PersonName');
        objTxn.InterfaceName__c = SSP_InterfaceConstants.SSPVCI_METADATANAME;
        if(mapEmployeeInfo != null && mapEmployeeInfo.containsKey('PersonSSNIdentification')) {
            objTxn.SSN__c = (String)mapEmployeeInfo.get('PersonSSNIdentification');
        }
        objTxn.put('BirthDate__c',Date.valueOf(((String)mapDateOfBirth.get('Date')).split('T')[0]));
        objTxn.PersonGivenName__c = (String)mapName.get('PersonGivenName');
        objTxn.PersonMiddleName__c = (String)mapName.get('PersonMiddleName');
        objTxn.PersonSurName__c = (String)mapName.get('PersonSurName');
        objTxn.ApplicationId__c = sAppId;
        return objTxn;
    }
}