/*
* Classname 		:  SSP_AVSIntegrationTest
* @description 	:  This class is the test class of SSP_AVSIntegrationService
* @author 		:  Rijia Khatun
* @date 		:  21/2/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/
@isTest
public class SSP_AVSIntegrationTest {
    @isTest 
    static void aVSTest() {
        Test.setMock(WebServiceMock.class, new SSP_AVSMockClass());
        Test.startTest(); 
        SSP_AVSSchemasPostAvstr.identity_element objRequest = new  SSP_AVSSchemasPostAvstr.identity_element();
        objRequest.socialSecurityNumber = '676766235';
        SSP_AVSSchemasPostAvstr.name_element objName = new SSP_AVSSchemasPostAvstr.name_element();
        objName.firstName = 'Roseanne' ;
        objName.lastName = 'Smith';
        objName.middleName = 'Sr';
        objRequest.name = objName;
        SSP_AVSSchemasPostAvstr.dateOfBirth_element objDOB = new SSP_AVSSchemasPostAvstr.dateOfBirth_element();
        objDOB.year = '1993';
        objDOB.month = '12';
        objDOB.date_x = '17';
        objRequest.dateOfBirth = objDOB;

        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objRequest),
        SSP_InterfaceConstants.SSPAHI_APPLICATIONID=>'AppId',
        SSP_InterfaceConstants.SSPAHI_CASENUMBER=>'CaseNumber'};
        SSP_AVSTempuriOrgImports objTemp = new SSP_AVSTempuriOrgImports();
        SSP_AVSSchemasPostAvstr.financialInstitutions_element objFin = new SSP_AVSSchemasPostAvstr.financialInstitutions_element(); 
        objFin.institution = 'Test';
        objFin.institutionId = 'Test';
        
        SSP_AVSSchemasPostAvstr.address_element objAddress = new SSP_AVSSchemasPostAvstr.address_element();
        objAddress.addressLine1 = '';
        objAddress.addressLine2 = '';
        objAddress.city = '';
        objAddress.state ='';
        objAddress.zip4 = '';
        objAddress.zip5 = '';
        
        SSP_AVSSchemasPostAvstr.addresses_element objAddresses = new SSP_AVSSchemasPostAvstr.addresses_element();
        objAddresses.type_x = '';
        objAddresses.addressLine = '';
        objAddresses.city = '';
        objAddresses.state ='';
        objAddresses.zip = '';
        
        SSP_AVSSchemasPostAvstr.phoneNumber_element objPh = new  SSP_AVSSchemasPostAvstr.phoneNumber_element();
        objPh.areaCode = '';
        objPh.extension = '';
        objPh.telephoneNumber = '';
        

        
        SSP_AVSSchemasPostAvstr.propertyUse_element objProperty = new SSP_AVSSchemasPostAvstr.propertyUse_element();
        objProperty.code = '';
        objProperty.description ='';
        
        SSP_AVSSchemasPostAvstr.error_element objError = new SSP_AVSSchemasPostAvstr.error_element();
        objError.statusCode = '';
        objError.message = '';
        objError.field ='';
        
        SSP_AVSSchemasPostAvstr.transactions_element objTran = new SSP_AVSSchemasPostAvstr.transactions_element();
		objTran.marketValue ='';
        objTran.parcelNumber ='';
        objTran.priceOnTransaction ='';
        objTran.transactionDate ='';
        objTran.nameOnDeed ='';
        objTran.address =  new SSP_AVSSchemasPostAvstr.address_element();
        objTran.transactionType ='';
        objTran.propertyUse = new SSP_AVSSchemasPostAvstr.propertyUse_element();
        
        SSP_AVSSchemasPostAvstr.user_element objUser = new SSP_AVSSchemasPostAvstr.user_element();
        objUser.id ='';
        objUser.username ='';
        objUser.email ='';
        objUser.customFields = new List<SSP_AVSSchemasPostAvstr.customFields_element>();
      
        
        SSP_AVSSchemasPostAvstr.employmentInformation_element objEmploy = new SSP_AVSSchemasPostAvstr.employmentInformation_element();
        objEmploy.employmentHistory = new List<SSP_AVSSchemasPostAvstr.employmentHistory_element>();
        objEmploy.error = new SSP_AVSSchemasPostAvstr.error_element();
        
        
        SSP_AVSSchemasPostAvstr.identityCheckInformation_element objIdentityCheck = new SSP_AVSSchemasPostAvstr.identityCheckInformation_element();
        objIdentityCheck.decision ='';
        objIdentityCheck.reasonCodes = new List<SSP_AVSSchemasPostAvstr.reasonCodes_element>();
        objIdentityCheck.error = new SSP_AVSSchemasPostAvstr.error_element();
        
        SSP_AVSSchemasPostAvstr.accountInformation_element objAccInfo = new SSP_AVSSchemasPostAvstr.accountInformation_element();
        objAccInfo.financialInstitutions = new List<SSP_AVSSchemasPostAvstr.financialInstitutions_element>();
        objAccInfo.error = new SSP_AVSSchemasPostAvstr.error_element();
        
        SSP_AVSSchemasPostAvstr.employmentHistory_element objEmplyHis = new SSP_AVSSchemasPostAvstr.employmentHistory_element();
        objEmplyHis.employerCode = '';
        objEmplyHis.employerName = '';
        objEmplyHis.employerName2 = '';
        objEmplyHis.statusMessage = '';
        objEmplyHis.lastPayPeriod = '';
        
        
        SSP_AVSSchemasPostAvstr.propertyInformation_element objPropInfo = new SSP_AVSSchemasPostAvstr.propertyInformation_element();
        objPropInfo.error = new  SSP_AVSSchemasPostAvstr.error_element();
        objPropInfo.events = new  List<SSP_AVSSchemasPostAvstr.events_element>();
        objPropInfo.transactions = new  List<SSP_AVSSchemasPostAvstr.transactions_element>();
		SSP_AVSMicrosoftComMessage.MessageBody objMessage = new SSP_AVSMicrosoftComMessage.MessageBody();
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPAVS_METADATANAME, objResponse);
        System.assertEquals(2,lstData.size(),'Wrong Output');
        Test.stopTest();
    }
  	@isTest 
    static void aVSTestNegetive() {
        Test.startTest() ;
        SSP_AVSSchemasPostAvstr.identity_element objRequest = new  SSP_AVSSchemasPostAvstr.identity_element();
        Map<String, Object> objResponse = new Map<String, Object>{'body'=> JSON.serialize(objRequest),
        SSP_InterfaceConstants.SSPAHI_APPLICATIONID=>'AppId',
        SSP_InterfaceConstants.SSPAHI_CASENUMBER=>'CaseNumber'};
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPAVS_METADATANAME, objResponse);
        System.assertEquals(2,lstData.size(),'Wrong Output'); 
        Test.stopTest();
    }
}