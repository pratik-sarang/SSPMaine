/* Classname     :  SSP_UpdateAgentAssisterRequestWrapper
* @description   :  This class is the request wrapper for Update Agent and Assister
* @author     :  Rijia Khatun
* @date     :  21/4/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName        MM/DD/YYYY        A Brief Description 
                   about the Change
**/
public class SSP_UpdateAgentAssisterRequestWrapper {
    public  SSP_UpdateAgentAssisterRequestWrapper(){}
    public String Operation= SSP_GlobalConstants.UPDATE_ALL; 
    public List<cls_DCAgencyIndividualCaseAssociationModel> DCAgencyIndividualCaseAssociationModel;
    
    public class cls_AuthRepDetails {
        public cls_AuthRepDetailsArray[] AuthRepDetails;
    }
    public class cls_AuthRepDetailsArray  {
        public String AuthRepFirstname; 
        public String AuthRepMiddleIntial;
        public String AuthRepLastName;
        public cls_ClientAddress AuthRepAddress;
        public Integer RepresentativeId = 0;
        public String AuthRepDeliveryPreference;
        public String AuthRepLanguagePreference;
    }
    public class cls_ClientAddress {
        public String AddressLine1;
        public String AddressLine2; 
        public String City; 
        public String StateCode; 
        public String ZipCode5;
        public String DeliveryPreference;
        public String LanguagePreference; 
    }

    public class cls_DCAgencyIndividualCaseAssociationModel {
        public String AgencyId;
        public String CaseNumber;   
        public String IndividualId; 
        public String AgencyEmployeeId; 
        public String IndividualContactPhone;   
        public String DoiAgentId;
        public String DoiAgencyId;
        public String IsAgentUpdate = SSP_GlobalConstants.FALSE_VAL; 
        public String IsAssisterUpdate= SSP_GlobalConstants.FALSE_VAL; 
        public String NewAssignment;
        public String LoggedInUserId;

        public Boolean IsTriggeredbyAgencyAdmin = false; //Keep true only to create correspondence (HBE18 implementation)

        public Integer ApplicationNumber = 0; 
        public String ClientFirstName; 
        public String ClientMI; 
        public String ClientLastName; 
        public cls_ClientAddress ClientAddress;
        public cls_AuthRepDetails AuthRepDetails;
    }
}