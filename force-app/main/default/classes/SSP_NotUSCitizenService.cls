/***************************************************************************************************************************
*   Type         :   Service Class
*   Name         :   SSP_NotUSCitizenService
*   Created By   :   Shivam Tiwari
*   Created Date :   29-JAN-2020
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Shivam Tiwari                    29-JAN-2020        Initial Version
*****************************************************************************************************************************/
public class SSP_NotUSCitizenService {
    
    /********************************************************************************************
    * @author       Shivam Tiwari
    * @date         29-JAN-2020
    * @description  This method prepares the request for VLP service call.
    * @param        jsonMemberData
    * @param        applicationNumber
    * @return       String
	********************************************************************************************/
    public static map<String,Object> prepareRequest(String jsonMemberData, String applicationNumber, SSP_Member__c objMember) {
        map<String,Object> objResponse = new map<String,Object>();
        SSP_VLPRequestWrapper reqWrapper = new SSP_VLPRequestWrapper();
            if(!String.isBlank(jsonMemberData) && !String.isBlank(applicationNumber)){
                SSP_NotUSCitizenController.memberDataWrapper memberWrapper = (SSP_NotUSCitizenController.memberDataWrapper)JSON.deserialize(jsonMemberData, SSP_NotUSCitizenController.memberDataWrapper.class);
                
                
                SSP_VLPRequestWrapper.VLPLawfulPresenceRequest VLPlawful = new SSP_VLPRequestWrapper.VLPLawfulPresenceRequest();
                SSP_VLPRequestWrapper.cls_LawfulPresenceRequest lawfulElement = new SSP_VLPRequestWrapper.cls_LawfulPresenceRequest();
				SSP_VLPRequestWrapper.cls_DHSId DHSIdElement = new SSP_VLPRequestWrapper.cls_DHSId();
                List<SSP_VLPRequestWrapper.cls_LawfulPresenceRequest> lawfulList = new List<SSP_VLPRequestWrapper.cls_LawfulPresenceRequest>();
                SSP_VLPRequestWrapper.cls_LawfulPresenceRequestList lawfulListElement = new SSP_VLPRequestWrapper.cls_LawfulPresenceRequestList();
                
                reqWrapper.SourceSystem = SSP_GlobalConstants.SSP;
                VLPlawful.ApplicationNumber = applicationNumber;
                
                    lawfulElement.PersonSurName = (memberWrapper.immigrationLastName) != NULL ? memberWrapper.immigrationLastName : objMember.LastName__c;
                    lawfulElement.PersonNameSuffixText = (memberWrapper.immigrationSuffix) != NULL ? memberWrapper.immigrationSuffix : objMember.SuffixCode__c;
                    lawfulElement.PersonGivenName = (memberWrapper.immigrationFirstName) != NULL ? memberWrapper.immigrationFirstName : objMember.FirstName__c;
                    lawfulElement.PersonMiddleName = memberWrapper.immigrationMiddleName != NULL ? memberWrapper.immigrationMiddleName : objMember.MiddleInitial__c;
                    lawfulElement.PersonBirthDate = memberWrapper.immigrationDateOfBirth != NULL ? memberWrapper.immigrationDateOfBirth : objMember.BirthDate__c;
                if(memberWrapper.alienTypeCode == SSP_GlobalConstants.CHP){
                    lawfulElement.RequesterCommentsForHub = SSP_GlobalConstants.CUBAN_HAITIAN;
                }
                if(memberWrapper.immigrationDateOfBirth != null || objMember.BirthDate__c != NULL){
                    Date dPersonDate = memberWrapper.immigrationDateOfBirth != NULL ? memberWrapper.immigrationDateOfBirth : objMember.BirthDate__c;
                    lawfulElement.PersonBirthDate = dPersonDate;

                    Double age = (dPersonDate.monthsBetween(system.today()))/12;
                    if (age > 19 && memberWrapper.hasLivedInUS == SSP_GlobalConstants.NO && memberWrapper.servedInUSMilitary == SSP_GlobalConstants.NO ){
                        lawfulElement.FiveYearBarApplicabilityIndicator = true;
                    }
                    else{
                        lawfulElement.FiveYearBarApplicabilityIndicator = false;
                    }
                }
                if(memberWrapper.immigrationDocumentTypeCode != null){
                    Date dt = memberWrapper.documentExpiryDate;
                    DateTime conDT;
                    DateTime nullDT;
                    if(dt != NULL){
                        conDT  = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                    }
                    nullDT  = DateTime.newInstance(0001, 01, 03, 00, 00, 00);
                    if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_DS2){
                        SSP_VLPRequestWrapper.DS2019DocumentId ds2 = new SSP_VLPRequestWrapper.DS2019DocumentId();
                        ds2.DocExpirationDate = nullDT;
                        ds2.SEVISID = memberWrapper.SEVISId;
                        DHSIdElement.DS2019DocumentId = ds2;
                        lawfulElement.RequestGrantDateIndicator = false;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_FP){
                        SSP_VLPRequestWrapper.UnexpForeignPassportDocumentId fp = new SSP_VLPRequestWrapper.UnexpForeignPassportDocumentId();
                        fp.DocExpirationDate = conDT;
                        fp.SEVISID = null;
                        fp.I94Number = memberWrapper.i94Number;
                        fp.CountryOfIssuance = memberWrapper.issuanceCountryCode;
                        fp.PassportNumber = memberWrapper.passportNumber;
                        DHSIdElement.UnexpForeignPassportDocumentId = fp;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_CZ){
                        SSP_VLPRequestWrapper.CertOfCitDocumentId cz = new SSP_VLPRequestWrapper.CertOfCitDocumentId();
                        cz.AlienNumber = memberWrapper.alienNumber;
                        cz.CitizenshipNumber = memberWrapper.citizenshipNumber;
                        DHSIdElement.CertOfCitDocumentId = cz;
                        lawfulElement.RequestGrantDateIndicator = false;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I20){
                        SSP_VLPRequestWrapper.I94DocumentId i20 = new SSP_VLPRequestWrapper.I94DocumentId();
                        i20.SEVISID = memberWrapper.SEVISId;
                        i20.DocExpirationDate = nullDT;
                        i20.I94Number = null;
                        DHSIdElement.I20DocumentId = i20;
                        lawfulElement.RequestGrantDateIndicator = false;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I3){
                        SSP_VLPRequestWrapper.I571DocumentId i3 = new SSP_VLPRequestWrapper.I571DocumentId();
						i3.AlienNumber = memberWrapper.alienNumber;
                        i3.DocExpirationDate = nullDT;
                        DHSIdElement.I327DocumentId = i3;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I57){
                        SSP_VLPRequestWrapper.I571DocumentId i57 = new SSP_VLPRequestWrapper.I571DocumentId();
						i57.AlienNumber = memberWrapper.alienNumber;
                        i57.DocExpirationDate = nullDT;
                        DHSIdElement.I571DocumentId = i57;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.AR){
                        SSP_VLPRequestWrapper.I551DocumentId ar = new SSP_VLPRequestWrapper.I551DocumentId();
						ar.AlienNumber = memberWrapper.alienNumber;
                        ar.CardNumber = memberWrapper.receiptNumber;
                        ar.DocExpirationDate = nullDT;
                        DHSIdElement.I551DocumentId = ar;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I5){
                        SSP_VLPRequestWrapper.TempI551DocumentId i5 = new SSP_VLPRequestWrapper.TempI551DocumentId();
						i5.AlienNumber = memberWrapper.alienNumber;
                        i5.DocExpirationDate = nullDT;
                        i5.CountryOfIssuance = null;
                        i5.PassportNumber = null;
                        DHSIdElement.TempI551DocumentId = i5;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I76){
                        SSP_VLPRequestWrapper.I766DocumentId i76 = new SSP_VLPRequestWrapper.I766DocumentId();
						i76.AlienNumber = memberWrapper.alienNumber;
                        i76.ReceiptNumber = memberWrapper.receiptNumber;	//IS card number and reciept number same.
                        i76.DocExpirationDate = nullDT;
                        DHSIdElement.I766DocumentId = i76;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I9){
                        SSP_VLPRequestWrapper.I94DocumentId i9 = new SSP_VLPRequestWrapper.I94DocumentId();
                        i9.SEVISID = null;
                        i9.DocExpirationDate = nullDT;
                        i9.I94Number = memberWrapper.i94Number;
                        DHSIdElement.I94DocumentId = i9;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I9F){
                        SSP_VLPRequestWrapper.I94UnexpForeignPassportDocumentId i9f = new SSP_VLPRequestWrapper.I94UnexpForeignPassportDocumentId();
                        i9f.PassportNumber = memberWrapper.passportNumber;
                        i9f.CountryOfIssuance = memberWrapper.issuanceCountryCode;
                        i9f.DocExpirationDate = conDT;
                        i9f.I94Number = memberWrapper.i94Number;
                        i9f.SEVISID = null;
                        DHSIdElement.I94UnexpForeignPassportDocumentId = i9f;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_MRV){
                        SSP_VLPRequestWrapper.MacReadI551DocumentId mrv = new SSP_VLPRequestWrapper.MacReadI551DocumentId();
                        mrv.PassportNumber = memberWrapper.passportNumber;
                        mrv.CountryOfIssuance = memberWrapper.issuanceCountryCode;
                        mrv.DocExpirationDate = nullDT;
                        mrv.AlienNumber = memberWrapper.alienNumber;
                        DHSIdElement.MacReadI551DocumentId = mrv;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_INT){
                        SSP_VLPRequestWrapper.NatrOfCertDocumentId nt = new SSP_VLPRequestWrapper.NatrOfCertDocumentId();
                        nt.NaturalizationNumber = memberWrapper.naturalizationNumber;
                        nt.AlienNumber = memberWrapper.alienNumber;
                        DHSIdElement.NatrOfCertDocumentId = nt;
                        lawfulElement.RequestGrantDateIndicator = false;
                    }
                    else if(memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_OT || memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_I79 ||
                           memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_AI || memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_CHE ||
                           memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_OREL || memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_RAS ||
                           memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_WR || memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_INA1 ||
                           memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_DHS || memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_INA3 ||
                           memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_HHS || memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_NA ||
                           memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.IMMIGRATION_DOCTYPE_ORR || memberWrapper.immigrationDocumentTypeCode == SSP_GlobalConstants.CV ){
                        SSP_VLPRequestWrapper.OtherCase1DocumentId oth = new SSP_VLPRequestWrapper.OtherCase1DocumentId();
                        oth.AlienNumber = memberWrapper.alienNumber;
                        oth.CountryOfIssuance = memberWrapper.issuanceCountryCode;
                        oth.DocExpirationDate = conDT;
                        oth.DocDescReq = memberWrapper.documentDescription;
                        DHSIdElement.OtherCase1DocumentId = oth;
                        lawfulElement.RequestGrantDateIndicator = true;
                    }
                }
                if(objMember != NULL && objMember.IndividualId__c != NULL){
                    lawfulElement.IndividualId = objMember.IndividualId__c;
                }
                lawfulElement.DHSId = DHSIdElement;
                lawfulList.add(lawfulElement);
                lawfulListElement.LawfulPresenceRequest = lawfulList;
                VLPlawful.LawfulPresenceRequestList = lawfulListElement;
                reqWrapper.VLPLawfulPresenceRequest = VLPlawful;
                
                objResponse.put('bIsSuccess',true) ;
                objResponse.put('vlpRequestData',reqWrapper);

            }
        return objResponse;
    }

}