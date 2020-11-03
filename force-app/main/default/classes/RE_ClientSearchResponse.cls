/**
* Class Name    : RE_ClientSearchResponse
* Owner         : DELOITTE
* Created Date  : 10/24/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  10/22/2019  Payal Dubela       Initial Version
* */
public class RE_ClientSearchResponse {

    public IndResponse indSearchResponse;

    public class IndResponse{
        public Integer matchResult;
        public List<ClientData> memberData;
        public ResponseError errorData;
    }

    public class ClientData{
       public integer individualId;
       public integer mciId;
       public String firstName;
       public String lastName;
       public String gender;
       public Date dob;
       public String email;
       public String phoneNumber;
       public String preferredContactMethodCode;
    }
    public class ResponseError{
        public string errorCode;
        public String errorDescription;    
    }

}