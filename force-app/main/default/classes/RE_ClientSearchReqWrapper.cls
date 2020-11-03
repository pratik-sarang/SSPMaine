public class RE_ClientSearchReqWrapper {
    public RequestData indSearchRequest;

    public class RequestData{
        public String firstName;
        public String lastName;
        public String dob;
        public String Individualid;
        public String CaseNumber;
        public String SSN;
        public String SearchType;
        
        public RequestData(String firstName,String lastName,String dob, String searchType){
            this.firstName=firstName;
            this.lastName=lastName;
            this.dob=dob;
            this.SearchType = searchType;
        }

        public RequestData(String searchValue, String searchType)
        {
            this.SearchType = searchType;
            if(searchType == 'Individualid')
            {
                this.Individualid=searchValue; 
            }
            else if(searchType == 'CaseNumber')
            {
                this.CaseNumber=searchValue; 
            }
            else if(searchType == 'SSN')
            {
                this.SSN=searchValue; 
            }
        }
    }

}