/**
 * Class Name    : SSP_RACSelectionDetailsWrapper 
 * Owner         : DELOITTE
 * Created Date  : 03/09/2020
 * Description   : Wrapper Clss for RAC Selections Screen
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  03/09/2020  Rajeev Kumar    Initial Version
 */
public with sharing class SSP_RACSelectionDetailsWrapper {
    
    // Public Attributes
    public List<SSPMember> SSPMember;
    public List<Healthcare> Healthcare;
    public List<Income> Income;
    
    /**
    * Description: Wrapper Class
    */
    public class SSPMember {
        public String  IndividualId;
        public String  FullName;
        public String  BirthDate;
        public String  IsReceivingMedicareBenefitToggle;
        public String  IsUSCitizenToggle;
        public String  HasEmergencyMedicalConditionToggle;
        public String  IsRecoveryFromIllnessOrInjuryToggle;
        public String  IsDisabledToggle;
        public String  IsBlindToggle;
        public String  IsPregnantInLastThreeMonthsToggle;
        public String  GenderCode;
        public String  TemporarilyLivesElsewhereToggle;
        public String  InHomeCareType;
        public String  IsEnrolledInSchool;        
    }
    
    /**
    * Description: Wrapper Class
    */
    public class Income{
        public String IncomeTypeCode;
        public String IncomeSubtypeCode;
        public String IncomePayFrequency;
        public String TotalGrossAmount;
        public String EmployerName;
        public String BusinessTypeCode;
        public String IncomePayDetailHoursPerWeek;
        public String IndividualId;
        public String FullName;        
    }
    
    /**
    * Description: Wrapper Class
    */
    public class Healthcare {
        public String PlanName;
        public String  InsuranceCompanyName;
        public String  TypeOfCoverageCode;
        public String  InsurancePolicyNumber;
        public String  PolicyHolderName;
        public String  PolicyHolderId;       
    }
    
    public SSP_RACSelectionDetailsWrapper(){
        
    }
}