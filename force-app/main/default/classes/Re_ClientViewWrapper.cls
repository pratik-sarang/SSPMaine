/**
* Class Name    : Re_ClientViewWrapper
* Owner         : DELOITTE
* Created Date  : 06/10/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  10/06/2019  SUYASH       Initial Version
*  
**/
public class Re_ClientViewWrapper {

	 public ResponseError errorData;
	 public HouseHoldData houseHoldMembersData;
	 public IndividualData memberData;
	 public Integer matchResult;


	public class ResponseError{
		public string errorCode;
		public String errorDescription;    
	 }
	 public class HouseholdComposition {
		 public string firstName;
		 public string lastName;
		 public string gender;
		 public Date dob;
		 public String relationship; 
	 }
	 public class HouseHoldData{
		 public  List<HouseholdComposition> houseHoldMembers;
	 }

	 public class IndividualData{
		 public String individualId;
		 public String firstName;
		 public String lastName;
		 public String gender;
		 public Date dob;
		 public ClientAddress addressData;
		 public CommunicationData contactData;
		 public EnrolledPrograms programData;
	 }
	 public class ClientAddress{
		 public String addressType ;
		 public String addressLine1;
		 public String addressLine2;
         public String city;
		 public String county;
		 public String state;
		 public String zipCode;
	 }
	 public class CommunicationData{
		 public String preferredContactMethodCode ;
		 public String email;
		 public String phoneNumber;
	 }
	public class EnrolledPrograms {
		 public List<Programs> programs;
	 }
	 public class Programs{
		 public String assistanceType;
		 public String eligibilityBeginDate;
		 public String eligibilityEndDate;
		 public String renewalDate;
	 }

	
	public static Re_ClientViewWrapper parse(String json) {
		return (Re_ClientViewWrapper) System.JSON.deserialize(json, Re_ClientViewWrapper.class);
	}
}