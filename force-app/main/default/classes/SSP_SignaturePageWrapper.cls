/*
* classname 		: SSP_SignaturePageWrapper
* @description 		: This is the Wrapper class for SignaturePageCtrl.
* @author 			: Sai Kiran.
* @date 			: 02/06/2019.
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_SignaturePageWrapper {
    @AuraEnabled public Boolean bIsNonMagi {get;set;}
    @AuraEnabled public Boolean bShowLTCSection {get;set;}
    @AuraEnabled public String sHouseHoldSpouseName {get;set;}
    @AuraEnabled public String sPrimaryApplicantFirstName {get;set;}
    @AuraEnabled public String sPrimaryApplicantLastName {get;set;}
    @AuraEnabled public String sPrimaryApplicantMiddleName {get;set;}
    @AuraEnabled public String sPrimaryApplicantSuffix {get;set;}
    
    public class Mode{
        public String SSP_APP_ProgramSelection {get;set;}
        public String SSP_APP_HHMembersSummary {get;set;}
        public String REPS_Home {get;set;}
    }
    public class SSP_AppSectionList{
        public Mode Intake, AddRemoveMember,Renewal,ModifyExistingData;
    }
    
    public class SSP_SSPDCResponse{
        public SSP_SSPDCResponseMap SubmitApplicationResponse;
    }
    public class SSP_SSPDCResponseMap{
        public SSP_SSPDCAcknowledgement AckResponse;
    }
    public class SSP_SSPDCAcknowledgement{
        public String AckResponseCode {get;set;}
        public String AckResponseDescription {get;set;}
    }
}