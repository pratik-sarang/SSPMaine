public class SSP_MCIMergedServiceResponeWrapper	 {
    public string MatchStatus;
    public string ErrorCode;
    public string ErrorMessage;
    public boolean isApplicationBlocked;
    public string CaseNumber;
    public string Mode;
    public string Applicationnumber;
    public string ViewName;
    public string IndividualId;
    public string BlockedCaseNumber; 
    public boolean isMemberFileCleared;
    public List<SSP_Member__c> lstOfSSPMembers;
    public List<SSP_ApplicationIndividual__c> lstOfApplicationIndividuals;
    public List<SSP_Application__c> lstofApplications;
    public List<LOG_LogMessage__c> lstofLogMessages;
    
}