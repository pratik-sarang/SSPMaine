/*
 * Classname             : SSP_AgreementAndSignatureController
 * @description          : This is controller class for agreement and signature widget
 * @author               : Anuja Ingole
 * @date                 : 06/15/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_AgreementAndSignatureController {
    public SSP_AgreementAndSignatureController() {

    }

    @AuraEnabled
   public static SSP_LightningResponse fetchSignatureData(String appId){
    
    SSP_LightningResponse response = new SSP_LightningResponse();
    List<SSP_PastApplicationsPayloadWrapper.SSP_PastApplicationsWrapper> result = null;
    SSP_PastApplicationsWrapper pastApp = new SSP_PastApplicationsWrapper();
    String individualId = SSP_Utility.getIndividualId(); //Defect-391899
    if(individualId != null){
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.PAST_APPLICATIONS;
        reqWrapper.primaryApplicationIndividualId = individualId; 
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams); 
        if(serviceResponses!= null){
            
            RSSP_DC_Wrapper dCWrapper = (RSSP_DC_Wrapper) serviceResponses.get(0);
            SSP_PastApplicationsPayloadWrapper pastAppsWrapper = new SSP_PastApplicationsPayloadWrapper();
            pastAppsWrapper = (SSP_PastApplicationsPayloadWrapper) dCWrapper.PastApplicationsPayload ;
            if(pastAppsWrapper != null){
                result = pastAppsWrapper.PASTAPPLICATIONS;
                
            }
            if(result != null){
                Integer intIndividualId = Integer.valueOf(individualId);
                List<Contact_Mapping__c> lstContact = [SELECT Contact__c, contact__r.FirstName, contact__r.LastName, Id,IEES_Id__c,Name 
                                                        FROM Contact_Mapping__c Where IEES_Id__c = :intIndividualId];

                for(SSP_PastApplicationsPayloadWrapper.SSP_PastApplicationsWrapper app: result){
                    if(app.applicationNumber == Integer.valueOf(appId)){
                        
                        pastApp.individualId = app.IndividualId;
                        pastApp.ApplicationNumber = app.ApplicationNumber;
                        if(lstContact != null && lstContact.size()>0){
                            pastApp.ApplicationEsignFirstName = lstContact[0].contact__r.FirstName;
                            pastApp.ApplicationEsignLastName = lstContact[0].contact__r.LastName; 
                        }
                        
                        pastApp.IsAgreeingToApplicationConsent = 'Y';
                        pastApp.IsAgreeingToMedicaidPenalty = app.IsAgreeingToMedicaidPenalty;
                        pastApp.IsRenewalConsent = app.IsRenewalConsent;
                        pastApp.IsAgreeingToSNAPRightsConsent = app.ProgramAppliedFor.split(';').contains('SN')? 'Y' : null;
                        pastApp.IsAgreeingToLTCResourceTransferConsent = app.IsAgreeingToLTCResourceTransferConsent;
                        pastApp.IsAgreeingToMA34Declaration = (app.DeclrtnfAnnuitiesAcceptanceCode == null && app.IsDMSAnnuitiesBeneficiary == null) ? NULL : (app.DeclrtnfAnnuitiesAcceptanceCode == 'Y' && app.IsDMSAnnuitiesBeneficiary == 'Y') ? 'Y' : 'N';
                        pastApp.IsAgreeingToKiHippConsent = app.ProgramAppliedFor.split(';').contains('KP')? 'Y' : null;
                        pastApp.IsApplicantAgreeToWorkRegister = app.IsApplicantAgreeToWorkRegister;
                        pastApp.IsRegisteredToVote = app.IsRegisteredToVote;
                        pastApp.additionalInfoSnap = app.ProgramAppliedFor.split(';').contains('SN')? true : false;
                        pastApp.additionalInfoKTAP = app.ProgramAppliedFor.split(';').contains('KT')? true : false;
                        pastApp.additionalInfoMedicaid = app.ProgramAppliedFor.split(';').contains('MA')? true : false;
                        
                        //Format application submitted date as per MM/DD/YYYY
                        if(app.ApplicationReceivedDate != null){
                            List<String> lstStartDate = app.ApplicationReceivedDate.split('-');
                            //received format YYYY-MM-DD. Expected Format - MM/DD/YYYY.
                            String startDate = lstStartDate[1]+'/'+lstStartDate[2]+'/'+lstStartDate[0];
                            pastApp.submittedDate = startDate;
                            pastApp.submittedDateDate = Date.parse(startDate);
                        }
                        
                        break;
                    }
                }
            }
        }
    }
    response.put('resultString', JSON.serialize(pastApp));

    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
    String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
    SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('BEN_PAPP',selectedRole);
    if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible'){
        response.put('showScreen',true);
    }else if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='NotAccessible'){
        response.put('showScreen',false);
    }
    if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='ReadOnly'){
        response.put('showScreen',true);
    }
    
    
    return response;
   }

   public class SSP_PastApplicationsWrapper {
        // public attributes
        public Integer IndividualId;
        public Integer CaseNumber;
        public String CaseStatusCode;
        public Integer ApplicationNumber;
        public String ApplicationReceivedDate;
        public String ProgramAppliedFor;
        public String DMSId;
        public String IsAgreeingToMedicaidPenalty;
        public String IsAgreeingToLTCResourceTransferConsent;
        public String IsRenewalConsent;
        public String IsApplicantAgreeToWorkRegister;
        public String IsRegisteredToVote;
        public String DeclrtnfAnnuitiesAcceptanceCode;
        public String IsDMSAnnuitiesBeneficiary;
        //Added below to show these values on UI
        public Date submittedDateDate;
        public String submittedDate;
        public String ApplicationEsignFirstName;
        public string ApplicationEsignLastName;
        public string IsAgreeingToApplicationConsent;
        public string IsAgreeingToSNAPRightsConsent;
        public string IsAgreeingToMA34Declaration;
        public string IsAgreeingToKiHippConsent;
        public boolean additionalInfoSnap;
        public boolean additionalInfoKTAP;
        public boolean additionalInfoMedicaid;
    }
}
