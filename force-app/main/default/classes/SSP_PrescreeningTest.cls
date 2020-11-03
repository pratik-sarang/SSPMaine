@isTest
public class SSP_PrescreeningTest {
    
    //Test KTAP Eligible Flow
    public static testmethod void KTAPEligibleTest(){
        
        SSP_PreScreeningData userInput= new SSP_PreScreeningData();
        userInput.noOfPeopleInHh = 4;
        userInput.isAnyoneChild = 'Y';
        userInput.checkingSavingIncome = 0;
        userInput.grossIncome = 0;
        userInput.monthlyChildCareExpense = 500;
        userInput.childSupportExpense = 500;
    	
        test.startTest();
        userInput = SSP_PrescreeningService.determineEligibility(userInput);
        test.stopTest();
        
        system.assertEquals(userInput.ktapResult, 'Eligible');
        
    }
    
    //Test KTAP NeedMoreInfo Flow
    public static testmethod void KTAPNeedMoreInfoTest(){
        
        SSP_PreScreeningData userInput= new SSP_PreScreeningData();
        userInput.noOfPeopleInHh = 4;
        userInput.isAnyoneChild = 'Y';
        userInput.checkingSavingIncome = 3000;
        userInput.grossIncome = 2500;
        userInput.monthlyChildCareExpense = 500;
        userInput.childSupportExpense = 500;
    	
        test.startTest();
        userInput = SSP_PrescreeningService.determineEligibility(userInput);
        test.stopTest();
        
        system.assertEquals(userInput.ktapResult, 'NeedMoreInfo');
        
    }
    
    public static testmethod void SNAPEligibleMigrantTest(){
        
         
        SSP_PreScreeningData userInput= new SSP_PreScreeningData();
        userInput.isAnyoneMigrant = 'Y';

    	
        test.startTest();
        userInput = SSP_PrescreeningService.determineEligibility(userInput);
        test.stopTest();
        
        system.assertEquals(userInput.snapResult, 'Eligible');
        
    }

}