/*
* classname 		: SSP_ExpeditedSnapBenefitWrapper
* @description 		: This is the Wrapper class for SSP_ExpeditedSnapBenefitCtrl class.
* @author 			: Sai Kiran
* @date 			: 01/10/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/

public class SSP_ExpeditedSnapBenefitWrapper {
    @AuraEnabled public String sApplicationId {get;set;}
    @AuraEnabled public Decimal sGrossIncAmount {get;set;}
    @AuraEnabled public Decimal sCashSavingAmount {get;set;}
    @AuraEnabled public String bShelterExpExceedIncomeResourcesToggle {get;set;}
    @AuraEnabled public String bDestituteFarmOrMigrantHouseholdToggle {get;set;}

}