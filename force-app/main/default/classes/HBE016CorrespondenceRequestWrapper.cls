public class HBE016CorrespondenceRequestWrapper {

	public integer AgencyEmployeeId;
    public integer AgencyId;
    public Integer ApplicationNumber;
    public Integer CaseNumber; 
    public string CorrespondenceCode;
    public string CreatedDate;
    public string CreatedUserId;
    public integer DoiAgencyId;
    public integer DoiAgentId;
    public Integer IndividualId;
    public string MiscellaneousParameters;
    public string PrintMode;
    public string ProgramCode;
    public string RequestTriggerStatusCode;
    public string TriggerSourceCode;
    public string UpdatedDate;
    public string UpdatedUserId;
    public string Reqtype;
    public string AuditUserId;
    
    public static HBE016CorrespondenceRequestWrapper parse(String json){
		return (HBE016CorrespondenceRequestWrapper) System.JSON.deserialize(json, HBE016CorrespondenceRequestWrapper.class);
	}
    public HBE016CorrespondenceRequestWrapper(){
        this.AgencyEmployeeId = 0;
        this.AgencyId = 0;
        this.RequestTriggerStatusCode = 'NEW';
        this.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
        this.PrintMode = 'BP';
        this.CreatedDate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        this.UpdatedDate =  string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        this.Reqtype = 'InsertCorrespondenceTrigger';
    }
    
    
}