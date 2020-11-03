/*
* classname     : SFDCNumberValidationRuleTest
* @description  : This class is use to cover class of SFDCNumberValidationRule
* @author       : Payal Dubela
* @date         : 08/23/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SFDCNumberValidationRuleTest {
    @testSetup static void setup() {
        
    }
     @isTest
    public static void testMethod1(){
       SFDCValidator stvr= new SFDCValidator();
       stvr.getValidDouble('200',  0, 5000000, false);
    }
    @isTest
    public static void testMethod2(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidDouble('200',5000,500, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('maxValue must be larger than minValue'),true);
        }
       
    }
     @isTest
    public static void testMethod3(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidDouble(null,500,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Input number required'),true);
        }
        try{
            stvr.getValidDouble(null,500,5000, true);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Input number required'),true);
        }
       
    }
    @isTest
    public static void testMethod4(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidDouble('200',1000,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Invalid number input must be between'),true);
        }
       
    }
    @isTest
    public static void testMethod5(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidDouble('20000',1000,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Invalid number input must be between'),true);
        }
       
    }
    @isTest
    public static void testMethod6(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidDouble('str',1000,5000, false);
            stvr.getValidDouble('123.12',1000,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Invalid number input'),true);
        }
       
    }

}