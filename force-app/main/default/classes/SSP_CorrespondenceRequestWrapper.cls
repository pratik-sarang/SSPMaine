/**
* Class Name    : CorrespondenceRequestWrapper
* Owner         : DELOITTE
* Created Date  : 28/11/2019
* Description   : Wrapper Class to hold correspondence Request
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          Description                                                         
*  ----------  --------------     -------------------------------------------------------------------
*  11/12/2019  Rajeev Kumar    			Initial Version
* 3/6/2020    Kommana Lova Durga Prasad    Initial Version
*/
public with sharing class SSP_CorrespondenceRequestWrapper {
    public string Systemdate;
    public Integer AgencyEmployeeId;
    public Integer AgencyId;
    public Integer ApplicationNumber;
    public Integer CaseNumber;
    public String CorrespondenceCode;
    public String CreatedDate;	
    public String CreatedUserId;
    public String DmsDocumentId;
    public String DocumentType;
    public Integer DoiAgencyId;   
    public Integer DoiAgentId;
    public Integer EdgNumber;
    public Integer EdgTraceId;
    public Integer EmployeeId;
    public Integer GeneratedDocumentId;
    public Integer IndividualId;
    public Integer InvalidTriggerId;
    public boolean IsDmsError;
    public boolean IsEsigned;
    public boolean IsHpExstreamError;
    public string MiscellaneousParameters;
    public String PrintMode;
    public string ProgramCode;
    public Integer RecipientId;
    public Integer RepresentativeId;
    public Integer ReprintRequestTriggerId;
    public String RequestTriggerStatusCode;
    public String TriggerSourceCode;	
    public String UpdatedDate;	
    public String UpdatedUserId;
    public boolean ViaPreProcessor; 
    public List<MiscellaneousParametersWrapper> MiscellaneousParametersList;	
    public Integer ClaimNumber;
    public boolean IsPrimary;
    public Integer PrimaryGeneratedDocumentId;
    public boolean RequiresPreProcessing;
    public Integer HearingRequestID;
    public Integer GeneratedLiveDocumentID;
    public Integer PageCount;
    public Integer LastAccessUserId;
    public Boolean IsExcludedFromGenerateDocument;
    public String KYHbeConnectionString;
    public String Reqtype;	
    
    public class MiscellaneousParametersWrapper {
        public String GroupIdentifier;	
        public String ParamName;	
        public String ParamValue;	
    }
    
    /*
* Method Name          : CorrespondenceRequestWrapper
* Description          : Default Constructor
*/
    public SSP_CorrespondenceRequestWrapper(string CorrespondenceCode) {        
        if(CorrespondenceCode == 'SSP-001'){
            this.Systemdate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.AgencyEmployeeId = 0;
            this.AgencyId = 0;
            this.ApplicationNumber = 0;
            this.CaseNumber = 0;
            this.CorrespondenceCode = 'SSP-001';
            this.CreatedDate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.CreatedUserId = userinfo.getUserName();
            this.DocumentType = 'APE';
            this.DoiAgencyId = 0;
            this.DoiAgentId = 0;
            this.EdgNumber = 0;
            this.EdgTraceId = 0;
            this.EmployeeId = 0;
            this.GeneratedDocumentId = 0;
            this.IndividualId = 0;
            this.InvalidTriggerId = 0;
            this.IsDmsError = false;
            this.IsEsigned = false;
            this.IsHpExstreamError = false; 
            this.PrintMode = 'BP';
            this.RecipientId = 0;
            this.RepresentativeId = 0;
            this.ReprintRequestTriggerId = 0;
            this.RequestTriggerStatusCode = 'NEW';
            this.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
            this.UpdatedDate =  string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss')); 
            this.UpdatedUserId =  userinfo.getUserName();
            this.ViaPreProcessor = false;
            this.ClaimNumber = 0;
            this.IsPrimary = false;
            this.PrimaryGeneratedDocumentId = 0;
            this.RequiresPreProcessing = false;
            this.HearingRequestID = 0;
            this.GeneratedLiveDocumentID = 0;
            this.PageCount = 0;
            this.LastAccessUserId = 0;
            this.IsExcludedFromGenerateDocument = false;
            this.Reqtype = 'InsertCorrespondenceTrigger'; 
        }
        else if(CorrespondenceCode == 'HBE-016'){
           
            this.Systemdate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.AgencyEmployeeId = 0;
            this.AgencyId = 0;
            this.ApplicationNumber = 0;
            this.CaseNumber = 0;
            this.CorrespondenceCode = 'HBE-016';
            this.CreatedDate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.CreatedUserId = userinfo.getUserName();
            this.DoiAgencyId = 0;
            this.DoiAgentId = 0;
            this.EdgNumber = 0;
            this.EdgTraceId = 0;
            this.EmployeeId = 0;
            this.GeneratedDocumentId = 0;
            this.IndividualId = 0;
            this.InvalidTriggerId = 0;
            this.IsDmsError = false;
            this.IsEsigned = false;
            this.IsHpExstreamError = false; 
            this.PrintMode = 'BP';
            this.RecipientId = 0;
            this.RepresentativeId = 0;
            this.ReprintRequestTriggerId = 0;
            this.RequestTriggerStatusCode = 'NEW';
            this.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
            this.UpdatedDate =  string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss')); 
            this.UpdatedUserId =  userinfo.getUserName();
            this.ViaPreProcessor = false;
            this.ClaimNumber = 0;
            this.IsPrimary = false;
            this.PrimaryGeneratedDocumentId = 0;
            this.RequiresPreProcessing = false;
            this.HearingRequestID = 0;
            this.GeneratedLiveDocumentID = 0;
            this.PageCount = 0;
            this.LastAccessUserId = 0;
            this.IsExcludedFromGenerateDocument = false;
            this.Reqtype = 'InsertCorrespondenceTrigger'; 
        }
        else if(CorrespondenceCode == 'HBE-017'){
           
            this.Systemdate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.AgencyEmployeeId = 0;
            this.AgencyId = 0;
            this.ApplicationNumber = 0;
            this.CaseNumber = 0;
            this.CorrespondenceCode = 'HBE-017';
            this.CreatedDate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.CreatedUserId = userinfo.getUserName();
            this.DoiAgencyId = 0;
            this.DoiAgentId = 0;
            this.EdgNumber = 0;
            this.EdgTraceId = 0;
            this.EmployeeId = 0;
            this.GeneratedDocumentId = 0;
            this.IndividualId = 0;
            this.InvalidTriggerId = 0;
            this.IsDmsError = false;
            this.IsEsigned = false;
            this.IsHpExstreamError = false; 
            this.PrintMode = 'BP';
            this.RecipientId = 0;
            this.RepresentativeId = 0;
            this.ReprintRequestTriggerId = 0;
            this.RequestTriggerStatusCode = 'NEW';
            this.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
            this.UpdatedDate =  string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss')); 
            this.UpdatedUserId =  userinfo.getUserName();
            this.ViaPreProcessor = false;
            this.ClaimNumber = 0;
            this.IsPrimary = false;
            this.PrimaryGeneratedDocumentId = 0;
            this.RequiresPreProcessing = false;
            this.HearingRequestID = 0;
            this.GeneratedLiveDocumentID = 0;
            this.PageCount = 0;
            this.LastAccessUserId = 0;
            this.IsExcludedFromGenerateDocument = false;
            this.Reqtype = 'InsertCorrespondenceTrigger'; 
        }
        else if(CorrespondenceCode == 'HBE-055'){
           
            this.Systemdate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.AgencyEmployeeId = 0;
            this.AgencyId = 0;
            this.ApplicationNumber = 0;
            this.CaseNumber = 0;
            this.CorrespondenceCode = 'HBE-055';
            this.CreatedDate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            this.CreatedUserId = userinfo.getUserName();
            this.DoiAgencyId = 0;
            this.DoiAgentId = 0;
            this.EdgNumber = 0;
            this.EdgTraceId = 0;
            this.EmployeeId = 0;
            this.GeneratedDocumentId = 0;
            this.IndividualId = 0;
            this.InvalidTriggerId = 0;
            this.IsDmsError = false;
            this.IsEsigned = false;
            this.IsHpExstreamError = false; 
            this.PrintMode = 'LP';
            this.ProgramCode = 'SN';
            this.RecipientId = 0;
            this.RepresentativeId = 0;
            this.ReprintRequestTriggerId = 0;
            this.RequestTriggerStatusCode = 'NEW';
            this.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
            this.UpdatedDate =  string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss')); 
            this.UpdatedUserId =  userinfo.getUserName();
            this.ViaPreProcessor = false;
            this.ClaimNumber = 0;
            this.IsPrimary = false;
            this.PrimaryGeneratedDocumentId = 0;
            this.RequiresPreProcessing = false;
            this.HearingRequestID = 0;
            this.GeneratedLiveDocumentID = 0;
            this.PageCount = 0;
            this.LastAccessUserId = 0;
            this.IsExcludedFromGenerateDocument = false;
            this.Reqtype = 'GenerateCorrespondence'; 
        }
        
    }
}
