/*
* Classname         :  SSP_VCIRequestWrapper
* @description  :  This class is the request wrapper class for AHI
* @author       :  Rijia Khatun
* @date         :  03/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
  Rijia Khatun        03/06/2020          Initial Version
**/
public class SSP_VCIRequestWrapper {
    public String CaseNumber;   
    public String ApplicationNumber;  
    public cls_VerifyCurrentIncomeIndividuals VerifyCurrentIncomeIndividuals;
    
    public class cls_VerifyCurrentIncomeIndividuals {
      public cls_VerifyCurrentIncomeIndividual[] VerifyCurrentIncomeIndividual;
    }
    
    public class cls_VerifyCurrentIncomeIndividual {
        public String IndividualId;
        public String PersonBirthDate;  
        public String PersonGivenName;  
        public String PersonMiddleName;
        public String PersonSSNIdentification; 
        public String PersonSurName;  
    }
}
