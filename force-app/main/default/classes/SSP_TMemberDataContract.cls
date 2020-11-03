/*
* Classname 	:  SSP_TMemberDataContract
* @description 	:  This class is a stub class for TMember
* @author 		:  Rijia Khatun
* @date 		:  01/7/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/

public class SSP_TMemberDataContract {
    public class SSPProgram {
        public String ProgramCode;
        private String[] ProgramCode_type_info = new String[]{'ProgramCode','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'ProgramCode'};
    }
    public class ArrayOfSSPIndividual {
        public SSP_TMemberDataContract.SSPIndividual[] SSPIndividual;
        private String[] SSPIndividual_type_info = new String[]{'SSPIndividual','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'SSPIndividual'};
    }
    public class SSPIndividual {
        public Boolean AppliedForCC;
        public Boolean AppliedForKC;
        public Boolean AppliedForKTAP;
        public Boolean AppliedForMA;
        public Boolean AppliedForQP;
        public Boolean AppliedForSAFE;
        public Boolean AppliedForSNAP;
        public Boolean AppliedForSS;
        public Long DependentIndividualId;
        public String HouseholdStatus;
        public Long IndividualAge;
        public Long IndividualId;
        public Boolean IsHeadOfHousehold;
        public String LivingArrangement;
        public Boolean PurchasesAndPreparesTogether;
        public SSP_TMemberDataContract.ArrayOfSSPRelationship Relationship;
        public String TaxFilingStatus;
        private String[] AppliedForCC_type_info = new String[]{'AppliedForCC','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] AppliedForKC_type_info = new String[]{'AppliedForKC','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] AppliedForKTAP_type_info = new String[]{'AppliedForKTAP','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] AppliedForMA_type_info = new String[]{'AppliedForMA','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] AppliedForQP_type_info = new String[]{'AppliedForQP','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] AppliedForSAFE_type_info = new String[]{'AppliedForSAFE','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] AppliedForSNAP_type_info = new String[]{'AppliedForSNAP','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] AppliedForSS_type_info = new String[]{'AppliedForSS','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] DependentIndividualId_type_info = new String[]{'DependentIndividualId','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] HouseholdStatus_type_info = new String[]{'HouseholdStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] IndividualAge_type_info = new String[]{'IndividualAge','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] IndividualId_type_info = new String[]{'IndividualId','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] IsHeadOfHousehold_type_info = new String[]{'IsHeadOfHousehold','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] LivingArrangement_type_info = new String[]{'LivingArrangement','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] PurchasesAndPreparesTogether_type_info = new String[]{'PurchasesAndPreparesTogether','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] Relationship_type_info = new String[]{'Relationship','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] TaxFilingStatus_type_info = new String[]{'TaxFilingStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'AppliedForCC','AppliedForKC','AppliedForKTAP','AppliedForMA','AppliedForQP','AppliedForSAFE','AppliedForSNAP','AppliedForSS','DependentIndividualId','HouseholdStatus','IndividualAge','IndividualId','IsHeadOfHousehold','LivingArrangement','PurchasesAndPreparesTogether','Relationship','TaxFilingStatus'};
    }
    public class ArrayOfSSPMemberStatus {
        public SSP_TMemberDataContract.SSPMemberStatus[] SSPMemberStatus;
        private String[] SSPMemberStatus_type_info = new String[]{'SSPMemberStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'SSPMemberStatus'};
    }
    public class SSPMemberStatus {
        public Integer IndividualID;
        public String MemberStatus;
        public String MemberStatusReasonCode;
        private String[] IndividualID_type_info = new String[]{'IndividualID','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','false'};
        private String[] MemberStatus_type_info = new String[]{'MemberStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] MemberStatusReasonCode_type_info = new String[]{'MemberStatusReasonCode','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'IndividualID','MemberStatus','MemberStatusReasonCode'};
    }
    public class SSPCaseResponse {
        public Integer CaseNumber;
        public Boolean IsSuccess;
        public String Message;
        public SSP_TMemberDataContract.ArrayOfSSPMemberStatus memberStatuses;
        private String[] CaseNumber_type_info = new String[]{'CaseNumber','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','false'};
        private String[] IsSuccess_type_info = new String[]{'IsSuccess','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','false'};
        private String[] Message_type_info = new String[]{'Message','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] memberStatuses_type_info = new String[]{'memberStatuses','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'CaseNumber','IsSuccess','Message','memberStatuses'};
    }
    public class CaseRequest {
        public Integer CaseNumber;
        public DateTime EdbcRunDate;
        public SSP_TMemberStubClass.ArrayOfint IndividualIds;
        private String[] CaseNumber_type_info = new String[]{'CaseNumber','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','false'};
        private String[] EdbcRunDate_type_info = new String[]{'EdbcRunDate','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','false'};
        private String[] IndividualIds_type_info = new String[]{'IndividualIds','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'CaseNumber','EdbcRunDate','IndividualIds'};
    }
    public class ArrayOfSSPRelationship {
        public SSP_TMemberDataContract.SSPRelationship[] SSPRelationship;
        private String[] SSPRelationship_type_info = new String[]{'SSPRelationship','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'SSPRelationship'};
    }
    public class SSPRelationship {
        public Long IndividualId;
        public Long ReferenceIndividualId;
        public String RelationshipTypeCode;
        private String[] IndividualId_type_info = new String[]{'IndividualId','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] ReferenceIndividualId_type_info = new String[]{'ReferenceIndividualId','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] RelationshipTypeCode_type_info = new String[]{'RelationshipTypeCode','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'IndividualId','ReferenceIndividualId','RelationshipTypeCode'};
    }
    public class ArrayOfSSPProgram {
        public SSP_TMemberDataContract.SSPProgram[] SSPProgram;
        private String[] SSPProgram_type_info = new String[]{'SSPProgram','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'SSPProgram'};
    }
    public class SSPCaseRequest {
        public Integer ApplicationNumber;
        public String CaseMode;
        public Integer CaseNumber;
        public String CaseStatus;
        public SSP_TMemberDataContract.ArrayOfSSPIndividual Individuals;
        public SSP_TMemberDataContract.ArrayOfSSPProgram ProgramCodes;
        public String SourceSystem;
        public DateTime SystemDate;
        private String[] ApplicationNumber_type_info = new String[]{'ApplicationNumber','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','false'};
        private String[] CaseMode_type_info = new String[]{'CaseMode','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] CaseNumber_type_info = new String[]{'CaseNumber','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','false'};
        private String[] CaseStatus_type_info = new String[]{'CaseStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] Individuals_type_info = new String[]{'Individuals','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] ProgramCodes_type_info = new String[]{'ProgramCodes','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','true'};
        private String[] SourceSystem_type_info = new String[]{'SourceSystem','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'0','1','true'};
        private String[] SystemDate_type_info = new String[]{'SystemDate','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Custom','true','false'};
        private String[] field_order_type_info = new String[]{'ApplicationNumber','CaseMode','CaseNumber','CaseStatus','Individuals','ProgramCodes','SourceSystem','SystemDate'};
    }
    public class CaseProgramMemeberStatus {
        public Integer IndividualID;
        public String MemberReason;
        public String MemberStatus;
        public String ProgramCode;
        private String[] IndividualID_type_info = new String[]{'IndividualID','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','false'};
        private String[] MemberReason_type_info = new String[]{'MemberReason','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] MemberStatus_type_info = new String[]{'MemberStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] ProgramCode_type_info = new String[]{'ProgramCode','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service','true','false'};
        private String[] field_order_type_info = new String[]{'IndividualID','MemberReason','MemberStatus','ProgramCode'};
    }
    public class EDCustomDictionary {
        public String Key;
        public String Value;
        private String[] Key_type_info = new String[]{'Key','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] Value_type_info = new String[]{'Value','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service','true','false'};
        private String[] field_order_type_info = new String[]{'Key','Value'};
    }
    public class CaseResponse {
        public SSP_TMemberDataContract.ArrayOfCaseMemeberStatus CaseMemeberStatusModels;
        public Integer CaseNumber;
        public SSP_TMemberDataContract.CaseProgramMemeberStatus CaseProgramMemeberStatusModels;
        public Integer EligibilityTransactionID;
        public SSP_TMemberDataContract.EDExceptionDetails ErrorDetails;
        public Boolean IsSuccess;
        public String Message;
        private String[] CaseMemeberStatusModels_type_info = new String[]{'CaseMemeberStatusModels','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] CaseNumber_type_info = new String[]{'CaseNumber','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','false'};
        private String[] CaseProgramMemeberStatusModels_type_info = new String[]{'CaseProgramMemeberStatusModels','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] EligibilityTransactionID_type_info = new String[]{'EligibilityTransactionID','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','false'};
        private String[] ErrorDetails_type_info = new String[]{'ErrorDetails','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] IsSuccess_type_info = new String[]{'IsSuccess','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','false'};
        private String[] Message_type_info = new String[]{'Message','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service','true','false'};
        private String[] field_order_type_info = new String[]{'CaseMemeberStatusModels','CaseNumber','CaseProgramMemeberStatusModels','EligibilityTransactionID','ErrorDetails','IsSuccess','Message'};
    }
    public class ArrayOfCaseMemeberStatus {
        public SSP_TMemberDataContract.CaseMemeberStatus[] CaseMemeberStatus;
        private String[] CaseMemeberStatus_type_info = new String[]{'CaseMemeberStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service','true','false'};
        private String[] field_order_type_info = new String[]{'CaseMemeberStatus'};
    }
    public class CaseMemeberStatus {
        public Integer CaseNumber;
        public Integer IndividualID;
        public String MemberStatus;
        public String MemberStatusReasonCode;
        public String MemberStatusReasonDescription;
        private String[] CaseNumber_type_info = new String[]{'CaseNumber','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','false'};
        private String[] IndividualID_type_info = new String[]{'IndividualID','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','false'};
        private String[] MemberStatus_type_info = new String[]{'MemberStatus','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] MemberStatusReasonCode_type_info = new String[]{'MemberStatusReasonCode','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] MemberStatusReasonDescription_type_info = new String[]{'MemberStatusReasonDescription','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service','true','false'};
        private String[] field_order_type_info = new String[]{'CaseNumber','IndividualID','MemberStatus','MemberStatusReasonCode','MemberStatusReasonDescription'};
    }
    public class EDExceptionDetails {
        public SSP_TMemberDataContract.ArrayOfEDCustomDictionary AdditionalErrorInformation;
        public String ErrorCode;
        private String[] AdditionalErrorInformation_type_info = new String[]{'AdditionalErrorInformation','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] ErrorCode_type_info = new String[]{'ErrorCode','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service','true','false'};
        private String[] field_order_type_info = new String[]{'AdditionalErrorInformation','ErrorCode'};
    }
    public class ArrayOfEDCustomDictionary {
        public SSP_TMemberDataContract.EDCustomDictionary[] EDCustomDictionary;
        private String[] EDCustomDictionary_type_info = new String[]{'EDCustomDictionary','http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Ky.Hbe.Edbc.HHMBR.Data.Contracts.Service','true','false'};
        private String[] field_order_type_info = new String[]{'EDCustomDictionary'};
    }
}