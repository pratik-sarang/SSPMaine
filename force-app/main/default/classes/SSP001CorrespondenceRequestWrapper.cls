public class SSP001CorrespondenceRequestWrapper{
    public string Action;
    public string ActionCode;
	public MiscellaneousParametersListWrapper MiscellaneousParametersList;
	public Integer ApplicationNumber;	
	public String CorrespondenceCode;	
	public String CreatedDate;	
	public String CreatedUserId;	
	public String DocumentType;	
	public Integer IndividualId;	
    public String PrintMode;	
	public String RequestTriggerStatusCode;	
	public String TriggerSourceCode;	
	public String UpdatedDate;	
	public String UpdatedUserId;	
	public String Reqtype;	
	public class MiscellaneousParametersListWrapper {
		public List<MiscellaneousParametersTableWrapper> MiscellaneousParametersTable;
	}
	public class MiscellaneousParametersTableWrapper {
		public String GroupIdentifier;	
		public String ParamName;	
		public String ParamValue;	
	}
	public static SSP001CorrespondenceRequestWrapper parse(String json){
		return (SSP001CorrespondenceRequestWrapper) System.JSON.deserialize(json, SSP001CorrespondenceRequestWrapper.class);
	}
    public SSP001CorrespondenceRequestWrapper(){
        this.PrintMode = 'BP';
        this.Reqtype = 'InsertCorrespondenceTrigger';
        this.RequestTriggerStatusCode = 'NEW';
        this.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
        this.DocumentType = 'APE';
        this.CorrespondenceCode = 'SSP-001';
        this.CreatedDate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        this.UpdatedDate =  string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
    }
    
}