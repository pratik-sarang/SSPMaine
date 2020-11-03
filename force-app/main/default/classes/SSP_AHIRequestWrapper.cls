/*
* Classname         :  SSP_AHIRequestWrapper
* @description  :  This class is the request wrapper class for AHI
* @author       :  Rijia Khatun
* @date         :  02/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
  Rijia Khatun        02/05/2020          Initial Version
**/
public class SSP_AHIRequestWrapper {
    public SSP_AHIRequestWrapper() {
    } 
    public IndividualInformationListClass IndividualInformationList;
    public String RequestId;    
    public String KeyIdentifier;    
    public String KeyValue; 
    public class IndividualInformationListClass {
      public List<IndividualInformation> IndividualInformation;
    }
    public class IndividualInformation {
      public String IndividualId; 
      public String PersonGivenName;
      public String PersonMiddleName; 
      public String PersonSSNIdentification;
      public String PersonSurName;
      public String TypeOfTaxFiler; 
    }
}