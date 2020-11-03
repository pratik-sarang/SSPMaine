public class SSP_MCIMergedServiceRequestWrapper {
 
    public string sourceSystemName;
    public Integer sourceIndividualId; /* It is indivudal Id of Member. In case of HouseHold, HOHId and sourceIndividualId value is same.  */
    public string firstName;
    public string middleName;
    public string lastName;
    public string DOB;
    public string SSN;
    public string gender;
    public Integer HOHId;/* It is IndividualId of HouseHold*/
    public boolean isHeadOfHousehold; /* If you are calling for HOH, then make it as true, for members always fales*/ 
    public boolean IscitizenshipVerified;
    public boolean isSSNValidated;
    public Integer caseNumber;
    public Integer applicationNumber;
    public string userRole;
    public string program; /* Selected Programs*/
    public string screenName;
    public string mode;
    public boolean ssnRetryFlag; /* This field will be used in SSN retry Mechanisam, Initially we need to send as a true. If you got SSN Failure, we always need to send false*/
    public boolean isMemberFileCleared; 
}